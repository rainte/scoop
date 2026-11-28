//+------------------------------------------------------------------+
//| MACD.mq5                                                         |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   5

#property indicator_label1  "MACD"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrRed, clrGreen
#property indicator_width1  2

#property indicator_label2  "DIF"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrWhite
#property indicator_width2  1

#property indicator_label3  "DEA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_width3  1

#property indicator_label4  "Golden"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLime
#property indicator_width4  2

#property indicator_label5  "Dead"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_width5  2

input int InpFast   = 12;
input int InpSlow   = 26;
input int InpSignal = 9;

// 8 个 buffer：5 个绘图 + 3 个计算用（emaF, emaS, deaV 单独存）
double BufHist[], BufColor[], BufDIF[], BufDEA[], BufGold[], BufDead[];
double BufEmaF[], BufEmaS[], BufDEA_C[];

//====================================================================
int OnInit() {
  SetIndexBuffer(0, BufHist,  INDICATOR_DATA);
  SetIndexBuffer(1, BufColor, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(2, BufDIF,   INDICATOR_DATA);
  SetIndexBuffer(3, BufDEA,   INDICATOR_DATA);
  SetIndexBuffer(4, BufGold,  INDICATOR_DATA);
  SetIndexBuffer(5, BufDead,  INDICATOR_DATA);

  // 隐藏计算 buffer，不绘图
  SetIndexBuffer(6, BufEmaF,  INDICATOR_CALCULATIONS);
  SetIndexBuffer(7, BufEmaS,  INDICATOR_CALCULATIONS);
  // 注意：deaV 用 BufDEA 自身递推即可，不再额外开 buffer
  // 但为清晰，把 BufDEA_C 去掉，用 BufDEA[i-1]

  PlotIndexSetInteger(3, PLOT_ARROW, 233);
  PlotIndexSetInteger(4, PLOT_ARROW, 234);
  PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
  PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
  PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0.0);

  IndicatorSetString(INDICATOR_SHORTNAME, StringFormat("EM MACD(%d,%d,%d)", InpFast, InpSlow, InpSignal));
  IndicatorSetInteger(INDICATOR_DIGITS, 5);
  return INIT_SUCCEEDED;
}

//====================================================================
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
  if(rates_total < InpSlow + InpSignal) return 0;

  int start = prev_calculated - 1;
  if(start < 0) start = 0;

  double kF = 2.0 / (InpFast + 1);
  double kS = 2.0 / (InpSlow + 1);
  double kG = 2.0 / (InpSignal + 1);

  for(int i = start; i < rates_total; ++i) {
    if(i == 0) {
      BufEmaF[i] = close[i];
      BufEmaS[i] = close[i];
      BufDIF[i]  = 0;
      BufDEA[i]  = 0;
    } else {
      BufEmaF[i] = close[i] * kF + BufEmaF[i - 1] * (1 - kF);
      BufEmaS[i] = close[i] * kS + BufEmaS[i - 1] * (1 - kS);
      BufDIF[i]  = BufEmaF[i] - BufEmaS[i];
      BufDEA[i]  = BufDIF[i] * kG + BufDEA[i - 1] * (1 - kG);
    }

    BufHist[i]  = (BufDIF[i] - BufDEA[i]) * 2.0;
    BufColor[i] = (BufHist[i] >= 0) ? 0 : 1;

    BufGold[i] = BufDead[i] = 0;
    if(i > 0) {
      if(BufDIF[i - 1] <= BufDEA[i - 1] && BufDIF[i] > BufDEA[i]) BufGold[i] = BufDIF[i];
      if(BufDIF[i - 1] >= BufDEA[i - 1] && BufDIF[i] < BufDEA[i]) BufDead[i] = BufDIF[i];
    }
  }
  return rates_total;
}
//+------------------------------------------------------------------+
