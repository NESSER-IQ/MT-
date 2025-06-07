//+------------------------------------------------------------------+
//|                                         CorrectionPatterns.mqh |
//|                                            أنماط التصحيح       |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط التصحيح                                               |
//+------------------------------------------------------------------+
class CCorrectionPatterns : public CPatternDetector
{
private:
   double            m_tasukiThreshold;       // حد خط تاسوكي
   double            m_sandwichDepth;         // عمق الشطيرة
   double            m_pigeonReturnRatio;     // نسبة عودة الحمامة
   
public:
   // المنشئ والهادم
                     CCorrectionPatterns();
                     ~CCorrectionPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط التصحيح المحددة
   bool              DetectUpwardGapTasukiLine(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result);
                                             
   bool              DetectDownwardGapTasukiLine(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], 
                                               SPatternDetectionResult &result);
                                               
   bool              DetectStickSandwich(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       SPatternDetectionResult &result);
                                       
   bool              DetectHomingPigeon(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[], 
                                      SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsTasukiPattern(const double &open[], const double &high[], const double &low[], 
                                   const double &close[], int startIdx, bool upward);
   bool              IsSandwichPattern(const double &open[], const double &close[], int startIdx);
   bool              IsHomingPattern(const double &open[], const double &high[], const double &low[], 
                                   const double &close[], int startIdx);
   double            CalculateGapFillRatio(const double gapStart, const double gapEnd, const double fillLevel);
   double            CalculateCorrectionStrength(const double &open[], const double &close[], int startIdx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CCorrectionPatterns::CCorrectionPatterns()
{
   m_tasukiThreshold = 0.5;      // 50% حد ملء الفجوة
   m_sandwichDepth = 0.7;        // 70% عمق الشطيرة
   m_pigeonReturnRatio = 0.8;    // 80% نسبة عودة الحمامة
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CCorrectionPatterns::~CCorrectionPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CCorrectionPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط التصحيح                                     |
//+------------------------------------------------------------------+
int CCorrectionPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف خط تاسوكي للفجوة الصاعدة
   if(DetectUpwardGapTasukiLine(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف خط تاسوكي للفجوة الهابطة
   if(DetectDownwardGapTasukiLine(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف شطيرة العصا
   if(DetectStickSandwich(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف الحمامة العائدة
   if(DetectHomingPigeon(idx, open, high, low, close, result))
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
//| كشف خط تاسوكي للفجوة الصاعدة (Upward Gap Tasuki Line)           |
//+------------------------------------------------------------------+
bool CCorrectionPatterns::DetectUpwardGapTasukiLine(const int idx, const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], 
                                                   SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: صعودية
   bool firstBullish = close[idx-2] > open[idx-2];
   if(!firstBullish) return false;
   
   // الشمعة الثانية: صعودية مع فجوة صعودية
   bool secondBullish = close[idx-1] > open[idx-1];
   bool hasUpGap = low[idx-1] > high[idx-2];
   
   if(!secondBullish || !hasUpGap) return false;
   
   // الشمعة الثالثة: هبوطية تملأ جزء من الفجوة (خط تاسوكي)
   bool thirdBearish = close[idx] < open[idx];
   if(!thirdBearish) return false;
   
   // يجب أن تفتح ضمن جسم الشمعة الثانية
   bool opensInSecondBody = (open[idx] <= MathMax(open[idx-1], close[idx-1])) && 
                           (open[idx] >= MathMin(open[idx-1], close[idx-1]));
   
   // يجب أن تغلق ضمن الفجوة (تملأ جزء منها)
   bool closesInGap = (close[idx] > high[idx-2]) && (close[idx] < low[idx-1]);
   
   if(!opensInSecondBody || !closesInGap) return false;
   
   // التحقق من نمط تاسوكي
   if(!IsTasukiPattern(open, high, low, close, idx-2, true)) return false;
   
   // حساب نسبة ملء الفجوة
   double gapFillRatio = CalculateGapFillRatio(high[idx-2], low[idx-1], close[idx]);
   
   result.patternName = "Upward Gap Tasuki Line";
   result.strength = gapFillRatio * 2.0;
   result.reliability = 0.65;
   result.direction = PATTERN_BULLISH; // استمرار صعودي عادة
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف خط تاسوكي للفجوة الهابطة (Downward Gap Tasuki Line)         |
//+------------------------------------------------------------------+
bool CCorrectionPatterns::DetectDownwardGapTasukiLine(const int idx, const double &open[], const double &high[], 
                                                     const double &low[], const double &close[], 
                                                     SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: هبوطية
   bool firstBearish = close[idx-2] < open[idx-2];
   if(!firstBearish) return false;
   
   // الشمعة الثانية: هبوطية مع فجوة هبوطية
   bool secondBearish = close[idx-1] < open[idx-1];
   bool hasDownGap = high[idx-1] < low[idx-2];
   
   if(!secondBearish || !hasDownGap) return false;
   
   // الشمعة الثالثة: صعودية تملأ جزء من الفجوة (خط تاسوكي)
   bool thirdBullish = close[idx] > open[idx];
   if(!thirdBullish) return false;
   
   // يجب أن تفتح ضمن جسم الشمعة الثانية
   bool opensInSecondBody = (open[idx] >= MathMin(open[idx-1], close[idx-1])) && 
                           (open[idx] <= MathMax(open[idx-1], close[idx-1]));
   
   // يجب أن تغلق ضمن الفجوة (تملأ جزء منها)
   bool closesInGap = (close[idx] < low[idx-2]) && (close[idx] > high[idx-1]);
   
   if(!opensInSecondBody || !closesInGap) return false;
   
   // التحقق من نمط تاسوكي
   if(!IsTasukiPattern(open, high, low, close, idx-2, false)) return false;
   
   // حساب نسبة ملء الفجوة
   double gapFillRatio = CalculateGapFillRatio(low[idx-2], high[idx-1], close[idx]);
   
   result.patternName = "Downward Gap Tasuki Line";
   result.strength = gapFillRatio * 2.0;
   result.reliability = 0.65;
   result.direction = PATTERN_BEARISH; // استمرار هبوطي عادة
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف شطيرة العصا (Stick Sandwich)                                |
//+------------------------------------------------------------------+
bool CCorrectionPatterns::DetectStickSandwich(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى والثالثة يجب أن تكونا متشابهتين في الإغلاق
   double firstClose = close[idx-2];
   double thirdClose = close[idx];
   double closeDifference = MathAbs(thirdClose - firstClose);
   double avgPrice = (firstClose + thirdClose) / 2.0;
   
   if(avgPrice == 0) return false;
   
   bool similarCloses = (closeDifference / avgPrice) <= 0.02; // فرق أقل من 2%
   if(!similarCloses) return false;
   
   // الشمعة الوسطى يجب أن تكون مختلفة اللون والحجم
   bool firstBearish = close[idx-2] < open[idx-2];
   bool secondOpposite = (firstBearish && close[idx-1] > open[idx-1]) || 
                        (!firstBearish && close[idx-1] < open[idx-1]);
   bool thirdSameAsFirst = (firstBearish && close[idx] < open[idx]) || 
                          (!firstBearish && close[idx] > open[idx]);
   
   if(!secondOpposite || !thirdSameAsFirst) return false;
   
   // الشمعة الوسطى يجب أن تكون أكبر أو تختلف بشكل واضح
   double firstBody = MathAbs(close[idx-2] - open[idx-2]);
   double secondBody = MathAbs(close[idx-1] - open[idx-1]);
   double thirdBody = MathAbs(close[idx] - open[idx]);
   
   bool middleStandsOut = (secondBody > firstBody * 1.2) || (secondBody > thirdBody * 1.2);
   if(!middleStandsOut) return false;
   
   // التحقق من نمط الشطيرة
   if(!IsSandwichPattern(open, close, idx-2)) return false;
   
   // تحديد الاتجاه
   ENUM_PATTERN_DIRECTION direction = firstBearish ? PATTERN_BULLISH : PATTERN_BEARISH;
   
   result.patternName = "Stick Sandwich";
   result.strength = secondBody / ((firstBody + thirdBody) / 2.0);
   result.reliability = 0.60;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف الحمامة العائدة (Homing Pigeon)                             |
//+------------------------------------------------------------------+
bool CCorrectionPatterns::DetectHomingPigeon(const int idx, const double &open[], const double &high[], 
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
   
   // الشمعة الثانية: هبوطية أصغر (الحمامة الصغيرة)
   bool secondBearish = close[idx-1] < open[idx-1];
   double secondBody = MathAbs(close[idx-1] - open[idx-1]);
   
   if(!secondBearish) return false;
   
   // الشمعة الثانية يجب أن تكون ضمن جسم الأولى
   bool secondInFirst = (high[idx-1] <= MathMax(open[idx-2], close[idx-2])) && 
                       (low[idx-1] >= MathMin(open[idx-2], close[idx-2]));
   
   // الحمامة يجب أن تكون أصغر من الأولى
   bool secondSmaller = secondBody < firstBody * m_pigeonReturnRatio;
   
   if(!secondInFirst || !secondSmaller) return false;
   
   // الشمعة الثالثة: انعكاس صعودي (عودة الحمامة)
   bool thirdBullish = close[idx] > open[idx];
   bool returnsHome = close[idx] > MathMax(open[idx-1], close[idx-1]);
   
   if(!thirdBullish || !returnsHome) return false;
   
   // التحقق من نمط الحمامة
   if(!IsHomingPattern(open, high, low, close, idx-2)) return false;
   
   // حساب قوة العودة
   double returnStrength = (close[idx] - low[idx-2]) / (high[idx-2] - low[idx-2]);
   
   result.patternName = "Homing Pigeon";
   result.strength = returnStrength * 2.0;
   result.reliability = 0.70;
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من نمط تاسوكي                                             |
//+------------------------------------------------------------------+
bool CCorrectionPatterns::IsTasukiPattern(const double &open[], const double &high[], const double &low[], 
                                         const double &close[], int startIdx, bool upward)
{
   if(upward)
   {
      // نمط تاسوكي صعودي: صعودي، فجوة صعودية، هبوطي يملأ جزء من الفجوة
      return (close[startIdx] > open[startIdx]) &&           // أولى صعودية
             (close[startIdx+1] > open[startIdx+1]) &&        // ثانية صعودية
             (low[startIdx+1] > high[startIdx]) &&            // فجوة صعودية
             (close[startIdx+2] < open[startIdx+2]) &&        // ثالثة هبوطية
             (close[startIdx+2] > high[startIdx]) &&          // تغلق فوق الأولى
             (close[startIdx+2] < low[startIdx+1]);           // تغلق تحت الثانية
   }
   else
   {
      // نمط تاسوكي هبوطي: هبوطي، فجوة هبوطية، صعودي يملأ جزء من الفجوة
      return (close[startIdx] < open[startIdx]) &&           // أولى هبوطية
             (close[startIdx+1] < open[startIdx+1]) &&        // ثانية هبوطية
             (high[startIdx+1] < low[startIdx]) &&            // فجوة هبوطية
             (close[startIdx+2] > open[startIdx+2]) &&        // ثالثة صعودية
             (close[startIdx+2] < low[startIdx]) &&           // تغلق تحت الأولى
             (close[startIdx+2] > high[startIdx+1]);          // تغلق فوق الثانية
   }
}

//+------------------------------------------------------------------+
//| التحقق من نمط الشطيرة                                           |
//+------------------------------------------------------------------+
bool CCorrectionPatterns::IsSandwichPattern(const double &open[], const double &close[], int startIdx)
{
   // الشمعة الأولى والثالثة متشابهتان، الوسطى مختلفة
   bool firstAndThirdSimilar = MathAbs(close[startIdx] - close[startIdx+2]) < 
                              MathAbs(close[startIdx] - close[startIdx+1]);
   
   // الألوان: أولى وثالثة نفس اللون، وسطى مختلفة
   bool firstBearish = close[startIdx] < open[startIdx];
   bool secondDifferent = (firstBearish && close[startIdx+1] > open[startIdx+1]) || 
                         (!firstBearish && close[startIdx+1] < open[startIdx+1]);
   bool thirdSameAsFirst = (firstBearish && close[startIdx+2] < open[startIdx+2]) || 
                          (!firstBearish && close[startIdx+2] > open[startIdx+2]);
   
   return firstAndThirdSimilar && secondDifferent && thirdSameAsFirst;
}

//+------------------------------------------------------------------+
//| التحقق من نمط الحمامة                                           |
//+------------------------------------------------------------------+
bool CCorrectionPatterns::IsHomingPattern(const double &open[], const double &high[], const double &low[], 
                                         const double &close[], int startIdx)
{
   // هبوطية كبيرة، هبوطية صغيرة داخلية، صعودية عائدة
   bool sequence = (close[startIdx] < open[startIdx]) &&      // أولى هبوطية
                  (close[startIdx+1] < open[startIdx+1]) &&   // ثانية هبوطية
                  (close[startIdx+2] > open[startIdx+2]);     // ثالثة صعودية
   
   if(!sequence) return false;
   
   // الثانية داخل الأولى والثالثة تتجاوز الثانية
   bool pigeonInside = (high[startIdx+1] <= high[startIdx]) && (low[startIdx+1] >= low[startIdx]);
   bool returnsHome = close[startIdx+2] > high[startIdx+1];
   
   return pigeonInside && returnsHome;
}

//+------------------------------------------------------------------+
//| حساب نسبة ملء الفجوة                                            |
//+------------------------------------------------------------------+
double CCorrectionPatterns::CalculateGapFillRatio(const double gapStart, const double gapEnd, const double fillLevel)
{
   double gapSize = MathAbs(gapEnd - gapStart);
   if(gapSize == 0) return 0;
   
   double fillAmount = MathAbs(fillLevel - gapEnd);
   return MathMin(fillAmount / gapSize, 1.0);
}

//+------------------------------------------------------------------+
//| حساب قوة التصحيح                                                |
//+------------------------------------------------------------------+
double CCorrectionPatterns::CalculateCorrectionStrength(const double &open[], const double &close[], int startIdx)
{
   double totalMove = 0;
   double correctionMove = 0;
   
   for(int i = 0; i < 3; i++)
   {
      double move = MathAbs(close[startIdx + i] - open[startIdx + i]);
      totalMove += move;
      
      if(i == 2) // الشمعة المصححة
         correctionMove = move;
   }
   
   if(totalMove == 0) return 0;
   
   return correctionMove / totalMove * 3.0; // تضخيم النتيجة
}
