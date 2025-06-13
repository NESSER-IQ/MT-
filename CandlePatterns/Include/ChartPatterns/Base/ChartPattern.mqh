//+------------------------------------------------------------------+
//|                                                    ChartPattern.mqh |
//|                  حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//|                                       https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../CandlePatterns/Base/CandleUtils.mqh"
#include "../../CandlePatterns/Base/TrendDetector.mqh"
#include "../../CandlePatterns/Base/PatternSignal.mqh"
#include "ChartUtils.mqh"

//+------------------------------------------------------------------+
//| تعدادات أنماط المخططات                                          |
//+------------------------------------------------------------------+
enum ENUM_CHART_PATTERN_NAME
{
    CHART_HEAD_SHOULDERS,          // الرأس والكتفين
    CHART_INVERSE_HEAD_SHOULDERS,  // الرأس والكتفين المقلوب
    CHART_DOUBLE_TOP,              // القمة المزدوجة
    CHART_DOUBLE_BOTTOM,           // القاع المزدوج
    CHART_TRIPLE_TOP,              // القمة الثلاثية
    CHART_TRIPLE_BOTTOM,           // القاع الثلاثي
    CHART_ASCENDING_TRIANGLE,      // المثلث الصاعد
    CHART_DESCENDING_TRIANGLE,     // المثلث الهابط
    CHART_SYMMETRICAL_TRIANGLE,    // المثلث المتماثل
    CHART_RISING_WEDGE,            // الوتد الصاعد
    CHART_FALLING_WEDGE,           // الوتد الهابط
    CHART_RECTANGLE,               // المستطيل
    CHART_FLAG,                    // العلم
    CHART_PENNANT,                 // الراية
    CHART_CUP_HANDLE,              // الكوب والمقبض
    CHART_ROUNDING_BOTTOM,         // القاع المدور
    CHART_ROUNDING_TOP,            // القمة المدورة
    CHART_DIAMOND,                 // الماس
    CHART_BROADENING_FORMATION,    // التشكيل المتوسع
    CHART_GARTLEY,                 // نمط جارتلي
    CHART_BUTTERFLY,               // الفراشة
    CHART_BAT,                     // الخفاش
    CHART_CRAB,                    // السلطعون
    CHART_CYPHER,                  // سايفر
    CHART_SHARK,                   // القرش
    CHART_ABCD,                    // ABCD
    CHART_THREE_DRIVES,            // الدفعات الثلاث
    CHART_WOLFE_WAVE,              // موجة وولف
    CHART_ELLIOTT_WAVE             // موجة إليوت
};

//+------------------------------------------------------------------+
//| هيكل إشارة نمط المخطط                                           |
//+------------------------------------------------------------------+
struct SChartPatternSignal
{
    // معلومات النمط
    string patternName;                    // اسم النمط
    ENUM_CHART_PATTERN_NAME patternType;   // نوع النمط
    ENUM_CHART_PATTERN_TYPE category;      // فئة النمط
    ENUM_PATTERN_DIRECTION direction;      // اتجاه النمط
    
    // معلومات الإشارة
    datetime signalTime;                   // وقت الإشارة
    double confidence;                     // درجة الثقة (0-1)
    double reliability;                    // معدل الموثوقية
    double strength;                       // قوة النمط
    
    // نقاط النمط
    SChartPoint keyPoints[];               // النقاط الرئيسية
    STrendLine trendLines[];               // خطوط الاتجاه
    SPriceLevel supportResistance[];       // مستويات الدعم والمقاومة
    
    // أهداف التداول
    double entryPrice;                     // سعر الدخول
    double stopLoss;                       // وقف الخسارة
    double takeProfit1;                    // الهدف الأول
    double takeProfit2;                    // الهدف الثاني
    double takeProfit3;                    // الهدف الثالث
    double riskReward;                     // نسبة المخاطرة للعائد
    
    // معلومات التأكيد
    bool volumeConfirmed;                  // تأكيد الحجم
    bool trendConfirmed;                   // تأكيد الاتجاه
    bool candleConfirmed;                  // تأكيد الشموع
    bool timeConfirmed;                    // تأكيد التوقيت
    
    // معلومات الأداء
    double projectedMove;                  // الحركة المتوقعة
    double successProbability;             // احتمالية النجاح
    datetime expectedDuration;             // المدة المتوقعة
    double maxDrawdown;                    // أقصى تراجع متوقع
    
    // معلومات إضافية
    string description;                    // وصف النمط
    string tradingNotes;                   // ملاحظات التداول
    string warnings;                       // تحذيرات
    int barIndex;                          // مؤشر الشمعة
    
