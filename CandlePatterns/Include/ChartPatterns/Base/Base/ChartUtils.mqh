//+------------------------------------------------------------------+
//|                                                 ChartUtils.mqh |
//|                              أدوات مساعدة لتحليل المخططات      |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

// تضمين الملفات المطلوبة
#include "..\..\CandlePatterns\Base\CandleUtils.mqh"

//+------------------------------------------------------------------+
//| تعدادات نوع النقطة                                               |
//+------------------------------------------------------------------+
enum ENUM_CHART_POINT_TYPE
{
   CHART_POINT_UNKNOWN,           // نقطة غير معروفة
   CHART_POINT_HIGH,              // قمة
   CHART_POINT_LOW,               // قاع
   CHART_POINT_SUPPORT,           // دعم
   CHART_POINT_RESISTANCE,        // مقاومة
   CHART_POINT_BREAKOUT,          // اختراق
   CHART_POINT_RETEST             // إعادة اختبار
};

//+------------------------------------------------------------------+
//| هيكل نقطة المخطط                                                |
//+------------------------------------------------------------------+
struct SChartPoint
{
   datetime          time;         // الوقت
   double            price;        // السعر
   int               index;        // الفهرس
   ENUM_CHART_POINT_TYPE type;     // نوع النقطة
   
   SChartPoint()
   {
      time = 0;
      price = 0.0;
      index = -1;
      type = CHART_POINT_UNKNOWN;
   }
   
   SChartPoint(datetime t, double p, int idx, ENUM_CHART_POINT_TYPE pt_type)
   {
      time = t;
      price = p;
      index = idx;
      type = pt_type;
   }
};

//+------------------------------------------------------------------+
//| هيكل خط الاتجاه                                                 |
//+------------------------------------------------------------------+
struct STrendLine
{
   SChartPoint       point1;       // النقطة الأولى
   SChartPoint       point2;       // النقطة الثانية
   double            slope;        // الميل
   double            angle;        // الزاوية
   bool              isValid;      // صحة الخط
   int               touches;      // عدد مرات اللمس
   double            strength;     // قوة خط الاتجاه
   
   STrendLine()
   {
      slope = 0.0;
      angle = 0.0;
      isValid = false;
      touches = 0;
      strength = 0.0;
   }
};

//+------------------------------------------------------------------+
//| هيكل مستوى السعر                                                |
//+------------------------------------------------------------------+
struct SPriceLevel
{
   double            price;            // السعر
   int               touches;          // عدد مرات اللمس
   double            strength;         // قوة المستوى
   datetime          firstTouch;       // أول لمسة
   datetime          lastTouch;        // آخر لمسة
   bool              isSupport;        // مستوى دعم
   bool              isResistance;     // مستوى مقاومة
   bool              isBroken;         // مكسور
   
   SPriceLevel()
   {
      price = 0.0;
      touches = 0;
      strength = 0.0;
      firstTouch = 0;
      lastTouch = 0;
      isSupport = false;
      isResistance = false;
      isBroken = false;
   }
};

//+------------------------------------------------------------------+
//| هيكل مدى التداول                                                |
//+------------------------------------------------------------------+
struct STradingRange
{
   double            upperBound;       // الحد الأعلى
   double            lowerBound;       // الحد الأدنى
   double            midPoint;         // النقطة الوسطى
   double            width;            // العرض
   int               duration;         // المدة بالشموع
   datetime          startTime;        // وقت البداية
   datetime          endTime;          // وقت النهاية
   bool              isActive;         // نشط
   
   STradingRange()
   {
      upperBound = 0.0;
      lowerBound = 0.0;
      midPoint = 0.0;
      width = 0.0;
      duration = 0;
      startTime = 0;
      endTime = 0;
      isActive = false;
   }
};

//+------------------------------------------------------------------+
//| هيكل إحصائيات التقلب                                           |
//+------------------------------------------------------------------+
struct SVolatilityStats
{
   double            averageRange;     // متوسط المدى
   double            averageTrueRange; // متوسط المدى الحقيقي
   double            standardDeviation; // الانحراف المعياري
   double            volatilityRatio;  // نسبة التقلب
   double            currentVolatility; // التقلب الحالي
   
   SVolatilityStats()
   {
      averageRange = 0.0;
      averageTrueRange = 0.0;
      standardDeviation = 0.0;
      volatilityRatio = 0.0;
      currentVolatility = 0.0;
   }
};

//+------------------------------------------------------------------+
//| فئة الأدوات المساعدة للمخططات                                   |
//+------------------------------------------------------------------+
class CChartUtils
{
private:
   // إعدادات الفئة
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   bool              m_initialized;
   
   // بيانات التحليل
   SPriceLevel       m_priceLevels[];     // مستويات الأسعار
   STradingRange     m_tradingRanges[];   // مدى التداول
   SVolatilityStats  m_volatilityStats;   // إحصائيات التقلب
   
