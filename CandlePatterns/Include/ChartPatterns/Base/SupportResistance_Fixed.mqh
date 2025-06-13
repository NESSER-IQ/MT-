//+------------------------------------------------------------------+
//| SupportResistance.mqh - Fixed Version |
//| حقوق النشر 2025, مكتبة أنماط المخططات |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط المخططات"
#property link "https://www.yourwebsite.com"
#property version "1.00"
#property strict

#include "ChartPattern.mqh"
#include "TrendLineDetector.mqh"
#include "../../CandlePatterns/Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| تعدادات الدعم والمقاومة |
//+------------------------------------------------------------------+
enum ENUM_SR_TYPE
{
   SR_SUPPORT,          // دعم
   SR_RESISTANCE,       // مقاومة
   SR_PIVOT_POINT,      // نقطة ارتكاز
   SR_FIBONACCI,        // فيبوناتشي
   SR_PSYCHOLOGICAL,    // نفسي
   SR_VOLUME_PROFILE    // ملف حجم التداول
};

enum ENUM_SR_STRENGTH
{
   SR_WEAK,             // ضعيف
   SR_MODERATE,         // متوسط
   SR_STRONG,           // قوي
   SR_VERY_STRONG       // قوي جداً
};

enum ENUM_SR_STATUS
{
   SR_ACTIVE,           // نشط
   SR_BROKEN,           // مكسور
   SR_RETESTED,         // معاد اختباره
   SR_CONFIRMED,        // مؤكد
   SR_WEAKENING         // يضعف
};

enum ENUM_SR_TIMEFRAME_IMPORTANCE
{
   SR_MINOR,            // ثانوي
   SR_INTERMEDIATE,     // متوسط
   SR_MAJOR,            // رئيسي
   SR_CRITICAL          // حرج
};

//+------------------------------------------------------------------+
//| هيكل مستوى الدعم/المقاومة |
//+------------------------------------------------------------------+
struct SSupportResistanceLevel
{
   // معلومات المستوى
   long                           id;              // معرف المستوى
   string                         name;            // اسم المستوى
   ENUM_SR_TYPE                   type;            // نوع المستوى
   ENUM_SR_STRENGTH              strength;         // قوة المستوى
   ENUM_SR_STATUS                status;           // حالة المستوى
   ENUM_SR_TIMEFRAME_IMPORTANCE  importance;       // أهمية المستوى
   
   // معلومات السعر
   double                         price;           // سعر المستوى
   double                         tolerance;       // نطاق التسامح
   double                         upperBound;      // الحد الأعلى
   double                         lowerBound;      // الحد الأسفل
   
   // نقاط التفاعل
   SChartPoint                    touchPoints[];   // نقاط اللمس
   SChartPoint                    breakPoints[];   // نقاط الكسر
   SChartPoint                    retestPoints[];  // نقاط إعادة الاختبار
   
   // إحصائيات
   int                            touchCount;      // عدد مرات اللمس
   int                            breakCount;      // عدد مرات الكسر
   int                            retestCount;     // عدد مرات إعادة الاختبار
   int                            rejectionCount;  // عدد مرات الرفض
   
   // معلومات زمنية
   datetime                       firstTouch;     // أول لمسة
   datetime                       lastTouch;      // آخر لمسة
   datetime                       creationTime;   // وقت الإنشاء
   int                            ageInBars;      // العمر بالشموع
   
   // معلومات الحجم
   double                         averageVolume;  // متوسط الحجم عند المستوى
   double                         maxVolume;      // أقصى حجم مسجل
   bool                           hasVolumeSpike; // يحتوي على قفزة في الحجم
   
   // قوة وموثوقية
   double                         reliabilityScore; // نقاط الموثوقية
   double                         successRate;      // معدل النجاح
   
   SSupportResistanceLevel()
   {
      id = 0;
      name = "";
      type = SR_SUPPORT;
      strength = SR_WEAK;
      status = SR_ACTIVE;
      importance = SR_MINOR;
      
      price = 0.0;
      tolerance = 0.0;
      upperBound = 0.0;
      lowerBound = 0.0;
      
      touchCount = 0;
      breakCount = 0;
      retestCount = 0;
      rejectionCount = 0;
      
      firstTouch = 0;
      lastTouch = 0;
      creationTime = 0;
      ageInBars = 0;
      
      averageVolume = 0.0;
      maxVolume = 0.0;
      hasVolumeSpike = false;
      
      reliabilityScore = 0.0;
      successRate = 0.0;
      
      ArrayResize(touchPoints, 0);
      ArrayResize(breakPoints, 0);
      ArrayResize(retestPoints, 0);
   }
};

//+------------------------------------------------------------------+
//| فئة كاشف الدعم والمقاومة |
//+------------------------------------------------------------------+
class CSupportResistanceDetector
{
private:
   // مستويات الدعم والمقاومة
   SSupportResistanceLevel       m_levels[];         // مصفوفة المستويات
   int                           m_levelCount;       // عدد المستويات
   
   // أدوات التحليل
   CTrendLineDetector*           m_trendDetector;    // كاشف خطوط الاتجاه
   CTrendDetector*               m_trendAnalyzer;    // محلل الاتجاه
   
   // إعدادات الكشف
   int                           m_lookbackPeriod;   // فترة البحث للخلف
   int                           m_minTouchPoints;   // الحد الأدنى لنقاط اللمس
   double                        m_tolerancePercent; // نسبة التسامح
   double                        m_minLevelStrength; // الحد الأدنى لقوة المستوى
   bool                          m_useVolumeAnalysis; // استخدام تحليل الحجم
   
   // إعدادات فيبوناتشي
   double                        m_fibLevels[9];     // مستويات فيبوناتشي
   bool                          m_autoFibDetection; // كشف تلقائي لفيبوناتشي
   
