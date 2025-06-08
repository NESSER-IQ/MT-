//+------------------------------------------------------------------+
//|                                          TrendLineDetector.mqh |
//|                                  كاشف خطوط الاتجاه المتقدم      |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

// تضمين التعريفات المشتركة
#include "ChartCommonDefs.mqh"

//+------------------------------------------------------------------+
//| نقطة للحسابات                                                   |
//+------------------------------------------------------------------+
struct SPoint
{
   datetime    time;           // الوقت
   double      price;          // السعر
   int         bar_index;      // فهرس الشمعة
   
   SPoint()
   {
      time = 0;
      price = 0.0;
      bar_index = 0;
   }
   
   SPoint(datetime t, double p, int idx)
   {
      time = t;
      price = p;
      bar_index = idx;
   }
};

//+------------------------------------------------------------------+
//| فئة كاشف خطوط الاتجاه                                           |
//+------------------------------------------------------------------+
class CTrendLineDetector
{
private:
   // متغيرات الفئة
   string              m_symbol;                   // الرمز المتداول
   ENUM_TIMEFRAMES     m_timeframe;               // الإطار الزمني
   int                 m_lookback_bars;           // عدد الشموع للبحث
   double              m_min_slope_threshold;     // الحد الأدنى لميل الخط
   double              m_max_slope_threshold;     // الحد الأقصى لميل الخط
   int                 m_min_touches;             // الحد الأدنى لعدد اللمسات
   double              m_tolerance_pips;          // التسامح بالنقاط
   bool                m_initialized;             // حالة التهيئة
   
   // مصفوفات البيانات
   STrendLine          m_trendlines[];            // مصفوفة خطوط الاتجاه
   SPoint              m_highs[];                 // القمم
   SPoint              m_lows[];                  // القيعان
   
   // متغيرات العمل
   int                 m_rates_total;             // العدد الإجمالي للبارات
   MqlRates            m_rates[];                 // بيانات الأسعار
   
public:
   // Constructor & Destructor
   CTrendLineDetector(void);
   ~CTrendLineDetector(void);
   
   // دوال التهيئة
   bool                Initialize(string symbol, ENUM_TIMEFRAMES timeframe);
   void                Deinitialize();
   void                SetParameters(int lookback_bars = 100, 
                                    double min_slope = 0.0001, 
                                    double max_slope = 0.01,
                                    int min_touches = 2,
                                    double tolerance_pips = 5.0);
   
   // دوال الكشف الرئيسية
   bool                DetectTrendLines(void);
   bool                UpdateTrendLines(int startIdx = 0, int endIdx = 0);
   
   // دوال الحصول على النتائج
   int                 GetTrendLinesCount(void) { return ArraySize(m_trendlines); }
   bool                GetTrendLine(int index, STrendLine &trendline);
   bool                GetStrongestTrendLine(ENUM_PATTERN_DIRECTION direction, STrendLine &trendline);
   
   // دوال التحليل
   ENUM_PATTERN_DIRECTION GetOverallTrend(void);
   double              GetTrendStrength(ENUM_PATTERN_DIRECTION direction);
   bool                IsTrendLineValid(const STrendLine &trendline);
   
   // دوال الرسم
   bool                DrawTrendLines(long chart_id = 0);
   bool                RemoveTrendLines(long chart_id = 0);
   
   // دوال الوصول للبيانات
   bool                IsInitialized() const { return m_initialized; }
   string              GetSymbol() const { return m_symbol; }
   ENUM_TIMEFRAMES     GetTimeframe() const { return m_timeframe; }
   
private:
   // دوال مساعدة خاصة
   bool                LoadPriceData(void);
   bool                FindHighsAndLows(void);
   bool                CalculateTrendLine(const SPoint &point1, const SPoint &point2, STrendLine &trendline);
   double              CalculateLineStrength(const STrendLine &trendline);
   int                 CountTouches(const STrendLine &trendline);
   bool                IsPointOnLine(const SPoint &point, const STrendLine &trendline, double tolerance);
   double              GetPriceAtTime(const STrendLine &trendline, datetime time);
   void                SortTrendLinesByStrength(void);
   bool                AddTrendLineToChart(const STrendLine &trendline, long chart_id);
   string              GenerateObjectName(const STrendLine &trendline);
   
