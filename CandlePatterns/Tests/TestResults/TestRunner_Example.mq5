//+------------------------------------------------------------------+
//|                                    TestRunner_Example.mq5     |
//|                                  مثال على تشغيل اختبار المكتبة |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property version   "1.00"
#property script_show_inputs

//--- معاملات الإدخال للمثال
input string InpTestSymbol = "EURUSD";      // الرمز للاختبار
input ENUM_TIMEFRAMES InpTestTimeframe = PERIOD_H1; // الإطار الزمني
input int InpTestBars = 1000;               // عدد الشموع للاختبار
input bool InpDetailedReport = true;       // تقرير مفصل

//+------------------------------------------------------------------+
//| تشغيل السكريبت                                                   |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== مثال على تشغيل اختبار مكتبة أنماط الشموع ===");
   
   // معلومات عامة
   Print("الرمز: ", InpTestSymbol);
   Print("الإطار الزمني: ", EnumToString(InpTestTimeframe));
   Print("عدد الشموع: ", InpTestBars);
   
   // تشغيل اختبار سريع
   RunQuickTest();
   
   // تشغيل اختبار شامل (اختياري)
   if(InpDetailedReport)
   {
      RunDetailedTest();
   }
   
   Print("=== انتهاء المثال ===");
}

//+------------------------------------------------------------------+
//| اختبار سريع للمكتبة                                             |
//+------------------------------------------------------------------+
void RunQuickTest()
{
   Print("--- اختبار سريع ---");
   
   // محاولة تشغيل اختبار أساسي
   Print("خطوة 1: فحص توفر البيانات...");
   
   double open[], high[], low[], close[];
   long volume[];
   
   int copied = CopyOpen(InpTestSymbol, InpTestTimeframe, 0, 10, open);
   if(copied <= 0)
   {
      Print("خطأ: لا يمكن الحصول على بيانات للرمز ", InpTestSymbol);
      return;
   }
   
   Print("✓ تم الحصول على ", copied, " شمعة");
   
   // فحص صحة البيانات
   CopyHigh(InpTestSymbol, InpTestTimeframe, 0, 10, high);
   CopyLow(InpTestSymbol, InpTestTimeframe, 0, 10, low);
   CopyClose(InpTestSymbol, InpTestTimeframe, 0, 10, close);
   
   bool dataValid = true;
   for(int i = 0; i < copied; i++)
   {
      if(high[i] < open[i] || high[i] < close[i] || 
         low[i] > open[i] || low[i] > close[i] ||
         high[i] <= low[i])
      {
         Print("تحذير: بيانات غير صحيحة في الشمعة ", i);
         dataValid = false;
      }
   }
   
   if(dataValid)
      Print("✓ البيانات صحيحة");
   else
      Print("⚠️ تم اكتشاف بيانات غير صحيحة");
   
   Print("خطوة 2: اختبار دوال المرافق...");
   TestUtilityFunctions(open, high, low, close);
   
   Print("--- انتهاء الاختبار السريع ---");
}

//+------------------------------------------------------------------+
//| اختبار مفصل                                                     |
//+------------------------------------------------------------------+
void RunDetailedTest()
{
   Print("--- اختبار مفصل ---");
   
   // محاولة تحميل المزيد من البيانات
   double open[], high[], low[], close[];
   long volume[];
   
   int copied = CopyOpen(InpTestSymbol, InpTestTimeframe, 0, InpTestBars, open);
   if(copied <= 0)
   {
      Print("خطأ: لا يمكن الحصول على بيانات مفصلة");
      return;
   }
   
   CopyHigh(InpTestSymbol, InpTestTimeframe, 0, InpTestBars, high);
   CopyLow(InpTestSymbol, InpTestTimeframe, 0, InpTestBars, low);
   CopyClose(InpTestSymbol, InpTestTimeframe, 0, InpTestBars, close);
   CopyTickVolume(InpTestSymbol, InpTestTimeframe, 0, InpTestBars, volume);
   
   Print("تم تحميل ", copied, " شمعة للتحليل المفصل");
   
   // تحليل إحصائي للبيانات
   AnalyzeMarketData(open, high, low, close, volume);
   
   // اختبار أنماط مختلفة
   TestPatternDistribution(open, high, low, close, volume);
   
   Print("--- انتهاء الاختبار المفصل ---");
}

