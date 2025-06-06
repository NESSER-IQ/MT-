//+------------------------------------------------------------------+
//|                                       CounterAttackPatterns.mqh |
//|                                   أنماط الهجوم المضاد اليابانية |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../Base/PatternDetector.mqh"
#include "../../Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| فئة الهجوم المضاد الصعودي                                       |
//+------------------------------------------------------------------+
class CBullishCounterAttack : public CPatternDetector
{
private:
   double            m_priceMatchTolerance;   // تسامح تطابق السعر
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   double            m_minFirstBodySize;      // الحد الأدنى لحجم الجسم الأول
   bool              m_requireGap;            // يتطلب فجوة
   
public:
                     CBullishCounterAttack();
                     ~CBullishCounterAttack();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPriceMatchTolerance(double tolerance) { m_priceMatchTolerance = MathMax(0.002, MathMin(0.02, tolerance)); }
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.4, MathMin(0.9, ratio)); }
   void              SetMinFirstBodySize(double size) { m_minFirstBodySize = MathMax(0.005, MathMin(0.05, size)); }
   void              SetRequireGap(bool require) { m_requireGap = require; }
   
   // دوال مساعدة
   bool              IsValidBullishCounterAttack(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   bool              ArePricesMatching(double price1, double price2, double tolerance, double referencePrice);
};

//+------------------------------------------------------------------+
//| فئة الهجوم المضاد الهبوطي                                       |
//+------------------------------------------------------------------+
class CBearishCounterAttack : public CPatternDetector
{
private:
   double            m_priceMatchTolerance;   // تسامح تطابق السعر
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   double            m_minFirstBodySize;      // الحد الأدنى لحجم الجسم الأول
   bool              m_requireGap;            // يتطلب فجوة
   
public:
                     CBearishCounterAttack();
                     ~CBearishCounterAttack();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPriceMatchTolerance(double tolerance) { m_priceMatchTolerance = MathMax(0.002, MathMin(0.02, tolerance)); }
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.4, MathMin(0.9, ratio)); }
   void              SetMinFirstBodySize(double size) { m_minFirstBodySize = MathMax(0.005, MathMin(0.05, size)); }
   void              SetRequireGap(bool require) { m_requireGap = require; }
   
   // دوال مساعدة
   bool              IsValidBearishCounterAttack(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   bool              ArePricesMatching(double price1, double price2, double tolerance, double referencePrice);
};

//+------------------------------------------------------------------+
//| فئة الخطوط المنفصلة                                            |
//+------------------------------------------------------------------+
class CSeparatingLines : public CPatternDetector
{
private:
   double            m_priceMatchTolerance;   // تسامح تطابق السعر
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   double            m_minGapSize;            // الحد الأدنى لحجم الفجوة
   
public:
                     CSeparatingLines();
                     ~CSeparatingLines();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPriceMatchTolerance(double tolerance) { m_priceMatchTolerance = MathMax(0.002, MathMin(0.02, tolerance)); }
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.3, MathMin(0.8, ratio)); }
   void              SetMinGapSize(double size) { m_minGapSize = MathMax(0.001, MathMin(0.02, size)); }
   
   // دوال مساعدة
   bool              IsValidSeparatingLines(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   ENUM_PATTERN_DIRECTION DetermineDirection(const int idx, const double &open[], const double &close[]);
};

//+------------------------------------------------------------------+
//| محرك أنماط الهجوم المضاد الموحد                                 |
//+------------------------------------------------------------------+
class CCounterAttackPatterns : public CPatternDetector
{
private:
   CBullishCounterAttack*   m_bullishCounterAttack;
   CBearishCounterAttack*   m_bearishCounterAttack;
   CSeparatingLines*        m_separatingLines;
   
   bool                     m_enableBullishCounterAttack;
   bool                     m_enableBearishCounterAttack;
   bool                     m_enableSeparatingLines;
   
   // دالة مساعدة للتحقق من صحة المؤشر
   bool                     IsValidPointer(void* ptr);
   
public:
                     CCounterAttackPatterns();
                     ~CCounterAttackPatterns();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // إعدادات التفعيل
   void              EnableBullishCounterAttack(bool enable) { m_enableBullishCounterAttack = enable; }
   void              EnableBearishCounterAttack(bool enable) { m_enableBearishCounterAttack = enable; }
   void              EnableSeparatingLines(bool enable) { m_enableSeparatingLines = enable; }
   void              EnableAllCounterAttackPatterns(bool enable);
   
   // دوال الوصول لكائنات الأنماط الفرعية
   CBullishCounterAttack* GetBullishCounterAttack() { return m_bullishCounterAttack; }
   CBearishCounterAttack* GetBearishCounterAttack() { return m_bearishCounterAttack; }
   CSeparatingLines*      GetSeparatingLines() { return m_separatingLines; }
};

