//+------------------------------------------------------------------+
//| PriceAction.mqh - مُصحح بالكامل |
//| حقوق النشر 2025, مكتبة أنماط المخططات |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط المخططات"
#property link "https://www.yourwebsite.com"
#property version "1.01"
#property strict

#include "ChartPattern.mqh"
#include "SupportResistance.mqh"
#include "TrendLineDetector.mqh"
#include "../../CandlePatterns/Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| تعدادات اتجاه الترند - لتجنب التضارب |
//+------------------------------------------------------------------+
enum ENUM_PA_TREND_DIRECTION
{
   PA_TREND_BULLISH,         // صاعد
   PA_TREND_BEARISH,         // هابط
   PA_TREND_SIDEWAYS         // جانبي
};

//+------------------------------------------------------------------+
//| تعدادات تحليل حركة السعر |
//+------------------------------------------------------------------+
enum ENUM_PRICE_ACTION_TYPE
{
   PA_BREAKOUT,           // اختراق
   PA_PULLBACK,           // ارتداد
   PA_REVERSAL,           // انعكاس
   PA_CONTINUATION,       // استمرار
   PA_CONSOLIDATION,      // توطيد
   PA_EXHAUSTION,         // استنزاف
   PA_MOMENTUM_SHIFT,     // تغيير في الزخم
   PA_VOLUME_CLIMAX       // ذروة حجم التداول
};

enum ENUM_PRICE_STRUCTURE
{
   PS_HIGHER_HIGHS,       // قمم أعلى
   PS_LOWER_LOWS,         // قيعان أدنى
   PS_EQUAL_HIGHS,        // قمم متساوية
   PS_EQUAL_LOWS,         // قيعان متساوية
   PS_DOUBLE_TOP,         // قمة مزدوجة
   PS_DOUBLE_BOTTOM,      // قاع مزدوج
   PS_TRIPLE_TOP,         // قمة ثلاثية
   PS_TRIPLE_BOTTOM       // قاع ثلاثي
};

enum ENUM_MOMENTUM_STATE
{
   MOMENTUM_ACCELERATING, // متسارع
   MOMENTUM_DECELERATING, // متباطئ
   MOMENTUM_SIDEWAYS,     // جانبي
   MOMENTUM_EXHAUSTED     // منهك
};

enum ENUM_VOLUME_ANALYSIS
{
   VOLUME_INCREASING,     // متزايد
   VOLUME_DECREASING,     // متناقص
   VOLUME_CLIMAX,         // ذروة
   VOLUME_DRY_UP,         // جفاف
   VOLUME_NORMAL          // طبيعي
};

//+------------------------------------------------------------------+
//| هيكل نقطة الرسم البياني - لتجنب التضارب |
//+------------------------------------------------------------------+
struct SPAChartPoint
{
   datetime                time;        // الوقت
   double                  price;       // السعر
   int                     barIndex;    // فهرس الشمعة
   bool                    isValid;     // صحة النقطة
   
   SPAChartPoint()
   {
      time = 0;
      price = 0.0;
      barIndex = -1;
      isValid = false;
   }
};

//+------------------------------------------------------------------+
//| هيكل تحليل حركة السعر |
//+------------------------------------------------------------------+
struct SPriceActionSignal
{
   // معلومات الإشارة
   long                    id;                  // معرف الإشارة
   string                  name;                // اسم الإشارة
   ENUM_PRICE_ACTION_TYPE  type;                // نوع حركة السعر
   ENUM_PATTERN_DIRECTION  direction;           // الاتجاه
   ENUM_PRICE_STRUCTURE    structure;           // هيكل السعر
   
   // معلومات الموقع
   SPAChartPoint           triggerPoint;        // نقطة التفعيل
   SPAChartPoint           confirmationPoint;   // نقطة التأكيد
   SPAChartPoint           entryPoint;          // نقطة الدخول
   SPAChartPoint           stopLossPoint;       // نقطة وقف الخسارة
   SPAChartPoint           takeProfitPoint;     // نقطة جني الأرباح
   
   // تحليل الزخم
   ENUM_MOMENTUM_STATE     momentumState;       // حالة الزخم
   double                  momentumStrength;    // قوة الزخم
   double                  velocityChange;      // تغيير السرعة
   
   // تحليل الحجم
   ENUM_VOLUME_ANALYSIS    volumeAnalysis;      // تحليل الحجم
   double                  volumeRatio;         // نسبة الحجم
   bool                    volumeConfirmation;  // تأكيد الحجم
   
   // الموثوقية والقوة
   double                  reliability;         // الموثوقية
   double                  strength;            // القوة
   double                  probability;         // الاحتمالية
   double                  riskReward;          // نسبة المخاطرة للعائد
   
   // معلومات زمنية
   datetime                signalTime;          // وقت الإشارة
   datetime                expirationTime;      // وقت انتهاء الصلاحية
   int                     timeframe;           // الإطار الزمني
   
   // السياق السوقي
   ENUM_PA_TREND_DIRECTION overallTrend;        // الاتجاه العام
   double                  trendStrength;       // قوة الاتجاه
   bool                    nearSupportResistance; // قرب الدعم/المقاومة
   
