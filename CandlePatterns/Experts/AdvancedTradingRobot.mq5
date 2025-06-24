//+------------------------------------------------------------------+
//|                                           AdvancedTradingRobot.mq5 |
//|                                   روبوت التداول المتكامل المتقدم |
//|                         حقوق النشر 2025, علي تك للتداول الذكي |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, علي تك للتداول الذكي"
#property link      "https://www.alitech-trading.com"
#property version   "4.00"
#property description "روبوت تداول متكامل يستخدم أنماط الشموع مع إدارة المخاطر المتقدمة"

// تضمين المكتبات المطلوبة
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>

//+------------------------------------------------------------------+
//| التعدادات والهياكل الأساسية                                      |
//+------------------------------------------------------------------+
enum ENUM_MONEY_MANAGEMENT_TYPE
{
   MM_FIXED_LOT,               // حجم ثابت
   MM_PERCENT_BALANCE,         // نسبة من الرصيد
   MM_PERCENT_EQUITY,          // نسبة من حقوق الملكية
   MM_RISK_PERCENT,            // نسبة المخاطرة
   MM_KELLY_CRITERION          // معيار كيلي
};

enum ENUM_TRADE_DIRECTION_FILTER
{
   TRADE_BOTH,                 // التداول في الاتجاهين
   TRADE_BUY_ONLY,            // الشراء فقط
   TRADE_SELL_ONLY,           // البيع فقط
   TRADE_TREND_ONLY           // اتجاه الترند فقط
};

enum ENUM_EXIT_STRATEGY
{
   EXIT_FIXED_TP_SL,          // جني أرباح ووقف خسارة ثابت
   EXIT_TRAILING_STOP,        // وقف خسارة متحرك
   EXIT_ATR_BASED,            // مبني على ATR
   EXIT_PATTERN_REVERSAL,     // انعكاس النمط
   EXIT_TIME_BASED            // مبني على الوقت
};

//+------------------------------------------------------------------+
//| هيكل معلومات الصفقة                                             |
//+------------------------------------------------------------------+
struct STradeInfo
{
   ulong             ticket;           // رقم التذكرة
   string            symbol;           // الرمز
   double            entryPrice;       // سعر الدخول
   double            lotSize;          // حجم الصفقة
   datetime          entryTime;        // وقت الدخول
   string            patternUsed;      // النمط المستخدم
   double            stopLoss;         // وقف الخسارة
   double            takeProfit;       // جني الأرباح
   double            riskAmount;       // مبلغ المخاطرة
   bool              isTrailingActive; // هل التتبع نشط
   double            maxDrawdown;      // أقصى سحب
   double            maxProfit;        // أقصى ربح
   
   STradeInfo()
   {
      ticket = 0;
      symbol = "";
      entryPrice = 0;
      lotSize = 0;
      entryTime = 0;
      patternUsed = "";
      stopLoss = 0;
      takeProfit = 0;
      riskAmount = 0;
      isTrailingActive = false;
      maxDrawdown = 0;
      maxProfit = 0;
   }
};

//+------------------------------------------------------------------+
//| هيكل إحصائيات الأداء                                           |
//+------------------------------------------------------------------+
struct SPerformanceStats
{
   int               totalTrades;          // إجمالي الصفقات
   int               winningTrades;        // الصفقات الرابحة
   int               losingTrades;         // الصفقات الخاسرة
   double            grossProfit;          // إجمالي الأرباح
   double            grossLoss;            // إجمالي الخسائر
   double            netProfit;            // صافي الربح
   double            profitFactor;         // عامل الربح
   double            expectedPayoff;       // العائد المتوقع
   double            maxDrawdown;          // أقصى سحب
   double            maxDrawdownPercent;   // أقصى سحب بالنسبة المئوية
   double            sharpeRatio;          // نسبة شارب
   double            winRate;              // معدل الربح
   double            avgWin;               // متوسط الربح
   double            avgLoss;              // متوسط الخسارة
   double            largestWin;           // أكبر ربح
   double            largestLoss;          // أكبر خسارة
   int               consecutiveWins;      // الأرباح المتتالية
   int               consecutiveLosses;    // الخسائر المتتالية
   double            recoveryFactor;       // عامل التعافي
   double            calmarRatio;          // نسبة كالمار
   
   SPerformanceStats()
   {
      totalTrades = 0;
      winningTrades = 0;
      losingTrades = 0;
      grossProfit = 0;
      grossLoss = 0;
      netProfit = 0;
      profitFactor = 0;
      expectedPayoff = 0;
      maxDrawdown = 0;
      maxDrawdownPercent = 0;
      sharpeRatio = 0;
      winRate = 0;
      avgWin = 0;
      avgLoss = 0;
      largestWin = 0;
      largestLoss = 0;
      consecutiveWins = 0;
      consecutiveLosses = 0;
      recoveryFactor = 0;
      calmarRatio = 0;
   }
};

//+------------------------------------------------------------------+
//| معاملات الدخل - إعدادات عامة                                    |
//+------------------------------------------------------------------+
input group "=== الإعدادات العامة ===";
input ulong              InpMagicNumber = 20250623;              // الرقم السحري
input string             InpEAComment = "روبوت التداول المتكامل";  // تعليق الصفقات
input bool               InpAllowTrading = true;                  // السماح بالتداول
input int                InpMaxSpread = 30;                      // أقصى سبريد (بالنقاط)
input int                InpSlippage = 3;                        // الانزلاق المسموح

input group "=== إدارة الأموال ===";
input ENUM_MONEY_MANAGEMENT_TYPE InpMMType = MM_RISK_PERCENT;    // نوع إدارة الأموال
input double             InpLotSize = 0.1;                       // حجم الصفقة (للحجم الثابت)
input double             InpRiskPercent = 2.0;                   // نسبة المخاطرة من الرصيد
input double             InpMaxRiskPercent = 10.0;               // أقصى مخاطرة إجمالية
input int                InpMaxPositions = 5;                    // أقصى عدد صفقات متزامنة
input double             InpMinLotSize = 0.01;                   // أقل حجم صفقة
input double             InpMaxLotSize = 10.0;                   // أكبر حجم صفقة

