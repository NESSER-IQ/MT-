//+------------------------------------------------------------------+
//|                                                     ChartSignal.mqh |
//|                  حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//|                                       https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../CandlePatterns/Base/PatternSignal.mqh"
#include "ChartPattern.mqh"
#include "ChartUtils.mqh"

//+------------------------------------------------------------------+
//| تعدادات حالة الإشارة                                            |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_STATUS
{
    SIGNAL_STATUS_PENDING,      // في الانتظار
    SIGNAL_STATUS_ACTIVE,       // نشطة
    SIGNAL_STATUS_TRIGGERED,    // مفعلة
    SIGNAL_STATUS_COMPLETED,    // مكتملة
    SIGNAL_STATUS_CANCELLED,    // ملغاة
    SIGNAL_STATUS_EXPIRED,      // منتهية الصلاحية
    SIGNAL_STATUS_FAILED        // فاشلة
};

enum ENUM_SIGNAL_ACTION
{
    SIGNAL_ACTION_BUY,          // شراء
    SIGNAL_ACTION_SELL,         // بيع
    SIGNAL_ACTION_CLOSE_BUY,    // إغلاق الشراء
    SIGNAL_ACTION_CLOSE_SELL,   // إغلاق البيع
    SIGNAL_ACTION_MODIFY,       // تعديل
    SIGNAL_ACTION_WAIT,         // انتظار
    SIGNAL_ACTION_ALERT         // تنبيه فقط
};

enum ENUM_SIGNAL_URGENCY
{
    URGENCY_LOW = 1,            // عاجلة منخفضة
    URGENCY_NORMAL = 2,         // عاجلة عادية
    URGENCY_HIGH = 3,           // عاجلة عالية
    URGENCY_CRITICAL = 4        // عاجلة حرجة
};

//+------------------------------------------------------------------+
//| هيكل إشارة المخطط المحسنة                                       |
//+------------------------------------------------------------------+
struct SChartSignalInfo
{
    // معلومات أساسية
    ulong signalId;                     // معرف الإشارة
    string patternName;                 // اسم النمط
    string symbolName;                  // اسم الرمز
    ENUM_TIMEFRAMES timeframe;          // الإطار الزمني
    datetime signalTime;                // وقت الإشارة
    datetime expiryTime;                // وقت انتهاء الصلاحية
    
    // معلومات النمط
    ENUM_CHART_PATTERN_NAME patternType;    // نوع النمط
    ENUM_PATTERN_DIRECTION direction;       // الاتجاه
    ENUM_SIGNAL_STATUS status;              // حالة الإشارة
    ENUM_SIGNAL_ACTION action;              // العمل المطلوب
    ENUM_SIGNAL_URGENCY urgency;            // درجة الإلحاح
    
    // بيانات التداول
    double entryPrice;                  // سعر الدخول
    double currentPrice;                // السعر الحالي
    double stopLoss;                    // وقف الخسارة
    double takeProfit1;                 // الهدف الأول
    double takeProfit2;                 // الهدف الثاني
    double takeProfit3;                 // الهدف الثالث
    double trailingStop;                // وقف متحرك
    
    // بيانات الجودة
    double confidence;                  // درجة الثقة (0-1)
    double reliability;                 // الموثوقية (0-1)
    double strength;                    // قوة النمط (0-1)
    double riskReward;                  // نسبة المخاطرة للعائد
    double successProbability;          // احتمالية النجاح
    
    // بيانات التأكيد
    bool volumeConfirmed;               // تأكيد الحجم
    bool trendConfirmed;                // تأكيد الاتجاه
    bool candleConfirmed;               // تأكيد الشموع
    bool priceActionConfirmed;          // تأكيد حركة السعر
    bool multiTimeframeConfirmed;       // تأكيد متعدد الإطارات
    
    // معلومات الأداء
    double maxProfit;                   // أقصى ربح محقق
    double maxLoss;                     // أقصى خسارة محققة
    double currentPnL;                  // الربح/الخسارة الحالية
    double realizedPnL;                 // الربح/الخسارة المحققة
    int barsActive;                     // عدد الشموع النشطة
    datetime lastUpdate;                // آخر تحديث
    
