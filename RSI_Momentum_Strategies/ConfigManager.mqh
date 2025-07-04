//+------------------------------------------------------------------+
//| Strategy Configuration Manager - Fixed Version                  |
//| Developer: AI Assistant                                          |
//| Version: 2.0                                                     |
//| Description: Fixed version with proper serialization for        |
//|              structures containing strings                       |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "2.00"

//+------------------------------------------------------------------+
//| Strategy Configuration Structure (Fixed Version)                |
//| استخدام char arrays بدلاً من strings لدعم FileWriteStruct      |
//+------------------------------------------------------------------+
struct SStrategyConfig
{
    // Strategy Identification - استخدام char arrays بحجم ثابت
    char strategy_name[64];
    char description[256];
    double expected_win_rate;
    double expected_avg_profit;
    
    // RSI Parameters
    int rsi_period;
    double rsi_oversold;
    double rsi_overbought;
    bool use_dynamic_levels;
    
    // Risk Management
    double risk_percent;
    double max_risk_per_trade;
    double stop_loss_percent;
    bool use_atr_stops;
    double atr_multiplier;
    
    // Market Filters
    int sma_period;
    bool use_trend_filter;
    bool use_volume_filter;
    bool use_volatility_filter;
    
    // Position Management
    int max_daily_trades;
    bool use_trailing_stops;
    double trailing_percent;
    int max_holding_days;
    
    // Asset Type Optimization
    bool optimized_for_stocks;
    bool optimized_for_forex;
    bool optimized_for_indices;
    bool optimized_for_commodities;
};

//+------------------------------------------------------------------+
//| Configuration Manager Class - Enhanced Version                  |
//+------------------------------------------------------------------+
class CConfigManager
{
private:
    SStrategyConfig m_configs[10]; // Support for up to 10 different configs
    int m_config_count;
    string m_config_file_path;
    
    // Helper functions for string conversion
    void StringToCharArray(const string& str, char& char_array[], int max_size)
    {
        // إعادة تعيين المصفوفة
        ArrayInitialize(char_array, 0);
        
        // تحويل string إلى char array
        int str_len = StringLen(str);
        int copy_len = MathMin(str_len, max_size - 1); // ترك مساحة للـ null terminator
        
        for(int i = 0; i < copy_len; i++)
        {
            char_array[i] = (char)StringGetCharacter(str, i);
        }
        char_array[copy_len] = 0; // null terminator
    }
    
    string CharArrayToString(const char& char_array[])
    {
        string result = "";
        int array_size = ArraySize(char_array);
        
        for(int i = 0; i < array_size && char_array[i] != 0; i++)
        {
            result += CharToString(char_array[i]);
        }
        
        return result;
    }
    
public:
    // Constructor
    CConfigManager()
    {
        m_config_count = 0;
        m_config_file_path = "RSI_Strategies_Config.dat";
        InitializeDefaultConfigs();
    }
    
