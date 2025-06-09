//+------------------------------------------------------------------+
//|                                               ChartPattern.mqh |
//|                                     الفئة الأساسية لأنماط المخططات |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| تعدادات أنواع أنماط المخططات                                    |
//+------------------------------------------------------------------+
enum ENUM_CHART_PATTERN_TYPE
{
   CHART_PATTERN_CONTINUATION = 0,  // نمط استمراري
   CHART_PATTERN_REVERSAL = 1       // نمط انعكاسي
};

// تعداد حالة النمط
enum ENUM_CHART_PATTERN_STATUS
{
   CHART_PATTERN_FORMING = 0,       // في التكوين
   CHART_PATTERN_CONFIRMED = 1      // مؤكد
};

// تعداد اتجاه النمط
enum ENUM_PATTERN_DIRECTION
{
   PATTERN_NEUTRAL = 0,             // محايد
   PATTERN_BULLISH = 1,             // صعودي
   PATTERN_BEARISH = -1             // هبوطي
};

// تعداد نوع النقطة
enum ENUM_CHART_POINT_TYPE
{
   CHART_POINT_HIGH = 0,            // قمة
   CHART_POINT_LOW = 1              // قاع
};

//+------------------------------------------------------------------+
//| هياكل البيانات الأساسية                                         |
//+------------------------------------------------------------------+

// هيكل النقطة في المخطط
struct SChartPoint
{
   int               index;          // فهرس الشمعة
   double            price;          // السعر
   datetime          time;           // الوقت
   ENUM_CHART_POINT_TYPE type;       // نوع النقطة
   
   SChartPoint()
   {
      index = 0;
      price = 0.0;
      time = 0;
      type = CHART_POINT_HIGH;
   }
};

// هيكل خط الاتجاه
struct STrendLine
{
   SChartPoint       point1;         // النقطة الأولى
   SChartPoint       point2;         // النقطة الثانية
   double            slope;          // الميل
   double            intercept;      // النقطة المقطوعة
   bool              isValid;        // صالح أم لا
   
   STrendLine()
   {
      slope = 0.0;
      intercept = 0.0;
      isValid = false;
   }
};

// هيكل نتيجة نمط المخطط
struct SChartPatternResult
{
   string            patternName;          // اسم النمط
   ENUM_CHART_PATTERN_TYPE patternType;   // نوع النمط
   ENUM_PATTERN_DIRECTION direction;      // الاتجاه
   double            confidence;           // درجة الثقة
   double            reliability;          // الموثوقية
   double            completionPercentage; // نسبة الاكتمال
   
   double            priceTarget;          // الهدف السعري
   double            stopLoss;             // وقف الخسارة
   double            entryPrice;           // سعر الدخول
   
   datetime          formationStart;       // بداية التكوين
   datetime          formationEnd;         // نهاية التكوين
   datetime          detectionTime;        // وقت الكشف
   int               barsInPattern;        // عدد الشموع في النمط
   
   double            patternHeight;        // ارتفاع النمط
   double            patternWidth;         // عرض النمط
   
   SChartPoint       keyPoints[];         // النقاط الرئيسية
   STrendLine        trendLines[];        // خطوط الاتجاه
   
   ENUM_CHART_PATTERN_STATUS status;      // حالة النمط
   bool              isActive;            // نشط أم لا
   bool              isCompleted;         // مكتمل أم لا
   bool              hasVolConfirmation;  // تأكيد الحجم
   
   SChartPatternResult()
   {
      patternName = "";
      patternType = CHART_PATTERN_CONTINUATION;
      direction = PATTERN_NEUTRAL;
      confidence = 0.0;
      reliability = 0.0;
      completionPercentage = 0.0;
      
      priceTarget = 0.0;
      stopLoss = 0.0;
      entryPrice = 0.0;
      
      formationStart = 0;
      formationEnd = 0;
      detectionTime = 0;
      barsInPattern = 0;
      
      patternHeight = 0.0;
      patternWidth = 0.0;
      
      ArrayResize(keyPoints, 0);
      ArrayResize(trendLines, 0);
      
      status = CHART_PATTERN_FORMING;
      isActive = false;
      isCompleted = false;
      hasVolConfirmation = false;
   }
};

//+------------------------------------------------------------------+
//| الفئة الأساسية لأنماط المخططات                                   |
//+------------------------------------------------------------------+
class CChartPattern
{
protected:
   // المعلومات الأساسية
   string                     m_symbol;           // الرمز
   ENUM_TIMEFRAMES           m_timeframe;        // الإطار الزمني
   bool                      m_initialized;      // حالة التهيئة
   
