//+------------------------------------------------------------------+
//|                                  ChartUtils.mqh |
//|                حقوق النشر 2025, مكتبة أنماط المخططات المتكاملة |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط المخططات المتكاملة"
#property link "https://www.yourwebsite.com"
#property version "2.00"
#property strict

#include "../../CandlePatterns/Base/CandleUtils.mqh"
#include "../../CandlePatterns/Base/TrendDetector.mqh"

//+------------------------------------------------------------------+
//| تعدادات موحدة للمخططات |
//+------------------------------------------------------------------+
enum ENUM_CHART_ANALYSIS_TYPE
{
   CHART_ANALYSIS_TREND,                // تحليل الاتجاه
   CHART_ANALYSIS_SUPPORT_RESISTANCE,   // تحليل الدعم والمقاومة
   CHART_ANALYSIS_PRICE_ACTION,         // تحليل حركة السعر
   CHART_ANALYSIS_VOLUME,               // تحليل الحجم
   CHART_ANALYSIS_MOMENTUM,             // تحليل الزخم
   CHART_ANALYSIS_VOLATILITY            // تحليل التقلبات
};

enum ENUM_CHART_TIMEFRAME_STRENGTH
{
   TIMEFRAME_STRENGTH_WEAK,       // ضعيف
   TIMEFRAME_STRENGTH_MODERATE,   // متوسط
   TIMEFRAME_STRENGTH_STRONG,     // قوي
   TIMEFRAME_STRENGTH_VERY_STRONG // قوي جداً
};

enum ENUM_CONFLUENCE_LEVEL
{
   CONFLUENCE_NONE,        // لا يوجد توافق
   CONFLUENCE_LOW,         // توافق ضعيف
   CONFLUENCE_MEDIUM,      // توافق متوسط
   CONFLUENCE_HIGH,        // توافق عالي
   CONFLUENCE_VERY_HIGH    // توافق عالي جداً
};

//+------------------------------------------------------------------+
//| تعدادات أنماط المخططات |
//+------------------------------------------------------------------+
enum ENUM_CHART_PATTERN_TYPE
{
    CHART_PATTERN_REVERSAL,        // انعكاس
    CHART_PATTERN_CONTINUATION,    // استمرار
    CHART_PATTERN_BILATERAL,       // ثنائي الاتجاه
    CHART_PATTERN_HARMONIC         // هارمونيك
};

enum ENUM_PATTERN_DIRECTION
{
    PATTERN_BULLISH,               // صاعد
    PATTERN_BEARISH,               // هابط
    PATTERN_NEUTRAL                // محايد
};

enum ENUM_CHART_POINT_TYPE
{
    CHART_POINT_HIGH,              // قمة
    CHART_POINT_LOW,               // قاع
    CHART_POINT_PIVOT,             // نقطة محورية
    CHART_POINT_BREAKOUT,          // كسر
    CHART_POINT_SUPPORT,           // دعم
    CHART_POINT_RESISTANCE         // مقاومة
};

enum ENUM_TRENDLINE_TYPE
{
    TRENDLINE_SUPPORT,             // دعم
    TRENDLINE_RESISTANCE,          // مقاومة
    TRENDLINE_TREND,               // اتجاه
    TRENDLINE_CHANNEL              // قناة
};

enum ENUM_PRICE_LEVEL_TYPE
{
    PRICE_LEVEL_SUPPORT,           // دعم
    PRICE_LEVEL_RESISTANCE,        // مقاومة
    PRICE_LEVEL_PIVOT,             // محوري
    PRICE_LEVEL_FIBONACCI,         // فيبوناتشي
    PRICE_LEVEL_PSYCHOLOGICAL      // نفسي
};

//+------------------------------------------------------------------+
//| هياكل المخططات المشتركة |
//+------------------------------------------------------------------+
struct SChartPoint
{
    double               price;           // السعر
    datetime             time;            // الوقت
    int                  barIndex;        // مؤشر الشمعة
    ENUM_CHART_POINT_TYPE pointType;      // نوع النقطة
    double               strength;        // قوة النقطة
    bool                 isConfirmed;     // مؤكد
    
    SChartPoint()
    {
        price = 0.0;
        time = 0;
        barIndex = -1;
        pointType = CHART_POINT_HIGH;
        strength = 0.0;
        isConfirmed = false;
    }
};

struct STrendLine
{
    SChartPoint          startPoint;      // نقطة البداية
    SChartPoint          endPoint;        // نقطة النهاية
    double               slope;           // الميل
    double               strength;        // القوة
    ENUM_TRENDLINE_TYPE  lineType;        // نوع الخط
    bool                 isValid;         // صالح
    
    STrendLine()
    {
        slope = 0.0;
        strength = 0.0;
        lineType = TRENDLINE_SUPPORT;
        isValid = false;
    }
};

struct SPriceLevel
{
    double               price;           // السعر
    ENUM_PRICE_LEVEL_TYPE levelType;      // نوع المستوى
    double               strength;        // القوة
    int                  touchCount;      // عدد اللمسات
    datetime             firstTouch;      // أول لمسة
    datetime             lastTouch;       // آخر لمسة
    bool                 isActive;        // نشط
    
