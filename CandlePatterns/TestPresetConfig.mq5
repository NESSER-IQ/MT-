//+------------------------------------------------------------------+
//|                                              TestPresetConfig.mq5 |
//|                                    اختبار ملف الإعدادات المعدة |
//|                         حقوق النشر 2025, علي تك للتداول الذكي |
//+------------------------------------------------------------------+

#property copyright "حقوق النشر 2025, علي تك للتداول الذكي"
#property link      "https://www.alitech-trading.com"
#property version   "1.00"
#property indicator_chart_window

// استيراد ملف الإعدادات
#include "Include/PresetConfigurations.mqh"

// متغير الإعدادات
CPresetManager* g_presetManager;

//+------------------------------------------------------------------+
//| دالة التهيئة                                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("🔄 تهيئة اختبار ملف الإعدادات...");
   
   // إنشاء مدير الإعدادات
   g_presetManager = new CPresetManager();
   
   if(g_presetManager == NULL)
   {
      Print("❌ فشل في إنشاء مدير الإعدادات");
      return INIT_FAILED;
   }
   
   Print("✅ تم إنشاء مدير الإعدادات بنجاح");
   
   // اختبار الإعدادات
   TestPresets();
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| دالة التنظيف                                                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(g_presetManager != NULL)
   {
      delete g_presetManager;
      g_presetManager = NULL;
   }
   
   Print("🔄 تم إنهاء اختبار ملف الإعدادات");
}

//+------------------------------------------------------------------+
//| اختبار الإعدادات                                               |
//+------------------------------------------------------------------+
void TestPresets()
{
   Print("🧪 بدء اختبار الإعدادات...");
   
   // الحصول على عدد الإعدادات
   int presetsCount = g_presetManager.GetPresetsCount();
   Print("📊 عدد الإعدادات المتاحة: ", presetsCount);
   
   // الحصول على أسماء الإعدادات
   string presetNames[];
   g_presetManager.GetPresetNames(presetNames);
   
   Print("📋 أسماء الإعدادات:");
   for(int i = 0; i < ArraySize(presetNames); i++)
   {
      Print("   ", i + 1, ". ", presetNames[i]);
   }
   
   // اختبار كل إعداد
   for(int i = 0; i < presetsCount; i++)
   {
      Print("\\n🔍 اختبار الإعداد رقم ", i + 1, ":");
      
      // الحصول على الإعداد
      SPresetConfig preset = g_presetManager.GetPreset(i);
      
      // طباعة التفاصيل الأساسية
      Print("📝 الاسم: ", preset.name);
      Print("📖 الوصف: ", preset.description);
      Print("💰 إدارة الأموال: ", MoneyManagementTypeToString(preset.mmType));
      Print("📈 اتجاه التداول: ", TradeDirectionFilterToString(preset.tradeDirection));
      Print("🚪 استراتيجية الخروج: ", ExitStrategyToString(preset.exitStrategy));
      Print("⚖️ نسبة المخاطرة: ", preset.riskPercent, "%");
      Print("🎯 قوة النمط المطلوبة: ", preset.minPatternStrength);
      Print("📊 موثوقية النمط: ", preset.minPatternReliability);
      
      // طباعة التفاصيل الكاملة
      g_presetManager.PrintPresetDetails(i);
      
      // اختبار تطبيق الإعداد
      bool applied = g_presetManager.ApplyPreset(i);
      Print("✅ تطبيق الإعداد: ", applied ? "نجح" : "فشل");
   }
   
   // اختبار حفظ وتحميل الإعدادات
   Print("\\n💾 اختبار حفظ وتحميل الإعدادات...");
   
   SPresetConfig testPreset = g_presetManager.GetPreset(0);
   bool saved = SavePresetToFile(testPreset, "test_preset.txt");
   Print("💾 حفظ الإعداد: ", saved ? "نجح" : "فشل");
   
   SPresetConfig loadedPreset;
   bool loaded = LoadPresetFromFile("test_preset.txt", loadedPreset);
   Print("📁 تحميل الإعداد: ", loaded ? "نجح" : "فشل");
   
   Print("\\n✅ انتهى اختبار الإعدادات بنجاح!");
}

//+------------------------------------------------------------------+
//| دالة الحساب (مطلوبة للمؤشرات)                                   |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // لا حاجة لحسابات في هذا الاختبار
   return rates_total;
}

//+------------------------------------------------------------------+
//| نهاية الملف                                                     |
//+------------------------------------------------------------------+