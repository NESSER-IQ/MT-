//+------------------------------------------------------------------+
//|                                           EngulfingPatterns.mqh |
//|                                                أنماط الابتلاع اليابانية    |
//|                                   حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../Base/PatternDetector.mqh"
#include "../../Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الابتلاع الصعودي                                      |
//+------------------------------------------------------------------+
class CBullishEngulfing : public CPatternDetector
{
private:
   double            m_minEngulfmentRatio;    // نسبة الابتلاع الدنيا
   double            m_volumeThreshold;       // حد الحجم
   
public:
                     CBullishEngulfing();
                     ~CBullishEngulfing();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMinEngulfmentRatio(double ratio) { m_minEngulfmentRatio = MathMax(0.5, MathMin(1.0, ratio)); }
   void              SetVolumeThreshold(double threshold) { m_volumeThreshold = MathMax(0.0, threshold); }
   
   // دوال مساعدة
   bool              IsValidBullishEngulfing(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], const long &volume[]);
   double            CalculateEngulfmentStrength(const int idx, const double &open[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة أنماط الابتلاع الهبوطي                                      |
//+------------------------------------------------------------------+
class CBearishEngulfing : public CPatternDetector
{
private:
   double            m_minEngulfmentRatio;    // نسبة الابتلاع الدنيا
   double            m_volumeThreshold;       // حد الحجم
   
public:
                     CBearishEngulfing();
                     ~CBearishEngulfing();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMinEngulfmentRatio(double ratio) { m_minEngulfmentRatio = MathMax(0.5, MathMin(1.0, ratio)); }
   void              SetVolumeThreshold(double threshold) { m_volumeThreshold = MathMax(0.0, threshold); }
   
   // دوال مساعدة
   bool              IsValidBearishEngulfing(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], const long &volume[]);
   double            CalculateEngulfmentStrength(const int idx, const double &open[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة أنماط الابتلاع الجزئي                                       |
//+------------------------------------------------------------------+
class CPartialEngulfing : public CPatternDetector
{
private:
   double            m_minPartialRatio;       // نسبة الابتلاع الجزئي الدنيا
   double            m_maxPartialRatio;       // نسبة الابتلاع الجزئي العليا
   
public:
                     CPartialEngulfing();
                     ~CPartialEngulfing();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPartialRatioRange(double minRatio, double maxRatio);
   
   // دوال مساعدة
   bool              IsValidPartialEngulfing(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[]);
   double            CalculatePartialStrength(const int idx, const double &open[], const double &close[]);
};

//+------------------------------------------------------------------+
//| محرك أنماط الابتلاع الموحد                                      |
//+------------------------------------------------------------------+
class CEngulfingPatterns : public CPatternDetector
{
private:
   CBullishEngulfing*   m_bullishEngulfing;
   CBearishEngulfing*   m_bearishEngulfing;
   CPartialEngulfing*   m_partialEngulfing;
   
   bool                 m_enableBullish;
   bool                 m_enableBearish;
   bool                 m_enablePartial;
   
   // دالة مساعدة للتحقق من صحة المؤشر
   bool                 IsValidPointer(void* ptr);
   
public:
                     CEngulfingPatterns();
                     ~CEngulfingPatterns();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // إعدادات التفعيل
   void              EnableBullishEngulfing(bool enable) { m_enableBullish = enable; }
   void              EnableBearishEngulfing(bool enable) { m_enableBearish = enable; }
   void              EnablePartialEngulfing(bool enable) { m_enablePartial = enable; }
   void              EnableAllEngulfingPatterns(bool enable);
   
   // دوال الوصول لكائنات الأنماط الفرعية
   CBullishEngulfing* GetBullishEngulfing() { return m_bullishEngulfing; }
   CBearishEngulfing* GetBearishEngulfing() { return m_bearishEngulfing; }
   CPartialEngulfing* GetPartialEngulfing() { return m_partialEngulfing; }
};

//+------------------------------------------------------------------+
//| تنفيذ CBullishEngulfing                                         |
//+------------------------------------------------------------------+
CBullishEngulfing::CBullishEngulfing()
{
   m_minEngulfmentRatio = 0.8;  // 80% ابتلاع كحد أدنى
   m_volumeThreshold = 1.2;     // 120% من متوسط الحجم
}

CBullishEngulfing::~CBullishEngulfing()
{
}

bool CBullishEngulfing::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CBullishEngulfing::IsValidBullishEngulfing(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], const long &volume[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة السابقة يجب أن تكون هبوطية
   bool prevBearish = CCandleUtils::IsBearish(open[idx+1], close[idx+1]);
   if(!prevBearish) return false;
   
   // الشمعة الحالية يجب أن تكون صعودية
   bool currBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
   if(!currBullish) return false;
   
   // فحص الابتلاع: الجسم الحالي يبتلع الجسم السابق
   double prevBodyTop = MathMax(open[idx+1], close[idx+1]);
   double prevBodyBottom = MathMin(open[idx+1], close[idx+1]);
   double currBodyTop = MathMax(open[idx], close[idx]);
   double currBodyBottom = MathMin(open[idx], close[idx]);
   
   // شروط الابتلاع الكامل
   if(currBodyBottom >= prevBodyBottom || currBodyTop <= prevBodyTop)
      return false;
   
   // حساب نسبة الابتلاع
   double prevBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double currBodySize = MathAbs(close[idx] - open[idx]);
   double engulfmentRatio = (prevBodySize > 0) ? currBodySize / prevBodySize : 0;
   
   if(engulfmentRatio < m_minEngulfmentRatio)
      return false;
   
   // فحص الحجم إذا كان مطلوباً
   if(m_volumeThreshold > 0 && ArraySize(volume) > idx && idx >= 0)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx);
      if(avgVolume > 0 && volume[idx] < m_volumeThreshold * avgVolume)
         return false;
   }
   
   return true;
}

double CBullishEngulfing::CalculateEngulfmentStrength(const int idx, const double &open[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   double prevBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double currBodySize = MathAbs(close[idx] - open[idx]);
   
   if(prevBodySize <= 0) return 0.0;
   
   double ratio = currBodySize / prevBodySize;
   return MathMin(3.0, ratio); // تحديد القوة بين 0-3
}

int CBullishEngulfing::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                       const double &open[], const double &high[], const double &low[], 
                                       const double &close[], const long &volume[], 
                                       SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidBullishEngulfing(idx, open, high, low, close, volume))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "الابتلاع الصعودي";
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateEngulfmentStrength(idx, open, close);
   result.reliability = 0.75 + (result.strength - 1.0) * 0.1; // موثوقية أساسية 75%
   result.confidence = MathMin(1.0, result.reliability * 1.1);
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
//| تنفيذ CBearishEngulfing                                         |
//+------------------------------------------------------------------+
CBearishEngulfing::CBearishEngulfing()
{
   m_minEngulfmentRatio = 0.8;  // 80% ابتلاع كحد أدنى
   m_volumeThreshold = 1.2;     // 120% من متوسط الحجم
}

CBearishEngulfing::~CBearishEngulfing()
{
}

bool CBearishEngulfing::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CBearishEngulfing::IsValidBearishEngulfing(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], const long &volume[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة السابقة يجب أن تكون صعودية
   bool prevBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
   if(!prevBullish) return false;
   
   // الشمعة الحالية يجب أن تكون هبوطية
   bool currBearish = CCandleUtils::IsBearish(open[idx], close[idx]);
   if(!currBearish) return false;
   
   // فحص الابتلاع: الجسم الحالي يبتلع الجسم السابق
   double prevBodyTop = MathMax(open[idx+1], close[idx+1]);
   double prevBodyBottom = MathMin(open[idx+1], close[idx+1]);
   double currBodyTop = MathMax(open[idx], close[idx]);
   double currBodyBottom = MathMin(open[idx], close[idx]);
   
   // شروط الابتلاع الكامل
   if(currBodyTop <= prevBodyTop || currBodyBottom >= prevBodyBottom)
      return false;
   
   // حساب نسبة الابتلاع
   double prevBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double currBodySize = MathAbs(close[idx] - open[idx]);
   double engulfmentRatio = (prevBodySize > 0) ? currBodySize / prevBodySize : 0;
   
   if(engulfmentRatio < m_minEngulfmentRatio)
      return false;
   
   // فحص الحجم إذا كان مطلوباً
   if(m_volumeThreshold > 0 && ArraySize(volume) > idx && idx >= 0)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx);
      if(avgVolume > 0 && volume[idx] < m_volumeThreshold * avgVolume)
         return false;
   }
   
   return true;
}

