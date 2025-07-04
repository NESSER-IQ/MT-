//+------------------------------------------------------------------+
//| Advanced Market Analyzer for RSI Strategies                    |
//| Developer: AI Assistant                                          |
//| Version: 1.0                                                     |
//| Description: Comprehensive market analysis tool combining       |
//|              multiple indicators and market conditions          |
//+------------------------------------------------------------------+

#property copyright "RSI Momentum Strategies"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Market Analysis Structures                                      |
//+------------------------------------------------------------------+
enum ENUM_MARKET_STATE
{
    MARKET_UNDEFINED,           // Market state undefined
    MARKET_STRONG_UPTREND,      // Strong bullish trend
    MARKET_WEAK_UPTREND,        // Weak bullish trend
    MARKET_STRONG_DOWNTREND,    // Strong bearish trend
    MARKET_WEAK_DOWNTREND,      // Weak bearish trend
    MARKET_SIDEWAYS_NEUTRAL,    // Neutral sideways market
    MARKET_SIDEWAYS_BULLISH,    // Bullish bias sideways
    MARKET_SIDEWAYS_BEARISH,    // Bearish bias sideways
    MARKET_HIGHLY_VOLATILE,     // High volatility environment
    MARKET_LOW_VOLATILITY       // Low volatility environment
};

enum ENUM_SIGNAL_STRENGTH
{
    SIGNAL_NONE,                // No signal
    SIGNAL_WEAK,                // Weak signal
    SIGNAL_MODERATE,            // Moderate signal
    SIGNAL_STRONG,              // Strong signal
    SIGNAL_VERY_STRONG          // Very strong signal
};

struct SMarketAnalysis
{
    // Basic Market Information
    datetime analysis_time;
    string symbol;
    ENUM_TIMEFRAMES timeframe;
    
    // Trend Analysis
    ENUM_MARKET_STATE market_state;
    double trend_strength;      // -100 to +100
    int trend_duration_bars;
    double trend_angle;
    
    // Volatility Analysis
    double current_volatility;
    double avg_volatility;
    double volatility_percentile;
    bool volatility_expanding;
    
    // Volume Analysis
    double current_volume_ratio;
    double volume_trend;
    bool volume_confirmation;
    
    // RSI Analysis
    double rsi_value;
    double rsi_trend;
    bool rsi_oversold;
    bool rsi_overbought;
    bool rsi_divergence_bullish;
    bool rsi_divergence_bearish;
    
    // Support/Resistance
    double nearest_support;
    double nearest_resistance;
    double support_strength;
    double resistance_strength;
    
    // Multi-Timeframe Analysis
    ENUM_MARKET_STATE mtf_daily_state;
    ENUM_MARKET_STATE mtf_h4_state;
    ENUM_MARKET_STATE mtf_h1_state;
    bool mtf_alignment;
    
    // Signal Analysis
    ENUM_SIGNAL_STRENGTH buy_signal_strength;
    ENUM_SIGNAL_STRENGTH sell_signal_strength;
    double signal_confidence;
    string signal_reasons[10];
    int signal_count;
    
    // Risk Assessment
    double market_risk_level;   // 0 to 100
    string risk_factors[10];
    int risk_factor_count;
    
    // Trading Recommendations
    bool recommend_long;
    bool recommend_short;
    bool recommend_wait;
    double recommended_position_size;
    double recommended_stop_loss;
    double recommended_take_profit;
};

//+------------------------------------------------------------------+
//| Market Analyzer Class                                           |
//+------------------------------------------------------------------+
class CMarketAnalyzer
{
private:
    string m_symbol;
    ENUM_TIMEFRAMES m_timeframe;
    
    // Indicator handles
    int m_rsi_handle;
    int m_sma_20_handle;
    int m_sma_50_handle;
    int m_sma_200_handle;
    int m_atr_handle;
    int m_bb_handle;
    int m_macd_handle;
    int m_stoch_handle;
    
    // Multi-timeframe handles
    int m_mtf_daily_rsi;
    int m_mtf_h4_rsi;
    int m_mtf_h1_rsi;
    int m_mtf_daily_sma;
    int m_mtf_h4_sma;
    
