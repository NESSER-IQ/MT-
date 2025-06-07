//+------------------------------------------------------------------+
//|                                           SupportResistance.mqh |
//|                                   كاشف الدعم والمقاومة          |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "ChartUtils.mqh"

//+------------------------------------------------------------------+
//| تعدادات أنواع مستويات الدعم والمقاومة                          |
//+------------------------------------------------------------------+
enum ENUM_SR_TYPE
{
   SR_SUPPORT,           // دعم
   SR_RESISTANCE,        // مقاومة
   SR_PIVOT,             // محوري
   SR_FIBONACCI,         // فيبوناتشي
   SR_PSYCHOLOGICAL,     // نفسي
   SR_VOLUME_PROFILE,    // ملف الحجم
   SR_PREVIOUS_HIGH,     // قمة سابقة
   SR_PREVIOUS_LOW       // قاع سابق
};

enum ENUM_SR_STRENGTH
{
   SR_WEAK,              // ضعيف
   SR_MODERATE,          // متوسط
   SR_STRONG,            // قوي
   SR_VERY_STRONG        // قوي جداً
};

enum ENUM_SR_STATUS
{
   SR_ACTIVE,            // نشط
   SR_BROKEN,            // مكسور
   SR_RETESTED,          // معاد اختباره
   SR_FLIP,              // انقلب (دعم أصبح مقاومة أو العكس)
   SR_WEAKENING          // يضعف
};

//+------------------------------------------------------------------+
//| هيكل مستوى الدعم/المقاومة المتقدم                              |
//+------------------------------------------------------------------+
struct SAdvancedSRLevel
{
   SPriceLevel       baseLevel;         // المستوى الأساسي
   ENUM_SR_TYPE      type;              // نوع المستوى
   ENUM_SR_STRENGTH  strengthLevel;     // مستوى القوة
   ENUM_SR_STATUS    status;            // حالة المستوى
   
   double            exactPrice;        // السعر الدقيق
   double            zone_upper;        // الحد الأعلى للمنطقة
   double            zone_lower;        // الحد الأدنى للمنطقة
   double            zoneWidth;         // عرض المنطقة
   
   int               totalTouches;      // إجمالي اللمسات
   int               recentTouches;     // اللمسات الأخيرة
   datetime          lastTouchTime;     // وقت آخر لمسة
   datetime          creationTime;      // وقت الإنشاء
   
   bool              hasVolumeConfirm;  // تأكيد الحجم
   double            avgVolumeAtLevel;  // متوسط الحجم عند المستوى
   double            maxVolumeAtLevel;  // أقصى حجم عند المستوى
   
   // تحليل الاختراق
   bool              wasBroken;         // تم كسره
   datetime          breakTime;         // وقت الكسر
   double            breakPrice;        // سعر الكسر
   bool              wasRetested;       // تم إعادة اختباره
   datetime          retestTime;        // وقت إعادة الاختبار
   
   // إحصائيات
   double            successRate;       // معدل النجاح
   int               bounces;           // الارتدادات
   int               breakouts;         // الاختراقات
   double            reliability;       // الموثوقية
   
   SAdvancedSRLevel()
   {
      type = SR_SUPPORT;
      strengthLevel = SR_WEAK;
      status = SR_ACTIVE;
      
      exactPrice = 0.0;
      zone_upper = 0.0;
      zone_lower = 0.0;
      zoneWidth = 0.0;
      
      totalTouches = 0;
      recentTouches = 0;
      lastTouchTime = 0;
      creationTime = 0;
      
      hasVolumeConfirm = false;
      avgVolumeAtLevel = 0.0;
      maxVolumeAtLevel = 0.0;
      
      wasBroken = false;
      breakTime = 0;
      breakPrice = 0.0;
      wasRetested = false;
      retestTime = 0;
      
      successRate = 0.0;
      bounces = 0;
      breakouts = 0;
      reliability = 0.0;
   }
};

//+------------------------------------------------------------------+
//| هيكل منطقة الدعم/المقاومة                                       |
//+------------------------------------------------------------------+
struct SSRZone
{
   double            upperBound;        // الحد الأعلى
   double            lowerBound;        // الحد الأدنى
   double            centerPrice;       // السعر المركزي
   ENUM_SR_TYPE      zoneType;          // نوع المنطقة
   
   int               levelCount;        // عدد المستويات في المنطقة
   SAdvancedSRLevel  levels[];          // المستويات في المنطقة
   
   double            zoneStrength;      // قوة المنطقة
   bool              isConfluentZone;   // منطقة متقاربة
   datetime          formationTime;     // وقت التكوين
   
   SSRZone()
   {
      upperBound = 0.0;
      lowerBound = 0.0;
      centerPrice = 0.0;
      zoneType = SR_SUPPORT;
      levelCount = 0;
      zoneStrength = 0.0;
      isConfluentZone = false;
      formationTime = 0;
      ArrayResize(levels, 0);
   }
};

//+------------------------------------------------------------------+
//| فئة كاشف الدعم والمقاومة                                        |
//+------------------------------------------------------------------+
class CSupportResistance
{
private:
   // إعدادات الكاشف
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   bool              m_initialized;
   
   // معاملات الكشف
   int               m_lookbackPeriod;       // فترة البحث
   double            m_priceTolerancePercent; // نسبة تساهل السعر
   int               m_minTouchesForLevel;   // أقل عدد لمسات للمستوى
   bool              m_useVolumeAnalysis;    // استخدام تحليل الحجم
   bool              m_detectPsychLevels;    // كشف المستويات النفسية
   bool              m_detectFibLevels;      // كشف مستويات فيبوناتشي
   
   // البيانات المحسوبة
   SAdvancedSRLevel  m_supportLevels[];      // مستويات الدعم
   SAdvancedSRLevel  m_resistanceLevels[];   // مستويات المقاومة
   SSRZone          m_srZones[];             // مناطق الدعم والمقاومة
   
