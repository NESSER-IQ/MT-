# مكتبة أنماط الشموع الثلاثية - Triple Candle Patterns Library

## نظرة عامة
مكتبة شاملة ومتقدمة لكشف وتحليل أنماط الشموع اليابانية الثلاثية في MetaTrader 5، مطورة بلغة MQL5 مع دعم كامل للغة العربية.

## الميزات الرئيسية

### 🎯 **شمولية الأنماط**
- **55+ نمط شموع ثلاثي** مقسم إلى 4 فئات رئيسية
- **تغطية كاملة** للأنماط التقليدية والحديثة
- **دعم الأنماط اليابانية** الأصلية والمتكيفة

### 🔧 **سهولة الاستخدام**
- **واجهة برمجية موحدة** لجميع الأنماط
- **تكامل سلس** مع منصة MetaTrader 5
- **إعدادات قابلة للتخصيص** لكل مجموعة أنماط

### 📊 **تحليل متقدم**
- **حساب القوة والموثوقية** لكل نمط
- **تحليل الحجم** والتقلبات
- **مؤشرات الثقة** المتقدمة

### 🌍 **دعم اللغة العربية**
- **تعليقات شاملة** باللغة العربية
- **أسماء متغيرات** واضحة ومفهومة
- **وثائق مفصلة** بالعربية

## هيكل المكتبة

```
├── TripleCandle/
│   ├── TripleCandlePatterns.mqh        // الملف الرئيسي
│   │
│   ├── Essential/                      // الأنماط الأساسية (أولوية قصوى)
│   │   ├── StarPatterns.mqh            // أنماط النجوم (4 أنماط)
│   │   ├── SoldierCrowPatterns.mqh     // أنماط الجنود والغربان (4 أنماط)
│   │   ├── InsideOutsidePatterns.mqh   // أنماط الداخل والخارج (4 أنماط)
│   │   ├── ThreeMethodsPatterns.mqh    // أنماط الطرق الثلاث (4 أنماط)
│   │   └── TripleLinePatterns.mqh      // أنماط الخطوط الثلاثية (4 أنماط)
│   │
│   ├── Advanced/                       // الأنماط المتقدمة
│   │   ├── BreakawayPatterns.mqh       // أنماط الانفصال (2 أنماط)
│   │   ├── ConcealingPatterns.mqh      // أنماط الإخفاء (2 أنماط)
│   │   ├── AdvanceBlockPatterns.mqh    // أنماط كتلة التقدم (3 أنماط)
│   │   ├── CorrectionPatterns.mqh      // أنماط التصحيح (4 أنماط)
│   │   └── IdentityPatterns.mqh        // أنماط الهوية والتطابق (4 أنماط)
│   │
│   ├── Specialized/                    // الأنماط المتخصصة
│   │   ├── GappingPatterns.mqh         // أنماط الفجوات (4 أنماط)
│   │   ├── DeliberationPatterns.mqh    // أنماط التداول (3 أنماط)
│   │   └── UniquePatterns.mqh          // الأنماط الفريدة (4 أنماط)
│   │
│   └── Japanese/                       // الأنماط اليابانية التقليدية
│       ├── TraditionalPatterns.mqh     // الأنماط التقليدية (4 أنماط)
│       └── ModernAdaptations.mqh       // التكيفات الحديثة (3 أنماط)
```

## الأنماط المدعومة

### 🌟 **الأنماط الأساسية (Essential) - 20 نمط**

#### أنماط النجوم (StarPatterns)
1. **نجمة الصباح** (Morning Star) - صعودي
2. **نجمة المساء** (Evening Star) - هبوطي  
3. **نجمة الدوجي** (Doji Star) - انعكاس
4. **الطفل المهجور** (Abandoned Baby) - انعكاس قوي

#### أنماط الجنود والغربان (SoldierCrowPatterns)
1. **ثلاثة جنود بيض** (Three White Soldiers) - صعودي قوي
2. **ثلاثة غربان سود** (Three Black Crows) - هبوطي قوي
3. **كتلة التقدم** (Advance Block) - تحذير انعكاس
4. **نمط التداول** (Deliberation Pattern) - تردد

