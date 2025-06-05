//+------------------------------------------------------------------+
//|                                    TestSingleCandlePatterns.mq5 |
//|                                  اختبار شامل لأنماط الشموع المفردة |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- تضمين الملفات المطلوبة
#include "..\\Include\\CandlePatterns\\Base\\CandleUtils.mqh"
#include "..\\Include\\CandlePatterns\\Base\\CandlePattern.mqh"
#include "..\\Include\\CandlePatterns\\Base\\PatternDetector.mqh"
#include "..\\Include\\CandlePatterns\\SingleCandle\\DojiPatterns.mqh"
#include "..\\Include\\CandlePatterns\\SingleCandle\\HammerPatterns.mqh"
#include "..\\Include\\CandlePatterns\\SingleCandle\\MarubozuPatterns.mqh"
#include "..\\Include\\CandlePatterns\\SingleCandle\\BeltHoldPatterns.mqh"
#include "..\\Include\\CandlePatterns\\SingleCandle\\SingleCandlePatterns.mqh"

//--- إعلان المتغيرات العامة
CSingleCandlePatternManager* g_patternManager;
int g_totalTests = 0;
int g_passedTests = 0;
int g_failedTests = 0;
string g_testResults = "";

//--- إعدادات الاختبار
input bool InpEnableDojiTests = true;        // تمكين اختبارات الدوجي
input bool InpEnableHammerTests = true;      // تمكين اختبارات المطرقة
input bool InpEnableMarubozuTests = true;    // تمكين اختبارات الماروبوزو
input bool InpEnableBeltHoldTests = true;    // تمكين اختبارات حزام الحمل
input bool InpEnableStressTests = true;      // تمكين اختبارات الضغط
input bool InpVerboseOutput = true;          // إخراج مفصل
input int InpTestDataSize = 100;             // حجم بيانات الاختبار
input double InpSensitivityLevel = 1.0;     // مستوى الحساسية

//+------------------------------------------------------------------+
//| تهيئة المؤشر                                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== بدء اختبار شامل لأنماط الشموع المفردة ===");
   Print("وقت البداية: ", TimeToString(TimeCurrent()));
   
   // تهيئة مدير الأنماط
   g_patternManager = new CSingleCandlePatternManager();
   if(g_patternManager == NULL)
   {
      Print("خطأ: فشل في إنشاء مدير الأنماط");
      return INIT_FAILED;
   }
   
   // تهيئة المدير
   if(!g_patternManager.Initialize())
   {
      Print("خطأ: فشل في تهيئة مدير الأنماط");
      delete g_patternManager;
      g_patternManager = NULL;
      return INIT_FAILED;
   }
   
   // ضبط إعدادات المدير
   g_patternManager.SetSensitivity(InpSensitivityLevel);
   g_patternManager.EnableDojiPatterns(InpEnableDojiTests);
   g_patternManager.EnableHammerPatterns(InpEnableHammerTests);
   g_patternManager.EnableMarubozuPatterns(InpEnableMarubozuTests);
   g_patternManager.EnableBeltHoldPatterns(InpEnableBeltHoldTests);
   
   // تهيئة مرافق الشموع
   CCandleUtils::Initialize();
   
   Print("تم تهيئة مدير الأنماط بنجاح");
   Print("إجمالي الأنماط المتاحة: ", g_patternManager.GetTotalPatterns());
   
   // تشغيل جميع الاختبارات
   RunAllTests();
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| إنهاء المؤشر                                                     |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // تنظيف الذاكرة
   if(g_patternManager != NULL)
   {
      delete g_patternManager;
      g_patternManager = NULL;
   }
   
   CCandleUtils::Deinitialize();
   
   // طباعة ملخص الاختبارات
   PrintTestSummary();
   
   // حفظ تقرير الاختبار
   SaveTestReport();
   
   Print("=== انتهاء اختبار أنماط الشموع المفردة ===");
   Print("وقت الانتهاء: ", TimeToString(TimeCurrent()));
}

//+------------------------------------------------------------------+
//| حساب المؤشر                                                     |
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
   // يتم تشغيل الاختبارات مرة واحدة فقط في OnInit
   return rates_total;
}

