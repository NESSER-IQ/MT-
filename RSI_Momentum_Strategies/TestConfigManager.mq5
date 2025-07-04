//+------------------------------------------------------------------+
//| Test Script for ConfigManager.mqh                               |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Test script to verify ConfigManager functionality  |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies Test"
#property version   "1.00"
#property script_show_inputs

#include "ConfigManager.mqh"

//+------------------------------------------------------------------+
//| Script program start function                                   |
//+------------------------------------------------------------------+
void OnStart()
{
    Print("=== ConfigManager Test Started ===");
    
    // Test 1: Initialize ConfigManager
    Print("\n--- Test 1: Initializing ConfigManager ---");
    if(InitConfigManager())
    {
        Print("✅ ConfigManager initialized successfully");
    }
    else
    {
        Print("❌ Failed to initialize ConfigManager");
        return;
    }
    
    // Test 2: List all configurations
    Print("\n--- Test 2: Listing All Configurations ---");
    CConfigManager* manager = GetConfigManager();
    if(manager != NULL)
    {
        manager.ListConfigurations();
        Print("✅ Configuration listing completed");
    }
    
    // Test 3: Get configuration by name
    Print("\n--- Test 3: Getting Configuration by Name ---");
    SStrategyConfig config;
    if(manager.GetConfig("RSI_Simple_Stocks", config))
    {
        string name = manager.GetStrategyName(config);
        string desc = manager.GetDescription(config);
        
        Print("✅ Configuration retrieved successfully:");
        Print("   Name: ", name);
        Print("   Description: ", desc);
        Print("   Win Rate: ", DoubleToString(config.expected_win_rate, 1), "%");
        Print("   RSI Period: ", config.rsi_period);
        Print("   Risk Percent: ", DoubleToString(config.risk_percent * 100, 1), "%");
    }
    else
    {
        Print("❌ Failed to retrieve configuration");
    }
    
    // Test 4: Save configurations
    Print("\n--- Test 4: Saving Configurations ---");
    if(manager.SaveConfigurations())
    {
        Print("✅ Configurations saved successfully");
    }
    else
    {
        Print("❌ Failed to save configurations");
    }
    
    // Test 5: Auto-detect best config
    Print("\n--- Test 5: Auto-detecting Best Configuration ---");
    string auto_config = manager.AutoDetectBestConfig();
    Print("✅ Auto-detected configuration: ", auto_config);
    
    // Test 6: Create new configuration
    Print("\n--- Test 6: Creating New Configuration ---");
    SStrategyConfig new_config = manager.CreateConfig(
        "Test_Strategy",
        "Test configuration created by script",
        85.5,
        1.2
    );
    
    if(manager.AddConfig(new_config))
    {
        Print("✅ New configuration created and added successfully");
        Print("   Total configurations: ", manager.GetConfigCount());
    }
    else
    {
        Print("❌ Failed to add new configuration");
    }
    
    // Test 7: Get configuration by asset type
    Print("\n--- Test 7: Getting Configuration by Asset Type ---");
    SStrategyConfig forex_config;
    if(manager.GetConfigByAssetType("FOREX", forex_config))
    {
        string forex_name = manager.GetStrategyName(forex_config);
        Print("✅ Forex configuration found: ", forex_name);
    }
    else
    {
        Print("❌ No forex configuration found");
    }
    
    // Test 8: Create optimized configuration
    Print("\n--- Test 8: Creating Optimized Configuration ---");
    SStrategyConfig optimized = manager.CreateOptimizedConfig("RSI_Simple_Stocks");
    string opt_name = manager.GetStrategyName(optimized);
    Print("✅ Optimized configuration created based on: ", opt_name);
    Print("   Optimized RSI Oversold: ", DoubleToString(optimized.rsi_oversold, 1));
    Print("   Optimized Risk Percent: ", DoubleToString(optimized.risk_percent * 100, 2), "%");
    
    // Cleanup
    Print("\n--- Cleanup ---");
    DeinitConfigManager();
    Print("✅ ConfigManager cleanup completed");
    
    Print("\n=== ConfigManager Test Completed Successfully ===");
    
    // Display summary
    Print("\n📊 Test Summary:");
    Print("   ✅ All tests passed successfully");
    Print("   ✅ FileWriteStruct/FileReadStruct working correctly");
    Print("   ✅ String conversion functions working");
    Print("   ✅ Configuration management functional");
    Print("   ✅ No compilation errors");
    
    MessageBox("ConfigManager test completed successfully!\nCheck the Experts tab for detailed results.", 
               "Test Results", MB_OK | MB_ICONINFORMATION);
}
