//+------------------------------------------------------------------+
//|                       TrendLineDetector.mqh |
//|                  حقوق النشر 2025, مكتبة أنماط المخططات |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط المخططات"
#property link "https://www.yourwebsite.com"
#property version "1.00"
#property strict

#include "ChartUtils.mqh"
#include "../../CandlePatterns/Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| تعدادات خطوط الاتجاه المخصصة |
//+------------------------------------------------------------------+
enum ENUM_TRENDLINE_DIRECTION
  {
   TRENDLINE_ASCENDING,    // خط اتجاه صاعد
   TRENDLINE_DESCENDING,   // خط اتجاه هابط
   TRENDLINE_HORIZONTAL    // خط أفقي
  };

enum ENUM_TRENDLINE_STRENGTH
  {
   TRENDLINE_WEAK,      // ضعيف
   TRENDLINE_MODERATE,  // متوسط
   TRENDLINE_STRONG,    // قوي
   TRENDLINE_VERY_STRONG // قوي جداً
  };

enum ENUM_TRENDLINE_STATUS
  {
   TRENDLINE_ACTIVE,     // نشط
   TRENDLINE_BROKEN,     // مكسور
   TRENDLINE_RETESTED,   // معاد اختباره
   TRENDLINE_CONFIRMED   // مؤكد
  };

//+------------------------------------------------------------------+
//| هيكل خط الاتجاه المبسط |
//+------------------------------------------------------------------+
struct STrendLineDetailed
  {
   // معلومات الخط
   int                        id;                // معرف الخط
   string                     name;              // اسم الخط
   ENUM_TRENDLINE_DIRECTION   direction;         // اتجاه الخط
   ENUM_TRENDLINE_STRENGTH    strength;          // قوة الخط
   ENUM_TRENDLINE_STATUS      status;            // حالة الخط

   // النقاط الأساسية
   SChartPoint                startPoint;        // نقطة البداية
   SChartPoint                endPoint;          // نقطة النهاية

   // خصائص الخط
   double                     slope;             // الميل
   double                     angle;             // الزاوية
   double                     intercept;         // نقطة التقاطع مع المحور العمودي
   double                     r_squared;         // معامل التحديد

   // معلومات إضافية
   int                        touchCount;        // عدد نقاط اللمس
   datetime                   creationTime;      // وقت الإنشاء
   datetime                   lastTouchTime;     // آخر وقت لمس
   double                     averageDistance;   // المسافة المتوسطة

   void Reset()
     {
      id = 0;
      name = "";
      direction = TRENDLINE_ASCENDING;
      strength = TRENDLINE_WEAK;
      status = TRENDLINE_ACTIVE;
      slope = 0.0;
      angle = 0.0;
      intercept = 0.0;
      r_squared = 0.0;
      touchCount = 0;
      creationTime = 0;
      lastTouchTime = 0;
      averageDistance = 0.0;
     }
  };

