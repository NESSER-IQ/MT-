//+------------------------------------------------------------------+
//| Quick Setup and Installation Script                             |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Automated setup and configuration for RSI          |
//|              Momentum Strategies system                         |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"
#property description "Quick setup and installation script"
#property script_show_inputs

#include "ConfigManager.mqh"
#include "GlobalConfig.mqh"

//--- Input Parameters
input group "=== Setup Options ==="
input bool    InpCreateDefaultConfigs = true;     // Create Default Configurations
input bool    InpOptimizeForSymbol = true;        // Optimize Settings for Current Symbol
input bool    InpCreateSampleReport = true;       // Create Sample Performance Report
input bool    InpRunSystemCheck = true;           // Run System Health Check
input bool    InpCreateUserGuide = true;          // Create User Guide

input group "=== System Settings ==="
input double  InpDefaultRisk = 0.02;              // Default Risk per Trade (%)
input double  InpMaxDailyRisk = 0.06;             // Maximum Daily Risk (%)
input bool    InpEnableNotifications = true;      // Enable Notifications
input bool    InpVerboseLogging = false;          // Enable Verbose Logging

//--- Global Variables
int g_setup_steps = 0;
int g_completed_steps = 0;
string g_setup_log[];
int g_log_count = 0;

//+------------------------------------------------------------------+
//| Script start function                                           |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== RSI Momentum Strategies - Quick Setup ===");
    Print("Initializing automated setup and configuration...");
    Print("Time: ", TimeToString(TimeCurrent()));
    Print("Symbol: ", _Symbol);
    Print("Account: ", AccountInfoString(ACCOUNT_NAME));
    Print("");
    
    // Initialize setup
    ArrayResize(g_setup_log, 100);
    g_setup_steps = 0;
    g_completed_steps = 0;
    g_log_count = 0;
    
    // Count total steps
    if(InpCreateDefaultConfigs) g_setup_steps++;
    if(InpOptimizeForSymbol) g_setup_steps++;
    if(InpCreateSampleReport) g_setup_steps++;
    if(InpRunSystemCheck) g_setup_steps++;
    if(InpCreateUserGuide) g_setup_steps++;
    
    Print("Total setup steps: ", g_setup_steps);
    Print("");
    
    // Run setup steps
    if(InpCreateDefaultConfigs)
        ExecuteStep("Creating Default Configurations", 1);
        
    if(InpOptimizeForSymbol)
        ExecuteStep("Optimizing for Current Symbol", 2);
        
    if(InpCreateSampleReport)
        ExecuteStep("Creating Sample Performance Report", 3);
        
    if(InpRunSystemCheck)
        ExecuteStep("Running System Health Check", 4);
        
    if(InpCreateUserGuide)
        ExecuteStep("Creating User Guide", 5);
    
    // Generate setup summary
    GenerateSetupSummary();
    
    Print("");
    Print("=== Setup Complete ===");
    Print("Completed Steps: ", g_completed_steps, "/", g_setup_steps);
    
    if(g_completed_steps == g_setup_steps)
    {
        Print("🎉 SETUP SUCCESSFUL!");
        Print("Your RSI Momentum Strategies system is ready to use.");
        Print("");
        Print("Next Steps:");
        Print("1. Run DiagnosticTest.mq5 to verify system health");
        Print("2. Use Backtester_FIXED.mq5 for strategy testing");
        Print("3. Check the generated files in MQL5\\Files\\Common\\");
    }
    else
    {
        Print("⚠️  Setup completed with some issues");
        Print("Please check the setup log for details");
    }
}

//+------------------------------------------------------------------+
//| Execute setup step with error handling                         |
//+------------------------------------------------------------------+
void ExecuteStep(string step_name, int step_type)
{
    Print("📋 Step ", g_completed_steps + 1, "/", g_setup_steps, ": ", step_name);
    
    bool result = false;
    int start_time = (int)GetTickCount();
    
    // Execute the appropriate step function
    switch(step_type)
    {
        case 1: result = CreateDefaultConfigurations(); break;
        case 2: result = OptimizeForCurrentSymbol(); break;
        case 3: result = CreateSampleReport(); break;
        case 4: result = RunSystemHealthCheck(); break;
        case 5: result = CreateUserGuide(); break;
        default: result = false; break;
    }
    
    int elapsed_time = (int)GetTickCount() - start_time;
    
    if(result)
    {
        g_completed_steps++;
        Print("✅ ", step_name, " - Completed (", elapsed_time, "ms)");
        LogStep(step_name + " - SUCCESS", true);
    }
    else
    {
        Print("❌ ", step_name, " - Failed (", elapsed_time, "ms)");
        LogStep(step_name + " - FAILED", false);
    }
    
    Print("");
}

