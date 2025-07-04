//+------------------------------------------------------------------+
//| Real-Time Performance Dashboard                                  |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Live performance monitoring with visual dashboard  |
//|              and real-time statistics display                   |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"
#property description "Real-time performance dashboard for RSI strategies"
#property indicator_separate_window
#property indicator_buffers 0
#property indicator_plots   0

#include "PerformanceMonitor.mqh"
#include "NotificationManager.mqh"

//--- Input Parameters
input group "=== Dashboard Settings ==="
input bool               InpShowDashboard = true;       // Show Performance Dashboard
input int                InpUpdateInterval = 5;         // Update Interval (seconds)
input bool               InpShowDetailedStats = true;   // Show Detailed Statistics
input bool               InpShowEquityCurve = true;     // Show Equity Curve
input bool               InpShowRiskMetrics = true;     // Show Risk Metrics

input group "=== Display Options ==="
input color              InpBackgroundColor = C'25,25,25';    // Dashboard Background
input color              InpTextColor = clrWhite;             // Text Color
input color              InpProfitColor = clrLimeGreen;       // Profit Color
input color              InpLossColor = clrCrimson;           // Loss Color
input color              InpNeutralColor = clrGray;           // Neutral Color
input int                InpFontSize = 10;                    // Font Size

input group "=== Alert Thresholds ==="
input double             InpProfitAlertThreshold = 1000.0;    // Profit Alert Threshold
input double             InpLossAlertThreshold = -500.0;      // Loss Alert Threshold
input double             InpDrawdownAlertThreshold = 10.0;    // Drawdown Alert Threshold (%)

//--- Global Variables
CPerformanceMonitor* g_dashboard_monitor;
CNotificationManager* g_dashboard_notifications;

datetime g_last_update = 0;
double g_last_balance = 0;
double g_session_start_balance = 0;
double g_daily_start_balance = 0;
datetime g_session_start_time = 0;
datetime g_daily_start_time = 0;

// Dashboard display coordinates
int g_dashboard_x = 20;
int g_dashboard_y = 30;
int g_line_height = 18;
int g_dashboard_width = 400;
int g_dashboard_height = 600;

// Performance tracking arrays
double g_equity_curve[];
datetime g_equity_times[];
int g_equity_points = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("=== Initializing Real-Time Performance Dashboard ===");
    
    // Initialize performance monitor
    g_dashboard_monitor = new CPerformanceMonitor("Dashboard_Monitor");
    g_dashboard_notifications = new CNotificationManager("Dashboard");
    
    if(g_dashboard_monitor == NULL || g_dashboard_notifications == NULL)
    {
        Print("ERROR: Failed to initialize dashboard components");
        return INIT_FAILED;
    }
    
    // Initialize session tracking
    g_session_start_time = TimeCurrent();
    g_daily_start_time = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    g_session_start_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    g_daily_start_balance = g_session_start_balance;
    g_last_balance = g_session_start_balance;
    
    // Initialize equity curve
    ArrayResize(g_equity_curve, 10000);
    ArrayResize(g_equity_times, 10000);
    g_equity_points = 0;
    
    // Set timer for updates
    EventSetTimer(InpUpdateInterval);
    
    // Create initial dashboard
    if(InpShowDashboard)
    {
        CreateDashboard();
    }
    
    Print("Dashboard initialized successfully");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("=== Deinitializing Performance Dashboard ===");
    
    EventKillTimer();
    
    // Final performance report
    if(g_dashboard_monitor != NULL)
    {
        g_dashboard_monitor.PrintPerformanceReport();
        delete g_dashboard_monitor;
    }
    
    if(g_dashboard_notifications != NULL)
    {
        delete g_dashboard_notifications;
    }
    
    // Clean up dashboard objects
    DeleteDashboard();
    
    Print("Dashboard deinitialized");
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
    if(!InpShowDashboard) return;
    
    // Update dashboard data
    UpdateDashboardData();
    
    // Refresh dashboard display
    UpdateDashboard();
    
    // Check alert conditions
    CheckAlertConditions();
    
    g_last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Update dashboard data                                            |
//+------------------------------------------------------------------+
void UpdateDashboardData()
{
    double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    // Update equity curve
    if(g_equity_points < ArraySize(g_equity_curve))
    {
        g_equity_curve[g_equity_points] = current_equity;
        g_equity_times[g_equity_points] = TimeCurrent();
        g_equity_points++;
    }
    
    // Check for new trades
    if(current_balance != g_last_balance)
    {
        double trade_result = current_balance - g_last_balance;
        g_dashboard_monitor.UpdateTrade(trade_result);
        g_last_balance = current_balance;
        
        // Send trade notification
        if(g_dashboard_notifications != NULL)
        {
            string message = StringFormat("Trade Result: $%.2f", trade_result);
            if(trade_result > 0)
                g_dashboard_notifications.AlertTradeOpened("Dashboard", current_balance, 0, 0, message);
            else
                g_dashboard_notifications.AlertTradeClosed("Dashboard", 0, 0, trade_result, (trade_result/g_last_balance)*100, "Auto-detected");
        }
    }
    
    // Reset daily tracking if new day
    datetime current_day = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
    if(current_day != StringToTime(TimeToString(g_daily_start_time, TIME_DATE)))
    {
        g_daily_start_time = current_day;
        g_daily_start_balance = current_balance;
    }
}

