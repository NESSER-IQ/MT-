//+------------------------------------------------------------------+
//| System Diagnostic and Health Check Tool                         |
//| Developer: MQL5 Expert Developer                                 |
//| Version: 1.1 - Fixed Version                                    |
//| Description: Professional diagnostic tool to verify system      |
//|              integrity and troubleshoot common issues           |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.10"
#property description "System diagnostic and health check tool - Fixed Version"
#property script_show_inputs

#include "ConfigManager.mqh"
#include "GlobalConfig.mqh"

//--- Input Parameters
input group "=== Diagnostic Options ==="
input bool    InpTestConfigManager = true;        // Test Configuration Manager
input bool    InpTestIndicators = true;           // Test Indicator Initialization
input bool    InpTestDataAccess = true;           // Test Data Access
input bool    InpTestFileOperations = true;       // Test File Operations
input bool    InpGenerateTestReport = true;       // Generate Test Report

//--- Global Variables
string g_test_results[];
int g_test_count = 0;
int g_passed_tests = 0;
int g_failed_tests = 0;

//+------------------------------------------------------------------+
//| Safe Terminal Info Functions                                    |
//+------------------------------------------------------------------+
string GetTerminalBuildInfo()
{
    // Try to get terminal build safely
    ResetLastError();
    
    // Method 1: Try using MQL5 build as fallback
    int mql_build = (int)MQLInfoInteger(MQL_PROGRAM_BUILD);
    if(mql_build > 0)
    {
        return IntegerToString(mql_build);
    }
    
    // Method 2: Get current year as version indicator
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    return IntegerToString(dt.year);
}

string GetTerminalVersionInfo()
{
    // Safe way to get terminal version
    ResetLastError();
    
    string terminal_name = TerminalInfoString(TERMINAL_NAME);
    if(terminal_name != "")
    {
        return terminal_name;
    }
    
    return "MetaTrader 5";
}

//+------------------------------------------------------------------+
//| Script start function                                           |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== RSI Momentum Strategies - System Diagnostic ===");
    Print("Starting comprehensive system health check...");
    Print("Time: ", TimeToString(TimeCurrent()));
    Print("Symbol: ", _Symbol);
    Print("Terminal Build: ", GetTerminalBuildInfo());
    Print("MQL5 Build: ", IntegerToString(MQLInfoInteger(MQL_PROGRAM_BUILD)));
    Print("Program Name: ", MQLInfoString(MQL_PROGRAM_NAME));
    Print("Terminal Company: ", TerminalInfoString(TERMINAL_COMPANY));
    Print("Terminal Name: ", GetTerminalVersionInfo());
    Print("");
    
    // Initialize results array
    ArrayResize(g_test_results, 50);
    g_test_count = 0;
    g_passed_tests = 0;
    g_failed_tests = 0;
    
    // Run diagnostic tests
    if(InpTestConfigManager)
        TestConfigurationManager();
        
    if(InpTestIndicators)
        TestIndicatorInitialization();
        
    if(InpTestDataAccess)
        TestDataAccess();
        
    if(InpTestFileOperations)
        TestFileOperations();
    
    // Test System Environment
    TestSystemEnvironment();
    
    // Generate summary
    GenerateDiagnosticSummary();
    
    if(InpGenerateTestReport)
        GenerateTestReport();
    
    Print("");
    Print("=== Diagnostic Complete ===");
    Print("Total Tests: ", g_test_count);
    if(g_test_count > 0)
    {
        Print("Passed: ", g_passed_tests, " (", DoubleToString((double)g_passed_tests/g_test_count*100, 1), "%)");
        Print("Failed: ", g_failed_tests, " (", DoubleToString((double)g_failed_tests/g_test_count*100, 1), "%)");
    }
    
    if(g_failed_tests == 0)
    {
        Print("🎉 ALL TESTS PASSED - System is healthy!");
    }
    else
    {
        Print("⚠️  Some tests failed - Check details above");
    }
}

