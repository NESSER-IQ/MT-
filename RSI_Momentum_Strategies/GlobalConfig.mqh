//+------------------------------------------------------------------+
//| Global Configuration Settings                                   |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Centralized configuration file for all RSI         |
//|              momentum strategies with global settings           |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Global Constants and Enumerations                               |
//+------------------------------------------------------------------+

// Strategy Version Information
#define STRATEGY_SUITE_VERSION "1.0"
#define STRATEGY_SUITE_BUILD   "20241229"
#define STRATEGY_SUITE_NAME    "RSI Momentum Strategies"

// Magic Numbers for Different Strategies
#define MAGIC_RSI_SIMPLE       123456
#define MAGIC_TRIPLE_RSI       234567
#define MAGIC_DUAL_RSI         345678
#define MAGIC_STRATEGY_SELECTOR 999999
#define MAGIC_DASHBOARD        111111

// File Paths and Names
#define CONFIG_FILE_PATH       "RSI_Strategies_Config.dat"
#define LOG_FILE_PATH          "RSI_Strategies_Log.log"
#define PERFORMANCE_FILE_PATH  "RSI_Performance_Data.csv"
#define ALERTS_LOG_PATH        "RSI_Alerts_Log.txt"

// Default Risk Management Settings
#define DEFAULT_RISK_PERCENT   0.02    // 2% default risk
#define MAX_RISK_PERCENT       0.10    // 10% maximum risk
#define MIN_RISK_PERCENT       0.001   // 0.1% minimum risk
#define DEFAULT_MAX_DAILY_LOSS 0.05    // 5% max daily loss
#define DEFAULT_MAX_TRADES_DAY 5       // Maximum trades per day

// RSI Default Settings
#define DEFAULT_RSI_PERIOD     14
#define DEFAULT_RSI_OVERSOLD   30.0
#define DEFAULT_RSI_OVERBOUGHT 70.0
#define STOCK_RSI_PERIOD       2
#define STOCK_RSI_OVERSOLD     15.0
#define STOCK_RSI_OVERBOUGHT   85.0

// Moving Average Settings
#define DEFAULT_SMA_PERIOD     200
#define FAST_SMA_PERIOD        20
#define MEDIUM_SMA_PERIOD      50
#define SLOW_SMA_PERIOD        200

// Time Frame Settings
#define PRIMARY_TIMEFRAME      PERIOD_D1
#define SECONDARY_TIMEFRAME    PERIOD_H4
#define TERTIARY_TIMEFRAME     PERIOD_H1

// Performance Thresholds
#define EXCELLENT_WIN_RATE     80.0    // Excellent win rate threshold
#define GOOD_WIN_RATE          70.0    // Good win rate threshold
#define MIN_WIN_RATE           60.0    // Minimum acceptable win rate
#define EXCELLENT_PROFIT_FACTOR 2.5    // Excellent profit factor
#define GOOD_PROFIT_FACTOR     1.8     // Good profit factor  
#define MIN_PROFIT_FACTOR      1.2     // Minimum profit factor
#define MAX_ACCEPTABLE_DD      15.0    // Maximum acceptable drawdown
#define WARNING_DD_LEVEL       10.0    // Drawdown warning level

// Alert and Notification Settings
#define DEFAULT_ALERT_COOLDOWN 300     // 5 minutes between similar alerts
#define MAX_ALERTS_PER_HOUR    20      // Maximum alerts per hour
#define URGENT_ALERT_COOLDOWN  60      // 1 minute for urgent alerts

//+------------------------------------------------------------------+
//| Asset Configuration Structure                                   |
//+------------------------------------------------------------------+
struct SAssetConfig
{
    string asset_type;
    int optimal_rsi_period;
    double optimal_oversold;
    double optimal_overbought;
    double recommended_risk;
    int max_daily_trades;
    bool use_atr_stops;
    double atr_multiplier;
    string preferred_strategy;
    bool requires_volume_filter;
};

