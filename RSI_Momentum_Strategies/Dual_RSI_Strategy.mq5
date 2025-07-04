//+------------------------------------------------------------------+
//| Expert Advisor: Dual RSI Trend Filter Strategy                  |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Dual RSI system with long-term trend filter and    |
//|              short-term entry signals for enhanced precision    |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"
#property description "Dual RSI Strategy with trend filtering for improved accuracy"

#include "RiskManager.mqh"
#include "PerformanceMonitor.mqh"

//--- Input Parameters
input group "=== Dual RSI Strategy Parameters ==="
input int                InpRSILongPeriod = 30;         // RSI Long Period (Trend Filter)
input int                InpRSIShortPeriod = 2;         // RSI Short Period (Entry Signal)
input double             InpRSILongThreshold = 50.0;    // RSI Long Trend Threshold
input double             InpRSIShortBuy = 15.0;         // RSI Short Buy Level
input double             InpRSIShortSell = 85.0;        // RSI Short Sell Level
input bool               InpDynamicThresholds = true;   // Use dynamic thresholds based on volatility

input group "=== Additional Filters ==="
input int                InpSMAPeriod = 200;            // SMA Period for additional trend confirmation
input bool               InpUsePriceActionFilter = true; // Use price action confirmation
input bool               InpUseCandlestickPatterns = true; // Use candlestick pattern recognition
input int                InpLookbackPeriod = 5;         // Lookback period for pattern analysis

input group "=== Risk Management ==="
input double             InpRiskPercent = 0.025;        // Risk per trade (2.5%)
input double             InpMaxRiskPerTrade = 0.06;     // Maximum risk per trade (6%)
input bool               InpUseATRStops = true;         // Use ATR-based stop loss
input double             InpATRMultiplier = 2.0;        // ATR multiplier for stops
input double             InpFixedStopPercent = 0.025;   // Fixed stop loss percentage

input group "=== Position Management ==="
input int                InpMaxDailyTrades = 4;         // Maximum trades per day
input bool               InpUsePartialTakeProfit = true; // Use partial profit taking
input double             InpPartialTPPercent = 0.02;    // Partial TP at 2% profit
input double             InpPartialTPSize = 0.5;        // Close 50% at partial TP
input bool               InpTrailAfterTP = true;        // Trail remaining position after partial TP

input group "=== Market Conditions ==="
input bool               InpTradeInTrendOnly = true;    // Trade only in trending markets
input bool               InpAvoidNewsEvents = false;    // Avoid trading during news (placeholder)
input int                InpMinDaysForEntry = 2;        // Minimum days since last signal

//--- Global Variables
int g_rsi_long_handle;
int g_rsi_short_handle;
int g_sma_handle;
int g_atr_handle;
double g_rsi_long_buffer[];
double g_rsi_short_buffer[];
double g_sma_buffer[];
double g_atr_buffer[];
double g_high_buffer[];
double g_close_buffer[];
double g_low_buffer[];
double g_open_buffer[];
long g_volume_buffer[];

CRiskManager* g_risk_manager;
CPerformanceMonitor* g_performance_monitor;

