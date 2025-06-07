//+------------------------------------------------------------------+
//|                                          ModernAdaptations.mqh |
//|                                    التكيفات الحديثة للأنماط اليابانية |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة التكيفات الحديثة للأنماط اليابانية                          |
//+------------------------------------------------------------------+
class CModernAdaptations : public CPatternDetector
{
private:
   double            m_modernSensitivity;     // حساسية الأنماط الحديثة
   double            m_volumeWeight;          // وزن الحجم في التحليل
   double            m_trendStrength;         // قوة الاتجاه المطلوبة
   double            m_adaptationFactor;      // عامل التكيف
   
public:
   // المنشئ والهادم
                     CModernAdaptations();
                     ~CModernAdaptations();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // التكيفات الحديثة المحددة
   bool              DetectModernMorningStar(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], const long &volume[],
                                           SPatternDetectionResult &result);
                                           
   bool              DetectModernEveningStar(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], const long &volume[],
                                           SPatternDetectionResult &result);
                                           
   bool              DetectModernThreeMethods(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[], const long &volume[],
                                            SPatternDetectionResult &result);
   
   // دوال مساعدة للتكيف الحديث
   bool              IsModernStar(const double open, const double high, const double low, const double close, 
                                const long volume, const long avgVolume);
   bool              HasVolumeConfirmation(const long &volume[], int idx);
   bool              IsInTrendContext(const double &close[], int idx, bool bullishContext);
   double            CalculateModernStrength(const double &open[], const double &high[], const double &low[], 
                                           const double &close[], const long &volume[], int startIdx);
   double            GetVolumeRatio(const long currentVol, const long avgVol);
   bool              HasModernGap(const double high1, const double low1, const double high2, const double low2);
   double            CalculateVolatilityAdjustment(const double &high[], const double &low[], int startIdx);
   bool              IsValidModernContext(const double &close[], int idx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CModernAdaptations::CModernAdaptations()
{
   m_modernSensitivity = 0.8;    // 80% حساسية للأنماط الحديثة
   m_volumeWeight = 0.3;         // 30% وزن الحجم
   m_trendStrength = 0.6;        // 60% قوة اتجاه مطلوبة
   m_adaptationFactor = 1.2;     // 20% عامل تكيف
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CModernAdaptations::~CModernAdaptations()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CModernAdaptations::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع التكيفات الحديثة                                  |
//+------------------------------------------------------------------+
int CModernAdaptations::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف نجمة الصباح الحديثة
   if(DetectModernMorningStar(idx, open, high, low, close, volume, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف نجمة المساء الحديثة
   if(DetectModernEveningStar(idx, open, high, low, close, volume, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف الطرق الثلاث الحديثة
   if(DetectModernThreeMethods(idx, open, high, low, close, volume, result))
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
//| كشف نجمة الصباح الحديثة (Modern Morning Star)                   |
//+------------------------------------------------------------------+
bool CModernAdaptations::DetectModernMorningStar(const int idx, const double &open[], const double &high[], 
                                                const double &low[], const double &close[], const long &volume[],
                                                SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من السياق الحديث
   if(!IsValidModernContext(close, idx)) return false;
   
   // الشمعة الأولى: هبوطية في سياق اتجاه هبوطي
   bool firstBearish = close[idx-2] < open[idx-2];
   bool inDowntrend = IsInTrendContext(close, idx-2, false);
   
   if(!firstBearish || !inDowntrend) return false;
   
   // الشمعة الثانية: نجمة حديثة (تأخذ الحجم في الاعتبار)
   long avgVolume = (volume[idx-2] + volume[idx-1] + volume[idx]) / 3;
   bool isModernStar = IsModernStar(open[idx-1], high[idx-1], low[idx-1], close[idx-1], 
                                   volume[idx-1], avgVolume);
   
   if(!isModernStar) return false;
   
   // فجوة حديثة (أقل صرامة من التقليدية)
   bool hasModernGap = HasModernGap(high[idx-2], low[idx-2], high[idx-1], low[idx-1]);
   
   // الشمعة الثالثة: صعودية مع تأكيد الحجم
   bool thirdBullish = close[idx] > open[idx];
   bool volumeConfirmation = HasVolumeConfirmation(volume, idx);
   
   if(!thirdBullish) return false;
   
   // التحقق من قوة الانعكاس الحديثة
   bool strongReversal = close[idx] > (high[idx-1] + low[idx-1]) / 2.0; // يتجاوز منتصف النجمة
   
   // تعديل الحجم والتقلبات
   double volatilityAdj = CalculateVolatilityAdjustment(high, low, idx-2);
   double modernStrength = CalculateModernStrength(open, high, low, close, volume, idx-2);
   
   // حساب الموثوقية الحديثة
   double baseReliability = 0.70;
   if(hasModernGap) baseReliability += 0.05;
   if(volumeConfirmation) baseReliability += 0.10;
   if(strongReversal) baseReliability += 0.05;
   
   // تطبيق عامل التكيف
   modernStrength *= m_adaptationFactor;
   baseReliability = MathMin(baseReliability * m_adaptationFactor, 1.0);
   
   result.patternName = "Modern Morning Star";
   result.strength = modernStrength * volatilityAdj;
   result.reliability = baseReliability;
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف نجمة المساء الحديثة (Modern Evening Star)                   |
//+------------------------------------------------------------------+
bool CModernAdaptations::DetectModernEveningStar(const int idx, const double &open[], const double &high[], 
                                                const double &low[], const double &close[], const long &volume[],
                                                SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من السياق الحديث
   if(!IsValidModernContext(close, idx)) return false;
   
   // الشمعة الأولى: صعودية في سياق اتجاه صعودي
   bool firstBullish = close[idx-2] > open[idx-2];
   bool inUptrend = IsInTrendContext(close, idx-2, true);
   
   if(!firstBullish || !inUptrend) return false;
   
   // الشمعة الثانية: نجمة حديثة مع تحليل الحجم
   long avgVolume = (volume[idx-2] + volume[idx-1] + volume[idx]) / 3;
   bool isModernStar = IsModernStar(open[idx-1], high[idx-1], low[idx-1], close[idx-1], 
                                   volume[idx-1], avgVolume);
   
   if(!isModernStar) return false;
   
   // فجوة حديثة
   bool hasModernGap = HasModernGap(high[idx-2], low[idx-2], high[idx-1], low[idx-1]);
   
   // الشمعة الثالثة: هبوطية مع تأكيد الحجم
   bool thirdBearish = close[idx] < open[idx];
   bool volumeConfirmation = HasVolumeConfirmation(volume, idx);
   
   if(!thirdBearish) return false;
   
   // التحقق من قوة الانعكاس الحديثة
   bool strongReversal = close[idx] < (high[idx-1] + low[idx-1]) / 2.0; // يكسر منتصف النجمة
   
   // تعديل الحجم والتقلبات
   double volatilityAdj = CalculateVolatilityAdjustment(high, low, idx-2);
   double modernStrength = CalculateModernStrength(open, high, low, close, volume, idx-2);
   
   // حساب الموثوقية الحديثة
   double baseReliability = 0.70;
   if(hasModernGap) baseReliability += 0.05;
   if(volumeConfirmation) baseReliability += 0.10;
   if(strongReversal) baseReliability += 0.05;
   
   // تطبيق عامل التكيف
   modernStrength *= m_adaptationFactor;
   baseReliability = MathMin(baseReliability * m_adaptationFactor, 1.0);
   
   result.patternName = "Modern Evening Star";
   result.strength = modernStrength * volatilityAdj;
   result.reliability = baseReliability;
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف الطرق الثلاث الحديثة (Modern Three Methods)                 |
//+------------------------------------------------------------------+
bool CModernAdaptations::DetectModernThreeMethods(const int idx, const double &open[], const double &high[], 
                                                 const double &low[], const double &close[], const long &volume[],
                                                 SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من السياق الحديث
   if(!IsValidModernContext(close, idx)) return false;
   
   // تحليل الأنماط الحديثة للطرق الثلاث
   bool modernRisingMethods = false;
   bool modernFallingMethods = false;
   
   // الطرق الصاعدة الحديثة
   if((close[idx-2] > open[idx-2]) && // أولى صعودية قوية
      (close[idx] > open[idx]) &&     // ثالثة صعودية قوية
      (close[idx] > close[idx-2]))    // تجاوز الأولى
   {
      // التراجع الحديث (أكثر مرونة)
      bool modernRetracement = (close[idx-1] <= close[idx-2]) && // لا يتجاوز الأولى
                              (low[idx-1] >= low[idx-2] * 0.98); // لا يكسر الدعم بقوة
      
      if(modernRetracement)
         modernRisingMethods = true;
   }
   
   // الطرق الهابطة الحديثة
   if((close[idx-2] < open[idx-2]) && // أولى هبوطية قوية
      (close[idx] < open[idx]) &&     // ثالثة هبوطية قوية
      (close[idx] < close[idx-2]))    // تجاوز الأولى
   {
      // التراجع الحديث
      bool modernRetracement = (close[idx-1] >= close[idx-2]) && // لا يتجاوز الأولى
                              (high[idx-1] <= high[idx-2] * 1.02); // لا يكسر المقاومة بقوة
      
      if(modernRetracement)
         modernFallingMethods = true;
   }
   
   if(!modernRisingMethods && !modernFallingMethods) return false;
   
   // تأكيد الحجم الحديث
   bool modernVolumePattern = false;
   
   // نمط الحجم: قوي في الأولى والثالثة، ضعيف في الثانية
   if(volume[idx-2] > 0 && volume[idx-1] > 0 && volume[idx] > 0)
   {
      long avgFirstThird = (volume[idx-2] + volume[idx]) / 2;
      modernVolumePattern = volume[idx-1] <= avgFirstThird * 0.8; // الوسطى أقل بـ 20%
   }
   
   // حساب القوة الحديثة
   double modernStrength = CalculateModernStrength(open, high, low, close, volume, idx-2);
   
   // تعديل التقلبات
   double volatilityAdj = CalculateVolatilityAdjustment(high, low, idx-2);
   
   // حساب الموثوقية مع عوامل حديثة
   double baseReliability = 0.65;
   if(modernVolumePattern) baseReliability += 0.10;
   
   // تطبيق عامل التكيف الحديث
   modernStrength *= m_adaptationFactor;
   baseReliability = MathMin(baseReliability * m_adaptationFactor, 1.0);
   
   result.patternName = modernRisingMethods ? "Modern Rising Three Methods" : "Modern Falling Three Methods";
   result.strength = modernStrength * volatilityAdj;
   result.reliability = baseReliability;
   result.direction = modernRisingMethods ? PATTERN_BULLISH : PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من النجمة الحديثة                                         |
//+------------------------------------------------------------------+
bool CModernAdaptations::IsModernStar(const double open, const double high, const double low, const double close, 
                                     const long volume, const long avgVolume)
{
   double bodySize = MathAbs(close - open);
   double range = high - low;
   
   if(range == 0) return false;
   
   // نجمة حديثة: جسم صغير نسبياً (أكثر مرونة من التقليدية)
   bool smallBody = (bodySize / range) <= 0.4; // 40% بدلاً من 30%
   
   // تحليل الحجم الحديث
   bool volumeOk = true;
   if(avgVolume > 0)
   {
      double volumeRatio = GetVolumeRatio(volume, avgVolume);
      // النجمة الحديثة قد تكون بحجم منخفض (تردد) أو عالي (اهتمام)
      volumeOk = (volumeRatio >= 0.5) && (volumeRatio <= 2.0);
   }
   
   return smallBody && volumeOk;
}

//+------------------------------------------------------------------+
//| التحقق من تأكيد الحجم                                           |
//+------------------------------------------------------------------+
bool CModernAdaptations::HasVolumeConfirmation(const long &volume[], int idx)
{
   if(idx < 1) return false;
   
   // تأكيد الحجم الحديث: زيادة في حجم الشمعة الأخيرة
   if(volume[idx-1] <= 0) return true; // إذا لم يكن هناك بيانات حجم
   
   double volumeIncrease = (double)volume[idx] / (double)volume[idx-1];
   return volumeIncrease >= (1.0 + m_volumeWeight); // زيادة بنسبة وزن الحجم
}

//+------------------------------------------------------------------+
//| التحقق من سياق الاتجاه                                          |
//+------------------------------------------------------------------+
bool CModernAdaptations::IsInTrendContext(const double &close[], int idx, bool bullishContext)
{
   if(idx < 1) return false;
   
   // تحليل الاتجاه الحديث (أكثر مرونة)
   double recentMove = close[idx] - close[idx-1];
   double avgPrice = (close[idx] + close[idx-1]) / 2.0;
   
   if(avgPrice == 0) return false;
   
   double movePercent = MathAbs(recentMove) / avgPrice;
   
   if(bullishContext)
   {
      return (recentMove > 0) && (movePercent >= 0.005); // 0.5% حركة صعودية
   }
   else
   {
      return (recentMove < 0) && (movePercent >= 0.005); // 0.5% حركة هبوطية
   }
}

//+------------------------------------------------------------------+
//| حساب القوة الحديثة                                              |
//+------------------------------------------------------------------+
double CModernAdaptations::CalculateModernStrength(const double &open[], const double &high[], const double &low[], 
                                                  const double &close[], const long &volume[], int startIdx)
{
   double priceStrength = 0;
   double volumeStrength = 0;
   
   // حساب قوة السعر
   for(int i = 0; i < 3; i++)
   {
      double bodySize = MathAbs(close[startIdx + i] - open[startIdx + i]);
      double range = high[startIdx + i] - low[startIdx + i];
      
      if(range > 0)
         priceStrength += bodySize / range;
   }
   
   priceStrength /= 3.0; // متوسط القوة
   
   // حساب قوة الحجم (إذا كان متوفراً)
   if(volume[startIdx] > 0 && volume[startIdx+1] > 0 && volume[startIdx+2] > 0)
   {
      long totalVolume = volume[startIdx] + volume[startIdx+1] + volume[startIdx+2];
      long avgVolume = totalVolume / 3;
      
      // قوة الحجم تعتمد على التوزيع
      for(int i = 0; i < 3; i++)
      {
         if(avgVolume > 0)
            volumeStrength += GetVolumeRatio(volume[startIdx + i], avgVolume);
      }
      
      volumeStrength /= 3.0;
   }
   else
   {
      volumeStrength = 1.0; // افتراضي إذا لم يكن الحجم متوفراً
   }
   
   // دمج قوة السعر والحجم
   double combinedStrength = priceStrength * (1.0 - m_volumeWeight) + volumeStrength * m_volumeWeight;
   
   return combinedStrength * 2.0; // تضخيم للحصول على قيمة مناسبة
}

//+------------------------------------------------------------------+
//| حساب نسبة الحجم                                                 |
//+------------------------------------------------------------------+
double CModernAdaptations::GetVolumeRatio(const long currentVol, const long avgVol)
{
   if(avgVol <= 0) return 1.0;
   
   return (double)currentVol / (double)avgVol;
}

//+------------------------------------------------------------------+
//| التحقق من الفجوة الحديثة                                        |
//+------------------------------------------------------------------+
bool CModernAdaptations::HasModernGap(const double high1, const double low1, const double high2, const double low2)
{
   // فجوة حديثة: أكثر مرونة من التقليدية
   double minGapSize = 0.0005; // 0.05% حد أدنى
   
   // فجوة صعودية
   if(low2 > high1)
   {
      double gapSize = (low2 - high1) / high1;
      return gapSize >= minGapSize;
   }
   
   // فجوة هبوطية
   if(high2 < low1)
   {
      double gapSize = (low1 - high2) / low1;
      return gapSize >= minGapSize;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| حساب تعديل التقلبات                                             |
//+------------------------------------------------------------------+
double CModernAdaptations::CalculateVolatilityAdjustment(const double &high[], const double &low[], int startIdx)
{
   double totalVolatility = 0;
   
   for(int i = 0; i < 3; i++)
   {
      double range = high[startIdx + i] - low[startIdx + i];
      double midPrice = (high[startIdx + i] + low[startIdx + i]) / 2.0;
      
      if(midPrice > 0)
         totalVolatility += range / midPrice;
   }
   
   double avgVolatility = totalVolatility / 3.0;
   
   // تعديل بناء على التقلبات: تقلبات عالية = قوة أقل، تقلبات منخفضة = قوة أعلى
   return MathMax(0.5, MathMin(2.0, 1.0 / (1.0 + avgVolatility * 10)));
}

//+------------------------------------------------------------------+
//| التحقق من صحة السياق الحديث                                     |
//+------------------------------------------------------------------+
bool CModernAdaptations::IsValidModernContext(const double &close[], int idx)
{
   if(idx < 2) return false;
   
   // السياق الحديث: يجب أن تكون هناك حركة سعرية معقولة
   double totalMove = MathAbs(close[idx] - close[idx-2]);
   double avgPrice = (close[idx] + close[idx-2]) / 2.0;
   
   if(avgPrice == 0) return false;
   
   double movePercent = totalMove / avgPrice;
   
   // حركة بين 0.1% و 10% (تجنب الأسواق الراكدة والمتقلبة جداً)
   return (movePercent >= 0.001) && (movePercent <= 0.10);
}