//+------------------------------------------------------------------+
//| Global Configuration Class                                      |
//+------------------------------------------------------------------+
class CGlobalConfig
{
private:
    // Suite Information
    string m_suite_name;
    string m_suite_version;
    string m_suite_build;
    datetime m_installation_date;
    
    // Default Risk Settings
    double m_default_risk_percent;
    double m_max_risk_percent;
    double m_max_daily_loss_percent;
    int m_max_daily_trades;
    bool m_use_conservative_mode;
    
    // Default Strategy Settings
    int m_default_rsi_period;
    double m_default_oversold;
    double m_default_overbought;
    int m_default_sma_period;
    bool m_use_trend_filter;
    bool m_use_volume_filter;
    bool m_use_volatility_filter;
    
    // Performance Monitoring
    bool m_auto_performance_reports;
    int m_performance_report_frequency;
    bool m_alert_on_poor_performance;
    double m_min_acceptable_win_rate;
    double m_max_acceptable_drawdown;
    
    // Notification Settings
    bool m_notifications_enabled;
    bool m_email_notifications;
    bool m_mobile_notifications;
    bool m_sound_notifications;
    bool m_popup_notifications;
    int m_alert_cooldown_seconds;
    
    // Advanced Features
    bool m_auto_strategy_switching;
    bool m_auto_parameter_optimization;
    bool m_multi_timeframe_analysis;
    bool m_market_condition_analysis;
    
    // Data and Logging
    bool m_detailed_logging;
    bool m_save_trade_history;
    bool m_export_performance_data;
    int m_log_retention_days;
    
    // UI and Display
    bool m_show_dashboard;
    bool m_show_signals_on_chart;
    bool m_show_performance_info;
    color m_profit_color;
    color m_loss_color;
    color m_neutral_color;
    
    // Debug and Development
    bool m_debug_mode;
    bool m_verbose_logging;
    bool m_performance_testing_mode;
    
    // Asset Configuration Data
    string m_asset_types[10];
    int m_asset_rsi_periods[10];
    double m_asset_oversold_levels[10];
    double m_asset_overbought_levels[10];
    double m_asset_recommended_risks[10];
    int m_asset_max_trades[10];
    bool m_asset_use_atr_stops[10];
    double m_asset_atr_multipliers[10];
    string m_asset_preferred_strategies[10];
    bool m_asset_requires_volume_filter[10];
    int m_asset_config_count;
    
    // File operations
    string m_config_file_path;
    bool m_config_loaded;
    
public:
    // Constructor
    CGlobalConfig()
    {
        m_config_file_path = CONFIG_FILE_PATH;
        m_asset_config_count = 0;
        m_config_loaded = false;
        
        InitializeDefaultConfig();
        InitializeAssetConfigs();
    }
    
    // Initialize default configuration
    void InitializeDefaultConfig()
    {
        // Suite Information
        m_suite_name = STRATEGY_SUITE_NAME;
        m_suite_version = STRATEGY_SUITE_VERSION;
        m_suite_build = STRATEGY_SUITE_BUILD;
        m_installation_date = TimeCurrent();
        
        // Risk Management
        m_default_risk_percent = DEFAULT_RISK_PERCENT;
        m_max_risk_percent = MAX_RISK_PERCENT;
        m_max_daily_loss_percent = DEFAULT_MAX_DAILY_LOSS;
        m_max_daily_trades = DEFAULT_MAX_TRADES_DAY;
        m_use_conservative_mode = false;
        
        // Strategy Settings
        m_default_rsi_period = DEFAULT_RSI_PERIOD;
        m_default_oversold = DEFAULT_RSI_OVERSOLD;
        m_default_overbought = DEFAULT_RSI_OVERBOUGHT;
        m_default_sma_period = DEFAULT_SMA_PERIOD;
        m_use_trend_filter = true;
        m_use_volume_filter = true;
        m_use_volatility_filter = true;
        
        // Performance Monitoring
        m_auto_performance_reports = true;
        m_performance_report_frequency = 24; // Daily
        m_alert_on_poor_performance = true;
        m_min_acceptable_win_rate = MIN_WIN_RATE;
        m_max_acceptable_drawdown = MAX_ACCEPTABLE_DD;
        
        // Notifications
        m_notifications_enabled = true;
        m_email_notifications = false;
        m_mobile_notifications = true;
        m_sound_notifications = true;
        m_popup_notifications = false;
        m_alert_cooldown_seconds = DEFAULT_ALERT_COOLDOWN;
        
        // Advanced Features
        m_auto_strategy_switching = false;
        m_auto_parameter_optimization = false;
        m_multi_timeframe_analysis = true;
        m_market_condition_analysis = true;
        
        // Data and Logging
        m_detailed_logging = true;
        m_save_trade_history = true;
        m_export_performance_data = true;
        m_log_retention_days = 30;
        
        // UI and Display
        m_show_dashboard = true;
        m_show_signals_on_chart = true;
        m_show_performance_info = true;
        m_profit_color = clrLimeGreen;
        m_loss_color = clrCrimson;
        m_neutral_color = clrGray;
        
        // Debug
        m_debug_mode = false;
        m_verbose_logging = false;
        m_performance_testing_mode = false;
        
        Print("Default global configuration initialized");
    }
    
