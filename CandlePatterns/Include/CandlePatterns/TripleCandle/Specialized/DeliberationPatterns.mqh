//+------------------------------------------------------------------+
//|                                         DeliberationPatterns.mqh|
//|                                            أنماط التداول       |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط التداول                                               |
//+------------------------------------------------------------------+
class CDeliberationPatterns : public CPatternDetector
{
private:
   double            m_deliberationThreshold;  // حد التردد
   double            m_stallingRatio;          // نسبة التوقف
   double            m_indecisionLevel;        // مستوى التردد
   
public:
   // المنشئ والهادم
                     CDeliberationPatterns();
                     ~CDeliberationPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط التداول المحددة
   bool              DetectDeliberationBlock(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], 
                                           SPatternDetectionResult &result);
                                           
   bool              DetectStalling(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], 
                                  SPatternDetectionResult &result);
                                  
   bool              DetectDeliberationStar(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsDeliberativeCandle(const double open, const double high, const double low, const double close);
   bool              IsStalling(const double &open[], const double &high[], const double &low[], 
                              const double &close[], int startIdx);
   bool              ShowsIndecision(const double open, const double high, const double low, const double close);
   double            CalculateDeliberationStrength(const double &open[], const double &high[], 
                                                  const double &low[], const double &close[], int startIdx);
   double            CalculateProgressLoss(const double &close[], int startIdx);
   bool              HasDiminishingMomentum(const double &open[], const double &close[], int startIdx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CDeliberationPatterns::CDeliberationPatterns()
{
   m_deliberationThreshold = 0.3;   // 30% حد التردد
   m_stallingRatio = 0.5;           // 50% نسبة التوقف
   m_indecisionLevel = 0.2;         // 20% مستوى التردد
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CDeliberationPatterns::~CDeliberationPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CDeliberationPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط التداول                                     |
//+------------------------------------------------------------------+
int CDeliberationPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف كتلة التداول
   if(DetectDeliberationBlock(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف التوقف
   if(DetectStalling(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف نجمة التداول
   if(DetectDeliberationStar(idx, open, high, low, close, result))
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
//| كشف كتلة التداول (Deliberation Block)                          |
//+------------------------------------------------------------------+
bool CDeliberationPatterns::DetectDeliberationBlock(const int idx, const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], 
                                                   SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشموع الثلاث يجب أن تظهر نفس الاتجاه مع تباطؤ تدريجي
   
   // تحديد الاتجاه العام
   bool overallBullish = (close[idx] > close[idx-2]);
   bool overallBearish = (close[idx] < close[idx-2]);
   
   if(!overallBullish && !overallBearish) return false;
   
   // التحقق من تناقص الزخم
   if(!HasDiminishingMomentum(open, close, idx-2)) return false;
   
   // التحقق من أن كل شمعة تظهر تردد أكثر من السابقة
   bool progressiveDeliberation = true;
   double prevDeliberation = 0;
   
   for(int i = 0; i < 3; i++)
   {
      double bodySize = MathAbs(close[idx-2+i] - open[idx-2+i]);
      double range = high[idx-2+i] - low[idx-2+i];
      double deliberationLevel = (range > 0) ? 1.0 - (bodySize / range) : 0;
      
      if(i > 0 && deliberationLevel <= prevDeliberation)
      {
         progressiveDeliberation = false;
         break;
      }
      
      prevDeliberation = deliberationLevel;
   }
   
   if(!progressiveDeliberation) return false;
   
   // الشمعة الأخيرة يجب أن تظهر تردد واضح
   if(!IsDeliberativeCandle(open[idx], high[idx], low[idx], close[idx])) return false;
   
   // حساب فقدان التقدم
   double progressLoss = CalculateProgressLoss(close, idx-2);
   
   result.patternName = "Deliberation Block";
   result.strength = progressLoss * 2.0;
   result.reliability = 0.70;
   result.direction = overallBullish ? PATTERN_BEARISH : PATTERN_BULLISH; // انعكاس محتمل
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف التوقف (Stalling)                                           |
//+------------------------------------------------------------------+
bool CDeliberationPatterns::DetectStalling(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من نمط التوقف
   if(!IsStalling(open, high, low, close, idx-2)) return false;
   
   // أول شمعتين يجب أن تكونا في اتجاه قوي
   double firstMove = MathAbs(close[idx-2] - open[idx-2]);
   double secondMove = MathAbs(close[idx-1] - open[idx-1]);
   
   bool strongStart = true;
   double firstRange = high[idx-2] - low[idx-2];
   double secondRange = high[idx-1] - low[idx-1];
   
   if(firstRange > 0 && (firstMove / firstRange < 0.6)) strongStart = false;
   if(secondRange > 0 && (secondMove / secondRange < 0.6)) strongStart = false;
   
   if(!strongStart) return false;
   
   // الشمعة الثالثة: توقف واضح
   double thirdMove = MathAbs(close[idx] - open[idx]);
   double thirdRange = high[idx] - low[idx];
   
   bool isStalled = false;
   
   // التوقف يمكن أن يكون:
   // 1. شمعة صغيرة الجسم
   if(thirdRange > 0 && (thirdMove / thirdRange < m_stallingRatio))
      isStalled = true;
   
   // 2. دوجي أو شمعة متردد
   if(ShowsIndecision(open[idx], high[idx], low[idx], close[idx]))
      isStalled = true;
   
   // 3. عدم تقدم كبير رغم الفتح الجيد
   bool goodOpen = false;
   bool poorProgress = false;
   
   if(close[idx-1] > open[idx-1]) // اتجاه صعودي
   {
      goodOpen = open[idx] >= close[idx-1] * 0.999;
      poorProgress = close[idx] < open[idx] + (close[idx-1] - open[idx-1]) * 0.3;
   }
   else if(close[idx-1] < open[idx-1]) // اتجاه هبوطي
   {
      goodOpen = open[idx] <= close[idx-1] * 1.001;
      poorProgress = close[idx] > open[idx] - (open[idx-1] - close[idx-1]) * 0.3;
   }
   
   if(goodOpen && poorProgress)
      isStalled = true;
   
   if(!isStalled) return false;
   
   // تحديد الاتجاه الأصلي للتوقف
   bool originallyBullish = (close[idx-1] > close[idx-2]) && (close[idx-2] > open[idx-2]);
   
   result.patternName = "Stalling";
   result.strength = 1.5;
   result.reliability = 0.65;
   result.direction = originallyBullish ? PATTERN_BEARISH : PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف نجمة التداول (Deliberation Star)                            |
//+------------------------------------------------------------------+
bool CDeliberationPatterns::DetectDeliberationStar(const int idx, const double &open[], const double &high[], 
                                                  const double &low[], const double &close[], 
                                                  SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // أول شمعتين في اتجاه قوي
   bool firstTwoTrending = false;
   bool uptrend = false;
   
   if((close[idx-2] > open[idx-2]) && (close[idx-1] > open[idx-1]) && 
      (close[idx-1] > close[idx-2]))
   {
      firstTwoTrending = true;
      uptrend = true;
   }
   else if((close[idx-2] < open[idx-2]) && (close[idx-1] < open[idx-1]) && 
           (close[idx-1] < close[idx-2]))
   {
      firstTwoTrending = true;
      uptrend = false;
   }
   
   if(!firstTwoTrending) return false;
   
   // الشمعة الثالثة: نجمة (جسم صغير)
   double thirdBody = MathAbs(close[idx] - open[idx]);
   double thirdRange = high[idx] - low[idx];
   
   if(thirdRange == 0) return false;
   
   bool isStar = (thirdBody / thirdRange) <= 0.3; // جسم أقل من 30%
   if(!isStar) return false;
   
   // النجمة يجب أن تكون في مستوى مرتفع (للصعودي) أو منخفض (للهبوطي)
   bool starAtExtreme = false;
   
   if(uptrend)
   {
      // النجمة عند قمة الحركة
      double avgThird = (high[idx] + low[idx]) / 2.0;
      double maxPrev = MathMax(high[idx-2], high[idx-1]);
      starAtExtreme = avgThird >= maxPrev * 0.98;
   }
   else
   {
      // النجمة عند قاع الحركة
      double avgThird = (high[idx] + low[idx]) / 2.0;
      double minPrev = MathMin(low[idx-2], low[idx-1]);
      starAtExtreme = avgThird <= minPrev * 1.02;
   }
   
   if(!starAtExtreme) return false;
   
   // النجمة تشير للتردد بعد حركة قوية
   bool hasGap = false;
   
   if(uptrend)
   {
      hasGap = low[idx] > high[idx-1]; // فجوة صعودية
   }
   else
   {
      hasGap = high[idx] < low[idx-1]; // فجوة هبوطية
   }
   
   // حساب قوة التردد
   double deliberationStrength = CalculateDeliberationStrength(open, high, low, close, idx-2);
   
   result.patternName = "Deliberation Star";
   result.strength = deliberationStrength;
   result.reliability = hasGap ? 0.75 : 0.65;
   result.direction = uptrend ? PATTERN_BEARISH : PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من الشمعة المترددة                                       |
//+------------------------------------------------------------------+
bool CDeliberationPatterns::IsDeliberativeCandle(const double open, const double high, const double low, const double close)
{
   double bodySize = MathAbs(close - open);
   double range = high - low;
   
   if(range == 0) return false;
   
   // شمعة مترددة: جسم صغير نسبياً
   double bodyRatio = bodySize / range;
   return bodyRatio <= m_deliberationThreshold;
}

//+------------------------------------------------------------------+
//| التحقق من التوقف                                                |
//+------------------------------------------------------------------+
bool CDeliberationPatterns::IsStalling(const double &open[], const double &high[], const double &low[], 
                                      const double &close[], int startIdx)
{
   // التحقق من أن الحركة تتباطأ مع الوقت
   double move1 = MathAbs(close[startIdx] - open[startIdx]);
   double move2 = MathAbs(close[startIdx+1] - open[startIdx+1]);
   double move3 = MathAbs(close[startIdx+2] - open[startIdx+2]);
   
   // كل حركة أصغر من السابقة (توقف تدريجي)
   return (move2 <= move1 * 1.1) && (move3 <= move2 * m_stallingRatio);
}

//+------------------------------------------------------------------+
//| التحقق من التردد                                                |
//+------------------------------------------------------------------+
bool CDeliberationPatterns::ShowsIndecision(const double open, const double high, const double low, const double close)
{
   double bodySize = MathAbs(close - open);
   double range = high - low;
   
   if(range == 0) return false;
   
   // تردد: جسم صغير جداً (دوجي أو قريب منه)
   double bodyRatio = bodySize / range;
   if(bodyRatio <= m_indecisionLevel) return true;
   
   // أو ظلال طويلة من الجانبين
   double upperShadow = high - MathMax(open, close);
   double lowerShadow = MathMin(open, close) - low;
   
   bool longShadows = (upperShadow > bodySize) && (lowerShadow > bodySize);
   return longShadows;
}

//+------------------------------------------------------------------+
//| حساب قوة التردد                                                 |
//+------------------------------------------------------------------+
double CDeliberationPatterns::CalculateDeliberationStrength(const double &open[], const double &high[], 
                                                           const double &low[], const double &close[], int startIdx)
{
   double totalDeliberation = 0;
   
   for(int i = 0; i < 3; i++)
   {
      double bodySize = MathAbs(close[startIdx + i] - open[startIdx + i]);
      double range = high[startIdx + i] - low[startIdx + i];
      
      if(range > 0)
      {
         double shadowRatio = (range - bodySize) / range;
         totalDeliberation += shadowRatio;
      }
   }
   
   return totalDeliberation / 3.0 * 2.0; // متوسط التردد مضروب في 2
}

//+------------------------------------------------------------------+
//| حساب فقدان التقدم                                               |
//+------------------------------------------------------------------+
double CDeliberationPatterns::CalculateProgressLoss(const double &close[], int startIdx)
{
   // مقارنة التقدم الإجمالي مع التقدم المتوقع
   double actualProgress = MathAbs(close[startIdx + 2] - close[startIdx]);
   double firstMove = MathAbs(close[startIdx + 1] - close[startIdx]);
   double expectedProgress = firstMove * 2.0; // توقع استمرار نفس الوتيرة
   
   if(expectedProgress == 0) return 0;
   
   double progressRatio = actualProgress / expectedProgress;
   return MathMax(0, 1.0 - progressRatio); // كلما قل التقدم، زاد فقدان التقدم
}

//+------------------------------------------------------------------+
//| التحقق من تناقص الزخم                                           |
//+------------------------------------------------------------------+
bool CDeliberationPatterns::HasDiminishingMomentum(const double &open[], const double &close[], int startIdx)
{
   double move1 = MathAbs(close[startIdx] - open[startIdx]);
   double move2 = MathAbs(close[startIdx + 1] - open[startIdx + 1]);
   double move3 = MathAbs(close[startIdx + 2] - open[startIdx + 2]);
   
   // كل حركة أصغر من السابقة
   return (move2 <= move1) && (move3 <= move2);
}
