//+------------------------------------------------------------------+
//| Advanced Statistics and Reporting System                        |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Comprehensive statistics calculation and reporting |
//|              system for RSI momentum strategies                 |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Advanced Statistics Structures                                  |
//+------------------------------------------------------------------+
struct STradingStatistics
{
    // Basic Trade Statistics
    int total_trades;
    int winning_trades;
    int losing_trades;
    int breakeven_trades;
    double win_rate;
    double loss_rate;
    
    // Profit/Loss Statistics
    double gross_profit;
    double gross_loss;
    double net_profit;
    double profit_factor;
    double recovery_factor;
    double expected_payoff;
    double absolute_drawdown;
    double maximal_drawdown;
    double relative_drawdown;
    
    // Individual Trade Statistics
    double largest_profit_trade;
    double largest_loss_trade;
    double average_profit_trade;
    double average_loss_trade;
    double average_trade_length;
    
    // Consecutive Statistics
    int maximum_consecutive_wins;
    int maximum_consecutive_losses;
    int current_consecutive_wins;
    int current_consecutive_losses;
    double maximum_consecutive_profit;
    double maximum_consecutive_loss;
    
    // Advanced Risk Metrics
    double sharpe_ratio;
    double sortino_ratio;
    double calmar_ratio;
    double var_95;               // Value at Risk 95%
    double cvar_95;              // Conditional VaR 95%
    double maximum_adverse_excursion; // MAE
    double maximum_favorable_excursion; // MFE
    
    // Time-based Statistics
    double profit_per_day;
    double profit_per_month;
    double profit_per_year;
    int trades_per_day;
    int trades_per_month;
    int profitable_months;
    int losing_months;
    
    // Distribution Statistics
    double profit_standard_deviation;
    double profit_skewness;
    double profit_kurtosis;
    double trade_length_std_dev;
    
    // Portfolio Statistics
    double portfolio_beta;
    double portfolio_alpha;
    double information_ratio;
    double tracking_error;
    
    // Market Correlation
    double market_correlation;
    double up_market_capture;
    double down_market_capture;
};

struct SPerformancePeriod
{
    datetime start_time;
    datetime end_time;
    double starting_balance;
    double ending_balance;
    double period_return;
    double period_volatility;
    double period_sharpe;
    int period_trades;
    double period_win_rate;
    double period_max_drawdown;
};

struct STradeAnalysis
{
    datetime open_time;
    datetime close_time;
    double open_price;
    double close_price;
    double volume;
    double profit;
    double profit_percent;
    double mae_percent;          // Maximum Adverse Excursion
    double mfe_percent;          // Maximum Favorable Excursion
    int trade_length_bars;
    double entry_rsi;
    double exit_rsi;
    string entry_signal;
    string exit_signal;
    double market_return;        // Market return during trade
    double excess_return;        // Trade return vs market
};

//+------------------------------------------------------------------+
//| Advanced Statistics Calculator Class                            |
//+------------------------------------------------------------------+
class CAdvancedStatistics
{
private:
    STradeAnalysis m_trades[];
    STradingStatistics m_stats;
    SPerformancePeriod m_periods[];
    
    int m_trade_count;
    int m_period_count;
    double m_initial_balance;
    double m_current_balance;
    double m_peak_balance;
    string m_strategy_name;
    
    // Market data for correlation analysis
    double m_market_returns[];
    double m_portfolio_returns[];
    datetime m_return_dates[];
    int m_return_count;
    
public:
    // Constructor
    CAdvancedStatistics(string strategy_name = "RSI_Strategy", double initial_balance = 10000.0)
    {
        m_strategy_name = strategy_name;
        m_initial_balance = initial_balance;
        m_current_balance = initial_balance;
        m_peak_balance = initial_balance;
        m_trade_count = 0;
        m_period_count = 0;
        m_return_count = 0;
        
        ArrayResize(m_trades, 10000);
        ArrayResize(m_periods, 100);
        ArrayResize(m_market_returns, 10000);
        ArrayResize(m_portfolio_returns, 10000);
        ArrayResize(m_return_dates, 10000);
        
        ZeroMemory(m_stats);
        
        Print("Advanced Statistics initialized for ", m_strategy_name);
    }
    
