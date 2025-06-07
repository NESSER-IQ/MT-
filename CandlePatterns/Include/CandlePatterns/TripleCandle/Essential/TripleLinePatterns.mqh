//+------------------------------------------------------------------+
//|                                        TripleLinePatterns.mqh  |
//|                                      أنماط الخطوط الثلاثية      |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الخطوط الثلاثية                                       |
//+------------------------------------------------------------------+
class CTripleLinePatterns : public CPatternDetector
{
private:
   double            m_strikeThreshold;       // حد الضربة
   double            m_riverDepth;            // عمق النهر
   double            m_starDistance;          // مسافة النجمة
   
public:
   // المنشئ والهادم
                     CTripleLinePatterns();
                     ~CTripleLinePatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط الخطوط الثلاثية المحددة
   bool              DetectThreeLinesStrike(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result);
                                          
   bool              DetectThreeRiverBottom(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result);
                                          
   bool              DetectThreeRiverTop(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       SPatternDetectionResult &result);
                                       
   bool              DetectTriStar(const int idx, const double &open[], const double &high[], 
                                 const double &low[], const double &close[], 
                                 SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsStrikePattern(const double &open[], const double &close[], int startIdx);
   bool              IsRiverPattern(const double &high[], const double &low[], int startIdx, bool isBottom);
   bool              IsStarFormation(const double open, const double high, const double low, const double close);
   bool              AreThreeStars(const double &open[], const double &high[], const double &low[], 
                                 const double &close[], int startIdx);
   double            CalculateStrikeStrength(const double &open[], const double &close[], int startIdx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CTripleLinePatterns::CTripleLinePatterns()
{
   m_strikeThreshold = 1.5;      // حد قوة الضربة
   m_riverDepth = 0.3;           // عمق النهر (30%)
   m_starDistance = 0.1;         // مسافة النجمة (10%)
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CTripleLinePatterns::~CTripleLinePatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CTripleLinePatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط الخطوط الثلاثية                            |
//+------------------------------------------------------------------+
int CTripleLinePatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف ضربة الخطوط الثلاثة
   if(DetectThreeLinesStrike(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف قاع الأنهار الثلاثة
   if(DetectThreeRiverBottom(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف قمة الأنهار الثلاثة
   if(DetectThreeRiverTop(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف النجمة الثلاثية
   if(DetectTriStar(idx, open, high, low, close, result))
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
//| كشف ضربة الخطوط الثلاثة (Three Lines Strike)                   |
//+------------------------------------------------------------------+
bool CTripleLinePatterns::DetectThreeLinesStrike(const int idx, const double &open[], const double &high[], 
                                                const double &low[], const double &close[], 
                                                SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من نمط الضربة
   if(!IsStrikePattern(open, close, idx-2)) return false;
   
   // تحديد اتجاه الخطوط الثلاث الأولى
   bool firstThreeBullish = (close[idx-2] > open[idx-2]) && 
                           (close[idx-1] > open[idx-1]) && 
                           (close[idx-1] > close[idx-2]);
   
   bool firstThreeBearish = (close[idx-2] < open[idx-2]) && 
                           (close[idx-1] < open[idx-1]) && 
                           (close[idx-1] < close[idx-2]);
   
   if(!firstThreeBullish && !firstThreeBearish) return false;
   
   // الشمعة الرابعة (الحالية) يجب أن تكون عكس الاتجاه وقوية
   bool fourthIsCounter = false;
   ENUM_PATTERN_DIRECTION direction = PATTERN_NEUTRAL;
   
   if(firstThreeBullish)
   {
      // ثلاث شموع صعودية، الرابعة هبوطية قوية
      fourthIsCounter = (close[idx] < open[idx]) && 
                       (open[idx] > close[idx-1]) && 
                       (close[idx] < open[idx-2]);
      direction = PATTERN_BEARISH;
   }
   else if(firstThreeBearish)
   {
      // ثلاث شموع هبوطية، الرابعة صعودية قوية
      fourthIsCounter = (close[idx] > open[idx]) && 
                       (open[idx] < close[idx-1]) && 
                       (close[idx] > open[idx-2]);
      direction = PATTERN_BULLISH;
   }
   
   if(!fourthIsCounter) return false;
   
   // حساب قوة الضربة
   double strikeStrength = CalculateStrikeStrength(open, close, idx-2);
   
   result.patternName = "Three Lines Strike";
   result.strength = strikeStrength;
   result.reliability = 0.70;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف قاع الأنهار الثلاثة (Three River Bottom)                    |
//+------------------------------------------------------------------+
bool CTripleLinePatterns::DetectThreeRiverBottom(const int idx, const double &open[], const double &high[], 
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
   
   // الشمعة الثانية: دوجي أو جسم صغير عند القاع
   double secondBody = MathAbs(close[idx-1] - open[idx-1]);
   double secondRange = high[idx-1] - low[idx-1];
   bool secondSmall = (secondRange > 0) && (secondBody / secondRange < 0.3);
   bool secondAtBottom = low[idx-1] <= low[idx-2] * 1.01; // قريب من قاع الأولى
   
   if(!secondSmall || !secondAtBottom) return false;
   
   // الشمعة الثالثة: صعودية تؤكد الانعكاس
   bool thirdBullish = close[idx] > open[idx];
   bool thirdConfirms = close[idx] > MathMax(open[idx-1], close[idx-1]);
   
   if(!thirdBullish || !thirdConfirms) return false;
   
   // التحقق من نمط النهر
   if(!IsRiverPattern(high, low, idx-2, true)) return false;
   
   result.patternName = "Three River Bottom";
   result.strength = firstBody / firstRange * 2.0;
   result.reliability = 0.75;
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف قمة الأنهار الثلاثة (Three River Top)                       |
//+------------------------------------------------------------------+
bool CTripleLinePatterns::DetectThreeRiverTop(const int idx, const double &open[], const double &high[], 
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
   
   // الشمعة الثانية: دوجي أو جسم صغير عند القمة
   double secondBody = MathAbs(close[idx-1] - open[idx-1]);
   double secondRange = high[idx-1] - low[idx-1];
   bool secondSmall = (secondRange > 0) && (secondBody / secondRange < 0.3);
   bool secondAtTop = high[idx-1] >= high[idx-2] * 0.99; // قريب من قمة الأولى
   
   if(!secondSmall || !secondAtTop) return false;
   
   // الشمعة الثالثة: هبوطية تؤكد الانعكاس
   bool thirdBearish = close[idx] < open[idx];
   bool thirdConfirms = close[idx] < MathMin(open[idx-1], close[idx-1]);
   
   if(!thirdBearish || !thirdConfirms) return false;
   
   // التحقق من نمط النهر
   if(!IsRiverPattern(high, low, idx-2, false)) return false;
   
   result.patternName = "Three River Top";
   result.strength = firstBody / firstRange * 2.0;
   result.reliability = 0.75;
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف النجمة الثلاثية (Tri Star)                                  |
//+------------------------------------------------------------------+
bool CTripleLinePatterns::DetectTriStar(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من أن الشموع الثلاث كلها نجوم (دوجي)
   if(!AreThreeStars(open, high, low, close, idx-2)) return false;
   
   // الشمعة الوسطى يجب أن تكون أعلى أو أقل من الجانبيتين
   bool middleHigh = (high[idx-1] > high[idx-2]) && (high[idx-1] > high[idx]);
   bool middleLow = (low[idx-1] < low[idx-2]) && (low[idx-1] < low[idx]);
   
   if(!middleHigh && !middleLow) return false;
   
   // تحديد الاتجاه
   ENUM_PATTERN_DIRECTION direction = PATTERN_NEUTRAL;
   double reliability = 0.60;
   
   if(middleHigh)
   {
      direction = PATTERN_BEARISH; // نجمة عالية تشير لانعكاس هبوطي
      reliability = 0.70;
   }
   else if(middleLow)
   {
      direction = PATTERN_BULLISH; // نجمة منخفضة تشير لانعكاس صعودي
      reliability = 0.70;
   }
   
   // حساب المسافة بين النجوم
   double avgRange = (high[idx-2] - low[idx-2] + high[idx-1] - low[idx-1] + high[idx] - low[idx]) / 3.0;
   double starSpread = MathMax(high[idx-1], MathMax(high[idx-2], high[idx])) - 
                      MathMin(low[idx-1], MathMin(low[idx-2], low[idx]));
   
   result.patternName = "Tri Star";
   result.strength = (avgRange > 0) ? starSpread / avgRange : 1.0;
   result.reliability = reliability;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من نمط الضربة                                            |
//+------------------------------------------------------------------+
bool CTripleLinePatterns::IsStrikePattern(const double &open[], const double &close[], int startIdx)
{
   // التحقق من أن الشموع الثلاث في نفس الاتجاه
   bool allBullish = true, allBearish = true;
   
   for(int i = 0; i < 3; i++)
   {
      if(close[startIdx + i] <= open[startIdx + i])
         allBullish = false;
      if(close[startIdx + i] >= open[startIdx + i])
         allBearish = false;
   }
   
   return allBullish || allBearish;
}

//+------------------------------------------------------------------+
//| التحقق من نمط النهر                                             |
//+------------------------------------------------------------------+
bool CTripleLinePatterns::IsRiverPattern(const double &high[], const double &low[], int startIdx, bool isBottom)
{
   if(isBottom)
   {
      // قاع النهر: الشمعة الوسطى تصل أو تقترب من أدنى نقطة
      double lowestPoint = MathMin(low[startIdx], MathMin(low[startIdx+1], low[startIdx+2]));
      return MathAbs(low[startIdx+1] - lowestPoint) <= (high[startIdx+1] - low[startIdx+1]) * m_riverDepth;
   }
   else
   {
      // قمة النهر: الشمعة الوسطى تصل أو تقترب من أعلى نقطة
      double highestPoint = MathMax(high[startIdx], MathMax(high[startIdx+1], high[startIdx+2]));
      return MathAbs(high[startIdx+1] - highestPoint) <= (high[startIdx+1] - low[startIdx+1]) * m_riverDepth;
   }
}

//+------------------------------------------------------------------+
//| التحقق من تشكيل النجمة                                          |
//+------------------------------------------------------------------+
bool CTripleLinePatterns::IsStarFormation(const double open, const double high, const double low, const double close)
{
   double body = MathAbs(close - open);
   double range = high - low;
   
   if(range == 0) return false;
   
   // النجمة: جسم صغير نسبياً (أقل من 10% من المدى)
   return body <= range * m_starDistance;
}

//+------------------------------------------------------------------+
//| التحقق من ثلاث نجوم                                             |
//+------------------------------------------------------------------+
bool CTripleLinePatterns::AreThreeStars(const double &open[], const double &high[], const double &low[], 
                                       const double &close[], int startIdx)
{
   for(int i = 0; i < 3; i++)
   {
      if(!IsStarFormation(open[startIdx + i], high[startIdx + i], 
                         low[startIdx + i], close[startIdx + i]))
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| حساب قوة الضربة                                                 |
//+------------------------------------------------------------------+
double CTripleLinePatterns::CalculateStrikeStrength(const double &open[], const double &close[], int startIdx)
{
   double totalMove = 0;
   
   for(int i = 0; i < 3; i++)
   {
      totalMove += MathAbs(close[startIdx + i] - open[startIdx + i]);
   }
   
   return totalMove / 3.0;
}
