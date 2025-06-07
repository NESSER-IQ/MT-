//+------------------------------------------------------------------+
//|                                         ConcealingPatterns.mqh |
//|                                            أنماط الإخفاء        |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الإخفاء                                               |
//+------------------------------------------------------------------+
class CConcealingPatterns : public CPatternDetector
{
private:
   double            m_concealmentThreshold;   // حد الإخفاء
   double            m_swallowRatio;          // نسبة الابتلاع
   double            m_cloudCoverDepth;       // عمق الغطاء السحابي
   
public:
   // المنشئ والهادم
                     CConcealingPatterns();
                     ~CConcealingPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط الإخفاء المحددة
   bool              DetectConcealingBabySwallow(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], 
                                               SPatternDetectionResult &result);
                                               
   bool              DetectConcealingCloudCover(const int idx, const double &open[], const double &high[], 
                                              const double &low[], const double &close[], 
                                              SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsConcealed(const double high1, const double low1, const double high2, const double low2);
   bool              IsBabySwallowPattern(const double &open[], const double &high[], const double &low[], 
                                        const double &close[], int startIdx);
   bool              IsCloudCoverPattern(const double &open[], const double &high[], const double &low[], 
                                       const double &close[], int startIdx);
   double            CalculateSwallowDepth(const double open1, const double close1, 
                                         const double open2, const double close2);
   double            CalculateConcealmentStrength(const double &high[], const double &low[], int startIdx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CConcealingPatterns::CConcealingPatterns()
{
   m_concealmentThreshold = 0.7;    // 70% حد الإخفاء
   m_swallowRatio = 0.5;           // 50% نسبة الابتلاع
   m_cloudCoverDepth = 0.5;        // 50% عمق الغطاء السحابي
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CConcealingPatterns::~CConcealingPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CConcealingPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط الإخفاء                                     |
//+------------------------------------------------------------------+
int CConcealingPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                          const double &open[], const double &high[], const double &low[], 
                                          const double &close[], const long &volume[], 
                                          SPatternDetectionResult &results[])
{
   if(idx < 2 || !ValidateData(open, high, low, close, volume, idx))
      return 0;
      
   SPatternDetectionResult tempResults[];
   ArrayResize(tempResults, 2); // نمطين محتملين
   int found = 0;
   
   SPatternDetectionResult result;
   
   // كشف ابتلاع الطفل المخفي
   if(DetectConcealingBabySwallow(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف الغطاء السحابي المخفي
   if(DetectConcealingCloudCover(idx, open, high, low, close, result))
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
//| كشف ابتلاع الطفل المخفي (Concealing Baby Swallow)               |
//+------------------------------------------------------------------+
bool CConcealingPatterns::DetectConcealingBabySwallow(const int idx, const double &open[], const double &high[], 
                                                     const double &low[], const double &close[], 
                                                     SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: هبوطية قوية
   bool firstBearish = close[idx-2] < open[idx-2];
   double firstBody = MathAbs(close[idx-2] - open[idx-2]);
   double firstRange = high[idx-2] - low[idx-2];
   bool firstStrong = (firstRange > 0) && (firstBody / firstRange > 0.6);
   
   if(!firstBearish || !firstStrong) return false;
   
   // الشمعة الثانية: "الطفل" - شمعة صغيرة أو دوجي
   double secondBody = MathAbs(close[idx-1] - open[idx-1]);
   double secondRange = high[idx-1] - low[idx-1];
   bool secondSmall = (secondRange > 0) && (secondBody / secondRange < 0.3);
   
   // يجب أن تكون أقل من الأولى (مخفية)
   bool secondConcealed = IsConcealed(high[idx-2], low[idx-2], high[idx-1], low[idx-1]);
   
   if(!secondSmall || !secondConcealed) return false;
   
   // الشمعة الثالثة: "الابتلاع" - صعودية قوية تحتوي الاثنتين السابقتين
   bool thirdBullish = close[idx] > open[idx];
   bool swallowsBoth = (open[idx] <= MathMin(low[idx-2], low[idx-1])) && 
                      (close[idx] >= MathMax(high[idx-2], high[idx-1]));
   
   if(!thirdBullish || !swallowsBoth) return false;
   
   // التحقق من نمط الابتلاع الكامل
   if(!IsBabySwallowPattern(open, high, low, close, idx-2)) return false;
   
   // حساب قوة الإخفاء
   double swallowDepth = CalculateSwallowDepth(open[idx-2], close[idx-2], open[idx], close[idx]);
   double concealmentStrength = CalculateConcealmentStrength(high, low, idx-2);
   
   result.patternName = "Concealing Baby Swallow";
   result.strength = (swallowDepth + concealmentStrength) / 2.0;
   result.reliability = 0.80;
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف الغطاء السحابي المخفي (Concealing Cloud Cover)              |
//+------------------------------------------------------------------+
bool CConcealingPatterns::DetectConcealingCloudCover(const int idx, const double &open[], const double &high[], 
                                                    const double &low[], const double &close[], 
                                                    SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: صعودية قوية
   bool firstBullish = close[idx-2] > open[idx-2];
   double firstBody = MathAbs(close[idx-2] - open[idx-2]);
   double firstRange = high[idx-2] - low[idx-2];
   bool firstStrong = (firstRange > 0) && (firstBody / firstRange > 0.6);
   
   if(!firstBullish || !firstStrong) return false;
   
   // الشمعة الثانية: شمعة انتقالية (قد تكون صعودية أو هبوطية صغيرة)
   double secondBody = MathAbs(close[idx-1] - open[idx-1]);
   double secondRange = high[idx-1] - low[idx-1];
   bool secondTransition = (secondRange > 0) && (secondBody / secondRange < 0.5);
   
   // يجب أن تكون في نطاق الأولى أو قريبة منها
   bool secondInRange = (low[idx-1] >= low[idx-2] * 0.98) && (high[idx-1] <= high[idx-2] * 1.02);
   
   if(!secondTransition || !secondInRange) return false;
   
   // الشمعة الثالثة: "الغطاء السحابي" - هبوطية تغطي جزء كبير من الصعود
   bool thirdBearish = close[idx] < open[idx];
   if(!thirdBearish) return false;
   
   // يجب أن تفتح أعلى من إغلاق الأولى وتغلق داخل جسم الأولى
   bool opensHigh = open[idx] > close[idx-2];
   bool closesInBody = close[idx] > open[idx-2] && close[idx] < close[idx-2];
   
   // عمق الاختراق يجب أن يكون كافياً
   double penetrationDepth = (close[idx-2] - close[idx]) / (close[idx-2] - open[idx-2]);
   bool sufficientDepth = penetrationDepth >= m_cloudCoverDepth;
   
   if(!opensHigh || !closesInBody || !sufficientDepth) return false;
   
   // التحقق من نمط الغطاء السحابي
   if(!IsCloudCoverPattern(open, high, low, close, idx-2)) return false;
   
   // حساب قوة الغطاء
   double coverageStrength = penetrationDepth * 2.0;
   double concealmentStrength = CalculateConcealmentStrength(high, low, idx-2);
   
   result.patternName = "Concealing Cloud Cover";
   result.strength = (coverageStrength + concealmentStrength) / 2.0;
   result.reliability = 0.75;
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من الإخفاء                                               |
//+------------------------------------------------------------------+
bool CConcealingPatterns::IsConcealed(const double high1, const double low1, const double high2, const double low2)
{
   // الشمعة الثانية يجب أن تكون مخفية ضمن الأولى
   double range1 = high1 - low1;
   if(range1 == 0) return false;
   
   // نسبة الإخفاء
   double concealedHigh = MathMax(0, MathMin(high2, high1) - MathMax(low2, low1));
   double concealmentRatio = concealedHigh / range1;
   
   return concealmentRatio >= m_concealmentThreshold;
}

//+------------------------------------------------------------------+
//| التحقق من نمط ابتلاع الطفل                                      |
//+------------------------------------------------------------------+
bool CConcealingPatterns::IsBabySwallowPattern(const double &open[], const double &high[], const double &low[], 
                                              const double &close[], int startIdx)
{
   // التحقق من التسلسل: هبوطية كبيرة، صغيرة مخفية، صعودية كبيرة
   bool sequence = (close[startIdx] < open[startIdx]) &&      // أولى هبوطية
                  (close[startIdx+2] > open[startIdx+2]);     // ثالثة صعودية
   
   if(!sequence) return false;
   
   // التحقق من الابتلاع الكامل
   double minLow = MathMin(low[startIdx], low[startIdx+1]);
   double maxHigh = MathMax(high[startIdx], high[startIdx+1]);
   
   bool completeSwallow = (low[startIdx+2] <= minLow) && (high[startIdx+2] >= maxHigh);
   
   return completeSwallow;
}

//+------------------------------------------------------------------+
//| التحقق من نمط الغطاء السحابي                                    |
//+------------------------------------------------------------------+
bool CConcealingPatterns::IsCloudCoverPattern(const double &open[], const double &high[], const double &low[], 
                                             const double &close[], int startIdx)
{
   // التحقق من التسلسل: صعودية، انتقالية، هبوطية مغطية
   bool sequence = (close[startIdx] > open[startIdx]) &&      // أولى صعودية
                  (close[startIdx+2] < open[startIdx+2]);     // ثالثة هبوطية
   
   if(!sequence) return false;
   
   // التحقق من الغطاء
   bool coversWell = (open[startIdx+2] > close[startIdx]) &&   // تفتح أعلى
                    (close[startIdx+2] < close[startIdx]);     // تغلق داخل الجسم
   
   return coversWell;
}

//+------------------------------------------------------------------+
//| حساب عمق الابتلاع                                               |
//+------------------------------------------------------------------+
double CConcealingPatterns::CalculateSwallowDepth(const double open1, const double close1, 
                                                 const double open2, const double close2)
{
   double body1 = MathAbs(close1 - open1);
   double body2 = MathAbs(close2 - open2);
   
   if(body1 == 0) return 0;
   
   // نسبة الابتلاع
   return MathMin(body2 / body1, 3.0); // حد أقصى 3
}

//+------------------------------------------------------------------+
//| حساب قوة الإخفاء                                                |
//+------------------------------------------------------------------+
double CConcealingPatterns::CalculateConcealmentStrength(const double &high[], const double &low[], int startIdx)
{
   double totalRange = 0;
   double concealedRange = 0;
   
   for(int i = 0; i < 3; i++)
   {
      double range = high[startIdx + i] - low[startIdx + i];
      totalRange += range;
      
      if(i == 1) // الشمعة الوسطى (المخفية)
      {
         // حساب مدى الإخفاء بالنسبة للشموع المحيطة
         double maxHigh = MathMax(high[startIdx], high[startIdx + 2]);
         double minLow = MathMin(low[startIdx], low[startIdx + 2]);
         
         if(high[startIdx + i] <= maxHigh && low[startIdx + i] >= minLow)
            concealedRange += range;
      }
   }
   
   if(totalRange == 0) return 0;
   
   return (concealedRange / totalRange) * 2.0; // تضخيم النتيجة
}
