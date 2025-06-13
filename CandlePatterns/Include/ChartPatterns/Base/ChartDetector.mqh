//+------------------------------------------------------------------+
//|                                               ChartDetector.mqh |
//|                                   حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//|                                     https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../CandlePatterns/Base/CandleUtils.mqh"
#include "../../CandlePatterns/Base/TrendDetector.mqh"
#include "ChartPattern.mqh"
#include "ChartUtils.mqh"

//+------------------------------------------------------------------+
//| تعدادات أولويات الكشف                                          |
//+------------------------------------------------------------------+
enum ENUM_DETECTION_PRIORITY
  {
   PRIORITY_LOW = 1,       // أولوية منخفضة
   PRIORITY_NORMAL = 2,    // أولوية عادية
   PRIORITY_HIGH = 3,      // أولوية عالية
   PRIORITY_URGENT = 4     // أولوية عاجلة
  };

enum ENUM_DETECTION_MODE
  {
   MODE_REALTIME,          // الوقت الفعلي
   MODE_HISTORICAL,        // تاريخي
   MODE_BACKTEST,          // اختبار خلفي
   MODE_OPTIMIZATION       // تحسين
  };

enum ENUM_FILTER_TYPE
  {
   FILTER_TIMEFRAME,       // مرشح الإطار الزمني
   FILTER_RELIABILITY,     // مرشح الموثوقية
   FILTER_RISK_REWARD,     // مرشح المخاطرة/العائد
   FILTER_VOLUME,          // مرشح الحجم
   FILTER_TREND,           // مرشح الاتجاه
   FILTER_MARKET_HOURS,    // مرشح ساعات السوق
   FILTER_NEWS,            // مرشح الأخبار
   FILTER_VOLATILITY       // مرشح التقلبات
  };

//+------------------------------------------------------------------+
//| هيكل إعدادات الكشف                                              |
//+------------------------------------------------------------------+
struct SDetectionSettings
  {
   // إعدادات عامة
   ENUM_DETECTION_MODE mode;               // نمط الكشف
   bool              enableRealTimeDetection;           // تفعيل الكشف الفوري
   bool              enableHistoricalScan;              // تفعيل المسح التاريخي
   int               maxPatternsPerSymbol;               // الحد الأقصى للأنماط لكل رمز
   int               lookbackPeriod;                     // فترة البحث الخلفي

   // إعدادات الجودة
   double            minReliability;                  // الحد الأدنى للموثوقية
   double            minRiskReward;                   // الحد الأدنى للمخاطرة/العائد
   double            minConfidence;                   // الحد الأدنى للثقة
   double            tolerancePercent;                // نسبة التسامح

   // إعدادات المرشحات
   bool              enableTimeFilter;                  // تفعيل مرشح الوقت
   bool              enableVolumeFilter;                // تفعيل مرشح الحجم
   bool              enableTrendFilter;                 // تفعيل مرشح الاتجاه
   bool              enableVolatilityFilter;            // تفعيل مرشح التقلبات

   // إعدادات الأداء
   bool              enableMultiThreading;              // تفعيل المعالجة المتوازية
   bool              enableCaching;                     // تفعيل التخزين المؤقت
   int               maxProcessingTime;                  // الحد الأقصى لوقت المعالجة (ms)
   bool              optimizeMemoryUsage;               // تحسين استخدام الذاكرة

                     SDetectionSettings()
     {
      mode = MODE_REALTIME;
      enableRealTimeDetection = true;
      enableHistoricalScan = false;
      maxPatternsPerSymbol = 10;
      lookbackPeriod = 500;
      minReliability = 0.6;
      minRiskReward = 1.5;
      minConfidence = 0.7;
      tolerancePercent = 0.05;
      enableTimeFilter = true;
      enableVolumeFilter = true;
      enableTrendFilter = true;
      enableVolatilityFilter = false;
      enableMultiThreading = false;
      enableCaching = true;
      maxProcessingTime = 1000;
      optimizeMemoryUsage = true;
     }
  };

//+------------------------------------------------------------------+
//| هيكل إحصائيات الكشف                                            |
//+------------------------------------------------------------------+
struct SDetectionStatistics
  {
   // إحصائيات عامة
   int               totalPatternsDetected;              // إجمالي الأنماط المكتشفة
   int               validPatterns;                      // الأنماط الصحيحة
   int               filteredPatterns;                   // الأنماط المفلترة
   int               successfulSignals;                  // الإشارات الناجحة
   int               failedSignals;                      // الإشارات الفاشلة

   // إحصائيات الأداء
   double            averageProcessingTime;           // متوسط وقت المعالجة
   double            averageReliability;              // متوسط الموثوقية
   double            successRate;                     // معدل النجاح
   double            averageRiskReward;               // متوسط المخاطرة/العائد

   // إحصائيات زمنية
   datetime          firstDetection;                // أول كشف
   datetime          lastDetection;                 // آخر كشف
   datetime          lastUpdate;                    // آخر تحديث
   int               detectionsToday;                    // الاكتشافات اليوم
   int               detectionsThisWeek;                 // الاكتشافات هذا الأسبوع

                     SDetectionStatistics()
     {
      totalPatternsDetected = 0;
      validPatterns = 0;
      filteredPatterns = 0;
      successfulSignals = 0;
      failedSignals = 0;
      averageProcessingTime = 0.0;
      averageReliability = 0.0;
      successRate = 0.0;
      averageRiskReward = 0.0;
      firstDetection = 0;
      lastDetection = 0;
      lastUpdate = 0;
      detectionsToday = 0;
      detectionsThisWeek = 0;
     }
  };

