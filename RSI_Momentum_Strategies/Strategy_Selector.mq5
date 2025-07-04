//+------------------------------------------------------------------+
//| Expert Advisor: RSI Strategy Selector & Launcher                |
//| Developer: AI Assistant                                          |
//| Version: 1.0 - Fixed                                             |
//| Description: Intelligent strategy selector that automatically   |
//|              chooses the best RSI strategy based on market      |
//|              conditions and asset type                          |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"
#property description "Smart strategy selector with auto-optimization"

#include "ConfigManager.mqh"
#include "RiskManager.mqh"
#include "PerformanceMonitor.mqh"

//--- Enumerations (Must be declared BEFORE input parameters)
enum ENUM_STRATEGY_MODE
{
    STRATEGY_AUTO,           // Auto-select best strategy
    STRATEGY_MANUAL,         // Use manually specified strategy
    STRATEGY_ADAPTIVE,       // Adaptive strategy switching
    STRATEGY_PORTFOLIO       // Portfolio of strategies
};

enum ENUM_MARKET_CONDITION
{
    MARKET_TRENDING_UP,      // Strong uptrend
    MARKET_TRENDING_DOWN,    // Strong downtrend
    MARKET_SIDEWAYS,         // Sideways/ranging
    MARKET_VOLATILE,         // High volatility
    MARKET_LOW_VOLATILITY    // Low volatility
};

//--- Input Parameters
input group "=== Strategy Selection ==="
input ENUM_STRATEGY_MODE InpStrategyMode = STRATEGY_AUTO;    // Strategy Selection Mode
input string             InpManualStrategy = "RSI_Simple_Stocks"; // Manual Strategy Name (if manual mode)
input bool               InpAutoOptimize = true;            // Auto-optimize for current market
input bool               InpShowStrategyInfo = true;        // Show strategy information on chart

input group "=== Market Analysis ==="
input bool               InpAnalyzeVolatility = true;       // Analyze market volatility
input bool               InpAnalyzeTrend = true;            // Analyze trend strength
input bool               InpAnalyzeVolume = true;           // Analyze volume patterns
input int                InpAnalysisPeriod = 30;            // Analysis period (days)

input group "=== Performance Monitoring ==="
input bool               InpSwitchOnPoorPerformance = true; // Switch strategy on poor performance
input double             InpMinWinRate = 60.0;              // Minimum acceptable win rate
input double             InpMaxDrawdown = 15.0;             // Maximum acceptable drawdown
input int                InpMinTradesForEvaluation = 10;    // Minimum trades before evaluation

input group "=== Risk Management Override ==="
input bool               InpOverrideRisk = false;           // Override strategy risk settings
input double             InpGlobalRisk = 0.02;              // Global risk per trade
input double             InpGlobalMaxRisk = 0.05;           // Global maximum risk per trade

//--- Global Variables (Fixed: Removed duplicate g_config_manager declaration)
CRiskManager* g_global_risk_manager = NULL;
CPerformanceMonitor* g_strategy_monitor = NULL;

string g_current_strategy = "";
SStrategyConfig g_current_config;
datetime g_last_analysis_time = 0;
ENUM_MARKET_CONDITION g_market_condition = MARKET_SIDEWAYS;

// Market analysis handles
int g_atr_handle = INVALID_HANDLE;
int g_sma_200_handle = INVALID_HANDLE;
int g_sma_50_handle = INVALID_HANDLE;
double g_atr_buffer[];
double g_sma_200_buffer[];
double g_sma_50_buffer[];
double g_close_buffer[];
long g_volume_buffer[];

// Strategy performance tracking
struct SStrategyPerformance
{
    string strategy_name;
    int total_trades;
    double win_rate;
    double profit_factor;
    double max_drawdown;
    double net_profit;
    datetime last_trade_time;
    bool is_active;
};