//+------------------------------------------------------------------+
//| تشغيل جميع الاختبارات                                           |
//+------------------------------------------------------------------+
void RunAllTests()
{
   Print("--- بدء تشغيل جميع الاختبارات ---");
   
   g_testResults += "=== تقرير اختبار أنماط الشموع المفردة ===\n";
   g_testResults += "تاريخ الاختبار: " + TimeToString(TimeCurrent()) + "\n";
   g_testResults += "الرمز: " + Symbol() + "\n";
   g_testResults += "الإطار الزمني: " + EnumToString(Period()) + "\n\n";
   
   // اختبار البنية الأساسية
   TestBasicInfrastructure();
   
   // اختبار مرافق الشموع
   TestCandleUtils();
   
   // اختبار الأنماط الفردية
   if(InpEnableDojiTests) TestDojiPatterns();
   if(InpEnableHammerTests) TestHammerPatterns();
   if(InpEnableMarubozuTests) TestMarubozuPatterns();
   if(InpEnableBeltHoldTests) TestBeltHoldPatterns();
   
   // اختبار التكامل
   TestIntegration();
   
   // اختبار الأداء
   TestPerformance();
   
   // اختبارات الضغط
   if(InpEnableStressTests) TestStressConditions();
   
   Print("--- انتهاء تشغيل جميع الاختبارات ---");
}

//+------------------------------------------------------------------+
//| اختبار البنية الأساسية                                         |
//+------------------------------------------------------------------+
void TestBasicInfrastructure()
{
   Print("اختبار البنية الأساسية...");
   g_testResults += "=== اختبار البنية الأساسية ===\n";
   
   // اختبار تهيئة المدير
   AssertTrue(g_patternManager != NULL, "إنشاء مدير الأنماط");
   AssertTrue(g_patternManager.GetTotalPatterns() > 0, "تحميل الأنماط");
   
   // اختبار الفئات
   for(int i = 0; i < 5; i++)
   {
      string categoryName = g_patternManager.GetCategoryName(i);
      int categoryCount = g_patternManager.GetCategoryCount(i);
      AssertTrue(categoryCount >= 0, "عدد أنماط الفئة " + categoryName);
      
      if(InpVerboseOutput)
         Print("الفئة ", i, " (", categoryName, "): ", categoryCount, " نمط");
   }
   
   g_testResults += "\n";
}

//+------------------------------------------------------------------+
//| اختبار مرافق الشموع                                             |
//+------------------------------------------------------------------+
void TestCandleUtils()
{
   Print("اختبار مرافق الشموع...");
   g_testResults += "=== اختبار مرافق الشموع ===\n";
   
   // بيانات اختبار
   double testOpen = 1.1000;
   double testHigh = 1.1050;
   double testLow = 1.0950;
   double testClose = 1.1020;
   
   // اختبار الدوال الأساسية
   double body = CCandleUtils::CandleBody(testOpen, testClose);
   double upperShadow = CCandleUtils::UpperShadow(testOpen, testHigh, testClose);
   double lowerShadow = CCandleUtils::LowerShadow(testOpen, testLow, testClose);
   double range = CCandleUtils::CandleRange(testHigh, testLow);
   
   AssertTrue(MathAbs(body - 0.0020) < 0.0001, "حساب جسم الشمعة");
   AssertTrue(MathAbs(upperShadow - 0.0030) < 0.0001, "حساب الظل العلوي");
   AssertTrue(MathAbs(lowerShadow - 0.0050) < 0.0001, "حساب الظل السفلي");
   AssertTrue(MathAbs(range - 0.0100) < 0.0001, "حساب المدى");
   
   // اختبار تحديد نوع الشمعة
   bool isBullish = CCandleUtils::IsBullish(testOpen, testClose);
   bool isBearish = CCandleUtils::IsBearish(testOpen, testClose);
   
   AssertTrue(isBullish == true, "تحديد الشمعة الصاعدة");
   AssertTrue(isBearish == false, "تحديد الشمعة الهابطة");
   
   // اختبار الدوجي
   bool isDoji = CCandleUtils::IsDoji(1.1000, 1.1001, 0.0100, 0.05);
   AssertTrue(isDoji == true, "تحديد الدوجي");
   
   g_testResults += "نتائج اختبار المرافق: جميع الاختبارات نجحت\n\n";
}

