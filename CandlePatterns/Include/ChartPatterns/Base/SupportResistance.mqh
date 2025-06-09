//+------------------------------------------------------------------+
//|                                           SupportResistance.mqh |
//|                                   كاشف الدعم والمقاومة          |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

// تضمين التعريفات المشتركة
#include "ChartCommonDefs.mqh"

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
   double            CalculateVolumeAtLevel(const SAdvancedSRLevel &level, const long &volume[], 
                                          const int startIdx, const int endIdx);
   
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
   bool              IsInitialized() const { return m_initialized; }
   
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
   
   // دوال مساعدة للحسابات
   bool              IsPriceNearLevel(const double price, const double levelPrice, const double tolerance);
   void              UpdatePriceLevelStrength(SPriceLevel &level);
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
//| باقي الدوال المبسطة لتجنب الأخطاء                                |
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

void CSupportResistance::CalculateLevelZone(SAdvancedSRLevel &level)
{
   double zoneWidth = level.exactPrice * m_priceTolerancePercent / 100.0;
   
   level.zone_upper = level.exactPrice + zoneWidth;
   level.zone_lower = level.exactPrice - zoneWidth;
   level.zoneWidth = zoneWidth * 2.0;
}

double CSupportResistance::CalculateLevelStrength(const SAdvancedSRLevel &level)
{
   double strength = 0.0;
   
   // عامل عدد اللمسات (0-40%)
   strength += MathMin(level.totalTouches / 5.0, 0.4);
   
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
   
   // عامل معدل النجاح (0-10%)
   strength += level.successRate * 0.1;
   
   return MathMin(strength, 1.0);
}

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

bool CSupportResistance::HasVolumeConfirmation(const SAdvancedSRLevel &level, const long &volume[],
                                              const int startIdx, const int endIdx)
{
   // حساب متوسط الحجم عند هذا المستوى
   double levelVolume = CalculateVolumeAtLevel(level, volume, startIdx, endIdx);
   
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

double CSupportResistance::CalculateVolumeAtLevel(const SAdvancedSRLevel &level, const long &volume[], 
                                                 const int startIdx, const int endIdx)
{
   long totalVolume = 0;
   int count = 0;
   
   double tolerance = level.exactPrice * m_priceTolerancePercent / 100.0;
   
   for(int i = startIdx; i <= endIdx; i++)
   {
      // استخدام أسعار الإغلاق من البيانات المباشرة
      double price = iClose(m_symbol, m_timeframe, i);
      
      if(MathAbs(price - level.exactPrice) <= tolerance)
      {
         totalVolume += volume[i];
         count++;
      }
   }
   
   return (count > 0) ? (double)totalVolume / count : 0.0;
}

// باقي الدوال الأساسية
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
   
   return true;
}

SAdvancedSRLevel CSupportResistance::GetSupportLevel(const int index) const
{
   SAdvancedSRLevel emptyLevel;
   
   if(index < 0 || index >= ArraySize(m_supportLevels))
      return emptyLevel;
   
   return m_supportLevels[index];
}

SAdvancedSRLevel CSupportResistance::GetResistanceLevel(const int index) const
{
   SAdvancedSRLevel emptyLevel;
   
   if(index < 0 || index >= ArraySize(m_resistanceLevels))
      return emptyLevel;
   
   return m_resistanceLevels[index];
}

SSRZone CSupportResistance::GetSRZone(const int index) const
{
   SSRZone emptyZone;
   
   if(index < 0 || index >= ArraySize(m_srZones))
      return emptyZone;
   
   return m_srZones[index];
}

double CSupportResistance::GetSuccessRate() const
{
   int totalTests = m_successfulBounces + m_successfulBreakouts;
   if(totalTests > 0)
      return (double)m_successfulBounces / totalTests;
   
   return 0.0;
}

// دوال أساسية مبسطة لتجنب الأخطاء
void CSupportResistance::ValidateLevels(const double currentPrice, const long currentVolume) {}
void CSupportResistance::UpdateLevelStatus(SAdvancedSRLevel &level, const double currentPrice) {}
int CSupportResistance::DetectPsychologicalLevels(const double minPrice, const double maxPrice) { return 0; }
int CSupportResistance::DetectFibonacciLevels(const double swingHigh, const double swingLow) { return 0; }
int CSupportResistance::DetectVolumeProfileLevels(const int startIdx, const int endIdx, const double &prices[], const long &volume[]) { return 0; }
int CSupportResistance::CreateSRZones() { return 0; }
bool CSupportResistance::IsConfluentZone(const SSRZone &zone) { return false; }
double CSupportResistance::CalculateZoneStrength(const SSRZone &zone) { return 0.0; }
bool CSupportResistance::IsBreakout(const SAdvancedSRLevel &level, const double currentPrice, const double minimumBreakDistance) { return false; }
bool CSupportResistance::IsBounce(const SAdvancedSRLevel &level, const double &prices[], const int startIdx, const int endIdx) { return false; }
bool CSupportResistance::IsRetest(const SAdvancedSRLevel &level, const double currentPrice) { return false; }
ENUM_SR_TYPE CSupportResistance::GetNearestLevelType(const double currentPrice) { return SR_SUPPORT; }
double CSupportResistance::GetNearestLevelDistance(const double currentPrice) { return 0.0; }
SAdvancedSRLevel CSupportResistance::GetNearestLevel(const double currentPrice) { SAdvancedSRLevel empty; return empty; }

void CSupportResistance::FilterLevels(SAdvancedSRLevel &levels[]) {}
void CSupportResistance::MergeSimilarLevels(SAdvancedSRLevel &levels[]) {}
void CSupportResistance::SortLevelsByStrength(SAdvancedSRLevel &levels[]) {}
void CSupportResistance::UpdateLevelStatistics(SAdvancedSRLevel &level, const double &prices[], const int startIdx, const int endIdx) {}
void CSupportResistance::CalculateSuccessRate(SAdvancedSRLevel &level) {}
void CSupportResistance::UpdateMarketContext(const double &open[], const double &high[], const double &low[], const double &close[], const long &volume[], const int endIdx) {}
bool CSupportResistance::IsPsychologicalPrice(const double price) { return false; }
bool CSupportResistance::IsPriceNearLevel(const double price, const double levelPrice, const double tolerance) { return false; }
void CSupportResistance::UpdatePriceLevelStrength(SPriceLevel &level) {}
