//+------------------------------------------------------------------+
//| Performance Monitor Library for RSI Momentum Strategies        |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Performance Metrics Structure                                    |
//+------------------------------------------------------------------+
struct SPerformanceMetrics
{
    int    total_trades;
    int    winning_trades;
    int    losing_trades;
    double total_profit;
    double total_loss;
    double max_profit;
    double max_loss;
    double max_drawdown;
    double current_drawdown;
    double peak_balance;
    double profit_factor;
    double win_rate;
    double average_win;
    double average_loss;
    double expectancy;
    datetime start_time;
    datetime last_update;
};

//+------------------------------------------------------------------+
//| Performance Monitor Class                                        |
//+------------------------------------------------------------------+
class CPerformanceMonitor
{
private:
    SPerformanceMetrics m_metrics;
    double m_initial_balance;
    string m_strategy_name;
    
public:
    // Constructor
    CPerformanceMonitor(string strategy_name = "RSI_Strategy")
    {
        m_strategy_name = strategy_name;
        m_initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        
        // Initialize metrics
        ZeroMemory(m_metrics);
        m_metrics.start_time = TimeCurrent();
        m_metrics.peak_balance = m_initial_balance;
        
        Print("Performance Monitor initialized for ", m_strategy_name);
        Print("Initial Balance: ", DoubleToString(m_initial_balance, 2));
    }
    
    // Update metrics after each trade
    void UpdateTrade(double trade_result, double trade_volume = 0)
    {
        m_metrics.total_trades++;
        m_metrics.last_update = TimeCurrent();
        
        double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        
        if(trade_result > 0)
        {
            m_metrics.winning_trades++;
            m_metrics.total_profit += trade_result;
            m_metrics.max_profit = MathMax(m_metrics.max_profit, trade_result);
        }
        else if(trade_result < 0)
        {
            m_metrics.losing_trades++;
            m_metrics.total_loss += MathAbs(trade_result);
            m_metrics.max_loss = MathMax(m_metrics.max_loss, MathAbs(trade_result));
        }
        
        // Update peak balance and drawdown
        if(current_balance > m_metrics.peak_balance)
        {
            m_metrics.peak_balance = current_balance;
            m_metrics.current_drawdown = 0;
        }
        else
        {
            m_metrics.current_drawdown = (m_metrics.peak_balance - current_balance) / m_metrics.peak_balance * 100;
            m_metrics.max_drawdown = MathMax(m_metrics.max_drawdown, m_metrics.current_drawdown);
        }
        
        // Calculate derived metrics
        CalculateDerivedMetrics();
        
        // Log the trade
        LogTrade(trade_result);
    }
    
    // Calculate derived performance metrics
    void CalculateDerivedMetrics()
    {
        if(m_metrics.total_trades > 0)
        {
            m_metrics.win_rate = (double)m_metrics.winning_trades / m_metrics.total_trades * 100;
        }
        
        if(m_metrics.winning_trades > 0)
        {
            m_metrics.average_win = m_metrics.total_profit / m_metrics.winning_trades;
        }
        
        if(m_metrics.losing_trades > 0)
        {
            m_metrics.average_loss = m_metrics.total_loss / m_metrics.losing_trades;
        }
        
        if(m_metrics.total_loss > 0)
        {
            m_metrics.profit_factor = m_metrics.total_profit / m_metrics.total_loss;
        }
        
        if(m_metrics.total_trades > 0)
        {
            double gross_profit = m_metrics.total_profit;
            double gross_loss = -m_metrics.total_loss;
            m_metrics.expectancy = (gross_profit + gross_loss) / m_metrics.total_trades;
        }
    }
    