    // Initialize default configurations
    void InitializeDefaultConfigs()
    {
        // Config 1: RSI Simple for Stocks
        SStrategyConfig config1;
        StringToCharArray("RSI_Simple_Stocks", config1.strategy_name, 64);
        StringToCharArray("Optimized for stock trading with 91% win rate", config1.description, 256);
        config1.expected_win_rate = 91.0;
        config1.expected_avg_profit = 0.82;
        config1.rsi_period = 2;
        config1.rsi_oversold = 15.0;
        config1.rsi_overbought = 85.0;
        config1.use_dynamic_levels = false;
        config1.risk_percent = 0.02;
        config1.max_risk_per_trade = 0.05;
        config1.stop_loss_percent = 0.02;
        config1.use_atr_stops = false;
        config1.atr_multiplier = 2.0;
        config1.sma_period = 200;
        config1.use_trend_filter = true;
        config1.use_volume_filter = true;
        config1.use_volatility_filter = true;
        config1.max_daily_trades = 3;
        config1.use_trailing_stops = false;
        config1.trailing_percent = 0.015;
        config1.max_holding_days = 3;
        config1.optimized_for_stocks = true;
        config1.optimized_for_forex = false;
        config1.optimized_for_indices = false;
        config1.optimized_for_commodities = false;
        AddConfig(config1);
        
        // Config 2: RSI Simple for Forex
        SStrategyConfig config2;
        StringToCharArray("RSI_Simple_Forex", config2.strategy_name, 64);
        StringToCharArray("Optimized for forex trading", config2.description, 256);
        config2.expected_win_rate = 75.0;
        config2.expected_avg_profit = 0.65;
        config2.rsi_period = 14;
        config2.rsi_oversold = 30.0;
        config2.rsi_overbought = 70.0;
        config2.use_dynamic_levels = true;
        config2.risk_percent = 0.01;
        config2.max_risk_per_trade = 0.03;
        config2.stop_loss_percent = 0.015;
        config2.use_atr_stops = true;
        config2.atr_multiplier = 1.5;
        config2.sma_period = 200;
        config2.use_trend_filter = true;
        config2.use_volume_filter = false;
        config2.use_volatility_filter = true;
        config2.max_daily_trades = 5;
        config2.use_trailing_stops = true;
        config2.trailing_percent = 0.01;
        config2.max_holding_days = 2;
        config2.optimized_for_stocks = false;
        config2.optimized_for_forex = true;
        config2.optimized_for_indices = false;
        config2.optimized_for_commodities = false;
        AddConfig(config2);
        
        // Config 3: Triple RSI Advanced
        SStrategyConfig config3;
        StringToCharArray("Triple_RSI_Advanced", config3.strategy_name, 64);
        StringToCharArray("Advanced Triple RSI with 90% win rate", config3.description, 256);
        config3.expected_win_rate = 90.0;
        config3.expected_avg_profit = 1.4;
        config3.rsi_period = 2;
        config3.rsi_oversold = 30.0;
        config3.rsi_overbought = 70.0;
        config3.use_dynamic_levels = true;
        config3.risk_percent = 0.025;
        config3.max_risk_per_trade = 0.07;
        config3.stop_loss_percent = 0.03;
        config3.use_atr_stops = true;
        config3.atr_multiplier = 2.5;
        config3.sma_period = 200;
        config3.use_trend_filter = true;
        config3.use_volume_filter = true;
        config3.use_volatility_filter = true;
        config3.max_daily_trades = 2;
        config3.use_trailing_stops = true;
        config3.trailing_percent = 0.015;
        config3.max_holding_days = 5;
        config3.optimized_for_stocks = true;
        config3.optimized_for_forex = false;
        config3.optimized_for_indices = true;
        config3.optimized_for_commodities = false;
        AddConfig(config3);
        
        // Config 4: Dual RSI for Indices
        SStrategyConfig config4;
        StringToCharArray("Dual_RSI_Indices", config4.strategy_name, 64);
        StringToCharArray("Dual RSI optimized for index trading", config4.description, 256);
        config4.expected_win_rate = 78.0;
        config4.expected_avg_profit = 1.1;
        config4.rsi_period = 14;
        config4.rsi_oversold = 25.0;
        config4.rsi_overbought = 75.0;
        config4.use_dynamic_levels = true;
        config4.risk_percent = 0.03;
        config4.max_risk_per_trade = 0.08;
        config4.stop_loss_percent = 0.025;
        config4.use_atr_stops = true;
        config4.atr_multiplier = 2.0;
        config4.sma_period = 200;
        config4.use_trend_filter = true;
        config4.use_volume_filter = true;
        config4.use_volatility_filter = true;
        config4.max_daily_trades = 4;
        config4.use_trailing_stops = true;
        config4.trailing_percent = 0.02;
        config4.max_holding_days = 3;
        config4.optimized_for_stocks = false;
        config4.optimized_for_forex = false;
        config4.optimized_for_indices = true;
        config4.optimized_for_commodities = false;
        AddConfig(config4);
        
        Print("Initialized ", m_config_count, " default strategy configurations");
    }
    
