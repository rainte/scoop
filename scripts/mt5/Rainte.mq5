//+------------------------------------------------------------------+
//| Rainte.mq5                                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input group "=== ATR (开启后固定止损失效) ==="
input bool              InpATR            = true;       // ATR
input ENUM_TIMEFRAMES   InpATR_TF         = PERIOD_M1;  // 图表周期
input int               InpSL_ATR_Period  = 14;         // 周期
input double            InpSL_ATR_Mult    = 2;          // 止损 (0=关闭)
input double            InpTrail_ATR_Mult = 0.8;        // 追踪止损 (0=关闭)

input group "=== 固定止损 ==="
input int   InpSL         = 500;    // 止损 (0=关闭)
input int   InpTrailDist  = 200;    // 追踪止损 (0=关闭)

input group "=== 交易 ==="
input int   InpSL_Min     = 200;    // 最小止损
input long  InpMagic      = -1;     // 只处理此magic (-1=全部)

input group "=== 图表 ==="
input bool InpChartStyle  = true;   // 应用图表属性
input bool InpCountdown   = true;   // 显示倒计时

#define CD_OBJ "Countdown"

CTrade  g_trade;
int     g_lastLeft = -1;
ulong   g_pending[];  // 待补 SL 的 posId 队列
int     g_atrHandle = INVALID_HANDLE;
double  g_startBalance = 0.0;
bool    g_halfAlerted = false;

//====================================================================
// OnInit
//====================================================================
int OnInit() {
  EventSetTimer(1);
  g_trade.SetDeviationInPoints(10);
  g_trade.SetTypeFillingBySymbol(_Symbol);
  g_trade.LogLevel(LOG_LEVEL_ERRORS);
  ApplyChartStyle();
  g_atrHandle = iATR(_Symbol, InpATR_TF, InpSL_ATR_Period);
  if(g_atrHandle == INVALID_HANDLE) {
    Print("ATR 句柄创建失败, err=", GetLastError());
    return INIT_FAILED;
  }
  g_startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  g_halfAlerted  = false;
  return INIT_SUCCEEDED;
}

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason) {
  EventKillTimer();
  ObjectDelete(0, CD_OBJ);
  ChartRedraw(0);
}

//====================================================================
// OnTimer
//====================================================================
void OnTimer() {
  DoPendingSL();
  DoTrailing();
  DoCountdown();
  CheckHalfBalanceAlert();
}

//====================================================================
// OnTradeTransaction：只做标记，不碰交易 API
//====================================================================
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &req,
                        const MqlTradeResult  &res) {
  if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
  if(!HistoryDealSelect(trans.deal)) return;
  if(HistoryDealGetInteger(trans.deal, DEAL_ENTRY) != DEAL_ENTRY_IN) return;

  if(InpATR) {
    if(InpSL_ATR_Mult <= 0) return;
  } else {
    if(InpSL <= 0) return;
  }

  ulong posId = (ulong)HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
  if(posId == 0) return;

  int n = ArraySize(g_pending);
  ArrayResize(g_pending, n + 1);
  g_pending[n] = posId;
  PrintFormat("标记待补SL posId=%I64u", posId);
}

//====================================================================
// 补 SL（消费队列，避开竞态）
//====================================================================
void DoPendingSL() {
  for(int k = ArraySize(g_pending) - 1; k >= 0; --k) {
    ulong posId  = g_pending[k];
    ulong ticket = FindTicketById(posId);

    if(ticket == 0) continue;  // 还没同步，保留，下秒再试

    if(!PositionSelectByTicket(ticket)) {
      RemoveAt(g_pending, k);
      continue;
    }
    if(PositionGetString(POSITION_SYMBOL) != _Symbol) {
      RemoveAt(g_pending, k);
      continue;
    }
    if(!PassMagic(PositionGetInteger(POSITION_MAGIC))) {
      RemoveAt(g_pending, k);
      continue;
    }
    if(PositionGetDouble(POSITION_SL) != 0.0) {
      RemoveAt(g_pending, k);
      continue;
    }

    long   type  = PositionGetInteger(POSITION_TYPE);
    double open  = PositionGetDouble(POSITION_PRICE_OPEN);
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    double slDist = InpSL * point;

    if(InpATR) {
      double atr = GetATR();
      if(atr <= 0) return;
      slDist = atr * InpSL_ATR_Mult;
    }

    slDist = fmax(slDist, InpSL_Min * point);

    double sl = NormalizeDouble(type == POSITION_TYPE_BUY
                                ? open - slDist
                                : open + slDist, _Digits);

    if(g_trade.PositionModify(ticket, sl, 0.0)) {
      PrintFormat("补SL OK pos=%I64u sl=%.5f", ticket, sl);
      RemoveAt(g_pending, k);
    } else {
      PrintFormat("补SL FAIL pos=%I64u ret=%u err=%d", ticket, g_trade.ResultRetcode(), GetLastError());
      RemoveAt(g_pending, k);
    }
  }
}

