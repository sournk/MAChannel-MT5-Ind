#property copyright   "Denis Kislitsyn"
#property link        "https://kislitsyn.me/peronal/algo"
#property description "Channel indicator around MA"
#property description "Expert advisors often use a channel around standard MAs"
#property description "This indicator builds such a channel and has three buffers: MA, MA Channel Top, and MA Channel Bottom"

#property version     "1.00"
#property icon        "img\\logo\\logo_64.ico"

#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "MA Channel Top"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "MA Channel Bottom"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

input uint                InpPeriod        = 10;           // Period
input uint                InpShift         = 0;            // Shift
input ENUM_MA_METHOD      InpMAMethod      = MODE_SMA;     // Method
input ENUM_APPLIED_PRICE  InpAppliedPrice  = PRICE_CLOSE;  // Apply to
input uint                InpOffsetTopPnt  = 100;          // Offset Top, pnt
input uint                InpOffsetBotPnt  = 100;          // Offset Bottom, pnt

int            IndMAHndl;
double         Buf[], BufTop[], BufBot[];
int            MAPeriod;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
  MAPeriod = (InpPeriod > 0) ? (int)InpPeriod : 10;
  IndMAHndl = iMA(_Symbol, _Period, InpPeriod, InpShift, InpMAMethod, InpAppliedPrice);
  if(IndMAHndl == INVALID_HANDLE) {
    Print("iMA INVALID_HANDLE error");
    return(INIT_FAILED);
  }
  
   SetIndexBuffer(0, Buf, INDICATOR_DATA);
   SetIndexBuffer(1, BufTop, INDICATOR_DATA);
   SetIndexBuffer(2, BufBot, INDICATOR_DATA);
   
   
   //IndicatorSetInteger(INDICATOR_DIGITS, 4);
   IndicatorSetString(INDICATOR_SHORTNAME, "MA(" + IntegerToString(MAPeriod) + ")");
   
   //IndicatorSetInteger(INDICATOR_LEVELS, 1);
   //IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0.0);
   //IndicatorSetString(INDICATOR_LEVELTEXT, 0, "0");
   //IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrRed);
   //IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_SOLID);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
                
  int copied = rates_total - prev_calculated;
  if (prev_calculated == 0)
    copied = rates_total; // при первом вызове — вся история
  else
    copied += 1; // +1 для пересчёта текущего бара
  
  double ma_data[];
  if(CopyBuffer(IndMAHndl, 0, 0, copied, ma_data) <= 0) 
    return 0;
  
  int start = prev_calculated == 0 ? 0 : prev_calculated - 1;
  for (int i = start; i < rates_total; i++) {
    Buf[i]  = ma_data[i - start];
    BufTop[i] = Buf[i] + InpOffsetTopPnt*_Point;
    BufBot[i] = Buf[i] - InpOffsetBotPnt*_Point;
  }
  
  return(rates_total);
}