    // Add trade to analysis
    void AddTrade(STradeAnalysis& trade)
    {
        if(m_trade_count >= ArraySize(m_trades))
        {
            ArrayResize(m_trades, ArraySize(m_trades) + 1000);
        }
        
        m_trades[m_trade_count] = trade;
        m_trade_count++;
        
        // Update balance tracking
        m_current_balance += trade.profit;
        if(m_current_balance > m_peak_balance)
            m_peak_balance = m_current_balance;
            
        // Recalculate statistics
        CalculateAllStatistics();
    }
    
    // Calculate all statistics
    void CalculateAllStatistics()
    {
        if(m_trade_count == 0) return;
        
        CalculateBasicStatistics();
        CalculateProfitLossStatistics();
        CalculateDrawdownStatistics();
        CalculateConsecutiveStatistics();
        CalculateAdvancedRiskMetrics();
        CalculateTimeBasedStatistics();
        CalculateDistributionStatistics();
        CalculateMarketCorrelationStatistics();
    }
    
    // Calculate basic trade statistics
    void CalculateBasicStatistics()
    {
        m_stats.total_trades = m_trade_count;
        m_stats.winning_trades = 0;
        m_stats.losing_trades = 0;
        m_stats.breakeven_trades = 0;
        
        for(int i = 0; i < m_trade_count; i++)
        {
            if(m_trades[i].profit > 0)
                m_stats.winning_trades++;
            else if(m_trades[i].profit < 0)
                m_stats.losing_trades++;
            else
                m_stats.breakeven_trades++;
        }
        
        m_stats.win_rate = (double)m_stats.winning_trades / m_trade_count * 100;
        m_stats.loss_rate = (double)m_stats.losing_trades / m_trade_count * 100;
    }
    
    // Calculate profit/loss statistics
    void CalculateProfitLossStatistics()
    {
        m_stats.gross_profit = 0;
        m_stats.gross_loss = 0;
        m_stats.largest_profit_trade = 0;
        m_stats.largest_loss_trade = 0;
        
        double total_profit_trades = 0;
        double total_loss_trades = 0;
        double total_trade_length = 0;
        
        for(int i = 0; i < m_trade_count; i++)
        {
            double profit = m_trades[i].profit;
            
            if(profit > 0)
            {
                m_stats.gross_profit += profit;
                total_profit_trades += profit;
                if(profit > m_stats.largest_profit_trade)
                    m_stats.largest_profit_trade = profit;
            }
            else if(profit < 0)
            {
                m_stats.gross_loss += MathAbs(profit);
                total_loss_trades += MathAbs(profit);
                if(MathAbs(profit) > m_stats.largest_loss_trade)
                    m_stats.largest_loss_trade = MathAbs(profit);
            }
            
            total_trade_length += m_trades[i].trade_length_bars;
        }
        
        m_stats.net_profit = m_stats.gross_profit - m_stats.gross_loss;
        m_stats.profit_factor = (m_stats.gross_loss > 0) ? m_stats.gross_profit / m_stats.gross_loss : 999;
        m_stats.expected_payoff = m_stats.net_profit / m_trade_count;
        
        m_stats.average_profit_trade = (m_stats.winning_trades > 0) ? total_profit_trades / m_stats.winning_trades : 0;
        m_stats.average_loss_trade = (m_stats.losing_trades > 0) ? total_loss_trades / m_stats.losing_trades : 0;
        m_stats.average_trade_length = total_trade_length / m_trade_count;
    }
    