    // معلومات إضافية
    string description;                 // وصف الإشارة
    string notes;                       // ملاحظات
    string warnings;                    // تحذيرات
    int magicNumber;                    // الرقم السحري
    ulong positionTicket;               // رقم المركز
    
    // بيانات إحصائية
    double volatility;                  // التقلبات
    double volume;                      // حجم التداول
    double spread;                      // السبريد
    double swapLong;                    // سواب الشراء
    double swapShort;                   // سواب البيع
    
    SChartSignalInfo()
    {
        signalId = 0;
        patternName = "";
        symbolName = "";
        timeframe = PERIOD_CURRENT;
        signalTime = 0;
        expiryTime = 0;
        patternType = CHART_HEAD_SHOULDERS;
        direction = PATTERN_NEUTRAL;
        status = SIGNAL_STATUS_PENDING;
        action = SIGNAL_ACTION_WAIT;
        urgency = URGENCY_NORMAL;
        entryPrice = 0.0;
        currentPrice = 0.0;
        stopLoss = 0.0;
        takeProfit1 = 0.0;
        takeProfit2 = 0.0;
        takeProfit3 = 0.0;
        trailingStop = 0.0;
        confidence = 0.0;
        reliability = 0.0;
        strength = 0.0;
        riskReward = 0.0;
        successProbability = 0.0;
        volumeConfirmed = false;
        trendConfirmed = false;
        candleConfirmed = false;
        priceActionConfirmed = false;
        multiTimeframeConfirmed = false;
        maxProfit = 0.0;
        maxLoss = 0.0;
        currentPnL = 0.0;
        realizedPnL = 0.0;
        barsActive = 0;
        lastUpdate = 0;
        description = "";
        notes = "";
        warnings = "";
        magicNumber = 0;
        positionTicket = 0;
        volatility = 0.0;
        volume = 0.0;
        spread = 0.0;
        swapLong = 0.0;
        swapShort = 0.0;
    }
};

//+------------------------------------------------------------------+
//| فئة إدارة إشارات أنماط المخططات                                 |
//+------------------------------------------------------------------+
class CChartSignalManager
{
private:
    // مصفوفة الإشارات
    SChartSignalInfo   m_signals[];         // الإشارات النشطة
    int                m_signalCount;       // عدد الإشارات
    int                m_maxSignals;        // الحد الأقصى للإشارات
    ulong              m_nextSignalId;      // معرف الإشارة التالي
    
    // إدارة الإشارات
    CPatternSignalManager* m_patternSignalManager;  // مدير إشارات الأنماط
    
    // إعدادات النظام
    bool               m_enabled;           // تفعيل النظام
    bool               m_autoTrading;       // التداول التلقائي
    bool               m_alertsEnabled;     // تفعيل التنبيهات
    int                m_maxSignalsPerSymbol;   // الحد الأقصى للإشارات لكل رمز
    int                m_signalExpiryBars;  // انتهاء الصلاحية بالشموع
    
    // إحصائيات
    int                m_totalSignals;      // إجمالي الإشارات
    int                m_activeSignals;     // الإشارات النشطة
    int                m_successfulSignals; // الإشارات الناجحة
    int                m_failedSignals;     // الإشارات الفاشلة
    double             m_totalPnL;          // إجمالي الربح/الخسارة
    double             m_successRate;       // معدل النجاح
    
    // أداء النظام
    datetime           m_lastUpdate;        // آخر تحديث
    int                m_updateCount;       // عدد التحديثات
    bool               m_isProcessing;      // حالة المعالجة
    
public:
    // المنشئ والهادم
    CChartSignalManager(int maxSignals = 1000);
    ~CChartSignalManager();
    
    // دوال التهيئة والإعداد
    bool               Initialize();
    void               Deinitialize();
    void               SetEnabled(bool enabled) { m_enabled = enabled; }
    void               SetAutoTrading(bool enabled) { m_autoTrading = enabled; }
    void               SetAlertsEnabled(bool enabled) { m_alertsEnabled = enabled; }
    void               SetMaxSignalsPerSymbol(int max) { m_maxSignalsPerSymbol = MathMax(1, max); }
    void               SetSignalExpiryBars(int bars) { m_signalExpiryBars = MathMax(1, bars); }
    
