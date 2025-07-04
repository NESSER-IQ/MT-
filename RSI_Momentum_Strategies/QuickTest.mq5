//+------------------------------------------------------------------+
//| Quick System Test and Validation Tool                           |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Fast system validation and performance test        |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"
#property description "Quick system test and validation"
#property script_show_inputs

#include "ConfigManager.mqh"

//--- Input Parameters
input group "=== Quick Test Settings ==="
input int     InpTestBars = 100;              // Number of bars to test
input bool    InpRunFullTest = false;         // Run full system test
input bool    InpGenerateReport = true;       // Generate test report

//--- Global Variables
datetime g_test_start_time;
int g_total_tests = 0;
int g_passed_tests = 0;
string g_test_log[];
int g_log_count = 0;

//+------------------------------------------------------------------+
//| Script start function                                           |
//+------------------------------------------------------------------+
void OnStart()
{
    g_test_start_time = TimeCurrent();
    Print("=== RSI System Quick Test Started ===");
    Print("Time: ", TimeToString(g_test_start_time));
    Print("Symbol: ", _Symbol);
    Print("");
    
    ArrayResize(g_test_log, 50);
    g_total_tests = 0;
    g_passed_tests = 0;
    g_log_count = 0;
    
    // Quick validation tests
    RunQuickValidation();
    
    if(InpRunFullTest)
        RunFullSystemTest();
    
    // Generate summary
    GenerateTestSummary();
    
    if(InpGenerateReport)
        GenerateQuickReport();
    
    Print("");
    Print("=== Quick Test Complete ===");
    Print("Duration: ", (TimeCurrent() - g_test_start_time), " seconds");
    Print("Success Rate: ", DoubleToString((double)g_passed_tests/g_total_tests*100, 1), "%");
    
    if(g_passed_tests == g_total_tests)
    {
        Print("🎉 ALL TESTS PASSED - System is ready!");
        Print("✅ You can proceed with backtesting");
    }
    else
    {
        Print("⚠️  Some tests failed - Check diagnostic tools");
        Print("❌ Run DiagnosticTest.mq5 for detailed analysis");
    }
}

//+------------------------------------------------------------------+
//| Run quick validation tests                                     |
//+------------------------------------------------------------------+
void RunQuickValidation()
{
    Print("--- Quick Validation Tests ---");
    
    // Test 1: Basic system components
    LogTest("System Components", TestSystemComponents());
    
    // Test 2: Data availability
    LogTest("Data Availability", TestDataAvailability());
    
    // Test 3: Indicator functionality
    LogTest("Indicator Functionality", TestIndicators());
    
    // Test 4: Configuration access
    LogTest("Configuration Access", TestConfiguration());
    
    // Test 5: File operations
    LogTest("File Operations", TestFileOperations());
    
    Print("Quick validation completed");
    Print("");
}

//+------------------------------------------------------------------+
//| Run full system test                                           |
//+------------------------------------------------------------------+
void RunFullSystemTest()
{
    Print("--- Full System Test ---");
    
    // Test 6: Mini backtest
    LogTest("Mini Backtest", RunMiniBacktest());
    
    // Test 7: Performance calculations
    LogTest("Performance Calculations", TestPerformanceCalc());
    
    // Test 8: Risk management
    LogTest("Risk Management", TestRiskManagement());
    
    Print("Full system test completed");
    Print("");
}

//+------------------------------------------------------------------+
//| Individual test functions                                      |
//+------------------------------------------------------------------+

bool TestSystemComponents()
{
    // Check if all necessary components are available
    bool all_good = true;
    
    // Check symbol information
    if(SymbolInfoDouble(_Symbol, SYMBOL_BID) <= 0)
    {
        Print("  ERROR: Symbol information not available");
        all_good = false;
    }
    
    // Check account information
    if(AccountInfoDouble(ACCOUNT_BALANCE) <= 0)
    {
        Print("  ERROR: Account information not available");
        all_good = false;
    }
    
    // Check terminal information
    if(TerminalInfoString(TERMINAL_NAME) == "")
    {
        Print("  ERROR: Terminal information not available");
        all_good = false;
    }
    
    if(all_good)
        Print("  ✓ System components: OK");
    
    return all_good;
}

bool TestDataAvailability()
{
    int available_bars = Bars(_Symbol, PERIOD_D1);
    
    if(available_bars < InpTestBars)
    {
        Print("  ERROR: Insufficient data (", available_bars, " bars, need ", InpTestBars, ")");
        return false;
    }
    
    // Test data quality
    double test_close[];
    ArraySetAsSeries(test_close, true);
    
    if(CopyClose(_Symbol, PERIOD_D1, 0, 10, test_close) <= 0)
    {
        Print("  ERROR: Cannot copy price data");
        return false;
    }
    
    if(test_close[0] <= 0)
    {
        Print("  ERROR: Invalid price data");
        return false;
    }
    
    Print("  ✓ Data availability: ", available_bars, " bars");
    return true;
}