//+------------------------------------------------------------------+
//| اختبار دوال المرافق                                             |
//+------------------------------------------------------------------+
void TestUtilityFunctions(double &open[], double &high[], double &low[], double &close[])
{
   for(int i = 0; i < ArraySize(open); i++)
   {
      // حساب خصائص الشمعة
      double body = MathAbs(close[i] - open[i]);
      double upperShadow = high[i] - MathMax(open[i], close[i]);
      double lowerShadow = MathMin(open[i], close[i]) - low[i];
      double range = high[i] - low[i];
      
      // فحص صحة الحسابات
      if(range < body + upperShadow + lowerShadow - 0.00001)
      {
         Print("تحذير: خطأ في حساب خصائص الشمعة ", i);
      }
      
      // تحديد نوع الشمعة
      string candleType = "محايدة";
      if(close[i] > open[i])
         candleType = "صاعدة";
      else if(close[i] < open[i])
         candleType = "هابطة";
      
      if(i < 3) // طباعة أول 3 شموع كمثال
      {
         Print("الشمعة ", i, ": ", candleType, 
               " - الجسم: ", DoubleToString(body, 5),
               " - المدى: ", DoubleToString(range, 5));
      }
   }
   
   Print("✓ اختبار دوال المرافق مكتمل");
}

//+------------------------------------------------------------------+
//| تحليل بيانات السوق                                              |
//+------------------------------------------------------------------+
void AnalyzeMarketData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   int size = ArraySize(open);
   if(size == 0) return;
   
   // حساب الإحصائيات الأساسية
   double totalRange = 0;
   double totalBody = 0;
   int bullishCount = 0;
   int bearishCount = 0;
   int dojiCount = 0;
   
   for(int i = 0; i < size; i++)
   {
      double body = MathAbs(close[i] - open[i]);
      double range = high[i] - low[i];
      
      totalRange += range;
      totalBody += body;
      
      if(close[i] > open[i])
         bullishCount++;
      else if(close[i] < open[i])
         bearishCount++;
      else
         dojiCount++;
   }
   
   double avgRange = totalRange / size;
   double avgBody = totalBody / size;
   double bodyToRangeRatio = (totalRange > 0) ? totalBody / totalRange : 0;
   
   Print("=== تحليل بيانات السوق ===");
   Print("متوسط المدى: ", DoubleToString(avgRange, 5));
   Print("متوسط الجسم: ", DoubleToString(avgBody, 5));
   Print("نسبة الجسم للمدى: ", DoubleToString(bodyToRangeRatio * 100, 1), "%");
   Print("الشموع الصاعدة: ", bullishCount, " (", DoubleToString((double)bullishCount/size*100, 1), "%)");
   Print("الشموع الهابطة: ", bearishCount, " (", DoubleToString((double)bearishCount/size*100, 1), "%)");
   Print("الدوجي: ", dojiCount, " (", DoubleToString((double)dojiCount/size*100, 1), "%)");
}

//+------------------------------------------------------------------+
//| اختبار توزيع الأنماط                                             |
//+------------------------------------------------------------------+
void TestPatternDistribution(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   int size = ArraySize(open);
   if(size < 20) return; // نحتاج بيانات كافية
   
   Print("=== اختبار توزيع الأنماط ===");
   
   // إحصائيات الأنماط الأساسية
   int hammerLike = 0;    // شموع تشبه المطرقة
   int dojiLike = 0;      // شموع تشبه الدوجي
   int marubozuLike = 0;  // شموع تشبه الماروبوزو
   int spinningTop = 0;   // قمم دوارة
   
   for(int i = 0; i < size; i++)
   {
      double body = MathAbs(close[i] - open[i]);
      double range = high[i] - low[i];
      double upperShadow = high[i] - MathMax(open[i], close[i]);
      double lowerShadow = MathMin(open[i], close[i]) - low[i];
      
      if(range == 0) continue;
      
      double bodyRatio = body / range;
      
      // تصنيف تقريبي للأنماط
      if(bodyRatio < 0.1) // جسم صغير جداً
      {
         dojiLike++;
      }
      else if(bodyRatio > 0.8) // جسم كبير
      {
         marubozuLike++;
      }
      else if(bodyRatio < 0.3) // جسم صغير مع ظلال
      {
         if(lowerShadow > body * 2 && upperShadow < body * 0.5)
            hammerLike++;
         else if(upperShadow > body && lowerShadow > body)
            spinningTop++;
      }
   }
   
   Print("الأنماط المكتشفة (تقريبية):");
   Print("  مثل الدوجي: ", dojiLike, " (", DoubleToString((double)dojiLike/size*100, 1), "%)");
   Print("  مثل المطرقة: ", hammerLike, " (", DoubleToString((double)hammerLike/size*100, 1), "%)");
   Print("  مثل الماروبوزو: ", marubozuLike, " (", DoubleToString((double)marubozuLike/size*100, 1), "%)");
   Print("  قمم دوارة: ", spinningTop, " (", DoubleToString((double)spinningTop/size*100, 1), "%)");
   
   // تحليل فترات التقلب
   AnalyzeVolatilityPeriods(open, high, low, close);
}