SStrategyPerformance g_strategy_performance[4];
int g_strategy_count = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("=== Initializing RSI Strategy Selector ===");
    
    // Initialize configuration manager
    if(!InitConfigManager())
    {
        Print("ERROR: Failed to initialize configuration manager");
        return INIT_FAILED;
    }
    
    // Get the global config manager instance (Fixed: Use GetConfigManager())
    CConfigManager* config_manager = GetConfigManager();
    if(config_manager == NULL)
    {
        Print("ERROR: Configuration manager is NULL");
        return INIT_FAILED;
    }
    
    // Initialize global risk manager
    g_global_risk_manager = new CRiskManager(InpGlobalRisk, InpGlobalMaxRisk);
    g_strategy_monitor = new CPerformanceMonitor("Strategy_Selector");
    
    if(g_global_risk_manager == NULL || g_strategy_monitor == NULL)
    {
        Print("ERROR: Failed to initialize managers");
        return INIT_FAILED;
    }
    
    // Initialize market analysis indicators
    g_atr_handle = iATR(_Symbol, PERIOD_D1, 14);
    g_sma_200_handle = iMA(_Symbol, PERIOD_D1, 200, 0, MODE_SMA, PRICE_CLOSE);
    g_sma_50_handle = iMA(_Symbol, PERIOD_D1, 50, 0, MODE_SMA, PRICE_CLOSE);
    
    if(g_atr_handle == INVALID_HANDLE || g_sma_200_handle == INVALID_HANDLE || g_sma_50_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to initialize market analysis indicators");
        return INIT_FAILED;
    }
    
    // Initialize arrays
    ArraySetAsSeries(g_atr_buffer, true);
    ArraySetAsSeries(g_sma_200_buffer, true);
    ArraySetAsSeries(g_sma_50_buffer, true);
    ArraySetAsSeries(g_close_buffer, true);
    ArraySetAsSeries(g_volume_buffer, true);
    
    // Perform initial market analysis and strategy selection
    AnalyzeMarketConditions();
    SelectOptimalStrategy();
    
    // Enable timer for periodic analysis
    EventSetTimer(3600); // Every hour
    
    Print("Strategy Selector initialized successfully");
    Print("Current Symbol: ", _Symbol);
    Print("Selected Strategy: ", g_current_strategy);
    Print("Market Condition: ", EnumToString(g_market_condition));
    
    // Show strategy information on chart if enabled
    if(InpShowStrategyInfo)
    {
        DisplayStrategyInfo();
    }
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("=== Deinitializing RSI Strategy Selector ===");
    
    EventKillTimer();
    
    // Clean up chart objects
    ObjectsDeleteAll(0, "StrategyInfo_");
    
    // Print final performance report
    if(g_strategy_monitor != NULL)
    {
        g_strategy_monitor.PrintPerformanceReport();
        PrintStrategyComparisonReport();
        delete g_strategy_monitor;
        g_strategy_monitor = NULL;
    }
    
    // Cleanup
    if(g_global_risk_manager != NULL)
    {
        delete g_global_risk_manager;
        g_global_risk_manager = NULL;
    }
        
    DeinitConfigManager();
    
    if(g_atr_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_atr_handle);
        g_atr_handle = INVALID_HANDLE;
    }
    if(g_sma_200_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_sma_200_handle);
        g_sma_200_handle = INVALID_HANDLE;
    }
    if(g_sma_50_handle != INVALID_HANDLE)
    {
        IndicatorRelease(g_sma_50_handle);
        g_sma_50_handle = INVALID_HANDLE;
    }
    
    Print("Strategy Selector deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check for new daily bar
    static datetime last_bar_time = 0;
    datetime current_time = iTime(_Symbol, PERIOD_D1, 0);
    
    if(current_time == last_bar_time)
        return;
    
    last_bar_time = current_time;
    
    // Update market analysis data
    if(!UpdateMarketData())
        return;
    
    // Check if we need to switch strategies based on performance
    if(InpSwitchOnPoorPerformance && InpStrategyMode == STRATEGY_ADAPTIVE)
    {
        CheckStrategyPerformance();
    }
    
    // Execute the selected strategy logic
    ExecuteCurrentStrategy();
}