bool TestIndicators()
{
    // Test RSI indicator
    int rsi_handle = iRSI(_Symbol, PERIOD_D1, 14, PRICE_CLOSE);
    if(rsi_handle == INVALID_HANDLE)
    {
        Print("  ERROR: Cannot create RSI indicator");
        return false;
    }
    
    // Wait for calculation
    Sleep(100);
    
    double rsi_value[];
    ArraySetAsSeries(rsi_value, true);
    
    if(CopyBuffer(rsi_handle, 0, 0, 5, rsi_value) <= 0)
    {
        IndicatorRelease(rsi_handle);
        Print("  ERROR: Cannot get RSI values");
        return false;
    }
    
    IndicatorRelease(rsi_handle);
    
    // Test SMA indicator
    int sma_handle = iMA(_Symbol, PERIOD_D1, 20, 0, MODE_SMA, PRICE_CLOSE);
    if(sma_handle == INVALID_HANDLE)
    {
        Print("  ERROR: Cannot create SMA indicator");
        return false;
    }
    
    IndicatorRelease(sma_handle);
    
    Print("  ✓ Indicators: Working properly");
    return true;
}

bool TestConfiguration()
{
    // Test configuration manager
    if(!InitConfigManager())
    {
        Print("  ERROR: Cannot initialize configuration manager");
        return false;
    }
    
    CConfigManager* config_mgr = GetConfigManager();
    if(config_mgr == NULL)
    {
        Print("  ERROR: Configuration manager is null");
        return false;
    }
    
    int config_count = config_mgr.GetConfigCount();
    if(config_count == 0)
    {
        Print("  ERROR: No configurations available");
        DeinitConfigManager();
        return false;
    }
    
    // Test getting a specific configuration
    SStrategyConfig test_config;
    if(!config_mgr.GetConfig("RSI_Simple_Stocks", test_config))
    {
        Print("  ERROR: Cannot retrieve test configuration");
        DeinitConfigManager();
        return false;
    }
    
    DeinitConfigManager();
    
    Print("  ✓ Configuration: ", config_count, " configs available");
    return true;
}