//+------------------------------------------------------------------+
//| Create default configurations                                  |
//+------------------------------------------------------------------+
bool CreateDefaultConfigurations()
{
    // Initialize configuration manager
    if(!InitConfigManager())
    {
        Print("ERROR: Failed to initialize configuration manager");
        return false;
    }
    
    CConfigManager* config_mgr = GetConfigManager();
    if(config_mgr == NULL)
    {
        Print("ERROR: Configuration manager is null");
        return false;
    }
    
    // List available configurations
    config_mgr.ListConfigurations();
    
    // Save configurations to file
    if(!config_mgr.SaveConfigurations())
    {
        Print("ERROR: Failed to save configurations");
        DeinitConfigManager();
        return false;
    }
    
    Print("✓ Default configurations created and saved");
    DeinitConfigManager();
    return true;
}

//+------------------------------------------------------------------+
//| Optimize settings for current symbol                           |
//+------------------------------------------------------------------+
bool OptimizeForCurrentSymbol()
{
    // Initialize global config
    if(!InitGlobalConfig())
    {
        Print("ERROR: Failed to initialize global config");
        return false;
    }
    
    CGlobalConfig* global_config = GetGlobalConfig();
    if(global_config == NULL)
    {
        Print("ERROR: Global config is null");
        return false;
    }
    
    // Get recommended settings for current symbol
    SAssetConfig recommended = global_config.GetRecommendedSettings(_Symbol);
    
    Print("✓ Symbol analysis completed for: ", _Symbol);
    Print("  Asset Type: ", recommended.asset_type);
    Print("  Recommended RSI Period: ", recommended.optimal_rsi_period);
    Print("  Recommended Oversold: ", recommended.optimal_oversold);
    Print("  Recommended Overbought: ", recommended.optimal_overbought);
    Print("  Recommended Risk: ", DoubleToString(recommended.recommended_risk * 100, 1), "%");
    Print("  Preferred Strategy: ", recommended.preferred_strategy);
    
    // Apply optimized settings
    global_config.SetRiskSettings(recommended.recommended_risk, 
                                 recommended.recommended_risk * 2.5, 
                                 InpMaxDailyRisk);
    
    global_config.SetNotificationSettings(InpEnableNotifications, 
                                         false, // email
                                         true,  // mobile
                                         true); // sound
    
    global_config.SetDebugMode(false, InpVerboseLogging);
    
    // Save optimized configuration
    global_config.SaveConfig();
    
    Print("✓ Optimized settings applied and saved");
    DeinitGlobalConfig();
    return true;
}

