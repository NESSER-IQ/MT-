//+------------------------------------------------------------------+
//| Enhanced RSI Indicator for Momentum Strategies                  |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Advanced RSI indicator with multiple timeframes,   |
//|              dynamic levels, and visual signal detection        |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"
#property description "Enhanced RSI with momentum signals and multi-timeframe analysis"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   8

// RSI Main Line
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

// RSI Signal Line (Smoothed)
#property indicator_label2  "RSI Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

// Overbought Level
#property indicator_label3  "Overbought"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

// Oversold Level
#property indicator_label4  "Oversold"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrLime
#property indicator_style4  STYLE_DOT
#property indicator_width4  1

// Buy Signals
#property indicator_label5  "Buy Signal"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrLime
#property indicator_width5  3

// Sell Signals
#property indicator_label6  "Sell Signal"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_width6  3

// Divergence Lines
#property indicator_label7  "Bullish Divergence"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrLimeGreen
#property indicator_style7  STYLE_DASH
#property indicator_width7  2

#property indicator_label8  "Bearish Divergence"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrCrimson
#property indicator_style8  STYLE_DASH
#property indicator_width8  2

//--- Input Parameters
input group "=== RSI Parameters ==="
input int                InpRSIPeriod = 14;             // RSI Period
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; // Applied Price
input bool               InpUseDynamicLevels = true;    // Use Dynamic Levels
input double             InpOverboughtLevel = 70.0;     // Static Overbought Level
input double             InpOversoldLevel = 30.0;       // Static Oversold Level

input group "=== Signal Detection ==="
input bool               InpDetectSignals = true;       // Detect Entry/Exit Signals
input bool               InpDetectDivergence = true;    // Detect Divergence
input int                InpSignalSmoothPeriod = 3;     // Signal Smoothing Period
input int                InpDivergenceBars = 20;        // Divergence Lookback Bars

input group "=== Multi-Timeframe Analysis ==="
input bool               InpShowMTF = true;             // Show Multi-Timeframe RSI
input ENUM_TIMEFRAMES    InpHigherTimeframe = PERIOD_H4; // Higher Timeframe
input bool               InpMTFSignalsOnly = false;     // Trade Only When MTF Agrees

input group "=== Visual Settings ==="
input bool               InpShowLevels = true;          // Show Overbought/Oversold Levels
input bool               InpShowSignalArrows = true;    // Show Signal Arrows
input bool               InpShowAlerts = true;          // Show Alerts
input bool               InpShowBackground = true;      // Color Background
input color              InpOverboughtColor = C'255,240,240'; // Overbought Background
input color              InpOversoldColor = C'240,255,240';   // Oversold Background

//--- Indicator Buffers
double RSI_Buffer[];
double Signal_Buffer[];
double Overbought_Buffer[];
double Oversold_Buffer[];
double Buy_Signal_Buffer[];
double Sell_Signal_Buffer[];
double Bullish_Div_Buffer[];
double Bearish_Div_Buffer[];

//--- Global Variables
int g_rsi_handle;
int g_ma_signal_handle;
int g_mtf_rsi_handle;
double g_rsi_array[];
double g_signal_array[];
double g_mtf_rsi_array[];
double g_high_array[];
double g_low_array[];
double g_close_array[];