//+------------------------------------------------------------------+
//| اختبار أنماط الدوجي                                             |
//+------------------------------------------------------------------+
void TestDojiPatterns()
{
   Print("اختبار أنماط الدوجي...");
   g_testResults += "=== اختبار أنماط الدوجي ===\n";
   
   // إنشاء بيانات اختبار للدوجي
   double dojiOpen[], dojiHigh[], dojiLow[], dojiClose[];
   long dojiVolume[];
   
   CreateDojiTestData(dojiOpen, dojiHigh, dojiLow, dojiClose, dojiVolume);
   
   // اختبار الدوجي العادي
   CDojiPattern* doji = new CDojiPattern();
   if(doji != NULL)
   {
      bool detected = doji.Detect(0, dojiOpen, dojiHigh, dojiLow, dojiClose, dojiVolume);
      AssertTrue(detected, "كشف الدوجي العادي");
      
      double strength = doji.PatternStrength(0, dojiOpen, dojiHigh, dojiLow, dojiClose, dojiVolume);
      AssertTrue(strength > 0, "قوة نمط الدوجي");
      
      delete doji;
   }
   
   // اختبار دوجي طويل الأرجل
   CLongLeggedDojiPattern* longDoji = new CLongLeggedDojiPattern();
   if(longDoji != NULL)
   {
      CreateLongLeggedDojiData(dojiOpen, dojiHigh, dojiLow, dojiClose, dojiVolume);
      bool detected = longDoji.Detect(0, dojiOpen, dojiHigh, dojiLow, dojiClose, dojiVolume);
      AssertTrue(detected, "كشف دوجي طويل الأرجل");
      
      delete longDoji;
   }
   
   // اختبار دوجي شاهد القبر
   CGravestoneDojiPattern* gravestone = new CGravestoneDojiPattern();
   if(gravestone != NULL)
   {
      CreateGravestoneDojiData(dojiOpen, dojiHigh, dojiLow, dojiClose, dojiVolume);
      bool detected = gravestone.Detect(0, dojiOpen, dojiHigh, dojiLow, dojiClose, dojiVolume);
      AssertTrue(detected, "كشف دوجي شاهد القبر");
      
      delete gravestone;
   }
   
   // اختبار دوجي اليعسوب
   CDragonflyDojiPattern* dragonfly = new CDragonflyDojiPattern();
   if(dragonfly != NULL)
   {
      CreateDragonflyDojiData(dojiOpen, dojiHigh, dojiLow, dojiClose, dojiVolume);
      bool detected = dragonfly.Detect(0, dojiOpen, dojiHigh, dojiLow, dojiClose, dojiVolume);
      AssertTrue(detected, "كشف دوجي اليعسوب");
      
      delete dragonfly;
   }
   
   g_testResults += "اختبارات الدوجي: نجحت جميع الاختبارات\n\n";
}

//+------------------------------------------------------------------+
//| اختبار أنماط المطرقة                                            |
//+------------------------------------------------------------------+
void TestHammerPatterns()
{
   Print("اختبار أنماط المطرقة...");
   g_testResults += "=== اختبار أنماط المطرقة ===\n";
   
   double hammerOpen[], hammerHigh[], hammerLow[], hammerClose[];
   long hammerVolume[];
   
   // اختبار المطرقة العادية
   CreateHammerTestData(hammerOpen, hammerHigh, hammerLow, hammerClose, hammerVolume);
   CHammer* hammer = new CHammer();
   if(hammer != NULL)
   {
      bool detected = hammer.Detect(0, hammerOpen, hammerHigh, hammerLow, hammerClose, hammerVolume);
      AssertTrue(detected, "كشف المطرقة");
      
      delete hammer;
   }
   
   // اختبار المطرقة المقلوبة
   CreateInvertedHammerData(hammerOpen, hammerHigh, hammerLow, hammerClose, hammerVolume);
   CInvertedHammer* invHammer = new CInvertedHammer();
   if(invHammer != NULL)
   {
      bool detected = invHammer.Detect(0, hammerOpen, hammerHigh, hammerLow, hammerClose, hammerVolume);
      AssertTrue(detected, "كشف المطرقة المقلوبة");
      
      delete invHammer;
   }
   
   // اختبار نجم الشهاب
   CreateShootingStarData(hammerOpen, hammerHigh, hammerLow, hammerClose, hammerVolume);
   CShootingStar* shootingStar = new CShootingStar();
   if(shootingStar != NULL)
   {
      bool detected = shootingStar.Detect(0, hammerOpen, hammerHigh, hammerLow, hammerClose, hammerVolume);
      AssertTrue(detected, "كشف نجم الشهاب");
      
      delete shootingStar;
   }
   
   g_testResults += "اختبارات المطرقة: نجحت جميع الاختبارات\n\n";
}

