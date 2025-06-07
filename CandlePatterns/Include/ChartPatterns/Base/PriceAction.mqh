//+------------------------------------------------------------------+
//|                                                  PriceAction.mqh |
//|                                    تحليل حركة السعر             |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "ChartUtils.mqh"

//+------------------------------------------------------------------+
//| تعدادات تحليل حركة السعر                                        |
//+------------------------------------------------------------------+
enum ENUM_PRICE_ACTION_TYPE
{
   PA_BREAKOUT,             // اختراق
   PA_PULLBACK,             // تراجع
   PA_REVERSAL,             // انعكاس
   PA_CONTINUATION,         // استمرار
   PA_CONSOLIDATION,        // توطيد
   PA_EXPANSION,            // توسع
   PA_COMPRESSION,          // انضغاط
   PA_MOMENTUM_SHIFT        // تغير في الزخم
};

enum ENUM_MARKET_STRUCTURE
{
   STRUCTURE_UPTREND,       // اتجاه صاعد
   STRUCTURE_DOWNTREND,     // اتجاه هابط
   STRUCTURE_SIDEWAYS,      // حركة جانبية
   STRUCTURE_TRANSITION,    // مرحلة انتقال
   STRUCTURE_UNDEFINED      // غير محدد
};

enum ENUM_PRICE_MOMENTUM
{
   MOMENTUM_STRONG_BULLISH, // زخم صعودي قوي
   MOMENTUM_WEAK_BULLISH,   // زخم صعودي ضعيف
   MOMENTUM_NEUTRAL,        // زخم محايد
   MOMENTUM_WEAK_BEARISH,   // زخم هبوطي ضعيف
   MOMENTUM_STRONG_BEARISH  // زخم هبوطي قوي
};

//+------------------------------------------------------------------+
//| هيكل تحليل حركة السعر                                           |
//+------------------------------------------------------------------+
struct SPriceActionAnalysis
{
   ENUM_PRICE_ACTION_TYPE actionType;    // نوع حركة السعر
   ENUM_MARKET_STRUCTURE structure;      // هيكل السوق
   ENUM_PRICE_MOMENTUM momentum;         // الزخم
   
   double            strength;           // قوة حركة السعر (0-1)
   double            velocity;           // سرعة الحركة
   double            acceleration;       // التسارع
   
   SChartPoint       keyLevels[];        // المستويات الرئيسية
   STrendLine        trendLines[];       // خطوط الاتجاه
   
   double            supportLevel;       // مستوى الدعم الحالي
   double            resistanceLevel;    // مستوى المقاومة الحالي
   
   bool              isBreakout;         // هناك اختراق
   bool              isPullback;         // هناك تراجع
   bool              isReversal;         // هناك انعكاس
   
   datetime          analysisTime;       // وقت التحليل
   string            description;        // وصف التحليل
   
   SPriceActionAnalysis()
   {
      actionType = PA_CONSOLIDATION;
      structure = STRUCTURE_UNDEFINED;
      momentum = MOMENTUM_NEUTRAL;
      
      strength = 0.0;
      velocity = 0.0;
      acceleration = 0.0;
      
      ArrayResize(keyLevels, 0);
      ArrayResize(trendLines, 0);
      
      supportLevel = 0.0;
      resistanceLevel = 0.0;
      
      isBreakout = false;
      isPullback = false;
      isReversal = false;
      
      analysisTime = 0;
      description = "";
   }
};

//+------------------------------------------------------------------+
//| هيكل إحصائيات الشموع                                           |
//+------------------------------------------------------------------+
struct SCandleStatistics
{
   int               totalCandles;       // إجمالي الشموع
   int               bullishCandles;     // الشموع الصعودية
   int               bearishCandles;     // الشموع الهبوطية
   int               dojiCandles;        // شموع الدوجي
   
   double            avgBodySize;        // متوسط حجم الجسم
   double            avgUpperShadow;     // متوسط الظل العلوي
   double            avgLowerShadow;     // متوسط الظل السفلي
   double            avgRange;           // متوسط المدى
   
   double            bodyToRangeRatio;   // نسبة الجسم للمدى
   double            shadowToBodyRatio;  // نسبة الظلال للجسم
   
   int               consecutiveBullish; // الشموع الصعودية المتتالية
   int               consecutiveBearish; // الشموع الهبوطية المتتالية
   
   SCandleStatistics()
   {
      totalCandles = 0;
      bullishCandles = 0;
      bearishCandles = 0;
      dojiCandles = 0;
      
      avgBodySize = 0.0;
      avgUpperShadow = 0.0;
      avgLowerShadow = 0.0;
      avgRange = 0.0;
      
      bodyToRangeRatio = 0.0;
      shadowToBodyRatio = 0.0;
      
      consecutiveBullish = 0;
      consecutiveBearish = 0;
   }
};

