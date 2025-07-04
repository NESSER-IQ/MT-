//+------------------------------------------------------------------+
//| Advanced Notification and Alert System                          |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Comprehensive notification system for RSI          |
//|              strategies with multiple alert channels            |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"

//--- Include Windows API for advanced notifications
#import "user32.dll"
   int MessageBoxW(int hWnd, string lpText, string lpCaption, int uType);
#import

//+------------------------------------------------------------------+
//| Alert Types Enumeration                                         |
//+------------------------------------------------------------------+
enum ENUM_ALERT_TYPE
{
    ALERT_TRADE_OPEN,           // Trade opened
    ALERT_TRADE_CLOSE,          // Trade closed
    ALERT_SIGNAL_DETECTED,      // Trading signal detected
    ALERT_RISK_WARNING,         // Risk management warning
    ALERT_PERFORMANCE_UPDATE,   // Performance milestone
    ALERT_STRATEGY_SWITCH,      // Strategy switched
    ALERT_ERROR,                // System error
    ALERT_DAILY_SUMMARY,        // Daily summary
    ALERT_OPTIMIZATION_COMPLETE // Optimization completed
};

enum ENUM_ALERT_PRIORITY
{
    PRIORITY_LOW,               // Informational
    PRIORITY_MEDIUM,            // Important
    PRIORITY_HIGH,              // Critical
    PRIORITY_URGENT             // Immediate attention
};

enum ENUM_NOTIFICATION_CHANNEL
{
    CHANNEL_TERMINAL    = 1,    // MetaTrader terminal (2^0)
    CHANNEL_MOBILE      = 2,    // Mobile push notification (2^1)
    CHANNEL_EMAIL       = 4,    // Email notification (2^2)
    CHANNEL_SOUND       = 8,    // Sound alert (2^3)
    CHANNEL_POPUP       = 16,   // Windows popup (2^4)
    CHANNEL_FILE_LOG    = 32    // File logging (2^5)
};

// Define constant for all channels
#define CHANNEL_ALL_FLAGS (CHANNEL_TERMINAL | CHANNEL_MOBILE | CHANNEL_EMAIL | CHANNEL_SOUND | CHANNEL_POPUP | CHANNEL_FILE_LOG)

//+------------------------------------------------------------------+
//| Alert Configuration Structure                                   |
//+------------------------------------------------------------------+
struct SAlertConfig
{
    bool enabled;
    int channels;               // Changed to int for bitwise operations
    string sound_file;
    string email_subject_prefix;
    bool include_screenshot;
    bool include_chart_data;
    int max_alerts_per_hour;
    datetime last_alert_time;
    int alert_count_hour;
};

//+------------------------------------------------------------------+
//| Notification Manager Class                                      |
//+------------------------------------------------------------------+
class CNotificationManager
{
private:
    SAlertConfig m_alert_configs[10];
    string m_strategy_name;
    string m_symbol;
    bool m_notifications_enabled;
    string m_log_file_path;
    int m_daily_alert_count;
    datetime m_last_daily_reset;
    
public:
    // Constructor
    CNotificationManager(string strategy_name = "RSI_Strategy")
    {
        m_strategy_name = strategy_name;
        m_symbol = _Symbol;
        m_notifications_enabled = true;
        m_log_file_path = "RSI_Alerts_" + m_symbol + ".log";
        m_daily_alert_count = 0;
        m_last_daily_reset = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
        
        InitializeDefaultConfigs();
        
        Print("Notification Manager initialized for ", m_strategy_name);
    }
    
