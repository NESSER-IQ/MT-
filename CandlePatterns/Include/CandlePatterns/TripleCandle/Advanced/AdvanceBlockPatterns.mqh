//+------------------------------------------------------------------+
//|                                        AdvanceBlockPatterns.mqh|
//|                                           أنماط كتلة التقدم     |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط كتلة التقدم                                           |
//+------------------------------------------------------------------+
class CAdvanceBlockPatterns : public CPatternDetector
{
private:
   double            m_diminishingThreshold;   // حد التناقص
   double            m_shadowIncreaseRatio;    // نسبة زيادة الظل
   double            m_bodyDecreaseRatio;      // نسبة تناقص الجسم
   
public:
   // المنشئ والهادم
                     CAdvanceBlockPatterns();
                     ~CAdvanceBlockPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط كتلة التقدم المحددة
   bool              DetectAdvanceBlock(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[], 
                                      SPatternDetectionResult &result);
                                      
   bool              DetectBearishAdvanceBlock(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result);
                                             
   bool              DetectDeliberationAdvanceBlock(const int idx, const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], 
                                                   SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsDiminishingBodies(const double &open[], const double &close[], int startIdx);
   bool              IsIncreasingShadows(const double &high[], const double &low[], const double &open[], 
                                       const double &close[], int startIdx);
   bool              IsProgressiveTrend(const double &close[], int startIdx, bool bullish);
   double            CalculateBodyRatio(const double open, const double close, const double high, const double low);
   double            CalculateUpperShadowRatio(const double open, const double close, const double high);
   double            CalculateAdvanceBlockStrength(const double &open[], const double &high[], 
                                                  const double &low[], const double &close[], int startIdx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CAdvanceBlockPatterns::CAdvanceBlockPatterns()
{
   m_diminishingThreshold = 0.8;    // 80% حد التناقص
   m_shadowIncreaseRatio = 1.2;     // 20% زيادة في الظل
   m_bodyDecreaseRatio = 0.9;       // 10% تناقص في الجسم
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CAdvanceBlockPatterns::~CAdvanceBlockPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CAdvanceBlockPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط كتلة التقدم                                 |
//+------------------------------------------------------------------+
int CAdvanceBlockPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                            const double &open[], const double &high[], const double &low[], 
                                            const double &close[], const long &volume[], 
                                            SPatternDetectionResult &results[])
{
   if(idx < 2 || !ValidateData(open, high, low, close, volume, idx))
      return 0;
      
   SPatternDetectionResult tempResults[];
   ArrayResize(tempResults, 3); // ثلاثة أنماط محتملة
   int found = 0;
   
   SPatternDetectionResult result;
   
   // كشف كتلة التقدم الكلاسيكية
   if(DetectAdvanceBlock(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف كتلة التقدم الهبوطية
   if(DetectBearishAdvanceBlock(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف كتلة التقدم مع التردد
   if(DetectDeliberationAdvanceBlock(idx, open, high, low, close, result))
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
//| كشف كتلة التقدم الكلاسيكية (Classic Advance Block)              |
//+------------------------------------------------------------------+
bool CAdvanceBlockPatterns::DetectAdvanceBlock(const int idx, const double &open[], const double &high[], 
                                              const double &low[], const double &close[], 
                                              SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // جميع الشموع الثلاث يجب أن تكون صعودية
   bool allBullish = true;
   for(int i = 0; i < 3; i++)
   {
      if(close[idx-2+i] <= open[idx-2+i])
      {
         allBullish = false;
         break;
      }
   }
   
   if(!allBullish) return false;
   
   // التحقق من التقدم التدريجي
   if(!IsProgressiveTrend(close, idx-2, true)) return false;
   
   // التحقق من تناقص أجسام الشموع
   if(!IsDiminishingBodies(open, close, idx-2)) return false;
   
   // التحقق من زيادة الظلال العلوية
   if(!IsIncreasingShadows(high, low, open, close, idx-2)) return false;
   
   // حساب مؤشرات الضعف
   double lastBodyRatio = CalculateBodyRatio(open[idx], close[idx], high[idx], low[idx]);
   double lastShadowRatio = CalculateUpperShadowRatio(open[idx], close[idx], high[idx]);
   
   // كلما قل حجم الجسم وزاد الظل، زادت إشارة الضعف
   bool weaknessSignal = (lastBodyRatio < 0.5) && (lastShadowRatio > 0.3);
   
   if(!weaknessSignal) return false;
   
   // حساب قوة النمط
   double strength = CalculateAdvanceBlockStrength(open, high, low, close, idx-2);
   
   result.patternName = "Advance Block";
   result.strength = strength;
   result.reliability = 0.70;
   result.direction = PATTERN_BEARISH; // إشارة انعكاس هبوطي
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف كتلة التقدم الهبوطية (Bearish Advance Block)                |
//+------------------------------------------------------------------+
bool CAdvanceBlockPatterns::DetectBearishAdvanceBlock(const int idx, const double &open[], const double &high[], 
                                                     const double &low[], const double &close[], 
                                                     SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // جميع الشموع الثلاث يجب أن تكون هبوطية
   bool allBearish = true;
   for(int i = 0; i < 3; i++)
   {
      if(close[idx-2+i] >= open[idx-2+i])
      {
         allBearish = false;
         break;
      }
   }
   
   if(!allBearish) return false;
   
   // التحقق من التقدم التدريجي الهبوطي
   if(!IsProgressiveTrend(close, idx-2, false)) return false;
   
   // التحقق من تناقص أجسام الشموع (إشارة ضعف الهبوط)
   if(!IsDiminishingBodies(open, close, idx-2)) return false;
   
   // التحقق من زيادة الظلال السفلية
   bool increasingLowerShadows = true;
   double prevLowerShadow = 0;
   
   for(int i = 0; i < 3; i++)
   {
      double lowerShadow = MathMin(open[idx-2+i], close[idx-2+i]) - low[idx-2+i];
      if(i > 0 && lowerShadow < prevLowerShadow * m_shadowIncreaseRatio)
      {
         increasingLowerShadows = false;
         break;
      }
      prevLowerShadow = lowerShadow;
   }
   
   if(!increasingLowerShadows) return false;
   
   // حساب مؤشرات الضعف في الهبوط
   double lastBodyRatio = CalculateBodyRatio(open[idx], close[idx], high[idx], low[idx]);
   double lowerShadowRatio = (MathMin(open[idx], close[idx]) - low[idx]) / (high[idx] - low[idx]);
   
   bool weaknessSignal = (lastBodyRatio < 0.5) && (lowerShadowRatio > 0.3);
   
   if(!weaknessSignal) return false;
   
   double strength = CalculateAdvanceBlockStrength(open, high, low, close, idx-2);
   
   result.patternName = "Bearish Advance Block";
   result.strength = strength;
   result.reliability = 0.65;
   result.direction = PATTERN_BULLISH; // إشارة انعكاس صعودي
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف كتلة التقدم مع التردد (Deliberation Advance Block)           |
//+------------------------------------------------------------------+
bool CAdvanceBlockPatterns::DetectDeliberationAdvanceBlock(const int idx, const double &open[], const double &high[], 
                                                          const double &low[], const double &close[], 
                                                          SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // أول شمعتين يجب أن تكونا صعوديتين قويتين
   bool firstTwoStrong = (close[idx-2] > open[idx-2]) && (close[idx-1] > open[idx-1]);
   if(!firstTwoStrong) return false;
   
   // التحقق من قوة الشمعتين الأوليين
   double firstBodyRatio = CalculateBodyRatio(open[idx-2], close[idx-2], high[idx-2], low[idx-2]);
   double secondBodyRatio = CalculateBodyRatio(open[idx-1], close[idx-1], high[idx-1], low[idx-1]);
   
   if(firstBodyRatio < 0.6 || secondBodyRatio < 0.6) return false;
   
   // الشمعة الثالثة: تردد واضح
   bool thirdIsIndecisive = false;
   
   // التردد يمكن أن يكون:
   // 1. دوجي أو شمعة جسم صغير
   double thirdBodyRatio = CalculateBodyRatio(open[idx], close[idx], high[idx], low[idx]);
   bool smallBody = thirdBodyRatio < 0.3;
   
   // 2. شمعة بظلال طويلة (تردد)
   double thirdUpperShadow = CalculateUpperShadowRatio(open[idx], close[idx], high[idx]);
   double thirdLowerShadow = (MathMin(open[idx], close[idx]) - low[idx]) / (high[idx] - low[idx]);
   bool longShadows = (thirdUpperShadow > 0.3) || (thirdLowerShadow > 0.3);
   
   // 3. شمعة تفتح أعلى لكن لا تحرز تقدم كبير
   bool opensHighCloseFlat = (open[idx] > close[idx-1]) && 
                            (MathAbs(close[idx] - open[idx]) < MathAbs(close[idx-1] - open[idx-1]) * 0.5);
   
   thirdIsIndecisive = smallBody || longShadows || opensHighCloseFlat;
   
   if(!thirdIsIndecisive) return false;
   
   // حساب قوة التردد
   double deliberationStrength = 1.0;
   if(smallBody) deliberationStrength += 0.5;
   if(longShadows) deliberationStrength += 0.5;
   if(opensHighCloseFlat) deliberationStrength += 0.3;
   
   result.patternName = "Deliberation Advance Block";
   result.strength = deliberationStrength;
   result.reliability = 0.75;
   result.direction = PATTERN_BEARISH; // تحذير من انعكاس محتمل
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من تناقص أجسام الشموع                                    |
//+------------------------------------------------------------------+
bool CAdvanceBlockPatterns::IsDiminishingBodies(const double &open[], const double &close[], int startIdx)
{
   double body1 = MathAbs(close[startIdx] - open[startIdx]);
   double body2 = MathAbs(close[startIdx+1] - open[startIdx+1]);
   double body3 = MathAbs(close[startIdx+2] - open[startIdx+2]);
   
   // كل جسم يجب أن يكون أصغر من أو مساوي للسابق
   return (body2 <= body1 * (1.0 / m_bodyDecreaseRatio)) && 
          (body3 <= body2 * (1.0 / m_bodyDecreaseRatio));
}

//+------------------------------------------------------------------+
//| التحقق من زيادة الظلال                                          |
//+------------------------------------------------------------------+
bool CAdvanceBlockPatterns::IsIncreasingShadows(const double &high[], const double &low[], const double &open[], 
                                               const double &close[], int startIdx)
{
   double shadow1 = high[startIdx] - MathMax(open[startIdx], close[startIdx]);
   double shadow2 = high[startIdx+1] - MathMax(open[startIdx+1], close[startIdx+1]);
   double shadow3 = high[startIdx+2] - MathMax(open[startIdx+2], close[startIdx+2]);
   
   // كل ظل يجب أن يكون أكبر من أو مساوي للسابق
   return (shadow2 >= shadow1 * m_shadowIncreaseRatio) && 
          (shadow3 >= shadow2 * m_shadowIncreaseRatio);
}

//+------------------------------------------------------------------+
//| التحقق من الاتجاه التدريجي                                      |
//+------------------------------------------------------------------+
bool CAdvanceBlockPatterns::IsProgressiveTrend(const double &close[], int startIdx, bool bullish)
{
   if(bullish)
   {
      // للاتجاه الصعودي: كل إغلاق أعلى من السابق
      return (close[startIdx+1] > close[startIdx]) && 
             (close[startIdx+2] > close[startIdx+1]);
   }
   else
   {
      // للاتجاه الهبوطي: كل إغلاق أقل من السابق
      return (close[startIdx+1] < close[startIdx]) && 
             (close[startIdx+2] < close[startIdx+1]);
   }
}

//+------------------------------------------------------------------+
//| حساب نسبة الجسم                                                 |
//+------------------------------------------------------------------+
double CAdvanceBlockPatterns::CalculateBodyRatio(const double open, const double close, const double high, const double low)
{
   double range = high - low;
   if(range == 0) return 0;
   
   double body = MathAbs(close - open);
   return body / range;
}

//+------------------------------------------------------------------+
//| حساب نسبة الظل العلوي                                           |
//+------------------------------------------------------------------+
double CAdvanceBlockPatterns::CalculateUpperShadowRatio(const double open, const double close, const double high)
{
   double range = high - MathMin(open, close);
   if(range == 0) return 0;
   
   double upperShadow = high - MathMax(open, close);
   return upperShadow / (high - MathMin(open, close));
}

//+------------------------------------------------------------------+
//| حساب قوة كتلة التقدم                                             |
//+------------------------------------------------------------------+
double CAdvanceBlockPatterns::CalculateAdvanceBlockStrength(const double &open[], const double &high[], 
                                                           const double &low[], const double &close[], int startIdx)
{
   double totalBodyDecrease = 0;
   double totalShadowIncrease = 0;
   
   for(int i = 1; i < 3; i++)
   {
      // حساب تناقص الجسم
      double prevBody = MathAbs(close[startIdx+i-1] - open[startIdx+i-1]);
      double currBody = MathAbs(close[startIdx+i] - open[startIdx+i]);
      
      if(prevBody > 0)
         totalBodyDecrease += (prevBody - currBody) / prevBody;
      
      // حساب زيادة الظل
      double prevShadow = high[startIdx+i-1] - MathMax(open[startIdx+i-1], close[startIdx+i-1]);
      double currShadow = high[startIdx+i] - MathMax(open[startIdx+i], close[startIdx+i]);
      
      if(prevShadow > 0)
         totalShadowIncrease += (currShadow - prevShadow) / prevShadow;
   }
   
   return (totalBodyDecrease + totalShadowIncrease) / 2.0;
}