//+------------------------------------------------------------------+
//| فئة محرك الكشف عن أنماط المخططات                               |
//+------------------------------------------------------------------+
class CChartDetector
  {
private:
   // مصفوفة الأنماط المسجلة
   CChartPattern*         m_patterns[];        // أنماط المخططات
   string                 m_patternNames[];    // أسماء الأنماط
   ENUM_DETECTION_PRIORITY m_priorities[];    // أولويات الكشف
   bool                   m_patternEnabled[];  // حالة تفعيل النمط

   // إعدادات النظام
   SDetectionSettings     m_settings;          // إعدادات الكشف
   SDetectionStatistics   m_statistics;        // إحصائيات الكشف

   // أدوات التحليل
   CTrendDetector*        m_trendDetector;     // كاشف الاتجاه

   // بيانات التخزين المؤقت
   SChartPatternSignal    m_cachedSignals[];   // الإشارات المخزنة
   datetime               m_lastCacheUpdate;   // آخر تحديث للذاكرة المؤقتة
   string                 m_cachedSymbol;      // الرمز المخزن
   ENUM_TIMEFRAMES        m_cachedTimeframe;   // الإطار الزمني المخزن

   // متغيرات الأداء
   datetime               m_lastProcessTime;   // آخر وقت معالجة
   int                    m_processedBars;     // الشموع المعالجة
   bool                   m_isProcessing;      // حالة المعالجة

   // متغيرات الذاكرة
   int                    m_maxMemoryUsage;    // الحد الأقصى لاستخدام الذاكرة
   int                    m_currentMemoryUsage; // الاستخدام الحالي للذاكرة

public:
   // المنشئ والهادم
                     CChartDetector();
                    ~CChartDetector();

   // دوال التهيئة والإعداد
   bool                   Initialize();
   void                   Deinitialize();
   bool                   RegisterPattern(CChartPattern* pattern, ENUM_DETECTION_PRIORITY priority = PRIORITY_NORMAL);
   bool                   UnregisterPattern(const string patternName);
   void                   EnablePattern(const string patternName, bool enable);
   bool                   IsPatternEnabled(const string patternName);

   // دوال الكشف الرئيسية
   int                    DetectPatterns(const string symbol, ENUM_TIMEFRAMES timeframe,
                                         const double &open[], const double &high[],
                                         const double &low[], const double &close[],
                                         const long &volume[], const datetime &time[],
                                         int rates_total, SChartPatternSignal &signals[]);

   bool                   DetectSinglePattern(const string patternName, const string symbol,
         ENUM_TIMEFRAMES timeframe,
         const double &open[], const double &high[],
         const double &low[], const double &close[],
         const long &volume[], const datetime &time[],
         int rates_total, SChartPatternSignal &signal);

   int                    ScanHistoricalData(const string symbol, ENUM_TIMEFRAMES timeframe,
         datetime startTime, datetime endTime,
         SChartPatternSignal &signals[]);

   // دوال المرشحات
   bool                   ApplyFilters(SChartPatternSignal &signal);
   bool                   ApplyTimeFilter(const SChartPatternSignal &signal);
   bool                   ApplyReliabilityFilter(const SChartPatternSignal &signal);
   bool                   ApplyRiskRewardFilter(const SChartPatternSignal &signal);
   bool                   ApplyVolumeFilter(const SChartPatternSignal &signal);
   bool                   ApplyTrendFilter(const SChartPatternSignal &signal);
   bool                   ApplyVolatilityFilter(const SChartPatternSignal &signal);

   // دوال إدارة الإعدادات
   void                   SetDetectionSettings(const SDetectionSettings &settings) { m_settings = settings; }
   SDetectionSettings     GetDetectionSettings() const { return m_settings; }
   void                   SetMinReliability(double reliability) { m_settings.minReliability = MathMax(0.1, reliability); }
   void                   SetMinRiskReward(double ratio) { m_settings.minRiskReward = MathMax(1.0, ratio); }
   void                   SetLookbackPeriod(int period) { m_settings.lookbackPeriod = MathMax(50, period); }
   void                   EnableTimeFilter(bool enable) { m_settings.enableTimeFilter = enable; }
   void                   EnableVolumeFilter(bool enable) { m_settings.enableVolumeFilter = enable; }
   void                   EnableTrendFilter(bool enable) { m_settings.enableTrendFilter = enable; }

   // دوال الحصول على المعلومات
   int                    GetRegisteredPatternsCount() const { return ArraySize(m_patterns); }
   string                 GetPatternName(int index) const;
   SDetectionStatistics   GetStatistics() const { return m_statistics; }
   bool                   IsProcessing() const { return m_isProcessing; }
   datetime               GetLastProcessTime() const { return m_lastProcessTime; }

   // دوال التخزين المؤقت
   bool                   EnableCaching(bool enable) { m_settings.enableCaching = enable; return true; }
   void                   ClearCache();
   int                    GetCachedSignalsCount() const { return ArraySize(m_cachedSignals); }
   bool                   GetCachedSignal(int index, SChartPatternSignal &signal);

   // دوال الإحصائيات والتقارير
   void                   UpdateStatistics(const SChartPatternSignal &signal, bool successful);
   void                   ResetStatistics();
   void                   PrintStatisticsReport();
   string                 GetStatisticsString();
   void                   SaveStatistics(const string fileName);
   bool                   LoadStatistics(const string fileName);

   // دوال التحسين والأداء
   void                   OptimizeMemoryUsage();
   void                   OptimizeProcessingSpeed();
   bool                   CheckPerformanceLimits();
   void                   SetMaxProcessingTime(int milliseconds) { m_settings.maxProcessingTime = MathMax(100, milliseconds); }

   // دوال التحديث والصيانة
   void                   Update();
   void                   OnTick();
   void                   OnNewBar();
   void                   OnTimer();

   // دوال التشخيص وإصلاح الأخطاء
   bool                   ValidateConfiguration();
   void                   RunDiagnostics();
   string                 GetLastError();
   void                   ClearErrors();

private:
   // دوال مساعدة خاصة
   int                    FindPatternIndex(const string patternName);
   bool                   ValidatePatternData(CChartPattern* pattern);
   void                   SortSignalsByPriority(SChartPatternSignal &signals[]);
   void                   SortSignalsByReliability(SChartPatternSignal &signals[]);
   void                   SortSignalsByTime(SChartPatternSignal &signals[]);

   // دوال إدارة الذاكرة
   bool                   AllocateMemory(int requiredSize);
   void                   FreeUnusedMemory();
   int                    CalculateMemoryUsage();
   void                   UpdateMemoryStatistics();

   // دوال معالجة البيانات
   bool                   PreprocessData(const double &open[], const double &high[],
                                         const double &low[], const double &close[],
                                         const long &volume[], int rates_total);

   bool                   ValidateInputData(const double &open[], const double &high[],
         const double &low[], const double &close[],
         const long &volume[], int rates_total);

   void                   CleanupExpiredSignals();
   void                   RemoveDuplicateSignals(SChartPatternSignal &signals[]);

   // دوال التحسين
   void                   OptimizePatternOrder();
   void                   UpdateProcessingStatistics(ulong startTime, ulong endTime);
   bool                   ShouldSkipPattern(const string patternName, datetime currentTime);

   // دوال الأمان والتحقق
   bool                   CheckSystemResources();
   bool                   ValidateTimeframe(ENUM_TIMEFRAMES timeframe);
   bool                   CheckDataIntegrity(const double &prices[], int size);

   // دوال التسجيل والمراقبة
   void                   LogDetection(const SChartPatternSignal &signal);
   void                   LogError(const string error);
   void                   LogPerformance(double processingTime, int patternsDetected);

   // متغيرات خاصة للحالة
   string                 m_lastError;         // آخر خطأ
   bool                   m_initialized;       // حالة التهيئة
   int                    m_errorCount;        // عدد الأخطاء
   datetime               m_startTime;         // وقت البداية
  };