    // دوال إدارة الإشارات
    ulong              AddSignal(const SChartPatternSignal &patternSignal);
    ulong              AddSignal(const SChartSignalInfo &signal);
    bool               RemoveSignal(ulong signalId);
    bool               UpdateSignal(ulong signalId, const SChartSignalInfo &updatedSignal);
    bool               GetSignal(ulong signalId, SChartSignalInfo &signal);
    int                GetSignalsCount() const { return m_signalCount; }
    int                GetActiveSignalsCount();
    
    // دوال البحث والتصفية
    int                FindSignalsBySymbol(const string symbol, ulong &signalIds[]);
    int                FindSignalsByPattern(const string patternName, ulong &signalIds[]);
    int                FindSignalsByStatus(ENUM_SIGNAL_STATUS status, ulong &signalIds[]);
    int                FindSignalsByTimeframe(ENUM_TIMEFRAMES timeframe, ulong &signalIds[]);
    int                FindSignalsByDirection(ENUM_PATTERN_DIRECTION direction, ulong &signalIds[]);
    ulong              FindBestSignal(const string symbol = "");
    ulong              FindMostUrgentSignal();
    
    // دوال حالة الإشارة
    bool               ActivateSignal(ulong signalId);
    bool               TriggerSignal(ulong signalId);
    bool               CompleteSignal(ulong signalId, double finalPnL);
    bool               CancelSignal(ulong signalId, const string reason = "");
    bool               ExpireSignal(ulong signalId);
    bool               FailSignal(ulong signalId, const string reason = "");
    
    // دوال تحديث الإشارات
    void               UpdateAllSignals();
    void               UpdateSignalPrices();
    void               UpdateSignalStatus();
    void               CheckSignalConditions();
    void               CleanupExpiredSignals();
    void               ProcessTrailingStops();
    
    // دوال التحليل والمراقبة
    bool               IsSignalValid(ulong signalId);
    bool               ShouldSignalExpire(ulong signalId);
    double             CalculateSignalPnL(ulong signalId);
    double             CalculateSignalRisk(ulong signalId);
    double             GetSignalProgress(ulong signalId);
    ENUM_SIGNAL_URGENCY CalculateSignalUrgency(ulong signalId);
    
    // دوال التداول
    bool               ExecuteSignal(ulong signalId);
    bool               CloseSignalPosition(ulong signalId);
    bool               ModifySignalStops(ulong signalId, double newSL, double newTP);
    bool               SetTrailingStop(ulong signalId, double distance);
    
    // دوال التنبيهات
    void               SendSignalAlert(ulong signalId, const string message);
    void               SendUrgentAlert(ulong signalId);
    void               SendSuccessAlert(ulong signalId);
    void               SendFailureAlert(ulong signalId);
    
    // دوال الإحصائيات
    void               UpdateStatistics();
    void               ResetStatistics();
    double             GetSuccessRate() const { return m_successRate; }
    double             GetTotalPnL() const { return m_totalPnL; }
    int                GetTotalSignalsCount() const { return m_totalSignals; }
    int                GetSuccessfulSignalsCount() const { return m_successfulSignals; }
    int                GetFailedSignalsCount() const { return m_failedSignals; }
    
    // دوال التقارير
    void               PrintSignalsReport();
    void               PrintStatisticsReport();
    string             GetSignalString(ulong signalId);
    string             GetStatisticsString();
    void               SaveSignalsToFile(const string fileName);
    bool               LoadSignalsFromFile(const string fileName);
    
    // دوال الأداء والتحسين
    void               OptimizeMemoryUsage();
    void               CompactSignalArray();
    void               SortSignalsByPriority();
    void               SortSignalsByTime();
    void               SortSignalsByReliability();
    
    // دوال الأحداث
    void               OnTick();
    void               OnNewBar();
    void               OnTimer();
    void               OnTrade();
    