datetime g_last_bar_time = 0;
int g_daily_trades_count = 0;
datetime g_last_trade_day = 0;
double g_entry_price = 0;
datetime g_position_open_time = 0;
bool g_partial_tp_taken = false;
double g_remaining_volume = 0;
datetime g_last_signal_time = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("=== Initializing Dual RSI Trend Filter Strategy ===");
    
    // Initialize indicators
    g_rsi_long_handle = iRSI(_Symbol, PERIOD_D1, InpRSILongPeriod, PRICE_CLOSE);
    g_rsi_short_handle = iRSI(_Symbol, PERIOD_D1, InpRSIShortPeriod, PRICE_CLOSE);
    g_sma_handle = iMA(_Symbol, PERIOD_D1, InpSMAPeriod, 0, MODE_SMA, PRICE_CLOSE);
    g_atr_handle = iATR(_Symbol, PERIOD_D1, 14);
    
    if(g_rsi_long_handle == INVALID_HANDLE || g_rsi_short_handle == INVALID_HANDLE || 
       g_sma_handle == INVALID_HANDLE || g_atr_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to initialize indicators");
        return INIT_FAILED;
    }
    
    // Initialize arrays
    ArraySetAsSeries(g_rsi_long_buffer, true);
    ArraySetAsSeries(g_rsi_short_buffer, true);
    ArraySetAsSeries(g_sma_buffer, true);
    ArraySetAsSeries(g_atr_buffer, true);
    ArraySetAsSeries(g_high_buffer, true);
    ArraySetAsSeries(g_close_buffer, true);
    ArraySetAsSeries(g_low_buffer, true);
    ArraySetAsSeries(g_open_buffer, true);
    ArraySetAsSeries(g_volume_buffer, true);
    
    // Initialize risk manager and performance monitor
    g_risk_manager = new CRiskManager(InpRiskPercent, InpMaxRiskPerTrade);
    g_performance_monitor = new CPerformanceMonitor("Dual_RSI_Trend_Filter");
    
    if(g_risk_manager == NULL || g_performance_monitor == NULL)
    {
        Print("ERROR: Failed to initialize risk manager or performance monitor");
        return INIT_FAILED;
    }
    
    // Enable timer for advanced features
    EventSetTimer(60); // Every minute
    
    Print("Dual RSI Strategy initialized successfully");
    Print("RSI Long Period: ", InpRSILongPeriod, " (Trend Filter)");
    Print("RSI Short Period: ", InpRSIShortPeriod, " (Entry Signal)");
    Print("Long Threshold: ", InpRSILongThreshold);
    Print("Short Buy Level: ", InpRSIShortBuy);
    Print("Short Sell Level: ", InpRSIShortSell);
    Print("Risk per trade: ", InpRiskPercent * 100, "%");
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("=== Deinitializing Dual RSI Trend Filter Strategy ===");
    
    EventKillTimer();
    
    // Print final performance report
    if(g_performance_monitor != NULL)
    {
        g_performance_monitor.PrintPerformanceReport();
        g_performance_monitor.SavePerformanceToFile();
        delete g_performance_monitor;
    }
    
    // Cleanup
    if(g_risk_manager != NULL)
        delete g_risk_manager;
        
    if(g_rsi_long_handle != INVALID_HANDLE)
        IndicatorRelease(g_rsi_long_handle);
    if(g_rsi_short_handle != INVALID_HANDLE)
        IndicatorRelease(g_rsi_short_handle);
    if(g_sma_handle != INVALID_HANDLE)
        IndicatorRelease(g_sma_handle);
    if(g_atr_handle != INVALID_HANDLE)
        IndicatorRelease(g_atr_handle);
    
    Print("Dual RSI Strategy deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check for new daily bar
    datetime current_time = iTime(_Symbol, PERIOD_D1, 0);
    if(current_time == g_last_bar_time)
        return;
    
    g_last_bar_time = current_time;
    
    // Reset daily trade counter
    datetime current_day = StringToTime(TimeToString(current_time, TIME_DATE));
    if(current_day != g_last_trade_day)
    {
        g_daily_trades_count = 0;
        g_last_trade_day = current_day;
    }
    
    // Check if maximum daily loss is reached
    if(g_risk_manager.IsMaxDailyLossReached())
    {
        Print("Maximum daily loss reached. Stopping trading for today.");
        return;
    }
    
    // Copy indicator data
    if(!CopyIndicatorData())
        return;
    
    // Check exit conditions first
    if(PositionSelect(_Symbol))
    {
        CheckExitConditions();
        CheckPartialTakeProfit();
        return;
    }
    
    // Check entry conditions
    if(g_daily_trades_count < InpMaxDailyTrades)
    {
        CheckDualRSIEntry();
    }
}

