//+------------------------------------------------------------------+
//|                                            TweezerPatterns.mqh |
//|                                       أنماط الملقاط اليابانية    |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../Base/PatternDetector.mqh"
#include "../../Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط قمة الملقاط                                           |
//+------------------------------------------------------------------+
class CTweezerTop : public CPatternDetector
{
private:
   double            m_priceTolerancePercent;    // نسبة التسامح في السعر
   double            m_minBodySizeRatio;         // نسبة الحد الأدنى لحجم الجسم
   bool              m_requireOppositeColors;    // يتطلب ألوان متضادة
   bool              m_allowShadowVariation;     // يسمح بتباين الظلال
   
public:
                     CTweezerTop();
                     ~CTweezerTop();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPriceTolerancePercent(double percent) { m_priceTolerancePercent = MathMax(0.1, MathMin(2.0, percent)); }
   void              SetMinBodySizeRatio(double ratio) { m_minBodySizeRatio = MathMax(0.1, MathMin(0.8, ratio)); }
   void              SetRequireOppositeColors(bool require) { m_requireOppositeColors = require; }
   void              SetAllowShadowVariation(bool allow) { m_allowShadowVariation = allow; }
   
   // دوال مساعدة
   bool              IsValidTweezerTop(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   double            CalculateTweezerStrength(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[]);
   bool              ArePricesEqual(double price1, double price2, double tolerancePercent, double referencePrice);
};

//+------------------------------------------------------------------+
//| فئة أنماط قاع الملقاط                                           |
//+------------------------------------------------------------------+
class CTweezerBottom : public CPatternDetector
{
private:
   double            m_priceTolerancePercent;    // نسبة التسامح في السعر
   double            m_minBodySizeRatio;         // نسبة الحد الأدنى لحجم الجسم
   bool              m_requireOppositeColors;    // يتطلب ألوان متضادة
   bool              m_allowShadowVariation;     // يسمح بتباين الظلال
   
public:
                     CTweezerBottom();
                     ~CTweezerBottom();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPriceTolerancePercent(double percent) { m_priceTolerancePercent = MathMax(0.1, MathMin(2.0, percent)); }
   void              SetMinBodySizeRatio(double ratio) { m_minBodySizeRatio = MathMax(0.1, MathMin(0.8, ratio)); }
   void              SetRequireOppositeColors(bool require) { m_requireOppositeColors = require; }
   void              SetAllowShadowVariation(bool allow) { m_allowShadowVariation = allow; }
   
   // دوال مساعدة
   bool              IsValidTweezerBottom(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[]);
   double            CalculateTweezerStrength(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[]);
   bool              ArePricesEqual(double price1, double price2, double tolerancePercent, double referencePrice);
};

//+------------------------------------------------------------------+
//| محرك أنماط الملقاط الموحد                                       |
//+------------------------------------------------------------------+
class CTweezerPatterns : public CPatternDetector
{
private:
   CTweezerTop*         m_tweezerTop;
   CTweezerBottom*      m_tweezerBottom;
   
   bool                 m_enableTop;
   bool                 m_enableBottom;
   
   // دالة مساعدة للتحقق من صحة المؤشر
   bool                 IsValidPointer(void* ptr);
   
public:
                     CTweezerPatterns();
                     ~CTweezerPatterns();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // إعدادات التفعيل
   void              EnableTweezerTop(bool enable) { m_enableTop = enable; }
   void              EnableTweezerBottom(bool enable) { m_enableBottom = enable; }
   void              EnableAllTweezerPatterns(bool enable);
   
