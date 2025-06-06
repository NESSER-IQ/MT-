//+------------------------------------------------------------------+
//|                                              PatternSignal.mqh   |
//|                        حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//|                                       https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayInt.mqh>
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//| تعدادات إدارة الإشارات                                            |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_SIGNAL_TYPE
{
   PATTERN_SIGNAL_NONE,              // لا توجد إشارة
   PATTERN_SIGNAL_BUY,               // إشارة شراء
   PATTERN_SIGNAL_SELL,              // إشارة بيع
   PATTERN_SIGNAL_CLOSE_BUY,         // إشارة إغلاق الشراء
   PATTERN_SIGNAL_CLOSE_SELL,        // إشارة إغلاق البيع
   PATTERN_SIGNAL_MODIFY_BUY,        // تعديل مركز الشراء
   PATTERN_SIGNAL_MODIFY_SELL,       // تعديل مركز البيع
   PATTERN_SIGNAL_PENDING_BUY_STOP,  // أمر شراء معلق (Buy Stop)
   PATTERN_SIGNAL_PENDING_SELL_STOP, // أمر بيع معلق (Sell Stop)
   PATTERN_SIGNAL_PENDING_BUY_LIMIT, // أمر شراء معلق (Buy Limit)
   PATTERN_SIGNAL_PENDING_SELL_LIMIT // أمر بيع معلق (Sell Limit)
};

enum ENUM_PATTERN_SIGNAL_STRENGTH
{
   PATTERN_SIGNAL_STRENGTH_VERY_WEAK = 1,  // إشارة ضعيفة جداً
   PATTERN_SIGNAL_STRENGTH_WEAK = 2,       // إشارة ضعيفة
   PATTERN_SIGNAL_STRENGTH_MEDIUM = 3,     // إشارة متوسطة
   PATTERN_SIGNAL_STRENGTH_STRONG = 4,     // إشارة قوية
   PATTERN_SIGNAL_STRENGTH_VERY_STRONG = 5 // إشارة قوية جداً
};

enum ENUM_PATTERN_SIGNAL_PRIORITY
{
   PATTERN_SIGNAL_PRIORITY_LOW = 1,     // أولوية منخفضة
   PATTERN_SIGNAL_PRIORITY_NORMAL = 2,  // أولوية عادية
   PATTERN_SIGNAL_PRIORITY_HIGH = 3,    // أولوية عالية
   PATTERN_SIGNAL_PRIORITY_URGENT = 4,  // أولوية عاجلة
   PATTERN_SIGNAL_PRIORITY_CRITICAL = 5 // أولوية حرجة
};

enum ENUM_PATTERN_SIGNAL_STATUS
{
   PATTERN_SIGNAL_STATUS_PENDING,     // في انتظار التنفيذ
   PATTERN_SIGNAL_STATUS_EXECUTED,    // تم التنفيذ
   PATTERN_SIGNAL_STATUS_PARTIAL,     // تنفيذ جزئي
   PATTERN_SIGNAL_STATUS_CANCELLED,   // تم الإلغاء
   PATTERN_SIGNAL_STATUS_EXPIRED,     // انتهت صلاحيتها
   PATTERN_SIGNAL_STATUS_REJECTED,    // تم الرفض
   PATTERN_SIGNAL_STATUS_MODIFIED,    // تم التعديل
   PATTERN_SIGNAL_STATUS_ERROR        // خطأ في التنفيذ
};

enum ENUM_RISK_MANAGEMENT_TYPE
{
   RISK_FIXED_AMOUNT,         // مبلغ ثابت
   RISK_PERCENT_BALANCE,      // نسبة من الرصيد
   RISK_PERCENT_EQUITY,       // نسبة من رأس المال
   RISK_FIXED_LOTS,           // عدد لوت ثابت
   RISK_KELLY_CRITERION,      // معيار كيلي
   RISK_OPTIMAL_F,            // الكسر الأمثل
   RISK_MARTINGALE,           // نظام مارتينجيل
   RISK_ANTI_MARTINGALE       // نظام مارتينجيل العكسي
};

//+------------------------------------------------------------------+
//| هيكل الإشارة المبسط (متوافق مع MQL5)                            |
//+------------------------------------------------------------------+
struct SPatternSignalInfo
{
   // المعلومات الأساسية
   string                        patternName;        // اسم النمط
   string                        patternDescription; // وصف النمط
   ENUM_PATTERN_SIGNAL_TYPE      signalType;         // نوع الإشارة
   ENUM_PATTERN_SIGNAL_STRENGTH  strength;           // قوة الإشارة
   ENUM_PATTERN_SIGNAL_PRIORITY  priority;           // أولوية الإشارة
   ENUM_PATTERN_SIGNAL_STATUS    status;             // حالة الإشارة
   
   // معلومات السوق
   string                        symbolName;         // الرمز
   ENUM_TIMEFRAMES               timeFrame;          // الإطار الزمني
   datetime                      signalTime;         // وقت الإشارة
   datetime                      expiryTime;         // وقت انتهاء الصلاحية
   datetime                      activationTime;     // وقت التفعيل
   
   // معلومات السعر
   double                        signalPrice;        // سعر الإشارة
   double                        entryPrice;         // سعر الدخول المقترح
   double                        stopLoss;           // وقف الخسارة
   double                        takeProfit;         // جني الأرباح
   double                        trailingStop;       // وقف متحرك
   double                        partialTP1;         // هدف جزئي أول
   double                        partialTP2;         // هدف جزئي ثاني
   double                        partialTP3;         // هدف جزئي ثالث
   
   // معلومات إحصائية
   double                        confidence;         // درجة الثقة (0-1)
   double                        riskReward;         // نسبة المخاطرة للعائد
   double                        winProbability;     // احتمالية النجاح
   double                        expectedReturn;     // العائد المتوقع
   double                        maxRisk;            // الحد الأقصى للمخاطرة
   
   // معلومات التنفيذ
   ulong                         orderTicket;        // رقم الأمر
   datetime                      executionTime;      // وقت التنفيذ
   double                        executionPrice;     // سعر التنفيذ
   double                        slippageValue;      // الانزلاق
   double                        commissionValue;    // العمولة
   double                        swapValue;          // السواب
   
   // معلومات الأداء
   double                        realizedPnL;        // الربح/الخسارة المحققة
   double                        unrealizedPnL;      // الربح/الخسارة غير المحققة
   double                        currentPrice;       // السعر الحالي
   double                        maxDrawdown;        // أقصى سحب
   double                        maxProfit;          // أقصى ربح
   
   // معلومات إضافية
   string                        commentText;        // تعليق
   int                           magicNumber;        // الرقم السحري
   string                        expertName;         // اسم الخبير
   
   // معلومات الفلترة
   bool                          isFiltered;         // تم فلترتها
   string                        filterReason;       // سبب الفلترة
   double                        filterScore;        // نقاط الفلتر
   
   // معلومات السوق الإضافية
   int                           barIndex;           // مؤشر الشمعة
   long                          volumeValue;        // الحجم
   double                        spreadValue;        // السبريد
   double                        volatilityValue;    // التقلبات
   double                        atrValue;           // متوسط المدى الحقيقي
};

//+------------------------------------------------------------------+
//| هيكل إعدادات إدارة المخاطر                                        |
//+------------------------------------------------------------------+
struct SRiskManagementSettings
{
   ENUM_RISK_MANAGEMENT_TYPE type;       // نوع إدارة المخاطر
   double            riskPercent;        // نسبة المخاطرة
   double            maxRiskPerTrade;    // الحد الأقصى للمخاطرة لكل تداول
   double            maxDailyRisk;       // الحد الأقصى للمخاطرة اليومية
   double            maxWeeklyRisk;      // الحد الأقصى للمخاطرة الأسبوعية
   double            maxMonthlyRisk;     // الحد الأقصى للمخاطرة الشهرية
   double            minRiskReward;      // الحد الأدنى لنسبة المخاطرة للعائد
   double            maxDrawdown;        // الحد الأقصى للسحب
   double            targetProfit;       // الهدف اليومي للربح
   bool              useTrailingStop;    // استخدام وقف متحرك
   double            trailingDistance;   // مسافة الوقف المتحرك
   bool              usePartialTP;       // استخدام أهداف جزئية
   double            partialTPPercent1;  // نسبة الهدف الجزئي الأول
   double            partialTPPercent2;  // نسبة الهدف الجزئي الثاني
   double            partialTPPercent3;  // نسبة الهدف الجزئي الثالث
   bool              enableHedging;      // تمكين التحوط
   double            hedgingRatio;       // نسبة التحوط
};

//+------------------------------------------------------------------+
//| هيكل إعدادات الفلتر                                              |
//+------------------------------------------------------------------+
struct SFilterSettings
{
   bool              enableTimeFilter;      // تمكين فلتر الوقت
   int               startHour;             // ساعة البداية
   int               endHour;               // ساعة النهاية
   bool              mondayEnabled;         // تداول الاثنين
   bool              tuesdayEnabled;        // تداول الثلاثاء
   bool              wednesdayEnabled;      // تداول الأربعاء
   bool              thursdayEnabled;       // تداول الخميس
   bool              fridayEnabled;         // تداول الجمعة
   
   bool              enableTrendFilter;     // تمكين فلتر الاتجاه
   double            minTrendStrength;      // الحد الأدنى لقوة الاتجاه
   
   bool              enableVolatilityFilter; // تمكين فلتر التقلبات
   double            minVolatility;         // الحد الأدنى للتقلبات
   double            maxVolatility;         // الحد الأقصى للتقلبات
   
   bool              enableSpreadFilter;    // تمكين فلتر السبريد
   double            maxSpread;             // الحد الأقصى للسبريد
   
   bool              enableNewsFilter;      // تمكين فلتر الأخبار
   int               newsFilterMinutes;     // دقائق تجنب الأخبار
   
   bool              enableDrawdownFilter;  // تمكين فلتر السحب
   double            maxCurrentDrawdown;    // الحد الأقصى للسحب الحالي
};

//+------------------------------------------------------------------+
//| هيكل إعدادات التنبيهات                                           |
//+------------------------------------------------------------------+
struct SAlertSettings
{
   bool              enableAlerts;          // تمكين التنبيهات
   bool              enablePopup;           // تمكين النوافذ المنبثقة
   bool              enableSound;           // تمكين الصوت
   string            soundFile;             // ملف الصوت
   bool              enableEmail;           // تمكين البريد الإلكتروني
   string            emailTo;               // البريد المرسل إليه
   bool              enablePush;            // تمكين الإشعارات
   bool              alertOnSignal;         // تنبيه عند الإشارة
   bool              alertOnExecution;      // تنبيه عند التنفيذ
   bool              alertOnProfit;         // تنبيه عند الربح
   bool              alertOnLoss;           // تنبيه عند الخسارة
   bool              alertOnError;          // تنبيه عند الخطأ
};

//+------------------------------------------------------------------+
//| فئة الإحصائيات المبسطة                                          |
//+------------------------------------------------------------------+
class CSignalStatistics : public CObject
{
private:
   // إحصائيات عامة
   int               m_totalSignals;        // إجمالي الإشارات
   int               m_executedSignals;     // الإشارات المنفذة
   int               m_successfulSignals;   // الإشارات الناجحة
   int               m_failedSignals;       // الإشارات الفاشلة
   
   // إحصائيات مالية
   double            m_totalProfit;         // إجمالي الربح
   double            m_totalLoss;           // إجمالي الخسارة
   double            m_netProfit;           // صافي الربح
   double            m_maxProfit;           // أقصى ربح
   double            m_maxLoss;             // أقصى خسارة
   double            m_avgProfit;           // متوسط الربح
   double            m_avgLoss;             // متوسط الخسارة
   
   // إحصائيات الأداء
   double            m_winRate;             // معدل النجاح
   double            m_profitFactor;        // عامل الربح
   double            m_sharpeRatio;         // نسبة شارب
   double            m_maxDD;               // أقصى سحب
   double            m_recoveryFactor;      // عامل التعافي
   
   // إحصائيات زمنية
   datetime          m_firstSignalTime;     // وقت أول إشارة
   datetime          m_lastSignalTime;      // وقت آخر إشارة
   double            m_avgHoldingTime;      // متوسط وقت الاحتفاظ
   
public:
                     CSignalStatistics();
                     ~CSignalStatistics();
   
   // تحديث الإحصائيات
   void              UpdateStatistics(const SPatternSignalInfo &signalInfo);
   void              RecalculateAll();
   void              Reset();
   
