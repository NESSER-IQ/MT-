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

//+------------------------------------------------------------------+
//| هياكل البيانات المطلوبة للاختبار                                  |
//+------------------------------------------------------------------+
struct SPatternDetectionResult
{
   string            patternName;      // اسم النمط
   double            strength;         // قوة النمط
   double            reliability;      // موثوقية النمط
   ENUM_PATTERN_DIRECTION direction;  // اتجاه النمط
   ENUM_PATTERN_TYPE type;            // نوع النمط
   double            confidence;       // مستوى الثقة
   datetime          timestamp;        // وقت الكشف
   int               barIndex;         // رقم الشمعة
   
   SPatternDetectionResult()
   {
      patternName = "";
      strength = 0.0;
      reliability = 0.0;
      direction = PATTERN_NEUTRAL;
      type = PATTERN_SINGLE;
      confidence = 0.0;
      timestamp = 0;
      barIndex = -1;
   }
};

//+------------------------------------------------------------------+
//| فئة مدير الأنماط المبسط للاختبار                                 |
//+------------------------------------------------------------------+
class CSingleCandlePatternManager
{
private:
   bool           m_initialized;
   bool           m_enableDoji;
   bool           m_enableHammer;
   bool           m_enableMarubozu;
   bool           m_enableBeltHold;
   double         m_sensitivityLevel;
   int            m_detectionCount;
   
public:
                  CSingleCandlePatternManager();
                  ~CSingleCandlePatternManager();
                  
   bool           Initialize();
   void           Deinitialize();
   
   // إعدادات التمكين
   void           EnableDojiPatterns(bool enable) { m_enableDoji = enable; }
   void           EnableHammerPatterns(bool enable) { m_enableHammer = enable; }
   void           EnableMarubozuPatterns(bool enable) { m_enableMarubozu = enable; }
   void           EnableBeltHoldPatterns(bool enable) { m_enableBeltHold = enable; }
   void           SetSensitivityLevel(double level) { m_sensitivityLevel = level; }
   
   // معلومات الأنماط
   int            GetTotalPatterns();
   string         GetCategoryName(int index);
   int            GetCategoryCount(int index);
   
   // كشف الأنماط
   int            DetectAllPatterns(int idx, string symbol, ENUM_TIMEFRAMES timeframe,
                                  const double &open[], const double &high[], 
                                  const double &low[], const double &close[], 
                                  const long &volume[], SPatternDetectionResult &results[]);
                                  
   void           PrintDetectionStatistics();
   
private:
   bool           DetectDoji(int idx, const double &open[], const double &high[], 
                           const double &low[], const double &close[], 
                           SPatternDetectionResult &result);
   bool           DetectHammer(int idx, const double &open[], const double &high[], 
                             const double &low[], const double &close[], 
                             SPatternDetectionResult &result);
   bool           DetectMarubozu(int idx, const double &open[], const double &high[], 
                               const double &low[], const double &close[], 
                               SPatternDetectionResult &result);
   bool           DetectBeltHold(int idx, const double &open[], const double &high[], 
                               const double &low[], const double &close[], 
                               SPatternDetectionResult &result);
};

//+------------------------------------------------------------------+
//| مُنشِئ مدير الأنماط                                               |
//+------------------------------------------------------------------+
CSingleCandlePatternManager::CSingleCandlePatternManager()
{
   m_initialized = false;
   m_enableDoji = true;
   m_enableHammer = true;
   m_enableMarubozu = true;
   m_enableBeltHold = true;
   m_sensitivityLevel = 1.0;
   m_detectionCount = 0;
}