//+------------------------------------------------------------------+
//| فئة كاشف خطوط الاتجاه |
//+------------------------------------------------------------------+
class CTrendLineDetector
  {
private:
   // خطوط الاتجاه المكتشفة
   STrendLineDetailed        m_trendLines[100];  // مصفوفة خطوط الاتجاه ثابتة الحجم
   SChartPoint               m_touchPoints[100][20]; // نقاط اللمس لكل خط
   int                       m_lineCount;        // عدد الخطوط

   // إعدادات الكشف
   int                       m_lookbackPeriod;   // فترة البحث للخلف
   int                       m_minTouchPoints;   // الحد الأدنى لنقاط اللمس
   double                    m_tolerancePercent; // نسبة التسامح
   double                    m_minR_Squared;     // الحد الأدنى لمعامل التحديد
   double                    m_maxAngleDegrees;  // الحد الأقصى للزاوية بالدرجات

   // أدوات التحليل
   CTrendDetector*           m_trendDetector;    // كاشف الاتجاه العام

public:
                     CTrendLineDetector();
                    ~CTrendLineDetector();

   // الكشف عن خطوط الاتجاه
   int               DetectTrendLines(const string symbol, ENUM_TIMEFRAMES timeframe,
                                      const double &high[], const double &low[],
                                      const double &close[], const datetime &time[],
                                      int rates_total);

   int               DetectAscendingTrendLines(const double &high[], const double &low[],
         const datetime &time[], int rates_total);

   int               DetectDescendingTrendLines(const double &high[], const double &low[],
         const datetime &time[], int rates_total);

   int               DetectHorizontalLines(const double &high[], const double &low[],
                                           const datetime &time[], int rates_total);

   // التحقق من كسر خطوط الاتجاه
   bool              CheckTrendLineBreakout(const STrendLineDetailed &trendline,
         const double &high[], const double &low[],
         const double &close[], const datetime &time[],
         int currentBar, double &breakoutPrice);

   // حساب قوة خط الاتجاه
   ENUM_TRENDLINE_STRENGTH CalculateTrendLineStrength(const STrendLineDetailed &trendline);

   // الوصول لخطوط الاتجاه
   int               GetTrendLineCount() const { return m_lineCount; }
   STrendLineDetailed GetTrendLine(int index) const;
   int               GetActiveTrendLines(ENUM_TRENDLINE_DIRECTION direction, STrendLineDetailed &activeLines[]);

   // تحديث خطوط الاتجاه
   void              UpdateTrendLines(const double &high[], const double &low[],
                                      const double &close[], const datetime &time[],
                                      int currentBar);

   // رسم خطوط الاتجاه
   void              DrawTrendLine(const string symbol, const STrendLineDetailed &trendline,
                                   color lineColor = clrBlue, int lineWidth = 1,
                                   ENUM_LINE_STYLE lineStyle = STYLE_SOLID);

   void              DrawAllTrendLines(const string symbol);

   // إعدادات الكاشف
   void              SetLookbackPeriod(int period) { m_lookbackPeriod = MathMax(20, period); }
   void              SetMinTouchPoints(int points) { m_minTouchPoints = MathMax(2, points); }
   void              SetTolerancePercent(double percent) { m_tolerancePercent = MathMax(0.001, percent); }
   void              SetMinR_Squared(double r_squared) { m_minR_Squared = MathMax(0.1, r_squared); }
   void              SetMaxAngleDegrees(double degrees) { m_maxAngleDegrees = MathMax(1.0, degrees); }

   int               GetLookbackPeriod() const { return m_lookbackPeriod; }
   int               GetMinTouchPoints() const { return m_minTouchPoints; }
   double            GetTolerancePercent() const { return m_tolerancePercent; }

   // مسح خطوط الاتجاه
   void              ClearTrendLines();
   void              RemoveBrokenTrendLines();

private:
   // دوال مساعدة
   bool              FindPivotPoints(const double &high[], const double &low[],
                                     int start, int end, SChartPoint &pivots[]);

   STrendLineDetailed CreateTrendLine(const SChartPoint &point1, const SChartPoint &point2,
                                      ENUM_TRENDLINE_DIRECTION direction);

   bool              ValidateTrendLine(const STrendLineDetailed &trendline,
                                       const double &high[], const double &low[],
                                       const datetime &time[], int rates_total);

   double            CalculateLineDistance(const STrendLineDetailed &trendline,
                                           const SChartPoint &point);

   double            CalculateR_Squared(int lineIndex);

   bool              IsPointNearLine(const STrendLineDetailed &trendline, const SChartPoint &point);

   double            GetPriceAtTime(const STrendLineDetailed &trendline, datetime time);

   void              AddTouchPoint(int lineIndex, const SChartPoint &point);

   int               GenerateUniqueId();
  };