   // الحصول على الإحصائيات
   int               GetTotalSignals() const { return m_totalSignals; }
   int               GetExecutedSignals() const { return m_executedSignals; }
   int               GetSuccessfulSignals() const { return m_successfulSignals; }
   int               GetFailedSignals() const { return m_failedSignals; }
   double            GetWinRate() const { return m_winRate; }
   double            GetProfitFactor() const { return m_profitFactor; }
   double            GetNetProfit() const { return m_netProfit; }
   double            GetMaxDrawdown() const { return m_maxDD; }
   double            GetSharpeRatio() const { return m_sharpeRatio; }
   double            GetAvgProfit() const { return m_avgProfit; }
   double            GetAvgLoss() const { return m_avgLoss; }
   
   // طباعة التقرير
   void              PrintReport();
   void              SaveReport(const string fileName);
   string            GetReportString();
};

//+------------------------------------------------------------------+
//| الفئة الرئيسية لإدارة إشارات أنماط الشموع                        |
//+------------------------------------------------------------------+
class CPatternSignalManager : public CObject
{
private:
   // مصفوفات الإشارات (بدلاً من المؤشرات)
   SPatternSignalInfo m_signals[];         // مصفوفة الإشارات
   int               m_signalCount;         // عدد الإشارات
   int               m_maxSignals;          // الحد الأقصى للإشارات
   
   // كائنات التداول
   CTrade            m_trade;               // كائن التداول
   CPositionInfo     m_position;            // معلومات المراكز
   COrderInfo        m_order;               // معلومات الأوامر
   CAccountInfo      m_account;             // معلومات الحساب
   CSymbolInfo       m_symbolInfo;          // معلومات الرمز
   
   // الإحصائيات
   CSignalStatistics *m_statistics;         // إحصائيات الإشارات
   
   // الإعدادات
   SRiskManagementSettings m_riskSettings;  // إعدادات إدارة المخاطر
   SFilterSettings   m_filterSettings;      // إعدادات الفلتر
   SAlertSettings    m_alertSettings;       // إعدادات التنبيهات
   
   // معلمات التحكم
   bool              m_isEnabled;           // تمكين الإشارات
   bool              m_allowMultipleSignals; // السماح بإشارات متعددة
   int               m_signalExpiryBars;    // عدد الشموع لانتهاء الصلاحية
   int               m_magicNumber;         // الرقم السحري
   string            m_expertName;          // اسم الخبير
   
   // متغيرات التتبع
   datetime          m_lastUpdateTime;      // آخر وقت تحديث
   double            m_dailyPnL;            // الربح/الخسارة اليومية
   double            m_weeklyPnL;           // الربح/الخسارة الأسبوعية
   double            m_monthlyPnL;          // الربح/الخسارة الشهرية
   double            m_currentDrawdown;     // السحب الحالي
   int               m_consecutiveLosses;   // الخسائر المتتالية
   int               m_consecutiveWins;     // الأرباح المتتالية
   
   // دوال خاصة - التحقق والتصفية
   bool              ValidateSignal(const SPatternSignalInfo &signalInfo);
   bool              ApplyFilters(SPatternSignalInfo &signalInfo);
   bool              CheckTimeFilter(const SPatternSignalInfo &signalInfo);
   bool              CheckTrendFilter(const SPatternSignalInfo &signalInfo);
   bool              CheckVolatilityFilter(const SPatternSignalInfo &signalInfo);
   bool              CheckSpreadFilter(const SPatternSignalInfo &signalInfo);
   bool              CheckDrawdownFilter(const SPatternSignalInfo &signalInfo);
   
   // دوال خاصة - إدارة المخاطر
   double            CalculatePositionSize(const SPatternSignalInfo &signalInfo);
   void              CalculatePartialTargets(SPatternSignalInfo &signalInfo);
   bool              CheckRiskLimits(const SPatternSignalInfo &signalInfo);
   
   // دوال خاصة - التنفيذ
   bool              ExecuteBuySignal(const SPatternSignalInfo &signalInfo);
   bool              ExecuteSellSignal(const SPatternSignalInfo &signalInfo);
   bool              ExecuteCloseSignal(const SPatternSignalInfo &signalInfo);
   bool              ExecutePendingOrder(const SPatternSignalInfo &signalInfo);
   
   // دوال خاصة - التنبيهات
   void              SendAlert(const SPatternSignalInfo &signalInfo, const string message);
   void              SendEmailAlert(const SPatternSignalInfo &signalInfo, const string message);
   void              SendPushNotification(const SPatternSignalInfo &signalInfo, const string message);
   
   // دوال خاصة - الإدارة
   void              UpdateSignalStatus();
   void              UpdatePerformanceMetrics();
   void              CleanupExpiredSignals();
   int               FindSignalIndex(ulong orderTicket);
   int               FindSignalIndex(const string patternName, const string symbolName);
   void              SortSignalsByPriority();
   
   // دوال خاصة - التحليل
   double            CalculateSignalScore(const SPatternSignalInfo &signalInfo);
   bool              IsMarketSuitable();
   
public:
   // المنشئ والهادم
                     CPatternSignalManager(int maxSignals = 1000);
                     ~CPatternSignalManager();
   
   // التهيئة والإعداد
   bool              Initialize();
   void              Deinitialize();
   void              SetMagicNumber(int magic) { m_magicNumber = magic; m_trade.SetExpertMagicNumber(magic); }
   void              SetExpertName(const string name) { m_expertName = name; }
   
   // إدارة الإشارات الأساسية
   bool              AddSignal(const SPatternSignalInfo &signalInfo);
   bool              AddSignal(const string patternName, const string symbolName, ENUM_PATTERN_SIGNAL_TYPE signalType,
                              double entryPrice, double stopLoss, double takeProfit, 
                              ENUM_PATTERN_SIGNAL_STRENGTH strength = PATTERN_SIGNAL_STRENGTH_MEDIUM,
                              const string commentText = "");
   bool              RemoveSignal(int index);
   bool              RemoveSignal(ulong orderTicket);
   void              ClearSignals();
   void              ClearExpiredSignals();
   void              ClearSignalsByStatus(ENUM_PATTERN_SIGNAL_STATUS statusValue);
   
   // الحصول على الإشارات
   int               GetSignalCount() const { return m_signalCount; }
   bool              GetSignal(int index, SPatternSignalInfo &signalInfo);
   bool              GetLatestSignal(SPatternSignalInfo &signalInfo);
   bool              GetStrongestSignal(SPatternSignalInfo &signalInfo, ENUM_PATTERN_SIGNAL_TYPE signalType = PATTERN_SIGNAL_NONE);
   bool              GetSignalByTicket(ulong orderTicket, SPatternSignalInfo &signalInfo);
   
   // البحث والتصفية
   int               GetSignalsByType(ENUM_PATTERN_SIGNAL_TYPE signalType, SPatternSignalInfo &results[]);
   int               GetSignalsByStrength(ENUM_PATTERN_SIGNAL_STRENGTH minStrength, SPatternSignalInfo &results[]);
   int               GetSignalsBySymbol(const string symbolName, SPatternSignalInfo &results[]);
   int               GetSignalsByStatus(ENUM_PATTERN_SIGNAL_STATUS statusValue, SPatternSignalInfo &results[]);
   int               GetSignalsByTimeRange(datetime startTime, datetime endTime, SPatternSignalInfo &results[]);
   
   // تنفيذ الإشارات
   bool              ExecuteSignal(int index);
   bool              ExecuteSignalByInfo(const SPatternSignalInfo &signalInfo);
   bool              ExecuteAllSignals();
   bool              ExecuteSignalsByType(ENUM_PATTERN_SIGNAL_TYPE signalType);
   bool              ExecuteSignalsByStrength(ENUM_PATTERN_SIGNAL_STRENGTH minStrength);
   int               ExecutePendingSignals();
   
   // إدارة المراكز
   bool              ClosePosition(ulong ticket);
   bool              CloseAllPositions();
   bool              ClosePositionsBySymbol(const string symbolName);
   bool              ModifyPosition(ulong ticket, double newSL, double newTP);
   bool              SetTrailingStop(ulong ticket, double distance);
   
   // الإعدادات - إدارة المخاطر
   void              SetRiskSettings(const SRiskManagementSettings &settings) { m_riskSettings = settings; }
   void              GetRiskSettings(SRiskManagementSettings &settings) const { settings = m_riskSettings; }
   void              SetRiskPercent(double percent) { m_riskSettings.riskPercent = MathMax(0.1, MathMin(100.0, percent)); }
   void              SetMaxRiskPerTrade(double risk) { m_riskSettings.maxRiskPerTrade = MathMax(0.0, risk); }
   void              SetMinRiskReward(double ratio) { m_riskSettings.minRiskReward = MathMax(0.5, ratio); }
   
   // الإعدادات - الفلتر
   void              SetFilterSettings(const SFilterSettings &settings) { m_filterSettings = settings; }
   void              GetFilterSettings(SFilterSettings &settings) const { settings = m_filterSettings; }
   void              EnableTimeFilter(bool enable) { m_filterSettings.enableTimeFilter = enable; }
   void              SetTradingHours(int startHour, int endHour) { m_filterSettings.startHour = startHour; m_filterSettings.endHour = endHour; }
   void              EnableTrendFilter(bool enable) { m_filterSettings.enableTrendFilter = enable; }
   
   // الإعدادات - التنبيهات
   void              SetAlertSettings(const SAlertSettings &settings) { m_alertSettings = settings; }
   void              GetAlertSettings(SAlertSettings &settings) const { settings = m_alertSettings; }
   void              EnableAlerts(bool enable) { m_alertSettings.enableAlerts = enable; }
   void              EnableEmailAlerts(bool enable) { m_alertSettings.enableEmail = enable; }
   void              EnablePushNotifications(bool enable) { m_alertSettings.enablePush = enable; }
   
   // الإعدادات العامة
   void              SetEnabled(bool enabled) { m_isEnabled = enabled; }
   bool              IsEnabled() const { return m_isEnabled; }
   void              SetAllowMultipleSignals(bool allow) { m_allowMultipleSignals = allow; }
   void              SetSignalExpiryBars(int bars) { m_signalExpiryBars = MathMax(1, bars); }
   
   // التحديث والصيانة
   void              Update();
   void              OnTick();
   void              OnTimer();
   void              OnTrade();
   
   // الإحصائيات والتقارير
   CSignalStatistics* GetStatistics() { return m_statistics; }
   void              ResetStatistics() { if(m_statistics != NULL) m_statistics.Reset(); }
   double            GetCurrentDrawdown() const { return m_currentDrawdown; }
   double            GetDailyPnL() const { return m_dailyPnL; }
   double            GetWeeklyPnL() const { return m_weeklyPnL; }
   double            GetMonthlyPnL() const { return m_monthlyPnL; }
   
   // حفظ واستعادة الإعدادات
   bool              SaveSettings(const string fileName);
   bool              LoadSettings(const string fileName);
   bool              SaveSignals(const string fileName);
   bool              LoadSignals(const string fileName);
   
   // أدوات التشخيص والصيانة
   void              PrintSignals();
   void              PrintStatistics();
   string            GetStatusString();
   bool              CheckIntegrity();
   void              OptimizeMemory();
   
   // متقدم - تحليل الأداء
   double            CalculateExpectedReturn(const SPatternSignalInfo &signalInfo);
   double            CalculateVolatility(const string symbolName, int period = 20);
   double            CalculateATR(const string symbolName, int period = 14);
   bool              IsHighVolatilityPeriod(const string symbolName);
   
   // متقدم - الذكاء الاصطناعي
   double            PredictSignalSuccess(const SPatternSignalInfo &signalInfo);
   void              AdaptParameters();
   void              OptimizeRiskSettings();
   bool              ShouldReduceRisk();
   bool              ShouldIncreaseRisk();
};

