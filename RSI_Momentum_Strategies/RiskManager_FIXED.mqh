//+------------------------------------------------------------------+
//| Risk Management System - Enhanced Version                       |
//| Developer: AI Assistant                                          |
//| Version: 2.0                                                     |
//| Description: Comprehensive risk management with enhanced        |
//|              position sizing and drawdown protection            |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "2.00"

//+------------------------------------------------------------------+
//| Risk Management Configuration Structure                         |
//+------------------------------------------------------------------+
struct SRiskConfig
{
    double max_risk_per_trade;          // Maximum risk per trade (%)
    double max_daily_risk;              // Maximum daily risk (%)
    double max_portfolio_risk;          // Maximum portfolio risk (%)
    double max_drawdown_limit;          // Maximum allowed drawdown (%)
    double position_size_multiplier;    // Position size multiplier
    bool use_kelly_criterion;           // Use Kelly Criterion for sizing
    bool use_atr_stops;                // Use ATR-based stops
    double atr_multiplier;              // ATR multiplier for stops
    int max_concurrent_trades;          // Maximum concurrent trades
    bool use_correlation_filter;        // Use correlation filter
    double correlation_threshold;       // Correlation threshold
};

//+------------------------------------------------------------------+
//| Position Information Structure                                  |
//+------------------------------------------------------------------+
struct SPositionInfo
{
    string symbol;
    double entry_price;
    double current_price;
    double stop_loss;
    double take_profit;
    double position_size;
    double unrealized_pnl;
    double risk_amount;
    datetime entry_time;
    bool is_long;
};

//+------------------------------------------------------------------+
//| Risk Manager Class - Enhanced Version                          |
//+------------------------------------------------------------------+
class CRiskManager
{
private:
    SRiskConfig m_config;
    SPositionInfo m_positions[50];      // Support up to 50 positions
    int m_position_count;
    
    double m_account_balance;
    double m_account_equity;
    double m_daily_pnl;
    double m_total_risk_exposure;
    double m_peak_equity;
    double m_current_drawdown;
    double m_max_drawdown;
    
    datetime m_last_reset_time;
    
    // Risk metrics
    double m_daily_var;                 // Value at Risk
    double m_portfolio_beta;            // Portfolio beta
    double m_sharpe_ratio;              // Sharpe ratio
    
    // ATR handle for volatility-based sizing
    int m_atr_handle;
    
public:
    // Constructor
    CRiskManager()
    {
        InitializeDefaults();
        m_position_count = 0;
        m_account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
        m_peak_equity = m_account_equity;
        m_current_drawdown = 0.0;
        m_max_drawdown = 0.0;
        m_daily_pnl = 0.0;
        m_total_risk_exposure = 0.0;
        m_last_reset_time = TimeCurrent();
        
        // Initialize ATR for volatility calculations
        m_atr_handle = iATR(_Symbol, PERIOD_D1, 14);
    }
    
    // Destructor
    ~CRiskManager()
    {
        if(m_atr_handle != INVALID_HANDLE)
            IndicatorRelease(m_atr_handle);
    }
    
    // Initialize default configuration
    void InitializeDefaults()
    {
        m_config.max_risk_per_trade = 0.02;      // 2% max risk per trade
        m_config.max_daily_risk = 0.06;          // 6% max daily risk
        m_config.max_portfolio_risk = 0.20;      // 20% max portfolio risk
        m_config.max_drawdown_limit = 0.15;      // 15% max drawdown
        m_config.position_size_multiplier = 1.0; // Normal sizing
        m_config.use_kelly_criterion = false;    // Conservative approach
        m_config.use_atr_stops = true;           // Use ATR stops
        m_config.atr_multiplier = 2.0;           // 2x ATR for stops
        m_config.max_concurrent_trades = 5;      // Max 5 concurrent trades
        m_config.use_correlation_filter = true;  // Use correlation filter
        m_config.correlation_threshold = 0.7;    // 70% correlation threshold
    }
    
    // Set risk configuration
    void SetRiskConfig(const SRiskConfig& config)
    {
        m_config = config;
    }
    
    // Get risk configuration
    SRiskConfig GetRiskConfig() const
    {
        return m_config;
    }
    