//+------------------------------------------------------------------+
//| المنشئ |
//+------------------------------------------------------------------+
CTrendLineDetector::CTrendLineDetector()
  {
   m_lineCount = 0;
   m_lookbackPeriod = 100;
   m_minTouchPoints = 2;
   m_tolerancePercent = 0.02; // 2%
   m_minR_Squared = 0.7;
   m_maxAngleDegrees = 45.0;

   m_trendDetector = new CTrendDetector();

   // تهيئة المصفوفات
   for(int i = 0; i < 100; i++)
     {
      m_trendLines[i].Reset();
      for(int j = 0; j < 20; j++)
        {
         m_touchPoints[i][j].price = 0.0;
         m_touchPoints[i][j].barIndex = -1;
        }
     }
  }

//+------------------------------------------------------------------+
//| الهادم |
//+------------------------------------------------------------------+
CTrendLineDetector::~CTrendLineDetector()
  {
   ClearTrendLines();
   if(m_trendDetector != NULL)
     {
      delete m_trendDetector;
      m_trendDetector = NULL;
     }
  }

//+------------------------------------------------------------------+
//| الكشف عن خطوط الاتجاه |
//+------------------------------------------------------------------+
int CTrendLineDetector::DetectTrendLines(const string symbol, ENUM_TIMEFRAMES timeframe,
      const double &high[], const double &low[],
      const double &close[], const datetime &time[],
      int rates_total)
  {
   if(rates_total < m_lookbackPeriod)
      return 0;

   ClearTrendLines();

   int totalLines = 0;

// كشف خطوط الاتجاه الصاعدة
   totalLines += DetectAscendingTrendLines(high, low, time, rates_total);

// كشف خطوط الاتجاه الهابطة
   totalLines += DetectDescendingTrendLines(high, low, time, rates_total);

// كشف الخطوط الأفقية
   totalLines += DetectHorizontalLines(high, low, time, rates_total);

   return totalLines;
  }

//+------------------------------------------------------------------+
//| كشف خطوط الاتجاه الصاعدة |
//+------------------------------------------------------------------+
int CTrendLineDetector::DetectAscendingTrendLines(const double &high[], const double &low[],
      const datetime &time[], int rates_total)
  {
   int linesFound = 0;
   SChartPoint pivots[];

// البحث عن القيعان (pivot lows)
   if(!FindPivotPoints(high, low, rates_total - m_lookbackPeriod, rates_total - 1, pivots))
      return 0;

// ترتيب النقاط حسب الوقت
   for(int i = 0; i < ArraySize(pivots) - 1 && m_lineCount < 100; i++)
     {
      for(int j = i + 1; j < ArraySize(pivots) && m_lineCount < 100; j++)
        {
         // التأكد من أن النقطة الثانية أعلى من الأولى (اتجاه صاعد)
         if(pivots[j].price > pivots[i].price && pivots[j].barIndex > pivots[i].barIndex)
           {
            STrendLineDetailed newLine = CreateTrendLine(pivots[i], pivots[j], TRENDLINE_ASCENDING);

            if(ValidateTrendLine(newLine, high, low, time, rates_total))
              {
               // إضافة الخط إلى المصفوفة
               m_trendLines[m_lineCount] = newLine;
               // إضافة نقاط اللمس
               m_touchPoints[m_lineCount][0] = pivots[i];
               m_touchPoints[m_lineCount][1] = pivots[j];
               m_lineCount++;
               linesFound++;
              }
           }
        }
     }

   return linesFound;
  }