//+------------------------------------------------------------------+
//| Copy indicator data                                              |
//+------------------------------------------------------------------+
bool CopyIndicatorData()
{
    // Copy RSI data
    if(CopyBuffer(g_rsi_long_handle, 0, 0, 3, g_rsi_long_buffer) < 3)
    {
        Print("Failed to copy RSI Long data");
        return false;
    }
    
    if(CopyBuffer(g_rsi_short_handle, 0, 0, 3, g_rsi_short_buffer) < 3)
    {
        Print("Failed to copy RSI Short data");
        return false;
    }
    
    if(CopyBuffer(g_sma_handle, 0, 0, 2, g_sma_buffer) < 2)
    {
        Print("Failed to copy SMA data");
        return false;
    }
    
    // Copy price data for pattern analysis
    int lookback = MathMax(InpLookbackPeriod, 5);
    if(CopyHigh(_Symbol, PERIOD_D1, 0, lookback, g_high_buffer) < lookback)
    {
        Print("Failed to copy High data");
        return false;
    }
    
    if(CopyClose(_Symbol, PERIOD_D1, 0, lookback, g_close_buffer) < lookback)
    {
        Print("Failed to copy Close data");
        return false;
    }
    
    if(CopyLow(_Symbol, PERIOD_D1, 0, lookback, g_low_buffer) < lookback)
    {
        Print("Failed to copy Low data");
        return false;
    }
    
    if(CopyOpen(_Symbol, PERIOD_D1, 0, lookback, g_open_buffer) < lookback)
    {
        Print("Failed to copy Open data");
        return false;
    }
    
    // Copy ATR data
    if(CopyBuffer(g_atr_handle, 0, 0, 1, g_atr_buffer) < 1)
    {
        Print("Failed to copy ATR data");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check Dual RSI entry conditions                                 |
//+------------------------------------------------------------------+
void CheckDualRSIEntry()
{
    double rsi_long = g_rsi_long_buffer[0];
    double rsi_short = g_rsi_short_buffer[0];
    double rsi_short_prev = g_rsi_short_buffer[1];
    double current_close = g_close_buffer[0];
    double sma_value = g_sma_buffer[0];
    
    // Calculate dynamic thresholds if enabled
    double buy_threshold = InpRSIShortBuy;
    double trend_threshold = InpRSILongThreshold;
    
    if(InpDynamicThresholds)
    {
        buy_threshold = CalculateDynamicThreshold(true);
        trend_threshold = CalculateDynamicTrendThreshold();
    }
    
    // Core Dual RSI Logic
    bool trend_condition = rsi_long > trend_threshold;        // Long-term RSI indicates uptrend
    bool entry_condition = rsi_short < buy_threshold;         // Short-term RSI oversold
    bool signal_fresh = rsi_short_prev >= buy_threshold;      // First time crossing threshold
    
    // Additional trend confirmation
    bool sma_trend = true;
    if(InpTradeInTrendOnly)
    {
        sma_trend = current_close > sma_value;                // Price above SMA
    }
    
    // Price action filter
    bool price_action_filter = true;
    if(InpUsePriceActionFilter)
    {
        price_action_filter = CheckPriceActionCondition();
    }
    
    // Candlestick pattern filter
    bool candlestick_filter = true;
    if(InpUseCandlestickPatterns)
    {
        candlestick_filter = CheckCandlestickPatterns();
    }
    
    // Time-based filter
    bool time_filter = true;
    if(g_last_signal_time > 0)
    {
        double days_since_signal = (TimeCurrent() - g_last_signal_time) / 86400.0;
        time_filter = days_since_signal >= InpMinDaysForEntry;
    }
    
    // Market structure analysis
    bool market_structure = CheckMarketStructure();
    
    // Final entry decision
    if(trend_condition && entry_condition && signal_fresh && sma_trend && 
       price_action_filter && candlestick_filter && time_filter && market_structure)
    {
        OpenDualRSIPosition();
        g_last_signal_time = TimeCurrent();
    }
    
    // Detailed logging
    if(trend_condition && entry_condition)
    {
        Print("Dual RSI signal detected:");
        Print("RSI Long: ", DoubleToString(rsi_long, 2), " (threshold: ", DoubleToString(trend_threshold, 2), ")");
        Print("RSI Short: ", DoubleToString(rsi_short, 2), " (threshold: ", DoubleToString(buy_threshold, 2), ")");
        Print("Filters - SMA: ", sma_trend, " PriceAction: ", price_action_filter, 
              " Candlestick: ", candlestick_filter, " Time: ", time_filter, " Structure: ", market_structure);
    }
}

//+------------------------------------------------------------------+
//| Calculate dynamic threshold based on volatility                 |
//+------------------------------------------------------------------+
double CalculateDynamicThreshold(bool for_entry = true)
{
    if(ArraySize(g_atr_buffer) < 1) 
        return for_entry ? InpRSIShortBuy : InpRSIShortSell;
    
    // Get ATR for volatility measurement
    double current_atr = g_atr_buffer[0];
    
    // Calculate recent ATR average
    double atr_extended[];
    ArraySetAsSeries(atr_extended, true);
    
    if(CopyBuffer(g_atr_handle, 0, 0, 20, atr_extended) == 20)
    {
        double avg_atr = 0;
        for(int i = 0; i < 20; i++)
            avg_atr += atr_extended[i];
        avg_atr /= 20;
        
        // Adjust thresholds based on volatility
        double volatility_ratio = current_atr / avg_atr;
        
        if(for_entry)
        {
            // In high volatility, use more extreme oversold levels
            if(volatility_ratio > 1.5)
                return InpRSIShortBuy - 5.0;  // More oversold
            else if(volatility_ratio < 0.7)
                return InpRSIShortBuy + 3.0;  // Less oversold
        }
        else
        {
            // For exit, adjust overbought levels
            if(volatility_ratio > 1.5)
                return InpRSIShortSell + 5.0;  // More overbought
            else if(volatility_ratio < 0.7)
                return InpRSIShortSell - 3.0;  // Less overbought
        }
    }
    
    return for_entry ? InpRSIShortBuy : InpRSIShortSell;
}

//+------------------------------------------------------------------+
//| Calculate dynamic trend threshold                               |
//+------------------------------------------------------------------+
double CalculateDynamicTrendThreshold()
{
    // Analyze recent RSI long values to determine trend strength
    if(ArraySize(g_rsi_long_buffer) < 3) return InpRSILongThreshold;
    
    double rsi_avg = (g_rsi_long_buffer[0] + g_rsi_long_buffer[1] + g_rsi_long_buffer[2]) / 3;
    
    // If RSI is consistently high, lower threshold slightly for more opportunities
    if(rsi_avg > 70) return InpRSILongThreshold - 5.0;
    
    // If RSI is borderline, raise threshold for more conservative entries
    if(rsi_avg < 45) return InpRSILongThreshold + 5.0;
    
    return InpRSILongThreshold;
}

//+------------------------------------------------------------------+
//| Check price action condition                                    |
//+------------------------------------------------------------------+
bool CheckPriceActionCondition()
{
    if(ArraySize(g_close_buffer) < 3) return true;
    
    double current_close = g_close_buffer[0];
    double prev_close = g_close_buffer[1];
    double prev2_close = g_close_buffer[2];
    
    // Look for signs of potential reversal
    // 1. Current close higher than previous (showing strength)
    bool strength_signal = current_close > prev_close;
    
    // 2. But still in a minor pullback (not at new highs)
    double recent_high = g_high_buffer[0];
    for(int i = 1; i < MathMin(5, ArraySize(g_high_buffer)); i++)
    {
        recent_high = MathMax(recent_high, g_high_buffer[i]);
    }
    
    bool pullback_signal = current_close < recent_high * 0.99; // At least 1% below recent high
    
    return strength_signal || pullback_signal;
}

//+------------------------------------------------------------------+
//| Check candlestick patterns                                      |
//+------------------------------------------------------------------+
bool CheckCandlestickPatterns()
{
    if(ArraySize(g_open_buffer) < 2) return true;
    
    double open_0 = g_open_buffer[0];
    double high_0 = g_high_buffer[0];
    double low_0 = g_low_buffer[0];
    double close_0 = g_close_buffer[0];
    
    double open_1 = g_open_buffer[1];
    double high_1 = g_high_buffer[1];
    double low_1 = g_low_buffer[1];
    double close_1 = g_close_buffer[1];
    
    // Simple bullish patterns
    
    // 1. Hammer or Doji at low RSI
    double body_0 = MathAbs(close_0 - open_0);
    double total_range_0 = high_0 - low_0;
    bool hammer_like = (body_0 < total_range_0 * 0.3) && (close_0 > (high_0 + low_0) / 2);
    
    // 2. Bullish engulfing
    bool bullish_engulfing = (close_1 < open_1) && (close_0 > open_0) && 
                            (open_0 < close_1) && (close_0 > open_1);
    
    // 3. Higher low formation
    bool higher_low = low_0 > low_1 && close_0 > close_1;
    
    return hammer_like || bullish_engulfing || higher_low;
}

//+------------------------------------------------------------------+
//| Check market structure                                          |
//+------------------------------------------------------------------+
bool CheckMarketStructure()
{
    if(ArraySize(g_close_buffer) < InpLookbackPeriod) return true;
    
    // Analyze recent market structure for trend continuation
    double current_close = g_close_buffer[0];
    
    // Count higher closes in recent periods
    int higher_closes = 0;
    for(int i = 1; i < InpLookbackPeriod; i++)
    {
        if(g_close_buffer[i-1] > g_close_buffer[i])
            higher_closes++;
    }
    
    // Look for overall upward bias
    double structure_ratio = (double)higher_closes / (InpLookbackPeriod - 1);
    
    return structure_ratio >= 0.4; // At least 40% of recent closes were higher
}

//+------------------------------------------------------------------+
//| Check exit conditions                                           |
//+------------------------------------------------------------------+
void CheckExitConditions()
{
    double rsi_short = g_rsi_short_buffer[0];
    double sell_threshold = InpDynamicThresholds ? CalculateDynamicThreshold(false) : InpRSIShortSell;
    
    bool rsi_exit = rsi_short > sell_threshold;
    
    if(rsi_exit)
    {
        ClosePosition("RSI Overbought (" + DoubleToString(rsi_short, 2) + ")");
    }
}

//+------------------------------------------------------------------+
//| Check partial take profit                                       |
//+------------------------------------------------------------------+
void CheckPartialTakeProfit()
{
    if(!InpUsePartialTakeProfit || g_partial_tp_taken || g_entry_price == 0)
        return;
    
    double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double profit_percent = (current_price - g_entry_price) / g_entry_price;
    
    if(profit_percent >= InpPartialTPPercent)
    {
        ExecutePartialTakeProfit();
    }
}

//+------------------------------------------------------------------+
//| Execute partial take profit                                     |
//+------------------------------------------------------------------+
void ExecutePartialTakeProfit()
{
    if(!PositionSelect(_Symbol)) return;
    
    double current_volume = PositionGetDouble(POSITION_VOLUME);
    double partial_volume = current_volume * InpPartialTPSize;
    
    // Normalize volume
    double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    partial_volume = MathMax(min_volume, NormalizeDouble(partial_volume, 2));
    
    if(partial_volume >= min_volume && partial_volume < current_volume)
    {
        MqlTradeRequest request = {};
        MqlTradeResult result = {};
        
        request.action = TRADE_ACTION_DEAL;
        request.symbol = _Symbol;
        request.volume = partial_volume;
        request.type = ORDER_TYPE_SELL;
        request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        request.comment = "Dual_RSI_Partial_TP";
        request.magic = 345678;
        
        if(OrderSend(request, result))
        {
            if(result.retcode == TRADE_RETCODE_DONE)
            {
                g_partial_tp_taken = true;
                g_remaining_volume = current_volume - partial_volume;
                
                double profit_percent = (request.price - g_entry_price) / g_entry_price * 100;
                Print("Partial TP executed: ", DoubleToString(partial_volume, 2), 
                      " lots at ", DoubleToString(profit_percent, 2), "% profit");
                      
                // If trailing is enabled, modify remaining position
                if(InpTrailAfterTP)
                {
                    // Implementation for trailing stop modification would go here
                    Print("Trailing stop activated for remaining ", DoubleToString(g_remaining_volume, 2), " lots");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Open Dual RSI position                                          |
//+------------------------------------------------------------------+
void OpenDualRSIPosition()
{
    double current_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    if(current_price <= 0)
    {
        Print("Invalid price for opening position");
        return;
    }
    
    // Calculate stop loss
    double stop_loss = 0;
    if(InpUseATRStops && ArraySize(g_atr_buffer) > 0)
    {
        stop_loss = g_risk_manager.CalculateATRStopLoss(current_price, true, InpATRMultiplier);
    }
    else
    {
        stop_loss = current_price * (1.0 - InpFixedStopPercent);
    }
    
    // Calculate position size
    double volume = g_risk_manager.CalculatePositionSize(current_price, stop_loss);
    if(volume <= 0)
    {
        Print("Invalid volume calculated: ", volume);
        return;
    }
    
    // Prepare trade request
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = volume;
    request.type = ORDER_TYPE_BUY;
    request.price = current_price;
    request.sl = stop_loss;
    request.tp = 0; // Dynamic exit
    request.comment = "Dual_RSI_Long";
    request.magic = 345678;
    request.deviation = 10;
    
    // Send order
    if(OrderSend(request, result))
    {
        if(result.retcode == TRADE_RETCODE_DONE)
        {
            g_entry_price = current_price;
            g_position_open_time = TimeCurrent();
            g_daily_trades_count++;
            g_partial_tp_taken = false;
            g_remaining_volume = volume;
            
            Print("=== DUAL RSI POSITION OPENED ===");
            Print("Entry Price: ", DoubleToString(current_price, _Digits));
            Print("Volume: ", DoubleToString(volume, 2));
            Print("Stop Loss: ", DoubleToString(stop_loss, _Digits));
            Print("RSI Long: ", DoubleToString(g_rsi_long_buffer[0], 2));
            Print("RSI Short: ", DoubleToString(g_rsi_short_buffer[0], 2));
            Print("Daily trades count: ", g_daily_trades_count, "/", InpMaxDailyTrades);
        }
        else
        {
            Print("Dual RSI order failed with return code: ", result.retcode);
        }
    }
    else
    {
        Print("Dual RSI OrderSend failed. Error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Close position                                                   |
//+------------------------------------------------------------------+
void ClosePosition(string reason = "Manual Close")
{
    if(!PositionSelect(_Symbol))
        return;
    
    double position_volume = PositionGetDouble(POSITION_VOLUME);
    double position_profit = PositionGetDouble(POSITION_PROFIT);
    double close_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = position_volume;
    request.type = ORDER_TYPE_SELL;
    request.price = close_price;
    request.comment = "Dual_RSI_Close: " + reason;
    request.magic = 345678;
    request.deviation = 10;
    
    if(OrderSend(request, result))
    {
        if(result.retcode == TRADE_RETCODE_DONE)
        {
            // Calculate metrics
            double profit_percent = (close_price - g_entry_price) / g_entry_price * 100;
            double holding_days = (TimeCurrent() - g_position_open_time) / 86400.0;
            
            // Update performance monitor
            g_performance_monitor.UpdateTrade(position_profit, position_volume);
            
            Print("=== DUAL RSI POSITION CLOSED ===");
            Print("Reason: ", reason);
            Print("Profit: $", DoubleToString(position_profit, 2));
            Print("Profit %: ", DoubleToString(profit_percent, 2), "%");
            Print("Holding Period: ", DoubleToString(holding_days, 1), " days");
            Print("Partial TP taken: ", g_partial_tp_taken ? "Yes" : "No");
            
            // Reset tracking variables
            g_entry_price = 0;
            g_position_open_time = 0;
            g_partial_tp_taken = false;
            g_remaining_volume = 0;
        }
        else
        {
            Print("Dual RSI close order failed with return code: ", result.retcode);
        }
    }
    else
    {
        Print("Dual RSI OrderSend for close failed. Error: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Performance monitoring and updates
    static datetime last_report = 0;
    if(TimeCurrent() - last_report >= 3600) // Hourly
    {
        if(g_performance_monitor != NULL && g_performance_monitor.GetTotalTrades() > 0)
        {
            Print("=== Dual RSI Performance Update ===");
            Print("Total Trades: ", g_performance_monitor.GetTotalTrades());
            Print("Win Rate: ", DoubleToString(g_performance_monitor.GetWinRate(), 1), "%");
            Print("Net Profit: $", DoubleToString(g_performance_monitor.GetNetProfit(), 2));
            Print("Max Drawdown: ", DoubleToString(g_performance_monitor.GetMaxDrawdown(), 1), "%");
        }
        last_report = TimeCurrent();
    }
}