    // Add configuration
    bool AddConfig(SStrategyConfig& config)
    {
        if(m_config_count >= 10)
        {
            Print("Maximum number of configurations reached");
            return false;
        }
        
        m_configs[m_config_count] = config;
        m_config_count++;
        return true;
    }
    
    // Get configuration by name
    bool GetConfig(string strategy_name, SStrategyConfig& config)
    {
        for(int i = 0; i < m_config_count; i++)
        {
            string current_name = CharArrayToString(m_configs[i].strategy_name);
            if(current_name == strategy_name)
            {
                config = m_configs[i];
                return true;
            }
        }
        
        Print("Configuration not found: ", strategy_name);
        return false;
    }
    
    // Get configuration by asset type
    bool GetConfigByAssetType(string asset_type, SStrategyConfig& config)
    {
        for(int i = 0; i < m_config_count; i++)
        {
            if(asset_type == "STOCKS" && m_configs[i].optimized_for_stocks)
            {
                config = m_configs[i];
                return true;
            }
            else if(asset_type == "FOREX" && m_configs[i].optimized_for_forex)
            {
                config = m_configs[i];
                return true;
            }
            else if(asset_type == "INDICES" && m_configs[i].optimized_for_indices)
            {
                config = m_configs[i];
                return true;
            }
            else if(asset_type == "COMMODITIES" && m_configs[i].optimized_for_commodities)
            {
                config = m_configs[i];
                return true;
            }
        }
        
        Print("No configuration found for asset type: ", asset_type);
        return false;
    }
    
    // List all available configurations
    void ListConfigurations()
    {
        Print("=== Available Strategy Configurations ===");
        for(int i = 0; i < m_config_count; i++)
        {
            string name = CharArrayToString(m_configs[i].strategy_name);
            string desc = CharArrayToString(m_configs[i].description);
            
            Print("Config ", (i+1), ": ", name);
            Print("  Description: ", desc);
            Print("  Expected Win Rate: ", DoubleToString(m_configs[i].expected_win_rate, 1), "%");
            Print("  Expected Avg Profit: ", DoubleToString(m_configs[i].expected_avg_profit, 2), "%");
            Print("  RSI Period: ", m_configs[i].rsi_period);
            Print("  Risk per Trade: ", DoubleToString(m_configs[i].risk_percent * 100, 1), "%");
            Print("  Asset Types: ", 
                  (m_configs[i].optimized_for_stocks ? "STOCKS " : ""),
                  (m_configs[i].optimized_for_forex ? "FOREX " : ""),
                  (m_configs[i].optimized_for_indices ? "INDICES " : ""),
                  (m_configs[i].optimized_for_commodities ? "COMMODITIES " : ""));
            Print("  --------------------------------");
        }
    }
    
    // Auto-detect best configuration for current symbol
    string AutoDetectBestConfig()
    {
        string symbol = _Symbol;
        string symbol_upper = symbol;
        StringToUpper(symbol_upper);
        
        // Simple symbol classification logic
        if(StringFind(symbol_upper, "USD") >= 0 || StringFind(symbol_upper, "EUR") >= 0 || 
           StringFind(symbol_upper, "GBP") >= 0 || StringFind(symbol_upper, "JPY") >= 0 ||
           StringFind(symbol_upper, "CHF") >= 0 || StringFind(symbol_upper, "CAD") >= 0 ||
           StringFind(symbol_upper, "AUD") >= 0 || StringFind(symbol_upper, "NZD") >= 0)
        {
            Print("Auto-detected asset type: FOREX for symbol ", symbol);
            return "RSI_Simple_Forex";
        }
        else if(StringFind(symbol_upper, "SPX") >= 0 || StringFind(symbol_upper, "NDX") >= 0 ||
                StringFind(symbol_upper, "DJI") >= 0 || StringFind(symbol_upper, "DAX") >= 0 ||
                StringFind(symbol_upper, "FTSE") >= 0 || StringFind(symbol_upper, "NIKKEI") >= 0)
        {
            Print("Auto-detected asset type: INDICES for symbol ", symbol);
            return "Dual_RSI_Indices";
        }
        else if(StringFind(symbol_upper, "GOLD") >= 0 || StringFind(symbol_upper, "SILVER") >= 0 ||
                StringFind(symbol_upper, "OIL") >= 0 || StringFind(symbol_upper, "BRENT") >= 0)
        {
            Print("Auto-detected asset type: COMMODITIES for symbol ", symbol);
            return "Triple_RSI_Advanced"; // Use advanced strategy for commodities
        }
        else
        {
            Print("Auto-detected asset type: STOCKS for symbol ", symbol);
            return "RSI_Simple_Stocks";
        }
    }
    