//+------------------------------------------------------------------+
//| فئة تحليل حركة السعر                                            |
//+------------------------------------------------------------------+
class CPriceAction
{
private:
   // إعدادات المحلل
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   bool              m_initialized;
   
   // معاملات التحليل
   int               m_analysisPeriod;      // فترة التحليل
   double            m_breakoutThreshold;   // عتبة الاختراق
   double            m_momentumThreshold;   // عتبة الزخم
   int               m_trendPeriod;         // فترة تحديد الاتجاه
   
   // بيانات التحليل الحالي
   SPriceActionAnalysis m_currentAnalysis;
   SCandleStatistics    m_candleStats;
   
   // البيانات التاريخية
   SPriceActionAnalysis m_historicalAnalysis[];
   
   // أدوات مساعدة
   CChartUtils      *m_chartUtils;
   
public:
   // المنشئ والهادم
                     CPriceAction();
                     ~CPriceAction();
   
   // تهيئة المحلل
   bool              Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   void              Deinitialize();
   
   // إعداد المعاملات
   void              SetAnalysisParameters(const int analysisPeriod, const double breakoutThreshold,
                                         const double momentumThreshold, const int trendPeriod);
   
   // التحليل الرئيسي
   SPriceActionAnalysis AnalyzePriceAction(const int startIdx, const int endIdx,
                                          const double &open[], const double &high[],
                                          const double &low[], const double &close[],
                                          const long &volume[]);
   
   // تحليل هيكل السوق
   ENUM_MARKET_STRUCTURE AnalyzeMarketStructure(const int startIdx, const int endIdx,
                                               const double &high[], const double &low[]);
   
   // تحليل الزخم
   ENUM_PRICE_MOMENTUM AnalyzeMomentum(const int startIdx, const int endIdx,
                                      const double &close[], const long &volume[]);
   
   // تحليل الاختراقات
   bool              DetectBreakout(const int idx, const double &high[], const double &low[],
                                  const long &volume[], double &breakoutLevel);
   
   bool              IsValidBreakout(const double currentPrice, const double breakoutLevel,
                                   const long currentVolume, const long avgVolume);
   
   // تحليل التراجعات
   bool              DetectPullback(const int startIdx, const int endIdx,
                                  const double &high[], const double &low[]);
   
   // تحليل الانعكاسات
   bool              DetectReversal(const int startIdx, const int endIdx,
                                  const double &open[], const double &high[],
                                  const double &low[], const double &close[]);
   
   // تحليل التوطيد
   bool              DetectConsolidation(const int startIdx, const int endIdx,
                                       const double &high[], const double &low[]);
   
   // تحليل الشموع
   SCandleStatistics AnalyzeCandlePatterns(const int startIdx, const int endIdx,
                                         const double &open[], const double &high[],
                                         const double &low[], const double &close[]);
   
   // حساب مؤشرات حركة السعر
   double            CalculatePriceVelocity(const int period, const double &close[]);
   double            CalculatePriceAcceleration(const int period, const double &close[]);
   double            CalculateVolatilityExpansion(const int period, const double &high[], 
                                                const double &low[]);
   
   // تحليل مستويات الدعم والمقاومة
   bool              FindCurrentSupportResistance(const int startIdx, const int endIdx,
                                                const double &high[], const double &low[],
                                                double &support, double &resistance);
   
   // تحليل القوة والضعف
   double            CalculateBullishStrength(const int period, const double &open[],
                                           const double &high[], const double &close[]);
   
   double            CalculateBearishStrength(const int period, const double &open[],
                                            const double &low[], const double &close[]);
   
   // تحليل الحجم
   bool              AnalyzeVolumeConfirmation(const int idx, const double &prices[],
                                             const long &volume[]);
   
   double            CalculateVolumePressure(const int period, const double &close[],
                                           const long &volume[]);
   
   // تحليل الوقت والدورات
   bool              DetectTimeBasedPatterns(const int startIdx, const int endIdx,
                                           const datetime &time[]);
   
   // دوال التنبؤ
   ENUM_PATTERN_DIRECTION PredictNextMove(const SPriceActionAnalysis &analysis);
   double            EstimateTargetPrice(const SPriceActionAnalysis &analysis, 
                                       const double currentPrice);
   
   // الوصول للبيانات
   SPriceActionAnalysis GetCurrentAnalysis() const { return m_currentAnalysis; }
   SCandleStatistics GetCandleStatistics() const { return m_candleStats; }
   int               GetHistoricalAnalysisCount() const { return ArraySize(m_historicalAnalysis); }
   SPriceActionAnalysis GetHistoricalAnalysis(const int index) const;
   
   // تقارير التحليل
   string            GenerateAnalysisReport(const SPriceActionAnalysis &analysis);
   string            GenerateCandleReport(const SCandleStatistics &stats);
   
protected:
   // دوال مساعدة
   bool              IsUptrend(const double &highs[], const double &lows[], const int period);
   bool              IsDowntrend(const double &highs[], const double &lows[], const int period);
   
