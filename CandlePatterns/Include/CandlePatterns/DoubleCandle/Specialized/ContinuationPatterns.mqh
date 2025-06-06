//+------------------------------------------------------------------+
//|                                         ContinuationPatterns.mqh |
//|                                        أنماط الاستمرار اليابانية |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../Base/PatternDetector.mqh"
#include "../../Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| فئة تثبيت الحصيرة                                               |
//+------------------------------------------------------------------+
class CMatHold : public CPatternDetector
{
private:
   double            m_minFirstBodyRatio;     // نسبة الجسم الأول الدنيا
   double            m_maxSecondBodyRatio;    // نسبة الجسم الثاني القصوى
   double            m_gapThreshold;          // حد الفجوة
   bool              m_requireUptrend;        // يتطلب اتجاه صاعد
   int               m_minCandleCount;        // الحد الأدنى لعدد الشموع
   
public:
                     CMatHold();
                     ~CMatHold();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMinFirstBodyRatio(double ratio) { m_minFirstBodyRatio = MathMax(0.5, MathMin(0.9, ratio)); }
   void              SetMaxSecondBodyRatio(double ratio) { m_maxSecondBodyRatio = MathMax(0.1, MathMin(0.5, ratio)); }
   void              SetGapThreshold(double threshold) { m_gapThreshold = MathMax(0.001, MathMin(0.02, threshold)); }
   void              SetRequireUptrend(bool require) { m_requireUptrend = require; }
   void              SetMinCandleCount(int count) { m_minCandleCount = MathMax(2, MathMin(5, count)); }
   