//+------------------------------------------------------------------+
//| منشئ محرك الكشف                                                  |
//+------------------------------------------------------------------+
CChartDetector::CChartDetector()
  {
// تهيئة المتغيرات
   m_trendDetector = NULL;
   m_lastCacheUpdate = 0;
   m_cachedSymbol = "";
   m_cachedTimeframe = PERIOD_CURRENT;
   m_lastProcessTime = 0;
   m_processedBars = 0;
   m_isProcessing = false;
   m_maxMemoryUsage = 1024 * 1024; // 1 MB
   m_currentMemoryUsage = 0;
   m_lastError = "";
   m_initialized = false;
   m_errorCount = 0;
   m_startTime = TimeCurrent();

// تهيئة المصفوفات
   ArrayResize(m_patterns, 0);
   ArrayResize(m_patternNames, 0);
   ArrayResize(m_priorities, 0);
   ArrayResize(m_patternEnabled, 0);
   ArrayResize(m_cachedSignals, 0);
  }

//+------------------------------------------------------------------+
//| هادم محرك الكشف                                                  |
//+------------------------------------------------------------------+
CChartDetector::~CChartDetector()
  {
   Deinitialize();
  }

//+------------------------------------------------------------------+
//| تهيئة محرك الكشف                                                 |
//+------------------------------------------------------------------+
bool CChartDetector::Initialize()
  {
   if(m_initialized)
      return true;

// تهيئة أدوات التحليل
   m_trendDetector = new CTrendDetector(TREND_ALGO_COMPOSITE, 20);
   if(m_trendDetector == NULL)
     {
      m_lastError = "فشل في إنشاء كاشف الاتجاه";
      return false;
     }

// تهيئة ChartUtils
   if(!CChartUtils::Initialize())
     {
      m_lastError = "فشل في تهيئة أدوات المخططات: " + CChartUtils::GetLastError();
      return false;
     }

// إعداد الإعدادات الافتراضية
   m_settings = SDetectionSettings();
   m_statistics = SDetectionStatistics();

   m_initialized = true;
   m_lastError = "";
   return true;
  }

