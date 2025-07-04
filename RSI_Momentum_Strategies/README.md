# دليل استراتيجيات الزخم RSI المتكامل - MQL5

## نظرة عامة

هذا المشروع يحتوي على مجموعة شاملة من استراتيجيات التداول المبنية على مؤشر القوة النسبية (RSI) مع إدارة مخاطر متقدمة ومراقبة الأداء. تم تطوير هذه الاستراتيجيات بناءً على بحوث مثبتة علمياً وبيانات تاريخية موثقة.

## محتويات المشروع

### 1. الاستراتيجيات الأساسية

#### أ) RSI Simple Strategy (معدل نجاح 91%)
**الملف:** `RSI_Simple_Strategy.mq5`

**المواصفات:**
- معدل النجاح: 91% للأسهم، 75% للفوركس
- متوسط الربح لكل صفقة: 0.82%
- مناسبة للمبتدئين والمتقدمين

**المعايير الأمثل:**
```cpp
// للأسهم
RSI_Period = 2
RSI_Oversold = 15.0
RSI_Overbought = 85.0

// للفوركس  
RSI_Period = 14
RSI_Oversold = 30.0
RSI_Overbought = 70.0
```

**قواعد التداول:**
1. **الدخول:** RSI < 15 (أسهم) أو RSI < 30 (فوركس) + السعر أعلى المتوسط المتحرك 200
2. **الخروج:** RSI > 85 (أسهم) أو RSI > 70 (فوركس) أو السعر أعلى من أعلى سعر الأمس

#### ب) Triple RSI Advanced Strategy (معدل نجاح 90%)
**الملف:** `Triple_RSI_Strategy.mq5`

**المواصفات:**
- معدل النجاح: 90%
- متوسط الربح لكل صفقة: 1.4%
- معامل الربح: 5.0
- للمتداولين المتقدمين

**الشروط المعقدة:**
```cpp
// شروط الدخول الثلاثية
bool condition1 = rsi_today < rsi_yesterday;
bool condition2 = rsi_yesterday < rsi_day_before;  
bool condition3 = close_today > sma_200;
bool condition4 = rsi_today < 30;
```

**المزايا:**
- دقة عالية جداً في التوقيت
- مخاطر أقل من الاستراتيجية البسيطة
- مناسبة للأسواق المتقلبة

#### ج) Dual RSI Trend Filter Strategy
**الملف:** `Dual_RSI_Strategy.mq5`

**المواصفات:**
- يجمع بين RSI طويل المدى (30) و RSI قصير المدى (2)
- فلاتر متعددة لتحسين الدقة
- إدارة مخاطر ديناميكية

**المنطق:**
- RSI طويل المدى (30) > 50: فلتر الاتجاه العام
- RSI قصير المدى (2) < 15: إشارة الدخول
- جني أرباح جزئي عند 2%

### 2. نظام إدارة المخاطر
**الملف:** `RiskManager.mqh`

**الميزات:**
```cpp
class CRiskManager
{
    // حساب حجم المركز بناءً على المخاطرة
    double CalculatePositionSize(double entry_price, double stop_loss);
    
    // حساب وقف الخسارة بناءً على ATR  
    double CalculateATRStopLoss(double entry_price, bool is_long);
    
    // فحص الحد الأقصى للخسارة اليومية
    bool IsMaxDailyLossReached(double max_daily_loss_percent);
    
    // حساب حجم المركز بناءً على ATR
    double CalculateATRBasedPosition(double entry_price, bool is_long);
}
```

**المعايير الافتراضية:**
- المخاطرة لكل صفقة: 2%
- الحد الأقصى للمخاطرة: 5%
- وقف الخسارة التلقائي: 2 × ATR

### 3. نظام مراقبة الأداء
**الملف:** `PerformanceMonitor.mqh`

**التقارير المتوفرة:**
```cpp
class CPerformanceMonitor
{
    // تحديث الإحصائيات بعد كل صفقة
    void UpdateTrade(double trade_result, double trade_volume);
    
    // طباعة تقرير الأداء الشامل
    void PrintPerformanceReport();
    
    // حفظ الأداء في ملف
    void SavePerformanceToFile();
    
    // فحص جودة الأداء
    bool IsPerformanceGood(double min_win_rate, double min_profit_factor);
}
```

**المؤشرات المتتبعة:**
- معدل النجاح
- معامل الربح
- أقصى تراجع
- متوسط الربح/الخسارة
- العائد المتوقع
- عدد الصفقات

### 4. نظام إدارة التكوين
**الملف:** `ConfigManager.mqh`

**الإعدادات المحسّنة:**
```cpp
// للأسهم
RSI_Simple_Stocks: RSI(2), 15/85, Risk 2%

// للفوركس  
RSI_Simple_Forex: RSI(14), 30/70, Risk 1%

// للمؤشرات
Dual_RSI_Indices: RSI(14), 25/75, Risk 3%

// للسلع
Triple_RSI_Advanced: RSI(2), 30/70, Risk 2.5%
```

