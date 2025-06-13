//+------------------------------------------------------------------+
//| SupportResistance.mqh |
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
   CTrendLineDetector           *m_trendDetector;    // كاشف خطوط الاتجاه
   CTrendDetector               *m_trendAnalyzer;    // محلل الاتجاه
   
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
   bool GetLevel(int index, SSupportResistanceLevel &level) const;
   int GetActiveLevels(SSupportResistanceLevel &activeLevels[]);
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
   
   // دوال نسخ الهياكل
   void CopyLevel(SSupportResistanceLevel &destination, const SSupportResistanceLevel &source);
   static void CopyLevelStatic(SSupportResistanceLevel &destination, const SSupportResistanceLevel &source);
   
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
   if(CheckPointer(m_trendDetector) == POINTER_DYNAMIC)
   {
      delete m_trendDetector;
      m_trendDetector = NULL;
   }
   if(CheckPointer(m_trendAnalyzer) == POINTER_DYNAMIC)
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
               CopyLevel(m_levels[m_levelCount], newLevel);
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
               CopyLevel(m_levels[m_levelCount], newLevel);
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
   
   if(rates_total < 10)
      return 0;
   
   // حساب نقطة الارتكاز للشمعة السابقة
   int prevBar = rates_total - 2; // الشمعة السابقة
   if(prevBar < 0)
      return 0;
   
   double pivotPoint = (high[prevBar] + low[prevBar] + close[prevBar]) / 3.0;
   double s1 = (2 * pivotPoint) - high[prevBar];
   double r1 = (2 * pivotPoint) - low[prevBar];
   double s2 = pivotPoint - (high[prevBar] - low[prevBar]);
   double r2 = pivotPoint + (high[prevBar] - low[prevBar]);
   
   // إنشاء مستويات نقاط الارتكاز
   double pivotLevels[] = {pivotPoint, r1, r2, s1, s2};
   string pivotNames[] = {"PP", "R1", "R2", "S1", "S2"};
   
   for(int i = 0; i < ArraySize(pivotLevels); i++)
   {
      SChartPoint initialPoint;
      initialPoint.price = pivotLevels[i];
      initialPoint.time = time[rates_total - 1];
      initialPoint.barIndex = rates_total - 1;
      initialPoint.isConfirmed = true;
      
      SSupportResistanceLevel pivotLevel = CreateLevel(pivotLevels[i], SR_PIVOT_POINT, initialPoint);
      pivotLevel.name = "Pivot_" + pivotNames[i];
      
      // تحديد نوع المستوى
      if(i == 0) // نقطة الارتكاز الأساسية
      {
         pivotLevel.type = (close[rates_total-1] > pivotLevels[i]) ? SR_SUPPORT : SR_RESISTANCE;
      }
      else if(i == 1 || i == 2) // مستويات المقاومة
      {
         pivotLevel.type = SR_RESISTANCE;
      }
      else // مستويات الدعم
      {
         pivotLevel.type = SR_SUPPORT;
      }
      
      pivotLevel.strength = SR_MODERATE;
      pivotLevel.importance = SR_INTERMEDIATE;
      
      // إضافة المستوى
      ArrayResize(m_levels, m_levelCount + 1);
      CopyLevel(m_levels[m_levelCount], pivotLevel);
      m_levelCount++;
      levelsFound++;
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
         CopyLevel(m_levels[m_levelCount], fibLevel);
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
         CopyLevel(m_levels[m_levelCount], psychLevel);
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
   
   if(rates_total < m_lookbackPeriod || ArraySize(volume) == 0)
      return 0;
   
   // إنشاء ملف الحجم
   struct SVolumeLevel
   {
      double price;
      double totalVolume;
   };
   
   SVolumeLevel volumeLevels[];
   int levelCount = 100; // تقسيم النطاق السعري إلى 100 مستوى
   ArrayResize(volumeLevels, levelCount);
   
   // العثور على النطاق السعري
   double minPrice = low[ArrayMinimum(low, rates_total - m_lookbackPeriod, m_lookbackPeriod)];
   double maxPrice = high[ArrayMaximum(high, rates_total - m_lookbackPeriod, m_lookbackPeriod)];
   double priceStep = (maxPrice - minPrice) / levelCount;
   
   if(priceStep <= 0)
      return 0;
   
   // تهيئة مستويات الحجم
   for(int i = 0; i < levelCount; i++)
   {
      volumeLevels[i].price = minPrice + (i * priceStep);
      volumeLevels[i].totalVolume = 0.0;
   }
   
   // توزيع الحجم على المستويات
   for(int i = rates_total - m_lookbackPeriod; i < rates_total; i++)
   {
      if(i >= ArraySize(volume))
         break;
         
      double barVolume = (double)volume[i];
      double avgPrice = (high[i] + low[i] + close[i]) / 3.0;
      
      // العثور على المستوى المناسب
      int levelIndex = (int)((avgPrice - minPrice) / priceStep);
      if(levelIndex >= 0 && levelIndex < levelCount)
      {
         volumeLevels[levelIndex].totalVolume += barVolume;
      }
   }
   
   // العثور على مستويات الحجم العالي
   double maxVolume = 0.0;
   for(int i = 0; i < levelCount; i++)
   {
      maxVolume = MathMax(maxVolume, volumeLevels[i].totalVolume);
   }
   
   if(maxVolume == 0)
      return 0;
   
   // إنشاء مستويات الدعم والمقاومة من ملف الحجم
   double volumeThreshold = maxVolume * 0.7; // 70% من أعلى حجم
   
   for(int i = 0; i < levelCount; i++)
   {
      if(volumeLevels[i].totalVolume >= volumeThreshold)
      {
         SChartPoint initialPoint;
         initialPoint.price = volumeLevels[i].price;
         initialPoint.time = time[rates_total - 1];
         initialPoint.barIndex = rates_total - 1;
         initialPoint.isConfirmed = true;
         
         SSupportResistanceLevel volumeLevel = CreateLevel(volumeLevels[i].price, SR_VOLUME_PROFILE, initialPoint);
         volumeLevel.name = "VOL_" + DoubleToString(volumeLevels[i].price, 5);
         
         // تحديد نوع المستوى
         double currentPrice = close[rates_total - 1];
         if(volumeLevels[i].price < currentPrice)
            volumeLevel.type = SR_SUPPORT;
         else
            volumeLevel.type = SR_RESISTANCE;
         
         volumeLevel.strength = SR_STRONG; // مستويات الحجم لها قوة عالية
         volumeLevel.importance = SR_MAJOR;
         volumeLevel.averageVolume = volumeLevels[i].totalVolume;
         volumeLevel.hasVolumeSpike = true;
         
         // إضافة المستوى
         ArrayResize(m_levels, m_levelCount + 1);
         CopyLevel(m_levels[m_levelCount], volumeLevel);
         m_levelCount++;
         levelsFound++;
      }
   }
   
   return levelsFound;
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
   
   // عدد نقاط اللمس
   score += level.touchCount * 10.0;
   
   // عمر المستوى
   score += level.ageInBars * 0.1;
   
   // قوة المستوى
   switch(level.strength)
   {
      case SR_VERY_STRONG: score += 40.0; break;
      case SR_STRONG: score += 30.0; break;
      case SR_MODERATE: score += 20.0; break;
      case SR_WEAK: score += 10.0; break;
   }
   
   // تأكيد الحجم
   if(level.hasVolumeSpike)
      score += 15.0;
   
   return MathMin(100.0, score);
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
//| الحصول على مستوى بالفهرس |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::GetLevel(int index, SSupportResistanceLevel &level) const
{
   if(index >= 0 && index < m_levelCount)
   {
      CopyLevelStatic(level, m_levels[index]);
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| الحصول على جميع المستويات النشطة |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::GetActiveLevels(SSupportResistanceLevel &activeLevels[])
{
   ArrayResize(activeLevels, 0);
   int count = 0;
   
   for(int i = 0; i < m_levelCount; i++)
   {
      if(m_levels[i].status == SR_ACTIVE)
      {
         ArrayResize(activeLevels, count + 1);
         CopyLevel(activeLevels[count], m_levels[i]);
         count++;
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| الحصول على المستويات النشطة حسب النوع |
//+------------------------------------------------------------------+
int CSupportResistanceDetector::GetActiveLevels(ENUM_SR_TYPE type, SSupportResistanceLevel &activeLevels[])
{
   ArrayResize(activeLevels, 0);
   int count = 0;
   
   for(int i = 0; i < m_levelCount; i++)
   {
      if(m_levels[i].status == SR_ACTIVE && m_levels[i].type == type)
      {
         ArrayResize(activeLevels, count + 1);
         CopyLevel(activeLevels[count], m_levels[i]);
         count++;
      }
   }
   
   return count;
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
         CopyLevel(nearLevels[nearCount], m_levels[i]);
         nearCount++;
      }
   }
   
   return nearCount;
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
//| تحديث المستويات |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::UpdateLevels(const double &high[], const double &low[], 
                                              const double &close[], const double &volume[],
                                              const datetime &time[], int currentBar)
{
   // تحديث إحصائيات كل مستوى
   for(int i = 0; i < m_levelCount; i++)
   {
      UpdateLevelStatistics(m_levels[i], high, low, close, volume, currentBar);
   }
   
   // إزالة المستويات الضعيفة
   RemoveWeakLevels();
}

//+------------------------------------------------------------------+
//| تحديث إحصائيات المستوى |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::UpdateLevelStatistics(SSupportResistanceLevel &level,
                                                       const double &high[], const double &low[], 
                                                       const double &close[], const double &volume[],
                                                       int currentBar)
{
   if(currentBar <= 0)
      return;
   
   double currentPrice = close[currentBar];
   
   // فحص إذا كان السعر قريب من المستوى
   if(IsNearLevel(currentPrice, level))
   {
      // إضافة نقطة لمس جديدة
      SChartPoint touchPoint;
      touchPoint.price = currentPrice;
      touchPoint.barIndex = currentBar;
      touchPoint.isConfirmed = true;
      
      AddTouchPoint(level, touchPoint);
   }
   
   // تحديث عمر المستوى
   level.ageInBars++;
   
   // إعادة حساب قوة المستوى
   level.strength = CalculateLevelStrength(level);
   level.reliabilityScore = CalculateReliabilityScore(level);
}

//+------------------------------------------------------------------+
//| فحص كسر المستوى |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::CheckLevelBreakout(const SSupportResistanceLevel &level,
                                                    const double &high[], const double &low[], 
                                                    const double &close[], int currentBar,
                                                    double &breakoutPrice)
{
   if(currentBar <= 0)
      return false;
   
   breakoutPrice = 0.0;
   
   if(level.type == SR_SUPPORT)
   {
      // فحص كسر الدعم
      if(close[currentBar] < level.lowerBound)
      {
         breakoutPrice = level.price;
         return true;
      }
   }
   else if(level.type == SR_RESISTANCE)
   {
      // فحص كسر المقاومة
      if(close[currentBar] > level.upperBound)
      {
         breakoutPrice = level.price;
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| فحص إعادة اختبار المستوى |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::CheckLevelRetest(const SSupportResistanceLevel &level,
                                                  const double &high[], const double &low[], 
                                                  const double &close[], int currentBar)
{
   if(currentBar <= 0)
      return false;
   
   // فحص إذا كان السعر يعيد اختبار المستوى بعد كسره
   if(level.status == SR_BROKEN)
   {
      return IsNearLevel(close[currentBar], level);
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| إضافة نقطة لمس |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::AddTouchPoint(SSupportResistanceLevel &level, const SChartPoint &point)
{
   ArrayResize(level.touchPoints, level.touchCount + 1);
   level.touchPoints[level.touchCount] = point;
   level.touchCount++;
   level.lastTouch = point.time;
}

//+------------------------------------------------------------------+
//| إضافة نقطة كسر |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::AddBreakPoint(SSupportResistanceLevel &level, const SChartPoint &point)
{
   ArrayResize(level.breakPoints, level.breakCount + 1);
   level.breakPoints[level.breakCount] = point;
   level.breakCount++;
   level.status = SR_BROKEN;
}

//+------------------------------------------------------------------+
//| إضافة نقطة إعادة اختبار |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::AddRetestPoint(SSupportResistanceLevel &level, const SChartPoint &point)
{
   ArrayResize(level.retestPoints, level.retestCount + 1);
   level.retestPoints[level.retestCount] = point;
   level.retestCount++;
   level.status = SR_RETESTED;
}

//+------------------------------------------------------------------+
//| فحص القرب من المستوى |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::IsNearLevel(double price, const SSupportResistanceLevel &level)
{
   return (price >= level.lowerBound && price <= level.upperBound);
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
//| حساب معدل الحجم عند المستوى |
//+------------------------------------------------------------------+
double CSupportResistanceDetector::CalculateVolumeAtLevel(const SSupportResistanceLevel &level,
                                                          const double &high[], const double &low[], 
                                                          const double &volume[], int rates_total)
{
   if(ArraySize(volume) == 0)
      return 0.0;
   
   double totalVolume = 0.0;
   int volumeCount = 0;
   
   // حساب متوسط الحجم عند نقاط اللمس
   for(int i = 0; i < level.touchCount; i++)
   {
      int barIndex = level.touchPoints[i].barIndex;
      if(barIndex >= 0 && barIndex < rates_total)
      {
         totalVolume += volume[barIndex];
         volumeCount++;
      }
   }
   
   return (volumeCount > 0) ? totalVolume / volumeCount : 0.0;
}

//+------------------------------------------------------------------+
//| حساب أهمية المستوى |
//+------------------------------------------------------------------+
ENUM_SR_TIMEFRAME_IMPORTANCE CSupportResistanceDetector::CalculateImportance(const SSupportResistanceLevel &level)
{
   double score = level.reliabilityScore;
   
   if(score >= 80.0)
      return SR_CRITICAL;
   else if(score >= 60.0)
      return SR_MAJOR;
   else if(score >= 40.0)
      return SR_INTERMEDIATE;
   else
      return SR_MINOR;
}

//+------------------------------------------------------------------+
//| توليد معرف فريد |
//+------------------------------------------------------------------+
long CSupportResistanceDetector::GenerateUniqueId()
{
   return (long)GetTickCount64();
}

//+------------------------------------------------------------------+
//| مسح المستويات |
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
   for(int i = m_levelCount - 1; i >= 0; i--)
   {
      if(m_levels[i].status == SR_BROKEN)
      {
         // إزالة المستوى المكسور
         for(int j = i; j < m_levelCount - 1; j++)
         {
            m_levels[j] = m_levels[j + 1];
         }
         m_levelCount--;
      }
   }
   
   ArrayResize(m_levels, m_levelCount);
}

//+------------------------------------------------------------------+
//| إزالة المستويات الضعيفة |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::RemoveWeakLevels()
{
   for(int i = m_levelCount - 1; i >= 0; i--)
   {
      if(m_levels[i].strength == SR_WEAK && m_levels[i].touchCount < 2)
      {
         // إزالة المستوى الضعيف
         for(int j = i; j < m_levelCount - 1; j++)
         {
            m_levels[j] = m_levels[j + 1];
         }
         m_levelCount--;
      }
   }
   
   ArrayResize(m_levels, m_levelCount);
}

//+------------------------------------------------------------------+
//| التحقق من صحة المستوى |
//+------------------------------------------------------------------+
bool CSupportResistanceDetector::ValidateLevel(const SSupportResistanceLevel &level,
                                               const double &high[], const double &low[], 
                                               const double &close[], int rates_total)
{
   // فحص أساسي
   if(level.price <= 0.0 || level.touchCount < m_minTouchPoints)
      return false;
   
   // فحص قوة المستوى
   if(level.reliabilityScore < m_minLevelStrength * 100.0)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| رسم مستوى واحد |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::DrawLevel(const string symbol, const SSupportResistanceLevel &level,
                                           color levelColor, int lineWidth,
                                           ENUM_LINE_STYLE lineStyle)
{
   string objectName = "SR_Level_" + IntegerToString(level.id);
   
   if(ObjectCreate(0, objectName, OBJ_HLINE, 0, 0, level.price))
   {
      ObjectSetInteger(0, objectName, OBJPROP_COLOR, levelColor);
      ObjectSetInteger(0, objectName, OBJPROP_WIDTH, lineWidth);
      ObjectSetInteger(0, objectName, OBJPROP_STYLE, lineStyle);
   }
}

//+------------------------------------------------------------------+
//| رسم جميع المستويات |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::DrawAllLevels(const string symbol)
{
   for(int i = 0; i < m_levelCount; i++)
   {
      color levelColor = (m_levels[i].type == SR_SUPPORT) ? clrBlue : clrRed;
      DrawLevel(symbol, m_levels[i], levelColor);
   }
}

//+------------------------------------------------------------------+
//| رسم المستويات حسب النوع |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::DrawLevelsByType(const string symbol, ENUM_SR_TYPE type)
{
   for(int i = 0; i < m_levelCount; i++)
   {
      if(m_levels[i].type == type)
      {
         color levelColor = (type == SR_SUPPORT) ? clrBlue : clrRed;
         DrawLevel(symbol, m_levels[i], levelColor);
      }
   }
}

//+------------------------------------------------------------------+
//| نسخ مستوى بشكل يدوي |
//+------------------------------------------------------------------+
void CSupportResistanceDetector::CopyLevel(SSupportResistanceLevel &destination, const SSupportResistanceLevel &source)
{
   // نسخ القيم البسيطة
   destination.id = source.id;
   destination.name = source.name;
   destination.type = source.type;
   destination.strength = source.strength;
   destination.status = source.status;
   destination.importance = source.importance;
   destination.price = source.price;
   destination.tolerance = source.tolerance;
   destination.upperBound = source.upperBound;
   destination.lowerBound = source.lowerBound;
   destination.touchCount = source.touchCount;
   destination.breakCount = source.breakCount;
   destination.retestCount = source.retestCount;
   destination.rejectionCount = source.rejectionCount;
   destination.firstTouch = source.firstTouch;
   destination.lastTouch = source.lastTouch;
   destination.creationTime = source.creationTime;
   destination.ageInBars = source.ageInBars;
   destination.averageVolume = source.averageVolume;
   destination.maxVolume = source.maxVolume;
   destination.hasVolumeSpike = source.hasVolumeSpike;
   destination.reliabilityScore = source.reliabilityScore;
   destination.successRate = source.successRate;
   
   // نسخ المصفوفات
   ArrayResize(destination.touchPoints, ArraySize(source.touchPoints));
   for(int i = 0; i < ArraySize(source.touchPoints); i++)
      destination.touchPoints[i] = source.touchPoints[i];
   
   ArrayResize(destination.breakPoints, ArraySize(source.breakPoints));
   for(int i = 0; i < ArraySize(source.breakPoints); i++)
      destination.breakPoints[i] = source.breakPoints[i];
   
   ArrayResize(destination.retestPoints, ArraySize(source.retestPoints));
   for(int i = 0; i < ArraySize(source.retestPoints); i++)
      destination.retestPoints[i] = source.retestPoints[i];
}

//+------------------------------------------------------------------+
//| نسخ مستوى بشكل يدوي (دالة ستاتيك) |
//+------------------------------------------------------------------+
static void CSupportResistanceDetector::CopyLevelStatic(SSupportResistanceLevel &destination, const SSupportResistanceLevel &source)
{
   // نسخ القيم البسيطة
   destination.id = source.id;
   destination.name = source.name;
   destination.type = source.type;
   destination.strength = source.strength;
   destination.status = source.status;
   destination.importance = source.importance;
   destination.price = source.price;
   destination.tolerance = source.tolerance;
   destination.upperBound = source.upperBound;
   destination.lowerBound = source.lowerBound;
   destination.touchCount = source.touchCount;
   destination.breakCount = source.breakCount;
   destination.retestCount = source.retestCount;
   destination.rejectionCount = source.rejectionCount;
   destination.firstTouch = source.firstTouch;
   destination.lastTouch = source.lastTouch;
   destination.creationTime = source.creationTime;
   destination.ageInBars = source.ageInBars;
   destination.averageVolume = source.averageVolume;
   destination.maxVolume = source.maxVolume;
   destination.hasVolumeSpike = source.hasVolumeSpike;
   destination.reliabilityScore = source.reliabilityScore;
   destination.successRate = source.successRate;
   
   // نسخ المصفوفات
   ArrayResize(destination.touchPoints, ArraySize(source.touchPoints));
   for(int i = 0; i < ArraySize(source.touchPoints); i++)
      destination.touchPoints[i] = source.touchPoints[i];
   
   ArrayResize(destination.breakPoints, ArraySize(source.breakPoints));
   for(int i = 0; i < ArraySize(source.breakPoints); i++)
      destination.breakPoints[i] = source.breakPoints[i];
   
   ArrayResize(destination.retestPoints, ArraySize(source.retestPoints));
   for(int i = 0; i < ArraySize(source.retestPoints); i++)
      destination.retestPoints[i] = source.retestPoints[i];
}