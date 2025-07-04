//+------------------------------------------------------------------+
//| Performance Monitor System - Enhanced Version                   |
//| Developer: AI Assistant                                          |
//| Version: 2.0                                                     |
//| Description: Comprehensive performance tracking and analysis    |
//|              with real-time metrics and reporting               |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "2.00"

//+------------------------------------------------------------------+
//| Performance Metrics Structure                                   |
//+------------------------------------------------------------------+
struct SPerformanceMetrics
{
    // Basic metrics
    int total_trades;
    int winning_trades;
    int losing_trades;
    double win_rate;
    double loss_rate;
    
    // Profit/Loss metrics
    double total_profit;
    double total_loss;
    double net_profit;
    double gross_profit;
    double gross_loss;
    
    // Statistical metrics
    double profit_factor;
    double expectancy;
    double average_win;
    double average_loss;
    double largest_win;
    double largest_loss;
    
    // Risk metrics
    double max_drawdown;
    double current_drawdown;
    double recovery_factor;
    double sharpe_ratio;
    double sortino_ratio;
    double calmar_ratio;
    
    // Consistency metrics
    int max_consecutive_wins;
    int max_consecutive_losses;
    int current_consecutive_wins;
    int current_consecutive_losses;
    
    // Time-based metrics
    datetime first_trade_time;
    datetime last_trade_time;
    double trades_per_day;
    double profit_per_day;
    double average_trade_duration;
    
    // Advanced metrics
    double information_ratio;
    double treynor_ratio;
    double value_at_risk_95;
    double value_at_risk_99;
    double conditional_var;
    double maximum_adverse_excursion;
    double maximum_favorable_excursion;
    
    // Monthly metrics
    double best_month;
    double worst_month;
    int profitable_months;
    int losing_months;
    double monthly_volatility;
};

//+------------------------------------------------------------------+
//| Trade Performance Structure                                     |
//+------------------------------------------------------------------+
struct STradePerformance
{
    datetime open_time;
    datetime close_time;
    double open_price;
    double close_price;
    double profit_loss;
    double profit_percent;
    double trade_duration_hours;
    double max_adverse_excursion;
    double max_favorable_excursion;
    string trade_reason;
    bool is_winner;
    double cumulative_profit;
    double account_balance_after;
    double drawdown_at_close;
};

//+------------------------------------------------------------------+
//| Performance Monitor Class - Enhanced Version                   |
//+------------------------------------------------------------------+
class CPerformanceMonitor
{
private:
    SPerformanceMetrics m_metrics;
    STradePerformance m_trade_history[5000];
    int m_trade_count;
    
    double m_initial_balance;
    double m_current_balance;
    double m_peak_balance;
    double m_equity_curve[10000];
    datetime m_equity_times[10000];
    int m_equity_points;
    
    // Performance tracking arrays
    double m_monthly_returns[60];       // 5 years of monthly data
    double m_daily_returns[2000];       // Daily returns
    int m_monthly_count;
    int m_daily_count;
    
    // Benchmark comparison
    double m_benchmark_returns[2000];
    bool m_use_benchmark;
    string m_benchmark_symbol;
    
    // Real-time tracking
    datetime m_last_update;
    double m_last_balance;
    
public:
    // Constructor
    CPerformanceMonitor()
    {
        InitializeMetrics();
        m_trade_count = 0;
        m_equity_points = 0;
        m_monthly_count = 0;
        m_daily_count = 0;
        m_initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_current_balance = m_initial_balance;
        m_peak_balance = m_initial_balance;
        m_last_balance = m_initial_balance;
        m_last_update = TimeCurrent();
        m_use_benchmark = false;
        m_benchmark_symbol = "";
        
        // Initialize equity curve
        m_equity_curve[0] = m_initial_balance;
        m_equity_times[0] = TimeCurrent();
        m_equity_points = 1;
    }
    
    // Initialize metrics to zero
    void InitializeMetrics()
    {
        ZeroMemory(m_metrics);
        m_metrics.first_trade_time = 0;
        m_metrics.last_trade_time = 0;
        m_metrics.profit_factor = 0.0;
        m_metrics.recovery_factor = 0.0;
    }
    