   // إعدادات المستويات النفسية
   bool                          m_detectPsychological; // كشف المستويات النفسية
   int                           m_roundNumberDigits;    // عدد أرقام الأعداد الصحيحة

public:
   CSupportResistanceDetector();
   ~CSupportResistanceDetector();
   
   // الكشف عن مستويات الدعم والمقاومة
   int DetectSupportResistanceLevels(const string symbol, ENUM_TIMEFRAMES timeframe,
                                   const double &high[], const double &low[], 
                                   const double &close[], const double &volume[],
                                   const datetime &time[], int rates_total);
   
   int DetectSupportLevels(const double &high[], const double &low[], 
                          const double &close[], const datetime &time[],
                          int rates_total);
   
   int DetectResistanceLevels(const double &high[], const double &low[], 
                             const double &close[], const datetime &time[],
                             int rates_total);
   
   int DetectPivotPoints(const double &high[], const double &low[], 
                        const double &close[], const datetime &time[],
                        int rates_total);
   
   int DetectFibonacciLevels(const double &high[], const double &low[], 
                            const datetime &time[], int rates_total);
   
   int DetectPsychologicalLevels(const double &high[], const double &low[], 
                                const double &close[], int rates_total);
   
   int DetectVolumeProfileLevels(const double &high[], const double &low[], 
                                const double &close[], const double &volume[],
                                const datetime &time[], int rates_total);
   
   // التحقق من كسر/اختبار المستويات
   bool CheckLevelBreakout(const SSupportResistanceLevel &level,
                          const double &high[], const double &low[], 
                          const double &close[], int currentBar,
                          double &breakoutPrice);
   
   bool CheckLevelRetest(const SSupportResistanceLevel &level,
                        const double &high[], const double &low[], 
                        const double &close[], int currentBar);
   
   // حساب قوة المستوى
   ENUM_SR_STRENGTH CalculateLevelStrength(const SSupportResistanceLevel &level);
   double CalculateReliabilityScore(const SSupportResistanceLevel &level);
   
   // الوصول للمستويات
   int GetLevelCount() const { return m_levelCount; }
   SSupportResistanceLevel GetLevel(int index) const;
   int GetActiveLevels(ENUM_SR_TYPE type, SSupportResistanceLevel &activeLevels[]);
   int GetLevelsNearPrice(double price, double range, SSupportResistanceLevel &nearLevels[]);
   
   // تحديث المستويات
   void UpdateLevels(const double &high[], const double &low[], 
                    const double &close[], const double &volume[],
                    const datetime &time[], int currentBar);
   
   void UpdateLevelStatistics(SSupportResistanceLevel &level,
                             const double &high[], const double &low[], 
                             const double &close[], const double &volume[],
                             int currentBar);
   
   // رسم المستويات
   void DrawLevel(const string symbol, const SSupportResistanceLevel &level,
                 color levelColor = clrBlue, int lineWidth = 1,
                 ENUM_LINE_STYLE lineStyle = STYLE_SOLID);
   
   void DrawAllLevels(const string symbol);
   void DrawLevelsByType(const string symbol, ENUM_SR_TYPE type);
   
   // إعدادات الكاشف
   void SetLookbackPeriod(int period) { m_lookbackPeriod = MathMax(50, period); }
   void SetMinTouchPoints(int points) { m_minTouchPoints = MathMax(2, points); }
   void SetTolerancePercent(double percent) { m_tolerancePercent = MathMax(0.001, percent); }
   void SetUseVolumeAnalysis(bool use) { m_useVolumeAnalysis = use; }
   void SetDetectPsychological(bool detect) { m_detectPsychological = detect; }
   void SetAutoFibDetection(bool auto) { m_autoFibDetection = auto; }
   
   // الحصول على الإعدادات
   int GetLookbackPeriod() const { return m_lookbackPeriod; }
   int GetMinTouchPoints() const { return m_minTouchPoints; }
   double GetTolerancePercent() const { return m_tolerancePercent; }
   
   // مسح المستويات
   void ClearLevels();
   void RemoveBrokenLevels();
   void RemoveWeakLevels();

private:
   // دوال مساعدة
   bool FindSignificantLevels(const double &high[], const double &low[], 
                             const double &close[], int start, int end,
                             SSupportResistanceLevel &levels[]);
   
   SSupportResistanceLevel CreateLevel(double price, ENUM_SR_TYPE type,
                                      const SChartPoint &initialTouch);
   
   bool ValidateLevel(const SSupportResistanceLevel &level,
                     const double &high[], const double &low[], 
                     const double &close[], int rates_total);
   
   void AddTouchPoint(SSupportResistanceLevel &level, const SChartPoint &point);
   void AddBreakPoint(SSupportResistanceLevel &level, const SChartPoint &point);
   void AddRetestPoint(SSupportResistanceLevel &level, const SChartPoint &point);
   
   bool IsNearLevel(double price, const SSupportResistanceLevel &level);
   bool IsPsychologicalLevel(double price);
   
   double CalculateVolumeAtLevel(const SSupportResistanceLevel &level,
                                const double &high[], const double &low[], 
                                const double &volume[], int rates_total);
   
   ENUM_SR_TIMEFRAME_IMPORTANCE CalculateImportance(const SSupportResistanceLevel &level);
   
   long GenerateUniqueId();
   void InitializeFibonacciLevels();
   
   // دوال فيبوناتشي
   void FindSwingHighLow(const double &high[], const double &low[], 
                        int start, int end, double &swingHigh, double &swingLow,
                        int &swingHighIndex, int &swingLowIndex);
};

//+------------------------------------------------------------------+
//| المنشئ |
//+------------------------------------------------------------------+
CSupportResistanceDetector::CSupportResistanceDetector()
{
   m_levelCount = 0;
   m_lookbackPeriod = 200;
   m_minTouchPoints = 2;
   m_tolerancePercent = 0.02; // 2%
   m_minLevelStrength = 0.3;
   m_useVolumeAnalysis = true;
   m_autoFibDetection = true;
   m_detectPsychological = true;
   m_roundNumberDigits = 2;
   
   m_trendDetector = new CTrendLineDetector();
   m_trendAnalyzer = new CTrendDetector();
   
   ArrayResize(m_levels, 0);
   InitializeFibonacciLevels();
}