    // Initialize asset-specific configurations
    void InitializeAssetConfigs()
    {
        m_asset_config_count = 0;
        
        // Stocks Configuration
        AddAssetConfigData("STOCKS", STOCK_RSI_PERIOD, STOCK_RSI_OVERSOLD, STOCK_RSI_OVERBOUGHT, 
                          0.02, 3, false, 2.0, "RSI_Simple_Stocks", true);
        
        // Forex Configuration
        AddAssetConfigData("FOREX", DEFAULT_RSI_PERIOD, DEFAULT_RSI_OVERSOLD, DEFAULT_RSI_OVERBOUGHT, 
                          0.01, 5, true, 1.5, "RSI_Simple_Forex", false);
        
        // Indices Configuration
        AddAssetConfigData("INDICES", DEFAULT_RSI_PERIOD, 25.0, 75.0, 
                          0.025, 4, true, 2.0, "Dual_RSI_Indices", true);
        
        // Commodities Configuration
        AddAssetConfigData("COMMODITIES", 6, 20.0, 80.0, 
                          0.02, 2, true, 2.5, "Triple_RSI_Advanced", false);
        
        Print("Asset-specific configurations initialized: ", m_asset_config_count, " configs");
    }
    
    // Add asset configuration data
    bool AddAssetConfigData(string asset_type, int rsi_period, double oversold, double overbought,
                           double risk, int max_trades, bool use_atr, double atr_mult, 
                           string strategy, bool volume_filter)
    {
        if(m_asset_config_count >= 10) return false;
        
        int index = m_asset_config_count;
        m_asset_types[index] = asset_type;
        m_asset_rsi_periods[index] = rsi_period;
        m_asset_oversold_levels[index] = oversold;
        m_asset_overbought_levels[index] = overbought;
        m_asset_recommended_risks[index] = risk;
        m_asset_max_trades[index] = max_trades;
        m_asset_use_atr_stops[index] = use_atr;
        m_asset_atr_multipliers[index] = atr_mult;
        m_asset_preferred_strategies[index] = strategy;
        m_asset_requires_volume_filter[index] = volume_filter;
        
        m_asset_config_count++;
        return true;
    }
    
    // Get asset configuration
    bool GetAssetConfig(string asset_type, SAssetConfig &config)
    {
        for(int i = 0; i < m_asset_config_count; i++)
        {
            if(m_asset_types[i] == asset_type)
            {
                config.asset_type = m_asset_types[i];
                config.optimal_rsi_period = m_asset_rsi_periods[i];
                config.optimal_oversold = m_asset_oversold_levels[i];
                config.optimal_overbought = m_asset_overbought_levels[i];
                config.recommended_risk = m_asset_recommended_risks[i];
                config.max_daily_trades = m_asset_max_trades[i];
                config.use_atr_stops = m_asset_use_atr_stops[i];
                config.atr_multiplier = m_asset_atr_multipliers[i];
                config.preferred_strategy = m_asset_preferred_strategies[i];
                config.requires_volume_filter = m_asset_requires_volume_filter[i];
                return true;
            }
        }
        return false;
    }
    