//+------------------------------------------------------------------+
//| إنهاء محرك الكشف                                                 |
//+------------------------------------------------------------------+
void CChartDetector::Deinitialize()
  {
   if(!m_initialized)
      return;

// تنظيف أنماط المخططات
   for(int i = 0; i < ArraySize(m_patterns); i++)
     {
      if(m_patterns[i] != NULL)
        {
         delete m_patterns[i];
         m_patterns[i] = NULL;
        }
     }

// تنظيف كاشف الاتجاه
   if(m_trendDetector != NULL)
     {
      delete m_trendDetector;
      m_trendDetector = NULL;
     }

// تنظيف الذاكرة
   ArrayResize(m_patterns, 0);
   ArrayResize(m_patternNames, 0);
   ArrayResize(m_priorities, 0);
   ArrayResize(m_patternEnabled, 0);
   ArrayResize(m_cachedSignals, 0);

// تنظيف ChartUtils
   CChartUtils::Deinitialize();

   m_initialized = false;
   m_lastError = "";
  }

//+------------------------------------------------------------------+
//| تسجيل نمط جديد                                                   |
//+------------------------------------------------------------------+
bool CChartDetector::RegisterPattern(CChartPattern* pattern, ENUM_DETECTION_PRIORITY priority)
  {
   if(!m_initialized)
     {
      m_lastError = "محرك الكشف غير مهيأ";
      return false;
     }

   if(pattern == NULL)
     {
      m_lastError = "مؤشر النمط فارغ";
      return false;
     }

// التحقق من عدم وجود النمط مسبقاً
   string patternName = pattern.GetName();
   if(FindPatternIndex(patternName) >= 0)
     {
      m_lastError = "النمط " + patternName + " موجود بالفعل";
      return false;
     }

// إضافة النمط
   int size = ArraySize(m_patterns);
   ArrayResize(m_patterns, size + 1);
   ArrayResize(m_patternNames, size + 1);
   ArrayResize(m_priorities, size + 1);
   ArrayResize(m_patternEnabled, size + 1);

   m_patterns[size] = pattern;
   m_patternNames[size] = patternName;
   m_priorities[size] = priority;
   m_patternEnabled[size] = true;

   m_lastError = "";
   return true;
  }

//+------------------------------------------------------------------+
//| إلغاء تسجيل نمط                                                 |
//+------------------------------------------------------------------+
bool CChartDetector::UnregisterPattern(const string patternName)
  {
   if(!m_initialized)
     {
      m_lastError = "محرك الكشف غير مهيأ";
      return false;
     }

   int index = FindPatternIndex(patternName);
   if(index < 0)
     {
      m_lastError = "النمط " + patternName + " غير موجود";
      return false;
     }

// حذف النمط
   if(m_patterns[index] != NULL)
     {
      delete m_patterns[index];
      m_patterns[index] = NULL;
     }

// إعادة ترتيب المصفوفات
   for(int i = index; i < ArraySize(m_patterns) - 1; i++)
     {
      m_patterns[i] = m_patterns[i + 1];
      m_patternNames[i] = m_patternNames[i + 1];
      m_priorities[i] = m_priorities[i + 1];
      m_patternEnabled[i] = m_patternEnabled[i + 1];
     }

// تقليص حجم المصفوفات
   int newSize = ArraySize(m_patterns) - 1;
   ArrayResize(m_patterns, newSize);
   ArrayResize(m_patternNames, newSize);
   ArrayResize(m_priorities, newSize);
   ArrayResize(m_patternEnabled, newSize);

   m_lastError = "";
   return true;
  }

//+------------------------------------------------------------------+
//| تفعيل/إلغاء تفعيل نمط                                           |
//+------------------------------------------------------------------+
void CChartDetector::EnablePattern(const string patternName, bool enable)
  {
   int index = FindPatternIndex(patternName);
   if(index >= 0)
      m_patternEnabled[index] = enable;
  }

//+------------------------------------------------------------------+
//| التحقق من حالة تفعيل النمط                                       |
//+------------------------------------------------------------------+
bool CChartDetector::IsPatternEnabled(const string patternName)
  {
   int index = FindPatternIndex(patternName);
   return (index >= 0) ? m_patternEnabled[index] : false;
  }