double CBearishEngulfing::CalculateEngulfmentStrength(const int idx, const double &open[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   double prevBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double currBodySize = MathAbs(close[idx] - open[idx]);
   
   if(prevBodySize <= 0) return 0.0;
   
   double ratio = currBodySize / prevBodySize;
   return MathMin(3.0, ratio); // تحديد القوة بين 0-3
}

int CBearishEngulfing::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                       const double &open[], const double &high[], const double &low[], 
                                       const double &close[], const long &volume[], 
                                       SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidBearishEngulfing(idx, open, high, low, close, volume))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "الابتلاع الهبوطي";
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateEngulfmentStrength(idx, open, close);
   result.reliability = 0.75 + (result.strength - 1.0) * 0.1; // موثوقية أساسية 75%
   result.confidence = MathMin(1.0, result.reliability * 1.1);
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
//| تنفيذ CPartialEngulfing                                         |
//+------------------------------------------------------------------+
CPartialEngulfing::CPartialEngulfing()
{
   m_minPartialRatio = 0.4;  // 40% ابتلاع جزئي كحد أدنى
   m_maxPartialRatio = 0.8;  // 80% ابتلاع جزئي كحد أعلى
}

CPartialEngulfing::~CPartialEngulfing()
{
}

bool CPartialEngulfing::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

