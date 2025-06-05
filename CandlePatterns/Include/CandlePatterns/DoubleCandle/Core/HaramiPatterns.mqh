//+------------------------------------------------------------------+
//|                                             HaramiPatterns.mqh |
//|                                       أنماط الحامل اليابانية     |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../Base/PatternDetector.mqh"
#include "../../Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الحامل الصعودي                                        |
//+------------------------------------------------------------------+
class CBullishHarami : public CPatternDetector
{
private:
   double            m_maxBodyRatio;          // نسبة الجسم القصوى للشمعة الثانية
   double            m_minFirstBodyRatio;     // نسبة الجسم الدنيا للشمعة الأولى
   bool              m_requireGapOpen;        // يتطلب فجوة في الافتتاح
   
public:
                     CBullishHarami();
                     ~CBullishHarami();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMaxBodyRatio(double ratio) { m_maxBodyRatio = MathMax(0.1, MathMin(0.8, ratio)); }
   void              SetMinFirstBodyRatio(double ratio) { m_minFirstBodyRatio = MathMax(0.3, MathMin(0.9, ratio)); }
   void              SetRequireGapOpen(bool require) { m_requireGapOpen = require; }
   
   // دوال مساعدة
   bool              IsValidBullishHarami(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[]);
   double            CalculateHaramiStrength(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة أنماط الحامل الهبوطي                                        |
//+------------------------------------------------------------------+
class CBearishHarami : public CPatternDetector
{
private:
   double            m_maxBodyRatio;          // نسبة الجسم القصوى للشمعة الثانية
   double            m_minFirstBodyRatio;     // نسبة الجسم الدنيا للشمعة الأولى
   bool              m_requireGapOpen;        // يتطلب فجوة في الافتتاح
   
public:
                     CBearishHarami();
                     ~CBearishHarami();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMaxBodyRatio(double ratio) { m_maxBodyRatio = MathMax(0.1, MathMin(0.8, ratio)); }
   void              SetMinFirstBodyRatio(double ratio) { m_minFirstBodyRatio = MathMax(0.3, MathMin(0.9, ratio)); }
   void              SetRequireGapOpen(bool require) { m_requireGapOpen = require; }
   
   // دوال مساعدة
   bool              IsValidBearishHarami(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[]);
   double            CalculateHaramiStrength(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة أنماط صليب الحامل                                           |
//+------------------------------------------------------------------+
class CHaramiCross : public CPatternDetector
{
private:
   double            m_dojiThreshold;         // حد الدوجي
   double            m_minFirstBodyRatio;     // نسبة الجسم الدنيا للشمعة الأولى
   
public:
                     CHaramiCross();
                     ~CHaramiCross();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetDojiThreshold(double threshold) { m_dojiThreshold = MathMax(0.01, MathMin(0.1, threshold)); }
   void              SetMinFirstBodyRatio(double ratio) { m_minFirstBodyRatio = MathMax(0.3, MathMin(0.9, ratio)); }
   
   // دوال مساعدة
   bool              IsValidHaramiCross(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[]);
   double            CalculateCrossStrength(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| محرك أنماط الحامل الموحد                                        |
//+------------------------------------------------------------------+
class CHaramiPatterns : public CPatternDetector
{
private:
   CBullishHarami*      m_bullishHarami;
   CBearishHarami*      m_bearishHarami;
   CHaramiCross*        m_haramiCross;
   
   bool                 m_enableBullish;
   bool                 m_enableBearish;
   bool                 m_enableCross;
   
public:
                     CHaramiPatterns();
                     ~CHaramiPatterns();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // إعدادات التفعيل
   void              EnableBullishHarami(bool enable) { m_enableBullish = enable; }
   void              EnableBearishHarami(bool enable) { m_enableBearish = enable; }
   void              EnableHaramiCross(bool enable) { m_enableCross = enable; }
   void              EnableAllHaramiPatterns(bool enable);
};

//+------------------------------------------------------------------+
//| تنفيذ CBullishHarami                                            |
//+------------------------------------------------------------------+
CBullishHarami::CBullishHarami()
{
   m_maxBodyRatio = 0.5;        // الشمعة الثانية يجب أن تكون 50% أو أقل من الأولى
   m_minFirstBodyRatio = 0.6;   // الشمعة الأولى يجب أن تكون قوية
   m_requireGapOpen = false;    // لا يتطلب فجوة افتراضياً
}

CBullishHarami::~CBullishHarami()
{
}

bool CBullishHarami::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CBullishHarami::IsValidBullishHarami(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || !IsValidIndex(idx, ArraySize(open)) || !IsValidIndex(idx-1, ArraySize(open)))
      return false;
   
   // الشمعة الأولى يجب أن تكون هبوطية وقوية
   bool firstBearish = CCandleUtils::IsBearish(open[idx+1], close[idx+1]);
   if(!firstBearish) return false;
   
   // الشمعة الثانية يجب أن تكون صعودية
   bool secondBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
   if(!secondBullish) return false;
   
   // حساب أحجام الأجسام
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double firstRange = high[idx+1] - low[idx+1];
   
   // فحص قوة الشمعة الأولى
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minFirstBodyRatio)
      return false;
   
   // فحص نسبة حجم الجسم الثاني إلى الأول
   if(firstBodySize > 0 && (secondBodySize / firstBodySize) > m_maxBodyRatio)
      return false;
   
   // فحص الاحتواء: الشمعة الثانية يجب أن تكون داخل الأولى
   double firstBodyTop = MathMax(open[idx+1], close[idx+1]);
   double firstBodyBottom = MathMin(open[idx+1], close[idx+1]);
   double secondBodyTop = MathMax(open[idx], close[idx]);
   double secondBodyBottom = MathMin(open[idx], close[idx]);
   
   if(secondBodyTop > firstBodyTop || secondBodyBottom < firstBodyBottom)
      return false;
   
   // فحص الفجوة في الافتتاح إذا كان مطلوباً
   if(m_requireGapOpen)
   {
      if(open[idx] <= close[idx+1]) // يجب أن يكون الافتتاح أعلى من إغلاق الشمعة السابقة
         return false;
   }
   
   return true;
}

double CBullishHarami::CalculateHaramiStrength(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[])
{
   if(idx < 1) return 0.0;
   
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   
   if(firstBodySize <= 0) return 0.0;
   
   // كلما كانت الشمعة الثانية أصغر، كانت القوة أكبر
   double sizeRatio = secondBodySize / firstBodySize;
   double strength = 1.0 + (m_maxBodyRatio - sizeRatio) * 2.0; // معكوس النسبة
   
   // إضافة قوة إضافية للفجوة
   if(m_requireGapOpen && open[idx] > close[idx+1])
   {
      double gapSize = open[idx] - close[idx+1];
      double avgRange = (high[idx+1] - low[idx+1] + high[idx] - low[idx]) / 2.0;
      if(avgRange > 0)
         strength += (gapSize / avgRange) * 0.5;
   }
   
   return MathMin(3.0, MathMax(1.0, strength));
}

int CBullishHarami::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], const double &low[], 
                                    const double &close[], const long &volume[], 
                                    SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidBullishHarami(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "الحامل الصعودي";
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateHaramiStrength(idx, open, high, low, close);
   result.reliability = 0.65 + (result.strength - 1.0) * 0.1; // موثوقية أساسية 65%
   result.confidence = MathMin(1.0, result.reliability * 1.05);
   result.barIndex = idx;
   result.time = iTime(symbol, timeframe, idx);
   
   ArrayResize(results, 1);
   results[0] = result;
   
   return 1;
}

//+------------------------------------------------------------------+
//| تنفيذ CBearishHarami                                            |
//+------------------------------------------------------------------+
CBearishHarami::CBearishHarami()
{
   m_maxBodyRatio = 0.5;        // الشمعة الثانية يجب أن تكون 50% أو أقل من الأولى
   m_minFirstBodyRatio = 0.6;   // الشمعة الأولى يجب أن تكون قوية
   m_requireGapOpen = false;    // لا يتطلب فجوة افتراضياً
}

CBearishHarami::~CBearishHarami()
{
}

bool CBearishHarami::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CBearishHarami::IsValidBearishHarami(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || !IsValidIndex(idx, ArraySize(open)) || !IsValidIndex(idx-1, ArraySize(open)))
      return false;
   
   // الشمعة الأولى يجب أن تكون صعودية وقوية
   bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
   if(!firstBullish) return false;
   
   // الشمعة الثانية يجب أن تكون هبوطية
   bool secondBearish = CCandleUtils::IsBearish(open[idx], close[idx]);
   if(!secondBearish) return false;
   
   // حساب أحجام الأجسام
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double firstRange = high[idx+1] - low[idx+1];
   
   // فحص قوة الشمعة الأولى
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minFirstBodyRatio)
      return false;
   
   // فحص نسبة حجم الجسم الثاني إلى الأول
   if(firstBodySize > 0 && (secondBodySize / firstBodySize) > m_maxBodyRatio)
      return false;
   
   // فحص الاحتواء: الشمعة الثانية يجب أن تكون داخل الأولى
   double firstBodyTop = MathMax(open[idx+1], close[idx+1]);
   double firstBodyBottom = MathMin(open[idx+1], close[idx+1]);
   double secondBodyTop = MathMax(open[idx], close[idx]);
   double secondBodyBottom = MathMin(open[idx], close[idx]);
   
   if(secondBodyTop > firstBodyTop || secondBodyBottom < firstBodyBottom)
      return false;
   
   // فحص الفجوة في الافتتاح إذا كان مطلوباً
   if(m_requireGapOpen)
   {
      if(open[idx] >= close[idx+1]) // يجب أن يكون الافتتاح أقل من إغلاق الشمعة السابقة
         return false;
   }
   
   return true;
}

double CBearishHarami::CalculateHaramiStrength(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[])
{
   if(idx < 1) return 0.0;
   
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   
   if(firstBodySize <= 0) return 0.0;
   
   // كلما كانت الشمعة الثانية أصغر، كانت القوة أكبر
   double sizeRatio = secondBodySize / firstBodySize;
   double strength = 1.0 + (m_maxBodyRatio - sizeRatio) * 2.0; // معكوس النسبة
   
   // إضافة قوة إضافية للفجوة
   if(m_requireGapOpen && open[idx] < close[idx+1])
   {
      double gapSize = close[idx+1] - open[idx];
      double avgRange = (high[idx+1] - low[idx+1] + high[idx] - low[idx]) / 2.0;
      if(avgRange > 0)
         strength += (gapSize / avgRange) * 0.5;
   }
   
   return MathMin(3.0, MathMax(1.0, strength));
}

int CBearishHarami::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], const double &low[], 
                                    const double &close[], const long &volume[], 
                                    SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidBearishHarami(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "الحامل الهبوطي";
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateHaramiStrength(idx, open, high, low, close);
   result.reliability = 0.65 + (result.strength - 1.0) * 0.1; // موثوقية أساسية 65%
   result.confidence = MathMin(1.0, result.reliability * 1.05);
   result.barIndex = idx;
   result.time = iTime(symbol, timeframe, idx);
   
   ArrayResize(results, 1);
   results[0] = result;
   
   return 1;
}

