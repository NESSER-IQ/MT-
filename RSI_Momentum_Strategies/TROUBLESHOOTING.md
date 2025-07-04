# دليل استكشاف الأخطاء والحلول - استراتيجيات RSI

## نظرة عامة
هذا الدليل يساعدك في حل المشاكل الشائعة التي قد تواجهها عند استخدام استراتيجيات RSI.

---

## فهرس المحتويات
1. [مشاكل التثبيت والإعداد](#تثبيت-وإعداد)
2. [مشاكل تشغيل الاستراتيجيات](#تشغيل-الاستراتيجيات)
3. [مشاكل الأداء والنتائج](#الأداء-والنتائج)
4. [مشاكل التنبيهات والإشعارات](#التنبيهات-والإشعارات)
5. [مشاكل البيانات والمؤشرات](#البيانات-والمؤشرات)
6. [مشاكل إدارة المخاطر](#إدارة-المخاطر)
7. [رسائل الخطأ الشائعة](#رسائل-الخطأ)

---

## تثبيت وإعداد

### المشكلة: فشل في تحميل الملفات
**الأعراض:**
- رسالة "Cannot load library/include file"
- الاستراتيجية لا تعمل عند التشغيل

**الحلول:**
```
✅ تأكد من وضع جميع ملفات .mqh في مجلد Include
✅ تأكد من وضع جميع ملفات .mq5 في المجلد الصحيح
✅ أعد تشغيل MetaTrader 5
✅ تأكد من عدم وجود أخطاء إملائية في أسماء الملفات
```

**خطوات التحقق:**
1. افتح مجلد البيانات في MetaTrader: File → Open Data Folder
2. تنقل إلى MQL5 → Include
3. تأكد من وجود جميع ملفات .mqh
4. تنقل إلى MQL5 → Experts
5. تأكد من وجود جميع ملفات .mq5

### المشكلة: رسالة "Trading is disabled"
**الأعراض:**
- الاستراتيجية محملة لكن لا تفتح صفقات
- رسالة "Trading is disabled" في سجل الأحداث

**الحلول:**
```
✅ تفعيل AutoTrading في شريط الأدوات
✅ تأكد من السماح بالـ EAs في إعدادات الحساب
✅ تحقق من أن السوق مفتوح
✅ تأكد من توفر رصيد كافي
```

**خطوات الحل:**
1. انقر على أيقونة AutoTrading في الشريط العلوي
2. Tools → Options → Expert Advisors
3. تفعيل "Allow automated trading"
4. تفعيل "Allow DLL imports" إذا لزم الأمر

### المشكلة: الاستراتيجية لا تظهر في قائمة Expert Advisors
**الحلول:**
```
✅ تأكد من الترجمة الصحيحة (Compile)
✅ تحقق من عدم وجود أخطاء في الكود
✅ أعد تشغيل MetaTrader
✅ تحديث Navigator (F5)
```

---

## تشغيل الاستراتيجيات

### المشكلة: الاستراتيجية لا تفتح صفقات
**الأعراض:**
- الاستراتيجية تعمل لكن لا توجد صفقات
- لا توجد إشارات في السجل

**التشخيص:**
```cpp
// أضف هذا الكود للتشخيص
Print("RSI Value: ", current_rsi);
Print("SMA Value: ", sma_value);
Print("Entry Condition Met: ", (rsi_condition && trend_condition));
```

**الحلول الشائعة:**
```
✅ تحقق من قيم RSI (يجب أن تكون بين 0-100)
✅ تأكد من أن ظروف السوق تناسب شروط الدخول
✅ راجع إعدادات المخاطرة (قد تكون صغيرة جداً)
✅ تحقق من فترة RSI المستخدمة
```

**إعدادات مقترحة للاختبار:**
```cpp
// للأسهم
InpRSIPeriod = 2
InpRSIOversold = 20.0  // أقل صرامة للاختبار
InpRSIOverbought = 80.0

// للفوركس
InpRSIPeriod = 14
InpRSIOversold = 35.0  // أقل صرامة
InpRSIOverbought = 65.0
```

### المشكلة: كثرة الصفقات الخاسرة
**التشخيص:**
- فحص سجل الصفقات
- مراجعة نسبة النجاح
- تحليل ظروف السوق

**الحلول:**
```
✅ استخدم فلاتر إضافية (Volume, Volatility)
✅ اضبط مستويات RSI لتكون أكثر صرامة
✅ فعّل فلتر الاتجاه (SMA 200)
✅ قلل حجم المراكز
✅ استخدم Strategy Selector للتبديل التلقائي
```

**إعدادات محافظة:**
```cpp
InpRiskPercent = 0.01          // 1% بدلاً من 2%
InpUseVolumeFilter = true      // تفعيل فلتر الحجم
InpUseTrendFilter = true       // تفعيل فلتر الاتجاه
InpMaxDailyTrades = 2          // تقليل الصفقات اليومية
```

### المشكلة: الاستراتيجية تتوقف فجأة
**الأعراض:**
- الاستراتيجية تعمل ثم تتوقف
- رسائل خطأ في السجل
- وجه حزين في الرسم البياني

**الحلول:**
```
✅ تحقق من استقرار الاتصال بالإنترنت
✅ راجع سجل الأحداث للأخطاء
✅ تأكد من عدم تجاوز الحد الأقصى للخسارة اليومية
✅ أعد تشغيل الاستراتيجية
```

---

## الأداء والنتائج

### المشكلة: الأداء أقل من المتوقع
**مؤشرات الأداء الضعيف:**
- معدل نجاح أقل من 50%
- تراجع أكثر من 20%
- خسائر متتالية أكثر من 5 صفقات

**خطوات التحسين:**

#### 1. تحليل الأداء الحالي
```cpp
// استخدم Performance Monitor لعرض الإحصائيات
g_performance_monitor.PrintPerformanceReport();
```

#### 2. اختبار إعدادات مختلفة
```cpp
// جرب إعدادات أكثر محافظة
InpRSIPeriod = 14               // بدلاً من 2
InpRSIOversold = 25.0           // أكثر صرامة
InpUseATRStops = true           // وقف خسارة ديناميكي
```

#### 3. استخدام التحسين التلقائي
```cpp
// شغل Backtester.mq5 لإيجاد أفضل المعايير
InpOptimizeRSIPeriod = true
InpOptimizeOversold = true
InpOptimizeRisk = true
```

### المشكلة: تراجع كبير في الرصيد
**الإجراءات الفورية:**
```
⚠️ أوقف التداول فوراً
⚠️ راجع آخر 10 صفقات
⚠️ حلل سبب الخسائر
⚠️ لا تضاعف حجم المراكز
```

**خطوات التعافي:**
```
✅ قلل المخاطرة إلى 0.5% لكل صفقة
✅ استخدم الاستراتيجية البسيطة فقط
✅ فعّل جميع الفلاتر
✅ اختبر على حساب تجريبي أولاً
```

---

## التنبيهات والإشعارات

### المشكلة: لا تصل الإشعارات
**للإشعارات الصوتية:**
```
✅ تحقق من إعدادات الصوت في Windows
✅ تأكد من وجود ملفات الصوت في مجلد Sounds
✅ جرب تشغيل ملف صوتي يدوياً
```

**للإشعارات المحمولة:**
```
✅ تأكد من تفعيل الإشعارات في MetaTrader Mobile
✅ تحقق من الاتصال بالإنترنت
✅ راجع إعدادات الحساب في MetaQuotes ID
```

**للإيميل:**
```
✅ اضبط إعدادات SMTP في MetaTrader
✅ تأكد من صحة عنوان البريد الإلكتروني
✅ تحقق من مجلد الرسائل المهملة
```

### المشكلة: كثرة الإشعارات
**الحلول:**
```cpp
// قلل عدد الإشعارات
InpMaxAlertsPerHour = 5         // بدلاً من 20
InpShowSignalArrows = false     // أوقف إشعارات الإشارات
InpShowAlerts = false           // أوقف التنبيهات الصوتية
```

---

## البيانات والمؤشرات

### المشكلة: قيم RSI غير منطقية
**الأعراض:**
- RSI يظهر قيم سالبة أو أكبر من 100
- RSI لا يتغير مع تغير الأسعار

**الحلول:**
```
✅ تحقق من صحة بيانات الأسعار
✅ أعد تشغيل المؤشر
✅ امسح الذاكرة المؤقتة للمؤشرات
✅ تأكد من اتصال الإنترنت
```

**كود التشخيص:**
```cpp
// أضف هذا للتحقق من البيانات
double rsi_values[];
int copied = CopyBuffer(rsi_handle, 0, 0, 5, rsi_values);
Print("RSI Values copied: ", copied);
for(int i = 0; i < copied; i++)
    Print("RSI[", i, "] = ", rsi_values[i]);
```

### المشكلة: تأخير في تحديث البيانات
**الحلول:**
```
✅ تحقق من سرعة الإنترنت
✅ أعد الاتصال بالخادم
✅ تغيير الخادم إذا أمكن
✅ تحديث MetaTrader 5
```

---

## إدارة المخاطر

### المشكلة: حجم المراكز كبير جداً أو صغير جداً
**للمراكز الكبيرة:**
```cpp
// تحقق من هذه الإعدادات
InpRiskPercent = 0.01           // قلل المخاطرة
InpMaxRiskPerTrade = 0.02       // اضبط الحد الأقصى
```

**للمراكز الصغيرة:**
```cpp
// تأكد من أن الرصيد كافي
double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
Print("Minimum volume: ", min_volume);
Print("Calculated volume: ", calculated_volume);
```

### المشكلة: وقف الخسارة لا يعمل
**التشخيص:**
```cpp
// تحقق من قيم وقف الخسارة
Print("Entry Price: ", entry_price);
Print("Stop Loss: ", stop_loss);
Print("Distance: ", MathAbs(entry_price - stop_loss));
```

**الحلول:**
```
✅ تأكد من أن وقف الخسارة ضمن المستويات المسموحة
✅ تحقق من Freeze Level و Stop Level
✅ استخدم ATR-based stops
✅ تأكد من عدم وجود أخطاء في حساب الوقف
```

---

## رسائل الخطأ الشائعة

### "Invalid stops" أو "Invalid S/L or T/P"
**السبب:** وقف الخسارة/جني الأرباح قريب جداً من السعر الحالي

**الحل:**
```cpp
// تحقق من المستويات المطلوبة
int stop_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
double min_distance = stop_level * point;

// تأكد من أن وقف الخسارة أبعد من الحد الأدنى
if(MathAbs(entry_price - stop_loss) < min_distance)
{
    stop_loss = is_buy ? (entry_price - min_distance * 1.5) : 
                        (entry_price + min_distance * 1.5);
}
```

### "Not enough money"
**الحل:**
```cpp
// قلل حجم المركز
volume = volume * 0.5;
// أو قلل المخاطرة
InpRiskPercent = 0.005;  // 0.5%
```

### "Trade context is busy"
**الحل:**
```cpp
// أضف انتظار قبل الطلب التالي
Sleep(100);
// أو استخدم IsTradeContextBusy()
while(IsTradeContextBusy()) Sleep(10);
```

### "Market is closed"
**الحل:**
```cpp
// تحقق من أوقات التداول
bool market_open = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;
if(!market_open)
{
    Print("Market is closed, waiting...");
    return;
}
```

---

## أدوات التشخيص المتقدم

### أداة فحص الاستراتيجية
```cpp
// أضف هذا الكود في OnTick() للتشخيص
void DiagnoseStrategy()
{
    static datetime last_diagnosis = 0;
    if(TimeCurrent() - last_diagnosis < 60) return; // كل دقيقة
    
    Print("=== STRATEGY DIAGNOSIS ===");
    Print("Balance: ", AccountInfoDouble(ACCOUNT_BALANCE));
    Print("Equity: ", AccountInfoDouble(ACCOUNT_EQUITY));
    Print("Free Margin: ", AccountInfoDouble(ACCOUNT_FREEMARGIN));
    Print("RSI Value: ", current_rsi);
    Print("Trend Filter: ", current_close > sma_value);
    Print("Volume Filter: ", volume_condition);
    Print("Risk Manager OK: ", risk_manager != NULL);
    Print("Position Count: ", PositionsTotal());
    Print("========================");
    
    last_diagnosis = TimeCurrent();
}
```

### أداة مراقبة الأداء المباشر
```cpp
// استخدم Dashboard.mq5 لمراقبة الأداء المباشر
// أو أضف هذا الكود
void MonitorPerformance()
{
    static double last_balance = 0;
    double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    
    if(current_balance != last_balance)
    {
        double change = current_balance - last_balance;
        string status = (change > 0) ? "PROFIT" : "LOSS";
        Print("Balance Change: ", status, " $", DoubleToString(change, 2));
        last_balance = current_balance;
    }
}
```

---

## متى تطلب المساعدة

### اطلب المساعدة إذا:
```
❌ جربت جميع الحلول المذكورة أعلاه
❌ المشكلة تتكرر باستمرار  
❌ تواجه خسائر كبيرة غير مبررة
❌ رسائل خطأ غير مفهومة
❌ مشاكل تقنية معقدة
```

### معلومات مطلوبة عند طلب المساعدة:
```
✅ وصف دقيق للمشكلة
✅ رسائل الخطأ كاملة
✅ الإعدادات المستخدمة
✅ نوع الحساب (تجريبي/حقيقي)
✅ الرمز المتداول
✅ إصدار MetaTrader
✅ لقطة شاشة إذا أمكن
```

---

## نصائح الصيانة الوقائية

### يومياً:
```
✅ تحقق من سجل الأحداث
✅ راجع الأداء اليومي
✅ تأكد من استقرار الاتصال
```

### أسبوعياً:
```
✅ راجع إحصائيات الأداء الأسبوعية
✅ احفظ نسخة احتياطية من الإعدادات
✅ تحديث المعايير إذا لزم الأمر
```

### شهرياً:
```
✅ تشغيل Backtester لتحسين المعايير
✅ مراجعة شاملة للأداء
✅ تحديث الاستراتيجيات إذا متوفر
```

---

## أرقام المساعدة السريعة

### للمشاكل الطارئة:
- **أوقف التداول فوراً** إذا كانت الخسائر تتجاوز 5% يومياً
- **أغلق جميع المراكز** إذا واجهت مشكلة تقنية كبيرة
- **انتقل للحساب التجريبي** عند اختبار إعدادات جديدة

### للتشخيص السريع:
```cpp
// اختبار سريع - أضف في OnInit()
Print("=== QUICK DIAGNOSIS ===");
Print("AutoTrading: ", TerminalInfoInteger(TERMINAL_TRADE_ALLOWED));
Print("Account Trading: ", AccountInfoInteger(ACCOUNT_TRADE_ALLOWED));
Print("EA Trading: ", MQLInfoInteger(MQL_TRADE_ALLOWED));
Print("Connection: ", TerminalInfoInteger(TERMINAL_CONNECTED));
Print("======================");
```

---

**ملاحظة مهمة:** هذا الدليل يغطي المشاكل الأكثر شيوعاً. للمشاكل المعقدة أو غير المذكورة هنا، يُنصح بطلب المساعدة من خبير MQL5 مؤهل.

**تذكر:** التداول ينطوي على مخاطر، واستكشاف الأخطاء وحلها جزء طبيعي من عملية التطوير والتحسين المستمر.