    SChartPatternSignal()
    {
        patternName = "";
        patternType = CHART_HEAD_SHOULDERS;
        category = CHART_PATTERN_REVERSAL;
        direction = PATTERN_NEUTRAL;
        signalTime = 0;
        confidence = 0.0;
        reliability = 0.0;
        strength = 0.0;
        entryPrice = 0.0;
        stopLoss = 0.0;
        takeProfit1 = 0.0;
        takeProfit2 = 0.0;
        takeProfit3 = 0.0;
        riskReward = 0.0;
        volumeConfirmed = false;
        trendConfirmed = false;
        candleConfirmed = false;
        timeConfirmed = false;
        projectedMove = 0.0;
        successProbability = 0.0;
        expectedDuration = 0;
        maxDrawdown = 0.0;
        description = "";
        tradingNotes = "";
        warnings = "";
        barIndex = -1;
    }
};

//+------------------------------------------------------------------+
//| الفئة الأساسية لأنماط المخططات                                  |
//+------------------------------------------------------------------+
class CChartPattern
{
protected:
    // أدوات التحليل من CandlePatterns/Base
    CTrendDetector*        m_trendDetector;     // كاشف الاتجاه
    
    // خصائص النمط
    string                 m_name;              // اسم النمط
    ENUM_CHART_PATTERN_NAME m_patternType;      // نوع النمط
    ENUM_CHART_PATTERN_TYPE m_category;         // فئة النمط
    ENUM_PATTERN_DIRECTION m_direction;         // الاتجاه المتوقع
    double                 m_reliability;       // معدل الموثوقية
    
    // إعدادات التحليل
    int                    m_minBars;           // الحد الأدنى للشموع
    int                    m_maxBars;           // الحد الأقصى للشموع
    double                 m_tolerancePercent;  // نسبة التسامح
    bool                   m_useVolumeConfirmation;   // استخدام تأكيد الحجم
    bool                   m_useCandleConfirmation;   // استخدام تأكيد الشموع
    bool                   m_useTrendConfirmation;    // استخدام تأكيد الاتجاه
    
    // معاملات التحليل المتقدم
    double                 m_minReliability;    // الحد الأدنى للموثوقية
    double                 m_minRiskReward;     // الحد الأدنى للمخاطرة/العائد
    int                    m_confirmationBars;  // عدد شموع التأكيد
    
    // بيانات التحليل الحالي
    SChartPoint           m_detectedPoints[];   // النقاط المكتشفة
    STrendLine            m_detectedLines[];    // الخطوط المكتشفة
    SPriceLevel           m_detectedLevels[];   // المستويات المكتشفة
    
public:
    // المنشئ والهادم
    CChartPattern(const string name, ENUM_CHART_PATTERN_NAME patternType, 
                  ENUM_CHART_PATTERN_TYPE category, ENUM_PATTERN_DIRECTION direction, 
                  double reliability);
    virtual ~CChartPattern();
    
    // الدوال الافتراضية الأساسية
    virtual bool          Detect(const double &open[], const double &high[], const double &low[], 
                                const double &close[], const long &volume[], const datetime &time[], 
                                int rates_total, int &patternStart, int &patternEnd);
    
    virtual SChartPatternSignal GenerateSignal(const string symbol, ENUM_TIMEFRAMES timeframe,
                                              const double &open[], const double &high[], 
                                              const double &low[], const double &close[], 
                                              const long &volume[], const datetime &time[],
                                              int patternStart, int patternEnd);
    
    // دوال التكوين والإعدادات
    void                  SetTolerancePercent(double tolerance) { m_tolerancePercent = MathMax(0.01, tolerance); }
    void                  SetMinBars(int bars) { m_minBars = MathMax(5, bars); }
    void                  SetMaxBars(int bars) { m_maxBars = MathMax(m_minBars, bars); }
    void                  SetVolumeConfirmation(bool enable) { m_useVolumeConfirmation = enable; }
    void                  SetCandleConfirmation(bool enable) { m_useCandleConfirmation = enable; }
    void                  SetTrendConfirmation(bool enable) { m_useTrendConfirmation = enable; }
    void                  SetMinReliability(double reliability) { m_minReliability = MathMax(0.1, reliability); }
    void                  SetMinRiskReward(double ratio) { m_minRiskReward = MathMax(1.0, ratio); }
    
    // دوال الحصول على المعلومات
    string                GetName() const { return m_name; }
    ENUM_CHART_PATTERN_NAME GetPatternType() const { return m_patternType; }
    ENUM_CHART_PATTERN_TYPE GetCategory() const { return m_category; }
    ENUM_PATTERN_DIRECTION GetDirection() const { return m_direction; }
    double                GetReliability() const { return m_reliability; }
    double                GetTolerancePercent() const { return m_tolerancePercent; }
    
    // دوال التحليل المساعدة
    bool                  IsPatternComplete(const SChartPoint &points[]);
    double                CalculatePatternHeight(const SChartPoint &points[]);
    double                CalculatePatternWidth(const SChartPoint &points[]);
    double                CalculatePatternSymmetry(const SChartPoint &points[]);
    