double g_dynamic_overbought = 70.0;
double g_dynamic_oversold = 30.0;
int g_last_signal_bar = -1;
datetime g_last_alert_time = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Set indicator buffers
    SetIndexBuffer(0, RSI_Buffer, INDICATOR_DATA);
    SetIndexBuffer(1, Signal_Buffer, INDICATOR_DATA);
    SetIndexBuffer(2, Overbought_Buffer, INDICATOR_DATA);
    SetIndexBuffer(3, Oversold_Buffer, INDICATOR_DATA);
    SetIndexBuffer(4, Buy_Signal_Buffer, INDICATOR_DATA);
    SetIndexBuffer(5, Sell_Signal_Buffer, INDICATOR_DATA);
    SetIndexBuffer(6, Bullish_Div_Buffer, INDICATOR_DATA);
    SetIndexBuffer(7, Bearish_Div_Buffer, INDICATOR_DATA);
    
    // Set arrow codes for signals
    PlotIndexSetInteger(4, PLOT_ARROW, 233); // Up arrow
    PlotIndexSetInteger(5, PLOT_ARROW, 234); // Down arrow
    
    // Initialize arrays
    ArraySetAsSeries(RSI_Buffer, true);
    ArraySetAsSeries(Signal_Buffer, true);
    ArraySetAsSeries(Overbought_Buffer, true);
    ArraySetAsSeries(Oversold_Buffer, true);
    ArraySetAsSeries(Buy_Signal_Buffer, true);
    ArraySetAsSeries(Sell_Signal_Buffer, true);
    ArraySetAsSeries(Bullish_Div_Buffer, true);
    ArraySetAsSeries(Bearish_Div_Buffer, true);
    
    ArraySetAsSeries(g_rsi_array, true);
    ArraySetAsSeries(g_signal_array, true);
    ArraySetAsSeries(g_mtf_rsi_array, true);
    ArraySetAsSeries(g_high_array, true);
    ArraySetAsSeries(g_low_array, true);
    ArraySetAsSeries(g_close_array, true);
    
    // Create RSI handle
    g_rsi_handle = iRSI(_Symbol, _Period, InpRSIPeriod, InpAppliedPrice);
    if(g_rsi_handle == INVALID_HANDLE)
    {
        Print("Failed to create RSI indicator handle");
        return INIT_FAILED;
    }
    
    // Create signal smoothing handle
    g_ma_signal_handle = iMA(_Symbol, _Period, InpSignalSmoothPeriod, 0, MODE_SMA, PRICE_CLOSE);
    if(g_ma_signal_handle == INVALID_HANDLE)
    {
        Print("Failed to create Signal MA handle");
        return INIT_FAILED;
    }
    
    // Create multi-timeframe RSI handle
    if(InpShowMTF)
    {
        g_mtf_rsi_handle = iRSI(_Symbol, InpHigherTimeframe, InpRSIPeriod, InpAppliedPrice);
        if(g_mtf_rsi_handle == INVALID_HANDLE)
        {
            Print("Failed to create MTF RSI handle");
            return INIT_FAILED;
        }
    }
    
    // Set indicator properties
    IndicatorSetString(INDICATOR_SHORTNAME, "Enhanced RSI(" + IntegerToString(InpRSIPeriod) + ")");
    IndicatorSetInteger(INDICATOR_DIGITS, 1);
    IndicatorSetDouble(INDICATOR_MINIMUM, 0);
    IndicatorSetDouble(INDICATOR_MAXIMUM, 100);
    
    // Initialize level buffers
    if(InpShowLevels)
    {
        for(int i = 0; i < Bars(_Symbol, _Period); i++)
        {
            Overbought_Buffer[i] = InpOverboughtLevel;
            Oversold_Buffer[i] = InpOversoldLevel;
        }
    }
    
    Print("Enhanced RSI indicator initialized successfully");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    if(g_rsi_handle != INVALID_HANDLE)
        IndicatorRelease(g_rsi_handle);
    if(g_ma_signal_handle != INVALID_HANDLE)
        IndicatorRelease(g_ma_signal_handle);
    if(g_mtf_rsi_handle != INVALID_HANDLE)
        IndicatorRelease(g_mtf_rsi_handle);
        
    // Clean up chart objects
    ObjectsDeleteAll(0, "RSI_");
}