//+------------------------------------------------------------------+
//| الهادم |
//+------------------------------------------------------------------+
CSupportResistanceDetector::~CSupportResistanceDetector()
{
   ClearLevels();
   if(m_trendDetector != NULL)
   {
      delete m_trendDetector;
      m_trendDetector = NULL;
   }
   if(m_trendAnalyzer != NULL)
   {
      delete m_trendAnalyzer;
      m_trendAnalyzer = NULL;
   }
}

//+------------------------------------------------------------------+
//| الكشف عن مستويات الدعم والمقاومة |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::DetectSupportResistanceLevels(const string symbol, ENUM_TIMEFRAMES timeframe,
                                                            const double &high[], const double &low[], 
                                                            const double &close[], const double &volume[],
                                                            const datetime &time[], int rates_total)
{
   if(rates_total < m_lookbackPeriod)
      return 0;
   
   ClearLevels();
   
   int totalLevels = 0;
   
   // كشف مستويات الدعم
   totalLevels += DetectSupportLevels(high, low, close, time, rates_total);
   
   // كشف مستويات المقاومة
   totalLevels += DetectResistanceLevels(high, low, close, time, rates_total);
   
   // كشف نقاط الارتكاز
   totalLevels += DetectPivotPoints(high, low, close, time, rates_total);
   
   // كشف مستويات فيبوناتشي
   if(m_autoFibDetection)
      totalLevels += DetectFibonacciLevels(high, low, time, rates_total);
   
   // كشف المستويات النفسية
   if(m_detectPsychological)
      totalLevels += DetectPsychologicalLevels(high, low, close, rates_total);
   
   // كشف مستويات ملف الحجم
   if(m_useVolumeAnalysis && ArraySize(volume) > 0)
      totalLevels += DetectVolumeProfileLevels(high, low, close, volume, time, rates_total);
   
   return totalLevels;
}

//+------------------------------------------------------------------+
//| كشف مستويات الدعم |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::DetectSupportLevels(const double &high[], const double &low[], 
                                                   const double &close[], const datetime &time[],
                                                   int rates_total)
{
   int levelsFound = 0;
   double tolerance = (high[rates_total-1] - low[rates_total-1]) * m_tolerancePercent;
   
   // البحث عن القيعان المهمة
   for(int i = rates_total - m_lookbackPeriod; i < rates_total - 10; i++)
   {
      bool isSignificantLow = true;
      int lookback = 5;
      
      // التحقق من كون هذه نقطة قاع مهمة
      for(int j = MathMax(0, i - lookback); j <= MathMin(rates_total - 1, i + lookback); j++)
      {
         if(j != i && low[j] <= low[i])
         {
            isSignificantLow = false;
            break;
         }
      }
      
      if(isSignificantLow)
      {
         double supportPrice = low[i];
         int touchCount = 1;
         SChartPoint touchPoints[];
         
         // إضافة النقطة الأولى
         ArrayResize(touchPoints, 1);
         touchPoints[0].price = supportPrice;
         touchPoints[0].time = time[i];
         touchPoints[0].barIndex = i;
         touchPoints[0].isConfirmed = true;
         
         // البحث عن نقاط لمس أخرى
         for(int k = i + 5; k < rates_total; k++)
         {
            if(MathAbs(low[k] - supportPrice) <= tolerance)
            {
               ArrayResize(touchPoints, touchCount + 1);
               touchPoints[touchCount].price = low[k];
               touchPoints[touchCount].time = time[k];
               touchPoints[touchCount].barIndex = k;
               touchPoints[touchCount].isConfirmed = true;
               touchCount++;
            }
         }
         
         // إذا كان عدد نقاط اللمس كافي
         if(touchCount >= m_minTouchPoints)
         {
            SSupportResistanceLevel newLevel = CreateLevel(supportPrice, SR_SUPPORT, touchPoints[0]);
            
            // إضافة نقاط اللمس
            ArrayResize(newLevel.touchPoints, touchCount);
            ArrayCopy(newLevel.touchPoints, touchPoints);
            newLevel.touchCount = touchCount;
            
            newLevel.strength = CalculateLevelStrength(newLevel);
            newLevel.reliabilityScore = CalculateReliabilityScore(newLevel);
            
            if(ValidateLevel(newLevel, high, low, close, rates_total))
            {
               // إضافة المستوى إلى المصفوفة
               ArrayResize(m_levels, m_levelCount + 1);
               m_levels[m_levelCount] = newLevel;
               m_levelCount++;
               levelsFound++;
            }
         }
      }
   }
   
   return levelsFound;
}