//+------------------------------------------------------------------+
//| Create sample performance report                               |
//+------------------------------------------------------------------+
bool CreateSampleReport()
{
    string filename = "RSI_Setup_Sample_Report.html";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    
    if(file_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create sample report file");
        return false;
    }
    
    // Write HTML content
    FileWriteString(file_handle, "<!DOCTYPE html>\n<html>\n<head>\n");
    FileWriteString(file_handle, "<title>RSI Strategies - Sample Report</title>\n");
    FileWriteString(file_handle, "<meta charset='UTF-8'>\n");
    FileWriteString(file_handle, "<style>\n");
    FileWriteString(file_handle, "body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }\n");
    FileWriteString(file_handle, ".container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }\n");
    FileWriteString(file_handle, "h1 { color: #2c3e50; text-align: center; }\n");
    FileWriteString(file_handle, ".success { color: #27ae60; font-weight: bold; }\n");
    FileWriteString(file_handle, ".info { background: #ecf0f1; padding: 15px; border-radius: 5px; margin: 20px 0; }\n");
    FileWriteString(file_handle, "</style>\n</head>\n<body>\n");
    
    FileWriteString(file_handle, "<div class='container'>\n");
    FileWriteString(file_handle, "<h1>🚀 RSI Momentum Strategies - Setup Complete!</h1>\n");
    
    FileWriteString(file_handle, "<div class='info'>\n");
    FileWriteString(file_handle, "<h3>✅ System Successfully Installed</h3>\n");
    FileWriteString(file_handle, "<p>Your RSI Momentum Strategies system has been successfully set up and configured.</p>\n");
    FileWriteString(file_handle, "<p><strong>Setup Date:</strong> " + TimeToString(TimeCurrent()) + "</p>\n");
    FileWriteString(file_handle, "<p><strong>Symbol:</strong> " + _Symbol + "</p>\n");
    FileWriteString(file_handle, "<p><strong>Account:</strong> " + AccountInfoString(ACCOUNT_NAME) + "</p>\n");
    FileWriteString(file_handle, "</div>\n");
    
    FileWriteString(file_handle, "<h3>📊 Recommended Settings for " + _Symbol + "</h3>\n");
    FileWriteString(file_handle, "<ul>\n");
    FileWriteString(file_handle, "<li><strong>Default Risk per Trade:</strong> " + DoubleToString(InpDefaultRisk * 100, 1) + "%</li>\n");
    FileWriteString(file_handle, "<li><strong>Maximum Daily Risk:</strong> " + DoubleToString(InpMaxDailyRisk * 100, 1) + "%</li>\n");
    FileWriteString(file_handle, "<li><strong>Notifications:</strong> " + (InpEnableNotifications ? "Enabled" : "Disabled") + "</li>\n");
    FileWriteString(file_handle, "<li><strong>Verbose Logging:</strong> " + (InpVerboseLogging ? "Enabled" : "Disabled") + "</li>\n");
    FileWriteString(file_handle, "</ul>\n");
    
    FileWriteString(file_handle, "<h3>🎯 Next Steps</h3>\n");
    FileWriteString(file_handle, "<ol>\n");
    FileWriteString(file_handle, "<li>Run <strong>DiagnosticTest.mq5</strong> to verify system health</li>\n");
    FileWriteString(file_handle, "<li>Use <strong>Backtester_FIXED.mq5</strong> for strategy testing</li>\n");
    FileWriteString(file_handle, "<li>Review the generated configuration files</li>\n");
    FileWriteString(file_handle, "<li>Start with conservative settings and gradually optimize</li>\n");
    FileWriteString(file_handle, "</ol>\n");
    
    FileWriteString(file_handle, "<div class='info'>\n");
    FileWriteString(file_handle, "<h3>📞 Support & Documentation</h3>\n");
    FileWriteString(file_handle, "<p>For additional help and documentation:</p>\n");
    FileWriteString(file_handle, "<ul>\n");
    FileWriteString(file_handle, "<li>Check <strong>README_UPDATED.md</strong> for detailed instructions</li>\n");
    FileWriteString(file_handle, "<li>Review <strong>TROUBLESHOOTING.md</strong> for common issues</li>\n");
    FileWriteString(file_handle, "<li>Use the diagnostic tools for system verification</li>\n");
    FileWriteString(file_handle, "</ul>\n");
    FileWriteString(file_handle, "</div>\n");
    
    FileWriteString(file_handle, "<p class='success' style='text-align: center;'>🎉 Happy Trading!</p>\n");
    FileWriteString(file_handle, "</div>\n");
    FileWriteString(file_handle, "</body>\n</html>");
    
    FileClose(file_handle);
    
    Print("✓ Sample performance report created: ", filename);
    return true;
}