    // Add trade to performance tracking
    void AddTrade(datetime open_time, datetime close_time, double open_price, 
                 double close_price, double profit_loss, string reason = "")
    {
        if(m_trade_count >= ArraySize(m_trade_history))
        {
            Print("Performance Monitor: Trade history array full");
            return;
        }
        
        // Create trade record
        STradePerformance trade;
        trade.open_time = open_time;
        trade.close_time = close_time;
        trade.open_price = open_price;
        trade.close_price = close_price;
        trade.profit_loss = profit_loss;
        trade.profit_percent = (close_price - open_price) / open_price * 100;
        trade.trade_duration_hours = (double)(close_time - open_time) / 3600;
        trade.trade_reason = reason;
        trade.is_winner = profit_loss > 0;
        
        // Update current balance
        m_current_balance += profit_loss;
        trade.account_balance_after = m_current_balance;
        trade.cumulative_profit = m_current_balance - m_initial_balance;
        
        // Update peak and drawdown
        if(m_current_balance > m_peak_balance)
        {
            m_peak_balance = m_current_balance;
            trade.drawdown_at_close = 0.0;
        }
        else
        {
            trade.drawdown_at_close = (m_peak_balance - m_current_balance) / m_peak_balance * 100;
        }
        
        // Store trade
        m_trade_history[m_trade_count] = trade;
        m_trade_count++;
        
        // Update equity curve
        AddEquityPoint(close_time, m_current_balance);
        
        // Recalculate metrics
        CalculateMetrics();
        
        Print("Performance Monitor: Trade added - P&L: $", DoubleToString(profit_loss, 2), 
              " | Total Trades: ", m_trade_count, " | Balance: $", DoubleToString(m_current_balance, 2));
    }
    
    // Calculate all performance metrics
    void CalculateMetrics()
    {
        if(m_trade_count == 0)
            return;
            
        // Initialize counters
        m_metrics.total_trades = m_trade_count;
        m_metrics.winning_trades = 0;
        m_metrics.losing_trades = 0;
        m_metrics.total_profit = 0.0;
        m_metrics.total_loss = 0.0;
        m_metrics.largest_win = 0.0;
        m_metrics.largest_loss = 0.0;
        
        int consecutive_wins = 0;
        int consecutive_losses = 0;
        m_metrics.max_consecutive_wins = 0;
        m_metrics.max_consecutive_losses = 0;
        
        double total_duration = 0.0;
        double max_dd = 0.0;
        double peak = m_initial_balance;
        
        // Calculate basic metrics
        for(int i = 0; i < m_trade_count; i++)
        {
            STradePerformance trade = m_trade_history[i];
            
            // Profit/Loss statistics
            if(trade.is_winner)
            {
                m_metrics.winning_trades++;
                m_metrics.total_profit += trade.profit_loss;
                if(trade.profit_loss > m_metrics.largest_win)
                    m_metrics.largest_win = trade.profit_loss;
                    
                consecutive_wins++;
                consecutive_losses = 0;
                if(consecutive_wins > m_metrics.max_consecutive_wins)
                    m_metrics.max_consecutive_wins = consecutive_wins;
            }
            else
            {
                m_metrics.losing_trades++;
                m_metrics.total_loss += MathAbs(trade.profit_loss);
                if(MathAbs(trade.profit_loss) > m_metrics.largest_loss)
                    m_metrics.largest_loss = MathAbs(trade.profit_loss);
                    
                consecutive_losses++;
                consecutive_wins = 0;
                if(consecutive_losses > m_metrics.max_consecutive_losses)
                    m_metrics.max_consecutive_losses = consecutive_losses;
            }
            
            // Drawdown calculation
            if(trade.account_balance_after > peak)
                peak = trade.account_balance_after;
            else
            {
                double dd = (peak - trade.account_balance_after) / peak * 100;
                if(dd > max_dd)
                    max_dd = dd;
            }
            
            // Duration
            total_duration += trade.trade_duration_hours;
            
            // Time tracking
            if(i == 0)
                m_metrics.first_trade_time = trade.open_time;
            if(i == m_trade_count - 1)
                m_metrics.last_trade_time = trade.close_time;
        }
        
        // Calculate derived metrics
        m_metrics.win_rate = (double)m_metrics.winning_trades / m_metrics.total_trades * 100;
        m_metrics.loss_rate = (double)m_metrics.losing_trades / m_metrics.total_trades * 100;
        m_metrics.net_profit = m_metrics.total_profit - m_metrics.total_loss;
        m_metrics.gross_profit = m_metrics.total_profit;
        m_metrics.gross_loss = m_metrics.total_loss;
        
        // Advanced metrics
        if(m_metrics.winning_trades > 0)
            m_metrics.average_win = m_metrics.total_profit / m_metrics.winning_trades;
        if(m_metrics.losing_trades > 0)
            m_metrics.average_loss = m_metrics.total_loss / m_metrics.losing_trades;
            
        if(m_metrics.total_loss > 0)
            m_metrics.profit_factor = m_metrics.total_profit / m_metrics.total_loss;
        else
            m_metrics.profit_factor = 999.0; // All winning trades
            
        m_metrics.expectancy = m_metrics.net_profit / m_metrics.total_trades;
        m_metrics.max_drawdown = max_dd;
        m_metrics.current_drawdown = (m_peak_balance - m_current_balance) / m_peak_balance * 100;
        
        if(m_metrics.max_drawdown > 0)
            m_metrics.recovery_factor = m_metrics.net_profit / m_metrics.max_drawdown;
            
        m_metrics.average_trade_duration = total_duration / m_metrics.total_trades;
        
        // Time-based metrics
        if(m_metrics.last_trade_time > m_metrics.first_trade_time)
        {
            double days = (double)(m_metrics.last_trade_time - m_metrics.first_trade_time) / (24 * 3600);
            if(days > 0)
            {
                m_metrics.trades_per_day = m_metrics.total_trades / days;
                m_metrics.profit_per_day = m_metrics.net_profit / days;
            }
        }
        
        // Calculate Sharpe ratio
        CalculateSharpeRatio();
        
        // Calculate other advanced metrics
        CalculateAdvancedMetrics();
    }
    
