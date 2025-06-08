//+------------------------------------------------------------------+
//|                                               ChartPattern.mqh |
//|                               الفئة الأساسية لأنماط المخططات |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

// تضمين التعريفات المشتركة
#include "ChartCommonDefs.mqh"

// إعلان forward للفئة الأساسية لتجنب تضارب الأسماء
class CCandlePattern;

//+------------------------------------------------------------------+
//| الفئة الأساسية لأنماط المخططات                                  |
//+------------------------------------------------------------------+
class CChartPattern
{
protected:
   // معلومات الرمز والإطار الزمني
   string            m_symbol;              // رمز التداول
   ENUM_TIMEFRAMES   m_timeframe;          // الإطار الزمني
   bool              m_initialized;         // حالة التهيئة
   
   // معاملات النمط
   double            m_minPatternHeight;    // أقل ارتفاع للنمط
   double            m_maxPatternHeight;    // أقصى ارتفاع للنمط
   int               m_minPatternBars;      // أقل عدد شموع
   int               m_maxPatternBars;      // أقصى عدد شموع
   double            m_tolerancePercent;   // نسبة التساهل
   
   // معاملات التحليل
   bool              m_useVolumeConfirmation; // استخدام تأكيد الحجم
   bool              m_strictMode;          // الوضع الصارم
   double            m_minVolatility;       // أقل تقلب مطلوب
   
   // بيانات التحليل
   SChartPoint       m_recentHighs[];      // القمم الأخيرة
   SChartPoint       m_recentLows[];       // القيعان الأخيرة
   STrendLine        m_supportLines[];     // خطوط الدعم
   STrendLine        m_resistanceLines[];  // خطوط المقاومة
   
   // نوع النمط
   ENUM_CHART_PATTERN_TYPE m_patternType;
   string            m_patternName;         // اسم النمط
   
public:
   // المنشئ والهادم
                     CChartPattern();
   virtual          ~CChartPattern();
   
   // تهيئة النمط
   virtual bool      Initialize(const string symbol, const ENUM_TIMEFRAMES timeframe);
   virtual void      Deinitialize();
   virtual void      SetParameters(const double minHeight, const double maxHeight, 
                                 const int minBars, const int maxBars);
   
   // الكشف عن الأنماط - دالة افتراضية يجب تنفيذها في الفئات المشتقة
   virtual bool      DetectPattern(const int startIdx, const string symbol, 
                                 const ENUM_TIMEFRAMES timeframe,
                                 const double &open[], const double &high[], 
                                 const double &low[], const double &close[], 
                                 const long &volume[], SChartPatternResult &result) = 0;
   
   // تحليل النمط
   virtual double    CalculatePatternStrength(const SChartPatternResult &result);
   virtual double    CalculateReliability(const SChartPatternResult &result);
   virtual void      CalculateTargets(SChartPatternResult &result);
   
   // تحديد النقاط الرئيسية
   virtual bool      FindKeyPoints(const int startIdx, const int endIdx,
                                 const double &high[], const double &low[],
                                 SChartPoint &keyPoints[]);
   
   // تحليل خطوط الاتجاه
   virtual bool      AnalyzeTrendLines(const SChartPoint &points[], STrendLine &lines[]);
   virtual double    CalculateTrendLineStrength(const STrendLine &line);
   
   // تأكيد الحجم
   virtual bool      ValidateVolumePattern(const SChartPatternResult &result, 
                                         const long &volume[]);
   
   // الوصول للمعاملات
   void              SetMinPatternHeight(const double height) { m_minPatternHeight = height; }
   void              SetMaxPatternHeight(const double height) { m_maxPatternHeight = height; }
   void              SetMinPatternBars(const int bars) { m_minPatternBars = bars; }
   void              SetMaxPatternBars(const int bars) { m_maxPatternBars = bars; }
   void              SetTolerancePercent(const double percent) { m_tolerancePercent = percent; }
   void              SetUseVolumeConfirmation(const bool use) { m_useVolumeConfirmation = use; }
   void              SetStrictMode(const bool strict) { m_strictMode = strict; }
   void              SetPatternType(const ENUM_CHART_PATTERN_TYPE type) { m_patternType = type; }
   void              SetPatternName(const string name) { m_patternName = name; }
   