   // دوال التحويل بين أنواع النقاط
   SPoint              ChartPointToPoint(const SChartPoint &chartPoint);
   SChartPoint         PointToChartPoint(const SPoint &point);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CTrendLineDetector::CTrendLineDetector(void)
{
   m_symbol = Symbol();
   m_timeframe = Period();
   m_lookback_bars = 100;
   m_min_slope_threshold = 0.0001;
   m_max_slope_threshold = 0.01;
   m_min_touches = 2;
   m_tolerance_pips = 5.0;
   m_rates_total = 0;
   m_initialized = false;
   
   // تهيئة المصفوفات
   ArrayResize(m_trendlines, 0);
   ArrayResize(m_highs, 0);
   ArrayResize(m_lows, 0);
   ArrayResize(m_rates, 0);
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CTrendLineDetector::~CTrendLineDetector(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة الكاشف                                                     |
//+------------------------------------------------------------------+
bool CTrendLineDetector::Initialize(string symbol, ENUM_TIMEFRAMES timeframe)
{
   m_symbol = symbol;
   m_timeframe = timeframe;
   
   if(LoadPriceData())
   {
      m_initialized = true;
      Print("تم تهيئة كاشف خطوط الاتجاه للرمز: ", m_symbol, " الإطار الزمني: ", EnumToString(m_timeframe));
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| إنهاء الكاشف                                                     |
//+------------------------------------------------------------------+
void CTrendLineDetector::Deinitialize()
{
   if(m_initialized)
   {
      RemoveTrendLines();
      ArrayFree(m_trendlines);
      ArrayFree(m_highs);
      ArrayFree(m_lows);
      ArrayFree(m_rates);
      m_initialized = false;
   }
}

//+------------------------------------------------------------------+
//| تحديد المعاملات                                                 |
//+------------------------------------------------------------------+
void CTrendLineDetector::SetParameters(int lookback_bars = 100, 
                                      double min_slope = 0.0001, 
                                      double max_slope = 0.01,
                                      int min_touches = 2,
                                      double tolerance_pips = 5.0)
{
   m_lookback_bars = MathMax(10, lookback_bars);
   m_min_slope_threshold = MathMax(0.00001, min_slope);
   m_max_slope_threshold = MathMax(m_min_slope_threshold, max_slope);
   m_min_touches = MathMax(1, min_touches);
   m_tolerance_pips = MathMax(1.0, tolerance_pips);
}

//+------------------------------------------------------------------+
//| تحميل بيانات الأسعار                                            |
//+------------------------------------------------------------------+
bool CTrendLineDetector::LoadPriceData(void)
{
   int copied = CopyRates(m_symbol, m_timeframe, 0, m_lookback_bars, m_rates);
   
   if(copied <= 0)
   {
      Print("خطأ في تحميل بيانات الأسعار للرمز: ", m_symbol, " الإطار الزمني: ", EnumToString(m_timeframe));
      return false;
   }
   
   m_rates_total = copied;
   ArraySetAsSeries(m_rates, true);
   
   return true;
}

//+------------------------------------------------------------------+
//| البحث عن القمم والقيعان                                         |
//+------------------------------------------------------------------+
bool CTrendLineDetector::FindHighsAndLows(void)
{
   if(m_rates_total < 5) 
      return false;
   
   ArrayResize(m_highs, 0);
   ArrayResize(m_lows, 0);
   
   // البحث عن القمم والقيعان
   for(int i = 2; i < m_rates_total - 2; i++)
   {
      // البحث عن القمم (High أعلى من الشموع المجاورة)
      if(m_rates[i].high > m_rates[i-1].high && 
         m_rates[i].high > m_rates[i-2].high &&
         m_rates[i].high > m_rates[i+1].high && 
         m_rates[i].high > m_rates[i+2].high)
      {
         SPoint high(m_rates[i].time, m_rates[i].high, i);
         
         int size = ArraySize(m_highs);
         ArrayResize(m_highs, size + 1);
         m_highs[size] = high;
      }
      
      // البحث عن القيعان (Low أقل من الشموع المجاورة)
      if(m_rates[i].low < m_rates[i-1].low && 
         m_rates[i].low < m_rates[i-2].low &&
         m_rates[i].low < m_rates[i+1].low && 
         m_rates[i].low < m_rates[i+2].low)
      {
         SPoint low(m_rates[i].time, m_rates[i].low, i);
         
         int size = ArraySize(m_lows);
         ArrayResize(m_lows, size + 1);
         m_lows[size] = low;
      }
   }
   
   return (ArraySize(m_highs) > 0 || ArraySize(m_lows) > 0);
}

//+------------------------------------------------------------------+
//| كشف خطوط الاتجاه                                                |
//+------------------------------------------------------------------+
bool CTrendLineDetector::DetectTrendLines(void)
{
   if(!LoadPriceData()) 
      return false;
   if(!FindHighsAndLows()) 
      return false;
   
   ArrayResize(m_trendlines, 0);
   
   // البحث عن خطوط اتجاه من القمم
   int highs_count = ArraySize(m_highs);
   for(int i = 0; i < highs_count - 1; i++)
   {
      for(int j = i + 1; j < highs_count; j++)
      {
         STrendLine trendline;
         if(CalculateTrendLine(m_highs[i], m_highs[j], trendline))
         {
            if(IsTrendLineValid(trendline))
            {
               int size = ArraySize(m_trendlines);
               ArrayResize(m_trendlines, size + 1);
               m_trendlines[size] = trendline;
            }
         }
      }
   }
   
   // البحث عن خطوط اتجاه من القيعان  
   int lows_count = ArraySize(m_lows);
   for(int i = 0; i < lows_count - 1; i++)
   {
      for(int j = i + 1; j < lows_count; j++)
      {
         STrendLine trendline;
         if(CalculateTrendLine(m_lows[i], m_lows[j], trendline))
         {
            if(IsTrendLineValid(trendline))
            {
               int size = ArraySize(m_trendlines);
               ArrayResize(m_trendlines, size + 1);
               m_trendlines[size] = trendline;
            }
         }
      }
   }
   
   // ترتيب خطوط الاتجاه حسب القوة
   SortTrendLinesByStrength();
   
   return (ArraySize(m_trendlines) > 0);
}

//+------------------------------------------------------------------+
//| حساب خط الاتجاه                                                 |
//+------------------------------------------------------------------+
bool CTrendLineDetector::CalculateTrendLine(const SPoint &point1, const SPoint &point2, STrendLine &trendline)
{
   // حساب الميل
   double time_diff = (double)(point2.time - point1.time);
   if(time_diff == 0) 
      return false;
   
   // تحديث الهيكل بالطريقة الجديدة
   trendline.point1.time = point1.time;
   trendline.point1.price = point1.price;
   trendline.point1.index = point1.bar_index;
   trendline.point1.type = CHART_POINT_HIGH; // سيتم تحديده لاحقاً
   
   trendline.point2.time = point2.time;
   trendline.point2.price = point2.price;
   trendline.point2.index = point2.bar_index;
   trendline.point2.type = CHART_POINT_HIGH; // سيتم تحديده لاحقاً
   
   // تحديث البيانات القديمة للتوافق
   trendline.start_time = point1.time;
   trendline.start_price = point1.price;
   trendline.end_time = point2.time;
   trendline.end_price = point2.price;
   
   trendline.slope = (point2.price - point1.price) / time_diff;
   trendline.angle = CalculateTrendLineAngle(trendline);
   
   // تحديد الاتجاه
   trendline.direction = DetermineTrendDirection(trendline.slope, m_min_slope_threshold);
   
   // حساب عدد اللمسات
   trendline.touches = CountTouches(trendline);
   
   // حساب القوة
   trendline.strength = CalculateLineStrength(trendline);
   
   trendline.isValid = true;
   trendline.chart_id = ChartID();
   trendline.object_name = GenerateObjectName(trendline);
   
   return true;
}

//+------------------------------------------------------------------+
//| حساب عدد اللمسات على خط الاتجاه                                |
//+------------------------------------------------------------------+
int CTrendLineDetector::CountTouches(const STrendLine &trendline)
{
   int touches = 0;
   double tolerance = m_tolerance_pips * SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   
   for(int i = 0; i < m_rates_total; i++)
   {
      if(m_rates[i].time < trendline.start_time || m_rates[i].time > trendline.end_time)
         continue;
         
      double line_price = GetPriceAtTime(trendline, m_rates[i].time);
      
      // فحص ما إذا كانت الشمعة تلمس الخط
      if(MathAbs(m_rates[i].high - line_price) <= tolerance ||
         MathAbs(m_rates[i].low - line_price) <= tolerance)
      {
         touches++;
      }
   }
   
   return touches;
}

//+------------------------------------------------------------------+
//| الحصول على السعر في وقت محدد على خط الاتجاه                    |
//+------------------------------------------------------------------+
double CTrendLineDetector::GetPriceAtTime(const STrendLine &trendline, datetime time)
{
   if(time < trendline.start_time) 
      time = trendline.start_time;
   if(time > trendline.end_time) 
      time = trendline.end_time;
   
   double time_diff = (double)(time - trendline.start_time);
   return trendline.start_price + (trendline.slope * time_diff);
}

//+------------------------------------------------------------------+
//| حساب قوة الخط                                                   |
//+------------------------------------------------------------------+
double CTrendLineDetector::CalculateLineStrength(const STrendLine &trendline)
{
   double strength = 0.0;
   
   // قوة بناءً على عدد اللمسات
   strength += (trendline.touches * 20.0);
   
   // قوة بناءً على طول الخط الزمني
   double time_factor = (double)(trendline.end_time - trendline.start_time) / (24 * 3600);
   strength += MathMin(time_factor * 5.0, 30.0);
   
   // قوة بناءً على الميل
   double slope_factor = MathAbs(trendline.slope) * 10000;
   strength += MathMin(slope_factor * 10.0, 20.0);
   
   return MathMin(strength, 100.0);
}

//+------------------------------------------------------------------+
//| فحص صحة خط الاتجاه                                              |
//+------------------------------------------------------------------+
bool CTrendLineDetector::IsTrendLineValid(const STrendLine &trendline)
{
   // فحص الحد الأدنى لعدد اللمسات
   if(trendline.touches < m_min_touches) 
      return false;
   
   // فحص نطاق الميل
   double abs_slope = MathAbs(trendline.slope);
   if(abs_slope < m_min_slope_threshold || abs_slope > m_max_slope_threshold) 
      return false;
   
   // فحص الحد الأدنى للقوة
   if(trendline.strength < 30.0) 
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| الحصول على خط اتجاه بالفهرس                                     |
//+------------------------------------------------------------------+
bool CTrendLineDetector::GetTrendLine(int index, STrendLine &trendline)
{
   if(index < 0 || index >= ArraySize(m_trendlines)) 
      return false;
   
   trendline = m_trendlines[index];
   return true;
}

//+------------------------------------------------------------------+
//| الحصول على أقوى خط اتجاه حسب الاتجاه                           |
//+------------------------------------------------------------------+
bool CTrendLineDetector::GetStrongestTrendLine(ENUM_PATTERN_DIRECTION direction, STrendLine &trendline)
{
   double max_strength = 0.0;
   int best_index = -1;
   
   for(int i = 0; i < ArraySize(m_trendlines); i++)
   {
      if(m_trendlines[i].direction == direction && m_trendlines[i].strength > max_strength)
      {
         max_strength = m_trendlines[i].strength;
         best_index = i;
      }
   }
   
   if(best_index >= 0)
   {
      trendline = m_trendlines[best_index];
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| الحصول على الاتجاه العام                                        |
//+------------------------------------------------------------------+
ENUM_PATTERN_DIRECTION CTrendLineDetector::GetOverallTrend(void)
{
   double bullish_strength = GetTrendStrength(PATTERN_BULLISH);
   double bearish_strength = GetTrendStrength(PATTERN_BEARISH);
   
   if(bullish_strength > bearish_strength + 20.0)
      return PATTERN_BULLISH;
   else if(bearish_strength > bullish_strength + 20.0)
      return PATTERN_BEARISH;
   else
      return PATTERN_NEUTRAL;
}

//+------------------------------------------------------------------+
//| الحصول على قوة الاتجاه حسب النوع                                |
//+------------------------------------------------------------------+
double CTrendLineDetector::GetTrendStrength(ENUM_PATTERN_DIRECTION direction)
{
   double total_strength = 0.0;
   int count = 0;
   
   for(int i = 0; i < ArraySize(m_trendlines); i++)
   {
      if(m_trendlines[i].direction == direction)
      {
         total_strength += m_trendlines[i].strength;
         count++;
      }
   }
   
   return (count > 0) ? total_strength / count : 0.0;
}

//+------------------------------------------------------------------+
//| ترتيب خطوط الاتجاه حسب القوة                                    |
//+------------------------------------------------------------------+
void CTrendLineDetector::SortTrendLinesByStrength(void)
{
   int count = ArraySize(m_trendlines);
   if(count <= 1) 
      return;
   
   // ترتيب تنازلي حسب القوة (Bubble Sort)
   for(int i = 0; i < count - 1; i++)
   {
      for(int j = 0; j < count - i - 1; j++)
      {
         if(m_trendlines[j].strength < m_trendlines[j + 1].strength)
         {
            STrendLine temp = m_trendlines[j];
            m_trendlines[j] = m_trendlines[j + 1];
            m_trendlines[j + 1] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| توليد اسم كائن فريد                                              |
//+------------------------------------------------------------------+
string CTrendLineDetector::GenerateObjectName(const STrendLine &trendline)
{
   return StringFormat("TrendLine_%s_%d_%d", 
                      EnumToString(trendline.direction),
                      (int)trendline.start_time,
                      (int)trendline.end_time);
}

//+------------------------------------------------------------------+
//| رسم خطوط الاتجاه على المخطط                                     |
//+------------------------------------------------------------------+
bool CTrendLineDetector::DrawTrendLines(long chart_id = 0)
{
   if(chart_id == 0) 
      chart_id = ChartID();
   
   bool success = true;
   
   for(int i = 0; i < ArraySize(m_trendlines); i++)
   {
      if(!AddTrendLineToChart(m_trendlines[i], chart_id))
         success = false;
   }
   
   ChartRedraw(chart_id);
   return success;
}

//+------------------------------------------------------------------+
//| إضافة خط اتجاه للمخطط                                           |
//+------------------------------------------------------------------+
bool CTrendLineDetector::AddTrendLineToChart(const STrendLine &trendline, long chart_id)
{
   // إنشاء خط الاتجاه على الرسم البياني
   if(!ObjectCreate(chart_id, trendline.object_name, OBJ_TREND, 0, 
                   trendline.start_time, trendline.start_price,
                   trendline.end_time, trendline.end_price))
   {
      Print("خطأ في إنشاء كائن خط الاتجاه: ", GetLastError());
      return false;
   }
   
   // تحديد لون الخط حسب الاتجاه
   color line_color;
   switch(trendline.direction)
   {
      case PATTERN_BULLISH: line_color = clrGreen; break;
      case PATTERN_BEARISH: line_color = clrRed; break;
      default: line_color = clrBlue; break;
   }
   
   // تطبيق خصائص الخط
   ObjectSetInteger(chart_id, trendline.object_name, OBJPROP_COLOR, line_color);
   ObjectSetInteger(chart_id, trendline.object_name, OBJPROP_WIDTH, 2);
   ObjectSetInteger(chart_id, trendline.object_name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(chart_id, trendline.object_name, OBJPROP_RAY_RIGHT, true);
   
   // إضافة وصف
   string description = StringFormat("%s خط اتجاه (القوة: %.1f%%)", 
                                    EnumToString(trendline.direction), 
                                    trendline.strength);
   ObjectSetString(chart_id, trendline.object_name, OBJPROP_TOOLTIP, description);
   
   return true;
}

//+------------------------------------------------------------------+
//| إزالة خطوط الاتجاه من المخطط                                    |
//+------------------------------------------------------------------+
bool CTrendLineDetector::RemoveTrendLines(long chart_id = 0)
{
   if(chart_id == 0) 
      chart_id = ChartID();
   
   for(int i = 0; i < ArraySize(m_trendlines); i++)
   {
      ObjectDelete(chart_id, m_trendlines[i].object_name);
   }
   
   ChartRedraw(chart_id);
   return true;
}

//+------------------------------------------------------------------+
//| تحديث خطوط الاتجاه                                              |
//+------------------------------------------------------------------+
bool CTrendLineDetector::UpdateTrendLines(int startIdx = 0, int endIdx = 0)
{
   RemoveTrendLines();
   return DetectTrendLines();
}

//+------------------------------------------------------------------+
//| تحويل SPoint إلى SChartPoint                                    |
//+------------------------------------------------------------------+
SChartPoint CTrendLineDetector::PointToChartPoint(const SPoint &point)
{
   SChartPoint chartPoint;
   chartPoint.time = point.time;
   chartPoint.price = point.price;
   chartPoint.index = point.bar_index;
   chartPoint.type = CHART_POINT_UNKNOWN;
   
   return chartPoint;
}

//+------------------------------------------------------------------+
//| تحويل SChartPoint إلى SPoint                                    |
//+------------------------------------------------------------------+
SPoint CTrendLineDetector::ChartPointToPoint(const SChartPoint &chartPoint)
{
   SPoint point;
   point.time = chartPoint.time;
   point.price = chartPoint.price;
   point.bar_index = chartPoint.index;
   
   return point;
}

//+------------------------------------------------------------------+
//| فحص إذا كانت النقطة على الخط                                    |
//+------------------------------------------------------------------+
bool CTrendLineDetector::IsPointOnLine(const SPoint &point, const STrendLine &trendline, double tolerance)
{
   double line_price = GetPriceAtTime(trendline, point.time);
   return (MathAbs(point.price - line_price) <= tolerance);
}