   // دوال الوصول لكائنات الأنماط الفرعية
   CTweezerTop*      GetTweezerTop() { return m_tweezerTop; }
   CTweezerBottom*   GetTweezerBottom() { return m_tweezerBottom; }
};

//+------------------------------------------------------------------+
//| تنفيذ CTweezerTop                                               |
//+------------------------------------------------------------------+
CTweezerTop::CTweezerTop()
{
   m_priceTolerancePercent = 0.5;  // 0.5% تسامح في السعر
   m_minBodySizeRatio = 0.3;       // الحد الأدنى 30% من النطاق
   m_requireOppositeColors = true; // يتطلب ألوان متضادة افتراضياً
   m_allowShadowVariation = true;  // يسمح بتباين الظلال
}

CTweezerTop::~CTweezerTop()
{
}

bool CTweezerTop::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CTweezerTop::ArePricesEqual(double price1, double price2, double tolerancePercent, double referencePrice)
{
   if(referencePrice <= 0) return false;
   
   double tolerance = referencePrice * (tolerancePercent / 100.0);
   return MathAbs(price1 - price2) <= tolerance;
}

bool CTweezerTop::IsValidTweezerTop(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // فحص تساوي القمم مع التسامح المسموح
   double avgPrice = (high[idx] + high[idx+1]) / 2.0;
   if(!ArePricesEqual(high[idx], high[idx+1], m_priceTolerancePercent, avgPrice))
      return false;
   
   // فحص حجم الأجسام
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double firstRange = high[idx+1] - low[idx+1];
   double secondRange = high[idx] - low[idx];
   
   // يجب أن تكون الأجسام بحجم معقول
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minBodySizeRatio)
      return false;
   if(secondRange > 0 && (secondBodySize / secondRange) < m_minBodySizeRatio)
      return false;
   
   // فحص الألوان المتضادة إذا كان مطلوباً
   if(m_requireOppositeColors)
   {
      bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
      bool secondBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
      
      if(firstBullish == secondBullish) return false;
   }
   
   // فحص الظلال العلوية إذا كان التباين غير مسموح
   if(!m_allowShadowVariation)
   {
      double firstUpperShadow = CCandleUtils::UpperShadow(open[idx+1], high[idx+1], close[idx+1]);
      double secondUpperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
      
      // يجب أن تكون الظلال العلوية متشابهة
      double avgShadow = (firstUpperShadow + secondUpperShadow) / 2.0;
      if(avgShadow > 0 && !ArePricesEqual(firstUpperShadow, secondUpperShadow, m_priceTolerancePercent * 2, avgShadow))
         return false;
   }
   
   return true;
}