    // دوال التحقق من الصحة
    bool                  ValidateMinimumRequirements(int barCount, double priceRange);
    bool                  ValidateTimeframe(ENUM_TIMEFRAMES timeframe);
    bool                  ValidateMarketConditions(const double &close[], int period);
    
protected:
    // دالة افتراضية للكشف المحدد (يجب تجاوزها)
    virtual bool          DetectSpecificPattern(const double &open[], const double &high[], 
                                              const double &low[], const double &close[], 
                                              const long &volume[], const datetime &time[], 
                                              int rates_total, int &patternStart, int &patternEnd) = 0;
    
    // دوال التأكيد المختلفة
    double                ConfirmWithCandlePatterns(const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], 
                                                   const long &volume[], int barIndex);
    
    double                ConfirmWithTrendAnalysis(const double &open[], const double &high[], 
                                                  const double &low[], const double &close[], 
                                                  const long &volume[], int patternStart, int patternEnd);
    
    double                ConfirmWithVolumeAnalysis(const long &volume[], int patternStart, int patternEnd);
    
    // دوال حساب الأهداف
    void                  CalculateTradingTargets(SChartPatternSignal &signal, 
                                                const SChartPoint &points[]);
    
    double                CalculateStopLoss(const SChartPoint &points[], ENUM_PATTERN_DIRECTION direction);
    double                CalculateTakeProfit(const SChartPoint &points[], ENUM_PATTERN_DIRECTION direction, 
                                            int targetLevel = 1);
    
    // دوال مساعدة تستخدم ChartUtils
    bool                  FindPatternPoints(const double &high[], const double &low[], const double &close[], 
                                          int start, int end, SChartPoint &points[]);
    
    bool                  FindPatternTrendLines(const double &high[], const double &low[], const double &close[],
                                              int start, int end, STrendLine &lines[]);
    
    bool                  FindKeyLevels(const double &high[], const double &low[], const double &close[],
                                      const datetime &time[], int start, int end, SPriceLevel &levels[]);
    
    // دوال التحليل الإحصائي
    double                CalculatePatternScore(const SChartPoint &points[], const STrendLine &lines[],
                                              const long &volume[], int start, int end);
    
    double                CalculateSuccessProbability(const SChartPoint &points[], 
                                                    const long &volume[], ENUM_TIMEFRAMES timeframe);
    
    // دوال التحقق من الجودة
    bool                  CheckPatternIntegrity(const SChartPoint &points[]);
    bool                  CheckTimeframeCompatibility(ENUM_TIMEFRAMES timeframe);
    bool                  CheckVolumeProfile(const long &volume[], int start, int end);
    
    // دوال الذاكرة والأداء
    void                  CleanupAnalysisData();
    void                  OptimizeMemoryUsage();
    
private:
    // دوال مساعدة خاصة
    void                  SortPointsByTime(SChartPoint &points[]);
    void                  SortPointsByPrice(SChartPoint &points[]);
    double                CalculateDistance(const SChartPoint &point1, const SChartPoint &point2);
    bool                  IsValidPoint(const SChartPoint &point, double minPrice, double maxPrice);
    
    // دوال التحقق من البيانات
    bool                  ValidateInputArrays(const double &open[], const double &high[], 
                                            const double &low[], const double &close[], 
                                            const long &volume[], int size);
    
    bool                  CheckDataConsistency(const double &high[], const double &low[], 
                                             const double &close[], int start, int end);
};

//+------------------------------------------------------------------+
//| منشئ الفئة الأساسية                                             |
//+------------------------------------------------------------------+
CChartPattern::CChartPattern(const string name, ENUM_CHART_PATTERN_NAME patternType, 
                            ENUM_CHART_PATTERN_TYPE category, ENUM_PATTERN_DIRECTION direction, 
                            double reliability)
{
    // تعيين المعلومات الأساسية
    m_name = name;
    m_patternType = patternType;
    m_category = category;
    m_direction = direction;
    m_reliability = MathMax(0.1, MathMin(1.0, reliability));
    
    // إنشاء كاشف الاتجاه
    m_trendDetector = new CTrendDetector();
    
    // إعدادات افتراضية
    m_minBars = 10;
    m_maxBars = 100;
    m_tolerancePercent = 0.05;
    m_useVolumeConfirmation = true;
    m_useCandleConfirmation = true;
    m_useTrendConfirmation = true;
    m_minReliability = 0.6;
    m_minRiskReward = 1.5;
    m_confirmationBars = 3;
    
    // تهيئة المصفوفات
    ArrayResize(m_detectedPoints, 0);
    ArrayResize(m_detectedLines, 0);
    ArrayResize(m_detectedLevels, 0);
}

//+------------------------------------------------------------------+
//| هادم الفئة                                                       |
//+------------------------------------------------------------------+
CChartPattern::~CChartPattern()
{
    if(m_trendDetector != NULL)
    {
        delete m_trendDetector;
        m_trendDetector = NULL;
    }
    
    CleanupAnalysisData();
}