    // Calculate optimal position size
    double CalculatePositionSize(string symbol, double entry_price, double stop_loss, 
                                double confidence = 0.5)
    {
        if(!IsValidPrice(entry_price) || !IsValidPrice(stop_loss))
            return 0.0;
            
        // Check if we can take new positions
        if(!CanOpenNewPosition())
            return 0.0;
            
        // Update account information
        UpdateAccountInfo();
        
        // Calculate stop distance
        double stop_distance = MathAbs(entry_price - stop_loss);
        if(stop_distance <= 0)
            return 0.0;
            
        // Calculate risk amount
        double risk_amount = CalculateRiskAmount(confidence);
        if(risk_amount <= 0)
            return 0.0;
            
        // Calculate base position size
        double position_size = risk_amount / stop_distance;
        
        // Apply volatility adjustment
        if(m_config.use_atr_stops)
        {
            double volatility_adjustment = GetVolatilityAdjustment(symbol);
            position_size *= volatility_adjustment;
        }
        
        // Apply Kelly Criterion if enabled
        if(m_config.use_kelly_criterion)
        {
            double kelly_factor = CalculateKellyFactor(confidence);
            position_size *= kelly_factor;
        }
        
        // Apply position size multiplier
        position_size *= m_config.position_size_multiplier;
        
        // Ensure minimum and maximum limits
        double min_size = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
        double max_size = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
        
        position_size = MathMax(min_size, MathMin(max_size, position_size));
        
        return NormalizeDouble(position_size, 2);
    }
    
    // Check if new position can be opened
    bool CanOpenNewPosition()
    {
        // Check maximum concurrent trades
        if(m_position_count >= m_config.max_concurrent_trades)
        {
            Print("Risk Manager: Maximum concurrent trades reached (", m_position_count, ")");
            return false;
        }
        
        // Check daily risk limit
        if(MathAbs(m_daily_pnl) >= m_account_balance * m_config.max_daily_risk)
        {
            Print("Risk Manager: Daily risk limit exceeded");
            return false;
        }
        
        // Check drawdown limit
        if(m_current_drawdown >= m_config.max_drawdown_limit * 100)
        {
            Print("Risk Manager: Maximum drawdown limit exceeded (", 
                  DoubleToString(m_current_drawdown, 2), "%)");
            return false;
        }
        
        // Check portfolio risk
        if(m_total_risk_exposure >= m_account_balance * m_config.max_portfolio_risk)
        {
            Print("Risk Manager: Portfolio risk limit exceeded");
            return false;
        }
        
        return true;
    }
    
    // Add position to tracking
    bool AddPosition(string symbol, double entry_price, double stop_loss, 
                    double take_profit, double position_size, bool is_long)
    {
        if(m_position_count >= ArraySize(m_positions))
            return false;
            
        SPositionInfo position;
        position.symbol = symbol;
        position.entry_price = entry_price;
        position.current_price = entry_price;
        position.stop_loss = stop_loss;
        position.take_profit = take_profit;
        position.position_size = position_size;
        position.unrealized_pnl = 0.0;
        position.risk_amount = MathAbs(entry_price - stop_loss) * position_size;
        position.entry_time = TimeCurrent();
        position.is_long = is_long;
        
        m_positions[m_position_count] = position;
        m_position_count++;
        
        // Update total risk exposure
        m_total_risk_exposure += position.risk_amount;
        
        Print("Risk Manager: Position added - ", symbol, " Size: ", position_size, 
              " Risk: $", DoubleToString(position.risk_amount, 2));
        
        return true;
    }
    
    // Remove position from tracking
    bool RemovePosition(string symbol, double exit_price)
    {
        for(int i = 0; i < m_position_count; i++)
        {
            if(m_positions[i].symbol == symbol)
            {
                // Calculate realized P&L
                double realized_pnl = 0.0;
                if(m_positions[i].is_long)
                    realized_pnl = (exit_price - m_positions[i].entry_price) * m_positions[i].position_size;
                else
                    realized_pnl = (m_positions[i].entry_price - exit_price) * m_positions[i].position_size;
                
                // Update daily P&L
                m_daily_pnl += realized_pnl;
                
                // Update total risk exposure
                m_total_risk_exposure -= m_positions[i].risk_amount;
                
                Print("Risk Manager: Position closed - ", symbol, " P&L: $", 
                      DoubleToString(realized_pnl, 2));
                
                // Remove position by shifting array
                for(int j = i; j < m_position_count - 1; j++)
                {
                    m_positions[j] = m_positions[j + 1];
                }
                m_position_count--;
                
                return true;
            }
        }
        
        return false;
    }
    