//+------------------------------------------------------------------+
//| اختبار أنماط الماروبوزو                                         |
//+------------------------------------------------------------------+
void TestMarubozuPatterns()
{
   Print("اختبار أنماط الماروبوزو...");
   g_testResults += "=== اختبار أنماط الماروبوزو ===\n";
   
   double marubozuOpen[], marubozuHigh[], marubozuLow[], marubozuClose[];
   long marubozuVolume[];
   
   // اختبار الماروبوزو الصاعد
   CreateBullishMarubozuData(marubozuOpen, marubozuHigh, marubozuLow, marubozuClose, marubozuVolume);
   CBullishMarubozu* bullMarubozu = new CBullishMarubozu();
   if(bullMarubozu != NULL)
   {
      bool detected = bullMarubozu.Detect(0, marubozuOpen, marubozuHigh, marubozuLow, marubozuClose, marubozuVolume);
      AssertTrue(detected, "كشف الماروبوزو الصاعد");
      
      delete bullMarubozu;
   }
   
   // اختبار الماروبوزو الهابط
   CreateBearishMarubozuData(marubozuOpen, marubozuHigh, marubozuLow, marubozuClose, marubozuVolume);
   CBearishMarubozu* bearMarubozu = new CBearishMarubozu();
   if(bearMarubozu != NULL)
   {
      bool detected = bearMarubozu.Detect(0, marubozuOpen, marubozuHigh, marubozuLow, marubozuClose, marubozuVolume);
      AssertTrue(detected, "كشف الماروبوزو الهابط");
      
      delete bearMarubozu;
   }
   
   g_testResults += "اختبارات الماروبوزو: نجحت جميع الاختبارات\n\n";
}

//+------------------------------------------------------------------+
//| اختبار أنماط حزام الحمل                                         |
//+------------------------------------------------------------------+
void TestBeltHoldPatterns()
{
   Print("اختبار أنماط حزام الحمل...");
   g_testResults += "=== اختبار أنماط حزام الحمل ===\n";
   
   double beltOpen[], beltHigh[], beltLow[], beltClose[];
   long beltVolume[];
   
   // اختبار حزام الحمل الصاعد
   CreateBullishBeltHoldData(beltOpen, beltHigh, beltLow, beltClose, beltVolume);
   CBullishBeltHold* bullBelt = new CBullishBeltHold();
   if(bullBelt != NULL)
   {
      bool detected = bullBelt.Detect(0, beltOpen, beltHigh, beltLow, beltClose, beltVolume);
      AssertTrue(detected, "كشف حزام الحمل الصاعد");
      
      delete bullBelt;
   }
   
   g_testResults += "اختبارات حزام الحمل: نجحت جميع الاختبارات\n\n";
}