//+------------------------------------------------------------------+
//| الدالة الرئيسية للكشف عن النمط                                  |
//+------------------------------------------------------------------+
bool CChartPattern::Detect(const double &open[], const double &high[], const double &low[], 
                          const double &close[], const long &volume[], const datetime &time[], 
                          int rates_total, int &patternStart, int &patternEnd)
{
    // التحقق من صحة البيانات
    if(!ValidateInputArrays(open, high, low, close, volume, rates_total))
        return false;
    
    // التحقق من الحد الأدنى للبيانات
    if(rates_total < m_minBars)
        return false;
    
    // تنظيف البيانات السابقة
    CleanupAnalysisData();
    
    // البحث عن النمط باستخدام الدالة المحددة
    bool found = DetectSpecificPattern(open, high, low, close, volume, time, 
                                      rates_total, patternStart, patternEnd);
    
    if(!found)
        return false;
    
    // التحقق من صحة النتائج
    if(patternStart < 0 || patternEnd >= rates_total || patternStart >= patternEnd)
        return false;
    
    // التحقق من الحد الأدنى لطول النمط
    if(patternEnd - patternStart < m_minBars)
        return false;
    
    return true;
}

//+------------------------------------------------------------------+
//| إنتاج إشارة التداول                                             |
//+------------------------------------------------------------------+
SChartPatternSignal CChartPattern::GenerateSignal(const string symbol, ENUM_TIMEFRAMES timeframe,
                                                  const double &open[], const double &high[], 
                                                  const double &low[], const double &close[], 
                                                  const long &volume[], const datetime &time[],
                                                  int patternStart, int patternEnd)
{
    SChartPatternSignal signal;
    
    // تعبئة المعلومات الأساسية
    signal.patternName = m_name;
    signal.patternType = m_patternType;
    signal.category = m_category;
    signal.direction = m_direction;
    signal.reliability = m_reliability;
    signal.signalTime = time[patternEnd];
    signal.barIndex = patternEnd;
    
    // العثور على النقاط الرئيسية للنمط باستخدام CChartUtils
    if(CChartUtils::FindSignificantPoints(high, low, close, patternStart, patternEnd, signal.keyPoints))
    {
        // حساب قوة النمط
        signal.strength = CalculatePatternScore(signal.keyPoints, signal.trendLines, 
                                               volume, patternStart, patternEnd);
        
        // حساب الثقة الأساسية
        signal.confidence = m_reliability * signal.strength;
        
        // تأكيدات إضافية
        if(m_useTrendConfirmation)
        {
            double trendConfirmation = ConfirmWithTrendAnalysis(open, high, low, close, volume, 
                                                              patternStart, patternEnd);
            signal.confidence *= (0.5 + 0.5 * trendConfirmation);
            signal.trendConfirmed = (trendConfirmation > 0.6);
        }
        
        if(m_useVolumeConfirmation)
        {
            double volumeConfirmation = ConfirmWithVolumeAnalysis(volume, patternStart, patternEnd);
            signal.confidence *= (0.5 + 0.5 * volumeConfirmation);
            signal.volumeConfirmed = (volumeConfirmation > 0.6);
        }
        
        if(m_useCandleConfirmation)
        {
            double candleConfirmation = ConfirmWithCandlePatterns(open, high, low, close, 
                                                                volume, patternEnd);
            signal.confidence *= (0.5 + 0.5 * candleConfirmation);
            signal.candleConfirmed = (candleConfirmation > 0.6);
        }
        
        // حساب أهداف التداول
        CalculateTradingTargets(signal, signal.keyPoints);
        
        // حساب احتمالية النجاح
        signal.successProbability = CalculateSuccessProbability(signal.keyPoints, volume, timeframe);
        
        // إضافة معلومات إضافية
        signal.description = StringFormat("نمط %s تم اكتشافه من %s إلى %s", 
                                         m_name, TimeToString(time[patternStart]), 
                                         TimeToString(time[patternEnd]));
        
        // تحذيرات إذا لزم الأمر
        if(signal.confidence < m_minReliability)
            signal.warnings += "مستوى الثقة أقل من المطلوب. ";
        
        if(signal.riskReward < m_minRiskReward)
            signal.warnings += "نسبة المخاطرة للعائد منخفضة. ";
    }
    
    return signal;
}