    // Initialize default alert configurations
    void InitializeDefaultConfigs()
    {
        // Trade Open Alerts
        m_alert_configs[ALERT_TRADE_OPEN].enabled = true;
        m_alert_configs[ALERT_TRADE_OPEN].channels = CHANNEL_ALL_FLAGS;
        m_alert_configs[ALERT_TRADE_OPEN].sound_file = "alert.wav";
        m_alert_configs[ALERT_TRADE_OPEN].email_subject_prefix = "[RSI] Trade Opened";
        m_alert_configs[ALERT_TRADE_OPEN].include_screenshot = true;
        m_alert_configs[ALERT_TRADE_OPEN].max_alerts_per_hour = 20;
        
        // Trade Close Alerts
        m_alert_configs[ALERT_TRADE_CLOSE].enabled = true;
        m_alert_configs[ALERT_TRADE_CLOSE].channels = CHANNEL_TERMINAL | CHANNEL_MOBILE;
        m_alert_configs[ALERT_TRADE_CLOSE].sound_file = "ok.wav";
        m_alert_configs[ALERT_TRADE_CLOSE].email_subject_prefix = "[RSI] Trade Closed";
        m_alert_configs[ALERT_TRADE_CLOSE].include_chart_data = true;
        m_alert_configs[ALERT_TRADE_CLOSE].max_alerts_per_hour = 20;
        
        // Signal Detection Alerts
        m_alert_configs[ALERT_SIGNAL_DETECTED].enabled = true;
        m_alert_configs[ALERT_SIGNAL_DETECTED].channels = CHANNEL_TERMINAL | CHANNEL_SOUND;
        m_alert_configs[ALERT_SIGNAL_DETECTED].sound_file = "news.wav";
        m_alert_configs[ALERT_SIGNAL_DETECTED].max_alerts_per_hour = 10;
        
        // Risk Warning Alerts
        m_alert_configs[ALERT_RISK_WARNING].enabled = true;
        m_alert_configs[ALERT_RISK_WARNING].channels = CHANNEL_ALL_FLAGS;
        m_alert_configs[ALERT_RISK_WARNING].sound_file = "timeout.wav";
        m_alert_configs[ALERT_RISK_WARNING].email_subject_prefix = "[URGENT] Risk Warning";
        m_alert_configs[ALERT_RISK_WARNING].include_screenshot = true;
        m_alert_configs[ALERT_RISK_WARNING].max_alerts_per_hour = 5;
        
        // Performance Update Alerts
        m_alert_configs[ALERT_PERFORMANCE_UPDATE].enabled = true;
        m_alert_configs[ALERT_PERFORMANCE_UPDATE].channels = CHANNEL_TERMINAL;
        m_alert_configs[ALERT_PERFORMANCE_UPDATE].max_alerts_per_hour = 4;
        
        // Error Alerts
        m_alert_configs[ALERT_ERROR].enabled = true;
        m_alert_configs[ALERT_ERROR].channels = CHANNEL_ALL_FLAGS;
        m_alert_configs[ALERT_ERROR].sound_file = "expert.wav";
        m_alert_configs[ALERT_ERROR].email_subject_prefix = "[ERROR] System Alert";
        m_alert_configs[ALERT_ERROR].max_alerts_per_hour = 3;
        
        // Daily Summary
        m_alert_configs[ALERT_DAILY_SUMMARY].enabled = true;
        m_alert_configs[ALERT_DAILY_SUMMARY].channels = CHANNEL_EMAIL | CHANNEL_FILE_LOG;
        m_alert_configs[ALERT_DAILY_SUMMARY].email_subject_prefix = "[RSI] Daily Summary";
        m_alert_configs[ALERT_DAILY_SUMMARY].include_chart_data = true;
        m_alert_configs[ALERT_DAILY_SUMMARY].max_alerts_per_hour = 1;
    }
    