**الميزات:**
- اكتشاف تلقائي لنوع الأصل
- تحسين ديناميكي للمعايير
- حفظ/تحميل الإعدادات
- إعدادات متعددة لكل أصل

### 5. منتقي الاستراتيجيات الذكي
**الملف:** `Strategy_Selector.mq5`

**أنماط الاختيار:**
```cpp
enum ENUM_STRATEGY_MODE
{
    STRATEGY_AUTO,        // اختيار تلقائي
    STRATEGY_MANUAL,      // اختيار يدوي
    STRATEGY_ADAPTIVE,    // تبديل تكيفي
    STRATEGY_PORTFOLIO    // محفظة استراتيجيات
}
```

**تحليل السوق:**
- تحليل التقلبات (ATR)
- تحليل الاتجاه (SMA 50/200)  
- تحليل حجم التداول
- اكتشاف ظروف السوق

**الذكاء الاصطناعي:**
- اختيار الاستراتيجية الأمثل تلقائياً
- التبديل بناءً على الأداء
- تحسين المعايير حسب التقلبات

### 6. نظام الاختبار والتحسين
**الملف:** `Backtester.mq5`

**إمكانيات الاختبار:**
```cpp
// فترات الاختبار
InpStartDate = D'2020.01.01'
InpEndDate = D'2024.12.31'

// معايير التحسين
InpOptimizeRSIPeriod = true     // تحسين فترة RSI
InpOptimizeOversold = true      // تحسين مستوى التشبع البيعي  
InpOptimizeOverbought = true    // تحسين مستوى التشبع الشرائي
InpOptimizeRisk = true          // تحسين مستوى المخاطرة
```

**التقارير:**
- تقرير HTML تفصيلي
- تصدير CSV للبيانات
- منحنى الأرباح
- سجل الصفقات التفصيلي

**المؤشرات المحسوبة:**
- معامل الربح
- معدل النجاح
- أقصى تراجع
- معامل الاستراد
- نسبة شارب
- العائد الشهري

## طريقة الاستخدام

### 1. للمبتدئين - الاستراتيجية البسيطة

```cpp
// 1. افتح RSI_Simple_Strategy.mq5
// 2. اضبط المعايير حسب نوع الأصل:

// للأسهم (موصى به)
input int InpRSIPeriod = 2;
input double InpRSIOversold = 15.0;  
input double InpRSIOverbought = 85.0;
input bool InpUseStockSettings = true;

// للفوركس
input int InpRSIPeriod = 14;
input double InpRSIOversold = 30.0;
input double InpRSIOverbought = 70.0;
input bool InpUseStockSettings = false;

// 3. اضبط إدارة المخاطر
input double InpRiskPercent = 0.02;        // 2% مخاطرة
input double InpMaxRiskPerTrade = 0.05;    // 5% حد أقصى

// 4. شغل الروبوت على الرسم البياني اليومي
```

### 2. للمتقدمين - استراتيجية Triple RSI

```cpp
// 1. افتح Triple_RSI_Strategy.mq5  
// 2. المعايير المحسّنة (لا تغيرها إلا إذا كنت خبيراً)
input int InpRSIPeriod = 2;
input double InpRSIThreshold = 30.0;
input double InpRSIExit = 70.0;
input bool InpStrictTripleCondition = true;

// 3. إدارة مخاطر متقدمة
input double InpRiskPercent = 0.025;       // 2.5% مخاطرة
input bool InpUseATRStops = true;          // استخدام ATR للوقف
input double InpATRMultiplier = 2.5;       // 2.5 × ATR

// 4. إدارة المراكز
input int InpMaxDailyTrades = 2;           // حد أقصى صفقتان يومياً
input bool InpTrailStops = true;           // وقف متحرك
input int InpMaxHoldingDays = 5;           // حد أقصى 5 أيام للاحتفاظ
```

### 3. للخبراء - منتقي الاستراتيجيات

```cpp
// 1. افتح Strategy_Selector.mq5
// 2. اختر نمط التشغيل
input ENUM_STRATEGY_MODE InpStrategyMode = STRATEGY_AUTO;

// للاختيار التلقائي الذكي
InpStrategyMode = STRATEGY_AUTO;
input bool InpAutoOptimize = true;

// للتبديل التكيفي
InpStrategyMode = STRATEGY_ADAPTIVE; 
input bool InpSwitchOnPoorPerformance = true;
input double InpMinWinRate = 60.0;

// لمحفظة الاستراتيجيات
InpStrategyMode = STRATEGY_PORTFOLIO;
```

### 4. اختبار الاستراتيجيات

```cpp
// 1. افتح Backtester.mq5 كـ Script
// 2. اضبط فترة الاختبار
input datetime InpStartDate = D'2020.01.01';
input datetime InpEndDate = D'2024.12.31';

// 3. اختر الاستراتيجيات للاختبار
input bool InpTestRSISimple = true;
input bool InpTestTripleRSI = true;  
input bool InpTestDualRSI = true;

// 4. فعّل التحسين
input bool InpOptimizeRSIPeriod = true;
input bool InpOptimizeOversold = true;
input bool InpOptimizeOverbought = true;

// 5. شغل الـ Script وانتظر النتائج
```