//+------------------------------------------------------------------+
//| تنفيذ CBullishCounterAttack                                     |
//+------------------------------------------------------------------+
CBullishCounterAttack::CBullishCounterAttack()
{
   m_priceMatchTolerance = 0.005;  // 0.5% تسامح في تطابق السعر
   m_minBodyRatio = 0.6;           // 60% نسبة جسم دنيا
   m_minFirstBodySize = 0.01;      // 1% حد أدنى لحجم الجسم الأول
   m_requireGap = false;           // لا يتطلب فجوة افتراضياً
}

CBullishCounterAttack::~CBullishCounterAttack()
{
}

bool CBullishCounterAttack::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CBullishCounterAttack::ArePricesMatching(double price1, double price2, double tolerance, double referencePrice)
{
   if(referencePrice <= 0) return false;
   
   double toleranceValue = referencePrice * tolerance;
   return MathAbs(price1 - price2) <= toleranceValue;
}

bool CBullishCounterAttack::IsValidBullishCounterAttack(const int idx, const double &open[], const double &high[], 
                                                      const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون هبوطية وقوية
   bool firstBearish = CCandleUtils::IsBearish(open[idx+1], close[idx+1]);
   if(!firstBearish) return false;
   
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   
   // فحص حجم الجسم الأول
   if(avgPrice > 0 && (firstBodySize / avgPrice) < m_minFirstBodySize)
      return false;
   
   // فحص نسبة الجسم الأول
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minBodyRatio)
      return false;
   
   // الشمعة الثانية يجب أن تكون صعودية
   bool secondBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
   if(!secondBullish) return false;
   
   // فحص الفجوة إذا كان مطلوباً
   if(m_requireGap && open[idx] >= close[idx+1])
      return false;
   
   // فحص تطابق أسعار الإغلاق - يجب أن تغلق الشمعة الثانية بالقرب من إغلاق الأولى
   if(!ArePricesMatching(close[idx], close[idx+1], m_priceMatchTolerance, avgPrice))
      return false;
   
   // الشمعة الثانية يجب أن تفتح أسفل إغلاق الأولى
   if(open[idx] >= close[idx+1])
      return false;
   
   return true;
}

double CBullishCounterAttack::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                              const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // دقة تطابق أسعار الإغلاق
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   double closeDiff = MathAbs(close[idx] - close[idx+1]);
   double tolerance = avgPrice * m_priceMatchTolerance;
   double matchAccuracy = 1.0 - (closeDiff / tolerance);
   matchAccuracy = MathMax(0.0, MathMin(1.0, matchAccuracy));
   
   // قوة الشمعة الأولى
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double firstStrength = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   
   // قوة الشمعة الثانية
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   double secondStrength = (secondRange > 0) ? secondBodySize / secondRange : 0.0;
   
   // قوة الانتعاش (من الافتتاح إلى الإغلاق للشمعة الثانية)
   double recoverySize = close[idx] - open[idx];
   double maxPossibleRecovery = high[idx] - open[idx];
   double recoveryStrength = (maxPossibleRecovery > 0) ? recoverySize / maxPossibleRecovery : 0.0;
   
   // القوة الإجمالية
   double totalStrength = 1.0 + matchAccuracy * 1.0 + firstStrength * 0.4 + secondStrength * 0.4 + recoveryStrength * 0.2;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CBullishCounterAttack::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                           const double &open[], const double &high[], const double &low[], 
                                           const double &close[], const long &volume[], 
                                           SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidBullishCounterAttack(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "الهجوم المضاد الصعودي";
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.55 + (result.strength - 1.0) * 0.08; // موثوقية متوسطة
   result.confidence = MathMin(1.0, result.reliability * 1.0);
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
//| تنفيذ CBearishCounterAttack                                     |
//+------------------------------------------------------------------+
CBearishCounterAttack::CBearishCounterAttack()
{
   m_priceMatchTolerance = 0.005;  // 0.5% تسامح في تطابق السعر
   m_minBodyRatio = 0.6;           // 60% نسبة جسم دنيا
   m_minFirstBodySize = 0.01;      // 1% حد أدنى لحجم الجسم الأول
   m_requireGap = false;           // لا يتطلب فجوة افتراضياً
}

CBearishCounterAttack::~CBearishCounterAttack()
{
}

bool CBearishCounterAttack::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CBearishCounterAttack::ArePricesMatching(double price1, double price2, double tolerance, double referencePrice)
{
   if(referencePrice <= 0) return false;
   
   double toleranceValue = referencePrice * tolerance;
   return MathAbs(price1 - price2) <= toleranceValue;
}

bool CBearishCounterAttack::IsValidBearishCounterAttack(const int idx, const double &open[], const double &high[], 
                                                      const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون صعودية وقوية
   bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
   if(!firstBullish) return false;
   
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   
   // فحص حجم الجسم الأول
   if(avgPrice > 0 && (firstBodySize / avgPrice) < m_minFirstBodySize)
      return false;
   
   // فحص نسبة الجسم الأول
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minBodyRatio)
      return false;
   
   // الشمعة الثانية يجب أن تكون هبوطية
   bool secondBearish = CCandleUtils::IsBearish(open[idx], close[idx]);
   if(!secondBearish) return false;
   
   // فحص الفجوة إذا كان مطلوباً
   if(m_requireGap && open[idx] <= close[idx+1])
      return false;
   
   // فحص تطابق أسعار الإغلاق - يجب أن تغلق الشمعة الثانية بالقرب من إغلاق الأولى
   if(!ArePricesMatching(close[idx], close[idx+1], m_priceMatchTolerance, avgPrice))
      return false;
   
   // الشمعة الثانية يجب أن تفتح أعلى من إغلاق الأولى
   if(open[idx] <= close[idx+1])
      return false;
   
   return true;
}