    SPriceLevel()
    {
        price = 0.0;
        levelType = PRICE_LEVEL_SUPPORT;
        strength = 0.0;
        touchCount = 0;
        firstTouch = 0;
        lastTouch = 0;
        isActive = false;
    }
};

//+------------------------------------------------------------------+
//| هيكل تحليل شامل للمخطط |
//+------------------------------------------------------------------+
struct SChartAnalysis
{
   // تحليل الاتجاه
   ENUM_TREND_TYPE            overallTrend;        // الاتجاه العام
   double                     trendStrength;       // قوة الاتجاه
   ENUM_CHART_TIMEFRAME_STRENGTH trendReliability; // موثوقية الاتجاه
   
   // تحليل الدعم والمقاومة
   double                     nearestSupport;      // أقرب دعم
   double                     nearestResistance;   // أقرب مقاومة
   double                     supportStrength;     // قوة الدعم
   double                     resistanceStrength;  // قوة المقاومة
   
   // تحليل حركة السعر
   double                     momentum;            // الزخم
   double                     volatility;          // التقلبات
   double                     priceVelocity;       // سرعة السعر
   
   // تحليل الحجم
   double                     volumeTrend;         // اتجاه الحجم
   double                     volumeConfirmation;  // تأكيد الحجم
   bool                       volumeAnomaly;       // شذوذ في الحجم
   
   // مؤشرات التوافق
   ENUM_CONFLUENCE_LEVEL      confluenceLevel;     // مستوى التوافق
   double                     reliabilityScore;    // نقاط الموثوقية
   
   // معلومات السياق
   double                     currentPrice;        // السعر الحالي
   datetime                   analysisTime;        // وقت التحليل
   ENUM_TIMEFRAMES            timeframe;           // الإطار الزمني
   
   SChartAnalysis()
   {
      overallTrend = TREND_NEUTRAL;
      trendStrength = 0.0;
      trendReliability = TIMEFRAME_STRENGTH_WEAK;
      nearestSupport = 0.0;
      nearestResistance = 0.0;
      supportStrength = 0.0;
      resistanceStrength = 0.0;
      momentum = 0.0;
      volatility = 0.0;
      priceVelocity = 0.0;
      volumeTrend = 0.0;
      volumeConfirmation = 0.0;
      volumeAnomaly = false;
      confluenceLevel = CONFLUENCE_NONE;
      reliabilityScore = 0.0;
      currentPrice = 0.0;
      analysisTime = 0;
      timeframe = PERIOD_CURRENT;
   }
};

//+------------------------------------------------------------------+
//| هيكل نقطة توافق |
//+------------------------------------------------------------------+
struct SConfluencePoint
{
   double                     price;               // السعر
   ENUM_CONFLUENCE_LEVEL      level;               // مستوى التوافق
   string                     factors[];           // العوامل المؤثرة
   double                     strength;            // القوة الإجمالية
   datetime                   validFrom;           // صالح من
   datetime                   validUntil;          // صالح حتى
   bool                       isActive;            // نشط
   
   SConfluencePoint()
   {
      price = 0.0;
      level = CONFLUENCE_NONE;
      strength = 0.0;
      validFrom = 0;
      validUntil = 0;
      isActive = false;
      ArrayResize(factors, 0);
   }
};

//+------------------------------------------------------------------+
//| فئة أدوات المخططات الأساسية |
//+------------------------------------------------------------------+
class CChartUtils
{
private:
   static bool                m_initialized;       // حالة التهيئة
   static string              m_lastError;         // آخر خطأ

public:
   // دوال التهيئة والإنهاء
   static bool                Initialize();
   static void                Deinitialize();
   static bool                IsInitialized() { return m_initialized; }
   static string              GetLastError() { return m_lastError; }
   
   // دوال البحث عن القمم والقيعان
   static bool                FindPeaks(const double &high[], const double &low[], const double &close[],
                                       int start, int end, SChartPoint &peaks[]);
   
   static bool                FindValleys(const double &high[], const double &low[], const double &close[],
                                         int start, int end, SChartPoint &valleys[]);
   
   // دوال تحليل النقاط
   static bool                FindSignificantPoints(const double &high[], const double &low[], 
                                                   const double &close[], int start, int end,
                                                   SChartPoint &points[]);
   
   // دوال التحقق من الصحة
   static bool                ValidateChartData(const double &high[], const double &low[], 
                                               const double &close[], int size);
   
private:
   static void                SetLastError(const string error) { m_lastError = error; }
   static void                ClearLastError() { m_lastError = ""; }
};

// تعريف المتغيرات الثابتة
bool CChartUtils::m_initialized = false;
string CChartUtils::m_lastError = "";

