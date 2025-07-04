//+------------------------------------------------------------------+
//| Backtesting and Optimization Utility - FIXED VERSION           |
//| Developer: AI Assistant                                          |
//| Version: 2.0                                                     |
//| Description: Comprehensive backtesting system for RSI strategies|
//|              with multi-parameter optimization and reporting     |
//| Fixed: All compilation errors and improved performance          |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "2.00"
#property description "Advanced backtesting and optimization for RSI strategies - FIXED"
#property script_show_inputs

#include "ConfigManager.mqh"
#include "RiskManager.mqh"
#include "PerformanceMonitor.mqh"

//--- Input Parameters
input group "=== Backtesting Period ==="
input datetime    InpStartDate = D'2020.01.01';       // Backtest Start Date
input datetime    InpEndDate = D'2024.12.31';         // Backtest End Date
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_D1;       // Backtest Timeframe

input group "=== Strategy Selection ==="
input bool        InpTestRSISimple = true;            // Test RSI Simple Strategy
input bool        InpTestTripleRSI = true;            // Test Triple RSI Strategy
input bool        InpTestDualRSI = true;              // Test Dual RSI Strategy
input bool        InpTestAllConfigs = false;          // Test all available configurations

input group "=== Optimization Parameters ==="
input bool        InpOptimizeRSIPeriod = true;        // Optimize RSI Period
input int         InpRSIPeriodStart = 2;              // RSI Period Start
input int         InpRSIPeriodEnd = 21;               // RSI Period End
input int         InpRSIPeriodStep = 2;               // RSI Period Step

input bool        InpOptimizeOversold = true;         // Optimize Oversold Level
input double      InpOversoldStart = 10.0;            // Oversold Start
input double      InpOversoldEnd = 35.0;              // Oversold End
input double      InpOversoldStep = 5.0;              // Oversold Step

input bool        InpOptimizeOverbought = true;       // Optimize Overbought Level
input double      InpOverboughtStart = 65.0;          // Overbought Start
input double      InpOverboughtEnd = 90.0;            // Overbought End
input double      InpOverboughtStep = 5.0;            // Overbought Step

input bool        InpOptimizeRisk = true;             // Optimize Risk Level
input double      InpRiskStart = 0.01;                // Risk Start
input double      InpRiskEnd = 0.05;                  // Risk End
input double      InpRiskStep = 0.005;                // Risk Step

input group "=== Report Options ==="
input bool        InpGenerateDetailedReport = true;   // Generate detailed HTML report
input bool        InpSaveTradeLog = true;             // Save individual trade log
input bool        InpCreateEquityCurve = true;        // Create equity curve chart
input bool        InpExportToCSV = true;              // Export results to CSV

//--- Structures
struct SBacktestResult
{
    string strategy_name;
    int rsi_period;
    double oversold_level;
    double overbought_level;
    double risk_percent;
    
    int total_trades;
    int winning_trades;
    int losing_trades;
    double win_rate;
    double total_profit;
    double total_loss;
    double net_profit;
    double profit_factor;
    double max_drawdown;
    double max_consecutive_losses;
    double max_consecutive_wins;
    double average_win;
    double average_loss;
    double largest_win;
    double largest_loss;
    double expectancy;
    double sharpe_ratio;
    double sortino_ratio;
    datetime first_trade_time;
    datetime last_trade_time;
    double initial_balance;
    double final_balance;
    double return_percent;
    
    // Additional metrics
    double recovery_factor;
    double profit_per_month;
    double trades_per_month;
    int profitable_months;
    int losing_months;
    double max_monthly_gain;
    double max_monthly_loss;
};

struct STrade
{
    datetime open_time;
    datetime close_time;
    double open_price;
    double close_price;
    double volume;
    double profit;
    double profit_percent;
    string signal_reason;
    string exit_reason;
    double rsi_at_entry;
    double rsi_at_exit;
    int holding_period_hours;
};

//--- Global Variables
SBacktestResult g_results[];
STrade g_trades[];
int g_result_count = 0;
int g_trade_count = 0;
double g_current_balance = 10000.0; // Starting balance
double g_peak_balance = 10000.0;
double g_current_drawdown = 0.0;
double g_max_drawdown = 0.0;

// Configuration manager pointer (will be initialized in OnStart)
CConfigManager* g_config_mgr = NULL;