double CBearishCounterAttack::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                              const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // دقة تطابق أسعار الإغلاق
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   double closeDiff = MathAbs(close[idx] - close[idx+1]);
   double tolerance = avgPrice * m_priceMatchTolerance;
   double matchAccuracy = 1.0 - (closeDiff / tolerance);
   matchAccuracy = MathMax(0.0, MathMin(1.0, matchAccuracy));
   
   // قوة الشمعة الأولى
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double firstStrength = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   
   // قوة الشمعة الثانية
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   double secondStrength = (secondRange > 0) ? secondBodySize / secondRange : 0.0;
   
   // قوة الانحدار (من الافتتاح إلى الإغلاق للشمعة الثانية)
   double declineSize = open[idx] - close[idx];
   double maxPossibleDecline = open[idx] - low[idx];
   double declineStrength = (maxPossibleDecline > 0) ? declineSize / maxPossibleDecline : 0.0;
   
   // القوة الإجمالية
   double totalStrength = 1.0 + matchAccuracy * 1.0 + firstStrength * 0.4 + secondStrength * 0.4 + declineStrength * 0.2;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CBearishCounterAttack::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                           const double &open[], const double &high[], const double &low[], 
                                           const double &close[], const long &volume[], 
                                           SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidBearishCounterAttack(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "الهجوم المضاد الهبوطي";
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.55 + (result.strength - 1.0) * 0.08; // موثوقية متوسطة
   result.confidence = MathMin(1.0, result.reliability * 1.0);
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
//| تنفيذ CSeparatingLines                                          |
//+------------------------------------------------------------------+
CSeparatingLines::CSeparatingLines()
{
   m_priceMatchTolerance = 0.005;  // 0.5% تسامح في تطابق السعر
   m_minBodyRatio = 0.5;           // 50% نسبة جسم دنيا
   m_minGapSize = 0.002;           // 0.2% حد أدنى للفجوة
}

CSeparatingLines::~CSeparatingLines()
{
}

bool CSeparatingLines::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

ENUM_PATTERN_DIRECTION CSeparatingLines::DetermineDirection(const int idx, const double &open[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return PATTERN_NEUTRAL;
   
   bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
   bool secondBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
   
   // إذا كانت الشمعة الثانية صعودية والأولى هبوطية، فهو صعودي
   if(secondBullish && !firstBullish)
      return PATTERN_BULLISH;
   
   // إذا كانت الشمعة الثانية هبوطية والأولى صعودية، فهو هبوطي
   if(!secondBullish && firstBullish)
      return PATTERN_BEARISH;
   
   return PATTERN_NEUTRAL;
}

bool CSeparatingLines::IsValidSeparatingLines(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // يجب أن تكون الشمعتان من اتجاهين متضادين
   bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
   bool secondBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
   
   if(firstBullish == secondBullish) return false;
   
   // فحص نسبة الأجسام
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minBodyRatio)
      return false;
   if(secondRange > 0 && (secondBodySize / secondRange) < m_minBodyRatio)
      return false;
   
   // فحص تطابق أسعار الافتتاح
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   double tolerance = avgPrice * m_priceMatchTolerance;
   
   if(MathAbs(open[idx] - open[idx+1]) > tolerance)
      return false;
   
   // فحص وجود فجوة بين الإغلاقات
   double gapSize = MathAbs(close[idx] - close[idx+1]);
   double minGapValue = avgPrice * m_minGapSize;
   
   if(gapSize < minGapValue)
      return false;
   
   return true;
}

double CSeparatingLines::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // دقة تطابق أسعار الافتتاح
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   double openDiff = MathAbs(open[idx] - open[idx+1]);
   double tolerance = avgPrice * m_priceMatchTolerance;
   double matchAccuracy = 1.0 - (openDiff / tolerance);
   matchAccuracy = MathMax(0.0, MathMin(1.0, matchAccuracy));
   
   // قوة الفجوة بين الإغلاقات
   double gapSize = MathAbs(close[idx] - close[idx+1]);
   double minGapValue = avgPrice * m_minGapSize;
   double gapStrength = MathMin(1.0, gapSize / (minGapValue * 3.0));
   
   // قوة الأجسام
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   
   double firstBodyRatio = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   double secondBodyRatio = (secondRange > 0) ? secondBodySize / secondRange : 0.0;
   double avgBodyStrength = (firstBodyRatio + secondBodyRatio) / 2.0;
   
   // القوة الإجمالية
   double totalStrength = 1.0 + matchAccuracy * 0.8 + gapStrength * 0.7 + avgBodyStrength * 0.5;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CSeparatingLines::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                      const double &open[], const double &high[], const double &low[], 
                                      const double &close[], const long &volume[], 
                                      SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidSeparatingLines(idx, open, high, low, close))
      return 0;
   
   // تحديد الاتجاه
   ENUM_PATTERN_DIRECTION direction = DetermineDirection(idx, open, close);
   if(direction == PATTERN_NEUTRAL) return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = (direction == PATTERN_BULLISH) ? "الخطوط المنفصلة الصعودية" : "الخطوط المنفصلة الهبوطية";
   result.direction = direction;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.50 + (result.strength - 1.0) * 0.08; // موثوقية متوسطة-منخفضة
   result.confidence = MathMin(1.0, result.reliability * 1.0);
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
//| تنفيذ CCounterAttackPatterns                                    |
//+------------------------------------------------------------------+
CCounterAttackPatterns::CCounterAttackPatterns()
{
   m_bullishCounterAttack = NULL;
   m_bearishCounterAttack = NULL;
   m_separatingLines = NULL;
   
   m_enableBullishCounterAttack = true;
   m_enableBearishCounterAttack = true;
   m_enableSeparatingLines = true;
}