   SPriceActionSignal()
   {
      id = 0;
      name = "";
      type = PA_BREAKOUT;
      direction = PATTERN_NEUTRAL;
      structure = PS_HIGHER_HIGHS;
      momentumState = MOMENTUM_SIDEWAYS;
      momentumStrength = 0.0;
      velocityChange = 0.0;
      volumeAnalysis = VOLUME_NORMAL;
      volumeRatio = 1.0;
      volumeConfirmation = false;
      reliability = 0.0;
      strength = 0.0;
      probability = 0.0;
      riskReward = 0.0;
      signalTime = 0;
      expirationTime = 0;
      timeframe = PERIOD_CURRENT;
      overallTrend = PA_TREND_SIDEWAYS;
      trendStrength = 0.0;
      nearSupportResistance = false;
   }
};

//+------------------------------------------------------------------+
//| فئة كاشف الاتجاه البسيط - لتجنب التضارب |
//+------------------------------------------------------------------+
class CPATrendDetector
{
public:
   CPATrendDetector() {}
   ~CPATrendDetector() {}
   
   ENUM_PA_TREND_DIRECTION DetectTrend(const double &close[], int rates_total, int period = 20);
};

//+------------------------------------------------------------------+
//| تنفيذ كاشف الاتجاه |
//+------------------------------------------------------------------+
ENUM_PA_TREND_DIRECTION CPATrendDetector::DetectTrend(const double &close[], int rates_total, int period = 20)
{
   if(rates_total < period + 1)
      return PA_TREND_SIDEWAYS;
   
   double currentPrice = close[rates_total - 1];
   double pastPrice = close[rates_total - 1 - period];
   double threshold = 0.01; // 1% threshold
   
   double change = (currentPrice - pastPrice) / pastPrice;
   
   if(change > threshold)
      return PA_TREND_BULLISH;
   else if(change < -threshold)
      return PA_TREND_BEARISH;
   else
      return PA_TREND_SIDEWAYS;
}

//+------------------------------------------------------------------+
//| فئة تحليل حركة السعر - مُصححة |
//+------------------------------------------------------------------+
class CPriceActionAnalyzer
{
private:
   // إشارات حركة السعر
   SPriceActionSignal      m_signals[];         // مصفوفة الإشارات
   int                     m_signalCount;       // عدد الإشارات
   
   // أدوات التحليل
   CSupportResistanceDetector* m_srDetector;   // كاشف الدعم والمقاومة
   CTrendLineDetector*     m_trendDetector;     // كاشف خطوط الاتجاه
   CPATrendDetector*       m_trendAnalyzer;     // محلل الاتجاه
   
   // إعدادات التحليل
   int                     m_lookbackPeriod;    // فترة البحث للخلف
   int                     m_momentumPeriod;    // فترة حساب الزخم
   double                  m_breakoutThreshold; // عتبة الاختراق
   double                  m_volumeThreshold;   // عتبة الحجم
   bool                    m_useVolumeAnalysis; // استخدام تحليل الحجم
   
   // إعدادات الهيكل السعري
   int                     m_swingDetectionPeriod; // فترة كشف التأرجح
   double                  m_equalLevelTolerance;  // تسامح المستويات المتساوية
   
   // مؤشرات تقنية
   double                  m_rsi[];             // مؤشر RSI
   double                  m_momentum[];        // مؤشر الزخم
   double                  m_volumeSMA[];       // متوسط متحرك للحجم

public:
   CPriceActionAnalyzer();
   ~CPriceActionAnalyzer();
   
   // التحليل الرئيسي
   int AnalyzePriceAction(const string symbol, ENUM_TIMEFRAMES timeframe,
                         const double &high[], const double &low[], 
                         const double &close[], const double &open[],
                         const long &volume[], const datetime &time[],
                         int rates_total);
   
   // تحليل أنواع حركة السعر
   bool DetectBreakout(const double &high[], const double &low[], 
                      const double &close[], const long &volume[],
                      const datetime &time[], int rates_total,
                      SPriceActionSignal &signal);
   
   bool DetectPullback(const double &high[], const double &low[], 
                      const double &close[], const datetime &time[],
                      int rates_total, SPriceActionSignal &signal);
   
   bool DetectReversal(const double &high[], const double &low[], 
                      const double &close[], const double &open[],
                      const long &volume[], const datetime &time[],
                      int rates_total, SPriceActionSignal &signal);
   
   bool DetectConsolidation(const double &high[], const double &low[], 
                           const double &close[], const datetime &time[],
                           int rates_total, SPriceActionSignal &signal);
   
   // تحليل هيكل السعر
   ENUM_PRICE_STRUCTURE AnalyzePriceStructure(const double &high[], const double &low[],
                                             int start, int end);
   
   bool FindSwingPoints(const double &high[], const double &low[],
                       int start, int end, SPAChartPoint &swings[]);
   
   // تحليل الزخم
   ENUM_MOMENTUM_STATE AnalyzeMomentum(const double &close[], int rates_total, int period = 14);
   double CalculateMomentumStrength(const double &close[], int rates_total, int period = 14);
   double CalculateVelocityChange(const double &close[], int rates_total, int period = 5);
   
   // تحليل الحجم
   ENUM_VOLUME_ANALYSIS AnalyzeVolume(const long &volume[], int rates_total, int period = 20);
   double CalculateVolumeRatio(const long &volume[], int rates_total, int period = 20);
   bool IsVolumeClimax(const long &volume[], int rates_total, int period = 20);
   
   // تحليل السياق
   bool IsNearSupportResistance(double price, SSupportResistanceLevel &levels[], int levelCount);
   double CalculateDistanceToSR(double price, SSupportResistanceLevel &levels[], int levelCount);
   
   // حساب الموثوقية والاحتمالية
   double CalculateSignalReliability(const SPriceActionSignal &signal);
   double CalculateSignalProbability(const SPriceActionSignal &signal,
                                    const double &high[], const double &low[],
                                    const double &close[], int rates_total);
   