//+------------------------------------------------------------------+
//| Test Configuration Manager                                      |
//+------------------------------------------------------------------+
void TestConfigurationManager()
{
    Print("--- Testing Configuration Manager ---");
    
    // Test 1: Config Manager Initialization
    AddTestResult("Config Manager Initialization", TestConfigManagerInit());
    
    // Test 2: Default Configs Loading
    AddTestResult("Default Configurations Loading", TestDefaultConfigs());
    
    // Test 3: Config Retrieval
    AddTestResult("Configuration Retrieval", TestConfigRetrieval());
    
    // Test 4: Asset Type Detection
    AddTestResult("Asset Type Auto-Detection", TestAssetTypeDetection());
    
    Print("Configuration Manager tests completed");
    Print("");
}

//+------------------------------------------------------------------+
//| Test Indicator Initialization                                  |
//+------------------------------------------------------------------+
void TestIndicatorInitialization()
{
    Print("--- Testing Indicator Initialization ---");
    
    // Test RSI Indicator
    AddTestResult("RSI Indicator Creation", TestRSIIndicator());
    
    // Test SMA Indicator  
    AddTestResult("SMA Indicator Creation", TestSMAIndicator());
    
    // Test Multiple Timeframes
    AddTestResult("Multiple Timeframe Support", TestMultipleTimeframes());
    
    // Test Indicator Data Access
    AddTestResult("Indicator Data Access", TestIndicatorDataAccess());
    
    Print("Indicator tests completed");
    Print("");
}

//+------------------------------------------------------------------+
//| Test Data Access                                               |
//+------------------------------------------------------------------+
void TestDataAccess()
{
    Print("--- Testing Data Access ---");
    
    // Test Price Data
    AddTestResult("Price Data Access", TestPriceDataAccess());
    
    // Test Time Data
    AddTestResult("Time Data Access", TestTimeDataAccess());
    
    // Test Data Range
    AddTestResult("Historical Data Range", TestDataRange());
    
    // Test Data Quality
    AddTestResult("Data Quality Check", TestDataQuality());
    
    Print("Data access tests completed");
    Print("");
}

//+------------------------------------------------------------------+
//| Test File Operations                                           |
//+------------------------------------------------------------------+
void TestFileOperations()
{
    Print("--- Testing File Operations ---");
    
    // Test File Writing
    AddTestResult("File Write Operations", TestFileWrite());
    
    // Test File Reading
    AddTestResult("File Read Operations", TestFileRead());
    
    // Test CSV Export
    AddTestResult("CSV Export Functionality", TestCSVExport());
    
    // Test HTML Generation
    AddTestResult("HTML Report Generation", TestHTMLGeneration());
    
    Print("File operation tests completed");
    Print("");
}

//+------------------------------------------------------------------+
//| Individual Test Functions                                      |
//+------------------------------------------------------------------+

bool TestConfigManagerInit()
{
    ResetLastError();
    
    bool result = InitConfigManager();
    if(!result)
    {
        Print("ERROR: Failed to initialize ConfigManager - ", GetLastError());
        return false;
    }
    
    CConfigManager* config_mgr = GetConfigManager();
    if(config_mgr == NULL)
    {
        Print("ERROR: ConfigManager instance is NULL");
        return false;
    }
    
    Print("✅ ConfigManager initialized successfully");
    return true;
}

bool TestDefaultConfigs()
{
    CConfigManager* config_mgr = GetConfigManager();
    if(config_mgr == NULL) return false;
    
    int config_count = config_mgr.GetConfigCount();
    if(config_count == 0)
    {
        Print("ERROR: No default configurations found");
        return false;
    }
    
    Print("✅ Found ", config_count, " default configurations");
    return true;
}