   // خصائص النمط
   ENUM_CHART_PATTERN_TYPE   m_patternType;      // نوع النمط
   string                    m_patternName;      // اسم النمط
   
   // معاملات الكشف العامة
   double                    m_minConfidence;    // أقل درجة ثقة مقبولة
   double                    m_minReliability;   // أقل موثوقية مقبولة
   bool                      m_requireVolConfirm; // يتطلب تأكيد الحجم
   
   // إحصائيات الأداء
   int                       m_detectedPatterns; // عدد الأنماط المكتشفة
   int                       m_successfulPatterns; // عدد الأنماط الناجحة
   datetime                  m_lastDetectionTime; // آخر وقت كشف
   
public:
   // المنشئ والهادم
                     CChartPattern();
   virtual          ~CChartPattern();
   
   // التهيئة
   virtual bool      Initialize(const string symbol, const ENUM_TIMEFRAMES timeframe);
   virtual void      Reset();
   
   // الدوال الافتراضية الرئيسية
   virtual bool      DetectPattern(const int startIdx, const string symbol, 
                                 const ENUM_TIMEFRAMES timeframe,
                                 const double &open[], const double &high[], 
                                 const double &low[], const double &close[], 
                                 const long &volume[], SChartPatternResult &result) = 0;
   
   // إعداد المعاملات العامة
   void              SetDetectionParameters(const double minConfidence = 0.6,
                                          const double minReliability = 0.5,
                                          const bool requireVolConfirm = false);
   
   // الحصول على المعلومات
   string            GetSymbol() const { return m_symbol; }
   ENUM_TIMEFRAMES   GetTimeframe() const { return m_timeframe; }
   string            GetPatternName() const { return m_patternName; }
   ENUM_CHART_PATTERN_TYPE GetPatternType() const { return m_patternType; }
   bool              IsInitialized() const { return m_initialized; }
   
   // إحصائيات الأداء
   int               GetDetectedPatternsCount() const { return m_detectedPatterns; }
   int               GetSuccessfulPatternsCount() const { return m_successfulPatterns; }
   double            GetSuccessRate() const;
   datetime          GetLastDetectionTime() const { return m_lastDetectionTime; }
   
   // تقارير
   virtual string    GenerateStatusReport();
   virtual string    GeneratePerformanceReport();
   
protected:
   // دوال مساعدة للفئات المشتقة
   virtual void      SetPatternType(const ENUM_CHART_PATTERN_TYPE type) { m_patternType = type; }
   virtual void      SetPatternName(const string name) { m_patternName = name; }
   
   // دوال تحليل البيانات المشتركة
   bool              IsValidTimeframe(const ENUM_TIMEFRAMES timeframe);
   bool              IsValidSymbol(const string symbol);
   bool              HasSufficientData(const double &data[], const int minBars = 50);
   
   // دوال حساب إحصائية
   double            CalculateATR(const double &high[], const double &low[], 
                                const double &close[], const int period = 14, const int startIdx = 0);
   double            CalculateStdDev(const double &data[], const int period = 20, const int startIdx = 0);
   double            CalculateVolatility(const double &high[], const double &low[], 
                                       const double &close[], const int period = 20, const int startIdx = 0);
   
   // دوال تحليل الحجم
   bool              IsVolumeIncreasing(const long &volume[], const int idx, const int lookback = 5);
   bool              IsVolumeDecreasing(const long &volume[], const int idx, const int lookback = 5);
   double            CalculateVolumeRatio(const long &volume[], const int idx1, const int idx2);
   
   // دوال الاتجاه
   ENUM_PATTERN_DIRECTION DetectTrend(const double &close[], const int startIdx, const int endIdx);
   bool              IsUptrend(const double &close[], const int startIdx, const int period = 20);
   bool              IsDowntrend(const double &close[], const int startIdx, const int period = 20);
   
   // دوال القمم والقيعان
   bool              IsLocalHigh(const double &high[], const int idx, const int lookback = 2);
   bool              IsLocalLow(const double &low[], const int idx, const int lookback = 2);
   
   // دوال التحليل الزمني
   bool              IsTimeframeAppropriate(const ENUM_TIMEFRAMES tf, const int minBars);
   int               CalculateOptimalLookback(const ENUM_TIMEFRAMES tf);
   
   // دوال التحقق من صحة البيانات
   bool              ValidateArraySizes(const double &open[], const double &high[], 
                                      const double &low[], const double &close[], 
                                      const long &volume[]);
   bool              ValidateIndexRange(const int idx, const int arraySize);
   