    // Send alert
    bool SendAlert(ENUM_ALERT_TYPE alert_type, string message, ENUM_ALERT_PRIORITY priority = PRIORITY_MEDIUM, string additional_data = "")
    {
        if(!m_notifications_enabled) return false;
        
        // Check daily reset
        datetime current_day = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
        if(current_day != m_last_daily_reset)
        {
            m_daily_alert_count = 0;
            m_last_daily_reset = current_day;
            ResetHourlyCounters();
        }
        
        // Check if alert type is enabled
        if(!m_alert_configs[alert_type].enabled) return false;
        
        // Check rate limiting
        if(!CheckRateLimit(alert_type)) return false;
        
        // Format message
        string formatted_message = FormatAlertMessage(alert_type, message, priority, additional_data);
        
        // Send to configured channels
        bool result = true;
        int channels = m_alert_configs[alert_type].channels;
        
        if((channels & CHANNEL_TERMINAL) != 0)
            result &= SendTerminalAlert(formatted_message, priority);
            
        if((channels & CHANNEL_MOBILE) != 0)
            result &= SendMobileAlert(formatted_message);
            
        if((channels & CHANNEL_EMAIL) != 0)
            result &= SendEmailAlert(alert_type, formatted_message, additional_data);
            
        if((channels & CHANNEL_SOUND) != 0)
            result &= PlaySoundAlert(alert_type);
            
        if((channels & CHANNEL_POPUP) != 0)
            result &= ShowPopupAlert(formatted_message, priority);
            
        if((channels & CHANNEL_FILE_LOG) != 0)
            result &= LogToFile(formatted_message);
        
        // Update counters
        m_alert_configs[alert_type].alert_count_hour++;
        m_alert_configs[alert_type].last_alert_time = TimeCurrent();
        m_daily_alert_count++;
        
        return result;
    }
    
    // Specialized alert methods
    bool AlertTradeOpened(string strategy_name, double price, double volume, double rsi_value, string signal_details = "")
    {
        string message = StringFormat("TRADE OPENED\nStrategy: %s\nSymbol: %s\nPrice: %s\nVolume: %.2f\nRSI: %.2f\n%s",
            strategy_name, m_symbol, DoubleToString(price, _Digits), volume, rsi_value, signal_details);
            
        string additional_data = StringFormat("Price=%s;Volume=%.2f;RSI=%.2f", 
            DoubleToString(price, _Digits), volume, rsi_value);
            
        return SendAlert(ALERT_TRADE_OPEN, message, PRIORITY_HIGH, additional_data);
    }
    
    bool AlertTradeClosed(string strategy_name, double open_price, double close_price, double profit, double profit_percent, string exit_reason = "")
    {
        string profit_status = (profit > 0) ? "PROFIT" : "LOSS";
        color profit_color = (profit > 0) ? clrGreen : clrRed;
        
        string message = StringFormat("TRADE CLOSED - %s\nStrategy: %s\nSymbol: %s\nOpen: %s\nClose: %s\nProfit: $%.2f (%.2f%%)\nReason: %s",
            profit_status, strategy_name, m_symbol, 
            DoubleToString(open_price, _Digits), DoubleToString(close_price, _Digits),
            profit, profit_percent, exit_reason);
            
        string additional_data = StringFormat("Profit=%.2f;Percent=%.2f;Reason=%s", profit, profit_percent, exit_reason);
        
        ENUM_ALERT_PRIORITY priority = (profit > 0) ? PRIORITY_MEDIUM : PRIORITY_HIGH;
        
        return SendAlert(ALERT_TRADE_CLOSE, message, priority, additional_data);
    }
    
    bool AlertSignalDetected(string strategy_name, double rsi_value, string signal_type, string conditions = "")
    {
        string message = StringFormat("SIGNAL DETECTED\nStrategy: %s\nSymbol: %s\nSignal: %s\nRSI: %.2f\nConditions: %s",
            strategy_name, m_symbol, signal_type, rsi_value, conditions);
            
        return SendAlert(ALERT_SIGNAL_DETECTED, message, PRIORITY_MEDIUM);
    }
    
    bool AlertRiskWarning(string warning_type, string details, double current_drawdown = 0, double risk_level = 0)
    {
        string message = StringFormat("RISK WARNING\nType: %s\nSymbol: %s\nDetails: %s\nDrawdown: %.2f%%\nRisk Level: %.2f%%",
            warning_type, m_symbol, details, current_drawdown, risk_level * 100);
            
        return SendAlert(ALERT_RISK_WARNING, message, PRIORITY_URGENT);
    }
    
    bool AlertPerformanceUpdate(int total_trades, double win_rate, double profit_factor, double net_profit, double max_drawdown)
    {
        string message = StringFormat("PERFORMANCE UPDATE\nStrategy: %s\nSymbol: %s\nTrades: %d\nWin Rate: %.1f%%\nProfit Factor: %.2f\nNet Profit: $%.2f\nMax Drawdown: %.1f%%",
            m_strategy_name, m_symbol, total_trades, win_rate, profit_factor, net_profit, max_drawdown);
            
        return SendAlert(ALERT_PERFORMANCE_UPDATE, message, PRIORITY_LOW);
    }
    