//+------------------------------------------------------------------+
//| دوال مساعدة لتهيئة الهياكل                                        |
//+------------------------------------------------------------------+
void InitializePatternSignalInfo(SPatternSignalInfo &signalInfo)
{
   signalInfo.patternName = "";
   signalInfo.patternDescription = "";
   signalInfo.signalType = PATTERN_SIGNAL_NONE;
   signalInfo.strength = PATTERN_SIGNAL_STRENGTH_WEAK;
   signalInfo.priority = PATTERN_SIGNAL_PRIORITY_NORMAL;
   signalInfo.status = PATTERN_SIGNAL_STATUS_PENDING;
   
   signalInfo.symbolName = "";
   signalInfo.timeFrame = PERIOD_CURRENT;
   signalInfo.signalTime = 0;
   signalInfo.expiryTime = 0;
   signalInfo.activationTime = 0;
   
   signalInfo.signalPrice = 0.0;
   signalInfo.entryPrice = 0.0;
   signalInfo.stopLoss = 0.0;
   signalInfo.takeProfit = 0.0;
   signalInfo.trailingStop = 0.0;
   signalInfo.partialTP1 = 0.0;
   signalInfo.partialTP2 = 0.0;
   signalInfo.partialTP3 = 0.0;
   
   signalInfo.confidence = 0.0;
   signalInfo.riskReward = 0.0;
   signalInfo.winProbability = 0.0;
   signalInfo.expectedReturn = 0.0;
   signalInfo.maxRisk = 0.0;
   
   signalInfo.orderTicket = 0;
   signalInfo.executionTime = 0;
   signalInfo.executionPrice = 0.0;
   signalInfo.slippageValue = 0.0;
   signalInfo.commissionValue = 0.0;
   signalInfo.swapValue = 0.0;
   
   signalInfo.realizedPnL = 0.0;
   signalInfo.unrealizedPnL = 0.0;
   signalInfo.currentPrice = 0.0;
   signalInfo.maxDrawdown = 0.0;
   signalInfo.maxProfit = 0.0;
   
   signalInfo.commentText = "";
   signalInfo.magicNumber = 0;
   signalInfo.expertName = "";
   
   signalInfo.isFiltered = false;
   signalInfo.filterReason = "";
   signalInfo.filterScore = 0.0;
   
   signalInfo.barIndex = -1;
   signalInfo.volumeValue = 0;
   signalInfo.spreadValue = 0.0;
   signalInfo.volatilityValue = 0.0;
   signalInfo.atrValue = 0.0;
}

void InitializeRiskManagementSettings(SRiskManagementSettings &settings)
{
   settings.type = RISK_PERCENT_BALANCE;
   settings.riskPercent = 2.0;
   settings.maxRiskPerTrade = 1000.0;
   settings.maxDailyRisk = 5000.0;
   settings.maxWeeklyRisk = 15000.0;
   settings.maxMonthlyRisk = 50000.0;
   settings.minRiskReward = 1.5;
   settings.maxDrawdown = 20.0;
   settings.targetProfit = 1000.0;
   settings.useTrailingStop = true;
   settings.trailingDistance = 50.0;
   settings.usePartialTP = false;
   settings.partialTPPercent1 = 30.0;
   settings.partialTPPercent2 = 50.0;
   settings.partialTPPercent3 = 20.0;
   settings.enableHedging = false;
   settings.hedgingRatio = 0.5;
}

void InitializeFilterSettings(SFilterSettings &settings)
{
   settings.enableTimeFilter = true;
   settings.startHour = 8;
   settings.endHour = 18;
   settings.mondayEnabled = true;
   settings.tuesdayEnabled = true;
   settings.wednesdayEnabled = true;
   settings.thursdayEnabled = true;
   settings.fridayEnabled = true;
   
   settings.enableTrendFilter = true;
   settings.minTrendStrength = 0.6;
   
   settings.enableVolatilityFilter = false;
   settings.minVolatility = 0.0;
   settings.maxVolatility = 999.0;
   
   settings.enableSpreadFilter = true;
   settings.maxSpread = 3.0;
   
   settings.enableNewsFilter = false;
   settings.newsFilterMinutes = 30;
   
   settings.enableDrawdownFilter = true;
   settings.maxCurrentDrawdown = 15.0;
}

void InitializeAlertSettings(SAlertSettings &settings)
{
   settings.enableAlerts = true;
   settings.enablePopup = true;
   settings.enableSound = true;
   settings.soundFile = "alert.wav";
   settings.enableEmail = false;
   settings.emailTo = "";
   settings.enablePush = false;
   settings.alertOnSignal = true;
   settings.alertOnExecution = true;
   settings.alertOnProfit = true;
   settings.alertOnLoss = true;
   settings.alertOnError = true;
}

//+------------------------------------------------------------------+
//| منشئ فئة الإحصائيات                                              |
//+------------------------------------------------------------------+
CSignalStatistics::CSignalStatistics()
{
   Reset();
}

//+------------------------------------------------------------------+
//| هادم فئة الإحصائيات                                               |
//+------------------------------------------------------------------+
CSignalStatistics::~CSignalStatistics()
{
}

//+------------------------------------------------------------------+
//| إعادة تعيين الإحصائيات                                            |
//+------------------------------------------------------------------+
void CSignalStatistics::Reset()
{
   m_totalSignals = 0;
   m_executedSignals = 0;
   m_successfulSignals = 0;
   m_failedSignals = 0;
   
   m_totalProfit = 0.0;
   m_totalLoss = 0.0;
   m_netProfit = 0.0;
   m_maxProfit = 0.0;
   m_maxLoss = 0.0;
   m_avgProfit = 0.0;
   m_avgLoss = 0.0;
   
   m_winRate = 0.0;
   m_profitFactor = 0.0;
   m_sharpeRatio = 0.0;
   m_maxDD = 0.0;
   m_recoveryFactor = 0.0;
   
   m_firstSignalTime = 0;
   m_lastSignalTime = 0;
   m_avgHoldingTime = 0.0;
}

//+------------------------------------------------------------------+
//| تحديث الإحصائيات                                                 |
//+------------------------------------------------------------------+
void CSignalStatistics::UpdateStatistics(const SPatternSignalInfo &signalInfo)
{
   m_totalSignals++;
   
   if(signalInfo.status == PATTERN_SIGNAL_STATUS_EXECUTED)
   {
      m_executedSignals++;
      
      if(signalInfo.realizedPnL > 0)
      {
         m_successfulSignals++;
         m_totalProfit += signalInfo.realizedPnL;
         
         if(signalInfo.realizedPnL > m_maxProfit)
            m_maxProfit = signalInfo.realizedPnL;
      }
      else if(signalInfo.realizedPnL < 0)
      {
         m_failedSignals++;
         m_totalLoss += MathAbs(signalInfo.realizedPnL);
         
         if(MathAbs(signalInfo.realizedPnL) > m_maxLoss)
            m_maxLoss = MathAbs(signalInfo.realizedPnL);
      }
   }
   
   // تحديث الأوقات
   if(m_firstSignalTime == 0 || signalInfo.signalTime < m_firstSignalTime)
      m_firstSignalTime = signalInfo.signalTime;
      
   if(signalInfo.signalTime > m_lastSignalTime)
      m_lastSignalTime = signalInfo.signalTime;
   
   // إعادة حساب المقاييس
   RecalculateAll();
}

//+------------------------------------------------------------------+
//| إعادة حساب جميع المقاييس                                         |
//+------------------------------------------------------------------+
void CSignalStatistics::RecalculateAll()
{
   // صافي الربح
   m_netProfit = m_totalProfit - m_totalLoss;
   
   // معدل النجاح
   if(m_executedSignals > 0)
      m_winRate = (double)m_successfulSignals / m_executedSignals * 100.0;
   
   // عامل الربح
   if(m_totalLoss > 0)
      m_profitFactor = m_totalProfit / m_totalLoss;
   
   // متوسط الربح والخسارة
   if(m_successfulSignals > 0)
      m_avgProfit = m_totalProfit / m_successfulSignals;
   if(m_failedSignals > 0)
      m_avgLoss = m_totalLoss / m_failedSignals;
   
   // عامل التعافي  
   if(m_maxDD > 0)
      m_recoveryFactor = m_netProfit / m_maxDD;
}

//+------------------------------------------------------------------+
//| طباعة تقرير الإحصائيات                                           |
//+------------------------------------------------------------------+
void CSignalStatistics::PrintReport()
{
   Print("===== تقرير إحصائيات الإشارات =====");
   Print("إجمالي الإشارات: ", m_totalSignals);
   Print("الإشارات المنفذة: ", m_executedSignals);
   Print("الإشارات الناجحة: ", m_successfulSignals);
   Print("الإشارات الفاشلة: ", m_failedSignals);
   Print("معدل النجاح: ", DoubleToString(m_winRate, 2), "%");
   Print("صافي الربح: ", DoubleToString(m_netProfit, 2));
   Print("عامل الربح: ", DoubleToString(m_profitFactor, 2));
   Print("نسبة شارب: ", DoubleToString(m_sharpeRatio, 2));
   Print("أقصى سحب: ", DoubleToString(m_maxDD, 2));
   Print("====================================");
}

//+------------------------------------------------------------------+
//| الحصول على تقرير نصي                                             |
//+------------------------------------------------------------------+
string CSignalStatistics::GetReportString()
{
   string report = "";
   report += "===== تقرير إحصائيات الإشارات =====\n";
   report += "إجمالي الإشارات: " + IntegerToString(m_totalSignals) + "\n";
   report += "الإشارات المنفذة: " + IntegerToString(m_executedSignals) + "\n";
   report += "الإشارات الناجحة: " + IntegerToString(m_successfulSignals) + "\n";
   report += "الإشارات الفاشلة: " + IntegerToString(m_failedSignals) + "\n";
   report += "معدل النجاح: " + DoubleToString(m_winRate, 2) + "%\n";
   report += "صافي الربح: " + DoubleToString(m_netProfit, 2) + "\n";
   report += "عامل الربح: " + DoubleToString(m_profitFactor, 2) + "\n";
   report += "نسبة شارب: " + DoubleToString(m_sharpeRatio, 2) + "\n";
   report += "أقصى سحب: " + DoubleToString(m_maxDD, 2) + "\n";
   report += "====================================";
   return report;
}