#### أنماط الداخل والخارج (InsideOutsidePatterns)
1. **ثلاثة للداخل صعوداً** (Three Inside Up) - صعودي
2. **ثلاثة للداخل هبوطاً** (Three Inside Down) - هبوطي
3. **ثلاثة للخارج صعوداً** (Three Outside Up) - صعودي قوي
4. **ثلاثة للخارج هبوطاً** (Three Outside Down) - هبوطي قوي

#### أنماط الطرق الثلاث (ThreeMethodsPatterns)
1. **الطرق الثلاث الصاعدة** (Rising Three Methods) - استمرار صعودي
2. **الطرق الثلاث الهابطة** (Falling Three Methods) - استمرار هبوطي
3. **فجوة صاعدة بثلاث طرق** (Up Gap Three Methods) - تحليل فجوة
4. **فجوة هابطة بثلاث طرق** (Down Gap Three Methods) - تحليل فجوة

#### أنماط الخطوط الثلاثية (TripleLinePatterns)
1. **ضربة الخطوط الثلاثة** (Three Lines Strike) - انعكاس قوي
2. **قاع الأنهار الثلاثة** (Three River Bottom) - صعودي
3. **قمة الأنهار الثلاثة** (Three River Top) - هبوطي
4. **النجمة الثلاثية** (Tri Star) - انعكاس

### 🚀 **الأنماط المتقدمة (Advanced) - 15 نمط**

#### أنماط الانفصال (BreakawayPatterns)
1. **الانفصال الصعودي** (Bullish Breakaway) - اختراق صعودي
2. **الانفصال الهبوطي** (Bearish Breakaway) - اختراق هبوطي

#### أنماط الإخفاء (ConcealingPatterns)
1. **ابتلاع الطفل المخفي** (Concealing Baby Swallow) - صعودي
2. **الغطاء السحابي المخفي** (Concealing Cloud Cover) - هبوطي

#### أنماط كتلة التقدم (AdvanceBlockPatterns)
1. **كتلة التقدم الكلاسيكية** (Classic Advance Block) - تحذير انعكاس
2. **كتلة التقدم الهبوطية** (Bearish Advance Block) - انعكاس صعودي
3. **كتلة التقدم مع التردد** (Deliberation Advance Block) - تحذير

#### أنماط التصحيح (CorrectionPatterns)
1. **خط تاسوكي للفجوة الصاعدة** (Upward Gap Tasuki Line) - استمرار
2. **خط تاسوكي للفجوة الهابطة** (Downward Gap Tasuki Line) - استمرار
3. **شطيرة العصا** (Stick Sandwich) - انعكاس
4. **الحمامة العائدة** (Homing Pigeon) - صعودي

#### أنماط الهوية والتطابق (IdentityPatterns)
1. **ثلاثة غربان متطابقة** (Identical Three Crows) - هبوطي قوي
2. **القاع المطابق** (Matching Low) - دعم قوي
3. **القمة المطابقة** (Matching High) - مقاومة قوية
4. **ثلاث نجوم في الجنوب** (Three Stars in South) - انعكاس صعودي

### ⚡ **الأنماط المتخصصة (Specialized) - 11 نمط**

#### أنماط الفجوات (GappingPatterns)
1. **ثلاث فجوات صاعدة** (Three Gaps Up) - ذروة شراء
2. **ثلاث فجوات هابطة** (Three Gaps Down) - ذروة بيع
3. **فجوة صاعدة جانبية** (Up Gap Side by Side) - استمرار/انعكاس
4. **فجوة هابطة جانبية** (Down Gap Side by Side) - استمرار/انعكاس

#### أنماط التداول (DeliberationPatterns)
1. **كتلة التداول** (Deliberation Block) - تحذير انعكاس
2. **التوقف** (Stalling) - فقدان زخم
3. **نجمة التداول** (Deliberation Star) - تردد

#### الأنماط الفريدة (UniquePatterns)
1. **قمة بوذا الثلاثية** (Three Buddha Top) - انعكاس هبوطي
2. **قاع بوذا الثلاثي** (Three Buddha Bottom) - انعكاس صعودي
3. **الأنهار الثلاثة الفريدة** (Unique Three River) - تحليل تدفق
4. **التشكيلات النادرة** (Rare Formations) - أنماط استثنائية

### 🎌 **الأنماط اليابانية (Japanese) - 7 أنماط**

