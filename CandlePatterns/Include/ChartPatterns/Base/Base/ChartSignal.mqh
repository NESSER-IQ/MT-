//+------------------------------------------------------------------+
//|                                                ChartSignal.mqh |
//|                                 إشارات أنماط المخططات          |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "ChartPattern.mqh"
#include "..\..\CandlePatterns\Base\PatternSignal.mqh"

//+------------------------------------------------------------------+
//| تعدادات إشارات المخططات                                         |
//+------------------------------------------------------------------+
enum ENUM_CHART_SIGNAL_TYPE
{
   CHART_SIGNAL_ENTRY,          // إشارة دخول
   CHART_SIGNAL_EXIT,           // إشارة خروج
   CHART_SIGNAL_REVERSAL,       // إشارة انعكاس
   CHART_SIGNAL_CONTINUATION,   // إشارة استمرار
   CHART_SIGNAL_BREAKOUT,       // إشارة اختراق
   CHART_SIGNAL_PULLBACK,       // إشارة تراجع
   CHART_SIGNAL_WARNING,        // إشارة تحذير
   CHART_SIGNAL_CONFIRMATION    // إشارة تأكيد
};

enum ENUM_CHART_SIGNAL_STRENGTH
{
   CHART_SIGNAL_WEAK,           // ضعيفة
   CHART_SIGNAL_MODERATE,       // متوسطة
   CHART_SIGNAL_STRONG,         // قوية
   CHART_SIGNAL_VERY_STRONG     // قوية جداً
};

enum ENUM_CHART_SIGNAL_URGENCY
{
   CHART_SIGNAL_LOW_URGENCY,    // عجالة منخفضة
   CHART_SIGNAL_MEDIUM_URGENCY, // عجالة متوسطة
   CHART_SIGNAL_HIGH_URGENCY,   // عجالة عالية
   CHART_SIGNAL_IMMEDIATE       // فوري
};

//+------------------------------------------------------------------+
//| هيكل إشارة المخطط                                               |
//+------------------------------------------------------------------+
struct SChartSignal
{
   string            signalId;           // معرف الإشارة
   ENUM_CHART_SIGNAL_TYPE signalType;    // نوع الإشارة
   ENUM_PATTERN_DIRECTION direction;     // اتجاه الإشارة
   ENUM_CHART_SIGNAL_STRENGTH strength;  // قوة الإشارة
   ENUM_CHART_SIGNAL_URGENCY urgency;    // درجة العجالة
   
   string            patternName;        // اسم النمط
   double            triggerPrice;       // سعر التفعيل
   datetime          signalTime;         // وقت الإشارة
   datetime          expirationTime;     // وقت انتهاء الصلاحية
   
   // مستويات التداول
   double            entryPrice;         // سعر الدخول
   double            stopLoss;           // وقف الخسارة
   double            takeProfit1;        // هدف ربح 1
   double            takeProfit2;        // هدف ربح 2
   double            takeProfit3;        // هدف ربح 3
   
   // معلومات المخاطر
   double            riskRewardRatio;    // نسبة المخاطر للعائد
   double            probability;        // احتمالية النجاح
   double            confidence;         // مستوى الثقة
   
   // معلومات السياق
   string            marketCondition;    // حالة السوق
   string            timeframeAnalysis;  // تحليل الإطار الزمني
   bool              hasConfirmation;    // تأكيد من مؤشرات أخرى
   
   // معلومات إضافية
   string            description;        // وصف الإشارة
   string            actionRequired;     // الإجراء المطلوب
   string            notes;              // ملاحظات
   bool              isActive;           // الإشارة نشطة
   bool              wasTriggered;       // تم تفعيل الإشارة
   
   SChartSignal()
   {
      signalId = "";
      signalType = CHART_SIGNAL_ENTRY;
      direction = PATTERN_NEUTRAL;
      strength = CHART_SIGNAL_WEAK;
      urgency = CHART_SIGNAL_LOW_URGENCY;
      
      patternName = "";
      triggerPrice = 0.0;
      signalTime = 0;
      expirationTime = 0;
      
      entryPrice = 0.0;
      stopLoss = 0.0;
      takeProfit1 = 0.0;
      takeProfit2 = 0.0;
      takeProfit3 = 0.0;
      
      riskRewardRatio = 0.0;
      probability = 0.0;
      confidence = 0.0;
      
      marketCondition = "";
      timeframeAnalysis = "";
      hasConfirmation = false;
      
      description = "";
      actionRequired = "";
      notes = "";
      isActive = false;
      wasTriggered = false;
   }
};

//+------------------------------------------------------------------+
//| هيكل مجموعة الإشارات                                            |
//+------------------------------------------------------------------+
struct SSignalGroup
{
   string            groupId;            // معرف المجموعة
   string            groupName;          // اسم المجموعة
   ENUM_PATTERN_DIRECTION groupDirection; // اتجاه المجموعة
   
   SChartSignal      signals[];          // الإشارات في المجموعة
   int               signalCount;        // عدد الإشارات
   
