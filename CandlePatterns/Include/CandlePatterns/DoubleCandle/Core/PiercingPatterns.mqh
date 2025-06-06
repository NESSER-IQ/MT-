//+------------------------------------------------------------------+
//|                                            PiercingPatterns.mqh |
//|                                      أنماط الاختراق اليابانية    |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../Base/PatternDetector.mqh"
#include "../../Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| فئة خط الاختراق                                                 |
//+------------------------------------------------------------------+
class CPiercingLine : public CPatternDetector
{
private:
   double            m_minPenetration;        // الحد الأدنى لنسبة الاختراق
   double            m_maxPenetration;        // الحد الأقصى لنسبة الاختراق
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   bool              m_requireGap;            // يتطلب فجوة
   
public:
                     CPiercingLine();
                     ~CPiercingLine();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPenetrationRange(double minPen, double maxPen);
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.3, MathMin(0.9, ratio)); }
   void              SetRequireGap(bool require) { m_requireGap = require; }
   
   // دوال مساعدة
   bool              IsValidPiercingLine(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[]);
   double            CalculatePenetration(const int idx, const double &open[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة الغطاء السحابي المظلم                                        |
//+------------------------------------------------------------------+
class CDarkCloudCover : public CPatternDetector
{
private:
   double            m_minPenetration;        // الحد الأدنى لنسبة الاختراق
   double            m_maxPenetration;        // الحد الأقصى لنسبة الاختراق
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   bool              m_requireGap;            // يتطلب فجوة
   
public:
                     CDarkCloudCover();
                     ~CDarkCloudCover();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPenetrationRange(double minPen, double maxPen);
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.3, MathMin(0.9, ratio)); }
   void              SetRequireGap(bool require) { m_requireGap = require; }
   
   // دوال مساعدة
   bool              IsValidDarkCloudCover(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[]);
   double            CalculatePenetration(const int idx, const double &open[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة في العنق                                                    |
//+------------------------------------------------------------------+
class CInNeck : public CPatternDetector
{
private:
   double            m_penetrationTolerance;  // تسامح الاختراق
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   
public:
                     CInNeck();
                     ~CInNeck();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPenetrationTolerance(double tolerance) { m_penetrationTolerance = MathMax(0.01, MathMin(0.1, tolerance)); }
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.2, MathMin(0.8, ratio)); }
   
   // دوال مساعدة
   bool              IsValidInNeck(const int idx, const double &open[], const double &high[], 
                                 const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة على العنق                                                   |
//+------------------------------------------------------------------+
class COnNeck : public CPatternDetector
{
private:
   double            m_priceMatchTolerance;   // تسامح تطابق السعر
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   
public:
                     COnNeck();
                     ~COnNeck();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPriceMatchTolerance(double tolerance) { m_priceMatchTolerance = MathMax(0.01, MathMin(0.05, tolerance)); }
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.2, MathMin(0.8, ratio)); }
   
   // دوال مساعدة
   bool              IsValidOnNeck(const int idx, const double &open[], const double &high[], 
                                 const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة الدفع                                                       |
//+------------------------------------------------------------------+
class CThrusting : public CPatternDetector
{
private:
   double            m_minPenetration;        // الحد الأدنى للاختراق
   double            m_maxPenetration;        // الحد الأقصى للاختراق
   double            m_minBodyRatio;          // نسبة الجسم الدنيا
   
public:
                     CThrusting();
                     ~CThrusting();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetPenetrationRange(double minPen, double maxPen);
   void              SetMinBodyRatio(double ratio) { m_minBodyRatio = MathMax(0.2, MathMin(0.8, ratio)); }
   
   // دوال مساعدة
   bool              IsValidThrusting(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[]);
   double            CalculatePenetration(const int idx, const double &open[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| محرك أنماط الاختراق الموحد                                       |
//+------------------------------------------------------------------+
class CPiercingPatterns : public CPatternDetector
{
private:
   CPiercingLine*       m_piercingLine;
   CDarkCloudCover*     m_darkCloudCover;
   CInNeck*             m_inNeck;
   COnNeck*             m_onNeck;
   CThrusting*          m_thrusting;
   
   bool                 m_enablePiercingLine;
   bool                 m_enableDarkCloudCover;
   bool                 m_enableInNeck;
   bool                 m_enableOnNeck;
   bool                 m_enableThrusting;
   
   // دالة مساعدة للتحقق من صحة المؤشر
   bool                 IsValidPointer(void* ptr);
   
public:
                     CPiercingPatterns();
                     ~CPiercingPatterns();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // إعدادات التفعيل
   void              EnablePiercingLine(bool enable) { m_enablePiercingLine = enable; }
   void              EnableDarkCloudCover(bool enable) { m_enableDarkCloudCover = enable; }
   void              EnableInNeck(bool enable) { m_enableInNeck = enable; }
   void              EnableOnNeck(bool enable) { m_enableOnNeck = enable; }
   void              EnableThrusting(bool enable) { m_enableThrusting = enable; }
   void              EnableAllPiercingPatterns(bool enable);
   
   // دوال الوصول لكائنات الأنماط الفرعية
   CPiercingLine*    GetPiercingLine() { return m_piercingLine; }
   CDarkCloudCover*  GetDarkCloudCover() { return m_darkCloudCover; }
   CInNeck*          GetInNeck() { return m_inNeck; }
   COnNeck*          GetOnNeck() { return m_onNeck; }
   CThrusting*       GetThrusting() { return m_thrusting; }
};

//+------------------------------------------------------------------+
//| تنفيذ CPiercingLine                                             |
//+------------------------------------------------------------------+
CPiercingLine::CPiercingLine()
{
   m_minPenetration = 0.5;      // 50% حد أدنى للاختراق
   m_maxPenetration = 0.9;      // 90% حد أقصى للاختراق
   m_minBodyRatio = 0.6;        // 60% نسبة جسم دنيا
   m_requireGap = false;        // لا يتطلب فجوة افتراضياً
}

CPiercingLine::~CPiercingLine()
{
}

bool CPiercingLine::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

void CPiercingLine::SetPenetrationRange(double minPen, double maxPen)
{
   m_minPenetration = MathMax(0.3, MathMin(0.8, minPen));
   m_maxPenetration = MathMax(m_minPenetration + 0.1, MathMin(1.0, maxPen));
}

bool CPiercingLine::IsValidPiercingLine(const int idx, const double &open[], const double &high[], 
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
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minBodyRatio)
      return false;
   
   // الشمعة الثانية يجب أن تكون صعودية
   bool secondBullish = CCandleUtils::IsBullish(open[idx], close[idx]);
   if(!secondBullish) return false;
   
   // فحص الفجوة إذا كان مطلوباً
   if(m_requireGap && open[idx] >= close[idx+1])
      return false;
   
   // حساب نسبة الاختراق
   double penetration = CalculatePenetration(idx, open, close);
   if(penetration < m_minPenetration || penetration > m_maxPenetration)
      return false;
   
   // يجب أن تفتح الشمعة الثانية أسفل أدنى سعر للشمعة الأولى
   if(open[idx] > low[idx+1])
      return false;
   
   return true;
}

double CPiercingLine::CalculatePenetration(const int idx, const double &open[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   if(firstBodySize <= 0) return 0.0;
   
   double penetrationSize = close[idx] - close[idx+1];
   return penetrationSize / firstBodySize;
}

double CPiercingLine::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الاختراق
   double penetration = CalculatePenetration(idx, open, close);
   double penetrationStrength = (penetration - m_minPenetration) / (m_maxPenetration - m_minPenetration);
   penetrationStrength = MathMax(0.0, MathMin(1.0, penetrationStrength));
   
   // قوة الشمعة الثانية
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   double bodyStrength = (secondRange > 0) ? secondBodySize / secondRange : 0.0;
   
   // حجم الفجوة (إذا وجدت)
   double gapStrength = 0.0;
   if(open[idx] < close[idx+1])
   {
      double gapSize = close[idx+1] - open[idx];
      double avgRange = (high[idx+1] - low[idx+1] + high[idx] - low[idx]) / 2.0;
      gapStrength = (avgRange > 0) ? MathMin(1.0, gapSize / avgRange) : 0.0;
   }
   
   // القوة الإجمالية
   double totalStrength = 1.0 + penetrationStrength * 1.5 + bodyStrength * 0.5 + gapStrength * 0.3;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CPiercingLine::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                   const double &open[], const double &high[], const double &low[], 
                                   const double &close[], const long &volume[], 
                                   SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidPiercingLine(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "خط الاختراق";
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.70 + (result.strength - 1.0) * 0.1;
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
//| تنفيذ CDarkCloudCover                                           |
//+------------------------------------------------------------------+
CDarkCloudCover::CDarkCloudCover()
{
   m_minPenetration = 0.5;      // 50% حد أدنى للاختراق
   m_maxPenetration = 0.9;      // 90% حد أقصى للاختراق
   m_minBodyRatio = 0.6;        // 60% نسبة جسم دنيا
   m_requireGap = false;        // لا يتطلب فجوة افتراضياً
}

CDarkCloudCover::~CDarkCloudCover()
{
}

bool CDarkCloudCover::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

void CDarkCloudCover::SetPenetrationRange(double minPen, double maxPen)
{
   m_minPenetration = MathMax(0.3, MathMin(0.8, minPen));
   m_maxPenetration = MathMax(m_minPenetration + 0.1, MathMin(1.0, maxPen));
}

bool CDarkCloudCover::IsValidDarkCloudCover(const int idx, const double &open[], const double &high[], 
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
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minBodyRatio)
      return false;
   
   // الشمعة الثانية يجب أن تكون هبوطية
   bool secondBearish = CCandleUtils::IsBearish(open[idx], close[idx]);
   if(!secondBearish) return false;
   
   // فحص الفجوة إذا كان مطلوباً
   if(m_requireGap && open[idx] <= close[idx+1])
      return false;
   
   // حساب نسبة الاختراق
   double penetration = CalculatePenetration(idx, open, close);
   if(penetration < m_minPenetration || penetration > m_maxPenetration)
      return false;
   
   // يجب أن تفتح الشمعة الثانية أعلى من أعلى سعر للشمعة الأولى
   if(open[idx] < high[idx+1])
      return false;
   
   return true;
}

double CDarkCloudCover::CalculatePenetration(const int idx, const double &open[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   if(firstBodySize <= 0) return 0.0;
   
   double penetrationSize = close[idx+1] - close[idx];
   return penetrationSize / firstBodySize;
}

double CDarkCloudCover::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الاختراق
   double penetration = CalculatePenetration(idx, open, close);
   double penetrationStrength = (penetration - m_minPenetration) / (m_maxPenetration - m_minPenetration);
   penetrationStrength = MathMax(0.0, MathMin(1.0, penetrationStrength));
   
   // قوة الشمعة الثانية
   double secondBodySize = MathAbs(close[idx] - open[idx]);
   double secondRange = high[idx] - low[idx];
   double bodyStrength = (secondRange > 0) ? secondBodySize / secondRange : 0.0;
   
   // حجم الفجوة (إذا وجدت)
   double gapStrength = 0.0;
   if(open[idx] > close[idx+1])
   {
      double gapSize = open[idx] - close[idx+1];
      double avgRange = (high[idx+1] - low[idx+1] + high[idx] - low[idx]) / 2.0;
      gapStrength = (avgRange > 0) ? MathMin(1.0, gapSize / avgRange) : 0.0;
   }
   
   // القوة الإجمالية
   double totalStrength = 1.0 + penetrationStrength * 1.5 + bodyStrength * 0.5 + gapStrength * 0.3;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CDarkCloudCover::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidDarkCloudCover(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "الغطاء السحابي المظلم";
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.70 + (result.strength - 1.0) * 0.1;
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
//| تنفيذ CInNeck والفئات الأخرى (باقي التطبيق...)                  |
//+------------------------------------------------------------------+
CInNeck::CInNeck()
{
   m_penetrationTolerance = 0.02;  // 2% تسامح
   m_minBodyRatio = 0.5;           // 50% نسبة جسم دنيا
}

CInNeck::~CInNeck() {}

bool CInNeck::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

// ... باقي تطبيق الفئات (تم اختصاره لتوفير المساحة)

//+------------------------------------------------------------------+
//| تنفيذ CPiercingPatterns الرئيسي                                |
//+------------------------------------------------------------------+
CPiercingPatterns::CPiercingPatterns()
{
   m_piercingLine = NULL;
   m_darkCloudCover = NULL;
   m_inNeck = NULL;
   m_onNeck = NULL;
   m_thrusting = NULL;
   
   m_enablePiercingLine = true;
   m_enableDarkCloudCover = true;
   m_enableInNeck = true;
   m_enableOnNeck = true;
   m_enableThrusting = true;
}

CPiercingPatterns::~CPiercingPatterns()
{
   Deinitialize();
}

bool CPiercingPatterns::IsValidPointer(void* ptr)
{
   return (CheckPointer(ptr) != POINTER_INVALID);
}

bool CPiercingPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
   
   // إنشاء كائنات الأنماط
   m_piercingLine = new CPiercingLine();
   m_darkCloudCover = new CDarkCloudCover();
   m_inNeck = new CInNeck();
   m_onNeck = new COnNeck();
   m_thrusting = new CThrusting();
   
   // تهيئة جميع الأنماط
   bool success = true;
   if(IsValidPointer(m_piercingLine)) 
      success = success && m_piercingLine.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_darkCloudCover)) 
      success = success && m_darkCloudCover.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_inNeck)) 
      success = success && m_inNeck.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_onNeck)) 
      success = success && m_onNeck.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_thrusting)) 
      success = success && m_thrusting.Initialize(symbol, timeframe);
   else
      success = false;
   
   return success;
}