    // Save configurations to file (Fixed Version)
    bool SaveConfigurations()
    {
        int file_handle = FileOpen(m_config_file_path, FILE_WRITE | FILE_BIN | FILE_COMMON);
        if(file_handle != INVALID_HANDLE)
        {
            // كتابة عدد الكونفيجوريشنز
            FileWriteInteger(file_handle, m_config_count);
            
            // كتابة كل كونفيجوريشن باستخدام FileWriteStruct (الآن يعمل لأن الهيكل لا يحتوي على strings)
            for(int i = 0; i < m_config_count; i++)
            {
                FileWriteStruct(file_handle, m_configs[i]);
            }
            
            FileClose(file_handle);
            Print("Configurations saved successfully to ", m_config_file_path);
            return true;
        }
        
        Print("Failed to save configurations - Error: ", GetLastError());
        return false;
    }
    
    // Load configurations from file (Fixed Version)
    bool LoadConfigurations()
    {
        int file_handle = FileOpen(m_config_file_path, FILE_READ | FILE_BIN | FILE_COMMON);
        if(file_handle != INVALID_HANDLE)
        {
            // قراءة عدد الكونفيجوريشنز
            m_config_count = FileReadInteger(file_handle);
            
            // التأكد من أن العدد ضمن الحدود المسموحة
            if(m_config_count > 10)
            {
                Print("Warning: Configuration count exceeds maximum limit, limiting to 10");
                m_config_count = 10;
            }
            
            // قراءة كل كونفيجوريشن باستخدام FileReadStruct (الآن يعمل)
            for(int i = 0; i < m_config_count; i++)
            {
                FileReadStruct(file_handle, m_configs[i]);
            }
            
            FileClose(file_handle);
            Print("Configurations loaded successfully from ", m_config_file_path);
            return true;
        }
        
        Print("Configuration file not found, using defaults");
        return false;
    }
    
    // Get configuration count
    int GetConfigCount() { return m_config_count; }
    
    // Get configuration by index
    bool GetConfigByIndex(int index, SStrategyConfig& config)
    {
        if(index >= 0 && index < m_config_count)
        {
            config = m_configs[index];
            return true;
        }
        return false;
    }
    
    // Update configuration
    bool UpdateConfig(string strategy_name, SStrategyConfig& new_config)
    {
        for(int i = 0; i < m_config_count; i++)
        {
            string current_name = CharArrayToString(m_configs[i].strategy_name);
            if(current_name == strategy_name)
            {
                m_configs[i] = new_config;
                Print("Configuration updated: ", strategy_name);
                return true;
            }
        }
        
        Print("Configuration not found for update: ", strategy_name);
        return false;
    }
    
