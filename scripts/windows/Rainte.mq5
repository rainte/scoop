//+------------------------------------------------------------------+
//|                                                       Rainte.mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.30"

input int    InpSL         = 500;   // 止损点数.
input int    InpTrailDist  = 200;   // 追踪止损.

string InpBarTimeObj = "bar_time"; // 倒计时对象名.

//+------------------------------------------------------------------+
//| OnInit                                                           |
//+------------------------------------------------------------------+
int OnInit() {
  EventSetTimer(1);
  return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnDeinit                                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int r) {
  EventKillTimer();
  ObjectDelete(0, InpBarTimeObj);
}

//+------------------------------------------------------------------+
//| OnTimer                                                          |
//+------------------------------------------------------------------+
void OnTimer() {
  Trail();
  BarCountdown();
}

//+------------------------------------------------------------------+
//| OnTradeTransaction                                               |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {
  if(trans.type != TRADE_TRANSACTION_DEAL_ADD)
    return;
  if(!HistoryDealSelect(trans.deal))
    return;
  if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol)
    return;
  if(HistoryDealGetInteger(trans.deal, DEAL_ENTRY) != DEAL_ENTRY_IN)
    return;

  ulong posId = (ulong)HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
  if(posId == 0 || !PositionSelectByTicket(posId))
    return;
  if(PositionGetDouble(POSITION_SL) != 0.0)
    return;

  long   type  = PositionGetInteger(POSITION_TYPE);
  double open  = PositionGetDouble(POSITION_PRICE_OPEN);
  double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  double sl    = NormalizeDouble(
                   type == POSITION_TYPE_BUY ? open - InpSL * point : open + InpSL * point, _Digits);

  MqlTradeRequest req = {};
  MqlTradeResult  res = {};
  req.action   = TRADE_ACTION_SLTP;
  req.position = posId;
  req.symbol   = _Symbol;
  req.sl       = sl;

  if(!OrderSend(req, res) || res.retcode != TRADE_RETCODE_DONE)
    PrintFormat("补 SL 失败 pos=%I64u retcode=%d err=%d", posId, res.retcode, GetLastError());
}

//+------------------------------------------------------------------+
//| Trail                                                            |
//+------------------------------------------------------------------+
void Trail() {
  if(InpTrailDist <= 0)
    return;

  double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
  double ask   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double dist  = InpTrailDist * point;

  for(int i = PositionsTotal() - 1; i >= 0; i--) {
    ulong t = PositionGetTicket(i);
    if(t == 0 || !PositionSelectByTicket(t))
      continue;
    if(PositionGetString(POSITION_SYMBOL) != _Symbol)
      continue;

    long   pt   = PositionGetInteger(POSITION_TYPE);
    double open = PositionGetDouble(POSITION_PRICE_OPEN);
    double sl   = PositionGetDouble(POSITION_SL);
    double tp   = PositionGetDouble(POSITION_TP);

    double newSL;
    bool   move;

    if(pt == POSITION_TYPE_BUY) {
      newSL = NormalizeDouble(bid - dist, _Digits);
      move  = (bid - open > dist) && (newSL > sl);
    } else {
      newSL = NormalizeDouble(ask + dist, _Digits);
      move  = (open - ask > dist) && (sl == 0.0 || newSL < sl);
    }
    if(!move)
      continue;

    MqlTradeRequest req = {};
    MqlTradeResult  res = {};
    req.action   = TRADE_ACTION_SLTP;
    req.position = t;
    req.symbol   = _Symbol;
    req.sl       = newSL;
    req.tp       = tp;

    if(!OrderSend(req, res) || res.retcode != TRADE_RETCODE_DONE)
      PrintFormat("追踪失败 pos=%I64u retcode=%d", t, res.retcode);
  }
}

//+------------------------------------------------------------------+
//| BarCountdown                                                     |
//+------------------------------------------------------------------+
void BarCountdown() {
  datetime barStart = iTime(_Symbol, _Period, 0);
  int left = (int)(barStart + PeriodSeconds(_Period) - TimeCurrent());
  if(left < 0)
    left = 0;

  string text = (left >= 60)
                ? StringFormat("   %d:%02d", left / 60, left % 60)
                : StringFormat("   %ds", left);

  double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  if(ObjectFind(0, InpBarTimeObj) < 0) {
    if(!ObjectCreate(0, InpBarTimeObj, OBJ_TEXT, 0, barStart, price))
      return;
    ObjectSetInteger(0, InpBarTimeObj, OBJPROP_FONTSIZE, 10);
    ObjectSetInteger(0, InpBarTimeObj, OBJPROP_COLOR, clrYellow);
    ObjectSetInteger(0, InpBarTimeObj, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
  } else {
    ObjectMove(0, InpBarTimeObj, 0, barStart, price);
  }

  ObjectSetString(0, InpBarTimeObj, OBJPROP_TEXT, text);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