//+------------------------------------------------------------------+
//| Create dashboard visual elements                                |
//+------------------------------------------------------------------+
void CreateDashboard()
{
    // Create background rectangle
    if(ObjectFind(0, "Dashboard_Background") < 0)
    {
        ObjectCreate(0, "Dashboard_Background", OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, "Dashboard_Background", OBJPROP_XDISTANCE, g_dashboard_x - 10);
        ObjectSetInteger(0, "Dashboard_Background", OBJPROP_YDISTANCE, g_dashboard_y - 10);
        ObjectSetInteger(0, "Dashboard_Background", OBJPROP_XSIZE, g_dashboard_width);
        ObjectSetInteger(0, "Dashboard_Background", OBJPROP_YSIZE, g_dashboard_height);
        ObjectSetInteger(0, "Dashboard_Background", OBJPROP_BGCOLOR, InpBackgroundColor);
        ObjectSetInteger(0, "Dashboard_Background", OBJPROP_BORDER_COLOR, clrDarkGray);
        ObjectSetInteger(0, "Dashboard_Background", OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, "Dashboard_Background", OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, "Dashboard_Background", OBJPROP_BACK, false);
    }
    
    // Create title
    CreateDashboardLabel("Dashboard_Title", "RSI STRATEGY PERFORMANCE DASHBOARD", 0, clrYellow, 12, true);
    
    Print("Dashboard visual elements created");
}