    // Calculate drawdown statistics
    void CalculateDrawdownStatistics()
    {
        double peak = m_initial_balance;
        double max_dd = 0;
        double current_dd = 0;
        double balance = m_initial_balance;
        
        for(int i = 0; i < m_trade_count; i++)
        {
            balance += m_trades[i].profit;
            
            if(balance > peak)
            {
                peak = balance;
                current_dd = 0;
            }
            else
            {
                current_dd = (peak - balance) / peak * 100;
                if(current_dd > max_dd)
                    max_dd = current_dd;
            }
        }
        
        m_stats.maximal_drawdown = max_dd;
        m_stats.recovery_factor = (max_dd > 0) ? m_stats.net_profit / (max_dd / 100 * peak) : 999;
        m_stats.absolute_drawdown = m_initial_balance - (m_initial_balance + m_stats.net_profit);
        m_stats.relative_drawdown = (m_stats.absolute_drawdown / m_initial_balance) * 100;
    }
    
    // Calculate consecutive statistics
    void CalculateConsecutiveStatistics()
    {
        int current_wins = 0, current_losses = 0;
        int max_wins = 0, max_losses = 0;
        double current_profit = 0, current_loss = 0;
        double max_consecutive_profit = 0, max_consecutive_loss = 0;
        
        for(int i = 0; i < m_trade_count; i++)
        {
            if(m_trades[i].profit > 0)
            {
                current_wins++;
                current_losses = 0;
                current_profit += m_trades[i].profit;
                current_loss = 0;
                
                if(current_wins > max_wins)
                    max_wins = current_wins;
                if(current_profit > max_consecutive_profit)
                    max_consecutive_profit = current_profit;
            }
            else if(m_trades[i].profit < 0)
            {
                current_losses++;
                current_wins = 0;
                current_loss += MathAbs(m_trades[i].profit);
                current_profit = 0;
                
                if(current_losses > max_losses)
                    max_losses = current_losses;
                if(current_loss > max_consecutive_loss)
                    max_consecutive_loss = current_loss;
            }
            else
            {
                current_wins = 0;
                current_losses = 0;
                current_profit = 0;
                current_loss = 0;
            }
        }
        
        m_stats.maximum_consecutive_wins = max_wins;
        m_stats.maximum_consecutive_losses = max_losses;
        m_stats.maximum_consecutive_profit = max_consecutive_profit;
        m_stats.maximum_consecutive_loss = max_consecutive_loss;
        m_stats.current_consecutive_wins = current_wins;
        m_stats.current_consecutive_losses = current_losses;
    }
    
    // Calculate advanced risk metrics
    void CalculateAdvancedRiskMetrics()
    {
        if(m_trade_count < 10) return; // Need minimum trades for reliable calculations
        
        // Calculate returns array
        double returns[];
        ArrayResize(returns, m_trade_count);
        
        double balance = m_initial_balance;
        for(int i = 0; i < m_trade_count; i++)
        {
            double prev_balance = balance;
            balance += m_trades[i].profit;
            returns[i] = (balance - prev_balance) / prev_balance * 100;
        }
        
        // Calculate Sharpe Ratio
        double mean_return = CalculateMean(returns);
        double std_return = CalculateStandardDeviation(returns);
        double risk_free_rate = 2.0; // Assume 2% risk-free rate
        m_stats.sharpe_ratio = (std_return > 0) ? (mean_return - risk_free_rate/252) / std_return * MathSqrt(252) : 0;
        
        // Calculate Sortino Ratio (using downside deviation)
        double downside_deviation = CalculateDownsideDeviation(returns, risk_free_rate/252);
        m_stats.sortino_ratio = (downside_deviation > 0) ? (mean_return - risk_free_rate/252) / downside_deviation * MathSqrt(252) : 0;
        
        // Calculate Calmar Ratio
        double annualized_return = mean_return * 252;
        m_stats.calmar_ratio = (m_stats.maximal_drawdown > 0) ? annualized_return / m_stats.maximal_drawdown : 0;
        
        // Calculate VaR and CVaR
        CalculateVaRCVaR(returns);
        
        // Calculate MAE and MFE
        CalculateMAEMFE();
    }
    