bool TestConfigRetrieval()
{
    CConfigManager* config_mgr = GetConfigManager();
    if(config_mgr == NULL) return false;
    
    SStrategyConfig config;
    bool result = config_mgr.GetConfig("RSI_Simple_Stocks", config);
    
    if(!result)
    {
        Print("ERROR: Failed to retrieve RSI_Simple_Stocks configuration");
        return false;
    }
    
    Print("✅ Successfully retrieved strategy configuration");
    return true;
}

bool TestAssetTypeDetection()
{
    CConfigManager* config_mgr = GetConfigManager();
    if(config_mgr == NULL) return false;
    
    string detected_strategy = config_mgr.AutoDetectBestConfig();
    if(detected_strategy == "")
    {
        Print("ERROR: Asset type detection failed");
        return false;
    }
    
    Print("✅ Asset type detected: ", detected_strategy);
    return true;
}

bool TestRSIIndicator()
{
    ResetLastError();
    
    int rsi_handle = iRSI(_Symbol, PERIOD_D1, 14, PRICE_CLOSE);
    if(rsi_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create RSI indicator - ", GetLastError());
        return false;
    }
    
    // Wait for calculation
    Sleep(100);
    int calculated = BarsCalculated(rsi_handle);
    IndicatorRelease(rsi_handle);
    
    if(calculated <= 0)
    {
        Print("ERROR: RSI indicator not calculating");
        return false;
    }
    
    Print("✅ RSI indicator working correctly (", calculated, " bars calculated)");
    return true;
}

bool TestSMAIndicator()
{
    ResetLastError();
    
    int sma_handle = iMA(_Symbol, PERIOD_D1, 200, 0, MODE_SMA, PRICE_CLOSE);
    if(sma_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create SMA indicator - ", GetLastError());
        return false;
    }
    
    Sleep(100);
    int calculated = BarsCalculated(sma_handle);
    IndicatorRelease(sma_handle);
    
    if(calculated <= 0)
    {
        Print("ERROR: SMA indicator not calculating");
        return false;
    }
    
    Print("✅ SMA indicator working correctly (", calculated, " bars calculated)");
    return true;
}

bool TestMultipleTimeframes()
{
    ENUM_TIMEFRAMES timeframes[] = {PERIOD_H1, PERIOD_H4, PERIOD_D1};
    int tf_count = ArraySize(timeframes);
    
    for(int i = 0; i < tf_count; i++)
    {
        int bars = Bars(_Symbol, timeframes[i]);
        if(bars < 10)
        {
            Print("ERROR: Insufficient data for timeframe ", EnumToString(timeframes[i]));
            return false;
        }
    }
    
    Print("✅ Multiple timeframes supported");
    return true;
}

bool TestIndicatorDataAccess()
{
    int rsi_handle = iRSI(_Symbol, PERIOD_D1, 14, PRICE_CLOSE);
    if(rsi_handle == INVALID_HANDLE) return false;
    
    Sleep(100);
    
    double rsi_array[];
    ArraySetAsSeries(rsi_array, true);
    
    int copied = CopyBuffer(rsi_handle, 0, 0, 10, rsi_array);
    IndicatorRelease(rsi_handle);
    
    if(copied <= 0)
    {
        Print("ERROR: Failed to copy indicator data");
        return false;
    }
    
    if(rsi_array[0] == EMPTY_VALUE || rsi_array[0] < 0 || rsi_array[0] > 100)
    {
        Print("ERROR: Invalid RSI values");
        return false;
    }
    
    Print("✅ Indicator data access working correctly");
    return true;
}

bool TestPriceDataAccess()
{
    double close_array[];
    ArraySetAsSeries(close_array, true);
    
    int copied = CopyClose(_Symbol, PERIOD_D1, 0, 10, close_array);
    if(copied <= 0)
    {
        Print("ERROR: Failed to copy price data - ", GetLastError());
        return false;
    }
    
    if(close_array[0] <= 0)
    {
        Print("ERROR: Invalid price data");
        return false;
    }
    
    Print("✅ Price data access working correctly");
    return true;
}