   double            GetMinPatternHeight() const { return m_minPatternHeight; }
   double            GetMaxPatternHeight() const { return m_maxPatternHeight; }
   int               GetMinPatternBars() const { return m_minPatternBars; }
   int               GetMaxPatternBars() const { return m_maxPatternBars; }
   double            GetTolerancePercent() const { return m_tolerancePercent; }
   bool              GetUseVolumeConfirmation() const { return m_useVolumeConfirmation; }
   bool              GetStrictMode() const { return m_strictMode; }
   ENUM_CHART_PATTERN_TYPE GetPatternType() const { return m_patternType; }
   string            GetPatternName() const { return m_patternName; }
   bool              IsInitialized() const { return m_initialized; }
   
protected:
   // دوال مساعدة
   virtual bool      IsValidPatternHeight(const double height);
   virtual bool      IsValidPatternBars(const int bars);
   virtual double    CalculatePatternHeight(const SChartPoint &highest, const SChartPoint &lowest);
   virtual int       CalculatePatternBars(const datetime startTime, const datetime endTime);
   
   // تحليل القمم والقيعان
   virtual void      UpdateHighsAndLows(const int startIdx, const int endIdx,
                                       const double &high[], const double &low[],
                                       const datetime &time[]);
   
   // تحليل خطوط الدعم والمقاومة
   virtual void      UpdateSupportResistance(const SChartPoint &highs[], const SChartPoint &lows[]);
   