   // إدارة المخاطر
   void CalculateRiskReward(SPriceActionSignal &signal, 
                           const SSupportResistanceLevel &nearestSR);
   
   SPAChartPoint CalculateStopLoss(const SPriceActionSignal &signal,
                                  const double &high[], const double &low[],
                                  int rates_total);
   
   SPAChartPoint CalculateTakeProfit(const SPriceActionSignal &signal,
                                    const SSupportResistanceLevel &targetLevel);
   
   // الوصول للإشارات
   int GetSignalCount() const { return m_signalCount; }
   SPriceActionSignal GetSignal(int index) const;
   void GetActiveSignals(SPriceActionSignal &signals[], int &count, ENUM_PRICE_ACTION_TYPE type = (ENUM_PRICE_ACTION_TYPE)-1);
   void GetSignalsByDirection(SPriceActionSignal &signals[], int &count, ENUM_PATTERN_DIRECTION direction);
   
   // تحديث التحليل
   void UpdateAnalysis(const double &high[], const double &low[], 
                      const double &close[], const double &open[],
                      const long &volume[], const datetime &time[],
                      int currentBar);
   
   // رسم الإشارات
   void DrawSignal(const string symbol, const SPriceActionSignal &signal);
   void DrawAllSignals(const string symbol);
   
   // إعدادات المحلل
   void SetLookbackPeriod(int period) { m_lookbackPeriod = MathMax(20, period); }
   void SetMomentumPeriod(int period) { m_momentumPeriod = MathMax(5, period); }
   void SetBreakoutThreshold(double threshold) { m_breakoutThreshold = MathMax(0.001, threshold); }
   void SetVolumeThreshold(double threshold) { m_volumeThreshold = MathMax(1.0, threshold); }
   void SetUseVolumeAnalysis(bool use) { m_useVolumeAnalysis = use; }
   
   // تكامل مع أدوات أخرى
   void SetSRDetector(CSupportResistanceDetector* detector) { m_srDetector = detector; }
   void SetTrendDetector(CTrendLineDetector* detector) { m_trendDetector = detector; }
   
   // مسح الإشارات
   void ClearSignals();
   void RemoveExpiredSignals();

private:
   // دوال مساعدة
   SPriceActionSignal CreateSignal(ENUM_PRICE_ACTION_TYPE type, 
                                  ENUM_PATTERN_DIRECTION direction,
                                  const SPAChartPoint &triggerPoint);
   
   bool ValidateSignal(const SPriceActionSignal &signal,
                      const double &high[], const double &low[],
                      const double &close[], int rates_total);
   
   void CalculateIndicators(const double &close[], const long &volume[],
                           int rates_total);
   
   bool IsSignificantMove(const double &close[], int start, int end, double threshold);
   bool IsFalseBreakout(const double &high[], const double &low[], 
                       const double &close[], int breakoutBar, 
                       double breakoutLevel, bool isUpward);
   
   double CalculateAverageRange(const double &high[], const double &low[], 
                               int period, int rates_total);
   
   long GenerateUniqueId();
   datetime CalculateSignalExpiration(const SPriceActionSignal &signal);
   
   // تحليل أنماط الشموع - مُصحح
   bool IsHammer(const double &open[], const double &high[], 
                const double &low[], const double &close[], int index);
   
   bool IsDoji(const double &open[], const double &high[], 
              const double &low[], const double &close[], int index);
   
   bool IsEngulfing(const double &open[], const double &high[], 
                   const double &low[], const double &close[], int index);
};

//+------------------------------------------------------------------+
//| المنشئ |
//+------------------------------------------------------------------+
CPriceActionAnalyzer::CPriceActionAnalyzer()
{
   m_signalCount = 0;
   m_lookbackPeriod = 100;
   m_momentumPeriod = 14;
   m_breakoutThreshold = 0.02; // 2%
   m_volumeThreshold = 1.5;    // 150% من المتوسط
   m_useVolumeAnalysis = true;
   m_swingDetectionPeriod = 5;
   m_equalLevelTolerance = 0.01; // 1%
   
   m_srDetector = NULL;
   m_trendDetector = NULL;
   m_trendAnalyzer = new CPATrendDetector();
   
   ArrayResize(m_signals, 0);
   ArrayResize(m_rsi, 0);
   ArrayResize(m_momentum, 0);
   ArrayResize(m_volumeSMA, 0);
}

//+------------------------------------------------------------------+
//| الهادم |
//+------------------------------------------------------------------+
CPriceActionAnalyzer::~CPriceActionAnalyzer()
{
   ClearSignals();
   if(m_trendAnalyzer != NULL)
   {
      delete m_trendAnalyzer;
      m_trendAnalyzer = NULL;
   }
}

