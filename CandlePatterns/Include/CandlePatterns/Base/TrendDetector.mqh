//+------------------------------------------------------------------+
//|                                           TrendDetector.mqh      |
//|                        حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//|                                       https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "CandleUtils.mqh"

// تعداد لأنواع الاتجاهات
enum ENUM_TREND_TYPE
{
   TREND_BULLISH,    // اتجاه صعودي
   TREND_BEARISH,    // اتجاه هبوطي
   TREND_NEUTRAL     // اتجاه محايد
};

// تعداد لأنواع خوارزميات تحديد الاتجاه
enum ENUM_TREND_ALGORITHM
{
   TREND_ALGO_SINGLE_CANDLE,  // قوة الشمعة المفردة
   TREND_ALGO_HH_LL,          // قمم وقيعان متعاقبة
   TREND_ALGO_ENGULFING,      // مضاعف الابتلاع
   TREND_ALGO_RUN_LENGTH,     // قوة التتابع
   TREND_ALGO_HEIKIN_ASHI,    // شموع هيكين-آشي الداخلية
   TREND_ALGO_COMPOSITE,      // نظام النقاط المركبة
   TREND_ALGO_BODY_STD,       // الانحراف المعياري لجسم الشمعة
   TREND_ALGO_SIDEWAYS,       // حالة سوق حيادية
   TREND_ALGO_ALL             // جميع الخوارزميات
};

// فئة لتحديد الاتجاه باستخدام الشموع
class CTrendDetector
{
private:
   // معلمات عامة
   int m_period;                    // فترة التحليل
   ENUM_TREND_ALGORITHM m_algorithm; // الخوارزمية المستخدمة
   double m_trendStrength;          // قوة الاتجاه (0-10)
   
   // معلمات خوارزمية قوة الشمعة المفردة
   int m_windowStrong;              // عدد الشموع للتحليل
   double m_strengthRatio;          // نسبة قوة الشمعة
   
   // معلمات خوارزمية قمم وقيعان متعاقبة
   int m_hhllPeriod;                // فترة تحليل القمم والقيعان
   
   // معلمات خوارزمية مضاعف الابتلاع
   int m_engulfingPeriod;           // فترة تحليل الابتلاع
   
   // معلمات خوارزمية قوة التتابع
   double m_runDecayFactor;         // عامل اضمحلال التتابع
   double m_runThreshold;           // عتبة قوة التتابع
   
   // معلمات خوارزمية هيكين-آشي
   int m_haConsecutive;             // عدد الشموع المتتالية
   
   // معلمات خوارزمية النقاط المركبة
   double m_compositeWeights[8];    // أوزان النقاط المركبة
   double m_minCompositeScore;      // الحد الأدنى للنقاط
   
   // معلمات خوارزمية الانحراف المعياري
   int m_stdPeriod;                 // فترة حساب الانحراف المعياري
   double m_stdFactor;              // عامل الانحراف المعياري
   
   // معلمات خوارزمية حالة السوق الحيادية
   double m_mixRatio;               // نسبة الشموع المختلطة
   int m_sidewaysPeriod;            // فترة تحليل الحيادية
   
   // متغيرات داخلية
   double m_score;                  // النتيجة الحالية
   int m_consecutiveDir;            // اتجاه الشموع المتتالية
   double m_haOpen[];               // فتح هيكين-آشي
   double m_haClose[];              // إغلاق هيكين-آشي
   double m_haHigh[];               // أعلى هيكين-آشي
   double m_haLow[];                // أدنى هيكين-آشي
   double m_runScore;               // نتيجة خوارزمية قوة التتابع المتراكمة

   // مؤشرات للمتوسطات المتحركة (للتحسين المقترح)
   double m_maFast;                 // المتوسط المتحرك السريع
   double m_maSlow;                 // المتوسط المتحرك البطيء
   int m_maFastPeriod;              // فترة المتوسط المتحرك السريع
   int m_maSlowPeriod;              // فترة المتوسط المتحرك البطيء

   // دوال خاصة لكل خوارزمية
   ENUM_TREND_TYPE SingleCandleStrength(const double &open[], const double &high[], 
                                      const double &low[], const double &close[], const long &volume[],
                                      const int rates_total, const int bar_index);
                                      
   ENUM_TREND_TYPE HHLLBreak(const double &open[], const double &high[], 
                           const double &low[], const double &close[], const long &volume[],
                           const int rates_total, const int bar_index);
                           
   ENUM_TREND_TYPE EngulfingScore(const double &open[], const double &high[], 
                                const double &low[], const double &close[], const long &volume[],
                                const int rates_total, const int bar_index);
                                
   ENUM_TREND_TYPE RunLengthScoring(const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[],
                                  const int rates_total, const int bar_index);
                                  
   ENUM_TREND_TYPE HeikinAshiInternal(const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[],
                                    const int rates_total, const int bar_index);
                                    
   ENUM_TREND_TYPE CompositeScore(const double &open[], const double &high[], 
                                const double &low[], const double &close[], const long &volume[],
                                const int rates_total, const int bar_index);
                                
   ENUM_TREND_TYPE BodySTDFilter(const double &open[], const double &high[], 
                               const double &low[], const double &close[], const long &volume[],
                               const int rates_total, const int bar_index);
                               
   ENUM_TREND_TYPE SidewaysDetection(const double &open[], const double &high[], 
                                   const double &low[], const double &close[], const long &volume[],
                                   const int rates_total, const int bar_index);

   // دوال مساعدة
   void CalculateHeikinAshi(const double &open[], const double &high[], 
                           const double &low[], const double &close[], 
                           const int rates_total, const int bar_index);
                           
   double CalculateBodySTD(const double &open[], const double &close[], 
                          const int period, const int bar_index);
                          
   void CalculateMovingAverages(const double &close[], const int rates_total, const int bar_index);
   
   // تقييم قوة الاتجاه من 0 إلى 10
   double ScaleTrendStrength(double rawScore, double minScore, double maxScore);
   
   // تحليل الحجم لتعزيز القرار (للتحسين المقترح)
   double VolumeConfirmation(const long &volume[], const int rates_total, const int bar_index);
   
   // حساب سرعة وتسارع تغير السعر (للتحسين المقترح)
   void CalculateSpeedAcceleration(const double &close[], const int rates_total, const int bar_index,
                                 double &speed, double &acceleration);

public:
   // المنشئ
   CTrendDetector(ENUM_TREND_ALGORITHM algorithm = TREND_ALGO_COMPOSITE, 
                 int period = 14);
                 
   // الهادم
   ~CTrendDetector();
   
   // تحديد الاتجاه
   ENUM_TREND_TYPE DetectTrend(const double &open[], const double &high[], 
                              const double &low[], const double &close[], const long &volume[],
                              const int rates_total, const int bar_index);
                              
   // الحصول على قوة الاتجاه
   double GetTrendStrength() const { return m_trendStrength; }
   