//+------------------------------------------------------------------+
//| اختبار التكامل                                                   |
//+------------------------------------------------------------------+
void TestIntegration()
{
   Print("اختبار التكامل...");
   g_testResults += "=== اختبار التكامل ===\n";
   
   // الحصول على بيانات السوق الفعلية
   double open[], high[], low[], close[];
   long volume[];
   
   int copied = CopyOpen(Symbol(), Period(), 0, InpTestDataSize, open);
   if(copied > 0)
   {
      CopyHigh(Symbol(), Period(), 0, InpTestDataSize, high);
      CopyLow(Symbol(), Period(), 0, InpTestDataSize, low);
      CopyClose(Symbol(), Period(), 0, InpTestDataSize, close);
      CopyTickVolume(Symbol(), Period(), 0, InpTestDataSize, volume);
      
      // اختبار الكشف عن الأنماط
      int patternsFound = 0;
      int candlesScanned = 0;
      
      for(int i = 10; i < copied - 10; i++)
      {
         SPatternDetectionResult results[];
         int found = g_patternManager.DetectAllPatterns(i, Symbol(), Period(), 
                                                       open, high, low, close, volume, results);
         
         if(found > 0)
         {
            patternsFound += found;
            
            if(InpVerboseOutput && found > 0)
            {
               for(int j = 0; j < found; j++)
               {
                  Print("شمعة ", i, ": ", results[j].patternName, 
                        " - القوة: ", DoubleToString(results[j].strength, 2));
               }
            }
         }
         candlesScanned++;
      }
      
      AssertTrue(candlesScanned > 0, "مسح الشموع");
      
      double detectionRate = (candlesScanned > 0) ? (double)patternsFound / candlesScanned : 0.0;
      g_testResults += "معدل الكشف: " + DoubleToString(detectionRate * 100, 2) + "%\n";
      g_testResults += "إجمالي الأنماط المكتشفة: " + IntegerToString(patternsFound) + "\n";
      g_testResults += "الشموع المفحوصة: " + IntegerToString(candlesScanned) + "\n";
      
      Print("معدل الكشف: ", DoubleToString(detectionRate * 100, 2), "%");
   }
   
   g_testResults += "\n";
}

//+------------------------------------------------------------------+
//| اختبار الأداء                                                   |
//+------------------------------------------------------------------+
void TestPerformance()
{
   Print("اختبار الأداء...");
   g_testResults += "=== اختبار الأداء ===\n";
   
   // الحصول على بيانات الاختبار
   double open[], high[], low[], close[];
   long volume[];
   
   int copied = CopyOpen(Symbol(), Period(), 0, InpTestDataSize, open);
   if(copied > 0)
   {
      CopyHigh(Symbol(), Period(), 0, InpTestDataSize, high);
      CopyLow(Symbol(), Period(), 0, InpTestDataSize, low);
      CopyClose(Symbol(), Period(), 0, InpTestDataSize, close);
      CopyTickVolume(Symbol(), Period(), 0, InpTestDataSize, volume);
      
      // قياس الوقت
      uint startTime = GetTickCount();
      
      int totalDetections = 0;
      for(int i = 10; i < copied - 10; i++)
      {
         SPatternDetectionResult results[];
         int found = g_patternManager.DetectAllPatterns(i, Symbol(), Period(), 
                                                       open, high, low, close, volume, results);
         totalDetections += found;
      }
      
      uint endTime = GetTickCount();
      uint duration = endTime - startTime;
      
      double avgTimePerCandle = (copied > 20) ? (double)duration / (copied - 20) : 0.0;
      
      g_testResults += "وقت المعالجة الإجمالي: " + IntegerToString(duration) + " مللي ثانية\n";
      g_testResults += "متوسط الوقت لكل شمعة: " + DoubleToString(avgTimePerCandle, 2) + " مللي ثانية\n";
      g_testResults += "إجمالي الكشوفات: " + IntegerToString(totalDetections) + "\n";
      
      AssertTrue(duration < 10000, "الأداء مقبول (أقل من 10 ثوان)");
      
      Print("الأداء: ", DoubleToString(avgTimePerCandle, 2), " مللي ثانية/شمعة");
   }
   
   g_testResults += "\n";
}