double CTweezerTop::CalculateTweezerStrength(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // حساب دقة تطابق القمم
   double priceDiff = MathAbs(high[idx] - high[idx+1]);
   double avgPrice = (high[idx] + high[idx+1]) / 2.0;
   double priceAccuracy = 1.0 - (priceDiff / (avgPrice * 0.01)); // كلما قل الفرق، زادت الدقة
   priceAccuracy = MathMax(0.0, MathMin(1.0, priceAccuracy));
   
   // حساب قوة الأجسام
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double avgBodySize = (firstBodySize + secondBodySize) / 2.0;
   double avgRange = (high[idx+1] - low[idx+1] + high[idx] - low[idx]) / 2.0;
   
   double bodyStrength = (avgRange > 0) ? avgBodySize / avgRange : 0.0;
   bodyStrength = MathMax(0.0, MathMin(1.0, bodyStrength));
   
   // حساب قوة الظلال العلوية
   double firstUpperShadow = CCandleUtils::UpperShadow(open[idx+1], high[idx+1], close[idx+1]);
   double secondUpperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double avgUpperShadow = (firstUpperShadow + secondUpperShadow) / 2.0;
   
   double shadowStrength = (avgRange > 0) ? (1.0 - avgUpperShadow / avgRange) : 0.5;
   shadowStrength = MathMax(0.0, MathMin(1.0, shadowStrength));
   
   // القوة الإجمالية
   double totalStrength = 1.0 + priceAccuracy * 1.0 + bodyStrength * 0.5 + shadowStrength * 0.5;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CTweezerTop::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                 const double &open[], const double &high[], const double &low[], 
                                 const double &close[], const long &volume[], 
                                 SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidTweezerTop(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "قمة الملقاط";
   result.direction = PATTERN_BEARISH; // إشارة هبوطية
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateTweezerStrength(idx, open, high, low, close);
   result.reliability = 0.60 + (result.strength - 1.0) * 0.1; // موثوقية أساسية 60%
   result.confidence = MathMin(1.0, result.reliability * 1.05);
   result.barIndex = idx;
   
   // تعامل آمن مع دالة iTime
   datetime bar_time = 0;
   if(StringLen(symbol) > 0)
   {
      bar_time = iTime(symbol, timeframe, idx);
   }
   else
   {
      bar_time = iTime(_Symbol, timeframe, idx);
   }
   result.time = bar_time;
   
   ArrayResize(results, 1);
   results[0] = result;
   
   return 1;
}

//+------------------------------------------------------------------+
//| تنفيذ CTweezerBottom                                            |
//+------------------------------------------------------------------+
CTweezerBottom::CTweezerBottom()
{
   m_priceTolerancePercent = 0.5;  // 0.5% تسامح في السعر
   m_minBodySizeRatio = 0.3;       // الحد الأدنى 30% من النطاق
   m_requireOppositeColors = true; // يتطلب ألوان متضادة افتراضياً
   m_allowShadowVariation = true;  // يسمح بتباين الظلال
}

CTweezerBottom::~CTweezerBottom()
{
}

bool CTweezerBottom::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CTweezerBottom::ArePricesEqual(double price1, double price2, double tolerancePercent, double referencePrice)
{
   if(referencePrice <= 0) return false;
   
   double tolerance = referencePrice * (tolerancePercent / 100.0);
   return MathAbs(price1 - price2) <= tolerance;
}

bool CTweezerBottom::IsValidTweezerBottom(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // فحص تساوي القيعان مع التسامح المسموح
   double avgPrice = (low[idx] + low[idx+1]) / 2.0;
   if(!ArePricesEqual(low[idx], low[idx+1], m_priceTolerancePercent, avgPrice))
      return false;
   
   // فحص حجم الأجسام
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double firstRange = high[idx+1] - low[idx+1];
   double secondRange = high[idx] - low[idx];
   
   // يجب أن تكون الأجسام بحجم معقول
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minBodySizeRatio)
      return false;
   if(secondRange > 0 && (secondBodySize / secondRange) < m_minBodySizeRatio)
      return false;
   
   // فحص الألوان المتضادة إذا كان مطلوباً
   if(m_requireOppositeColors)
   {
      bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
      bool secondBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
      
      if(firstBullish == secondBullish) return false;
   }
   
   // فحص الظلال السفلية إذا كان التباين غير مسموح
   if(!m_allowShadowVariation)
   {
      double firstLowerShadow = CCandleUtils::LowerShadow(open[idx+1], low[idx+1], close[idx+1]);
      double secondLowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
      
      // يجب أن تكون الظلال السفلية متشابهة
      double avgShadow = (firstLowerShadow + secondLowerShadow) / 2.0;
      if(avgShadow > 0 && !ArePricesEqual(firstLowerShadow, secondLowerShadow, m_priceTolerancePercent * 2, avgShadow))
         return false;
   }
   
   return true;
}