//+------------------------------------------------------------------+
//| التحليل الرئيسي لحركة السعر - مُصحح |
//+------------------------------------------------------------------+
int CPriceActionAnalyzer::AnalyzePriceAction(const string symbol, ENUM_TIMEFRAMES timeframe,
                                           const double &high[], const double &low[], 
                                           const double &close[], const double &open[],
                                           const long &volume[], const datetime &time[],
                                           int rates_total)
{
   if(rates_total < m_lookbackPeriod)
      return 0;
   
   ClearSignals();
   
   // حساب المؤشرات التقنية
   CalculateIndicators(close, volume, rates_total);
   
   int signalsFound = 0;
   SPriceActionSignal signal;
   
   // كشف الاختراقات
   if(DetectBreakout(high, low, close, volume, time, rates_total, signal))
   {
      ArrayResize(m_signals, m_signalCount + 1);
      m_signals[m_signalCount] = signal;
      m_signalCount++;
      signalsFound++;
   }
   
   // كشف الارتدادات
   if(DetectPullback(high, low, close, time, rates_total, signal))
   {
      ArrayResize(m_signals, m_signalCount + 1);
      m_signals[m_signalCount] = signal;
      m_signalCount++;
      signalsFound++;
   }
   
   // كشف الانعكاسات
   if(DetectReversal(high, low, close, open, volume, time, rates_total, signal))
   {
      ArrayResize(m_signals, m_signalCount + 1);
      m_signals[m_signalCount] = signal;
      m_signalCount++;
      signalsFound++;
   }
   
   // كشف التوطيدات
   if(DetectConsolidation(high, low, close, time, rates_total, signal))
   {
      ArrayResize(m_signals, m_signalCount + 1);
      m_signals[m_signalCount] = signal;
      m_signalCount++;
      signalsFound++;
   }
   
   return signalsFound;
}