    // Load configuration from file
    bool LoadConfig()
    {
        int file_handle = FileOpen(m_config_file_path, FILE_READ | FILE_BIN | FILE_COMMON);
        if(file_handle != INVALID_HANDLE)
        {
            // Load basic configuration
            m_suite_name = FileReadString(file_handle);
            m_suite_version = FileReadString(file_handle);
            m_suite_build = FileReadString(file_handle);
            m_installation_date = (datetime)FileReadLong(file_handle);
            
            // Risk Settings
            m_default_risk_percent = FileReadDouble(file_handle);
            m_max_risk_percent = FileReadDouble(file_handle);
            m_max_daily_loss_percent = FileReadDouble(file_handle);
            m_max_daily_trades = FileReadInteger(file_handle);
            m_use_conservative_mode = (bool)FileReadInteger(file_handle);
            
            // Strategy Settings
            m_default_rsi_period = FileReadInteger(file_handle);
            m_default_oversold = FileReadDouble(file_handle);
            m_default_overbought = FileReadDouble(file_handle);
            m_default_sma_period = FileReadInteger(file_handle);
            m_use_trend_filter = (bool)FileReadInteger(file_handle);
            m_use_volume_filter = (bool)FileReadInteger(file_handle);
            m_use_volatility_filter = (bool)FileReadInteger(file_handle);
            
            // Notification Settings
            m_notifications_enabled = (bool)FileReadInteger(file_handle);
            m_email_notifications = (bool)FileReadInteger(file_handle);
            m_mobile_notifications = (bool)FileReadInteger(file_handle);
            m_sound_notifications = (bool)FileReadInteger(file_handle);
            m_popup_notifications = (bool)FileReadInteger(file_handle);
            
            // Debug Settings
            m_debug_mode = (bool)FileReadInteger(file_handle);
            m_verbose_logging = (bool)FileReadInteger(file_handle);
            
            FileClose(file_handle);
            m_config_loaded = true;
            
            Print("Configuration loaded from: ", m_config_file_path);
            return true;
        }
        
        Print("Configuration file not found, using defaults");
        return false;
    }
    
    // Save configuration to file
    bool SaveConfig()
    {
        int file_handle = FileOpen(m_config_file_path, FILE_WRITE | FILE_BIN | FILE_COMMON);
        if(file_handle != INVALID_HANDLE)
        {
            // Save basic configuration
            FileWriteString(file_handle, m_suite_name);
            FileWriteString(file_handle, m_suite_version);
            FileWriteString(file_handle, m_suite_build);
            FileWriteLong(file_handle, (long)m_installation_date);
            
            // Risk Settings
            FileWriteDouble(file_handle, m_default_risk_percent);
            FileWriteDouble(file_handle, m_max_risk_percent);
            FileWriteDouble(file_handle, m_max_daily_loss_percent);
            FileWriteInteger(file_handle, m_max_daily_trades);
            FileWriteInteger(file_handle, (int)m_use_conservative_mode);
            
            // Strategy Settings
            FileWriteInteger(file_handle, m_default_rsi_period);
            FileWriteDouble(file_handle, m_default_oversold);
            FileWriteDouble(file_handle, m_default_overbought);
            FileWriteInteger(file_handle, m_default_sma_period);
            FileWriteInteger(file_handle, (int)m_use_trend_filter);
            FileWriteInteger(file_handle, (int)m_use_volume_filter);
            FileWriteInteger(file_handle, (int)m_use_volatility_filter);
            
            // Notification Settings
            FileWriteInteger(file_handle, (int)m_notifications_enabled);
            FileWriteInteger(file_handle, (int)m_email_notifications);
            FileWriteInteger(file_handle, (int)m_mobile_notifications);
            FileWriteInteger(file_handle, (int)m_sound_notifications);
            FileWriteInteger(file_handle, (int)m_popup_notifications);
            
            // Debug Settings
            FileWriteInteger(file_handle, (int)m_debug_mode);
            FileWriteInteger(file_handle, (int)m_verbose_logging);
            
            FileClose(file_handle);
            Print("Configuration saved to: ", m_config_file_path);
            return true;
        }
        
        Print("Failed to save configuration");
        return false;
    }
    
