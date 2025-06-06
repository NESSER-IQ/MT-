//+------------------------------------------------------------------+
//|                                             KickingPatterns.mqh |
//|                                         أنماط الركل اليابانية   |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../Base/PatternDetector.mqh"
#include "../../Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| فئة الركل الصعودي                                               |
//+------------------------------------------------------------------+
class CKickingBullish : public CPatternDetector
{
private:
   double            m_minGapSize;            // الحد الأدنى لحجم الفجوة
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   double            m_maxShadowRatio;        // نسبة الظل القصوى
   bool              m_requireMarubozu;       // يتطلب شموع ماروبوزو
   
public:
                     CKickingBullish();
                     ~CKickingBullish();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMinGapSize(double size) { m_minGapSize = MathMax(0.005, MathMin(0.05, size)); }
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.7, MathMin(0.95, ratio)); }
   void              SetMaxShadowRatio(double ratio) { m_maxShadowRatio = MathMax(0.05, MathMin(0.3, ratio)); }
   void              SetRequireMarubozu(bool require) { m_requireMarubozu = require; }
   
   // دوال مساعدة
   bool              IsValidKickingBullish(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[]);
   double            CalculateGapSize(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   bool              IsMarubozuCandle(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة الركل الهبوطي                                               |
//+------------------------------------------------------------------+
class CKickingBearish : public CPatternDetector
{
private:
   double            m_minGapSize;            // الحد الأدنى لحجم الفجوة
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   double            m_maxShadowRatio;        // نسبة الظل القصوى
   bool              m_requireMarubozu;       // يتطلب شموع ماروبوزو
   
public:
                     CKickingBearish();
                     ~CKickingBearish();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMinGapSize(double size) { m_minGapSize = MathMax(0.005, MathMin(0.05, size)); }
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.7, MathMin(0.95, ratio)); }
   void              SetMaxShadowRatio(double ratio) { m_maxShadowRatio = MathMax(0.05, MathMin(0.3, ratio)); }
   void              SetRequireMarubozu(bool require) { m_requireMarubozu = require; }
   
   // دوال مساعدة
   bool              IsValidKickingBearish(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[]);
   double            CalculateGapSize(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   bool              IsMarubozuCandle(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| محرك أنماط الركل الموحد                                         |
//+------------------------------------------------------------------+
class CKickingPatterns : public CPatternDetector
{
private:
   CKickingBullish*     m_kickingBullish;
   CKickingBearish*     m_kickingBearish;
   
   bool                 m_enableBullish;
   bool                 m_enableBearish;
   
   // دالة مساعدة للتحقق من صحة المؤشر
   bool                 IsValidPointer(void* ptr);
   
public:
                     CKickingPatterns();
                     ~CKickingPatterns();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // إعدادات التفعيل
   void              EnableKickingBullish(bool enable) { m_enableBullish = enable; }
   void              EnableKickingBearish(bool enable) { m_enableBearish = enable; }
   void              EnableAllKickingPatterns(bool enable);
   
   // دوال الوصول لكائنات الأنماط الفرعية
   CKickingBullish*  GetKickingBullish() { return m_kickingBullish; }
   CKickingBearish*  GetKickingBearish() { return m_kickingBearish; }
};

//+------------------------------------------------------------------+
//| تنفيذ CKickingBullish                                           |
//+------------------------------------------------------------------+
CKickingBullish::CKickingBullish()
{
   m_minGapSize = 0.01;         // 1% حد أدنى للفجوة
   m_minBodyRatio = 0.8;        // 80% نسبة جسم دنيا
   m_maxShadowRatio = 0.1;      // 10% نسبة ظل قصوى
   m_requireMarubozu = true;    // يتطلب ماروبوزو افتراضياً
}

CKickingBullish::~CKickingBullish()
{
}

bool CKickingBullish::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CKickingBullish::IsMarubozuCandle(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[])
{
   if(idx >= ArraySize(open)) return false;
   
   double bodySize = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   
   if(range <= 0) return false;
   
   double bodyRatio = bodySize / range;
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   double shadowRatio = (upperShadow + lowerShadow) / range;
   
   return (bodyRatio >= m_minBodyRatio && shadowRatio <= m_maxShadowRatio);
}

bool CKickingBullish::IsValidKickingBullish(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون هبوطية
   bool firstBearish = CCandleUtils::IsBearish(open[idx+1], close[idx+1]);
   if(!firstBearish) return false;
   
   // الشمعة الثانية يجب أن تكون صعودية
   bool secondBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
   if(!secondBullish) return false;
   
   // فحص ماروبوزو إذا كان مطلوباً
   if(m_requireMarubozu)
   {
      if(!IsMarubozuCandle(idx+1, open, high, low, close) || 
         !IsMarubozuCandle(idx, open, high, low, close))
         return false;
   }
   
   // فحص الفجوة الصعودية - يجب أن يفتح أدنى سعر للشمعة الثانية أعلى من أعلى سعر للأولى
   if(low[idx] <= high[idx+1])
      return false;
   
   // حساب حجم الفجوة
   double gapSize = CalculateGapSize(idx, open, high, low, close);
   if(gapSize < m_minGapSize)
      return false;
   
   return true;
}

double CKickingBullish::CalculateGapSize(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   if(avgPrice <= 0) return 0.0;
   
   double gapSize = low[idx] - high[idx+1];
   return gapSize / avgPrice;
}

double CKickingBullish::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الفجوة
   double gapSize = CalculateGapSize(idx, open, high, low, close);
   double gapStrength = MathMin(1.0, gapSize / (m_minGapSize * 3.0)); // تطبيع نسبة إلى 3 أضعاف الحد الأدنى
   
   // قوة الشموع (ماروبوزو)
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   
   double firstBodyRatio = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   double secondBodyRatio = (secondRange > 0) ? secondBodySize / secondRange : 0.0;
   double avgBodyStrength = (firstBodyRatio + secondBodyRatio) / 2.0;
   
   // حجم الأجسام
   double avgRange = (firstRange + secondRange) / 2.0;
   double avgBodySize = (firstBodySize + secondBodySize) / 2.0;
   double sizeStrength = (avgRange > 0) ? avgBodySize / avgRange : 0.0;
   
   // القوة الإجمالية
   double totalStrength = 1.5 + gapStrength * 1.0 + avgBodyStrength * 0.8 + sizeStrength * 0.4;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CKickingBullish::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidKickingBullish(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "الركل الصعودي";
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.80 + (result.strength - 1.0) * 0.1; // موثوقية عالية
   result.confidence = MathMin(1.0, result.reliability * 1.2);
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
//| تنفيذ CKickingBearish                                           |
//+------------------------------------------------------------------+
CKickingBearish::CKickingBearish()
{
   m_minGapSize = 0.01;         // 1% حد أدنى للفجوة
   m_minBodyRatio = 0.8;        // 80% نسبة جسم دنيا
   m_maxShadowRatio = 0.1;      // 10% نسبة ظل قصوى
   m_requireMarubozu = true;    // يتطلب ماروبوزو افتراضياً
}

CKickingBearish::~CKickingBearish()
{
}

bool CKickingBearish::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CKickingBearish::IsMarubozuCandle(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[])
{
   if(idx >= ArraySize(open)) return false;
   
   double bodySize = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   
   if(range <= 0) return false;
   
   double bodyRatio = bodySize / range;
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   double shadowRatio = (upperShadow + lowerShadow) / range;
   
   return (bodyRatio >= m_minBodyRatio && shadowRatio <= m_maxShadowRatio);
}

bool CKickingBearish::IsValidKickingBearish(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون صعودية
   bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
   if(!firstBullish) return false;
   
   // الشمعة الثانية يجب أن تكون هبوطية
   bool secondBearish = CCandleUtils::IsBearish(open[idx], close[idx]);
   if(!secondBearish) return false;
   
   // فحص ماروبوزو إذا كان مطلوباً
   if(m_requireMarubozu)
   {
      if(!IsMarubozuCandle(idx+1, open, high, low, close) || 
         !IsMarubozuCandle(idx, open, high, low, close))
         return false;
   }
   
   // فحص الفجوة الهبوطية - يجب أن يفتح أعلى سعر للشمعة الثانية أسفل أدنى سعر للأولى
   if(high[idx] >= low[idx+1])
      return false;
   
   // حساب حجم الفجوة
   double gapSize = CalculateGapSize(idx, open, high, low, close);
   if(gapSize < m_minGapSize)
      return false;
   
   return true;
}

double CKickingBearish::CalculateGapSize(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   if(avgPrice <= 0) return 0.0;
   
   double gapSize = low[idx+1] - high[idx];
   return gapSize / avgPrice;
}

double CKickingBearish::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الفجوة
   double gapSize = CalculateGapSize(idx, open, high, low, close);
   double gapStrength = MathMin(1.0, gapSize / (m_minGapSize * 3.0)); // تطبيع نسبة إلى 3 أضعاف الحد الأدنى
   
   // قوة الشموع (ماروبوزو)
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   
   double firstBodyRatio = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   double secondBodyRatio = (secondRange > 0) ? secondBodySize / secondRange : 0.0;
   double avgBodyStrength = (firstBodyRatio + secondBodyRatio) / 2.0;
   
   // حجم الأجسام
   double avgRange = (firstRange + secondRange) / 2.0;
   double avgBodySize = (firstBodySize + secondBodySize) / 2.0;
   double sizeStrength = (avgRange > 0) ? avgBodySize / avgRange : 0.0;
   
   // القوة الإجمالية
   double totalStrength = 1.5 + gapStrength * 1.0 + avgBodyStrength * 0.8 + sizeStrength * 0.4;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CKickingBearish::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidKickingBearish(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "الركل الهبوطي";
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.80 + (result.strength - 1.0) * 0.1; // موثوقية عالية
   result.confidence = MathMin(1.0, result.reliability * 1.2);
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
//| تنفيذ CKickingPatterns                                          |
//+------------------------------------------------------------------+
CKickingPatterns::CKickingPatterns()
{
   m_kickingBullish = NULL;
   m_kickingBearish = NULL;
   
   m_enableBullish = true;
   m_enableBearish = true;
}

CKickingPatterns::~CKickingPatterns()
{
   Deinitialize();
}

bool CKickingPatterns::IsValidPointer(void* ptr)
{
   return (CheckPointer(ptr) != POINTER_INVALID);
}

bool CKickingPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
   
   // إنشاء كائنات الأنماط
   m_kickingBullish = new CKickingBullish();
   m_kickingBearish = new CKickingBearish();
   
   // تهيئة جميع الأنماط
   bool success = true;
   if(IsValidPointer(m_kickingBullish)) 
      success = success && m_kickingBullish.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_kickingBearish)) 
      success = success && m_kickingBearish.Initialize(symbol, timeframe);
   else
      success = false;
   
   return success;
}

void CKickingPatterns::Deinitialize()
{
   if(IsValidPointer(m_kickingBullish)) 
   { 
      delete m_kickingBullish; 
      m_kickingBullish = NULL; 
   }
   
   if(IsValidPointer(m_kickingBearish)) 
   { 
      delete m_kickingBearish; 
      m_kickingBearish = NULL; 
   }
   
   CPatternDetector::Deinitialize();
}

void CKickingPatterns::EnableAllKickingPatterns(bool enable)
{
   m_enableBullish = enable;
   m_enableBearish = enable;
}

int CKickingPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                      const double &open[], const double &high[], const double &low[], 
                                      const double &close[], const long &volume[], 
                                      SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // كشف الركل الصعودي
   if(m_enableBullish && IsValidPointer(m_kickingBullish))
   {
      int patternCount = m_kickingBullish.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
   
   // كشف الركل الهبوطي
   if(m_enableBearish && IsValidPointer(m_kickingBearish))
   {
      int patternCount = m_kickingBearish.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
