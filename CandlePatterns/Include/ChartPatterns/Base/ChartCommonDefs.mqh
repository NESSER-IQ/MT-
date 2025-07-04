//+------------------------------------------------------------------+
//|                                            ChartCommonDefs.mqh |
//|                         التعريفات المشتركة لأنماط المخططات      |
//|                 حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#ifndef CHART_COMMON_DEFS_MQH
#define CHART_COMMON_DEFS_MQH

//+------------------------------------------------------------------+
//| تعدادات أساسية                                                  |
//+------------------------------------------------------------------+

// أنواع النقاط في المخطط
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

// اتجاه النمط
enum ENUM_PATTERN_DIRECTION
{
   PATTERN_NEUTRAL,               // محايد
   PATTERN_BULLISH,               // صعودي  
   PATTERN_BEARISH                // هبوطي
};

// أنواع أنماط المخططات
enum ENUM_CHART_PATTERN_TYPE
{
   CHART_PATTERN_REVERSAL,        // أنماط الانعكاس
   CHART_PATTERN_CONTINUATION,    // أنماط الاستمرار
   CHART_PATTERN_BILATERAL,       // أنماط ثنائية الاتجاه
   CHART_PATTERN_HARMONIC,        // أنماط توافقية
   CHART_PATTERN_ELLIOTT,         // أمواج إليوت
   CHART_PATTERN_VOLUME,          // أنماط الحجم
   CHART_PATTERN_ADVANCED         // أنماط متقدمة
};

// حالة النمط
enum ENUM_CHART_PATTERN_STATUS
{
   CHART_PATTERN_FORMING,         // النمط قيد التكوين
   CHART_PATTERN_COMPLETED,       // النمط مكتمل
   CHART_PATTERN_CONFIRMED,       // النمط مؤكد
   CHART_PATTERN_FAILED,          // النمط فاشل
   CHART_PATTERN_PENDING          // النمط قيد الانتظار
};

// مستوى الموثوقية
enum ENUM_CHART_PATTERN_RELIABILITY
{
   CHART_RELIABILITY_LOW,         // موثوقية منخفضة (0-30%)
   CHART_RELIABILITY_MEDIUM,      // موثوقية متوسطة (30-60%)
   CHART_RELIABILITY_HIGH,        // موثوقية عالية (60-85%)
   CHART_RELIABILITY_VERY_HIGH    // موثوقية عالية جداً (85-100%)
};

//+------------------------------------------------------------------+
//| هياكل البيانات الأساسية                                         |
//+------------------------------------------------------------------+

// هيكل نقطة المخطط
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

// هيكل خط الاتجاه الموحد
struct STrendLine
{
   SChartPoint       point1;       // النقطة الأولى
   SChartPoint       point2;       // النقطة الثانية
   double            slope;        // الميل
   double            angle;        // الزاوية
   bool              isValid;      // صحة الخط
   int               touches;      // عدد مرات اللمس
   double            strength;     // قوة خط الاتجاه
   ENUM_PATTERN_DIRECTION direction; // اتجاه الخط
   
   // إضافات للتوافق مع TrendLineDetector
   datetime          start_time;   // وقت بداية الخط
   double            start_price;  // سعر بداية الخط
   datetime          end_time;     // وقت نهاية الخط
   double            end_price;    // سعر نهاية الخط
   long              chart_id;     // معرف الرسم البياني
   string            object_name;  // اسم كائن الخط على الرسم البياني
   
   STrendLine()
   {
      slope = 0.0;
      angle = 0.0;
      isValid = false;
      touches = 0;
      strength = 0.0;
      direction = PATTERN_NEUTRAL;
      start_time = 0;
      start_price = 0.0;
      end_time = 0;
      end_price = 0.0;
      chart_id = 0;
      object_name = "";
   }
   
   // دالة للتحويل من الهيكل الجديد
   void UpdateFromPoints()
   {
      start_time = point1.time;
      start_price = point1.price;
      end_time = point2.time;  
      end_price = point2.price;
   }
   
   // دالة للتحويل إلى الهيكل الجديد
   void UpdateToPoints()
   {
      point1.time = start_time;
      point1.price = start_price;
      point2.time = end_time;
      point2.price = end_price;
   }
};

// هيكل مستوى السعر
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

// هيكل مدى التداول
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

// هيكل إحصائيات التقلب
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

// هيكل نتيجة اكتشاف نمط المخطط
struct SChartPatternResult
{
   string            patternName;           // اسم النمط
   ENUM_CHART_PATTERN_TYPE patternType;     // نوع النمط
   ENUM_CHART_PATTERN_STATUS status;        // حالة النمط
   ENUM_PATTERN_DIRECTION direction;        // اتجاه النمط
   ENUM_CHART_PATTERN_RELIABILITY reliability; // الموثوقية
   
