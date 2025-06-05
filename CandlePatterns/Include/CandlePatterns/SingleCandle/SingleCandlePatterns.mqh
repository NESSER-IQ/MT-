//+------------------------------------------------------------------+
//|                                        SingleCandlePatterns.mqh |
//|                                  مدير أنماط الشموع المفردة |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\Base\PatternDetector.mqh"
#include "DojiPatterns.mqh"
#include "HammerPatterns.mqh"
#include "MarubozuPatterns.mqh"
#include "BeltHoldPatterns.mqh"

//+------------------------------------------------------------------+
//| مدير أنماط الشموع المفردة                                       |
//+------------------------------------------------------------------+
class CSingleCandlePatternManager : public CPatternDetector
{
private:
   // مصفوفات الأنماط
   CDojiPattern*             m_dojiPattern;
   CLongLeggedDojiPattern*   m_longDojiPattern;
   CGravestoneDojiPattern*   m_gravestonePattern;
   CDragonflyDojiPattern*    m_dragonflyPattern;
   CFourPriceDojiPattern*    m_fourPricePattern;
   
   // إعدادات التمكين
   bool                      m_enableDoji;
   bool                      m_enableHammer;
   bool                      m_enableMarubozu;
   bool                      m_enableBeltHold;
   
   // إحصائيات
   int                       m_totalDetections;
   int                       m_successfulDetections;
   
public:
   // المنشئ والهادم
                            CSingleCandlePatternManager();
                            ~CSingleCandlePatternManager();
   
   // تهيئة وإنهاء
   bool                     Initialize();
   void                     Deinitialize();
   
   // إعدادات التمكين
   void                     EnableDojiPatterns(bool enable) { m_enableDoji = enable; }
   void                     EnableHammerPatterns(bool enable) { m_enableHammer = enable; }
   void                     EnableMarubozuPatterns(bool enable) { m_enableMarubozu = enable; }
   void                     EnableBeltHoldPatterns(bool enable) { m_enableBeltHold = enable; }
   
   // الحصول على المعلومات
   int                      GetTotalPatterns();
   string                   GetCategoryName(int categoryIndex);
   int                      GetCategoryCount(int categoryIndex);
   
   // الكشف عن الأنماط
   virtual int              DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                            const double &open[], const double &high[], const double &low[], 
                                            const double &close[], const long &volume[], 
                                            SPatternDetectionResult &results[]);
   
   // إحصائيات
   void                     PrintDetectionStatistics();
   