//+------------------------------------------------------------------+
//| Update dashboard display                                        |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
    double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double current_margin = AccountInfoDouble(ACCOUNT_MARGIN);
    double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    double margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
    
    // Calculate session and daily performance
    double session_pnl = current_balance - g_session_start_balance;
    double session_pnl_percent = (g_session_start_balance > 0) ? (session_pnl / g_session_start_balance) * 100 : 0;
    double daily_pnl = current_balance - g_daily_start_balance;
    double daily_pnl_percent = (g_daily_start_balance > 0) ? (daily_pnl / g_daily_start_balance) * 100 : 0;
    
    // Calculate session duration
    int session_seconds = (int)(TimeCurrent() - g_session_start_time);
    int session_hours = session_seconds / 3600;
    int session_minutes = (session_seconds % 3600) / 60;
    
    int line = 2; // Start after title
    
    // === ACCOUNT INFORMATION ===
    CreateDashboardLabel("Dashboard_Section1", "=== ACCOUNT INFORMATION ===", line++, clrCyan, InpFontSize, true);
    line++;
    
    CreateDashboardLabel("Dashboard_Balance", "Balance: $" + DoubleToString(current_balance, 2), line++, InpTextColor);
    CreateDashboardLabel("Dashboard_Equity", "Equity: $" + DoubleToString(current_equity, 2), line++, InpTextColor);
    CreateDashboardLabel("Dashboard_Margin", "Margin: $" + DoubleToString(current_margin, 2), line++, InpTextColor);
    CreateDashboardLabel("Dashboard_FreeMargin", "Free Margin: $" + DoubleToString(free_margin, 2), line++, InpTextColor);
    CreateDashboardLabel("Dashboard_MarginLevel", "Margin Level: " + DoubleToString(margin_level, 1) + "%", line++, InpTextColor);
    line++;
    
    // === SESSION PERFORMANCE ===
    CreateDashboardLabel("Dashboard_Section2", "=== SESSION PERFORMANCE ===", line++, clrCyan, InpFontSize, true);
    line++;
    
    color session_color = (session_pnl >= 0) ? InpProfitColor : InpLossColor;
    CreateDashboardLabel("Dashboard_SessionPnL", "Session P&L: $" + DoubleToString(session_pnl, 2) + 
                        " (" + DoubleToString(session_pnl_percent, 2) + "%)", line++, session_color);
    
    CreateDashboardLabel("Dashboard_SessionTime", "Session Time: " + IntegerToString(session_hours) + "h " + 
                        IntegerToString(session_minutes) + "m", line++, InpTextColor);
    line++;
    
    // === DAILY PERFORMANCE ===
    CreateDashboardLabel("Dashboard_Section3", "=== DAILY PERFORMANCE ===", line++, clrCyan, InpFontSize, true);
    line++;
    
    color daily_color = (daily_pnl >= 0) ? InpProfitColor : InpLossColor;
    CreateDashboardLabel("Dashboard_DailyPnL", "Daily P&L: $" + DoubleToString(daily_pnl, 2) + 
                        " (" + DoubleToString(daily_pnl_percent, 2) + "%)", line++, daily_color);
    line++;
    
    // === STRATEGY STATISTICS ===
    if(InpShowDetailedStats && g_dashboard_monitor != NULL)
    {
        CreateDashboardLabel("Dashboard_Section4", "=== STRATEGY STATISTICS ===", line++, clrCyan, InpFontSize, true);
        line++;
        
        int total_trades = g_dashboard_monitor.GetTotalTrades();
        double win_rate = g_dashboard_monitor.GetWinRate();
        double max_drawdown = g_dashboard_monitor.GetMaxDrawdown();
        double net_profit = g_dashboard_monitor.GetNetProfit();
        
        CreateDashboardLabel("Dashboard_TotalTrades", "Total Trades: " + IntegerToString(total_trades), line++, InpTextColor);
        
        color wr_color = (win_rate >= 70) ? InpProfitColor : (win_rate >= 50) ? InpNeutralColor : InpLossColor;
        CreateDashboardLabel("Dashboard_WinRate", "Win Rate: " + DoubleToString(win_rate, 1) + "%", line++, wr_color);
        
        color dd_color = (max_drawdown <= 5) ? InpProfitColor : (max_drawdown <= 15) ? InpNeutralColor : InpLossColor;
        CreateDashboardLabel("Dashboard_MaxDD", "Max Drawdown: " + DoubleToString(max_drawdown, 1) + "%", line++, dd_color);
        
        color np_color = (net_profit >= 0) ? InpProfitColor : InpLossColor;
        CreateDashboardLabel("Dashboard_NetProfit", "Net Profit: $" + DoubleToString(net_profit, 2), line++, np_color);
        line++;
    }
    
    // === RISK METRICS ===
    if(InpShowRiskMetrics)
    {
        CreateDashboardLabel("Dashboard_Section5", "=== RISK METRICS ===", line++, clrCyan, InpFontSize, true);
        line++;
        
        double drawdown_percent = (current_balance < g_session_start_balance) ? 
                                 ((g_session_start_balance - current_balance) / g_session_start_balance) * 100 : 0;
        
        color risk_color = (drawdown_percent <= 2) ? InpProfitColor : 
                          (drawdown_percent <= 5) ? InpNeutralColor : InpLossColor;
        
        CreateDashboardLabel("Dashboard_CurrentDD", "Current Drawdown: " + DoubleToString(drawdown_percent, 2) + "%", line++, risk_color);
        
        // Risk level assessment
        string risk_level = "LOW";
        color risk_level_color = InpProfitColor;
        
        if(drawdown_percent > 10)
        {
            risk_level = "HIGH";
            risk_level_color = InpLossColor;
        }
        else if(drawdown_percent > 5)
        {
            risk_level = "MEDIUM";
            risk_level_color = clrOrange;
        }
        
        CreateDashboardLabel("Dashboard_RiskLevel", "Risk Level: " + risk_level, line++, risk_level_color);
        line++;
    }
    
    // === MARKET STATUS ===
    CreateDashboardLabel("Dashboard_Section6", "=== MARKET STATUS ===", line++, clrCyan, InpFontSize, true);
    line++;
    
    CreateDashboardLabel("Dashboard_Symbol", "Symbol: " + _Symbol, line++, InpTextColor);
    CreateDashboardLabel("Dashboard_Spread", "Spread: " + DoubleToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), 0) + " pts", line++, InpTextColor);
    
    bool market_open = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;
    color market_color = market_open ? InpProfitColor : InpLossColor;
    string market_status = market_open ? "OPEN" : "CLOSED";
    CreateDashboardLabel("Dashboard_MarketStatus", "Market: " + market_status, line++, market_color);
    line++;
    
    // === LAST UPDATE ===
    CreateDashboardLabel("Dashboard_LastUpdate", "Last Update: " + TimeToString(TimeCurrent(), TIME_MINUTES | TIME_SECONDS), line++, clrGray);
    
    // Force chart redraw
    ChartRedraw();
}

//+------------------------------------------------------------------+
//| Create dashboard label                                          |
//+------------------------------------------------------------------+
void CreateDashboardLabel(string name, string text, int line, color clr = clrWhite, int font_size = 0, bool bold = false)
{
    if(font_size == 0) font_size = InpFontSize;
    
    if(ObjectFind(0, name) < 0)
    {
        ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    }
    
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, g_dashboard_x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, g_dashboard_y + (line * g_line_height));
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
    
    string font_name = bold ? "Arial Bold" : "Arial";
    ObjectSetString(0, name, OBJPROP_FONT, font_name);
}