    // دوال التحقق والتشخيص
    bool               ValidateSignal(const SChartSignalInfo &signal);
    bool               CheckSystemHealth();
    void               RunDiagnostics();
    string             GetLastError();
    
private:
    // دوال مساعدة
    int                FindSignalIndex(ulong signalId);
    bool               IsSignalSlotAvailable();
    void               RemoveSignalAtIndex(int index);
    void               ShiftSignalsDown(int startIndex);
    
    // دوال التحقق
    bool               ValidateSignalData(const SChartSignalInfo &signal);
    bool               CheckSignalConflicts(const SChartSignalInfo &signal);
    bool               IsSymbolOverloaded(const string symbol);
    
    // دوال الحساب
    double             CalculateAverageReliability();
    double             CalculateAverageRiskReward();
    datetime           CalculateAverageSignalDuration();
    
    // دوال التحديث
    void               UpdateSignalProgress(int index);
    void               UpdateSignalMetrics(int index);
    void               CheckSignalExpiry(int index);
    
    // دوال الإشارات الفرعية
    bool               ConvertPatternSignal(const SChartPatternSignal &patternSignal, 
                                          SChartSignalInfo &signalInfo);
    void               FillSignalDefaults(SChartSignalInfo &signal);
    
    // متغيرات خاصة
    string             m_lastError;
    int                m_errorCount;
    datetime           m_lastDiagnostic;
};

//+------------------------------------------------------------------+
//| منشئ فئة إدارة الإشارات                                          |
//+------------------------------------------------------------------+
CChartSignalManager::CChartSignalManager(int maxSignals)
{
    m_maxSignals = MathMax(10, maxSignals);
    m_signalCount = 0;
    m_nextSignalId = 1;
    
    // تهيئة المصفوفات
    ArrayResize(m_signals, m_maxSignals);
    
    // إعدادات افتراضية
    m_enabled = true;
    m_autoTrading = false;
    m_alertsEnabled = true;
    m_maxSignalsPerSymbol = 5;
    m_signalExpiryBars = 50;
    
    // إحصائيات
    m_totalSignals = 0;
    m_activeSignals = 0;
    m_successfulSignals = 0;
    m_failedSignals = 0;
    m_totalPnL = 0.0;
    m_successRate = 0.0;
    
    // متغيرات النظام
    m_lastUpdate = 0;
    m_updateCount = 0;
    m_isProcessing = false;
    m_lastError = "";
    m_errorCount = 0;
    m_lastDiagnostic = 0;
    
    // إنشاء مدير إشارات الأنماط
    m_patternSignalManager = new CPatternSignalManager(maxSignals);
}

//+------------------------------------------------------------------+
//| هادم فئة إدارة الإشارات                                          |
//+------------------------------------------------------------------+
CChartSignalManager::~CChartSignalManager()
{
    Deinitialize();
    
    if(m_patternSignalManager != NULL)
    {
        delete m_patternSignalManager;
        m_patternSignalManager = NULL;
    }
}

//+------------------------------------------------------------------+
//| تهيئة مدير الإشارات                                             |
//+------------------------------------------------------------------+
bool CChartSignalManager::Initialize()
{
    if(m_patternSignalManager != NULL)
    {
        if(!m_patternSignalManager.Initialize())
            return false;
    }
    
    // تنظيف البيانات السابقة
    // تهيئة مصفوفة الإشارات عبر إعادة تغيير الحجم
    ArrayResize(m_signals, 0);
    ArrayResize(m_signals, m_maxSignals);
    
    // تهيئة كل عنصر في المصفوفة بشكل فردي
    for(int i = 0; i < m_maxSignals; i++)
    {
        m_signals[i] = SChartSignalInfo(); // استدعاء المنشئ الافتراضي
    }
    
    m_signalCount = 0;
    m_nextSignalId = 1;
    
    return true;
}

//+------------------------------------------------------------------+
//| إنهاء مدير الإشارات                                             |
//+------------------------------------------------------------------+
void CChartSignalManager::Deinitialize()
{
    if(m_patternSignalManager != NULL)
        m_patternSignalManager.Deinitialize();
    
    // تنظيف المصفوفات
    ArrayResize(m_signals, 0);
    m_signalCount = 0;
}