   // معلومات السياق
   double            m_currentPrice;         // السعر الحالي
   double            m_dailyRange;           // المدى اليومي
   double            m_averageVolume;        // متوسط الحجم
   
   // إحصائيات الأداء
   int               m_totalLevelsDetected;
   int               m_successfulBounces;
   int               m_successfulBreakouts;
   double            m_overallAccuracy;
   
public:
   // المنشئ والهادم
                     CSupportResistance();
                     ~CSupportResistance();
   
   // تهيئة الكاشف
   bool              Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   void              Deinitialize();
   
   // إعداد المعاملات
   void              SetParameters(const int lookbackPeriod, const double priceTolerancePercent,
                                 const int minTouchesForLevel, const bool useVolumeAnalysis = true,
                                 const bool detectPsychLevels = true, const bool detectFibLevels = false);
   
   // الكشف عن المستويات
   int               DetectAllLevels(const int startIdx, const int endIdx,
                                   const double &open[], const double &high[], 
                                   const double &low[], const double &close[],
                                   const long &volume[]);
   
   int               DetectSupportLevels(const int startIdx, const int endIdx,
                                       const double &low[], const long &volume[]);
   
   int               DetectResistanceLevels(const int startIdx, const int endIdx,
                                          const double &high[], const long &volume[]);
   
   // كشف أنواع المستويات المختلفة
   int               DetectPsychologicalLevels(const double minPrice, const double maxPrice);
   int               DetectFibonacciLevels(const double swingHigh, const double swingLow);
   int               DetectVolumeProfileLevels(const int startIdx, const int endIdx,
                                             const double &prices[], const long &volume[]);
   
   // تحليل المناطق
   int               CreateSRZones();
   bool              IsConfluentZone(const SSRZone &zone);
   double            CalculateZoneStrength(const SSRZone &zone);
   
   // تحديث المستويات
   bool              UpdateLevels(const int startIdx, const int endIdx);
   void              ValidateLevels(const double currentPrice, const long currentVolume);
   void              UpdateLevelStatus(SAdvancedSRLevel &level, const double currentPrice);
   
   // تحليل قوة المستويات
   double            CalculateLevelStrength(const SAdvancedSRLevel &level);
   ENUM_SR_STRENGTH  GetStrengthLevel(const double strength);
   double            CalculateReliability(const SAdvancedSRLevel &level);
   
   // تحليل الاختراقات والارتدادات
   bool              IsBreakout(const SAdvancedSRLevel &level, const double currentPrice, 
                              const double minimumBreakDistance = 0.0);
   bool              IsBounce(const SAdvancedSRLevel &level, const double &prices[], 
                            const int startIdx, const int endIdx);
   bool              IsRetest(const SAdvancedSRLevel &level, const double currentPrice);
   
   // تحليل السياق
   ENUM_SR_TYPE      GetNearestLevelType(const double currentPrice);
   double            GetNearestLevelDistance(const double currentPrice);
   SAdvancedSRLevel  GetNearestLevel(const double currentPrice);
   
   // تحليل الحجم
   bool              HasVolumeConfirmation(const SAdvancedSRLevel &level, const long &volume[],
                                         const int startIdx, const int endIdx);
   double            CalculateVolumeAtLevel(const SAdvancedSRLevel &level, const double &prices[],
                                          const long &volume[], const int startIdx, const int endIdx);
   
   // الوصول للبيانات
   int               GetSupportLevelsCount() const { return ArraySize(m_supportLevels); }
   int               GetResistanceLevelsCount() const { return ArraySize(m_resistanceLevels); }
   int               GetSRZonesCount() const { return ArraySize(m_srZones); }
   
   SAdvancedSRLevel  GetSupportLevel(const int index) const;
   SAdvancedSRLevel  GetResistanceLevel(const int index) const;
   SSRZone          GetSRZone(const int index) const;
   
   // إحصائيات الأداء
   double            GetOverallAccuracy() const { return m_overallAccuracy; }
   int               GetTotalLevelsDetected() const { return m_totalLevelsDetected; }
   double            GetSuccessRate() const;
   
protected:
   // دوال مساعدة
   bool              CreateSRLevel(const double price, const ENUM_SR_TYPE type, 
                                 const datetime creationTime, SAdvancedSRLevel &level);
   
   void              CalculateLevelZone(SAdvancedSRLevel &level);
   bool              IsPsychologicalPrice(const double price);
   
   // تصفية وتحسين
   void              FilterLevels(SAdvancedSRLevel &levels[]);
   void              MergeSimilarLevels(SAdvancedSRLevel &levels[]);
   void              SortLevelsByStrength(SAdvancedSRLevel &levels[]);
   
   // تحليل إحصائي
   void              UpdateLevelStatistics(SAdvancedSRLevel &level, const double &prices[],
                                         const int startIdx, const int endIdx);
   void              CalculateSuccessRate(SAdvancedSRLevel &level);
   
