//+------------------------------------------------------------------+
//|                                   TripleCandlePatternExample.mq5|
//|                              مثال على استخدام أنماط الشموع الثلاثية |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property description "مثال على استخدام مكتبة أنماط الشموع الثلاثية"

// تضمين مكتبة أنماط الشموع الثلاثية
#include <CandlePatterns\\TripleCandle\\TripleCandlePatterns.mqh>

// معاملات الإدخال
input group "=== إعدادات كشف الأنماط ==="
input bool EnableEssentialPatterns = true;        // تمكين الأنماط الأساسية
input bool EnableAdvancedPatterns = true;         // تمكين الأنماط المتقدمة
input bool EnableSpecializedPatterns = true;      // تمكين الأنماط المتخصصة
input bool EnableJapanesePatterns = true;         // تمكين الأنماط اليابانية
input double PatternSensitivity = 1.0;           // حساسية كشف الأنماط (0.5-2.0)

input group "=== إعدادات العرض ==="
input bool ShowPatternNames = true;               // عرض أسماء الأنماط
input bool ShowPatternStrength = true;            // عرض قوة الأنماط
input bool ShowPatternReliability = true;         // عرض موثوقية الأنماط
input color BullishPatternColor = clrGreen;       // لون الأنماط الصعودية
input color BearishPatternColor = clrRed;         // لون الأنماط الهبوطية
input color NeutralPatternColor = clrBlue;        // لون الأنماط المحايدة

// متغيرات عامة
CTripleCandlePatterns* g_patternDetector;         // كاشف الأنماط
datetime g_lastBarTime;                           // وقت آخر شمعة تم تحليلها

//+------------------------------------------------------------------+
//| دالة التهيئة                                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("بدء تهيئة مكتبة أنماط الشموع الثلاثية...");
   
   // إنشاء كاشف الأنماط
   g_patternDetector = new CTripleCandlePatterns();
   
   if(g_patternDetector == NULL)
   {
      Print("خطأ: فشل في إنشاء كاشف الأنماط");
      return INIT_FAILED;
   }
   
   // تهيئة الكاشف
   if(!g_patternDetector.Initialize(Symbol(), Period()))
   {
      Print("خطأ: فشل في تهيئة كاشف الأنماط");
      delete g_patternDetector;
      g_patternDetector = NULL;
      return INIT_FAILED;
   }
   
   // تكوين الأنماط المفعلة
   g_patternDetector.EnableEssentialPatterns(EnableEssentialPatterns);
   g_patternDetector.EnableAdvancedPatterns(EnableAdvancedPatterns);
   g_patternDetector.EnableSpecializedPatterns(EnableSpecializedPatterns);
   g_patternDetector.EnableJapanesePatterns(EnableJapanesePatterns);
   
   // تعيين الحساسية
   g_patternDetector.SetSensitivity(PatternSensitivity);
   
   // تهيئة وقت آخر شمعة
   g_lastBarTime = iTime(Symbol(), Period(), 0);
   
   Print("تم تهيئة مكتبة أنماط الشموع الثلاثية بنجاح");
   Print("عدد الأنماط المدعومة: ", g_patternDetector.GetTotalPatternsCount());
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| دالة الإنهاء                                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("إنهاء مكتبة أنماط الشموع الثلاثية...");
   
   if(g_patternDetector != NULL)
   {
      delete g_patternDetector;
      g_patternDetector = NULL;
   }
   
   // إزالة جميع الكائنات المرسومة
   ObjectsDeleteAll(0, "TriplePattern_");
   
   Print("تم إنهاء مكتبة أنماط الشموع الثلاثية");
}

//+------------------------------------------------------------------+
//| دالة التحديث عند كل تك                                         |
//+------------------------------------------------------------------+
void OnTick()
{
   // التحقق من وجود شمعة جديدة
   datetime currentBarTime = iTime(Symbol(), Period(), 0);
   if(currentBarTime <= g_lastBarTime)
      return;
   
   g_lastBarTime = currentBarTime;
   
   // تحليل الأنماط
   AnalyzePatterns();
}

//+------------------------------------------------------------------+
//| دالة تحليل الأنماط                                              |
//+------------------------------------------------------------------+
void AnalyzePatterns()
{
   if(g_patternDetector == NULL)
      return;
   
   // الحصول على بيانات الشموع
   double open[], high[], low[], close[];
   long volume[];
   
   int bars = 100; // عدد الشموع للتحليل
   
   if(!GetCandleData(bars, open, high, low, close, volume))
   {
      Print("خطأ: فشل في الحصول على بيانات الشموع");
      return;
   }
   
   // تحليل آخر 10 شموع
   for(int i = 10; i >= 2; i--)
   {
      SPatternDetectionResult results[];
      
      // كشف الأنماط
      int foundPatterns = g_patternDetector.DetectAllPatterns(i, Symbol(), Period(), 
                                                             open, high, low, close, volume, results);
      
      if(foundPatterns > 0)
      {
         ProcessDetectedPatterns(results, foundPatterns, i);
      }
   }
}