//+------------------------------------------------------------------+
//| كشف الاختراقات - مُصحح |
//+------------------------------------------------------------------+
bool CPriceActionAnalyzer::DetectBreakout(const double &high[], const double &low[], 
                                         const double &close[], const long &volume[],
                                         const datetime &time[], int rates_total,
                                         SPriceActionSignal &signal)
{
   if(rates_total < 10)
      return false;
   
   // البحث عن اختراق بسيط بناءً على الأسعار
   double currentPrice = close[rates_total - 1];
   double prevPrice = close[rates_total - 2];
   double breakoutThreshold = m_breakoutThreshold;
   
   // تحقق من اختراق بسيط
   if(MathAbs(currentPrice - prevPrice) / prevPrice > breakoutThreshold)
   {
      ENUM_PATTERN_DIRECTION dir = (currentPrice > prevPrice) ? PATTERN_BULLISH : PATTERN_BEARISH;
      
      SPAChartPoint triggerPoint;
      triggerPoint.time = time[rates_total - 1];
      triggerPoint.price = currentPrice;
      triggerPoint.barIndex = rates_total - 1;
      triggerPoint.isValid = true;
      
      signal = CreateSignal(PA_BREAKOUT, dir, triggerPoint);
      
      signal.confirmationPoint.price = currentPrice;
      signal.confirmationPoint.time = time[rates_total - 1];
      signal.confirmationPoint.barIndex = rates_total - 1;
      signal.confirmationPoint.isValid = true;
      
      // تحليل الحجم
      if(m_useVolumeAnalysis && ArraySize(volume) > 0)
      {
         signal.volumeAnalysis = AnalyzeVolume(volume, rates_total);
         signal.volumeRatio = CalculateVolumeRatio(volume, rates_total);
         signal.volumeConfirmation = (signal.volumeRatio > m_volumeThreshold);
      }
      
      // حساب الموثوقية
      signal.reliability = CalculateSignalReliability(signal);
      signal.probability = CalculateSignalProbability(signal, high, low, close, rates_total);
      
      return ValidateSignal(signal, high, low, close, rates_total);
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف الارتدادات - مُصحح |
//+------------------------------------------------------------------+
bool CPriceActionAnalyzer::DetectPullback(const double &high[], const double &low[], 
                                         const double &close[], const datetime &time[],
                                         int rates_total, SPriceActionSignal &signal)
{
   if(rates_total < m_lookbackPeriod || m_trendAnalyzer == NULL)
      return false;
   
   // تحديد الاتجاه العام
   ENUM_PA_TREND_DIRECTION trend = m_trendAnalyzer.DetectTrend(close, rates_total, m_lookbackPeriod / 2);
   
   if(trend == PA_TREND_SIDEWAYS)
      return false;
   
   // البحث عن ارتداد مؤقت ضد الاتجاه
   int pullbackStart = -1;
   
   // في الاتجاه الصاعد - البحث عن انخفاض مؤقت
   if(trend == PA_TREND_BULLISH)
   {
      for(int i = rates_total - 10; i < rates_total - 1; i++)
      {
         if(close[i] > close[i + 1] && close[i + 1] > close[i + 2])
         {
            pullbackStart = i;
            break;
         }
      }
      
      // التحقق من الارتداد للأعلى
      if(pullbackStart > 0 && close[rates_total - 1] > close[pullbackStart])
      {
         SPAChartPoint triggerPoint;
         triggerPoint.time = time[pullbackStart];
         triggerPoint.price = close[pullbackStart];
         triggerPoint.barIndex = pullbackStart;
         triggerPoint.isValid = true;
         
         signal = CreateSignal(PA_PULLBACK, PATTERN_BULLISH, triggerPoint);
         signal.overallTrend = trend;
         signal.reliability = 0.7; // ارتداد في اتجاه الترند له موثوقية جيدة
         
         return true;
      }
   }
   // في الاتجاه الهابط - البحث عن ارتفاع مؤقت
   else if(trend == PA_TREND_BEARISH)
   {
      for(int i = rates_total - 10; i < rates_total - 1; i++)
      {
         if(close[i] < close[i + 1] && close[i + 1] < close[i + 2])
         {
            pullbackStart = i;
            break;
         }
      }
      
      // التحقق من الارتداد للأسفل
      if(pullbackStart > 0 && close[rates_total - 1] < close[pullbackStart])
      {
         SPAChartPoint triggerPoint;
         triggerPoint.time = time[pullbackStart];
         triggerPoint.price = close[pullbackStart];
         triggerPoint.barIndex = pullbackStart;
         triggerPoint.isValid = true;
         
         signal = CreateSignal(PA_PULLBACK, PATTERN_BEARISH, triggerPoint);
         signal.overallTrend = trend;
         signal.reliability = 0.7;
         
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف الانعكاسات - مُصحح |
//+------------------------------------------------------------------+
bool CPriceActionAnalyzer::DetectReversal(const double &high[], const double &low[], 
                                         const double &close[], const double &open[],
                                         const long &volume[], const datetime &time[],
                                         int rates_total, SPriceActionSignal &signal)
{
   if(rates_total < m_momentumPeriod + 5)
      return false;
   
   // تحليل الزخم للبحث عن تباطؤ
   ENUM_MOMENTUM_STATE momentumState = AnalyzeMomentum(close, rates_total);
   
   if(momentumState != MOMENTUM_EXHAUSTED && momentumState != MOMENTUM_DECELERATING)
      return false;
   
   // البحث عن أنماط انعكاسية في الشموع
   int currentBar = rates_total - 1;
   
   // نمط الهامر في القاع
   if(IsHammer(open, high, low, close, currentBar) && 
      close[currentBar] < close[currentBar - 5]) // في منطقة انخفاض
   {
      SPAChartPoint triggerPoint;
      triggerPoint.time = time[currentBar];
      triggerPoint.price = close[currentBar];
      triggerPoint.barIndex = currentBar;
      triggerPoint.isValid = true;
      
      signal = CreateSignal(PA_REVERSAL, PATTERN_BULLISH, triggerPoint);
      signal.momentumState = momentumState;
      signal.structure = PS_DOUBLE_BOTTOM; // افتراض قاع مزدوج
      
      return true;
   }
   
   // نمط الدوجي كإشارة تردد
   if(IsDoji(open, high, low, close, currentBar))
   {
      ENUM_PATTERN_DIRECTION dir = (close[currentBar - 1] > close[currentBar - 5]) ? 
                                  PATTERN_BEARISH : PATTERN_BULLISH;
      
      SPAChartPoint triggerPoint;
      triggerPoint.time = time[currentBar];
      triggerPoint.price = close[currentBar];
      triggerPoint.barIndex = currentBar;
      triggerPoint.isValid = true;
      
      signal = CreateSignal(PA_REVERSAL, dir, triggerPoint);
      signal.momentumState = momentumState;
      signal.reliability = 0.6; // موثوقية متوسطة للدوجي
      
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف التوطيدات - مُصحح |
//+------------------------------------------------------------------+
bool CPriceActionAnalyzer::DetectConsolidation(const double &high[], const double &low[], 
                                              const double &close[], const datetime &time[],
                                              int rates_total, SPriceActionSignal &signal)
{
   if(rates_total < 20)
      return false;
   
   // حساب المدى السعري للشموع الأخيرة
   double totalRange = 0.0;
   double averageRange = 0.0;
   int period = 15;
   
   for(int i = rates_total - period; i < rates_total; i++)
   {
      totalRange += (high[i] - low[i]);
   }
   
   averageRange = totalRange / period;
   
   // حساب المدى السعري الإجمالي للفترة
   double maxHigh = high[ArrayMaximum(high, rates_total - period, period)];
   double minLow = low[ArrayMinimum(low, rates_total - period, period)];
   double overallRange = maxHigh - minLow;
   
   // إذا كان المدى الإجمالي صغير مقارنة بمتوسط مديات الشموع
   if(overallRange < averageRange * period * 0.6)
   {
      SPAChartPoint triggerPoint;
      triggerPoint.time = time[rates_total - period];
      triggerPoint.price = (maxHigh + minLow) / 2.0;
      triggerPoint.barIndex = rates_total - period;
      triggerPoint.isValid = true;
      
      signal = CreateSignal(PA_CONSOLIDATION, PATTERN_NEUTRAL, triggerPoint);
      signal.structure = PS_EQUAL_HIGHS; // توطيد أفقي
      signal.reliability = 0.8; // التوطيد له موثوقية عالية
      
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| إنشاء إشارة جديدة - مُصحح |
//+------------------------------------------------------------------+
SPriceActionSignal CPriceActionAnalyzer::CreateSignal(ENUM_PRICE_ACTION_TYPE type, 
                                                     ENUM_PATTERN_DIRECTION direction,
                                                     const SPAChartPoint &triggerPoint)
{
   SPriceActionSignal signal;
   
   signal.id = GenerateUniqueId();
   signal.name = EnumToString(type) + "_" + IntegerToString((int)signal.id);
   signal.type = type;
   signal.direction = direction;
   signal.triggerPoint = triggerPoint;
   signal.signalTime = TimeCurrent();
   signal.expirationTime = CalculateSignalExpiration(signal);
   signal.timeframe = Period();
   
   return signal;
}

//+------------------------------------------------------------------+
//| تحليل الزخم - مُصحح |
//+------------------------------------------------------------------+
ENUM_MOMENTUM_STATE CPriceActionAnalyzer::AnalyzeMomentum(const double &close[], int rates_total, int period)
{
   if(rates_total < period + 5)
      return MOMENTUM_SIDEWAYS;
   
   // حساب RSI
   double rsi = 0.0;
   if(ArraySize(m_rsi) > rates_total - 1)
      rsi = m_rsi[rates_total - 1];
   
   // حساب الزخم
   double momentum = close[rates_total - 1] - close[rates_total - 1 - period];
   double prevMomentum = close[rates_total - 2] - close[rates_total - 2 - period];
   
   // تحليل حالة الزخم
   if(MathAbs(momentum) > MathAbs(prevMomentum))
   {
      return MOMENTUM_ACCELERATING;
   }
   else if(MathAbs(momentum) < MathAbs(prevMomentum) * 0.5)
   {
      return MOMENTUM_DECELERATING;
   }
   else if(rsi > 80 || rsi < 20)
   {
      return MOMENTUM_EXHAUSTED;
   }
   
   return MOMENTUM_SIDEWAYS;
}

//+------------------------------------------------------------------+
//| تحليل الحجم - مُصحح |
//+------------------------------------------------------------------+
ENUM_VOLUME_ANALYSIS CPriceActionAnalyzer::AnalyzeVolume(const long &volume[], int rates_total, int period)
{
   if(ArraySize(volume) == 0 || rates_total < period)
      return VOLUME_NORMAL;
   
   long currentVolume = volume[rates_total - 1];
   double averageVolume = 0.0;
   
   // حساب متوسط الحجم
   for(int i = rates_total - period; i < rates_total - 1; i++)
   {
      averageVolume += (double)volume[i];
   }
   averageVolume /= (period - 1);
   
   double volumeRatio = (double)currentVolume / averageVolume;
   
   if(volumeRatio > 2.0)
      return VOLUME_CLIMAX;
   else if(volumeRatio > 1.5)
      return VOLUME_INCREASING;
   else if(volumeRatio < 0.5)
      return VOLUME_DRY_UP;
   else if(volumeRatio < 0.8)
      return VOLUME_DECREASING;
   
   return VOLUME_NORMAL;
}

//+------------------------------------------------------------------+
//| حساب المؤشرات التقنية - مُصحح |
//+------------------------------------------------------------------+
void CPriceActionAnalyzer::CalculateIndicators(const double &close[], const long &volume[],
                                              int rates_total)
{
   if(rates_total < m_momentumPeriod)
      return;
   
   // تحضير المصفوفات
   ArrayResize(m_rsi, rates_total);
   ArrayResize(m_momentum, rates_total);
   
   if(ArraySize(volume) > 0)
      ArrayResize(m_volumeSMA, rates_total);
   
   // حساب RSI (مبسط)
   for(int i = m_momentumPeriod; i < rates_total; i++)
   {
      double gains = 0.0, losses = 0.0;
      
      for(int j = i - m_momentumPeriod + 1; j <= i; j++)
      {
         double change = close[j] - close[j - 1];
         if(change > 0)
            gains += change;
         else
            losses += MathAbs(change);
      }
      
      double rs = (losses > 0) ? gains / losses : 100.0;
      m_rsi[i] = 100.0 - (100.0 / (1.0 + rs));
   }
   
   // حساب الزخم
   for(int i = m_momentumPeriod; i < rates_total; i++)
   {
      m_momentum[i] = close[i] - close[i - m_momentumPeriod];
   }
}

//+------------------------------------------------------------------+
//| كشف نمط الهامر - مُصحح |
//+------------------------------------------------------------------+
bool CPriceActionAnalyzer::IsHammer(const double &open[], const double &high[], 
                                   const double &low[], const double &close[], int index)
{
   if(index < 0 || index >= ArraySize(close) || index >= ArraySize(high) || index >= ArraySize(low))
      return false;
   
   double openPrice = 0.0;
   if(ArraySize(open) > 0 && ArraySize(open) > index)
      openPrice = open[index];
   else if(index > 0)
      openPrice = close[index - 1];
   else
      openPrice = close[index];
      
   double bodySize = MathAbs(close[index] - openPrice);
   double lowerShadow = MathMin(openPrice, close[index]) - low[index];
   double upperShadow = high[index] - MathMax(openPrice, close[index]);
   double totalRange = high[index] - low[index];
   
   // شروط الهامر: ظل سفلي طويل، جسم صغير، ظل علوي صغير
   return (lowerShadow > bodySize * 2.0 && 
           upperShadow < bodySize * 0.5 && 
           bodySize < totalRange * 0.3 &&
           totalRange > 0);
}

//+------------------------------------------------------------------+
//| كشف نمط الدوجي - مُصحح |
//+------------------------------------------------------------------+
bool CPriceActionAnalyzer::IsDoji(const double &open[], const double &high[], 
                                 const double &low[], const double &close[], int index)
{
   if(index < 0 || index >= ArraySize(close) || index >= ArraySize(high) || index >= ArraySize(low))
      return false;
   
   double openPrice = 0.0;
   if(ArraySize(open) > 0 && ArraySize(open) > index)
      openPrice = open[index];
   else if(index > 0)
      openPrice = close[index - 1];
   else
      openPrice = close[index];
      
   double bodySize = MathAbs(close[index] - openPrice);
   double totalRange = high[index] - low[index];
   
   // شروط الدوجي: جسم صغير جداً
   return (bodySize < totalRange * 0.1 && totalRange > 0);
}

//+------------------------------------------------------------------+
//| الدوال المساعدة المتبقية - مُصححة |
//+------------------------------------------------------------------+
double CPriceActionAnalyzer::CalculateVolumeRatio(const long &volume[], int rates_total, int period)
{
   if(ArraySize(volume) == 0 || rates_total < period)
      return 1.0;
   
   long currentVolume = volume[rates_total - 1];
   double averageVolume = 0.0;
   
   for(int i = rates_total - period; i < rates_total - 1; i++)
   {
      averageVolume += (double)volume[i];
   }
   averageVolume /= (period - 1);
   
   return (averageVolume > 0) ? (double)currentVolume / averageVolume : 1.0;
}

double CPriceActionAnalyzer::CalculateSignalReliability(const SPriceActionSignal &signal)
{
   double reliability = 0.5; // قيمة أساسية
   
   // تعديل حسب نوع الإشارة
   switch(signal.type)
   {
      case PA_BREAKOUT:
         reliability += (signal.volumeConfirmation ? 0.2 : 0.0);
         break;
      case PA_PULLBACK:
         reliability += (signal.overallTrend != PA_TREND_SIDEWAYS ? 0.2 : 0.0);
         break;
      case PA_REVERSAL:
         reliability += (signal.momentumState == MOMENTUM_EXHAUSTED ? 0.2 : 0.0);
         break;
      case PA_CONSOLIDATION:
         reliability += 0.3; // التوطيد عادة موثوق
         break;
   }
   
   // تعديل حسب السياق
   if(signal.nearSupportResistance)
      reliability += 0.1;
   
   return MathMin(reliability, 1.0);
}

double CPriceActionAnalyzer::CalculateSignalProbability(const SPriceActionSignal &signal,
                                                       const double &high[], const double &low[],
                                                       const double &close[], int rates_total)
{
   // حساب بسيط للاحتمالية بناء على الموثوقية
   return MathMin(signal.reliability * 1.2, 1.0);
}

SPriceActionSignal CPriceActionAnalyzer::GetSignal(int index) const
{
   if(index >= 0 && index < m_signalCount)
      return m_signals[index];
   
   SPriceActionSignal emptySignal;
   return emptySignal;
}

long CPriceActionAnalyzer::GenerateUniqueId()
{
   return (long)GetTickCount64();
}

datetime CPriceActionAnalyzer::CalculateSignalExpiration(const SPriceActionSignal &signal)
{
   int periodSeconds = PeriodSeconds();
   int barsToExpire = 10; // افتراضي 10 شموع
   
   switch(signal.type)
   {
      case PA_BREAKOUT: barsToExpire = 5; break;
      case PA_PULLBACK: barsToExpire = 8; break;
      case PA_REVERSAL: barsToExpire = 15; break;
      case PA_CONSOLIDATION: barsToExpire = 20; break;
   }
   
   return signal.signalTime + (barsToExpire * periodSeconds);
}

void CPriceActionAnalyzer::ClearSignals()
{
   ArrayResize(m_signals, 0);
   m_signalCount = 0;
}

bool CPriceActionAnalyzer::ValidateSignal(const SPriceActionSignal &signal,
                                         const double &high[], const double &low[],
                                         const double &close[], int rates_total)
{
   // التحقق من القيم الأساسية
   if(signal.reliability < 0.3)
      return false;
   
   if(signal.triggerPoint.barIndex < 0 || signal.triggerPoint.barIndex >= rates_total)
      return false;
   
   // تحققات إضافية حسب نوع الإشارة
   switch(signal.type)
   {
      case PA_BREAKOUT:
         return signal.volumeConfirmation || signal.reliability > 0.6;
         
      case PA_PULLBACK:
         return signal.overallTrend != PA_TREND_SIDEWAYS;
         
      case PA_REVERSAL:
         return signal.momentumState == MOMENTUM_EXHAUSTED || 
                signal.momentumState == MOMENTUM_DECELERATING;
         
      default:
         return true;
   }
}

//+------------------------------------------------------------------+
//| باقي الدوال المُصححة |
//+------------------------------------------------------------------+
double CPriceActionAnalyzer::CalculateMomentumStrength(const double &close[], int rates_total, int period)
{
   if(rates_total < period + 1)
      return 0.0;
   
   double momentum = close[rates_total - 1] - close[rates_total - 1 - period];
   double averagePrice = 0.0;
   
   for(int i = rates_total - period; i < rates_total; i++)
   {
      averagePrice += close[i];
   }
   averagePrice /= period;
   
   return (averagePrice > 0) ? MathAbs(momentum) / averagePrice : 0.0;
}

double CPriceActionAnalyzer::CalculateVelocityChange(const double &close[], int rates_total, int period)
{
   if(rates_total < period * 2)
      return 0.0;
   
   double currentVelocity = close[rates_total - 1] - close[rates_total - 1 - period];
   double previousVelocity = close[rates_total - 1 - period] - close[rates_total - 1 - period * 2];
   
   return currentVelocity - previousVelocity;
}

bool CPriceActionAnalyzer::IsVolumeClimax(const long &volume[], int rates_total, int period)
{
   if(ArraySize(volume) == 0 || rates_total < period)
      return false;
   
   double volumeRatio = CalculateVolumeRatio(volume, rates_total, period);
   return volumeRatio > 2.0;
}

void CPriceActionAnalyzer::GetActiveSignals(SPriceActionSignal &signals[], int &count, ENUM_PRICE_ACTION_TYPE type)
{
   count = 0;
   datetime currentTime = TimeCurrent();
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].expirationTime > currentTime)
      {
         if(type == (ENUM_PRICE_ACTION_TYPE)-1 || m_signals[i].type == type)
         {
            ArrayResize(signals, count + 1);
            signals[count] = m_signals[i];
            count++;
         }
      }
   }
}

void CPriceActionAnalyzer::GetSignalsByDirection(SPriceActionSignal &signals[], int &count, ENUM_PATTERN_DIRECTION direction)
{
   count = 0;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].direction == direction)
      {
         ArrayResize(signals, count + 1);
         signals[count] = m_signals[i];
         count++;
      }
   }
}

void CPriceActionAnalyzer::UpdateAnalysis(const double &high[], const double &low[], 
                                         const double &close[], const double &open[],
                                         const long &volume[], const datetime &time[],
                                         int currentBar)
{
   // تحديث بسيط - إعادة حساب آخر شمعة
   RemoveExpiredSignals();
}

void CPriceActionAnalyzer::DrawSignal(const string symbol, const SPriceActionSignal &signal)
{
   // رسم الإشارة على الرسم البياني
   // يمكن تنفيذ هذا باستخدام ObjectCreate في MQL5
}

void CPriceActionAnalyzer::DrawAllSignals(const string symbol)
{
   for(int i = 0; i < m_signalCount; i++)
   {
      DrawSignal(symbol, m_signals[i]);
   }
}

void CPriceActionAnalyzer::RemoveExpiredSignals()
{
   datetime currentTime = TimeCurrent();
   int validCount = 0;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].expirationTime > currentTime)
      {
         if(validCount != i)
            m_signals[validCount] = m_signals[i];
         validCount++;
      }
   }
   
   m_signalCount = validCount;
   ArrayResize(m_signals, m_signalCount);
}