   double            combinedProbability; // الاحتمالية المجمعة
   double            combinedConfidence;  // الثقة المجمعة
   ENUM_CHART_SIGNAL_STRENGTH combinedStrength; // القوة المجمعة
   
   datetime          firstSignalTime;    // وقت أول إشارة
   datetime          lastSignalTime;     // وقت آخر إشارة
   bool              isConsensus;        // إجماع الإشارات
   
   SSignalGroup()
   {
      groupId = "";
      groupName = "";
      groupDirection = PATTERN_NEUTRAL;
      signalCount = 0;
      combinedProbability = 0.0;
      combinedConfidence = 0.0;
      combinedStrength = CHART_SIGNAL_WEAK;
      firstSignalTime = 0;
      lastSignalTime = 0;
      isConsensus = false;
      ArrayResize(signals, 0);
   }
};

//+------------------------------------------------------------------+
//| فئة إشارات أنماط المخططات                                       |
//+------------------------------------------------------------------+
class CChartSignal
{
private:
   // إعدادات المولد
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   bool              m_initialized;
   
   // معاملات توليد الإشارات
   double            m_minProbability;      // أقل احتمالية مقبولة
   double            m_minConfidence;       // أقل ثقة مقبولة
   double            m_maxRiskReward;       // أقصى نسبة مخاطر مقبولة
   bool              m_requireConfirmation; // يتطلب تأكيد
   bool              m_combineSignals;      // دمج الإشارات
   
   // قوائم الإشارات
   SChartSignal      m_activeSignals[];     // الإشارات النشطة
   SChartSignal      m_historicalSignals[]; // الإشارات التاريخية
   SSignalGroup      m_signalGroups[];      // مجموعات الإشارات
   
   // إحصائيات الأداء
   int               m_totalSignals;
   int               m_successfulSignals;
   int               m_triggeredSignals;
   double            m_avgProfitLoss;
   double            m_winRate;
   
public:
   // المنشئ والهادم
                     CChartSignal();
                     ~CChartSignal();
   
   // تهيئة المولد
   bool              Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   void              Deinitialize();
   
   // إعداد المعاملات
   void              SetSignalParameters(const double minProbability, const double minConfidence,
                                       const double maxRiskReward, const bool requireConfirmation = true,
                                       const bool combineSignals = true);
   
   // توليد الإشارات
   int               GenerateSignalsFromPattern(const SChartPatternResult &patternResult,
                                              SChartSignal &signals[]);
   
   bool              CreateEntrySignal(const SChartPatternResult &patternResult, SChartSignal &signal);
   bool              CreateExitSignal(const SChartPatternResult &patternResult, SChartSignal &signal);
   bool              CreateBreakoutSignal(const SChartPatternResult &patternResult, SChartSignal &signal);
   bool              CreateReversalSignal(const SChartPatternResult &patternResult, SChartSignal &signal);
   
   // إدارة الإشارات
   bool              AddSignal(const SChartSignal &signal);
   bool              UpdateSignal(const string signalId, const SChartSignal &updatedSignal);
   bool              RemoveSignal(const string signalId);
   void              ClearExpiredSignals();
   
   // تجميع الإشارات
   int               GroupSignalsByDirection(SSignalGroup &groups[]);
   int               GroupSignalsByTimeframe(SSignalGroup &groups[]);
   int               GroupSignalsByPattern(SSignalGroup &groups[]);
   bool              CreateSignalGroup(const SChartSignal &signals[], SSignalGroup &group);
   
   // تحليل الإشارات
   ENUM_CHART_SIGNAL_STRENGTH CalculateSignalStrength(const SChartSignal &signal);
   ENUM_CHART_SIGNAL_URGENCY CalculateSignalUrgency(const SChartSignal &signal);
   double            CalculateProbability(const SChartPatternResult &patternResult);
   double            CalculateRiskReward(const SChartSignal &signal);
   
   // إدارة المخاطر
   bool              ValidateRiskParameters(const SChartSignal &signal);
   void              OptimizeStopLoss(SChartSignal &signal);
   void              OptimizeTakeProfit(SChartSignal &signal);
   void              CalculatePositionSize(SChartSignal &signal, const double accountBalance,
                                         const double riskPercent);
   
   // مراقبة الإشارات
   int               MonitorActiveSignals(const double currentPrice);
   bool              CheckSignalTrigger(SChartSignal &signal, const double currentPrice);
   void              UpdateSignalStatus(SChartSignal &signal, const double currentPrice);
   
   // تصفية الإشارات
   int               FilterSignalsByStrength(const ENUM_CHART_SIGNAL_STRENGTH minStrength,
                                           SChartSignal &filteredSignals[]);
   int               FilterSignalsByDirection(const ENUM_PATTERN_DIRECTION direction,
                                            SChartSignal &filteredSignals[]);
   int               FilterSignalsByTimeframe(const datetime startTime, const datetime endTime,
                                            SChartSignal &filteredSignals[]);
   