    bool AlertDailySummary(string summary_data)
    {
        string message = StringFormat("DAILY SUMMARY - %s\nStrategy: %s\nSymbol: %s\n%s",
            TimeToString(TimeCurrent(), TIME_DATE), m_strategy_name, m_symbol, summary_data);
            
        return SendAlert(ALERT_DAILY_SUMMARY, message, PRIORITY_LOW, summary_data);
    }
    
    bool AlertError(string error_type, string error_message, int error_code = 0)
    {
        string message = StringFormat("SYSTEM ERROR\nType: %s\nMessage: %s\nCode: %d\nStrategy: %s\nSymbol: %s",
            error_type, error_message, error_code, m_strategy_name, m_symbol);
            
        return SendAlert(ALERT_ERROR, message, PRIORITY_URGENT);
    }
    
    // Configuration methods
    void EnableAlert(ENUM_ALERT_TYPE alert_type, bool enable = true)
    {
        m_alert_configs[alert_type].enabled = enable;
    }
    
    void SetAlertChannels(ENUM_ALERT_TYPE alert_type, int channels)
    {
        m_alert_configs[alert_type].channels = channels;
    }
    
    void SetSoundFile(ENUM_ALERT_TYPE alert_type, string sound_file)
    {
        m_alert_configs[alert_type].sound_file = sound_file;
    }
    
    void EnableNotifications(bool enable = true)
    {
        m_notifications_enabled = enable;
        Print("Notifications ", enable ? "enabled" : "disabled");
    }
    
private:
    // Format alert message
    string FormatAlertMessage(ENUM_ALERT_TYPE alert_type, string message, ENUM_ALERT_PRIORITY priority, string additional_data)
    {
        string priority_text = "";
        switch(priority)
        {
            case PRIORITY_LOW: priority_text = "[INFO]"; break;
            case PRIORITY_MEDIUM: priority_text = "[IMPORTANT]"; break;
            case PRIORITY_HIGH: priority_text = "[HIGH]"; break;
            case PRIORITY_URGENT: priority_text = "[URGENT]"; break;
        }
        
        string timestamp = TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS);
        