//+------------------------------------------------------------------+
//| تهيئة أدوات المخططات الأساسية |
//+------------------------------------------------------------------+
bool CChartUtils::Initialize()
{
   if(m_initialized)
      return true;
      
   ClearLastError();
   
   // تهيئة أدوات الشموع
   CCandleUtils::Initialize();
   
   m_initialized = true;
   Print("تم تهيئة أدوات المخططات الأساسية بنجاح");
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء أدوات المخططات الأساسية |
//+------------------------------------------------------------------+
void CChartUtils::Deinitialize()
{
   if(!m_initialized)
      return;
      
   m_initialized = false;
   ClearLastError();
   Print("تم إنهاء أدوات المخططات الأساسية بنجاح");
}

//+------------------------------------------------------------------+
//| البحث عن القمم |
//+------------------------------------------------------------------+
bool CChartUtils::FindPeaks(const double &high[], const double &low[], const double &close[],
                            int start, int end, SChartPoint &peaks[])
{
   if(!m_initialized)
   {
      SetLastError("أدوات المخططات غير مهيأة");
      return false;
   }
   
   if(start >= end || end >= ArraySize(high))
   {
      SetLastError("معاملات البحث غير صحيحة");
      return false;
   }
   
   SChartPoint tempPeaks[];
   int peakCount = 0;
   
   // البحث عن القمم المحلية
   for(int i = start + 2; i <= end - 2; i++)
   {
      bool isPeak = true;
      
      // فحص القمة المحلية
      for(int j = i - 2; j <= i + 2; j++)
      {
         if(j != i && high[j] >= high[i])
         {
            isPeak = false;
            break;
         }
      }
      
      if(isPeak)
      {
         ArrayResize(tempPeaks, peakCount + 1);
         tempPeaks[peakCount].price = high[i];
         tempPeaks[peakCount].barIndex = i;
         tempPeaks[peakCount].pointType = CHART_POINT_HIGH;
         tempPeaks[peakCount].strength = 1.0;
         tempPeaks[peakCount].isConfirmed = true;
         peakCount++;
      }
   }
   
   if(peakCount > 0)
   {
      ArrayCopy(peaks, tempPeaks);
      ClearLastError();
      return true;
   }
   
   SetLastError("لم يتم العثور على قمم");
   return false;
}

//+------------------------------------------------------------------+
//| البحث عن القيعان |
//+------------------------------------------------------------------+
bool CChartUtils::FindValleys(const double &high[], const double &low[], const double &close[],
                              int start, int end, SChartPoint &valleys[])
{
   if(!m_initialized)
   {
      SetLastError("أدوات المخططات غير مهيأة");
      return false;
   }
   
   if(start >= end || end >= ArraySize(low))
   {
      SetLastError("معاملات البحث غير صحيحة");
      return false;
   }
   
   SChartPoint tempValleys[];
   int valleyCount = 0;
   
   // البحث عن القيعان المحلية
   for(int i = start + 2; i <= end - 2; i++)
   {
      bool isValley = true;
      
      // فحص القاع المحلي
      for(int j = i - 2; j <= i + 2; j++)
      {
         if(j != i && low[j] <= low[i])
         {
            isValley = false;
            break;
         }
      }
      
      if(isValley)
      {
         ArrayResize(tempValleys, valleyCount + 1);
         tempValleys[valleyCount].price = low[i];
         tempValleys[valleyCount].barIndex = i;
         tempValleys[valleyCount].pointType = CHART_POINT_LOW;
         tempValleys[valleyCount].strength = 1.0;
         tempValleys[valleyCount].isConfirmed = true;
         valleyCount++;
      }
   }
   
   if(valleyCount > 0)
   {
      ArrayCopy(valleys, tempValleys);
      ClearLastError();
      return true;
   }
   
   SetLastError("لم يتم العثور على قيعان");
   return false;
}

//+------------------------------------------------------------------+
//| البحث عن النقاط المهمة |
//+------------------------------------------------------------------+
bool CChartUtils::FindSignificantPoints(const double &high[], const double &low[], 
                                       const double &close[], int start, int end,
                                       SChartPoint &points[])
{
   if(!m_initialized)
   {
      SetLastError("أدوات المخططات غير مهيأة");
      return false;
   }
   
   SChartPoint peaks[], valleys[];
   
   bool foundPeaks = FindPeaks(high, low, close, start, end, peaks);
   bool foundValleys = FindValleys(high, low, close, start, end, valleys);
   
   if(!foundPeaks && !foundValleys)
   {
      SetLastError("لم يتم العثور على نقاط مهمة");
      return false;
   }
   
   // دمج القمم والقيعان
   int totalPoints = ArraySize(peaks) + ArraySize(valleys);
   ArrayResize(points, totalPoints);
   
   int pointIndex = 0;
   
   // إضافة القمم
   for(int i = 0; i < ArraySize(peaks); i++)
   {
      points[pointIndex] = peaks[i];
      pointIndex++;
   }
   
   // إضافة القيعان
   for(int i = 0; i < ArraySize(valleys); i++)
   {
      points[pointIndex] = valleys[i];
      pointIndex++;
   }
   
   // ترتيب النقاط حسب الوقت
   for(int i = 0; i < totalPoints - 1; i++)
   {
      for(int j = i + 1; j < totalPoints; j++)
      {
         if(points[j].barIndex < points[i].barIndex)
         {
            SChartPoint temp = points[i];
            points[i] = points[j];
            points[j] = temp;
         }
      }
   }
   
   ClearLastError();
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من صحة بيانات المخطط |
//+------------------------------------------------------------------+
bool CChartUtils::ValidateChartData(const double &high[], const double &low[], 
                                   const double &close[], int size)
{
   if(!m_initialized)
   {
      SetLastError("أدوات المخططات غير مهيأة");
      return false;
   }
   
   if(size < 10)
   {
      SetLastError("حجم البيانات أقل من الحد الأدنى");
      return false;
   }
      
   if(ArraySize(high) < size || ArraySize(low) < size || ArraySize(close) < size)
   {
      SetLastError("أحجام المصفوفات غير متطابقة");
      return false;
   }
   
   for(int i = 0; i < size; i++)
   {
      if(high[i] < low[i] || close[i] <= 0 || high[i] <= 0 || low[i] <= 0)
      {
         SetLastError(StringFormat("بيانات غير صحيحة في المؤشر %d", i));
         return false;
      }
   }
   
   ClearLastError();
   return true;
}

//+------------------------------------------------------------------+
//| فئة أدوات المخططات المتقدمة والمتكاملة |
//+------------------------------------------------------------------+
class CAdvancedChartUtils
{
private:
   // أدوات التحليل المتخصصة
   static CTrendDetector*     m_trendDetector;     // كاشف الاتجاه
   static bool                m_initialized;       // حالة التهيئة
   
   // إعدادات التحليل
   static double              m_tolerance;         // نسبة التسامح العامة
   static int                 m_analysisDepth;     // عمق التحليل
   static bool                m_useVolumeAnalysis; // استخدام تحليل الحجم
   static bool                m_enableConfluence;  // تفعيل تحليل التوافق

public:
   // تهيئة وإعدادات
   static bool                Initialize(double tolerance = 0.02, int analysisDepth = 100);
   static void                Deinitialize();
   static void                SetTolerance(double tolerance) { m_tolerance = MathMax(0.001, tolerance); }
   static void                SetAnalysisDepth(int depth) { m_analysisDepth = MathMax(50, depth); }
   static void                SetUseVolumeAnalysis(bool use) { m_useVolumeAnalysis = use; }
   static void                SetEnableConfluence(bool enable) { m_enableConfluence = enable; }
   
   // التحليل الشامل للمخطط - إصلاح التوقيع
   static SChartAnalysis      PerformComprehensiveAnalysis(const string symbol, 
                                                          ENUM_TIMEFRAMES timeframe,
                                                          const double &high[], 
                                                          const double &low[], 
                                                          const double &close[],
                                                          const long &volume[],
                                                          const datetime &time[],
                                                          int rates_total);
   
   // تحليل التوافق - إصلاح التوقيع
   static int                 FindConfluenceZones(const double &high[], const double &low[], 
                                                 const double &close[], const long &volume[],
                                                 const datetime &time[], int rates_total,
                                                 SConfluencePoint &confluencePoints[]);
   
   static ENUM_CONFLUENCE_LEVEL CalculateConfluenceLevel(double price, 
                                                        const double &high[], const double &low[], 
                                                        const double &close[], int rates_total);
   
   // دوال تحليل متقدمة
   static double              CalculateMarketStructure(const double &high[], const double &low[], 
                                                      const double &close[], int rates_total);
   
   static double              CalculatePriceVelocity(const double &close[], int period, int rates_total);
   
   static bool                DetectPriceExpansion(const double &high[], const double &low[], 
                                                  int period, int rates_total);
   
   static bool                DetectPriceContraction(const double &high[], const double &low[], 
                                                    int period, int rates_total);
   
   // تحليل القوة النسبية بين الإطارات الزمنية
   static double              CalculateMultiTimeframeStrength(const string symbol,
                                                             const ENUM_TIMEFRAMES &timeframes[],
                                                             ENUM_TREND_TYPE direction);
   
   // دوال تحليل السيولة - إصلاح التوقيع
   static double              CalculateLiquidityLevel(const double &high[], const double &low[], 
                                                     const long &volume[], int rates_total);
   
   static bool                DetectLiquidityGrab(const double &high[], const double &low[], 
                                                 const double &close[], const long &volume[],
                                                 int rates_total);
   
   // تحليل هيكل السوق
   static bool                IsMarketStructureBullish(const double &high[], const double &low[], 
                                                      int lookback, int rates_total);
   
   static bool                IsMarketStructureBearish(const double &high[], const double &low[], 
                                                      int lookback, int rates_total);
   
   // دوال التحليل الإحصائي المتقدم
   static double              CalculateSkewness(const double &prices[], int period, int start = 0);
   static double              CalculateKurtosis(const double &prices[], int period, int start = 0);
   static double              CalculateRSquared(const double &actual[], const double &predicted[], 
                                               int period, int start = 0);
   
   // تحليل الانحدار وخطوط الاتجاه
   static bool                CalculateLinearRegression(const double &prices[], int period,
                                                       double &slope, double &intercept, 
                                                       double &correlation, int start = 0);
   
   static double              CalculateRegressionDeviation(const double &prices[], 
                                                          double slope, double intercept,
                                                          int period, int start = 0);
   
   // دوال تحليل الدورات
   static bool                DetectCyclicalPattern(const double &prices[], int minCycle, 
                                                   int maxCycle, int rates_total);
   
   static double              CalculateCycleProbability(const double &prices[], int cycleLength,
                                                       int rates_total);
   
   // دوال التنبؤ
   static double              PredictNextPrice(const double &prices[], int period, 
                                              ENUM_TREND_TYPE trend, int rates_total);
   
   static bool                PredictPriceTarget(const double &high[], const double &low[], 
                                                const double &close[], double currentPrice,
                                                double &upperTarget, double &lowerTarget);
   
   // دوال تحليل المخاطر
   static double              CalculateValueAtRisk(const double &returns[], double confidence,
                                                  int period, int start = 0);
   
   static double              CalculateMaxDrawdown(const double &prices[], int period, int start = 0);
   
   static double              CalculateSharpeRatio(const double &returns[], double riskFreeRate,
                                                  int period, int start = 0);
   
   // دوال مساعدة للأداء
   static void                OptimizeAnalysisParameters(const double &high[], const double &low[], 
                                                        const double &close[], int rates_total,
                                                        double &optimalTolerance, 
                                                        int &optimalDepth);
   
   static double              CalculateAnalysisAccuracy(const SChartAnalysis &analysis,
                                                       const double &actualPrices[], 
                                                       int validationPeriod);
   
   // دوال التقارير والتصدير
   static string              AnalysisToString(const SChartAnalysis &analysis);
   static string              ConfluencePointToString(const SConfluencePoint &point);
   static void                GenerateAnalysisReport(const SChartAnalysis &analysis,
                                                    const SConfluencePoint &confluencePoints[],
                                                    string &report);
   
   // دوال التحليل الأساسية المحدثة
   static double              CalculateVolatility(const double &high[], const double &low[], 
                                                 int period, int start);
   
private:
   // دوال مساعدة خاصة
   static double              CalculateCompoundStrength(const double &values[], int count);
   static bool                ValidateAnalysisInput(const double &high[], const double &low[], 
                                                   const double &close[], int rates_total);
   static void                NormalizeConfluenceFactors(SConfluencePoint &point);
   static double              WeightFactorsByTimeframe(ENUM_TIMEFRAMES timeframe, double baseFactor);
};

// تعريف المتغيرات الثابتة
CTrendDetector* CAdvancedChartUtils::m_trendDetector = NULL;
bool CAdvancedChartUtils::m_initialized = false;
double CAdvancedChartUtils::m_tolerance = 0.02;
int CAdvancedChartUtils::m_analysisDepth = 100;
bool CAdvancedChartUtils::m_useVolumeAnalysis = true;
bool CAdvancedChartUtils::m_enableConfluence = true;

//+------------------------------------------------------------------+
//| تهيئة أدوات المخططات المتقدمة |
//+------------------------------------------------------------------+
bool CAdvancedChartUtils::Initialize(double tolerance, int analysisDepth)
{
   if(m_initialized)
      return true;
      
   // تهيئة أدوات الشموع أولاً
   CCandleUtils::Initialize(); // هذه الدالة لا ترجع قيمة
   
   // إنشاء كاشف الاتجاه المتقدم
   m_trendDetector = new CTrendDetector();
   if(m_trendDetector == NULL)
   {
      Print("خطأ: فشل في إنشاء كاشف الاتجاه");
      return false;
   }
   
   // تعيين المعاملات
   m_tolerance = MathMax(0.001, tolerance);
   m_analysisDepth = MathMax(50, analysisDepth);
   
   m_initialized = true;
   Print("تم تهيئة أدوات المخططات المتقدمة بنجاح");
   return true;
}

//+------------------------------------------------------------------+
//| إلغاء تهيئة أدوات المخططات |
//+------------------------------------------------------------------+
void CAdvancedChartUtils::Deinitialize()
{
   if(m_trendDetector != NULL)
   {
      delete m_trendDetector;
      m_trendDetector = NULL;
   }
   
   m_initialized = false;
   Print("تم إلغاء تهيئة أدوات المخططات المتقدمة");
}

//+------------------------------------------------------------------+
//| التحليل الشامل للمخطط - مُحدث |
//+------------------------------------------------------------------+
SChartAnalysis CAdvancedChartUtils::PerformComprehensiveAnalysis(const string symbol, 
                                                               ENUM_TIMEFRAMES timeframe,
                                                               const double &high[], 
                                                               const double &low[], 
                                                               const double &close[],
                                                               const long &volume[],
                                                               const datetime &time[],
                                                               int rates_total)
{
   SChartAnalysis analysis;
   
   if(!ValidateAnalysisInput(high, low, close, rates_total))
   {
      Print("خطأ: بيانات التحليل غير صحيحة");
      return analysis;
   }
   
   analysis.analysisTime = TimeCurrent();
   analysis.timeframe = timeframe;
   analysis.currentPrice = close[rates_total - 1];
   
   // تحليل الاتجاه
   if(m_trendDetector != NULL)
   {
      // نسخ بيانات الافتتاح من الرمز
      double open[];
      ArraySetAsSeries(open, true);
      
      // نسخ بيانات الافتتاح من المخدم
      if(CopyOpen(symbol, timeframe, 0, rates_total, open) <= 0)
      {
         // إذا فشل في نسخ بيانات الافتتاح، نرجع للتحليل البسيط
         Print("تحذير: فشل في نسخ بيانات الافتتاح، استخدام تحليل مبسط");
         analysis.overallTrend = TREND_NEUTRAL;
         analysis.trendStrength = 0.5;
      }
      else
      {
         // استدعاء الدالة بالمعاملات الصحيحة
         analysis.overallTrend = m_trendDetector.DetectTrend(open, high, low, close, volume, rates_total, rates_total - 1);
         analysis.trendStrength = m_trendDetector.GetTrendStrength();
      }
      
      // تحديد موثوقية الاتجاه
      if(analysis.trendStrength >= 0.8)
         analysis.trendReliability = TIMEFRAME_STRENGTH_VERY_STRONG;
      else if(analysis.trendStrength >= 0.6)
         analysis.trendReliability = TIMEFRAME_STRENGTH_STRONG;
      else if(analysis.trendStrength >= 0.4)
         analysis.trendReliability = TIMEFRAME_STRENGTH_MODERATE;
      else
         analysis.trendReliability = TIMEFRAME_STRENGTH_WEAK;
   }
   
   // تحليل الزخم والسرعة
   analysis.momentum = CalculatePriceVelocity(close, 14, rates_total);
   analysis.priceVelocity = CalculatePriceVelocity(close, 5, rates_total);
   
   // تحليل التقلبات
   if(rates_total >= 20)
      analysis.volatility = CalculateVolatility(high, low, 20, rates_total - 20);
   
   // تحليل الحجم إذا كان متاحاً
   if(m_useVolumeAnalysis && ArraySize(volume) > 0)
   {
      // حساب متوسط الحجم
      double avgVolume = 0.0;
      int volPeriod = MathMin(20, rates_total - 1);
      for(int i = rates_total - volPeriod; i < rates_total; i++)
         avgVolume += (double)volume[i]; // تحويل من long إلى double
      avgVolume /= volPeriod;
      
      if(avgVolume > 0)
      {
         analysis.volumeConfirmation = (double)volume[rates_total - 1] / avgVolume;
         analysis.volumeAnomaly = (analysis.volumeConfirmation > 2.0 || analysis.volumeConfirmation < 0.5);
      }
   }
   
   // حساب هيكل السوق
   double marketStructure = CalculateMarketStructure(high, low, close, rates_total);
   
   // تحليل التوافق إذا كان مفعلاً
   if(m_enableConfluence)
   {
      analysis.confluenceLevel = CalculateConfluenceLevel(analysis.currentPrice, high, low, close, rates_total);
   }
   
   // حساب النقاط الإجمالية للموثوقية
   analysis.reliabilityScore = 0.0;
   analysis.reliabilityScore += analysis.trendStrength * 0.3;  // 30% للاتجاه
   analysis.reliabilityScore += (analysis.volumeConfirmation > 1.2 ? 0.2 : 0.0);  // 20% للحجم
   analysis.reliabilityScore += (analysis.confluenceLevel >= CONFLUENCE_MEDIUM ? 0.25 : 0.0);  // 25% للتوافق
   analysis.reliabilityScore += (marketStructure > 0.6 ? 0.25 : 0.0);  // 25% لهيكل السوق
   
   return analysis;
}

//+------------------------------------------------------------------+
//| حساب سرعة السعر |
//+------------------------------------------------------------------+
double CAdvancedChartUtils::CalculatePriceVelocity(const double &close[], int period, int rates_total)
{
   if(rates_total < period + 1 || period <= 0)
      return 0.0;
   
   double totalChange = 0.0;
   for(int i = rates_total - period; i < rates_total - 1; i++)
   {
      totalChange += (close[i + 1] - close[i]);
   }
   
   return totalChange / period;
}

//+------------------------------------------------------------------+
//| حساب هيكل السوق |
//+------------------------------------------------------------------+
double CAdvancedChartUtils::CalculateMarketStructure(const double &high[], const double &low[], 
                                                    const double &close[], int rates_total)
{
   if(rates_total < 20)
      return 0.5;
   
   int higherHighs = 0, lowerLows = 0, totalSwings = 0;
   
   // البحث عن القمم والقيعان المحلية
   for(int i = 5; i < rates_total - 5; i++)
   {
      bool isHigh = true, isLow = true;
      
      // فحص القمة
      for(int j = i - 3; j <= i + 3; j++)
      {
         if(j != i && high[j] >= high[i])
         {
            isHigh = false;
            break;
         }
      }
      
      // فحص القاع
      for(int j = i - 3; j <= i + 3; j++)
      {
         if(j != i && low[j] <= low[i])
         {
            isLow = false;
            break;
         }
      }
      
      if(isHigh && i > 10)
      {
         // البحث عن قمة سابقة للمقارنة
         for(int k = i - 10; k >= 5; k--)
         {
            bool isPrevHigh = true;
            for(int l = k - 3; l <= k + 3; l++)
            {
               if(l != k && l >= 0 && high[l] >= high[k])
               {
                  isPrevHigh = false;
                  break;
               }
            }
            if(isPrevHigh)
            {
               totalSwings++;
               if(high[i] > high[k])
                  higherHighs++;
               break;
            }
         }
      }
      
      if(isLow && i > 10)
      {
         // البحث عن قاع سابق للمقارنة
         for(int k = i - 10; k >= 5; k--)
         {
            bool isPrevLow = true;
            for(int l = k - 3; l <= k + 3; l++)
            {
               if(l != k && l >= 0 && low[l] <= low[k])
               {
                  isPrevLow = false;
                  break;
               }
            }
            if(isPrevLow)
            {
               totalSwings++;
               if(low[i] < low[k])
                  lowerLows++;
               break;
            }
         }
      }
   }
   
   if(totalSwings == 0)
      return 0.5;
   
   // نسبة القمم الأعلى والقيعان الأدنى تشير لقوة الهيكل
   return (double)(higherHighs + lowerLows) / (totalSwings * 2);
}

//+------------------------------------------------------------------+
//| حساب مستوى التوافق |
//+------------------------------------------------------------------+
ENUM_CONFLUENCE_LEVEL CAdvancedChartUtils::CalculateConfluenceLevel(double price, 
                                                                   const double &high[], const double &low[], 
                                                                   const double &close[], int rates_total)
{
   int confluenceFactors = 0;
   double tolerance = price * m_tolerance;
   
   // عامل 1: قرب من مستويات الدعم/المقاومة التاريخية
   for(int i = 0; i < rates_total - 20; i += 5)
   {
      if(MathAbs(high[i] - price) <= tolerance || MathAbs(low[i] - price) <= tolerance)
      {
         confluenceFactors++;
         break;
      }
   }
   
   // عامل 2: قرب من المتوسطات المتحركة المهمة
   double sma20 = 0.0, sma50 = 0.0;
   if(rates_total >= 50)
   {
      for(int i = rates_total - 20; i < rates_total; i++)
         sma20 += close[i];
      sma20 /= 20;
      
      for(int i = rates_total - 50; i < rates_total; i++)
         sma50 += close[i];
      sma50 /= 50;
      
      if(MathAbs(sma20 - price) <= tolerance || MathAbs(sma50 - price) <= tolerance)
         confluenceFactors++;
   }
   
   // عامل 3: قرب من مستويات الأرقام النفسية
   double roundNumber = MathRound(price * 100) / 100; // تقريب لأقرب سنت
   if(MathAbs(roundNumber - price) <= tolerance)
      confluenceFactors++;
   
   // عامل 4: قرب من مستويات فيبوناتشي
   if(rates_total >= 100)
   {
      double highestHigh = high[ArrayMaximum(high, rates_total - 100, 100)];
      double lowestLow = low[ArrayMinimum(low, rates_total - 100, 100)];
      double range = highestHigh - lowestLow;
      
      double fibLevels[] = {0.236, 0.382, 0.5, 0.618, 0.764};
      for(int i = 0; i < ArraySize(fibLevels); i++)
      {
         double fibPrice = lowestLow + (range * fibLevels[i]);
         if(MathAbs(fibPrice - price) <= tolerance)
         {
            confluenceFactors++;
            break;
         }
      }
   }
   
   // تحديد مستوى التوافق بناءً على عدد العوامل
   if(confluenceFactors >= 4)
      return CONFLUENCE_VERY_HIGH;
   else if(confluenceFactors >= 3)
      return CONFLUENCE_HIGH;
   else if(confluenceFactors >= 2)
      return CONFLUENCE_MEDIUM;
   else if(confluenceFactors >= 1)
      return CONFLUENCE_LOW;
   else
      return CONFLUENCE_NONE;
}

//+------------------------------------------------------------------+
//| حساب الانحدار الخطي |
//+------------------------------------------------------------------+
bool CAdvancedChartUtils::CalculateLinearRegression(const double &prices[], int period,
                                                   double &slope, double &intercept, 
                                                   double &correlation, int start)
{
   if(period < 2 || start + period > ArraySize(prices))
      return false;
   
   // حساب المتوسطات
   double sumX = 0.0, sumY = 0.0;
   for(int i = 0; i < period; i++)
   {
      sumX += i;
      sumY += prices[start + i];
   }
   double avgX = sumX / period;
   double avgY = sumY / period;
   
   // حساب المعادلات
   double sumXY = 0.0, sumXX = 0.0, sumYY = 0.0;
   for(int i = 0; i < period; i++)
   {
      double x = i - avgX;
      double y = prices[start + i] - avgY;
      sumXY += x * y;
      sumXX += x * x;
      sumYY += y * y;
   }
   
   // حساب الميل ونقطة التقاطع
   if(sumXX != 0.0)
   {
      slope = sumXY / sumXX;
      intercept = avgY - (slope * avgX);
      
      // حساب معامل الارتباط
      if(sumXX != 0.0 && sumYY != 0.0)
         correlation = sumXY / MathSqrt(sumXX * sumYY);
      else
         correlation = 0.0;
      
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| التحقق من صحة بيانات التحليل |
//+------------------------------------------------------------------+
bool CAdvancedChartUtils::ValidateAnalysisInput(const double &high[], const double &low[], 
                                               const double &close[], int rates_total)
{
   if(rates_total < 20)
      return false;
      
   // التحقق من أحجام المصفوفات
   if(ArraySize(high) < rates_total || ArraySize(low) < rates_total || ArraySize(close) < rates_total)
      return false;
   
   // التحقق من العلاقات المنطقية
   for(int i = 0; i < rates_total; i++)
   {
      if(high[i] < low[i] || close[i] <= 0 || high[i] <= 0 || low[i] <= 0)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| تحويل التحليل إلى نص |
//+------------------------------------------------------------------+
string CAdvancedChartUtils::AnalysisToString(const SChartAnalysis &analysis)
{
   string result = "";
   result += "=== تحليل شامل للمخطط ===\n";
   result += StringFormat("الوقت: %s\n", TimeToString(analysis.analysisTime));
   result += StringFormat("السعر الحالي: %.5f\n", analysis.currentPrice);
   result += StringFormat("الاتجاه العام: %s (القوة: %.2f)\n", 
                         EnumToString(analysis.overallTrend), analysis.trendStrength);
   result += StringFormat("الزخم: %.5f\n", analysis.momentum);
   result += StringFormat("التقلبات: %.5f\n", analysis.volatility);
   result += StringFormat("سرعة السعر: %.5f\n", analysis.priceVelocity);
   result += StringFormat("تأكيد الحجم: %.2f\n", analysis.volumeConfirmation);
   result += StringFormat("مستوى التوافق: %s\n", EnumToString(analysis.confluenceLevel));
   result += StringFormat("نقاط الموثوقية: %.2f/1.0\n", analysis.reliabilityScore);
   result += "=========================";
   
   return result;
}

//+------------------------------------------------------------------+
//| حساب التقلبات المتقدم |
//+------------------------------------------------------------------+
double CAdvancedChartUtils::CalculateVolatility(const double &high[], const double &low[], 
                                               int period, int start)
{
   if(period <= 0 || start + period > ArraySize(high) || start < 0)
      return 0.0;
   
   double totalRange = 0.0;
   for(int i = start; i < start + period; i++)
   {
      totalRange += (high[i] - low[i]);
   }
   
   return totalRange / period;
}

//+------------------------------------------------------------------+
//| كشف توسع السعر |
//+------------------------------------------------------------------+
bool CAdvancedChartUtils::DetectPriceExpansion(const double &high[], const double &low[], 
                                              int period, int rates_total)
{
   if(rates_total < period * 2 || period <= 0)
      return false;
   
   // حساب متوسط المدى للفترة الحالية والسابقة
   double currentAvgRange = CalculateVolatility(high, low, period, rates_total - period);
   double previousAvgRange = CalculateVolatility(high, low, period, rates_total - period * 2);
   
   // التوسع يحدث عندما يزيد المدى الحالي عن السابق بشكل ملحوظ
   return (currentAvgRange > previousAvgRange * 1.5);
}

//+------------------------------------------------------------------+
//| كشف انكماش السعر |
//+------------------------------------------------------------------+
bool CAdvancedChartUtils::DetectPriceContraction(const double &high[], const double &low[], 
                                                int period, int rates_total)
{
   if(rates_total < period * 2 || period <= 0)
      return false;
   
   // حساب متوسط المدى للفترة الحالية والسابقة
   double currentAvgRange = CalculateVolatility(high, low, period, rates_total - period);
   double previousAvgRange = CalculateVolatility(high, low, period, rates_total - period * 2);
   
   // الانكماش يحدث عندما ينقص المدى الحالي عن السابق بشكل ملحوظ
   return (currentAvgRange < previousAvgRange * 0.7);
}

//+------------------------------------------------------------------+
//| تحليل هيكل السوق الصاعد |
//+------------------------------------------------------------------+
bool CAdvancedChartUtils::IsMarketStructureBullish(const double &high[], const double &low[], 
                                                  int lookback, int rates_total)
{
   if(rates_total < lookback || lookback <= 0)
      return false;
   
   // البحث عن قمم أعلى وقيعان أعلى
   int higherHighs = 0, higherLows = 0;
   double lastHigh = 0.0, lastLow = DBL_MAX;
   
   for(int i = rates_total - lookback; i < rates_total; i++)
   {
      if(high[i] > lastHigh)
      {
         higherHighs++;
         lastHigh = high[i];
      }
      
      if(low[i] > lastLow && lastLow != DBL_MAX)
      {
         higherLows++;
      }
      lastLow = MathMin(lastLow, low[i]);
   }
   
   // يعتبر الهيكل صاعد إذا كان هناك قمم وقيعان أعلى
   return (higherHighs >= 2 && higherLows >= 1);
}

//+------------------------------------------------------------------+
//| تحليل هيكل السوق الهابط |
//+------------------------------------------------------------------+
bool CAdvancedChartUtils::IsMarketStructureBearish(const double &high[], const double &low[], 
                                                  int lookback, int rates_total)
{
   if(rates_total < lookback || lookback <= 0)
      return false;
   
   // البحث عن قمم أدنى وقيعان أدنى
   int lowerHighs = 0, lowerLows = 0;
   double lastHigh = DBL_MAX, lastLow = 0.0;
   
   for(int i = rates_total - lookback; i < rates_total; i++)
   {
      if(high[i] < lastHigh && lastHigh != DBL_MAX)
      {
         lowerHighs++;
      }
      lastHigh = MathMin(lastHigh, high[i]);
      
      if(low[i] < lastLow)
      {
         lowerLows++;
         lastLow = low[i];
      }
   }
   
   // يعتبر الهيكل هابط إذا كان هناك قمم وقيعان أدنى
   return (lowerHighs >= 1 && lowerLows >= 2);
}

//+------------------------------------------------------------------+
//| حساب القوة المركبة |
//+------------------------------------------------------------------+
double CAdvancedChartUtils::CalculateCompoundStrength(const double &values[], int count)
{
   if(count <= 0)
      return 0.0;
      
   double total = 0.0;
   for(int i = 0; i < count; i++)
   {
      total += values[i];
   }
   
   return total / count;
}

//+------------------------------------------------------------------+