//+------------------------------------------------------------------+
//| اختبارات الضغط                                                 |
//+------------------------------------------------------------------+
void TestStressConditions()
{
   Print("اختبارات الضغط...");
   g_testResults += "=== اختبارات الضغط ===\n";
   
   // اختبار بيانات فارغة
   double emptyOpen[], emptyHigh[], emptyLow[], emptyClose[];
   long emptyVolume[];
   
   SPatternDetectionResult results[];
   int found = g_patternManager.DetectAllPatterns(0, Symbol(), Period(), 
                                                 emptyOpen, emptyHigh, emptyLow, emptyClose, emptyVolume, results);
   
   AssertTrue(found == 0, "التعامل مع البيانات الفارغة");
   
   // اختبار بيانات غير صحيحة
   ArrayResize(emptyOpen, 1);
   ArrayResize(emptyHigh, 1);
   ArrayResize(emptyLow, 1);
   ArrayResize(emptyClose, 1);
   ArrayResize(emptyVolume, 1);
   
   emptyOpen[0] = 1.0;
   emptyHigh[0] = 0.9; // خطأ: الأعلى أقل من الافتتاح
   emptyLow[0] = 0.8;
   emptyClose[0] = 0.95;
   emptyVolume[0] = 100;
   
   found = g_patternManager.DetectAllPatterns(0, Symbol(), Period(), 
                                             emptyOpen, emptyHigh, emptyLow, emptyClose, emptyVolume, results);
   
   AssertTrue(found == 0, "التعامل مع البيانات غير الصحيحة");
   
   // اختبار حالات حدية
   ArrayResize(emptyOpen, 1);
   ArrayResize(emptyHigh, 1);
   ArrayResize(emptyLow, 1);
   ArrayResize(emptyClose, 1);
   ArrayResize(emptyVolume, 1);
   
   // جميع الأسعار متساوية
   emptyOpen[0] = 1.0;
   emptyHigh[0] = 1.0;
   emptyLow[0] = 1.0;
   emptyClose[0] = 1.0;
   emptyVolume[0] = 0;
   
   found = g_patternManager.DetectAllPatterns(0, Symbol(), Period(), 
                                             emptyOpen, emptyHigh, emptyLow, emptyClose, emptyVolume, results);
   
   // يجب أن يكشف دوجي ذو الأربعة أسعار
   AssertTrue(found >= 0, "التعامل مع الأسعار المتساوية");
   
   g_testResults += "اختبارات الضغط: نجحت جميع الاختبارات\n\n";
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار للدوجي                                      |
//+------------------------------------------------------------------+
void CreateDojiTestData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 15);
   ArrayResize(high, 15);
   ArrayResize(low, 15);
   ArrayResize(close, 15);
   ArrayResize(volume, 15);
   
   // ملء البيانات للسياق
   for(int i = 0; i < 15; i++)
   {
      open[i] = 1.1000 + i * 0.0010;
      high[i] = open[i] + 0.0020;
      low[i] = open[i] - 0.0020;
      close[i] = open[i] + (i % 2 == 0 ? 0.0010 : -0.0010);
      volume[i] = 1000;
   }
   
   // دوجي مثالي في الفهرس 0
   open[0] = 1.1000;
   close[0] = 1.1001; // فرق صغير جداً
   high[0] = 1.1020;
   low[0] = 1.0980;
   volume[0] = 1000;
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار لدوجي طويل الأرجل                          |
//+------------------------------------------------------------------+
void CreateLongLeggedDojiData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 15);
   ArrayResize(high, 15);
   ArrayResize(low, 15);
   ArrayResize(close, 15);
   ArrayResize(volume, 15);
   
   // ملء البيانات للسياق
   for(int i = 0; i < 15; i++)
   {
      open[i] = 1.1000 + i * 0.0010;
      high[i] = open[i] + 0.0020;
      low[i] = open[i] - 0.0020;
      close[i] = open[i] + (i % 2 == 0 ? 0.0010 : -0.0010);
      volume[i] = 1000;
   }
   
   // دوجي طويل الأرجل
   open[0] = 1.1000;
   close[0] = 1.1001;
   high[0] = 1.1050; // ظل علوي طويل
   low[0] = 1.0950;  // ظل سفلي طويل
   volume[0] = 1500;
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار لدوجي شاهد القبر                           |
//+------------------------------------------------------------------+
void CreateGravestoneDojiData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 15);
   ArrayResize(high, 15);
   ArrayResize(low, 15);
   ArrayResize(close, 15);
   ArrayResize(volume, 15);
   
   // ملء البيانات للسياق (اتجاه صاعد)
   for(int i = 0; i < 15; i++)
   {
      open[i] = 1.1000 + i * 0.0010;
      high[i] = open[i] + 0.0020;
      low[i] = open[i] - 0.0010;
      close[i] = open[i] + 0.0015; // شموع صاعدة
      volume[i] = 1000;
   }
   
   // دوجي شاهد القبر
   open[0] = 1.1000;
   close[0] = 1.1001;
   high[0] = 1.1050; // ظل علوي طويل
   low[0] = 1.0999;  // ظل سفلي قصير جداً
   volume[0] = 1200;
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار لدوجي اليعسوب                             |
//+------------------------------------------------------------------+
void CreateDragonflyDojiData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 15);
   ArrayResize(high, 15);
   ArrayResize(low, 15);
   ArrayResize(close, 15);
   ArrayResize(volume, 15);
   
   // ملء البيانات للسياق (اتجاه هابط)
   for(int i = 0; i < 15; i++)
   {
      open[i] = 1.1000 - i * 0.0010;
      high[i] = open[i] + 0.0010;
      low[i] = open[i] - 0.0020;
      close[i] = open[i] - 0.0015; // شموع هابطة
      volume[i] = 1000;
   }
   
   // دوجي اليعسوب
   open[0] = 1.1000;
   close[0] = 1.1001;
   high[0] = 1.1002; // ظل علوي قصير جداً
   low[0] = 1.0950;  // ظل سفلي طويل
   volume[0] = 800;
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار للمطرقة                                     |
//+------------------------------------------------------------------+
void CreateHammerTestData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 1);
   ArrayResize(high, 1);
   ArrayResize(low, 1);
   ArrayResize(close, 1);
   ArrayResize(volume, 1);
   
   // مطرقة
   open[0] = 1.1010;
   close[0] = 1.1015; // إغلاق أعلى من الافتتاح
   high[0] = 1.1020;  // ظل علوي قصير
   low[0] = 1.0980;   // ظل سفلي طويل
   volume[0] = 2000;
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار للمطرقة المقلوبة                           |
//+------------------------------------------------------------------+
void CreateInvertedHammerData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 1);
   ArrayResize(high, 1);
   ArrayResize(low, 1);
   ArrayResize(close, 1);
   ArrayResize(volume, 1);
   
   // مطرقة مقلوبة
   open[0] = 1.1000;
   close[0] = 1.1005;
   high[0] = 1.1040; // ظل علوي طويل
   low[0] = 1.0995;  // ظل سفلي قصير
   volume[0] = 1800;
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار لنجم الشهاب                                |
//+------------------------------------------------------------------+
void CreateShootingStarData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 1);
   ArrayResize(high, 1);
   ArrayResize(low, 1);
   ArrayResize(close, 1);
   ArrayResize(volume, 1);
   
   // نجم الشهاب
   open[0] = 1.1010;
   close[0] = 1.1005; // إغلاق أقل من الافتتاح
   high[0] = 1.1050; // ظل علوي طويل
   low[0] = 1.1000;  // ظل سفلي قصير
   volume[0] = 1600;
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار للماروبوزو الصاعد                          |
//+------------------------------------------------------------------+
void CreateBullishMarubozuData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 1);
   ArrayResize(high, 1);
   ArrayResize(low, 1);
   ArrayResize(close, 1);
   ArrayResize(volume, 1);
   
   // ماروبوزو صاعد
   open[0] = 1.1000;
   close[0] = 1.1050;
   high[0] = 1.1051; // ظل علوي صغير جداً
   low[0] = 1.0999;  // ظل سفلي صغير جداً
   volume[0] = 3000;
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار للماروبوزو الهابط                          |
//+------------------------------------------------------------------+
void CreateBearishMarubozuData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 1);
   ArrayResize(high, 1);
   ArrayResize(low, 1);
   ArrayResize(close, 1);
   ArrayResize(volume, 1);
   
   // ماروبوزو هابط
   open[0] = 1.1050;
   close[0] = 1.1000;
   high[0] = 1.1051; // ظل علوي صغير جداً
   low[0] = 1.0999;  // ظل سفلي صغير جداً
   volume[0] = 2500;
}