//+------------------------------------------------------------------+
//| كشف مستويات المقاومة |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::DetectResistanceLevels(const double &high[], const double &low[], 
                                                      const double &close[], const datetime &time[],
                                                      int rates_total)
{
   int levelsFound = 0;
   double tolerance = (high[rates_total-1] - low[rates_total-1]) * m_tolerancePercent;
   
   // البحث عن القمم المهمة
   for(int i = rates_total - m_lookbackPeriod; i < rates_total - 10; i++)
   {
      bool isSignificantHigh = true;
      int lookback = 5;
      
      // التحقق من كون هذه نقطة قمة مهمة
      for(int j = MathMax(0, i - lookback); j <= MathMin(rates_total - 1, i + lookback); j++)
      {
         if(j != i && high[j] >= high[i])
         {
            isSignificantHigh = false;
            break;
         }
      }
      
      if(isSignificantHigh)
      {
         double resistancePrice = high[i];
         int touchCount = 1;
         SChartPoint touchPoints[];
         
         // إضافة النقطة الأولى
         ArrayResize(touchPoints, 1);
         touchPoints[0].price = resistancePrice;
         touchPoints[0].time = time[i];
         touchPoints[0].barIndex = i;
         touchPoints[0].isConfirmed = true;
         
         // البحث عن نقاط لمس أخرى
         for(int k = i + 5; k < rates_total; k++)
         {
            if(MathAbs(high[k] - resistancePrice) <= tolerance)
            {
               ArrayResize(touchPoints, touchCount + 1);
               touchPoints[touchCount].price = high[k];
               touchPoints[touchCount].time = time[k];
               touchPoints[touchCount].barIndex = k;
               touchPoints[touchCount].isConfirmed = true;
               touchCount++;
            }
         }
         
         // إذا كان عدد نقاط اللمس كافي
         if(touchCount >= m_minTouchPoints)
         {
            SSupportResistanceLevel newLevel = CreateLevel(resistancePrice, SR_RESISTANCE, touchPoints[0]);
            
            // إضافة نقاط اللمس
            ArrayResize(newLevel.touchPoints, touchCount);
            ArrayCopy(newLevel.touchPoints, touchPoints);
            newLevel.touchCount = touchCount;
            
            newLevel.strength = CalculateLevelStrength(newLevel);
            newLevel.reliabilityScore = CalculateReliabilityScore(newLevel);
            
            if(ValidateLevel(newLevel, high, low, close, rates_total))
            {
               // إضافة المستوى إلى المصفوفة
               ArrayResize(m_levels, m_levelCount + 1);
               m_levels[m_levelCount] = newLevel;
               m_levelCount++;
               levelsFound++;
            }
         }
      }
   }
   
   return levelsFound;
}

//+------------------------------------------------------------------+
//| كشف نقاط الارتكاز |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::DetectPivotPoints(const double &high[], const double &low[], 
                                                  const double &close[], const datetime &time[],
                                                  int rates_total)
{
   int levelsFound = 0;
   int lookback = 3;
   
   for(int i = rates_total - m_lookbackPeriod; i < rates_total - lookback; i++)
   {
      // البحث عن pivot highs
      bool isPivotHigh = true;
      for(int j = i - lookback; j <= i + lookback; j++)
      {
         if(j != i && j >= 0 && j < rates_total && high[j] >= high[i])
         {
            isPivotHigh = false;
            break;
         }
      }
      
      // البحث عن pivot lows
      bool isPivotLow = true;
      for(int j = i - lookback; j <= i + lookback; j++)
      {
         if(j != i && j >= 0 && j < rates_total && low[j] <= low[i])
         {
            isPivotLow = false;
            break;
         }
      }
      
      if(isPivotHigh || isPivotLow)
      {
         double pivotPrice = isPivotHigh ? high[i] : low[i];
         ENUM_SR_TYPE pivotType = isPivotHigh ? SR_RESISTANCE : SR_SUPPORT;
         
         SChartPoint initialPoint;
         initialPoint.price = pivotPrice;
         initialPoint.time = time[i];
         initialPoint.barIndex = i;
         initialPoint.isConfirmed = true;
         
         SSupportResistanceLevel pivotLevel = CreateLevel(pivotPrice, SR_PIVOT_POINT, initialPoint);
         pivotLevel.name = "Pivot_" + IntegerToString(pivotLevel.id);
         pivotLevel.type = pivotType;
         pivotLevel.strength = SR_MODERATE;
         
         // إضافة المستوى
         ArrayResize(m_levels, m_levelCount + 1);
         m_levels[m_levelCount] = pivotLevel;
         m_levelCount++;
         levelsFound++;
      }
   }
   
   return levelsFound;
}

//+------------------------------------------------------------------+
//| كشف مستويات فيبوناتشي |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::DetectFibonacciLevels(const double &high[], const double &low[], 
                                                     const datetime &time[], int rates_total)
{
   int levelsFound = 0;
   
   // البحث عن أعلى قمة وأدنى قاع في الفترة
   double swingHigh, swingLow;
   int swingHighIndex, swingLowIndex;
   
   FindSwingHighLow(high, low, rates_total - m_lookbackPeriod, rates_total - 1,
                   swingHigh, swingLow, swingHighIndex, swingLowIndex);
   
   if(swingHigh > swingLow && swingHighIndex >= 0 && swingLowIndex >= 0)
   {
      double range = swingHigh - swingLow;
      
      // حساب مستويات فيبوناتشي
      for(int i = 0; i < ArraySize(m_fibLevels); i++)
      {
         double fibPrice = swingLow + (range * m_fibLevels[i]);
         
         SChartPoint initialPoint;
         initialPoint.price = fibPrice;
         initialPoint.time = time[MathMax(swingHighIndex, swingLowIndex)];
         initialPoint.barIndex = MathMax(swingHighIndex, swingLowIndex);
         initialPoint.isConfirmed = true;
         
         SSupportResistanceLevel fibLevel = CreateLevel(fibPrice, SR_FIBONACCI, initialPoint);
         fibLevel.name = "Fib_" + DoubleToString(m_fibLevels[i] * 100, 1) + "%";
         
         // تحديد نوع المستوى (دعم أو مقاومة)
         double currentPrice = (high[rates_total-1] + low[rates_total-1]) / 2.0;
         if(fibPrice < currentPrice)
            fibLevel.type = SR_SUPPORT;
         else
            fibLevel.type = SR_RESISTANCE;
         
         fibLevel.strength = SR_MODERATE; // مستويات فيبوناتشي لها قوة متوسطة افتراضياً
         fibLevel.importance = SR_INTERMEDIATE;
         
         // إضافة المستوى
         ArrayResize(m_levels, m_levelCount + 1);
         m_levels[m_levelCount] = fibLevel;
         m_levelCount++;
         levelsFound++;
      }
   }
   
   return levelsFound;
}