    // Update position information
    void UpdatePositions()
    {
        for(int i = 0; i < m_position_count; i++)
        {
            // Get current price
            double current_price = SymbolInfoDouble(m_positions[i].symbol, SYMBOL_BID);
            m_positions[i].current_price = current_price;
            
            // Calculate unrealized P&L
            if(m_positions[i].is_long)
                m_positions[i].unrealized_pnl = (current_price - m_positions[i].entry_price) * m_positions[i].position_size;
            else
                m_positions[i].unrealized_pnl = (m_positions[i].entry_price - current_price) * m_positions[i].position_size;
        }
        
        // Update account information
        UpdateAccountInfo();
        
        // Reset daily P&L if new day
        CheckDailyReset();
    }
    
    // Get risk metrics
    void GetRiskMetrics(double& current_dd, double& max_dd, double& daily_pnl, 
                       double& total_exposure, int& active_positions)
    {
        current_dd = m_current_drawdown;
        max_dd = m_max_drawdown;
        daily_pnl = m_daily_pnl;
        total_exposure = m_total_risk_exposure;
        active_positions = m_position_count;
    }
    
    // Calculate Value at Risk (VaR)
    double CalculateVaR(double confidence_level = 0.95)
    {
        if(m_position_count == 0)
            return 0.0;
            
        // Simple VaR calculation based on position risk
        double total_position_risk = 0.0;
        for(int i = 0; i < m_position_count; i++)
        {
            total_position_risk += m_positions[i].risk_amount;
        }
        
        // Apply confidence factor
        double z_score = confidence_level == 0.95 ? 1.645 : 
                        confidence_level == 0.99 ? 2.326 : 1.282;
        
        return total_position_risk * z_score;
    }
    
    // Generate risk report
    void GenerateRiskReport()
    {
        Print("=== RISK MANAGEMENT REPORT ===");
        Print("Account Balance: $", DoubleToString(m_account_balance, 2));
        Print("Account Equity: $", DoubleToString(m_account_equity, 2));
        Print("Peak Equity: $", DoubleToString(m_peak_equity, 2));
        Print("Current Drawdown: ", DoubleToString(m_current_drawdown, 2), "%");
        Print("Max Drawdown: ", DoubleToString(m_max_drawdown, 2), "%");
        Print("Daily P&L: $", DoubleToString(m_daily_pnl, 2));
        Print("Total Risk Exposure: $", DoubleToString(m_total_risk_exposure, 2));
        Print("Risk Exposure %: ", DoubleToString(m_total_risk_exposure/m_account_balance*100, 2), "%");
        Print("Active Positions: ", m_position_count);
        Print("VaR (95%): $", DoubleToString(CalculateVaR(0.95), 2));
        
        Print("\n--- Active Positions ---");
        for(int i = 0; i < m_position_count; i++)
        {
            Print("Position ", (i+1), ": ", m_positions[i].symbol, 
                  " | Size: ", m_positions[i].position_size,
                  " | P&L: $", DoubleToString(m_positions[i].unrealized_pnl, 2),
                  " | Risk: $", DoubleToString(m_positions[i].risk_amount, 2));
        }
        Print("===============================");
    }
    
    // Check if symbol correlation is acceptable
    bool IsCorrelationAcceptable(string symbol1, string symbol2)
    {
        if(!m_config.use_correlation_filter)
            return true;
            
        // Simple correlation check based on price movements
        // In real implementation, you would calculate actual correlation
        double correlation = CalculateCorrelation(symbol1, symbol2);
        
        return MathAbs(correlation) < m_config.correlation_threshold;
    }
    
private:
    // Update account information
    void UpdateAccountInfo()
    {
        m_account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
        
        // Update peak equity and drawdown
        if(m_account_equity > m_peak_equity)
        {
            m_peak_equity = m_account_equity;
            m_current_drawdown = 0.0;
        }
        else
        {
            m_current_drawdown = (m_peak_equity - m_account_equity) / m_peak_equity * 100;
            if(m_current_drawdown > m_max_drawdown)
                m_max_drawdown = m_current_drawdown;
        }
    }
    