//+------------------------------------------------------------------+
//| التأكيد بأنماط الشموع                                           |
//+------------------------------------------------------------------+
double CChartPattern::ConfirmWithCandlePatterns(const double &open[], const double &high[], 
                                               const double &low[], const double &close[], 
                                               const long &volume[], int barIndex)
{
    double confirmationFactor = 1.0;
    
    // فحص آخر 3 شموع للتأكيد
    for(int i = MathMax(0, barIndex - 2); i <= barIndex && i < ArraySize(open); i++)
    {
        // تحليل بسيط للشموع
        double bodySize = MathAbs(close[i] - open[i]);
        double shadowSize = (high[i] - low[i]) - bodySize;
        double avgBody = 0.0;
        
        // حساب متوسط جسم الشمعة للـ 14 شمعة السابقة
        int period = MathMin(14, i);
        if(period > 0)
        {
            for(int j = i - period; j < i; j++)
            {
                avgBody += MathAbs(close[j] - open[j]);
            }
            avgBody /= period;
        }
        
        // تحليل نوع الشمعة
        bool isBullish = close[i] > open[i];
        bool isBearish = close[i] < open[i];
        bool isDoji = bodySize < (high[i] - low[i]) * 0.1;
        bool isHammer = (shadowSize > bodySize * 2) && 
                       ((isBullish && (high[i] - close[i]) < bodySize * 0.5) ||
                        (isBearish && (high[i] - open[i]) < bodySize * 0.5));
        bool isInvertedHammer = (shadowSize > bodySize * 2) && 
                               ((isBullish && (close[i] - low[i]) < bodySize * 0.5) ||
                                (isBearish && (open[i] - low[i]) < bodySize * 0.5));
        
        // تعديل عامل التأكيد بناءً على نوع الشمعة
        if(isDoji)
        {
            if(m_direction == PATTERN_NEUTRAL) confirmationFactor *= 1.1;
            else confirmationFactor *= 0.95;
        }
        else if(isHammer)
        {
            if(m_direction == PATTERN_BULLISH) confirmationFactor *= 1.1;
        }
        else if(isInvertedHammer)
        {
            if(m_direction == PATTERN_BEARISH) confirmationFactor *= 1.1;
        }
        else if(bodySize > avgBody * 1.5) // شمعة قوية
        {
            if((m_direction == PATTERN_BULLISH && isBullish) ||
               (m_direction == PATTERN_BEARISH && isBearish))
                confirmationFactor *= 1.15;
        }
    }
    
    return MathMax(0.0, MathMin(1.0, confirmationFactor));
}

//+------------------------------------------------------------------+
//| التأكيد بتحليل الاتجاه                                          |
//+------------------------------------------------------------------+
double CChartPattern::ConfirmWithTrendAnalysis(const double &open[], const double &high[], 
                                              const double &low[], const double &close[], 
                                              const long &volume[], int patternStart, int patternEnd)
{
    if(m_trendDetector == NULL)
        return 0.5;
    
    // استدعاء تحليل الاتجاه
    ENUM_TREND_TYPE detectedTrend = m_trendDetector.DetectTrend(open, high, low, close, volume, 
                                                               ArraySize(close), patternEnd);
    double trendStrength = m_trendDetector.GetTrendStrength();
    
    // مقارنة الاتجاه المكتشف مع اتجاه النمط
    double confirmationScore = 0.5; // محايد
    
    if(m_direction == PATTERN_BULLISH && detectedTrend == TREND_BULLISH)
        confirmationScore = 0.5 + (trendStrength * 0.5);
    else if(m_direction == PATTERN_BEARISH && detectedTrend == TREND_BEARISH)
        confirmationScore = 0.5 + (trendStrength * 0.5);
    else if(m_direction == PATTERN_NEUTRAL && detectedTrend == TREND_NEUTRAL)
        confirmationScore = 0.7;
    else if(detectedTrend == TREND_NEUTRAL)
        confirmationScore = 0.6; // اتجاه محايد يعطي تأكيد متوسط
    else
        confirmationScore = 0.5 - (trendStrength * 0.3); // اتجاه مضاد
    
    return MathMax(0.0, MathMin(1.0, confirmationScore));
}

//+------------------------------------------------------------------+
//| التأكيد بتحليل الحجم                                            |
//+------------------------------------------------------------------+
double CChartPattern::ConfirmWithVolumeAnalysis(const long &volume[], int patternStart, int patternEnd)
{
    if(ArraySize(volume) == 0 || patternEnd >= ArraySize(volume))
        return 0.5;
    
    // حساب متوسط الحجم قبل النمط
    double avgVolumeBefore = 0.0;
    int beforePeriod = MathMin(20, patternStart);
    int beforeCount = 0;
    
    for(int i = MathMax(0, patternStart - beforePeriod); i < patternStart; i++)
    {
        avgVolumeBefore += (double)volume[i];
        beforeCount++;
    }
    
    if(beforeCount > 0)
        avgVolumeBefore /= beforeCount;
    else
        return 0.5;
    
    // حساب متوسط الحجم أثناء النمط
    double avgVolumeDuring = 0.0;
    int duringCount = 0;
    
    for(int i = patternStart; i <= patternEnd; i++)
    {
        avgVolumeDuring += (double)volume[i];
        duringCount++;
    }
    
    if(duringCount > 0)
        avgVolumeDuring /= duringCount;
    else
        return 0.5;
    
    // حساب نسبة التأكيد
    double volumeRatio = (avgVolumeBefore > 0) ? (avgVolumeDuring / avgVolumeBefore) : 1.0;
    
    // تحديد مستوى التأكيد بناءً على نوع النمط
    double confirmationScore = 0.5;
    
    // أنماط الانعكاس تتطلب زيادة في الحجم
    if(m_category == CHART_PATTERN_REVERSAL)
    {
        if(volumeRatio > 1.5)
            confirmationScore = 0.8;
        else if(volumeRatio > 1.2)
            confirmationScore = 0.7;
        else if(volumeRatio > 1.0)
            confirmationScore = 0.6;
        else
            confirmationScore = 0.4;
    }
    // أنماط الاستمرار قد تتطلب انخفاض في الحجم
    else if(m_category == CHART_PATTERN_CONTINUATION)
    {
        if(volumeRatio < 0.8)
            confirmationScore = 0.7;
        else if(volumeRatio < 1.0)
            confirmationScore = 0.6;
        else
            confirmationScore = 0.5;
    }
    
    return MathMax(0.0, MathMin(1.0, confirmationScore));
}

