//+------------------------------------------------------------------+
//|                                          TrendLineDetector.mqh   |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- Include necessary files
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Pattern Direction Enumeration                                     |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_DIRECTION
{
    PATTERN_NEUTRAL,    // محايد
    PATTERN_BULLISH,    // صعودي  
    PATTERN_BEARISH     // هبوطي
};

//+------------------------------------------------------------------+
//| Trend Line Structure                                              |
//+------------------------------------------------------------------+
struct STrendLine
{
    datetime    start_time;     // وقت بداية الخط
    double      start_price;    // سعر بداية الخط
    datetime    end_time;       // وقت نهاية الخط
    double      end_price;      // سعر نهاية الخط
    double      slope;          // ميل الخط
    int         touches;        // عدد النقاط التي تلمس الخط
    ENUM_PATTERN_DIRECTION direction; // اتجاه الخط
    bool        is_valid;       // هل الخط صالح
    double      strength;       // قوة الخط (0-100)
    long        chart_id;       // معرف الرسم البياني
    string      object_name;    // اسم كائن الخط على الرسم البياني
};

//+------------------------------------------------------------------+
//| Point Structure for calculations                                  |
//+------------------------------------------------------------------+
struct SPoint
{
    datetime    time;           // الوقت
    double      price;          // السعر
    int         bar_index;      // فهرس الشمعة
};

//+------------------------------------------------------------------+
//| Trend Line Detector Class                                         |
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
    
    // مصفوفات البيانات
    STrendLine          m_trendlines[];            // مصفوفة خطوط الاتجاه
    SPoint              m_highs[];                 // القمم
    SPoint              m_lows[];                  // القيعان
    
    // متغيرات العمل
    int                 m_rates_total;             // العدد الإجمالي للبارات
    MqlRates            m_rates[];                 // بيانات الأسعار
    
public:
    // Constructor
    CTrendLineDetector(void);
    
    // Destructor  
    ~CTrendLineDetector(void);
    
    // دوال التهيئة
    bool                Initialize(string symbol, ENUM_TIMEFRAMES timeframe);
    void                SetParameters(int lookback_bars = 100, 
                                    double min_slope = 0.0001, 
                                    double max_slope = 0.01,
                                    int min_touches = 2,
                                    double tolerance_pips = 5.0);
    
    // دوال الكشف الرئيسية
    bool                DetectTrendLines(void);
    bool                UpdateTrendLines(void);
    
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
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
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
    
    // تهيئة المصفوفات
    ArrayResize(m_trendlines, 0);
    ArrayResize(m_highs, 0);
    ArrayResize(m_lows, 0);
    ArrayResize(m_rates, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CTrendLineDetector::~CTrendLineDetector(void)
{
    RemoveTrendLines();
    ArrayFree(m_trendlines);
    ArrayFree(m_highs);
    ArrayFree(m_lows);
    ArrayFree(m_rates);
}

//+------------------------------------------------------------------+
//| Initialize detector                                               |
//+------------------------------------------------------------------+
bool CTrendLineDetector::Initialize(string symbol, ENUM_TIMEFRAMES timeframe)
{
    m_symbol = symbol;
    m_timeframe = timeframe;
    
    return LoadPriceData();
}

//+------------------------------------------------------------------+
//| Set parameters                                                    |
//+------------------------------------------------------------------+
void CTrendLineDetector::SetParameters(int lookback_bars = 100, 
                                      double min_slope = 0.0001, 
                                      double max_slope = 0.01,
                                      int min_touches = 2,
                                      double tolerance_pips = 5.0)
{
    m_lookback_bars = lookback_bars;
    m_min_slope_threshold = min_slope;
    m_max_slope_threshold = max_slope;
    m_min_touches = min_touches;
    m_tolerance_pips = tolerance_pips;
}

//+------------------------------------------------------------------+
//| Load price data                                                   |
//+------------------------------------------------------------------+
bool CTrendLineDetector::LoadPriceData(void)
{
    int copied = CopyRates(m_symbol, m_timeframe, 0, m_lookback_bars, m_rates);
    
    if(copied <= 0)
    {
        Print("Error loading price data for ", m_symbol, " ", EnumToString(m_timeframe));
        return false;
    }
    
    m_rates_total = copied;
    ArraySetAsSeries(m_rates, true);
    
    return true;
}

//+------------------------------------------------------------------+
//| Find highs and lows                                               |
//+------------------------------------------------------------------+
bool CTrendLineDetector::FindHighsAndLows(void)
{
    if(m_rates_total < 5) return false;
    
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
            SPoint high;
            high.time = m_rates[i].time;
            high.price = m_rates[i].high;
            high.bar_index = i;
            
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
            SPoint low;
            low.time = m_rates[i].time;
            low.price = m_rates[i].low;
            low.bar_index = i;
            
            int size = ArraySize(m_lows);
            ArrayResize(m_lows, size + 1);
            m_lows[size] = low;
        }
    }
    
    return (ArraySize(m_highs) > 0 || ArraySize(m_lows) > 0);
}