//+------------------------------------------------------------------+
//| Check alert conditions                                          |
//+------------------------------------------------------------------+
void CheckAlertConditions()
{
    if(g_dashboard_notifications == NULL) return;
    
    double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double session_pnl = current_balance - g_session_start_balance;
    double session_drawdown = (current_balance < g_session_start_balance) ? 
                             ((g_session_start_balance - current_balance) / g_session_start_balance) * 100 : 0;
    
    // Profit alert
    if(session_pnl >= InpProfitAlertThreshold)
    {
        static datetime last_profit_alert = 0;
        if(TimeCurrent() - last_profit_alert > 3600) // Once per hour
        {
            g_dashboard_notifications.AlertPerformanceUpdate(
                g_dashboard_monitor.GetTotalTrades(),
                g_dashboard_monitor.GetWinRate(),
                0, session_pnl, session_drawdown);
            last_profit_alert = TimeCurrent();
        }
    }
    
    // Loss alert
    if(session_pnl <= InpLossAlertThreshold)
    {
        static datetime last_loss_alert = 0;
        if(TimeCurrent() - last_loss_alert > 1800) // Once per 30 minutes
        {
            g_dashboard_notifications.AlertRiskWarning("Session Loss Alert", 
                "Session P&L has reached alert threshold", session_drawdown);
            last_loss_alert = TimeCurrent();
        }
    }
    
    // Drawdown alert
    if(session_drawdown >= InpDrawdownAlertThreshold)
    {
        static datetime last_dd_alert = 0;
        if(TimeCurrent() - last_dd_alert > 900) // Once per 15 minutes
        {
            g_dashboard_notifications.AlertRiskWarning("Drawdown Alert", 
                "Maximum session drawdown exceeded", session_drawdown);
            last_dd_alert = TimeCurrent();
        }
    }
}

//+------------------------------------------------------------------+
//| Delete dashboard elements                                       |
//+------------------------------------------------------------------+
void DeleteDashboard()
{
    ObjectsDeleteAll(0, "Dashboard_");
    Print("Dashboard elements deleted");
}

//+------------------------------------------------------------------+
//| Custom indicator calculation function                           |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    // This indicator doesn't plot anything in the main window
    // All display is handled by the dashboard objects
    return rates_total;
}

//+------------------------------------------------------------------+
//| Chart event handler                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if(id == CHARTEVENT_CLICK)
    {
        // Handle dashboard click events
        if(StringFind(sparam, "Dashboard_") >= 0)
        {
            // Toggle detailed view or perform action based on clicked element
            Print("Dashboard element clicked: ", sparam);
        }
    }
}

//+------------------------------------------------------------------+
//| Get current session statistics                                 |
//+------------------------------------------------------------------+
string GetSessionSummary()
{
    double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double session_pnl = current_balance - g_session_start_balance;
    double session_pnl_percent = (g_session_start_balance > 0) ? (session_pnl / g_session_start_balance) * 100 : 0;
    
    int session_seconds = (int)(TimeCurrent() - g_session_start_time);
    int session_hours = session_seconds / 3600;
    int session_minutes = (session_seconds % 3600) / 60;
    
    string summary = StringFormat(
        "Session Summary:\n" +
        "Duration: %dh %dm\n" +
        "P&L: $%.2f (%.2f%%)\n" +
        "Trades: %d\n" +
        "Win Rate: %.1f%%",
        session_hours, session_minutes,
        session_pnl, session_pnl_percent,
        g_dashboard_monitor.GetTotalTrades(),
        g_dashboard_monitor.GetWinRate()
    );
    
    return summary;
}

//+------------------------------------------------------------------+
//| Export session data                                            |
//+------------------------------------------------------------------+
void ExportSessionData()
{
    string filename = "Dashboard_Session_" + TimeToString(TimeCurrent(), TIME_DATE) + ".txt";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    
    if(file_handle != INVALID_HANDLE)
    {
        FileWriteString(file_handle, "RSI Strategy Performance Dashboard Session Report\n");
        FileWriteString(file_handle, "==============================================\n");
        FileWriteString(file_handle, "Generated: " + TimeToString(TimeCurrent()) + "\n\n");
        
        FileWriteString(file_handle, GetSessionSummary() + "\n\n");
        
        // Add detailed performance data if available
        if(g_dashboard_monitor != NULL)
        {
            FileWriteString(file_handle, "Detailed Statistics:\n");
            FileWriteString(file_handle, "Max Drawdown: " + DoubleToString(g_dashboard_monitor.GetMaxDrawdown(), 2) + "%\n");
            FileWriteString(file_handle, "Net Profit: $" + DoubleToString(g_dashboard_monitor.GetNetProfit(), 2) + "\n");
        }
        
        FileClose(file_handle);
        Print("Session data exported to: ", filename);
    }
}