   // الوصول للبيانات
   int               GetActiveSignalsCount() const { return ArraySize(m_activeSignals); }
   int               GetHistoricalSignalsCount() const { return ArraySize(m_historicalSignals); }
   int               GetSignalGroupsCount() const { return ArraySize(m_signalGroups); }
   
   SChartSignal      GetActiveSignal(const int index) const;
   SChartSignal      GetHistoricalSignal(const int index) const;
   SSignalGroup      GetSignalGroup(const int index) const;
   SChartSignal      FindSignalById(const string signalId);
   
   // إحصائيات الأداء
   double            GetWinRate() const { return m_winRate; }
   double            GetAverageProfitLoss() const { return m_avgProfitLoss; }
   int               GetTotalSignals() const { return m_totalSignals; }
   int               GetSuccessfulSignals() const { return m_successfulSignals; }
   
   // تقارير الأداء
   string            GeneratePerformanceReport();
   string            GenerateSignalSummary(const SChartSignal &signal);
   string            GenerateGroupSummary(const SSignalGroup &group);
   
protected:
   // دوال مساعدة
   string            GenerateSignalId();
   bool              ValidateSignal(const SChartSignal &signal);
   void              CalculateSignalExpiration(SChartSignal &signal);
   
   // تحديث الإحصائيات
   void              UpdatePerformanceStats();
   void              RecordSignalOutcome(const SChartSignal &signal, const bool success, 
                                       const double profitLoss);
   