//+------------------------------------------------------------------+
//| كشف خطوط الاتجاه الهابطة |
//+------------------------------------------------------------------+
int CTrendLineDetector::DetectDescendingTrendLines(const double &high[], const double &low[],
      const datetime &time[], int rates_total)
  {
   int linesFound = 0;
   SChartPoint pivots[];

// البحث عن القمم (pivot highs)
   if(!FindPivotPoints(high, low, rates_total - m_lookbackPeriod, rates_total - 1, pivots))
      return 0;

// ترتيب النقاط حسب الوقت
   for(int i = 0; i < ArraySize(pivots) - 1 && m_lineCount < 100; i++)
     {
      for(int j = i + 1; j < ArraySize(pivots) && m_lineCount < 100; j++)
        {
         // التأكد من أن النقطة الثانية أقل من الأولى (اتجاه هابط)
         if(pivots[j].price < pivots[i].price && pivots[j].barIndex > pivots[i].barIndex)
           {
            STrendLineDetailed newLine = CreateTrendLine(pivots[i], pivots[j], TRENDLINE_DESCENDING);

            if(ValidateTrendLine(newLine, high, low, time, rates_total))
              {
               // إضافة الخط إلى المصفوفة
               m_trendLines[m_lineCount] = newLine;
               // إضافة نقاط اللمس
               m_touchPoints[m_lineCount][0] = pivots[i];
               m_touchPoints[m_lineCount][1] = pivots[j];
               m_lineCount++;
               linesFound++;
              }
           }
        }
     }

   return linesFound;
  }

//+------------------------------------------------------------------+
//| كشف الخطوط الأفقية |
//+------------------------------------------------------------------+
int CTrendLineDetector::DetectHorizontalLines(const double &high[], const double &low[],
      const datetime &time[], int rates_total)
  {
   int linesFound = 0;
   double tolerance = (high[rates_total-1] - low[rates_total-1]) * m_tolerancePercent;

// البحث عن مستويات السعر المتكررة
   for(int i = rates_total - m_lookbackPeriod; i < rates_total - 10 && m_lineCount < 100; i++)
     {
      double referencePrice = (high[i] + low[i]) / 2.0;
      int touchCount = 1;
      SChartPoint touchPoints[50];

      // إضافة النقطة المرجعية
      touchPoints[0].price = referencePrice;
      touchPoints[0].time = time[i];
      touchPoints[0].barIndex = i;
      touchPoints[0].isConfirmed = true;

      // البحث عن نقاط لمس أخرى
      for(int j = i + 5; j < rates_total && touchCount < 50; j++)
        {
         if(MathAbs(high[j] - referencePrice) <= tolerance ||
            MathAbs(low[j] - referencePrice) <= tolerance)
           {
            touchPoints[touchCount].price = (MathAbs(high[j] - referencePrice) <= tolerance) ? high[j] : low[j];
            touchPoints[touchCount].time = time[j];
            touchPoints[touchCount].barIndex = j;
            touchPoints[touchCount].isConfirmed = true;
            touchCount++;
           }
        }

      // إذا كان عدد نقاط اللمس كافي
      if(touchCount >= m_minTouchPoints)
        {
         STrendLineDetailed newLine;
         newLine.Reset();
         
         newLine.id = GenerateUniqueId();
         newLine.name = "Horizontal_" + IntegerToString(newLine.id);
         newLine.direction = TRENDLINE_HORIZONTAL;
         newLine.startPoint = touchPoints[0];
         newLine.endPoint = touchPoints[touchCount-1];
         newLine.slope = 0.0;
         newLine.angle = 0.0;
         newLine.intercept = referencePrice;
         newLine.touchCount = touchCount;
         newLine.creationTime = TimeCurrent();
         newLine.status = TRENDLINE_ACTIVE;

         newLine.strength = CalculateTrendLineStrength(newLine);

         // إضافة الخط إلى المصفوفة
         m_trendLines[m_lineCount] = newLine;
         
         // إضافة نقاط اللمس
         int maxTouchPoints = MathMin(touchCount, 20);
         for(int k = 0; k < maxTouchPoints; k++)
           {
            m_touchPoints[m_lineCount][k] = touchPoints[k];
           }
         
         m_lineCount++;
         linesFound++;
        }
     }

   return linesFound;
  }