//+------------------------------------------------------------------+
//| Analyze market conditions                                       |
//+------------------------------------------------------------------+
void AnalyzeMarketConditions()
{
    Print("=== Analyzing Market Conditions ===");
    
    if(!UpdateMarketData())
        return;
    
    // Volatility Analysis
    ENUM_MARKET_CONDITION volatility_condition = AnalyzeVolatility();
    
    // Trend Analysis
    ENUM_MARKET_CONDITION trend_condition = AnalyzeTrend();
    
    // Volume Analysis
    bool volume_strong = AnalyzeVolume();
    
    // Combine analyses to determine overall market condition
    if(trend_condition == MARKET_TRENDING_UP || trend_condition == MARKET_TRENDING_DOWN)
    {
        if(volatility_condition == MARKET_VOLATILE)
        {
            g_market_condition = MARKET_VOLATILE;
        }
        else
        {
            g_market_condition = trend_condition;
        }
    }
    else
    {
        if(volatility_condition == MARKET_VOLATILE)
        {
            g_market_condition = MARKET_VOLATILE;
        }
        else if(volatility_condition == MARKET_LOW_VOLATILITY)
        {
            g_market_condition = MARKET_LOW_VOLATILITY;
        }
        else
        {
            g_market_condition = MARKET_SIDEWAYS;
        }
    }
    
    Print("Market Analysis Results:");
    Print("Volatility Condition: ", EnumToString(volatility_condition));
    Print("Trend Condition: ", EnumToString(trend_condition));
    Print("Volume Strong: ", volume_strong ? "Yes" : "No");
    Print("Overall Market Condition: ", EnumToString(g_market_condition));
    
    g_last_analysis_time = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Analyze market volatility                                       |
//+------------------------------------------------------------------+
ENUM_MARKET_CONDITION AnalyzeVolatility()
{
    if(ArraySize(g_atr_buffer) < InpAnalysisPeriod)
        return MARKET_SIDEWAYS;
    
    double current_atr = g_atr_buffer[0];
    
    // Calculate average ATR over analysis period
    double avg_atr = 0;
    for(int i = 1; i < InpAnalysisPeriod; i++)
    {
        avg_atr += g_atr_buffer[i];
    }
    avg_atr /= (InpAnalysisPeriod - 1);
    
    if(avg_atr <= 0) return MARKET_SIDEWAYS;
    
    double volatility_ratio = current_atr / avg_atr;
    
    if(volatility_ratio > 1.3)
    {
        Print("High volatility detected (ratio: ", DoubleToString(volatility_ratio, 2), ")");
        return MARKET_VOLATILE;
    }
    else if(volatility_ratio < 0.7)
    {
        Print("Low volatility detected (ratio: ", DoubleToString(volatility_ratio, 2), ")");
        return MARKET_LOW_VOLATILITY;
    }
    
    return MARKET_SIDEWAYS;
}

//+------------------------------------------------------------------+
//| Analyze market trend                                            |
//+------------------------------------------------------------------+
ENUM_MARKET_CONDITION AnalyzeTrend()
{
    if(ArraySize(g_sma_200_buffer) < 1 || ArraySize(g_sma_50_buffer) < 1 || ArraySize(g_close_buffer) < 1)
        return MARKET_SIDEWAYS;
    
    double current_close = g_close_buffer[0];
    double sma_200 = g_sma_200_buffer[0];
    double sma_50 = g_sma_50_buffer[0];
    
    if(sma_200 <= 0) return MARKET_SIDEWAYS;
    
    // Calculate trend strength
    double trend_strength_200 = (current_close - sma_200) / sma_200 * 100;
    double trend_strength_50 = (sma_50 - sma_200) / sma_200 * 100;
    
    bool strong_uptrend = (current_close > sma_50) && (sma_50 > sma_200) && 
                         (trend_strength_200 > 2.0) && (trend_strength_50 > 1.0);
    
    bool strong_downtrend = (current_close < sma_50) && (sma_50 < sma_200) && 
                           (trend_strength_200 < -2.0) && (trend_strength_50 < -1.0);
    
    if(strong_uptrend)
    {
        Print("Strong uptrend detected (200 SMA trend: ", DoubleToString(trend_strength_200, 2), "%)");
        return MARKET_TRENDING_UP;
    }
    else if(strong_downtrend)
    {
        Print("Strong downtrend detected (200 SMA trend: ", DoubleToString(trend_strength_200, 2), "%)");
        return MARKET_TRENDING_DOWN;
    }
    
    return MARKET_SIDEWAYS;
}

//+------------------------------------------------------------------+
//| Analyze volume patterns                                         |
//+------------------------------------------------------------------+
bool AnalyzeVolume()
{
    if(ArraySize(g_volume_buffer) < InpAnalysisPeriod)
        return true;
    
    long current_volume = g_volume_buffer[0];
    
    // Calculate average volume
    long avg_volume = 0;
    for(int i = 1; i < InpAnalysisPeriod; i++)
    {
        avg_volume += g_volume_buffer[i];
    }
    avg_volume /= (InpAnalysisPeriod - 1);
    
    if(avg_volume <= 0) return true;
    
    double volume_ratio = (double)current_volume / avg_volume;
    
    bool volume_strong = volume_ratio > 1.2;
    
    Print("Volume Analysis: Current vs Average ratio = ", DoubleToString(volume_ratio, 2));
    
    return volume_strong;
}

//+------------------------------------------------------------------+
//| Select optimal strategy based on market conditions             |
//+------------------------------------------------------------------+
void SelectOptimalStrategy()
{
    Print("=== Selecting Optimal Strategy ===");
    
    string selected_strategy = "";
    
    switch(InpStrategyMode)
    {
        case STRATEGY_AUTO:
            selected_strategy = AutoSelectStrategy();
            break;
            
        case STRATEGY_MANUAL:
            selected_strategy = InpManualStrategy;
            break;
            
        case STRATEGY_ADAPTIVE:
            selected_strategy = AdaptiveStrategySelection();
            break;
            
        case STRATEGY_PORTFOLIO:
            selected_strategy = PortfolioStrategySelection();
            break;
            
        default:
            selected_strategy = AutoSelectStrategy();
            break;
    }
    
    // Load strategy configuration
    CConfigManager* config_manager = GetConfigManager();
    if(config_manager != NULL && config_manager.GetConfig(selected_strategy, g_current_config))
    {
        g_current_strategy = selected_strategy;
        
        // Apply optimizations if enabled
        if(InpAutoOptimize)
        {
            g_current_config = config_manager.CreateOptimizedConfig(selected_strategy);
        }
        
        // Override risk settings if specified
        if(InpOverrideRisk)
        {
            g_current_config.risk_percent = InpGlobalRisk;
            g_current_config.max_risk_per_trade = InpGlobalMaxRisk;
        }
        
        Print("Strategy selected: ", g_current_strategy);
        Print("Expected Win Rate: ", DoubleToString(g_current_config.expected_win_rate, 1), "%");
        Print("Expected Avg Profit: ", DoubleToString(g_current_config.expected_avg_profit, 2), "%");
        Print("Risk per Trade: ", DoubleToString(g_current_config.risk_percent * 100, 1), "%");
    }
    else
    {
        Print("ERROR: Failed to load strategy configuration for ", selected_strategy);
        g_current_strategy = "";
    }
}

//+------------------------------------------------------------------+
//| Auto-select strategy based on market analysis                  |
//+------------------------------------------------------------------+
string AutoSelectStrategy()
{
    CConfigManager* config_manager = GetConfigManager();
    if(config_manager == NULL) return "RSI_Simple_Stocks";
    
    // Auto-detect asset type first
    string auto_detected = config_manager.AutoDetectBestConfig();
    
    // Adjust based on market conditions
    switch(g_market_condition)
    {
        case MARKET_TRENDING_UP:
        case MARKET_TRENDING_DOWN:
            // Use Triple RSI for strong trends (higher profit potential)
            return "Triple_RSI_Advanced";
            
        case MARKET_VOLATILE:
            // Use Dual RSI for volatile markets (better filters)
            return "Dual_RSI_Indices";
            
        case MARKET_LOW_VOLATILITY:
            // Use Simple RSI for low volatility (more opportunities)
            return auto_detected;
            
        case MARKET_SIDEWAYS:
        default:
            // Use auto-detected based on asset type
            return auto_detected;
    }
}

//+------------------------------------------------------------------+
//| Adaptive strategy selection based on performance              |
//+------------------------------------------------------------------+
string AdaptiveStrategySelection()
{
    // If no performance data yet, use auto selection
    if(g_strategy_count == 0)
    {
        return AutoSelectStrategy();
    }
    
    // Find best performing strategy
    string best_strategy = "";
    double best_score = -999999;
    
    for(int i = 0; i < g_strategy_count; i++)
    {
        if(g_strategy_performance[i].total_trades >= InpMinTradesForEvaluation)
        {
            // Calculate performance score
            double score = CalculateStrategyScore(g_strategy_performance[i]);
            
            if(score > best_score)
            {
                best_score = score;
                best_strategy = g_strategy_performance[i].strategy_name;
            }
        }
    }
    
    if(best_strategy == "")
    {
        return AutoSelectStrategy();
    }
    
    Print("Adaptive selection: ", best_strategy, " (score: ", DoubleToString(best_score, 2), ")");
    return best_strategy;
}

//+------------------------------------------------------------------+
//| Portfolio strategy selection                                    |
//+------------------------------------------------------------------+
string PortfolioStrategySelection()
{
    // Rotate between strategies based on time or conditions
    static int strategy_rotation = 0;
    
    string strategies[] = {"RSI_Simple_Stocks", "Triple_RSI_Advanced", "Dual_RSI_Indices"};
    int strategy_count = ArraySize(strategies);
    
    string selected = strategies[strategy_rotation % strategy_count];
    strategy_rotation++;
    
    Print("Portfolio rotation: Selected ", selected);
    return selected;
}

//+------------------------------------------------------------------+
//| Calculate strategy performance score                            |
//+------------------------------------------------------------------+
double CalculateStrategyScore(SStrategyPerformance& performance)
{
    if(performance.total_trades == 0) return -999;
    
    double score = 0;
    
    // Win rate component (40% weight)
    score += (performance.win_rate / 100.0) * 40;
    
    // Profit factor component (30% weight)
    score += MathMin(performance.profit_factor / 2.0, 1.0) * 30;
    
    // Drawdown component (20% weight) - inverted
    score += (1.0 - MathMin(performance.max_drawdown / 50.0, 1.0)) * 20;
    
    // Net profit component (10% weight)
    score += MathMin(performance.net_profit / 1000.0, 1.0) * 10;
    
    return score;
}

//+------------------------------------------------------------------+
//| Update market data                                              |
//+------------------------------------------------------------------+
bool UpdateMarketData()
{
    // Copy ATR data
    if(CopyBuffer(g_atr_handle, 0, 0, InpAnalysisPeriod, g_atr_buffer) < InpAnalysisPeriod)
        return false;
    
    // Copy SMA data
    if(CopyBuffer(g_sma_200_handle, 0, 0, 2, g_sma_200_buffer) < 2)
        return false;
        
    if(CopyBuffer(g_sma_50_handle, 0, 0, 2, g_sma_50_buffer) < 2)
        return false;
    
    // Copy price data
    if(CopyClose(_Symbol, PERIOD_D1, 0, 2, g_close_buffer) < 2)
        return false;
    
    // Copy volume data
    if(InpAnalyzeVolume)
    {
        if(CopyTickVolume(_Symbol, PERIOD_D1, 0, InpAnalysisPeriod, g_volume_buffer) < InpAnalysisPeriod)
            return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Execute current strategy logic                                  |
//+------------------------------------------------------------------+
void ExecuteCurrentStrategy()
{
    if(g_current_strategy == "")
    {
        Print("No strategy selected");
        return;
    }
    
    // This is a simplified implementation
    // In practice, you would call the specific strategy's logic here
    // For now, we'll implement a basic RSI strategy using current config
    
    int rsi_handle = iRSI(_Symbol, PERIOD_D1, g_current_config.rsi_period, PRICE_CLOSE);
    if(rsi_handle == INVALID_HANDLE) return;
    
    double rsi_array[];
    ArraySetAsSeries(rsi_array, true);
    
    if(CopyBuffer(rsi_handle, 0, 0, 2, rsi_array) < 2)
    {
        IndicatorRelease(rsi_handle);
        return;
    }
    
    double current_rsi = rsi_array[0];
    double current_close = g_close_buffer[0];
    double sma_200 = g_sma_200_buffer[0];
    
    // Check exit conditions first
    if(PositionSelect(_Symbol))
    {
        if(current_rsi > g_current_config.rsi_overbought)
        {
            ClosePosition("RSI Overbought");
        }
    }
    else
    {
        // Check entry conditions
        bool rsi_oversold = current_rsi < g_current_config.rsi_oversold;
        bool trend_ok = !g_current_config.use_trend_filter || (current_close > sma_200);
        
        if(rsi_oversold && trend_ok)
        {
            OpenPosition();
        }
    }
    
    IndicatorRelease(rsi_handle);
}

//+------------------------------------------------------------------+
//| Open position using current strategy                           |
//+------------------------------------------------------------------+
void OpenPosition()
{
    double current_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    if(current_price <= 0) return;
    
    // Calculate stop loss
    double stop_loss = current_price * (1.0 - g_current_config.stop_loss_percent);
    
    // Calculate position size
    double volume = 0.01; // Default volume, should use risk manager
    if(g_global_risk_manager != NULL)
    {
        volume = g_global_risk_manager.CalculatePositionSize(current_price, stop_loss);
    }
    
    if(volume <= 0) return;
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = volume;
    request.type = ORDER_TYPE_BUY;
    request.price = current_price;
    request.sl = stop_loss;
    request.comment = "Strategy_Selector: " + g_current_strategy;
    request.magic = 999999;
    
    if(OrderSend(request, result))
    {
        if(result.retcode == TRADE_RETCODE_DONE)
        {
            Print("Position opened with strategy: ", g_current_strategy);
            Print("Price: ", DoubleToString(current_price, _Digits));
            Print("Volume: ", DoubleToString(volume, 2));
        }
    }
}

//+------------------------------------------------------------------+
//| Close position                                                   |
//+------------------------------------------------------------------+
void ClosePosition(string reason)
{
    if(!PositionSelect(_Symbol)) return;
    
    double position_volume = PositionGetDouble(POSITION_VOLUME);
    double position_profit = PositionGetDouble(POSITION_PROFIT);
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = position_volume;
    request.type = ORDER_TYPE_SELL;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    request.comment = "Strategy_Selector_Close: " + reason;
    request.magic = 999999;
    
    if(OrderSend(request, result))
    {
        if(result.retcode == TRADE_RETCODE_DONE)
        {
            // Update performance tracking
            if(g_strategy_monitor != NULL)
            {
                g_strategy_monitor.UpdateTrade(position_profit, position_volume);
            }
            UpdateStrategyPerformance(g_current_strategy, position_profit);
            
            Print("Position closed: ", reason);
            Print("Profit: $", DoubleToString(position_profit, 2));
        }
    }
}

//+------------------------------------------------------------------+
//| Update strategy performance tracking                            |
//+------------------------------------------------------------------+
void UpdateStrategyPerformance(string strategy_name, double trade_result)
{
    // Find or create strategy performance record
    int index = -1;
    for(int i = 0; i < g_strategy_count; i++)
    {
        if(g_strategy_performance[i].strategy_name == strategy_name)
        {
            index = i;
            break;
        }
    }
    
    if(index == -1 && g_strategy_count < 4)
    {
        index = g_strategy_count;
        g_strategy_performance[index].strategy_name = strategy_name;
        g_strategy_performance[index].total_trades = 0;
        g_strategy_performance[index].win_rate = 0;
        g_strategy_performance[index].profit_factor = 0;
        g_strategy_performance[index].max_drawdown = 0;
        g_strategy_performance[index].net_profit = 0;
        g_strategy_performance[index].is_active = true;
        g_strategy_count++;
    }
    
    if(index >= 0)
    {
        g_strategy_performance[index].total_trades++;
        g_strategy_performance[index].net_profit += trade_result;
        g_strategy_performance[index].last_trade_time = TimeCurrent();
        
        // Recalculate win rate (simplified)
        if(trade_result > 0)
        {
            double wins = (g_strategy_performance[index].win_rate * (g_strategy_performance[index].total_trades - 1) / 100.0) + 1;
            g_strategy_performance[index].win_rate = (wins / g_strategy_performance[index].total_trades) * 100.0;
        }
        else
        {
            double wins = (g_strategy_performance[index].win_rate * (g_strategy_performance[index].total_trades - 1) / 100.0);
            g_strategy_performance[index].win_rate = (wins / g_strategy_performance[index].total_trades) * 100.0;
        }
    }
}

//+------------------------------------------------------------------+
//| Check strategy performance and switch if needed                |
//+------------------------------------------------------------------+
void CheckStrategyPerformance()
{
    if(g_strategy_monitor == NULL) return;
    
    if(g_strategy_monitor.GetTotalTrades() < InpMinTradesForEvaluation)
        return;
    
    double current_win_rate = g_strategy_monitor.GetWinRate();
    double current_drawdown = g_strategy_monitor.GetMaxDrawdown();
    
    bool performance_poor = (current_win_rate < InpMinWinRate) || 
                           (current_drawdown > InpMaxDrawdown);
    
    if(performance_poor)
    {
        Print("Poor performance detected. Win Rate: ", DoubleToString(current_win_rate, 1), 
              "%, Max DD: ", DoubleToString(current_drawdown, 1), "%");
        Print("Switching to adaptive strategy selection...");
        
        // Force strategy reselection
        AnalyzeMarketConditions();
        SelectOptimalStrategy();
        
        // Reset performance monitor for new strategy
        delete g_strategy_monitor;
        g_strategy_monitor = new CPerformanceMonitor("Strategy_Selector_New");
    }
}

//+------------------------------------------------------------------+
//| Display strategy information on chart                          |
//+------------------------------------------------------------------+
void DisplayStrategyInfo()
{
    // Create or update text objects on chart
    string obj_name = "StrategyInfo_Main";
    
    if(ObjectFind(0, obj_name) < 0)
    {
        ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, 10);
        ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, 30);
        ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clrWhite);
        ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, 10);
    }
    
    string info_text = "Strategy: " + g_current_strategy + "\n" +
                      "Market: " + EnumToString(g_market_condition) + "\n" +
                      "Expected Win Rate: " + DoubleToString(g_current_config.expected_win_rate, 1) + "%\n" +
                      "Risk per Trade: " + DoubleToString(g_current_config.risk_percent * 100, 1) + "%";
    
    ObjectSetString(0, obj_name, OBJPROP_TEXT, info_text);
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Print strategy comparison report                                |
//+------------------------------------------------------------------+
void PrintStrategyComparisonReport()
{
    if(g_strategy_count == 0) return;
    
    Print("=== Strategy Performance Comparison ===");
    
    for(int i = 0; i < g_strategy_count; i++)
    {
        Print("Strategy: ", g_strategy_performance[i].strategy_name);
        Print("  Total Trades: ", g_strategy_performance[i].total_trades);
        Print("  Win Rate: ", DoubleToString(g_strategy_performance[i].win_rate, 1), "%");
        Print("  Net Profit: $", DoubleToString(g_strategy_performance[i].net_profit, 2));
        Print("  Max Drawdown: ", DoubleToString(g_strategy_performance[i].max_drawdown, 1), "%");
        Print("  Score: ", DoubleToString(CalculateStrategyScore(g_strategy_performance[i]), 2));
        Print("  --------------------------------");
    }
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    // Periodic market analysis and strategy evaluation
    if(TimeCurrent() - g_last_analysis_time >= 3600) // Every hour
    {
        AnalyzeMarketConditions();
        
        if(InpStrategyMode == STRATEGY_ADAPTIVE)
        {
            string new_strategy = AdaptiveStrategySelection();
            if(new_strategy != g_current_strategy)
            {
                Print("Switching strategy from ", g_current_strategy, " to ", new_strategy);
                SelectOptimalStrategy();
            }
        }
        
        // Update chart display
        if(InpShowStrategyInfo)
        {
            DisplayStrategyInfo();
        }
    }
}