    // Data arrays
    double m_rsi_array[];
    double m_sma20_array[];
    double m_sma50_array[];
    double m_sma200_array[];
    double m_atr_array[];
    double m_bb_upper_array[];
    double m_bb_lower_array[];
    double m_macd_main_array[];
    double m_macd_signal_array[];
    double m_stoch_main_array[];
    double m_stoch_signal_array[];
    
    double m_high_array[];
    double m_low_array[];
    double m_close_array[];
    double m_open_array[];
    long m_volume_array[];
    
    // Multi-timeframe arrays
    double m_mtf_daily_rsi_array[];
    double m_mtf_h4_rsi_array[];
    double m_mtf_h1_rsi_array[];
    double m_mtf_daily_sma_array[];
    double m_mtf_h4_sma_array[];
    
    SMarketAnalysis m_last_analysis;
    
public:
    // Constructor
    CMarketAnalyzer(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
    {
        m_symbol = (symbol == "") ? _Symbol : symbol;
        m_timeframe = (timeframe == PERIOD_CURRENT) ? _Period : timeframe;
        
        InitializeIndicators();
        InitializeArrays();
        
        Print("Market Analyzer initialized for ", m_symbol, " ", EnumToString(m_timeframe));
    }
    
    // Destructor
    ~CMarketAnalyzer()
    {
        CleanupIndicators();
    }
    
    // Initialize all indicators
    bool InitializeIndicators()
    {
        // Main timeframe indicators
        m_rsi_handle = iRSI(m_symbol, m_timeframe, 14, PRICE_CLOSE);
        m_sma_20_handle = iMA(m_symbol, m_timeframe, 20, 0, MODE_SMA, PRICE_CLOSE);
        m_sma_50_handle = iMA(m_symbol, m_timeframe, 50, 0, MODE_SMA, PRICE_CLOSE);
        m_sma_200_handle = iMA(m_symbol, m_timeframe, 200, 0, MODE_SMA, PRICE_CLOSE);
        m_atr_handle = iATR(m_symbol, m_timeframe, 14);
        m_bb_handle = iBands(m_symbol, m_timeframe, 20, 0, 2.0, PRICE_CLOSE);
        m_macd_handle = iMACD(m_symbol, m_timeframe, 12, 26, 9, PRICE_CLOSE);
        m_stoch_handle = iStochastic(m_symbol, m_timeframe, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
        
        // Multi-timeframe indicators
        m_mtf_daily_rsi = iRSI(m_symbol, PERIOD_D1, 14, PRICE_CLOSE);
        m_mtf_h4_rsi = iRSI(m_symbol, PERIOD_H4, 14, PRICE_CLOSE);
        m_mtf_h1_rsi = iRSI(m_symbol, PERIOD_H1, 14, PRICE_CLOSE);
        m_mtf_daily_sma = iMA(m_symbol, PERIOD_D1, 50, 0, MODE_SMA, PRICE_CLOSE);
        m_mtf_h4_sma = iMA(m_symbol, PERIOD_H4, 50, 0, MODE_SMA, PRICE_CLOSE);
        
        // Check handles
        bool all_valid = (m_rsi_handle != INVALID_HANDLE &&
                         m_sma_20_handle != INVALID_HANDLE &&
                         m_sma_50_handle != INVALID_HANDLE &&
                         m_sma_200_handle != INVALID_HANDLE &&
                         m_atr_handle != INVALID_HANDLE &&
                         m_bb_handle != INVALID_HANDLE &&
                         m_macd_handle != INVALID_HANDLE &&
                         m_stoch_handle != INVALID_HANDLE &&
                         m_mtf_daily_rsi != INVALID_HANDLE &&
                         m_mtf_h4_rsi != INVALID_HANDLE &&
                         m_mtf_h1_rsi != INVALID_HANDLE);
        
        if(!all_valid)
        {
            Print("ERROR: Failed to initialize some indicators");
            return false;
        }
        
        return true;
    }
    
    // Initialize arrays
    void InitializeArrays()
    {
        ArraySetAsSeries(m_rsi_array, true);
        ArraySetAsSeries(m_sma20_array, true);
        ArraySetAsSeries(m_sma50_array, true);
        ArraySetAsSeries(m_sma200_array, true);
        ArraySetAsSeries(m_atr_array, true);
        ArraySetAsSeries(m_bb_upper_array, true);
        ArraySetAsSeries(m_bb_lower_array, true);
        ArraySetAsSeries(m_macd_main_array, true);
        ArraySetAsSeries(m_macd_signal_array, true);
        ArraySetAsSeries(m_stoch_main_array, true);
        ArraySetAsSeries(m_stoch_signal_array, true);
        
        ArraySetAsSeries(m_high_array, true);
        ArraySetAsSeries(m_low_array, true);
        ArraySetAsSeries(m_close_array, true);
        ArraySetAsSeries(m_open_array, true);
        ArraySetAsSeries(m_volume_array, true);
        
        ArraySetAsSeries(m_mtf_daily_rsi_array, true);
        ArraySetAsSeries(m_mtf_h4_rsi_array, true);
        ArraySetAsSeries(m_mtf_h1_rsi_array, true);
        ArraySetAsSeries(m_mtf_daily_sma_array, true);
        ArraySetAsSeries(m_mtf_h4_sma_array, true);
    }
    
    // Cleanup indicators
    void CleanupIndicators()
    {
        if(m_rsi_handle != INVALID_HANDLE) IndicatorRelease(m_rsi_handle);
        if(m_sma_20_handle != INVALID_HANDLE) IndicatorRelease(m_sma_20_handle);
        if(m_sma_50_handle != INVALID_HANDLE) IndicatorRelease(m_sma_50_handle);
        if(m_sma_200_handle != INVALID_HANDLE) IndicatorRelease(m_sma_200_handle);
        if(m_atr_handle != INVALID_HANDLE) IndicatorRelease(m_atr_handle);
        if(m_bb_handle != INVALID_HANDLE) IndicatorRelease(m_bb_handle);
        if(m_macd_handle != INVALID_HANDLE) IndicatorRelease(m_macd_handle);
        if(m_stoch_handle != INVALID_HANDLE) IndicatorRelease(m_stoch_handle);
        if(m_mtf_daily_rsi != INVALID_HANDLE) IndicatorRelease(m_mtf_daily_rsi);
        if(m_mtf_h4_rsi != INVALID_HANDLE) IndicatorRelease(m_mtf_h4_rsi);
        if(m_mtf_h1_rsi != INVALID_HANDLE) IndicatorRelease(m_mtf_h1_rsi);
        if(m_mtf_daily_sma != INVALID_HANDLE) IndicatorRelease(m_mtf_daily_sma);
        if(m_mtf_h4_sma != INVALID_HANDLE) IndicatorRelease(m_mtf_h4_sma);
    }
    
    // Perform comprehensive market analysis
    SMarketAnalysis AnalyzeMarket()
    {
        SMarketAnalysis analysis;
        ZeroMemory(analysis);
        
        analysis.analysis_time = TimeCurrent();
        analysis.symbol = m_symbol;
        analysis.timeframe = m_timeframe;
        
        // Copy indicator data
        if(!CopyIndicatorData())
        {
            Print("Failed to copy indicator data");
            return analysis;
        }
        
        // Perform individual analyses
        AnalyzeTrend(analysis);
        AnalyzeVolatility(analysis);
        AnalyzeVolume(analysis);
        AnalyzeRSI(analysis);
        AnalyzeSupportResistance(analysis);
        AnalyzeMultiTimeframe(analysis);
        AnalyzeSignals(analysis);
        AssessRisk(analysis);
        GenerateRecommendations(analysis);
        
        m_last_analysis = analysis;
        
        return analysis;
    }
    
    // Copy all indicator data
    bool CopyIndicatorData()
    {
        int bars_needed = 100;
        
        // Copy main indicators
        if(CopyBuffer(m_rsi_handle, 0, 0, bars_needed, m_rsi_array) <= 0) return false;
        if(CopyBuffer(m_sma_20_handle, 0, 0, bars_needed, m_sma20_array) <= 0) return false;
        if(CopyBuffer(m_sma_50_handle, 0, 0, bars_needed, m_sma50_array) <= 0) return false;
        if(CopyBuffer(m_sma_200_handle, 0, 0, bars_needed, m_sma200_array) <= 0) return false;
        if(CopyBuffer(m_atr_handle, 0, 0, bars_needed, m_atr_array) <= 0) return false;
        if(CopyBuffer(m_bb_handle, 1, 0, bars_needed, m_bb_upper_array) <= 0) return false;
        if(CopyBuffer(m_bb_handle, 2, 0, bars_needed, m_bb_lower_array) <= 0) return false;
        if(CopyBuffer(m_macd_handle, 0, 0, bars_needed, m_macd_main_array) <= 0) return false;
        if(CopyBuffer(m_macd_handle, 1, 0, bars_needed, m_macd_signal_array) <= 0) return false;
        if(CopyBuffer(m_stoch_handle, 0, 0, bars_needed, m_stoch_main_array) <= 0) return false;
        if(CopyBuffer(m_stoch_handle, 1, 0, bars_needed, m_stoch_signal_array) <= 0) return false;
        
        // Copy price data
        if(CopyHigh(m_symbol, m_timeframe, 0, bars_needed, m_high_array) <= 0) return false;
        if(CopyLow(m_symbol, m_timeframe, 0, bars_needed, m_low_array) <= 0) return false;
        if(CopyClose(m_symbol, m_timeframe, 0, bars_needed, m_close_array) <= 0) return false;
        if(CopyOpen(m_symbol, m_timeframe, 0, bars_needed, m_open_array) <= 0) return false;
        if(CopyTickVolume(m_symbol, m_timeframe, 0, bars_needed, m_volume_array) <= 0) return false;
        
        // Copy multi-timeframe data
        if(CopyBuffer(m_mtf_daily_rsi, 0, 0, 20, m_mtf_daily_rsi_array) <= 0) return false;
        if(CopyBuffer(m_mtf_h4_rsi, 0, 0, 50, m_mtf_h4_rsi_array) <= 0) return false;
        if(CopyBuffer(m_mtf_h1_rsi, 0, 0, 100, m_mtf_h1_rsi_array) <= 0) return false;
        if(CopyBuffer(m_mtf_daily_sma, 0, 0, 20, m_mtf_daily_sma_array) <= 0) return false;
        if(CopyBuffer(m_mtf_h4_sma, 0, 0, 50, m_mtf_h4_sma_array) <= 0) return false;
        
        return true;
    }
    
    // Analyze trend
    void AnalyzeTrend(SMarketAnalysis& analysis)
    {
        double current_price = m_close_array[0];
        double sma20 = m_sma20_array[0];
        double sma50 = m_sma50_array[0];
        double sma200 = m_sma200_array[0];
        
        // Calculate trend strength
        double price_sma20_diff = (current_price - sma20) / sma20 * 100;
        double sma20_sma50_diff = (sma20 - sma50) / sma50 * 100;
        double sma50_sma200_diff = (sma50 - sma200) / sma200 * 100;
        
        analysis.trend_strength = (price_sma20_diff + sma20_sma50_diff + sma50_sma200_diff) / 3;
        
        // Determine market state
        if(current_price > sma20 && sma20 > sma50 && sma50 > sma200)
        {
            if(analysis.trend_strength > 2.0)
                analysis.market_state = MARKET_STRONG_UPTREND;
            else
                analysis.market_state = MARKET_WEAK_UPTREND;
        }
        else if(current_price < sma20 && sma20 < sma50 && sma50 < sma200)
        {
            if(analysis.trend_strength < -2.0)
                analysis.market_state = MARKET_STRONG_DOWNTREND;
            else
                analysis.market_state = MARKET_WEAK_DOWNTREND;
        }
        else
        {
            analysis.market_state = MARKET_SIDEWAYS_NEUTRAL;
        }
        
        // Calculate trend duration
        analysis.trend_duration_bars = CalculateTrendDuration();
        
        // Calculate trend angle
        analysis.trend_angle = CalculateTrendAngle();
    }
    
    // Analyze volatility
    void AnalyzeVolatility(SMarketAnalysis& analysis)
    {
        analysis.current_volatility = m_atr_array[0];
        
        // Calculate average volatility
        double sum_atr = 0;
        for(int i = 0; i < 20; i++)
        {
            sum_atr += m_atr_array[i];
        }
        analysis.avg_volatility = sum_atr / 20;
        
        // Calculate volatility percentile
        analysis.volatility_percentile = CalculateVolatilityPercentile();
        
        // Check if volatility is expanding
        analysis.volatility_expanding = (m_atr_array[0] > m_atr_array[1] && m_atr_array[1] > m_atr_array[2]);
        
        // Update market state based on volatility
        if(analysis.volatility_percentile > 80)
        {
            analysis.market_state = MARKET_HIGHLY_VOLATILE;
        }
        else if(analysis.volatility_percentile < 20)
        {
            analysis.market_state = MARKET_LOW_VOLATILITY;
        }
    }
    
    // Analyze volume
    void AnalyzeVolume(SMarketAnalysis& analysis)
    {
        long current_volume = m_volume_array[0];
        
        // Calculate average volume
        long sum_volume = 0;
        for(int i = 1; i < 20; i++)
        {
            sum_volume += m_volume_array[i];
        }
        long avg_volume = sum_volume / 19;
        
        analysis.current_volume_ratio = (double)current_volume / avg_volume;
        
        // Calculate volume trend
        long recent_avg = 0, older_avg = 0;
        for(int i = 0; i < 10; i++) recent_avg += m_volume_array[i];
        for(int i = 10; i < 20; i++) older_avg += m_volume_array[i];
        
        analysis.volume_trend = ((double)recent_avg / 10) / ((double)older_avg / 10);
        
        // Check volume confirmation
        double price_change = (m_close_array[0] - m_close_array[1]) / m_close_array[1];
        analysis.volume_confirmation = (price_change > 0 && analysis.current_volume_ratio > 1.2) ||
                                      (price_change < 0 && analysis.current_volume_ratio > 1.2);
    }
    
    // Analyze RSI
    void AnalyzeRSI(SMarketAnalysis& analysis)
    {
        analysis.rsi_value = m_rsi_array[0];
        analysis.rsi_trend = m_rsi_array[0] - m_rsi_array[1];
        analysis.rsi_oversold = (analysis.rsi_value < 30);
        analysis.rsi_overbought = (analysis.rsi_value > 70);
        
        // Check for divergences
        analysis.rsi_divergence_bullish = CheckRSIDivergence(true);
        analysis.rsi_divergence_bearish = CheckRSIDivergence(false);
    }
    
    // Analyze support and resistance
    void AnalyzeSupportResistance(SMarketAnalysis& analysis)
    {
        double current_price = m_close_array[0];
        
        // Find nearest support and resistance
        analysis.nearest_support = FindNearestSupport(current_price);
        analysis.nearest_resistance = FindNearestResistance(current_price);
        
        // Calculate strength
        analysis.support_strength = CalculateLevelStrength(analysis.nearest_support, true);
        analysis.resistance_strength = CalculateLevelStrength(analysis.nearest_resistance, false);
    }
    
    // Analyze multi-timeframe
    void AnalyzeMultiTimeframe(SMarketAnalysis& analysis)
    {
        // Analyze daily timeframe
        analysis.mtf_daily_state = AnalyzeMTFState(m_mtf_daily_rsi_array[0], m_mtf_daily_sma_array[0]);
        
        // Analyze H4 timeframe
        analysis.mtf_h4_state = AnalyzeMTFState(m_mtf_h4_rsi_array[0], m_mtf_h4_sma_array[0]);
        
        // Analyze H1 timeframe
        analysis.mtf_h1_state = AnalyzeMTFState(m_mtf_h1_rsi_array[0], 0); // Simplified
        
        // Check alignment
        analysis.mtf_alignment = CheckMTFAlignment(analysis);
    }
    
    // Analyze signals
    void AnalyzeSignals(SMarketAnalysis& analysis)
    {
        analysis.signal_count = 0;
        
        // RSI signals
        if(analysis.rsi_oversold && analysis.rsi_trend > 0)
        {
            analysis.buy_signal_strength = SIGNAL_MODERATE;
            analysis.signal_reasons[analysis.signal_count++] = "RSI Oversold + Rising";
        }
        
        if(analysis.rsi_overbought && analysis.rsi_trend < 0)
        {
            analysis.sell_signal_strength = SIGNAL_MODERATE;
            analysis.signal_reasons[analysis.signal_count++] = "RSI Overbought + Falling";
        }
        
        // MACD signals
        if(m_macd_main_array[0] > m_macd_signal_array[0] && m_macd_main_array[1] <= m_macd_signal_array[1])
        {
            if(analysis.buy_signal_strength < SIGNAL_MODERATE)
                analysis.buy_signal_strength = SIGNAL_MODERATE;
            else
                analysis.buy_signal_strength = SIGNAL_STRONG;
            analysis.signal_reasons[analysis.signal_count++] = "MACD Bullish Crossover";
        }
        
        // Volume confirmation
        if(analysis.volume_confirmation)
        {
            if(analysis.buy_signal_strength > SIGNAL_NONE)
                analysis.buy_signal_strength = (ENUM_SIGNAL_STRENGTH)(analysis.buy_signal_strength + 1);
            if(analysis.sell_signal_strength > SIGNAL_NONE)
                analysis.sell_signal_strength = (ENUM_SIGNAL_STRENGTH)(analysis.sell_signal_strength + 1);
            analysis.signal_reasons[analysis.signal_count++] = "Volume Confirmation";
        }
        
        // Calculate overall confidence
        analysis.signal_confidence = CalculateSignalConfidence(analysis);
    }
    
    // Assess risk
    void AssessRisk(SMarketAnalysis& analysis)
    {
        analysis.risk_factor_count = 0;
        analysis.market_risk_level = 0;
        
        // Volatility risk
        if(analysis.volatility_percentile > 80)
        {
            analysis.market_risk_level += 25;
            analysis.risk_factors[analysis.risk_factor_count++] = "High Volatility";
        }
        
        // Trend risk
        if(analysis.market_state == MARKET_SIDEWAYS_NEUTRAL)
        {
            analysis.market_risk_level += 15;
            analysis.risk_factors[analysis.risk_factor_count++] = "Sideways Market";
        }
        
        // Volume risk
        if(analysis.current_volume_ratio < 0.5)
        {
            analysis.market_risk_level += 10;
            analysis.risk_factors[analysis.risk_factor_count++] = "Low Volume";
        }
        
        // Multi-timeframe risk
        if(!analysis.mtf_alignment)
        {
            analysis.market_risk_level += 20;
            analysis.risk_factors[analysis.risk_factor_count++] = "MTF Misalignment";
        }
        
        // Support/Resistance risk
        double current_price = m_close_array[0];
        if(MathAbs(current_price - analysis.nearest_resistance) / current_price < 0.01)
        {
            analysis.market_risk_level += 15;
            analysis.risk_factors[analysis.risk_factor_count++] = "Near Resistance";
        }
    }
    
    // Generate trading recommendations
    void GenerateRecommendations(SMarketAnalysis& analysis)
    {
        analysis.recommend_long = false;
        analysis.recommend_short = false;
        analysis.recommend_wait = false;
        
        // Basic recommendation logic
        if(analysis.buy_signal_strength >= SIGNAL_MODERATE && analysis.market_risk_level < 50)
        {
            analysis.recommend_long = true;
            analysis.recommended_position_size = CalculatePositionSize(analysis);
            analysis.recommended_stop_loss = CalculateStopLoss(analysis, true);
            analysis.recommended_take_profit = CalculateTakeProfit(analysis, true);
        }
        else if(analysis.sell_signal_strength >= SIGNAL_MODERATE && analysis.market_risk_level < 50)
        {
            analysis.recommend_short = true;
            analysis.recommended_position_size = CalculatePositionSize(analysis);
            analysis.recommended_stop_loss = CalculateStopLoss(analysis, false);
            analysis.recommended_take_profit = CalculateTakeProfit(analysis, false);
        }
        else
        {
            analysis.recommend_wait = true;
        }
    }
    
    // Helper methods (simplified implementations)
    int CalculateTrendDuration() { return 10; } // Placeholder
    double CalculateTrendAngle() { return 0; } // Placeholder
    double CalculateVolatilityPercentile() { return 50; } // Placeholder
    bool CheckRSIDivergence(bool bullish) { return false; } // Placeholder
    double FindNearestSupport(double price) { return price * 0.98; } // Placeholder
    double FindNearestResistance(double price) { return price * 1.02; } // Placeholder
    double CalculateLevelStrength(double level, bool is_support) { return 50; } // Placeholder
    ENUM_MARKET_STATE AnalyzeMTFState(double rsi, double sma) { return MARKET_SIDEWAYS_NEUTRAL; } // Placeholder
    bool CheckMTFAlignment(SMarketAnalysis& analysis) { return true; } // Placeholder
    double CalculateSignalConfidence(SMarketAnalysis& analysis) { return 70; } // Placeholder
    double CalculatePositionSize(SMarketAnalysis& analysis) { return 0.1; } // Placeholder
    double CalculateStopLoss(SMarketAnalysis& analysis, bool is_long) { return m_close_array[0] * (is_long ? 0.98 : 1.02); }
    double CalculateTakeProfit(SMarketAnalysis& analysis, bool is_long) { return m_close_array[0] * (is_long ? 1.04 : 0.96); }
    
    // Print analysis report
    void PrintAnalysisReport(SMarketAnalysis& analysis)
    {
        Print("=== MARKET ANALYSIS REPORT ===");
        Print("Symbol: ", analysis.symbol);
        Print("Time: ", TimeToString(analysis.analysis_time));
        Print("Market State: ", EnumToString(analysis.market_state));
        Print("Trend Strength: ", DoubleToString(analysis.trend_strength, 2));
        Print("RSI: ", DoubleToString(analysis.rsi_value, 1));
        Print("Volatility Percentile: ", DoubleToString(analysis.volatility_percentile, 1));
        Print("Volume Ratio: ", DoubleToString(analysis.current_volume_ratio, 2));
        Print("Risk Level: ", DoubleToString(analysis.market_risk_level, 0), "%");
        Print("Buy Signal: ", EnumToString(analysis.buy_signal_strength));
        Print("Sell Signal: ", EnumToString(analysis.sell_signal_strength));
        Print("Recommendation: ", 
              analysis.recommend_long ? "LONG" : 
              analysis.recommend_short ? "SHORT" : "WAIT");
        Print("Signal Confidence: ", DoubleToString(analysis.signal_confidence, 1), "%");
        Print("================================");
    }
    
    // Get last analysis
    SMarketAnalysis GetLastAnalysis() { return m_last_analysis; }
    
    // Quick analysis methods
    bool IsMarketBullish() 
    { 
        return (m_last_analysis.market_state == MARKET_STRONG_UPTREND || 
                m_last_analysis.market_state == MARKET_WEAK_UPTREND); 
    }
    
    bool IsMarketBearish() 
    { 
        return (m_last_analysis.market_state == MARKET_STRONG_DOWNTREND || 
                m_last_analysis.market_state == MARKET_WEAK_DOWNTREND); 
    }
    
    bool IsHighRisk() { return m_last_analysis.market_risk_level > 70; }
    bool HasBuySignal() { return m_last_analysis.buy_signal_strength >= SIGNAL_MODERATE; }
    bool HasSellSignal() { return m_last_analysis.sell_signal_strength >= SIGNAL_MODERATE; }
};

//+------------------------------------------------------------------+
//| Global market analyzer instance                                 |
//+------------------------------------------------------------------+
CMarketAnalyzer* g_market_analyzer = NULL;

//+------------------------------------------------------------------+
//| Initialize market analyzer                                      |
//+------------------------------------------------------------------+
bool InitMarketAnalyzer(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
    if(g_market_analyzer == NULL)
    {
        g_market_analyzer = new CMarketAnalyzer(symbol, timeframe);
        return (g_market_analyzer != NULL);
    }
    return true;
}

//+------------------------------------------------------------------+
//| Cleanup market analyzer                                        |
//+------------------------------------------------------------------+
void DeinitMarketAnalyzer()
{
    if(g_market_analyzer != NULL)
    {
        delete g_market_analyzer;
        g_market_analyzer = NULL;
    }
}

//+------------------------------------------------------------------+
//| Get global market analyzer                                     |
//+------------------------------------------------------------------+
CMarketAnalyzer* GetMarketAnalyzer()
{
    return g_market_analyzer;
}

//+------------------------------------------------------------------+
//| Quick analysis function                                        |
//+------------------------------------------------------------------+
SMarketAnalysis QuickMarketAnalysis()
{
    SMarketAnalysis empty_analysis;
    ZeroMemory(empty_analysis);
    
    if(g_market_analyzer != NULL)
        return g_market_analyzer.AnalyzeMarket();
        
    return empty_analysis;
}
