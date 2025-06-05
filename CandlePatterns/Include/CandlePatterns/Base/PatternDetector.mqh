//+------------------------------------------------------------------+
//|                                              PatternDetector.mqh |
//|                                  محرك الكشف عن أنماط الشموع اليابانية |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "CandlePattern.mqh"
#include "CandleUtils.mqh"

//+------------------------------------------------------------------+
//| هيكل نتيجة الكشف عن النمط                                          |
//+------------------------------------------------------------------+
struct SPatternDetectionResult
{
   string            patternName;         // اسم النمط
   double            strength;            // قوة النمط (0.0-3.0)
   double            reliability;         // الموثوقية (0.0-1.0)
   ENUM_PATTERN_DIRECTION direction;      // اتجاه النمط
   ENUM_PATTERN_TYPE     type;            // نوع النمط
   double            confidence;          // مستوى الثقة (0.0-1.0)
   int               barIndex;            // رقم الشمعة
   datetime          time;                // وقت الشمعة
   
   // المنشئ الافتراضي
   SPatternDetectionResult()
   {
      patternName = "";
      strength = 0.0;
      reliability = 0.0;
      direction = PATTERN_NEUTRAL;
      type = PATTERN_SINGLE;
      confidence = 0.0;
      barIndex = -1;
      time = 0;
   }
};

//+------------------------------------------------------------------+
//| فئة محرك الكشف عن الأنماط                                        |
//+------------------------------------------------------------------+
class CPatternDetector
{
private:
   bool              m_initialized;       // حالة التهيئة
   string            m_symbol;            // الرمز الحالي
   ENUM_TIMEFRAMES   m_timeframe;         // الإطار الزمني الحالي
   double            m_sensitivity;       // مستوى الحساسية
   
public:
   // المنشئ والهادم
                     CPatternDetector();
                     ~CPatternDetector();
   
   // تهيئة المحرك
   bool              Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   void              Deinitialize();
   
   // إعدادات المحرك
   void              SetSensitivity(double sensitivity) { m_sensitivity = sensitivity; }
   double            GetSensitivity() const { return m_sensitivity; }
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // دوال مساعدة
   bool              IsValidIndex(const int idx, const int arraySize);
   bool              ValidateData(const double &open[], const double &high[], const double &low[], 
                                const double &close[], const long &volume[], const int idx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CPatternDetector::CPatternDetector()
{
   m_initialized = false;
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_sensitivity = 1.0;
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CPatternDetector::~CPatternDetector()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة المحرك                                                     |
//+------------------------------------------------------------------+
bool CPatternDetector::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   m_symbol = (symbol == "") ? Symbol() : symbol;
   m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
   m_initialized = true;
   
   // تهيئة مرافق الشموع
   CCandleUtils::Initialize();
   
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء المحرك                                                    |
//+------------------------------------------------------------------+
void CPatternDetector::Deinitialize()
{
   if(m_initialized)
   {
      CCandleUtils::Deinitialize();
      m_initialized = false;
   }
}

//+------------------------------------------------------------------+
//| التحقق من صحة الفهرس                                            |
//+------------------------------------------------------------------+
bool CPatternDetector::IsValidIndex(const int idx, const int arraySize)
{
   return (idx >= 0 && idx < arraySize);
}

//+------------------------------------------------------------------+
//| التحقق من صحة البيانات                                          |
//+------------------------------------------------------------------+
bool CPatternDetector::ValidateData(const double &open[], const double &high[], const double &low[], 
                                   const double &close[], const long &volume[], const int idx)
{
   // التحقق من الفهارس
   if(!IsValidIndex(idx, ArraySize(open)) || 
      !IsValidIndex(idx, ArraySize(high)) ||
      !IsValidIndex(idx, ArraySize(low)) ||
      !IsValidIndex(idx, ArraySize(close)))
      return false;
      
   // التحقق من صحة أسعار الشمعة
   if(high[idx] < MathMax(open[idx], close[idx]) ||
      low[idx] > MathMin(open[idx], close[idx]))
      return false;
      
   return true;
}

//+------------------------------------------------------------------+
//| الكشف عن جميع الأنماط (تنفيذ أساسي)                            |
//+------------------------------------------------------------------+
int CPatternDetector::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                       const double &open[], const double &high[], const double &low[], 
                                       const double &close[], const long &volume[], 
                                       SPatternDetectionResult &results[])
{
   // تنفيذ أساسي - سيتم إعادة تعريفه في الفئات المشتقة
   ArrayResize(results, 0);
   return 0;
}
