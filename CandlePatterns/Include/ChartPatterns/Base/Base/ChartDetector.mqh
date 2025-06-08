//+------------------------------------------------------------------+
//|                                              ChartDetector.mqh |
//|                             محرك الكشف عن أنماط المخططات      |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "ChartPattern.mqh"
#include "ChartUtils.mqh"
#include "TrendLineDetector.mqh"
#include "SupportResistance.mqh"

//+------------------------------------------------------------------+
//| إعدادات محرك الكشف                                              |
//+------------------------------------------------------------------+
struct SChartDetectorSettings
{
   bool              detectReversals;       // كشف أنماط الانعكاس
   bool              detectContinuations;   // كشف أنماط الاستمرار
   bool              detectHarmonic;        // كشف الأنماط التوافقية
   bool              detectElliott;         // كشف أمواج إليوت
   bool              detectVolume;          // كشف أنماط الحجم
   
   double            minPatternReliability; // أقل موثوقية مقبولة
   double            minPatternStrength;    // أقل قوة مقبولة
   int               maxPatternsPerBar;     // أقصى عدد أنماط لكل شمعة
   
   bool              useStrictMode;         // استخدام الوضع الصارم
   bool              enableVolumeFilter;    // تفعيل فلتر الحجم
   bool              enableTrendFilter;     // تفعيل فلتر الاتجاه
   
   int               lookbackPeriod;        // فترة الاستعراض
   double            noiseFilterLevel;      // مستوى تصفية الضوضاء
   
   SChartDetectorSettings()
   {
      detectReversals = true;
      detectContinuations = true;
      detectHarmonic = false;
      detectElliott = false;
      detectVolume = false;
      
      minPatternReliability = 0.3;
      minPatternStrength = 0.2;
      maxPatternsPerBar = 3;
      
      useStrictMode = false;
      enableVolumeFilter = false;
      enableTrendFilter = true;
      
      lookbackPeriod = 100;
      noiseFilterLevel = 0.1;
   }
};

//+------------------------------------------------------------------+
//| فئة محرك الكشف عن أنماط المخططات                                |
//+------------------------------------------------------------------+
class CChartDetector
{
private:
   // إعدادات المحرك
   SChartDetectorSettings m_settings;
   bool              m_initialized;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   
   // مكونات التحليل
   CChartUtils      *m_chartUtils;
   CTrendLineDetector *m_trendDetector;
   CSupportResistance *m_srDetector;
   
   // مصفوفات البيانات
   CChartPattern    *m_patterns[];         // مصفوفة الأنماط المسجلة
   SChartPatternResult m_recentResults[];  // النتائج الأخيرة
   
   // إحصائيات الأداء
   int               m_totalDetections;
   int               m_successfulDetections;
   double            m_avgReliability;
   
public:
   // المنشئ والهادم
                     CChartDetector();
                     ~CChartDetector();
   
   // تهيئة المحرك
   bool              Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   void              Deinitialize();
   
   // إدارة الإعدادات
   void              SetSettings(const SChartDetectorSettings &settings) { m_settings = settings; }
   SChartDetectorSettings GetSettings() const { return m_settings; }
   void              SetDetectionTypes(bool reversals, bool continuations, bool harmonic = false, 
                                     bool elliott = false, bool volume = false);
   
   // تسجيل الأنماط
   bool              RegisterPattern(CChartPattern *pattern);
   void              UnregisterPattern(const string patternName);
   void              ClearPatterns();
   int               GetRegisteredPatternsCount() const { return ArraySize(m_patterns); }
   
   // الكشف عن الأنماط
   int               DetectAllPatterns(const int startIdx, const int endIdx,
                                     SChartPatternResult &results[]);
   int               DetectPatternsByType(const int startIdx, const int endIdx,
                                        const ENUM_CHART_PATTERN_TYPE patternType,
                                        SChartPatternResult &results[]);
   
   // تحليل النتائج
   bool              ValidatePattern(const SChartPatternResult &result);
   void              FilterResults(SChartPatternResult &results[]);
   void              SortResultsByReliability(SChartPatternResult &results[]);
   