//+------------------------------------------------------------------+
//| كشف المستويات النفسية |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::DetectPsychologicalLevels(const double &high[], const double &low[], 
                                                         const double &close[], int rates_total)
{
   int levelsFound = 0;
   
   // الحصول على النطاق السعري
   double minPrice = low[ArrayMinimum(low, rates_total - m_lookbackPeriod, m_lookbackPeriod)];
   double maxPrice = high[ArrayMaximum(high, rates_total - m_lookbackPeriod, m_lookbackPeriod)];
   
   // البحث عن الأعداد الصحيحة في النطاق
   double step = MathPow(10, -m_roundNumberDigits);
   
   for(double price = MathFloor(minPrice / step) * step; price <= maxPrice; price += step)
   {
      if(IsPsychologicalLevel(price))
      {
         SChartPoint initialPoint;
         initialPoint.price = price;
         initialPoint.time = TimeCurrent();
         initialPoint.barIndex = rates_total - 1;
         initialPoint.isConfirmed = true;
         
         SSupportResistanceLevel psychLevel = CreateLevel(price, SR_PSYCHOLOGICAL, initialPoint);
         psychLevel.name = "Psych_" + DoubleToString(price, m_roundNumberDigits);
         
         // تحديد نوع المستوى
         double currentPrice = close[rates_total-1];
         if(price < currentPrice)
            psychLevel.type = SR_SUPPORT;
         else
            psychLevel.type = SR_RESISTANCE;
         
         psychLevel.strength = SR_WEAK; // المستويات النفسية لها قوة ضعيفة افتراضياً
         psychLevel.importance = SR_MINOR;
         
         // إضافة المستوى
         ArrayResize(m_levels, m_levelCount + 1);
         m_levels[m_levelCount] = psychLevel;
         m_levelCount++;
         levelsFound++;
      }
   }
   
   return levelsFound;
}

//+------------------------------------------------------------------+
//| كشف مستويات ملف الحجم |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::DetectVolumeProfileLevels(const double &high[], const double &low[], 
                                                         const double &close[], const double &volume[],
                                                         const datetime &time[], int rates_total)
{
   int levelsFound = 0;
   
   // حساب نطاق الأسعار
   double minPrice = low[ArrayMinimum(low, rates_total - m_lookbackPeriod, m_lookbackPeriod)];
   double maxPrice = high[ArrayMaximum(high, rates_total - m_lookbackPeriod, m_lookbackPeriod)];
   
   int priceIntervals = 50; // تقسيم النطاق إلى 50 فترة
   double intervalSize = (maxPrice - minPrice) / priceIntervals;
   
   double volumeProfile[];
   ArrayResize(volumeProfile, priceIntervals);
   ArrayInitialize(volumeProfile, 0.0);
   
   // تجميع الحجم حسب مستويات الأسعار
   for(int i = rates_total - m_lookbackPeriod; i < rates_total; i++)
   {
      double avgPrice = (high[i] + low[i] + close[i]) / 3.0;
      int intervalIndex = (int)((avgPrice - minPrice) / intervalSize);
      
      if(intervalIndex >= 0 && intervalIndex < priceIntervals)
      {
         volumeProfile[intervalIndex] += volume[i];
      }
   }
   
   // البحث عن أعلى مستويات الحجم
   for(int i = 1; i < priceIntervals - 1; i++)
   {
      bool isLocalMax = (volumeProfile[i] > volumeProfile[i-1] && 
                        volumeProfile[i] > volumeProfile[i+1] &&
                        volumeProfile[i] > 0);
      
      if(isLocalMax)
      {
         double levelPrice = minPrice + (i * intervalSize);
         
         SChartPoint initialPoint;
         initialPoint.price = levelPrice;
         initialPoint.time = time[rates_total - 1];
         initialPoint.barIndex = rates_total - 1;
         initialPoint.isConfirmed = true;
         
         SSupportResistanceLevel volumeLevel = CreateLevel(levelPrice, SR_VOLUME_PROFILE, initialPoint);
         volumeLevel.name = "Volume_" + IntegerToString(volumeLevel.id);
         volumeLevel.averageVolume = volumeProfile[i];
         volumeLevel.hasVolumeSpike = true;
         volumeLevel.strength = SR_STRONG;
         
         // تحديد نوع المستوى
         double currentPrice = close[rates_total-1];
         if(levelPrice < currentPrice)
            volumeLevel.type = SR_SUPPORT;
         else
            volumeLevel.type = SR_RESISTANCE;
         
         // إضافة المستوى
         ArrayResize(m_levels, m_levelCount + 1);
         m_levels[m_levelCount] = volumeLevel;
         m_levelCount++;
         levelsFound++;
      }
   }
   
   return levelsFound;
}

//+------------------------------------------------------------------+
//| الحصول على مستوى |
//+------------------------------------------------------------------+
SSupportResistanceLevel CSupportResistanceDetector::GetLevel(int index) const
{
   SSupportResistanceLevel emptyLevel;
   if(index >= 0 && index < m_levelCount)
      return m_levels[index];
   return emptyLevel;
}

//+------------------------------------------------------------------+
//| الحصول على المستويات النشطة |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::GetActiveLevels(ENUM_SR_TYPE type, SSupportResistanceLevel &activeLevels[])
{
   ArrayResize(activeLevels, 0);
   int activeCount = 0;
   
   for(int i = 0; i < m_levelCount; i++)
   {
      if(m_levels[i].status == SR_ACTIVE && 
         (type == -1 || m_levels[i].type == type))
      {
         ArrayResize(activeLevels, activeCount + 1);
         activeLevels[activeCount] = m_levels[i];
         activeCount++;
      }
   }
   
   return activeCount;
}