//+------------------------------------------------------------------+
//| الكشف عن الأنماط الرئيسي                                        |
//+------------------------------------------------------------------+
int CChartDetector::DetectPatterns(const string symbol, ENUM_TIMEFRAMES timeframe,
                                   const double &open[], const double &high[],
                                   const double &low[], const double &close[],
                                   const long &volume[], const datetime &time[],
                                   int rates_total, SChartPatternSignal &signals[])
  {
   if(!m_initialized)
     {
      m_lastError = "محرك الكشف غير مهيأ";
      return 0;
     }

   m_isProcessing = true;
   ulong startTime = GetTickCount(); // الحصول على وقت بالميلي ثانية

// التحقق من صحة البيانات
   if(!ValidateInputData(open, high, low, close, volume, rates_total))
     {
      m_isProcessing = false;
      return 0;
     }

// تنظيف الإشارات السابقة
   ArrayResize(signals, 0);

   int detectedCount = 0;

// البحث في كل نمط مسجل
   for(int i = 0; i < ArraySize(m_patterns); i++)
     {
      if(!m_patternEnabled[i] || m_patterns[i] == NULL)
         continue;

      // التحقق من حدود الوقت
      ulong currentTime = GetTickCount();
      if(currentTime - startTime > (ulong)m_settings.maxProcessingTime)
        {
         Print("تم تجاوز حد الوقت المسموح للمعالجة");
         break;
        }

      int patternStart, patternEnd;

      // محاولة كشف النمط
      if(m_patterns[i].Detect(open, high, low, close, volume, time,
                              rates_total, patternStart, patternEnd))
        {
         // إنتاج الإشارة
         SChartPatternSignal signal = m_patterns[i].GenerateSignal(symbol, timeframe,
                                      open, high, low, close,
                                      volume, time,
                                      patternStart, patternEnd);

         // تطبيق المرشحات
         if(ApplyFilters(signal))
           {
            int size = ArraySize(signals);
            ArrayResize(signals, size + 1);
            signals[size] = signal;
            detectedCount++;

            // تحديث الإحصائيات
            m_statistics.totalPatternsDetected++;
            m_statistics.validPatterns++;
            m_statistics.lastDetection = TimeCurrent();

            // التحقق من الحد الأقصى
            if(detectedCount >= m_settings.maxPatternsPerSymbol)
               break;
           }
         else
           {
            m_statistics.filteredPatterns++;
           }
        }
     }

// ترتيب الإشارات حسب الأولوية
   if(detectedCount > 1)
      SortSignalsByReliability(signals);

// تحديث إحصائيات الأداء
   ulong endTime = GetTickCount();
   UpdateProcessingStatistics(startTime, endTime);

   m_isProcessing = false;
   m_lastProcessTime = TimeCurrent();

   return detectedCount;
  }

//+------------------------------------------------------------------+
//| كشف نمط واحد محدد                                               |
//+------------------------------------------------------------------+
bool CChartDetector::DetectSinglePattern(const string patternName, const string symbol,
      ENUM_TIMEFRAMES timeframe,
      const double &open[], const double &high[],
      const double &low[], const double &close[],
      const long &volume[], const datetime &time[],
      int rates_total, SChartPatternSignal &signal)
  {
   if(!m_initialized)
     {
      m_lastError = "محرك الكشف غير مهيأ";
      return false;
     }

   int index = FindPatternIndex(patternName);
   if(index < 0)
     {
      m_lastError = "النمط " + patternName + " غير موجود";
      return false;
     }

   if(!m_patternEnabled[index] || m_patterns[index] == NULL)
     {
      m_lastError = "النمط " + patternName + " غير مفعل أو تالف";
      return false;
     }

// التحقق من صحة البيانات
   if(!ValidateInputData(open, high, low, close, volume, rates_total))
      return false;

   int patternStart, patternEnd;

// محاولة كشف النمط
   if(m_patterns[index].Detect(open, high, low, close, volume, time,
                               rates_total, patternStart, patternEnd))
     {
      // إنتاج الإشارة
      signal = m_patterns[index].GenerateSignal(symbol, timeframe,
               open, high, low, close,
               volume, time,
               patternStart, patternEnd);

      // تطبيق المرشحات
      if(ApplyFilters(signal))
        {
         // تحديث الإحصائيات
         m_statistics.totalPatternsDetected++;
         m_statistics.validPatterns++;
         m_statistics.lastDetection = TimeCurrent();

         m_lastError = "";
         return true;
        }
      else
        {
         m_statistics.filteredPatterns++;
         m_lastError = "تم رفض الإشارة بواسطة المرشحات";
         return false;
        }
     }

   m_lastError = "لم يتم العثور على النمط";
   return false;
  }

//+------------------------------------------------------------------+
//| تطبيق المرشحات على الإشارة                                     |
//+------------------------------------------------------------------+
bool CChartDetector::ApplyFilters(SChartPatternSignal &signal)
  {
// مرشح الموثوقية
   if(!ApplyReliabilityFilter(signal))
      return false;

// مرشح الثقة
   if(signal.confidence < m_settings.minConfidence)
      return false;

// مرشح المخاطرة/العائد
   if(!ApplyRiskRewardFilter(signal))
      return false;

// مرشح الوقت
   if(m_settings.enableTimeFilter && !ApplyTimeFilter(signal))
      return false;

// مرشح الحجم
   if(m_settings.enableVolumeFilter && !ApplyVolumeFilter(signal))
      return false;

// مرشح الاتجاه
   if(m_settings.enableTrendFilter && !ApplyTrendFilter(signal))
      return false;

// مرشح التقلبات
   if(m_settings.enableVolatilityFilter && !ApplyVolatilityFilter(signal))
      return false;

   return true;
  }

//+------------------------------------------------------------------+
//| مرشح الموثوقية                                                  |
//+------------------------------------------------------------------+
bool CChartDetector::ApplyReliabilityFilter(const SChartPatternSignal &signal)
  {
   return (signal.reliability >= m_settings.minReliability);
  }