    // Update configuration settings
    void SetRiskSettings(double default_risk, double max_risk, double max_daily_loss)
    {
        m_default_risk_percent = MathMax(MIN_RISK_PERCENT, MathMin(MAX_RISK_PERCENT, default_risk));
        m_max_risk_percent = MathMax(default_risk, MathMin(MAX_RISK_PERCENT, max_risk));
        m_max_daily_loss_percent = MathMax(0.01, MathMin(0.2, max_daily_loss));
    }
    
    void SetNotificationSettings(bool email, bool mobile, bool sound, bool popup)
    {
        m_email_notifications = email;
        m_mobile_notifications = mobile;
        m_sound_notifications = sound;
        m_popup_notifications = popup;
    }
    
    void SetAdvancedFeatures(bool auto_switching, bool auto_optimization, bool mtf_analysis)
    {
        m_auto_strategy_switching = auto_switching;
        m_auto_parameter_optimization = auto_optimization;
        m_multi_timeframe_analysis = mtf_analysis;
    }
    
    void SetDebugMode(bool debug, bool verbose)
    {
        m_debug_mode = debug;
        m_verbose_logging = verbose;
    }
    
    // Utility functions
    bool IsDebugMode() { return m_debug_mode; }
    bool IsVerboseLogging() { return m_verbose_logging; }
    bool IsConservativeMode() { return m_use_conservative_mode; }
    bool NotificationsEnabled() { return m_notifications_enabled; }
    
    double GetDefaultRisk() { return m_default_risk_percent; }
    double GetMaxRisk() { return m_max_risk_percent; }
    double GetMaxDailyLoss() { return m_max_daily_loss_percent; }
    int GetMaxDailyTrades() { return m_max_daily_trades; }
    
    // RSI Settings
    int GetDefaultRSIPeriod() { return m_default_rsi_period; }
    double GetDefaultOversold() { return m_default_oversold; }
    double GetDefaultOverbought() { return m_default_overbought; }
    
    // Print configuration summary
    void PrintConfigSummary()
    {
        Print("=== GLOBAL CONFIGURATION SUMMARY ===");
        Print("Suite: ", m_suite_name, " v", m_suite_version);
        Print("Build: ", m_suite_build);
        Print("Default Risk: ", DoubleToString(m_default_risk_percent * 100, 1), "%");
        Print("Max Risk: ", DoubleToString(m_max_risk_percent * 100, 1), "%");
        Print("Max Daily Loss: ", DoubleToString(m_max_daily_loss_percent * 100, 1), "%");
        Print("Notifications: ", m_notifications_enabled ? "Enabled" : "Disabled");
        Print("Debug Mode: ", m_debug_mode ? "On" : "Off");
        Print("Asset Configs: ", m_asset_config_count);
        Print("=====================================");
    }
    
    // Validate configuration
    bool ValidateConfig()
    {
        bool valid = true;
        
        // Validate risk settings
        if(m_default_risk_percent <= 0 || m_default_risk_percent > 0.1)
        {
            Print("WARNING: Invalid default risk setting");
            valid = false;
        }
        
        if(m_max_risk_percent < m_default_risk_percent)
        {
            Print("WARNING: Max risk is less than default risk");
            valid = false;
        }
        
        // Validate RSI settings
        if(m_default_rsi_period < 2 || m_default_rsi_period > 50)
        {
            Print("WARNING: Invalid RSI period");
            valid = false;
        }
        
        if(m_default_oversold >= m_default_overbought)
        {
            Print("WARNING: Invalid RSI levels");
            valid = false;
        }
        
        return valid;
    }
    