//+------------------------------------------------------------------+
//| تنفيذ CHaramiCross                                              |
//+------------------------------------------------------------------+
CHaramiCross::CHaramiCross()
{
   m_dojiThreshold = 0.05;      // 5% كحد أقصى لحجم جسم الدوجي
   m_minFirstBodyRatio = 0.7;   // الشمعة الأولى يجب أن تكون قوية جداً
}

CHaramiCross::~CHaramiCross()
{
}

bool CHaramiCross::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CHaramiCross::IsValidHaramiCross(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || !IsValidIndex(idx, ArraySize(open)) || !IsValidIndex(idx-1, ArraySize(open)))
      return false;
   
   // الشمعة الأولى يجب أن تكون قوية (صعودية أو هبوطية)
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   
   if(firstRange <= 0 || (firstBodySize / firstRange) < m_minFirstBodyRatio)
      return false;
   
   // الشمعة الثانية يجب أن تكون دوجي
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 10, idx);
   if(!CCandleUtils::IsDoji(open[idx], close[idx], avgRange, m_dojiThreshold))
      return false;
   
   // فحص الاحتواء: الدوجي يجب أن يكون داخل الشمعة الأولى
   double firstBodyTop = MathMax(open[idx+1], close[idx+1]);
   double firstBodyBottom = MathMin(open[idx+1], close[idx+1]);
   
   if(high[idx] > firstBodyTop || low[idx] < firstBodyBottom)
      return false;
   
   return true;
}