//+------------------------------------------------------------------+
//| التحقق من كسر خط الاتجاه |
//+------------------------------------------------------------------+
bool CTrendLineDetector::CheckTrendLineBreakout(const STrendLineDetailed &trendline,
      const double &high[], const double &low[],
      const double &close[], const datetime &time[],
      int currentBar, double &breakoutPrice)
  {
   if(currentBar < 1)
      return false;

   double currentPrice = GetPriceAtTime(trendline, time[currentBar]);
   double tolerance = currentPrice * m_tolerancePercent;

   bool breakout = false;

   switch(trendline.direction)
     {
      case TRENDLINE_ASCENDING:
         // كسر هبوطي لخط الاتجاه الصاعد
         if(close[currentBar] < currentPrice - tolerance)
           {
            breakout = true;
            breakoutPrice = currentPrice;
           }
         break;

      case TRENDLINE_DESCENDING:
         // كسر صاعد لخط الاتجاه الهابط
         if(close[currentBar] > currentPrice + tolerance)
           {
            breakout = true;
            breakoutPrice = currentPrice;
           }
         break;

      case TRENDLINE_HORIZONTAL:
         // كسر في أي اتجاه للخط الأفقي
         if(MathAbs(close[currentBar] - currentPrice) > tolerance)
           {
            breakout = true;
            breakoutPrice = currentPrice;
           }
         break;
     }

   return breakout;
  }

//+------------------------------------------------------------------+
//| حساب قوة خط الاتجاه |
//+------------------------------------------------------------------+
ENUM_TRENDLINE_STRENGTH CTrendLineDetector::CalculateTrendLineStrength(const STrendLineDetailed &trendline)
  {
   double score = 0.0;

// عدد نقاط اللمس
   if(trendline.touchCount >= 5)
      score += 3.0;
   else if(trendline.touchCount >= 3)
      score += 2.0;
   else if(trendline.touchCount >= 2)
      score += 1.0;

// معامل التحديد
   if(trendline.r_squared >= 0.9)
      score += 3.0;
   else if(trendline.r_squared >= 0.8)
      score += 2.0;
   else if(trendline.r_squared >= 0.7)
      score += 1.0;

// عمر الخط
   int ageInBars = (int)((TimeCurrent() - trendline.creationTime) / PeriodSeconds());
   if(ageInBars >= 50)
      score += 2.0;
   else if(ageInBars >= 20)
      score += 1.0;

// تصنيف القوة
   if(score >= 7.0)
      return TRENDLINE_VERY_STRONG;
   else if(score >= 5.0)
      return TRENDLINE_STRONG;
   else if(score >= 3.0)
      return TRENDLINE_MODERATE;
   else
      return TRENDLINE_WEAK;
  }

//+------------------------------------------------------------------+
//| إنشاء خط اتجاه |
//+------------------------------------------------------------------+
STrendLineDetailed CTrendLineDetector::CreateTrendLine(const SChartPoint &point1, const SChartPoint &point2,
      ENUM_TRENDLINE_DIRECTION direction)
  {
   STrendLineDetailed trendline;
   trendline.Reset();

   trendline.id = GenerateUniqueId();
   trendline.name = EnumToString(direction) + "_" + IntegerToString(trendline.id);
   trendline.direction = direction;
   trendline.startPoint = point1;
   trendline.endPoint = point2;
   trendline.creationTime = TimeCurrent();
   trendline.status = TRENDLINE_ACTIVE;

// حساب الميل والزاوية
   double deltaPrice = point2.price - point1.price;
   double deltaTime = (double)(point2.barIndex - point1.barIndex);

   if(deltaTime != 0)
     {
      trendline.slope = deltaPrice / deltaTime;
      trendline.angle = MathArctan(trendline.slope) * 180.0 / M_PI;
     }

// حساب نقطة التقاطع
   trendline.intercept = point1.price - (trendline.slope * (double)point1.barIndex);

// تعيين عدد نقاط اللمس الأولية
   trendline.touchCount = 2;

   return trendline;
  }