   // تعيين الخوارزمية
   void SetAlgorithm(ENUM_TREND_ALGORITHM algorithm) { m_algorithm = algorithm; }
   
   // تعيين الفترة
   void SetPeriod(int period) { m_period = period > 0 ? period : 14; }
   
   // تعيين معلمات خوارزمية قوة الشمعة المفردة
   void SetSingleCandleParams(int windowStrong, double strengthRatio);
   
   // تعيين معلمات خوارزمية قمم وقيعان متعاقبة
   void SetHHLLParams(int hhllPeriod);
   
   // تعيين معلمات خوارزمية مضاعف الابتلاع
   void SetEngulfingParams(int engulfingPeriod);
   
   // تعيين معلمات خوارزمية قوة التتابع
   void SetRunLengthParams(double runDecayFactor, double runThreshold);
   
   // تعيين معلمات خوارزمية هيكين-آشي
   void SetHeikinAshiParams(int haConsecutive);
   
   // تعيين معلمات خوارزمية النقاط المركبة
   void SetCompositeParams(const double &weights[], double minScore);
   
   // تعيين معلمات خوارزمية الانحراف المعياري
   void SetSTDParams(int stdPeriod, double stdFactor);
   
   // تعيين معلمات خوارزمية حالة السوق الحيادية
   void SetSidewaysParams(double mixRatio, int sidewaysPeriod);
   
   // تعيين معلمات المتوسطات المتحركة (للتحسين المقترح)
   void SetMAParams(int fastPeriod, int slowPeriod);
};

