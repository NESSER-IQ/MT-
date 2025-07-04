# 🤖 روبوت التداول المتكامل - نظام تداول أنماط الشموع المتقدم

<div align="center">

![Version](https://img.shields.io/badge/version-4.0.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-MetaTrader%205-green.svg)
![Language](https://img.shields.io/badge/language-MQL5-orange.svg)
![License](https://img.shields.io/badge/license-Commercial-red.svg)

**نظام تداول آلي متطور يستخدم أنماط الشموع اليابانية مع إدارة مخاطر متقدمة**

[🚀 بدء الاستخدام](#-التركيب-والإعداد) • [📖 الدليل](#-الوثائق) • [🔧 الميزات](#-الميزات-الرئيسية) • [📞 الدعم](#-الدعم-الفني)

</div>

---

## 📋 جدول المحتويات

- [نظرة عامة](#-نظرة-عامة)
- [الميزات الرئيسية](#-الميزات-الرئيسية)
- [متطلبات النظام](#-متطلبات-النظام)
- [التركيب والإعداد](#-التركيب-والإعداد)
- [هيكل المشروع](#-هيكل-المشروع)
- [الاستخدام السريع](#-الاستخدام-السريع)
- [الإعدادات المتقدمة](#-الإعدادات-المتقدمة)
- [مثال الاستخدام](#-مثال-الاستخدام)
- [الأداء والإحصائيات](#-الأداء-والإحصائيات)
- [استكشاف الأخطاء](#-استكشاف-الأخطاء)
- [الوثائق](#-الوثائق)
- [التحديثات](#-تاريخ-التحديثات)
- [المساهمة](#-المساهمة)
- [الدعم الفني](#-الدعم-الفني)
- [الترخيص](#-الترخيص)

---

## 🎯 نظرة عامة

روبوت التداول المتكامل هو نظام تداول آلي متطور تم تطويره خصيصاً لمنصة MetaTrader 5، يجمع بين قوة تحليل أنماط الشموع اليابانية ونظام إدارة مخاطر متعدد المستويات لتحقيق نتائج تداول مثلى.

### 🎨 المفهوم الأساسي

يعتمد النظام على:
- **تحليل أنماط الشموع**: 15+ نمط شموع ياباني معترف به عالمياً
- **إدارة المخاطر الذكية**: 4 مستويات حماية متدرجة
- **التحليل الفني المتقدم**: مؤشرات تقنية مدمجة للتأكيد
- **التداول الآلي**: تنفيذ تلقائي مع مراقبة مستمرة

---

## 🌟 الميزات الرئيسية

### 🔍 نظام كشف الأنماط المتقدم
- ✅ **15+ نمط شموع**: مطرقة، ابتلاع، دوجي، نجوم، وأكثر
- ✅ **تقييم ذكي**: تحليل قوة وموثوقية كل نمط
- ✅ **تصفية متطورة**: إزالة الإشارات الضعيفة تلقائياً
- ✅ **تأكيد متعدد**: دمج مؤشرات تقنية للتأكيد

### 💰 إدارة الأموال المتطورة
- 💎 **5 أنواع إدارة**: ثابت، نسبة مخاطرة، معيار كيلي، وأكثر
- 💎 **حماية رأس المال**: حدود مخاطرة قابلة للتخصيص
- 💎 **تحجيم ديناميكي**: تعديل تلقائي لأحجام الصفقات
- 💎 **مراقبة مستمرة**: تتبع المخاطرة الإجمالية

### 🛡️ نظام الحماية متعدد المستويات
```
المستوى 1: حماية الصفقة الواحدة
  ├── وقف الخسارة التلقائي
  ├── جني الأرباح المحسوب
  └── الوقف المتحرك الذكي

المستوى 2: حماية المحفظة
  ├── حد المخاطرة الإجمالية
  ├── توزيع الصفقات
  └── مراقبة الارتباط

المستوى 3: حماية الحساب
  ├── حد السحب المسموح
  ├── حماية حقوق الملكية
  └── حد الخسارة اليومية

المستوى 4: الحماية الطارئة
  ├── الإيقاف التلقائي
  ├── إغلاق جميع الصفقات
  └── منع التداول الجديد
```

---

## 🚀 التركيب والإعداد

### الخطوة 1: تحضير الملفات
```bash
# نسخ الملفات إلى المجلدات المناسبة
📁 MQL5/
├── 📂 Experts/
│   └── AdvancedTradingRobot.mq5
├── 📂 Include/
│   ├── PatternIntegrationLibrary.mqh
│   └── PresetConfigurations.mqh
├── 📂 Scripts/
│   ├── ForexCandlePatternMonitor.mq5
│   └── PerformanceTester.mq5
└── 📂 Indicators/
    └── PatternSignalDisplay.mq5
```

### الخطوة 2: التصنيف
1. افتح **MetaEditor** (F4)
2. انتقل إلى كل ملف واضغط **F7** للتصنيف
3. تأكد من عدم وجود أخطاء

### الخطوة 3: التطبيق
1. اسحب `AdvancedTradingRobot.mq5` من Navigator إلى الرسم البياني
2. في نافذة الإعدادات:
   - ✅ تأكد من تفعيل **"Allow live trading"**
   - ✅ تأكد من تفعيل **"Allow DLL imports"**
   - ⚙️ اختر الإعدادات المناسبة
3. اضغط **OK**

---

## ⚡ الاستخدام السريع

### للمبتدئين - الإعداد السريع
```mql5
// الإعدادات الأساسية الموصى بها
InpMagicNumber = 20250623;        // الرقم السحري
InpRiskPercent = 1.0;             // 1% مخاطرة (آمن)
InpMaxPositions = 2;              // صفقتان بحد أقصى
InpMinPatternStrength = 3.0;      // أنماط قوية فقط
InpUseDrawdownProtection = true;  // تفعيل الحماية
```

### للمتقدمين - إعداد مخصص
```mql5
// إعدادات متقدمة
InpMMType = MM_RISK_PERCENT;      // إدارة بنسبة المخاطرة
InpRiskPercent = 2.0;             // 2% مخاطرة
InpMaxPositions = 5;              // 5 صفقات متزامنة
InpExitStrategy = EXIT_ATR_BASED; // خروج مبني على ATR
InpUseTrailingStop = true;        // وقف متحرك
```

---

## 🔧 استكشاف الأخطاء

### المشاكل الشائعة

#### 🚫 الروبوت لا يتداول
**الحلول:**
```mql5
// 1. تحقق من الإعدادات الأساسية
InpAllowTrading = true;
InpMaxSpread = 50;  // زيادة مؤقتة

// 2. خفض مرشحات الجودة مؤقتاً
InpMinPatternStrength = 2.0;
InpMinPatternReliability = 0.6;
```

#### ❌ أخطاء التصنيف
**الحلول:**
```mql5
// التأكد من وجود جميع includes
#include <Trade\Trade.mqh>
#include <PatternIntegrationLibrary.mqh>
```

---

## 📞 الدعم الفني

### قنوات الدعم
- **البريد الإلكتروني**: support@alitech-trading.com
- **الموقع الرسمي**: https://www.alitech-trading.com
- **التليجرام**: @AliTechTrading

### ساعات الدعم
```
🕐 الأحد - الخميس: 8:00 ص - 8:00 م (بتوقيت بغداد GMT+3)
🕐 الجمعة: 8:00 ص - 2:00 م  
🕐 السبت: مغلق
```

---

## 📄 الترخيص

```
حقوق النشر © 2025 علي تك للتداول الذكي
جميع الحقوق محفوظة
```

### إخلاء المسؤولية
> ⚠️ **تحذير مهم**: التداول في الفوركس ينطوي على مخاطر عالية وقد يؤدي إلى خسارة كامل رأس المال. استخدم هذا الروبوت على مسؤوليتك الخاصة ولا تستثمر أكثر مما يمكنك تحمل خسارته.

---

<div align="center">

**صنع بـ ❤️ في العراق** | **Version 4.0.0** | **آخر تحديث: 23 يونيو 2025**

</div>