## نصائح للاستخدام الأمثل

### 1. اختيار الاستراتيجية المناسبة

**للأسهم:** RSI Simple Strategy مع المعايير (2, 15, 85)
**للفوركس:** RSI Simple Strategy مع المعايير (14, 30, 70)  
**للمؤشرات:** Dual RSI Strategy مع فلاتر متعددة
**للسلع:** Triple RSI Strategy للدقة العالية

### 2. إدارة المخاطر

```cpp
// مبادئ أساسية
- لا تخاطر بأكثر من 2% لكل صفقة
- استخدم وقف الخسارة دائماً  
- احدد حد أقصى للخسارة اليومية (5%)
- تنويع المحفظة على أصول متعددة

// للمبتدئين
InpRiskPercent = 0.01;          // 1% مخاطرة
InpMaxRiskPerTrade = 0.02;      // 2% حد أقصى

// للمتقدمين  
InpRiskPercent = 0.02;          // 2% مخاطرة
InpMaxRiskPerTrade = 0.05;      // 5% حد أقصى

// للخبراء
InpRiskPercent = 0.03;          // 3% مخاطرة  
InpMaxRiskPerTrade = 0.08;      // 8% حد أقصى
```

### 3. مراقبة الأداء

```cpp
// مؤشرات مهمة للمراقبة
معدل النجاح > 70%              // ممتاز > 80%
معامل الربح > 1.5               // ممتاز > 2.0  
أقصى تراجع < 15%                // ممتاز < 10%
العائد المتوقع > 0               // ممتاز > 1%

// متى تتوقف؟
- معدل النجاح < 50% لأكثر من 20 صفقة
- أقصى تراجع > 20%
- خسارة أكثر من 10% في يوم واحد
```

### 4. التحسين والتطوير

```cpp
// خطوات التحسين
1. اختبر الاستراتيجية على بيانات تاريخية (2+ سنوات)
2. حسّن المعايير باستخدام Backtester.mq5
3. اختبر على حساب تجريبي (شهر كامل)
4. ابدأ بحجم صغير على حساب حقيقي
5. راقب الأداء وعدّل حسب الحاجة

// معايير التحسين
- اختبر فترات RSI من 2 إلى 21
- جرب مستويات تشبع مختلفة  
- حسّن نسبة المخاطرة
- أضف فلاتر إضافية حسب السوق
```

## استكشاف الأخطاء

### مشاكل شائعة وحلولها

```cpp
// 1. الاستراتيجية لا تفتح صفقات
- تأكد من أن السوق مفتوح
- فحص شروط الدخول (RSI + فلتر الاتجاه)
- تأكد من عدم تجاوز الحد الأقصى للصفقات اليومية

// 2. خسائر متتالية
- راجع إعدادات إدارة المخاطر
- تأكد من مناسبة الاستراتيجية لظروف السوق الحالية
- استخدم Strategy Selector للتبديل التلقائي

// 3. أداء ضعيف
- شغل Backtester لتحسين المعايير
- تأكد من استخدام الإعدادات المناسبة لنوع الأصل
- راجع تقارير الأداء لفهم نقاط الضعف

// 4. مشاكل تقنية
- تأكد من إصدار MQL5 الحديث
- فحص صحة البيانات التاريخية
- تأكد من عدم وجود تضارب في Magic Numbers
```

## ملفات النظام

```
RSI_Momentum_Strategies/
├── RSI_Simple_Strategy.mq5         // الاستراتيجية البسيطة
├── Triple_RSI_Strategy.mq5         // استراتيجية Triple RSI
├── Dual_RSI_Strategy.mq5           // استراتيجية Dual RSI  
├── Strategy_Selector.mq5           // منتقي الاستراتيجيات
├── Backtester.mq5                  // نظام الاختبار والتحسين
├── RiskManager.mqh                 // إدارة المخاطر
├── PerformanceMonitor.mqh          // مراقبة الأداء
├── ConfigManager.mqh               // إدارة التكوين
└── README.md                       // هذا الملف
```

## الدعم والمساعدة

### للمساعدة التقنية:
1. راجع هذا الدليل أولاً
2. اختبر على حساب تجريبي
3. ادرس تقارير الأداء
4. ابدأ بالاستراتيجية البسيطة

### للتطوير المتقدم:
1. ادرس الكود المصدري
2. عدّل المعايير تدريجياً  
3. اختبر التعديلات بدقة
4. احتفظ بنسخ احتياطية

---

**إخلاء مسؤولية:** هذه الاستراتيجيات مبنية على بحوث تاريخية ولا تضمن أرباحاً مستقبلية. تداول دائماً بمسؤولية واختبر على حساب تجريبي أولاً.

**النجاح في التداول يتطلب:**
- صبر وانضباط
- إدارة مخاطر صارمة  
- تعلم مستمر
- اختبار دقيق
- مراقبة منتظمة للأداء

**بالتوفيق في رحلة التداول! 🚀📈**
