//+------------------------------------------------------------------+
//|                          ChartUtils_Example.mq5 |
//|              مثال على استخدام أدوات المخططات المحسنة |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025"
#property version   "1.00"
#property strict

#include "Include/ChartPatterns/Base/ChartUtils.mqh"

//+------------------------------------------------------------------+
//| مثال على كيفية استخدام أدوات المخططات |
//+------------------------------------------------------------------+
void OnStart()
{
   // تهيئة أدوات المخططات
   if(!CAdvancedChartUtils::Initialize(0.02, 100))
   {
      Print("خطأ: فشل في تهيئة أدوات المخططات");
      return;
   }
   
   // الحصول على بيانات الأسعار
   double high[], low[], close[], volume[];
   datetime time[];
   
   string symbol = Symbol();
   ENUM_TIMEFRAMES tf = PERIOD_H1;
   int rates = 500;
   
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(time, true);
   
   // نسخ البيانات
   int copied_high = CopyHigh(symbol, tf, 0, rates, high);
   int copied_low = CopyLow(symbol, tf, 0, rates, low);
   int copied_close = CopyClose(symbol, tf, 0, rates, close);
   int copied_volume = CopyTickVolume(symbol, tf, 0, rates, volume);
   int copied_time = CopyTime(symbol, tf, 0, rates, time);
   
   if(copied_high > 0 && copied_low > 0 && copied_close > 0)
   {
      Print("تم الحصول على ", copied_high, " شمعة للتحليل");
      
      // إجراء التحليل الشامل
      SChartAnalysis analysis = CAdvancedChartUtils::PerformComprehensiveAnalysis(
         symbol, tf, high, low, close, volume, time, copied_high);
      
      // طباعة نتائج التحليل
      string result = CAdvancedChartUtils::AnalysisToString(analysis);
      Print(result);
      
      // اختبار دوال أخرى
      bool expansion = CAdvancedChartUtils::DetectPriceExpansion(high, low, 20, copied_high);
      bool contraction = CAdvancedChartUtils::DetectPriceContraction(high, low, 20, copied_high);
      bool bullish = CAdvancedChartUtils::IsMarketStructureBullish(high, low, 50, copied_high);
      bool bearish = CAdvancedChartUtils::IsMarketStructureBearish(high, low, 50, copied_high);
      
      Print("توسع السعر: ", expansion ? "نعم" : "لا");
      Print("انكماش السعر: ", contraction ? "نعم" : "لا");
      Print("هيكل صاعد: ", bullish ? "نعم" : "لا");
      Print("هيكل هابط: ", bearish ? "نعم" : "لا");
      
      // حساب التقلبات
      double volatility = CAdvancedChartUtils::CalculateVolatility(high, low, 20, copied_high - 20);
      Print("التقلبات (20 فترة): ", DoubleToString(volatility, 5));
      
      // حساب سرعة السعر
      double velocity = CAdvancedChartUtils::CalculatePriceVelocity(close, 14, copied_high);
      Print("سرعة السعر (14 فترة): ", DoubleToString(velocity, 5));
      
      // إظهار معلومات إضافية عن الاتجاه
      string trendStr = "";
      switch(analysis.overallTrend)
      {
         case TREND_BULLISH: trendStr = "صاعد"; break;
         case TREND_BEARISH: trendStr = "هابط"; break;
         case TREND_NEUTRAL: trendStr = "محايد"; break;
         default: trendStr = "غير محدد"; break;
      }
      Print("الاتجاه العام: ", trendStr, " (القوة: ", DoubleToString(analysis.trendStrength, 2), ")");
   }
   else
   {
      Print("خطأ: فشل في الحصول على بيانات الأسعار");
   }
   
   // تنظيف الموارد
   CAdvancedChartUtils::Deinitialize();
}