bool TestTimeDataAccess()
{
    datetime time_array[];
    ArraySetAsSeries(time_array, true);
    
    int copied = CopyTime(_Symbol, PERIOD_D1, 0, 10, time_array);
    if(copied <= 0)
    {
        Print("ERROR: Failed to copy time data - ", GetLastError());
        return false;
    }
    
    if(time_array[0] == 0)
    {
        Print("ERROR: Invalid time data");
        return false;
    }
    
    Print("✅ Time data access working correctly");
    return true;
}

bool TestDataRange()
{
    datetime start_time = TimeCurrent() - 30*24*3600; // 30 days ago
    datetime end_time = TimeCurrent();
    
    int bars = Bars(_Symbol, PERIOD_D1, start_time, end_time);
    if(bars < 20)
    {
        Print("WARNING: Limited historical data available (", bars, " bars)");
        return false;
    }
    
    Print("✅ Sufficient historical data available (", bars, " bars)");
    return true;
}

bool TestDataQuality()
{
    double close_array[], high_array[], low_array[];
    ArraySetAsSeries(close_array, true);
    ArraySetAsSeries(high_array, true);
    ArraySetAsSeries(low_array, true);
    
    int copied = CopyClose(_Symbol, PERIOD_D1, 0, 10, close_array);
    CopyHigh(_Symbol, PERIOD_D1, 0, 10, high_array);
    CopyLow(_Symbol, PERIOD_D1, 0, 10, low_array);
    
    if(copied <= 0) return false;
    
    // Check for data integrity
    for(int i = 0; i < copied; i++)
    {
        if(high_array[i] < low_array[i] || close_array[i] > high_array[i] || close_array[i] < low_array[i])
        {
            Print("ERROR: Data integrity issue at bar ", i);
            return false;
        }
    }
    
    Print("✅ Data quality check passed");
    return true;
}

bool TestFileWrite()
{
    ResetLastError();
    
    string filename = "diagnostic_test.txt";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    
    if(file_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create test file - ", GetLastError());
        return false;
    }
    
    FileWriteString(file_handle, "Diagnostic test file");
    FileClose(file_handle);
    
    Print("✅ File write operations working");
    return true;
}

bool TestFileRead()
{
    ResetLastError();
    
    string filename = "diagnostic_test.txt";
    int file_handle = FileOpen(filename, FILE_READ | FILE_TXT | FILE_COMMON);
    
    if(file_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to read test file - ", GetLastError());
        return false;
    }
    
    string content = FileReadString(file_handle);
    FileClose(file_handle);
    FileDelete(filename, FILE_COMMON); // Cleanup
    
    if(content != "Diagnostic test file")
    {
        Print("ERROR: File content mismatch");
        return false;
    }
    
    Print("✅ File read operations working");
    return true;
}

bool TestCSVExport()
{
    ResetLastError();
    
    string filename = "diagnostic_test.csv";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_CSV | FILE_COMMON);
    
    if(file_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create CSV file - ", GetLastError());
        return false;
    }
    
    FileWrite(file_handle, "Test", "Data", 123.45, true);
    FileClose(file_handle);
    FileDelete(filename, FILE_COMMON); // Cleanup
    
    Print("✅ CSV export functionality working");
    return true;
}

bool TestHTMLGeneration()
{
    ResetLastError();
    
    string filename = "diagnostic_test.html";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    
    if(file_handle == INVALID_HANDLE)
    {
        Print("ERROR: Failed to create HTML file - ", GetLastError());
        return false;
    }
    
    FileWriteString(file_handle, "<html><body><h1>Test</h1></body></html>");
    FileClose(file_handle);
    FileDelete(filename, FILE_COMMON); // Cleanup
    
    Print("✅ HTML generation working");
    return true;
}