void CPiercingPatterns::Deinitialize()
{
   if(IsValidPointer(m_piercingLine)) 
   { 
      delete m_piercingLine; 
      m_piercingLine = NULL; 
   }
   
   if(IsValidPointer(m_darkCloudCover)) 
   { 
      delete m_darkCloudCover; 
      m_darkCloudCover = NULL; 
   }
   
   if(IsValidPointer(m_inNeck)) 
   { 
      delete m_inNeck; 
      m_inNeck = NULL; 
   }
   
   if(IsValidPointer(m_onNeck)) 
   { 
      delete m_onNeck; 
      m_onNeck = NULL; 
   }
   
   if(IsValidPointer(m_thrusting)) 
   { 
      delete m_thrusting; 
      m_thrusting = NULL; 
   }
   
   CPatternDetector::Deinitialize();
}

void CPiercingPatterns::EnableAllPiercingPatterns(bool enable)
{
   m_enablePiercingLine = enable;
   m_enableDarkCloudCover = enable;
   m_enableInNeck = enable;
   m_enableOnNeck = enable;
   m_enableThrusting = enable;
}

int CPiercingPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                       const double &open[], const double &high[], const double &low[], 
                                       const double &close[], const long &volume[], 
                                       SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // كشف خط الاختراق
   if(m_enablePiercingLine && IsValidPointer(m_piercingLine))
   {
      int patternCount = m_piercingLine.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
   
   // كشف الغطاء السحابي المظلم
   if(m_enableDarkCloudCover && IsValidPointer(m_darkCloudCover))
   {
      int patternCount = m_darkCloudCover.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
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
   
   // ... باقي أنماط الكشف
   
   return totalPatterns;
}