    // Calculate time-based statistics
    void CalculateTimeBasedStatistics()
    {
        if(m_trade_count == 0) return;
        
        datetime first_trade = m_trades[0].open_time;
        datetime last_trade = m_trades[m_trade_count-1].close_time;
        
        double total_days = (last_trade - first_trade) / 86400.0;
        double total_months = total_days / 30.0;
        double total_years = total_days / 365.0;
        
        if(total_days > 0)
        {
            m_stats.profit_per_day = m_stats.net_profit / total_days;
            m_stats.trades_per_day = m_trade_count / total_days;
        }
        
        if(total_months > 0)
        {
            m_stats.profit_per_month = m_stats.net_profit / total_months;
            m_stats.trades_per_month = m_trade_count / total_months;
        }
        
        if(total_years > 0)
        {
            m_stats.profit_per_year = m_stats.net_profit / total_years;
        }
        
        // Calculate monthly performance
        CalculateMonthlyPerformance();
    }
    
    // Calculate distribution statistics
    void CalculateDistributionStatistics()
    {
        if(m_trade_count < 5) return;
        
        double profits[];
        double trade_lengths[];
        ArrayResize(profits, m_trade_count);
        ArrayResize(trade_lengths, m_trade_count);
        
        for(int i = 0; i < m_trade_count; i++)
        {
            profits[i] = m_trades[i].profit;
            trade_lengths[i] = m_trades[i].trade_length_bars;
        }
        
        m_stats.profit_standard_deviation = CalculateStandardDeviation(profits);
        m_stats.profit_skewness = CalculateSkewness(profits);
        m_stats.profit_kurtosis = CalculateKurtosis(profits);
        m_stats.trade_length_std_dev = CalculateStandardDeviation(trade_lengths);
    }
    
    // Calculate market correlation statistics
    void CalculateMarketCorrelationStatistics()
    {
        if(m_return_count < 10) return;
        
        m_stats.market_correlation = CalculateCorrelation(m_portfolio_returns, m_market_returns, m_return_count);
        
        // Calculate beta and alpha
        double portfolio_variance = CalculateVariance(m_portfolio_returns, m_return_count);
        double market_variance = CalculateVariance(m_market_returns, m_return_count);
        double covariance = CalculateCovariance(m_portfolio_returns, m_market_returns, m_return_count);
        
        m_stats.portfolio_beta = (market_variance > 0) ? covariance / market_variance : 0;
        
        double portfolio_mean = CalculateMean(m_portfolio_returns, m_return_count);
        double market_mean = CalculateMean(m_market_returns, m_return_count);
        m_stats.portfolio_alpha = portfolio_mean - m_stats.portfolio_beta * market_mean;
        
        // Calculate tracking error
        double excess_returns[];
        ArrayResize(excess_returns, m_return_count);
        for(int i = 0; i < m_return_count; i++)
        {
            excess_returns[i] = m_portfolio_returns[i] - m_market_returns[i];
        }
        m_stats.tracking_error = CalculateStandardDeviation(excess_returns, m_return_count);
        
        // Information ratio
        double excess_mean = CalculateMean(excess_returns, m_return_count);
        m_stats.information_ratio = (m_stats.tracking_error > 0) ? excess_mean / m_stats.tracking_error : 0;
    }
    
    // Helper statistical functions
    double CalculateMean(const double& array[], int count = -1)
    {
        if(count == -1) count = ArraySize(array);
        if(count == 0) return 0;
        
        double sum = 0;
        for(int i = 0; i < count; i++)
            sum += array[i];
        return sum / count;
    }
    
    double CalculateStandardDeviation(const double& array[], int count = -1)
    {
        if(count == -1) count = ArraySize(array);
        if(count < 2) return 0;
        
        double mean = CalculateMean(array, count);
        double sum_sq_diff = 0;
        
        for(int i = 0; i < count; i++)
        {
            double diff = array[i] - mean;
            sum_sq_diff += diff * diff;
        }
        
        return MathSqrt(sum_sq_diff / (count - 1));
    }
    