CCounterAttackPatterns::~CCounterAttackPatterns()
{
   Deinitialize();
}

bool CCounterAttackPatterns::IsValidPointer(void* ptr)
{
   return (CheckPointer(ptr) != POINTER_INVALID);
}

bool CCounterAttackPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
   
   // إنشاء كائنات الأنماط
   m_bullishCounterAttack = new CBullishCounterAttack();
   m_bearishCounterAttack = new CBearishCounterAttack();
   m_separatingLines = new CSeparatingLines();
   
   // تهيئة جميع الأنماط
   bool success = true;
   if(IsValidPointer(m_bullishCounterAttack)) 
      success = success && m_bullishCounterAttack.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_bearishCounterAttack)) 
      success = success && m_bearishCounterAttack.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_separatingLines)) 
      success = success && m_separatingLines.Initialize(symbol, timeframe);
   else
      success = false;
   
   return success;
}

void CCounterAttackPatterns::Deinitialize()
{
   if(IsValidPointer(m_bullishCounterAttack)) 
   { 
      delete m_bullishCounterAttack; 
      m_bullishCounterAttack = NULL; 
   }
   
   if(IsValidPointer(m_bearishCounterAttack)) 
   { 
      delete m_bearishCounterAttack; 
      m_bearishCounterAttack = NULL; 
   }
   
   if(IsValidPointer(m_separatingLines)) 
   { 
      delete m_separatingLines; 
      m_separatingLines = NULL; 
   }
   
   CPatternDetector::Deinitialize();
}

void CCounterAttackPatterns::EnableAllCounterAttackPatterns(bool enable)
{
   m_enableBullishCounterAttack = enable;
   m_enableBearishCounterAttack = enable;
   m_enableSeparatingLines = enable;
}

int CCounterAttackPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                            const double &open[], const double &high[], const double &low[], 
                                            const double &close[], const long &volume[], 
                                            SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // كشف الهجوم المضاد الصعودي
   if(m_enableBullishCounterAttack && IsValidPointer(m_bullishCounterAttack))
   {
      int patternCount = m_bullishCounterAttack.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
   
   // كشف الهجوم المضاد الهبوطي
   if(m_enableBearishCounterAttack && IsValidPointer(m_bearishCounterAttack))
   {
      int patternCount = m_bearishCounterAttack.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
   
   // كشف الخطوط المنفصلة
   if(m_enableSeparatingLines && IsValidPointer(m_separatingLines))
   {
      int patternCount = m_separatingLines.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