// دوال إضافية للتوافق
ENUM_PRICE_STRUCTURE CPriceActionAnalyzer::AnalyzePriceStructure(const double &high[], const double &low[],
                                                                int start, int end)
{
   // تحليل بسيط للهيكل السعري
   return PS_HIGHER_HIGHS;
}

bool CPriceActionAnalyzer::FindSwingPoints(const double &high[], const double &low[],
                                          int start, int end, SPAChartPoint &swings[])
{
   // البحث عن نقاط التأرجح
   return false;
}

bool CPriceActionAnalyzer::IsNearSupportResistance(double price, SSupportResistanceLevel &levels[], int levelCount)
{
   // التحقق من قرب مستويات الدعم والمقاومة
   return false;
}

double CPriceActionAnalyzer::CalculateDistanceToSR(double price, SSupportResistanceLevel &levels[], int levelCount)
{
   // حساب المسافة إلى أقرب مستوى دعم/مقاومة
   return 0.0;
}

void CPriceActionAnalyzer::CalculateRiskReward(SPriceActionSignal &signal, const SSupportResistanceLevel &nearestSR)
{
   // حساب نسبة المخاطرة للعائد
   signal.riskReward = 2.0; // افتراضي
}

SPAChartPoint CPriceActionAnalyzer::CalculateStopLoss(const SPriceActionSignal &signal,
                                                     const double &high[], const double &low[],
                                                     int rates_total)
{
   SPAChartPoint stopLoss;
   // حساب وقف الخسارة
   return stopLoss;
}