   double            confidence;            // مستوى الثقة (0-1)
   double            completionPercentage;  // نسبة الاكتمال (0-100)
   
   SChartPoint       keyPoints[];          // النقاط الرئيسية
   STrendLine        trendLines[];         // خطوط الاتجاه
   
   double            priceTarget;          // الهدف السعري
   double            stopLoss;             // وقف الخسارة
   double            entryPrice;           // سعر الدخول
   
   datetime          formationStart;       // بداية التكوين
   datetime          formationEnd;         // نهاية التكوين
   datetime          detectionTime;        // وقت الاكتشاف
   
   int               barsInPattern;        // عدد الشموع في النمط
   double            patternHeight;        // ارتفاع النمط
   double            patternWidth;         // عرض النمط
   
   bool              isActive;             // النمط نشط
   bool              isCompleted;          // النمط مكتمل
   bool              hasVolConfirmation;   // تأكيد الحجم
   
   SChartPatternResult()
   {
      patternName = "";
      patternType = CHART_PATTERN_REVERSAL;
      status = CHART_PATTERN_FORMING;
      direction = PATTERN_NEUTRAL;
      reliability = CHART_RELIABILITY_LOW;
      
      confidence = 0.0;
      completionPercentage = 0.0;
      
      ArrayResize(keyPoints, 0);
      ArrayResize(trendLines, 0);
      
      priceTarget = 0.0;
      stopLoss = 0.0;
      entryPrice = 0.0;
      
      formationStart = 0;
      formationEnd = 0;
      detectionTime = 0;
      
      barsInPattern = 0;
      patternHeight = 0.0;
      patternWidth = 0.0;
      
      isActive = false;
      isCompleted = false;
      hasVolConfirmation = false;
   }
};

//+------------------------------------------------------------------+
//| دوال مساعدة عامة                                                |
//+------------------------------------------------------------------+

// تحويل قيمة الثقة إلى مستوى موثوقية
ENUM_CHART_PATTERN_RELIABILITY ConfidenceToReliability(double confidence)
{
   if(confidence >= 0.85)
      return CHART_RELIABILITY_VERY_HIGH;
   else if(confidence >= 0.6)
      return CHART_RELIABILITY_HIGH;
   else if(confidence >= 0.3)
      return CHART_RELIABILITY_MEDIUM;
   else
      return CHART_RELIABILITY_LOW;
}

// تحويل مستوى الموثوقية إلى قيمة رقمية
double ReliabilityToConfidence(ENUM_CHART_PATTERN_RELIABILITY reliability)
{
   switch(reliability)
   {
      case CHART_RELIABILITY_VERY_HIGH: return 0.9;
      case CHART_RELIABILITY_HIGH:      return 0.75;
      case CHART_RELIABILITY_MEDIUM:    return 0.45;
      case CHART_RELIABILITY_LOW:       return 0.15;
      default:                          return 0.5;
   }
}

// فحص صحة نقطة المخطط
bool IsValidChartPoint(const SChartPoint &point)
{
   return (point.price > 0.0 && point.time > 0 && point.index >= 0);
}

// فحص صحة خط الاتجاه
bool IsValidTrendLine(const STrendLine &line)
{
   return (line.isValid && 
           IsValidChartPoint(line.point1) && 
           IsValidChartPoint(line.point2) &&
           line.point1.time != line.point2.time);
}

// حساب المسافة بين نقطتين
double CalculatePointDistance(const SChartPoint &point1, const SChartPoint &point2)
{
   if(!IsValidChartPoint(point1) || !IsValidChartPoint(point2))
      return 0.0;
      
   double priceDistance = MathAbs(point2.price - point1.price);
   double timeDistance = MathAbs(point2.index - point1.index);
   
   return MathSqrt(priceDistance * priceDistance + timeDistance * timeDistance);
}

// حساب ميل خط الاتجاه
double CalculateTrendLineSlope(const STrendLine &line)
{
   if(!IsValidTrendLine(line))
      return 0.0;
      
   if(line.point2.index == line.point1.index)
      return 0.0;
      
   return (line.point2.price - line.point1.price) / (line.point2.index - line.point1.index);
}

// حساب زاوية خط الاتجاه
double CalculateTrendLineAngle(const STrendLine &line)
{
   double slope = CalculateTrendLineSlope(line);
   return MathArctan(slope) * 180.0 / M_PI;
}

// تحديد اتجاه خط الاتجاه بناءً على الميل
ENUM_PATTERN_DIRECTION DetermineTrendDirection(double slope, double threshold = 0.0001)
{
   if(slope > threshold)
      return PATTERN_BULLISH;
   else if(slope < -threshold)
      return PATTERN_BEARISH;
   else
      return PATTERN_NEUTRAL;
}

#endif // CHART_COMMON_DEFS_MQH