    double CalculateVariance(const double& array[], int count)
    {
        double std_dev = CalculateStandardDeviation(array, count);
        return std_dev * std_dev;
    }
    
    double CalculateSkewness(const double& array[], int count = -1)
    {
        if(count == -1) count = ArraySize(array);
        if(count < 3) return 0;
        
        double mean = CalculateMean(array, count);
        double std_dev = CalculateStandardDeviation(array, count);
        if(std_dev == 0) return 0;
        
        double sum_cubed = 0;
        for(int i = 0; i < count; i++)
        {
            double normalized = (array[i] - mean) / std_dev;
            sum_cubed += normalized * normalized * normalized;
        }
        
        return sum_cubed / count;
    }
    
    double CalculateKurtosis(const double& array[], int count = -1)
    {
        if(count == -1) count = ArraySize(array);
        if(count < 4) return 0;
        
        double mean = CalculateMean(array, count);
        double std_dev = CalculateStandardDeviation(array, count);
        if(std_dev == 0) return 0;
        
        double sum_fourth = 0;
        for(int i = 0; i < count; i++)
        {
            double normalized = (array[i] - mean) / std_dev;
            sum_fourth += normalized * normalized * normalized * normalized;
        }
        
        return (sum_fourth / count) - 3; // Excess kurtosis
    }
    
    double CalculateCorrelation(const double& array1[], const double& array2[], int count)
    {
        if(count < 2) return 0;
        
        double covariance = CalculateCovariance(array1, array2, count);
        double std1 = CalculateStandardDeviation(array1, count);
        double std2 = CalculateStandardDeviation(array2, count);
        
        if(std1 == 0 || std2 == 0) return 0;
        
        return covariance / (std1 * std2);
    }
    
    double CalculateCovariance(const double& array1[], const double& array2[], int count)
    {
        if(count < 2) return 0;
        
        double mean1 = CalculateMean(array1, count);
        double mean2 = CalculateMean(array2, count);
        
        double sum = 0;
        for(int i = 0; i < count; i++)
        {
            sum += (array1[i] - mean1) * (array2[i] - mean2);
        }
        
        return sum / (count - 1);
    }
    
    double CalculateDownsideDeviation(const double& array[], double target_return, int count = -1)
    {
        if(count == -1) count = ArraySize(array);
        if(count < 2) return 0;
        
        double sum_sq_negative = 0;
        int negative_count = 0;
        
        for(int i = 0; i < count; i++)
        {
            if(array[i] < target_return)
            {
                double diff = array[i] - target_return;
                sum_sq_negative += diff * diff;
                negative_count++;
            }
        }
        
        if(negative_count == 0) return 0;
        
        return MathSqrt(sum_sq_negative / negative_count);
    }
    
    void CalculateVaRCVaR(const double& returns[])
    {
        int count = ArraySize(returns);
        if(count < 20) return;
        
        // Sort returns for percentile calculation
        double sorted_returns[];
        ArrayResize(sorted_returns, count);
        ArrayCopy(sorted_returns, returns);
        ArraySort(sorted_returns);
        
        // VaR 95% (5th percentile)
        int var_index = (int)MathMax(0.0, MathMin((double)(count - 1), MathFloor(count * 0.05)));
        m_stats.var_95 = MathAbs(sorted_returns[var_index]);
        
        // CVaR 95% (mean of worst 5% returns)
        double sum_worst = 0;
        int safe_var_index = (int)MathMax(0.0, MathMin((double)(count - 1), (double)var_index));
        for(int i = 0; i <= safe_var_index; i++)
        {
            sum_worst += MathAbs(sorted_returns[i]);
        }
        m_stats.cvar_95 = sum_worst / (safe_var_index + 1);
    }
    