   // دوال التحليل المساعدة
   virtual bool      IsPointValid(const SChartPoint &point);
   virtual double    GetPriceAtIndex(const double &prices[], const int index);
   virtual datetime  GetTimeAtIndex(const int index);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CChartPattern::CChartPattern()
{
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_initialized = false;
   
   m_minPatternHeight = 0.0;
   m_maxPatternHeight = 0.0;
   m_minPatternBars = 5;
   m_maxPatternBars = 200;
   m_tolerancePercent = 2.0;
   
   m_useVolumeConfirmation = false;
   m_strictMode = false;
   m_minVolatility = 0.0;
   m_patternType = CHART_PATTERN_REVERSAL;
   m_patternName = "نمط عام";
   
   ArrayResize(m_recentHighs, 0);
   ArrayResize(m_recentLows, 0);
   ArrayResize(m_supportLines, 0);
   ArrayResize(m_resistanceLines, 0);
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CChartPattern::~CChartPattern()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CChartPattern::Initialize(const string symbol, const ENUM_TIMEFRAMES timeframe)
{
   // تهيئة المتغيرات الأساسية
   m_symbol = (symbol == "") ? Symbol() : symbol;
   m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
   
   // تحديد المعاملات التلقائية بناءً على الإطار الزمني
   switch(timeframe)
   {
      case PERIOD_M1:
      case PERIOD_M5:
         m_minPatternBars = 5;
         m_maxPatternBars = 50;
         m_tolerancePercent = 3.0;
         break;
         
      case PERIOD_M15:
      case PERIOD_M30:
         m_minPatternBars = 8;
         m_maxPatternBars = 100;
         m_tolerancePercent = 2.5;
         break;
         
      case PERIOD_H1:
      case PERIOD_H4:
         m_minPatternBars = 10;
         m_maxPatternBars = 150;
         m_tolerancePercent = 2.0;
         break;
         
      case PERIOD_D1:
      case PERIOD_W1:
         m_minPatternBars = 15;
         m_maxPatternBars = 200;
         m_tolerancePercent = 1.5;
         break;
         
      default:
         m_minPatternBars = 10;
         m_maxPatternBars = 100;
         m_tolerancePercent = 2.0;
         break;
   }
   
   m_initialized = true;
   Print("تم تهيئة نمط المخطط: ", m_patternName, " للرمز: ", m_symbol, " الإطار الزمني: ", EnumToString(m_timeframe));
   
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء النمط                                                     |
//+------------------------------------------------------------------+
void CChartPattern::Deinitialize()
{
   if(m_initialized)
   {
      ArrayFree(m_recentHighs);
      ArrayFree(m_recentLows);
      ArrayFree(m_supportLines);
      ArrayFree(m_resistanceLines);
      m_initialized = false;
   }
}

//+------------------------------------------------------------------+
//| تحديد معاملات النمط                                             |
//+------------------------------------------------------------------+
void CChartPattern::SetParameters(const double minHeight, const double maxHeight, 
                                 const int minBars, const int maxBars)
{
   m_minPatternHeight = MathMax(0.0, minHeight);
   m_maxPatternHeight = MathMax(minHeight, maxHeight);
   m_minPatternBars = MathMax(3, minBars);
   m_maxPatternBars = MathMax(minBars, maxBars);
}

//+------------------------------------------------------------------+
//| حساب قوة النمط                                                  |
//+------------------------------------------------------------------+
double CChartPattern::CalculatePatternStrength(const SChartPatternResult &result)
{
   double strength = 0.0;
   
   // عوامل قوة النمط
   // 1. اكتمال النمط (0-30%)
   strength += (result.completionPercentage / 100.0) * 0.3;
   
   // 2. عدد النقاط الرئيسية (0-20%)
   int pointCount = ArraySize(result.keyPoints);
   if(pointCount >= 3)
      strength += MathMin(pointCount / 10.0, 0.2);
   
   // 3. قوة خطوط الاتجاه (0-25%)
   double avgTrendStrength = 0.0;
   int trendCount = ArraySize(result.trendLines);
   if(trendCount > 0)
   {
      for(int i = 0; i < trendCount; i++)
         avgTrendStrength += result.trendLines[i].strength;
      avgTrendStrength /= trendCount;
      strength += avgTrendStrength * 0.25;
   }
   
   // 4. تأكيد الحجم (0-15%)
   if(result.hasVolConfirmation)
      strength += 0.15;
   
   // 5. ارتفاع النمط (0-10%)
   if(result.patternHeight > 0.0)
   {
      double heightFactor = MathMin(result.patternHeight / (m_maxPatternHeight * 0.5), 1.0);
      strength += heightFactor * 0.1;
   }
   
   return MathMin(strength, 1.0);
}

//+------------------------------------------------------------------+
//| حساب الموثوقية                                                  |
//+------------------------------------------------------------------+
double CChartPattern::CalculateReliability(const SChartPatternResult &result)
{
   double reliability = result.confidence;
   
   // تعديل الموثوقية بناءً على العوامل
   if(result.hasVolConfirmation)
      reliability += 0.1;
   
   if(result.status == CHART_PATTERN_CONFIRMED)
      reliability += 0.15;
   
   if(ArraySize(result.trendLines) >= 2)
      reliability += 0.05;
   
   return MathMin(reliability, 1.0);
}

//+------------------------------------------------------------------+
//| حساب الأهداف                                                    |
//+------------------------------------------------------------------+
void CChartPattern::CalculateTargets(SChartPatternResult &result)
{
   if(ArraySize(result.keyPoints) < 2)
      return;
   
   // حساب ارتفاع النمط
   double patternHeight = result.patternHeight;
   if(patternHeight == 0.0)
      return;
   
   // تحديد نقطة الكسر المتوقعة
   SChartPoint breakoutPoint = result.keyPoints[ArraySize(result.keyPoints) - 1];
   
   // حساب الهدف بناءً على اتجاه النمط
   if(result.direction == PATTERN_BULLISH)
   {
      result.priceTarget = breakoutPoint.price + patternHeight;
      result.stopLoss = breakoutPoint.price - (patternHeight * 0.3);
      result.entryPrice = breakoutPoint.price;
   }
   else if(result.direction == PATTERN_BEARISH)
   {
      result.priceTarget = breakoutPoint.price - patternHeight;
      result.stopLoss = breakoutPoint.price + (patternHeight * 0.3);
      result.entryPrice = breakoutPoint.price;
   }
}

//+------------------------------------------------------------------+
//| البحث عن النقاط الرئيسية                                       |
//+------------------------------------------------------------------+
bool CChartPattern::FindKeyPoints(const int startIdx, const int endIdx,
                                 const double &high[], const double &low[],
                                 SChartPoint &keyPoints[])
{
   ArrayResize(keyPoints, 0);
   
   if(startIdx >= endIdx || endIdx >= ArraySize(high))
      return false;
   
   // البحث عن القمم والقيعان المحلية
   for(int i = startIdx + 1; i < endIdx - 1; i++)
   {
      // فحص القمة المحلية
      if(high[i] > high[i-1] && high[i] > high[i+1])
      {
         SChartPoint point;
         point.index = i;
         point.price = high[i];
         point.time = GetTimeAtIndex(i);
         point.type = CHART_POINT_HIGH;
         
         int size = ArraySize(keyPoints);
         ArrayResize(keyPoints, size + 1);
         keyPoints[size] = point;
      }
      
      // فحص القاع المحلي
      if(low[i] < low[i-1] && low[i] < low[i+1])
      {
         SChartPoint point;
         point.index = i;
         point.price = low[i];
         point.time = GetTimeAtIndex(i);
         point.type = CHART_POINT_LOW;
         
         int size = ArraySize(keyPoints);
         ArrayResize(keyPoints, size + 1);
         keyPoints[size] = point;
      }
   }
   
   return ArraySize(keyPoints) > 0;
}

//+------------------------------------------------------------------+
//| تحليل خطوط الاتجاه                                              |
//+------------------------------------------------------------------+
bool CChartPattern::AnalyzeTrendLines(const SChartPoint &points[], STrendLine &lines[])
{
   ArrayResize(lines, 0);
   
   int pointCount = ArraySize(points);
   if(pointCount < 2)
      return false;
   
   // إنشاء خطوط الاتجاه من النقاط
   for(int i = 0; i < pointCount - 1; i++)
   {
      for(int j = i + 1; j < pointCount; j++)
      {
         if(points[i].type == points[j].type) // نفس نوع النقطة
         {
            STrendLine line;
            line.point1 = points[i];
            line.point2 = points[j];
            
            // حساب الميل والزاوية
            line.slope = CalculateTrendLineSlope(line);
            line.angle = CalculateTrendLineAngle(line);
            line.direction = DetermineTrendDirection(line.slope);
            
            if(IsValidTrendLine(line))
            {
               line.isValid = true;
               line.touches = 2;
               line.strength = CalculateTrendLineStrength(line);
               
               // تحديث البيانات المتوافقة
               line.UpdateFromPoints();
               
               int size = ArraySize(lines);
               ArrayResize(lines, size + 1);
               lines[size] = line;
            }
         }
      }
   }
   
   return ArraySize(lines) > 0;
}

//+------------------------------------------------------------------+
//| حساب قوة خط الاتجاه                                             |
//+------------------------------------------------------------------+
double CChartPattern::CalculateTrendLineStrength(const STrendLine &line)
{
   double strength = 0.0;
   
   // عوامل قوة خط الاتجاه
   // 1. عدد مرات اللمس
   strength += MathMin(line.touches / 5.0, 0.4);
   
   // 2. طول الخط (المدة الزمنية)
   int timeDiff = line.point2.index - line.point1.index;
   strength += MathMin(timeDiff / 50.0, 0.3);
   
   // 3. زاوية الخط (الخطوط المائلة أقوى)
   double absAngle = MathAbs(line.angle);
   if(absAngle > 15.0 && absAngle < 75.0)
      strength += 0.3;
   
   return MathMin(strength, 1.0);
}

//+------------------------------------------------------------------+
//| التحقق من نمط الحجم                                             |
//+------------------------------------------------------------------+
bool CChartPattern::ValidateVolumePattern(const SChartPatternResult &result, 
                                         const long &volume[])
{
   if(!m_useVolumeConfirmation || ArraySize(volume) == 0)
      return true;
   
   // حساب متوسط الحجم
   int startIdx = MathMax(0, ArraySize(volume) - 20);
   long avgVolume = 0;
   int count = 0;
   
   for(int i = startIdx; i < ArraySize(volume); i++)
   {
      avgVolume += volume[i];
      count++;
   }
   
   if(count > 0)
      avgVolume /= count;
   
   // فحص الحجم في النقاط الرئيسية
   for(int i = 0; i < ArraySize(result.keyPoints); i++)
   {
      int idx = result.keyPoints[i].index;
      if(idx >= 0 && idx < ArraySize(volume))
      {
         if(volume[idx] > avgVolume * 1.5) // حجم عالي
            return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| التحقق من صحة ارتفاع النمط                                      |
//+------------------------------------------------------------------+
bool CChartPattern::IsValidPatternHeight(const double height)
{
   if(m_minPatternHeight > 0.0 && height < m_minPatternHeight)
      return false;
      
   if(m_maxPatternHeight > 0.0 && height > m_maxPatternHeight)
      return false;
      
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من صحة عدد الشموع                                        |
//+------------------------------------------------------------------+
bool CChartPattern::IsValidPatternBars(const int bars)
{
   return (bars >= m_minPatternBars && bars <= m_maxPatternBars);
}

//+------------------------------------------------------------------+
//| حساب ارتفاع النمط                                               |
//+------------------------------------------------------------------+
double CChartPattern::CalculatePatternHeight(const SChartPoint &highest, const SChartPoint &lowest)
{
   return MathAbs(highest.price - lowest.price);
}

//+------------------------------------------------------------------+
//| حساب عدد الشموع في النمط                                        |
//+------------------------------------------------------------------+
int CChartPattern::CalculatePatternBars(const datetime startTime, const datetime endTime)
{
   int startIdx = iBarShift(m_symbol, m_timeframe, startTime, false);
   int endIdx = iBarShift(m_symbol, m_timeframe, endTime, false);
   
   if(startIdx < 0 || endIdx < 0)
      return 0;
      
   return MathAbs(startIdx - endIdx) + 1;
}

//+------------------------------------------------------------------+
//| تحديث القمم والقيعان                                            |
//+------------------------------------------------------------------+
void CChartPattern::UpdateHighsAndLows(const int startIdx, const int endIdx,
                                       const double &high[], const double &low[],
                                       const datetime &time[])
{
   ArrayResize(m_recentHighs, 0);
   ArrayResize(m_recentLows, 0);
   
   for(int i = startIdx + 1; i < endIdx - 1; i++)
   {
      // البحث عن القمم
      if(high[i] > high[i-1] && high[i] > high[i+1])
      {
         SChartPoint point(time[i], high[i], i, CHART_POINT_HIGH);
         int size = ArraySize(m_recentHighs);
         ArrayResize(m_recentHighs, size + 1);
         m_recentHighs[size] = point;
      }
      
      // البحث عن القيعان
      if(low[i] < low[i-1] && low[i] < low[i+1])
      {
         SChartPoint point(time[i], low[i], i, CHART_POINT_LOW);
         int size = ArraySize(m_recentLows);
         ArrayResize(m_recentLows, size + 1);
         m_recentLows[size] = point;
      }
   }
}

//+------------------------------------------------------------------+
//| تحديث خطوط الدعم والمقاومة                                      |
//+------------------------------------------------------------------+
void CChartPattern::UpdateSupportResistance(const SChartPoint &highs[], const SChartPoint &lows[])
{
   ArrayResize(m_supportLines, 0);
   ArrayResize(m_resistanceLines, 0);
   
   // إنشاء خطوط المقاومة من القمم
   AnalyzeTrendLines(highs, m_resistanceLines);
   
   // إنشاء خطوط الدعم من القيعان
   AnalyzeTrendLines(lows, m_supportLines);
}

//+------------------------------------------------------------------+
//| دوال مساعدة إضافية                                              |
//+------------------------------------------------------------------+
bool CChartPattern::IsPointValid(const SChartPoint &point)
{
   return IsValidChartPoint(point);
}

double CChartPattern::GetPriceAtIndex(const double &prices[], const int index)
{
   if(index >= 0 && index < ArraySize(prices))
      return prices[index];
   return 0.0;
}

datetime CChartPattern::GetTimeAtIndex(const int index)
{
   return iTime(m_symbol, m_timeframe, index);
}