//+------------------------------------------------------------------+
//| Script start function                                           |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== Starting RSI Strategy Backtesting & Optimization ===");
    Print("Period: ", TimeToString(InpStartDate), " to ", TimeToString(InpEndDate));
    Print("Symbol: ", _Symbol);
    Print("Timeframe: ", EnumToString(InpTimeframe));
    
    // Initialize configuration manager
    if(!InitializeConfigManager())
    {
        Print("ERROR: Failed to initialize configuration manager");
        return;
    }
    
    // Prepare results array
    ArrayResize(g_results, 1000); // Reserve space for results
    ArrayResize(g_trades, 10000); // Reserve space for trades
    
    // Run backtests
    if(InpTestAllConfigs)
    {
        RunAllConfigBacktests();
    }
    else
    {
        if(InpTestRSISimple) RunStrategyBacktest("RSI_Simple_Stocks");
        if(InpTestTripleRSI) RunStrategyBacktest("Triple_RSI_Advanced");
        if(InpTestDualRSI) RunStrategyBacktest("Dual_RSI_Indices");
    }
    
    // Generate reports
    GenerateOptimizationReport();
    
    if(InpGenerateDetailedReport)
        GenerateHTMLReport();
        
    if(InpExportToCSV)
        ExportResultsToCSV();
        
    if(InpSaveTradeLog)
        SaveTradeLog();
    
    Print("Backtesting completed. Total tests: ", g_result_count);
    Print("Best result: ", FindBestResult());
    
    // Cleanup
    CleanupConfigManager();
}