private:
   // دوال مساعدة
   void                     CreatePatterns();
   void                     DestroyPatterns();
   bool                     DetectDojiPatterns(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], const long &volume[],
                                             SPatternDetectionResult &results[], int &count);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CSingleCandlePatternManager::CSingleCandlePatternManager()
{
   // تهيئة الأنماط
   m_dojiPattern = NULL;
   m_longDojiPattern = NULL;
   m_gravestonePattern = NULL;
   m_dragonflyPattern = NULL;
   m_fourPricePattern = NULL;
   
   // تمكين جميع الأنماط افتراضياً
   m_enableDoji = true;
   m_enableHammer = true;
   m_enableMarubozu = true;
   m_enableBeltHold = true;
   
   // إحصائيات
   m_totalDetections = 0;
   m_successfulDetections = 0;
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CSingleCandlePatternManager::~CSingleCandlePatternManager()
{
   DestroyPatterns();
}

//+------------------------------------------------------------------+
//| تهيئة المدير                                                     |
//+------------------------------------------------------------------+
bool CSingleCandlePatternManager::Initialize()
{
   // استدعاء تهيئة الفئة الأساسية
   if(!CPatternDetector::Initialize())
      return false;
   
   // إنشاء الأنماط
   CreatePatterns();
   
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء المدير                                                    |
//+------------------------------------------------------------------+
void CSingleCandlePatternManager::Deinitialize()
{
   DestroyPatterns();
   CPatternDetector::Deinitialize();
}

//+------------------------------------------------------------------+
//| إنشاء الأنماط                                                   |
//+------------------------------------------------------------------+
void CSingleCandlePatternManager::CreatePatterns()
{
   // إنشاء أنماط الدوجي
   if(m_enableDoji)
   {
      m_dojiPattern = new CDojiPattern();
      m_longDojiPattern = new CLongLeggedDojiPattern();
      m_gravestonePattern = new CGravestoneDojiPattern();
      m_dragonflyPattern = new CDragonflyDojiPattern();
      m_fourPricePattern = new CFourPriceDojiPattern();
   }
}

//+------------------------------------------------------------------+
//| تدمير الأنماط                                                   |
//+------------------------------------------------------------------+
void CSingleCandlePatternManager::DestroyPatterns()
{
   // تدمير أنماط الدوجي
   if(m_dojiPattern != NULL)
   {
      delete m_dojiPattern;
      m_dojiPattern = NULL;
   }
   
   if(m_longDojiPattern != NULL)
   {
      delete m_longDojiPattern;
      m_longDojiPattern = NULL;
   }
   
   if(m_gravestonePattern != NULL)
   {
      delete m_gravestonePattern;
      m_gravestonePattern = NULL;
   }
   
   if(m_dragonflyPattern != NULL)
   {
      delete m_dragonflyPattern;
      m_dragonflyPattern = NULL;
   }
   
   if(m_fourPricePattern != NULL)
   {
      delete m_fourPricePattern;
      m_fourPricePattern = NULL;
   }
}

//+------------------------------------------------------------------+
//| الحصول على العدد الإجمالي للأنماط                               |
//+------------------------------------------------------------------+
int CSingleCandlePatternManager::GetTotalPatterns()
{
   int total = 0;
   
   if(m_enableDoji) total += 5; // أنماط الدوجي
   if(m_enableHammer) total += 4; // أنماط المطرقة
   if(m_enableMarubozu) total += 2; // أنماط الماروبوزو
   if(m_enableBeltHold) total += 2; // أنماط حزام الحمل
   
   return total;
}

//+------------------------------------------------------------------+
//| الحصول على اسم الفئة                                            |
//+------------------------------------------------------------------+
string CSingleCandlePatternManager::GetCategoryName(int categoryIndex)
{
   switch(categoryIndex)
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
//| الحصول على عدد أنماط الفئة                                      |
//+------------------------------------------------------------------+
int CSingleCandlePatternManager::GetCategoryCount(int categoryIndex)
{
   switch(categoryIndex)
   {
      case 0: return m_enableDoji ? 5 : 0;
      case 1: return m_enableHammer ? 4 : 0;
      case 2: return m_enableMarubozu ? 2 : 0;
      case 3: return m_enableBeltHold ? 2 : 0;
      case 4: return 0;
      default: return 0;
   }
}

//+------------------------------------------------------------------+
//| الكشف عن جميع الأنماط                                           |
//+------------------------------------------------------------------+
int CSingleCandlePatternManager::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                  const double &open[], const double &high[], const double &low[], 
                                                  const double &close[], const long &volume[], 
                                                  SPatternDetectionResult &results[])
{
   // التحقق من صحة البيانات
   if(!ValidateData(open, high, low, close, volume, idx))
      return 0;
   
   m_totalDetections++;
   
   // مصفوفة مؤقتة للنتائج
   SPatternDetectionResult tempResults[];
   ArrayResize(tempResults, 20); // حجم أولي
   
   int totalFound = 0;
   
   // البحث عن أنماط الدوجي
   if(m_enableDoji)
   {
      int dojiCount = 0;
      if(DetectDojiPatterns(idx, open, high, low, close, volume, tempResults, dojiCount))
      {
         totalFound += dojiCount;
      }
   }
   
   // نسخ النتائج النهائية
   if(totalFound > 0)
   {
      ArrayResize(results, totalFound);
      for(int i = 0; i < totalFound; i++)
      {
         results[i] = tempResults[i];
         results[i].barIndex = idx;
         results[i].time = iTime(symbol, timeframe, idx);
      }
      m_successfulDetections++;
   }
   else
   {
      ArrayResize(results, 0);
   }
   
   return totalFound;
}

//+------------------------------------------------------------------+
//| الكشف عن أنماط الدوجي                                           |
//+------------------------------------------------------------------+
bool CSingleCandlePatternManager::DetectDojiPatterns(const int idx, const double &open[], const double &high[], 
                                                    const double &low[], const double &close[], const long &volume[],
                                                    SPatternDetectionResult &results[], int &count)
{
   count = 0;
   
   // الدوجي العادي
   if(m_dojiPattern != NULL && m_dojiPattern.Detect(idx, open, high, low, close, volume))
   {
      results[count].patternName = m_dojiPattern.Name();
      results[count].strength = m_dojiPattern.PatternStrength(idx, open, high, low, close, volume);
      results[count].reliability = m_dojiPattern.Reliability();
      results[count].direction = m_dojiPattern.Direction();
      results[count].type = m_dojiPattern.Type();
      results[count].confidence = results[count].strength / 3.0;
      count++;
   }
   
   // دوجي طويل الأرجل
   if(m_longDojiPattern != NULL && m_longDojiPattern.Detect(idx, open, high, low, close, volume))
   {
      results[count].patternName = m_longDojiPattern.Name();
      results[count].strength = m_longDojiPattern.PatternStrength(idx, open, high, low, close, volume);
      results[count].reliability = m_longDojiPattern.Reliability();
      results[count].direction = m_longDojiPattern.Direction();
      results[count].type = m_longDojiPattern.Type();
      results[count].confidence = results[count].strength / 3.0;
      count++;
   }
   
   // دوجي شاهد القبر
   if(m_gravestonePattern != NULL && m_gravestonePattern.Detect(idx, open, high, low, close, volume))
   {
      results[count].patternName = m_gravestonePattern.Name();
      results[count].strength = m_gravestonePattern.PatternStrength(idx, open, high, low, close, volume);
      results[count].reliability = m_gravestonePattern.Reliability();
      results[count].direction = m_gravestonePattern.Direction();
      results[count].type = m_gravestonePattern.Type();
      results[count].confidence = results[count].strength / 3.0;
      count++;
   }
   
   // دوجي اليعسوب
   if(m_dragonflyPattern != NULL && m_dragonflyPattern.Detect(idx, open, high, low, close, volume))
   {
      results[count].patternName = m_dragonflyPattern.Name();
      results[count].strength = m_dragonflyPattern.PatternStrength(idx, open, high, low, close, volume);
      results[count].reliability = m_dragonflyPattern.Reliability();
      results[count].direction = m_dragonflyPattern.Direction();
      results[count].type = m_dragonflyPattern.Type();
      results[count].confidence = results[count].strength / 3.0;
      count++;
   }
   
   // دوجي الأربعة أسعار
   if(m_fourPricePattern != NULL && m_fourPricePattern.Detect(idx, open, high, low, close, volume))
   {
      results[count].patternName = m_fourPricePattern.Name();
      results[count].strength = m_fourPricePattern.PatternStrength(idx, open, high, low, close, volume);
      results[count].reliability = m_fourPricePattern.Reliability();
      results[count].direction = m_fourPricePattern.Direction();
      results[count].type = m_fourPricePattern.Type();
      results[count].confidence = results[count].strength / 3.0;
      count++;
   }
   
   return count > 0;
}

//+------------------------------------------------------------------+
//| طباعة الإحصائيات                                                |
//+------------------------------------------------------------------+
void CSingleCandlePatternManager::PrintDetectionStatistics()
{
   Print("=== إحصائيات الكشف عن الأنماط ===");
   Print("إجمالي المحاولات: ", m_totalDetections);
   Print("المحاولات الناجحة: ", m_successfulDetections);
   
   double successRate = (m_totalDetections > 0) ? (double)m_successfulDetections / m_totalDetections * 100.0 : 0.0;
   Print("معدل النجاح: ", DoubleToString(successRate, 1), "%");
   
   Print("الأنماط المفعلة:");
   Print("- أنماط الدوجي: ", m_enableDoji ? "مفعل" : "معطل");
   Print("- أنماط المطرقة: ", m_enableHammer ? "مفعل" : "معطل");
   Print("- أنماط الماروبوزو: ", m_enableMarubozu ? "مفعل" : "معطل");
   Print("- أنماط حزام الحمل: ", m_enableBeltHold ? "مفعل" : "معطل");
}

//+------------------------------------------------------------------+
//| فئات مساعدة للفئات المفقودة                                     |
//+------------------------------------------------------------------+

// فئة الدوجي الأساسية (مبسطة للاختبار)
typedef CDojiPattern CDoji;
typedef CLongLeggedDojiPattern CLongLeggedDoji;
typedef CGravestoneDojiPattern CGravestoneDoji;
typedef CDragonflyDojiPattern CDragonflyDoji;

// فئات المطرقة (سيتم إضافتها لاحقاً)
class CHammer : public CCandlePattern
{
public:
   CHammer() 
   { 
      m_name = "المطرقة"; 
      m_direction = PATTERN_BULLISH;
      m_type = PATTERN_SINGLE;
   }
   
   virtual bool Detect(const int idx, const double &open[], const double &high[], 
                      const double &low[], const double &close[], const long &volume[])
   {
      // تنفيذ مبسط للاختبار
      if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
         return false;
         
      double body = CCandleUtils::CandleBody(open[idx], close[idx]);
      double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
      double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
      
      return (lowerShadow >= 2 * body && upperShadow <= 0.1 * body);
   }
};

class CInvertedHammer : public CCandlePattern
{
public:
   CInvertedHammer() 
   { 
      m_name = "المطرقة المقلوبة"; 
      m_direction = PATTERN_BULLISH;
      m_type = PATTERN_SINGLE;
   }
   
   virtual bool Detect(const int idx, const double &open[], const double &high[], 
                      const double &low[], const double &close[], const long &volume[])
   {
      if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
         return false;
         
      double body = CCandleUtils::CandleBody(open[idx], close[idx]);
      double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
      double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
      
      return (upperShadow >= 2 * body && lowerShadow <= 0.1 * body);
   }
};

class CShootingStar : public CCandlePattern
{
public:
   CShootingStar() 
   { 
      m_name = "نجم الشهاب"; 
      m_direction = PATTERN_BEARISH;
      m_type = PATTERN_SINGLE;
   }
   
   virtual bool Detect(const int idx, const double &open[], const double &high[], 
                      const double &low[], const double &close[], const long &volume[])
   {
      if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
         return false;
         
      double body = CCandleUtils::CandleBody(open[idx], close[idx]);
      double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
      double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
      
      return (upperShadow >= 2 * body && lowerShadow <= 0.1 * body);
   }
};

// فئات الماروبوزو
class CBullishMarubozu : public CCandlePattern
{
public:
   CBullishMarubozu() 
   { 
      m_name = "الماروبوزو الصاعد"; 
      m_direction = PATTERN_BULLISH;
      m_type = PATTERN_SINGLE;
   }
   
   virtual bool Detect(const int idx, const double &open[], const double &high[], 
                      const double &low[], const double &close[], const long &volume[])
   {
      if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
         return false;
         
      if(!CCandleUtils::IsBullish(open[idx], close[idx]))
         return false;
         
      double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
      double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
      double body = CCandleUtils::CandleBody(open[idx], close[idx]);
      
      return (upperShadow <= 0.05 * body && lowerShadow <= 0.05 * body);
   }
};

class CBearishMarubozu : public CCandlePattern
{
public:
   CBearishMarubozu() 
   { 
      m_name = "الماروبوزو الهابط"; 
      m_direction = PATTERN_BEARISH;
      m_type = PATTERN_SINGLE;
   }
   
   virtual bool Detect(const int idx, const double &open[], const double &high[], 
                      const double &low[], const double &close[], const long &volume[])
   {
      if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
         return false;
         
      if(!CCandleUtils::IsBearish(open[idx], close[idx]))
         return false;
         
      double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
      double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
      double body = CCandleUtils::CandleBody(open[idx], close[idx]);
      
      return (upperShadow <= 0.05 * body && lowerShadow <= 0.05 * body);
   }
};

// فئة حزام الحمل
class CBullishBeltHold : public CCandlePattern
{
public:
   CBullishBeltHold() 
   { 
      m_name = "حزام الحمل الصاعد"; 
      m_direction = PATTERN_BULLISH;
      m_type = PATTERN_SINGLE;
   }
   
   virtual bool Detect(const int idx, const double &open[], const double &high[], 
                      const double &low[], const double &close[], const long &volume[])
   {
      if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
         return false;
         
      if(!CCandleUtils::IsBullish(open[idx], close[idx]))
         return false;
         
      double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
      double range = CCandleUtils::CandleRange(high[idx], low[idx]);
      
      return (lowerShadow <= 0.05 * range);
   }
};