   // تحديث الإحصائيات
   void              UpdateDetectionStats(const bool patternFound);
   void              UpdateSuccessStats(const bool patternSuccessful);
   
private:
   // دوال خاصة للاستخدام الداخلي
   void              InitializeDefaultValues();
   bool              ValidateInitialization();
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CChartPattern::CChartPattern()
{
   InitializeDefaultValues();
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CChartPattern::~CChartPattern()
{
   // تنظيف إضافي إذا احتجنا
}

//+------------------------------------------------------------------+
//| تهيئة القيم الافتراضية                                           |
//+------------------------------------------------------------------+
void CChartPattern::InitializeDefaultValues()
{
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_initialized = false;
   
   m_patternType = CHART_PATTERN_CONTINUATION;
   m_patternName = "نمط عام";
   
   m_minConfidence = 0.6;
   m_minReliability = 0.5;
   m_requireVolConfirm = false;
   
   m_detectedPatterns = 0;
   m_successfulPatterns = 0;
   m_lastDetectionTime = 0;
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CChartPattern::Initialize(const string symbol, const ENUM_TIMEFRAMES timeframe)
{
   if(!IsValidSymbol(symbol) || !IsValidTimeframe(timeframe))
      return false;
   
   m_symbol = symbol;
   m_timeframe = timeframe;
   m_initialized = true;
   
   Print("تم تهيئة كاشف النمط: ", m_patternName, " للرمز: ", symbol, 
         " الإطار الزمني: ", EnumToString(timeframe));
   
   return ValidateInitialization();
}

//+------------------------------------------------------------------+
//| إعادة تعيين النمط                                               |
//+------------------------------------------------------------------+
void CChartPattern::Reset()
{
   m_detectedPatterns = 0;
   m_successfulPatterns = 0;
   m_lastDetectionTime = 0;
}

//+------------------------------------------------------------------+
//| تحديد معاملات الكشف                                             |
//+------------------------------------------------------------------+
void CChartPattern::SetDetectionParameters(const double minConfidence = 0.6,
                                          const double minReliability = 0.5,
                                          const bool requireVolConfirm = false)
{
   m_minConfidence = MathMax(0.1, MathMin(1.0, minConfidence));
   m_minReliability = MathMax(0.1, MathMin(1.0, minReliability));
   m_requireVolConfirm = requireVolConfirm;
}

//+------------------------------------------------------------------+
//| حساب معدل النجاح                                                |
//+------------------------------------------------------------------+
double CChartPattern::GetSuccessRate() const
{
   if(m_detectedPatterns == 0)
      return 0.0;
   
   return (double)m_successfulPatterns / m_detectedPatterns * 100.0;
}

//+------------------------------------------------------------------+
//| توليد تقرير الحالة                                              |
//+------------------------------------------------------------------+
string CChartPattern::GenerateStatusReport()
{
   string report = "=== تقرير حالة النمط ===\n";
   report += "اسم النمط: " + m_patternName + "\n";
   report += "الرمز: " + m_symbol + "\n";
   report += "الإطار الزمني: " + EnumToString(m_timeframe) + "\n";
   report += "مهيأ: " + (m_initialized ? "نعم" : "لا") + "\n";
   report += StringFormat("أقل ثقة مقبولة: %.1f%%\n", m_minConfidence * 100);
   report += StringFormat("أقل موثوقية مقبولة: %.1f%%\n", m_minReliability * 100);
   report += "تأكيد الحجم مطلوب: " + (m_requireVolConfirm ? "نعم" : "لا") + "\n";
   
   return report;
}

//+------------------------------------------------------------------+
//| توليد تقرير الأداء                                              |
//+------------------------------------------------------------------+
string CChartPattern::GeneratePerformanceReport()
{
   string report = "=== تقرير أداء النمط ===\n";
   report += StringFormat("الأنماط المكتشفة: %d\n", m_detectedPatterns);
   report += StringFormat("الأنماط الناجحة: %d\n", m_successfulPatterns);
   report += StringFormat("معدل النجاح: %.1f%%\n", GetSuccessRate());
   
   if(m_lastDetectionTime > 0)
      report += "آخر كشف: " + TimeToString(m_lastDetectionTime) + "\n";
   else
      report += "لم يتم كشف أي نمط بعد\n";
   
   return report;
}

//+------------------------------------------------------------------+
//| التحقق من صحة الإطار الزمني                                     |
//+------------------------------------------------------------------+
bool CChartPattern::IsValidTimeframe(const ENUM_TIMEFRAMES timeframe)
{
   return (timeframe >= PERIOD_M1 && timeframe <= PERIOD_MN1);
}

//+------------------------------------------------------------------+
//| التحقق من صحة الرمز                                             |
//+------------------------------------------------------------------+
bool CChartPattern::IsValidSymbol(const string symbol)
{
   return (StringLen(symbol) > 0 && StringLen(symbol) <= 12);
}

//+------------------------------------------------------------------+
//| التحقق من كفاية البيانات                                        |
//+------------------------------------------------------------------+
bool CChartPattern::HasSufficientData(const double &data[], const int minBars = 50)
{
   return (ArraySize(data) >= minBars);
}

//+------------------------------------------------------------------+
//| حساب مؤشر ATR                                                   |
//+------------------------------------------------------------------+
double CChartPattern::CalculateATR(const double &high[], const double &low[], 
                                  const double &close[], const int period = 14, const int startIdx = 0)
{
   if(ArraySize(high) < period + startIdx || period <= 0)
      return 0.0;
   
   double sum = 0.0;
   for(int i = startIdx + 1; i < startIdx + period + 1; i++)
   {
      double tr1 = high[i] - low[i];
      double tr2 = MathAbs(high[i] - close[i-1]);
      double tr3 = MathAbs(low[i] - close[i-1]);
      
      sum += MathMax(tr1, MathMax(tr2, tr3));
   }
   
   return sum / period;
}

//+------------------------------------------------------------------+
//| حساب الانحراف المعياري                                          |
//+------------------------------------------------------------------+
double CChartPattern::CalculateStdDev(const double &data[], const int period = 20, const int startIdx = 0)
{
   if(ArraySize(data) < period + startIdx || period <= 0)
      return 0.0;
   
   // حساب المتوسط
   double sum = 0.0;
   for(int i = startIdx; i < startIdx + period; i++)
      sum += data[i];
   double mean = sum / period;
   
   // حساب الانحراف المعياري
   double variance = 0.0;
   for(int i = startIdx; i < startIdx + period; i++)
      variance += MathPow(data[i] - mean, 2);
   
   return MathSqrt(variance / period);
}

//+------------------------------------------------------------------+
//| حساب التقلبات                                                   |
//+------------------------------------------------------------------+
double CChartPattern::CalculateVolatility(const double &high[], const double &low[], 
                                         const double &close[], const int period = 20, const int startIdx = 0)
{
   if(ArraySize(close) < period + startIdx || period <= 0)
      return 0.0;
   
   double returns[];
   ArrayResize(returns, period - 1);
   
   for(int i = 0; i < period - 1; i++)
   {
      returns[i] = MathLog(close[startIdx + i + 1] / close[startIdx + i]);
   }
   
   return CalculateStdDev(returns, period - 1, 0);
}

//+------------------------------------------------------------------+
//| فحص زيادة الحجم                                                 |
//+------------------------------------------------------------------+
bool CChartPattern::IsVolumeIncreasing(const long &volume[], const int idx, const int lookback = 5)
{
   if(idx < lookback || ArraySize(volume) <= idx)
      return false;
   
   long currentAvg = 0;
   long previousAvg = 0;
   
   for(int i = 0; i < lookback; i++)
   {
      currentAvg += volume[idx - i];
      previousAvg += volume[idx - lookback - i];
   }
   
   return (currentAvg > previousAvg);
}

//+------------------------------------------------------------------+
//| فحص نقصان الحجم                                                 |
//+------------------------------------------------------------------+
bool CChartPattern::IsVolumeDecreasing(const long &volume[], const int idx, const int lookback = 5)
{
   return !IsVolumeIncreasing(volume, idx, lookback);
}

//+------------------------------------------------------------------+
//| حساب نسبة الحجم                                                 |
//+------------------------------------------------------------------+
double CChartPattern::CalculateVolumeRatio(const long &volume[], const int idx1, const int idx2)
{
   if(idx1 >= ArraySize(volume) || idx2 >= ArraySize(volume) || volume[idx2] == 0)
      return 1.0;
   
   return (double)volume[idx1] / volume[idx2];
}

//+------------------------------------------------------------------+
//| كشف الاتجاه                                                     |
//+------------------------------------------------------------------+
ENUM_PATTERN_DIRECTION CChartPattern::DetectTrend(const double &close[], const int startIdx, const int endIdx)
{
   if(startIdx >= endIdx || endIdx >= ArraySize(close))
      return PATTERN_NEUTRAL;
   
   double startPrice = close[startIdx];
   double endPrice = close[endIdx];
   double change = (endPrice - startPrice) / startPrice * 100.0;
   
   if(change > 2.0)       // صعود أكثر من 2%
      return PATTERN_BULLISH;
   else if(change < -2.0) // هبوط أكثر من 2%
      return PATTERN_BEARISH;
   else
      return PATTERN_NEUTRAL;
}

//+------------------------------------------------------------------+
//| فحص الاتجاه الصاعد                                              |
//+------------------------------------------------------------------+
bool CChartPattern::IsUptrend(const double &close[], const int startIdx, const int period = 20)
{
   return DetectTrend(close, startIdx - period, startIdx) == PATTERN_BULLISH;
}

//+------------------------------------------------------------------+
//| فحص الاتجاه الهابط                                              |
//+------------------------------------------------------------------+
bool CChartPattern::IsDowntrend(const double &close[], const int startIdx, const int period = 20)
{
   return DetectTrend(close, startIdx - period, startIdx) == PATTERN_BEARISH;
}

//+------------------------------------------------------------------+
//| فحص القمة المحلية                                               |
//+------------------------------------------------------------------+
bool CChartPattern::IsLocalHigh(const double &high[], const int idx, const int lookback = 2)
{
   if(idx < lookback || idx >= ArraySize(high) - lookback)
      return false;
   
   for(int i = 1; i <= lookback; i++)
   {
      if(high[idx] <= high[idx - i] || high[idx] <= high[idx + i])
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص القاع المحلي                                                |
//+------------------------------------------------------------------+
bool CChartPattern::IsLocalLow(const double &low[], const int idx, const int lookback = 2)
{
   if(idx < lookback || idx >= ArraySize(low) - lookback)
      return false;
   
   for(int i = 1; i <= lookback; i++)
   {
      if(low[idx] >= low[idx - i] || low[idx] >= low[idx + i])
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص مناسبة الإطار الزمني                                        |
//+------------------------------------------------------------------+
bool CChartPattern::IsTimeframeAppropriate(const ENUM_TIMEFRAMES tf, const int minBars)
{
   // يمكن تخصيص هذه الدالة حسب نوع النمط
   return true;
}

//+------------------------------------------------------------------+
//| حساب فترة البحث المثلى                                          |
//+------------------------------------------------------------------+
int CChartPattern::CalculateOptimalLookback(const ENUM_TIMEFRAMES tf)
{
   switch(tf)
   {
      case PERIOD_M1:
      case PERIOD_M5:  return 50;
      case PERIOD_M15:
      case PERIOD_M30: return 100;
      case PERIOD_H1:  return 150;
      case PERIOD_H4:  return 200;
      case PERIOD_D1:  return 250;
      default:         return 100;
   }
}

//+------------------------------------------------------------------+
//| التحقق من صحة أحجام المصفوفات                                   |
//+------------------------------------------------------------------+
bool CChartPattern::ValidateArraySizes(const double &open[], const double &high[], 
                                      const double &low[], const double &close[], 
                                      const long &volume[])
{
   int size = ArraySize(open);
   return (ArraySize(high) == size && 
           ArraySize(low) == size && 
           ArraySize(close) == size && 
           (ArraySize(volume) == size || ArraySize(volume) == 0));
}

//+------------------------------------------------------------------+
//| التحقق من صحة المؤشر                                            |
//+------------------------------------------------------------------+
bool CChartPattern::ValidateIndexRange(const int idx, const int arraySize)
{
   return (idx >= 0 && idx < arraySize);
}

//+------------------------------------------------------------------+
//| تحديث إحصائيات الكشف                                            |
//+------------------------------------------------------------------+
void CChartPattern::UpdateDetectionStats(const bool patternFound)
{
   if(patternFound)
   {
      m_detectedPatterns++;
      m_lastDetectionTime = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| تحديث إحصائيات النجاح                                           |
//+------------------------------------------------------------------+
void CChartPattern::UpdateSuccessStats(const bool patternSuccessful)
{
   if(patternSuccessful)
      m_successfulPatterns++;
}

//+------------------------------------------------------------------+
//| التحقق من صحة التهيئة                                           |
//+------------------------------------------------------------------+
bool CChartPattern::ValidateInitialization()
{
   return (m_initialized && 
           StringLen(m_symbol) > 0 && 
           IsValidTimeframe(m_timeframe));
}