void CPartialEngulfing::SetPartialRatioRange(double minRatio, double maxRatio)
{
   m_minPartialRatio = MathMax(0.2, MathMin(0.6, minRatio));
   m_maxPartialRatio = MathMax(m_minPartialRatio + 0.1, MathMin(0.9, maxRatio));
}

bool CPartialEngulfing::IsValidPartialEngulfing(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // يجب أن تكون الشمعتان من اتجاهين متضادين
   bool prevBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
   bool currBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
   
   if(prevBullish == currBullish) return false;
   
   // حساب الابتلاع الجزئي
   double prevBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double currBodySize = MathAbs(close[idx] - open[idx]);
   
   if(prevBodySize <= 0) return false;
   
   double partialRatio = currBodySize / prevBodySize;
   
   // التحقق من أن النسبة ضمن النطاق المطلوب
   if(partialRatio < m_minPartialRatio || partialRatio > m_maxPartialRatio)
      return false;
   
   // التحقق من وجود ابتلاع جزئي حقيقي
   double prevBodyTop = MathMax(open[idx+1], close[idx+1]);
   double prevBodyBottom = MathMin(open[idx+1], close[idx+1]);
   double currBodyTop = MathMax(open[idx], close[idx]);
   double currBodyBottom = MathMin(open[idx], close[idx]);
   
   // يجب أن يكون هناك تداخل جزئي
   bool hasOverlap = (currBodyTop > prevBodyBottom && currBodyTop < prevBodyTop) ||
                     (currBodyBottom > prevBodyBottom && currBodyBottom < prevBodyTop);
   
   return hasOverlap;
}