//+------------------------------------------------------------------+
//| Detect trend lines                                                |
//+------------------------------------------------------------------+
bool CTrendLineDetector::DetectTrendLines(void)
{
    if(!LoadPriceData()) return false;
    if(!FindHighsAndLows()) return false;
    
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
//| Calculate trend line                                              |
//+------------------------------------------------------------------+
bool CTrendLineDetector::CalculateTrendLine(const SPoint &point1, const SPoint &point2, STrendLine &trendline)
{
    // حساب الميل
    double time_diff = (double)(point2.time - point1.time);
    if(time_diff == 0) return false;
    
    trendline.start_time = point1.time;
    trendline.start_price = point1.price;
    trendline.end_time = point2.time;
    trendline.end_price = point2.price;
    
    trendline.slope = (point2.price - point1.price) / time_diff;
    
    // تحديد الاتجاه
    if(trendline.slope > m_min_slope_threshold)
        trendline.direction = PATTERN_BULLISH;
    else if(trendline.slope < -m_min_slope_threshold)
        trendline.direction = PATTERN_BEARISH;
    else
        trendline.direction = PATTERN_NEUTRAL;
    
    // حساب عدد اللمسات
    trendline.touches = CountTouches(trendline);
    
    // حساب القوة
    trendline.strength = CalculateLineStrength(trendline);
    
    trendline.is_valid = true;
    trendline.chart_id = ChartID();
    trendline.object_name = GenerateObjectName(trendline);
    
    return true;
}

//+------------------------------------------------------------------+
//| Count touches on trend line                                       |
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
//| Get price at specific time on trend line                         |
//+------------------------------------------------------------------+
double CTrendLineDetector::GetPriceAtTime(const STrendLine &trendline, datetime time)
{
    if(time < trendline.start_time) time = trendline.start_time;
    if(time > trendline.end_time) time = trendline.end_time;
    
    double time_diff = (double)(time - trendline.start_time);
    return trendline.start_price + (trendline.slope * time_diff);
}

//+------------------------------------------------------------------+
//| Calculate line strength                                           |
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
//| Check if trend line is valid                                      |
//+------------------------------------------------------------------+
bool CTrendLineDetector::IsTrendLineValid(const STrendLine &trendline)
{
    // فحص الحد الأدنى لعدد اللمسات
    if(trendline.touches < m_min_touches) return false;
    
    // فحص نطاق الميل
    double abs_slope = MathAbs(trendline.slope);
    if(abs_slope < m_min_slope_threshold || abs_slope > m_max_slope_threshold) return false;
    
    // فحص الحد الأدنى للقوة
    if(trendline.strength < 30.0) return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| Get trend line by index                                           |
//+------------------------------------------------------------------+
bool CTrendLineDetector::GetTrendLine(int index, STrendLine &trendline)
{
    if(index < 0 || index >= ArraySize(m_trendlines)) return false;
    
    trendline = m_trendlines[index];
    return true;
}

//+------------------------------------------------------------------+
//| Get strongest trend line by direction                             |
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
//| Get overall trend                                                 |
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
//| Get trend strength by direction                                   |
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
//| Sort trend lines by strength                                      |
//+------------------------------------------------------------------+
void CTrendLineDetector::SortTrendLinesByStrength(void)
{
    int count = ArraySize(m_trendlines);
    if(count <= 1) return;
    
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
//| Generate unique object name                                       |
//+------------------------------------------------------------------+
string CTrendLineDetector::GenerateObjectName(const STrendLine &trendline)
{
    return StringFormat("TrendLine_%s_%d_%d", 
                       EnumToString(trendline.direction),
                       (int)trendline.start_time,
                       (int)trendline.end_time);
}

//+------------------------------------------------------------------+
//| Draw trend lines on chart                                         |
//+------------------------------------------------------------------+
bool CTrendLineDetector::DrawTrendLines(long chart_id = 0)
{
    if(chart_id == 0) chart_id = ChartID();
    
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
//| Add trend line to chart                                           |
//+------------------------------------------------------------------+
bool CTrendLineDetector::AddTrendLineToChart(const STrendLine &trendline, long chart_id)
{
    // إنشاء خط الاتجاه على الرسم البياني
    if(!ObjectCreate(chart_id, trendline.object_name, OBJ_TREND, 0, 
                    trendline.start_time, trendline.start_price,
                    trendline.end_time, trendline.end_price))
    {
        Print("Error creating trend line object: ", GetLastError());
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
    string description = StringFormat("%s Trend (Strength: %.1f%%)", 
                                     EnumToString(trendline.direction), 
                                     trendline.strength);
    ObjectSetString(chart_id, trendline.object_name, OBJPROP_TOOLTIP, description);
    
    return true;
}

//+------------------------------------------------------------------+
//| Remove trend lines from chart                                     |
//+------------------------------------------------------------------+
bool CTrendLineDetector::RemoveTrendLines(long chart_id = 0)
{
    if(chart_id == 0) chart_id = ChartID();
    
    for(int i = 0; i < ArraySize(m_trendlines); i++)
    {
        ObjectDelete(chart_id, m_trendlines[i].object_name);
    }
    
    ChartRedraw(chart_id);
    return true;
}

//+------------------------------------------------------------------+
//| Update trend lines                                                |
//+------------------------------------------------------------------+
bool CTrendLineDetector::UpdateTrendLines(void)
{
    RemoveTrendLines();
    return DetectTrendLines();
}

//+------------------------------------------------------------------+