    // Get current performance metrics
    SPerformanceMetrics GetMetrics() const
    {
        return m_metrics;
    }
    
    // Get trade history
    bool GetTradeHistory(STradePerformance& trades[], int& count)
    {
        count = m_trade_count;
        if(m_trade_count == 0)
            return false;
            
        ArrayResize(trades, m_trade_count);
        for(int i = 0; i < m_trade_count; i++)
        {
            trades[i] = m_trade_history[i];
        }
        
        return true;
    }
    
    // Generate performance report
    void GeneratePerformanceReport()
    {
        Print("=== PERFORMANCE ANALYSIS REPORT ===");
        Print("Report Generated: ", TimeToString(TimeCurrent()));
        Print("Trading Period: ", TimeToString(m_metrics.first_trade_time), " to ", TimeToString(m_metrics.last_trade_time));
        Print("");
        
        Print("--- BASIC STATISTICS ---");
        Print("Total Trades: ", m_metrics.total_trades);
        Print("Winning Trades: ", m_metrics.winning_trades, " (", DoubleToString(m_metrics.win_rate, 1), "%)");
        Print("Losing Trades: ", m_metrics.losing_trades, " (", DoubleToString(m_metrics.loss_rate, 1), "%)");
        Print("");
        
        Print("--- PROFIT/LOSS ANALYSIS ---");
        Print("Net Profit: $", DoubleToString(m_metrics.net_profit, 2));
        Print("Gross Profit: $", DoubleToString(m_metrics.gross_profit, 2));
        Print("Gross Loss: $", DoubleToString(m_metrics.gross_loss, 2));
        Print("Profit Factor: ", DoubleToString(m_metrics.profit_factor, 2));
        Print("Expectancy: $", DoubleToString(m_metrics.expectancy, 2));
        Print("");
        
        Print("--- TRADE STATISTICS ---");
        Print("Average Win: $", DoubleToString(m_metrics.average_win, 2));
        Print("Average Loss: $", DoubleToString(m_metrics.average_loss, 2));
        Print("Largest Win: $", DoubleToString(m_metrics.largest_win, 2));
        Print("Largest Loss: $", DoubleToString(m_metrics.largest_loss, 2));
        Print("Average Trade Duration: ", DoubleToString(m_metrics.average_trade_duration, 1), " hours");
        Print("");
        
        Print("--- RISK ANALYSIS ---");
        Print("Maximum Drawdown: ", DoubleToString(m_metrics.max_drawdown, 2), "%");
        Print("Current Drawdown: ", DoubleToString(m_metrics.current_drawdown, 2), "%");
        Print("Recovery Factor: ", DoubleToString(m_metrics.recovery_factor, 2));
        Print("Sharpe Ratio: ", DoubleToString(m_metrics.sharpe_ratio, 3));
        Print("Sortino Ratio: ", DoubleToString(m_metrics.sortino_ratio, 3));
        Print("");
        
        Print("--- CONSISTENCY METRICS ---");
        Print("Max Consecutive Wins: ", m_metrics.max_consecutive_wins);
        Print("Max Consecutive Losses: ", m_metrics.max_consecutive_losses);
        Print("Trades per Day: ", DoubleToString(m_metrics.trades_per_day, 2));
        Print("Profit per Day: $", DoubleToString(m_metrics.profit_per_day, 2));
        Print("");
        
        Print("--- ACCOUNT PERFORMANCE ---");
        Print("Initial Balance: $", DoubleToString(m_initial_balance, 2));
        Print("Current Balance: $", DoubleToString(m_current_balance, 2));
        Print("Peak Balance: $", DoubleToString(m_peak_balance, 2));
        Print("Total Return: ", DoubleToString((m_current_balance - m_initial_balance) / m_initial_balance * 100, 2), "%");
        Print("=====================================");
    }
    