double CPartialEngulfing::CalculatePartialStrength(const int idx, const double &open[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   double prevBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double currBodySize = MathAbs(close[idx] - open[idx]);
   
   if(prevBodySize <= 0) return 0.0;
   
   double ratio = currBodySize / prevBodySize;
   
   // تحويل النسبة إلى قوة من 1-2 للابتلاع الجزئي
   double strength = 1.0 + (ratio - m_minPartialRatio) / (m_maxPartialRatio - m_minPartialRatio);
   return MathMin(2.0, MathMax(1.0, strength));
}

int CPartialEngulfing::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                       const double &open[], const double &high[], const double &low[], 
                                       const double &close[], const long &volume[], 
                                       SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidPartialEngulfing(idx, open, high, low, close))
      return 0;
   
   // تحديد الاتجاه
   bool currBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
   ENUM_PATTERN_DIRECTION direction = currBullish ? PATTERN_BULLISH : PATTERN_BEARISH;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = currBullish ? "الابتلاع الجزئي الصعودي" : "الابتلاع الجزئي الهبوطي";
   result.direction = direction;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculatePartialStrength(idx, open, close);
   result.reliability = 0.55 + (result.strength - 1.0) * 0.1; // موثوقية أقل من الابتلاع الكامل
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
//| تنفيذ CEngulfingPatterns                                        |
//+------------------------------------------------------------------+
CEngulfingPatterns::CEngulfingPatterns()
{
   m_bullishEngulfing = NULL;
   m_bearishEngulfing = NULL;
   m_partialEngulfing = NULL;
   
   m_enableBullish = true;
   m_enableBearish = true;
   m_enablePartial = true;
}

CEngulfingPatterns::~CEngulfingPatterns()
{
   Deinitialize();
}

bool CEngulfingPatterns::IsValidPointer(void* ptr)
{
   return (CheckPointer(ptr) != POINTER_INVALID);
}

bool CEngulfingPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
   
   // إنشاء كائنات الأنماط
   m_bullishEngulfing = new CBullishEngulfing();
   m_bearishEngulfing = new CBearishEngulfing();
   m_partialEngulfing = new CPartialEngulfing();
   
   // تهيئة جميع الأنماط
   bool success = true;
   if(IsValidPointer(m_bullishEngulfing)) 
      success = success && m_bullishEngulfing.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_bearishEngulfing)) 
      success = success && m_bearishEngulfing.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_partialEngulfing)) 
      success = success && m_partialEngulfing.Initialize(symbol, timeframe);
   else
      success = false;
   
   return success;
}

void CEngulfingPatterns::Deinitialize()
{
   if(IsValidPointer(m_bullishEngulfing)) 
   { 
      delete m_bullishEngulfing; 
      m_bullishEngulfing = NULL; 
   }
   
   if(IsValidPointer(m_bearishEngulfing)) 
   { 
      delete m_bearishEngulfing; 
      m_bearishEngulfing = NULL; 
   }
   
   if(IsValidPointer(m_partialEngulfing)) 
   { 
      delete m_partialEngulfing; 
      m_partialEngulfing = NULL; 
   }
   
   CPatternDetector::Deinitialize();
}

void CEngulfingPatterns::EnableAllEngulfingPatterns(bool enable)
{
   m_enableBullish = enable;
   m_enableBearish = enable;
   m_enablePartial = enable;
}

int CEngulfingPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                        const double &open[], const double &high[], const double &low[], 
                                        const double &close[], const long &volume[], 
                                        SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // كشف الابتلاع الصعودي
   if(m_enableBullish && IsValidPointer(m_bullishEngulfing))
   {
      int patternCount = m_bullishEngulfing.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
   
   // كشف الابتلاع الهبوطي
   if(m_enableBearish && IsValidPointer(m_bearishEngulfing))
   {
      int patternCount = m_bearishEngulfing.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
   
   // كشف الابتلاع الجزئي
   if(m_enablePartial && IsValidPointer(m_partialEngulfing))
   {
      int patternCount = m_partialEngulfing.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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