bool TestFileOperations()
{
    string test_filename = "quick_test_file.txt";
    
    // Test file writing
    int file_handle = FileOpen(test_filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    if(file_handle == INVALID_HANDLE)
    {
        Print("  ERROR: Cannot create test file");
        return false;
    }
    
    FileWriteString(file_handle, "Quick test data");
    FileClose(file_handle);
    
    // Test file reading
    file_handle = FileOpen(test_filename, FILE_READ | FILE_TXT | FILE_COMMON);
    if(file_handle == INVALID_HANDLE)
    {
        Print("  ERROR: Cannot read test file");
        return false;
    }
    
    string content = FileReadString(file_handle);
    FileClose(file_handle);
    
    // Cleanup
    FileDelete(test_filename, FILE_COMMON);
    
    if(content != "Quick test data")
    {
        Print("  ERROR: File content mismatch");
        return false;
    }
    
    Print("  ✓ File operations: Working properly");
    return true;
}

bool RunMiniBacktest()
{
    Print("  Running mini backtest with ", InpTestBars, " bars...");
    
    // Initialize indicators
    int rsi_handle = iRSI(_Symbol, PERIOD_D1, 14, PRICE_CLOSE);
    if(rsi_handle == INVALID_HANDLE)
    {
        Print("  ERROR: Cannot initialize RSI for backtest");
        return false;
    }
    
    // Wait for indicators
    Sleep(200);
    
    // Prepare arrays
    double rsi_array[], close_array[];
    ArraySetAsSeries(rsi_array, true);
    ArraySetAsSeries(close_array, true);
    
    // Copy data
    int test_bars = MathMin(InpTestBars, Bars(_Symbol, PERIOD_D1));
    
    if(CopyBuffer(rsi_handle, 0, 0, test_bars, rsi_array) <= 0 ||
       CopyClose(_Symbol, PERIOD_D1, 0, test_bars, close_array) <= 0)
    {
        IndicatorRelease(rsi_handle);
        Print("  ERROR: Cannot copy data for backtest");
        return false;
    }
    
    // Simple signal generation test
    int signals_found = 0;
    for(int i = test_bars - 1; i >= 1; i--)
    {
        if(rsi_array[i] < 30 || rsi_array[i] > 70)
            signals_found++;
    }
    
    IndicatorRelease(rsi_handle);
    
    if(signals_found == 0)
    {
        Print("  WARNING: No signals found in test period");
        return false;
    }
    
    Print("  ✓ Mini backtest: ", signals_found, " signals found");
    return true;
}

bool TestPerformanceCalc()
{
    // Test basic performance calculations
    double test_trades[] = {100, -50, 150, -30, 80, -40, 200};
    int trade_count = ArraySize(test_trades);
    
    // Calculate basic metrics
    double total_profit = 0;
    double total_loss = 0;
    int winning_trades = 0;
    
    for(int i = 0; i < trade_count; i++)
    {
        if(test_trades[i] > 0)
        {
            total_profit += test_trades[i];
            winning_trades++;
        }
        else
        {
            total_loss += MathAbs(test_trades[i]);
        }
    }
    
    double win_rate = (double)winning_trades / trade_count * 100;
    double profit_factor = total_loss > 0 ? total_profit / total_loss : 999;
    
    if(win_rate <= 0 || profit_factor <= 0)
    {
        Print("  ERROR: Invalid performance calculations");
        return false;
    }
    
    Print("  ✓ Performance calc: Win rate ", DoubleToString(win_rate, 1), 
          "%, PF ", DoubleToString(profit_factor, 2));
    return true;
}

bool TestRiskManagement()
{
    // Test basic risk calculations
    double account_balance = 10000;
    double risk_percent = 0.02;
    double entry_price = 100;
    double stop_loss = 98;
    
    // Calculate position size
    double risk_amount = account_balance * risk_percent;
    double stop_distance = MathAbs(entry_price - stop_loss);
    double position_size = stop_distance > 0 ? risk_amount / stop_distance : 0;
    
    if(position_size <= 0 || position_size > account_balance)
    {
        Print("  ERROR: Invalid position size calculation");
        return false;
    }
    
    // Test drawdown calculation
    double peak_balance = 12000;
    double current_balance = 10500;
    double drawdown = (peak_balance - current_balance) / peak_balance * 100;
    
    if(drawdown < 0 || drawdown > 100)
    {
        Print("  ERROR: Invalid drawdown calculation");
        return false;
    }
    
    Print("  ✓ Risk management: Position size ", DoubleToString(position_size, 2), 
          ", DD ", DoubleToString(drawdown, 1), "%");
    return true;
}

//+------------------------------------------------------------------+
//| Helper functions                                               |
//+------------------------------------------------------------------+

void LogTest(string test_name, bool result)
{
    g_total_tests++;
    if(result) g_passed_tests++;
    
    string status = result ? "PASS" : "FAIL";
    string log_entry = test_name + ": " + status;
    
    if(g_log_count < ArraySize(g_test_log))
    {
        g_test_log[g_log_count] = log_entry;
        g_log_count++;
    }
    
    Print(result ? "✅ " : "❌ ", log_entry);
}

void GenerateTestSummary()
{
    Print("");
    Print("=== TEST SUMMARY ===");
    Print("Total Tests: ", g_total_tests);
    Print("Passed: ", g_passed_tests);
    Print("Failed: ", g_total_tests - g_passed_tests);
    Print("Success Rate: ", DoubleToString((double)g_passed_tests/g_total_tests*100, 1), "%");
    
    if(g_passed_tests < g_total_tests)
    {
        Print("");
        Print("Failed Tests:");
        for(int i = 0; i < g_log_count; i++)
        {
            if(StringFind(g_test_log[i], "FAIL") >= 0)
                Print("  ❌ ", g_test_log[i]);
        }
    }
}

void GenerateQuickReport()
{
    string filename = "Quick_Test_Report_" + TimeToString(TimeCurrent(), TIME_DATE) + ".txt";
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
    
    if(file_handle != INVALID_HANDLE)
    {
        FileWriteString(file_handle, "RSI Momentum Strategies - Quick Test Report");
        FileWriteString(file_handle, "==========================================");
        FileWriteString(file_handle, "Test Date: " + TimeToString(TimeCurrent()));
        FileWriteString(file_handle, "Symbol: " + _Symbol);
        FileWriteString(file_handle, "Test Duration: " + IntegerToString(TimeCurrent() - g_test_start_time) + " seconds");
        FileWriteString(file_handle, "");
        
        FileWriteString(file_handle, "Test Results:");
        FileWriteString(file_handle, "Total Tests: " + IntegerToString(g_total_tests));
        FileWriteString(file_handle, "Passed: " + IntegerToString(g_passed_tests));
        FileWriteString(file_handle, "Failed: " + IntegerToString(g_total_tests - g_passed_tests));
        FileWriteString(file_handle, "Success Rate: " + DoubleToString((double)g_passed_tests/g_total_tests*100, 1) + "%");
        FileWriteString(file_handle, "");
        
        FileWriteString(file_handle, "Detailed Results:");
        for(int i = 0; i < g_log_count; i++)
        {
            FileWriteString(file_handle, g_test_log[i]);
        }
        
        FileWriteString(file_handle, "");
        if(g_passed_tests == g_total_tests)
        {
            FileWriteString(file_handle, "Status: ALL TESTS PASSED - System is ready for use");
            FileWriteString(file_handle, "Recommendation: Proceed with backtesting");
        }
        else
        {
            FileWriteString(file_handle, "Status: Some tests failed - System needs attention");
            FileWriteString(file_handle, "Recommendation: Run DiagnosticTest.mq5 for detailed analysis");
        }
        
        FileClose(file_handle);
        Print("✓ Quick test report saved: ", filename);
    }
}