   double            CalculateATR(const int period, const double &high[], 
                                const double &low[], const double &close[]);
   
   bool              IsDoji(const int idx, const double &open[], const double &close[]);
   bool              IsEngulfing(const int idx, const double &open[], const double &close[]);
   
   // تحديث التحليل
   void              UpdateAnalysisHistory();
   void              SaveAnalysisToHistory(const SPriceActionAnalysis &analysis);
   
   // إحصائيات
   void              UpdateStatistics(const SPriceActionAnalysis &analysis);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CPriceAction::CPriceAction()
{
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_initialized = false;
   
   // المعاملات الافتراضية
   m_analysisPeriod = 20;
   m_breakoutThreshold = 0.002; // 0.2%
   m_momentumThreshold = 0.05;
   m_trendPeriod = 10;
   
   m_chartUtils = NULL;
   
   ArrayResize(m_historicalAnalysis, 0);
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CPriceAction::~CPriceAction()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة المحلل                                                     |
//+------------------------------------------------------------------+
bool CPriceAction::Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   m_symbol = (symbol == "") ? Symbol() : symbol;
   m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
   
   // إنشاء أدوات المخططات
   m_chartUtils = new CChartUtils();
   if(!m_chartUtils.Initialize(m_symbol, m_timeframe))
   {
      Print("خطأ في تهيئة أدوات المخططات لتحليل حركة السعر");
      return false;
   }
   
   m_initialized = true;
   Print("تم تهيئة محلل حركة السعر للرمز: ", m_symbol, " الإطار الزمني: ", EnumToString(m_timeframe));
   
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء المحلل                                                    |
//+------------------------------------------------------------------+
void CPriceAction::Deinitialize()
{
   if(m_initialized)
   {
      if(m_chartUtils != NULL)
      {
         delete m_chartUtils;
         m_chartUtils = NULL;
      }
      
      ArrayFree(m_historicalAnalysis);
      m_initialized = false;
   }
}

//+------------------------------------------------------------------+
//| تحديد معاملات التحليل                                           |
//+------------------------------------------------------------------+
void CPriceAction::SetAnalysisParameters(const int analysisPeriod, const double breakoutThreshold,
                                         const double momentumThreshold, const int trendPeriod)
{
   m_analysisPeriod = MathMax(5, analysisPeriod);
   m_breakoutThreshold = MathMax(0.001, breakoutThreshold);
   m_momentumThreshold = MathMax(0.01, momentumThreshold);
   m_trendPeriod = MathMax(3, trendPeriod);
}

//+------------------------------------------------------------------+
//| التحليل الرئيسي لحركة السعر                                     |
//+------------------------------------------------------------------+
SPriceActionAnalysis CPriceAction::AnalyzePriceAction(const int startIdx, const int endIdx,
                                                     const double &open[], const double &high[],
                                                     const double &low[], const double &close[],
                                                     const long &volume[])
{
   SPriceActionAnalysis analysis;
   
   if(!m_initialized || startIdx >= endIdx)
      return analysis;
   
   analysis.analysisTime = TimeCurrent();
   
   // تحليل هيكل السوق
   analysis.structure = AnalyzeMarketStructure(startIdx, endIdx, high, low);
   
   // تحليل الزخم
   analysis.momentum = AnalyzeMomentum(startIdx, endIdx, close, volume);
   
   // البحث عن المستويات الرئيسية
   FindCurrentSupportResistance(startIdx, endIdx, high, low, 
                               analysis.supportLevel, analysis.resistanceLevel);
   
   // كشف أنواع حركة السعر
   double breakoutLevel;
   analysis.isBreakout = DetectBreakout(endIdx, high, low, volume, breakoutLevel);
   analysis.isPullback = DetectPullback(startIdx, endIdx, high, low);
   analysis.isReversal = DetectReversal(startIdx, endIdx, open, high, low, close);
   
   // تحديد نوع حركة السعر الرئيسي
   if(analysis.isBreakout)
      analysis.actionType = PA_BREAKOUT;
   else if(analysis.isPullback)
      analysis.actionType = PA_PULLBACK;
   else if(analysis.isReversal)
      analysis.actionType = PA_REVERSAL;
   else if(DetectConsolidation(startIdx, endIdx, high, low))
      analysis.actionType = PA_CONSOLIDATION;
   else
      analysis.actionType = PA_CONTINUATION;
   
   // حساب مؤشرات الحركة
   analysis.velocity = CalculatePriceVelocity(m_analysisPeriod, close);
   analysis.acceleration = CalculatePriceAcceleration(m_analysisPeriod, close);
   
   // حساب قوة حركة السعر
   double bullishStrength = CalculateBullishStrength(m_analysisPeriod, open, high, close);
   double bearishStrength = CalculateBearishStrength(m_analysisPeriod, open, low, close);
   analysis.strength = MathMax(bullishStrength, bearishStrength);
   
   // تحليل الشموع
   m_candleStats = AnalyzeCandlePatterns(startIdx, endIdx, open, high, low, close);
   
   // وصف التحليل
   analysis.description = "تحليل حركة السعر - " + EnumToString(analysis.actionType) + 
                         " | هيكل: " + EnumToString(analysis.structure) + 
                         " | زخم: " + EnumToString(analysis.momentum);
   
   // حفظ التحليل
   m_currentAnalysis = analysis;
   SaveAnalysisToHistory(analysis);
   
   return analysis;
}

//+------------------------------------------------------------------+
//| تحليل هيكل السوق                                                |
//+------------------------------------------------------------------+
ENUM_MARKET_STRUCTURE CPriceAction::AnalyzeMarketStructure(const int startIdx, const int endIdx,
                                                          const double &high[], const double &low[])
{
   if(endIdx - startIdx < m_trendPeriod)
      return STRUCTURE_UNDEFINED;
   
   // تحليل القمم والقيعان
   SChartPoint swingHighs[], swingLows[];
   m_chartUtils.FindSwingHighs(startIdx, endIdx, 3, high, swingHighs);
   m_chartUtils.FindSwingLows(startIdx, endIdx, 3, low, swingLows);
   
   if(ArraySize(swingHighs) < 2 || ArraySize(swingLows) < 2)
      return STRUCTURE_UNDEFINED;
   
   // فحص اتجاه القمم والقيعان
   bool higherHighs = (swingHighs[ArraySize(swingHighs)-1].price > swingHighs[ArraySize(swingHighs)-2].price);
   bool higherLows = (swingLows[ArraySize(swingLows)-1].price > swingLows[ArraySize(swingLows)-2].price);
   bool lowerHighs = (swingHighs[ArraySize(swingHighs)-1].price < swingHighs[ArraySize(swingHighs)-2].price);
   bool lowerLows = (swingLows[ArraySize(swingLows)-1].price < swingLows[ArraySize(swingLows)-2].price);
   
   // تحديد هيكل السوق
   if(higherHighs && higherLows)
      return STRUCTURE_UPTREND;
   else if(lowerHighs && lowerLows)
      return STRUCTURE_DOWNTREND;
   else if((higherHighs && lowerLows) || (lowerHighs && higherLows))
      return STRUCTURE_TRANSITION;
   else
      return STRUCTURE_SIDEWAYS;
}

//+------------------------------------------------------------------+
//| تحليل الزخم                                                     |
//+------------------------------------------------------------------+
ENUM_PRICE_MOMENTUM CPriceAction::AnalyzeMomentum(const int startIdx, const int endIdx,
                                                 const double &close[], const long &volume[])
{
   if(endIdx - startIdx < 5)
      return MOMENTUM_NEUTRAL;
   
   // حساب تغير السعر
   double priceChange = (close[endIdx] - close[endIdx - 5]) / close[endIdx - 5];
   
   // حساب تغير الحجم
   double avgVolume1 = 0, avgVolume2 = 0;
   for(int i = endIdx - 4; i <= endIdx; i++)
      avgVolume1 += volume[i];
   for(int i = endIdx - 9; i <= endIdx - 5; i++)
      avgVolume2 += volume[i];
   
   avgVolume1 /= 5;
   avgVolume2 /= 5;
   
   double volumeChange = (avgVolume2 > 0) ? (avgVolume1 - avgVolume2) / avgVolume2 : 0;
   
   // تحديد الزخم
   if(priceChange > m_momentumThreshold && volumeChange > 0.2)
      return MOMENTUM_STRONG_BULLISH;
   else if(priceChange > m_momentumThreshold * 0.5)
      return MOMENTUM_WEAK_BULLISH;
   else if(priceChange < -m_momentumThreshold && volumeChange > 0.2)
      return MOMENTUM_STRONG_BEARISH;
   else if(priceChange < -m_momentumThreshold * 0.5)
      return MOMENTUM_WEAK_BEARISH;
   else
      return MOMENTUM_NEUTRAL;
}

//+------------------------------------------------------------------+
//| كشف الاختراق                                                    |
//+------------------------------------------------------------------+
bool CPriceAction::DetectBreakout(const int idx, const double &high[], const double &low[],
                                 const long &volume[], double &breakoutLevel)
{
   if(idx < 10)
      return false;
   
   // البحث عن مستوى مقاومة أو دعم حديث
   double recentHigh = high[idx-1];
   double recentLow = low[idx-1];
   
   for(int i = idx - 10; i < idx; i++)
   {
      if(high[i] > recentHigh)
         recentHigh = high[i];
      if(low[i] < recentLow)
         recentLow = low[i];
   }
   
   // فحص الاختراق الصعودي
   if(high[idx] > recentHigh * (1 + m_breakoutThreshold))
   {
      breakoutLevel = recentHigh;
      return IsValidBreakout(high[idx], breakoutLevel, volume[idx], 
                           m_chartUtils.CalculateAverageVolume(idx - 10, 10, volume));
   }
   
   // فحص الاختراق الهبوطي
   if(low[idx] < recentLow * (1 - m_breakoutThreshold))
   {
      breakoutLevel = recentLow;
      return IsValidBreakout(low[idx], breakoutLevel, volume[idx],
                           m_chartUtils.CalculateAverageVolume(idx - 10, 10, volume));
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| التحقق من صحة الاختراق                                          |
//+------------------------------------------------------------------+
bool CPriceAction::IsValidBreakout(const double currentPrice, const double breakoutLevel,
                                  const long currentVolume, const long avgVolume)
{
   // فحص قوة الاختراق
   double breakoutStrength = MathAbs(currentPrice - breakoutLevel) / breakoutLevel;
   if(breakoutStrength < m_breakoutThreshold)
      return false;
   
   // فحص تأكيد الحجم
   if(currentVolume < avgVolume * 1.2) // حجم أعلى من المتوسط بـ 20%
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف التراجع                                                     |
//+------------------------------------------------------------------+
bool CPriceAction::DetectPullback(const int startIdx, const int endIdx,
                                 const double &high[], const double &low[])
{
   if(endIdx - startIdx < 6)
      return false;
   
   // البحث عن حركة في اتجاه ثم عكس جزئي
   bool hadUpMove = false;
   bool hadDownMove = false;
   
   // فحص الحركة الأولى (صعودية)
   if(high[endIdx - 3] > high[startIdx] * 1.01) // صعود 1%
      hadUpMove = true;
   
   // فحص الحركة الثانية (هبوطية - تراجع)
   if(hadUpMove && low[endIdx] < high[endIdx - 3] * 0.99) // تراجع 1%
      hadDownMove = true;
   
   // فحص الحركة الأولى (هبوطية)
   if(low[endIdx - 3] < low[startIdx] * 0.99) // هبوط 1%
      hadDownMove = true;
   
   // فحص الحركة الثانية (صعودية - تراجع)
   if(hadDownMove && high[endIdx] > low[endIdx - 3] * 1.01) // تراجع صعودي 1%
      hadUpMove = true;
   
   return (hadUpMove && hadDownMove);
}

//+------------------------------------------------------------------+
//| كشف الانعكاس                                                    |
//+------------------------------------------------------------------+
bool CPriceAction::DetectReversal(const int startIdx, const int endIdx,
                                 const double &open[], const double &high[],
                                 const double &low[], const double &close[])
{
   if(endIdx - startIdx < 5)
      return false;
   
   // فحص تغير في اتجاه الشموع
   int bullishCount = 0;
   int bearishCount = 0;
   
   // عد الشموع في النصف الأول
   for(int i = startIdx; i < startIdx + (endIdx - startIdx) / 2; i++)
   {
      if(close[i] > open[i])
         bullishCount++;
      else if(close[i] < open[i])
         bearishCount++;
   }
   
   // عد الشموع في النصف الثاني
   int bullishCount2 = 0;
   int bearishCount2 = 0;
   
   for(int i = startIdx + (endIdx - startIdx) / 2; i <= endIdx; i++)
   {
      if(close[i] > open[i])
         bullishCount2++;
      else if(close[i] < open[i])
         bearishCount2++;
   }
   
   // فحص انعكاس من هبوطي لصعودي
   if(bearishCount > bullishCount && bullishCount2 > bearishCount2)
      return true;
   
   // فحص انعكاس من صعودي لهبوطي
   if(bullishCount > bearishCount && bearishCount2 > bullishCount2)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف التوطيد                                                     |
//+------------------------------------------------------------------+
bool CPriceAction::DetectConsolidation(const int startIdx, const int endIdx,
                                      const double &high[], const double &low[])
{
   if(endIdx - startIdx < 5)
      return false;
   
   // حساب المدى العام
   double maxHigh = high[startIdx];
   double minLow = low[startIdx];
   
   for(int i = startIdx + 1; i <= endIdx; i++)
   {
      if(high[i] > maxHigh)
         maxHigh = high[i];
      if(low[i] < minLow)
         minLow = low[i];
   }
   
   double totalRange = maxHigh - minLow;
   
   // حساب متوسط المدى اليومي
   double avgDailyRange = 0;
   for(int i = startIdx; i <= endIdx; i++)
      avgDailyRange += (high[i] - low[i]);
   
   avgDailyRange /= (endIdx - startIdx + 1);
   
   // التوطيد عندما يكون المدى العام صغير نسبة للمدى اليومي
   return (totalRange < avgDailyRange * 2.5);
}

//+------------------------------------------------------------------+
//| تحليل أنماط الشموع                                              |
//+------------------------------------------------------------------+
SCandleStatistics CPriceAction::AnalyzeCandlePatterns(const int startIdx, const int endIdx,
                                                     const double &open[], const double &high[],
                                                     const double &low[], const double &close[])
{
   SCandleStatistics stats;
   
   stats.totalCandles = endIdx - startIdx + 1;
   
   double totalBodySize = 0;
   double totalUpperShadow = 0;
   double totalLowerShadow = 0;
   double totalRange = 0;
   
   int currentBullish = 0;
   int currentBearish = 0;
   
   for(int i = startIdx; i <= endIdx; i++)
   {
      double bodySize = MathAbs(close[i] - open[i]);
      double upperShadow = high[i] - MathMax(open[i], close[i]);
      double lowerShadow = MathMin(open[i], close[i]) - low[i];
      double range = high[i] - low[i];
      
      totalBodySize += bodySize;
      totalUpperShadow += upperShadow;
      totalLowerShadow += lowerShadow;
      totalRange += range;
      
      // تصنيف الشمعة
      if(close[i] > open[i])
      {
         stats.bullishCandles++;
         currentBullish++;
         currentBearish = 0;
      }
      else if(close[i] < open[i])
      {
         stats.bearishCandles++;
         currentBearish++;
         currentBullish = 0;
      }
      else
      {
         stats.dojiCandles++;
         currentBullish = 0;
         currentBearish = 0;
      }
      
      // تحديث أقصى متتالية
      if(currentBullish > stats.consecutiveBullish)
         stats.consecutiveBullish = currentBullish;
      
      if(currentBearish > stats.consecutiveBearish)
         stats.consecutiveBearish = currentBearish;
   }
   
   // حساب المتوسطات
   if(stats.totalCandles > 0)
   {
      stats.avgBodySize = totalBodySize / stats.totalCandles;
      stats.avgUpperShadow = totalUpperShadow / stats.totalCandles;
      stats.avgLowerShadow = totalLowerShadow / stats.totalCandles;
      stats.avgRange = totalRange / stats.totalCandles;
      
      if(stats.avgRange > 0)
         stats.bodyToRangeRatio = stats.avgBodySize / stats.avgRange;
      
      if(stats.avgBodySize > 0)
         stats.shadowToBodyRatio = (stats.avgUpperShadow + stats.avgLowerShadow) / stats.avgBodySize;
   }
   
   return stats;
}

//+------------------------------------------------------------------+
//| حساب سرعة السعر                                                 |
//+------------------------------------------------------------------+
double CPriceAction::CalculatePriceVelocity(const int period, const double &close[])
{
   if(period < 2)
      return 0.0;
   
   int endIdx = ArraySize(close) - 1;
   int startIdx = endIdx - period + 1;
   
   if(startIdx < 0)
      return 0.0;
   
   double priceChange = close[endIdx] - close[startIdx];
   double timeChange = period;
   
   return priceChange / timeChange; // نقاط لكل شمعة
}

//+------------------------------------------------------------------+
//| حساب تسارع السعر                                                |
//+------------------------------------------------------------------+
double CPriceAction::CalculatePriceAcceleration(const int period, const double &close[])
{
   if(period < 4)
      return 0.0;
   
   int endIdx = ArraySize(close) - 1;
   
   // حساب السرعة للفترة الأخيرة
   double velocity1 = CalculatePriceVelocity(period / 2, close);
   
   // حساب السرعة للفترة السابقة
   double tempClose[];
   int tempSize = endIdx - period / 2 + 1;
   ArrayResize(tempClose, tempSize);
   
   for(int i = 0; i < tempSize; i++)
      tempClose[i] = close[i];
   
   double velocity2 = CalculatePriceVelocity(period / 2, tempClose);
   
   return velocity1 - velocity2; // تغير السرعة
}

//+------------------------------------------------------------------+
//| البحث عن الدعم والمقاومة الحالي                                  |
//+------------------------------------------------------------------+
bool CPriceAction::FindCurrentSupportResistance(const int startIdx, const int endIdx,
                                               const double &high[], const double &low[],
                                               double &support, double &resistance)
{
   if(m_chartUtils == NULL)
      return false;
   
   SPriceLevel supportLevels[], resistanceLevels[];
   
   m_chartUtils.FindSupportLevels(startIdx, endIdx, low, supportLevels);
   m_chartUtils.FindResistanceLevels(startIdx, endIdx, high, resistanceLevels);
   
   // أخذ أقوى مستوى دعم ومقاومة
   if(ArraySize(supportLevels) > 0)
      support = supportLevels[0].price;
   else
      support = 0.0;
   
   if(ArraySize(resistanceLevels) > 0)
      resistance = resistanceLevels[0].price;
   else
      resistance = 0.0;
   
   return (support > 0.0 && resistance > 0.0);
}

//+------------------------------------------------------------------+
//| حساب القوة الصعودية                                             |
//+------------------------------------------------------------------+
double CPriceAction::CalculateBullishStrength(const int period, const double &open[],
                                             const double &high[], const double &close[])
{
   if(period < 1)
      return 0.0;
   
   int endIdx = ArraySize(close) - 1;
   int startIdx = MathMax(0, endIdx - period + 1);
   
   double bullishStrength = 0.0;
   int count = 0;
   
   for(int i = startIdx; i <= endIdx; i++)
   {
      if(close[i] > open[i]) // شمعة صعودية
      {
         double bodySize = close[i] - open[i];
         double upperShadow = high[i] - close[i];
         double totalRange = high[i] - open[i];
         
         if(totalRange > 0)
         {
            // القوة = حجم الجسم / (حجم الجسم + الظل العلوي)
            bullishStrength += bodySize / (bodySize + upperShadow + 0.0001);
            count++;
         }
      }
   }
   
   return (count > 0) ? bullishStrength / count : 0.0;
}

//+------------------------------------------------------------------+
//| حساب القوة الهبوطية                                             |
//+------------------------------------------------------------------+
double CPriceAction::CalculateBearishStrength(const int period, const double &open[],
                                             const double &low[], const double &close[])
{
   if(period < 1)
      return 0.0;
   
   int endIdx = ArraySize(close) - 1;
   int startIdx = MathMax(0, endIdx - period + 1);
   
   double bearishStrength = 0.0;
   int count = 0;
   
   for(int i = startIdx; i <= endIdx; i++)
   {
      if(close[i] < open[i]) // شمعة هبوطية
      {
         double bodySize = open[i] - close[i];
         double lowerShadow = close[i] - low[i];
         double totalRange = open[i] - low[i];
         
         if(totalRange > 0)
         {
            // القوة = حجم الجسم / (حجم الجسم + الظل السفلي)
            bearishStrength += bodySize / (bodySize + lowerShadow + 0.0001);
            count++;
         }
      }
   }
   
   return (count > 0) ? bearishStrength / count : 0.0;
}

//+------------------------------------------------------------------+
//| تحليل تأكيد الحجم                                               |
//+------------------------------------------------------------------+
bool CPriceAction::AnalyzeVolumeConfirmation(const int idx, const double &prices[],
                                            const long &volume[])
{
   if(idx < 5 || m_chartUtils == NULL)
      return false;
   
   double avgVolume = m_chartUtils.CalculateAverageVolume(idx - 5, 5, volume);
   
   // تأكيد الحجم عند الحركة القوية
   if(volume[idx] > avgVolume * 1.5)
   {
      double priceChange = MathAbs(prices[idx] - prices[idx - 1]) / prices[idx - 1];
      if(priceChange > 0.01) // حركة أكبر من 1%
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| التنبؤ بالحركة التالية                                          |
//+------------------------------------------------------------------+
ENUM_PATTERN_DIRECTION CPriceAction::PredictNextMove(const SPriceActionAnalysis &analysis)
{
   // التنبؤ بناءً على نوع حركة السعر
   switch(analysis.actionType)
   {
      case PA_BREAKOUT:
         if(analysis.momentum == MOMENTUM_STRONG_BULLISH)
            return PATTERN_BULLISH;
         else if(analysis.momentum == MOMENTUM_STRONG_BEARISH)
            return PATTERN_BEARISH;
         break;
         
      case PA_PULLBACK:
         // التراجع عادة يؤدي لاستمرار الاتجاه الأصلي
         if(analysis.structure == STRUCTURE_UPTREND)
            return PATTERN_BULLISH;
         else if(analysis.structure == STRUCTURE_DOWNTREND)
            return PATTERN_BEARISH;
         break;
         
      case PA_REVERSAL:
         // الانعكاس يشير لتغير الاتجاه
         if(analysis.structure == STRUCTURE_UPTREND)
            return PATTERN_BEARISH;
         else if(analysis.structure == STRUCTURE_DOWNTREND)
            return PATTERN_BULLISH;
         break;
         
      case PA_CONSOLIDATION:
         // التوطيد عادة محايد
         return PATTERN_NEUTRAL;
   }
   
   return PATTERN_NEUTRAL;
}

//+------------------------------------------------------------------+
//| تقدير السعر المستهدف                                            |
//+------------------------------------------------------------------+
double CPriceAction::EstimateTargetPrice(const SPriceActionAnalysis &analysis, 
                                        const double currentPrice)
{
   double targetPrice = currentPrice;
   
   if(analysis.supportLevel > 0 && analysis.resistanceLevel > 0)
   {
      double range = analysis.resistanceLevel - analysis.supportLevel;
      
      // تقدير بناءً على نوع الحركة
      switch(analysis.actionType)
      {
         case PA_BREAKOUT:
            if(currentPrice > analysis.resistanceLevel)
               targetPrice = analysis.resistanceLevel + range; // إسقاط المدى
            else if(currentPrice < analysis.supportLevel)
               targetPrice = analysis.supportLevel - range;
            break;
            
         case PA_PULLBACK:
            if(analysis.structure == STRUCTURE_UPTREND)
               targetPrice = analysis.resistanceLevel;
            else if(analysis.structure == STRUCTURE_DOWNTREND)
               targetPrice = analysis.supportLevel;
            break;
            
         case PA_REVERSAL:
            if(currentPrice > (analysis.supportLevel + analysis.resistanceLevel) / 2)
               targetPrice = analysis.supportLevel;
            else
               targetPrice = analysis.resistanceLevel;
            break;
      }
   }
   
   return targetPrice;
}

//+------------------------------------------------------------------+
//| توليد تقرير التحليل                                             |
//+------------------------------------------------------------------+
string CPriceAction::GenerateAnalysisReport(const SPriceActionAnalysis &analysis)
{
   string report = "=== تقرير تحليل حركة السعر ===\n";
   report += StringFormat("الوقت: %s\n", TimeToString(analysis.analysisTime));
   report += StringFormat("نوع الحركة: %s\n", EnumToString(analysis.actionType));
   report += StringFormat("هيكل السوق: %s\n", EnumToString(analysis.structure));
   report += StringFormat("الزخم: %s\n", EnumToString(analysis.momentum));
   report += StringFormat("القوة: %.2f | السرعة: %.5f | التسارع: %.5f\n", 
                         analysis.strength, analysis.velocity, analysis.acceleration);
   
   if(analysis.supportLevel > 0)
      report += StringFormat("مستوى الدعم: %.5f\n", analysis.supportLevel);
   
   if(analysis.resistanceLevel > 0)
      report += StringFormat("مستوى المقاومة: %.5f\n", analysis.resistanceLevel);
   
   report += StringFormat("اختراق: %s | تراجع: %s | انعكاس: %s\n",
                         analysis.isBreakout ? "نعم" : "لا",
                         analysis.isPullback ? "نعم" : "لا", 
                         analysis.isReversal ? "نعم" : "لا");
   
   report += StringFormat("الوصف: %s\n", analysis.description);
   
   return report;
}

//+------------------------------------------------------------------+
//| توليد تقرير الشموع                                              |
//+------------------------------------------------------------------+
string CPriceAction::GenerateCandleReport(const SCandleStatistics &stats)
{
   string report = "=== تقرير إحصائيات الشموع ===\n";
   report += StringFormat("إجمالي الشموع: %d\n", stats.totalCandles);
   report += StringFormat("صعودية: %d (%.1f%%) | هبوطية: %d (%.1f%%) | دوجي: %d (%.1f%%)\n",
                         stats.bullishCandles, 
                         stats.totalCandles > 0 ? (double)stats.bullishCandles / stats.totalCandles * 100 : 0,
                         stats.bearishCandles,
                         stats.totalCandles > 0 ? (double)stats.bearishCandles / stats.totalCandles * 100 : 0,
                         stats.dojiCandles,
                         stats.totalCandles > 0 ? (double)stats.dojiCandles / stats.totalCandles * 100 : 0);
   
   report += StringFormat("متوسط حجم الجسم: %.5f\n", stats.avgBodySize);
   report += StringFormat("متوسط الظل العلوي: %.5f\n", stats.avgUpperShadow);
   report += StringFormat("متوسط الظل السفلي: %.5f\n", stats.avgLowerShadow);
   report += StringFormat("متوسط المدى: %.5f\n", stats.avgRange);
   report += StringFormat("نسبة الجسم للمدى: %.2f\n", stats.bodyToRangeRatio);
   report += StringFormat("نسبة الظلال للجسم: %.2f\n", stats.shadowToBodyRatio);
   report += StringFormat("أقصى شموع صعودية متتالية: %d\n", stats.consecutiveBullish);
   report += StringFormat("أقصى شموع هبوطية متتالية: %d\n", stats.consecutiveBearish);
   
   return report;
}

//+------------------------------------------------------------------+
//| الحصول على تحليل تاريخي                                         |
//+------------------------------------------------------------------+
SPriceActionAnalysis CPriceAction::GetHistoricalAnalysis(const int index) const
{
   SPriceActionAnalysis emptyAnalysis;
   
   if(index < 0 || index >= ArraySize(m_historicalAnalysis))
      return emptyAnalysis;
   
   return m_historicalAnalysis[index];
}

//+------------------------------------------------------------------+
//| حفظ التحليل في التاريخ                                          |
//+------------------------------------------------------------------+
void CPriceAction::SaveAnalysisToHistory(const SPriceActionAnalysis &analysis)
{
   int size = ArraySize(m_historicalAnalysis);
   
   // الاحتفاظ بآخر 100 تحليل فقط
   if(size >= 100)
   {
      for(int i = 0; i < size - 1; i++)
         m_historicalAnalysis[i] = m_historicalAnalysis[i + 1];
      
      m_historicalAnalysis[size - 1] = analysis;
   }
   else
   {
      ArrayResize(m_historicalAnalysis, size + 1);
      m_historicalAnalysis[size] = analysis;
   }
}
