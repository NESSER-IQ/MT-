//+------------------------------------------------------------------+
//|                                            GappingPatterns.mqh |
//|                                       أنماط الفجوات الثلاثية   |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الفجوات الثلاثية                                      |
//+------------------------------------------------------------------+
class CGappingPatterns : public CPatternDetector
{
private:
   double            m_minGapSize;            // الحد الأدنى لحجم الفجوة
   double            m_sideBySideThreshold;   // حد النمط الجانبي
   double            m_gapProgressRatio;      // نسبة تقدم الفجوات
   
public:
   // المنشئ والهادم
                     CGappingPatterns();
                     ~CGappingPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط الفجوات المحددة
   bool              DetectThreeGapsUp(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[], 
                                     SPatternDetectionResult &result);
                                     
   bool              DetectThreeGapsDown(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       SPatternDetectionResult &result);
                                       
   bool              DetectUpGapSideBySide(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[], 
                                         SPatternDetectionResult &result);
                                         
   bool              DetectDownGapSideBySide(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], 
                                           SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              HasGap(const double high1, const double low1, const double high2, const double low2, bool upward);
   bool              IsValidGapSequence(const double &high[], const double &low[], int startIdx, bool upward);
   bool              IsSideBySidePattern(const double &open[], const double &high[], const double &low[], 
                                       const double &close[], int startIdx);
   double            CalculateGapSize(const double price1, const double price2);
   double            CalculateGapMomentum(const double &high[], const double &low[], const double &close[], int startIdx);
   int               CountConsecutiveGaps(const double &high[], const double &low[], int startIdx, bool upward);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CGappingPatterns::CGappingPatterns()
{
   m_minGapSize = 0.001;            // 0.1% حد أدنى للفجوة
   m_sideBySideThreshold = 0.8;     // 80% تشابه للنمط الجانبي
   m_gapProgressRatio = 1.1;        // 10% زيادة في حجم الفجوات
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CGappingPatterns::~CGappingPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CGappingPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط الفجوات                                     |
//+------------------------------------------------------------------+
int CGappingPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف ثلاث فجوات صاعدة
   if(DetectThreeGapsUp(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف ثلاث فجوات هابطة
   if(DetectThreeGapsDown(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف فجوة صاعدة جانبية
   if(DetectUpGapSideBySide(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف فجوة هابطة جانبية
   if(DetectDownGapSideBySide(idx, open, high, low, close, result))
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
//| كشف ثلاث فجوات صاعدة (Three Gaps Up)                           |
//+------------------------------------------------------------------+
bool CGappingPatterns::DetectThreeGapsUp(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[], 
                                        SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من وجود تسلسل من الفجوات الصاعدة
   if(!IsValidGapSequence(high, low, idx-2, true)) return false;
   
   // عد الفجوات المتتالية
   int gapCount = CountConsecutiveGaps(high, low, idx-2, true);
   if(gapCount < 3) return false;
   
   // التحقق من قوة الاتجاه الصعودي
   bool strongUptrend = true;
   for(int i = 0; i < 3; i++)
   {
      if(close[idx-2+i] <= open[idx-2+i])
      {
         strongUptrend = false;
         break;
      }
   }
   
   if(!strongUptrend) return false;
   
   // حساب زخم الفجوات
   double gapMomentum = CalculateGapMomentum(high, low, close, idx-2);
   
   // الفجوات الثلاث تشير عادة لذروة شراء وانعكاس محتمل
   bool exhaustionSignal = false;
   
   // البحث عن علامات الإنهاك
   // 1. تناقص حجم الفجوات
   double gap1 = CalculateGapSize(high[idx-2], low[idx-1]);
   double gap2 = CalculateGapSize(high[idx-1], low[idx]);
   bool diminishingGaps = gap2 <= gap1 * 0.9;
   
   // 2. ظلال علوية طويلة في الشمعة الأخيرة
   double upperShadow = high[idx] - MathMax(open[idx], close[idx]);
   double bodySize = MathAbs(close[idx] - open[idx]);
   bool longUpperShadow = (bodySize > 0) && (upperShadow > bodySize * 0.5);
   
   exhaustionSignal = diminishingGaps || longUpperShadow;
   
   result.patternName = "Three Gaps Up";
   result.strength = gapMomentum;
   result.reliability = exhaustionSignal ? 0.75 : 0.60;
   result.direction = exhaustionSignal ? PATTERN_BEARISH : PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف ثلاث فجوات هابطة (Three Gaps Down)                         |
//+------------------------------------------------------------------+
bool CGappingPatterns::DetectThreeGapsDown(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من وجود تسلسل من الفجوات الهابطة
   if(!IsValidGapSequence(high, low, idx-2, false)) return false;
   
   // عد الفجوات المتتالية
   int gapCount = CountConsecutiveGaps(high, low, idx-2, false);
   if(gapCount < 3) return false;
   
   // التحقق من قوة الاتجاه الهبوطي
   bool strongDowntrend = true;
   for(int i = 0; i < 3; i++)
   {
      if(close[idx-2+i] >= open[idx-2+i])
      {
         strongDowntrend = false;
         break;
      }
   }
   
   if(!strongDowntrend) return false;
   
   // حساب زخم الفجوات
   double gapMomentum = CalculateGapMomentum(high, low, close, idx-2);
   
   // الفجوات الثلاث تشير عادة لذروة بيع وانعكاس محتمل
   bool exhaustionSignal = false;
   
   // البحث عن علامات الإنهاك
   // 1. تناقص حجم الفجوات
   double gap1 = CalculateGapSize(low[idx-2], high[idx-1]);
   double gap2 = CalculateGapSize(low[idx-1], high[idx]);
   bool diminishingGaps = gap2 <= gap1 * 0.9;
   
   // 2. ظلال سفلية طويلة في الشمعة الأخيرة
   double lowerShadow = MathMin(open[idx], close[idx]) - low[idx];
   double bodySize = MathAbs(close[idx] - open[idx]);
   bool longLowerShadow = (bodySize > 0) && (lowerShadow > bodySize * 0.5);
   
   exhaustionSignal = diminishingGaps || longLowerShadow;
   
   result.patternName = "Three Gaps Down";
   result.strength = gapMomentum;
   result.reliability = exhaustionSignal ? 0.75 : 0.60;
   result.direction = exhaustionSignal ? PATTERN_BULLISH : PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف فجوة صاعدة جانبية (Up Gap Side by Side)                     |
//+------------------------------------------------------------------+
bool CGappingPatterns::DetectUpGapSideBySide(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], 
                                           SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: صعودية
   bool firstBullish = close[idx-2] > open[idx-2];
   if(!firstBullish) return false;
   
   // الشمعة الثانية: فجوة صعودية
   bool hasUpGap = HasGap(high[idx-2], low[idx-2], high[idx-1], low[idx-1], true);
   if(!hasUpGap) return false;
   
   // الشمعة الثالثة: "جانبية" مع الثانية
   bool sideBySide = IsSideBySidePattern(open, high, low, close, idx-1);
   if(!sideBySide) return false;
   
   // التحقق من التشابه في الحجم والموقع
   double body2 = MathAbs(close[idx-1] - open[idx-1]);
   double body3 = MathAbs(close[idx] - open[idx]);
   double bodySimilarity = (body2 > 0) ? MathMin(body3/body2, body2/body3) : 0;
   
   bool similarBodies = bodySimilarity >= m_sideBySideThreshold;
   if(!similarBodies) return false;
   
   // التحقق من المستوى الجانبي
   double avg2 = (high[idx-1] + low[idx-1]) / 2.0;
   double avg3 = (high[idx] + low[idx]) / 2.0;
   double levelDiff = MathAbs(avg3 - avg2) / avg2;
   bool sameLevel = levelDiff <= 0.02; // فرق أقل من 2%
   
   if(!sameLevel) return false;
   
   // تحديد الاتجاه بناء على اللون الثالث
   bool thirdBullish = close[idx] > open[idx];
   ENUM_PATTERN_DIRECTION direction = thirdBullish ? PATTERN_BULLISH : PATTERN_BEARISH;
   
   result.patternName = "Up Gap Side by Side";
   result.strength = CalculateGapSize(high[idx-2], low[idx-1]) * 1000;
   result.reliability = 0.65;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف فجوة هابطة جانبية (Down Gap Side by Side)                   |
//+------------------------------------------------------------------+
bool CGappingPatterns::DetectDownGapSideBySide(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: هبوطية
   bool firstBearish = close[idx-2] < open[idx-2];
   if(!firstBearish) return false;
   
   // الشمعة الثانية: فجوة هبوطية
   bool hasDownGap = HasGap(high[idx-2], low[idx-2], high[idx-1], low[idx-1], false);
   if(!hasDownGap) return false;
   
   // الشمعة الثالثة: "جانبية" مع الثانية
   bool sideBySide = IsSideBySidePattern(open, high, low, close, idx-1);
   if(!sideBySide) return false;
   
   // التحقق من التشابه في الحجم والموقع
   double body2 = MathAbs(close[idx-1] - open[idx-1]);
   double body3 = MathAbs(close[idx] - open[idx]);
   double bodySimilarity = (body2 > 0) ? MathMin(body3/body2, body2/body3) : 0;
   
   bool similarBodies = bodySimilarity >= m_sideBySideThreshold;
   if(!similarBodies) return false;
   
   // التحقق من المستوى الجانبي
   double avg2 = (high[idx-1] + low[idx-1]) / 2.0;
   double avg3 = (high[idx] + low[idx]) / 2.0;
   double levelDiff = MathAbs(avg3 - avg2) / avg2;
   bool sameLevel = levelDiff <= 0.02; // فرق أقل من 2%
   
   if(!sameLevel) return false;
   
   // تحديد الاتجاه بناء على اللون الثالث
   bool thirdBearish = close[idx] < open[idx];
   ENUM_PATTERN_DIRECTION direction = thirdBearish ? PATTERN_BEARISH : PATTERN_BULLISH;
   
   result.patternName = "Down Gap Side by Side";
   result.strength = CalculateGapSize(low[idx-2], high[idx-1]) * 1000;
   result.reliability = 0.65;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من وجود فجوة                                             |
//+------------------------------------------------------------------+
bool CGappingPatterns::HasGap(const double high1, const double low1, const double high2, const double low2, bool upward)
{
   if(upward)
   {
      // فجوة صاعدية: أدنى الثانية أعلى من أعلى الأولى
      double gapSize = low2 - high1;
      return gapSize > 0 && (gapSize / high1 >= m_minGapSize);
   }
   else
   {
      // فجوة هبوطية: أعلى الثانية أقل من أدنى الأولى
      double gapSize = low1 - high2;
      return gapSize > 0 && (gapSize / low1 >= m_minGapSize);
   }
}

//+------------------------------------------------------------------+
//| التحقق من تسلسل الفجوات الصحيح                                 |
//+------------------------------------------------------------------+
bool CGappingPatterns::IsValidGapSequence(const double &high[], const double &low[], int startIdx, bool upward)
{
   // التحقق من وجود فجوتين على الأقل
   int gapCount = 0;
   
   for(int i = 0; i < 2; i++)
   {
      if(HasGap(high[startIdx + i], low[startIdx + i], high[startIdx + i + 1], low[startIdx + i + 1], upward))
         gapCount++;
   }
   
   return gapCount >= 2;
}

//+------------------------------------------------------------------+
//| التحقق من النمط الجانبي                                         |
//+------------------------------------------------------------------+
bool CGappingPatterns::IsSideBySidePattern(const double &open[], const double &high[], const double &low[], 
                                         const double &close[], int startIdx)
{
   // الشمعتان يجب أن تكونا في نفس المستوى تقريباً
   double range1 = high[startIdx] - low[startIdx];
   double range2 = high[startIdx + 1] - low[startIdx + 1];
   
   if(range1 == 0 || range2 == 0) return false;
   
   // التحقق من التداخل الجانبي
   double overlap = MathMin(high[startIdx], high[startIdx + 1]) - 
                   MathMax(low[startIdx], low[startIdx + 1]);
   
   double avgRange = (range1 + range2) / 2.0;
   
   return (overlap > 0) && (overlap >= avgRange * m_sideBySideThreshold);
}

//+------------------------------------------------------------------+
//| حساب حجم الفجوة                                                 |
//+------------------------------------------------------------------+
double CGappingPatterns::CalculateGapSize(const double price1, const double price2)
{
   if(price1 == 0) return 0;
   return MathAbs(price2 - price1) / price1;
}

//+------------------------------------------------------------------+
//| حساب زخم الفجوات                                                |
//+------------------------------------------------------------------+
double CGappingPatterns::CalculateGapMomentum(const double &high[], const double &low[], const double &close[], int startIdx)
{
   double totalGapSize = 0;
   double totalPriceMove = 0;
   
   for(int i = 0; i < 2; i++)
   {
      // حساب حجم الفجوة
      if(close[startIdx + i] > close[startIdx + i + 1]) // صعودي
      {
         totalGapSize += CalculateGapSize(high[startIdx + i], low[startIdx + i + 1]);
      }
      else // هبوطي
      {
         totalGapSize += CalculateGapSize(low[startIdx + i], high[startIdx + i + 1]);
      }
      
      // حساب الحركة الإجمالية
      totalPriceMove += MathAbs(close[startIdx + i + 1] - close[startIdx + i]);
   }
   
   return (totalGapSize + totalPriceMove / 1000) * 1000; // تحويل لنقاط
}

//+------------------------------------------------------------------+
//| عد الفجوات المتتالية                                            |
//+------------------------------------------------------------------+
int CGappingPatterns::CountConsecutiveGaps(const double &high[], const double &low[], int startIdx, bool upward)
{
   int count = 0;
   
   for(int i = 0; i < 2; i++)
   {
      if(HasGap(high[startIdx + i], low[startIdx + i], high[startIdx + i + 1], low[startIdx + i + 1], upward))
         count++;
      else
         break; // توقف عند أول عدم وجود فجوة
   }
   
   return count;
}