//+------------------------------------------------------------------+
//| التحقق من صحة خط الاتجاه |
//+------------------------------------------------------------------+
bool CTrendLineDetector::ValidateTrendLine(const STrendLineDetailed &trendline,
      const double &high[], const double &low[],
      const datetime &time[], int rates_total)
  {
// التحقق من الزاوية
   if(MathAbs(trendline.angle) > m_maxAngleDegrees)
      return false;

// البحث عن نقاط لمس إضافية
   int additionalTouches = 0;
   double tolerance = (high[rates_total-1] - low[rates_total-1]) * m_tolerancePercent;

   for(int i = trendline.startPoint.barIndex + 1; i < trendline.endPoint.barIndex; i++)
     {
      double expectedPrice = trendline.intercept + (trendline.slope * (double)i);

      if(trendline.direction == TRENDLINE_ASCENDING)
        {
         if(MathAbs(low[i] - expectedPrice) <= tolerance)
            additionalTouches++;
        }
      else if(trendline.direction == TRENDLINE_DESCENDING)
        {
         if(MathAbs(high[i] - expectedPrice) <= tolerance)
            additionalTouches++;
        }
     }

   return (additionalTouches >= 0); // يمكن تعديل هذا الشرط حسب الحاجة
  }

//+------------------------------------------------------------------+
//| الحصول على السعر في وقت محدد |
//+------------------------------------------------------------------+
double CTrendLineDetector::GetPriceAtTime(const STrendLineDetailed &trendline, datetime time)
  {
   if(trendline.direction == TRENDLINE_HORIZONTAL)
      return trendline.intercept;

   // تحويل الوقت إلى مؤشر شمعة (تقريبي)
   double barIndex = (double)time; // هذا تقريب - يفضل استخدام مؤشر شمعة فعلي
   return trendline.intercept + (trendline.slope * barIndex);
  }

//+------------------------------------------------------------------+
//| الحصول على خط اتجاه |
//+------------------------------------------------------------------+
STrendLineDetailed CTrendLineDetector::GetTrendLine(int index) const
  {
   STrendLineDetailed emptyLine;
   emptyLine.Reset();
   if(index >= 0 && index < m_lineCount)
      return m_trendLines[index];
   return emptyLine;
  }

//+------------------------------------------------------------------+
//| الحصول على خطوط الاتجاه النشطة |
//+------------------------------------------------------------------+
int CTrendLineDetector::GetActiveTrendLines(ENUM_TRENDLINE_DIRECTION direction, STrendLineDetailed &activeLines[])
  {
   int activeCount = 0;
   ArrayResize(activeLines, 0);
   
   for(int i = 0; i < m_lineCount && activeCount < 50; i++)
     {
      if(m_trendLines[i].status == TRENDLINE_ACTIVE && 
         (direction == TRENDLINE_ASCENDING || m_trendLines[i].direction == direction))
        {
         ArrayResize(activeLines, activeCount + 1);
         activeLines[activeCount] = m_trendLines[i];
         activeCount++;
        }
     }
   
   return activeCount;
  }

//+------------------------------------------------------------------+
//| رسم خط اتجاه |
//+------------------------------------------------------------------+
void CTrendLineDetector::DrawTrendLine(const string symbol, const STrendLineDetailed &trendline,
                                       color lineColor, int lineWidth,
                                       ENUM_LINE_STYLE lineStyle)
  {
   // تحديد اسم الكائن
   string objectName = "TrendLine_" + IntegerToString(trendline.id);
   
   // حذف الكائن السابق إذا وجد
   ObjectDelete(0, objectName);
   
   // إنشاء خط الاتجاه
   if(ObjectCreate(0, objectName, OBJ_TREND, 0, 
                   trendline.startPoint.time, trendline.startPoint.price,
                   trendline.endPoint.time, trendline.endPoint.price))
   {
      ObjectSetInteger(0, objectName, OBJPROP_COLOR, lineColor);
      ObjectSetInteger(0, objectName, OBJPROP_WIDTH, lineWidth);
      ObjectSetInteger(0, objectName, OBJPROP_STYLE, lineStyle);
      ObjectSetInteger(0, objectName, OBJPROP_RAY_RIGHT, true);
      ObjectSetString(0, objectName, OBJPROP_TEXT, trendline.name);
   }
  }