    void CalculateMAEMFE()
    {
        double total_mae = 0, total_mfe = 0;
        int count = 0;
        
        for(int i = 0; i < m_trade_count; i++)
        {
            if(m_trades[i].mae_percent != 0 || m_trades[i].mfe_percent != 0)
            {
                total_mae += MathAbs(m_trades[i].mae_percent);
                total_mfe += m_trades[i].mfe_percent;
                count++;
            }
        }
        
        if(count > 0)
        {
            m_stats.maximum_adverse_excursion = total_mae / count;
            m_stats.maximum_favorable_excursion = total_mfe / count;
        }
    }
    
    void CalculateMonthlyPerformance()
    {
        // Group trades by month and calculate performance
        // This is a simplified implementation
        m_stats.profitable_months = 0;
        m_stats.losing_months = 0;
        
        // For a full implementation, you would group trades by month
        // and calculate monthly returns, then count profitable vs losing months
    }
    
    // Generate comprehensive statistics report
    void GenerateDetailedReport()
    {
        Print("========================================");
        Print("    ADVANCED STATISTICS REPORT");
        Print("========================================");
        Print("Strategy: ", m_strategy_name);
        Print("Report Generated: ", TimeToString(TimeCurrent()));
        Print("");
        
        Print("--- BASIC STATISTICS ---");
        Print("Total Trades: ", m_stats.total_trades);
        Print("Winning Trades: ", m_stats.winning_trades, " (", DoubleToString(m_stats.win_rate, 2), "%)");
        Print("Losing Trades: ", m_stats.losing_trades, " (", DoubleToString(m_stats.loss_rate, 2), "%)");
        Print("Breakeven Trades: ", m_stats.breakeven_trades);
        Print("");
        
        Print("--- PROFIT/LOSS ANALYSIS ---");
        Print("Gross Profit: $", DoubleToString(m_stats.gross_profit, 2));
        Print("Gross Loss: $", DoubleToString(m_stats.gross_loss, 2));
        Print("Net Profit: $", DoubleToString(m_stats.net_profit, 2));
        Print("Profit Factor: ", DoubleToString(m_stats.profit_factor, 2));
        Print("Expected Payoff: $", DoubleToString(m_stats.expected_payoff, 2));
        Print("Recovery Factor: ", DoubleToString(m_stats.recovery_factor, 2));
        Print("");
        
        Print("--- DRAWDOWN ANALYSIS ---");
        Print("Maximum Drawdown: ", DoubleToString(m_stats.maximal_drawdown, 2), "%");
        Print("Absolute Drawdown: $", DoubleToString(m_stats.absolute_drawdown, 2));
        Print("Relative Drawdown: ", DoubleToString(m_stats.relative_drawdown, 2), "%");
        Print("");
        
        Print("--- RISK METRICS ---");
        Print("Sharpe Ratio: ", DoubleToString(m_stats.sharpe_ratio, 3));
        Print("Sortino Ratio: ", DoubleToString(m_stats.sortino_ratio, 3));
        Print("Calmar Ratio: ", DoubleToString(m_stats.calmar_ratio, 3));
        Print("VaR 95%: ", DoubleToString(m_stats.var_95, 2), "%");
        Print("CVaR 95%: ", DoubleToString(m_stats.cvar_95, 2), "%");
        Print("");
        
        Print("--- CONSECUTIVE STATISTICS ---");
        Print("Max Consecutive Wins: ", m_stats.maximum_consecutive_wins);
        Print("Max Consecutive Losses: ", m_stats.maximum_consecutive_losses);
        Print("Max Consecutive Profit: $", DoubleToString(m_stats.maximum_consecutive_profit, 2));
        Print("Max Consecutive Loss: $", DoubleToString(m_stats.maximum_consecutive_loss, 2));
        Print("");
        
        Print("--- TIME-BASED PERFORMANCE ---");
        Print("Profit per Day: $", DoubleToString(m_stats.profit_per_day, 2));
        Print("Profit per Month: $", DoubleToString(m_stats.profit_per_month, 2));
        Print("Profit per Year: $", DoubleToString(m_stats.profit_per_year, 2));
        Print("Trades per Day: ", DoubleToString(m_stats.trades_per_day, 2));
        Print("Trades per Month: ", DoubleToString(m_stats.trades_per_month, 1));
        Print("");
        
        Print("--- MARKET CORRELATION ---");
        Print("Market Correlation: ", DoubleToString(m_stats.market_correlation, 3));
        Print("Portfolio Beta: ", DoubleToString(m_stats.portfolio_beta, 3));
        Print("Portfolio Alpha: ", DoubleToString(m_stats.portfolio_alpha, 3));
        Print("Information Ratio: ", DoubleToString(m_stats.information_ratio, 3));
        Print("Tracking Error: ", DoubleToString(m_stats.tracking_error, 3));
        Print("");
        
        Print("========================================");
    }
    