   // معاملات التحليل
   double            m_priceTolerancePercent; // نسبة تساهل السعر
   int               m_minTouchesForLevel;    // أقل عدد لمسات للمستوى
   int               m_volatilityPeriod;      // فترة حساب التقلب
   
   // كاش البيانات
   double            m_cachedATR[];           // مخزن ATR
   double            m_cachedRanges[];        // مخزن المديات
   bool              m_dataUpdated;           // حالة تحديث البيانات
   
public:
   // المنشئ والهادم
                     CChartUtils();
                     ~CChartUtils();
   
   // تهيئة الأدوات
   bool              Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   void              Deinitialize();
   
   // تحديث البيانات
   bool              UpdateData(const int startIdx, const int endIdx);
   void              ClearCache();
   
   // تحليل مستويات الأسعار
   int               FindPriceLevels(const int startIdx, const int endIdx,
                                   const double &high[], const double &low[],
                                   SPriceLevel &levels[]);
   int               FindSupportLevels(const int startIdx, const int endIdx,
                                     const double &low[], SPriceLevel &levels[]);
   int               FindResistanceLevels(const int startIdx, const int endIdx,
                                        const double &high[], SPriceLevel &levels[]);
   
   // تحليل مدى التداول
   int               FindTradingRanges(const int startIdx, const int endIdx,
                                     const double &high[], const double &low[],
                                     STradingRange &ranges[]);
   bool              IsInTradingRange(const double price, const STradingRange &range);
   
   // تحليل التقلب
   double            CalculateAverageRange(const int startIdx, const int count,
                                         const double &high[], const double &low[]);
   double            CalculateATR(const int startIdx, const int period,
                                const double &high[], const double &low[], 
                                const double &close[]);
   double            CalculateVolatilityRatio(const int startIdx, const int period,
                                            const double &high[], const double &low[]);
   SVolatilityStats  GetVolatilityStats(const int startIdx, const int period,
                                       const double &high[], const double &low[],
                                       const double &close[]);
   
   // تحليل فيبوناتشي
   void              CalculateFibonacciLevels(const double highPrice, const double lowPrice,
                                            double &levels[], string &labels[]);
   double            GetFibonacciLevel(const double highPrice, const double lowPrice, 
                                     const double ratio);
   bool              IsFibonacciLevel(const double price, const double highPrice, 
                                    const double lowPrice, const double tolerance = 0.001);
   
   // تحليل القمم والقيعان
   int               FindSwingHighs(const int startIdx, const int endIdx, const int strength,
                                  const double &high[], SChartPoint &swings[]);
   int               FindSwingLows(const int startIdx, const int endIdx, const int strength,
                                 const double &low[], SChartPoint &swings[]);
   bool              IsSwingHigh(const int idx, const int strength, const double &high[]);
   bool              IsSwingLow(const int idx, const int strength, const double &low[]);
   
   // تحليل الاختراقات
   bool              IsBreakout(const double currentPrice, const SPriceLevel &level, 
                              const double minimumBreakDistance = 0.0);
   bool              IsValidBreakout(const double breakPrice, const SPriceLevel &level,
                                   const long &volume[], const int volumeIdx,
                                   const bool requireVolumeConfirmation = false);
   
   // تحليل إعادة الاختبار
   bool              IsRetest(const double currentPrice, const SPriceLevel &level,
                            const double tolerance = 0.001);
   bool              IsFalseBreakout(const double &prices[], const int startIdx, const int endIdx,
                                   const SPriceLevel &level);
   
   // أدوات هندسية
   double            CalculateSlope(const SChartPoint &point1, const SChartPoint &point2);
   double            CalculateAngle(const SChartPoint &point1, const SChartPoint &point2);
   double            CalculateDistance(const SChartPoint &point1, const SChartPoint &point2);
   bool              ArePointsAligned(const SChartPoint &points[], const double tolerance = 0.02);
   
   // تحليل الأحجام
   double            CalculateAverageVolume(const int startIdx, const int period,
                                         const long &volume[]);
   bool              IsVolumeSpike(const long currentVolume, const long &volume[],
                                 const int startIdx, const int period, 
                                 const double spikeRatio = 2.0);
   bool              IsVolumeClimaxPattern(const long &volume[], const int startIdx, 
                                         const int endIdx);
   
   // معاملات التحكم
   void              SetPriceTolerancePercent(const double percent) { m_priceTolerancePercent = percent; }
   void              SetMinTouchesForLevel(const int touches) { m_minTouchesForLevel = touches; }
   void              SetVolatilityPeriod(const int period) { m_volatilityPeriod = period; }
   