   // معلومات الأداء
   double            GetSuccessRate() const;
   double            GetAverageReliability() const { return m_avgReliability; }
   int               GetTotalDetections() const { return m_totalDetections; }
   
   // الوصول للمكونات
   CChartUtils      *GetChartUtils() const { return m_chartUtils; }
   CTrendLineDetector *GetTrendDetector() const { return m_trendDetector; }
   CSupportResistance *GetSRDetector() const { return m_srDetector; }
   
protected:
   // دوال مساعدة
   bool              PrepareData(const int startIdx, const int endIdx);
   void              UpdateStatistics(const SChartPatternResult &results[]);
   bool              PassesFilters(const SChartPatternResult &result);
   
   // تحسين الأداء
   bool              IsPatternRedundant(const SChartPatternResult &newPattern, 
                                       const SChartPatternResult &existingPatterns[]);
   void              OptimizeResults(SChartPatternResult &results[]);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CChartDetector::CChartDetector()
{
   m_initialized = false;
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   
   m_chartUtils = NULL;
   m_trendDetector = NULL;
   m_srDetector = NULL;
   
   ArrayResize(m_patterns, 0);
   ArrayResize(m_recentResults, 0);
   
   m_totalDetections = 0;
   m_successfulDetections = 0;
   m_avgReliability = 0.0;
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CChartDetector::~CChartDetector()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة المحرك                                                     |
//+------------------------------------------------------------------+
bool CChartDetector::Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(m_initialized)
      Deinitialize();
   
   m_symbol = (symbol == "") ? Symbol() : symbol;
   m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
   
   // إنشاء مكونات التحليل
   m_chartUtils = new CChartUtils();
   if(!m_chartUtils.Initialize(m_symbol, m_timeframe))
   {
      Print("خطأ في تهيئة CChartUtils");
      return false;
   }
   
   m_trendDetector = new CTrendLineDetector();
   if(!m_trendDetector.Initialize(m_symbol, m_timeframe))
   {
      Print("خطأ في تهيئة CTrendLineDetector");
      return false;
   }
   
   m_srDetector = new CSupportResistance();
   if(!m_srDetector.Initialize(m_symbol, m_timeframe))
   {
      Print("خطأ في تهيئة CSupportResistance");
      return false;
   }
   
   m_initialized = true;
   Print("تم تهيئة محرك الكشف عن أنماط المخططات بنجاح");
   
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء المحرك                                                    |
//+------------------------------------------------------------------+
void CChartDetector::Deinitialize()
{
   if(m_initialized)
   {
      // حذف مكونات التحليل
      if(m_chartUtils != NULL)
      {
         delete m_chartUtils;
         m_chartUtils = NULL;
      }
      
      if(m_trendDetector != NULL)
      {
         delete m_trendDetector;
         m_trendDetector = NULL;
      }
      
      if(m_srDetector != NULL)
      {
         delete m_srDetector;
         m_srDetector = NULL;
      }
      
      // تنظيف الأنماط المسجلة
      ClearPatterns();
      
      m_initialized = false;
   }
}

//+------------------------------------------------------------------+
//| تحديد أنواع الكشف                                               |
//+------------------------------------------------------------------+
void CChartDetector::SetDetectionTypes(bool reversals, bool continuations, bool harmonic = false, 
                                       bool elliott = false, bool volume = false)
{
   m_settings.detectReversals = reversals;
   m_settings.detectContinuations = continuations;
   m_settings.detectHarmonic = harmonic;
   m_settings.detectElliott = elliott;
   m_settings.detectVolume = volume;
}

//+------------------------------------------------------------------+
//| تسجيل نمط جديد                                                  |
//+------------------------------------------------------------------+
bool CChartDetector::RegisterPattern(CChartPattern *pattern)
{
   if(pattern == NULL)
      return false;
   
   // التحقق من عدم وجود النمط مسبقاً
   for(int i = 0; i < ArraySize(m_patterns); i++)
   {
      if(m_patterns[i] == pattern)
         return false; // النمط موجود مسبقاً
   }
   
   // إضافة النمط
   int size = ArraySize(m_patterns);
   ArrayResize(m_patterns, size + 1);
   m_patterns[size] = pattern;
   
   // تهيئة النمط
   if(!pattern.Initialize(m_symbol, m_timeframe))
   {
      ArrayResize(m_patterns, size); // إلغاء الإضافة
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| إلغاء تسجيل نمط                                                 |
//+------------------------------------------------------------------+
void CChartDetector::UnregisterPattern(const string patternName)
{
   for(int i = ArraySize(m_patterns) - 1; i >= 0; i--)
   {
      if(m_patterns[i] != NULL && m_patterns[i].GetPatternName() == patternName)
      {
         // حذف النمط من المصفوفة
         for(int j = i; j < ArraySize(m_patterns) - 1; j++)
            m_patterns[j] = m_patterns[j + 1];
         
         ArrayResize(m_patterns, ArraySize(m_patterns) - 1);
         break;
      }
   }
}

//+------------------------------------------------------------------+
//| مسح جميع الأنماط                                                |
//+------------------------------------------------------------------+
void CChartDetector::ClearPatterns()
{
   ArrayResize(m_patterns, 0);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع الأنماط                                           |
//+------------------------------------------------------------------+
int CChartDetector::DetectAllPatterns(const int startIdx, const int endIdx,
                                     SChartPatternResult &results[])
{
   if(!m_initialized)
   {
      Print("محرك الكشف غير مهيئ");
      ArrayResize(results, 0);
      return 0;
   }
   
   if(!PrepareData(startIdx, endIdx))
   {
      Print("فشل في تحضير البيانات");
      ArrayResize(results, 0);
      return 0;
   }
   
   // مصفوفة مؤقتة لجمع النتائج
   SChartPatternResult tempResults[];
   ArrayResize(tempResults, 0);
   
   // تحضير بيانات الأسعار
   double open[], high[], low[], close[];
   long volume[];
   datetime time[];
   
   int dataSize = endIdx - startIdx + 1;
   ArrayResize(open, dataSize);
   ArrayResize(high, dataSize);
   ArrayResize(low, dataSize);
   ArrayResize(close, dataSize);
   ArrayResize(volume, dataSize);
   ArrayResize(time, dataSize);
   
   for(int i = 0; i < dataSize; i++)
   {
      int idx = startIdx + i;
      open[i] = iOpen(m_symbol, m_timeframe, idx);
      high[i] = iHigh(m_symbol, m_timeframe, idx);
      low[i] = iLow(m_symbol, m_timeframe, idx);
      close[i] = iClose(m_symbol, m_timeframe, idx);
      volume[i] = iVolume(m_symbol, m_timeframe, idx);
      time[i] = iTime(m_symbol, m_timeframe, idx);
   }
   
   // تشغيل كل نمط مسجل
   for(int patternIdx = 0; patternIdx < ArraySize(m_patterns); patternIdx++)
   {
      CChartPattern *pattern = m_patterns[patternIdx];
      if(pattern == NULL)
         continue;
      
      // فحص نوع النمط إذا كان مفعل
      ENUM_CHART_PATTERN_TYPE patternType = pattern.GetPatternType();
      if(!IsPatternTypeEnabled(patternType))
         continue;
      
      // تشغيل الكشف لهذا النمط
      for(int barIdx = startIdx; barIdx <= endIdx - pattern.GetMinPatternBars(); barIdx++)
      {
         SChartPatternResult result;
         
         if(pattern.DetectPattern(barIdx, m_symbol, m_timeframe, 
                                open, high, low, close, volume, result))
         {
            // التحقق من صحة النتيجة
            if(ValidatePattern(result))
            {
               int size = ArraySize(tempResults);
               ArrayResize(tempResults, size + 1);
               tempResults[size] = result;
            }
         }
      }
   }
   
   // تصفية وتحسين النتائج
   FilterResults(tempResults);
   OptimizeResults(tempResults);
   SortResultsByReliability(tempResults);
   
   // نسخ النتائج النهائية
   int finalCount = MathMin(ArraySize(tempResults), m_settings.maxPatternsPerBar * (endIdx - startIdx + 1));
   ArrayResize(results, finalCount);
   
   for(int i = 0; i < finalCount; i++)
      results[i] = tempResults[i];
   
   // تحديث الإحصائيات
   UpdateStatistics(results);
   
   // حفظ النتائج الأخيرة
   ArrayCopy(m_recentResults, results);
   
   return ArraySize(results);
}

//+------------------------------------------------------------------+
//| الكشف عن أنماط بنوع محدد                                        |
//+------------------------------------------------------------------+
int CChartDetector::DetectPatternsByType(const int startIdx, const int endIdx,
                                        const ENUM_CHART_PATTERN_TYPE patternType,
                                        SChartPatternResult &results[])
{
   // حفظ الإعدادات الحالية
   SChartDetectorSettings oldSettings = m_settings;
   
   // تعطيل جميع الأنواع ما عدا النوع المطلوب
   m_settings.detectReversals = (patternType == CHART_PATTERN_REVERSAL);
   m_settings.detectContinuations = (patternType == CHART_PATTERN_CONTINUATION);
   m_settings.detectHarmonic = (patternType == CHART_PATTERN_HARMONIC);
   m_settings.detectElliott = (patternType == CHART_PATTERN_ELLIOTT);
   m_settings.detectVolume = (patternType == CHART_PATTERN_VOLUME);
   
   // تشغيل الكشف
   int count = DetectAllPatterns(startIdx, endIdx, results);
   
   // استعادة الإعدادات
   m_settings = oldSettings;
   
   return count;
}

//+------------------------------------------------------------------+
//| التحقق من صحة النمط                                             |
//+------------------------------------------------------------------+
bool CChartDetector::ValidatePattern(const SChartPatternResult &result)
{
   // فحص الموثوقية
   if(result.confidence < m_settings.minPatternReliability)
      return false;
   
   // فحص القوة (إذا كانت محسوبة)
   if(result.completionPercentage > 0.0)
   {
      double strength = result.completionPercentage / 100.0;
      if(strength < m_settings.minPatternStrength)
         return false;
   }
   
   // فحص اكتمال النمط
   if(m_settings.useStrictMode && result.status != CHART_PATTERN_COMPLETED)
      return false;
   
   // فحص الفلاتر الإضافية
   if(!PassesFilters(result))
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| تصفية النتائج                                                   |
//+------------------------------------------------------------------+
void CChartDetector::FilterResults(SChartPatternResult &results[])
{
   SChartPatternResult filteredResults[];
   ArrayResize(filteredResults, 0);
   
   for(int i = 0; i < ArraySize(results); i++)
   {
      if(ValidatePattern(results[i]))
      {
         // فحص التكرار
         bool isDuplicate = false;
         for(int j = 0; j < ArraySize(filteredResults); j++)
         {
            if(IsPatternRedundant(results[i], filteredResults))
            {
               isDuplicate = true;
               break;
            }
         }
         
         if(!isDuplicate)
         {
            int size = ArraySize(filteredResults);
            ArrayResize(filteredResults, size + 1);
            filteredResults[size] = results[i];
         }
      }
   }
   
   // نسخ النتائج المصفاة
   ArrayCopy(results, filteredResults);
}

//+------------------------------------------------------------------+
//| ترتيب النتائج حسب الموثوقية                                     |
//+------------------------------------------------------------------+
void CChartDetector::SortResultsByReliability(SChartPatternResult &results[])
{
   int count = ArraySize(results);
   if(count <= 1)
      return;
   
   // ترتيب فقاعي بسيط
   for(int i = 0; i < count - 1; i++)
   {
      for(int j = 0; j < count - i - 1; j++)
      {
         if(results[j].confidence < results[j + 1].confidence)
         {
            // تبديل المواقع
            SChartPatternResult temp = results[j];
            results[j] = results[j + 1];
            results[j + 1] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| حساب معدل النجاح                                                |
//+------------------------------------------------------------------+
double CChartDetector::GetSuccessRate() const
{
   if(m_totalDetections == 0)
      return 0.0;
   
   return (double)m_successfulDetections / m_totalDetections;
}

//+------------------------------------------------------------------+
//| تحضير البيانات                                                  |
//+------------------------------------------------------------------+
bool CChartDetector::PrepareData(const int startIdx, const int endIdx)
{
   if(startIdx >= endIdx)
      return false;
   
   // تحديث مكونات التحليل
   if(m_chartUtils != NULL)
      m_chartUtils.UpdateData(startIdx, endIdx);
   
   if(m_trendDetector != NULL)
      m_trendDetector.UpdateTrendLines(startIdx, endIdx);
   
   if(m_srDetector != NULL)
      m_srDetector.UpdateLevels(startIdx, endIdx);
   
   return true;
}

//+------------------------------------------------------------------+
//| تحديث الإحصائيات                                                |
//+------------------------------------------------------------------+
void CChartDetector::UpdateStatistics(const SChartPatternResult &results[])
{
   int count = ArraySize(results);
   if(count == 0)
      return;
   
   m_totalDetections += count;
   
   double totalReliability = 0.0;
   for(int i = 0; i < count; i++)
   {
      totalReliability += results[i].confidence;
      
      // زيادة عداد النجاح إذا كان النمط موثوق
      if(results[i].confidence >= 0.7)
         m_successfulDetections++;
   }
   
   m_avgReliability = totalReliability / count;
}

//+------------------------------------------------------------------+
//| فحص الفلاتر                                                     |
//+------------------------------------------------------------------+
bool CChartDetector::PassesFilters(const SChartPatternResult &result)
{
   // فلتر الحجم
   if(m_settings.enableVolumeFilter && !result.hasVolConfirmation)
      return false;
   
   // فلتر الاتجاه
   if(m_settings.enableTrendFilter)
   {
      // يمكن إضافة منطق فلتر الاتجاه هنا
      // مثلاً التحقق من توافق النمط مع الاتجاه العام
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص التكرار                                                     |
//+------------------------------------------------------------------+
bool CChartDetector::IsPatternRedundant(const SChartPatternResult &newPattern, 
                                       const SChartPatternResult &existingPatterns[])
{
   for(int i = 0; i < ArraySize(existingPatterns); i++)
   {
      // فحص التداخل الزمني
      if(MathAbs(newPattern.formationStart - existingPatterns[i].formationStart) < 
         PeriodSeconds(m_timeframe) * 5) // تداخل أقل من 5 شموع
      {
         // فحص التشابه في النوع
         if(newPattern.patternType == existingPatterns[i].patternType ||
            newPattern.patternName == existingPatterns[i].patternName)
         {
            return true; // نمط مكرر
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| تحسين النتائج                                                   |
//+------------------------------------------------------------------+
void CChartDetector::OptimizeResults(SChartPatternResult &results[])
{
   // إزالة الأنماط المتداخلة ذات الموثوقية الأقل
   SChartPatternResult optimizedResults[];
   ArrayResize(optimizedResults, 0);
   
   for(int i = 0; i < ArraySize(results); i++)
   {
      bool keepPattern = true;
      
      for(int j = 0; j < ArraySize(results); j++)
      {
         if(i != j)
         {
            // فحص التداخل
            if(MathAbs(results[i].formationStart - results[j].formationStart) < 
               PeriodSeconds(m_timeframe) * 3)
            {
               // إبقاء النمط الأكثر موثوقية
               if(results[i].confidence < results[j].confidence)
               {
                  keepPattern = false;
                  break;
               }
            }
         }
      }
      
      if(keepPattern)
      {
         int size = ArraySize(optimizedResults);
         ArrayResize(optimizedResults, size + 1);
         optimizedResults[size] = results[i];
      }
   }
   
   ArrayCopy(results, optimizedResults);
}

//+------------------------------------------------------------------+
//| فحص تفعيل نوع النمط                                             |
//+------------------------------------------------------------------+
bool CChartDetector::IsPatternTypeEnabled(const ENUM_CHART_PATTERN_TYPE patternType)
{
   switch(patternType)
   {
      case CHART_PATTERN_REVERSAL:
         return m_settings.detectReversals;
      case CHART_PATTERN_CONTINUATION:
         return m_settings.detectContinuations;
      case CHART_PATTERN_HARMONIC:
         return m_settings.detectHarmonic;
      case CHART_PATTERN_ELLIOTT:
         return m_settings.detectElliott;
      case CHART_PATTERN_VOLUME:
         return m_settings.detectVolume;
      default:
         return true;
   }
}