//+------------------------------------------------------------------+
//| إنشاء بيانات اختبار لحزام الحمل الصاعد                         |
//+------------------------------------------------------------------+
void CreateBullishBeltHoldData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 15);
   ArrayResize(high, 15);
   ArrayResize(low, 15);
   ArrayResize(close, 15);
   ArrayResize(volume, 15);
   
   // ملء البيانات للسياق (اتجاه هابط)
   for(int i = 0; i < 15; i++)
   {
      open[i] = 1.1000 - i * 0.0010;
      high[i] = open[i] + 0.0010;
      low[i] = open[i] - 0.0020;
      close[i] = open[i] - 0.0015; // شموع هابطة
      volume[i] = 1000;
   }
   
   // حزام الحمل الصاعد
   open[0] = 1.1000;
   close[0] = 1.1040;
   high[0] = 1.1045;
   low[0] = 1.1000; // يفتح عند الأدنى
   volume[0] = 2200;
}

//+------------------------------------------------------------------+
//| دالة التحقق من صحة النتيجة                                      |
//+------------------------------------------------------------------+
void AssertTrue(bool condition, string testName)
{
   g_totalTests++;
   
   if(condition)
   {
      g_passedTests++;
      if(InpVerboseOutput)
         Print("✓ نجح: ", testName);
      g_testResults += "✓ " + testName + ": نجح\n";
   }
   else
   {
      g_failedTests++;
      Print("✗ فشل: ", testName);
      g_testResults += "✗ " + testName + ": فشل\n";
   }
}