   // تحديث السياق
   void              UpdateMarketContext(const double &open[], const double &high[],
                                       const double &low[], const double &close[],
                                       const long &volume[], const int endIdx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CSupportResistance::CSupportResistance()
{
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_initialized = false;
   
   // المعاملات الافتراضية
   m_lookbackPeriod = 100;
   m_priceTolerancePercent = 0.1;
   m_minTouchesForLevel = 2;
   m_useVolumeAnalysis = true;
   m_detectPsychLevels = true;
   m_detectFibLevels = false;
   
   // تهيئة المصفوفات
   ArrayResize(m_supportLevels, 0);
   ArrayResize(m_resistanceLevels, 0);
   ArrayResize(m_srZones, 0);
   
   // متغيرات السياق
   m_currentPrice = 0.0;
   m_dailyRange = 0.0;
   m_averageVolume = 0.0;
   
   // إحصائيات
   m_totalLevelsDetected = 0;
   m_successfulBounces = 0;
   m_successfulBreakouts = 0;
   m_overallAccuracy = 0.0;
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CSupportResistance::~CSupportResistance()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة الكاشف                                                     |
//+------------------------------------------------------------------+
bool CSupportResistance::Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   m_symbol = (symbol == "") ? Symbol() : symbol;
   m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
   
   // تعديل المعاملات حسب الإطار الزمني
   switch(m_timeframe)
   {
      case PERIOD_M1:
      case PERIOD_M5:
         m_lookbackPeriod = 50;
         m_priceTolerancePercent = 0.2;
         break;
         
      case PERIOD_M15:
      case PERIOD_M30:
         m_lookbackPeriod = 75;
         m_priceTolerancePercent = 0.15;
         break;
         
      case PERIOD_H1:
      case PERIOD_H4:
         m_lookbackPeriod = 100;
         m_priceTolerancePercent = 0.1;
         break;
         
      case PERIOD_D1:
      case PERIOD_W1:
         m_lookbackPeriod = 200;
         m_priceTolerancePercent = 0.08;
         break;
   }
   
   m_initialized = true;
   Print("تم تهيئة كاشف الدعم والمقاومة للرمز: ", m_symbol, " الإطار الزمني: ", EnumToString(m_timeframe));
   
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء الكاشف                                                    |
//+------------------------------------------------------------------+
void CSupportResistance::Deinitialize()
{
   if(m_initialized)
   {
      ArrayFree(m_supportLevels);
      ArrayFree(m_resistanceLevels);
      ArrayFree(m_srZones);
      
      m_initialized = false;
   }
}

//+------------------------------------------------------------------+
//| تحديد المعاملات                                                 |
//+------------------------------------------------------------------+
void CSupportResistance::SetParameters(const int lookbackPeriod, const double priceTolerancePercent,
                                       const int minTouchesForLevel, const bool useVolumeAnalysis = true,
                                       const bool detectPsychLevels = true, const bool detectFibLevels = false)
{
   m_lookbackPeriod = MathMax(10, lookbackPeriod);
   m_priceTolerancePercent = MathMax(0.01, priceTolerancePercent);
   m_minTouchesForLevel = MathMax(1, minTouchesForLevel);
   m_useVolumeAnalysis = useVolumeAnalysis;
   m_detectPsychLevels = detectPsychLevels;
   m_detectFibLevels = detectFibLevels;
}

//+------------------------------------------------------------------+
//| الكشف عن جميع المستويات                                         |
//+------------------------------------------------------------------+
int CSupportResistance::DetectAllLevels(const int startIdx, const int endIdx,
                                       const double &open[], const double &high[], 
                                       const double &low[], const double &close[],
                                       const long &volume[])
{
   if(!m_initialized || startIdx >= endIdx)
      return 0;
   
   // تحديث سياق السوق
   UpdateMarketContext(open, high, low, close, volume, endIdx);
   
   // كشف مستويات الدعم
   int supportCount = DetectSupportLevels(startIdx, endIdx, low, volume);
   
   // كشف مستويات المقاومة
   int resistanceCount = DetectResistanceLevels(startIdx, endIdx, high, volume);
   
   // كشف المستويات النفسية إذا كان مطلوب
   if(m_detectPsychLevels)
   {
      double minPrice = low[iLowest(m_symbol, m_timeframe, MODE_LOW, endIdx - startIdx + 1, startIdx)];
      double maxPrice = high[iHighest(m_symbol, m_timeframe, MODE_HIGH, endIdx - startIdx + 1, startIdx)];
      DetectPsychologicalLevels(minPrice, maxPrice);
   }
   
   // كشف مستويات فيبوناتشي إذا كان مطلوب
   if(m_detectFibLevels)
   {
      double swingHigh = high[iHighest(m_symbol, m_timeframe, MODE_HIGH, endIdx - startIdx + 1, startIdx)];
      double swingLow = low[iLowest(m_symbol, m_timeframe, MODE_LOW, endIdx - startIdx + 1, startIdx)];
      DetectFibonacciLevels(swingHigh, swingLow);
   }
   
   // إنشاء المناطق
   CreateSRZones();
   
   // تصفية وتحسين النتائج
   FilterLevels(m_supportLevels);
   FilterLevels(m_resistanceLevels);
   
   SortLevelsByStrength(m_supportLevels);
   SortLevelsByStrength(m_resistanceLevels);
   
   // تحديث الإحصائيات
   m_totalLevelsDetected = supportCount + resistanceCount;
   
   return m_totalLevelsDetected;
}

//+------------------------------------------------------------------+
//| الكشف عن مستويات الدعم                                          |
//+------------------------------------------------------------------+
int CSupportResistance::DetectSupportLevels(const int startIdx, const int endIdx,
                                           const double &low[], const long &volume[])
{
   ArrayResize(m_supportLevels, 0);
   
   if(startIdx >= endIdx)
      return 0;
   
   // البحث عن القيعان المحلية
   for(int i = startIdx + 2; i <= endIdx - 2; i++)
   {
      // فحص إذا كان قاع محلي
      if(low[i] <= low[i-1] && low[i] <= low[i+1] &&
         low[i] <= low[i-2] && low[i] <= low[i+2])
      {
         // إنشاء مستوى دعم
         SAdvancedSRLevel supportLevel;
         datetime creationTime = iTime(m_symbol, m_timeframe, i);
         
         if(CreateSRLevel(low[i], SR_SUPPORT, creationTime, supportLevel))
         {
            // حساب عدد اللمسات
            int touches = 0;
            for(int j = startIdx; j <= endIdx; j++)
            {
               double tolerance = supportLevel.exactPrice * m_priceTolerancePercent / 100.0;
               if(MathAbs(low[j] - supportLevel.exactPrice) <= tolerance)
                  touches++;
            }
            
            supportLevel.totalTouches = touches;
            supportLevel.baseLevel.touches = touches;
            
            if(touches >= m_minTouchesForLevel)
            {
               // تحليل الحجم
               if(m_useVolumeAnalysis)
                  supportLevel.hasVolumeConfirm = HasVolumeConfirmation(supportLevel, volume, startIdx, endIdx);
               
               // حساب قوة المستوى
               supportLevel.reliability = CalculateReliability(supportLevel);
               supportLevel.strengthLevel = GetStrengthLevel(CalculateLevelStrength(supportLevel));
               
               // حساب منطقة المستوى
               CalculateLevelZone(supportLevel);
               
               // تحديث الإحصائيات
               UpdateLevelStatistics(supportLevel, low, startIdx, endIdx);
               
               int size = ArraySize(m_supportLevels);
               ArrayResize(m_supportLevels, size + 1);
               m_supportLevels[size] = supportLevel;
            }
         }
      }
   }
   
   return ArraySize(m_supportLevels);
}

//+------------------------------------------------------------------+
//| الكشف عن مستويات المقاومة                                       |
//+------------------------------------------------------------------+
int CSupportResistance::DetectResistanceLevels(const int startIdx, const int endIdx,
                                              const double &high[], const long &volume[])
{
   ArrayResize(m_resistanceLevels, 0);
   
   if(startIdx >= endIdx)
      return 0;
   
   // البحث عن القمم المحلية
   for(int i = startIdx + 2; i <= endIdx - 2; i++)
   {
      // فحص إذا كانت قمة محلية
      if(high[i] >= high[i-1] && high[i] >= high[i+1] &&
         high[i] >= high[i-2] && high[i] >= high[i+2])
      {
         // إنشاء مستوى مقاومة
         SAdvancedSRLevel resistanceLevel;
         datetime creationTime = iTime(m_symbol, m_timeframe, i);
         
         if(CreateSRLevel(high[i], SR_RESISTANCE, creationTime, resistanceLevel))
         {
            // حساب عدد اللمسات
            int touches = 0;
            for(int j = startIdx; j <= endIdx; j++)
            {
               double tolerance = resistanceLevel.exactPrice * m_priceTolerancePercent / 100.0;
               if(MathAbs(high[j] - resistanceLevel.exactPrice) <= tolerance)
                  touches++;
            }
            
            resistanceLevel.totalTouches = touches;
            resistanceLevel.baseLevel.touches = touches;
            
            if(touches >= m_minTouchesForLevel)
            {
               // تحليل الحجم
               if(m_useVolumeAnalysis)
                  resistanceLevel.hasVolumeConfirm = HasVolumeConfirmation(resistanceLevel, volume, startIdx, endIdx);
               
               // حساب قوة المستوى
               resistanceLevel.reliability = CalculateReliability(resistanceLevel);
               resistanceLevel.strengthLevel = GetStrengthLevel(CalculateLevelStrength(resistanceLevel));
               
               // حساب منطقة المستوى
               CalculateLevelZone(resistanceLevel);
               
               // تحديث الإحصائيات
               UpdateLevelStatistics(resistanceLevel, high, startIdx, endIdx);
               
               int size = ArraySize(m_resistanceLevels);
               ArrayResize(m_resistanceLevels, size + 1);
               m_resistanceLevels[size] = resistanceLevel;
            }
         }
      }
   }
   
   return ArraySize(m_resistanceLevels);
}

//+------------------------------------------------------------------+
//| الكشف عن المستويات النفسية                                      |
//+------------------------------------------------------------------+
int CSupportResistance::DetectPsychologicalLevels(const double minPrice, const double maxPrice)
{
   int psychLevelsCount = 0;
   
   // تحديد نطاق البحث
   double startPrice = MathFloor(minPrice * 10) / 10; // تقريب للعشر الأقرب
   double endPrice = MathCeil(maxPrice * 10) / 10;
   
   // البحث عن الأرقام المستديرة
   for(double price = startPrice; price <= endPrice; price += 0.1)
   {
      if(IsPsychologicalPrice(price))
      {
         SAdvancedSRLevel psychLevel;
         if(CreateSRLevel(price, (price > m_currentPrice) ? SR_RESISTANCE : SR_SUPPORT, 
                         TimeCurrent(), psychLevel))
         {
            psychLevel.type = SR_PSYCHOLOGICAL;
            psychLevel.strengthLevel = SR_MODERATE; // المستويات النفسية لها قوة متوسطة
            psychLevel.reliability = 0.6; // موثوقية متوسطة
            
            CalculateLevelZone(psychLevel);
            
            // إضافة المستوى للقائمة المناسبة
            if(price > m_currentPrice)
            {
               int size = ArraySize(m_resistanceLevels);
               ArrayResize(m_resistanceLevels, size + 1);
               m_resistanceLevels[size] = psychLevel;
            }
            else
            {
               int size = ArraySize(m_supportLevels);
               ArrayResize(m_supportLevels, size + 1);
               m_supportLevels[size] = psychLevel;
            }
            
            psychLevelsCount++;
         }
      }
   }
   
   return psychLevelsCount;
}

//+------------------------------------------------------------------+
//| الكشف عن مستويات فيبوناتشي                                      |
//+------------------------------------------------------------------+
int CSupportResistance::DetectFibonacciLevels(const double swingHigh, const double swingLow)
{
   int fibLevelsCount = 0;
   
   // نسب فيبوناتشي الرئيسية
   double fibRatios[] = {0.236, 0.382, 0.5, 0.618, 0.786};
   
   for(int i = 0; i < ArraySize(fibRatios); i++)
   {
      double fibPrice = swingLow + ((swingHigh - swingLow) * fibRatios[i]);
      
      SAdvancedSRLevel fibLevel;
      if(CreateSRLevel(fibPrice, (fibPrice > m_currentPrice) ? SR_RESISTANCE : SR_SUPPORT,
                      TimeCurrent(), fibLevel))
      {
         fibLevel.type = SR_FIBONACCI;
         fibLevel.strengthLevel = SR_STRONG; // مستويات فيبوناتشي قوية
         fibLevel.reliability = 0.75; // موثوقية عالية
         
         CalculateLevelZone(fibLevel);
         
         // إضافة المستوى للقائمة المناسبة
         if(fibPrice > m_currentPrice)
         {
            int size = ArraySize(m_resistanceLevels);
            ArrayResize(m_resistanceLevels, size + 1);
            m_resistanceLevels[size] = fibLevel;
         }
         else
         {
            int size = ArraySize(m_supportLevels);
            ArrayResize(m_supportLevels, size + 1);
            m_supportLevels[size] = fibLevel;
         }
         
         fibLevelsCount++;
      }
   }
   
   return fibLevelsCount;
}

//+------------------------------------------------------------------+
//| إنشاء مناطق الدعم والمقاومة                                     |
//+------------------------------------------------------------------+
int CSupportResistance::CreateSRZones()
{
   ArrayResize(m_srZones, 0);
   
   // دمج جميع المستويات
   SAdvancedSRLevel allLevels[];
   int totalLevels = ArraySize(m_supportLevels) + ArraySize(m_resistanceLevels);
   ArrayResize(allLevels, totalLevels);
   
   // نسخ مستويات الدعم
   for(int i = 0; i < ArraySize(m_supportLevels); i++)
      allLevels[i] = m_supportLevels[i];
   
   // نسخ مستويات المقاومة
   for(int i = 0; i < ArraySize(m_resistanceLevels); i++)
      allLevels[ArraySize(m_supportLevels) + i] = m_resistanceLevels[i];
   
   // تجميع المستويات المتقاربة في مناطق
   bool processed[];
   ArrayResize(processed, totalLevels);
   ArrayInitialize(processed, false);
   
   for(int i = 0; i < totalLevels; i++)
   {
      if(processed[i])
         continue;
      
      SSRZone zone;
      zone.centerPrice = allLevels[i].exactPrice;
      zone.zoneType = allLevels[i].type;
      zone.formationTime = allLevels[i].creationTime;
      
      // البحث عن المستويات المتقاربة
      ArrayResize(zone.levels, 1);
      zone.levels[0] = allLevels[i];
      zone.levelCount = 1;
      processed[i] = true;
      
      double zoneRange = allLevels[i].exactPrice * 0.005; // 0.5% كنطاق للمنطقة
      
      for(int j = i + 1; j < totalLevels; j++)
      {
         if(!processed[j] && MathAbs(allLevels[j].exactPrice - zone.centerPrice) <= zoneRange)
         {
            ArrayResize(zone.levels, zone.levelCount + 1);
            zone.levels[zone.levelCount] = allLevels[j];
            zone.levelCount++;
            processed[j] = true;
         }
      }
      
      // حساب حدود المنطقة
      if(zone.levelCount > 1)
      {
         double minPrice = zone.levels[0].exactPrice;
         double maxPrice = zone.levels[0].exactPrice;
         
         for(int k = 1; k < zone.levelCount; k++)
         {
            if(zone.levels[k].exactPrice < minPrice)
               minPrice = zone.levels[k].exactPrice;
            if(zone.levels[k].exactPrice > maxPrice)
               maxPrice = zone.levels[k].exactPrice;
         }
         
         zone.lowerBound = minPrice;
         zone.upperBound = maxPrice;
         zone.centerPrice = (minPrice + maxPrice) / 2.0;
         zone.isConfluentZone = IsConfluentZone(zone);
         zone.zoneStrength = CalculateZoneStrength(zone);
         
         int size = ArraySize(m_srZones);
         ArrayResize(m_srZones, size + 1);
         m_srZones[size] = zone;
      }
   }
   
   return ArraySize(m_srZones);
}

//+------------------------------------------------------------------+
//| تحديث المستويات                                                 |
//+------------------------------------------------------------------+
bool CSupportResistance::UpdateLevels(const int startIdx, const int endIdx)
{
   if(!m_initialized)
      return false;
   
   // تحضير البيانات
   int dataSize = endIdx - startIdx + 1;
   double open[], high[], low[], close[];
   long volume[];
   
   ArrayResize(open, dataSize);
   ArrayResize(high, dataSize);
   ArrayResize(low, dataSize);
   ArrayResize(close, dataSize);
   ArrayResize(volume, dataSize);
   
   for(int i = 0; i < dataSize; i++)
   {
      int idx = startIdx + i;
      open[i] = iOpen(m_symbol, m_timeframe, idx);
      high[i] = iHigh(m_symbol, m_timeframe, idx);
      low[i] = iLow(m_symbol, m_timeframe, idx);
      close[i] = iClose(m_symbol, m_timeframe, idx);
      volume[i] = iVolume(m_symbol, m_timeframe, idx);
   }
   
   // إعادة كشف المستويات
   DetectAllLevels(0, dataSize - 1, open, high, low, close, volume);
   
   // التحقق من صحة المستويات الحالية
   m_currentPrice = close[dataSize - 1];
   ValidateLevels(m_currentPrice, volume[dataSize - 1]);
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من صحة المستويات                                         |
//+------------------------------------------------------------------+
void CSupportResistance::ValidateLevels(const double currentPrice, const long currentVolume)
{
   // تحديث حالة مستويات الدعم
   for(int i = 0; i < ArraySize(m_supportLevels); i++)
      UpdateLevelStatus(m_supportLevels[i], currentPrice);
   
   // تحديث حالة مستويات المقاومة
   for(int i = 0; i < ArraySize(m_resistanceLevels); i++)
      UpdateLevelStatus(m_resistanceLevels[i], currentPrice);
}

//+------------------------------------------------------------------+
//| تحديث حالة المستوى                                              |
//+------------------------------------------------------------------+
void CSupportResistance::UpdateLevelStatus(SAdvancedSRLevel &level, const double currentPrice)
{
   // فحص الاختراق
   if(IsBreakout(level, currentPrice))
   {
      if(!level.wasBroken)
      {
         level.wasBroken = true;
         level.breakTime = TimeCurrent();
         level.breakPrice = currentPrice;
         level.status = SR_BROKEN;
         level.breakouts++;
      }
   }
   // فحص إعادة الاختبار
   else if(level.wasBroken && IsRetest(level, currentPrice))
   {
      if(!level.wasRetested)
      {
         level.wasRetested = true;
         level.retestTime = TimeCurrent();
         level.status = SR_RETESTED;
      }
   }
   // فحص الارتداد
   else if(!level.wasBroken && IsRetest(level, currentPrice))
   {
      level.bounces++;
      level.lastTouchTime = TimeCurrent();
      level.status = SR_ACTIVE;
   }
   
   // تحديث معدل النجاح
   CalculateSuccessRate(level);
}

//+------------------------------------------------------------------+
//| حساب قوة المستوى                                                |
//+------------------------------------------------------------------+
double CSupportResistance::CalculateLevelStrength(const SAdvancedSRLevel &level)
{
   double strength = 0.0;
   
   // عامل عدد اللمسات (0-30%)
   strength += MathMin(level.totalTouches / 5.0, 0.3);
   
   // عامل العمر (0-20%)
   long currentTime = TimeCurrent();
   long ageSeconds = currentTime - level.creationTime;
   double ageDays = ageSeconds / 86400.0;
   strength += MathMin(ageDays / 30.0, 0.2);
   
   // عامل تأكيد الحجم (0-15%)
   if(level.hasVolumeConfirm)
      strength += 0.15;
   
   // عامل النوع (0-15%)
   switch(level.type)
   {
      case SR_FIBONACCI:
         strength += 0.15;
         break;
      case SR_PSYCHOLOGICAL:
         strength += 0.1;
         break;
      case SR_PIVOT:
         strength += 0.12;
         break;
      default:
         strength += 0.08;
         break;
   }
   
   // عامل معدل النجاح (0-20%)
   strength += level.successRate * 0.2;
   
   return MathMin(strength, 1.0);
}

//+------------------------------------------------------------------+
//| تحديد مستوى القوة                                               |
//+------------------------------------------------------------------+
ENUM_SR_STRENGTH CSupportResistance::GetStrengthLevel(const double strength)
{
   if(strength >= 0.8)
      return SR_VERY_STRONG;
   else if(strength >= 0.6)
      return SR_STRONG;
   else if(strength >= 0.4)
      return SR_MODERATE;
   else
      return SR_WEAK;
}

//+------------------------------------------------------------------+
//| حساب الموثوقية                                                  |
//+------------------------------------------------------------------+
double CSupportResistance::CalculateReliability(const SAdvancedSRLevel &level)
{
   double reliability = 0.5; // قيمة أساسية
   
   // تعديل بناءً على عدد اللمسات
   reliability += MathMin(level.totalTouches * 0.1, 0.3);
   
   // تعديل بناءً على النوع
   switch(level.type)
   {
      case SR_FIBONACCI:
         reliability += 0.15;
         break;
      case SR_PIVOT:
         reliability += 0.1;
         break;
      case SR_PSYCHOLOGICAL:
         reliability += 0.05;
         break;
   }
   
   // تعديل بناءً على تأكيد الحجم
   if(level.hasVolumeConfirm)
      reliability += 0.1;
   
   return MathMin(reliability, 0.95);
}

//+------------------------------------------------------------------+
//| فحص الاختراق                                                    |
//+------------------------------------------------------------------+
bool CSupportResistance::IsBreakout(const SAdvancedSRLevel &level, const double currentPrice, 
                                   const double minimumBreakDistance = 0.0)
{
   double breakDistance = level.exactPrice * 0.002; // 0.2% كحد أدنى للاختراق
   if(minimumBreakDistance > 0.0)
      breakDistance = MathMax(breakDistance, minimumBreakDistance);
   
   if(level.type == SR_SUPPORT && currentPrice < level.exactPrice - breakDistance)
      return true;
   
   if(level.type == SR_RESISTANCE && currentPrice > level.exactPrice + breakDistance)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| فحص إعادة الاختبار                                              |
//+------------------------------------------------------------------+
bool CSupportResistance::IsRetest(const SAdvancedSRLevel &level, const double currentPrice)
{
   double tolerance = level.exactPrice * m_priceTolerancePercent / 100.0;
   return (MathAbs(currentPrice - level.exactPrice) <= tolerance);
}

//+------------------------------------------------------------------+
//| الحصول على أقرب مستوى                                          |
//+------------------------------------------------------------------+
SAdvancedSRLevel CSupportResistance::GetNearestLevel(const double currentPrice)
{
   SAdvancedSRLevel nearestLevel;
   double minDistance = DBL_MAX;
   
   // فحص مستويات الدعم
   for(int i = 0; i < ArraySize(m_supportLevels); i++)
   {
      double distance = MathAbs(currentPrice - m_supportLevels[i].exactPrice);
      if(distance < minDistance)
      {
         minDistance = distance;
         nearestLevel = m_supportLevels[i];
      }
   }
   
   // فحص مستويات المقاومة
   for(int i = 0; i < ArraySize(m_resistanceLevels); i++)
   {
      double distance = MathAbs(currentPrice - m_resistanceLevels[i].exactPrice);
      if(distance < minDistance)
      {
         minDistance = distance;
         nearestLevel = m_resistanceLevels[i];
      }
   }
   
   return nearestLevel;
}

//+------------------------------------------------------------------+
//| فحص تأكيد الحجم                                                  |
//+------------------------------------------------------------------+
bool CSupportResistance::HasVolumeConfirmation(const SAdvancedSRLevel &level, const long &volume[],
                                              const int startIdx, const int endIdx)
{
   // حساب متوسط الحجم عند هذا المستوى
   double levelVolume = CalculateVolumeAtLevel(level, NULL, volume, startIdx, endIdx);
   
   // حساب متوسط الحجم العام
   long totalVolume = 0;
   int count = 0;
   for(int i = startIdx; i <= endIdx; i++)
   {
      totalVolume += volume[i];
      count++;
   }
   
   double avgVolume = (count > 0) ? (double)totalVolume / count : 0.0;
   
   // تأكيد الحجم إذا كان أعلى من المتوسط بنسبة 50%
   return (levelVolume > avgVolume * 1.5);
}

//+------------------------------------------------------------------+
//| حساب الحجم عند المستوى                                          |
//+------------------------------------------------------------------+
double CSupportResistance::CalculateVolumeAtLevel(const SAdvancedSRLevel &level, const double &prices[],
                                                 const long &volume[], const int startIdx, const int endIdx)
{
   long totalVolume = 0;
   int count = 0;
   
   double tolerance = level.exactPrice * m_priceTolerancePercent / 100.0;
   
   for(int i = startIdx; i <= endIdx; i++)
   {
      // إذا لم يتم توفير أسعار، استخدم أسعار الإغلاق
      double price = (prices != NULL) ? prices[i] : iClose(m_symbol, m_timeframe, i);
      
      if(MathAbs(price - level.exactPrice) <= tolerance)
      {
         totalVolume += volume[i];
         count++;
      }
   }
   
   return (count > 0) ? (double)totalVolume / count : 0.0;
}

//+------------------------------------------------------------------+
//| إنشاء مستوى دعم/مقاومة                                          |
//+------------------------------------------------------------------+
bool CSupportResistance::CreateSRLevel(const double price, const ENUM_SR_TYPE type, 
                                      const datetime creationTime, SAdvancedSRLevel &level)
{
   if(price <= 0.0)
      return false;
   
   level.exactPrice = price;
   level.type = type;
   level.creationTime = creationTime;
   level.status = SR_ACTIVE;
   level.baseLevel.price = price;
   level.baseLevel.firstTouch = creationTime;
   level.baseLevel.lastTouch = creationTime;
   level.baseLevel.isSupport = (type == SR_SUPPORT);
   level.baseLevel.isResistance = (type == SR_RESISTANCE);
   
   return true;
}

//+------------------------------------------------------------------+
//| حساب منطقة المستوى                                              |
//+------------------------------------------------------------------+
void CSupportResistance::CalculateLevelZone(SAdvancedSRLevel &level)
{
   double zoneWidth = level.exactPrice * m_priceTolerancePercent / 100.0;
   
   level.zone_upper = level.exactPrice + zoneWidth;
   level.zone_lower = level.exactPrice - zoneWidth;
   level.zoneWidth = zoneWidth * 2.0;
}

//+------------------------------------------------------------------+
//| فحص إذا كان سعر نفسي                                            |
//+------------------------------------------------------------------+
bool CSupportResistance::IsPsychologicalPrice(const double price)
{
   // فحص الأرقام المستديرة (مضاعفات 10، 50، 100)
   int priceInt = (int)MathRound(price * 10000); // تحويل إلى نقاط
   
   if(priceInt % 1000 == 0) // مضاعفات 100 نقطة
      return true;
   if(priceInt % 500 == 0)  // مضاعفات 50 نقطة
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| تصفية المستويات                                                 |
//+------------------------------------------------------------------+
void CSupportResistance::FilterLevels(SAdvancedSRLevel &levels[])
{
   SAdvancedSRLevel filteredLevels[];
   ArrayResize(filteredLevels, 0);
   
   for(int i = 0; i < ArraySize(levels); i++)
   {
      // فحص الحد الأدنى للمسات
      if(levels[i].totalTouches >= m_minTouchesForLevel)
      {
         // فحص الموثوقية
         if(levels[i].reliability >= 0.3)
         {
            int size = ArraySize(filteredLevels);
            ArrayResize(filteredLevels, size + 1);
            filteredLevels[size] = levels[i];
         }
      }
   }
   
   ArrayCopy(levels, filteredLevels);
}

//+------------------------------------------------------------------+
//| دمج المستويات المتشابهة                                         |
//+------------------------------------------------------------------+
void CSupportResistance::MergeSimilarLevels(SAdvancedSRLevel &levels[])
{
   for(int i = ArraySize(levels) - 1; i >= 0; i--)
   {
      for(int j = i - 1; j >= 0; j--)
      {
         double priceDiff = MathAbs(levels[i].exactPrice - levels[j].exactPrice);
         double tolerance = levels[i].exactPrice * 0.001; // 0.1%
         
         if(priceDiff <= tolerance && levels[i].type == levels[j].type)
         {
            // دمج المستويات (الاحتفاظ بالأقوى)
            if(levels[i].reliability < levels[j].reliability)
            {
               // حذف المستوى الأضعف
               for(int k = i; k < ArraySize(levels) - 1; k++)
                  levels[k] = levels[k + 1];
               ArrayResize(levels, ArraySize(levels) - 1);
               break;
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| ترتيب المستويات حسب القوة                                       |
//+------------------------------------------------------------------+
void CSupportResistance::SortLevelsByStrength(SAdvancedSRLevel &levels[])
{
   int count = ArraySize(levels);
   if(count <= 1)
      return;
   
   for(int i = 0; i < count - 1; i++)
   {
      for(int j = 0; j < count - i - 1; j++)
      {
         if(levels[j].reliability < levels[j + 1].reliability)
         {
            SAdvancedSRLevel temp = levels[j];
            levels[j] = levels[j + 1];
            levels[j + 1] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| تحديث إحصائيات المستوى                                          |
//+------------------------------------------------------------------+
void CSupportResistance::UpdateLevelStatistics(SAdvancedSRLevel &level, const double &prices[],
                                              const int startIdx, const int endIdx)
{
   // حساب الارتدادات والاختراقات
   int bounces = 0;
   int breakouts = 0;
   
   for(int i = startIdx + 1; i <= endIdx; i++)
   {
      if(IsRetest(level, prices[i]))
      {
         // فحص الشمعة التالية للتحديد
         if(i < endIdx)
         {
            if(level.type == SR_SUPPORT)
            {
               if(prices[i+1] > level.exactPrice)
                  bounces++;
               else if(prices[i+1] < level.exactPrice - level.exactPrice * 0.002)
                  breakouts++;
            }
            else if(level.type == SR_RESISTANCE)
            {
               if(prices[i+1] < level.exactPrice)
                  bounces++;
               else if(prices[i+1] > level.exactPrice + level.exactPrice * 0.002)
                  breakouts++;
            }
         }
      }
   }
   
   level.bounces = bounces;
   level.breakouts = breakouts;
   
   CalculateSuccessRate(level);
}

//+------------------------------------------------------------------+
//| حساب معدل النجاح                                                |
//+------------------------------------------------------------------+
void CSupportResistance::CalculateSuccessRate(SAdvancedSRLevel &level)
{
   int totalTests = level.bounces + level.breakouts;
   if(totalTests > 0)
   {
      level.successRate = (double)level.bounces / totalTests;
   }
   else
   {
      level.successRate = 0.5; // قيمة افتراضية
   }
}

//+------------------------------------------------------------------+
//| تحديث سياق السوق                                                |
//+------------------------------------------------------------------+
void CSupportResistance::UpdateMarketContext(const double &open[], const double &high[],
                                            const double &low[], const double &close[],
                                            const long &volume[], const int endIdx)
{
   if(endIdx < 0)
      return;
   
   m_currentPrice = close[endIdx];
   
   // حساب المدى اليومي
   m_dailyRange = high[endIdx] - low[endIdx];
   
   // حساب متوسط الحجم
   long totalVolume = 0;
   int count = MathMin(20, endIdx + 1);
   
   for(int i = endIdx - count + 1; i <= endIdx; i++)
   {
      if(i >= 0)
         totalVolume += volume[i];
   }
   
   m_averageVolume = (count > 0) ? (double)totalVolume / count : 0.0;
}

//+------------------------------------------------------------------+
//| فحص إذا كانت منطقة متقاربة                                      |
//+------------------------------------------------------------------+
bool CSupportResistance::IsConfluentZone(const SSRZone &zone)
{
   // منطقة متقاربة إذا احتوت على أكثر من نوع واحد من المستويات
   bool hasSupport = false;
   bool hasResistance = false;
   bool hasFib = false;
   bool hasPsych = false;
   
   for(int i = 0; i < zone.levelCount; i++)
   {
      switch(zone.levels[i].type)
      {
         case SR_SUPPORT:
            hasSupport = true;
            break;
         case SR_RESISTANCE:
            hasResistance = true;
            break;
         case SR_FIBONACCI:
            hasFib = true;
            break;
         case SR_PSYCHOLOGICAL:
            hasPsych = true;
            break;
      }
   }
   
   int typeCount = 0;
   if(hasSupport) typeCount++;
   if(hasResistance) typeCount++;
   if(hasFib) typeCount++;
   if(hasPsych) typeCount++;
   
   return (typeCount >= 2 || zone.levelCount >= 3);
}

//+------------------------------------------------------------------+
//| حساب قوة المنطقة                                                |
//+------------------------------------------------------------------+
double CSupportResistance::CalculateZoneStrength(const SSRZone &zone)
{
   double strength = 0.0;
   
   // قوة أساسية من عدد المستويات
   strength += MathMin(zone.levelCount / 5.0, 0.4);
   
   // قوة من متوسط موثوقية المستويات
   double totalReliability = 0.0;
   for(int i = 0; i < zone.levelCount; i++)
      totalReliability += zone.levels[i].reliability;
   
   if(zone.levelCount > 0)
      strength += (totalReliability / zone.levelCount) * 0.3;
   
   // مكافأة للمناطق المتقاربة
   if(zone.isConfluentZone)
      strength += 0.2;
   
   // قوة من العمر
   long ageSeconds = TimeCurrent() - zone.formationTime;
   double ageDays = ageSeconds / 86400.0;
   strength += MathMin(ageDays / 30.0, 0.1);
   
   return MathMin(strength, 1.0);
}

//+------------------------------------------------------------------+
//| الحصول على معدل النجاح                                          |
//+------------------------------------------------------------------+
double CSupportResistance::GetSuccessRate() const
{
   int totalTests = m_successfulBounces + m_successfulBreakouts;
   if(totalTests > 0)
      return (double)m_successfulBounces / totalTests;
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| الحصول على مستوى دعم                                           |
//+------------------------------------------------------------------+
SAdvancedSRLevel CSupportResistance::GetSupportLevel(const int index) const
{
   SAdvancedSRLevel emptyLevel;
   
   if(index < 0 || index >= ArraySize(m_supportLevels))
      return emptyLevel;
   
   return m_supportLevels[index];
}

//+------------------------------------------------------------------+
//| الحصول على مستوى مقاومة                                        |
//+------------------------------------------------------------------+
SAdvancedSRLevel CSupportResistance::GetResistanceLevel(const int index) const
{
   SAdvancedSRLevel emptyLevel;
   
   if(index < 0 || index >= ArraySize(m_resistanceLevels))
      return emptyLevel;
   
   return m_resistanceLevels[index];
}

//+------------------------------------------------------------------+
//| الحصول على منطقة دعم/مقاومة                                     |
//+------------------------------------------------------------------+
SSRZone CSupportResistance::GetSRZone(const int index) const
{
   SSRZone emptyZone;
   
   if(index < 0 || index >= ArraySize(m_srZones))
      return emptyZone;
   
   return m_srZones[index];
}