//+------------------------------------------------------------------+
//| Custom indicator calculation function                           |
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
                const int &spread[])
{
    if(rates_total < InpRSIPeriod + InpSignalSmoothPeriod)
        return 0;
    
    int calculated = BarsCalculated(g_rsi_handle);
    if(calculated < rates_total)
        return 0;
    
    int to_copy = rates_total - prev_calculated + 1;
    if(prev_calculated > 0)
        to_copy++;
    
    // Copy RSI data
    if(CopyBuffer(g_rsi_handle, 0, 0, to_copy, g_rsi_array) <= 0)
        return 0;
    
    // Copy price data for divergence detection
    if(InpDetectDivergence)
    {
        if(CopyHigh(_Symbol, _Period, 0, to_copy + InpDivergenceBars, g_high_array) <= 0)
            return 0;
        if(CopyLow(_Symbol, _Period, 0, to_copy + InpDivergenceBars, g_low_array) <= 0)
            return 0;
        if(CopyClose(_Symbol, _Period, 0, to_copy + InpDivergenceBars, g_close_array) <= 0)
            return 0;
    }
    
    // Copy MTF RSI if enabled
    if(InpShowMTF)
    {
        int mtf_bars = rates_total / (InpHigherTimeframe / _Period) + 10;
        if(CopyBuffer(g_mtf_rsi_handle, 0, 0, mtf_bars, g_mtf_rsi_array) <= 0)
            return 0;
    }
    
    int start = prev_calculated;
    if(start == 0)
        start = InpRSIPeriod + InpSignalSmoothPeriod;
    
    // Calculate indicator values
    for(int i = start; i < rates_total; i++)
    {
        int buf_index = rates_total - 1 - i;
        
        // Copy RSI value
        RSI_Buffer[buf_index] = g_rsi_array[buf_index];
        
        // Calculate dynamic levels if enabled
        if(InpUseDynamicLevels)
        {
            CalculateDynamicLevels(buf_index, rates_total);
        }
        else
        {
            g_dynamic_overbought = InpOverboughtLevel;
            g_dynamic_oversold = InpOversoldLevel;
        }
        
        // Update level buffers
        if(InpShowLevels)
        {
            Overbought_Buffer[buf_index] = g_dynamic_overbought;
            Oversold_Buffer[buf_index] = g_dynamic_oversold;
        }
        
        // Calculate signal line (smoothed RSI)
        if(buf_index <= rates_total - InpSignalSmoothPeriod)
        {
            Signal_Buffer[buf_index] = CalculateSmoothedRSI(buf_index);
        }
        
        // Detect signals
        if(InpDetectSignals && buf_index <= rates_total - 2)
        {
            DetectEntryExitSignals(buf_index, time[rates_total - 1 - buf_index]);
        }
        
        // Detect divergence
        if(InpDetectDivergence && buf_index <= rates_total - InpDivergenceBars)
        {
            DetectDivergence(buf_index);
        }
        
        // Color background
        if(InpShowBackground)
        {
            ColorBackground(buf_index, time[rates_total - 1 - buf_index]);
        }
    }
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Calculate dynamic overbought/oversold levels                   |
//+------------------------------------------------------------------+
void CalculateDynamicLevels(int index, int total_bars)
{
    int lookback = MathMin(50, total_bars - index);
    if(lookback < 10) return;
    
    double sum = 0, sum_sq = 0;
    for(int i = 0; i < lookback; i++)
    {
        if(index + i >= ArraySize(g_rsi_array)) break;
        double rsi_val = g_rsi_array[index + i];
        sum += rsi_val;
        sum_sq += rsi_val * rsi_val;
    }
    
    double mean = sum / lookback;
    double variance = (sum_sq / lookback) - (mean * mean);
    double std_dev = MathSqrt(variance);
    
    // Adjust levels based on volatility
    double volatility_factor = std_dev / 15.0; // Normalize
    volatility_factor = MathMax(0.5, MathMin(2.0, volatility_factor));
    
    g_dynamic_overbought = 50 + (InpOverboughtLevel - 50) * volatility_factor;
    g_dynamic_oversold = 50 - (50 - InpOversoldLevel) * volatility_factor;
    
    // Keep within reasonable bounds
    g_dynamic_overbought = MathMax(60, MathMin(90, g_dynamic_overbought));
    g_dynamic_oversold = MathMax(10, MathMin(40, g_dynamic_oversold));
}

//+------------------------------------------------------------------+
//| Calculate smoothed RSI signal                                  |
//+------------------------------------------------------------------+
double CalculateSmoothedRSI(int index)
{
    double sum = 0;
    for(int i = 0; i < InpSignalSmoothPeriod; i++)
    {
        if(index + i >= ArraySize(g_rsi_array)) break;
        sum += g_rsi_array[index + i];
    }
    return sum / InpSignalSmoothPeriod;
}

//+------------------------------------------------------------------+
//| Detect entry and exit signals                                  |
//+------------------------------------------------------------------+
void DetectEntryExitSignals(int index, datetime bar_time)
{
    if(index == 0) return; // Need previous bar for comparison
    
    double current_rsi = RSI_Buffer[index];
    double prev_rsi = RSI_Buffer[index + 1];
    double current_signal = Signal_Buffer[index];
    double prev_signal = Signal_Buffer[index + 1];
    
    // Initialize signal buffers
    Buy_Signal_Buffer[index] = EMPTY_VALUE;
    Sell_Signal_Buffer[index] = EMPTY_VALUE;
    
    // Check multi-timeframe agreement if enabled
    bool mtf_agreement = true;
    if(InpShowMTF && InpMTFSignalsOnly)
    {
        mtf_agreement = CheckMTFAgreement(index);
    }
    
    // Buy signal conditions
    bool buy_condition1 = (prev_rsi <= g_dynamic_oversold && current_rsi > g_dynamic_oversold); // RSI crossing above oversold
    bool buy_condition2 = (prev_rsi < current_rsi && current_rsi < g_dynamic_oversold + 5); // RSI rising from oversold
    bool buy_condition3 = (prev_signal <= g_dynamic_oversold && current_signal > g_dynamic_oversold); // Signal line crossing
    
    // Sell signal conditions  
    bool sell_condition1 = (prev_rsi >= g_dynamic_overbought && current_rsi < g_dynamic_overbought); // RSI crossing below overbought
    bool sell_condition2 = (prev_rsi > current_rsi && current_rsi > g_dynamic_overbought - 5); // RSI falling from overbought
    bool sell_condition3 = (prev_signal >= g_dynamic_overbought && current_signal < g_dynamic_overbought); // Signal line crossing
    
    // Generate signals
    if((buy_condition1 || buy_condition2 || buy_condition3) && mtf_agreement && g_last_signal_bar != index)
    {
        if(InpShowSignalArrows)
            Buy_Signal_Buffer[index] = current_rsi - 5;
            
        g_last_signal_bar = index;
        
        if(InpShowAlerts && TimeCurrent() - g_last_alert_time > 300) // 5 minute cooldown
        {
            Alert("RSI Buy Signal on ", _Symbol, " - RSI: ", DoubleToString(current_rsi, 1));
            g_last_alert_time = TimeCurrent();
        }
        
        // Create signal object on chart
        CreateSignalObject("RSI_BUY_" + TimeToString(bar_time), bar_time, current_rsi - 5, "BUY", clrLime);
    }
    
    if((sell_condition1 || sell_condition2 || sell_condition3) && g_last_signal_bar != index)
    {
        if(InpShowSignalArrows)
            Sell_Signal_Buffer[index] = current_rsi + 5;
            
        g_last_signal_bar = index;
        
        if(InpShowAlerts && TimeCurrent() - g_last_alert_time > 300)
        {
            Alert("RSI Sell Signal on ", _Symbol, " - RSI: ", DoubleToString(current_rsi, 1));
            g_last_alert_time = TimeCurrent();
        }
        
        // Create signal object on chart
        CreateSignalObject("RSI_SELL_" + TimeToString(bar_time), bar_time, current_rsi + 5, "SELL", clrRed);
    }
}

//+------------------------------------------------------------------+
//| Check multi-timeframe agreement                                |
//+------------------------------------------------------------------+
bool CheckMTFAgreement(int index)
{
    if(!InpShowMTF) return true;
    
    // Get current MTF RSI value
    int mtf_shift = index / (InpHigherTimeframe / _Period);
    if(mtf_shift >= ArraySize(g_mtf_rsi_array)) return true;
    
    double mtf_rsi = g_mtf_rsi_array[mtf_shift];
    double current_rsi = RSI_Buffer[index];
    
    // Check if both timeframes show similar oversold/overbought conditions
    bool both_oversold = (current_rsi < g_dynamic_oversold + 10) && (mtf_rsi < 40);
    bool both_overbought = (current_rsi > g_dynamic_overbought - 10) && (mtf_rsi > 60);
    
    return both_oversold || both_overbought;
}

//+------------------------------------------------------------------+
//| Detect bullish and bearish divergence                          |
//+------------------------------------------------------------------+
void DetectDivergence(int index)
{
    Bullish_Div_Buffer[index] = EMPTY_VALUE;
    Bearish_Div_Buffer[index] = EMPTY_VALUE;
    
    if(index < InpDivergenceBars) return;
    
    // Find recent highs and lows
    int recent_high_bar = FindRecentExtreme(index, InpDivergenceBars, true);
    int recent_low_bar = FindRecentExtreme(index, InpDivergenceBars, false);
    
    // Check for bullish divergence (price makes lower low, RSI makes higher low)
    if(recent_low_bar > 0)
    {
        double current_low = g_low_array[index];
        double prev_low = g_low_array[recent_low_bar];
        double current_rsi_low = RSI_Buffer[index];
        double prev_rsi_low = RSI_Buffer[recent_low_bar];
        
        if(current_low < prev_low && current_rsi_low > prev_rsi_low && current_rsi_low < 40)
        {
            Bullish_Div_Buffer[index] = current_rsi_low;
            CreateDivergenceObject("BULL_DIV_" + IntegerToString(index), index, recent_low_bar, true);
        }
    }
    
    // Check for bearish divergence (price makes higher high, RSI makes lower high)
    if(recent_high_bar > 0)
    {
        double current_high = g_high_array[index];
        double prev_high = g_high_array[recent_high_bar];
        double current_rsi_high = RSI_Buffer[index];
        double prev_rsi_high = RSI_Buffer[recent_high_bar];
        
        if(current_high > prev_high && current_rsi_high < prev_rsi_high && current_rsi_high > 60)
        {
            Bearish_Div_Buffer[index] = current_rsi_high;
            CreateDivergenceObject("BEAR_DIV_" + IntegerToString(index), index, recent_high_bar, false);
        }
    }
}

//+------------------------------------------------------------------+
//| Find recent extreme (high or low)                              |
//+------------------------------------------------------------------+
int FindRecentExtreme(int start_index, int lookback, bool find_high)
{
    double extreme_value = find_high ? -999999 : 999999;
    int extreme_index = -1;
    
    for(int i = start_index + 3; i < start_index + lookback; i++)
    {
        if(i >= ArraySize(g_high_array)) break;
        
        double price = find_high ? g_high_array[i] : g_low_array[i];
        
        if(find_high && price > extreme_value)
        {
            extreme_value = price;
            extreme_index = i;
        }
        else if(!find_high && price < extreme_value)
        {
            extreme_value = price;
            extreme_index = i;
        }
    }
    
    return extreme_index;
}

//+------------------------------------------------------------------+
//| Color background based on RSI levels                           |
//+------------------------------------------------------------------+
void ColorBackground(int index, datetime bar_time)
{
    double current_rsi = RSI_Buffer[index];
    
    string obj_name = "RSI_BG_" + TimeToString(bar_time);
    
    if(current_rsi > g_dynamic_overbought)
    {
        CreateBackgroundObject(obj_name, bar_time, InpOverboughtColor);
    }
    else if(current_rsi < g_dynamic_oversold)
    {
        CreateBackgroundObject(obj_name, bar_time, InpOversoldColor);
    }
    else
    {
        ObjectDelete(0, obj_name); // Remove background if in neutral zone
    }
}

//+------------------------------------------------------------------+
//| Create signal object on main chart                             |
//+------------------------------------------------------------------+
void CreateSignalObject(string name, datetime time, double price, string text, color clr)
{
    if(ObjectFind(0, name) >= 0) return; // Object already exists
    
    ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
    ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER);
}