//+------------------------------------------------------------------+
//| مرشح المخاطرة/العائد                                            |
//+------------------------------------------------------------------+
bool CChartDetector::ApplyRiskRewardFilter(const SChartPatternSignal &signal)
  {
   return (signal.riskReward >= m_settings.minRiskReward);
  }

//+------------------------------------------------------------------+
//| مرشح الوقت                                                      |
//+------------------------------------------------------------------+
bool CChartDetector::ApplyTimeFilter(const SChartPatternSignal &signal)
  {
// يمكن تطبيق قواعد الوقت مثل تجنب الأوقات ذات السيولة المنخفضة
// أو التداول خلال جلسات معينة فقط
   return true; // مقبول افتراضياً
  }

//+------------------------------------------------------------------+
//| مرشح الحجم                                                      |
//+------------------------------------------------------------------+
bool CChartDetector::ApplyVolumeFilter(const SChartPatternSignal &signal)
  {
// التحقق من تأكيد الحجم إذا كان متاحاً
   return signal.volumeConfirmed || !m_settings.enableVolumeFilter;
  }

//+------------------------------------------------------------------+
//| مرشح الاتجاه                                                    |
//+------------------------------------------------------------------+
bool CChartDetector::ApplyTrendFilter(const SChartPatternSignal &signal)
  {
// التحقق من تأكيد الاتجاه إذا كان متاحاً
   return signal.trendConfirmed || !m_settings.enableTrendFilter;
  }

//+------------------------------------------------------------------+
//| مرشح التقلبات                                                   |
//+------------------------------------------------------------------+
bool CChartDetector::ApplyVolatilityFilter(const SChartPatternSignal &signal)
  {
// يمكن تطبيق قواعد التقلبات هنا
   return true; // مقبول افتراضياً
  }

//+------------------------------------------------------------------+
//| البحث عن فهرس النمط                                              |
//+------------------------------------------------------------------+
int CChartDetector::FindPatternIndex(const string patternName)
  {
   for(int i = 0; i < ArraySize(m_patternNames); i++)
     {
      if(m_patternNames[i] == patternName)
         return i;
     }
   return -1;
  }

//+------------------------------------------------------------------+
//| الحصول على اسم النمط حسب الفهرس                                 |
//+------------------------------------------------------------------+
string CChartDetector::GetPatternName(int index) const
  {
   if(index >= 0 && index < ArraySize(m_patternNames))
      return m_patternNames[index];
   return "";
  }