    // Export performance data to CSV
    void ExportToCSV(string filename = "")
    {
        if(filename == "")
            filename = "Performance_Report_" + TimeToString(TimeCurrent(), TIME_DATE) + ".csv";
            
        int file_handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON);
        if(file_handle != INVALID_HANDLE)
        {
            // Write headers
            FileWrite(file_handle, "Open_Time", "Close_Time", "Open_Price", "Close_Price", 
                     "Profit_Loss", "Profit_Percent", "Duration_Hours", "Trade_Reason",
                     "Is_Winner", "Cumulative_Profit", "Balance_After", "Drawdown_At_Close");
            
            // Write trade data
            for(int i = 0; i < m_trade_count; i++)
            {
                STradePerformance trade = m_trade_history[i];
                FileWrite(file_handle,
                    TimeToString(trade.open_time),
                    TimeToString(trade.close_time),
                    trade.open_price,
                    trade.close_price,
                    trade.profit_loss,
                    trade.profit_percent,
                    trade.trade_duration_hours,
                    trade.trade_reason,
                    trade.is_winner ? "YES" : "NO",
                    trade.cumulative_profit,
                    trade.account_balance_after,
                    trade.drawdown_at_close);
            }
            
            FileClose(file_handle);
            Print("Performance data exported to: ", filename);
        }
    }
    
    // Update real-time performance
    void UpdateRealTime()
    {
        datetime current_time = TimeCurrent();
        double current_balance = AccountInfoDouble(ACCOUNT_EQUITY);
        
        // Update equity curve if balance changed
        if(MathAbs(current_balance - m_last_balance) > 0.01)
        {
            AddEquityPoint(current_time, current_balance);
            m_last_balance = current_balance;
        }
        
        m_last_update = current_time;
    }
    
    // Get equity curve data
    bool GetEquityCurve(double& equity[], datetime& times[], int& count)
    {
        count = m_equity_points;
        if(m_equity_points == 0)
            return false;
            
        ArrayResize(equity, m_equity_points);
        ArrayResize(times, m_equity_points);
        
        for(int i = 0; i < m_equity_points; i++)
        {
            equity[i] = m_equity_curve[i];
            times[i] = m_equity_times[i];
        }
        
        return true;
    }
    