double CHaramiCross::CalculateCrossStrength(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[])
{
   if(idx < 1) return 0.0;
   
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double firstRange = high[idx+1] - low[idx+1];
   
   if(firstBodySize <= 0 || firstRange <= 0) return 0.0;
   
   // قوة الدوجي معكوسة مع حجم الجسم
   double dojiStrength = 1.0 - (secondBodySize / (firstRange * m_dojiThreshold));
   dojiStrength = MathMax(0.0, MathMin(1.0, dojiStrength));
   
   // قوة الشمعة الأولى
   double firstStrength = firstBodySize / firstRange;
   
   // القوة الإجمالية
   double totalStrength = 1.5 + dojiStrength * 1.0 + firstStrength * 0.5;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CHaramiCross::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                  const double &open[], const double &high[], const double &low[], 
                                  const double &close[], const long &volume[], 
                                  SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidHaramiCross(idx, open, high, low, close))
      return 0;
   
   // تحديد الاتجاه بناءً على الشمعة الأولى
   bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
   ENUM_PATTERN_DIRECTION direction = firstBullish ? PATTERN_BEARISH : PATTERN_BULLISH; // انعكاس
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = direction == PATTERN_BULLISH ? "صليب الحامل الصعودي" : "صليب الحامل الهبوطي";
   result.direction = direction;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateCrossStrength(idx, open, high, low, close);
   result.reliability = 0.70 + (result.strength - 1.0) * 0.1; // موثوقية أعلى من الحامل العادي
   result.confidence = MathMin(1.0, result.reliability * 1.1);
   result.barIndex = idx;
   result.time = iTime(symbol, timeframe, idx);
   
   ArrayResize(results, 1);
   results[0] = result;
   
   return 1;
}

