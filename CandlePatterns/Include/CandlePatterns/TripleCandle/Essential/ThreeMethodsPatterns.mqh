//+------------------------------------------------------------------+
//|                                       ThreeMethodsPatterns.mqh |
//|                                        أنماط الطرق الثلاث       |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الطرق الثلاث                                          |
//+------------------------------------------------------------------+
class CThreeMethodsPatterns : public CPatternDetector
{
private:
   double            m_retraceThreshold;      // حد التراجع
   double            m_gapSizeThreshold;      // حد حجم الفجوة
   
public:
   // المنشئ والهادم
                     CThreeMethodsPatterns();
                     ~CThreeMethodsPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط الطرق الثلاث المحددة
   bool              DetectRisingThreeMethods(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[], 
                                            SPatternDetectionResult &result);
                                            
   bool              DetectFallingThreeMethods(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result);
                                             
   bool              DetectUpGapThreeMethods(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], 
                                           SPatternDetectionResult &result);
                                           
   bool              DetectDownGapThreeMethods(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsValidRetracement(const double high1, const double low1, const double high2, 
                                      const double low2, const double high3, const double low3, bool isRising);
   bool              HasSignificantGap(const double price1, const double price2);
   bool              IsStrongTrendCandle(const double open, const double high, const double low, const double close);
   double            CalculateRetracementLevel(const double start, const double end, const double retrace);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CThreeMethodsPatterns::CThreeMethodsPatterns()
{
   m_retraceThreshold = 0.5;     // 50% حد التراجع
   m_gapSizeThreshold = 0.002;   // 0.2% حد الفجوة
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CThreeMethodsPatterns::~CThreeMethodsPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CThreeMethodsPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط الطرق الثلاث                               |
//+------------------------------------------------------------------+
int CThreeMethodsPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                            const double &open[], const double &high[], const double &low[], 
                                            const double &close[], const long &volume[], 
                                            SPatternDetectionResult &results[])
{
   if(idx < 2 || !ValidateData(open, high, low, close, volume, idx))
      return 0;
      
   SPatternDetectionResult tempResults[];
   ArrayResize(tempResults, 4); // أربعة أنماط محتملة
   int found = 0;
   
   SPatternDetectionResult result;
   
   // كشف الطرق الثلاث الصاعدة
   if(DetectRisingThreeMethods(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف الطرق الثلاث الهابطة
   if(DetectFallingThreeMethods(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف فجوة صاعدة بثلاث طرق
   if(DetectUpGapThreeMethods(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف فجوة هابطة بثلاث طرق
   if(DetectDownGapThreeMethods(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // نسخ النتائج
   if(found > 0)
   {
      ArrayResize(results, found);
      for(int i = 0; i < found; i++)
         results[i] = tempResults[i];
   }
   
   return found;
}

//+------------------------------------------------------------------+
//| كشف الطرق الثلاث الصاعدة (Rising Three Methods)                 |
//+------------------------------------------------------------------+
bool CThreeMethodsPatterns::DetectRisingThreeMethods(const int idx, const double &open[], const double &high[], 
                                                    const double &low[], const double &close[], 
                                                    SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: صعودية قوية
   bool firstBullish = close[idx-2] > open[idx-2];
   bool firstStrong = IsStrongTrendCandle(open[idx-2], high[idx-2], low[idx-2], close[idx-2]);
   
   if(!firstBullish || !firstStrong) return false;
   
   // الشمعة الثانية: هبوطية صغيرة (تراجع)
   bool secondBearish = close[idx-1] < open[idx-1];
   if(!secondBearish) return false;
   
   // التحقق من أن التراجع ضمن جسم الشمعة الأولى
   bool retracementValid = high[idx-1] <= high[idx-2] && low[idx-1] >= low[idx-2];
   if(!retracementValid) return false;
   
   // الشمعة الثالثة: صعودية قوية تتجاوز الأولى
   bool thirdBullish = close[idx] > open[idx];
   bool thirdStrong = IsStrongTrendCandle(open[idx], high[idx], low[idx], close[idx]);
   bool exceedsFirst = close[idx] > close[idx-2];
   
   if(!thirdBullish || !thirdStrong || !exceedsFirst) return false;
   
   // التحقق من مستوى التراجع
   double retracementLevel = CalculateRetracementLevel(close[idx-2], open[idx-2], close[idx-1]);
   if(retracementLevel > 0.8) return false; // تراجع لا يتجاوز 80%
   
   // حساب قوة النمط
   double firstBody = MathAbs(close[idx-2] - open[idx-2]);
   double thirdBody = MathAbs(close[idx] - open[idx]);
   double strength = (firstBody + thirdBody) / 2.0;
   
   result.patternName = "Rising Three Methods";
   result.strength = MathMin(strength * 100, 3.0);
   result.reliability = 0.75;
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف الطرق الثلاث الهابطة (Falling Three Methods)                |
//+------------------------------------------------------------------+
bool CThreeMethodsPatterns::DetectFallingThreeMethods(const int idx, const double &open[], const double &high[], 
                                                     const double &low[], const double &close[], 
                                                     SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: هبوطية قوية
   bool firstBearish = close[idx-2] < open[idx-2];
   bool firstStrong = IsStrongTrendCandle(open[idx-2], high[idx-2], low[idx-2], close[idx-2]);
   
   if(!firstBearish || !firstStrong) return false;
   
   // الشمعة الثانية: صعودية صغيرة (تراجع)
   bool secondBullish = close[idx-1] > open[idx-1];
   if(!secondBullish) return false;
   
   // التحقق من أن التراجع ضمن جسم الشمعة الأولى
   bool retracementValid = high[idx-1] <= high[idx-2] && low[idx-1] >= low[idx-2];
   if(!retracementValid) return false;
   
   // الشمعة الثالثة: هبوطية قوية تتجاوز الأولى
   bool thirdBearish = close[idx] < open[idx];
   bool thirdStrong = IsStrongTrendCandle(open[idx], high[idx], low[idx], close[idx]);
   bool exceedsFirst = close[idx] < close[idx-2];
   
   if(!thirdBearish || !thirdStrong || !exceedsFirst) return false;
   
   // التحقق من مستوى التراجع
   double retracementLevel = CalculateRetracementLevel(close[idx-2], open[idx-2], close[idx-1]);
   if(retracementLevel > 0.8) return false; // تراجع لا يتجاوز 80%
   
   // حساب قوة النمط
   double firstBody = MathAbs(close[idx-2] - open[idx-2]);
   double thirdBody = MathAbs(close[idx] - open[idx]);
   double strength = (firstBody + thirdBody) / 2.0;
   
   result.patternName = "Falling Three Methods";
   result.strength = MathMin(strength * 100, 3.0);
   result.reliability = 0.75;
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف فجوة صاعدة بثلاث طرق (Up Gap Three Methods)                 |
//+------------------------------------------------------------------+
bool CThreeMethodsPatterns::DetectUpGapThreeMethods(const int idx, const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], 
                                                   SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: صعودية
   bool firstBullish = close[idx-2] > open[idx-2];
   if(!firstBullish) return false;
   
   // الشمعة الثانية: فجوة صعودية
   bool hasUpGap = low[idx-1] > high[idx-2];
   if(!hasUpGap) return false;
   
   // الشمعة الثالثة: تغلق الفجوة جزئياً أو كلياً
   bool fillsGap = low[idx] <= high[idx-2];
   if(!fillsGap) return false;
   
   // التحقق من أن الإغلاق الأخير لا يكسر أدنى الشمعة الأولى بقوة
   bool maintainsSupport = close[idx] > low[idx-2];
   if(!maintainsSupport) return false;
   
   // تحديد قوة ملء الفجوة
   double gapSize = low[idx-1] - high[idx-2];
   double fillAmount = low[idx-1] - MathMax(low[idx], high[idx-2]);
   double fillRatio = (gapSize > 0) ? fillAmount / gapSize : 0;
   
   // تحديد الاتجاه بناء على مدى ملء الفجوة
   ENUM_PATTERN_DIRECTION direction = PATTERN_NEUTRAL;
   double reliability = 0.6;
   
   if(fillRatio < 0.5)
   {
      direction = PATTERN_BULLISH; // الفجوة لم تُملأ كثيراً - إشارة استمرار صعودي
      reliability = 0.75;
   }
   else if(fillRatio > 0.8)
   {
      direction = PATTERN_BEARISH; // الفجوة مُلئت بالكامل - إشارة انعكاس
      reliability = 0.70;
   }
   
   result.patternName = "Up Gap Three Methods";
   result.strength = gapSize * 1000; // تحويل لنقاط
   result.reliability = reliability;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف فجوة هابطة بثلاث طرق (Down Gap Three Methods)               |
//+------------------------------------------------------------------+
bool CThreeMethodsPatterns::DetectDownGapThreeMethods(const int idx, const double &open[], const double &high[], 
                                                     const double &low[], const double &close[], 
                                                     SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: هبوطية
   bool firstBearish = close[idx-2] < open[idx-2];
   if(!firstBearish) return false;
   
   // الشمعة الثانية: فجوة هبوطية
   bool hasDownGap = high[idx-1] < low[idx-2];
   if(!hasDownGap) return false;
   
   // الشمعة الثالثة: تغلق الفجوة جزئياً أو كلياً
   bool fillsGap = high[idx] >= low[idx-2];
   if(!fillsGap) return false;
   
   // التحقق من أن الإغلاق الأخير لا يكسر أعلى الشمعة الأولى بقوة
   bool maintainsResistance = close[idx] < high[idx-2];
   if(!maintainsResistance) return false;
   
   // تحديد قوة ملء الفجوة
   double gapSize = low[idx-2] - high[idx-1];
   double fillAmount = MathMin(high[idx], low[idx-2]) - high[idx-1];
   double fillRatio = (gapSize > 0) ? fillAmount / gapSize : 0;
   
   // تحديد الاتجاه بناء على مدى ملء الفجوة
   ENUM_PATTERN_DIRECTION direction = PATTERN_NEUTRAL;
   double reliability = 0.6;
   
   if(fillRatio < 0.5)
   {
      direction = PATTERN_BEARISH; // الفجوة لم تُملأ كثيراً - إشارة استمرار هبوطي
      reliability = 0.75;
   }
   else if(fillRatio > 0.8)
   {
      direction = PATTERN_BULLISH; // الفجوة مُلئت بالكامل - إشارة انعكاس
      reliability = 0.70;
   }
   
   result.patternName = "Down Gap Three Methods";
   result.strength = gapSize * 1000; // تحويل لنقاط
   result.reliability = reliability;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من صحة التراجع                                           |
//+------------------------------------------------------------------+
bool CThreeMethodsPatterns::IsValidRetracement(const double high1, const double low1, const double high2, 
                                              const double low2, const double high3, const double low3, bool isRising)
{
   if(isRising)
   {
      // للاتجاه الصعودي: التراجع يجب أن يكون محدود
      return (low2 >= low1 && high2 <= high3);
   }
   else
   {
      // للاتجاه الهبوطي: التراجع يجب أن يكون محدود
      return (high2 <= high1 && low2 >= low3);
   }
}

//+------------------------------------------------------------------+
//| التحقق من وجود فجوة مهمة                                        |
//+------------------------------------------------------------------+
bool CThreeMethodsPatterns::HasSignificantGap(const double price1, const double price2)
{
   double gap = MathAbs(price2 - price1);
   double avgPrice = (price1 + price2) / 2.0;
   
   if(avgPrice == 0) return false;
   
   return (gap / avgPrice) >= m_gapSizeThreshold;
}

//+------------------------------------------------------------------+
//| التحقق من قوة شمعة الاتجاه                                       |
//+------------------------------------------------------------------+
bool CThreeMethodsPatterns::IsStrongTrendCandle(const double open, const double high, const double low, const double close)
{
   double range = high - low;
   if(range == 0) return false;
   
   double body = MathAbs(close - open);
   double bodyRatio = body / range;
   
   // الشمعة قوية إذا كان الجسم أكثر من 60% من المدى
   return bodyRatio >= 0.6;
}

//+------------------------------------------------------------------+
//| حساب مستوى التراجع                                              |
//+------------------------------------------------------------------+
double CThreeMethodsPatterns::CalculateRetracementLevel(const double start, const double end, const double retrace)
{
   double totalMove = MathAbs(end - start);
   if(totalMove == 0) return 0;
   
   double retraceMove = MathAbs(retrace - end);
   return retraceMove / totalMove;
}