    // Create configuration from strings (Helper function)
    SStrategyConfig CreateConfig(string name, string description, double win_rate, double avg_profit)
    {
        SStrategyConfig config;
        StringToCharArray(name, config.strategy_name, 64);
        StringToCharArray(description, config.description, 256);
        config.expected_win_rate = win_rate;
        config.expected_avg_profit = avg_profit;
        
        // Set default values
        config.rsi_period = 14;
        config.rsi_oversold = 30.0;
        config.rsi_overbought = 70.0;
        config.use_dynamic_levels = false;
        config.risk_percent = 0.02;
        config.max_risk_per_trade = 0.05;
        config.stop_loss_percent = 0.02;
        config.use_atr_stops = false;
        config.atr_multiplier = 2.0;
        config.sma_period = 200;
        config.use_trend_filter = true;
        config.use_volume_filter = true;
        config.use_volatility_filter = true;
        config.max_daily_trades = 3;
        config.use_trailing_stops = false;
        config.trailing_percent = 0.015;
        config.max_holding_days = 3;
        config.optimized_for_stocks = true;
        config.optimized_for_forex = false;
        config.optimized_for_indices = false;
        config.optimized_for_commodities = false;
        
        return config;
    }
    
    // Create optimized configuration for current market conditions
    SStrategyConfig CreateOptimizedConfig(string base_config_name)
    {
        SStrategyConfig base_config;
        SStrategyConfig optimized_config;
        
        if(GetConfig(base_config_name, base_config))
        {
            optimized_config = base_config;
            
            // Get market volatility for optimization
            int atr_handle = iATR(_Symbol, PERIOD_D1, 14);
            if(atr_handle != INVALID_HANDLE)
            {
                double atr_array[];
                ArraySetAsSeries(atr_array, true);
                
                if(CopyBuffer(atr_handle, 0, 0, 20, atr_array) == 20)
                {
                    double current_atr = atr_array[0];
                    double avg_atr = 0;
                    for(int i = 0; i < 20; i++)
                        avg_atr += atr_array[i];
                    avg_atr /= 20;
                    
                    double volatility_ratio = current_atr / avg_atr;
                    
                    // Adjust parameters based on volatility
                    if(volatility_ratio > 1.3) // High volatility
                    {
                        optimized_config.rsi_oversold -= 3;
                        optimized_config.rsi_overbought += 3;
                        optimized_config.risk_percent *= 0.8;
                        optimized_config.atr_multiplier *= 1.2;
                        Print("Optimized for HIGH volatility market");
                    }
                    else if(volatility_ratio < 0.7) // Low volatility
                    {
                        optimized_config.rsi_oversold += 2;
                        optimized_config.rsi_overbought -= 2;
                        optimized_config.risk_percent *= 1.1;
                        optimized_config.atr_multiplier *= 0.9;
                        Print("Optimized for LOW volatility market");
                    }
                }
                
                IndicatorRelease(atr_handle);
            }
        }
        
        return optimized_config;
    }
    
    // Get strategy name as string (Helper function)
    string GetStrategyName(const SStrategyConfig& config)
    {
        return CharArrayToString(config.strategy_name);
    }
    
    // Get description as string (Helper function)
    string GetDescription(const SStrategyConfig& config)
    {
        return CharArrayToString(config.description);
    }
};

//+------------------------------------------------------------------+
//| Global configuration manager instance                           |
//+------------------------------------------------------------------+
CConfigManager* g_config_manager = NULL;

//+------------------------------------------------------------------+
//| Initialize configuration manager                                 |
//+------------------------------------------------------------------+
bool InitConfigManager()
{
    if(g_config_manager == NULL)
    {
        g_config_manager = new CConfigManager();
        if(g_config_manager != NULL)
        {
            g_config_manager.LoadConfigurations();
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Cleanup configuration manager                                   |
//+------------------------------------------------------------------+
void DeinitConfigManager()
{
    if(g_config_manager != NULL)
    {
        g_config_manager.SaveConfigurations();
        delete g_config_manager;
        g_config_manager = NULL;
    }
}

//+------------------------------------------------------------------+
//| Get global configuration manager                                |
//+------------------------------------------------------------------+
CConfigManager* GetConfigManager()
{
    return g_config_manager;
}