        return StringFormat("%s %s - %s\n%s", timestamp, priority_text, EnumToString(alert_type), message);
    }
    
    // Check rate limiting
    bool CheckRateLimit(ENUM_ALERT_TYPE alert_type)
    {
        datetime current_time = TimeCurrent();
        datetime hour_ago = current_time - 3600;
        
        if(m_alert_configs[alert_type].last_alert_time < hour_ago)
        {
            m_alert_configs[alert_type].alert_count_hour = 0;
        }
        
        return m_alert_configs[alert_type].alert_count_hour < m_alert_configs[alert_type].max_alerts_per_hour;
    }
    
    // Reset hourly counters
    void ResetHourlyCounters()
    {
        for(int i = 0; i < 10; i++)
        {
            m_alert_configs[i].alert_count_hour = 0;
        }
    }
    
    // Send terminal alert
    bool SendTerminalAlert(string message, ENUM_ALERT_PRIORITY priority)
    {
        color msg_color = clrWhite;
        switch(priority)
        {
            case PRIORITY_LOW: msg_color = clrLightBlue; break;
            case PRIORITY_MEDIUM: msg_color = clrYellow; break;
            case PRIORITY_HIGH: msg_color = clrOrange; break;
            case PRIORITY_URGENT: msg_color = clrRed; break;
        }
        
        Print(message);
        Comment(message); // Show on chart
        
        return true;
    }
    
    // Send mobile alert
    bool SendMobileAlert(string message)
    {
        return SendNotification(StringSubstr(message, 0, 255)); // Mobile notifications have character limit
    }
    
    // Send email alert
    bool SendEmailAlert(ENUM_ALERT_TYPE alert_type, string message, string additional_data)
    {
        string subject = m_alert_configs[alert_type].email_subject_prefix + " - " + m_symbol;
        
        string body = message + "\n\n";
        body += "Timestamp: " + TimeToString(TimeCurrent()) + "\n";
        body += "Account: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\n";
        body += "Balance: $" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "\n";
        
        if(additional_data != "")
        {
            body += "\nAdditional Data:\n" + additional_data;
        }
        
        return SendMail(subject, body);
    }
    
    // Play sound alert
    bool PlaySoundAlert(ENUM_ALERT_TYPE alert_type)
    {
        string sound_file = m_alert_configs[alert_type].sound_file;
        if(sound_file != "")
        {
            PlaySound(sound_file);
            return true;
        }
        return false;
    }
    
    // Show popup alert
    bool ShowPopupAlert(string message, ENUM_ALERT_PRIORITY priority)
    {
        int msg_type = 0; // MB_OK
        
        switch(priority)
        {
            case PRIORITY_URGENT: msg_type = 16; break; // MB_ICONERROR
            case PRIORITY_HIGH: msg_type = 48; break;   // MB_ICONEXCLAMATION
            case PRIORITY_MEDIUM: msg_type = 64; break; // MB_ICONINFORMATION
            case PRIORITY_LOW: msg_type = 64; break;    // MB_ICONINFORMATION
        }
        
        string title = "RSI Strategy Alert - " + m_symbol;
        
        return MessageBoxW(0, message, title, msg_type) > 0;
    }
    
    // Log to file
    bool LogToFile(string message)
    {
        int file_handle = FileOpen(m_log_file_path, FILE_WRITE | FILE_READ | FILE_TXT | FILE_COMMON);
        
        if(file_handle != INVALID_HANDLE)
        {
            FileSeek(file_handle, 0, SEEK_END); // Go to end of file
            FileWriteString(file_handle, message + "\n");
            FileClose(file_handle);
            return true;
        }
        
        return false;
    }
};

//+------------------------------------------------------------------+
//| Global notification manager instance                            |
//+------------------------------------------------------------------+
CNotificationManager* g_notification_manager = NULL;

//+------------------------------------------------------------------+
//| Initialize notification manager                                 |
//+------------------------------------------------------------------+
bool InitNotificationManager(string strategy_name = "RSI_Strategy")
{
    if(g_notification_manager == NULL)
    {
        g_notification_manager = new CNotificationManager(strategy_name);
        return (g_notification_manager != NULL);
    }
    return true;
}

//+------------------------------------------------------------------+
//| Cleanup notification manager                                   |
//+------------------------------------------------------------------+
void DeinitNotificationManager()
{
    if(g_notification_manager != NULL)
    {
        delete g_notification_manager;
        g_notification_manager = NULL;
    }
}

//+------------------------------------------------------------------+
//| Get global notification manager                                |
//+------------------------------------------------------------------+
CNotificationManager* GetNotificationManager()
{
    return g_notification_manager;
}

//+------------------------------------------------------------------+
//| Quick alert functions for easy use                             |
//+------------------------------------------------------------------+
bool QuickAlertTradeOpen(string strategy, double price, double volume, double rsi)
{
    if(g_notification_manager != NULL)
        return g_notification_manager.AlertTradeOpened(strategy, price, volume, rsi);
    return false;
}

bool QuickAlertTradeClose(string strategy, double open_price, double close_price, double profit, double profit_percent, string reason = "")
{
    if(g_notification_manager != NULL)
        return g_notification_manager.AlertTradeClosed(strategy, open_price, close_price, profit, profit_percent, reason);
    return false;
}

bool QuickAlertSignal(string strategy, double rsi, string signal_type)
{
    if(g_notification_manager != NULL)
        return g_notification_manager.AlertSignalDetected(strategy, rsi, signal_type);
    return false;
}

bool QuickAlertRisk(string warning, string details, double drawdown = 0)
{
    if(g_notification_manager != NULL)
        return g_notification_manager.AlertRiskWarning(warning, details, drawdown);
    return false;
}

bool QuickAlertError(string error_type, string message, int code = 0)
{
    if(g_notification_manager != NULL)
        return g_notification_manager.AlertError(error_type, message, code);
    return false;
}