//+------------------------------------------------------------------+
//| إضافة إشارة جديدة من نمط مخطط                                   |
//+------------------------------------------------------------------+
ulong CChartSignalManager::AddSignal(const SChartPatternSignal &patternSignal)
{
    if(!m_enabled || !IsSignalSlotAvailable())
        return 0;
    
    SChartSignalInfo signal;
    if(!ConvertPatternSignal(patternSignal, signal))
        return 0;
    
    return AddSignal(signal);
}

//+------------------------------------------------------------------+
//| إضافة إشارة جديدة                                               |
//+------------------------------------------------------------------+
ulong CChartSignalManager::AddSignal(const SChartSignalInfo &signal)
{
    if(!m_enabled || !ValidateSignal(signal) || !IsSignalSlotAvailable())
        return 0;
    
    // التحقق من التضارب
    if(CheckSignalConflicts(signal))
        return 0;
    
    // إنشاء نسخة من الإشارة
    SChartSignalInfo newSignal = signal;
    newSignal.signalId = m_nextSignalId++;
    newSignal.signalTime = TimeCurrent();
    newSignal.lastUpdate = TimeCurrent();
    newSignal.status = SIGNAL_STATUS_PENDING;
    
    // ملء البيانات الافتراضية
    FillSignalDefaults(newSignal);
    
    // إضافة الإشارة
    m_signals[m_signalCount] = newSignal;
    m_signalCount++;
    m_totalSignals++;
    
    // إرسال تنبيه
    if(m_alertsEnabled)
        SendSignalAlert(newSignal.signalId, "إشارة جديدة: " + newSignal.patternName);
    
    return newSignal.signalId;
}

//+------------------------------------------------------------------+
//| العثور على أفضل إشارة                                           |
//+------------------------------------------------------------------+
ulong CChartSignalManager::FindBestSignal(const string symbol)
{
    ulong bestSignalId = 0;
    double bestScore = 0.0;
    
    for(int i = 0; i < m_signalCount; i++)
    {
        if(!IsSignalValid(m_signals[i].signalId))
            continue;
        
        if(symbol != "" && m_signals[i].symbolName != symbol)
            continue;
        
        // حساب نقاط الجودة
        double score = m_signals[i].confidence * m_signals[i].reliability * 
                      m_signals[i].strength * m_signals[i].riskReward;
        
        if(score > bestScore)
        {
            bestScore = score;
            bestSignalId = m_signals[i].signalId;
        }
    }
    
    return bestSignalId;
}

//+------------------------------------------------------------------+
//| تحديث جميع الإشارات                                              |
//+------------------------------------------------------------------+
void CChartSignalManager::UpdateAllSignals()
{
    if(!m_enabled || m_isProcessing)
        return;
    
    m_isProcessing = true;
    
    // تحديث الأسعار والحالات
    UpdateSignalPrices();
    UpdateSignalStatus();
    CheckSignalConditions();
    ProcessTrailingStops();
    CleanupExpiredSignals();
    
    // تحديث الإحصائيات
    UpdateStatistics();
    
    m_lastUpdate = TimeCurrent();
    m_updateCount++;
    m_isProcessing = false;
}