//+------------------------------------------------------------------+
//| رسم جميع خطوط الاتجاه |
//+------------------------------------------------------------------+
void CTrendLineDetector::DrawAllTrendLines(const string symbol)
  {
   for(int i = 0; i < m_lineCount; i++)
     {
      color lineColor = clrBlue;
      
      switch(m_trendLines[i].direction)
        {
         case TRENDLINE_ASCENDING:
            lineColor = clrGreen;
            break;
         case TRENDLINE_DESCENDING:
            lineColor = clrRed;
            break;
         case TRENDLINE_HORIZONTAL:
            lineColor = clrBlue;
            break;
        }
      
      DrawTrendLine(symbol, m_trendLines[i], lineColor);
     }
  }

//+------------------------------------------------------------------+
//| تحديث خطوط الاتجاه |
//+------------------------------------------------------------------+
void CTrendLineDetector::UpdateTrendLines(const double &high[], const double &low[],
                                          const double &close[], const datetime &time[],
                                          int currentBar)
  {
   // تحديث حالة خطوط الاتجاه
   for(int i = 0; i < m_lineCount; i++)
     {
      double breakoutPrice;
      if(CheckTrendLineBreakout(m_trendLines[i], high, low, close, time, currentBar, breakoutPrice))
        {
         m_trendLines[i].status = TRENDLINE_BROKEN;
        }
     }
  }

//+------------------------------------------------------------------+
//| توليد معرف فريد |
//+------------------------------------------------------------------+
int CTrendLineDetector::GenerateUniqueId()
  {
   static int counter = 1000;
   return counter++;
  }

//+------------------------------------------------------------------+
//| مسح خطوط الاتجاه |
//+------------------------------------------------------------------+
void CTrendLineDetector::ClearTrendLines()
  {
   m_lineCount = 0;
   for(int i = 0; i < 100; i++)
     {
      m_trendLines[i].Reset();
      for(int j = 0; j < 20; j++)
        {
         m_touchPoints[i][j].price = 0.0;
         m_touchPoints[i][j].barIndex = -1;
        }
     }
  }

//+------------------------------------------------------------------+
//| إزالة خطوط الاتجاه المكسورة |
//+------------------------------------------------------------------+
void CTrendLineDetector::RemoveBrokenTrendLines()
  {
   int writeIndex = 0;
   
   // ضغط المصفوفة بإزالة الخطوط المكسورة
   for(int i = 0; i < m_lineCount; i++)
     {
      if(m_trendLines[i].status != TRENDLINE_BROKEN)
        {
         if(writeIndex != i)
           {
            m_trendLines[writeIndex] = m_trendLines[i];
            // نسخ نقاط اللمس
            for(int j = 0; j < 20; j++)
              {
               m_touchPoints[writeIndex][j] = m_touchPoints[i][j];
              }
           }
         writeIndex++;
        }
     }
   
   m_lineCount = writeIndex;
  }