//+------------------------------------------------------------------+
//| تحليل فترات التقلب                                              |
//+------------------------------------------------------------------+
void AnalyzeVolatilityPeriods(double &open[], double &high[], double &low[], double &close[])
{
   int size = ArraySize(open);
   if(size < 50) return;
   
   Print("--- تحليل فترات التقلب ---");
   
   // حساب متوسط المدى المتحرك
   double ranges[];
   ArrayResize(ranges, size);
   
   for(int i = 0; i < size; i++)
   {
      ranges[i] = high[i] - low[i];
   }
   
   // حساب المتوسط المتحرك للمدى (14 فترة)
   double avgRanges[];
   ArrayResize(avgRanges, size);
   
   for(int i = 14; i < size; i++)
   {
      double sum = 0;
      for(int j = i - 13; j <= i; j++)
      {
         sum += ranges[j];
      }
      avgRanges[i] = sum / 14.0;
   }
   
   // العثور على فترات التقلب العالي والمنخفض
   int highVolatilityPeriods = 0;
   int lowVolatilityPeriods = 0;
   
   for(int i = 14; i < size; i++)
   {
      if(avgRanges[i] > 0)
      {
         double volatilityRatio = ranges[i] / avgRanges[i];
         
         if(volatilityRatio > 1.5)
            highVolatilityPeriods++;
         else if(volatilityRatio < 0.7)
            lowVolatilityPeriods++;
      }
   }
   
   Print("فترات التقلب العالي: ", highVolatilityPeriods);
   Print("فترات التقلب المنخفض: ", lowVolatilityPeriods);
   
   // فترات التقلب قد تؤثر على دقة كشف الأنماط
   if(highVolatilityPeriods > size * 0.2)
   {
      Print("تحذير: نسبة عالية من فترات التقلب العالي قد تؤثر على دقة الكشف");
   }
}

//+------------------------------------------------------------------+
//| دالة مساعدة لحفظ تقرير مفصل                                    |
//+------------------------------------------------------------------+
void SaveDetailedReport(string symbolName, ENUM_TIMEFRAMES timeframe, int barsAnalyzed)
{
   string fileName = "QuickTest_" + symbolName + "_" + EnumToString(timeframe) + "_" + 
                    TimeToString(TimeCurrent(), TIME_DATE) + ".txt";
   
   int handle = FileOpen(fileName, FILE_WRITE | FILE_TXT);
   if(handle != INVALID_HANDLE)
   {
      FileWriteString(handle, "=== تقرير اختبار سريع ===\n");
      FileWriteString(handle, "التاريخ: " + TimeToString(TimeCurrent()) + "\n");
      FileWriteString(handle, "الرمز: " + symbolName + "\n");
      FileWriteString(handle, "الإطار الزمني: " + EnumToString(timeframe) + "\n");
      FileWriteString(handle, "عدد الشموع المحللة: " + IntegerToString(barsAnalyzed) + "\n\n");
      
      FileWriteString(handle, "ملاحظة: هذا اختبار سريع للتأكد من جاهزية النظام.\n");
      FileWriteString(handle, "للحصول على اختبار شامل، استخدم TestSingleCandlePatterns.mq5\n");
      
      FileClose(handle);
      Print("تم حفظ التقرير: ", fileName);
   }
}
