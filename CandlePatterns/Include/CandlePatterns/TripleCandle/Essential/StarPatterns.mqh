//+------------------------------------------------------------------+
//|                                              StarPatterns.mqh   |
//|                                          أنماط النجوم الثلاثية   |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط النجوم الثلاثية                                       |
//+------------------------------------------------------------------+
class CStarPatterns : public CPatternDetector
{
private:
   double            m_starBodyThreshold;     // حد جسم النجمة
   double            m_gapThreshold;          // حد الفجوة
   
public:
   // المنشئ والهادم
                     CStarPatterns();
                     ~CStarPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط النجوم المحددة
   bool              DetectMorningStar(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[], 
                                     SPatternDetectionResult &result);
                                     
   bool              DetectEveningStar(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[], 
                                     SPatternDetectionResult &result);
                                     
   bool              DetectDojiStar(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], 
                                  SPatternDetectionResult &result);
                                  
   bool              DetectAbandonedBaby(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsStarCandle(const double open, const double high, const double low, const double close);
   bool              HasGap(const double high1, const double low1, const double high2, const double low2);
   double            CalculateBodySize(const double open, const double close);
   double            CalculateRealBody(const double open, const double close);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CStarPatterns::CStarPatterns()
{
   m_starBodyThreshold = 0.1;    // 10% من متوسط حجم الجسم
   m_gapThreshold = 0.001;       // حد أدنى للفجوة
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CStarPatterns::~CStarPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CStarPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط النجوم                                     |
//+------------------------------------------------------------------+
int CStarPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], const double &low[], 
                                    const double &close[], const long &volume[], 
                                    SPatternDetectionResult &results[])
{
   if(idx < 2 || !ValidateData(open, high, low, close, volume, idx))
      return 0;
      
   SPatternDetectionResult tempResults[];
   ArrayResize(tempResults, 4); // أربعة أنماط نجوم محتملة
   int found = 0;
   
   SPatternDetectionResult result;
   
   // كشف نجمة الصباح
   if(DetectMorningStar(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف نجمة المساء
   if(DetectEveningStar(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف نجمة الدوجي
   if(DetectDojiStar(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف الطفل المهجور
   if(DetectAbandonedBaby(idx, open, high, low, close, result))
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
//| كشف نجمة الصباح (Morning Star)                                  |
//+------------------------------------------------------------------+
bool CStarPatterns::DetectMorningStar(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[], 
                                     SPatternDetectionResult &result)
{
   // التحقق من وجود ثلاث شموع
   if(idx < 2) return false;
   
   // الشمعة الأولى: هبوطية قوية
   bool firstBearish = close[idx-2] < open[idx-2];
   double firstBodySize = MathAbs(close[idx-2] - open[idx-2]);
   
   // الشمعة الثانية: نجمة (جسم صغير)
   bool isStarMiddle = IsStarCandle(open[idx-1], high[idx-1], low[idx-1], close[idx-1]);
   bool gapDown = low[idx-1] < close[idx-2];
   
   // الشمعة الثالثة: صعودية قوية
   bool thirdBullish = close[idx] > open[idx];
   double thirdBodySize = MathAbs(close[idx] - open[idx]);
   bool gapUp = open[idx] > high[idx-1];
   
   // التحقق من شروط النمط
   if(firstBearish && isStarMiddle && thirdBullish && gapDown)
   {
      // حساب القوة والموثوقية
      double strength = (firstBodySize + thirdBodySize) / 2.0;
      double reliability = 0.75;
      
      if(gapUp) reliability += 0.15; // مكافأة للفجوة الصعودية
      
      result.patternName = "Morning Star";
      result.strength = MathMin(strength * 100, 3.0);
      result.reliability = MathMin(reliability, 1.0);
      result.direction = PATTERN_BULLISH;
      result.type = PATTERN_TRIPLE;
      result.confidence = (strength + reliability) / 2.0;
      
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف نجمة المساء (Evening Star)                                  |
//+------------------------------------------------------------------+
bool CStarPatterns::DetectEveningStar(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[], 
                                     SPatternDetectionResult &result)
{
   // التحقق من وجود ثلاث شموع
   if(idx < 2) return false;
   
   // الشمعة الأولى: صعودية قوية
   bool firstBullish = close[idx-2] > open[idx-2];
   double firstBodySize = MathAbs(close[idx-2] - open[idx-2]);
   
   // الشمعة الثانية: نجمة (جسم صغير)
   bool isStarMiddle = IsStarCandle(open[idx-1], high[idx-1], low[idx-1], close[idx-1]);
   bool gapUp = low[idx-1] > close[idx-2];
   
   // الشمعة الثالثة: هبوطية قوية
   bool thirdBearish = close[idx] < open[idx];
   double thirdBodySize = MathAbs(close[idx] - open[idx]);
   bool gapDown = open[idx] < low[idx-1];
   
   // التحقق من شروط النمط
   if(firstBullish && isStarMiddle && thirdBearish && gapUp)
   {
      // حساب القوة والموثوقية
      double strength = (firstBodySize + thirdBodySize) / 2.0;
      double reliability = 0.75;
      
      if(gapDown) reliability += 0.15; // مكافأة للفجوة الهبوطية
      
      result.patternName = "Evening Star";
      result.strength = MathMin(strength * 100, 3.0);
      result.reliability = MathMin(reliability, 1.0);
      result.direction = PATTERN_BEARISH;
      result.type = PATTERN_TRIPLE;
      result.confidence = (strength + reliability) / 2.0;
      
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف نجمة الدوجي (Doji Star)                                     |
//+------------------------------------------------------------------+
bool CStarPatterns::DetectDojiStar(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], 
                                  SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الوسطى يجب أن تكون دوجي
   double middleBodySize = MathAbs(close[idx-1] - open[idx-1]);
   double middleRange = high[idx-1] - low[idx-1];
   bool isDoji = middleBodySize <= (middleRange * 0.1); // جسم أقل من 10% من المدى
   
   if(!isDoji) return false;
   
   // تحديد الاتجاه بناء على الشموع المحيطة
   bool firstBullish = close[idx-2] > open[idx-2];
   bool thirdBearish = close[idx] < open[idx];
   bool firstBearish = close[idx-2] < open[idx-2];
   bool thirdBullish = close[idx] > open[idx];
   
   // نمط انعكاس صعودي
   if(firstBearish && thirdBullish)
   {
      result.patternName = "Doji Star Bullish";
      result.direction = PATTERN_BULLISH;
      result.reliability = 0.65;
   }
   // نمط انعكاس هبوطي
   else if(firstBullish && thirdBearish)
   {
      result.patternName = "Doji Star Bearish";
      result.direction = PATTERN_BEARISH;
      result.reliability = 0.65;
   }
   else
   {
      result.patternName = "Doji Star Neutral";
      result.direction = PATTERN_NEUTRAL;
      result.reliability = 0.45;
   }
   
   result.strength = 1.5;
   result.type = PATTERN_TRIPLE;
   result.confidence = result.reliability;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف الطفل المهجور (Abandoned Baby)                              |
//+------------------------------------------------------------------+
bool CStarPatterns::DetectAbandonedBaby(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الوسطى يجب أن تكون دوجي مع فجوات على الجانبين
   double middleBodySize = MathAbs(close[idx-1] - open[idx-1]);
   double middleRange = high[idx-1] - low[idx-1];
   bool isDoji = middleBodySize <= (middleRange * 0.05); // جسم أقل من 5%
   
   if(!isDoji) return false;
   
   // التحقق من الفجوات
   bool gapBeforeDoji = HasGap(high[idx-2], low[idx-2], high[idx-1], low[idx-1]);
   bool gapAfterDoji = HasGap(high[idx-1], low[idx-1], high[idx], low[idx]);
   
   if(!gapBeforeDoji || !gapAfterDoji) return false;
   
   // تحديد الاتجاه
   bool firstBearish = close[idx-2] < open[idx-2];
   bool thirdBullish = close[idx] > open[idx];
   bool firstBullish = close[idx-2] > open[idx-2];
   bool thirdBearish = close[idx] < open[idx];
   
   if(firstBearish && thirdBullish)
   {
      result.patternName = "Abandoned Baby Bullish";
      result.direction = PATTERN_BULLISH;
      result.reliability = 0.85;
   }
   else if(firstBullish && thirdBearish)
   {
      result.patternName = "Abandoned Baby Bearish";
      result.direction = PATTERN_BEARISH;
      result.reliability = 0.85;
   }
   else
   {
      return false; // لا يوجد نمط صحيح
   }
   
   result.strength = 2.5;
   result.type = PATTERN_TRIPLE;
   result.confidence = result.reliability;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من كون الشمعة نجمة                                       |
//+------------------------------------------------------------------+
bool CStarPatterns::IsStarCandle(const double open, const double high, const double low, const double close)
{
   double bodySize = MathAbs(close - open);
   double range = high - low;
   
   if(range == 0) return false;
   
   // الجسم يجب أن يكون صغير نسبياً (أقل من 30% من المدى)
   return (bodySize <= range * 0.3);
}

//+------------------------------------------------------------------+
//| التحقق من وجود فجوة                                             |
//+------------------------------------------------------------------+
bool CStarPatterns::HasGap(const double high1, const double low1, const double high2, const double low2)
{
   // فجوة صعودية: أدنى الشمعة الثانية أعلى من أعلى الأولى
   if(low2 > high1 + m_gapThreshold) return true;
   
   // فجوة هبوطية: أعلى الشمعة الثانية أقل من أدنى الأولى
   if(high2 < low1 - m_gapThreshold) return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| حساب حجم الجسم                                                  |
//+------------------------------------------------------------------+
double CStarPatterns::CalculateBodySize(const double open, const double close)
{
   return MathAbs(close - open);
}

//+------------------------------------------------------------------+
//| حساب الجسم الحقيقي                                              |
//+------------------------------------------------------------------+
double CStarPatterns::CalculateRealBody(const double open, const double close)
{
   return close - open; // موجب للصعودي، سالب للهبوطي
}