input group "=== إعدادات التداول ===";
input ENUM_TRADE_DIRECTION_FILTER InpTradeDirection = TRADE_BOTH; // اتجاه التداول المسموح
input bool               InpUsePatternStrengthFilter = true;      // استخدام مرشح قوة النمط
input double             InpMinPatternStrength = 2.5;            // الحد الأدنى لقوة النمط
input double             InpMinPatternReliability = 0.75;        // الحد الأدنى لموثوقية النمط
input bool               InpUseTrendFilter = true;               // استخدام مرشح الترند
input int                InpTrendPeriod = 50;                    // فترة المتوسط المتحرك للترند

input group "=== إدارة المخاطر ===";
input ENUM_EXIT_STRATEGY InpExitStrategy = EXIT_ATR_BASED;       // استراتيجية الخروج
input double             InpStopLossATR = 2.0;                   // وقف الخسارة (مضاعف ATR)
input double             InpTakeProfitATR = 4.0;                 // جني الأرباح (مضاعف ATR)
input bool               InpUseTrailingStop = true;              // استخدام وقف الخسارة المتحرك
input double             InpTrailingDistance = 50;               // مسافة الوقف المتحرك (بالنقاط)
input double             InpTrailingStep = 10;                   // خطوة الوقف المتحرك (بالنقاط)
input int                InpATRPeriod = 14;                      // فترة ATR

input group "=== مرشحات الوقت ===";
input bool               InpUseTimeFilter = true;                // استخدام مرشح الوقت
input int                InpStartHour = 8;                       // ساعة بداية التداول
input int                InpEndHour = 22;                        // ساعة نهاية التداول
input bool               InpAvoidNews = true;                    // تجنب الأخبار المهمة
input int                InpNewsFilterMinutes = 30;              // تجنب التداول قبل/بعد الأخبار (بالدقائق)
input bool               InpTradeOnFriday = false;               // التداول يوم الجمعة
input bool               InpCloseOnFriday = true;                // إغلاق الصفقات يوم الجمعة

input group "=== الحماية المتقدمة ===";
input bool               InpUseDrawdownProtection = true;        // حماية من السحب
input double             InpMaxDrawdownPercent = 20.0;           // أقصى سحب مسموح (%)
input bool               InpUseEquityProtection = true;          // حماية حقوق الملكية
input double             InpMinEquityPercent = 80.0;             // أقل نسبة لحقوق الملكية
input bool               InpUseDailyLossLimit = true;            // حد الخسارة اليومية
input double             InpDailyLossLimitPercent = 5.0;         // حد الخسارة اليومية (%)

input group "=== الإشعارات والتقارير ===";
input bool               InpSendAlerts = true;                   // إرسال التنبيهات
input bool               InpSendEmails = false;                  // إرسال البريد الإلكتروني
input bool               InpSendPushNotifications = false;       // إرسال الإشعارات
input bool               InpCreateDailyReport = true;            // إنشاء تقرير يومي
input bool               InpShowDashboard = true;                // إظهار لوحة المعلومات
input bool               InpDetailedLogging = true;              // تسجيل مفصل

//+------------------------------------------------------------------+
//| المتغيرات العامة                                                |
//+------------------------------------------------------------------+
CTrade               g_trade;
CSymbolInfo          g_symbolInfo;
CPositionInfo        g_positionInfo;
COrderInfo           g_orderInfo;
CAccountInfo         g_accountInfo;
CDealInfo            g_dealInfo;

// متغيرات إدارة الصفقات
STradeInfo           g_activeTrades[];
SPerformanceStats    g_stats;

// متغيرات التحكم والحماية
bool                 g_tradingAllowed = true;
bool                 g_emergencyStop = false;
datetime             g_lastTradeTime = 0;
double               g_initialBalance = 0;
double               g_dailyStartBalance = 0;
double               g_maxEquity = 0;
datetime             g_currentDate = 0;

// متغيرات المؤشرات
int                  g_atrHandle = INVALID_HANDLE;
int                  g_maHandle = INVALID_HANDLE;

// متغيرات الواجهة
uint                 g_dashboardTimer = 0;
uint                 g_reportTimer = 0;

// متغير لحفظ آخر نمط مكتشف
string               g_lastDetectedPattern = "";

//+------------------------------------------------------------------+
//| دالة التهيئة                                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== بدء تهيئة روبوت التداول المتكامل ===");
   
   // التحقق من صحة المعاملات
   if(!ValidateInputParameters())
   {
      Print("❌ خطأ في معاملات الدخل");
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // تهيئة إعدادات التداول
   if(!InitializeTradingSettings())
   {
      Print("❌ فشل في تهيئة إعدادات التداول");
      return INIT_FAILED;
   }
   
   // تهيئة المؤشرات
   if(!InitializeIndicators())
   {
      Print("❌ فشل في تهيئة المؤشرات");
      return INIT_FAILED;
   }
   
   // تهيئة نظام إدارة المخاطر
   InitializeRiskManagement();
   
   // تهيئة الإحصائيات
   InitializeStatistics();
   
   // تهيئة الواجهة
   if(InpShowDashboard)
   {
      CreateDashboard();
   }
   
   // تحديد التوقيت
   g_dashboardTimer = GetTickCount();
   g_reportTimer = GetTickCount();
   g_currentDate = TimeCurrent();
   
   Print("✅ تم تهيئة الروبوت بنجاح");
   Print("🎯 الرقم السحري: ", InpMagicNumber);
   Print("💰 نوع إدارة الأموال: ", EnumToString(InpMMType));
   Print("🛡️ نسبة المخاطرة: ", InpRiskPercent, "%");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| دالة إنهاء البرنامج                                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("=== إنهاء روبوت التداول ===");
   
   // تنظيف المؤشرات
   CleanupIndicators();
   
   // تنظيف الواجهة
   CleanupDashboard();
   
   // إنشاء تقرير نهائي
   CreateFinalReport();
   
   // حفظ الإحصائيات
   SaveStatistics();
   
   string reasonText = "";
   switch(reason)
   {
      case REASON_PROGRAM: reasonText = "تغيير البرنامج"; break;
      case REASON_REMOVE: reasonText = "إزالة من الرسم البياني"; break;
      case REASON_RECOMPILE: reasonText = "إعادة تصنيف"; break;
      case REASON_CHARTCHANGE: reasonText = "تغيير خصائص الرسم البياني"; break;
      case REASON_CHARTCLOSE: reasonText = "إغلاق الرسم البياني"; break;
      case REASON_PARAMETERS: reasonText = "تغيير المعاملات"; break;
      case REASON_ACCOUNT: reasonText = "تغيير الحساب"; break;
      default: reasonText = "سبب غير معروف"; break;
   }
   
   Print("👋 تم إنهاء الروبوت - السبب: ", reasonText);
}

