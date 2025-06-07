//+------------------------------------------------------------------+
//|                                     InsideOutsidePatterns.mqh   |
//|                                     أنماط الداخل والخارج        |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الداخل والخارج                                        |
//+------------------------------------------------------------------+
class CInsideOutsidePatterns : public CPatternDetector
{
private:
   double            m_containmentThreshold;   // حد الاحتواء
   double            m_confirmationThreshold;  // حد التأكيد
   
public:
   // المنشئ والهادم
                     CInsideOutsidePatterns();
                     ~CInsideOutsidePatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط الداخل والخارج المحددة
   bool              DetectThreeInsideUp(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       SPatternDetectionResult &result);
                                       
   bool              DetectThreeInsideDown(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[], 
                                         SPatternDetectionResult &result);
                                         
   bool              DetectThreeOutsideUp(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[], 
                                        SPatternDetectionResult &result);
                                        
   bool              DetectThreeOutsideDown(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsInsideCandle(const double high1, const double low1, const double high2, const double low2);
   bool              IsOutsideCandle(const double high1, const double low1, const double high2, const double low2);
   bool              IsEngulfingPattern(const double open1, const double close1, const double open2, const double close2);
   bool              IsConfirmationCandle(const double open, const double close, ENUM_PATTERN_DIRECTION direction);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CInsideOutsidePatterns::CInsideOutsidePatterns()
{
   m_containmentThreshold = 0.95;  // 95% احتواء
   m_confirmationThreshold = 0.5;  // 50% حد التأكيد
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CInsideOutsidePatterns::~CInsideOutsidePatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CInsideOutsidePatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط الداخل والخارج                             |
//+------------------------------------------------------------------+
int CInsideOutsidePatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف ثلاثة للداخل صعوداً
   if(DetectThreeInsideUp(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف ثلاثة للداخل هبوطاً
   if(DetectThreeInsideDown(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف ثلاثة للخارج صعوداً
   if(DetectThreeOutsideUp(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف ثلاثة للخارج هبوطاً
   if(DetectThreeOutsideDown(idx, open, high, low, close, result))
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
//| كشف ثلاثة للداخل صعوداً (Three Inside Up)                       |
//+------------------------------------------------------------------+
bool CInsideOutsidePatterns::DetectThreeInsideUp(const int idx, const double &open[], const double &high[], 
                                                const double &low[], const double &close[], 
                                                SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: هبوطية قوية
   bool firstBearish = close[idx-2] < open[idx-2];
   if(!firstBearish) return false;
   
   // الشمعة الثانية: صعودية وداخل الأولى (Harami)
   bool secondBullish = close[idx-1] > open[idx-1];
   bool secondInside = IsInsideCandle(high[idx-2], low[idx-2], high[idx-1], low[idx-1]);
   
   if(!secondBullish || !secondInside) return false;
   
   // الشمعة الثالثة: تأكيد صعودي (تغلق أعلى من إغلاق الثانية)
   bool thirdConfirmation = IsConfirmationCandle(open[idx], close[idx], PATTERN_BULLISH);
   bool closesHigher = close[idx] > close[idx-1];
   
   if(!thirdConfirmation || !closesHigher) return false;
   
   // حساب قوة النمط
   double firstBodySize = MathAbs(close[idx-2] - open[idx-2]);
   double secondBodySize = MathAbs(close[idx-1] - open[idx-1]);
   double thirdBodySize = MathAbs(close[idx] - open[idx]);
   
   // التحقق من أن الشمعة الثالثة تكسر أعلى الشمعة الأولى (اختياري للقوة)
   bool breaksFirstHigh = close[idx] > high[idx-2];
   
   result.patternName = "Three Inside Up";
   result.strength = (firstBodySize + thirdBodySize) / 2.0;
   result.reliability = 0.75;
   
   if(breaksFirstHigh) 
      result.reliability += 0.1; // مكافأة لكسر القمة
   
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف ثلاثة للداخل هبوطاً (Three Inside Down)                     |
//+------------------------------------------------------------------+
bool CInsideOutsidePatterns::DetectThreeInsideDown(const int idx, const double &open[], const double &high[], 
                                                  const double &low[], const double &close[], 
                                                  SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: صعودية قوية
   bool firstBullish = close[idx-2] > open[idx-2];
   if(!firstBullish) return false;
   
   // الشمعة الثانية: هبوطية وداخل الأولى (Harami)
   bool secondBearish = close[idx-1] < open[idx-1];
   bool secondInside = IsInsideCandle(high[idx-2], low[idx-2], high[idx-1], low[idx-1]);
   
   if(!secondBearish || !secondInside) return false;
   
   // الشمعة الثالثة: تأكيد هبوطي (تغلق أقل من إغلاق الثانية)
   bool thirdConfirmation = IsConfirmationCandle(open[idx], close[idx], PATTERN_BEARISH);
   bool closesLower = close[idx] < close[idx-1];
   
   if(!thirdConfirmation || !closesLower) return false;
   
   // حساب قوة النمط
   double firstBodySize = MathAbs(close[idx-2] - open[idx-2]);
   double secondBodySize = MathAbs(close[idx-1] - open[idx-1]);
   double thirdBodySize = MathAbs(close[idx] - open[idx]);
   
   // التحقق من أن الشمعة الثالثة تكسر أدنى الشمعة الأولى (اختياري للقوة)
   bool breaksFirstLow = close[idx] < low[idx-2];
   
   result.patternName = "Three Inside Down";
   result.strength = (firstBodySize + thirdBodySize) / 2.0;
   result.reliability = 0.75;
   
   if(breaksFirstLow) 
      result.reliability += 0.1; // مكافأة لكسر القاع
   
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف ثلاثة للخارج صعوداً (Three Outside Up)                      |
//+------------------------------------------------------------------+
bool CInsideOutsidePatterns::DetectThreeOutsideUp(const int idx, const double &open[], const double &high[], 
                                                 const double &low[], const double &close[], 
                                                 SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: هبوطية
   bool firstBearish = close[idx-2] < open[idx-2];
   if(!firstBearish) return false;
   
   // الشمعة الثانية: صعودية وتحتوي الأولى (Engulfing)
   bool secondBullish = close[idx-1] > open[idx-1];
   bool secondEngulfs = IsEngulfingPattern(open[idx-2], close[idx-2], open[idx-1], close[idx-1]);
   
   if(!secondBullish || !secondEngulfs) return false;
   
   // الشمعة الثالثة: تأكيد صعودي (تغلق أعلى من إغلاق الثانية)
   bool thirdConfirmation = IsConfirmationCandle(open[idx], close[idx], PATTERN_BULLISH);
   bool closesHigher = close[idx] > close[idx-1];
   
   if(!thirdConfirmation || !closesHigher) return false;
   
   // حساب قوة النمط
   double firstBodySize = MathAbs(close[idx-2] - open[idx-2]);
   double secondBodySize = MathAbs(close[idx-1] - open[idx-1]);
   double thirdBodySize = MathAbs(close[idx] - open[idx]);
   
   // التحقق من قوة الاحتواء
   double engulfingRatio = secondBodySize / MathMax(firstBodySize, 0.0001);
   
   result.patternName = "Three Outside Up";
   result.strength = (secondBodySize + thirdBodySize) / 2.0;
   result.reliability = 0.80;
   
   if(engulfingRatio > 1.5) 
      result.reliability += 0.1; // مكافأة للاحتواء القوي
   
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف ثلاثة للخارج هبوطاً (Three Outside Down)                    |
//+------------------------------------------------------------------+
bool CInsideOutsidePatterns::DetectThreeOutsideDown(const int idx, const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], 
                                                   SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: صعودية
   bool firstBullish = close[idx-2] > open[idx-2];
   if(!firstBullish) return false;
   
   // الشمعة الثانية: هبوطية وتحتوي الأولى (Engulfing)
   bool secondBearish = close[idx-1] < open[idx-1];
   bool secondEngulfs = IsEngulfingPattern(open[idx-2], close[idx-2], open[idx-1], close[idx-1]);
   
   if(!secondBearish || !secondEngulfs) return false;
   
   // الشمعة الثالثة: تأكيد هبوطي (تغلق أقل من إغلاق الثانية)
   bool thirdConfirmation = IsConfirmationCandle(open[idx], close[idx], PATTERN_BEARISH);
   bool closesLower = close[idx] < close[idx-1];
   
   if(!thirdConfirmation || !closesLower) return false;
   
   // حساب قوة النمط
   double firstBodySize = MathAbs(close[idx-2] - open[idx-2]);
   double secondBodySize = MathAbs(close[idx-1] - open[idx-1]);
   double thirdBodySize = MathAbs(close[idx] - open[idx]);
   
   // التحقق من قوة الاحتواء
   double engulfingRatio = secondBodySize / MathMax(firstBodySize, 0.0001);
   
   result.patternName = "Three Outside Down";
   result.strength = (secondBodySize + thirdBodySize) / 2.0;
   result.reliability = 0.80;
   
   if(engulfingRatio > 1.5) 
      result.reliability += 0.1; // مكافأة للاحتواء القوي
   
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من الشمعة الداخلية                                       |
//+------------------------------------------------------------------+
bool CInsideOutsidePatterns::IsInsideCandle(const double high1, const double low1, const double high2, const double low2)
{
   // الشمعة الثانية يجب أن تكون بالكامل داخل الأولى
   return (high2 <= high1 && low2 >= low1);
}

//+------------------------------------------------------------------+
//| التحقق من الشمعة الخارجية                                       |
//+------------------------------------------------------------------+
bool CInsideOutsidePatterns::IsOutsideCandle(const double high1, const double low1, const double high2, const double low2)
{
   // الشمعة الثانية يجب أن تحتوي الأولى بالكامل
   return (high2 >= high1 && low2 <= low1);
}

//+------------------------------------------------------------------+
//| التحقق من نمط الاحتواء                                          |
//+------------------------------------------------------------------+
bool CInsideOutsidePatterns::IsEngulfingPattern(const double open1, const double close1, const double open2, const double close2)
{
   // تحديد أجسام الشموع
   double body1_top = MathMax(open1, close1);
   double body1_bottom = MathMin(open1, close1);
   double body2_top = MathMax(open2, close2);
   double body2_bottom = MathMin(open2, close2);
   
   // الشمعة الثانية يجب أن تحتوي جسم الأولى
   return (body2_top > body1_top && body2_bottom < body1_bottom);
}

//+------------------------------------------------------------------+
//| التحقق من شمعة التأكيد                                          |
//+------------------------------------------------------------------+
bool CInsideOutsidePatterns::IsConfirmationCandle(const double open, const double close, ENUM_PATTERN_DIRECTION direction)
{
   if(direction == PATTERN_BULLISH)
   {
      return close > open; // شمعة صعودية
   }
   else if(direction == PATTERN_BEARISH)
   {
      return close < open; // شمعة هبوطية
   }
   
   return false;
}