//+------------------------------------------------------------------+
//| ترتيب الإشارات حسب الموثوقية                                   |
//+------------------------------------------------------------------+
void CChartDetector::SortSignalsByReliability(SChartPatternSignal &signals[])
  {
   int size = ArraySize(signals);

// ترتيب تنازلي حسب الموثوقية
   for(int i = 0; i < size - 1; i++)
     {
      for(int j = i + 1; j < size; j++)
        {
         if(signals[j].reliability > signals[i].reliability)
           {
            SChartPatternSignal temp = signals[i];
            signals[i] = signals[j];
            signals[j] = temp;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| التحقق من صحة البيانات المدخلة                                   |
//+------------------------------------------------------------------+
bool CChartDetector::ValidateInputData(const double &open[], const double &high[],
                                       const double &low[], const double &close[],
                                       const long &volume[], int rates_total)
  {
   if(rates_total < m_settings.lookbackPeriod)
     {
      m_lastError = "عدد الشموع أقل من الحد الأدنى المطلوب";
      return false;
     }

   if(!CCandleUtils::ValidateArrays(open, high, low, close, rates_total))
     {
      m_lastError = "بيانات الشموع غير صحيحة";
      return false;
     }

   if(ArraySize(volume) > 0 && !CCandleUtils::ValidateArray(volume, rates_total))
     {
      m_lastError = "بيانات الحجم غير صحيحة";
      return false;
     }

   return true;
  }

//+------------------------------------------------------------------+
//| تحديث إحصائيات المعالجة                                         |
//+------------------------------------------------------------------+
void CChartDetector::UpdateProcessingStatistics(ulong startTime, ulong endTime)
  {
   double processingTime = (double)(endTime - startTime); // بالميلي ثانية

   if(m_statistics.averageProcessingTime == 0.0)
      m_statistics.averageProcessingTime = processingTime;
   else
      m_statistics.averageProcessingTime = (m_statistics.averageProcessingTime + processingTime) / 2.0;

   m_statistics.lastUpdate = TimeCurrent();
  }

//+------------------------------------------------------------------+
//| تحديث الإحصائيات                                                |
//+------------------------------------------------------------------+
void CChartDetector::UpdateStatistics(const SChartPatternSignal &signal, bool successful)
  {
   if(successful)
      m_statistics.successfulSignals++;
   else
      m_statistics.failedSignals++;

// تحديث معدل النجاح
   int totalSignals = m_statistics.successfulSignals + m_statistics.failedSignals;
   if(totalSignals > 0)
      m_statistics.successRate = (double)m_statistics.successfulSignals / totalSignals * 100.0;

// تحديث متوسط الموثوقية
   if(m_statistics.averageReliability == 0.0)
      m_statistics.averageReliability = signal.reliability;
   else
      m_statistics.averageReliability = (m_statistics.averageReliability + signal.reliability) / 2.0;

// تحديث متوسط المخاطرة/العائد
   if(m_statistics.averageRiskReward == 0.0)
      m_statistics.averageRiskReward = signal.riskReward;
   else
      m_statistics.averageRiskReward = (m_statistics.averageRiskReward + signal.riskReward) / 2.0;

   m_statistics.lastUpdate = TimeCurrent();
  }

//+------------------------------------------------------------------+
//| إعادة تعيين الإحصائيات                                          |
//+------------------------------------------------------------------+
void CChartDetector::ResetStatistics()
  {
   m_statistics = SDetectionStatistics();
  }

//+------------------------------------------------------------------+
//| طباعة تقرير الإحصائيات                                           |
//+------------------------------------------------------------------+
void CChartDetector::PrintStatisticsReport()
  {
   Print("===== تقرير إحصائيات كاشف أنماط المخططات =====");
   Print("إجمالي الأنماط المكتشفة: ", m_statistics.totalPatternsDetected);
   Print("الأنماط الصحيحة: ", m_statistics.validPatterns);
   Print("الأنماط المفلترة: ", m_statistics.filteredPatterns);
   Print("الإشارات الناجحة: ", m_statistics.successfulSignals);
   Print("الإشارات الفاشلة: ", m_statistics.failedSignals);
   Print("معدل النجاح: ", DoubleToString(m_statistics.successRate, 2), "%");
   Print("متوسط وقت المعالجة: ", DoubleToString(m_statistics.averageProcessingTime, 2), " ms");
   Print("متوسط الموثوقية: ", DoubleToString(m_statistics.averageReliability, 3));
   Print("متوسط المخاطرة/العائد: ", DoubleToString(m_statistics.averageRiskReward, 2));
   Print("عدد الأنماط المسجلة: ", ArraySize(m_patterns));
   Print("===================================");
  }

//+------------------------------------------------------------------+
//| الحصول على سلسلة الإحصائيات                                     |
//+------------------------------------------------------------------+
string CChartDetector::GetStatisticsString()
  {
   string result = "";
   result += "إجمالي الأنماط: " + IntegerToString(m_statistics.totalPatternsDetected) + "\n";
   result += "الأنماط الصحيحة: " + IntegerToString(m_statistics.validPatterns) + "\n";
   result += "معدل النجاح: " + DoubleToString(m_statistics.successRate, 2) + "%\n";
   result += "متوسط الموثوقية: " + DoubleToString(m_statistics.averageReliability, 3) + "\n";
   result += "متوسط وقت المعالجة: " + DoubleToString(m_statistics.averageProcessingTime, 2) + " ms";
   return result;
  }

//+------------------------------------------------------------------+
//| تنظيف الذاكرة المؤقتة                                            |
//+------------------------------------------------------------------+
void CChartDetector::ClearCache()
  {
   ArrayResize(m_cachedSignals, 0);
   m_lastCacheUpdate = 0;
   m_cachedSymbol = "";
   m_cachedTimeframe = PERIOD_CURRENT;
  }

//+------------------------------------------------------------------+
//| الحصول على إشارة مخزنة                                          |
//+------------------------------------------------------------------+
bool CChartDetector::GetCachedSignal(int index, SChartPatternSignal &signal)
  {
   if(index >= 0 && index < ArraySize(m_cachedSignals))
     {
      signal = m_cachedSignals[index];
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| التحقق من صحة التكوين                                           |
//+------------------------------------------------------------------+
bool CChartDetector::ValidateConfiguration()
  {
   if(!m_initialized)
     {
      m_lastError = "المحرك غير مهيأ";
      return false;
     }

   if(ArraySize(m_patterns) == 0)
     {
      m_lastError = "لا توجد أنماط مسجلة";
      return false;
     }

   if(m_trendDetector == NULL)
     {
      m_lastError = "كاشف الاتجاه غير متاح";
      return false;
     }

   m_lastError = "";
   return true;
  }

//+------------------------------------------------------------------+
//| تشغيل التشخيصات                                                 |
//+------------------------------------------------------------------+
void CChartDetector::RunDiagnostics()
  {
   Print("===== تشخيصات محرك كشف الأنماط =====");
   Print("حالة التهيئة: ", m_initialized ? "مهيأ" : "غير مهيأ");
   Print("عدد الأنماط المسجلة: ", ArraySize(m_patterns));
   Print("حالة المعالجة: ", m_isProcessing ? "يعمل" : "متوقف");
   Print("استخدام الذاكرة: ", m_currentMemoryUsage, " بايت");
   Print("آخر خطأ: ", m_lastError == "" ? "لا يوجد" : m_lastError);
   Print("===================================");
  }

//+------------------------------------------------------------------+
//| الحصول على آخر خطأ                                              |
//+------------------------------------------------------------------+
string CChartDetector::GetLastError()
  {
   return m_lastError;
  }

//+------------------------------------------------------------------+
//| مسح الأخطاء                                                     |
//+------------------------------------------------------------------+
void CChartDetector::ClearErrors()
  {
   m_lastError = "";
   m_errorCount = 0;
  }

//+------------------------------------------------------------------+
//| التحديث العام                                                   |
//+------------------------------------------------------------------+
void CChartDetector::Update()
  {
   if(!m_initialized)
      return;

// تنظيف الإشارات المنتهية الصلاحية
   CleanupExpiredSignals();

// تحسين استخدام الذاكرة إذا لزم الأمر
   if(m_settings.optimizeMemoryUsage)
      OptimizeMemoryUsage();
  }

//+------------------------------------------------------------------+
//| تنظيف الإشارات المنتهية الصلاحية                               |
//+------------------------------------------------------------------+
void CChartDetector::CleanupExpiredSignals()
  {
   datetime currentTime = TimeCurrent();
   datetime expirationTime = 24 * 60 * 60; // 24 ساعة

   for(int i = ArraySize(m_cachedSignals) - 1; i >= 0; i--)
     {
      if(currentTime - m_cachedSignals[i].signalTime > expirationTime)
        {
         // إزالة الإشارة المنتهية الصלاحية
         for(int j = i; j < ArraySize(m_cachedSignals) - 1; j++)
           {
            m_cachedSignals[j] = m_cachedSignals[j + 1];
           }
         ArrayResize(m_cachedSignals, ArraySize(m_cachedSignals) - 1);
        }
     }
  }

//+------------------------------------------------------------------+
//| تحسين استخدام الذاكرة                                           |
//+------------------------------------------------------------------+
void CChartDetector::OptimizeMemoryUsage()
  {
// تنظيف الذاكرة المؤقتة إذا تجاوزت الحد المسموح
   if(m_currentMemoryUsage > m_maxMemoryUsage * 0.8)
     {
      ClearCache();
     }

// تحديث إحصائيات الذاكرة
   UpdateMemoryStatistics();
  }

//+------------------------------------------------------------------+
//| تحديث إحصائيات الذاكرة                                          |
//+------------------------------------------------------------------+
void CChartDetector::UpdateMemoryStatistics()
  {
// حساب تقريبي لاستخدام الذاكرة
   m_currentMemoryUsage = 0;
   m_currentMemoryUsage += ArraySize(m_patterns) * sizeof(void*);
   m_currentMemoryUsage += ArraySize(m_patternNames) * 50; // تقدير متوسط طول الاسم
   m_currentMemoryUsage += ArraySize(m_cachedSignals) * sizeof(SChartPatternSignal);
  }

//+------------------------------------------------------------------+
//| الأحداث - OnTick                                                 |
//+------------------------------------------------------------------+
void CChartDetector::OnTick()
  {
   if(!m_initialized || m_isProcessing)
      return;

// يمكن إضافة منطق معالجة التيك هنا
  }

//+------------------------------------------------------------------+
//| الأحداث - OnNewBar                                               |
//+------------------------------------------------------------------+
void CChartDetector::OnNewBar()
  {
   if(!m_initialized)
      return;

// يمكن تشغيل الكشف التلقائي عند شمعة جديدة
   Update();
  }

//+------------------------------------------------------------------+
//| الأحداث - OnTimer                                                |
//+------------------------------------------------------------------+
void CChartDetector::OnTimer()
  {
   if(!m_initialized)
      return;

// تنظيف دوري
   Update();
  }

//+------------------------------------------------------------------+
//| حفظ الإحصائيات                                                  |
//+------------------------------------------------------------------+
void CChartDetector::SaveStatistics(const string fileName)
  {
   int fileHandle = FileOpen(fileName, FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      FileWrite(fileHandle, GetStatisticsString());
      FileClose(fileHandle);
      Print("تم حفظ الإحصائيات في الملف: ", fileName);
     }
   else
     {
      Print("خطأ في حفظ الإحصائيات: ", GetLastError());
     }
  }

//+------------------------------------------------------------------+
//| تحميل الإحصائيات                                                |
//+------------------------------------------------------------------+
bool CChartDetector::LoadStatistics(const string fileName)
  {
   int fileHandle = FileOpen(fileName, FILE_READ | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      // يمكن تطبيق منطق تحميل الإحصائيات هنا
      FileClose(fileHandle);
      Print("تم تحميل الإحصائيات من الملف: ", fileName);
      return true;
     }
   else
     {
      Print("خطأ في تحميل الإحصائيات: ", GetLastError());
      return false;
     }
  }

//+------------------------------------------------------------------+
//| مسح المسح التاريخي                                              |
//+------------------------------------------------------------------+
int CChartDetector::ScanHistoricalData(const string symbol, ENUM_TIMEFRAMES timeframe,
                                       datetime startTime, datetime endTime,
                                       SChartPatternSignal &signals[])
  {
   if(!m_initialized)
     {
      m_lastError = "محرك الكشف غير مهيأ";
      return 0;
     }

// تنظيف المصفوفة
   ArrayResize(signals, 0);

// يمكن تطبيق منطق المسح التاريخي هنا
// هذا يتطلب تحميل البيانات التاريخية وتطبيق الكشف عليها

   Print("المسح التاريخي من ", TimeToString(startTime), " إلى ", TimeToString(endTime));

   return 0; // مؤقت
  }

//+------------------------------------------------------------------+