    // Calculate risk amount based on configuration
    double CalculateRiskAmount(double confidence)
    {
        double base_risk = m_account_balance * m_config.max_risk_per_trade;
        
        // Adjust based on confidence
        double adjusted_risk = base_risk * confidence;
        
        // Ensure we don't exceed daily risk limit
        double remaining_daily_risk = (m_account_balance * m_config.max_daily_risk) - MathAbs(m_daily_pnl);
        adjusted_risk = MathMin(adjusted_risk, remaining_daily_risk);
        
        return MathMax(0.0, adjusted_risk);
    }
    
    // Get volatility adjustment factor
    double GetVolatilityAdjustment(string symbol)
    {
        if(m_atr_handle == INVALID_HANDLE)
            return 1.0;
            
        double atr_array[];
        ArraySetAsSeries(atr_array, true);
        
        if(CopyBuffer(m_atr_handle, 0, 0, 20, atr_array) < 20)
            return 1.0;
            
        double current_atr = atr_array[0];
        double avg_atr = 0.0;
        for(int i = 0; i < 20; i++)
            avg_atr += atr_array[i];
        avg_atr /= 20;
        
        if(avg_atr == 0.0)
            return 1.0;
            
        double volatility_ratio = current_atr / avg_atr;
        
        // Reduce position size when volatility is high
        if(volatility_ratio > 1.5)
            return 0.7;  // Reduce by 30%
        else if(volatility_ratio > 1.2)
            return 0.85; // Reduce by 15%
        else if(volatility_ratio < 0.8)
            return 1.15; // Increase by 15%
        else
            return 1.0;  // Normal size
    }
    
    // Calculate Kelly Criterion factor
    double CalculateKellyFactor(double confidence)
    {
        // Simplified Kelly calculation
        // In real implementation, use historical win rate and average win/loss
        double win_rate = 0.6;  // 60% estimated win rate
        double avg_win = 1.5;   // Average win ratio
        double avg_loss = 1.0;  // Average loss ratio
        
        double kelly = (win_rate * avg_win - (1 - win_rate) * avg_loss) / avg_win;
        kelly = MathMax(0.0, MathMin(0.25, kelly)); // Cap at 25%
        
        return kelly * confidence;
    }
    
    // Check if price is valid
    bool IsValidPrice(double price)
    {
        return price > 0.0 && price != EMPTY_VALUE;
    }
    
    // Check for daily reset
    void CheckDailyReset()
    {
        datetime current_time = TimeCurrent();
        MqlDateTime current_dt, last_dt;
        
        TimeToStruct(current_time, current_dt);
        TimeToStruct(m_last_reset_time, last_dt);
        
        if(current_dt.day != last_dt.day)
        {
            m_daily_pnl = 0.0;
            m_last_reset_time = current_time;
            Print("Risk Manager: Daily reset - New trading day started");
        }
    }
    
    // Calculate correlation between two symbols
    double CalculateCorrelation(string symbol1, string symbol2)
    {
        // Simplified correlation calculation
        // In real implementation, calculate actual price correlation
        
        if(symbol1 == symbol2)
            return 1.0;
            
        // Simple heuristic based on symbol similarity
        if(StringFind(symbol1, "USD") >= 0 && StringFind(symbol2, "USD") >= 0)
            return 0.8;  // High correlation for USD pairs
        else if(StringFind(symbol1, "EUR") >= 0 && StringFind(symbol2, "EUR") >= 0)
            return 0.7;  // High correlation for EUR pairs
        else
            return 0.3;  // Low correlation for different pairs
    }
};

//+------------------------------------------------------------------+
//| Global Risk Manager Instance                                   |
//+------------------------------------------------------------------+
CRiskManager* g_risk_manager = NULL;

//+------------------------------------------------------------------+
//| Initialize Risk Manager                                         |
//+------------------------------------------------------------------+
bool InitRiskManager()
{
    if(g_risk_manager == NULL)
    {
        g_risk_manager = new CRiskManager();
        if(g_risk_manager != NULL)
        {
            Print("Risk Manager initialized successfully");
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Cleanup Risk Manager                                           |
//+------------------------------------------------------------------+
void DeinitRiskManager()
{
    if(g_risk_manager != NULL)
    {
        g_risk_manager.GenerateRiskReport();
        delete g_risk_manager;
        g_risk_manager = NULL;
    }
}

//+------------------------------------------------------------------+
//| Get Global Risk Manager                                        |
//+------------------------------------------------------------------+
CRiskManager* GetRiskManager()
{
    return g_risk_manager;
}