SPAChartPoint CPriceActionAnalyzer::CalculateTakeProfit(const SPriceActionSignal &signal,
                                                       const SSupportResistanceLevel &targetLevel)
{
   SPAChartPoint takeProfit;
   // حساب جني الأرباح
   return takeProfit;
}

bool CPriceActionAnalyzer::IsSignificantMove(const double &close[], int start, int end, double threshold)
{
   if(start >= end || end >= ArraySize(close))
      return false;
   
   double change = MathAbs(close[end] - close[start]) / close[start];
   return change > threshold;
}

bool CPriceActionAnalyzer::IsFalseBreakout(const double &high[], const double &low[], 
                                          const double &close[], int breakoutBar, 
                                          double breakoutLevel, bool isUpward)
{
   if(breakoutBar < 3)
      return false;
   
   // التحقق من عودة السعر خلال 3 شموع
   for(int i = breakoutBar + 1; i < MathMin(breakoutBar + 4, ArraySize(close)); i++)
   {
      if(isUpward && close[i] < breakoutLevel)
         return true; // عاد تحت مستوى الاختراق
      else if(!isUpward && close[i] > breakoutLevel)
         return true; // عاد فوق مستوى الاختراق
   }
   
   return false;
}

double CPriceActionAnalyzer::CalculateAverageRange(const double &high[], const double &low[], 
                                                  int period, int rates_total)
{
   if(rates_total < period)
      return 0.0;
   
   double totalRange = 0.0;
   for(int i = rates_total - period; i < rates_total; i++)
   {
      totalRange += (high[i] - low[i]);
   }
   
   return totalRange / period;
}

bool CPriceActionAnalyzer::IsEngulfing(const double &open[], const double &high[], 
                                      const double &low[], const double &close[], int index)
{
   if(index < 1 || ArraySize(open) == 0 || ArraySize(open) <= index || ArraySize(close) <= index)
      return false;
   
   // نمط الابتلاع الصاعد
   bool bullishEngulfing = (close[index - 1] < open[index - 1]) && // شمعة هابطة سابقة
                          (close[index] > open[index]) &&       // شمعة صاعدة حالية
                          (open[index] < close[index - 1]) &&   // فتح أقل من إغلاق السابقة
                          (close[index] > open[index - 1]);     // إغلاق أعلى من فتح السابقة
   
   // نمط الابتلاع الهابط
   bool bearishEngulfing = (close[index - 1] > open[index - 1]) && // شمعة صاعدة سابقة
                          (close[index] < open[index]) &&        // شمعة هابطة حالية
                          (open[index] > close[index - 1]) &&    // فتح أعلى من إغلاق السابقة
                          (close[index] < open[index - 1]);      // إغلاق أقل من فتح السابقة
   
   return bullishEngulfing || bearishEngulfing;
}
//+------------------------------------------------------------------+