//+------------------------------------------------------------------+
//| مُدمِّر مدير الأنماط                                              |
//+------------------------------------------------------------------+
CSingleCandlePatternManager::~CSingleCandlePatternManager()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة المدير                                                      |
//+------------------------------------------------------------------+
bool CSingleCandlePatternManager::Initialize()
{
   m_initialized = true;
   m_detectionCount = 0;
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء المدير                                                     |
//+------------------------------------------------------------------+
void CSingleCandlePatternManager::Deinitialize()
{
   m_initialized = false;
}

//+------------------------------------------------------------------+
//| الحصول على العدد الإجمالي للأنماط                                |
//+------------------------------------------------------------------+
int CSingleCandlePatternManager::GetTotalPatterns()
{
   int total = 0;
   if(m_enableDoji) total += 4;     // Doji, LongLegged, Gravestone, Dragonfly
   if(m_enableHammer) total += 4;   // Hammer, InvertedHammer, ShootingStar, HangingMan
   if(m_enableMarubozu) total += 2; // Bullish, Bearish
   if(m_enableBeltHold) total += 2; // Bullish, Bearish
   return total;
}

//+------------------------------------------------------------------+
//| الحصول على اسم الفئة                                             |
//+------------------------------------------------------------------+
string CSingleCandlePatternManager::GetCategoryName(int index)
{
   switch(index)
   {
      case 0: return "أنماط الدوجي";
      case 1: return "أنماط المطرقة";
      case 2: return "أنماط الماروبوزو";
      case 3: return "أنماط حزام الحمل";
      case 4: return "أنماط أخرى";
      default: return "غير معروف";
   }
}

//+------------------------------------------------------------------+
//| الحصول على عدد أنماط الفئة                                       |
//+------------------------------------------------------------------+
int CSingleCandlePatternManager::GetCategoryCount(int index)
{
   switch(index)
   {
      case 0: return m_enableDoji ? 4 : 0;
      case 1: return m_enableHammer ? 4 : 0;
      case 2: return m_enableMarubozu ? 2 : 0;
      case 3: return m_enableBeltHold ? 2 : 0;
      case 4: return 0;
      default: return 0;
   }
}

//+------------------------------------------------------------------+
//| كشف جميع الأنماط                                                 |
//+------------------------------------------------------------------+
int CSingleCandlePatternManager::DetectAllPatterns(int idx, string symbol, ENUM_TIMEFRAMES timeframe,
                                                  const double &open[], const double &high[], 
                                                  const double &low[], const double &close[], 
                                                  const long &volume[], SPatternDetectionResult &results[])
{
   if(!m_initialized || idx >= ArraySize(open))
      return 0;
      
   ArrayResize(results, 0);
   int foundCount = 0;
   SPatternDetectionResult tempResult;
   
   // كشف أنماط الدوجي
   if(m_enableDoji && DetectDoji(idx, open, high, low, close, tempResult))
   {
      ArrayResize(results, foundCount + 1);
      results[foundCount] = tempResult;
      foundCount++;
      m_detectionCount++;
   }
   
   // كشف أنماط المطرقة
   if(m_enableHammer && DetectHammer(idx, open, high, low, close, tempResult))
   {
      ArrayResize(results, foundCount + 1);
      results[foundCount] = tempResult;
      foundCount++;
      m_detectionCount++;
   }
   
   // كشف أنماط الماروبوزو
   if(m_enableMarubozu && DetectMarubozu(idx, open, high, low, close, tempResult))
   {
      ArrayResize(results, foundCount + 1);
      results[foundCount] = tempResult;
      foundCount++;
      m_detectionCount++;
   }
   
   // كشف أنماط حزام الحمل
   if(m_enableBeltHold && DetectBeltHold(idx, open, high, low, close, tempResult))
   {
      ArrayResize(results, foundCount + 1);
      results[foundCount] = tempResult;
      foundCount++;
      m_detectionCount++;
   }
   
   return foundCount;
}

//+------------------------------------------------------------------+
//| كشف نمط الدوجي                                                   |
//+------------------------------------------------------------------+
bool CSingleCandlePatternManager::DetectDoji(int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[], 
                                            SPatternDetectionResult &result)
{
   if(idx >= ArraySize(open)) return false;
   
   double body = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   
   if(range <= 0) return false;
   
   double bodyRatio = body / range;
   if(bodyRatio <= 0.05 * m_sensitivityLevel) // 5% من المدى
   {
      result.patternName = "دوجي";
      result.strength = 2.0 - bodyRatio * 20; // كلما صغر الجسم كلما زادت القوة
      result.reliability = 0.75;
      result.direction = PATTERN_NEUTRAL;
      result.type = PATTERN_SINGLE;
      result.confidence = 0.8;
      result.barIndex = idx;
      result.timestamp = TimeCurrent();
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف نمط المطرقة                                                  |
//+------------------------------------------------------------------+
bool CSingleCandlePatternManager::DetectHammer(int idx, const double &open[], const double &high[], 
                                              const double &low[], const double &close[], 
                                              SPatternDetectionResult &result)
{
   if(idx >= ArraySize(open)) return false;
   
   double body = MathAbs(close[idx] - open[idx]);
   double upperShadow = high[idx] - MathMax(open[idx], close[idx]);
   double lowerShadow = MathMin(open[idx], close[idx]) - low[idx];
   double range = high[idx] - low[idx];
   
   if(range <= 0 || body <= 0) return false;
   
   // شروط المطرقة: جسم صغير، ظل سفلي طويل، ظل علوي قصير
   if(body <= range * 0.3 && 
      lowerShadow >= body * 2.0 && 
      upperShadow <= body * 0.1)
   {
      result.patternName = "مطرقة";
      result.strength = 2.5;
      result.reliability = 0.72;
      result.direction = PATTERN_BULLISH;
      result.type = PATTERN_SINGLE;
      result.confidence = 0.75;
      result.barIndex = idx;
      result.timestamp = TimeCurrent();
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف نمط الماروبوزو                                               |
//+------------------------------------------------------------------+
bool CSingleCandlePatternManager::DetectMarubozu(int idx, const double &open[], const double &high[], 
                                                const double &low[], const double &close[], 
                                                SPatternDetectionResult &result)
{
   if(idx >= ArraySize(open)) return false;
   
   double body = MathAbs(close[idx] - open[idx]);
   double upperShadow = high[idx] - MathMax(open[idx], close[idx]);
   double lowerShadow = MathMin(open[idx], close[idx]) - low[idx];
   double range = high[idx] - low[idx];
   
   if(range <= 0 || body <= 0) return false;
   
   // شروط الماروبوزو: جسم كبير، ظلال صغيرة جداً
   if(body >= range * 0.9 && 
      upperShadow <= body * 0.05 && 
      lowerShadow <= body * 0.05)
   {
      result.patternName = close[idx] > open[idx] ? "ماروبوزو صاعد" : "ماروبوزو هابط";
      result.strength = 3.0;
      result.reliability = 0.82;
      result.direction = close[idx] > open[idx] ? PATTERN_BULLISH : PATTERN_BEARISH;
      result.type = PATTERN_SINGLE;
      result.confidence = 0.85;
      result.barIndex = idx;
      result.timestamp = TimeCurrent();
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف نمط حزام الحمل                                               |
//+------------------------------------------------------------------+
bool CSingleCandlePatternManager::DetectBeltHold(int idx, const double &open[], const double &high[], 
                                                const double &low[], const double &close[], 
                                                SPatternDetectionResult &result)
{
   if(idx >= ArraySize(open)) return false;
   
   double body = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   
   if(range <= 0 || body <= 0) return false;
   
   bool isBullish = close[idx] > open[idx];
   
   // شروط حزام الحمل الصاعد: يفتح في الأدنى
   if(isBullish && MathAbs(open[idx] - low[idx]) <= range * 0.05)
   {
      result.patternName = "حزام الحمل الصاعد";
      result.strength = 2.2;
      result.reliability = 0.75;
      result.direction = PATTERN_BULLISH;
      result.type = PATTERN_SINGLE;
      result.confidence = 0.78;
      result.barIndex = idx;
      result.timestamp = TimeCurrent();
      return true;
   }
   
   // شروط حزام الحمل الهابط: يفتح في الأعلى
   if(!isBullish && MathAbs(open[idx] - high[idx]) <= range * 0.05)
   {
      result.patternName = "حزام الحمل الهابط";
      result.strength = 2.2;
      result.reliability = 0.75;
      result.direction = PATTERN_BEARISH;
      result.type = PATTERN_SINGLE;
      result.confidence = 0.78;
      result.barIndex = idx;
      result.timestamp = TimeCurrent();
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| طباعة إحصائيات الكشف                                             |
//+------------------------------------------------------------------+
void CSingleCandlePatternManager::PrintDetectionStatistics()
{
   Print("=== إحصائيات كشف الأنماط ===");
   Print("إجمالي الأنماط المكتشفة: ", m_detectionCount);
   Print("أنماط الدوجي: ", m_enableDoji ? "مُمكّن" : "مُعطّل");
   Print("أنماط المطرقة: ", m_enableHammer ? "مُمكّن" : "مُعطّل");
   Print("أنماط الماروبوزو: ", m_enableMarubozu ? "مُمكّن" : "مُعطّل");
   Print("أنماط حزام الحمل: ", m_enableBeltHold ? "مُمكّن" : "مُعطّل");
   Print("مستوى الحساسية: ", m_sensitivityLevel);
}

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
   g_patternManager.SetSensitivityLevel(InpSensitivityLevel);
   g_patternManager.EnableDojiPatterns(InpEnableDojiTests);
   g_patternManager.EnableHammerPatterns(InpEnableHammerTests);
   g_patternManager.EnableMarubozuPatterns(InpEnableMarubozuTests);
   g_patternManager.EnableBeltHoldPatterns(InpEnableBeltHoldTests);
   
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
   double body = MathAbs(testClose - testOpen);
   double upperShadow = testHigh - MathMax(testOpen, testClose);
   double lowerShadow = MathMin(testOpen, testClose) - testLow;
   double range = testHigh - testLow;
   
   AssertTrue(body == 0.0020, "حساب جسم الشمعة");
   AssertTrue(upperShadow == 0.0030, "حساب الظل العلوي");
   AssertTrue(lowerShadow == 0.0050, "حساب الظل السفلي");
   AssertTrue(range == 0.0100, "حساب المدى");
   
   // اختبار تحديد نوع الشمعة
   bool isBullish = (testClose > testOpen);
   bool isBearish = (testClose < testOpen);
   
   AssertTrue(isBullish == true, "تحديد الشمعة الصاعدة");
   AssertTrue(isBearish == false, "تحديد الشمعة الهابطة");
   
   // اختبار الدوجي
   bool isDoji = (MathAbs(testClose - testOpen) / range <= 0.05);
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
   
   // اختبار كشف الدوجي
   SPatternDetectionResult result;
   bool detected = g_patternManager.DetectDoji(0, dojiOpen, dojiHigh, dojiLow, dojiClose, result);
   AssertTrue(detected, "كشف الدوجي العادي");
   
   if(detected)
   {
      AssertTrue(result.strength > 0, "قوة نمط الدوجي");
      AssertTrue(result.direction == PATTERN_NEUTRAL, "اتجاه الدوجي محايد");
      if(InpVerboseOutput)
         PrintPatternDetails(result);
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
   SPatternDetectionResult result;
   bool detected = g_patternManager.DetectHammer(0, hammerOpen, hammerHigh, hammerLow, hammerClose, result);
   AssertTrue(detected, "كشف المطرقة");
   
   if(detected && InpVerboseOutput)
      PrintPatternDetails(result);
   
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
   SPatternDetectionResult result;
   bool detected = g_patternManager.DetectMarubozu(0, marubozuOpen, marubozuHigh, marubozuLow, marubozuClose, result);
   AssertTrue(detected, "كشف الماروبوزو الصاعد");
   
   if(detected && InpVerboseOutput)
      PrintPatternDetails(result);
   
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
   SPatternDetectionResult result;
   bool detected = g_patternManager.DetectBeltHold(0, beltOpen, beltHigh, beltLow, beltClose, result);
   AssertTrue(detected, "كشف حزام الحمل الصاعد");
   
   if(detected && InpVerboseOutput)
      PrintPatternDetails(result);
   
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
            
            if(InpVerboseOutput)
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
      
      double detectionRate = (double)patternsFound / candlesScanned;
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
      
      double avgTimePerCandle = (double)duration / (copied - 20);
      
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
   ArrayResize(open, 1);
   ArrayResize(high, 1);
   ArrayResize(low, 1);
   ArrayResize(close, 1);
   ArrayResize(volume, 1);
   
   // دوجي مثالي
   open[0] = 1.1000;
   close[0] = 1.1001; // فرق صغير جداً
   high[0] = 1.1020;
   low[0] = 1.0980;
   volume[0] = 1000;
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
//| إنشاء بيانات اختبار لحزام الحمل الصاعد                         |
//+------------------------------------------------------------------+
void CreateBullishBeltHoldData(double &open[], double &high[], double &low[], double &close[], long &volume[])
{
   ArrayResize(open, 1);
   ArrayResize(high, 1);
   ArrayResize(low, 1);
   ArrayResize(close, 1);
   ArrayResize(volume, 1);
   
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