//+------------------------------------------------------------------+
//| تنفيذ CHaramiPatterns                                           |
//+------------------------------------------------------------------+
CHaramiPatterns::CHaramiPatterns()
{
   m_bullishHarami = NULL;
   m_bearishHarami = NULL;
   m_haramiCross = NULL;
   
   m_enableBullish = true;
   m_enableBearish = true;
   m_enableCross = true;
}

CHaramiPatterns::~CHaramiPatterns()
{
   Deinitialize();
}

bool CHaramiPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
   
   // إنشاء كائنات الأنماط
   m_bullishHarami = new CBullishHarami();
   m_bearishHarami = new CBearishHarami();
   m_haramiCross = new CHaramiCross();
   
   // تهيئة جميع الأنماط
   bool success = true;
   if(m_bullishHarami) success &= m_bullishHarami.Initialize(symbol, timeframe);
   if(m_bearishHarami) success &= m_bearishHarami.Initialize(symbol, timeframe);
   if(m_haramiCross) success &= m_haramiCross.Initialize(symbol, timeframe);
   
   return success;
}

void CHaramiPatterns::Deinitialize()
{
   if(m_bullishHarami) { delete m_bullishHarami; m_bullishHarami = NULL; }
   if(m_bearishHarami) { delete m_bearishHarami; m_bearishHarami = NULL; }
   if(m_haramiCross) { delete m_haramiCross; m_haramiCross = NULL; }
   
   CPatternDetector::Deinitialize();
}

void CHaramiPatterns::EnableAllHaramiPatterns(bool enable)
{
   m_enableBullish = enable;
   m_enableBearish = enable;
   m_enableCross = enable;
}

int CHaramiPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // كشف الحامل الصعودي
   if(m_enableBullish && m_bullishHarami)
   {
      int patternCount = m_bullishHarami.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف الحامل الهبوطي
   if(m_enableBearish && m_bearishHarami)
   {
      int patternCount = m_bearishHarami.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف صليب الحامل
   if(m_enableCross && m_haramiCross)
   {
      int patternCount = m_haramiCross.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   return totalPatterns;
}
