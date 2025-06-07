//+------------------------------------------------------------------+
//|                                          BreakawayPatterns.mqh |
//|                                          أنماط الانفصال        |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الانفصال                                              |
//+------------------------------------------------------------------+
class CBreakawayPatterns : public CPatternDetector
{
private:
   double            m_gapThreshold;          // حد الفجوة
   double            m_volumeMultiplier;      // مضاعف الحجم
   double            m_breakawayStrength;     // قوة الانفصال
   
public:
   // المنشئ والهادم
                     CBreakawayPatterns();
                     ~CBreakawayPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط الانفصال المحددة
   bool              DetectBullishBreakaway(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], const long &volume[],
                                          SPatternDetectionResult &result);
                                          
   bool              DetectBearishBreakaway(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], const long &volume[],
                                          SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              HasBreakawayGap(const double high1, const double low1, const double high2, const double low2, bool bullish);
   bool              IsVolumeExpansion(const long vol1, const long vol2, const long vol3);
   bool              IsValidBreakawaySequence(const double &open[], const double &close[], int startIdx, bool bullish);
   double            CalculateGapSize(const double price1, const double price2);
   double            CalculateBreakawayMomentum(const double &open[], const double &close[], 
                                              const long &volume[], int startIdx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CBreakawayPatterns::CBreakawayPatterns()
{
   m_gapThreshold = 0.002;       // 0.2% حد أدنى للفجوة
   m_volumeMultiplier = 1.2;     // 20% زيادة في الحجم
   m_breakawayStrength = 1.5;    // قوة الانفصال
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CBreakawayPatterns::~CBreakawayPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CBreakawayPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط الانفصال                                   |
//+------------------------------------------------------------------+
int CBreakawayPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف الانفصال الصعودي
   if(DetectBullishBreakaway(idx, open, high, low, close, volume, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف الانفصال الهبوطي
   if(DetectBearishBreakaway(idx, open, high, low, close, volume, result))
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
//| كشف الانفصال الصعودي (Bullish Breakaway)                        |
//+------------------------------------------------------------------+
bool CBreakawayPatterns::DetectBullishBreakaway(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], const long &volume[],
                                               SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: هبوطية قوية
   bool firstBearish = close[idx-2] < open[idx-2];
   double firstBody = MathAbs(close[idx-2] - open[idx-2]);
   double firstRange = high[idx-2] - low[idx-2];
   bool firstStrong = (firstRange > 0) && (firstBody / firstRange > 0.6);
   
   if(!firstBearish || !firstStrong) return false;
   
   // الشمعة الثانية: فجوة هبوطية مع استمرار الضعف
   bool hasGapDown = HasBreakawayGap(high[idx-2], low[idx-2], high[idx-1], low[idx-1], false);
   if(!hasGapDown) return false;
   
   bool secondWeakness = close[idx-1] <= close[idx-2]; // استمرار الضعف أو ثبات
   if(!secondWeakness) return false;
   
   // الشمعة الثالثة: انعكاس قوي صعودي مع حجم عالي
   bool thirdBullish = close[idx] > open[idx];
   bool strongReversal = close[idx] > high[idx-1]; // تجاوز أعلى الشمعة السابقة
   bool volumeConfirmation = IsVolumeExpansion(volume[idx-2], volume[idx-1], volume[idx]);
   
   if(!thirdBullish || !strongReversal) return false;
   
   // التحقق من تسلسل الانفصال الصحيح
   if(!IsValidBreakawaySequence(open, close, idx-2, true)) return false;
   
   // حساب قوة النمط
   double gapSize = CalculateGapSize(low[idx-2], high[idx-1]);
   double momentum = CalculateBreakawayMomentum(open, close, volume, idx-2);
   
   result.patternName = "Bullish Breakaway";
   result.strength = momentum;
   result.reliability = 0.75;
   
   if(volumeConfirmation) result.reliability += 0.1; // مكافأة للحجم
   if(gapSize > m_gapThreshold * 2) result.reliability += 0.05; // مكافأة للفجوة الكبيرة
   
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف الانفصال الهبوطي (Bearish Breakaway)                        |
//+------------------------------------------------------------------+
bool CBreakawayPatterns::DetectBearishBreakaway(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], const long &volume[],
                                               SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعة الأولى: صعودية قوية
   bool firstBullish = close[idx-2] > open[idx-2];
   double firstBody = MathAbs(close[idx-2] - open[idx-2]);
   double firstRange = high[idx-2] - low[idx-2];
   bool firstStrong = (firstRange > 0) && (firstBody / firstRange > 0.6);
   
   if(!firstBullish || !firstStrong) return false;
   
   // الشمعة الثانية: فجوة صعودية مع استمرار القوة
   bool hasGapUp = HasBreakawayGap(high[idx-2], low[idx-2], high[idx-1], low[idx-1], true);
   if(!hasGapUp) return false;
   
   bool secondStrength = close[idx-1] >= close[idx-2]; // استمرار القوة أو ثبات
   if(!secondStrength) return false;
   
   // الشمعة الثالثة: انعكاس قوي هبوطي مع حجم عالي
   bool thirdBearish = close[idx] < open[idx];
   bool strongReversal = close[idx] < low[idx-1]; // تجاوز أدنى الشمعة السابقة
   bool volumeConfirmation = IsVolumeExpansion(volume[idx-2], volume[idx-1], volume[idx]);
   
   if(!thirdBearish || !strongReversal) return false;
   
   // التحقق من تسلسل الانفصال الصحيح
   if(!IsValidBreakawaySequence(open, close, idx-2, false)) return false;
   
   // حساب قوة النمط
   double gapSize = CalculateGapSize(high[idx-2], low[idx-1]);
   double momentum = CalculateBreakawayMomentum(open, close, volume, idx-2);
   
   result.patternName = "Bearish Breakaway";
   result.strength = momentum;
   result.reliability = 0.75;
   
   if(volumeConfirmation) result.reliability += 0.1; // مكافأة للحجم
   if(gapSize > m_gapThreshold * 2) result.reliability += 0.05; // مكافأة للفجوة الكبيرة
   
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من فجوة الانفصال                                         |
//+------------------------------------------------------------------+
bool CBreakawayPatterns::HasBreakawayGap(const double high1, const double low1, const double high2, const double low2, bool bullish)
{
   if(bullish)
   {
      // فجوة صعودية: أدنى الثانية أعلى من أعلى الأولى
      double gapSize = low2 - high1;
      return gapSize > 0 && (gapSize / high1 >= m_gapThreshold);
   }
   else
   {
      // فجوة هبوطية: أعلى الثانية أقل من أدنى الأولى
      double gapSize = low1 - high2;
      return gapSize > 0 && (gapSize / low1 >= m_gapThreshold);
   }
}

//+------------------------------------------------------------------+
//| التحقق من توسع الحجم                                            |
//+------------------------------------------------------------------+
bool CBreakawayPatterns::IsVolumeExpansion(const long vol1, const long vol2, const long vol3)
{
   // التحقق من زيادة الحجم في الشمعة الأخيرة
   if(vol1 <= 0 || vol2 <= 0) return false;
   
   double avgVolume = (vol1 + vol2) / 2.0;
   return vol3 >= avgVolume * m_volumeMultiplier;
}

//+------------------------------------------------------------------+
//| التحقق من تسلسل الانفصال الصحيح                                |
//+------------------------------------------------------------------+
bool CBreakawayPatterns::IsValidBreakawaySequence(const double &open[], const double &close[], int startIdx, bool bullish)
{
   if(bullish)
   {
      // للنمط الصعودي: هبوط ثم انعكاس
      return (close[startIdx] < open[startIdx]) &&     // أولى هبوطية
             (close[startIdx+1] <= close[startIdx]) &&  // ثانية ضعيفة
             (close[startIdx+2] > open[startIdx+2]);    // ثالثة صعودية قوية
   }
   else
   {
      // للنمط الهبوطي: صعود ثم انعكاس
      return (close[startIdx] > open[startIdx]) &&     // أولى صعودية
             (close[startIdx+1] >= close[startIdx]) &&  // ثانية قوية
             (close[startIdx+2] < open[startIdx+2]);    // ثالثة هبوطية قوية
   }
}

//+------------------------------------------------------------------+
//| حساب حجم الفجوة                                                 |
//+------------------------------------------------------------------+
double CBreakawayPatterns::CalculateGapSize(const double price1, const double price2)
{
   if(price1 == 0) return 0;
   return MathAbs(price2 - price1) / price1;
}

//+------------------------------------------------------------------+
//| حساب زخم الانفصال                                               |
//+------------------------------------------------------------------+
double CBreakawayPatterns::CalculateBreakawayMomentum(const double &open[], const double &close[], 
                                                     const long &volume[], int startIdx)
{
   // حساب الحركة الإجمالية
   double totalMove = 0;
   long totalVolume = 0;
   
   for(int i = 0; i < 3; i++)
   {
      totalMove += MathAbs(close[startIdx + i] - open[startIdx + i]);
      totalVolume += volume[startIdx + i];
   }
   
   double avgMove = totalMove / 3.0;
   double avgVolume = (double)totalVolume / 3.0;
   
   // الزخم يتناسب مع الحركة والحجم
   double momentum = avgMove;
   if(avgVolume > 0 && volume[startIdx + 2] > avgVolume * m_volumeMultiplier)
      momentum *= 1.5; // مكافأة للحجم العالي في الشمعة الأخيرة
   
   return MathMin(momentum * 100, 3.0);
}