double CTweezerBottom::CalculateTweezerStrength(const int idx, const double &open[], const double &high[], 
                                              const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // حساب دقة تطابق القيعان
   double priceDiff = MathAbs(low[idx] - low[idx+1]);
   double avgPrice = (low[idx] + low[idx+1]) / 2.0;
   double priceAccuracy = 1.0 - (priceDiff / (avgPrice * 0.01)); // كلما قل الفرق، زادت الدقة
   priceAccuracy = MathMax(0.0, MathMin(1.0, priceAccuracy));
   
   // حساب قوة الأجسام
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double avgBodySize = (firstBodySize + secondBodySize) / 2.0;
   double avgRange = (high[idx+1] - low[idx+1] + high[idx] - low[idx]) / 2.0;
   
   double bodyStrength = (avgRange > 0) ? avgBodySize / avgRange : 0.0;
   bodyStrength = MathMax(0.0, MathMin(1.0, bodyStrength));
   
   // حساب قوة الظلال السفلية
   double firstLowerShadow = CCandleUtils::LowerShadow(open[idx+1], low[idx+1], close[idx+1]);
   double secondLowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   double avgLowerShadow = (firstLowerShadow + secondLowerShadow) / 2.0;
   
   double shadowStrength = (avgRange > 0) ? (1.0 - avgLowerShadow / avgRange) : 0.5;
   shadowStrength = MathMax(0.0, MathMin(1.0, shadowStrength));
   
   // القوة الإجمالية
   double totalStrength = 1.0 + priceAccuracy * 1.0 + bodyStrength * 0.5 + shadowStrength * 0.5;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CTweezerBottom::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], const double &low[], 
                                    const double &close[], const long &volume[], 
                                    SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidTweezerBottom(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "قاع الملقاط";
   result.direction = PATTERN_BULLISH; // إشارة صعودية
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateTweezerStrength(idx, open, high, low, close);
   result.reliability = 0.60 + (result.strength - 1.0) * 0.1; // موثوقية أساسية 60%
   result.confidence = MathMin(1.0, result.reliability * 1.05);
   result.barIndex = idx;
   
   // تعامل آمن مع دالة iTime
   datetime bar_time = 0;
   if(StringLen(symbol) > 0)
   {
      bar_time = iTime(symbol, timeframe, idx);
   }
   else
   {
      bar_time = iTime(_Symbol, timeframe, idx);
   }
   result.time = bar_time;
   
   ArrayResize(results, 1);
   results[0] = result;
   
   return 1;
}

//+------------------------------------------------------------------+
//| تنفيذ CTweezerPatterns                                          |
//+------------------------------------------------------------------+
CTweezerPatterns::CTweezerPatterns()
{
   m_tweezerTop = NULL;
   m_tweezerBottom = NULL;
   
   m_enableTop = true;
   m_enableBottom = true;
}

CTweezerPatterns::~CTweezerPatterns()
{
   Deinitialize();
}

bool CTweezerPatterns::IsValidPointer(void* ptr)
{
   return (CheckPointer(ptr) != POINTER_INVALID);
}

bool CTweezerPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
   
   // إنشاء كائنات الأنماط
   m_tweezerTop = new CTweezerTop();
   m_tweezerBottom = new CTweezerBottom();
   
   // تهيئة جميع الأنماط
   bool success = true;
   if(IsValidPointer(m_tweezerTop)) 
      success = success && m_tweezerTop.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_tweezerBottom)) 
      success = success && m_tweezerBottom.Initialize(symbol, timeframe);
   else
      success = false;
   
   return success;
}

void CTweezerPatterns::Deinitialize()
{
   if(IsValidPointer(m_tweezerTop)) 
   { 
      delete m_tweezerTop; 
      m_tweezerTop = NULL; 
   }
   
   if(IsValidPointer(m_tweezerBottom)) 
   { 
      delete m_tweezerBottom; 
      m_tweezerBottom = NULL; 
   }
   
   CPatternDetector::Deinitialize();
}

void CTweezerPatterns::EnableAllTweezerPatterns(bool enable)
{
   m_enableTop = enable;
   m_enableBottom = enable;
}

int CTweezerPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                      const double &open[], const double &high[], const double &low[], 
                                      const double &close[], const long &volume[], 
                                      SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // كشف قمة الملقاط
   if(m_enableTop && IsValidPointer(m_tweezerTop))
   {
      int patternCount = m_tweezerTop.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         int currentSize = ArraySize(results);
         ArrayResize(results, currentSize + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[currentSize + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف قاع الملقاط
   if(m_enableBottom && IsValidPointer(m_tweezerBottom))
   {
      int patternCount = m_tweezerBottom.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         int currentSize = ArraySize(results);
         ArrayResize(results, currentSize + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[currentSize + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   return totalPatterns;
}