private:
    // Add point to equity curve
    void AddEquityPoint(datetime time, double equity)
    {
        if(m_equity_points >= ArraySize(m_equity_curve))
        {
            // Shift array to make room for new point
            for(int i = 0; i < ArraySize(m_equity_curve) - 1; i++)
            {
                m_equity_curve[i] = m_equity_curve[i + 1];
                m_equity_times[i] = m_equity_times[i + 1];
            }
            m_equity_points = ArraySize(m_equity_curve) - 1;
        }
        
        m_equity_curve[m_equity_points] = equity;
        m_equity_times[m_equity_points] = time;
        m_equity_points++;
    }
    
    // Calculate Sharpe ratio
    void CalculateSharpeRatio()
    {
        if(m_trade_count < 2)
        {
            m_metrics.sharpe_ratio = 0.0;
            return;
        }
        
        // Calculate returns
        double returns[];
        ArrayResize(returns, m_trade_count);
        
        for(int i = 0; i < m_trade_count; i++)
        {
            returns[i] = m_trade_history[i].profit_percent;
        }
        
        // Calculate mean and standard deviation
        double mean_return = 0.0;
        for(int i = 0; i < m_trade_count; i++)
            mean_return += returns[i];
        mean_return /= m_trade_count;
        
        double variance = 0.0;
        for(int i = 0; i < m_trade_count; i++)
        {
            double diff = returns[i] - mean_return;
            variance += diff * diff;
        }
        variance /= (m_trade_count - 1);
        
        double std_deviation = MathSqrt(variance);
        
        // Calculate Sharpe ratio (assuming risk-free rate = 0)
        if(std_deviation > 0)
            m_metrics.sharpe_ratio = mean_return / std_deviation;
        else
            m_metrics.sharpe_ratio = 0.0;
    }
    
    // Calculate advanced metrics
    void CalculateAdvancedMetrics()
    {
        // Calculate Sortino ratio
        CalculateSortinoRatio();
        
        // Calculate Calmar ratio
        if(m_metrics.max_drawdown > 0)
            m_metrics.calmar_ratio = (m_metrics.net_profit / m_initial_balance * 100) / m_metrics.max_drawdown;
        else
            m_metrics.calmar_ratio = 0.0;
            
        // Calculate Value at Risk
        CalculateVaR();
    }
    
    // Calculate Sortino ratio
    void CalculateSortinoRatio()
    {
        if(m_trade_count < 2)
        {
            m_metrics.sortino_ratio = 0.0;
            return;
        }
        
        // Calculate downside deviation
        double mean_return = 0.0;
        for(int i = 0; i < m_trade_count; i++)
            mean_return += m_trade_history[i].profit_percent;
        mean_return /= m_trade_count;
        
        double downside_variance = 0.0;
        int downside_count = 0;
        
        for(int i = 0; i < m_trade_count; i++)
        {
            double return_val = m_trade_history[i].profit_percent;
            if(return_val < 0)
            {
                downside_variance += return_val * return_val;
                downside_count++;
            }
        }
        
        if(downside_count > 0)
        {
            double downside_deviation = MathSqrt(downside_variance / downside_count);
            if(downside_deviation > 0)
                m_metrics.sortino_ratio = mean_return / downside_deviation;
            else
                m_metrics.sortino_ratio = 0.0;
        }
        else
            m_metrics.sortino_ratio = 999.0; // No negative returns
    }
    
    // Calculate Value at Risk
    void CalculateVaR()
    {
        if(m_trade_count < 20)
        {
            m_metrics.value_at_risk_95 = 0.0;
            m_metrics.value_at_risk_99 = 0.0;
            return;
        }
        
        // Create sorted array of returns
        double returns[];
        ArrayResize(returns, m_trade_count);
        
        for(int i = 0; i < m_trade_count; i++)
            returns[i] = m_trade_history[i].profit_percent;
            
        ArraySort(returns);
        
        // Calculate VaR at 95% and 99% confidence levels
        int var_95_index = (int)(m_trade_count * 0.05);
        int var_99_index = (int)(m_trade_count * 0.01);
        
        m_metrics.value_at_risk_95 = MathAbs(returns[var_95_index]);
        m_metrics.value_at_risk_99 = MathAbs(returns[var_99_index]);
    }
};

//+------------------------------------------------------------------+
//| Global Performance Monitor Instance                             |
//+------------------------------------------------------------------+
CPerformanceMonitor* g_performance_monitor = NULL;

//+------------------------------------------------------------------+
//| Initialize Performance Monitor                                  |
//+------------------------------------------------------------------+
bool InitPerformanceMonitor()
{
    if(g_performance_monitor == NULL)
    {
        g_performance_monitor = new CPerformanceMonitor();
        if(g_performance_monitor != NULL)
        {
            Print("Performance Monitor initialized successfully");
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Cleanup Performance Monitor                                     |
//+------------------------------------------------------------------+
void DeinitPerformanceMonitor()
{
    if(g_performance_monitor != NULL)
    {
        g_performance_monitor.GeneratePerformanceReport();
        delete g_performance_monitor;
        g_performance_monitor = NULL;
    }
}

//+------------------------------------------------------------------+
//| Get Global Performance Monitor                                  |
//+------------------------------------------------------------------+
CPerformanceMonitor* GetPerformanceMonitor()
{
    return g_performance_monitor;
}