//====================================================================
// 追踪止损
//====================================================================
void DoTrailing() {
  if(InpATR) {
    if(InpTrail_ATR_Mult <= 0) return;
  } else {
    if(InpTrailDist <= 0) return;
  }

  double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  double ask   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double dist  = InpTrailDist * point;

  if(InpATR) {
    double atr = GetATR();
    if(atr <= 0) return;
    dist = atr * InpTrail_ATR_Mult;
  }

  dist = fmax(dist, InpSL_Min * point);

  for(int i = PositionsTotal() - 1; i >= 0; --i) {
    ulong t = PositionGetTicket(i);
    if(t == 0 || !PositionSelectByTicket(t)) continue;
    if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
    if(!PassMagic(PositionGetInteger(POSITION_MAGIC))) continue;

    long   pt   = PositionGetInteger(POSITION_TYPE);
    double open = PositionGetDouble(POSITION_PRICE_OPEN);
    double sl   = PositionGetDouble(POSITION_SL);
    double tp   = PositionGetDouble(POSITION_TP);
    double newSL = 0;
    bool move = false;

    if(pt == POSITION_TYPE_BUY) {
      newSL = NormalizeDouble(bid - dist, _Digits);
      move  = (bid - open > dist) && (sl == 0 || newSL > sl);
    } else {
      newSL = NormalizeDouble(ask + dist, _Digits);
      move  = (open - ask > dist) && (sl == 0 || newSL < sl);
    }
    if(move) g_trade.PositionModify(t, newSL, tp);
  }
}

//====================================================================
// 倒计时
//====================================================================
void DoCountdown() {
  if(!InpCountdown) {
    ObjectDelete(0, CD_OBJ);
    return;
  }

  datetime barStart = iTime(_Symbol, _Period, 0);
  int left = (int)(barStart + PeriodSeconds(_Period) - TimeCurrent());
  if(left < 0) left = 0;
  if(left == g_lastLeft) return;
  g_lastLeft = left;

  string text = (left >= 60) ? StringFormat("  %d:%02d", left / 60, left % 60)
                : StringFormat("  %ds", left);
  double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  if(ObjectFind(0, CD_OBJ) < 0) {
    ObjectCreate(0, CD_OBJ, OBJ_TEXT, 0, barStart, price);
    ObjectSetInteger(0, CD_OBJ, OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, CD_OBJ, OBJPROP_COLOR, clrYellow);
    ObjectSetInteger(0, CD_OBJ, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
  } else ObjectMove(0, CD_OBJ, 0, barStart, price);
  ObjectSetString(0, CD_OBJ, OBJPROP_TEXT, text);
}

//====================================================================
// ApplyChartStyle
//====================================================================
void ApplyChartStyle() {
  if(!InpChartStyle) return;
  ChartSetInteger(0, CHART_AUTOSCROLL,          true);
  ChartSetInteger(0, CHART_SHIFT,               true);
  ChartSetInteger(0, CHART_SHOW_OHLC,           false);
  ChartSetInteger(0, CHART_SHOW_ASK_LINE,       true);
  ChartSetInteger(0, CHART_SHOW_BID_LINE,       false);
  ChartSetInteger(0, CHART_SHOW_LAST_LINE,      true);
  ChartSetInteger(0, CHART_SHOW_PERIOD_SEP,     true);
  ChartSetInteger(0, CHART_SHOW_GRID,           true);
  ChartSetInteger(0, CHART_SHOW_VOLUMES,        CHART_VOLUME_TICK);
  ChartSetInteger(0, CHART_SHOW_OBJECT_DESCR,   true);
  ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS,   true);
  ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY,  false);
  ChartRedraw(0);
}

//====================================================================
// FindTicketById
//====================================================================
ulong FindTicketById(ulong posId) {
  for(int i = PositionsTotal() - 1; i >= 0; --i) {
    ulong t = PositionGetTicket(i);
    if(t == 0 || !PositionSelectByTicket(t)) continue;
    if((ulong)PositionGetInteger(POSITION_IDENTIFIER) == posId) return t;
  }
  return 0;
}

//====================================================================
// PassMagic
//====================================================================
bool PassMagic(long m) {
  return InpMagic < 0 || m == InpMagic;
}

//====================================================================
// RemoveAt
//====================================================================
void RemoveAt(ulong &a[], int idx) {
  int n = ArraySize(a);
  for(int i = idx; i < n - 1; ++i) a[i] = a[i + 1];
  ArrayResize(a, n - 1);
}

//====================================================================
// GetATR
//====================================================================
double GetATR() {
  double buf[];
  if(CopyBuffer(g_atrHandle, 0, 0, 1, buf) != 1) return 0.0;
  return buf[0];
}

//====================================================================
// 亏损过半告警
//====================================================================
void CheckHalfBalanceAlert() {
  double equity = AccountInfoDouble(ACCOUNT_EQUITY);
  double limit  = g_startBalance * 0.5;

  // 资金回升到阈值以上，重置告警标记，允许下次再提醒
  if(equity > limit) {
    g_halfAlerted = false;
    return;
  }

  if(!g_halfAlerted) {
    g_halfAlerted = true;
    string msg = "⚠️ 账户净值亏损过半！\n初始资金：" + DoubleToString(g_startBalance, 2) +  "\n当前净值：" + DoubleToString(equity, 2);
    Alert(msg);
  }
}
//+------------------------------------------------------------------+