    // Print current performance report
    void PrintPerformanceReport()
    {
        Print("=== ", m_strategy_name, " Performance Report ===");
        Print("Trading Period: ", TimeToString(m_metrics.start_time), " to ", TimeToString(m_metrics.last_update));
        Print("Total Trades: ", m_metrics.total_trades);
        Print("Winning Trades: ", m_metrics.winning_trades);
        Print("Losing Trades: ", m_metrics.losing_trades);
        Print("Win Rate: ", DoubleToString(m_metrics.win_rate, 2), "%");
        Print("Total Profit: $", DoubleToString(m_metrics.total_profit, 2));
        Print("Total Loss: $", DoubleToString(-m_metrics.total_loss, 2));
        Print("Net Profit: $", DoubleToString(m_metrics.total_profit - m_metrics.total_loss, 2));
        Print("Profit Factor: ", DoubleToString(m_metrics.profit_factor, 2));
        Print("Average Win: $", DoubleToString(m_metrics.average_win, 2));
        Print("Average Loss: $", DoubleToString(-m_metrics.average_loss, 2));
        Print("Expectancy: $", DoubleToString(m_metrics.expectancy, 2));
        Print("Max Profit: $", DoubleToString(m_metrics.max_profit, 2));
        Print("Max Loss: $", DoubleToString(-m_metrics.max_loss, 2));
        Print("Max Drawdown: ", DoubleToString(m_metrics.max_drawdown, 2), "%");
        Print("Current Drawdown: ", DoubleToString(m_metrics.current_drawdown, 2), "%");
        Print("Initial Balance: $", DoubleToString(m_initial_balance, 2));
        Print("Current Balance: $", DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
        Print("Total Return: ", DoubleToString((AccountInfoDouble(ACCOUNT_BALANCE) - m_initial_balance) / m_initial_balance * 100, 2), "%");
        Print("==========================================");
    }
    
    // Log individual trade
    void LogTrade(double result)
    {
        string status = (result > 0) ? "WIN" : (result < 0) ? "LOSS" : "BREAKEVEN";
        Print("Trade #", m_metrics.total_trades, " [", status, "]: $", DoubleToString(result, 2), 
              " | Win Rate: ", DoubleToString(m_metrics.win_rate, 1), "% | Balance: $", 
              DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
    }
    
    // Get specific metrics
    double GetWinRate() { return m_metrics.win_rate; }
    double GetProfitFactor() { return m_metrics.profit_factor; }
    double GetMaxDrawdown() { return m_metrics.max_drawdown; }
    double GetCurrentDrawdown() { return m_metrics.current_drawdown; }
    double GetExpectancy() { return m_metrics.expectancy; }
    int GetTotalTrades() { return m_metrics.total_trades; }
    double GetNetProfit() { return m_metrics.total_profit - m_metrics.total_loss; }
    
    // Check if performance meets criteria
    bool IsPerformanceGood(double min_win_rate = 70.0, double min_profit_factor = 1.5, double max_drawdown = 25.0)
    {
        if(m_metrics.total_trades < 10) return true; // Need minimum trades for evaluation
        
        return (m_metrics.win_rate >= min_win_rate && 
                m_metrics.profit_factor >= min_profit_factor && 
                m_metrics.max_drawdown <= max_drawdown);
    }
    
    // Save performance to file
    void SavePerformanceToFile()
    {
        string filename = m_strategy_name + "_Performance_" + TimeToString(TimeCurrent(), TIME_DATE) + ".csv";
        int file_handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON);
        
        if(file_handle != INVALID_HANDLE)
        {
            FileWrite(file_handle, "Metric,Value");
            FileWrite(file_handle, "Strategy Name", m_strategy_name);
            FileWrite(file_handle, "Total Trades", m_metrics.total_trades);
            FileWrite(file_handle, "Win Rate %", m_metrics.win_rate);
            FileWrite(file_handle, "Profit Factor", m_metrics.profit_factor);
            FileWrite(file_handle, "Max Drawdown %", m_metrics.max_drawdown);
            FileWrite(file_handle, "Net Profit", m_metrics.total_profit - m_metrics.total_loss);
            FileWrite(file_handle, "Expectancy", m_metrics.expectancy);
            FileWrite(file_handle, "Average Win", m_metrics.average_win);
            FileWrite(file_handle, "Average Loss", -m_metrics.average_loss);
            
            FileClose(file_handle);
            Print("Performance saved to: ", filename);
        }
    }
};