   double            GetPriceTolerancePercent() const { return m_priceTolerancePercent; }
   int               GetMinTouchesForLevel() const { return m_minTouchesForLevel; }
   int               GetVolatilityPeriod() const { return m_volatilityPeriod; }
   
   // الوصول للبيانات
   int               GetPriceLevelsCount() const { return ArraySize(m_priceLevels); }
   SPriceLevel       GetPriceLevel(const int index) const;
   int               GetTradingRangesCount() const { return ArraySize(m_tradingRanges); }
   STradingRange     GetTradingRange(const int index) const;
   SVolatilityStats  GetCurrentVolatilityStats() const { return m_volatilityStats; }
   
protected:
   // دوال مساعدة
   bool              IsPriceNearLevel(const double price, const double levelPrice, 
                                    const double tolerance);
   void              UpdatePriceLevelStrength(SPriceLevel &level);
   void              SortPriceLevels(SPriceLevel &levels[]);
   
   // تحديث البيانات المخزنة
   void              UpdateVolatilityStats(const int startIdx, const int endIdx,
                                         const double &high[], const double &low[],
                                         const double &close[]);
   void              UpdateATRCache(const int startIdx, const int endIdx,
                                  const double &high[], const double &low[],
                                  const double &close[]);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CChartUtils::CChartUtils()
{
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_initialized = false;
   
   m_priceTolerancePercent = 0.1;  // 0.1%
   m_minTouchesForLevel = 2;
   m_volatilityPeriod = 14;
   m_dataUpdated = false;
   
   ArrayResize(m_priceLevels, 0);
   ArrayResize(m_tradingRanges, 0);
   ArrayResize(m_cachedATR, 0);
   ArrayResize(m_cachedRanges, 0);
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CChartUtils::~CChartUtils()
{
   ClearCache();
}

//+------------------------------------------------------------------+
//| تهيئة الأدوات                                                   |
//+------------------------------------------------------------------+
bool CChartUtils::Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   m_symbol = (symbol == "") ? Symbol() : symbol;
   m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
   
   ClearCache();
   m_initialized = true;
   
   Print("تم تهيئة أدوات المخططات للرمز: ", m_symbol, " الإطار الزمني: ", EnumToString(m_timeframe));
   
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء الأدوات                                                   |
//+------------------------------------------------------------------+
void CChartUtils::Deinitialize()
{
   if(m_initialized)
   {
      ClearCache();
      m_initialized = false;
   }
}

//+------------------------------------------------------------------+
//| تحديث البيانات                                                  |
//+------------------------------------------------------------------+
bool CChartUtils::UpdateData(const int startIdx, const int endIdx)
{
   if(startIdx >= endIdx)
      return false;
   
   // تحضير مصفوفات الأسعار
   int dataSize = endIdx - startIdx + 1;
   double high[], low[], close[];
   ArrayResize(high, dataSize);
   ArrayResize(low, dataSize);
   ArrayResize(close, dataSize);
   
   for(int i = 0; i < dataSize; i++)
   {
      int idx = startIdx + i;
      high[i] = iHigh(m_symbol, m_timeframe, idx);
      low[i] = iLow(m_symbol, m_timeframe, idx);
      close[i] = iClose(m_symbol, m_timeframe, idx);
   }
   
   // تحديث التحليلات
   UpdateVolatilityStats(0, dataSize - 1, high, low, close);
   UpdateATRCache(0, dataSize - 1, high, low, close);
   
   // البحث عن مستويات الأسعار
   FindPriceLevels(0, dataSize - 1, high, low, m_priceLevels);
   
   // البحث عن مدى التداول
   FindTradingRanges(0, dataSize - 1, high, low, m_tradingRanges);
   
   m_dataUpdated = true;
   return true;
}

//+------------------------------------------------------------------+
//| مسح الكاش                                                       |
//+------------------------------------------------------------------+
void CChartUtils::ClearCache()
{
   ArrayResize(m_priceLevels, 0);
   ArrayResize(m_tradingRanges, 0);
   ArrayResize(m_cachedATR, 0);
   ArrayResize(m_cachedRanges, 0);
   m_dataUpdated = false;
}

//+------------------------------------------------------------------+
//| البحث عن مستويات الأسعار                                       |
//+------------------------------------------------------------------+
int CChartUtils::FindPriceLevels(const int startIdx, const int endIdx,
                                const double &high[], const double &low[],
                                SPriceLevel &levels[])
{
   ArrayResize(levels, 0);
   
   if(startIdx >= endIdx || endIdx >= ArraySize(high))
      return 0;
   
   // البحث عن القمم والقيعان
   SChartPoint swingHighs[], swingLows[];
   FindSwingHighs(startIdx, endIdx, 3, high, swingHighs);
   FindSwingLows(startIdx, endIdx, 3, low, swingLows);
   
   // تجميع النقاط في مستويات
   SChartPoint allPoints[];
   int totalPoints = ArraySize(swingHighs) + ArraySize(swingLows);
   ArrayResize(allPoints, totalPoints);
   
   // نسخ القمم
   for(int i = 0; i < ArraySize(swingHighs); i++)
      allPoints[i] = swingHighs[i];
   
   // نسخ القيعان
   for(int i = 0; i < ArraySize(swingLows); i++)
      allPoints[ArraySize(swingHighs) + i] = swingLows[i];
   
   // تجميع النقاط المتقاربة في مستويات
   for(int i = 0; i < totalPoints; i++)
   {
      bool foundLevel = false;
      
      // البحث عن مستوى موجود
      for(int j = 0; j < ArraySize(levels); j++)
      {
         if(IsPriceNearLevel(allPoints[i].price, levels[j].price, 
                           levels[j].price * m_priceTolerancePercent / 100.0))
         {
            levels[j].touches++;
            levels[j].lastTouch = allPoints[i].time;
            
            // تحديث السعر كمتوسط مرجح
            levels[j].price = (levels[j].price * (levels[j].touches - 1) + allPoints[i].price) / levels[j].touches;
            
            UpdatePriceLevelStrength(levels[j]);
            foundLevel = true;
            break;
         }
      }
      
      // إنشاء مستوى جديد
      if(!foundLevel)
      {
         SPriceLevel newLevel;
         newLevel.price = allPoints[i].price;
         newLevel.touches = 1;
         newLevel.firstTouch = allPoints[i].time;
         newLevel.lastTouch = allPoints[i].time;
         newLevel.isSupport = (allPoints[i].type == CHART_POINT_LOW);
         newLevel.isResistance = (allPoints[i].type == CHART_POINT_HIGH);
         
         UpdatePriceLevelStrength(newLevel);
         
         int size = ArraySize(levels);
         ArrayResize(levels, size + 1);
         levels[size] = newLevel;
      }
   }
   
   // تصفية المستويات الضعيفة
   SPriceLevel filteredLevels[];
   ArrayResize(filteredLevels, 0);
   
   for(int i = 0; i < ArraySize(levels); i++)
   {
      if(levels[i].touches >= m_minTouchesForLevel)
      {
         int size = ArraySize(filteredLevels);
         ArrayResize(filteredLevels, size + 1);
         filteredLevels[size] = levels[i];
      }
   }
   
   // ترتيب المستويات
   SortPriceLevels(filteredLevels);
   ArrayCopy(levels, filteredLevels);
   
   return ArraySize(levels);
}

//+------------------------------------------------------------------+
//| البحث عن مستويات الدعم                                         |
//+------------------------------------------------------------------+
int CChartUtils::FindSupportLevels(const int startIdx, const int endIdx,
                                  const double &low[], SPriceLevel &levels[])
{
   ArrayResize(levels, 0);
   
   SChartPoint swingLows[];
   FindSwingLows(startIdx, endIdx, 3, low, swingLows);
   
   // تحويل النقاط إلى مستويات دعم
   for(int i = 0; i < ArraySize(swingLows); i++)
   {
      SPriceLevel level;
      level.price = swingLows[i].price;
      level.touches = 1;
      level.firstTouch = swingLows[i].time;
      level.lastTouch = swingLows[i].time;
      level.isSupport = true;
      level.isResistance = false;
      
      UpdatePriceLevelStrength(level);
      
      int size = ArraySize(levels);
      ArrayResize(levels, size + 1);
      levels[size] = level;
   }
   
   return ArraySize(levels);
}

//+------------------------------------------------------------------+
//| البحث عن مستويات المقاومة                                      |
//+------------------------------------------------------------------+
int CChartUtils::FindResistanceLevels(const int startIdx, const int endIdx,
                                     const double &high[], SPriceLevel &levels[])
{
   ArrayResize(levels, 0);
   
   SChartPoint swingHighs[];
   FindSwingHighs(startIdx, endIdx, 3, high, swingHighs);
   
   // تحويل النقاط إلى مستويات مقاومة
   for(int i = 0; i < ArraySize(swingHighs); i++)
   {
      SPriceLevel level;
      level.price = swingHighs[i].price;
      level.touches = 1;
      level.firstTouch = swingHighs[i].time;
      level.lastTouch = swingHighs[i].time;
      level.isSupport = false;
      level.isResistance = true;
      
      UpdatePriceLevelStrength(level);
      
      int size = ArraySize(levels);
      ArrayResize(levels, size + 1);
      levels[size] = level;
   }
   
   return ArraySize(levels);
}

//+------------------------------------------------------------------+
//| البحث عن مدى التداول                                           |
//+------------------------------------------------------------------+
int CChartUtils::FindTradingRanges(const int startIdx, const int endIdx,
                                  const double &high[], const double &low[],
                                  STradingRange &ranges[])
{
   ArrayResize(ranges, 0);
   
   if(endIdx - startIdx < 20) // مدى قصير جداً
      return 0;
   
   // البحث عن مناطق التداول المستقر
   for(int i = startIdx; i <= endIdx - 20; i++)
   {
      double maxHigh = high[i];
      double minLow = low[i];
      
      // حساب المدى لفترة 20 شمعة
      for(int j = i; j < i + 20 && j < ArraySize(high); j++)
      {
         if(high[j] > maxHigh) maxHigh = high[j];
         if(low[j] < minLow) minLow = low[j];
      }
      
      double rangeWidth = maxHigh - minLow;
      double avgATR = (ArraySize(m_cachedATR) > 0) ? m_cachedATR[MathMin(i / m_volatilityPeriod, ArraySize(m_cachedATR) - 1)] : rangeWidth;
      
      // فحص إذا كان المدى ضيق نسبياً
      if(rangeWidth <= avgATR * 2.0)
      {
         STradingRange range;
         range.upperBound = maxHigh;
         range.lowerBound = minLow;
         range.midPoint = (maxHigh + minLow) / 2.0;
         range.width = rangeWidth;
         range.duration = 20;
         range.startTime = iTime(m_symbol, m_timeframe, i);
         range.endTime = iTime(m_symbol, m_timeframe, i + 19);
         range.isActive = true;
         
         int size = ArraySize(ranges);
         ArrayResize(ranges, size + 1);
         ranges[size] = range;
         
         i += 10; // تجنب التداخل
      }
   }
   
   return ArraySize(ranges);
}

//+------------------------------------------------------------------+
//| فحص إذا كان السعر في مدى التداول                               |
//+------------------------------------------------------------------+
bool CChartUtils::IsInTradingRange(const double price, const STradingRange &range)
{
   return (price >= range.lowerBound && price <= range.upperBound);
}

//+------------------------------------------------------------------+
//| حساب متوسط المدى                                                |
//+------------------------------------------------------------------+
double CChartUtils::CalculateAverageRange(const int startIdx, const int count,
                                         const double &high[], const double &low[])
{
   if(count <= 0 || startIdx + count > ArraySize(high))
      return 0.0;
   
   double totalRange = 0.0;
   
   for(int i = startIdx; i < startIdx + count; i++)
      totalRange += (high[i] - low[i]);
   
   return totalRange / count;
}

//+------------------------------------------------------------------+
//| حساب متوسط المدى الحقيقي (ATR)                                  |
//+------------------------------------------------------------------+
double CChartUtils::CalculateATR(const int startIdx, const int period,
                                const double &high[], const double &low[], 
                                const double &close[])
{
   if(period <= 0 || startIdx + period > ArraySize(high))
      return 0.0;
   
   double totalTR = 0.0;
   
   for(int i = startIdx; i < startIdx + period; i++)
   {
      double tr = high[i] - low[i];
      
      if(i > 0)
      {
         tr = MathMax(tr, MathAbs(high[i] - close[i-1]));
         tr = MathMax(tr, MathAbs(low[i] - close[i-1]));
      }
      
      totalTR += tr;
   }
   
   return totalTR / period;
}

//+------------------------------------------------------------------+
//| حساب نسبة التقلب                                                |
//+------------------------------------------------------------------+
double CChartUtils::CalculateVolatilityRatio(const int startIdx, const int period,
                                            const double &high[], const double &low[])
{
   if(period <= 1)
      return 0.0;
   
   double currentRange = CalculateAverageRange(startIdx, 1, high, low);
   double avgRange = CalculateAverageRange(startIdx - period + 1, period, high, low);
   
   if(avgRange == 0.0)
      return 0.0;
   
   return currentRange / avgRange;
}

//+------------------------------------------------------------------+
//| الحصول على إحصائيات التقلب                                     |
//+------------------------------------------------------------------+
SVolatilityStats CChartUtils::GetVolatilityStats(const int startIdx, const int period,
                                                const double &high[], const double &low[],
                                                const double &close[])
{
   SVolatilityStats stats;
   
   if(period <= 0 || startIdx + period > ArraySize(high))
      return stats;
   
   stats.averageRange = CalculateAverageRange(startIdx, period, high, low);
   stats.averageTrueRange = CalculateATR(startIdx, period, high, low, close);
   stats.volatilityRatio = CalculateVolatilityRatio(startIdx + period - 1, period, high, low);
   stats.currentVolatility = (high[startIdx + period - 1] - low[startIdx + period - 1]);
   
   // حساب الانحراف المعياري
   double mean = stats.averageRange;
   double variance = 0.0;
   
   for(int i = startIdx; i < startIdx + period; i++)
   {
      double range = high[i] - low[i];
      variance += MathPow(range - mean, 2);
   }
   
   stats.standardDeviation = MathSqrt(variance / period);
   
   return stats;
}

//+------------------------------------------------------------------+
//| حساب مستويات فيبوناتشي                                          |
//+------------------------------------------------------------------+
void CChartUtils::CalculateFibonacciLevels(const double highPrice, const double lowPrice,
                                          double &levels[], string &labels[])
{
   double fibRatios[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.618, 2.618};
   string fibLabels[] = {"0%", "23.6%", "38.2%", "50%", "61.8%", "78.6%", "100%", "127.2%", "161.8%", "261.8%"};
   
   int count = ArraySize(fibRatios);
   ArrayResize(levels, count);
   ArrayResize(labels, count);
   
   double range = highPrice - lowPrice;
   
   for(int i = 0; i < count; i++)
   {
      levels[i] = highPrice - (range * fibRatios[i]);
      labels[i] = fibLabels[i];
   }
}

//+------------------------------------------------------------------+
//| الحصول على مستوى فيبوناتشي                                     |
//+------------------------------------------------------------------+
double CChartUtils::GetFibonacciLevel(const double highPrice, const double lowPrice, 
                                     const double ratio)
{
   return highPrice - ((highPrice - lowPrice) * ratio);
}

//+------------------------------------------------------------------+
//| فحص إذا كان السعر على مستوى فيبوناتشي                         |
//+------------------------------------------------------------------+
bool CChartUtils::IsFibonacciLevel(const double price, const double highPrice, 
                                  const double lowPrice, const double tolerance = 0.001)
{
   double fibRatios[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0};
   
   for(int i = 0; i < ArraySize(fibRatios); i++)
   {
      double fibLevel = GetFibonacciLevel(highPrice, lowPrice, fibRatios[i]);
      if(MathAbs(price - fibLevel) <= tolerance * (highPrice - lowPrice))
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| البحث عن القمم المتأرجحة                                        |
//+------------------------------------------------------------------+
int CChartUtils::FindSwingHighs(const int startIdx, const int endIdx, const int strength,
                               const double &high[], SChartPoint &swings[])
{
   ArrayResize(swings, 0);
   
   for(int i = startIdx + strength; i <= endIdx - strength; i++)
   {
      if(IsSwingHigh(i, strength, high))
      {
         SChartPoint point;
         point.index = i;
         point.price = high[i];
         point.time = iTime(m_symbol, m_timeframe, i);
         point.type = CHART_POINT_HIGH;
         
         int size = ArraySize(swings);
         ArrayResize(swings, size + 1);
         swings[size] = point;
      }
   }
   
   return ArraySize(swings);
}

//+------------------------------------------------------------------+
//| البحث عن القيعان المتأرجحة                                      |
//+------------------------------------------------------------------+
int CChartUtils::FindSwingLows(const int startIdx, const int endIdx, const int strength,
                              const double &low[], SChartPoint &swings[])
{
   ArrayResize(swings, 0);
   
   for(int i = startIdx + strength; i <= endIdx - strength; i++)
   {
      if(IsSwingLow(i, strength, low))
      {
         SChartPoint point;
         point.index = i;
         point.price = low[i];
         point.time = iTime(m_symbol, m_timeframe, i);
         point.type = CHART_POINT_LOW;
         
         int size = ArraySize(swings);
         ArrayResize(swings, size + 1);
         swings[size] = point;
      }
   }
   
   return ArraySize(swings);
}

//+------------------------------------------------------------------+
//| فحص إذا كانت قمة متأرجحة                                        |
//+------------------------------------------------------------------+
bool CChartUtils::IsSwingHigh(const int idx, const int strength, const double &high[])
{
   if(idx < strength || idx >= ArraySize(high) - strength)
      return false;
   
   for(int i = idx - strength; i <= idx + strength; i++)
   {
      if(i != idx && high[i] >= high[idx])
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص إذا كان قاع متأرجح                                          |
//+------------------------------------------------------------------+
bool CChartUtils::IsSwingLow(const int idx, const int strength, const double &low[])
{
   if(idx < strength || idx >= ArraySize(low) - strength)
      return false;
   
   for(int i = idx - strength; i <= idx + strength; i++)
   {
      if(i != idx && low[i] <= low[idx])
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص الاختراق                                                    |
//+------------------------------------------------------------------+
bool CChartUtils::IsBreakout(const double currentPrice, const SPriceLevel &level, 
                            const double minimumBreakDistance = 0.0)
{
   double breakDistance = MathAbs(currentPrice - level.price);
   
   if(minimumBreakDistance > 0.0 && breakDistance < minimumBreakDistance)
      return false;
   
   if(level.isResistance && currentPrice > level.price)
      return true;
   
   if(level.isSupport && currentPrice < level.price)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| فحص صحة الاختراق                                                |
//+------------------------------------------------------------------+
bool CChartUtils::IsValidBreakout(const double breakPrice, const SPriceLevel &level,
                                 const long &volume[], const int volumeIdx,
                                 const bool requireVolumeConfirmation = false)
{
   // فحص الاختراق الأساسي
   if(!IsBreakout(breakPrice, level))
      return false;
   
   // فحص تأكيد الحجم إذا كان مطلوب
   if(requireVolumeConfirmation && ArraySize(volume) > volumeIdx)
   {
      double avgVolume = CalculateAverageVolume(MathMax(0, volumeIdx - 10), 10, volume);
      if(volume[volumeIdx] < avgVolume * 1.5) // حجم أقل من 1.5 ضعف المتوسط
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص إعادة الاختبار                                              |
//+------------------------------------------------------------------+
bool CChartUtils::IsRetest(const double currentPrice, const SPriceLevel &level,
                          const double tolerance = 0.001)
{
   return IsPriceNearLevel(currentPrice, level.price, tolerance);
}

//+------------------------------------------------------------------+
//| فحص الاختراق الكاذب                                             |
//+------------------------------------------------------------------+
bool CChartUtils::IsFalseBreakout(const double &prices[], const int startIdx, const int endIdx,
                                 const SPriceLevel &level)
{
   if(startIdx >= endIdx || endIdx >= ArraySize(prices))
      return false;
   
   bool hadBreakout = false;
   bool returnedToLevel = false;
   
   for(int i = startIdx; i <= endIdx; i++)
   {
      if(IsBreakout(prices[i], level))
         hadBreakout = true;
      else if(hadBreakout && IsRetest(prices[i], level, level.price * 0.002))
         returnedToLevel = true;
   }
   
   return (hadBreakout && returnedToLevel);
}

//+------------------------------------------------------------------+
//| حساب الميل                                                      |
//+------------------------------------------------------------------+
double CChartUtils::CalculateSlope(const SChartPoint &point1, const SChartPoint &point2)
{
   if(point2.index == point1.index)
      return 0.0;
   
   return (point2.price - point1.price) / (point2.index - point1.index);
}

//+------------------------------------------------------------------+
//| حساب الزاوية                                                    |
//+------------------------------------------------------------------+
double CChartUtils::CalculateAngle(const SChartPoint &point1, const SChartPoint &point2)
{
   double slope = CalculateSlope(point1, point2);
   return MathArctan(slope) * 180.0 / M_PI;
}

//+------------------------------------------------------------------+
//| حساب المسافة                                                    |
//+------------------------------------------------------------------+
double CChartUtils::CalculateDistance(const SChartPoint &point1, const SChartPoint &point2)
{
   double priceDistance = MathAbs(point2.price - point1.price);
   double timeDistance = MathAbs(point2.index - point1.index);
   
   return MathSqrt(priceDistance * priceDistance + timeDistance * timeDistance);
}

//+------------------------------------------------------------------+
//| فحص محاذاة النقاط                                               |
//+------------------------------------------------------------------+
bool CChartUtils::ArePointsAligned(const SChartPoint &points[], const double tolerance = 0.02)
{
   int count = ArraySize(points);
   if(count < 3)
      return true;
   
   // حساب خط الانحدار الخطي
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
   
   for(int i = 0; i < count; i++)
   {
      double x = points[i].index;
      double y = points[i].price;
      
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
   }
   
   double slope = (count * sumXY - sumX * sumY) / (count * sumX2 - sumX * sumX);
   double intercept = (sumY - slope * sumX) / count;
   
   // فحص انحراف النقاط عن الخط
   for(int i = 0; i < count; i++)
   {
      double expectedY = slope * points[i].index + intercept;
      double deviation = MathAbs(points[i].price - expectedY) / points[i].price;
      
      if(deviation > tolerance)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| حساب متوسط الحجم                                                |
//+------------------------------------------------------------------+
double CChartUtils::CalculateAverageVolume(const int startIdx, const int period,
                                         const long &volume[])
{
   if(period <= 0 || startIdx + period > ArraySize(volume))
      return 0.0;
   
   long totalVolume = 0;
   
   for(int i = startIdx; i < startIdx + period; i++)
      totalVolume += volume[i];
   
   return (double)totalVolume / period;
}

//+------------------------------------------------------------------+
//| فحص ارتفاع الحجم                                                |
//+------------------------------------------------------------------+
bool CChartUtils::IsVolumeSpike(const long currentVolume, const long &volume[],
                               const int startIdx, const int period, 
                               const double spikeRatio = 2.0)
{
   double avgVolume = CalculateAverageVolume(startIdx, period, volume);
   return (currentVolume >= avgVolume * spikeRatio);
}

//+------------------------------------------------------------------+
//| فحص نمط ذروة الحجم                                              |
//+------------------------------------------------------------------+
bool CChartUtils::IsVolumeClimaxPattern(const long &volume[], const int startIdx, 
                                       const int endIdx)
{
   if(endIdx - startIdx < 3)
      return false;
   
   // البحث عن أعلى حجم في الفترة
   long maxVolume = volume[startIdx];
   int maxIndex = startIdx;
   
   for(int i = startIdx + 1; i <= endIdx; i++)
   {
      if(volume[i] > maxVolume)
      {
         maxVolume = volume[i];
         maxIndex = i;
      }
   }
   
   // فحص إذا كان الحجم في المنتصف تقريباً وأعلى من المتوسط بكثير
   double avgVolume = CalculateAverageVolume(startIdx, endIdx - startIdx + 1, volume);
   
   return (maxVolume >= avgVolume * 3.0 && 
           maxIndex > startIdx + 1 && 
           maxIndex < endIdx - 1);
}

//+------------------------------------------------------------------+
//| فحص قرب السعر من المستوى                                        |
//+------------------------------------------------------------------+
bool CChartUtils::IsPriceNearLevel(const double price, const double levelPrice, 
                                  const double tolerance)
{
   return (MathAbs(price - levelPrice) <= tolerance);
}

//+------------------------------------------------------------------+
//| تحديث قوة مستوى السعر                                           |
//+------------------------------------------------------------------+
void CChartUtils::UpdatePriceLevelStrength(SPriceLevel &level)
{
   // حساب القوة بناءً على عدد اللمسات والعمر
   double touchStrength = MathMin(level.touches / 5.0, 1.0); // 0-1
   
   // حساب قوة العمر (الخطوط الأقدم أقوى)
   long currentTime = TimeCurrent();
   long ageSeconds = currentTime - level.firstTouch;
   double ageDays = ageSeconds / 86400.0; // تحويل إلى أيام
   double ageStrength = MathMin(ageDays / 30.0, 1.0); // 0-1 (30 يوم = قوة كاملة)
   
   level.strength = (touchStrength * 0.7) + (ageStrength * 0.3);
}

//+------------------------------------------------------------------+
//| ترتيب مستويات الأسعار                                          |
//+------------------------------------------------------------------+
void CChartUtils::SortPriceLevels(SPriceLevel &levels[])
{
   int count = ArraySize(levels);
   if(count <= 1)
      return;
   
   // ترتيب حسب القوة (الأعلى أولاً)
   for(int i = 0; i < count - 1; i++)
   {
      for(int j = 0; j < count - i - 1; j++)
      {
         if(levels[j].strength < levels[j + 1].strength)
         {
            SPriceLevel temp = levels[j];
            levels[j] = levels[j + 1];
            levels[j + 1] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| تحديث إحصائيات التقلب                                           |
//+------------------------------------------------------------------+
void CChartUtils::UpdateVolatilityStats(const int startIdx, const int endIdx,
                                       const double &high[], const double &low[],
                                       const double &close[])
{
   int period = MathMin(m_volatilityPeriod, endIdx - startIdx + 1);
   m_volatilityStats = GetVolatilityStats(endIdx - period + 1, period, high, low, close);
}

//+------------------------------------------------------------------+
//| تحديث كاش ATR                                                   |
//+------------------------------------------------------------------+
void CChartUtils::UpdateATRCache(const int startIdx, const int endIdx,
                                const double &high[], const double &low[],
                                const double &close[])
{
   int dataSize = endIdx - startIdx + 1;
   int cacheSize = dataSize / m_volatilityPeriod;
   
   ArrayResize(m_cachedATR, cacheSize);
   
   for(int i = 0; i < cacheSize; i++)
   {
      int idx = startIdx + (i * m_volatilityPeriod);
      if(idx + m_volatilityPeriod <= dataSize)
      {
         m_cachedATR[i] = CalculateATR(idx, m_volatilityPeriod, high, low, close);
      }
   }
}

//+------------------------------------------------------------------+
//| الحصول على مستوى سعر                                           |
//+------------------------------------------------------------------+
SPriceLevel CChartUtils::GetPriceLevel(const int index) const
{
   SPriceLevel emptyLevel;
   
   if(index < 0 || index >= ArraySize(m_priceLevels))
      return emptyLevel;
   
   return m_priceLevels[index];
}

//+------------------------------------------------------------------+
//| الحصول على مدى التداول                                          |
//+------------------------------------------------------------------+
STradingRange CChartUtils::GetTradingRange(const int index) const
{
   STradingRange emptyRange;
   
   if(index < 0 || index >= ArraySize(m_tradingRanges))
      return emptyRange;
   
   return m_tradingRanges[index];
}