//+------------------------------------------------------------------+
//| دالة الحصول على بيانات الشموع                                  |
//+------------------------------------------------------------------+
bool GetCandleData(int bars, double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   // تغيير حجم المصفوفات
   ArrayResize(open, bars);
   ArrayResize(high, bars);
   ArrayResize(low, bars);
   ArrayResize(close, bars);
   ArrayResize(volume, bars);
   
   // نسخ البيانات
   if(CopyOpen(Symbol(), Period(), 0, bars, open) != bars)
      return false;
   if(CopyHigh(Symbol(), Period(), 0, bars, high) != bars)
      return false;
   if(CopyLow(Symbol(), Period(), 0, bars, low) != bars)
      return false;
   if(CopyClose(Symbol(), Period(), 0, bars, close) != bars)
      return false;
   if(CopyTickVolume(Symbol(), Period(), 0, bars, volume) != bars)
   {
      // في حالة عدم توفر الحجم، استخدم قيم افتراضية
      ArrayInitialize(volume, 1);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| دالة معالجة الأنماط المكتشفة                                    |
//+------------------------------------------------------------------+
void ProcessDetectedPatterns(const SPatternDetectionResult &results[], int count, int barIndex)
{
   for(int i = 0; i < count; i++)
   {
      const SPatternDetectionResult pattern = results[i];
      
      // طباعة معلومات النمط
      PrintPatternInfo(pattern, barIndex);
      
      // رسم النمط على الرسم البياني
      DrawPatternOnChart(pattern, barIndex);
      
      // إرسال تنبيه
      SendPatternAlert(pattern, barIndex);
   }
}

//+------------------------------------------------------------------+
//| دالة طباعة معلومات النمط                                        |
//+------------------------------------------------------------------+
void PrintPatternInfo(const SPatternDetectionResult &pattern, int barIndex)
{
   string directionStr = "";
   switch(pattern.direction)
   {
      case PATTERN_BULLISH: directionStr = "صعودي"; break;
      case PATTERN_BEARISH: directionStr = "هبوطي"; break;
      case PATTERN_NEUTRAL: directionStr = "محايد"; break;
   }
   
   string message = StringFormat(
      "نمط مكتشف: %s | الاتجاه: %s | القوة: %.2f | الموثوقية: %.2f | الثقة: %.2f | الشمعة: %d",
      pattern.patternName, directionStr, pattern.strength, pattern.reliability, 
      pattern.confidence, barIndex);
   
   Print(message);
}

//+------------------------------------------------------------------+
//| دالة رسم النمط على الرسم البياني                               |
//+------------------------------------------------------------------+
void DrawPatternOnChart(const SPatternDetectionResult &pattern, int barIndex)
{
   if(!ShowPatternNames && !ShowPatternStrength && !ShowPatternReliability)
      return;
   
   // تحديد اللون بناء على الاتجاه
   color patternColor = NeutralPatternColor;
   switch(pattern.direction)
   {
      case PATTERN_BULLISH: patternColor = BullishPatternColor; break;
      case PATTERN_BEARISH: patternColor = BearishPatternColor; break;
   }
   
   // إنشاء اسم الكائن
   string objectName = StringFormat("TriplePattern_%s_%d", pattern.patternName, barIndex);
   
   // الحصول على سعر الرسم
   double price = iHigh(Symbol(), Period(), barIndex) + (iHigh(Symbol(), Period(), barIndex) - iLow(Symbol(), Period(), barIndex)) * 0.1;
   
   // رسم النص
   string displayText = "";
   if(ShowPatternNames)
      displayText += pattern.patternName;
   if(ShowPatternStrength)
      displayText += StringFormat("\nقوة: %.1f", pattern.strength);
   if(ShowPatternReliability)
      displayText += StringFormat("\nموثوقية: %.1f%%", pattern.reliability * 100);
   
   datetime time = iTime(Symbol(), Period(), barIndex);
   
   ObjectCreate(0, objectName, OBJ_TEXT, 0, time, price);
   ObjectSetString(0, objectName, OBJPROP_TEXT, displayText);
   ObjectSetInteger(0, objectName, OBJPROP_COLOR, patternColor);
   ObjectSetInteger(0, objectName, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, objectName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
}

//+------------------------------------------------------------------+
//| دالة إرسال التنبيه                                              |
//+------------------------------------------------------------------+
void SendPatternAlert(const SPatternDetectionResult &pattern, int barIndex)
{
   // إرسال تنبيه فقط للأنماط عالية الموثوقية
   if(pattern.reliability < 0.7)
      return;
   
   string directionStr = "";
   switch(pattern.direction)
   {
      case PATTERN_BULLISH: directionStr = "صعودي"; break;
      case PATTERN_BEARISH: directionStr = "هبوطي"; break;
      case PATTERN_NEUTRAL: directionStr = "محايد"; break;
   }
   
   string alertMessage = StringFormat(
      "%s: نمط %s %s - موثوقية %.1f%%",
      Symbol(), pattern.patternName, directionStr, pattern.reliability * 100);
   
   Alert(alertMessage);
}

//+------------------------------------------------------------------+
//| دالة معلومات إضافية عن النمط                                   |
//+------------------------------------------------------------------+
string GetPatternDescription(string patternName)
{
   // يمكن إضافة وصف مفصل لكل نمط هنا
   if(patternName == "Morning Star")
      return "نمط انعكاس صعودي يتكون من شمعة هبوطية، نجمة، وشمعة صعودية";
   else if(patternName == "Evening Star")
      return "نمط انعكاس هبوطي يتكون من شمعة صعودية، نجمة، وشمعة هبوطية";
   else if(patternName == "Three White Soldiers")
      return "نمط استمرار صعودي يتكون من ثلاث شموع صعودية متتالية";
   else if(patternName == "Three Black Crows")
      return "نمط استمرار هبوطي يتكون من ثلاث شموع هبوطية متتالية";
   
   return "نمط شموع ثلاثي";
}