//+------------------------------------------------------------------+
//| الحصول على المستويات القريبة من السعر |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::GetLevelsNearPrice(double price, double range, SSupportResistanceLevel &nearLevels[])
{
   ArrayResize(nearLevels, 0);
   int nearCount = 0;
   
   for(int i = 0; i < m_levelCount; i++)
   {
      if(MathAbs(m_levels[i].price - price) <= range)
      {
         ArrayResize(nearLevels, nearCount + 1);
         nearLevels[nearCount] = m_levels[i];
         nearCount++;
      }
   }
   
   return nearCount;
}

//+------------------------------------------------------------------+
//| حساب قوة المستوى |
//+------------------------------------------------------------------+
ENUM_SR_STRENGTH CSupportResistanceDetector::CalculateLevelStrength(const SSupportResistanceLevel &level)
{
   double score = 0.0;
   
   // عدد نقاط اللمس
   if(level.touchCount >= 5) score += 3.0;
   else if(level.touchCount >= 3) score += 2.0;
   else if(level.touchCount >= 2) score += 1.0;
   
   // عمر المستوى
   if(level.ageInBars >= 100) score += 2.0;
   else if(level.ageInBars >= 50) score += 1.0;
   
   // معدل النجاح
   if(level.successRate >= 0.8) score += 2.0;
   else if(level.successRate >= 0.6) score += 1.0;
   
   // وجود حجم كبير
   if(level.hasVolumeSpike) score += 1.0;
   
   // تصنيف القوة
   if(score >= 7.0) return SR_VERY_STRONG;
   else if(score >= 5.0) return SR_STRONG;
   else if(score >= 3.0) return SR_MODERATE;
   else return SR_WEAK;
}

//+------------------------------------------------------------------+
//| حساب نقاط الموثوقية |
//+------------------------------------------------------------------+
double CSupportResistanceDetector::CalculateReliabilityScore(const SSupportResistanceLevel &level)
{
   double score = 0.0;
   
   // قوة المستوى
   switch(level.strength)
   {
      case SR_VERY_STRONG: score += 4.0; break;
      case SR_STRONG: score += 3.0; break;
      case SR_MODERATE: score += 2.0; break;
      case SR_WEAK: score += 1.0; break;
   }
   
   // عدد نقاط اللمس
   score += level.touchCount * 0.5;
   
   // العمر
   score += (level.ageInBars / 50.0);
   
   // نوع المستوى
   switch(level.type)
   {
      case SR_FIBONACCI: score += 1.0; break;
      case SR_PIVOT_POINT: score += 1.5; break;
      case SR_VOLUME_PROFILE: score += 2.0; break;
   }
   
   return MathMin(score, 10.0); // الحد الأقصى 10
}

//+------------------------------------------------------------------+
//| إنشاء مستوى جديد |
//+------------------------------------------------------------------+
SSupportResistanceLevel CSupportResistanceDetector::CreateLevel(double price, ENUM_SR_TYPE type,
                                                               const SChartPoint &initialTouch)
{
   SSupportResistanceLevel level;
   
   level.id = GenerateUniqueId();
   level.name = EnumToString(type) + "_" + IntegerToString(level.id);
   level.type = type;
   level.price = price;
   level.tolerance = price * m_tolerancePercent;
   level.upperBound = price + level.tolerance;
   level.lowerBound = price - level.tolerance;
   level.creationTime = TimeCurrent();
   level.firstTouch = initialTouch.time;
   level.lastTouch = initialTouch.time;
   level.status = SR_ACTIVE;
   level.strength = SR_WEAK;
   level.importance = SR_MINOR;
   
   return level;
}

//+------------------------------------------------------------------+
//| التحقق من كون السعر مستوى نفسي |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::IsPsychologicalLevel(double price)
{
   // التحقق من الأعداد الصحيحة والأعداد النصفية
   double step = MathPow(10, -m_roundNumberDigits);
   double remainder = MathMod(price, step);
   
   return (MathAbs(remainder) < step * 0.01 || MathAbs(remainder - step) < step * 0.01);
}

//+------------------------------------------------------------------+
//| توليد معرف فريد |
//+------------------------------------------------------------------+
long CSupportResistanceDetector::GenerateUniqueId()
{
   return (long)(GetTickCount64() & 0x7FFFFFFFFFFFFFFF);
}

//+------------------------------------------------------------------+
//| تهيئة مستويات فيبوناتشي |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::InitializeFibonacciLevels()
{
   m_fibLevels[0] = 0.0;     // 0%
   m_fibLevels[1] = 0.236;   // 23.6%
   m_fibLevels[2] = 0.382;   // 38.2%
   m_fibLevels[3] = 0.5;     // 50%
   m_fibLevels[4] = 0.618;   // 61.8%
   m_fibLevels[5] = 0.764;   // 76.4%
   m_fibLevels[6] = 1.0;     // 100%
   m_fibLevels[7] = 1.272;   // 127.2%
   m_fibLevels[8] = 1.618;   // 161.8%
}

//+------------------------------------------------------------------+
//| البحث عن أعلى قمة وأدنى قاع |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::FindSwingHighLow(const double &high[], const double &low[], 
                                                 int start, int end, double &swingHigh, double &swingLow,
                                                 int &swingHighIndex, int &swingLowIndex)
{
   swingHigh = high[start];
   swingLow = low[start];
   swingHighIndex = start;
   swingLowIndex = start;
   
   for(int i = start + 1; i <= end; i++)
   {
      if(high[i] > swingHigh)
      {
         swingHigh = high[i];
         swingHighIndex = i;
      }
      
      if(low[i] < swingLow)
      {
         swingLow = low[i];
         swingLowIndex = i;
      }
   }
}

//+------------------------------------------------------------------+
//| مسح جميع المستويات |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::ClearLevels()
{
   ArrayResize(m_levels, 0);
   m_levelCount = 0;
}