    // Export statistics to CSV
    void ExportToCSV(string filename = "")
    {
        if(filename == "")
            filename = m_strategy_name + "_Statistics_" + TimeToString(TimeCurrent(), TIME_DATE) + ".csv";
            
        int file_handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON);
        
        if(file_handle != INVALID_HANDLE)
        {
            FileWrite(file_handle, "Metric", "Value");
            FileWrite(file_handle, "Strategy Name", m_strategy_name);
            FileWrite(file_handle, "Total Trades", m_stats.total_trades);
            FileWrite(file_handle, "Win Rate %", m_stats.win_rate);
            FileWrite(file_handle, "Profit Factor", m_stats.profit_factor);
            FileWrite(file_handle, "Net Profit", m_stats.net_profit);
            FileWrite(file_handle, "Max Drawdown %", m_stats.maximal_drawdown);
            FileWrite(file_handle, "Sharpe Ratio", m_stats.sharpe_ratio);
            FileWrite(file_handle, "Sortino Ratio", m_stats.sortino_ratio);
            FileWrite(file_handle, "Calmar Ratio", m_stats.calmar_ratio);
            FileWrite(file_handle, "VaR 95%", m_stats.var_95);
            FileWrite(file_handle, "CVaR 95%", m_stats.cvar_95);
            FileWrite(file_handle, "Expected Payoff", m_stats.expected_payoff);
            FileWrite(file_handle, "Recovery Factor", m_stats.recovery_factor);
            FileWrite(file_handle, "Market Correlation", m_stats.market_correlation);
            FileWrite(file_handle, "Portfolio Beta", m_stats.portfolio_beta);
            FileWrite(file_handle, "Portfolio Alpha", m_stats.portfolio_alpha);
            FileWrite(file_handle, "Average Trade Length", m_stats.average_trade_length);
            FileWrite(file_handle, "Profit Standard Deviation", m_stats.profit_standard_deviation);
            FileWrite(file_handle, "Profit Skewness", m_stats.profit_skewness);
            FileWrite(file_handle, "Profit Kurtosis", m_stats.profit_kurtosis);
            
            FileClose(file_handle);
            Print("Statistics exported to: ", filename);
        }
    }
    
    // Get statistics structure
    STradingStatistics GetStatistics() { return m_stats; }
    
    // Get trade count
    int GetTradeCount() { return m_trade_count; }
    
    // Get specific metrics
    double GetSharpeRatio() { return m_stats.sharpe_ratio; }
    double GetMaxDrawdown() { return m_stats.maximal_drawdown; }
    double GetWinRate() { return m_stats.win_rate; }
    double GetProfitFactor() { return m_stats.profit_factor; }
    double GetNetProfit() { return m_stats.net_profit; }
    
    // Check if performance meets criteria
    bool IsPerformanceExcellent(double min_sharpe = 1.5, double max_dd = 15.0, double min_profit_factor = 2.0)
    {
        return (m_stats.sharpe_ratio >= min_sharpe && 
                m_stats.maximal_drawdown <= max_dd && 
                m_stats.profit_factor >= min_profit_factor &&
                m_stats.win_rate >= 65.0);
    }
};