    // Reset to defaults
    void ResetToDefaults()
    {
        InitializeDefaultConfig();
        InitializeAssetConfigs();
        Print("Configuration reset to defaults");
    }
    
    // Get recommended settings for symbol
    SAssetConfig GetRecommendedSettings(string symbol)
    {
        SAssetConfig default_config;
        string symbol_upper = symbol;
        StringToUpper(symbol_upper);
        
        // Simple symbol classification
        if(StringFind(symbol_upper, "USD") >= 0 || StringFind(symbol_upper, "EUR") >= 0 || 
           StringFind(symbol_upper, "GBP") >= 0 || StringFind(symbol_upper, "JPY") >= 0)
        {
            GetAssetConfig("FOREX", default_config);
        }
        else if(StringFind(symbol_upper, "SPX") >= 0 || StringFind(symbol_upper, "NDX") >= 0 ||
                StringFind(symbol_upper, "DJI") >= 0 || StringFind(symbol_upper, "DAX") >= 0)
        {
            GetAssetConfig("INDICES", default_config);
        }
        else if(StringFind(symbol_upper, "GOLD") >= 0 || StringFind(symbol_upper, "SILVER") >= 0 ||
                StringFind(symbol_upper, "OIL") >= 0)
        {
            GetAssetConfig("COMMODITIES", default_config);
        }
        else
        {
            GetAssetConfig("STOCKS", default_config);
        }
        
        return default_config;
    }
};

//+------------------------------------------------------------------+
//| Global Configuration Instance                                   |
//+------------------------------------------------------------------+
CGlobalConfig* g_global_config = NULL;

//+------------------------------------------------------------------+
//| Initialize global configuration                                 |
//+------------------------------------------------------------------+
bool InitGlobalConfig()
{
    if(g_global_config == NULL)
    {
        g_global_config = new CGlobalConfig();
        if(g_global_config != NULL)
        {
            g_global_config.LoadConfig(); // Try to load saved config
            g_global_config.PrintConfigSummary();
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Cleanup global configuration                                   |
//+------------------------------------------------------------------+
void DeinitGlobalConfig()
{
    if(g_global_config != NULL)
    {
        g_global_config.SaveConfig(); // Save current config
        delete g_global_config;
        g_global_config = NULL;
    }
}

//+------------------------------------------------------------------+
//| Get global configuration                                        |
//+------------------------------------------------------------------+
CGlobalConfig* GetGlobalConfig()
{
    return g_global_config;
}

//+------------------------------------------------------------------+
//| Quick access functions                                          |
//+------------------------------------------------------------------+
double GetDefaultRiskPercent()
{
    if(g_global_config != NULL)
        return g_global_config.GetDefaultRisk();
    return DEFAULT_RISK_PERCENT;
}

bool IsDebugModeEnabled()
{
    if(g_global_config != NULL)
        return g_global_config.IsDebugMode();
    return false;
}

bool AreNotificationsEnabled()
{
    if(g_global_config != NULL)
        return g_global_config.NotificationsEnabled();
    return true;
}

SAssetConfig GetSymbolRecommendedSettings(string symbol = "")
{
    SAssetConfig default_config;
    default_config.asset_type = "STOCKS";
    default_config.optimal_rsi_period = STOCK_RSI_PERIOD;
    default_config.optimal_oversold = STOCK_RSI_OVERSOLD;
    default_config.optimal_overbought = STOCK_RSI_OVERBOUGHT;
    default_config.recommended_risk = DEFAULT_RISK_PERCENT;
    default_config.max_daily_trades = DEFAULT_MAX_TRADES_DAY;
    default_config.use_atr_stops = false;
    default_config.atr_multiplier = 2.0;
    default_config.preferred_strategy = "RSI_Simple_Stocks";
    default_config.requires_volume_filter = true;
    
    if(g_global_config != NULL)
    {
        string test_symbol = (symbol == "") ? _Symbol : symbol;
        default_config = g_global_config.GetRecommendedSettings(test_symbol);
    }
    
    return default_config;
}