   // دوال مساعدة
   bool              IsValidMatHold(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة طرق الثلاثة الصاعدة (الجزء المزدوج)                        |
//+------------------------------------------------------------------+
class CRisingThreeMethods : public CPatternDetector
{
private:
   double            m_minLongBodyRatio;      // نسبة الجسم الطويل الدنيا
   double            m_maxShortBodyRatio;     // نسبة الجسم القصير القصوى
   double            m_consolidationRange;    // نطاق التماسك
   bool              m_requireUptrend;        // يتطلب اتجاه صاعد
   
public:
                     CRisingThreeMethods();
                     ~CRisingThreeMethods();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMinLongBodyRatio(double ratio) { m_minLongBodyRatio = MathMax(0.6, MathMin(0.9, ratio)); }
   void              SetMaxShortBodyRatio(double ratio) { m_maxShortBodyRatio = MathMax(0.1, MathMin(0.4, ratio)); }
   void              SetConsolidationRange(double range) { m_consolidationRange = MathMax(0.3, MathMin(0.8, range)); }
   void              SetRequireUptrend(bool require) { m_requireUptrend = require; }
   
   // دوال مساعدة
   bool              IsValidRisingThreeMethods(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   bool              IsConsolidationCandle(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[], double prevHigh, double prevLow);
};

//+------------------------------------------------------------------+
//| فئة طرق الثلاثة الهابطة (الجزء المزدوج)                        |
//+------------------------------------------------------------------+
class CFallingThreeMethods : public CPatternDetector
{
private:
   double            m_minLongBodyRatio;      // نسبة الجسم الطويل الدنيا
   double            m_maxShortBodyRatio;     // نسبة الجسم القصير القصوى
   double            m_consolidationRange;    // نطاق التماسك
   bool              m_requireDowntrend;      // يتطلب اتجاه هابط
   
public:
                     CFallingThreeMethods();
                     ~CFallingThreeMethods();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMinLongBodyRatio(double ratio) { m_minLongBodyRatio = MathMax(0.6, MathMin(0.9, ratio)); }
   void              SetMaxShortBodyRatio(double ratio) { m_maxShortBodyRatio = MathMax(0.1, MathMin(0.4, ratio)); }
   void              SetConsolidationRange(double range) { m_consolidationRange = MathMax(0.3, MathMin(0.8, range)); }
   void              SetRequireDowntrend(bool require) { m_requireDowntrend = require; }
   
   // دوال مساعدة
   bool              IsValidFallingThreeMethods(const int idx, const double &open[], const double &high[], 
                                              const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   bool              IsConsolidationCandle(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[], double prevHigh, double prevLow);
};

//+------------------------------------------------------------------+
//| محرك أنماط الاستمرار الموحد                                     |
//+------------------------------------------------------------------+
class CContinuationPatterns : public CPatternDetector
{
private:
   CMatHold*               m_matHold;
   CRisingThreeMethods*    m_risingThreeMethods;
   CFallingThreeMethods*   m_fallingThreeMethods;
   
   bool                    m_enableMatHold;
   bool                    m_enableRisingThreeMethods;
   bool                    m_enableFallingThreeMethods;
   
   // دالة مساعدة للتحقق من صحة المؤشر
   bool                    IsValidPointer(void* ptr);
   
public:
                     CContinuationPatterns();
                     ~CContinuationPatterns();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // إعدادات التفعيل
   void              EnableMatHold(bool enable) { m_enableMatHold = enable; }
   void              EnableRisingThreeMethods(bool enable) { m_enableRisingThreeMethods = enable; }
   void              EnableFallingThreeMethods(bool enable) { m_enableFallingThreeMethods = enable; }
   void              EnableAllContinuationPatterns(bool enable);
   
   // دوال الوصول لكائنات الأنماط الفرعية
   CMatHold*         GetMatHold() { return m_matHold; }
   CRisingThreeMethods* GetRisingThreeMethods() { return m_risingThreeMethods; }
   CFallingThreeMethods* GetFallingThreeMethods() { return m_fallingThreeMethods; }
};

//+------------------------------------------------------------------+
//| تنفيذ CMatHold                                                  |
//+------------------------------------------------------------------+
CMatHold::CMatHold()
{
   m_minFirstBodyRatio = 0.7;   // 70% نسبة جسم أول دنيا
   m_maxSecondBodyRatio = 0.3;  // 30% نسبة جسم ثاني قصوى
   m_gapThreshold = 0.005;      // 0.5% حد الفجوة
   m_requireUptrend = true;     // يتطلب اتجاه صاعد
   m_minCandleCount = 2;        // 2 شمعة كحد أدنى
}

CMatHold::~CMatHold()
{
}

bool CMatHold::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CMatHold::IsValidMatHold(const int idx, const double &open[], const double &high[], 
                            const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس (نحتاج على الأقل شمعتين)
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون صعودية وقوية
   if(m_requireUptrend)
   {
      bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
      if(!firstBullish) return false;
      
      double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
      double firstRange = high[idx+1] - low[idx+1];
      
      if(firstRange > 0 && (firstBodySize / firstRange) < m_minFirstBodyRatio)
         return false;
   }
   
   // الشمعة الثانية يجب أن تكون صغيرة ومع فجوة صعودية
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   
   if(secondRange > 0 && (secondBodySize / secondRange) > m_maxSecondBodyRatio)
      return false;
   
   // فحص الفجوة الصعودية
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   double gapSize = (open[idx] - close[idx+1]) / avgPrice;
   
   if(gapSize < m_gapThreshold)
      return false;
   
   // يجب أن تكون الشمعة الثانية أعلى من الأولى
   if(low[idx] <= high[idx+1])
      return false;
   
   return true;
}

double CMatHold::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                 const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الشمعة الأولى
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double firstStrength = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   
   // ضعف الشمعة الثانية (كلما كانت أصغر، زادت القوة)
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   double secondWeakness = 1.0 - ((secondRange > 0) ? secondBodySize / secondRange : 0.0);
   
   // قوة الفجوة
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   double gapSize = (avgPrice > 0) ? (open[idx] - close[idx+1]) / avgPrice : 0.0;
   double gapStrength = MathMin(1.0, gapSize / (m_gapThreshold * 3.0));
   
   // القوة الإجمالية
   double totalStrength = 1.0 + firstStrength * 0.5 + secondWeakness * 0.6 + gapStrength * 0.4;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CMatHold::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                              const double &open[], const double &high[], const double &low[], 
                              const double &close[], const long &volume[], 
                              SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidMatHold(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "تثبيت الحصيرة";
   result.direction = PATTERN_BULLISH; // نمط استمرار صعودي
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.65 + (result.strength - 1.0) * 0.08; // موثوقية جيدة
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
//| تنفيذ CRisingThreeMethods                                       |
//+------------------------------------------------------------------+
CRisingThreeMethods::CRisingThreeMethods()
{
   m_minLongBodyRatio = 0.7;    // 70% نسبة جسم طويل دنيا
   m_maxShortBodyRatio = 0.3;   // 30% نسبة جسم قصير قصوى
   m_consolidationRange = 0.5;  // 50% نطاق التماسك
   m_requireUptrend = true;     // يتطلب اتجاه صاعد
}

CRisingThreeMethods::~CRisingThreeMethods()
{
}

bool CRisingThreeMethods::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CRisingThreeMethods::IsConsolidationCandle(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], 
                                               double prevHigh, double prevLow)
{
   if(idx >= ArraySize(open)) return false;
   
   // يجب أن تكون الشمعة داخل نطاق الشمعة السابقة
   if(high[idx] > prevHigh || low[idx] < prevLow)
      return false;
   
   // يجب أن تكون صغيرة الجسم
   double bodySize = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   
   if(range > 0 && (bodySize / range) > m_maxShortBodyRatio)
      return false;
   
   return true;
}

bool CRisingThreeMethods::IsValidRisingThreeMethods(const int idx, const double &open[], const double &high[], 
                                                  const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس (نحتاج على الأقل شمعتين)
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون صعودية وطويلة
   if(m_requireUptrend)
   {
      bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
      if(!firstBullish) return false;
      
      double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
      double firstRange = high[idx+1] - low[idx+1];
      
      if(firstRange > 0 && (firstBodySize / firstRange) < m_minLongBodyRatio)
         return false;
   }
   
   // الشمعة الثانية يجب أن تكون شمعة تماسك
   if(!IsConsolidationCandle(idx, open, high, low, close, high[idx+1], low[idx+1]))
      return false;
   
   return true;
}

double CRisingThreeMethods::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الشمعة الأولى
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double firstStrength = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   
   // قوة التماسك (كلما كانت الشمعة الثانية أصغر، زادت القوة)
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   double consolidationStrength = 1.0 - ((secondRange > 0) ? secondBodySize / secondRange : 0.0);
   
   // احتواء الشمعة الثانية داخل الأولى
   double containmentRatio = 0.0;
   if(firstRange > 0)
   {
      double containedRange = high[idx] - low[idx];
      containmentRatio = 1.0 - (containedRange / firstRange);
      containmentRatio = MathMax(0.0, MathMin(1.0, containmentRatio));
   }
   
   // القوة الإجمالية
   double totalStrength = 1.0 + firstStrength * 0.5 + consolidationStrength * 0.4 + containmentRatio * 0.3;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CRisingThreeMethods::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                         const double &open[], const double &high[], const double &low[], 
                                         const double &close[], const long &volume[], 
                                         SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidRisingThreeMethods(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "طرق الثلاثة الصاعدة (جزء)";
   result.direction = PATTERN_BULLISH; // نمط استمرار صعودي
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.60 + (result.strength - 1.0) * 0.08; // موثوقية متوسطة-جيدة
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
//| تنفيذ CFallingThreeMethods                                      |
//+------------------------------------------------------------------+
CFallingThreeMethods::CFallingThreeMethods()
{
   m_minLongBodyRatio = 0.7;    // 70% نسبة جسم طويل دنيا
   m_maxShortBodyRatio = 0.3;   // 30% نسبة جسم قصير قصوى
   m_consolidationRange = 0.5;  // 50% نطاق التماسك
   m_requireDowntrend = true;   // يتطلب اتجاه هابط
}

CFallingThreeMethods::~CFallingThreeMethods()
{
}

bool CFallingThreeMethods::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CFallingThreeMethods::IsConsolidationCandle(const int idx, const double &open[], const double &high[], 
                                                const double &low[], const double &close[], 
                                                double prevHigh, double prevLow)
{
   if(idx >= ArraySize(open)) return false;
   
   // يجب أن تكون الشمعة داخل نطاق الشمعة السابقة
   if(high[idx] > prevHigh || low[idx] < prevLow)
      return false;
   
   // يجب أن تكون صغيرة الجسم
   double bodySize = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   
   if(range > 0 && (bodySize / range) > m_maxShortBodyRatio)
      return false;
   
   return true;
}

bool CFallingThreeMethods::IsValidFallingThreeMethods(const int idx, const double &open[], const double &high[], 
                                                     const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس (نحتاج على الأقل شمعتين)
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون هبوطية وطويلة
   if(m_requireDowntrend)
   {
      bool firstBearish = CCandleUtils::IsBearish(open[idx+1], close[idx+1]);
      if(!firstBearish) return false;
      
      double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
      double firstRange = high[idx+1] - low[idx+1];
      
      if(firstRange > 0 && (firstBodySize / firstRange) < m_minLongBodyRatio)
         return false;
   }
   
   // الشمعة الثانية يجب أن تكون شمعة تماسك
   if(!IsConsolidationCandle(idx, open, high, low, close, high[idx+1], low[idx+1]))
      return false;
   
   return true;
}

double CFallingThreeMethods::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الشمعة الأولى
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double firstStrength = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   
   // قوة التماسك (كلما كانت الشمعة الثانية أصغر، زادت القوة)
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   double consolidationStrength = 1.0 - ((secondRange > 0) ? secondBodySize / secondRange : 0.0);
   
   // احتواء الشمعة الثانية داخل الأولى
   double containmentRatio = 0.0;
   if(firstRange > 0)
   {
      double containedRange = high[idx] - low[idx];
      containmentRatio = 1.0 - (containedRange / firstRange);
      containmentRatio = MathMax(0.0, MathMin(1.0, containmentRatio));
   }
   
   // القوة الإجمالية
   double totalStrength = 1.0 + firstStrength * 0.5 + consolidationStrength * 0.4 + containmentRatio * 0.3;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CFallingThreeMethods::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                          const double &open[], const double &high[], const double &low[], 
                                          const double &close[], const long &volume[], 
                                          SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidFallingThreeMethods(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "طرق الثلاثة الهابطة (جزء)";
   result.direction = PATTERN_BEARISH; // نمط استمرار هبوطي
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.60 + (result.strength - 1.0) * 0.08; // موثوقية متوسطة-جيدة
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
//| تنفيذ CContinuationPatterns                                     |
//+------------------------------------------------------------------+
CContinuationPatterns::CContinuationPatterns()
{
   m_matHold = NULL;
   m_risingThreeMethods = NULL;
   m_fallingThreeMethods = NULL;
   
   m_enableMatHold = true;
   m_enableRisingThreeMethods = true;
   m_enableFallingThreeMethods = true;
}

CContinuationPatterns::~CContinuationPatterns()
{
   Deinitialize();
}

bool CContinuationPatterns::IsValidPointer(void* ptr)
{
   return (CheckPointer(ptr) != POINTER_INVALID);
}

bool CContinuationPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
   
   // إنشاء كائنات الأنماط
   m_matHold = new CMatHold();
   m_risingThreeMethods = new CRisingThreeMethods();
   m_fallingThreeMethods = new CFallingThreeMethods();
   
   // تهيئة جميع الأنماط
   bool success = true;
   if(IsValidPointer(m_matHold)) 
      success = success && m_matHold.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_risingThreeMethods)) 
      success = success && m_risingThreeMethods.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_fallingThreeMethods)) 
      success = success && m_fallingThreeMethods.Initialize(symbol, timeframe);
   else
      success = false;
   
   return success;
}

void CContinuationPatterns::Deinitialize()
{
   if(IsValidPointer(m_matHold)) 
   { 
      delete m_matHold; 
      m_matHold = NULL; 
   }
   
   if(IsValidPointer(m_risingThreeMethods)) 
   { 
      delete m_risingThreeMethods; 
      m_risingThreeMethods = NULL; 
   }
   
   if(IsValidPointer(m_fallingThreeMethods)) 
   { 
      delete m_fallingThreeMethods; 
      m_fallingThreeMethods = NULL; 
   }
   
   CPatternDetector::Deinitialize();
}

void CContinuationPatterns::EnableAllContinuationPatterns(bool enable)
{
   m_enableMatHold = enable;
   m_enableRisingThreeMethods = enable;
   m_enableFallingThreeMethods = enable;
}

int CContinuationPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                           const double &open[], const double &high[], const double &low[], 
                                           const double &close[], const long &volume[], 
                                           SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // كشف تثبيت الحصيرة
   if(m_enableMatHold && IsValidPointer(m_matHold))
   {
      int patternCount = m_matHold.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
   
   // كشف طرق الثلاثة الصاعدة
   if(m_enableRisingThreeMethods && IsValidPointer(m_risingThreeMethods))
   {
      int patternCount = m_risingThreeMethods.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
   
   // كشف طرق الثلاثة الهابطة
   if(m_enableFallingThreeMethods && IsValidPointer(m_fallingThreeMethods))
   {
      int patternCount = m_fallingThreeMethods.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