//+------------------------------------------------------------------+
//| Test System Environment                                        |
//+------------------------------------------------------------------+
void TestSystemEnvironment()
{
    Print("--- Testing System Environment ---");
    
    // Test Terminal Connection
    AddTestResult("Terminal Connection Status", TestTerminalConnection());
    
    // Test Trading Permissions
    AddTestResult("Trading Permissions", TestTradingPermissions());
    
    // Test DLL Permissions
    AddTestResult("DLL Import Permissions", TestDLLPermissions());
    
    // Test Account Information
    AddTestResult("Account Information Access", TestAccountInfo());
    
    // Test Market Watch
    AddTestResult("Market Watch Access", TestMarketWatch());
    
    // Test Performance Metrics
    AddTestResult("Performance Metrics", TestPerformanceMetrics());
    
    Print("System environment tests completed");
    Print("");
}

bool TestTerminalConnection()
{
    bool connected = TerminalInfoInteger(TERMINAL_CONNECTED);
    if(!connected)
    {
        Print("ERROR: Terminal not connected to trade server");
        return false;
    }
    
    Print("✅ Terminal connected to trade server");
    return true;
}

bool TestTradingPermissions()
{
    bool trade_allowed = TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
    if(!trade_allowed)
    {
        Print("WARNING: Trading not allowed from terminal");
        return false;
    }
    
    bool ea_allowed = MQLInfoInteger(MQL_TRADE_ALLOWED);
    if(!ea_allowed)
    {
        Print("WARNING: Expert Advisors trading not allowed");
        return false;
    }
    
    Print("✅ Trading permissions granted");
    return true;
}

bool TestDLLPermissions()
{
    bool dll_allowed = MQLInfoInteger(MQL_DLLS_ALLOWED);
    if(!dll_allowed)
    {
        Print("INFO: DLL imports not allowed (may limit some features)");
        return true; // Not critical for basic functionality
    }
    
    Print("✅ DLL imports allowed");
    return true;
}

bool TestAccountInfo()
{
    ResetLastError();
    
    long account_number = AccountInfoInteger(ACCOUNT_LOGIN);
    if(account_number == 0)
    {
        Print("ERROR: Failed to get account information - ", GetLastError());
        return false;
    }
    
    string account_server = AccountInfoString(ACCOUNT_SERVER);
    if(account_server == "")
    {
        Print("ERROR: Failed to get server information");
        return false;
    }
    
    Print("✅ Account access working (Account: ", account_number, ", Server: ", account_server, ")");
    return true;
}

bool TestMarketWatch()
{
    ResetLastError();
    
    // Test symbol selection
    bool selected = SymbolSelect(_Symbol, true);
    if(!selected)
    {
        Print("ERROR: Failed to select symbol in Market Watch - ", GetLastError());
        return false;
    }
    
    // Test symbol info access
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    
    if(bid == 0 || ask == 0)
    {
        Print("ERROR: Failed to get symbol quotes");
        return false;
    }
    
    Print("✅ Market Watch access working (Bid: ", bid, ", Ask: ", ask, ")");
    return true;
}

bool TestPerformanceMetrics()
{
    ResetLastError();
    
    // Test memory usage
    long memory_used = MQLInfoInteger(MQL_MEMORY_USED);
    long memory_limit = MQLInfoInteger(MQL_MEMORY_LIMIT);
    
    if(memory_used == 0)
    {
        Print("WARNING: Failed to get memory usage information");
        return false;
    }
    
    double memory_percent = (double)memory_used / memory_limit * 100;
    
    if(memory_percent > 80)
    {
        Print("WARNING: High memory usage detected (", DoubleToString(memory_percent, 1), "%)");
        return false;
    }
    
    // Test CPU usage simulation
    uint start_time = GetTickCount();
    
    // Simulate CPU intensive task
    double test_array[];
    ArrayResize(test_array, 1000);
    
    for(int i = 0; i < 1000; i++)
    {
        test_array[i] = MathSin(i * 0.001) * MathCos(i * 0.002);
    }
    
    uint end_time = GetTickCount();
    uint execution_time = end_time - start_time;
    
    if(execution_time > 1000) // More than 1 second for simple calculation
    {
        Print("WARNING: Slow system performance detected (", execution_time, "ms)");
        return false;
    }
    
    Print("✅ Performance metrics acceptable (Memory: ", DoubleToString(memory_percent, 1), "%, CPU test: ", execution_time, "ms)");
    return true;
}