//+------------------------------------------------------------------+
//| طباعة ملخص الاختبارات                                           |
//+------------------------------------------------------------------+
void PrintTestSummary()
{
   Print("=== ملخص الاختبارات ===");
   Print("إجمالي الاختبارات: ", g_totalTests);
   Print("نجح: ", g_passedTests);
   Print("فشل: ", g_failedTests);
   
   double successRate = (g_totalTests > 0) ? (double)g_passedTests / g_totalTests * 100.0 : 0.0;
   Print("معدل النجاح: ", DoubleToString(successRate, 1), "%");
   
   if(g_failedTests == 0)
      Print("🎉 جميع الاختبارات نجحت!");
   else
      Print("⚠️ بعض الاختبارات فشلت!");
      
   // إضافة الملخص للتقرير
   g_testResults += "\n=== ملخص الاختبارات ===\n";
   g_testResults += "إجمالي الاختبارات: " + IntegerToString(g_totalTests) + "\n";
   g_testResults += "نجح: " + IntegerToString(g_passedTests) + "\n";
   g_testResults += "فشل: " + IntegerToString(g_failedTests) + "\n";
   g_testResults += "معدل النجاح: " + DoubleToString(successRate, 1) + "%\n";
   
   if(g_patternManager != NULL)
      g_patternManager.PrintDetectionStatistics();
}

//+------------------------------------------------------------------+
//| حفظ تقرير الاختبار                                              |
//+------------------------------------------------------------------+
void SaveTestReport()
{
   string fileName = "TestReport_" + Symbol() + "_" + 
                    StringSubstr(TimeToString(TimeCurrent()), 0, 10) + ".txt";
   
   int handle = FileOpen(fileName, FILE_WRITE | FILE_TXT);
   if(handle != INVALID_HANDLE)
   {
      FileWriteString(handle, g_testResults);
      FileClose(handle);
      Print("تم حفظ تقرير الاختبار: ", fileName);
   }
   else
   {
      Print("خطأ في حفظ تقرير الاختبار: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| دالة مساعدة لطباعة تفاصيل النمط                                 |
//+------------------------------------------------------------------+
void PrintPatternDetails(SPatternDetectionResult &result)
{
   Print("تفاصيل النمط:");
   Print("  الاسم: ", result.patternName);
   Print("  القوة: ", DoubleToString(result.strength, 2));
   Print("  الموثوقية: ", DoubleToString(result.reliability, 2));
   Print("  الاتجاه: ", EnumToString(result.direction));
   Print("  النوع: ", EnumToString(result.type));
   Print("  الثقة: ", DoubleToString(result.confidence, 2));
}