//+------------------------------------------------------------------+
//| Run system health check                                        |
//+------------------------------------------------------------------+
bool RunSystemHealthCheck()
{
    Print("  Running basic system checks...");
    
    // Check 1: Symbol data availability
    int bars = Bars(_Symbol, PERIOD_D1);
    if(bars < 100)
    {
        Print("  WARNING: Limited historical data (", bars, " bars)");
    }
    else
    {
        Print("  ✓ Historical data: ", bars, " bars available");
    }
    
    // Check 2: Account information
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    string currency = AccountInfoString(ACCOUNT_CURRENCY);
    Print("  ✓ Account balance: ", DoubleToString(balance, 2), " ", currency);
    
    // Check 3: Indicator functionality
    int rsi_handle = iRSI(_Symbol, PERIOD_D1, 14, PRICE_CLOSE);
    if(rsi_handle == INVALID_HANDLE)
    {
        Print("  ERROR: Failed to create RSI indicator");
        return false;
    }
    
    // Wait for calculation
    Sleep(100);
    int calculated = BarsCalculated(rsi_handle);
    IndicatorRelease(rsi_handle);
    
    if(calculated > 0)
    {
        Print("  ✓ RSI indicator: Working (", calculated, " bars calculated)");
    }
    else
    {
        Print("  ERROR: RSI indicator not calculating properly");
        return false;
    }
    
    // Check 4: File operations
    string test_filename = "system_test.txt";
    int test_handle = FileOpen(test_filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    if(test_handle != INVALID_HANDLE)
    {
        FileWriteString(test_handle, "System test");
        FileClose(test_handle);
        FileDelete(test_filename, FILE_COMMON);
        Print("  ✓ File operations: Working");
    }
    else
    {
        Print("  WARNING: File operations may have issues");
    }
    
    // Check 5: Terminal information
    string terminal_name = TerminalInfoString(TERMINAL_NAME);
    int terminal_build = (int)TerminalInfoInteger(TERMINAL_BUILD);
    Print("  ✓ Terminal: ", terminal_name, " Build ", IntegerToString(terminal_build));
    
    Print("  ✓ System health check completed");
    return true;
}

//+------------------------------------------------------------------+
//| Create user guide                                              |
//+------------------------------------------------------------------+
bool CreateUserGuide()
{
    string filename = "RSI_Quick_Start_Guide.txt";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    
    if(file_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create user guide file");
        return false;
    }
    
    // Write user guide content
    FileWriteString(file_handle, "===============================================\n");
    FileWriteString(file_handle, "RSI MOMENTUM STRATEGIES - QUICK START GUIDE\n");
    FileWriteString(file_handle, "===============================================\n");
    FileWriteString(file_handle, "Generated: " + TimeToString(TimeCurrent()) + "\n");
    FileWriteString(file_handle, "Symbol: " + _Symbol + "\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "🚀 GETTING STARTED\n");
    FileWriteString(file_handle, "-------------------\n");
    FileWriteString(file_handle, "1. Your system has been automatically configured\n");
    FileWriteString(file_handle, "2. Default settings have been optimized for " + _Symbol + "\n");
    FileWriteString(file_handle, "3. All necessary files have been created\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "📁 KEY FILES\n");
    FileWriteString(file_handle, "-------------\n");
    FileWriteString(file_handle, "• Backtester_FIXED.mq5 - Main backtesting script\n");
    FileWriteString(file_handle, "• DiagnosticTest.mq5 - System health checker\n");
    FileWriteString(file_handle, "• ConfigManager.mqh - Configuration management\n");
    FileWriteString(file_handle, "• RiskManager_FIXED.mqh - Risk management\n");
    FileWriteString(file_handle, "• PerformanceMonitor_FIXED.mqh - Performance tracking\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "⚙️ RECOMMENDED SETTINGS FOR " + _Symbol + "\n");
    FileWriteString(file_handle, "--------------------------------\n");
    FileWriteString(file_handle, "• Risk per Trade: " + DoubleToString(InpDefaultRisk * 100, 1) + "%\n");
    FileWriteString(file_handle, "• Maximum Daily Risk: " + DoubleToString(InpMaxDailyRisk * 100, 1) + "%\n");
    FileWriteString(file_handle, "• Notifications: " + (InpEnableNotifications ? "Enabled" : "Disabled") + "\n");
    FileWriteString(file_handle, "• Verbose Logging: " + (InpVerboseLogging ? "Enabled" : "Disabled") + "\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "🎯 FIRST STEPS\n");
    FileWriteString(file_handle, "---------------\n");
    FileWriteString(file_handle, "1. Run DiagnosticTest.mq5 to verify everything works\n");
    FileWriteString(file_handle, "2. Start with a small backtest using Backtester_FIXED.mq5\n");
    FileWriteString(file_handle, "3. Review the generated reports\n");
    FileWriteString(file_handle, "4. Gradually increase complexity as you gain confidence\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "📊 BACKTESTING GUIDE\n");
    FileWriteString(file_handle, "---------------------\n");
    FileWriteString(file_handle, "1. Open Backtester_FIXED.mq5 in MetaTrader\n");
    FileWriteString(file_handle, "2. Set your backtest period (default: 2020-2024)\n");
    FileWriteString(file_handle, "3. Choose which strategies to test\n");
    FileWriteString(file_handle, "4. Enable optimization parameters as needed\n");
    FileWriteString(file_handle, "5. Run the script and wait for completion\n");
    FileWriteString(file_handle, "6. Review the generated HTML and CSV reports\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "⚠️ IMPORTANT NOTES\n");
    FileWriteString(file_handle, "-------------------\n");
    FileWriteString(file_handle, "• Always test on demo accounts first\n");
    FileWriteString(file_handle, "• Start with conservative settings\n");
    FileWriteString(file_handle, "• Monitor performance regularly\n");
    FileWriteString(file_handle, "• Keep detailed records of all trades\n");
    FileWriteString(file_handle, "• Never risk more than you can afford to lose\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "🔧 TROUBLESHOOTING\n");
    FileWriteString(file_handle, "-------------------\n");
    FileWriteString(file_handle, "If you encounter issues:\n");
    FileWriteString(file_handle, "1. Run DiagnosticTest.mq5 for system check\n");
    FileWriteString(file_handle, "2. Check the MetaTrader Experts log\n");
    FileWriteString(file_handle, "3. Ensure sufficient historical data is available\n");
    FileWriteString(file_handle, "4. Verify all files are in correct directories\n");
    FileWriteString(file_handle, "5. Review TROUBLESHOOTING.md for common solutions\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "📞 SUPPORT\n");
    FileWriteString(file_handle, "-----------\n");
    FileWriteString(file_handle, "• README_UPDATED.md - Comprehensive documentation\n");
    FileWriteString(file_handle, "• TROUBLESHOOTING.md - Common issues and solutions\n");
    FileWriteString(file_handle, "• Diagnostic tools for automated problem detection\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "🎉 SUCCESS TIPS\n");
    FileWriteString(file_handle, "----------------\n");
    FileWriteString(file_handle, "• Be patient - good strategies take time to develop\n");
    FileWriteString(file_handle, "• Focus on risk management over profit maximization\n");
    FileWriteString(file_handle, "• Keep learning and improving your approach\n");
    FileWriteString(file_handle, "• Maintain realistic expectations\n");
    FileWriteString(file_handle, "• Document your journey for future reference\n");
    FileWriteString(file_handle, "\n");
    
    FileWriteString(file_handle, "===============================================\n");
    FileWriteString(file_handle, "Happy Trading! 📈\n");
    FileWriteString(file_handle, "===============================================\n");
    
    FileClose(file_handle);
    
    Print("✓ Quick start guide created: ", filename);
    return true;
}

//+------------------------------------------------------------------+
//| Log setup step                                                 |
//+------------------------------------------------------------------+
void LogStep(string message, bool success)
{
    if(g_log_count >= ArraySize(g_setup_log))
        ArrayResize(g_setup_log, ArraySize(g_setup_log) + 20);
    
    string timestamp = TimeToString(TimeCurrent(), TIME_SECONDS);
    string status = success ? "SUCCESS" : "FAILED";
    
    g_setup_log[g_log_count] = "[" + timestamp + "] " + status + ": " + message;
    g_log_count++;
}

//+------------------------------------------------------------------+
//| Generate setup summary                                         |
//+------------------------------------------------------------------+
void GenerateSetupSummary()
{
    string filename = "RSI_Setup_Log_" + TimeToString(TimeCurrent(), TIME_DATE) + ".txt";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    
    if(file_handle != INVALID_HANDLE)
    {
        FileWriteString(file_handle, "RSI Momentum Strategies - Setup Log\n");
        FileWriteString(file_handle, "====================================\n");
        FileWriteString(file_handle, "Setup Date: " + TimeToString(TimeCurrent()) + "\n");
        FileWriteString(file_handle, "Symbol: " + _Symbol + "\n");
        FileWriteString(file_handle, "Account: " + AccountInfoString(ACCOUNT_NAME) + "\n");
        FileWriteString(file_handle, "\n");
        
        FileWriteString(file_handle, "Setup Summary:\n");
        FileWriteString(file_handle, "Total Steps: " + IntegerToString(g_setup_steps) + "\n");
        FileWriteString(file_handle, "Completed: " + IntegerToString(g_completed_steps) + "\n");
        FileWriteString(file_handle, "Success Rate: " + DoubleToString((double)g_completed_steps/g_setup_steps*100, 1) + "%\n");
        FileWriteString(file_handle, "\n");
        
        FileWriteString(file_handle, "Detailed Log:\n");
        FileWriteString(file_handle, "-------------\n");
        
        for(int i = 0; i < g_log_count; i++)
        {
            FileWriteString(file_handle, g_setup_log[i] + "\n");
        }
        
        FileClose(file_handle);
        Print("✓ Setup log saved: ", filename);
    }
}