//+------------------------------------------------------------------+
//| Initialize configuration manager                                |
//+------------------------------------------------------------------+
bool InitializeConfigManager()
{
    // Initialize the global config manager from ConfigManager.mqh
    if(!InitConfigManager())
    {
        Print("Failed to initialize global config manager");
        return false;
    }
    
    // Get the global instance
    g_config_mgr = GetConfigManager();
    if(g_config_mgr == NULL)
    {
        Print("Failed to get config manager instance");
        return false;
    }
    
    Print("Configuration manager initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Cleanup configuration manager                                  |
//+------------------------------------------------------------------+
void CleanupConfigManager()
{
    DeinitConfigManager();
    g_config_mgr = NULL;
}

//+------------------------------------------------------------------+
//| Run backtest for all available configurations                  |
//+------------------------------------------------------------------+
void RunAllConfigBacktests()
{
    Print("Running backtests for all available configurations...");
    
    if(g_config_mgr == NULL) return;
    
    int config_count = g_config_mgr.GetConfigCount();
    
    for(int i = 0; i < config_count; i++)
    {
        SStrategyConfig config;
        if(g_config_mgr.GetConfigByIndex(i, config))
        {
            RunConfigurationBacktest(config);
        }
    }
}

//+------------------------------------------------------------------+
//| Run backtest for specific strategy with optimization           |
//+------------------------------------------------------------------+
void RunStrategyBacktest(string strategy_name)
{
    Print("Running optimization for strategy: ", strategy_name);
    
    if(g_config_mgr == NULL)
    {
        Print("ERROR: Config manager not initialized");
        return;
    }
    
    SStrategyConfig base_config;
    if(!g_config_mgr.GetConfig(strategy_name, base_config))
    {
        Print("ERROR: Strategy configuration not found: ", strategy_name);
        return;
    }
    
    // Generate parameter combinations
    int total_combinations = CalculateTotalCombinations();
    Print("Total parameter combinations to test: ", total_combinations);
    
    int test_count = 0;
    
    // RSI Period optimization
    int rsi_start = InpOptimizeRSIPeriod ? InpRSIPeriodStart : base_config.rsi_period;
    int rsi_end = InpOptimizeRSIPeriod ? InpRSIPeriodEnd : base_config.rsi_period;
    int rsi_step = InpOptimizeRSIPeriod ? InpRSIPeriodStep : 1;
    
    for(int rsi_period = rsi_start; rsi_period <= rsi_end; rsi_period += rsi_step)
    {
        // Oversold level optimization
        double os_start = InpOptimizeOversold ? InpOversoldStart : base_config.rsi_oversold;
        double os_end = InpOptimizeOversold ? InpOversoldEnd : base_config.rsi_oversold;
        double os_step = InpOptimizeOversold ? InpOversoldStep : 1.0;
        
        for(double oversold = os_start; oversold <= os_end; oversold += os_step)
        {
            // Overbought level optimization
            double ob_start = InpOptimizeOverbought ? InpOverboughtStart : base_config.rsi_overbought;
            double ob_end = InpOptimizeOverbought ? InpOverboughtEnd : base_config.rsi_overbought;
            double ob_step = InpOptimizeOverbought ? InpOverboughtStep : 1.0;
            
            for(double overbought = ob_start; overbought <= ob_end; overbought += ob_step)
            {
                // Risk optimization
                double risk_start = InpOptimizeRisk ? InpRiskStart : base_config.risk_percent;
                double risk_end = InpOptimizeRisk ? InpRiskEnd : base_config.risk_percent;
                double risk_step = InpOptimizeRisk ? InpRiskStep : 0.001;
                
                for(double risk = risk_start; risk <= risk_end; risk += risk_step)
                {
                    // Skip invalid combinations
                    if(oversold >= overbought) continue;
                    
                    // Create test configuration
                    SStrategyConfig test_config = base_config;
                    test_config.rsi_period = rsi_period;
                    test_config.rsi_oversold = oversold;
                    test_config.rsi_overbought = overbought;
                    test_config.risk_percent = risk;
                    
                    // Run backtest
                    RunConfigurationBacktest(test_config);
                    
                    test_count++;
                    
                    // Progress report
                    if(test_count % 50 == 0)
                    {
                        Print("Progress: ", test_count, "/", total_combinations, 
                              " (", DoubleToString((double)test_count/total_combinations*100, 1), "%)");
                    }
                }
            }
        }
    }
    
    Print("Completed ", test_count, " optimization tests for ", strategy_name);
}

//+------------------------------------------------------------------+
//| Run backtest for specific configuration                        |
//+------------------------------------------------------------------+
void RunConfigurationBacktest(SStrategyConfig& config)
{
    // Reset for this test
    g_current_balance = 10000.0;
    g_peak_balance = 10000.0;
    g_current_drawdown = 0.0;
    int temp_trade_start = g_trade_count;
    
    // Initialize indicators for this test
    int rsi_handle = iRSI(_Symbol, InpTimeframe, config.rsi_period, PRICE_CLOSE);
    int sma_handle = iMA(_Symbol, InpTimeframe, config.sma_period, 0, MODE_SMA, PRICE_CLOSE);
    
    if(rsi_handle == INVALID_HANDLE || sma_handle == INVALID_HANDLE)
    {
        Print("Failed to initialize indicators for test");
        return;
    }
    
    // Wait for indicators to be calculated
    if(!WaitForIndicators(rsi_handle, sma_handle))
    {
        Print("Timeout waiting for indicators");
        IndicatorRelease(rsi_handle);
        IndicatorRelease(sma_handle);
        return;
    }
    
    // Get bars count for the period
    int bars = Bars(_Symbol, InpTimeframe, InpStartDate, InpEndDate);
    if(bars < 100)
    {
        Print("Insufficient data for backtesting: ", bars, " bars");
        IndicatorRelease(rsi_handle);
        IndicatorRelease(sma_handle);
        return;
    }
    
    // Prepare data arrays
    double rsi_array[], sma_array[], high_array[], low_array[], close_array[], open_array[];
    datetime time_array[];
    
    ArraySetAsSeries(rsi_array, true);
    ArraySetAsSeries(sma_array, true);
    ArraySetAsSeries(high_array, true);
    ArraySetAsSeries(low_array, true);
    ArraySetAsSeries(close_array, true);
    ArraySetAsSeries(open_array, true);
    ArraySetAsSeries(time_array, true);
    
    // Copy data with proper indexing
    int copied_bars = MathMin(bars, 5000); // Limit to prevent memory issues
    
    if(CopyBuffer(rsi_handle, 0, 0, copied_bars, rsi_array) <= 0 ||
       CopyBuffer(sma_handle, 0, 0, copied_bars, sma_array) <= 0 ||
       CopyHigh(_Symbol, InpTimeframe, 0, copied_bars, high_array) <= 0 ||
       CopyLow(_Symbol, InpTimeframe, 0, copied_bars, low_array) <= 0 ||
       CopyClose(_Symbol, InpTimeframe, 0, copied_bars, close_array) <= 0 ||
       CopyOpen(_Symbol, InpTimeframe, 0, copied_bars, open_array) <= 0 ||
       CopyTime(_Symbol, InpTimeframe, 0, copied_bars, time_array) <= 0)
    {
        Print("Failed to copy data arrays");
        IndicatorRelease(rsi_handle);
        IndicatorRelease(sma_handle);
        return;
    }
    
    // Run simulation
    bool in_position = false;
    STrade current_trade;
    int consecutive_wins = 0, consecutive_losses = 0;
    int max_consecutive_wins = 0, max_consecutive_losses = 0;
    double equity_peak = 10000.0;
    
    for(int i = copied_bars - 1; i >= 1; i--) // Start from oldest data
    {
        // Validate data
        if(time_array[i] == 0 || close_array[i] == 0.0) continue;
        if(time_array[i] < InpStartDate || time_array[i] > InpEndDate) continue;
        if(rsi_array[i] == EMPTY_VALUE || sma_array[i] == EMPTY_VALUE) continue;
            
        double current_rsi = rsi_array[i];
        double current_close = close_array[i];
        double current_sma = sma_array[i];
        double prev_high = (i + 1 < copied_bars) ? high_array[i + 1] : current_close;
        
        // Exit logic
        if(in_position)
        {
            bool exit_condition = false;
            string exit_reason = "";
            
            if(current_rsi > config.rsi_overbought)
            {
                exit_condition = true;
                exit_reason = "RSI Overbought";
            }
            else if(current_close > prev_high)
            {
                exit_condition = true;
                exit_reason = "Price Above Previous High";
            }
            
            if(exit_condition)
            {
                // Close trade
                current_trade.close_time = time_array[i];
                current_trade.close_price = current_close;
                current_trade.exit_reason = exit_reason;
                current_trade.rsi_at_exit = current_rsi;
                current_trade.holding_period_hours = (int)((current_trade.close_time - current_trade.open_time) / 3600);
                
                // Calculate profit
                current_trade.profit_percent = (current_trade.close_price - current_trade.open_price) / current_trade.open_price * 100;
                current_trade.profit = g_current_balance * config.risk_percent * current_trade.profit_percent / 100;
                
                // Update balance
                g_current_balance += current_trade.profit;
                
                // Update equity peak and drawdown
                if(g_current_balance > equity_peak)
                {
                    equity_peak = g_current_balance;
                    g_current_drawdown = 0;
                }
                else
                {
                    g_current_drawdown = (equity_peak - g_current_balance) / equity_peak * 100;
                    if(g_current_drawdown > g_max_drawdown)
                        g_max_drawdown = g_current_drawdown;
                }
                
                // Track consecutive wins/losses
                if(current_trade.profit > 0)
                {
                    consecutive_wins++;
                    consecutive_losses = 0;
                    if(consecutive_wins > max_consecutive_wins)
                        max_consecutive_wins = consecutive_wins;
                }
                else
                {
                    consecutive_losses++;
                    consecutive_wins = 0;
                    if(consecutive_losses > max_consecutive_losses)
                        max_consecutive_losses = consecutive_losses;
                }
                
                // Save trade
                if(g_trade_count < ArraySize(g_trades))
                {
                    g_trades[g_trade_count] = current_trade;
                    g_trade_count++;
                }
                
                in_position = false;
            }
        }
        else
        {
            // Entry logic
            bool entry_condition = false;
            string entry_reason = "";
            
            if(current_rsi < config.rsi_oversold)
            {
                if(!config.use_trend_filter || current_close > current_sma)
                {
                    entry_condition = true;
                    entry_reason = "RSI Oversold";
                }
            }
            
            if(entry_condition)
            {
                // Open trade
                current_trade.open_time = time_array[i];
                current_trade.open_price = current_close;
                current_trade.signal_reason = entry_reason;
                current_trade.rsi_at_entry = current_rsi;
                current_trade.volume = CalculatePositionSize(current_close, config.risk_percent);
                
                in_position = true;
            }
        }
    }
    
    // Calculate final results
    SBacktestResult result;
    CalculateBacktestResults(result, config, temp_trade_start);
    
    // Save result
    if(g_result_count < ArraySize(g_results))
    {
        g_results[g_result_count] = result;
        g_result_count++;
    }
    
    // Cleanup
    IndicatorRelease(rsi_handle);
    IndicatorRelease(sma_handle);
}

//+------------------------------------------------------------------+
//| Wait for indicators to be ready                                |
//+------------------------------------------------------------------+
bool WaitForIndicators(int handle1, int handle2, int timeout_ms = 5000)
{
    int start_time = (int)GetTickCount();
    
    while((int)GetTickCount() - start_time < timeout_ms)
    {
        if(BarsCalculated(handle1) > 0 && BarsCalculated(handle2) > 0)
            return true;
        Sleep(10);
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Calculate position size based on risk                          |
//+------------------------------------------------------------------+
double CalculatePositionSize(double price, double risk_percent)
{
    // Simplified position sizing
    double risk_amount = g_current_balance * risk_percent;
    double stop_distance = price * 0.02; // 2% stop loss
    double volume = risk_amount / stop_distance;
    
    return MathMax(0.01, volume); // Minimum volume
}

//+------------------------------------------------------------------+
//| Calculate backtest results                                      |
//+------------------------------------------------------------------+
void CalculateBacktestResults(SBacktestResult& result, SStrategyConfig& config, int trade_start_index)
{
    // Get strategy name as string
    result.strategy_name = g_config_mgr.GetStrategyName(config);
    
    result.rsi_period = config.rsi_period;
    result.oversold_level = config.rsi_oversold;
    result.overbought_level = config.rsi_overbought;
    result.risk_percent = config.risk_percent;
    result.initial_balance = 10000.0;
    result.final_balance = g_current_balance;
    result.return_percent = (g_current_balance - 10000.0) / 10000.0 * 100;
    result.max_drawdown = g_max_drawdown;
    
    // Calculate trade statistics
    result.total_trades = g_trade_count - trade_start_index;
    result.winning_trades = 0;
    result.losing_trades = 0;
    result.total_profit = 0;
    result.total_loss = 0;
    result.largest_win = 0;
    result.largest_loss = 0;
    
    for(int i = trade_start_index; i < g_trade_count; i++)
    {
        if(g_trades[i].profit > 0)
        {
            result.winning_trades++;
            result.total_profit += g_trades[i].profit;
            if(g_trades[i].profit > result.largest_win)
                result.largest_win = g_trades[i].profit;
        }
        else
        {
            result.losing_trades++;
            result.total_loss += MathAbs(g_trades[i].profit);
            if(MathAbs(g_trades[i].profit) > result.largest_loss)
                result.largest_loss = MathAbs(g_trades[i].profit);
        }
        
        if(i == trade_start_index)
            result.first_trade_time = g_trades[i].open_time;
        if(i == g_trade_count - 1)
            result.last_trade_time = g_trades[i].close_time;
    }
    
    // Calculate derived metrics
    if(result.total_trades > 0)
    {
        result.win_rate = (double)result.winning_trades / result.total_trades * 100;
        result.net_profit = result.total_profit - result.total_loss;
        
        if(result.winning_trades > 0)
            result.average_win = result.total_profit / result.winning_trades;
            
        if(result.losing_trades > 0)
            result.average_loss = result.total_loss / result.losing_trades;
            
        if(result.total_loss > 0)
            result.profit_factor = result.total_profit / result.total_loss;
        else
            result.profit_factor = 999; // All winning trades
            
        result.expectancy = result.net_profit / result.total_trades;
        
        // Calculate monthly metrics
        if(result.last_trade_time > result.first_trade_time)
        {
            double months = (double)(result.last_trade_time - result.first_trade_time) / (30 * 24 * 3600);
            if(months > 0)
            {
                result.profit_per_month = result.net_profit / months;
                result.trades_per_month = result.total_trades / months;
            }
        }
        
        // Recovery factor
        if(result.max_drawdown > 0)
            result.recovery_factor = result.net_profit / result.max_drawdown;
    }
}

//+------------------------------------------------------------------+
//| Calculate total optimization combinations                       |
//+------------------------------------------------------------------+
int CalculateTotalCombinations()
{
    int rsi_combinations = InpOptimizeRSIPeriod ? ((InpRSIPeriodEnd - InpRSIPeriodStart) / InpRSIPeriodStep + 1) : 1;
    int os_combinations = InpOptimizeOversold ? (int)((InpOversoldEnd - InpOversoldStart) / InpOversoldStep + 1) : 1;
    int ob_combinations = InpOptimizeOverbought ? (int)((InpOverboughtEnd - InpOverboughtStart) / InpOverboughtStep + 1) : 1;
    int risk_combinations = InpOptimizeRisk ? (int)((InpRiskEnd - InpRiskStart) / InpRiskStep + 1) : 1;
    
    return rsi_combinations * os_combinations * ob_combinations * risk_combinations;
}

//+------------------------------------------------------------------+
//| Find best result based on multiple criteria                    |
//+------------------------------------------------------------------+
string FindBestResult()
{
    if(g_result_count == 0) return "No results";
    
    int best_index = 0;
    double best_score = -999999;
    
    for(int i = 0; i < g_result_count; i++)
    {
        // Calculate composite score
        double score = 0;
        
        // Profit factor (25% weight)
        score += MathMin(g_results[i].profit_factor / 3.0, 1.0) * 25;
        
        // Win rate (25% weight)
        score += (g_results[i].win_rate / 100.0) * 25;
        
        // Return (30% weight)
        score += MathMin(g_results[i].return_percent / 50.0, 1.0) * 30;
        
        // Recovery factor (20% weight)
        score += MathMin(g_results[i].recovery_factor / 5.0, 1.0) * 20;
        
        if(score > best_score && g_results[i].total_trades >= 10)
        {
            best_score = score;
            best_index = i;
        }
    }
    
    return "Strategy: " + g_results[best_index].strategy_name + 
           ", RSI: " + IntegerToString(g_results[best_index].rsi_period) +
           ", Oversold: " + DoubleToString(g_results[best_index].oversold_level, 1) +
           ", Win Rate: " + DoubleToString(g_results[best_index].win_rate, 1) + "%" +
           ", Return: " + DoubleToString(g_results[best_index].return_percent, 1) + "%";
}

//+------------------------------------------------------------------+
//| Generate optimization report                                    |
//+------------------------------------------------------------------+
void GenerateOptimizationReport()
{
    Print("=== BACKTESTING OPTIMIZATION REPORT ===");
    Print("Period: ", TimeToString(InpStartDate), " to ", TimeToString(InpEndDate));
    Print("Symbol: ", _Symbol);
    Print("Total Tests: ", g_result_count);
    Print("Total Trades: ", g_trade_count);
    Print("");
    
    // Sort results by composite score
    SortResultsByScore();
    
    Print("TOP 10 RESULTS:");
    Print("Rank | Strategy | RSI | OS | OB | Risk% | Trades | Win% | PF | Return% | MaxDD% | Score");
    Print("-----|----------|-----|----|----|-------|--------|------|----|---------|---------|---------");
    
    for(int i = 0; i < MathMin(10, g_result_count); i++)
    {
        double score = CalculateResultScore(g_results[i]);
        
        Print(StringFormat("%4d | %8s | %3d | %2.0f | %2.0f | %5.1f | %6d | %4.1f | %3.1f | %7.1f | %6.1f | %7.2f",
            i+1,
            StringSubstr(g_results[i].strategy_name, 0, 8),
            g_results[i].rsi_period,
            g_results[i].oversold_level,
            g_results[i].overbought_level,
            g_results[i].risk_percent * 100,
            g_results[i].total_trades,
            g_results[i].win_rate,
            g_results[i].profit_factor,
            g_results[i].return_percent,
            g_results[i].max_drawdown,
            score));
    }
    
    Print("");
    Print("Best Overall Result:");
    if(g_result_count > 0)
    {
        SBacktestResult best = g_results[0];
        Print("Strategy: ", best.strategy_name);
        Print("Parameters: RSI(", best.rsi_period, "), Oversold=", best.oversold_level, ", Overbought=", best.overbought_level);
        Print("Risk per Trade: ", DoubleToString(best.risk_percent * 100, 1), "%");
        Print("Total Trades: ", best.total_trades);
        Print("Win Rate: ", DoubleToString(best.win_rate, 1), "%");
        Print("Profit Factor: ", DoubleToString(best.profit_factor, 2));
        Print("Net Profit: $", DoubleToString(best.net_profit, 2));
        Print("Return: ", DoubleToString(best.return_percent, 1), "%");
        Print("Max Drawdown: ", DoubleToString(best.max_drawdown, 1), "%");
        Print("Recovery Factor: ", DoubleToString(best.recovery_factor, 2));
        Print("Expectancy: $", DoubleToString(best.expectancy, 2));
    }
}

//+------------------------------------------------------------------+
//| Calculate result score                                          |
//+------------------------------------------------------------------+
double CalculateResultScore(SBacktestResult& result)
{
    if(result.total_trades < 5) return 0;
    
    double score = 0;
    score += MathMin(result.profit_factor / 3.0, 1.0) * 25;
    score += (result.win_rate / 100.0) * 25;
    score += MathMin(result.return_percent / 50.0, 1.0) * 30;
    score += MathMin(result.recovery_factor / 5.0, 1.0) * 20;
    
    return score;
}

//+------------------------------------------------------------------+
//| Sort results by score                                          |
//+------------------------------------------------------------------+
void SortResultsByScore()
{
    // Simple bubble sort by score
    for(int i = 0; i < g_result_count - 1; i++)
    {
        for(int j = 0; j < g_result_count - 1 - i; j++)
        {
            if(CalculateResultScore(g_results[j]) < CalculateResultScore(g_results[j + 1]))
            {
                SBacktestResult temp = g_results[j];
                g_results[j] = g_results[j + 1];
                g_results[j + 1] = temp;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Generate HTML report                                            |
//+------------------------------------------------------------------+
void GenerateHTMLReport()
{
    string filename = "RSI_Backtest_Report_" + _Symbol + "_" + TimeToString(TimeCurrent(), TIME_DATE) + ".html";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    
    if(file_handle != INVALID_HANDLE)
    {
        // Write HTML header
        FileWriteString(file_handle, "<!DOCTYPE html>\n<html>\n<head>\n");
        FileWriteString(file_handle, "<title>RSI Strategy Backtest Report</title>\n");
        FileWriteString(file_handle, "<meta charset='UTF-8'>\n");
        FileWriteString(file_handle, "<style>\n");
        FileWriteString(file_handle, "body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }\n");
        FileWriteString(file_handle, ".container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }\n");
        FileWriteString(file_handle, "h1 { color: #2c3e50; text-align: center; border-bottom: 3px solid #3498db; padding-bottom: 10px; }\n");
        FileWriteString(file_handle, "h3 { color: #34495e; margin-top: 30px; }\n");
        FileWriteString(file_handle, "table { border-collapse: collapse; width: 100%; margin: 20px 0; }\n");
        FileWriteString(file_handle, "th, td { border: 1px solid #ddd; padding: 12px; text-align: center; }\n");
        FileWriteString(file_handle, "th { background-color: #3498db; color: white; font-weight: bold; }\n");
        FileWriteString(file_handle, "tr:nth-child(even) { background-color: #f9f9f9; }\n");
        FileWriteString(file_handle, "tr:hover { background-color: #e8f4fd; }\n");
        FileWriteString(file_handle, ".positive { color: #27ae60; font-weight: bold; }\n");
        FileWriteString(file_handle, ".negative { color: #e74c3c; font-weight: bold; }\n");
        FileWriteString(file_handle, ".neutral { color: #7f8c8d; }\n");
        FileWriteString(file_handle, ".summary { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 20px 0; }\n");
        FileWriteString(file_handle, ".summary ul { margin: 0; }\n");
        FileWriteString(file_handle, ".summary li { margin: 5px 0; }\n");
        FileWriteString(file_handle, "</style>\n</head>\n<body>\n");
        
        // Write content container
        FileWriteString(file_handle, "<div class='container'>\n");
        
        // Write report header
        FileWriteString(file_handle, "<h1>🚀 RSI Strategy Backtesting Report</h1>\n");
        
        // Write summary
        FileWriteString(file_handle, "<div class='summary'>\n");
        FileWriteString(file_handle, "<h3>📊 Test Parameters</h3>\n");
        FileWriteString(file_handle, "<ul>\n");
        FileWriteString(file_handle, "<li><strong>Symbol:</strong> " + _Symbol + "</li>\n");
        FileWriteString(file_handle, "<li><strong>Period:</strong> " + TimeToString(InpStartDate) + " to " + TimeToString(InpEndDate) + "</li>\n");
        FileWriteString(file_handle, "<li><strong>Timeframe:</strong> " + EnumToString(InpTimeframe) + "</li>\n");
        FileWriteString(file_handle, "<li><strong>Total Tests:</strong> " + IntegerToString(g_result_count) + "</li>\n");
        FileWriteString(file_handle, "<li><strong>Total Trades:</strong> " + IntegerToString(g_trade_count) + "</li>\n");
        FileWriteString(file_handle, "<li><strong>Report Generated:</strong> " + TimeToString(TimeCurrent()) + "</li>\n");
        FileWriteString(file_handle, "</ul>\n");
        FileWriteString(file_handle, "</div>\n");
        
        // Results table
        FileWriteString(file_handle, "<h3>🏆 Top 20 Results</h3>\n");
        FileWriteString(file_handle, "<table>\n");
        FileWriteString(file_handle, "<tr><th>Rank</th><th>Strategy</th><th>RSI Period</th><th>Oversold</th><th>Overbought</th>");
        FileWriteString(file_handle, "<th>Risk%</th><th>Trades</th><th>Win%</th><th>Profit Factor</th><th>Return%</th><th>Max DD%</th><th>Score</th></tr>\n");
        
        for(int i = 0; i < MathMin(20, g_result_count); i++)
        {
            string row_class = (g_results[i].return_percent > 0) ? "positive" : "negative";
            double score = CalculateResultScore(g_results[i]);
            
            FileWriteString(file_handle, "<tr>");
            FileWriteString(file_handle, "<td>" + IntegerToString(i + 1) + "</td>");
            FileWriteString(file_handle, "<td>" + g_results[i].strategy_name + "</td>");
            FileWriteString(file_handle, "<td>" + IntegerToString(g_results[i].rsi_period) + "</td>");
            FileWriteString(file_handle, "<td>" + DoubleToString(g_results[i].oversold_level, 0) + "</td>");
            FileWriteString(file_handle, "<td>" + DoubleToString(g_results[i].overbought_level, 0) + "</td>");
            FileWriteString(file_handle, "<td>" + DoubleToString(g_results[i].risk_percent * 100, 1) + "</td>");
            FileWriteString(file_handle, "<td>" + IntegerToString(g_results[i].total_trades) + "</td>");
            FileWriteString(file_handle, "<td>" + DoubleToString(g_results[i].win_rate, 1) + "</td>");
            FileWriteString(file_handle, "<td>" + DoubleToString(g_results[i].profit_factor, 2) + "</td>");
            FileWriteString(file_handle, "<td class='" + row_class + "'>" + DoubleToString(g_results[i].return_percent, 1) + "</td>");
            FileWriteString(file_handle, "<td>" + DoubleToString(g_results[i].max_drawdown, 1) + "</td>");
            FileWriteString(file_handle, "<td>" + DoubleToString(score, 2) + "</td>");
            FileWriteString(file_handle, "</tr>\n");
        }
        
        FileWriteString(file_handle, "</table>\n");
        
        // Best result details
        if(g_result_count > 0)
        {
            FileWriteString(file_handle, "<div class='summary'>\n");
            FileWriteString(file_handle, "<h3>🎯 Best Overall Result</h3>\n");
            SBacktestResult best = g_results[0];
            FileWriteString(file_handle, "<ul>\n");
            FileWriteString(file_handle, "<li><strong>Strategy:</strong> " + best.strategy_name + "</li>\n");
            FileWriteString(file_handle, "<li><strong>RSI Period:</strong> " + IntegerToString(best.rsi_period) + "</li>\n");
            FileWriteString(file_handle, "<li><strong>Oversold Level:</strong> " + DoubleToString(best.oversold_level, 1) + "</li>\n");
            FileWriteString(file_handle, "<li><strong>Overbought Level:</strong> " + DoubleToString(best.overbought_level, 1) + "</li>\n");
            FileWriteString(file_handle, "<li><strong>Risk per Trade:</strong> " + DoubleToString(best.risk_percent * 100, 1) + "%</li>\n");
            FileWriteString(file_handle, "<li><strong>Total Trades:</strong> " + IntegerToString(best.total_trades) + "</li>\n");
            FileWriteString(file_handle, "<li><strong>Win Rate:</strong> " + DoubleToString(best.win_rate, 1) + "%</li>\n");
            FileWriteString(file_handle, "<li><strong>Profit Factor:</strong> " + DoubleToString(best.profit_factor, 2) + "</li>\n");
            FileWriteString(file_handle, "<li><strong>Net Profit:</strong> $" + DoubleToString(best.net_profit, 2) + "</li>\n");
            FileWriteString(file_handle, "<li><strong>Return:</strong> " + DoubleToString(best.return_percent, 1) + "%</li>\n");
            FileWriteString(file_handle, "<li><strong>Max Drawdown:</strong> " + DoubleToString(best.max_drawdown, 1) + "%</li>\n");
            FileWriteString(file_handle, "<li><strong>Recovery Factor:</strong> " + DoubleToString(best.recovery_factor, 2) + "</li>\n");
            FileWriteString(file_handle, "</ul>\n");
            FileWriteString(file_handle, "</div>\n");
        }
        
        // Close container and HTML
        FileWriteString(file_handle, "</div>\n");
        FileWriteString(file_handle, "</body>\n</html>");
        
        FileClose(file_handle);
        Print("Enhanced HTML report generated: ", filename);
    }
    else
    {
        Print("Failed to create HTML report file: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Export results to CSV                                          |
//+------------------------------------------------------------------+
void ExportResultsToCSV()
{
    string filename = "RSI_Backtest_Results_" + _Symbol + "_" + TimeToString(TimeCurrent(), TIME_DATE) + ".csv";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON);
    
    if(file_handle != INVALID_HANDLE)
    {
        // Write header
        FileWrite(file_handle, "Strategy", "RSI_Period", "Oversold", "Overbought", "Risk_Percent", 
                 "Total_Trades", "Win_Rate", "Profit_Factor", "Net_Profit", "Return_Percent", 
                 "Max_Drawdown", "Recovery_Factor", "Expectancy", "Avg_Win", "Avg_Loss");
        
        // Write data
        for(int i = 0; i < g_result_count; i++)
        {
            FileWrite(file_handle, 
                g_results[i].strategy_name,
                g_results[i].rsi_period,
                g_results[i].oversold_level,
                g_results[i].overbought_level,
                g_results[i].risk_percent,
                g_results[i].total_trades,
                g_results[i].win_rate,
                g_results[i].profit_factor,
                g_results[i].net_profit,
                g_results[i].return_percent,
                g_results[i].max_drawdown,
                g_results[i].recovery_factor,
                g_results[i].expectancy,
                g_results[i].average_win,
                g_results[i].average_loss);
        }
        
        FileClose(file_handle);
        Print("Results exported to CSV: ", filename);
    }
    else
    {
        Print("Failed to create CSV file: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Save trade log                                                  |
//+------------------------------------------------------------------+
void SaveTradeLog()
{
    string filename = "RSI_Trade_Log_" + _Symbol + "_" + TimeToString(TimeCurrent(), TIME_DATE) + ".csv";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON);
    
    if(file_handle != INVALID_HANDLE)
    {
        // Write header
        FileWrite(file_handle, "Open_Time", "Close_Time", "Open_Price", "Close_Price", 
                 "Profit", "Profit_Percent", "Signal_Reason", "Exit_Reason", 
                 "RSI_Entry", "RSI_Exit", "Holding_Hours");
        
        // Write trade data
        for(int i = 0; i < g_trade_count; i++)
        {
            FileWrite(file_handle,
                TimeToString(g_trades[i].open_time),
                TimeToString(g_trades[i].close_time),
                g_trades[i].open_price,
                g_trades[i].close_price,
                g_trades[i].profit,
                g_trades[i].profit_percent,
                g_trades[i].signal_reason,
                g_trades[i].exit_reason,
                g_trades[i].rsi_at_entry,
                g_trades[i].rsi_at_exit,
                g_trades[i].holding_period_hours);
        }
        
        FileClose(file_handle);
        Print("Trade log saved: ", filename);
    }
    else
    {
        Print("Failed to create trade log file: ", GetLastError());
    }
}