//+------------------------------------------------------------------+
//| حفظ التقرير في ملف                                               |
//+------------------------------------------------------------------+
void CSignalStatistics::SaveReport(const string fileName)
{
   int handle = FileOpen(fileName, FILE_WRITE | FILE_TXT);
   if(handle != INVALID_HANDLE)
   {
      FileWriteString(handle, GetReportString());
      FileClose(handle);
      Print("تم حفظ التقرير في: ", fileName);
   }
   else
   {
      Print("فشل في حفظ التقرير: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| منشئ الفئة الرئيسية                                              |
//+------------------------------------------------------------------+
CPatternSignalManager::CPatternSignalManager(int maxSignals)
{
   m_maxSignals = MathMax(10, maxSignals);
   m_signalCount = 0;
   ArrayResize(m_signals, m_maxSignals);
   
   // تهيئة الكائنات
   m_statistics = new CSignalStatistics();
   
   // الإعدادات الافتراضية
   InitializeRiskManagementSettings(m_riskSettings);
   InitializeFilterSettings(m_filterSettings);
   InitializeAlertSettings(m_alertSettings);
   
   // معلمات التحكم
   m_isEnabled = true;
   m_allowMultipleSignals = false;
   m_signalExpiryBars = 5;
   m_magicNumber = 123456;
   m_expertName = "Pattern Signal Manager";
   
   // متغيرات التتبع
   m_lastUpdateTime = 0;
   m_dailyPnL = 0.0;
   m_weeklyPnL = 0.0;
   m_monthlyPnL = 0.0;
   m_currentDrawdown = 0.0;
   m_consecutiveLosses = 0;
   m_consecutiveWins = 0;
   
   // تهيئة كائن التداول
   m_trade.SetExpertMagicNumber(m_magicNumber);
   m_trade.SetDeviationInPoints(10);
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   m_trade.SetTypeFillingBySymbol(Symbol());
}

//+------------------------------------------------------------------+
//| هادم الفئة الرئيسية                                              |
//+------------------------------------------------------------------+
CPatternSignalManager::~CPatternSignalManager()
{
   Deinitialize();
   
   if(m_statistics != NULL)
   {
      delete m_statistics;
      m_statistics = NULL;
   }
}

//+------------------------------------------------------------------+
//| تهيئة النظام                                                     |
//+------------------------------------------------------------------+
bool CPatternSignalManager::Initialize()
{
   // تحديد خصائص الرمز
   m_symbolInfo.Name(Symbol());
   m_symbolInfo.Refresh();
   
   // تحديث معلومات الحساب
   m_account.Login();
   
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء النظام                                                     |
//+------------------------------------------------------------------+
void CPatternSignalManager::Deinitialize()
{
   ClearSignals();
}

//+------------------------------------------------------------------+
//| إضافة إشارة جديدة (الإصدار المتقدم)                               |
//+------------------------------------------------------------------+
bool CPatternSignalManager::AddSignal(const SPatternSignalInfo &signalInfo)
{
   if(!m_isEnabled)
      return false;
      
   // التحقق من صحة الإشارة
   if(!ValidateSignal(signalInfo))
   {
      Print("فشل في التحقق من صحة الإشارة: ", signalInfo.patternName);
      return false;
   }
   
   // إنشاء نسخة قابلة للتعديل
   SPatternSignalInfo newSignal = signalInfo;
   
   // تطبيق الفلاتر
   if(!ApplyFilters(newSignal))
   {
      Print("تم فلترة الإشارة: ", newSignal.patternName, " - السبب: ", newSignal.filterReason);
      return false;
   }
   
   // التحقق من عدم السماح بإشارات متعددة
   if(!m_allowMultipleSignals)
   {
      for(int i = 0; i < m_signalCount; i++)
      {
         if(m_signals[i].symbolName == newSignal.symbolName && 
            m_signals[i].signalType == newSignal.signalType &&
            m_signals[i].status == PATTERN_SIGNAL_STATUS_PENDING)
         {
            Print("إشارة مماثلة موجودة بالفعل للرمز: ", newSignal.symbolName);
            return false;
         }
      }
   }
   
   // التحقق من وجود مساحة كافية
   if(m_signalCount >= m_maxSignals)
   {
      // إزالة أقدم إشارة منتهية الصلاحية
      CleanupExpiredSignals();
      
      if(m_signalCount >= m_maxSignals)
      {
         Print("تم الوصول للحد الأقصى من الإشارات");
         return false;
      }
   }
   
   // تحديد معلومات إضافية
   newSignal.magicNumber = m_magicNumber;
   newSignal.expertName = m_expertName;
   newSignal.signalTime = TimeCurrent();
   
   if(newSignal.expiryTime == 0)
      newSignal.expiryTime = TimeCurrent() + m_signalExpiryBars * PeriodSeconds();
   
   // حساب حجم المركز المقترح
   double lotSize = CalculatePositionSize(newSignal);
   if(lotSize <= 0)
   {
      Print("فشل في حساب حجم المركز للإشارة: ", newSignal.patternName);
      return false;
   }
   
   // حساب الأهداف الجزئية
   if(m_riskSettings.usePartialTP)
      CalculatePartialTargets(newSignal);
   
   // إضافة الإشارة
   m_signals[m_signalCount] = newSignal;
   m_signalCount++;
   
   // تحديث الإحصائيات
   if(m_statistics != NULL)
      m_statistics.UpdateStatistics(newSignal);
   
   // إرسال تنبيه
   if(m_alertSettings.alertOnSignal)
   {
      string message = StringFormat("إشارة جديدة: %s | %s | %s | القوة: %d | الثقة: %.1f%%",
         newSignal.patternName, newSignal.symbolName, EnumToString(newSignal.signalType),
         newSignal.strength, newSignal.confidence * 100);
      SendAlert(newSignal, message);
   }
   
   // ترتيب الإشارات حسب الأولوية
   SortSignalsByPriority();
   
   return true;
}

//+------------------------------------------------------------------+
//| إضافة إشارة جديدة (الإصدار المبسط)                               |
//+------------------------------------------------------------------+
bool CPatternSignalManager::AddSignal(const string patternName, const string symbolName, ENUM_PATTERN_SIGNAL_TYPE signalType,
                              double entryPrice, double stopLoss, double takeProfit, 
                              ENUM_PATTERN_SIGNAL_STRENGTH strength, const string commentText)
{
   SPatternSignalInfo signalInfo;
   InitializePatternSignalInfo(signalInfo);
   
   signalInfo.patternName = patternName;
   signalInfo.symbolName = symbolName;
   signalInfo.signalType = signalType;
   signalInfo.entryPrice = entryPrice;
   signalInfo.stopLoss = stopLoss;
   signalInfo.takeProfit = takeProfit;
   signalInfo.strength = strength;
   signalInfo.commentText = commentText;
   signalInfo.signalPrice = entryPrice;
   signalInfo.confidence = 0.7; // قيمة افتراضية
   
   // حساب نسبة المخاطرة للعائد
   if(signalType == PATTERN_SIGNAL_BUY && stopLoss < entryPrice && takeProfit > entryPrice)
   {
      double risk = entryPrice - stopLoss;
      double reward = takeProfit - entryPrice;
      signalInfo.riskReward = (risk > 0) ? reward / risk : 0.0;
   }
   else if(signalType == PATTERN_SIGNAL_SELL && stopLoss > entryPrice && takeProfit < entryPrice)
   {
      double risk = stopLoss - entryPrice;
      double reward = entryPrice - takeProfit;
      signalInfo.riskReward = (risk > 0) ? reward / risk : 0.0;
   }
   
   return AddSignal(signalInfo);
}

//+------------------------------------------------------------------+
//| التحقق من صحة الإشارة                                            |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ValidateSignal(const SPatternSignalInfo &signalInfo)
{
   // التحقق من المعلومات الأساسية
   if(signalInfo.signalType == PATTERN_SIGNAL_NONE)
      return false;
      
   if(signalInfo.symbolName == "")
      return false;
      
   if(signalInfo.patternName == "")
      return false;
   
   // التحقق من الأسعار للإشارات التي تتطلب دخول
   if(signalInfo.signalType == PATTERN_SIGNAL_BUY || signalInfo.signalType == PATTERN_SIGNAL_SELL)
   {
      if(signalInfo.entryPrice <= 0.0)
         return false;
         
      // التحقق من وقف الخسارة وجني الأرباح
      if(signalInfo.signalType == PATTERN_SIGNAL_BUY)
      {
         if(signalInfo.stopLoss >= signalInfo.entryPrice || signalInfo.takeProfit <= signalInfo.entryPrice)
            return false;
      }
      else if(signalInfo.signalType == PATTERN_SIGNAL_SELL)
      {
         if(signalInfo.stopLoss <= signalInfo.entryPrice || signalInfo.takeProfit >= signalInfo.entryPrice)
            return false;
      }
      
      // التحقق من نسبة المخاطرة للعائد
      if(signalInfo.riskReward < m_riskSettings.minRiskReward)
         return false;
   }
   
   // التحقق من درجة الثقة
   if(signalInfo.confidence < 0.0 || signalInfo.confidence > 1.0)
      return false;
   
   // التحقق من القوة
   if(signalInfo.strength < PATTERN_SIGNAL_STRENGTH_VERY_WEAK || signalInfo.strength > PATTERN_SIGNAL_STRENGTH_VERY_STRONG)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| تطبيق الفلاتر على الإشارة                                        |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ApplyFilters(SPatternSignalInfo &signalInfo)
{
   // فلتر الوقت
   if(m_filterSettings.enableTimeFilter && !CheckTimeFilter(signalInfo))
   {
      signalInfo.isFiltered = true;
      signalInfo.filterReason = "خارج ساعات التداول المسموحة";
      return false;
   }
   
   // فلتر الاتجاه
   if(m_filterSettings.enableTrendFilter && !CheckTrendFilter(signalInfo))
   {
      signalInfo.isFiltered = true;
      signalInfo.filterReason = "الإشارة لا تتفق مع الاتجاه العام";
      return false;
   }
   
   // فلتر التقلبات
   if(m_filterSettings.enableVolatilityFilter && !CheckVolatilityFilter(signalInfo))
   {
      signalInfo.isFiltered = true;
      signalInfo.filterReason = "التقلبات خارج النطاق المسموح";
      return false;
   }
   
   // فلتر السبريد
   if(m_filterSettings.enableSpreadFilter && !CheckSpreadFilter(signalInfo))
   {
      signalInfo.isFiltered = true;
      signalInfo.filterReason = "السبريد أعلى من المسموح";
      return false;
   }
   
   // فلتر السحب
   if(m_filterSettings.enableDrawdownFilter && !CheckDrawdownFilter(signalInfo))
   {
      signalInfo.isFiltered = true;
      signalInfo.filterReason = "السحب الحالي أعلى من المسموح";
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص فلتر الوقت                                                   |
//+------------------------------------------------------------------+
bool CPatternSignalManager::CheckTimeFilter(const SPatternSignalInfo &signalInfo)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // فحص اليوم
   switch(dt.day_of_week)
   {
      case 1: if(!m_filterSettings.mondayEnabled) return false; break;
      case 2: if(!m_filterSettings.tuesdayEnabled) return false; break;
      case 3: if(!m_filterSettings.wednesdayEnabled) return false; break;
      case 4: if(!m_filterSettings.thursdayEnabled) return false; break;
      case 5: if(!m_filterSettings.fridayEnabled) return false; break;
      default: return false; // السبت والأحد
   }
   
   // فحص الساعة
   if(dt.hour < m_filterSettings.startHour || dt.hour >= m_filterSettings.endHour)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص فلتر الاتجاه                                                 |
//+------------------------------------------------------------------+
bool CPatternSignalManager::CheckTrendFilter(const SPatternSignalInfo &signalInfo)
{
   // فلتر بسيط بناءً على حركة الأسعار
   double currentPrice = SymbolInfoDouble(signalInfo.symbolName, SYMBOL_BID);
   double prevPrice = iClose(signalInfo.symbolName, PERIOD_H1, 1);
   
   if(prevPrice <= 0) return true;
   
   bool isUpTrend = currentPrice > prevPrice;
   
   // التحقق من توافق الإشارة مع الاتجاه
   if(signalInfo.signalType == PATTERN_SIGNAL_BUY && !isUpTrend)
      return false;
   if(signalInfo.signalType == PATTERN_SIGNAL_SELL && isUpTrend)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص فلتر التقلبات                                                |
//+------------------------------------------------------------------+
bool CPatternSignalManager::CheckVolatilityFilter(const SPatternSignalInfo &signalInfo)
{
   double volatility = CalculateVolatility(signalInfo.symbolName);
   
   if(volatility < m_filterSettings.minVolatility || volatility > m_filterSettings.maxVolatility)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص فلتر السبريد                                                 |
//+------------------------------------------------------------------+
bool CPatternSignalManager::CheckSpreadFilter(const SPatternSignalInfo &signalInfo)
{
   m_symbolInfo.Name(signalInfo.symbolName);
   m_symbolInfo.Refresh();
   
   double spread = m_symbolInfo.Spread() * m_symbolInfo.Point();
   double spreadInPips = spread / (m_symbolInfo.Point() * 10);
   
   if(spreadInPips > m_filterSettings.maxSpread)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| فحص فلتر السحب                                                   |
//+------------------------------------------------------------------+
bool CPatternSignalManager::CheckDrawdownFilter(const SPatternSignalInfo &signalInfo)
{
   if(m_currentDrawdown > m_filterSettings.maxCurrentDrawdown)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| حساب حجم المركز                                                  |
//+------------------------------------------------------------------+
double CPatternSignalManager::CalculatePositionSize(const SPatternSignalInfo &signalInfo)
{
   // الحصول على معلومات الحساب
   double accountBalance = m_account.Balance();
   double accountEquity = m_account.Equity();
   
   // الحصول على معلومات الرمز
   m_symbolInfo.Name(signalInfo.symbolName);
   m_symbolInfo.Refresh();
   
   double minLot = m_symbolInfo.LotsMin();
   double maxLot = m_symbolInfo.LotsMax();
   double lotStep = m_symbolInfo.LotsStep();
   double tickValue = m_symbolInfo.TickValue();
   double tickSize = m_symbolInfo.TickSize();
   double point = m_symbolInfo.Point();
   
   double lotSize = 0.0;
   
   switch(m_riskSettings.type)
   {
      case RISK_FIXED_LOTS:
         lotSize = minLot;
         break;
         
      case RISK_FIXED_AMOUNT:
         {
            double stopDistance = MathAbs(signalInfo.entryPrice - signalInfo.stopLoss);
            if(stopDistance > 0 && tickValue > 0)
            {
               double pointValue = tickValue * (point / tickSize);
               lotSize = m_riskSettings.maxRiskPerTrade / (stopDistance * pointValue);
            }
         }
         break;
         
      case RISK_PERCENT_BALANCE:
         {
            double riskAmount = accountBalance * m_riskSettings.riskPercent / 100.0;
            riskAmount = MathMin(riskAmount, m_riskSettings.maxRiskPerTrade);
            
            double stopDistance = MathAbs(signalInfo.entryPrice - signalInfo.stopLoss);
            if(stopDistance > 0 && tickValue > 0)
            {
               double pointValue = tickValue * (point / tickSize);
               lotSize = riskAmount / (stopDistance * pointValue);
            }
         }
         break;
         
      case RISK_PERCENT_EQUITY:
         {
            double riskAmount = accountEquity * m_riskSettings.riskPercent / 100.0;
            riskAmount = MathMin(riskAmount, m_riskSettings.maxRiskPerTrade);
            
            double stopDistance = MathAbs(signalInfo.entryPrice - signalInfo.stopLoss);
            if(stopDistance > 0 && tickValue > 0)
            {
               double pointValue = tickValue * (point / tickSize);
               lotSize = riskAmount / (stopDistance * pointValue);
            }
         }
         break;
         
      default:
         lotSize = minLot;
         break;
   }
   
   // تطبيق الحدود
   if(lotSize > 0)
   {
      // تقريب إلى أقرب خطوة صحيحة
      lotSize = MathFloor(lotSize / lotStep) * lotStep;
      
      // تطبيق الحد الأدنى والأقصى
      lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
      
      // التحقق من حدود المخاطرة
      double stopDistance = MathAbs(signalInfo.entryPrice - signalInfo.stopLoss);
      double pointValue = tickValue * (point / tickSize);
      double potentialLoss = stopDistance * pointValue * lotSize;
      
      if(potentialLoss > m_riskSettings.maxRiskPerTrade)
      {
         lotSize = m_riskSettings.maxRiskPerTrade / (stopDistance * pointValue);
         lotSize = MathFloor(lotSize / lotStep) * lotStep;
         lotSize = MathMax(minLot, lotSize);
      }
   }
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| حساب الأهداف الجزئية                                             |
//+------------------------------------------------------------------+
void CPatternSignalManager::CalculatePartialTargets(SPatternSignalInfo &signalInfo)
{
   if(!m_riskSettings.usePartialTP)
      return;
   
   double totalDistance = MathAbs(signalInfo.takeProfit - signalInfo.entryPrice);
   
   if(signalInfo.signalType == PATTERN_SIGNAL_BUY)
   {
      signalInfo.partialTP1 = signalInfo.entryPrice + (totalDistance * m_riskSettings.partialTPPercent1 / 100.0);
      signalInfo.partialTP2 = signalInfo.entryPrice + (totalDistance * (m_riskSettings.partialTPPercent1 + m_riskSettings.partialTPPercent2) / 100.0);
      signalInfo.partialTP3 = signalInfo.takeProfit;
   }
   else if(signalInfo.signalType == PATTERN_SIGNAL_SELL)
   {
      signalInfo.partialTP1 = signalInfo.entryPrice - (totalDistance * m_riskSettings.partialTPPercent1 / 100.0);
      signalInfo.partialTP2 = signalInfo.entryPrice - (totalDistance * (m_riskSettings.partialTPPercent1 + m_riskSettings.partialTPPercent2) / 100.0);
      signalInfo.partialTP3 = signalInfo.takeProfit;
   }
}

//+------------------------------------------------------------------+
//| التحقق من حدود المخاطرة                                          |
//+------------------------------------------------------------------+
bool CPatternSignalManager::CheckRiskLimits(const SPatternSignalInfo &signalInfo)
{
   // التحقق من الحد الأقصى للمخاطرة لكل صفقة
   double potentialLoss = MathAbs(signalInfo.entryPrice - signalInfo.stopLoss) * CalculatePositionSize(signalInfo);
   
   if(potentialLoss > m_riskSettings.maxRiskPerTrade)
      return false;
   
   // التحقق من الحد الأقصى للسحب
   if(m_currentDrawdown > m_riskSettings.maxDrawdown)
      return false;
   
   // التحقق من الخسائر المتتالية
   if(m_consecutiveLosses >= 5) // حد أقصى 5 خسائر متتالية
      return false;
   
   // التحقق من المخاطرة اليومية
   if(MathAbs(m_dailyPnL) > m_riskSettings.maxDailyRisk)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| تنفيذ الإشارة                                                     |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ExecuteSignal(int index)
{
   if(index < 0 || index >= m_signalCount)
      return false;
   
   return ExecuteSignalByInfo(m_signals[index]);
}

//+------------------------------------------------------------------+
//| تنفيذ الإشارة بواسطة المعلومات                                    |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ExecuteSignalByInfo(const SPatternSignalInfo &signalInfo)
{
   if(!m_isEnabled)
      return false;
   
   // التحقق من حالة الإشارة
   if(signalInfo.status != PATTERN_SIGNAL_STATUS_PENDING)
      return false;
   
   // التحقق من انتهاء الصلاحية
   if(signalInfo.expiryTime > 0 && TimeCurrent() > signalInfo.expiryTime)
      return false;
   
   // التحقق من شروط السوق
   if(!IsMarketSuitable())
   {
      Print("ظروف السوق غير مناسبة للتداول");
      return false;
   }
   
   // التحقق من حدود المخاطرة
   if(!CheckRiskLimits(signalInfo))
      return false;
   
   bool result = false;
   
   // تنفيذ الإشارة حسب النوع
   switch(signalInfo.signalType)
   {
      case PATTERN_SIGNAL_BUY:
         result = ExecuteBuySignal(signalInfo);
         break;
         
      case PATTERN_SIGNAL_SELL:
         result = ExecuteSellSignal(signalInfo);
         break;
         
      case PATTERN_SIGNAL_CLOSE_BUY:
      case PATTERN_SIGNAL_CLOSE_SELL:
         result = ExecuteCloseSignal(signalInfo);
         break;
         
      case PATTERN_SIGNAL_PENDING_BUY_STOP:
      case PATTERN_SIGNAL_PENDING_SELL_STOP:
      case PATTERN_SIGNAL_PENDING_BUY_LIMIT:
      case PATTERN_SIGNAL_PENDING_SELL_LIMIT:
         result = ExecutePendingOrder(signalInfo);
         break;
         
      default:
         result = false;
         break;
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| تنفيذ إشارة الشراء                                               |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ExecuteBuySignal(const SPatternSignalInfo &signalInfo)
{
   // حساب حجم المركز
   double lotSize = CalculatePositionSize(signalInfo);
   if(lotSize <= 0)
      return false;
   
   // تحديث معلومات الرمز
   m_symbolInfo.Name(signalInfo.symbolName);
   m_symbolInfo.Refresh();
   
   // تنفيذ أمر الشراء
   bool result = m_trade.Buy(lotSize, signalInfo.symbolName, signalInfo.entryPrice, 
                           signalInfo.stopLoss, signalInfo.takeProfit, 
                           "Pattern: " + signalInfo.patternName);
   
   return result;
}

//+------------------------------------------------------------------+
//| تنفيذ إشارة البيع                                                |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ExecuteSellSignal(const SPatternSignalInfo &signalInfo)
{
   // حساب حجم المركز
   double lotSize = CalculatePositionSize(signalInfo);
   if(lotSize <= 0)
      return false;
   
   // تحديث معلومات الرمز
   m_symbolInfo.Name(signalInfo.symbolName);
   m_symbolInfo.Refresh();
   
   // تنفيذ أمر البيع
   bool result = m_trade.Sell(lotSize, signalInfo.symbolName, signalInfo.entryPrice, 
                            signalInfo.stopLoss, signalInfo.takeProfit, 
                            "Pattern: " + signalInfo.patternName);
   
   return result;
}

//+------------------------------------------------------------------+
//| تنفيذ إشارة الإغلاق                                              |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ExecuteCloseSignal(const SPatternSignalInfo &signalInfo)
{
   bool result = false;
   
   // البحث عن المراكز المفتوحة للرمز
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i))
      {
         if(m_position.Symbol() == signalInfo.symbolName && m_position.Magic() == m_magicNumber)
         {
            // تحديد ما إذا كان يجب إغلاق هذا المركز
            bool shouldClose = false;
            
            if(signalInfo.signalType == PATTERN_SIGNAL_CLOSE_BUY && m_position.PositionType() == POSITION_TYPE_BUY)
               shouldClose = true;
            else if(signalInfo.signalType == PATTERN_SIGNAL_CLOSE_SELL && m_position.PositionType() == POSITION_TYPE_SELL)
               shouldClose = true;
            
            if(shouldClose)
            {
               result = m_trade.PositionClose(m_position.Ticket());
               if(result)
                  break; // إغلاق مركز واحد فقط
            }
         }
      }
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| تنفيذ الأوامر المعلقة                                             |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ExecutePendingOrder(const SPatternSignalInfo &signalInfo)
{
   double lotSize = CalculatePositionSize(signalInfo);
   if(lotSize <= 0)
      return false;
   
   m_symbolInfo.Name(signalInfo.symbolName);
   m_symbolInfo.Refresh();
   
   bool result = false;
   
   switch(signalInfo.signalType)
   {
      case PATTERN_SIGNAL_PENDING_BUY_STOP:
         result = m_trade.BuyStop(lotSize, signalInfo.entryPrice, signalInfo.symbolName, 
                                signalInfo.stopLoss, signalInfo.takeProfit, ORDER_TIME_GTC, 0,
                                "Pattern: " + signalInfo.patternName);
         break;
         
      case PATTERN_SIGNAL_PENDING_SELL_STOP:
         result = m_trade.SellStop(lotSize, signalInfo.entryPrice, signalInfo.symbolName, 
                                 signalInfo.stopLoss, signalInfo.takeProfit, ORDER_TIME_GTC, 0,
                                 "Pattern: " + signalInfo.patternName);
         break;
         
      case PATTERN_SIGNAL_PENDING_BUY_LIMIT:
         result = m_trade.BuyLimit(lotSize, signalInfo.entryPrice, signalInfo.symbolName, 
                                 signalInfo.stopLoss, signalInfo.takeProfit, ORDER_TIME_GTC, 0,
                                 "Pattern: " + signalInfo.patternName);
         break;
         
      case PATTERN_SIGNAL_PENDING_SELL_LIMIT:
         result = m_trade.SellLimit(lotSize, signalInfo.entryPrice, signalInfo.symbolName, 
                                  signalInfo.stopLoss, signalInfo.takeProfit, ORDER_TIME_GTC, 0,
                                  "Pattern: " + signalInfo.patternName);
         break;
         
      default:
         result = false;
         break;
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| إرسال التنبيهات                                                  |
//+------------------------------------------------------------------+
void CPatternSignalManager::SendAlert(const SPatternSignalInfo &signalInfo, const string message)
{
   if(!m_alertSettings.enableAlerts)
      return;
   
   // تنبيه منبثق
   if(m_alertSettings.enablePopup)
      Alert(message);
   
   // تنبيه صوتي
   if(m_alertSettings.enableSound && m_alertSettings.soundFile != "")
      PlaySound(m_alertSettings.soundFile);
   
   // بريد إلكتروني
   if(m_alertSettings.enableEmail)
      SendEmailAlert(signalInfo, message);
   
   // إشعار دفع
   if(m_alertSettings.enablePush)
      SendPushNotification(signalInfo, message);
}

//+------------------------------------------------------------------+
//| إرسال بريد إلكتروني                                             |
//+------------------------------------------------------------------+
void CPatternSignalManager::SendEmailAlert(const SPatternSignalInfo &signalInfo, const string message)
{
   string subject = "إشارة نمط الشموع - " + signalInfo.symbolName;
   string body = message + "\n\n";
   body += "التفاصيل:\n";
   body += "النمط: " + signalInfo.patternName + "\n";
   body += "الرمز: " + signalInfo.symbolName + "\n";
   body += "السعر: " + DoubleToString(signalInfo.signalPrice, 5) + "\n";
   body += "الوقت: " + TimeToString(signalInfo.signalTime) + "\n";
   
   SendMail(subject, body);
}

//+------------------------------------------------------------------+
//| إرسال إشعار دفع                                                  |
//+------------------------------------------------------------------+
void CPatternSignalManager::SendPushNotification(const SPatternSignalInfo &signalInfo, const string message)
{
   string pushMessage = signalInfo.symbolName + ": " + message;
   SendNotification(pushMessage);
}

//+------------------------------------------------------------------+
//| تحديث النظام                                                     |
//+------------------------------------------------------------------+
void CPatternSignalManager::Update()
{
   if(!m_isEnabled)
      return;
   
   // تنظيف الإشارات المنتهية الصلاحية
   CleanupExpiredSignals();
   
   // تحديث حالة الإشارات
   UpdateSignalStatus();
   
   // تحديث مقاييس الأداء
   UpdatePerformanceMetrics();
   
   // تطبيق الوقف المتحرك
   if(m_riskSettings.useTrailingStop)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         if(m_position.SelectByIndex(i) && m_position.Magic() == m_magicNumber)
         {
            SetTrailingStop(m_position.Ticket(), m_riskSettings.trailingDistance);
         }
      }
   }
   
   m_lastUpdateTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| تحديث حالة الإشارات                                              |
//+------------------------------------------------------------------+
void CPatternSignalManager::UpdateSignalStatus()
{
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].status == PATTERN_SIGNAL_STATUS_EXECUTED && m_signals[i].orderTicket > 0)
      {
         // تحديث الربح/الخسارة الحالية
         if(m_position.SelectByTicket(m_signals[i].orderTicket))
         {
            m_signals[i].unrealizedPnL = m_position.Profit();
            m_signals[i].currentPrice = m_position.PriceCurrent();
            
            // تحديث أقصى ربح/سحب
            if(m_signals[i].unrealizedPnL > m_signals[i].maxProfit)
               m_signals[i].maxProfit = m_signals[i].unrealizedPnL;
            
            if(m_signals[i].unrealizedPnL < m_signals[i].maxDrawdown)
               m_signals[i].maxDrawdown = m_signals[i].unrealizedPnL;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| تحديث مقاييس الأداء                                              |
//+------------------------------------------------------------------+
void CPatternSignalManager::UpdatePerformanceMetrics()
{
   // حساب الربح/الخسارة اليومية
   m_dailyPnL = 0.0;
   datetime todayStart = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].executionTime >= todayStart)
      {
         m_dailyPnL += m_signals[i].realizedPnL + m_signals[i].unrealizedPnL;
      }
   }
   
   // حساب السحب الحالي
   double currentEquity = m_account.Equity();
   double balance = m_account.Balance();
   
   if(currentEquity < balance)
   {
      m_currentDrawdown = (balance - currentEquity) / balance * 100.0;
   }
   else
   {
      m_currentDrawdown = 0.0;
   }
}

//+------------------------------------------------------------------+
//| تنظيف الإشارات المنتهية الصلاحية                                 |
//+------------------------------------------------------------------+
void CPatternSignalManager::CleanupExpiredSignals()
{
   datetime currentTime = TimeCurrent();
   
   for(int i = m_signalCount - 1; i >= 0; i--)
   {
      if(m_signals[i].status == PATTERN_SIGNAL_STATUS_PENDING && 
         m_signals[i].expiryTime > 0 && 
         currentTime > m_signals[i].expiryTime)
      {
         m_signals[i].status = PATTERN_SIGNAL_STATUS_EXPIRED;
      }
      
      // إزالة الإشارات القديمة المنتهية أو المنفذة (أكثر من 24 ساعة)
      if((m_signals[i].status == PATTERN_SIGNAL_STATUS_EXPIRED || 
          m_signals[i].status == PATTERN_SIGNAL_STATUS_EXECUTED ||
          m_signals[i].status == PATTERN_SIGNAL_STATUS_CANCELLED) &&
         currentTime - m_signals[i].signalTime > 86400) // 24 ساعة
      {
         RemoveSignal(i);
      }
   }
}

//+------------------------------------------------------------------+
//| حذف إشارة                                                        |
//+------------------------------------------------------------------+
bool CPatternSignalManager::RemoveSignal(int index)
{
   if(index < 0 || index >= m_signalCount)
      return false;
   
   // نقل الإشارات للأعلى
   for(int i = index; i < m_signalCount - 1; i++)
   {
      m_signals[i] = m_signals[i + 1];
   }
   
   m_signalCount--;
   return true;
}

//+------------------------------------------------------------------+
//| حذف إشارة بواسطة رقم التيكت                                       |
//+------------------------------------------------------------------+
bool CPatternSignalManager::RemoveSignal(ulong orderTicket)
{
   int index = FindSignalIndex(orderTicket);
   if(index >= 0)
      return RemoveSignal(index);
   
   return false;
}

//+------------------------------------------------------------------+
//| مسح جميع الإشارات                                                |
//+------------------------------------------------------------------+
void CPatternSignalManager::ClearSignals()
{
   m_signalCount = 0;
   // إعادة تهيئة المصفوفة بدلاً من ArrayInitialize
   for(int i = 0; i < ArraySize(m_signals); i++)
   {
      InitializePatternSignalInfo(m_signals[i]);
   }
}

//+------------------------------------------------------------------+
//| البحث عن مؤشر الإشارة بواسطة رقم التيكت                          |
//+------------------------------------------------------------------+
int CPatternSignalManager::FindSignalIndex(ulong orderTicket)
{
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].orderTicket == orderTicket)
         return i;
   }
   
   return -1;
}

//+------------------------------------------------------------------+
//| البحث عن مؤشر الإشارة بواسطة النمط والرمز                        |
//+------------------------------------------------------------------+
int CPatternSignalManager::FindSignalIndex(const string patternName, const string symbolName)
{
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].patternName == patternName && m_signals[i].symbolName == symbolName)
         return i;
   }
   
   return -1;
}

//+------------------------------------------------------------------+
//| ترتيب الإشارات حسب الأولوية                                       |
//+------------------------------------------------------------------+
void CPatternSignalManager::SortSignalsByPriority()
{
   // خوارزمية الفقاعة للترتيب حسب الأولوية والقوة
   for(int i = 0; i < m_signalCount - 1; i++)
   {
      for(int j = i + 1; j < m_signalCount; j++)
      {
         double score1 = CalculateSignalScore(m_signals[i]);
         double score2 = CalculateSignalScore(m_signals[j]);
         
         if(score2 > score1)
         {
            // تبديل الإشارات
            SPatternSignalInfo temp = m_signals[i];
            m_signals[i] = m_signals[j];
            m_signals[j] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| حساب نقاط الإشارة                                                |
//+------------------------------------------------------------------+
double CPatternSignalManager::CalculateSignalScore(const SPatternSignalInfo &signalInfo)
{
   double score = 0.0;
   
   // نقاط القوة (0-5)
   score += (double)signalInfo.strength;
   
   // نقاط الثقة (0-10)
   score += signalInfo.confidence * 10.0;
   
   // نقاط الأولوية (0-5)
   score += (double)signalInfo.priority;
   
   // نقاط نسبة المخاطرة للعائد (0-5)
   if(signalInfo.riskReward >= 3.0)
      score += 5.0;
   else if(signalInfo.riskReward >= 2.0)
      score += 3.0;
   else if(signalInfo.riskReward >= 1.5)
      score += 1.0;
   
   // خصم للإشارات المفلترة
   if(signalInfo.isFiltered)
      score *= 0.5;
   
   return score;
}

//+------------------------------------------------------------------+
//| فحص ما إذا كان السوق مناسب للتداول                               |
//+------------------------------------------------------------------+
bool CPatternSignalManager::IsMarketSuitable()
{
   // فحص وقت السوق
   SPatternSignalInfo tempSignal;
   InitializePatternSignalInfo(tempSignal);
   if(!CheckTimeFilter(tempSignal))
      return false;
   
   // فحص التقلبات
   double volatility = CalculateVolatility(Symbol());
   if(volatility < 0.0001 || volatility > 0.01) // قيم مثالية
      return false;
   
   // فحص السبريد
   m_symbolInfo.Name(Symbol());
   m_symbolInfo.Refresh();
   double spread = m_symbolInfo.Spread() * m_symbolInfo.Point();
   double spreadInPips = spread / (m_symbolInfo.Point() * 10);
   if(spreadInPips > m_filterSettings.maxSpread)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| حساب التقلبات                                                    |
//+------------------------------------------------------------------+
double CPatternSignalManager::CalculateVolatility(const string symbolName, int period)
{
   double high[], low[];
   
   if(CopyHigh(symbolName, PERIOD_CURRENT, 0, period, high) != period ||
      CopyLow(symbolName, PERIOD_CURRENT, 0, period, low) != period)
      return 0.0;
   
   double sum = 0.0;
   for(int i = 0; i < period; i++)
   {
      double range = high[i] - low[i];
      sum += range * range;
   }
   
   return MathSqrt(sum / period);
}

//+------------------------------------------------------------------+
//| حساب متوسط المدى الحقيقي (ATR)                                   |
//+------------------------------------------------------------------+
double CPatternSignalManager::CalculateATR(const string symbolName, int period)
{
   double high[], low[], close[];
   
   if(CopyHigh(symbolName, PERIOD_CURRENT, 0, period + 1, high) != period + 1 ||
      CopyLow(symbolName, PERIOD_CURRENT, 0, period + 1, low) != period + 1 ||
      CopyClose(symbolName, PERIOD_CURRENT, 0, period + 1, close) != period + 1)
      return 0.0;
   
   double sum = 0.0;
   for(int i = 1; i <= period; i++)
   {
      double tr1 = high[i] - low[i];
      double tr2 = MathAbs(high[i] - close[i-1]);
      double tr3 = MathAbs(low[i] - close[i-1]);
      
      double tr = MathMax(tr1, MathMax(tr2, tr3));
      sum += tr;
   }
   
   return sum / period;
}

//+------------------------------------------------------------------+
//| فحص ما إذا كانت فترة تقلبات عالية                                |
//+------------------------------------------------------------------+
bool CPatternSignalManager::IsHighVolatilityPeriod(const string symbolName)
{
   double currentATR = CalculateATR(symbolName, 14);
   double longTermATR = CalculateATR(symbolName, 50);
   
   return currentATR > longTermATR * 1.5;
}

//+------------------------------------------------------------------+
//| مسح الإشارات المنتهية الصلاحية                                   |
//+------------------------------------------------------------------+
void CPatternSignalManager::ClearExpiredSignals()
{
   for(int i = m_signalCount - 1; i >= 0; i--)
   {
      if(m_signals[i].status == PATTERN_SIGNAL_STATUS_EXPIRED)
         RemoveSignal(i);
   }
}

//+------------------------------------------------------------------+
//| مسح الإشارات حسب الحالة                                          |
//+------------------------------------------------------------------+
void CPatternSignalManager::ClearSignalsByStatus(ENUM_PATTERN_SIGNAL_STATUS statusValue)
{
   for(int i = m_signalCount - 1; i >= 0; i--)
   {
      if(m_signals[i].status == statusValue)
         RemoveSignal(i);
   }
}

//+------------------------------------------------------------------+
//| الحصول على إشارة بالمؤشر                                         |
//+------------------------------------------------------------------+
bool CPatternSignalManager::GetSignal(int index, SPatternSignalInfo &signalInfo)
{
   if(index >= 0 && index < m_signalCount)
   {
      signalInfo = m_signals[index];
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| الحصول على أحدث إشارة                                           |
//+------------------------------------------------------------------+
bool CPatternSignalManager::GetLatestSignal(SPatternSignalInfo &signalInfo)
{
   if(m_signalCount == 0)
      return false;
   
   SPatternSignalInfo latest = m_signals[0];
   
   for(int i = 1; i < m_signalCount; i++)
   {
      if(m_signals[i].signalTime > latest.signalTime)
         latest = m_signals[i];
   }
   
   signalInfo = latest;
   return true;
}

//+------------------------------------------------------------------+
//| الحصول على أقوى إشارة                                           |
//+------------------------------------------------------------------+
bool CPatternSignalManager::GetStrongestSignal(SPatternSignalInfo &signalInfo, ENUM_PATTERN_SIGNAL_TYPE signalType)
{
   if(m_signalCount == 0)
      return false;
   
   bool found = false;
   double maxScore = 0.0;
   SPatternSignalInfo strongest;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if((signalType == PATTERN_SIGNAL_NONE || m_signals[i].signalType == signalType) &&
         m_signals[i].status == PATTERN_SIGNAL_STATUS_PENDING)
      {
         double score = CalculateSignalScore(m_signals[i]);
         if(score > maxScore)
         {
            maxScore = score;
            strongest = m_signals[i];
            found = true;
         }
      }
   }
   
   if(found)
   {
      signalInfo = strongest;
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| الحصول على إشارة برقم التيكت                                     |
//+------------------------------------------------------------------+
bool CPatternSignalManager::GetSignalByTicket(ulong orderTicket, SPatternSignalInfo &signalInfo)
{
   int index = FindSignalIndex(orderTicket);
   if(index >= 0)
   {
      signalInfo = m_signals[index];
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| الحصول على الإشارات حسب النوع                                     |
//+------------------------------------------------------------------+
int CPatternSignalManager::GetSignalsByType(ENUM_PATTERN_SIGNAL_TYPE signalType, SPatternSignalInfo &results[])
{
   ArrayResize(results, 0);
   int count = 0;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].signalType == signalType)
      {
         ArrayResize(results, count + 1);
         results[count] = m_signals[i];
         count++;
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| الحصول على الإشارات حسب القوة                                     |
//+------------------------------------------------------------------+
int CPatternSignalManager::GetSignalsByStrength(ENUM_PATTERN_SIGNAL_STRENGTH minStrength, SPatternSignalInfo &results[])
{
   ArrayResize(results, 0);
   int count = 0;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].strength >= minStrength)
      {
         ArrayResize(results, count + 1);
         results[count] = m_signals[i];
         count++;
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| الحصول على الإشارات حسب الرمز                                     |
//+------------------------------------------------------------------+
int CPatternSignalManager::GetSignalsBySymbol(const string symbolName, SPatternSignalInfo &results[])
{
   ArrayResize(results, 0);
   int count = 0;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].symbolName == symbolName)
      {
         ArrayResize(results, count + 1);
         results[count] = m_signals[i];
         count++;
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| الحصول على الإشارات حسب الحالة                                    |
//+------------------------------------------------------------------+
int CPatternSignalManager::GetSignalsByStatus(ENUM_PATTERN_SIGNAL_STATUS statusValue, SPatternSignalInfo &results[])
{
   ArrayResize(results, 0);
   int count = 0;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].status == statusValue)
      {
         ArrayResize(results, count + 1);
         results[count] = m_signals[i];
         count++;
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| الحصول على الإشارات حسب النطاق الزمني                             |
//+------------------------------------------------------------------+
int CPatternSignalManager::GetSignalsByTimeRange(datetime startTime, datetime endTime, SPatternSignalInfo &results[])
{
   ArrayResize(results, 0);
   int count = 0;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].signalTime >= startTime && m_signals[i].signalTime <= endTime)
      {
         ArrayResize(results, count + 1);
         results[count] = m_signals[i];
         count++;
      }
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| تنفيذ جميع الإشارات                                              |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ExecuteAllSignals()
{
   bool hasExecuted = false;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].status == PATTERN_SIGNAL_STATUS_PENDING)
      {
         if(ExecuteSignalByInfo(m_signals[i]))
            hasExecuted = true;
      }
   }
   
   return hasExecuted;
}

//+------------------------------------------------------------------+
//| تنفيذ الإشارات حسب النوع                                          |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ExecuteSignalsByType(ENUM_PATTERN_SIGNAL_TYPE signalType)
{
   bool hasExecuted = false;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].signalType == signalType && m_signals[i].status == PATTERN_SIGNAL_STATUS_PENDING)
      {
         if(ExecuteSignalByInfo(m_signals[i]))
            hasExecuted = true;
      }
   }
   
   return hasExecuted;
}

//+------------------------------------------------------------------+
//| تنفيذ الإشارات حسب القوة                                          |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ExecuteSignalsByStrength(ENUM_PATTERN_SIGNAL_STRENGTH minStrength)
{
   bool hasExecuted = false;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].strength >= minStrength && m_signals[i].status == PATTERN_SIGNAL_STATUS_PENDING)
      {
         if(ExecuteSignalByInfo(m_signals[i]))
            hasExecuted = true;
      }
   }
   
   return hasExecuted;
}

//+------------------------------------------------------------------+
//| تنفيذ الإشارات المعلقة                                            |
//+------------------------------------------------------------------+
int CPatternSignalManager::ExecutePendingSignals()
{
   int executedCount = 0;
   
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].status == PATTERN_SIGNAL_STATUS_PENDING)
      {
         if(ExecuteSignalByInfo(m_signals[i]))
            executedCount++;
      }
   }
   
   return executedCount;
}

//+------------------------------------------------------------------+
//| إغلاق مركز                                                       |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ClosePosition(ulong ticket)
{
   return m_trade.PositionClose(ticket);
}

//+------------------------------------------------------------------+
//| إغلاق جميع المراكز                                               |
//+------------------------------------------------------------------+
bool CPatternSignalManager::CloseAllPositions()
{
   bool result = true;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i) && m_position.Magic() == m_magicNumber)
      {
         if(!m_trade.PositionClose(m_position.Ticket()))
            result = false;
      }
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| إغلاق المراكز حسب الرمز                                          |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ClosePositionsBySymbol(const string symbolName)
{
   bool result = true;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i) && 
         m_position.Symbol() == symbolName && 
         m_position.Magic() == m_magicNumber)
      {
         if(!m_trade.PositionClose(m_position.Ticket()))
            result = false;
      }
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| تعديل مركز                                                       |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ModifyPosition(ulong ticket, double newSL, double newTP)
{
   return m_trade.PositionModify(ticket, newSL, newTP);
}

//+------------------------------------------------------------------+
//| تطبيق الوقف المتحرك                                              |
//+------------------------------------------------------------------+
bool CPatternSignalManager::SetTrailingStop(ulong ticket, double distance)
{
   if(!m_position.SelectByTicket(ticket))
      return false;
   
   double point = SymbolInfoDouble(m_position.Symbol(), SYMBOL_POINT);
   double currentPrice = m_position.PriceCurrent();
   double currentSL = m_position.StopLoss();
   double newSL = 0.0;
   
   if(m_position.PositionType() == POSITION_TYPE_BUY)
   {
      // مركز شراء
      newSL = currentPrice - distance * point;
      
      // تحرك الوقف فقط في الاتجاه المربح
      if(currentSL == 0.0 || newSL > currentSL)
      {
         return m_trade.PositionModify(ticket, newSL, m_position.TakeProfit());
      }
   }
   else if(m_position.PositionType() == POSITION_TYPE_SELL)
   {
      // مركز بيع
      newSL = currentPrice + distance * point;
      
      // تحرك الوقف فقط في الاتجاه المربح
      if(currentSL == 0.0 || newSL < currentSL)
      {
         return m_trade.PositionModify(ticket, newSL, m_position.TakeProfit());
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| التحديث عند كل تيك                                               |
//+------------------------------------------------------------------+
void CPatternSignalManager::OnTick()
{
   if(!m_isEnabled)
      return;
   
   // تحديث الأسعار الحالية للإشارات النشطة
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].status == PATTERN_SIGNAL_STATUS_EXECUTED)
      {
         m_signals[i].currentPrice = SymbolInfoDouble(m_signals[i].symbolName, SYMBOL_BID);
      }
   }
   
   // تطبيق الوقف المتحرك إذا كان مفعل
   if(m_riskSettings.useTrailingStop)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         if(m_position.SelectByIndex(i) && m_position.Magic() == m_magicNumber)
         {
            SetTrailingStop(m_position.Ticket(), m_riskSettings.trailingDistance);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| التحديث عند المؤقت                                               |
//+------------------------------------------------------------------+
void CPatternSignalManager::OnTimer()
{
   Update();
}

//+------------------------------------------------------------------+
//| التحديث عند التداول                                              |
//+------------------------------------------------------------------+
void CPatternSignalManager::OnTrade()
{
   // تحديث حالة الإشارات عند حدوث تداول
   UpdateSignalStatus();
   
   // تحديث مقاييس الأداء
   UpdatePerformanceMetrics();
}

//+------------------------------------------------------------------+
//| طباعة الإشارات                                                   |
//+------------------------------------------------------------------+
void CPatternSignalManager::PrintSignals()
{
   Print("===== إشارات أنماط الشموع =====");
   Print("العدد الإجمالي: ", m_signalCount);
   
   for(int i = 0; i < m_signalCount; i++)
   {
      string info = StringFormat("%d. %s | %s | %s | %s | %.5f | %.1f%%",
         i + 1,
         m_signals[i].patternName,
         m_signals[i].symbolName,
         EnumToString(m_signals[i].signalType),
         EnumToString(m_signals[i].status),
         m_signals[i].signalPrice,
         m_signals[i].confidence * 100);
      Print(info);
   }
   Print("===============================");
}

//+------------------------------------------------------------------+
//| طباعة الإحصائيات                                                 |
//+------------------------------------------------------------------+
void CPatternSignalManager::PrintStatistics()
{
   if(m_statistics != NULL)
      m_statistics.PrintReport();
   
   Print("===== مقاييس إضافية =====");
   Print("الربح/الخسارة اليومية: ", DoubleToString(m_dailyPnL, 2));
   Print("السحب الحالي: ", DoubleToString(m_currentDrawdown, 2), "%");
   Print("الخسائر المتتالية: ", m_consecutiveLosses);
   Print("الأرباح المتتالية: ", m_consecutiveWins);
   Print("========================");
}

//+------------------------------------------------------------------+
//| الحصول على سلسلة الحالة                                          |
//+------------------------------------------------------------------+
string CPatternSignalManager::GetStatusString()
{
   string status = "";
   status += "النظام: " + (m_isEnabled ? "مفعل" : "معطل") + "\n";
   status += "عدد الإشارات: " + IntegerToString(m_signalCount) + "\n";
   status += "الربح اليومي: " + DoubleToString(m_dailyPnL, 2) + "\n";
   status += "السحب الحالي: " + DoubleToString(m_currentDrawdown, 2) + "%\n";
   
   // إحصائيات الإشارات حسب الحالة
   int pending = 0, executed = 0, expired = 0;
   for(int i = 0; i < m_signalCount; i++)
   {
      switch(m_signals[i].status)
      {
         case PATTERN_SIGNAL_STATUS_PENDING: pending++; break;
         case PATTERN_SIGNAL_STATUS_EXECUTED: executed++; break;
         case PATTERN_SIGNAL_STATUS_EXPIRED: expired++; break;
         default: break;
      }
   }
   
   status += "معلقة: " + IntegerToString(pending) + " | ";
   status += "منفذة: " + IntegerToString(executed) + " | ";
   status += "منتهية: " + IntegerToString(expired);
   
   return status;
}

//+------------------------------------------------------------------+
//| فحص سلامة البيانات                                               |
//+------------------------------------------------------------------+
bool CPatternSignalManager::CheckIntegrity()
{
   // فحص سلامة المؤشرات
   if(m_signalCount < 0 || m_signalCount > m_maxSignals)
      return false;
   
   // فحص صحة البيانات
   for(int i = 0; i < m_signalCount; i++)
   {
      if(m_signals[i].symbolName == "" || m_signals[i].patternName == "")
         return false;
         
      if(m_signals[i].signalType == PATTERN_SIGNAL_NONE)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| تحسين الذاكرة                                                    |
//+------------------------------------------------------------------+
void CPatternSignalManager::OptimizeMemory()
{
   // إزالة الإشارات القديمة وغير الضرورية
   CleanupExpiredSignals();
   
   // إعادة تنظيم المصفوفة إذا كان هناك فراغات كثيرة
   if(m_signalCount < m_maxSignals * 0.5 && m_maxSignals > 100)
   {
      int newSize = MathMax(100, m_signalCount * 2);
      ArrayResize(m_signals, newSize);
      m_maxSignals = newSize;
   }
}

//+------------------------------------------------------------------+
//| حفظ الإعدادات                                                    |
//+------------------------------------------------------------------+
bool CPatternSignalManager::SaveSettings(const string fileName)
{
   int handle = FileOpen(fileName, FILE_WRITE | FILE_TXT);
   if(handle == INVALID_HANDLE)
      return false;
   
   string settings = "";
   settings += "[RiskSettings]\n";
   settings += "RiskPercent=" + DoubleToString(m_riskSettings.riskPercent, 2) + "\n";
   settings += "MaxRiskPerTrade=" + DoubleToString(m_riskSettings.maxRiskPerTrade, 2) + "\n";
   settings += "MinRiskReward=" + DoubleToString(m_riskSettings.minRiskReward, 2) + "\n";
   settings += "UseTrailingStop=" + (m_riskSettings.useTrailingStop ? "true" : "false") + "\n";
   settings += "TrailingDistance=" + DoubleToString(m_riskSettings.trailingDistance, 1) + "\n";
   
   settings += "\n[FilterSettings]\n";
   settings += "EnableTimeFilter=" + (m_filterSettings.enableTimeFilter ? "true" : "false") + "\n";
   settings += "StartHour=" + IntegerToString(m_filterSettings.startHour) + "\n";
   settings += "EndHour=" + IntegerToString(m_filterSettings.endHour) + "\n";
   settings += "EnableTrendFilter=" + (m_filterSettings.enableTrendFilter ? "true" : "false") + "\n";
   settings += "MaxSpread=" + DoubleToString(m_filterSettings.maxSpread, 1) + "\n";
   
   settings += "\n[General]\n";
   settings += "MagicNumber=" + IntegerToString(m_magicNumber) + "\n";
   settings += "ExpertName=" + m_expertName + "\n";
   settings += "SignalExpiryBars=" + IntegerToString(m_signalExpiryBars) + "\n";
   settings += "AllowMultipleSignals=" + (m_allowMultipleSignals ? "true" : "false") + "\n";
   settings += "IsEnabled=" + (m_isEnabled ? "true" : "false") + "\n";
   
   FileWriteString(handle, settings);
   FileClose(handle);
   return true;
}

//+------------------------------------------------------------------+
//| تحميل الإعدادات                                                  |
//+------------------------------------------------------------------+
bool CPatternSignalManager::LoadSettings(const string fileName)
{
   if(!FileIsExist(fileName))
      return false;
   
   int handle = FileOpen(fileName, FILE_READ | FILE_TXT);
   if(handle == INVALID_HANDLE)
      return false;
   
   string line;
   string section = "";
   
   while(!FileIsEnding(handle))
   {
      line = FileReadString(handle);
      StringTrimLeft(line);
      StringTrimRight(line);
      
      if(StringLen(line) == 0 || StringSubstr(line, 0, 1) == "#")
         continue;
         
      if(StringSubstr(line, 0, 1) == "[" && StringSubstr(line, StringLen(line) - 1, 1) == "]")
      {
         section = StringSubstr(line, 1, StringLen(line) - 2);
         continue;
      }
      
      string key, value;
      int pos = StringFind(line, "=");
      if(pos > 0)
      {
         key = StringSubstr(line, 0, pos);
         value = StringSubstr(line, pos + 1);
         
         if(section == "RiskSettings")
         {
            if(key == "RiskPercent") m_riskSettings.riskPercent = StringToDouble(value);
            else if(key == "MaxRiskPerTrade") m_riskSettings.maxRiskPerTrade = StringToDouble(value);
            else if(key == "MinRiskReward") m_riskSettings.minRiskReward = StringToDouble(value);
            else if(key == "UseTrailingStop") m_riskSettings.useTrailingStop = (value == "true");
            else if(key == "TrailingDistance") m_riskSettings.trailingDistance = StringToDouble(value);
         }
         else if(section == "FilterSettings")
         {
            if(key == "EnableTimeFilter") m_filterSettings.enableTimeFilter = (value == "true");
            else if(key == "StartHour") m_filterSettings.startHour = (int)StringToInteger(value);
            else if(key == "EndHour") m_filterSettings.endHour = (int)StringToInteger(value);
            else if(key == "EnableTrendFilter") m_filterSettings.enableTrendFilter = (value == "true");
            else if(key == "MaxSpread") m_filterSettings.maxSpread = StringToDouble(value);
         }
         else if(section == "General")
         {
            if(key == "MagicNumber") 
            {
               m_magicNumber = (int)StringToInteger(value);
               m_trade.SetExpertMagicNumber(m_magicNumber);
            }
            else if(key == "ExpertName") m_expertName = value;
            else if(key == "SignalExpiryBars") m_signalExpiryBars = (int)StringToInteger(value);
            else if(key == "AllowMultipleSignals") m_allowMultipleSignals = (value == "true");
            else if(key == "IsEnabled") m_isEnabled = (value == "true");
         }
      }
   }
   
   FileClose(handle);
   return true;
}

//+------------------------------------------------------------------+
//| حفظ الإشارات                                                     |
//+------------------------------------------------------------------+
bool CPatternSignalManager::SaveSignals(const string fileName)
{
   int handle = FileOpen(fileName, FILE_WRITE | FILE_CSV);
   if(handle == INVALID_HANDLE)
      return false;
   
   // كتابة العناوين
   string header = "PatternName,Symbol,SignalType,Status,EntryPrice,StopLoss,TakeProfit,SignalTime,Confidence";
   FileWriteString(handle, header);
   
   // كتابة بيانات الإشارات
   for(int i = 0; i < m_signalCount; i++)
   {
      string row = m_signals[i].patternName + "," +
                   m_signals[i].symbolName + "," +
                   EnumToString(m_signals[i].signalType) + "," +
                   EnumToString(m_signals[i].status) + "," +
                   DoubleToString(m_signals[i].entryPrice, 5) + "," +
                   DoubleToString(m_signals[i].stopLoss, 5) + "," +
                   DoubleToString(m_signals[i].takeProfit, 5) + "," +
                   TimeToString(m_signals[i].signalTime) + "," +
                   DoubleToString(m_signals[i].confidence, 3);
      FileWriteString(handle, row);
   }
   
   FileClose(handle);
   return true;
}

//+------------------------------------------------------------------+
//| تحميل الإشارات                                                   |
//+------------------------------------------------------------------+
bool CPatternSignalManager::LoadSignals(const string fileName)
{
   if(!FileIsExist(fileName))
      return false;
   
   int handle = FileOpen(fileName, FILE_READ | FILE_CSV);
   if(handle == INVALID_HANDLE)
      return false;
   
   // تخطي العنوان
   if(!FileIsEnding(handle))
      FileReadString(handle);
   
   // مسح الإشارات الحالية
   ClearSignals();
   
   // قراءة البيانات
   while(!FileIsEnding(handle) && m_signalCount < m_maxSignals)
   {
      string line = FileReadString(handle);
      if(StringLen(line) == 0) continue;
      
      // تحليل السطر (مبسط - في التطبيق الحقيقي يحتاج تحليل أفضل)
      string parts[];
      int partCount = StringSplit(line, ',', parts);
      
      if(partCount >= 9)
      {
         SPatternSignalInfo signal;
         InitializePatternSignalInfo(signal);
         
         signal.patternName = parts[0];
         signal.symbolName = parts[1];
         // signal.signalType يحتاج تحويل من string إلى enum
         // signal.status يحتاج تحويل من string إلى enum
         signal.entryPrice = StringToDouble(parts[4]);
         signal.stopLoss = StringToDouble(parts[5]);
         signal.takeProfit = StringToDouble(parts[6]);
         // signal.signalTime يحتاج تحويل من string إلى datetime
         signal.confidence = StringToDouble(parts[8]);
         
         m_signals[m_signalCount] = signal;
         m_signalCount++;
      }
   }
   
   FileClose(handle);
   return true;
}

//+------------------------------------------------------------------+
//| حساب العائد المتوقع للإشارة                                      |
//+------------------------------------------------------------------+
double CPatternSignalManager::CalculateExpectedReturn(const SPatternSignalInfo &signalInfo)
{
   // حساب العائد المتوقع بناء على احتمالية النجاح ونسبة المخاطرة للعائد
   double successProbability = PredictSignalSuccess(signalInfo);
   double failureProbability = 1.0 - successProbability;
   
   double potentialReward = MathAbs(signalInfo.takeProfit - signalInfo.entryPrice);
   double potentialRisk = MathAbs(signalInfo.entryPrice - signalInfo.stopLoss);
   
   // العائد المتوقع = (احتمالية النجاح × المكسب) - (احتمالية الفشل × الخسارة)
   double expectedReturn = (successProbability * potentialReward) - (failureProbability * potentialRisk);
   
   return expectedReturn;
}

//+------------------------------------------------------------------+
//| التنبؤ بنجاح الإشارة (ذكاء اصطناعي بسيط)                        |
//+------------------------------------------------------------------+
double CPatternSignalManager::PredictSignalSuccess(const SPatternSignalInfo &signalInfo)
{
   double prediction = 0.5; // احتمالية أساسية 50%
   
   // عوامل تؤثر على التنبؤ
   
   // 1. قوة النمط
   prediction += (signalInfo.strength - 3) * 0.1; // +/- 20% حسب القوة
   
   // 2. درجة الثقة
   prediction += (signalInfo.confidence - 0.5) * 0.4; // +/- 20% حسب الثقة
   
   // 3. نسبة المخاطرة للعائد
   if(signalInfo.riskReward >= 2.0)
      prediction += 0.1;
   else if(signalInfo.riskReward < 1.5)
      prediction -= 0.1;
   
   // 4. التقلبات
   double volatility = CalculateVolatility(signalInfo.symbolName);
   if(volatility > 0.005) // تقلبات عالية
      prediction -= 0.05;
   else if(volatility < 0.001) // تقلبات منخفضة جداً
      prediction -= 0.05;
   
   // 5. الإحصائيات التاريخية للنمط
   if(m_statistics != NULL)
   {
      double historicalWinRate = m_statistics.GetWinRate() / 100.0;
      prediction = prediction * 0.7 + historicalWinRate * 0.3;
   }
   
   // تحديد النتيجة بين 0 و 1
   return MathMax(0.0, MathMin(1.0, prediction));
}

//+------------------------------------------------------------------+
//| تكييف المعلمات تلقائياً                                          |
//+------------------------------------------------------------------+
void CPatternSignalManager::AdaptParameters()
{
   if(m_statistics == NULL)
      return;
   
   double winRate = m_statistics.GetWinRate();
   double profitFactor = m_statistics.GetProfitFactor();
   
   // تكييف نسبة المخاطرة
   if(winRate > 70.0 && profitFactor > 1.5)
   {
      // أداء جيد، زيادة المخاطرة قليلاً
      m_riskSettings.riskPercent = MathMin(m_riskSettings.riskPercent * 1.05, 5.0);
   }
   else if(winRate < 40.0 || profitFactor < 1.0)
   {
      // أداء ضعيف، تقليل المخاطرة
      m_riskSettings.riskPercent = MathMax(m_riskSettings.riskPercent * 0.95, 0.5);
   }
   
   // تكييف معايير الفلترة
   if(winRate < 50.0)
   {
      // زيادة صرامة الفلاتر
      m_filterSettings.minTrendStrength = MathMin(m_filterSettings.minTrendStrength * 1.1, 0.9);
   }
   else if(winRate > 60.0)
   {
      // تقليل صرامة الفلاتر لزيادة الفرص
      m_filterSettings.minTrendStrength = MathMax(m_filterSettings.minTrendStrength * 0.95, 0.3);
   }
}

//+------------------------------------------------------------------+
//| تحسين إعدادات إدارة المخاطر                                       |
//+------------------------------------------------------------------+
void CPatternSignalManager::OptimizeRiskSettings()
{
   if(m_statistics == NULL)
      return;
      
   double sharpeRatio = m_statistics.GetSharpeRatio();
   double maxDrawdown = m_statistics.GetMaxDrawdown();
   
   // تحسين بناءً على نسبة شارب
   if(sharpeRatio > 1.5)
   {
      // أداء ممتاز، يمكن زيادة المخاطرة
      m_riskSettings.riskPercent = MathMin(m_riskSettings.riskPercent * 1.1, 10.0);
   }
   else if(sharpeRatio < 0.5)
   {
      // أداء ضعيف، تقليل المخاطرة
      m_riskSettings.riskPercent = MathMax(m_riskSettings.riskPercent * 0.8, 0.5);
   }
   
   // تحسين بناءً على السحب الأقصى
   if(maxDrawdown > m_riskSettings.maxDrawdown * 0.8)
   {
      // السحب قريب من الحد الأقصى
      m_riskSettings.riskPercent *= 0.9;
      m_riskSettings.maxRiskPerTrade *= 0.9;
   }
}

//+------------------------------------------------------------------+
//| فحص ما إذا كان يجب تقليل المخاطرة                                |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ShouldReduceRisk()
{
   // تقليل المخاطرة إذا:
   return (m_consecutiveLosses >= 3 ||                    // 3 خسائر متتالية
           m_currentDrawdown > m_riskSettings.maxDrawdown * 0.7 || // سحب عالي
           m_monthlyPnL < -m_riskSettings.maxMonthlyRisk * 0.5);   // خسائر شهرية كبيرة
}

//+------------------------------------------------------------------+
//| فحص ما إذا كان يمكن زيادة المخاطرة                               |
//+------------------------------------------------------------------+
bool CPatternSignalManager::ShouldIncreaseRisk()
{
   // زيادة المخاطرة إذا:
   return (m_consecutiveWins >= 5 &&                      // 5 أرباح متتالية
           m_currentDrawdown < m_riskSettings.maxDrawdown * 0.2 && // سحب منخفض
           m_monthlyPnL > m_riskSettings.targetProfit &&   // تحقيق الهدف الشهري
           m_statistics != NULL && m_statistics.GetWinRate() > 65.0); // معدل نجاح عالي
}