//+------------------------------------------------------------------+
//| العثور على النقاط الرئيسية للنمط                                |
//+------------------------------------------------------------------+
bool CChartPattern::FindPatternPoints(const double &high[], const double &low[], const double &close[], 
                                     int start, int end, SChartPoint &points[])
{
    // استخدام CChartUtils للبحث عن النقاط
    return CChartUtils::FindSignificantPoints(high, low, close, start, end, points);
}

//+------------------------------------------------------------------+
//| ترتيب النقاط حسب الوقت                                          |
//+------------------------------------------------------------------+
void CChartPattern::SortPointsByTime(SChartPoint &points[])
{
    int size = ArraySize(points);
    
    // ترتيب بالفقاعات
    for(int i = 0; i < size - 1; i++)
    {
        for(int j = i + 1; j < size; j++)
        {
            if(points[j].barIndex < points[i].barIndex)
            {
                SChartPoint temp = points[i];
                points[i] = points[j];
                points[j] = temp;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| حساب نقاط النمط                                                |
//+------------------------------------------------------------------+
double CChartPattern::CalculatePatternScore(const SChartPoint &points[], const STrendLine &lines[],
                                          const long &volume[], int start, int end)
{
    double score = 0.0;
    int factors = 0;
    
    // عامل 1: عدد النقاط الرئيسية
    int pointCount = ArraySize(points);
    if(pointCount >= 3)
    {
        score += 0.3;
        factors++;
    }
    
    // عامل 2: تماثل النمط (إذا وجدت نقاط)
    if(pointCount >= 4)
    {
        double symmetry = CalculatePatternSymmetry(points);
        score += symmetry * 0.3;
        factors++;
    }
    
    // عامل 3: قوة النقاط
    if(pointCount > 0)
    {
        double avgStrength = 0.0;
        for(int i = 0; i < pointCount; i++)
        {
            avgStrength += points[i].strength;
        }
        avgStrength /= pointCount;
        score += avgStrength * 0.2;
        factors++;
    }
    
    // عامل 4: تحليل الحجم
    if(ArraySize(volume) > 0 && end < ArraySize(volume))
    {
        double volumeScore = 0.0;
        double avgVolume = 0.0;
        int volumeCount = 0;
        
        for(int i = start; i <= end; i++)
        {
            avgVolume += (double)volume[i];
            volumeCount++;
        }
        
        if(volumeCount > 0)
        {
            avgVolume /= volumeCount;
            // تطبيع الحجم
            volumeScore = MathMin(1.0, avgVolume / 1000.0);
            score += volumeScore * 0.2;
            factors++;
        }
    }
    
    // تطبيع النتيجة
    if(factors > 0)
        score /= factors;
    
    return MathMax(0.0, MathMin(1.0, score));
}

//+------------------------------------------------------------------+
//| حساب احتمالية النجاح                                            |
//+------------------------------------------------------------------+
double CChartPattern::CalculateSuccessProbability(const SChartPoint &points[], 
                                                const long &volume[], ENUM_TIMEFRAMES timeframe)
{
    double probability = m_reliability; // البداية من موثوقية النمط الأساسية
    
    // تعديل بناءً على عدد النقاط
    int pointCount = ArraySize(points);
    if(pointCount >= 5)
        probability += 0.1;
    else if(pointCount >= 3)
        probability += 0.05;
    
    // تعديل بناءً على الإطار الزمني
    switch(timeframe)
    {
        case PERIOD_D1:
            probability += 0.1; // الأطر الأعلى أكثر موثوقية
            break;
        case PERIOD_H4:
            probability += 0.05;
            break;
        case PERIOD_H1:
            break; // لا تعديل
        case PERIOD_M30:
        case PERIOD_M15:
            probability -= 0.05; // الأطر الأقل أقل موثوقية
            break;
        case PERIOD_M5:
        case PERIOD_M1:
            probability -= 0.1;
            break;
    }
    
    // تعديل بناءً على حجم التداول
    if(ArraySize(volume) > 0)
    {
        double avgVolume = 0.0;
        for(int i = 0; i < ArraySize(volume); i++)
        {
            avgVolume += (double)volume[i];
        }
        avgVolume /= ArraySize(volume);
        
        if(avgVolume > 1000) // حجم تداول عالي
            probability += 0.05;
    }
    
    return MathMax(0.1, MathMin(1.0, probability));
}

//+------------------------------------------------------------------+
//| حساب تماثل النمط                                               |
//+------------------------------------------------------------------+
double CChartPattern::CalculatePatternSymmetry(const SChartPoint &points[])
{
    int pointCount = ArraySize(points);
    if(pointCount < 4)
        return 0.5;
    
    // حساب المسافات بين النقاط
    double distances[];
    ArrayResize(distances, pointCount - 1);
    
    for(int i = 0; i < pointCount - 1; i++)
    {
        distances[i] = MathAbs(points[i + 1].barIndex - points[i].barIndex);
    }
    
    // حساب الانحراف المعياري للمسافات
    double avgDistance = 0.0;
    for(int i = 0; i < ArraySize(distances); i++)
    {
        avgDistance += distances[i];
    }
    avgDistance /= ArraySize(distances);
    
    double variance = 0.0;
    for(int i = 0; i < ArraySize(distances); i++)
    {
        variance += MathPow(distances[i] - avgDistance, 2);
    }
    variance /= ArraySize(distances);
    
    double standardDeviation = MathSqrt(variance);
    
    // تحويل الانحراف المعياري إلى نقاط تماثل (قيم أقل = تماثل أعلى)
    double symmetryScore = 1.0 - MathMin(1.0, standardDeviation / avgDistance);
    
    return MathMax(0.0, MathMin(1.0, symmetryScore));
}

//+------------------------------------------------------------------+
//| حساب أهداف التداول                                             |
//+------------------------------------------------------------------+
void CChartPattern::CalculateTradingTargets(SChartPatternSignal &signal, 
                                          const SChartPoint &points[])
{
    int pointCount = ArraySize(points);
    if(pointCount < 2)
        return;
    
    // العثور على أعلى وأقل نقطة في النمط
    double highestPrice = points[0].price;
    double lowestPrice = points[0].price;
    
    for(int i = 1; i < pointCount; i++)
    {
        highestPrice = MathMax(highestPrice, points[i].price);
        lowestPrice = MathMin(lowestPrice, points[i].price);
    }
    
    double patternHeight = highestPrice - lowestPrice;
    double patternMidpoint = (highestPrice + lowestPrice) / 2.0;
    
    // تحديد نقطة الدخول والوقف
    if(m_direction == PATTERN_BULLISH)
    {
        signal.entryPrice = highestPrice * 1.001; // كسر أعلى مستوى
        signal.stopLoss = lowestPrice * 0.999;   // أقل من أدنى مستوى
        signal.takeProfit1 = signal.entryPrice + (patternHeight * 0.618); // فيبوناتشي 61.8%
        signal.takeProfit2 = signal.entryPrice + patternHeight;           // ارتفاع النمط
        signal.takeProfit3 = signal.entryPrice + (patternHeight * 1.618); // فيبوناتشي 161.8%
    }
    else if(m_direction == PATTERN_BEARISH)
    {
        signal.entryPrice = lowestPrice * 0.999;  // كسر أدنى مستوى
        signal.stopLoss = highestPrice * 1.001;   // أعلى من أعلى مستوى
        signal.takeProfit1 = signal.entryPrice - (patternHeight * 0.618); // فيبوناتشي 61.8%
        signal.takeProfit2 = signal.entryPrice - patternHeight;           // ارتفاع النمط
        signal.takeProfit3 = signal.entryPrice - (patternHeight * 1.618); // فيبوناتشي 161.8%
    }
    else // PATTERN_NEUTRAL
    {
        signal.entryPrice = patternMidpoint;
        signal.stopLoss = (m_direction == PATTERN_BULLISH) ? lowestPrice : highestPrice;
        signal.takeProfit1 = signal.entryPrice + (patternHeight * 0.5);
        signal.takeProfit2 = signal.entryPrice + patternHeight;
        signal.takeProfit3 = signal.entryPrice + (patternHeight * 1.5);
    }
    
    // حساب نسبة المخاطرة للعائد
    double risk = MathAbs(signal.entryPrice - signal.stopLoss);
    double reward = MathAbs(signal.takeProfit1 - signal.entryPrice);
    
    if(risk > 0)
        signal.riskReward = reward / risk;
    else
        signal.riskReward = 0.0;
    
    // تقدير الحركة المتوقعة
    signal.projectedMove = patternHeight;
    
    // تقدير أقصى تراجع
    signal.maxDrawdown = patternHeight * 0.3; // 30% من ارتفاع النمط
}

//+------------------------------------------------------------------+
//| التحقق من صحة المصفوفات المدخلة                                 |
//+------------------------------------------------------------------+
bool CChartPattern::ValidateInputArrays(const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       const long &volume[], int size)
{
    // التحقق من الأحجام
    if(ArraySize(open) < size || ArraySize(high) < size || 
       ArraySize(low) < size || ArraySize(close) < size)
        return false;
    
    // التحقق من الحد الأدنى للحجم
    if(size < 10)
        return false;
    
    // التحقق من العلاقات المنطقية
    for(int i = 0; i < size; i++)
    {
        if(high[i] < low[i] || high[i] < open[i] || high[i] < close[i] ||
           low[i] > open[i] || low[i] > close[i] ||
           open[i] <= 0 || high[i] <= 0 || low[i] <= 0 || close[i] <= 0)
            return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| تنظيف بيانات التحليل                                            |
//+------------------------------------------------------------------+
void CChartPattern::CleanupAnalysisData()
{
    ArrayResize(m_detectedPoints, 0);
    ArrayResize(m_detectedLines, 0);
    ArrayResize(m_detectedLevels, 0);
}

//+------------------------------------------------------------------+
//| التحقق من اكتمال النمط                                          |
//+------------------------------------------------------------------+
bool CChartPattern::IsPatternComplete(const SChartPoint &points[])
{
    int pointCount = ArraySize(points);
    
    // الحد الأدنى للنقاط
    if(pointCount < 3)
        return false;
    
    // التحقق من أن جميع النقاط مؤكدة
    for(int i = 0; i < pointCount; i++)
    {
        if(!points[i].isConfirmed)
            return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| حساب ارتفاع النمط                                              |
//+------------------------------------------------------------------+
double CChartPattern::CalculatePatternHeight(const SChartPoint &points[])
{
    int pointCount = ArraySize(points);
    if(pointCount == 0)
        return 0.0;
    
    double maxPrice = points[0].price;
    double minPrice = points[0].price;
    
    for(int i = 1; i < pointCount; i++)
    {
        maxPrice = MathMax(maxPrice, points[i].price);
        minPrice = MathMin(minPrice, points[i].price);
    }
    
    return maxPrice - minPrice;
}

//+------------------------------------------------------------------+
//| حساب عرض النمط                                                 |
//+------------------------------------------------------------------+
double CChartPattern::CalculatePatternWidth(const SChartPoint &points[])
{
    int pointCount = ArraySize(points);
    if(pointCount == 0)
        return 0.0;
    
    int maxBarIndex = points[0].barIndex;
    int minBarIndex = points[0].barIndex;
    
    for(int i = 1; i < pointCount; i++)
    {
        maxBarIndex = MathMax(maxBarIndex, points[i].barIndex);
        minBarIndex = MathMin(minBarIndex, points[i].barIndex);
    }
    
    return maxBarIndex - minBarIndex;
}

//+------------------------------------------------------------------+
//| التحقق من الحد الأدنى للمتطلبات                                 |
//+------------------------------------------------------------------+
bool CChartPattern::ValidateMinimumRequirements(int barCount, double priceRange)
{
    return (barCount >= m_minBars && barCount <= m_maxBars && priceRange > 0.0);
}

//+------------------------------------------------------------------+
//| التحقق من صحة الإطار الزمني                                    |
//+------------------------------------------------------------------+
bool CChartPattern::ValidateTimeframe(ENUM_TIMEFRAMES timeframe)
{
    // قبول جميع الأطر الزمنية الأساسية
    switch(timeframe)
    {
        case PERIOD_M1:
        case PERIOD_M5:
        case PERIOD_M15:
        case PERIOD_M30:
        case PERIOD_H1:
        case PERIOD_H4:
        case PERIOD_D1:
        case PERIOD_W1:
        case PERIOD_MN1:
            return true;
        default:
            return false;
    }
}

//+------------------------------------------------------------------+
//| التحقق من ظروف السوق                                           |
//+------------------------------------------------------------------+
bool CChartPattern::ValidateMarketConditions(const double &close[], int period)
{
    if(period <= 0 || period > ArraySize(close))
        return false;
    
    // التحقق من وجود تقلبات كافية
    double maxPrice = close[0];
    double minPrice = close[0];
    
    for(int i = 1; i < period; i++)
    {
        maxPrice = MathMax(maxPrice, close[i]);
        minPrice = MathMin(minPrice, close[i]);
    }
    
    double volatility = (maxPrice - minPrice) / minPrice;
    
    // يجب أن تكون التقلبات أكبر من الحد الأدنى
    return (volatility > 0.01); // 1% كحد أدنى للتقلبات
}