//+------------------------------------------------------------------+
//| دالة التك                                                        |
//+------------------------------------------------------------------+
void OnTick()
{
   // التحقق من حالة التداول
   if(!CheckTradingConditions())
   {
      return;
   }
   
   // تحديث المعلومات
   UpdateMarketInfo();
   
   // إدارة الصفقات المفتوحة
   ManageOpenPositions();
   
   // البحث عن فرص تداول جديدة
   if(g_tradingAllowed && !g_emergencyStop)
   {
      CheckForTradingSignals();
   }
   
   // تحديث الحماية والمراقبة
   UpdateProtectionSystems();
   
   // تحديث الواجهة
   if(InpShowDashboard && GetTickCount() - g_dashboardTimer > 1000)
   {
      UpdateDashboard();
      g_dashboardTimer = GetTickCount();
   }
   
   // إنشاء التقارير الدورية
   if(InpCreateDailyReport && GetTickCount() - g_reportTimer > 3600000) // كل ساعة
   {
      CreatePeriodicReport();
      g_reportTimer = GetTickCount();
   }
   
   // فحص تغيير اليوم
   CheckNewDay();
}

//+------------------------------------------------------------------+
//| التحقق من شروط التداول                                          |
//+------------------------------------------------------------------+
bool CheckTradingConditions()
{
   // التحقق من السماح بالتداول
   if(!InpAllowTrading)
   {
      return false;
   }
   
   // التحقق من الإيقاف الطارئ
   if(g_emergencyStop)
   {
      return false;
   }
   
   // التحقق من حالة الاتصال
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
   {
      return false;
   }
   
   // التحقق من السوق
   if(!g_symbolInfo.RefreshRates())
   {
      return false;
   }
   
   // التحقق من السبريد
   double spread = g_symbolInfo.Spread() * g_symbolInfo.Point() / g_symbolInfo.Point();
   if(spread > InpMaxSpread)
   {
      if(InpDetailedLogging)
      {
         Print("⚠️ السبريد مرتفع جداً: ", spread, " نقطة");
      }
      return false;
   }
   
   // التحقق من وقت التداول
   if(InpUseTimeFilter && !IsWithinTradingHours())
   {
      return false;
   }
   
   // التحقق من حماية السحب
   if(InpUseDrawdownProtection && IsDrawdownExceeded())
   {
      g_emergencyStop = true;
      SendAlert("🚨 تم تفعيل الإيقاف الطارئ - تجاوز حد السحب المسموح");
      return false;
   }
   
   // التحقق من حماية حقوق الملكية
   if(InpUseEquityProtection && IsEquityTooLow())
   {
      g_emergencyStop = true;
      SendAlert("🚨 تم تفعيل الإيقاف الطارئ - انخفاض حقوق الملكية تحت الحد المسموح");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| البحث عن إشارات التداول                                         |
//+------------------------------------------------------------------+
void CheckForTradingSignals()
{
   // التحقق من عدد الصفقات المفتوحة
   if(GetActivePositionsCount() >= InpMaxPositions)
   {
      return;
   }
   
   // التحقق من المخاطرة الإجمالية
   if(GetCurrentRiskPercent() >= InpMaxRiskPercent)
   {
      return;
   }
   
   // فحص إشارات أنماط الشموع
   CheckCandlePatternSignals();
}

//+------------------------------------------------------------------+
//| فحص إشارات أنماط الشموع                                         |
//+------------------------------------------------------------------+
void CheckCandlePatternSignals()
{
   // محاكاة الحصول على بيانات الأسعار
   MqlRates rates[];
   int copied = CopyRates(Symbol(), PERIOD_H1, 0, 50, rates);
   
   if(copied < 10)
   {
      return;
   }
   
   // تحويل البيانات للتنسيق المطلوب
   double open[], high[], low[], close[];
   ArrayResize(open, copied);
   ArrayResize(high, copied);
   ArrayResize(low, copied);
   ArrayResize(close, copied);
   
   for(int i = 0; i < copied; i++)
   {
      open[i] = rates[i].open;
      high[i] = rates[i].high;
      low[i] = rates[i].low;
      close[i] = rates[i].close;
   }
   
   // فحص الأنماط الصعودية
   if(InpTradeDirection == TRADE_BOTH || InpTradeDirection == TRADE_BUY_ONLY)
   {
      if(DetectBullishPattern(1, open, high, low, close))
      {
         string patternName = GetLastDetectedPattern();
         if(ValidateSignal(ORDER_TYPE_BUY, patternName))
         {
            ExecuteTrade(ORDER_TYPE_BUY, patternName);
         }
      }
   }
   
   // فحص الأنماط الهبوطية
   if(InpTradeDirection == TRADE_BOTH || InpTradeDirection == TRADE_SELL_ONLY)
   {
      if(DetectBearishPattern(1, open, high, low, close))
      {
         string patternName = GetLastDetectedPattern();
         if(ValidateSignal(ORDER_TYPE_SELL, patternName))
         {
            ExecuteTrade(ORDER_TYPE_SELL, patternName);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| كشف الأنماط الصعودية                                            |
//+------------------------------------------------------------------+
bool DetectBullishPattern(int idx, const double &open[], const double &high[], 
                         const double &low[], const double &close[])
{
   // فحص المطرقة
   if(DetectHammerPattern(idx, open, high, low, close))
   {
      SetLastDetectedPattern("المطرقة");
      return true;
   }
   
   // فحص الابتلاع الصعودي
   if(DetectBullishEngulfingPattern(idx, open, high, low, close))
   {
      SetLastDetectedPattern("الابتلاع الصعودي");
      return true;
   }
   
   // فحص دوجي اليعسوب
   if(DetectDragonflyDojiPattern(idx, open, high, low, close))
   {
      SetLastDetectedPattern("دوجي اليعسوب");
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف الأنماط الهبوطية                                            |
//+------------------------------------------------------------------+
bool DetectBearishPattern(int idx, const double &open[], const double &high[], 
                         const double &low[], const double &close[])
{
   // فحص نجم الشهاب
   if(DetectShootingStarPattern(idx, open, high, low, close))
   {
      SetLastDetectedPattern("نجم الشهاب");
      return true;
   }
   
   // فحص الابتلاع الهبوطي
   if(DetectBearishEngulfingPattern(idx, open, high, low, close))
   {
      SetLastDetectedPattern("الابتلاع الهبوطي");
      return true;
   }
   
   // فحص دوجي شاهد القبر
   if(DetectGravestoneDojiPattern(idx, open, high, low, close))
   {
      SetLastDetectedPattern("دوجي شاهد القبر");
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| تنفيذ صفقة                                                       |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE orderType, string patternName)
{
   // حساب حجم الصفقة
   double lotSize = CalculateLotSize();
   if(lotSize <= 0)
   {
      Print("❌ لا يمكن حساب حجم الصفقة");
      return;
   }
   
   // حساب مستويات الدخول والخروج
   double entryPrice = (orderType == ORDER_TYPE_BUY) ? g_symbolInfo.Ask() : g_symbolInfo.Bid();
   double stopLoss = CalculateStopLoss(orderType, entryPrice);
   double takeProfit = CalculateTakeProfit(orderType, entryPrice);
   
   // التحقق من صحة المستويات
   if(!ValidateTradeLevels(orderType, entryPrice, stopLoss, takeProfit))
   {
      Print("❌ مستويات التداول غير صحيحة");
      return;
   }
   
   // تنفيذ الصفقة
   bool result = false;
   if(orderType == ORDER_TYPE_BUY)
   {
      result = g_trade.Buy(lotSize, Symbol(), entryPrice, stopLoss, takeProfit, InpEAComment + " - " + patternName);
   }
   else
   {
      result = g_trade.Sell(lotSize, Symbol(), entryPrice, stopLoss, takeProfit, InpEAComment + " - " + patternName);
   }
   
   if(result)
   {
      ulong ticket = g_trade.ResultOrder();
      
      // تسجيل الصفقة
      RegisterNewTrade(ticket, orderType, entryPrice, lotSize, stopLoss, takeProfit, patternName);
      
      // إرسال تنبيه
      string direction = (orderType == ORDER_TYPE_BUY) ? "شراء" : "بيع";
      string message = StringFormat(
         "🎯 تم فتح صفقة %s\n" +
         "📊 النمط: %s\n" +
         "💰 الحجم: %.2f\n" +
         "💵 السعر: %.5f\n" +
         "🛑 وقف الخسارة: %.5f\n" +
         "🎉 جني الأرباح: %.5f",
         direction, patternName, lotSize, entryPrice, stopLoss, takeProfit
      );
      
      SendAlert(message);
      
      if(InpDetailedLogging)
      {
         Print("✅ ", message);
      }
   }
   else
   {
      Print("❌ فشل في تنفيذ الصفقة - الخطأ: ", g_trade.ResultRetcode());
   }
}

//+------------------------------------------------------------------+
//| إدارة الصفقات المفتوحة                                          |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!g_positionInfo.SelectByIndex(i))
         continue;
         
      if(g_positionInfo.Magic() != InpMagicNumber || g_positionInfo.Symbol() != Symbol())
         continue;
      
      ulong ticket = g_positionInfo.Ticket();
      
      // تحديث معلومات الصفقة
      UpdateTradeInfo(ticket);
      
      // تطبيق الوقف المتحرك
      if(InpUseTrailingStop)
      {
         ApplyTrailingStop(ticket);
      }
      
      // فحص شروط الإغلاق المبكر
      CheckEarlyExit(ticket);
   }
}

//+------------------------------------------------------------------+
//| تطبيق الوقف المتحرك                                            |
//+------------------------------------------------------------------+
void ApplyTrailingStop(ulong ticket)
{
   if(!g_positionInfo.SelectByTicket(ticket))
      return;
   
   double currentPrice = (g_positionInfo.PositionType() == POSITION_TYPE_BUY) ? 
                        g_symbolInfo.Bid() : g_symbolInfo.Ask();
   double currentSL = g_positionInfo.StopLoss();
   double newSL = 0;
   
   double trailingDistance = InpTrailingDistance * g_symbolInfo.Point();
   double trailingStep = InpTrailingStep * g_symbolInfo.Point();
   
   if(g_positionInfo.PositionType() == POSITION_TYPE_BUY)
   {
      newSL = currentPrice - trailingDistance;
      
      if(newSL > currentSL + trailingStep || currentSL == 0)
      {
         newSL = NormalizeDouble(newSL, g_symbolInfo.Digits());
         
         if(g_trade.PositionModify(ticket, newSL, g_positionInfo.TakeProfit()))
         {
            if(InpDetailedLogging)
            {
               Print("📈 تم تحديث الوقف المتحرك للصفقة ", ticket, " إلى ", newSL);
            }
         }
      }
   }
   else // POSITION_TYPE_SELL
   {
      newSL = currentPrice + trailingDistance;
      
      if(newSL < currentSL - trailingStep || currentSL == 0)
      {
         newSL = NormalizeDouble(newSL, g_symbolInfo.Digits());
         
         if(g_trade.PositionModify(ticket, newSL, g_positionInfo.TakeProfit()))
         {
            if(InpDetailedLogging)
            {
               Print("📉 تم تحديث الوقف المتحرك للصفقة ", ticket, " إلى ", newSL);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| التحقق من الإغلاق المبكر                                        |
//+------------------------------------------------------------------+
void CheckEarlyExit(ulong ticket)
{
   if(!g_positionInfo.SelectByTicket(ticket))
      return;
   
   // إغلاق يوم الجمعة
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(InpCloseOnFriday && dt.day_of_week == 5 && dt.hour >= 20)
   {
      if(g_trade.PositionClose(ticket))
      {
         SendAlert("📅 تم إغلاق الصفقة " + IntegerToString(ticket) + " - نهاية الأسبوع");
      }
      return;
   }
   
   // إغلاق عند انعكاس النمط
   if(InpExitStrategy == EXIT_PATTERN_REVERSAL)
   {
      if(CheckPatternReversal(ticket))
      {
         if(g_trade.PositionClose(ticket))
         {
            SendAlert("🔄 تم إغلاق الصفقة " + IntegerToString(ticket) + " - انعكاس النمط");
         }
         return;
      }
   }
   
   // إغلاق مبني على الوقت
   if(InpExitStrategy == EXIT_TIME_BASED)
   {
      datetime entryTime = g_positionInfo.Time();
      if(TimeCurrent() - entryTime > 24 * 3600) // 24 ساعة
      {
         if(g_trade.PositionClose(ticket))
         {
            SendAlert("⏰ تم إغلاق الصفقة " + IntegerToString(ticket) + " - انتهاء الوقت المحدد");
         }
         return;
      }
   }
}

//+------------------------------------------------------------------+
//| دوال المساعدة والأدوات                                          |
//+------------------------------------------------------------------+

// دوال كشف الأنماط
bool DetectHammerPattern(int idx, const double &open[], const double &high[], 
                        const double &low[], const double &close[])
{
   if(ArraySize(open) <= idx) return false;
   
   double body = MathAbs(close[idx] - open[idx]);
   double lowerShadow = MathMin(open[idx], close[idx]) - low[idx];
   double upperShadow = high[idx] - MathMax(open[idx], close[idx]);
   
   return (lowerShadow >= 2 * body && upperShadow <= 0.1 * body && body > 0);
}

bool DetectBullishEngulfingPattern(int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[])
{
   if(ArraySize(open) <= idx + 1) return false;
   
   bool prevBearish = close[idx+1] < open[idx+1];
   bool currBullish = close[idx] > open[idx];
   bool engulfing = open[idx] < close[idx+1] && close[idx] > open[idx+1];
   
   return prevBearish && currBullish && engulfing;
}

bool DetectDragonflyDojiPattern(int idx, const double &open[], const double &high[], 
                               const double &low[], const double &close[])
{
   if(ArraySize(open) <= idx) return false;
   
   double body = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   double lowerShadow = MathMin(open[idx], close[idx]) - low[idx];
   double upperShadow = high[idx] - MathMax(open[idx], close[idx]);
   
   return (body <= 0.1 * range && lowerShadow >= 2 * upperShadow);
}

bool DetectShootingStarPattern(int idx, const double &open[], const double &high[], 
                              const double &low[], const double &close[])
{
   if(ArraySize(open) <= idx) return false;
   
   double body = MathAbs(close[idx] - open[idx]);
   double lowerShadow = MathMin(open[idx], close[idx]) - low[idx];
   double upperShadow = high[idx] - MathMax(open[idx], close[idx]);
   
   return (upperShadow >= 2 * body && lowerShadow <= 0.1 * body && close[idx] < open[idx]);
}

bool DetectBearishEngulfingPattern(int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[])
{
   if(ArraySize(open) <= idx + 1) return false;
   
   bool prevBullish = close[idx+1] > open[idx+1];
   bool currBearish = close[idx] < open[idx];
   bool engulfing = open[idx] > close[idx+1] && close[idx] < open[idx+1];
   
   return prevBullish && currBearish && engulfing;
}

bool DetectGravestoneDojiPattern(int idx, const double &open[], const double &high[], 
                                const double &low[], const double &close[])
{
   if(ArraySize(open) <= idx) return false;
   
   double body = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   double lowerShadow = MathMin(open[idx], close[idx]) - low[idx];
   double upperShadow = high[idx] - MathMax(open[idx], close[idx]);
   
   return (body <= 0.1 * range && upperShadow >= 2 * lowerShadow);
}

// دوال إدارة الأنماط
void SetLastDetectedPattern(string pattern) { g_lastDetectedPattern = pattern; }
string GetLastDetectedPattern() { return g_lastDetectedPattern; }

// التحقق من صحة الإشارة
bool ValidateSignal(ENUM_ORDER_TYPE orderType, string patternName)
{
   // التحقق من مرشح الترند
   if(InpUseTrendFilter)
   {
      double ma = GetMAValue();
      double currentPrice = g_symbolInfo.Ask();
      
      if(orderType == ORDER_TYPE_BUY && currentPrice < ma)
         return false;
      if(orderType == ORDER_TYPE_SELL && currentPrice > ma)
         return false;
   }
   
   return true;
}

// التحقق من صحة مستويات التداول
bool ValidateTradeLevels(ENUM_ORDER_TYPE orderType, double entry, double sl, double tp)
{
   double minDistance = g_symbolInfo.StopsLevel() * g_symbolInfo.Point();
   
   if(orderType == ORDER_TYPE_BUY)
   {
      if(sl > 0 && entry - sl < minDistance) return false;
      if(tp > 0 && tp - entry < minDistance) return false;
   }
   else
   {
      if(sl > 0 && sl - entry < minDistance) return false;
      if(tp > 0 && entry - tp < minDistance) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| دوال حساب الأحجام والمستويات                                   |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   double lotSize = InpLotSize;
   double balance = g_accountInfo.Balance();
   double equity = g_accountInfo.Equity();
   
   switch(InpMMType)
   {
      case MM_FIXED_LOT:
         lotSize = InpLotSize;
         break;
         
      case MM_PERCENT_BALANCE:
         lotSize = balance * InpRiskPercent / 100.0 / 1000.0;
         break;
         
      case MM_PERCENT_EQUITY:
         lotSize = equity * InpRiskPercent / 100.0 / 1000.0;
         break;
         
      case MM_RISK_PERCENT:
         {
            double riskAmount = balance * InpRiskPercent / 100.0;
            double entryPrice = g_symbolInfo.Ask();
            double stopLoss = CalculateStopLoss(ORDER_TYPE_BUY, entryPrice);
            double riskInPips = MathAbs(entryPrice - stopLoss) / g_symbolInfo.Point();
            
            if(riskInPips > 0)
            {
               double pipValue = g_symbolInfo.TickValue() * 10;
               lotSize = riskAmount / (riskInPips * pipValue);
            }
         }
         break;
         
      case MM_KELLY_CRITERION:
         lotSize = CalculateKellyLotSize();
         break;
   }
   
   // تطبيق الحدود
   lotSize = MathMax(lotSize, InpMinLotSize);
   lotSize = MathMin(lotSize, InpMaxLotSize);
   lotSize = MathMax(lotSize, g_symbolInfo.LotsMin());
   lotSize = MathMin(lotSize, g_symbolInfo.LotsMax());
   
   // تقريب إلى أقرب خطوة مسموحة
   double lotStep = g_symbolInfo.LotsStep();
   lotSize = NormalizeDouble(MathRound(lotSize / lotStep) * lotStep, 2);
   
   return lotSize;
}

double CalculateKellyLotSize()
{
   if(g_stats.totalTrades < 10)
   {
      return InpLotSize;
   }
   
   double winRate = g_stats.winRate / 100.0;
   double avgWin = g_stats.avgWin;
   double avgLoss = MathAbs(g_stats.avgLoss);
   
   if(avgLoss <= 0)
   {
      return InpLotSize;
   }
   
   double kellyPercent = winRate - ((1 - winRate) * avgWin / avgLoss);
   kellyPercent = MathMax(kellyPercent, 0.01);
   kellyPercent = MathMin(kellyPercent, 0.25);
   
   double balance = g_accountInfo.Balance();
   return balance * kellyPercent / 10000.0;
}

double CalculateStopLoss(ENUM_ORDER_TYPE orderType, double entryPrice)
{
   double stopLoss = 0;
   
   switch(InpExitStrategy)
   {
      case EXIT_FIXED_TP_SL:
         {
            double distance = InpStopLossATR * 100 * g_symbolInfo.Point();
            stopLoss = (orderType == ORDER_TYPE_BUY) ? entryPrice - distance : entryPrice + distance;
         }
         break;
         
      case EXIT_ATR_BASED:
         {
            double atr = GetATRValue();
            if(atr > 0)
            {
               double distance = InpStopLossATR * atr;
               stopLoss = (orderType == ORDER_TYPE_BUY) ? entryPrice - distance : entryPrice + distance;
            }
         }
         break;
         
      case EXIT_TRAILING_STOP:
         {
            double distance = InpTrailingDistance * g_symbolInfo.Point();
            stopLoss = (orderType == ORDER_TYPE_BUY) ? entryPrice - distance : entryPrice + distance;
         }
         break;
         
      default:
         {
            double atr = GetATRValue();
            if(atr > 0)
            {
               stopLoss = (orderType == ORDER_TYPE_BUY) ? entryPrice - (atr * 2.0) : entryPrice + (atr * 2.0);
            }
         }
         break;
   }
   
   // تطبيق الحد الأدنى للمسافة
   double minDistance = g_symbolInfo.StopsLevel() * g_symbolInfo.Point();
   if(orderType == ORDER_TYPE_BUY)
   {
      stopLoss = MathMin(stopLoss, entryPrice - minDistance);
   }
   else
   {
      stopLoss = MathMax(stopLoss, entryPrice + minDistance);
   }
   
   return NormalizeDouble(stopLoss, g_symbolInfo.Digits());
}

double CalculateTakeProfit(ENUM_ORDER_TYPE orderType, double entryPrice)
{
   double takeProfit = 0;
   
   switch(InpExitStrategy)
   {
      case EXIT_FIXED_TP_SL:
         {
            double distance = InpTakeProfitATR * 100 * g_symbolInfo.Point();
            takeProfit = (orderType == ORDER_TYPE_BUY) ? entryPrice + distance : entryPrice - distance;
         }
         break;
         
      case EXIT_ATR_BASED:
         {
            double atr = GetATRValue();
            if(atr > 0)
            {
               double distance = InpTakeProfitATR * atr;
               takeProfit = (orderType == ORDER_TYPE_BUY) ? entryPrice + distance : entryPrice - distance;
            }
         }
         break;
         
      default:
         {
            double atr = GetATRValue();
            if(atr > 0)
            {
               takeProfit = (orderType == ORDER_TYPE_BUY) ? entryPrice + (atr * 3.0) : entryPrice - (atr * 3.0);
            }
         }
         break;
   }
   
   // تطبيق الحد الأدنى للمسافة
   double minDistance = g_symbolInfo.StopsLevel() * g_symbolInfo.Point();
   if(orderType == ORDER_TYPE_BUY)
   {
      takeProfit = MathMax(takeProfit, entryPrice + minDistance);
   }
   else
   {
      takeProfit = MathMin(takeProfit, entryPrice - minDistance);
   }
   
   return NormalizeDouble(takeProfit, g_symbolInfo.Digits());
}

//+------------------------------------------------------------------+
//| دوال إدارة المعلومات والإحصائيات                               |
//+------------------------------------------------------------------+
void RegisterNewTrade(ulong ticket, ENUM_ORDER_TYPE orderType, double entryPrice, 
                     double lotSize, double stopLoss, double takeProfit, string pattern)
{
   int size = ArraySize(g_activeTrades);
   ArrayResize(g_activeTrades, size + 1);
   
   g_activeTrades[size].ticket = ticket;
   g_activeTrades[size].symbol = Symbol();
   g_activeTrades[size].entryPrice = entryPrice;
   g_activeTrades[size].lotSize = lotSize;
   g_activeTrades[size].entryTime = TimeCurrent();
   g_activeTrades[size].patternUsed = pattern;
   g_activeTrades[size].stopLoss = stopLoss;
   g_activeTrades[size].takeProfit = takeProfit;
   g_activeTrades[size].riskAmount = CalculateRiskAmount(lotSize, entryPrice, stopLoss);
   g_activeTrades[size].isTrailingActive = InpUseTrailingStop;
   
   g_lastTradeTime = TimeCurrent();
}

double CalculateRiskAmount(double lotSize, double entryPrice, double stopLoss)
{
   if(stopLoss == 0) return 0;
   
   double pipValue = g_symbolInfo.TickValue() * 10;
   double riskInPips = MathAbs(entryPrice - stopLoss) / g_symbolInfo.Point();
   
   return riskInPips * pipValue * lotSize;
}

void UpdateTradeInfo(ulong ticket)
{
   for(int i = 0; i < ArraySize(g_activeTrades); i++)
   {
      if(g_activeTrades[i].ticket == ticket)
      {
         if(g_positionInfo.SelectByTicket(ticket))
         {
            double currentProfit = g_positionInfo.Profit();
            
            if(currentProfit > g_activeTrades[i].maxProfit)
               g_activeTrades[i].maxProfit = currentProfit;
               
            if(currentProfit < g_activeTrades[i].maxDrawdown)
               g_activeTrades[i].maxDrawdown = currentProfit;
         }
         break;
      }
   }
}

int GetActivePositionsCount()
{
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      if(g_positionInfo.SelectByIndex(i) && 
         g_positionInfo.Magic() == InpMagicNumber && 
         g_positionInfo.Symbol() == Symbol())
      {
         count++;
      }
   }
   return count;
}

double GetCurrentRiskPercent()
{
   double totalRisk = 0;
   double balance = g_accountInfo.Balance();
   
   for(int i = 0; i < ArraySize(g_activeTrades); i++)
   {
      totalRisk += g_activeTrades[i].riskAmount;
   }
   
   return balance > 0 ? (totalRisk / balance) * 100.0 : 0;
}

//+------------------------------------------------------------------+
//| دوال التهيئة والتنظيف                                           |
//+------------------------------------------------------------------+
bool ValidateInputParameters()
{
   if(InpMagicNumber <= 0)
   {
      Print("❌ الرقم السحري يجب أن يكون أكبر من صفر");
      return false;
   }
   
   if(InpRiskPercent <= 0 || InpRiskPercent > 100)
   {
      Print("❌ نسبة المخاطرة يجب أن تكون بين 0 و 100");
      return false;
   }
   
   if(InpLotSize < 0.01)
   {
      Print("❌ حجم الصفقة يجب أن يكون على الأقل 0.01");
      return false;
   }
   
   return true;
}

bool InitializeTradingSettings()
{
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetMarginMode();
   g_trade.SetTypeFillingBySymbol(Symbol());
   g_trade.SetDeviationInPoints(InpSlippage);
   
   if(!g_symbolInfo.Name(Symbol()))
   {
      Print("❌ لا يمكن تهيئة معلومات الرمز");
      return false;
   }
   
   g_symbolInfo.RefreshRates();
   return true;
}

bool InitializeIndicators()
{
   g_atrHandle = iATR(Symbol(), PERIOD_CURRENT, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
   {
      Print("❌ فشل في إنشاء مؤشر ATR");
      return false;
   }
   
   g_maHandle = iMA(Symbol(), PERIOD_CURRENT, InpTrendPeriod, 0, MODE_SMA, PRICE_CLOSE);
   if(g_maHandle == INVALID_HANDLE)
   {
      Print("❌ فشل في إنشاء مؤشر المتوسط المتحرك");
      return false;
   }
   
   return true;
}

void InitializeRiskManagement()
{
   g_initialBalance = g_accountInfo.Balance();
   g_dailyStartBalance = g_initialBalance;
   g_maxEquity = g_accountInfo.Equity();
   g_tradingAllowed = true;
   g_emergencyStop = false;
}

void InitializeStatistics()
{
   g_stats = SPerformanceStats();
}

void CleanupIndicators()
{
   if(g_atrHandle != INVALID_HANDLE)
   {
      IndicatorRelease(g_atrHandle);
      g_atrHandle = INVALID_HANDLE;
   }
   
   if(g_maHandle != INVALID_HANDLE)
   {
      IndicatorRelease(g_maHandle);
      g_maHandle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| دوال المؤشرات والتحليل                                         |
//+------------------------------------------------------------------+
double GetATRValue()
{
   double atr[];
   if(CopyBuffer(g_atrHandle, 0, 0, 1, atr) > 0)
      return atr[0];
   return 0;
}

double GetMAValue()
{
   double ma[];
   if(CopyBuffer(g_maHandle, 0, 0, 1, ma) > 0)
      return ma[0];
   return 0;
}

//+------------------------------------------------------------------+
//| دوال الوقت والمرشحات                                           |
//+------------------------------------------------------------------+
bool IsWithinTradingHours()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(dt.day_of_week == 0 || dt.day_of_week == 6) // السبت والأحد
      return false;
      
   if(!InpTradeOnFriday && dt.day_of_week == 5 && dt.hour >= 20)
      return false;
   
   return (dt.hour >= InpStartHour && dt.hour <= InpEndHour);
}

void CheckNewDay()
{
   datetime current = TimeCurrent();
   MqlDateTime dtCurrent, dtPrevious;
   TimeToStruct(current, dtCurrent);
   TimeToStruct(g_currentDate, dtPrevious);
   
   if(dtCurrent.day != dtPrevious.day)
   {
      g_currentDate = current;
      g_dailyStartBalance = g_accountInfo.Balance();
      
      if(InpCreateDailyReport)
      {
         CreateDailyReport();
      }
   }
}

//+------------------------------------------------------------------+
//| دوال الحماية والمراقبة                                         |
//+------------------------------------------------------------------+
bool IsDrawdownExceeded()
{
   double currentEquity = g_accountInfo.Equity();
   double drawdown = (g_maxEquity - currentEquity) / g_maxEquity * 100.0;
   
   return drawdown > InpMaxDrawdownPercent;
}

bool IsEquityTooLow()
{
   double equity = g_accountInfo.Equity();
   double equityPercent = equity / g_initialBalance * 100.0;
   
   return equityPercent < InpMinEquityPercent;
}

bool CheckPatternReversal(ulong ticket)
{
   // منطق فحص انعكاس النمط - يمكن تطويره
   return false;
}

void UpdateMarketInfo()
{
   g_symbolInfo.RefreshRates();
   
   double currentEquity = g_accountInfo.Equity();
   if(currentEquity > g_maxEquity)
      g_maxEquity = currentEquity;
}

void UpdateProtectionSystems()
{
   if(InpUseDailyLossLimit)
   {
      double currentBalance = g_accountInfo.Balance();
      double dailyLoss = (g_dailyStartBalance - currentBalance) / g_dailyStartBalance * 100.0;
      
      if(dailyLoss > InpDailyLossLimitPercent)
      {
         g_emergencyStop = true;
         CloseAllPositions();
         SendAlert("🚨 تم تفعيل الإيقاف الطارئ - تجاوز حد الخسارة اليومية");
      }
   }
}

void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(g_positionInfo.SelectByIndex(i) && 
         g_positionInfo.Magic() == InpMagicNumber && 
         g_positionInfo.Symbol() == Symbol())
      {
         g_trade.PositionClose(g_positionInfo.Ticket());
      }
   }
}

//+------------------------------------------------------------------+
//| دوال الإشعارات والتقارير                                        |
//+------------------------------------------------------------------+
void SendAlert(string message)
{
   if(InpSendAlerts)
   {
      Alert(message);
   }
   
   if(InpSendEmails)
   {
      SendMail("تنبيه روبوت التداول", message);
   }
   
   if(InpSendPushNotifications)
   {
      SendNotification(message);
   }
   
   Print(message);
}

//+------------------------------------------------------------------+
//| دوال الواجهة                                                    |
//+------------------------------------------------------------------+
void CreateDashboard()
{
   string panelName = "EA_Dashboard";
   
   if(ObjectCreate(0, panelName, OBJ_RECTANGLE_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, panelName, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, panelName, OBJPROP_YDISTANCE, 10);
      ObjectSetInteger(0, panelName, OBJPROP_XSIZE, 350);
      ObjectSetInteger(0, panelName, OBJPROP_YSIZE, 300);
      ObjectSetInteger(0, panelName, OBJPROP_BGCOLOR, clrNavy);
      ObjectSetInteger(0, panelName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, panelName, OBJPROP_BORDER_COLOR, clrSilver);
   }
}

void UpdateDashboard()
{
   string info = StringFormat(
      "🤖 روبوت التداول المتكامل\n" +
      "💰 الرصيد: %.2f\n" +
      "📊 حقوق الملكية: %.2f\n" +
      "📈 الصفقات النشطة: %d/%d\n" +
      "🎯 إجمالي الصفقات: %d\n" +
      "✅ الصفقات الرابحة: %d\n" +
      "❌ الصفقات الخاسرة: %d\n" +
      "📊 معدل الربح: %.1f%%\n" +
      "💵 صافي الربح: %.2f\n" +
      "📉 أقصى سحب: %.2f%%\n" +
      "🛡️ حالة الحماية: %s\n" +
      "🕒 آخر تحديث: %s",
      g_accountInfo.Balance(),
      g_accountInfo.Equity(),
      GetActivePositionsCount(),
      InpMaxPositions,
      g_stats.totalTrades,
      g_stats.winningTrades,
      g_stats.losingTrades,
      g_stats.winRate,
      g_stats.netProfit,
      g_stats.maxDrawdownPercent,
      g_emergencyStop ? "متوقف" : "نشط",
      TimeToString(TimeCurrent(), TIME_MINUTES)
   );
   
   string labelName = "EA_Info";
   if(ObjectFind(0, labelName) < 0)
   {
      ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
   }
   
   ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, 30);
   ObjectSetString(0, labelName, OBJPROP_TEXT, info);
   ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, 9);
}

void CleanupDashboard()
{
   ObjectDelete(0, "EA_Dashboard");
   ObjectDelete(0, "EA_Info");
}

void CreateDailyReport()
{
   Print("=== التقرير اليومي ===");
   // يمكن إضافة المزيد من التفاصيل
}

void CreatePeriodicReport()
{
   // تقرير دوري
}

void CreateFinalReport()
{
   Print("=== التقرير النهائي ===");
   Print("إجمالي الصفقات: ", g_stats.totalTrades);
   Print("الصفقات الرابحة: ", g_stats.winningTrades);
   Print("معدل الربح: ", g_stats.winRate, "%");
   Print("صافي الربح: ", g_stats.netProfit);
}

void SaveStatistics()
{
   // حفظ الإحصائيات في ملف
}

//+------------------------------------------------------------------+
//| نهاية الملف                                                     |
//+------------------------------------------------------------------+