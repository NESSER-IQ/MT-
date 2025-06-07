//+------------------------------------------------------------------+
//|                                           IdentityPatterns.mqh |
//|                                       أنماط الهوية والتطابق     |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الهوية والتطابق                                       |
//+------------------------------------------------------------------+
class CIdentityPatterns : public CPatternDetector
{
private:
   double            m_identityThreshold;     // حد التطابق
   double            m_matchingTolerance;     // تسامح المطابقة
   double            m_starAlignment;         // محاذاة النجوم
   
public:
   // المنشئ والهادم
                     CIdentityPatterns();
                     ~CIdentityPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط الهوية والتطابق المحددة
   bool              DetectIdenticalThreeCrows(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result);
                                             
   bool              DetectMatchingLow(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[], 
                                     SPatternDetectionResult &result);
                                     
   bool              DetectMatchingHigh(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[], 
                                      SPatternDetectionResult &result);
                                      
   bool              DetectThreeStarsInSouth(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], 
                                           SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              AreIdenticalCandles(const double open1, const double high1, const double low1, const double close1,
                                       const double open2, const double high2, const double low2, const double close2);
   bool              IsMatchingLevel(const double price1, const double price2);
   bool              AreThreeStarsAligned(const double &open[], const double &high[], const double &low[], 
                                        const double &close[], int startIdx);
   bool              IsValidSouthernPattern(const double &open[], const double &high[], const double &low[], 
                                          const double &close[], int startIdx);
   double            CalculateIdentityStrength(const double &open[], const double &high[], const double &low[], 
                                              const double &close[], int startIdx);
   double            CalculateMatchingAccuracy(const double level1, const double level2, const double level3);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CIdentityPatterns::CIdentityPatterns()
{
   m_identityThreshold = 0.95;    // 95% تشابه للتطابق
   m_matchingTolerance = 0.005;   // 0.5% تسامح المطابقة
   m_starAlignment = 0.1;         // 10% انحراف النجوم المسموح
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CIdentityPatterns::~CIdentityPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CIdentityPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط الهوية والتطابق                            |
//+------------------------------------------------------------------+
int CIdentityPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف ثلاثة غربان متطابقة
   if(DetectIdenticalThreeCrows(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف القاع المطابق
   if(DetectMatchingLow(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف القمة المطابقة
   if(DetectMatchingHigh(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف ثلاث نجوم في الجنوب
   if(DetectThreeStarsInSouth(idx, open, high, low, close, result))
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
//| كشف ثلاثة غربان متطابقة (Identical Three Crows)                 |
//+------------------------------------------------------------------+
bool CIdentityPatterns::DetectIdenticalThreeCrows(const int idx, const double &open[], const double &high[], 
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
   
   // التحقق من التطابق في الحجم والشكل
   bool firstSecondIdentical = AreIdenticalCandles(open[idx-2], high[idx-2], low[idx-2], close[idx-2],
                                                  open[idx-1], high[idx-1], low[idx-1], close[idx-1]);
   
   bool secondThirdIdentical = AreIdenticalCandles(open[idx-1], high[idx-1], low[idx-1], close[idx-1],
                                                  open[idx], high[idx], low[idx], close[idx]);
   
   // يكفي أن تكون اثنتان متطابقتان بدرجة عالية
   bool sufficientIdentity = firstSecondIdentical || secondThirdIdentical;
   
   if(!sufficientIdentity) return false;
   
   // التحقق من التقدم التدريجي للهبوط
   bool progressiveDecline = (close[idx-1] < close[idx-2]) && (close[idx] < close[idx-1]);
   if(!progressiveDecline) return false;
   
   // كل شمعة تفتح ضمن جسم السابقة
   bool properOpenings = (open[idx-1] < open[idx-2] && open[idx-1] > close[idx-2]) &&
                        (open[idx] < open[idx-1] && open[idx] > close[idx-1]);
   
   if(!properOpenings) return false;
   
   // حساب قوة التطابق
   double identityStrength = CalculateIdentityStrength(open, high, low, close, idx-2);
   
   result.patternName = "Identical Three Crows";
   result.strength = identityStrength;
   result.reliability = 0.85;
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف القاع المطابق (Matching Low)                                |
//+------------------------------------------------------------------+
bool CIdentityPatterns::DetectMatchingLow(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[], 
                                         SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // البحث عن مستويات قيعان متطابقة
   double low1 = low[idx-2];
   double low2 = low[idx-1]; 
   double low3 = low[idx];
   
   // التحقق من تطابق القيعان (على الأقل اثنان متطابقان)
   bool match12 = IsMatchingLevel(low1, low2);
   bool match23 = IsMatchingLevel(low2, low3);
   bool match13 = IsMatchingLevel(low1, low3);
   
   bool hasMatchingLows = match12 || match23 || match13;
   if(!hasMatchingLows) return false;
   
   // يفضل أن تكون الشموع هبوطية أو مختلطة تشير لدعم
   bool supportivePattern = false;
   
   // النمط الأول: ثلاث شموع تختبر نفس القاع
   bool testingSameLevel = match12 && match23; // الثلاثة متطابقة
   
   // النمط الثاني: شمعتان تختبران قاع وثالثة ترتد
   bool bouncePattern = (match12 && close[idx] > low[idx]) || 
                       (match13 && close[idx-1] > low[idx-1]);
   
   supportivePattern = testingSameLevel || bouncePattern;
   if(!supportivePattern) return false;
   
   // التحقق من وجود إشارات انعكاس
   bool reversalSignals = false;
   
   // البحث عن شموع صعودية بعد اختبار القاع
   for(int i = 0; i < 3; i++)
   {
      if(close[idx-2+i] > open[idx-2+i] && low[idx-2+i] <= (low1 + low2 + low3) / 3.0 * 1.01)
      {
         reversalSignals = true;
         break;
      }
   }
   
   // حساب دقة المطابقة
   double matchingAccuracy = CalculateMatchingAccuracy(low1, low2, low3);
   
   result.patternName = "Matching Low";
   result.strength = matchingAccuracy * 2.0;
   result.reliability = reversalSignals ? 0.75 : 0.60;
   result.direction = PATTERN_BULLISH; // إشارة دعم وانعكاس محتمل
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف القمة المطابقة (Matching High)                              |
//+------------------------------------------------------------------+
bool CIdentityPatterns::DetectMatchingHigh(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // البحث عن مستويات قمم متطابقة
   double high1 = high[idx-2];
   double high2 = high[idx-1]; 
   double high3 = high[idx];
   
   // التحقق من تطابق القمم (على الأقل اثنان متطابقان)
   bool match12 = IsMatchingLevel(high1, high2);
   bool match23 = IsMatchingLevel(high2, high3);
   bool match13 = IsMatchingLevel(high1, high3);
   
   bool hasMatchingHighs = match12 || match23 || match13;
   if(!hasMatchingHighs) return false;
   
   // يفضل أن تكون الشموع صعودية أو مختلطة تشير لمقاومة
   bool resistancePattern = false;
   
   // النمط الأول: ثلاث شموع تختبر نفس القمة
   bool testingSameLevel = match12 && match23; // الثلاثة متطابقة
   
   // النمط الثاني: شمعتان تختبران قمة وثالثة ترتد
   bool rejectionPattern = (match12 && close[idx] < high[idx]) || 
                          (match13 && close[idx-1] < high[idx-1]);
   
   resistancePattern = testingSameLevel || rejectionPattern;
   if(!resistancePattern) return false;
   
   // التحقق من وجود إشارات انعكاس
   bool reversalSignals = false;
   
   // البحث عن شموع هبوطية بعد اختبار القمة
   for(int i = 0; i < 3; i++)
   {
      if(close[idx-2+i] < open[idx-2+i] && high[idx-2+i] >= (high1 + high2 + high3) / 3.0 * 0.99)
      {
         reversalSignals = true;
         break;
      }
   }
   
   // حساب دقة المطابقة
   double matchingAccuracy = CalculateMatchingAccuracy(high1, high2, high3);
   
   result.patternName = "Matching High";
   result.strength = matchingAccuracy * 2.0;
   result.reliability = reversalSignals ? 0.75 : 0.60;
   result.direction = PATTERN_BEARISH; // إشارة مقاومة وانعكاس محتمل
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف ثلاث نجوم في الجنوب (Three Stars in South)                 |
//+------------------------------------------------------------------+
bool CIdentityPatterns::DetectThreeStarsInSouth(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], 
                                               SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من أن الشموع الثلاث هي نجوم (أجسام صغيرة)
   if(!AreThreeStarsAligned(open, high, low, close, idx-2)) return false;
   
   // التحقق من النمط الجنوبي (اتجاه هبوطي مع تباطؤ)
   if(!IsValidSouthernPattern(open, high, low, close, idx-2)) return false;
   
   // الشموع يجب أن تكون في اتجاه هبوطي عام مع تناقص الزخم
   bool generallyDescending = (low[idx] <= low[idx-1]) && (low[idx-1] <= low[idx-2]);
   if(!generallyDescending) return false;
   
   // كل نجمة تحت السابقة (نمط هبوطي متدرج)
   bool progressiveStars = true;
   for(int i = 1; i < 3; i++)
   {
      double prevAvg = (open[idx-2+i-1] + close[idx-2+i-1]) / 2.0;
      double currAvg = (open[idx-2+i] + close[idx-2+i]) / 2.0;
      
      if(currAvg >= prevAvg)
      {
         progressiveStars = false;
         break;
      }
   }
   
   if(!progressiveStars) return false;
   
   // النجمة الأخيرة يجب أن تظهر علامات استنفاد البائعين
   bool exhaustionSignal = false;
   
   // البحث عن دوجي في النجمة الأخيرة
   double lastBodySize = MathAbs(close[idx] - open[idx]);
   double lastRange = high[idx] - low[idx];
   bool isDoji = (lastRange > 0) && (lastBodySize / lastRange < 0.1);
   
   // أو ظلال سفلية طويلة تشير لدعم
   double lowerShadow = MathMin(open[idx], close[idx]) - low[idx];
   bool longLowerShadow = (lastRange > 0) && (lowerShadow / lastRange > 0.5);
   
   exhaustionSignal = isDoji || longLowerShadow;
   
   // حساب قوة النمط الجنوبي
   double southernStrength = 1.0;
   if(isDoji) southernStrength += 0.5;
   if(longLowerShadow) southernStrength += 0.3;
   if(progressiveStars) southernStrength += 0.2;
   
   result.patternName = "Three Stars in South";
   result.strength = southernStrength;
   result.reliability = exhaustionSignal ? 0.70 : 0.55;
   result.direction = PATTERN_BULLISH; // إشارة انعكاس صعودي محتمل
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من تطابق الشموع                                          |
//+------------------------------------------------------------------+
bool CIdentityPatterns::AreIdenticalCandles(const double open1, const double high1, const double low1, const double close1,
                                           const double open2, const double high2, const double low2, const double close2)
{
   // حساب المقاييس النسبية
   double body1 = MathAbs(close1 - open1);
   double body2 = MathAbs(close2 - open2);
   double range1 = high1 - low1;
   double range2 = high2 - low2;
   
   if(range1 == 0 || range2 == 0) return false;
   
   // مقارنة نسب الأجسام
   double bodyRatio1 = body1 / range1;
   double bodyRatio2 = body2 / range2;
   double bodyDiff = MathAbs(bodyRatio1 - bodyRatio2);
   
   // مقارنة الاتجاهات
   bool sameDirection = ((close1 > open1) && (close2 > open2)) || 
                       ((close1 < open1) && (close2 < open2));
   
   // التطابق يتطلب نفس الاتجاه ونسب متشابهة
   return sameDirection && (bodyDiff <= (1.0 - m_identityThreshold));
}

//+------------------------------------------------------------------+
//| التحقق من مطابقة المستوى                                        |
//+------------------------------------------------------------------+
bool CIdentityPatterns::IsMatchingLevel(const double price1, const double price2)
{
   if(price1 == 0) return false;
   
   double diff = MathAbs(price2 - price1) / price1;
   return diff <= m_matchingTolerance;
}

//+------------------------------------------------------------------+
//| التحقق من محاذاة ثلاث نجوم                                      |
//+------------------------------------------------------------------+
bool CIdentityPatterns::AreThreeStarsAligned(const double &open[], const double &high[], const double &low[], 
                                            const double &close[], int startIdx)
{
   // كل شمعة يجب أن تكون نجمة (جسم صغير)
   for(int i = 0; i < 3; i++)
   {
      double body = MathAbs(close[startIdx + i] - open[startIdx + i]);
      double range = high[startIdx + i] - low[startIdx + i];
      
      if(range == 0 || body / range > m_starAlignment)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من صحة النمط الجنوبي                                     |
//+------------------------------------------------------------------+
bool CIdentityPatterns::IsValidSouthernPattern(const double &open[], const double &high[], const double &low[], 
                                              const double &close[], int startIdx)
{
   // النمط الجنوبي: اتجاه هبوطي عام مع تباطؤ التقدم
   double avgPrice1 = (high[startIdx] + low[startIdx]) / 2.0;
   double avgPrice2 = (high[startIdx+1] + low[startIdx+1]) / 2.0;
   double avgPrice3 = (high[startIdx+2] + low[startIdx+2]) / 2.0;
   
   // الاتجاه العام هبوطي
   bool overallDescending = (avgPrice2 <= avgPrice1) && (avgPrice3 <= avgPrice2);
   
   // لكن التقدم يتباطأ
   double move1 = MathAbs(avgPrice2 - avgPrice1);
   double move2 = MathAbs(avgPrice3 - avgPrice2);
   bool deceleratingMove = move2 <= move1;
   
   return overallDescending && deceleratingMove;
}

//+------------------------------------------------------------------+
//| حساب قوة التطابق                                                |
//+------------------------------------------------------------------+
double CIdentityPatterns::CalculateIdentityStrength(const double &open[], const double &high[], const double &low[], 
                                                   const double &close[], int startIdx)
{
   double totalSimilarity = 0;
   int comparisons = 0;
   
   // مقارنة كل شمعة مع الأخريات
   for(int i = 0; i < 3; i++)
   {
      for(int j = i + 1; j < 3; j++)
      {
         double body1 = MathAbs(close[startIdx + i] - open[startIdx + i]);
         double body2 = MathAbs(close[startIdx + j] - open[startIdx + j]);
         double range1 = high[startIdx + i] - low[startIdx + i];
         double range2 = high[startIdx + j] - low[startIdx + j];
         
         if(range1 > 0 && range2 > 0)
         {
            double ratio1 = body1 / range1;
            double ratio2 = body2 / range2;
            double similarity = 1.0 - MathAbs(ratio1 - ratio2);
            totalSimilarity += similarity;
            comparisons++;
         }
      }
   }
   
   return (comparisons > 0) ? totalSimilarity / comparisons * 2.0 : 0;
}

//+------------------------------------------------------------------+
//| حساب دقة المطابقة                                               |
//+------------------------------------------------------------------+
double CIdentityPatterns::CalculateMatchingAccuracy(const double level1, const double level2, const double level3)
{
   // حساب متوسط المستويات
   double avgLevel = (level1 + level2 + level3) / 3.0;
   if(avgLevel == 0) return 0;
   
   // حساب الانحراف عن المتوسط
   double deviation1 = MathAbs(level1 - avgLevel) / avgLevel;
   double deviation2 = MathAbs(level2 - avgLevel) / avgLevel;
   double deviation3 = MathAbs(level3 - avgLevel) / avgLevel;
   
   double avgDeviation = (deviation1 + deviation2 + deviation3) / 3.0;
   
   // كلما قل الانحراف، زادت دقة المطابقة
   return MathMax(0, 1.0 - avgDeviation * 10.0); // تضخيم الانحراف للحساسية
}