//+------------------------------------------------------------------+
//| Create divergence object                                       |
//+------------------------------------------------------------------+
void CreateDivergenceObject(string name, int index1, int index2, bool bullish)
{
    if(ObjectFind(0, name) >= 0) return;
    
    // This would create a trendline on the main chart showing divergence
    // Implementation depends on having access to main chart data
}

//+------------------------------------------------------------------+
//| Create background color object                                 |
//+------------------------------------------------------------------+
void CreateBackgroundObject(string name, datetime time, color bg_color)
{
    if(ObjectFind(0, name) >= 0)
    {
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg_color);
        return;
    }
    
    ObjectCreate(0, name, OBJ_RECTANGLE, 1, time, 0, time + PeriodSeconds(), 100);
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg_color);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
    ObjectSetInteger(0, name, OBJPROP_FILL, true);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 0);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}

//+------------------------------------------------------------------+
//| Get RSI value for external use                                 |
//+------------------------------------------------------------------+
double GetRSIValue(int shift = 0)
{
    if(shift >= 0 && shift < ArraySize(RSI_Buffer))
        return RSI_Buffer[shift];
    return 0;
}

//+------------------------------------------------------------------+
//| Get signal value for external use                              |
//+------------------------------------------------------------------+
double GetSignalValue(int shift = 0)
{
    if(shift >= 0 && shift < ArraySize(Signal_Buffer))
        return Signal_Buffer[shift];
    return 0;
}

//+------------------------------------------------------------------+
//| Check if RSI is oversold                                       |
//+------------------------------------------------------------------+
bool IsOversold(int shift = 0)
{
    if(shift >= 0 && shift < ArraySize(RSI_Buffer))
        return RSI_Buffer[shift] < g_dynamic_oversold;
    return false;
}

//+------------------------------------------------------------------+
//| Check if RSI is overbought                                     |
//+------------------------------------------------------------------+
bool IsOverbought(int shift = 0)
{
    if(shift >= 0 && shift < ArraySize(RSI_Buffer))
        return RSI_Buffer[shift] > g_dynamic_overbought;
    return false;
}

//+------------------------------------------------------------------+
//| Get dynamic levels                                             |
//+------------------------------------------------------------------+
void GetDynamicLevels(double& overbought, double& oversold)
{
    overbought = g_dynamic_overbought;
    oversold = g_dynamic_oversold;
}