//+------------------------------------------------------------------+
//| إزالة المستويات المكسورة |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::RemoveBrokenLevels()
{
   int writeIndex = 0;
   
   for(int i = 0; i < m_levelCount; i++)
   {
      if(m_levels[i].status != SR_BROKEN)
      {
         if(writeIndex != i)
            m_levels[writeIndex] = m_levels[i];
         writeIndex++;
      }
   }
   
   m_levelCount = writeIndex;
}

//+------------------------------------------------------------------+
//| إزالة المستويات الضعيفة |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::RemoveWeakLevels()
{
   int writeIndex = 0;
   
   for(int i = 0; i < m_levelCount; i++)
   {
      if(m_levels[i].strength != SR_WEAK || m_levels[i].reliabilityScore >= m_minLevelStrength)
      {
         if(writeIndex != i)
            m_levels[writeIndex] = m_levels[i];
         writeIndex++;
      }
   }
   
   m_levelCount = writeIndex;
}

//+------------------------------------------------------------------+
//| تحديث المستويات |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::UpdateLevels(const double &high[], const double &low[], 
                                              const double &close[], const double &volume[],
                                              const datetime &time[], int currentBar)
{
   for(int i = 0; i < m_levelCount; i++)
   {
      UpdateLevelStatistics(m_levels[i], high, low, close, volume, currentBar);
   }
}

//+------------------------------------------------------------------+
//| تحديث إحصائيات المستوى |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::UpdateLevels(const double &high[], const double &low[], 
                                              const double &close[], const double &volume[],
                                              const datetime &time[], int currentBar)
{
   for(int i = 0; i < m_levelCount; i++)
   {
      UpdateLevelStatistics(m_levels[i], high, low, close, volume, time, currentBar);
   }
}

void CSupportResistanceDetector::UpdateLevelStatistics(SSupportResistanceLevel &level,
                                                       const double &high[], const double &low[], 
                                                       const double &close[], const double &volume[],
                                                       const datetime &time[], int currentBar)
{
   // فحص إذا كان السعر الحالي يلمس المستوى
   if(IsNearLevel(high[currentBar], level) || IsNearLevel(low[currentBar], level))
   {
      level.touchCount++;
      level.lastTouch = time[currentBar]; // استخدام وقت الشريط بدلاً من الوقت الحالي
      
      SChartPoint touchPoint;
      touchPoint.price = (IsNearLevel(high[currentBar], level)) ? high[currentBar] : low[currentBar];
      touchPoint.barIndex = currentBar;
      touchPoint.time = time[currentBar]; // استخدام وقت الشريط
      touchPoint.isConfirmed = true;
      
      AddTouchPoint(level, touchPoint);
   }
   
   // تحديث عمر المستوى باستخدام أرقام الأشرطة بدلاً من التواريخ
   if (level.touchCount > 0)
   {
      int firstTouchBarIndex = level.touchPoints[0].barIndex;
      level.ageInBars = currentBar - firstTouchBarIndex;
   }
   else
   {
      level.ageInBars = 0;
   }
   
   // تحديث قوة المستوى
   level.strength = CalculateLevelStrength(level);
   level.reliabilityScore = CalculateReliabilityScore(level);
}

SSupportResistanceLevel CSupportResistanceDetector::CreateLevel(double price, ENUM_SR_TYPE type,
                                                               const SChartPoint &initialTouch)
{
   SSupportResistanceLevel level;
   
   level.id = GenerateUniqueId();
   level.name = EnumToString(type) + "_" + IntegerToString(level.id);
   level.type = type;
   level.price = price;
   level.tolerance = price * m_tolerancePercent;
   level.upperBound = price + level.tolerance;
   level.lowerBound = price - level.tolerance;
   level.creationTime = initialTouch.time; // استخدام وقت اللمسة الأولى بدلاً من الوقت الحالي
   level.firstTouch = initialTouch.time;
   level.lastTouch = initialTouch.time;
   level.status = SR_ACTIVE;
   level.strength = SR_WEAK;
   level.importance = SR_MINOR;
   
   return level;
}

//+------------------------------------------------------------------+
//| التحقق من قرب السعر من المستوى |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::IsNearLevel(double price, const SSupportResistanceLevel &level)
{
   return (MathAbs(price - level.price) <= level.tolerance);
}

//+------------------------------------------------------------------+
//| إضافة نقطة لمس |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::AddTouchPoint(SSupportResistanceLevel &level, const SChartPoint &point)
{
   int currentSize = ArraySize(level.touchPoints);
   ArrayResize(level.touchPoints, currentSize + 1);
   level.touchPoints[currentSize] = point;
}

//+------------------------------------------------------------------+
//| إضافة نقطة كسر |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::AddBreakPoint(SSupportResistanceLevel &level, const SChartPoint &point)
{
   int currentSize = ArraySize(level.breakPoints);
   ArrayResize(level.breakPoints, currentSize + 1);
   level.breakPoints[currentSize] = point;
   level.breakCount++;
}

//+------------------------------------------------------------------+
//| إضافة نقطة إعادة اختبار |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::AddRetestPoint(SSupportResistanceLevel &level, const SChartPoint &point)
{
   int currentSize = ArraySize(level.retestPoints);
   ArrayResize(level.retestPoints, currentSize + 1);
   level.retestPoints[currentSize] = point;
   level.retestCount++;
}

//+------------------------------------------------------------------+
//| التحقق من كسر المستوى |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::CheckLevelBreakout(const SSupportResistanceLevel &level,
                                                    const double &high[], const double &low[], 
                                                    const double &close[], int currentBar,
                                                    double &breakoutPrice)
{
   if(currentBar < 1) return false;
   
   bool breakout = false;
   
   if(level.type == SR_SUPPORT)
   {
      // كسر هبوطي لمستوى الدعم
      if(close[currentBar] < level.lowerBound)
      {
         breakout = true;
         breakoutPrice = level.price;
      }
   }
   else if(level.type == SR_RESISTANCE)
   {
      // كسر صاعد لمستوى المقاومة
      if(close[currentBar] > level.upperBound)
      {
         breakout = true;
         breakoutPrice = level.price;
      }
   }
   
   return breakout;
}