//+------------------------------------------------------------------+
//| Helper Functions                                               |
//+------------------------------------------------------------------+

void AddTestResult(string test_name, bool result)
{
    if(g_test_count >= ArraySize(g_test_results))
        ArrayResize(g_test_results, ArraySize(g_test_results) + 10);
    
    string status = result ? "PASS" : "FAIL";
    g_test_results[g_test_count] = test_name + ": " + status;
    
    if(result)
        g_passed_tests++;
    else
        g_failed_tests++;
        
    g_test_count++;
}

void GenerateDiagnosticSummary()
{
    Print("");
    Print("=== DIAGNOSTIC SUMMARY ===");
    
    for(int i = 0; i < g_test_count; i++)
    {
        string result = g_test_results[i];
        if(StringFind(result, "FAIL") >= 0)
            Print("❌ ", result);
        else
            Print("✅ ", result);
    }
}

void GenerateTestReport()
{
    string filename = "System_Diagnostic_Report_" + TimeToString(TimeCurrent(), TIME_DATE) + ".html";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    
    if(file_handle != INVALID_HANDLE)
    {
        // HTML Header
        FileWriteString(file_handle, "<!DOCTYPE html><html><head>");
        FileWriteString(file_handle, "<title>RSI System Diagnostic Report</title>");
        FileWriteString(file_handle, "<style>");
        FileWriteString(file_handle, "body { font-family: Arial, sans-serif; margin: 20px; }");
        FileWriteString(file_handle, ".pass { color: green; } .fail { color: red; }");
        FileWriteString(file_handle, "table { border-collapse: collapse; width: 100%; }");
        FileWriteString(file_handle, "th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        FileWriteString(file_handle, "th { background-color: #f2f2f2; }");
        FileWriteString(file_handle, "</style></head><body>");
        
        // Report Content
        FileWriteString(file_handle, "<h1>🔧 RSI System Diagnostic Report</h1>");
        FileWriteString(file_handle, "<p><strong>Generated:</strong> " + TimeToString(TimeCurrent()) + "</p>");
        FileWriteString(file_handle, "<p><strong>Symbol:</strong> " + _Symbol + "</p>");
        FileWriteString(file_handle, "<p><strong>Terminal Build:</strong> " + GetTerminalBuildInfo() + "</p>");
        FileWriteString(file_handle, "<p><strong>MQL5 Build:</strong> " + IntegerToString(MQLInfoInteger(MQL_PROGRAM_BUILD)) + "</p>");
        FileWriteString(file_handle, "<p><strong>Program:</strong> " + MQLInfoString(MQL_PROGRAM_NAME) + "</p>");
        FileWriteString(file_handle, "<p><strong>Terminal:</strong> " + GetTerminalVersionInfo() + "</p>");
        FileWriteString(file_handle, "<p><strong>Account:</strong> " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "</p>");
        FileWriteString(file_handle, "<p><strong>Server:</strong> " + AccountInfoString(ACCOUNT_SERVER) + "</p>");
        FileWriteString(file_handle, "<p><strong>Connection:</strong> " + (TerminalInfoInteger(TERMINAL_CONNECTED) ? "Connected" : "Disconnected") + "</p>");
        FileWriteString(file_handle, "<p><strong>Memory Used:</strong> " + IntegerToString(MQLInfoInteger(MQL_MEMORY_USED)) + " KB</p>");
        
        // Summary
        FileWriteString(file_handle, "<h2>📊 Summary</h2>");
        FileWriteString(file_handle, "<p>Total Tests: " + IntegerToString(g_test_count) + "</p>");
        FileWriteString(file_handle, "<p class='pass'>Passed: " + IntegerToString(g_passed_tests) + "</p>");
        FileWriteString(file_handle, "<p class='fail'>Failed: " + IntegerToString(g_failed_tests) + "</p>");
        
        // Test Results Table
        FileWriteString(file_handle, "<h2>📋 Test Results</h2>");
        FileWriteString(file_handle, "<table>");
        FileWriteString(file_handle, "<tr><th>Test Name</th><th>Result</th></tr>");
        
        for(int i = 0; i < g_test_count; i++)
        {
            string result = g_test_results[i];
            string class_name = StringFind(result, "FAIL") >= 0 ? "fail" : "pass";
            FileWriteString(file_handle, "<tr class='" + class_name + "'><td>" + result + "</td></tr>");
        }
        
        FileWriteString(file_handle, "</table>");
        
        // Add Recommendations section
        FileWriteString(file_handle, "<h2>💡 Recommendations</h2>");
        
        if(g_failed_tests > 0)
        {
            FileWriteString(file_handle, "<div style='background-color: #ffeeee; padding: 10px; border: 1px solid #ffcccc; border-radius: 5px;'>");
            FileWriteString(file_handle, "<h3>⚠️ Issues Found</h3>");
            FileWriteString(file_handle, "<ul>");
            
            for(int i = 0; i < g_test_count; i++)
            {
                if(StringFind(g_test_results[i], "FAIL") >= 0)
                {
                    FileWriteString(file_handle, "<li>" + g_test_results[i] + "</li>");
                }
            }
            
            FileWriteString(file_handle, "</ul>");
            FileWriteString(file_handle, "<p><strong>Recommended Actions:</strong></p>");
            FileWriteString(file_handle, "<ul>");
            FileWriteString(file_handle, "<li>Check MetaTrader 5 connection settings</li>");
            FileWriteString(file_handle, "<li>Verify trading permissions in Tools → Options → Expert Advisors</li>");
            FileWriteString(file_handle, "<li>Ensure sufficient historical data is available</li>");
            FileWriteString(file_handle, "<li>Check symbol availability in Market Watch</li>");
            FileWriteString(file_handle, "<li>Restart MetaTrader 5 if connection issues persist</li>");
            FileWriteString(file_handle, "</ul>");
            FileWriteString(file_handle, "</div>");
        }
        else
        {
            FileWriteString(file_handle, "<div style='background-color: #eeffee; padding: 10px; border: 1px solid #ccffcc; border-radius: 5px;'>");
            FileWriteString(file_handle, "<h3>✅ System Healthy</h3>");
            FileWriteString(file_handle, "<p>All diagnostic tests passed successfully. Your RSI Momentum Strategy system is ready for use.</p>");
            FileWriteString(file_handle, "</div>");
        }
        
        FileWriteString(file_handle, "<br><hr><p style='text-align: center; color: #666;'>");
        FileWriteString(file_handle, "Generated by RSI Momentum Strategies Diagnostic Tool v1.1 (Fixed Version)<br>");
        FileWriteString(file_handle, "Professional MQL5 Development - For support, contact: support@rsimomentum.com");
        FileWriteString(file_handle, "</p>");
        
        FileWriteString(file_handle, "</body></html>");
        
        FileClose(file_handle);
        Print("✅ Diagnostic report generated: ", filename);
    }
    else
    {
        Print("ERROR: Failed to create diagnostic report file");
    }
    
    // Cleanup config manager
    DeinitConfigManager();
}

//+------------------------------------------------------------------+
//| END OF DIAGNOSTIC TOOL                                         |
//+------------------------------------------------------------------+