#### الأنماط التقليدية (TraditionalPatterns)
1. **سانكو** (Sanku) - ثلاث فجوات تقليدية
2. **سانبي** (Sanpei) - ثلاث جنود تقليديين
3. **سانبو** (Sanpo) - ثلاث طرق تقليدية
4. **سانتن** (Santen) - ثلاث نقاط توازن

#### التكيفات الحديثة (ModernAdaptations)
1. **نجمة الصباح الحديثة** (Modern Morning Star) - تحليل متطور
2. **نجمة المساء الحديثة** (Modern Evening Star) - تحليل متطور
3. **الطرق الثلاث الحديثة** (Modern Three Methods) - تحليل حديث

## كيفية الاستخدام

### 1. **الاستخدام الأساسي**

```cpp
#include <CandlePatterns\\TripleCandle\\TripleCandlePatterns.mqh>

// إنشاء كاشف الأنماط
CTripleCandlePatterns* detector = new CTripleCandlePatterns();

// تهيئة الكاشف
if(detector.Initialize(Symbol(), Period()))
{
    // تحضير البيانات
    double open[], high[], low[], close[];
    long volume[];
    // ... تعبئة البيانات
    
    // كشف الأنماط
    SPatternDetectionResult results[];
    int found = detector.DetectAllPatterns(2, Symbol(), Period(), 
                                          open, high, low, close, volume, results);
    
    // معالجة النتائج
    for(int i = 0; i < found; i++)
    {
        Print("نمط مكتشف: ", results[i].patternName);
        Print("القوة: ", results[i].strength);
        Print("الموثوقية: ", results[i].reliability);
    }
}
```

### 2. **التحكم في الأنماط المفعلة**

```cpp
// تفعيل أنماط محددة فقط
detector.EnableEssentialPatterns(true);    // الأنماط الأساسية
detector.EnableAdvancedPatterns(false);    // إيقاف الأنماط المتقدمة
detector.EnableSpecializedPatterns(true);  // الأنماط المتخصصة
detector.EnableJapanesePatterns(true);     // الأنماط اليابانية

// تعديل الحساسية
detector.SetSensitivity(1.5); // حساسية عالية
```

### 3. **كشف أنماط محددة**

```cpp
// كشف الأنماط الأساسية فقط
SPatternDetectionResult essentialResults[];
int essentialCount = detector.DetectEssentialPatterns(2, Symbol(), Period(),
                                                     open, high, low, close, volume,
                                                     essentialResults);
```

## معايير التقييم

### **القوة (Strength)**
- **0.0 - 1.0**: ضعيف
- **1.0 - 2.0**: متوسط  
- **2.0 - 3.0**: قوي

### **الموثوقية (Reliability)**
- **0.0 - 0.5**: منخفضة
- **0.5 - 0.7**: متوسطة
- **0.7 - 0.9**: عالية
- **0.9 - 1.0**: عالية جداً

### **الثقة (Confidence)**
متوسط القوة والموثوقية - مؤشر شامل لجودة النمط

## متطلبات النظام

- **MetaTrader 5** (Build 3650+)
- **MQL5** Compiler
- **ذاكرة**: 50MB كحد أدنى
- **معالج**: أي معالج حديث

## التثبيت

1. نسخ المجلد `TripleCandle` إلى مجلد `Include/CandlePatterns/`
2. إعادة تشغيل MetaTrader 5
3. تضمين المكتبة في الكود: `#include <CandlePatterns\\TripleCandle\\TripleCandlePatterns.mqh>`

## الأداء والاستهلاك

- **سرعة المعالجة**: ~10ms لكل شمعة
- **استهلاك الذاكرة**: ~2MB للمكتبة كاملة
- **عدد الأنماط المدعومة**: 55+ نمط
- **دعم الحجم**: اختياري ومحسن للأداء

## الدعم والتطوير

### **الميزات المخططة**
- إضافة أنماط جديدة
- تحسين خوارزميات الكشف
- دعم إضافي للأطر الزمنية
- واجهة رسومية للإعدادات

### **الإبلاغ عن الأخطاء**
يرجى الإبلاغ عن أي أخطاء أو اقتراحات لتحسين المكتبة.

## الترخيص

حقوق النشر 2025 - مكتبة أنماط الشموع اليابانية
جميع الحقوق محفوظة.

---

**تم تطوير هذه المكتبة بعناية فائقة لتوفير أدق وأشمل نظام لكشف أنماط الشموع الثلاثية في السوق العربي.**