//+------------------------------------------------------------------+
//| التحقق من إعادة اختبار المستوى |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::CheckLevelRetest(const SSupportResistanceLevel &level,
                                                  const double &high[], const double &low[], 
                                                  const double &close[], int currentBar)
{
   if(currentBar < 1 || level.status != SR_BROKEN) return false;
   
   // فحص إعادة اختبار المستوى بعد الكسر
   return IsNearLevel(high[currentBar], level) || IsNearLevel(low[currentBar], level);
}

//+------------------------------------------------------------------+
//| رسم مستوى |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::DrawLevel(const string symbol, const SSupportResistanceLevel &level,
                                           color levelColor, int lineWidth,
                                           ENUM_LINE_STYLE lineStyle)
{
   string objectName = "SR_Level_" + IntegerToString(level.id);
   
   // حذف الكائن السابق إذا وجد
   ObjectDelete(0, objectName);
   
   // إنشاء خط أفقي
   if(ObjectCreate(0, objectName, OBJ_HLINE, 0, 0, level.price))
   {
      ObjectSetInteger(0, objectName, OBJPROP_COLOR, levelColor);
      ObjectSetInteger(0, objectName, OBJPROP_WIDTH, lineWidth);
      ObjectSetInteger(0, objectName, OBJPROP_STYLE, lineStyle);
      ObjectSetString(0, objectName, OBJPROP_TEXT, level.name);
   }
}

//+------------------------------------------------------------------+
//| رسم جميع المستويات |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::DrawAllLevels(const string symbol)
{
   for(int i = 0; i < m_levelCount; i++)
   {
      color levelColor = clrBlue;
      
      switch(m_levels[i].type)
      {
         case SR_SUPPORT: levelColor = clrGreen; break;
         case SR_RESISTANCE: levelColor = clrRed; break;
         case SR_PIVOT_POINT: levelColor = clrYellow; break;
         case SR_FIBONACCI: levelColor = clrPurple; break;
         case SR_PSYCHOLOGICAL: levelColor = clrGray; break;
         case SR_VOLUME_PROFILE: levelColor = clrOrange; break;
      }
      
      DrawLevel(symbol, m_levels[i], levelColor);
   }
}

//+------------------------------------------------------------------+
//| رسم مستويات حسب النوع |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::DrawLevelsByType(const string symbol, ENUM_SR_TYPE type)
{
   for(int i = 0; i < m_levelCount; i++)
   {
      if(m_levels[i].type == type)
      {
         color levelColor = clrBlue;
         
         switch(type)
         {
            case SR_SUPPORT: levelColor = clrGreen; break;
            case SR_RESISTANCE: levelColor = clrRed; break;
            case SR_PIVOT_POINT: levelColor = clrYellow; break;
            case SR_FIBONACCI: levelColor = clrPurple; break;
            case SR_PSYCHOLOGICAL: levelColor = clrGray; break;
            case SR_VOLUME_PROFILE: levelColor = clrOrange; break;
         }
         
         DrawLevel(symbol, m_levels[i], levelColor);
      }
   }
}

//+------------------------------------------------------------------+
//| التحقق من صحة المستوى |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::ValidateLevel(const SSupportResistanceLevel &level,
                                               const double &high[], const double &low[], 
                                               const double &close[], int rates_total)
{
   // التحقق من صحة السعر
   if(level.price <= 0.0) return false;
   
   // التحقق من عدد نقاط اللمس
   if(level.touchCount < m_minTouchPoints) return false;
   
   // التحقق من قوة المستوى
   if(level.reliabilityScore < m_minLevelStrength) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| حساب الحجم عند المستوى |
//+------------------------------------------------------------------+
double CSupportResistanceDetector::CalculateVolumeAtLevel(const SSupportResistanceLevel &level,
                                                          const double &high[], const double &low[], 
                                                          const double &volume[], int rates_total)
{
   double totalVolume = 0.0;
   int volumeCount = 0;
   
   for(int i = 0; i < rates_total; i++)
   {
      if(IsNearLevel(high[i], level) || IsNearLevel(low[i], level))
      {
         totalVolume += volume[i];
         volumeCount++;
      }
   }
   
   return (volumeCount > 0) ? (totalVolume / volumeCount) : 0.0;
}

//+------------------------------------------------------------------+
//| حساب أهمية المستوى |
//+------------------------------------------------------------------+
ENUM_SR_TIMEFRAME_IMPORTANCE CSupportResistanceDetector::CalculateImportance(const SSupportResistanceLevel &level)
{
   double score = 0.0;
   
   // قوة المستوى
   switch(level.strength)
   {
      case SR_VERY_STRONG: score += 4.0; break;
      case SR_STRONG: score += 3.0; break;
      case SR_MODERATE: score += 2.0; break;
      case SR_WEAK: score += 1.0; break;
   }
   
   // عدد نقاط اللمس
   if(level.touchCount >= 5) score += 2.0;
   else if(level.touchCount >= 3) score += 1.0;
   
   // عمر المستوى
   if(level.ageInBars >= 100) score += 1.0;
   
   // تصنيف الأهمية
   if(score >= 6.0) return SR_CRITICAL;
   else if(score >= 4.0) return SR_MAJOR;
   else if(score >= 2.0) return SR_INTERMEDIATE;
   else return SR_MINOR;
}

//+------------------------------------------------------------------+
//| البحث عن مستويات مهمة |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::FindSignificantLevels(const double &high[], const double &low[], 
                                                       const double &close[], int start, int end,
                                                       SSupportResistanceLevel &levels[])
{
   ArrayResize(levels, 0);
   
   // هذه دالة مساعدة للبحث عن مستويات مهمة في نطاق محدد
   // يمكن تطويرها لاحقاً حسب الحاجة
   
   return true;
}

//+------------------------------------------------------------------+