//+------------------------------------------------------------------+
//| البحث عن نقاط الارتكاز |
//+------------------------------------------------------------------+
bool CTrendLineDetector::FindPivotPoints(const double &high[], const double &low[],
      int start, int end, SChartPoint &pivots[])
  {
   ArrayResize(pivots, 0);
   int pivotCount = 0;
   int lookback = 3; // البحث في 3 شموع للخلف والأمام

   for(int i = start + lookback; i <= end - lookback && pivotCount < 100; i++)
     {
      bool isPivotHigh = true;
      bool isPivotLow = true;

      // التحقق من نقطة ارتكاز عليا
      for(int j = i - lookback; j <= i + lookback; j++)
        {
         if(j != i && high[j] >= high[i])
           {
            isPivotHigh = false;
            break;
           }
        }

      // التحقق من نقطة ارتكاز سفلى
      for(int j = i - lookback; j <= i + lookback; j++)
        {
         if(j != i && low[j] <= low[i])
           {
            isPivotLow = false;
            break;
           }
        }

      if(isPivotHigh || isPivotLow)
        {
         ArrayResize(pivots, pivotCount + 1);
         pivots[pivotCount].price = isPivotHigh ? high[i] : low[i];
         pivots[pivotCount].barIndex = i;
         pivots[pivotCount].pointType = isPivotHigh ? CHART_POINT_HIGH : CHART_POINT_LOW;
         pivots[pivotCount].isConfirmed = true;
         pivotCount++;
        }
     }

   return pivotCount > 0;
  }

//+------------------------------------------------------------------+
//| حساب المسافة من الخط |
//+------------------------------------------------------------------+
double CTrendLineDetector::CalculateLineDistance(const STrendLineDetailed &trendline,
                                                 const SChartPoint &point)
  {
   double expectedPrice = trendline.intercept + (trendline.slope * (double)point.barIndex);
   return MathAbs(point.price - expectedPrice);
  }

//+------------------------------------------------------------------+
//| حساب معامل التحديد |
//+------------------------------------------------------------------+
double CTrendLineDetector::CalculateR_Squared(int lineIndex)
  {
   if(lineIndex < 0 || lineIndex >= m_lineCount || m_trendLines[lineIndex].touchCount < 2)
      return 0.0;
   
   // حساب متوسط الأسعار
   double avgPrice = 0.0;
   int validPoints = MathMin(m_trendLines[lineIndex].touchCount, 20);
   
   for(int i = 0; i < validPoints; i++)
     {
      avgPrice += m_touchPoints[lineIndex][i].price;
     }
   avgPrice /= validPoints;
   
   // حساب مجموع المربعات
   double totalSumSquares = 0.0;
   double residualSumSquares = 0.0;
   
   for(int i = 0; i < validPoints; i++)
     {
      double actualPrice = m_touchPoints[lineIndex][i].price;
      double predictedPrice = m_trendLines[lineIndex].intercept + (m_trendLines[lineIndex].slope * (double)m_touchPoints[lineIndex][i].barIndex);
      
      totalSumSquares += MathPow(actualPrice - avgPrice, 2);
      residualSumSquares += MathPow(actualPrice - predictedPrice, 2);
     }
   
   if(totalSumSquares == 0.0)
      return 0.0;
   
   return 1.0 - (residualSumSquares / totalSumSquares);
  }

//+------------------------------------------------------------------+
//| التحقق من قرب النقطة من الخط |
//+------------------------------------------------------------------+
bool CTrendLineDetector::IsPointNearLine(const STrendLineDetailed &trendline, const SChartPoint &point)
  {
   double distance = CalculateLineDistance(trendline, point);
   double tolerance = point.price * m_tolerancePercent;
   return distance <= tolerance;
  }

//+------------------------------------------------------------------+
//| إضافة نقطة لمس |
//+------------------------------------------------------------------+
void CTrendLineDetector::AddTouchPoint(int lineIndex, const SChartPoint &point)
  {
   if(lineIndex < 0 || lineIndex >= m_lineCount)
      return;
      
   if(m_trendLines[lineIndex].touchCount < 20)
     {
      m_touchPoints[lineIndex][m_trendLines[lineIndex].touchCount] = point;
      m_trendLines[lineIndex].touchCount++;
      m_trendLines[lineIndex].lastTouchTime = point.time;
     }
  }

//+------------------------------------------------------------------+