   // دوال التأكيد
   bool              HasTechnicalConfirmation(const SChartPatternResult &patternResult);
   bool              HasVolumeConfirmation(const SChartPatternResult &patternResult);
   bool              HasMomentumConfirmation(const SChartPatternResult &patternResult);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CChartSignal::CChartSignal()
{
   m_symbol = "";
   m_timeframe = PERIOD_CURRENT;
   m_initialized = false;
   
   // المعاملات الافتراضية
   m_minProbability = 0.6;
   m_minConfidence = 0.5;
   m_maxRiskReward = 0.5; // مخاطرة 50% من العائد المتوقع
   m_requireConfirmation = true;
   m_combineSignals = true;
   
   // تهيئة المصفوفات
   ArrayResize(m_activeSignals, 0);
   ArrayResize(m_historicalSignals, 0);
   ArrayResize(m_signalGroups, 0);
   
   // إحصائيات
   m_totalSignals = 0;
   m_successfulSignals = 0;
   m_triggeredSignals = 0;
   m_avgProfitLoss = 0.0;
   m_winRate = 0.0;
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CChartSignal::~CChartSignal()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة المولد                                                     |
//+------------------------------------------------------------------+
bool CChartSignal::Initialize(const string symbol = "", const ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   m_symbol = (symbol == "") ? Symbol() : symbol;
   m_timeframe = (timeframe == PERIOD_CURRENT) ? Period() : timeframe;
   
   m_initialized = true;
   Print("تم تهيئة مولد إشارات المخططات للرمز: ", m_symbol, " الإطار الزمني: ", EnumToString(m_timeframe));
   
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء المولد                                                    |
//+------------------------------------------------------------------+
void CChartSignal::Deinitialize()
{
   if(m_initialized)
   {
      ArrayFree(m_activeSignals);
      ArrayFree(m_historicalSignals);
      ArrayFree(m_signalGroups);
      
      m_initialized = false;
   }
}

//+------------------------------------------------------------------+
//| تحديد معاملات الإشارة                                           |
//+------------------------------------------------------------------+
void CChartSignal::SetSignalParameters(const double minProbability, const double minConfidence,
                                       const double maxRiskReward, const bool requireConfirmation = true,
                                       const bool combineSignals = true)
{
   m_minProbability = MathMax(0.0, MathMin(1.0, minProbability));
   m_minConfidence = MathMax(0.0, MathMin(1.0, minConfidence));
   m_maxRiskReward = MathMax(0.1, maxRiskReward);
   m_requireConfirmation = requireConfirmation;
   m_combineSignals = combineSignals;
}

//+------------------------------------------------------------------+
//| توليد إشارات من النمط                                           |
//+------------------------------------------------------------------+
int CChartSignal::GenerateSignalsFromPattern(const SChartPatternResult &patternResult,
                                            SChartSignal &signals[])
{
   ArrayResize(signals, 0);
   
   if(!m_initialized || !patternResult.isCompleted)
      return 0;
   
   // فحص إذا كان النمط يستوفي المعايير الأساسية
   if(patternResult.confidence < m_minConfidence)
      return 0;
   
   // توليد الإشارات المختلفة
   SChartSignal tempSignals[];
   ArrayResize(tempSignals, 0);
   
   // إشارة دخول
   SChartSignal entrySignal;
   if(CreateEntrySignal(patternResult, entrySignal))
   {
      int size = ArraySize(tempSignals);
      ArrayResize(tempSignals, size + 1);
      tempSignals[size] = entrySignal;
   }
   
   // إشارة اختراق إذا كان النمط يدعم ذلك
   if(patternResult.patternType == CHART_PATTERN_CONTINUATION || 
      patternResult.patternType == CHART_PATTERN_BILATERAL)
   {
      SChartSignal breakoutSignal;
      if(CreateBreakoutSignal(patternResult, breakoutSignal))
      {
         int size = ArraySize(tempSignals);
         ArrayResize(tempSignals, size + 1);
         tempSignals[size] = breakoutSignal;
      }
   }
   
   // إشارة انعكاس إذا كان النمط انعكاسي
   if(patternResult.patternType == CHART_PATTERN_REVERSAL)
   {
      SChartSignal reversalSignal;
      if(CreateReversalSignal(patternResult, reversalSignal))
      {
         int size = ArraySize(tempSignals);
         ArrayResize(tempSignals, size + 1);
         tempSignals[size] = reversalSignal;
      }
   }
   
   // تصفية الإشارات
   for(int i = 0; i < ArraySize(tempSignals); i++)
   {
      if(ValidateSignal(tempSignals[i]))
      {
         // فحص التأكيد إذا كان مطلوب
         if(!m_requireConfirmation || tempSignals[i].hasConfirmation)
         {
            int size = ArraySize(signals);
            ArrayResize(signals, size + 1);
            signals[size] = tempSignals[i];
         }
      }
   }
   
   return ArraySize(signals);
}

//+------------------------------------------------------------------+
//| إنشاء إشارة دخول                                                |
//+------------------------------------------------------------------+
bool CChartSignal::CreateEntrySignal(const SChartPatternResult &patternResult, SChartSignal &signal)
{
   signal = SChartSignal(); // تهيئة
   
   signal.signalId = GenerateSignalId();
   signal.signalType = CHART_SIGNAL_ENTRY;
   signal.direction = patternResult.direction;
   signal.patternName = patternResult.patternName;
   signal.signalTime = patternResult.detectionTime;
   
   // تحديد أسعار التداول
   signal.entryPrice = patternResult.entryPrice;
   signal.stopLoss = patternResult.stopLoss;
   signal.takeProfit1 = patternResult.priceTarget;
   
   // حساب أهداف إضافية
   double patternHeight = patternResult.patternHeight;
   if(patternHeight > 0.0)
   {
      if(signal.direction == PATTERN_BULLISH)
      {
         signal.takeProfit2 = signal.takeProfit1 + (patternHeight * 0.5);
         signal.takeProfit3 = signal.takeProfit1 + patternHeight;
      }
      else if(signal.direction == PATTERN_BEARISH)
      {
         signal.takeProfit2 = signal.takeProfit1 - (patternHeight * 0.5);
         signal.takeProfit3 = signal.takeProfit1 - patternHeight;
      }
   }
   
   // حساب المخاطر والعائد
   signal.riskRewardRatio = CalculateRiskReward(signal);
   signal.probability = CalculateProbability(patternResult);
   signal.confidence = patternResult.confidence;
   
   // قوة ودرجة عجالة الإشارة
   signal.strength = CalculateSignalStrength(signal);
   signal.urgency = CalculateSignalUrgency(signal);
   
   // معلومات إضافية
   signal.description = "إشارة دخول بناءً على نمط " + patternResult.patternName;
   signal.actionRequired = (signal.direction == PATTERN_BULLISH) ? "شراء" : "بيع";
   signal.hasConfirmation = HasTechnicalConfirmation(patternResult);
   
   // تحديد انتهاء الصلاحية
   CalculateSignalExpiration(signal);
   
   signal.isActive = true;
   signal.wasTriggered = false;
   
   return true;
}

//+------------------------------------------------------------------+
//| إنشاء إشارة خروج                                                |
//+------------------------------------------------------------------+
bool CChartSignal::CreateExitSignal(const SChartPatternResult &patternResult, SChartSignal &signal)
{
   signal = SChartSignal();
   
   signal.signalId = GenerateSignalId();
   signal.signalType = CHART_SIGNAL_EXIT;
   signal.direction = (patternResult.direction == PATTERN_BULLISH) ? PATTERN_BEARISH : PATTERN_BULLISH;
   signal.patternName = patternResult.patternName;
   signal.signalTime = patternResult.detectionTime;
   
   signal.triggerPrice = patternResult.entryPrice;
   signal.probability = CalculateProbability(patternResult) * 0.8; // أقل قليلاً من إشارة الدخول
   signal.confidence = patternResult.confidence * 0.9;
   
   signal.description = "إشارة خروج بناءً على اكتمال نمط " + patternResult.patternName;
   signal.actionRequired = "إغلاق المركز";
   
   signal.strength = CalculateSignalStrength(signal);
   signal.urgency = CHART_SIGNAL_HIGH_URGENCY; // إشارات الخروج عادة عاجلة
   
   CalculateSignalExpiration(signal);
   
   signal.isActive = true;
   return true;
}

//+------------------------------------------------------------------+
//| إنشاء إشارة اختراق                                              |
//+------------------------------------------------------------------+
bool CChartSignal::CreateBreakoutSignal(const SChartPatternResult &patternResult, SChartSignal &signal)
{
   signal = SChartSignal();
   
   signal.signalId = GenerateSignalId();
   signal.signalType = CHART_SIGNAL_BREAKOUT;
   signal.direction = patternResult.direction;
   signal.patternName = patternResult.patternName;
   signal.signalTime = patternResult.detectionTime;
   
   // سعر التفعيل يكون عند مستوى الاختراق المتوقع
   if(ArraySize(patternResult.keyPoints) > 0)
   {
      if(signal.direction == PATTERN_BULLISH)
         signal.triggerPrice = patternResult.keyPoints[ArraySize(patternResult.keyPoints)-1].price * 1.002; // 0.2% فوق
      else
         signal.triggerPrice = patternResult.keyPoints[ArraySize(patternResult.keyPoints)-1].price * 0.998; // 0.2% تحت
   }
   else
   {
      signal.triggerPrice = patternResult.entryPrice;
   }
   
   signal.entryPrice = signal.triggerPrice;
   signal.stopLoss = patternResult.stopLoss;
   signal.takeProfit1 = patternResult.priceTarget;
   
   signal.probability = CalculateProbability(patternResult) * 0.9; // اختراق قد يكون كاذب
   signal.confidence = patternResult.confidence;
   signal.riskRewardRatio = CalculateRiskReward(signal);
   
   signal.description = "إشارة اختراق متوقع من نمط " + patternResult.patternName;
   signal.actionRequired = "انتظار اختراق ثم دخول";
   signal.hasConfirmation = patternResult.hasVolConfirmation;
   
   signal.strength = CalculateSignalStrength(signal);
   signal.urgency = CHART_SIGNAL_MEDIUM_URGENCY;
   
   CalculateSignalExpiration(signal);
   
   signal.isActive = true;
   return true;
}

//+------------------------------------------------------------------+
//| إنشاء إشارة انعكاس                                              |
//+------------------------------------------------------------------+
bool CChartSignal::CreateReversalSignal(const SChartPatternResult &patternResult, SChartSignal &signal)
{
   signal = SChartSignal();
   
   signal.signalId = GenerateSignalId();
   signal.signalType = CHART_SIGNAL_REVERSAL;
   signal.direction = patternResult.direction;
   signal.patternName = patternResult.patternName;
   signal.signalTime = patternResult.detectionTime;
   
   signal.entryPrice = patternResult.entryPrice;
   signal.stopLoss = patternResult.stopLoss;
   signal.takeProfit1 = patternResult.priceTarget;
   
   // انعكاسات عادة لها أهداف أكبر
   double patternHeight = patternResult.patternHeight;
   if(patternHeight > 0.0)
   {
      if(signal.direction == PATTERN_BULLISH)
      {
         signal.takeProfit2 = signal.takeProfit1 + patternHeight;
         signal.takeProfit3 = signal.takeProfit1 + (patternHeight * 1.618); // نسبة فيبوناتشي
      }
      else if(signal.direction == PATTERN_BEARISH)
      {
         signal.takeProfit2 = signal.takeProfit1 - patternHeight;
         signal.takeProfit3 = signal.takeProfit1 - (patternHeight * 1.618);
      }
   }
   
   signal.probability = CalculateProbability(patternResult);
   signal.confidence = patternResult.confidence;
   signal.riskRewardRatio = CalculateRiskReward(signal);
   
   signal.description = "إشارة انعكاس بناءً على نمط " + patternResult.patternName;
   signal.actionRequired = (signal.direction == PATTERN_BULLISH) ? "انعكاس صعودي - شراء" : "انعكاس هبوطي - بيع";
   signal.hasConfirmation = HasTechnicalConfirmation(patternResult);
   
   signal.strength = CalculateSignalStrength(signal);
   signal.urgency = CHART_SIGNAL_HIGH_URGENCY; // انعكاسات مهمة
   
   CalculateSignalExpiration(signal);
   
   signal.isActive = true;
   return true;
}

//+------------------------------------------------------------------+
//| إضافة إشارة                                                     |
//+------------------------------------------------------------------+
bool CChartSignal::AddSignal(const SChartSignal &signal)
{
   if(!ValidateSignal(signal))
      return false;
   
   int size = ArraySize(m_activeSignals);
   ArrayResize(m_activeSignals, size + 1);
   m_activeSignals[size] = signal;
   
   m_totalSignals++;
   
   return true;
}

//+------------------------------------------------------------------+
//| تحديث إشارة                                                     |
//+------------------------------------------------------------------+
bool CChartSignal::UpdateSignal(const string signalId, const SChartSignal &updatedSignal)
{
   for(int i = 0; i < ArraySize(m_activeSignals); i++)
   {
      if(m_activeSignals[i].signalId == signalId)
      {
         m_activeSignals[i] = updatedSignal;
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| إزالة إشارة                                                     |
//+------------------------------------------------------------------+
bool CChartSignal::RemoveSignal(const string signalId)
{
   for(int i = 0; i < ArraySize(m_activeSignals); i++)
   {
      if(m_activeSignals[i].signalId == signalId)
      {
         // نقل الإشارة للتاريخ
         int histSize = ArraySize(m_historicalSignals);
         ArrayResize(m_historicalSignals, histSize + 1);
         m_historicalSignals[histSize] = m_activeSignals[i];
         
         // حذف من القائمة النشطة
         for(int j = i; j < ArraySize(m_activeSignals) - 1; j++)
            m_activeSignals[j] = m_activeSignals[j + 1];
         
         ArrayResize(m_activeSignals, ArraySize(m_activeSignals) - 1);
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| مسح الإشارات المنتهية الصلاحية                                  |
//+------------------------------------------------------------------+
void CChartSignal::ClearExpiredSignals()
{
   datetime currentTime = TimeCurrent();
   
   for(int i = ArraySize(m_activeSignals) - 1; i >= 0; i--)
   {
      if(m_activeSignals[i].expirationTime > 0 && currentTime > m_activeSignals[i].expirationTime)
      {
         RemoveSignal(m_activeSignals[i].signalId);
      }
   }
}

//+------------------------------------------------------------------+
//| حساب قوة الإشارة                                                |
//+------------------------------------------------------------------+
ENUM_CHART_SIGNAL_STRENGTH CChartSignal::CalculateSignalStrength(const SChartSignal &signal)
{
   double strength = 0.0;
   
   // عامل الاحتمالية (0-40%)
   strength += signal.probability * 0.4;
   
   // عامل الثقة (0-30%)
   strength += signal.confidence * 0.3;
   
   // عامل نسبة المخاطر للعائد (0-20%)
   if(signal.riskRewardRatio > 0.0)
      strength += MathMin(1.0 / signal.riskRewardRatio / 3.0, 0.2);
   
   // عامل التأكيد (0-10%)
   if(signal.hasConfirmation)
      strength += 0.1;
   
   if(strength >= 0.8)
      return CHART_SIGNAL_VERY_STRONG;
   else if(strength >= 0.6)
      return CHART_SIGNAL_STRONG;
   else if(strength >= 0.4)
      return CHART_SIGNAL_MODERATE;
   else
      return CHART_SIGNAL_WEAK;
}

//+------------------------------------------------------------------+
//| حساب درجة عجالة الإشارة                                         |
//+------------------------------------------------------------------+
ENUM_CHART_SIGNAL_URGENCY CChartSignal::CalculateSignalUrgency(const SChartSignal &signal)
{
   // إشارات الخروج والانعكاس لها أولوية عالية
   if(signal.signalType == CHART_SIGNAL_EXIT || signal.signalType == CHART_SIGNAL_REVERSAL)
      return CHART_SIGNAL_HIGH_URGENCY;
   
   // إشارات قوية جداً تكون فورية
   if(signal.strength == CHART_SIGNAL_VERY_STRONG)
      return CHART_SIGNAL_IMMEDIATE;
   
   // إشارات قوية تكون عالية العجالة
   if(signal.strength == CHART_SIGNAL_STRONG)
      return CHART_SIGNAL_HIGH_URGENCY;
   
   // إشارات متوسطة تكون متوسطة العجالة
   if(signal.strength == CHART_SIGNAL_MODERATE)
      return CHART_SIGNAL_MEDIUM_URGENCY;
   
   return CHART_SIGNAL_LOW_URGENCY;
}

//+------------------------------------------------------------------+
//| حساب الاحتمالية                                                 |
//+------------------------------------------------------------------+
double CChartSignal::CalculateProbability(const SChartPatternResult &patternResult)
{
   double probability = patternResult.confidence;
   
   // تعديل بناءً على نوع النمط
   switch(patternResult.patternType)
   {
      case CHART_PATTERN_REVERSAL:
         probability *= 0.9; // انعكاسات أصعب
         break;
      case CHART_PATTERN_CONTINUATION:
         probability *= 1.1; // استمرار أسهل
         break;
      case CHART_PATTERN_HARMONIC:
         probability *= 1.05; // أنماط توافقية موثوقة
         break;
   }
   
   // تعديل بناءً على تأكيد الحجم
   if(patternResult.hasVolConfirmation)
      probability *= 1.1;
   
   // تعديل بناءً على الاكتمال
   probability *= (patternResult.completionPercentage / 100.0);
   
   return MathMin(probability, 0.95); // أقصى احتمالية 95%
}

//+------------------------------------------------------------------+
//| حساب نسبة المخاطر للعائد                                        |
//+------------------------------------------------------------------+
double CChartSignal::CalculateRiskReward(const SChartSignal &signal)
{
   if(signal.takeProfit1 == 0.0 || signal.stopLoss == 0.0 || signal.entryPrice == 0.0)
      return 0.0;
   
   double risk = MathAbs(signal.entryPrice - signal.stopLoss);
   double reward = MathAbs(signal.takeProfit1 - signal.entryPrice);
   
   if(reward == 0.0)
      return DBL_MAX;
   
   return risk / reward;
}

//+------------------------------------------------------------------+
//| مراقبة الإشارات النشطة                                          |
//+------------------------------------------------------------------+
int CChartSignal::MonitorActiveSignals(const double currentPrice)
{
   int triggeredCount = 0;
   
   for(int i = 0; i < ArraySize(m_activeSignals); i++)
   {
      if(CheckSignalTrigger(m_activeSignals[i], currentPrice))
      {
         triggeredCount++;
         m_triggeredSignals++;
      }
      
      UpdateSignalStatus(m_activeSignals[i], currentPrice);
   }
   
   // مسح الإشارات المنتهية الصلاحية
   ClearExpiredSignals();
   
   return triggeredCount;
}

//+------------------------------------------------------------------+
//| فحص تفعيل الإشارة                                               |
//+------------------------------------------------------------------+
bool CChartSignal::CheckSignalTrigger(SChartSignal &signal, const double currentPrice)
{
   if(signal.wasTriggered)
      return false;
   
   bool triggered = false;
   
   if(signal.triggerPrice > 0.0)
   {
      if(signal.direction == PATTERN_BULLISH && currentPrice >= signal.triggerPrice)
         triggered = true;
      else if(signal.direction == PATTERN_BEARISH && currentPrice <= signal.triggerPrice)
         triggered = true;
   }
   else
   {
      // إذا لم يكن هناك سعر تفعيل، فالإشارة نشطة فوراً
      triggered = true;
   }
   
   if(triggered)
   {
      signal.wasTriggered = true;
      Print("تم تفعيل الإشارة: ", signal.signalId, " - ", signal.description);
   }
   
   return triggered;
}

//+------------------------------------------------------------------+
//| تحديث حالة الإشارة                                              |
//+------------------------------------------------------------------+
void CChartSignal::UpdateSignalStatus(SChartSignal &signal, const double currentPrice)
{
   // فحص إذا وصل السعر لوقف الخسارة
   if(signal.stopLoss > 0.0)
   {
      bool hitStopLoss = false;
      
      if(signal.direction == PATTERN_BULLISH && currentPrice <= signal.stopLoss)
         hitStopLoss = true;
      else if(signal.direction == PATTERN_BEARISH && currentPrice >= signal.stopLoss)
         hitStopLoss = true;
      
      if(hitStopLoss)
      {
         signal.isActive = false;
         signal.notes += "تم ضرب وقف الخسارة؛ ";
         RecordSignalOutcome(signal, false, signal.stopLoss - signal.entryPrice);
      }
   }
   
   // فحص إذا وصل السعر للهدف
   if(signal.takeProfit1 > 0.0 && signal.isActive)
   {
      bool hitTarget = false;
      
      if(signal.direction == PATTERN_BULLISH && currentPrice >= signal.takeProfit1)
         hitTarget = true;
      else if(signal.direction == PATTERN_BEARISH && currentPrice <= signal.takeProfit1)
         hitTarget = true;
      
      if(hitTarget)
      {
         signal.isActive = false;
         signal.notes += "تم الوصول للهدف الأول؛ ";
         RecordSignalOutcome(signal, true, signal.takeProfit1 - signal.entryPrice);
      }
   }
}

//+------------------------------------------------------------------+
//| التحقق من صحة الإشارة                                           |
//+------------------------------------------------------------------+
bool CChartSignal::ValidateSignal(const SChartSignal &signal)
{
   // فحص الاحتمالية
   if(signal.probability < m_minProbability)
      return false;
   
   // فحص الثقة
   if(signal.confidence < m_minConfidence)
      return false;
   
   // فحص نسبة المخاطر للعائد
   if(signal.riskRewardRatio > m_maxRiskReward)
      return false;
   
   // فحص صحة الأسعار
   if(signal.entryPrice <= 0.0)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| حساب انتهاء صلاحية الإشارة                                      |
//+------------------------------------------------------------------+
void CChartSignal::CalculateSignalExpiration(SChartSignal &signal)
{
   // مدة الصلاحية تعتمد على الإطار الزمني
   int expirationBars = 0;
   
   switch(m_timeframe)
   {
      case PERIOD_M1:
      case PERIOD_M5:
         expirationBars = 60; // ساعة
         break;
      case PERIOD_M15:
      case PERIOD_M30:
         expirationBars = 48; // يوم
         break;
      case PERIOD_H1:
         expirationBars = 24; // يوم
         break;
      case PERIOD_H4:
         expirationBars = 18; // 3 أيام
         break;
      case PERIOD_D1:
         expirationBars = 7;  // أسبوع
         break;
      default:
         expirationBars = 10;
         break;
   }
   
   signal.expirationTime = signal.signalTime + (expirationBars * PeriodSeconds(m_timeframe));
}

//+------------------------------------------------------------------+
//| توليد معرف إشارة                                                |
//+------------------------------------------------------------------+
string CChartSignal::GenerateSignalId()
{
   static int counter = 0;
   counter++;
   
   return StringFormat("%s_%s_%d_%d", 
                      m_symbol, 
                      EnumToString(m_timeframe), 
                      (int)TimeCurrent(), 
                      counter);
}

//+------------------------------------------------------------------+
//| تسجيل نتيجة الإشارة                                             |
//+------------------------------------------------------------------+
void CChartSignal::RecordSignalOutcome(const SChartSignal &signal, const bool success, 
                                       const double profitLoss)
{
   if(success)
      m_successfulSignals++;
   
   // تحديث متوسط الربح/الخسارة
   m_avgProfitLoss = ((m_avgProfitLoss * (m_totalSignals - 1)) + profitLoss) / m_totalSignals;
   
   // تحديث معدل الفوز
   m_winRate = (double)m_successfulSignals / m_totalSignals;
}

//+------------------------------------------------------------------+
//| فحص التأكيد التقني                                              |
//+------------------------------------------------------------------+
bool CChartSignal::HasTechnicalConfirmation(const SChartPatternResult &patternResult)
{
   // فحص تأكيد الحجم
   bool volumeConfirm = patternResult.hasVolConfirmation;
   
   // فحص قوة النمط
   bool strongPattern = (patternResult.confidence >= 0.7);
   
   // فحص اكتمال النمط
   bool completePattern = (patternResult.completionPercentage >= 80.0);
   
   return (volumeConfirm && strongPattern && completePattern);
}

//+------------------------------------------------------------------+
//| الحصول على إشارة نشطة                                          |
//+------------------------------------------------------------------+
SChartSignal CChartSignal::GetActiveSignal(const int index) const
{
   SChartSignal emptySignal;
   
   if(index < 0 || index >= ArraySize(m_activeSignals))
      return emptySignal;
   
   return m_activeSignals[index];
}

//+------------------------------------------------------------------+
//| الحصول على إشارة تاريخية                                       |
//+------------------------------------------------------------------+
SChartSignal CChartSignal::GetHistoricalSignal(const int index) const
{
   SChartSignal emptySignal;
   
   if(index < 0 || index >= ArraySize(m_historicalSignals))
      return emptySignal;
   
   return m_historicalSignals[index];
}

//+------------------------------------------------------------------+
//| البحث عن إشارة بالمعرف                                          |
//+------------------------------------------------------------------+
SChartSignal CChartSignal::FindSignalById(const string signalId)
{
   SChartSignal emptySignal;
   
   // البحث في الإشارات النشطة
   for(int i = 0; i < ArraySize(m_activeSignals); i++)
   {
      if(m_activeSignals[i].signalId == signalId)
         return m_activeSignals[i];
   }
   
   // البحث في الإشارات التاريخية
   for(int i = 0; i < ArraySize(m_historicalSignals); i++)
   {
      if(m_historicalSignals[i].signalId == signalId)
         return m_historicalSignals[i];
   }
   
   return emptySignal;
}

//+------------------------------------------------------------------+
//| توليد تقرير الأداء                                              |
//+------------------------------------------------------------------+
string CChartSignal::GeneratePerformanceReport()
{
   string report = "=== تقرير أداء إشارات المخططات ===\n";
   report += StringFormat("الرمز: %s | الإطار الزمني: %s\n", m_symbol, EnumToString(m_timeframe));
   report += StringFormat("إجمالي الإشارات: %d\n", m_totalSignals);
   report += StringFormat("الإشارات الناجحة: %d\n", m_successfulSignals);
   report += StringFormat("معدل الفوز: %.2f%%\n", m_winRate * 100);
   report += StringFormat("متوسط الربح/الخسارة: %.5f\n", m_avgProfitLoss);
   report += StringFormat("الإشارات النشطة: %d\n", ArraySize(m_activeSignals));
   report += StringFormat("الإشارات المفعلة: %d\n", m_triggeredSignals);
   
   return report;
}

//+------------------------------------------------------------------+
//| توليد ملخص الإشارة                                              |
//+------------------------------------------------------------------+
string CChartSignal::GenerateSignalSummary(const SChartSignal &signal)
{
   string summary = StringFormat("=== ملخص الإشارة %s ===\n", signal.signalId);
   summary += StringFormat("النوع: %s | الاتجاه: %s\n", 
                          EnumToString(signal.signalType), 
                          EnumToString(signal.direction));
   summary += StringFormat("النمط: %s\n", signal.patternName);
   summary += StringFormat("القوة: %s | العجالة: %s\n", 
                          EnumToString(signal.strength), 
                          EnumToString(signal.urgency));
   summary += StringFormat("الاحتمالية: %.2f%% | الثقة: %.2f%%\n", 
                          signal.probability * 100, 
                          signal.confidence * 100);
   summary += StringFormat("سعر الدخول: %.5f\n", signal.entryPrice);
   summary += StringFormat("وقف الخسارة: %.5f\n", signal.stopLoss);
   summary += StringFormat("الهدف الأول: %.5f\n", signal.takeProfit1);
   summary += StringFormat("نسبة المخاطر/العائد: %.2f\n", signal.riskRewardRatio);
   summary += StringFormat("الوصف: %s\n", signal.description);
   summary += StringFormat("الإجراء المطلوب: %s\n", signal.actionRequired);
   
   return summary;
}