//+------------------------------------------------------------------+
//| المنشئ                                                            |
//+------------------------------------------------------------------+
CTrendDetector::CTrendDetector(ENUM_TREND_ALGORITHM algorithm, int period)
{
   // تعيين المعلمات الأساسية
   m_algorithm = algorithm;
   m_period = (period > 0) ? period : 14;
   m_trendStrength = 0.0;
   m_score = 0.0;
   m_consecutiveDir = 0;
   m_runScore = 0.0;
   
   // تهيئة المصفوفات الداخلية
   ArrayResize(m_haOpen, m_period);
   ArrayResize(m_haClose, m_period);
   ArrayResize(m_haHigh, m_period);
   ArrayResize(m_haLow, m_period);
   
   // تعيين القيم الافتراضية للمعلمات
   
   // قوة الشمعة المفردة
   m_windowStrong = 5;
   m_strengthRatio = 1.5;
   
   // قمم وقيعان متعاقبة
   m_hhllPeriod = m_period;
   
   // مضاعف الابتلاع
   m_engulfingPeriod = 3;
   
   // قوة التتابع
   m_runDecayFactor = 0.75;
   m_runThreshold = 3.0;
   
   // هيكين-آشي
   m_haConsecutive = 3;
   
   // النقاط المركبة
   m_compositeWeights[0] = 1.0;  // قوة الشمعة المفردة
   m_compositeWeights[1] = 2.0;  // قمم وقيعان متعاقبة
   m_compositeWeights[2] = 1.5;  // مضاعف الابتلاع
   m_compositeWeights[3] = 1.2;  // قوة التتابع
   m_compositeWeights[4] = 1.8;  // هيكين-آشي
   m_compositeWeights[5] = 0.8;  // الانحراف المعياري
   m_compositeWeights[6] = 1.0;  // حالة السوق الحيادية
   m_compositeWeights[7] = 0.7;  // تحليل الحجم
   m_minCompositeScore = 2.0;
   
   // الانحراف المعياري
   m_stdPeriod = m_period;
   m_stdFactor = 2.0;
   
   // حالة السوق الحيادية
   m_mixRatio = 0.4;
   m_sidewaysPeriod = m_period;
   
   // المتوسطات المتحركة
   m_maFastPeriod = 9;
   m_maSlowPeriod = 21;
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CTrendDetector::~CTrendDetector()
{
   // تحرير الذاكرة المستخدمة
   ArrayFree(m_haOpen);
   ArrayFree(m_haClose);
   ArrayFree(m_haHigh);
   ArrayFree(m_haLow);
}

//+------------------------------------------------------------------+
//| تحديد الاتجاه باستخدام الخوارزمية المحددة                          |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE CTrendDetector::DetectTrend(const double &open[], const double &high[], 
                                           const double &low[], const double &close[], const long &volume[],
                                           const int rates_total, const int bar_index)
{
   // التحقق من صحة البيانات
   if(rates_total <= m_period || bar_index < 0 || bar_index >= rates_total)
   {
      m_trendStrength = 0.0;
      return TREND_NEUTRAL;
   }
   
   ENUM_TREND_TYPE result = TREND_NEUTRAL;
   
   // حساب الاتجاه حسب الخوارزمية المحددة
   switch(m_algorithm)
   {
      case TREND_ALGO_SINGLE_CANDLE:
         result = SingleCandleStrength(open, high, low, close, volume, rates_total, bar_index);
         break;
         
      case TREND_ALGO_HH_LL:
         result = HHLLBreak(open, high, low, close, volume, rates_total, bar_index);
         break;
         
      case TREND_ALGO_ENGULFING:
         result = EngulfingScore(open, high, low, close, volume, rates_total, bar_index);
         break;
         
      case TREND_ALGO_RUN_LENGTH:
         result = RunLengthScoring(open, high, low, close, volume, rates_total, bar_index);
         break;
         
      case TREND_ALGO_HEIKIN_ASHI:
         result = HeikinAshiInternal(open, high, low, close, volume, rates_total, bar_index);
         break;
         
      case TREND_ALGO_COMPOSITE:
         result = CompositeScore(open, high, low, close, volume, rates_total, bar_index);
         break;
         
      case TREND_ALGO_BODY_STD:
         result = BodySTDFilter(open, high, low, close, volume, rates_total, bar_index);
         break;
         
      case TREND_ALGO_SIDEWAYS:
         result = SidewaysDetection(open, high, low, close, volume, rates_total, bar_index);
         break;
         
      case TREND_ALGO_ALL:
      {
         // استخدام جميع الخوارزميات مع أوزانها من مصفوفة الأوزان المركبة
         double bullishScore = 0.0, bearishScore = 0.0, neutralScore = 0.0;
         double totalWeight = 0.0;
         
         // 1. قوة الشمعة المفردة
         ENUM_TREND_TYPE singleResult = SingleCandleStrength(open, high, low, close, volume, rates_total, bar_index);
         if(singleResult == TREND_BULLISH) bullishScore += m_compositeWeights[0];
         else if(singleResult == TREND_BEARISH) bearishScore += m_compositeWeights[0];
         else neutralScore += m_compositeWeights[0];
         totalWeight += m_compositeWeights[0];
         
         // 2. قمم وقيعان متعاقبة
         ENUM_TREND_TYPE hhllResult = HHLLBreak(open, high, low, close, volume, rates_total, bar_index);
         if(hhllResult == TREND_BULLISH) bullishScore += m_compositeWeights[1];
         else if(hhllResult == TREND_BEARISH) bearishScore += m_compositeWeights[1];
         else neutralScore += m_compositeWeights[1];
         totalWeight += m_compositeWeights[1];
         
         // 3. مضاعف الابتلاع
         ENUM_TREND_TYPE engulfingResult = EngulfingScore(open, high, low, close, volume, rates_total, bar_index);
         if(engulfingResult == TREND_BULLISH) bullishScore += m_compositeWeights[2];
         else if(engulfingResult == TREND_BEARISH) bearishScore += m_compositeWeights[2];
         else neutralScore += m_compositeWeights[2];
         totalWeight += m_compositeWeights[2];
         
         // 4. قوة التتابع
         ENUM_TREND_TYPE runResult = RunLengthScoring(open, high, low, close, volume, rates_total, bar_index);
         if(runResult == TREND_BULLISH) bullishScore += m_compositeWeights[3];
         else if(runResult == TREND_BEARISH) bearishScore += m_compositeWeights[3];
         else neutralScore += m_compositeWeights[3];
         totalWeight += m_compositeWeights[3];
         
         // 5. هيكين-آشي
         ENUM_TREND_TYPE haResult = HeikinAshiInternal(open, high, low, close, volume, rates_total, bar_index);
         if(haResult == TREND_BULLISH) bullishScore += m_compositeWeights[4];
         else if(haResult == TREND_BEARISH) bearishScore += m_compositeWeights[4];
         else neutralScore += m_compositeWeights[4];
         totalWeight += m_compositeWeights[4];
         
         // 6. الانحراف المعياري
         ENUM_TREND_TYPE stdResult = BodySTDFilter(open, high, low, close, volume, rates_total, bar_index);
         if(stdResult == TREND_BULLISH) bullishScore += m_compositeWeights[5];
         else if(stdResult == TREND_BEARISH) bearishScore += m_compositeWeights[5];
         else neutralScore += m_compositeWeights[5];
         totalWeight += m_compositeWeights[5];
         
         // 7. حالة السوق الحيادية
         ENUM_TREND_TYPE sidewaysResult = SidewaysDetection(open, high, low, close, volume, rates_total, bar_index);
         if(sidewaysResult == TREND_BULLISH) bullishScore += m_compositeWeights[6];
         else if(sidewaysResult == TREND_BEARISH) bearishScore += m_compositeWeights[6];
         else neutralScore += m_compositeWeights[6];
         totalWeight += m_compositeWeights[6];
         
         // 8. تحليل الحجم (للتحسين المقترح)
         double volumeConfirmation = VolumeConfirmation(volume, rates_total, bar_index);
         if(volumeConfirmation > 0) bullishScore += m_compositeWeights[7] * volumeConfirmation;
         else if(volumeConfirmation < 0) bearishScore += m_compositeWeights[7] * MathAbs(volumeConfirmation);
         totalWeight += m_compositeWeights[7];
         
         // تحديد النتيجة النهائية
         if(totalWeight > 0)
         {
            bullishScore /= totalWeight;
            bearishScore /= totalWeight;
            neutralScore /= totalWeight;
            
            if(neutralScore > MathMax(bullishScore, bearishScore) && neutralScore > 0.4)
            {
               result = TREND_NEUTRAL;
               m_trendStrength = neutralScore * 10.0;
            }
            else if(bullishScore > bearishScore)
            {
               result = TREND_BULLISH;
               m_trendStrength = bullishScore * 10.0;
            }
            else if(bearishScore > bullishScore)
            {
               result = TREND_BEARISH;
               m_trendStrength = bearishScore * 10.0;
            }
            else
            {
               result = TREND_NEUTRAL;
               m_trendStrength = 5.0;
            }
         }
         break;
      }
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| خوارزمية 1: قوة الشمعة المفردة                                     |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE CTrendDetector::SingleCandleStrength(const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], const long &volume[],
                                                   const int rates_total, const int bar_index)
{
   if(bar_index >= rates_total - 1 || bar_index < 0)
      return TREND_NEUTRAL;
      
   // حساب متوسط حجم جسم الشمعة وحجم المدى
   double avgBody = 0.0;
   double avgRange = 0.0;
   int startIdx = bar_index + 1;
   int endIdx = MathMin(startIdx + m_windowStrong, rates_total);
   
   for(int i = startIdx; i < endIdx; i++)
   {
      avgBody += CCandleUtils::CandleBody(open[i], close[i]);
      avgRange += CCandleUtils::CandleRange(high[i], low[i]);
   }
   
   avgBody /= (endIdx - startIdx);
   avgRange /= (endIdx - startIdx);
   
   // حساب قوة الشمعة الحالية
   double currentBody = CCandleUtils::CandleBody(open[bar_index], close[bar_index]);
   double currentRange = CCandleUtils::CandleRange(high[bar_index], low[bar_index]);
   
   // تحديد الاتجاه بناءً على قوة الشمعة
   if(currentBody >= m_strengthRatio * avgBody)
   {
      if(close[bar_index] > open[bar_index])
      {
         // شمعة صعودية قوية
         m_trendStrength = ScaleTrendStrength(currentBody / avgBody, m_strengthRatio, m_strengthRatio * 2);
         return TREND_BULLISH;
      }
      else if(close[bar_index] < open[bar_index])
      {
         // شمعة هبوطية قوية
         m_trendStrength = ScaleTrendStrength(currentBody / avgBody, m_strengthRatio, m_strengthRatio * 2);
         return TREND_BEARISH;
      }
   }
   
   // شمعة دوجي تشير إلى حيادية السوق
   if(CCandleUtils::IsDoji(open[bar_index], close[bar_index], avgRange, 0.05))
   {
      m_trendStrength = MathMin(5.0, 10.0 * (avgRange / currentRange));
      return TREND_NEUTRAL;
   }
   
   // تحديد الاتجاه بناءً على الظلال
   double upperShadow = CCandleUtils::UpperShadow(open[bar_index], high[bar_index], close[bar_index]);
   double lowerShadow = CCandleUtils::LowerShadow(open[bar_index], low[bar_index], close[bar_index]);
   
   if(upperShadow < 0.2 * currentBody && lowerShadow > 2.0 * currentBody && close[bar_index] > open[bar_index])
   {
      // مطرقة صعودية
      m_trendStrength = 7.0;
      return TREND_BULLISH;
   }
   
   if(lowerShadow < 0.2 * currentBody && upperShadow > 2.0 * currentBody && close[bar_index] < open[bar_index])
   {
      // مطرقة هبوطية
      m_trendStrength = 7.0;
      return TREND_BEARISH;
   }
   
   // الشمعة لا تحمل إشارة واضحة
   if(close[bar_index] > open[bar_index])
   {
      m_trendStrength = 5.0 * (currentBody / avgBody);
      return TREND_BULLISH;
   }
   else if(close[bar_index] < open[bar_index])
   {
      m_trendStrength = 5.0 * (currentBody / avgBody);
      return TREND_BEARISH;
   }
   
   m_trendStrength = 3.0;
   return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| خوارزمية 2: قمم وقيعان متعاقبة                                     |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE CTrendDetector::HHLLBreak(const double &open[], const double &high[], 
                                         const double &low[], const double &close[], const long &volume[],
                                         const int rates_total, const int bar_index)
{
   if(bar_index >= rates_total - m_hhllPeriod || bar_index < 0)
      return TREND_NEUTRAL;
      
   // البحث عن قمم وقيعان خلال الفترة المحددة
   double highestHigh = high[bar_index + 1];
   double lowestLow = low[bar_index + 1];
   
   for(int i = bar_index + 1; i < bar_index + 1 + m_hhllPeriod && i < rates_total; i++)
   {
      if(high[i] > highestHigh)
         highestHigh = high[i];
      if(low[i] < lowestLow)
         lowestLow = low[i];
   }
   
   // التحقق من اختراق القمم أو القيعان
   if(high[bar_index] > highestHigh)
   {
      // اختراق صعودي
      m_trendStrength = ScaleTrendStrength((high[bar_index] - highestHigh) / highestHigh * 100, 0.1, 2.0);
      return TREND_BULLISH;
   }
   
   if(low[bar_index] < lowestLow)
   {
      // اختراق هبوطي
      m_trendStrength = ScaleTrendStrength((lowestLow - low[bar_index]) / lowestLow * 100, 0.1, 2.0);
      return TREND_BEARISH;
   }
   
   // فحص نمط القمم والقيعان المتتالية
   bool higherHigh = false;
   bool higherLow = false;
   bool lowerHigh = false;
   bool lowerLow = false;
   
   // نحتاج لثلاث شموع على الأقل للتحقق
   if(bar_index + 3 < rates_total)
   {
      higherHigh = high[bar_index] > high[bar_index + 1] && high[bar_index + 1] > high[bar_index + 2];
      higherLow = low[bar_index] > low[bar_index + 1] && low[bar_index + 1] > low[bar_index + 2];
      lowerHigh = high[bar_index] < high[bar_index + 1] && high[bar_index + 1] < high[bar_index + 2];
      lowerLow = low[bar_index] < low[bar_index + 1] && low[bar_index + 1] < low[bar_index + 2];
      
      // التحقق من المتوسطات المتحركة لتأكيد الاتجاه
      CalculateMovingAverages(close, rates_total, bar_index);
      
      if(higherHigh && higherLow)
      {
         // اتجاه صعودي قوي
         m_trendStrength = 8.0;
         
         // زيادة القوة إذا كان متوسط الفترة الأقصر فوق متوسط الفترة الأطول
         if(m_maFast > m_maSlow)
            m_trendStrength = 9.0;
            
         return TREND_BULLISH;
      }
      
      if(lowerHigh && lowerLow)
      {
         // اتجاه هبوطي قوي
         m_trendStrength = 8.0;
         
         // زيادة القوة إذا كان متوسط الفترة الأقصر تحت متوسط الفترة الأطول
         if(m_maFast < m_maSlow)
            m_trendStrength = 9.0;
            
         return TREND_BEARISH;
      }
      
      if(higherLow && !higherHigh)
      {
         // دعم متزايد، إشارة صعودية محتملة
         m_trendStrength = 6.0;
         return TREND_BULLISH;
      }
      
      if(lowerHigh && !lowerLow)
      {
         // مقاومة منخفضة، إشارة هبوطية محتملة
         m_trendStrength = 6.0;
         return TREND_BEARISH;
      }
   }
   
   // الحالة الافتراضية
   m_trendStrength = 4.0;
   return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| خوارزمية 3: مضاعف الابتلاع                                        |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE CTrendDetector::EngulfingScore(const double &open[], const double &high[], 
                                             const double &low[], const double &close[], const long &volume[],
                                             const int rates_total, const int bar_index)
{
   if(bar_index >= rates_total - 1 || bar_index < 0)
      return TREND_NEUTRAL;
      
   // التحقق من نمط الابتلاع الصعودي
   bool isBullishEngulfing = close[bar_index] > open[bar_index] &&  // شمعة صعودية حالية
                            close[bar_index + 1] < open[bar_index + 1] &&  // شمعة هبوطية سابقة
                            open[bar_index] <= close[bar_index + 1] && 
                            close[bar_index] >= open[bar_index + 1] && 
                            CCandleUtils::CandleBody(open[bar_index], close[bar_index]) > 
                            CCandleUtils::CandleBody(open[bar_index + 1], close[bar_index + 1]);
   
   // التحقق من نمط الابتلاع الهبوطي
   bool isBearishEngulfing = close[bar_index] < open[bar_index] &&  // شمعة هبوطية حالية
                            close[bar_index + 1] > open[bar_index + 1] &&  // شمعة صعودية سابقة
                            open[bar_index] >= close[bar_index + 1] && 
                            close[bar_index] <= open[bar_index + 1] && 
                            CCandleUtils::CandleBody(open[bar_index], close[bar_index]) > 
                            CCandleUtils::CandleBody(open[bar_index + 1], close[bar_index + 1]);
   
   // تحليل الحجم للتأكيد (إذا كان متاحاً)
   double volumeMultiplier = 1.0;
   if(ArraySize(volume) > bar_index + 1 && volume[bar_index] > 0 && volume[bar_index + 1] > 0)
   {
      volumeMultiplier = (double)volume[bar_index] / (double)volume[bar_index + 1];
      // تقييد المضاعف بين 1.0 و 3.0
      volumeMultiplier = MathMax(1.0, MathMin(3.0, volumeMultiplier));
   }
   
   if(isBullishEngulfing)
   {
      // حساب قوة نمط الابتلاع
      double engulfStrength = CCandleUtils::CandleBody(open[bar_index], close[bar_index]) / 
                             CCandleUtils::CandleBody(open[bar_index + 1], close[bar_index + 1]);
                             
      m_trendStrength = ScaleTrendStrength(engulfStrength * volumeMultiplier, 1.0, 3.0);
      
      // البحث عن عوامل تعزيز إضافية
      if(bar_index + m_engulfingPeriod < rates_total)
      {
         bool isDowntrend = true;
         for(int i = bar_index + 1; i < bar_index + 1 + m_engulfingPeriod && i < rates_total; i++)
         {
            if(close[i] > open[i])
            {
               isDowntrend = false;
               break;
            }
         }
         
         if(isDowntrend)
            m_trendStrength = MathMin(10.0, m_trendStrength + 2.0);  // تعزيز إشارة الانعكاس في الاتجاه الهبوطي
      }
      
      return TREND_BULLISH;
   }
   
   if(isBearishEngulfing)
   {
      // حساب قوة نمط الابتلاع
      double engulfStrength = CCandleUtils::CandleBody(open[bar_index], close[bar_index]) / 
                             CCandleUtils::CandleBody(open[bar_index + 1], close[bar_index + 1]);
                             
      m_trendStrength = ScaleTrendStrength(engulfStrength * volumeMultiplier, 1.0, 3.0);
      
      // البحث عن عوامل تعزيز إضافية
      if(bar_index + m_engulfingPeriod < rates_total)
      {
         bool isUptrend = true;
         for(int i = bar_index + 1; i < bar_index + 1 + m_engulfingPeriod && i < rates_total; i++)
         {
            if(close[i] < open[i])
            {
               isUptrend = false;
               break;
            }
         }
         
         if(isUptrend)
            m_trendStrength = MathMin(10.0, m_trendStrength + 2.0);  // تعزيز إشارة الانعكاس في الاتجاه الصعودي
      }
      
      return TREND_BEARISH;
   }
   
   // التحقق من أنماط أخرى للأهمية
   if(bar_index + 1 < rates_total)
   {
      // التحقق من نمط الهارامي
      bool isBullishHarami = close[bar_index] > open[bar_index] &&
                            close[bar_index + 1] < open[bar_index + 1] &&
                            open[bar_index] > close[bar_index + 1] &&
                            close[bar_index] < open[bar_index + 1];
                            
      bool isBearishHarami = close[bar_index] < open[bar_index] &&
                            close[bar_index + 1] > open[bar_index + 1] &&
                            open[bar_index] < close[bar_index + 1] &&
                            close[bar_index] > open[bar_index + 1];
                            
      if(isBullishHarami)
      {
         m_trendStrength = 6.0;
         return TREND_BULLISH;
      }
      
      if(isBearishHarami)
      {
         m_trendStrength = 6.0;
         return TREND_BEARISH;
      }
   }
   
   // الحالة الافتراضية
   m_trendStrength = 5.0;
   if(close[bar_index] > open[bar_index])
      return TREND_BULLISH;
   else if(close[bar_index] < open[bar_index])
      return TREND_BEARISH;
   else
      return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| خوارزمية 4: قوة التتابع                                           |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE CTrendDetector::RunLengthScoring(const double &open[], const double &high[], 
                                               const double &low[], const double &close[], const long &volume[],
                                               const int rates_total, const int bar_index)
{
   if(bar_index >= rates_total - 1 || bar_index < 0)
      return TREND_NEUTRAL;
      
   // تحديد اتجاه الشمعة الحالية
   int currentDirection = 0;
   if(close[bar_index] > open[bar_index])
      currentDirection = 1;  // صعودي
   else if(close[bar_index] < open[bar_index])
      currentDirection = -1; // هبوطي
   
   // إذا تغير الاتجاه، نبدأ تتبع تتابع جديد
   if(currentDirection != 0 && currentDirection != m_consecutiveDir)
   {
      m_consecutiveDir = currentDirection;
      m_runScore = 1.0;
   }
   // إذا استمر نفس الاتجاه، نزيد نتيجة التتابع
   else if(currentDirection != 0 && currentDirection == m_consecutiveDir)
   {
      m_runScore = m_runScore * m_runDecayFactor + 1.0;
   }
   else
   {
      // شمعة محايدة تضعف التتابع
      m_runScore *= m_runDecayFactor;
   }
   
   // تقييم قوة التتابع
   if(m_runScore >= m_runThreshold)
   {
      if(m_consecutiveDir > 0)
      {
         m_trendStrength = ScaleTrendStrength(m_runScore, m_runThreshold, m_runThreshold * 3);
         return TREND_BULLISH;
      }
      else if(m_consecutiveDir < 0)
      {
         m_trendStrength = ScaleTrendStrength(m_runScore, m_runThreshold, m_runThreshold * 3);
         return TREND_BEARISH;
      }
   }
   
   // الحالة الافتراضية
   if(m_runScore < 1.0)
   {
      m_trendStrength = 5.0;
      return TREND_NEUTRAL;
   }
   else if(m_consecutiveDir > 0)
   {
      m_trendStrength = 5.0 * (m_runScore / m_runThreshold);
      return TREND_BULLISH;
   }
   else if(m_consecutiveDir < 0)
   {
      m_trendStrength = 5.0 * (m_runScore / m_runThreshold);
      return TREND_BEARISH;
   }
   
   m_trendStrength = 3.0;
   return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| خوارزمية 5: شموع هيكين-آشي الداخلية                               |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE CTrendDetector::HeikinAshiInternal(const double &open[], const double &high[], 
                                                 const double &low[], const double &close[], const long &volume[],
                                                 const int rates_total, const int bar_index)
{
   if(bar_index >= rates_total - m_haConsecutive || bar_index < 0)
      return TREND_NEUTRAL;
      
   // حساب قيم هيكين-آشي
   CalculateHeikinAshi(open, high, low, close, rates_total, bar_index);
   
   // التحقق من تتابع شموع هيكين-آشي
   bool allBullish = true;
   bool allBearish = true;
   double haBodySizeTotal = 0.0;
   
   for(int i = 0; i < m_haConsecutive && i <= bar_index; i++)
   {
      if(m_haClose[i] <= m_haOpen[i])
         allBullish = false;
      if(m_haClose[i] >= m_haOpen[i])
         allBearish = false;
         
      haBodySizeTotal += MathAbs(m_haClose[i] - m_haOpen[i]);
   }
   
   double avgBodySize = haBodySizeTotal / m_haConsecutive;
   
   // تحديد الاتجاه بناءً على شموع هيكين-آشي
   if(allBullish)
   {
      // اتجاه صعودي قوي في هيكين-آشي
      double currentBody = MathAbs(m_haClose[0] - m_haOpen[0]);
      m_trendStrength = ScaleTrendStrength(currentBody / avgBodySize * m_haConsecutive, 0.5, 3.0);
      return TREND_BULLISH;
   }
   
   if(allBearish)
   {
      // اتجاه هبوطي قوي في هيكين-آشي
      double currentBody = MathAbs(m_haClose[0] - m_haOpen[0]);
      m_trendStrength = ScaleTrendStrength(currentBody / avgBodySize * m_haConsecutive, 0.5, 3.0);
      return TREND_BEARISH;
   }
   
   // التحقق من حالة تحول محتملة
   if(m_haClose[0] > m_haOpen[0] && m_haClose[1] <= m_haOpen[1])
   {
      // انعكاس محتمل للأعلى
      m_trendStrength = 6.0;
      return TREND_BULLISH;
   }
   
   if(m_haClose[0] < m_haOpen[0] && m_haClose[1] >= m_haOpen[1])
   {
      // انعكاس محتمل للأسفل
      m_trendStrength = 6.0;
      return TREND_BEARISH;
   }
   
   // الحالة الافتراضية
   if(m_haClose[0] > m_haOpen[0])
   {
      m_trendStrength = 5.0;
      return TREND_BULLISH;
   }
   else if(m_haClose[0] < m_haOpen[0])
   {
      m_trendStrength = 5.0;
      return TREND_BEARISH;
   }
   
   m_trendStrength = 3.0;
   return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| خوارزمية 6: نظام النقاط المركبة                                    |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE CTrendDetector::CompositeScore(const double &open[], const double &high[], 
                                             const double &low[], const double &close[], const long &volume[],
                                             const int rates_total, const int bar_index)
{
   if(bar_index >= rates_total - 1 || bar_index < 0)
      return TREND_NEUTRAL;
      
   // إنشاء نتيجة مركبة من عوامل متعددة
   double bullScore = 0.0;  // نقاط الاتجاه الصعودي
   double bearScore = 0.0;  // نقاط الاتجاه الهبوطي
   
   // 1. الشمعة الحالية
   if(close[bar_index] > open[bar_index])
   {
      bullScore += 1.0;
      
      // جسم قوي للشمعة
      double bodyRatio = CCandleUtils::CandleBody(open[bar_index], close[bar_index]) / 
                       CCandleUtils::CandleRange(high[bar_index], low[bar_index]);
      if(bodyRatio > 0.6)
         bullScore += 0.5;
   }
   else if(close[bar_index] < open[bar_index])
   {
      bearScore += 1.0;
      
      // جسم قوي للشمعة
      double bodyRatio = CCandleUtils::CandleBody(open[bar_index], close[bar_index]) / 
                       CCandleUtils::CandleRange(high[bar_index], low[bar_index]);
      if(bodyRatio > 0.6)
         bearScore += 0.5;
   }
   
   // 2. متوسطات متحركة
   CalculateMovingAverages(close, rates_total, bar_index);
   if(m_maFast > m_maSlow)
      bullScore += 1.0;
   else if(m_maFast < m_maSlow)
      bearScore += 1.0;
      
   // 3. سلسلة الشموع
   int bullCandles = 0, bearCandles = 0;
   for(int i = bar_index; i < bar_index + 5 && i < rates_total; i++)
   {
      if(close[i] > open[i])
         bullCandles++;
      else if(close[i] < open[i])
         bearCandles++;
   }
   
   if(bullCandles >= 3)
      bullScore += 0.5;
   if(bearCandles >= 3)
      bearScore += 0.5;
      
   // 4. اختراق القمم والقيعان
   double highestHigh = high[bar_index + 1];
   double lowestLow = low[bar_index + 1];
   for(int i = bar_index + 1; i < bar_index + 5 && i < rates_total; i++)
   {
      if(high[i] > highestHigh)
         highestHigh = high[i];
      if(low[i] < lowestLow)
         lowestLow = low[i];
   }
   
   if(high[bar_index] > highestHigh)
      bullScore += 1.5;
   if(low[bar_index] < lowestLow)
      bearScore += 1.5;
      
   // 5. حجم التداول
   if(ArraySize(volume) > bar_index + 1 && volume[bar_index] > 0 && volume[bar_index + 1] > 0)
   {
      if(volume[bar_index] > volume[bar_index + 1] * 1.5)
      {
         if(close[bar_index] > open[bar_index])
            bullScore += 0.7;
         else if(close[bar_index] < open[bar_index])
            bearScore += 0.7;
      }
   }
   
   // 6. تحليل السرعة والتسارع
   double speed, acceleration;
   CalculateSpeedAcceleration(close, rates_total, bar_index, speed, acceleration);
   
   if(speed > 0)
      bullScore += 0.3;
   else if(speed < 0)
      bearScore += 0.3;
      
   if(acceleration > 0)
      bullScore += 0.3;
   else if(acceleration < 0)
      bearScore += 0.3;
      
   // تحديد النتيجة النهائية
   double netScore = bullScore - bearScore;
   
   // حفظ قيمة النتيجة للاستخدام الخارجي
   m_score = netScore;
   
   // تحديد قوة الاتجاه
   m_trendStrength = ScaleTrendStrength(MathAbs(netScore), m_minCompositeScore, m_minCompositeScore * 2);
   
   if(netScore >= m_minCompositeScore)
      return TREND_BULLISH;
   else if(netScore <= -m_minCompositeScore)
      return TREND_BEARISH;
   else
      return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| خوارزمية 7: الانحراف المعياري لجسم الشمعة                          |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE CTrendDetector::BodySTDFilter(const double &open[], const double &high[], 
                                            const double &low[], const double &close[], const long &volume[],
                                            const int rates_total, const int bar_index)
{
   if(bar_index >= rates_total - m_stdPeriod || bar_index < 0)
      return TREND_NEUTRAL;
      
   // حساب الانحراف المعياري لأحجام الجسم
   double stdDev = CalculateBodySTD(open, close, m_stdPeriod, bar_index);
   
   // حساب متوسط حجم الجسم
   double avgBody = 0.0;
   for(int i = bar_index; i < bar_index + m_stdPeriod && i < rates_total; i++)
   {
      avgBody += CCandleUtils::CandleBody(open[i], close[i]);
   }
   avgBody /= m_stdPeriod;
   
   // حجم جسم الشمعة الحالية
   double currentBody = CCandleUtils::CandleBody(open[bar_index], close[bar_index]);
   
   // إذا كان جسم الشمعة الحالية أكبر من المتوسط + عامل الانحراف المعياري
   if(currentBody > avgBody + m_stdFactor * stdDev)
   {
      // شمعة قوية - قد تشير إلى بداية اتجاه جديد
      if(close[bar_index] > open[bar_index])
      {
         m_trendStrength = ScaleTrendStrength((currentBody - avgBody) / (stdDev), m_stdFactor, m_stdFactor * 2);
         return TREND_BULLISH;
      }
      else
      {
         m_trendStrength = ScaleTrendStrength((currentBody - avgBody) / (stdDev), m_stdFactor, m_stdFactor * 2);
         return TREND_BEARISH;
      }
   }
   
   // الحالة الافتراضية - تحديد الاتجاه بناءً على متوسطات متحركة
   CalculateMovingAverages(close, rates_total, bar_index);
   
   if(m_maFast > m_maSlow)
   {
      // اتجاه صعودي محتمل
      m_trendStrength = 5.0 + 2.0 * (m_maFast - m_maSlow) / m_maSlow * 100;
      return TREND_BULLISH;
   }
   else if(m_maFast < m_maSlow)
   {
      // اتجاه هبوطي محتمل
      m_trendStrength = 5.0 + 2.0 * (m_maSlow - m_maFast) / m_maFast * 100;
      return TREND_BEARISH;
   }
   
   // لا يوجد اتجاه واضح
   m_trendStrength = 3.0;
   return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| خوارزمية 8: حالة سوق حيادية                                       |
//+------------------------------------------------------------------+
ENUM_TREND_TYPE CTrendDetector::SidewaysDetection(const double &open[], const double &high[], 
                                                const double &low[], const double &close[], const long &volume[],
                                                const int rates_total, const int bar_index)
{
   if(bar_index >= rates_total - m_sidewaysPeriod || bar_index < 0)
      return TREND_NEUTRAL;
      
   // حساب عدد الشموع الصعودية والهبوطية والدوجي
   int bullCount = 0;
   int bearCount = 0;
   int dojiCount = 0;
   
   // حساب متوسط المدى
   double avgRange = 0.0;
   for(int i = bar_index; i < bar_index + m_sidewaysPeriod && i < rates_total; i++)
   {
      avgRange += CCandleUtils::CandleRange(high[i], low[i]);
   }
   avgRange /= m_sidewaysPeriod;
   
   // حساب التقلب
   double highestHigh = high[bar_index];
   double lowestLow = low[bar_index];
   
   for(int i = bar_index; i < bar_index + m_sidewaysPeriod && i < rates_total; i++)
   {
      if(high[i] > highestHigh)
         highestHigh = high[i];
      if(low[i] < lowestLow)
         lowestLow = low[i];
         
      if(CCandleUtils::IsDoji(open[i], close[i], avgRange, 0.05))
         dojiCount++;
      else if(close[i] > open[i])
         bullCount++;
      else if(close[i] < open[i])
         bearCount++;
   }
   
   // حساب نسبة الشموع الصعودية والهبوطية
   double bullRatio = (double)bullCount / m_sidewaysPeriod;
   double bearRatio = (double)bearCount / m_sidewaysPeriod;
   double dojiRatio = (double)dojiCount / m_sidewaysPeriod;
   
   // حساب نطاق التقلب كنسبة مئوية من السعر
   double volatilityRange = (highestHigh - lowestLow) / lowestLow * 100;
   
   // الكشف عن حالة السوق الحيادية
   if(MathAbs(bullRatio - bearRatio) < m_mixRatio && dojiRatio > 0.2 && volatilityRange < 3.0)
   {
      // سوق حيادي - تقلب منخفض وتوازن بين الشموع الصعودية والهبوطية
      m_trendStrength = 9.0;
      return TREND_NEUTRAL;
   }
   
   // التحقق من التقلب المنخفض بشكل عام
   if(volatilityRange < 1.5)
   {
      // تقلب منخفض جداً - قد يشير إلى تراكم أو توزيع قبل حركة كبيرة
      m_trendStrength = 7.0;
      return TREND_NEUTRAL;
   }
   
   // التحقق من وجود نمط متناوب من الشموع الصعودية والهبوطية
   bool alternating = true;
   for(int i = bar_index; i < bar_index + m_sidewaysPeriod - 1 && i + 1 < rates_total; i++)
   {
      if((close[i] > open[i] && close[i+1] > open[i+1]) || 
         (close[i] < open[i] && close[i+1] < open[i+1]))
      {
         alternating = false;
         break;
      }
   }
   
   if(alternating && m_sidewaysPeriod >= 4)
   {
      // نمط متناوب - يشير إلى تردد السوق
      m_trendStrength = 8.0;
      return TREND_NEUTRAL;
   }
   
   // الحالة الافتراضية - تحديد اتجاه ضعيف
   if(bullRatio > bearRatio + 0.2)
   {
      m_trendStrength = 5.0;
      return TREND_BULLISH;
   }
   else if(bearRatio > bullRatio + 0.2)
   {
      m_trendStrength = 5.0;
      return TREND_BEARISH;
   }
   
   m_trendStrength = 4.0;
   return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| حساب قيم هيكين-آشي                                               |
//+------------------------------------------------------------------+
void CTrendDetector::CalculateHeikinAshi(const double &open[], const double &high[], 
                                        const double &low[], const double &close[], 
                                        const int rates_total, const int bar_index)
{
   // التأكد من وجود مساحة كافية في المصفوفات
   int maxIdx = MathMin(m_period, bar_index + 1);
   if(ArraySize(m_haOpen) < maxIdx || ArraySize(m_haClose) < maxIdx || 
      ArraySize(m_haHigh) < maxIdx || ArraySize(m_haLow) < maxIdx)
   {
      ArrayResize(m_haOpen, maxIdx);
      ArrayResize(m_haClose, maxIdx);
      ArrayResize(m_haHigh, maxIdx);
      ArrayResize(m_haLow, maxIdx);
   }
   
   // حساب قيم هيكين-آشي للشمعة الأولى
   if(bar_index == rates_total - 1 || bar_index + 1 >= rates_total)
   {
      m_haClose[0] = (open[bar_index] + high[bar_index] + low[bar_index] + close[bar_index]) / 4.0;
      m_haOpen[0] = (open[bar_index] + close[bar_index]) / 2.0;
      m_haHigh[0] = high[bar_index];
      m_haLow[0] = low[bar_index];
      return;
   }
   
   // حساب قيم هيكين-آشي للشموع اللاحقة
   for(int i = 0; i < maxIdx; i++)
   {
      int idx = bar_index + i;
      if(idx >= rates_total)
         break;
         
      // حساب قيمة الإغلاق أولاً
      m_haClose[i] = (open[idx] + high[idx] + low[idx] + close[idx]) / 4.0;
      
      // حساب قيمة الافتتاح
      if(i == maxIdx - 1)
      {
         // الشمعة الأولى (الأقدم) في النطاق
         m_haOpen[i] = (open[idx] + close[idx]) / 2.0;
      }
      else
      {
         // الشموع اللاحقة
         m_haOpen[i] = (m_haOpen[i+1] + m_haClose[i+1]) / 2.0;
      }
      
      // حساب أعلى وأدنى قيمة
      m_haHigh[i] = MathMax(high[idx], MathMax(m_haOpen[i], m_haClose[i]));
      m_haLow[i] = MathMin(low[idx], MathMin(m_haOpen[i], m_haClose[i]));
   }
}

//+------------------------------------------------------------------+
//| حساب الانحراف المعياري لأحجام الجسم                                |
//+------------------------------------------------------------------+
double CTrendDetector::CalculateBodySTD(const double &open[], const double &close[], 
                                       const int period, const int bar_index)
{
   if(period <= 1 || bar_index < 0)
      return 0.0;
      
   double sum = 0.0;
   double sumSq = 0.0;
   int count = 0;
   
   // حساب متوسط حجم الجسم
   for(int i = bar_index; i < bar_index + period && i < ArraySize(open); i++)
   {
      double body = CCandleUtils::CandleBody(open[i], close[i]);
      sum += body;
      sumSq += body * body;
      count++;
   }
   
   if(count <= 1)
      return 0.0;
      
   double mean = sum / count;
   double variance = (sumSq - sum * mean) / (count - 1);
   
   return MathSqrt(MathMax(0.0, variance));
}

//+------------------------------------------------------------------+
//| حساب متوسطات متحركة بسيطة                                        |
//+------------------------------------------------------------------+
void CTrendDetector::CalculateMovingAverages(const double &close[], const int rates_total, const int bar_index)
{
   // التأكد من وجود بيانات كافية
   if(bar_index >= rates_total - m_maSlowPeriod || bar_index < 0)
   {
      m_maFast = m_maSlow = close[bar_index];
      return;
   }
   
   // حساب المتوسط المتحرك السريع
   double sumFast = 0.0;
   for(int i = bar_index; i < bar_index + m_maFastPeriod && i < rates_total; i++)
   {
      sumFast += close[i];
   }
   m_maFast = sumFast / m_maFastPeriod;
   
   // حساب المتوسط المتحرك البطيء
   double sumSlow = 0.0;
   for(int i = bar_index; i < bar_index + m_maSlowPeriod && i < rates_total; i++)
   {
      sumSlow += close[i];
   }
   m_maSlow = sumSlow / m_maSlowPeriod;
}

//+------------------------------------------------------------------+
//| تقييم قوة الاتجاه من 0 إلى 10                                     |
//+------------------------------------------------------------------+
double CTrendDetector::ScaleTrendStrength(double rawScore, double minScore, double maxScore)
{
   // تحويل النتيجة الخام إلى مقياس من 0 إلى 10
   if(rawScore <= minScore)
      return 5.0;
      
   if(rawScore >= maxScore)
      return 10.0;
      
   // تدرج خطي
   return 5.0 + (rawScore - minScore) / (maxScore - minScore) * 5.0;
}

//+------------------------------------------------------------------+
//| تحليل الحجم لتعزيز القرار                                         |
//+------------------------------------------------------------------+
double CTrendDetector::VolumeConfirmation(const long &volume[], const int rates_total, const int bar_index)
{
   if(ArraySize(volume) <= bar_index + 5 || bar_index < 0)
      return 0.0;
      
   // حساب متوسط الحجم لآخر 5 شموع
   double avgVolume = 0.0;
   for(int i = bar_index + 1; i <= bar_index + 5 && i < rates_total; i++)
   {
      avgVolume += (double)volume[i];
   }
   avgVolume /= 5.0;
   
   // لا يوجد حجم متاح
   if(avgVolume <= 0.0)
      return 0.0;
      
   // إرجاع قيمة تمثل نسبة الحجم الحالي مقارنة بالمتوسط
   double volumeRatio = (double)volume[bar_index] / avgVolume - 1.0;
   
   return MathMax(-1.0, MathMin(1.0, volumeRatio));
}

//+------------------------------------------------------------------+
//| حساب سرعة وتسارع تغير السعر                                       |
//+------------------------------------------------------------------+
void CTrendDetector::CalculateSpeedAcceleration(const double &close[], const int rates_total, 
                                              const int bar_index, double &speed, double &acceleration)
{
   speed = 0.0;
   acceleration = 0.0;
   
   if(bar_index + 2 >= rates_total)
      return;
      
   // حساب السرعة (المشتقة الأولى)
   speed = close[bar_index] - close[bar_index + 1];
   
   // حساب التسارع (المشتقة الثانية)
   double prevSpeed = close[bar_index + 1] - close[bar_index + 2];
   acceleration = speed - prevSpeed;
}

//+------------------------------------------------------------------+
//| تعيين معلمات خوارزمية قوة الشمعة المفردة                            |
//+------------------------------------------------------------------+
void CTrendDetector::SetSingleCandleParams(int windowStrong, double strengthRatio)
{
   m_windowStrong = (windowStrong > 0) ? windowStrong : 5;
   m_strengthRatio = (strengthRatio > 0.0) ? strengthRatio : 1.5;
}

//+------------------------------------------------------------------+
//| تعيين معلمات خوارزمية قمم وقيعان متعاقبة                           |
//+------------------------------------------------------------------+
void CTrendDetector::SetHHLLParams(int hhllPeriod)
{
   m_hhllPeriod = (hhllPeriod > 0) ? hhllPeriod : m_period;
}

//+------------------------------------------------------------------+
//| تعيين معلمات خوارزمية مضاعف الابتلاع                              |
//+------------------------------------------------------------------+
void CTrendDetector::SetEngulfingParams(int engulfingPeriod)
{
   m_engulfingPeriod = (engulfingPeriod > 0) ? engulfingPeriod : 3;
}

//+------------------------------------------------------------------+
//| تعيين معلمات خوارزمية قوة التتابع                                 |
//+------------------------------------------------------------------+
void CTrendDetector::SetRunLengthParams(double runDecayFactor, double runThreshold)
{
   m_runDecayFactor = MathMax(0.1, MathMin(0.99, runDecayFactor));
   m_runThreshold = (runThreshold > 0.0) ? runThreshold : 3.0;
}

//+------------------------------------------------------------------+
//| تعيين معلمات خوارزمية هيكين-آشي                                   |
//+------------------------------------------------------------------+
void CTrendDetector::SetHeikinAshiParams(int haConsecutive)
{
   m_haConsecutive = (haConsecutive > 0) ? haConsecutive : 3;
}

//+------------------------------------------------------------------+
//| تعيين معلمات خوارزمية النقاط المركبة                               |
//+------------------------------------------------------------------+
void CTrendDetector::SetCompositeParams(const double &weights[], double minScore)
{
   if(ArraySize(weights) >= 8)
   {
      for(int i = 0; i < 8; i++)
      {
         m_compositeWeights[i] = weights[i];
      }
   }
   
   m_minCompositeScore = (minScore > 0.0) ? minScore : 2.0;
}

//+------------------------------------------------------------------+
//| تعيين معلمات خوارزمية الانحراف المعياري                            |
//+------------------------------------------------------------------+
void CTrendDetector::SetSTDParams(int stdPeriod, double stdFactor)
{
   m_stdPeriod = (stdPeriod > 0) ? stdPeriod : m_period;
   m_stdFactor = (stdFactor > 0.0) ? stdFactor : 2.0;
}

//+------------------------------------------------------------------+
//| تعيين معلمات خوارزمية حالة السوق الحيادية                          |
//+------------------------------------------------------------------+
void CTrendDetector::SetSidewaysParams(double mixRatio, int sidewaysPeriod)
{
   m_mixRatio = MathMax(0.1, MathMin(0.5, mixRatio));
   m_sidewaysPeriod = (sidewaysPeriod > 0) ? sidewaysPeriod : m_period;
}

//+------------------------------------------------------------------+
//| تعيين معلمات المتوسطات المتحركة                                    |
//+------------------------------------------------------------------+
void CTrendDetector::SetMAParams(int fastPeriod, int slowPeriod)
{
   m_maFastPeriod = (fastPeriod > 0) ? fastPeriod : 9;
   m_maSlowPeriod = (slowPeriod > 0) ? slowPeriod : 21;
}