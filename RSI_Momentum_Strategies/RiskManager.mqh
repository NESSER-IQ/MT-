//+------------------------------------------------------------------+
//| Risk Manager Library for RSI Momentum Strategies               |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Risk Management Class                                            |
//+------------------------------------------------------------------+
class CRiskManager
{
private:
    double m_balance;
    double m_risk_percent;
    double m_max_risk_per_trade;
    int    m_atr_handle;
    double m_atr_array[];
    
public:
    // Constructor
    CRiskManager(double risk_percent = 0.02, double max_risk = 0.05)
    {
        m_risk_percent = risk_percent;
        m_max_risk_per_trade = max_risk;
        m_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        ArraySetAsSeries(m_atr_array, true);
        
        // Initialize ATR for dynamic stop loss calculation
        m_atr_handle = iATR(_Symbol, PERIOD_D1, 14);
    }
    
    // Destructor
    ~CRiskManager()
    {
        if(m_atr_handle != INVALID_HANDLE)
            IndicatorRelease(m_atr_handle);
    }
    
    // Calculate position size based on risk percentage
    double CalculatePositionSize(double entry_price, double stop_loss)
    {
        m_balance = AccountInfoDouble(ACCOUNT_BALANCE);
        double risk_amount = m_balance * m_risk_percent;
        double stop_distance = MathAbs(entry_price - stop_loss);
        
        if(stop_distance == 0) return 0;
        
        double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
        double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
        
        if(tick_value == 0 || tick_size == 0) return 0;
        
        double volume = risk_amount / (stop_distance / tick_size * tick_value);
        
        // Apply volume limits
        double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
        double max_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
        
        // Don't risk more than max_risk_per_trade of balance
        double max_allowed_volume = (m_balance * m_max_risk_per_trade) / (stop_distance / tick_size * tick_value);
        max_volume = MathMin(max_volume, max_allowed_volume);
        
        volume = MathMax(min_volume, MathMin(max_volume, volume));
        
        return NormalizeDouble(volume, 2);
    }
    
    // Calculate ATR-based stop loss
    double CalculateATRStopLoss(double entry_price, bool is_long, double atr_multiplier = 2.0)
    {
        if(CopyBuffer(m_atr_handle, 0, 0, 1, m_atr_array) < 1)
            return 0;
            
        double atr = m_atr_array[0];
        double stop_distance = atr * atr_multiplier;
        
        if(is_long)
            return entry_price - stop_distance;
        else
            return entry_price + stop_distance;
    }
    
    // Calculate position size using ATR
    double CalculateATRBasedPosition(double entry_price, bool is_long, double atr_multiplier = 2.0)
    {
        double stop_loss = CalculateATRStopLoss(entry_price, is_long, atr_multiplier);
        if(stop_loss == 0) return 0;
        
        return CalculatePositionSize(entry_price, stop_loss);
    }
    
    // Check if maximum daily loss is reached
    bool IsMaxDailyLossReached(double max_daily_loss_percent = 0.05)
    {
        double daily_profit = GetDailyProfit();
        double max_loss = m_balance * max_daily_loss_percent;
        
        return (daily_profit < -max_loss);
    }
    
    // Get today's profit/loss
    double GetDailyProfit()
    {
        datetime today_start = iTime(_Symbol, PERIOD_D1, 0);
        double profit = 0;
        
        HistorySelect(today_start, TimeCurrent());
        
        for(int i = HistoryDealsTotal() - 1; i >= 0; i--)
        {
            ulong ticket = HistoryDealGetTicket(i);
            if(ticket > 0)
            {
                if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol)
                {
                    profit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
                }
            }
        }
        
        return profit;
    }
    
    // Update risk parameters
    void UpdateRiskParameters(double new_risk_percent)
    {
        m_risk_percent = MathMax(0.001, MathMin(0.1, new_risk_percent)); // 0.1% to 10%
    }
    
    // Get current risk percentage
    double GetRiskPercent() { return m_risk_percent; }
    
    // Get account balance
    double GetBalance() { return AccountInfoDouble(ACCOUNT_BALANCE); }
};