//+------------------------------------------------------------------+
//| تحويل إشارة النمط إلى إشارة مخطط                                |
//+------------------------------------------------------------------+
bool CChartSignalManager::ConvertPatternSignal(const SChartPatternSignal &patternSignal, 
                                              SChartSignalInfo &signalInfo)
{
    signalInfo.patternName = patternSignal.patternName;
    signalInfo.patternType = patternSignal.patternType;
    signalInfo.direction = patternSignal.direction;
    signalInfo.confidence = patternSignal.confidence;
    signalInfo.reliability = patternSignal.reliability;
    signalInfo.strength = patternSignal.strength;
    signalInfo.entryPrice = patternSignal.entryPrice;
    signalInfo.stopLoss = patternSignal.stopLoss;
    signalInfo.takeProfit1 = patternSignal.takeProfit1;
    signalInfo.takeProfit2 = patternSignal.takeProfit2;
    signalInfo.takeProfit3 = patternSignal.takeProfit3;
    signalInfo.riskReward = patternSignal.riskReward;
    signalInfo.volumeConfirmed = patternSignal.volumeConfirmed;
    signalInfo.trendConfirmed = patternSignal.trendConfirmed;
    signalInfo.candleConfirmed = patternSignal.candleConfirmed;
    signalInfo.description = patternSignal.description;
    signalInfo.successProbability = patternSignal.successProbability;
    
    // تحديد نوع العمل
    switch(patternSignal.direction)
    {
        case PATTERN_BULLISH:
            signalInfo.action = SIGNAL_ACTION_BUY;
            break;
        case PATTERN_BEARISH:
            signalInfo.action = SIGNAL_ACTION_SELL;
            break;
        default:
            signalInfo.action = SIGNAL_ACTION_WAIT;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| ملء البيانات الافتراضية للإشارة                                 |
//+------------------------------------------------------------------+
void CChartSignalManager::FillSignalDefaults(SChartSignalInfo &signal)
{
    if(signal.symbolName == "")
        signal.symbolName = Symbol();
    
    if(signal.timeframe == PERIOD_CURRENT)
        signal.timeframe = Period();
    
    if(signal.expiryTime == 0)
        signal.expiryTime = TimeCurrent() + m_signalExpiryBars * PeriodSeconds();
    
    // تحديد درجة الإلحاح
    signal.urgency = CalculateSignalUrgency(signal.signalId);
    
    // تحديد السعر الحالي
    signal.currentPrice = SymbolInfoDouble(signal.symbolName, SYMBOL_BID);
}

//+------------------------------------------------------------------+
//| التحقق من صحة الإشارة                                           |
//+------------------------------------------------------------------+
bool CChartSignalManager::ValidateSignal(const SChartSignalInfo &signal)
{
    // التحقق من البيانات الأساسية
    if(signal.patternName == "" || signal.symbolName == "")
        return false;
    
    if(signal.confidence < 0.0 || signal.confidence > 1.0)
        return false;
    
    if(signal.reliability < 0.0 || signal.reliability > 1.0)
        return false;
    
    // التحقق من بيانات التداول
    if(signal.entryPrice <= 0.0)
        return false;
    
    if(signal.action == SIGNAL_ACTION_BUY || signal.action == SIGNAL_ACTION_SELL)
    {
        if(signal.stopLoss <= 0.0 || signal.takeProfit1 <= 0.0)
            return false;
        
        // التحقق من منطقية الأسعار
        if(signal.action == SIGNAL_ACTION_BUY)
        {
            if(signal.stopLoss >= signal.entryPrice || signal.takeProfit1 <= signal.entryPrice)
                return false;
        }
        else if(signal.action == SIGNAL_ACTION_SELL)
        {
            if(signal.stopLoss <= signal.entryPrice || signal.takeProfit1 >= signal.entryPrice)
                return false;
        }
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| طباعة تقرير الإشارات                                            |
//+------------------------------------------------------------------+
void CChartSignalManager::PrintSignalsReport()
{
    Print("===== تقرير إشارات أنماط المخططات =====");
    Print("إجمالي الإشارات: ", m_totalSignals);
    Print("الإشارات النشطة: ", GetActiveSignalsCount());
    Print("الإشارات الناجحة: ", m_successfulSignals);
    Print("الإشارات الفاشلة: ", m_failedSignals);
    Print("معدل النجاح: ", DoubleToString(m_successRate, 2), "%");
    Print("إجمالي الربح/الخسارة: ", DoubleToString(m_totalPnL, 2));
    
    if(m_signalCount > 0)
    {
        Print("--- الإشارات الحالية ---");
        for(int i = 0; i < m_signalCount; i++)
        {
            Print(StringFormat("[%d] %s - %s - %s - %.2f%%", 
                  m_signals[i].signalId, m_signals[i].patternName, 
                  m_signals[i].symbolName, EnumToString(m_signals[i].status),
                  m_signals[i].confidence * 100));
        }
    }
    Print("=======================================");
}
