//+------------------------------------------------------------------+
//|                                        TripleCandlePatterns.mqh |
//|                                    مكتبة أنماط الثلاث شموع اليابانية |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

// تضمين الملفات الأساسية
#include "..\\Base\\PatternDetector.mqh"

// تضمين الأنماط الأساسية (Essential)
#include "Essential\\StarPatterns.mqh"
#include "Essential\\SoldierCrowPatterns.mqh"
#include "Essential\\InsideOutsidePatterns.mqh"
#include "Essential\\ThreeMethodsPatterns.mqh"
#include "Essential\\TripleLinePatterns.mqh"

// تضمين الأنماط المتقدمة (Advanced)
#include "Advanced\\BreakawayPatterns.mqh"
#include "Advanced\\ConcealingPatterns.mqh"
#include "Advanced\\AdvanceBlockPatterns.mqh"
#include "Advanced\\CorrectionPatterns.mqh"
#include "Advanced\\IdentityPatterns.mqh"

// تضمين الأنماط المتخصصة (Specialized)
#include "Specialized\\GappingPatterns.mqh"
#include "Specialized\\DeliberationPatterns.mqh"
#include "Specialized\\UniquePatterns.mqh"

// تضمين الأنماط اليابانية (Japanese)
#include "Japanese\\TraditionalPatterns.mqh"
#include "Japanese\\ModernAdaptations.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الثلاث شموع الموحدة                                   |
//+------------------------------------------------------------------+
class CTripleCandlePatterns : public CPatternDetector
{
private:
   // كاشفات الأنماط الأساسية
   CStarPatterns*            m_starPatterns;
   CSoldierCrowPatterns*     m_soldierCrowPatterns;
   CInsideOutsidePatterns*   m_insideOutsidePatterns;
   CThreeMethodsPatterns*    m_threeMethodsPatterns;
   CTripleLinePatterns*      m_tripleLinePatterns;
   
   // كاشفات الأنماط المتقدمة
   CBreakawayPatterns*       m_breakawayPatterns;
   CConcealingPatterns*      m_concealingPatterns;
   CAdvanceBlockPatterns*    m_advanceBlockPatterns;
   CCorrectionPatterns*      m_correctionPatterns;
   CIdentityPatterns*        m_identityPatterns;
   
   // كاشفات الأنماط المتخصصة
   CGappingPatterns*         m_gappingPatterns;
   CDeliberationPatterns*    m_deliberationPatterns;
   CUniquePatterns*          m_uniquePatterns;
   
   // كاشفات الأنماط اليابانية
   CTraditionalPatterns*     m_traditionalPatterns;
   CModernAdaptations*       m_modernAdaptations;
   
   // إعدادات الكشف
   bool                      m_enableEssentialPatterns;
   bool                      m_enableAdvancedPatterns;
   bool                      m_enableSpecializedPatterns;
   bool                      m_enableJapanesePatterns;
   
public:
   // المنشئ والهادم
                     CTripleCandlePatterns();
                     ~CTripleCandlePatterns();
   
   // تهيئة وإنهاء
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   
   // إعدادات تمكين الأنماط
   void              EnableEssentialPatterns(bool enable = true) { m_enableEssentialPatterns = enable; }
   void              EnableAdvancedPatterns(bool enable = true) { m_enableAdvancedPatterns = enable; }
   void              EnableSpecializedPatterns(bool enable = true) { m_enableSpecializedPatterns = enable; }
   void              EnableJapanesePatterns(bool enable = true) { m_enableJapanesePatterns = enable; }
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // كشف أنماط محددة
   int               DetectEssentialPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                           const double &open[], const double &high[], const double &low[], 
                                           const double &close[], const long &volume[], 
                                           SPatternDetectionResult &results[]);
                                           
   int               DetectAdvancedPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                          const double &open[], const double &high[], const double &low[], 
                                          const double &close[], const long &volume[], 
                                          SPatternDetectionResult &results[]);
                                          
   int               DetectSpecializedPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                             const double &open[], const double &high[], const double &low[], 
                                             const double &close[], const long &volume[], 
                                             SPatternDetectionResult &results[]);
                                             
   int               DetectJapanesePatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                          const double &open[], const double &high[], const double &low[], 
                                          const double &close[], const long &volume[], 
                                          SPatternDetectionResult &results[]);
                                          
   // دوال مساعدة
   int               GetTotalPatternsCount();
   string            GetPatternGroupInfo(int groupIndex);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CTripleCandlePatterns::CTripleCandlePatterns()
{
   // تهيئة المؤشرات
   m_starPatterns = NULL;
   m_soldierCrowPatterns = NULL;
   m_insideOutsidePatterns = NULL;
   m_threeMethodsPatterns = NULL;
   m_tripleLinePatterns = NULL;
   
   m_breakawayPatterns = NULL;
   m_concealingPatterns = NULL;
   m_advanceBlockPatterns = NULL;
   m_correctionPatterns = NULL;
   m_identityPatterns = NULL;
   
   m_gappingPatterns = NULL;
   m_deliberationPatterns = NULL;
   m_uniquePatterns = NULL;
   
   m_traditionalPatterns = NULL;
   m_modernAdaptations = NULL;
   
   // تمكين جميع الأنماط افتراضياً
   m_enableEssentialPatterns = true;
   m_enableAdvancedPatterns = true;
   m_enableSpecializedPatterns = true;
   m_enableJapanesePatterns = true;
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CTripleCandlePatterns::~CTripleCandlePatterns()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة النظام                                                    |
//+------------------------------------------------------------------+
bool CTripleCandlePatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
      
   // إنشاء كاشفات الأنماط الأساسية
   m_starPatterns = new CStarPatterns();
   m_soldierCrowPatterns = new CSoldierCrowPatterns();
   m_insideOutsidePatterns = new CInsideOutsidePatterns();
   m_threeMethodsPatterns = new CThreeMethodsPatterns();
   m_tripleLinePatterns = new CTripleLinePatterns();
   
   // إنشاء كاشفات الأنماط المتقدمة
   m_breakawayPatterns = new CBreakawayPatterns();
   m_concealingPatterns = new CConcealingPatterns();
   m_advanceBlockPatterns = new CAdvanceBlockPatterns();
   m_correctionPatterns = new CCorrectionPatterns();
   m_identityPatterns = new CIdentityPatterns();
   
   // إنشاء كاشفات الأنماط المتخصصة
   m_gappingPatterns = new CGappingPatterns();
   m_deliberationPatterns = new CDeliberationPatterns();
   m_uniquePatterns = new CUniquePatterns();
   
   // إنشاء كاشفات الأنماط اليابانية
   m_traditionalPatterns = new CTraditionalPatterns();
   m_modernAdaptations = new CModernAdaptations();
   
   // تهيئة جميع الكاشفات
   bool success = true;
   
   if(m_starPatterns) success &= m_starPatterns.Initialize(symbol, timeframe);
   if(m_soldierCrowPatterns) success &= m_soldierCrowPatterns.Initialize(symbol, timeframe);
   if(m_insideOutsidePatterns) success &= m_insideOutsidePatterns.Initialize(symbol, timeframe);
   if(m_threeMethodsPatterns) success &= m_threeMethodsPatterns.Initialize(symbol, timeframe);
   if(m_tripleLinePatterns) success &= m_tripleLinePatterns.Initialize(symbol, timeframe);
   
   if(m_breakawayPatterns) success &= m_breakawayPatterns.Initialize(symbol, timeframe);
   if(m_concealingPatterns) success &= m_concealingPatterns.Initialize(symbol, timeframe);
   if(m_advanceBlockPatterns) success &= m_advanceBlockPatterns.Initialize(symbol, timeframe);
   if(m_correctionPatterns) success &= m_correctionPatterns.Initialize(symbol, timeframe);
   if(m_identityPatterns) success &= m_identityPatterns.Initialize(symbol, timeframe);
   
   if(m_gappingPatterns) success &= m_gappingPatterns.Initialize(symbol, timeframe);
   if(m_deliberationPatterns) success &= m_deliberationPatterns.Initialize(symbol, timeframe);
   if(m_uniquePatterns) success &= m_uniquePatterns.Initialize(symbol, timeframe);
   
   if(m_traditionalPatterns) success &= m_traditionalPatterns.Initialize(symbol, timeframe);
   if(m_modernAdaptations) success &= m_modernAdaptations.Initialize(symbol, timeframe);
   
   return success;
}

//+------------------------------------------------------------------+
//| إنهاء النظام                                                   |
//+------------------------------------------------------------------+
void CTripleCandlePatterns::Deinitialize()
{
   // تنظيف كاشفات الأنماط الأساسية
   if(m_starPatterns) { delete m_starPatterns; m_starPatterns = NULL; }
   if(m_soldierCrowPatterns) { delete m_soldierCrowPatterns; m_soldierCrowPatterns = NULL; }
   if(m_insideOutsidePatterns) { delete m_insideOutsidePatterns; m_insideOutsidePatterns = NULL; }
   if(m_threeMethodsPatterns) { delete m_threeMethodsPatterns; m_threeMethodsPatterns = NULL; }
   if(m_tripleLinePatterns) { delete m_tripleLinePatterns; m_tripleLinePatterns = NULL; }
   
   // تنظيف كاشفات الأنماط المتقدمة
   if(m_breakawayPatterns) { delete m_breakawayPatterns; m_breakawayPatterns = NULL; }
   if(m_concealingPatterns) { delete m_concealingPatterns; m_concealingPatterns = NULL; }
   if(m_advanceBlockPatterns) { delete m_advanceBlockPatterns; m_advanceBlockPatterns = NULL; }
   if(m_correctionPatterns) { delete m_correctionPatterns; m_correctionPatterns = NULL; }
   if(m_identityPatterns) { delete m_identityPatterns; m_identityPatterns = NULL; }
   
   // تنظيف كاشفات الأنماط المتخصصة
   if(m_gappingPatterns) { delete m_gappingPatterns; m_gappingPatterns = NULL; }
   if(m_deliberationPatterns) { delete m_deliberationPatterns; m_deliberationPatterns = NULL; }
   if(m_uniquePatterns) { delete m_uniquePatterns; m_uniquePatterns = NULL; }
   
   // تنظيف كاشفات الأنماط اليابانية
   if(m_traditionalPatterns) { delete m_traditionalPatterns; m_traditionalPatterns = NULL; }
   if(m_modernAdaptations) { delete m_modernAdaptations; m_modernAdaptations = NULL; }
   
   CPatternDetector::Deinitialize();
}

//+------------------------------------------------------------------+
//| الكشف عن جميع الأنماط                                          |
//+------------------------------------------------------------------+
int CTripleCandlePatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                            const double &open[], const double &high[], const double &low[], 
                                            const double &close[], const long &volume[], 
                                            SPatternDetectionResult &results[])
{
   SPatternDetectionResult tempResults[];
   SPatternDetectionResult allResults[];
   ArrayResize(allResults, 0);
   
   int totalFound = 0;
   
   // كشف الأنماط الأساسية
   if(m_enableEssentialPatterns)
   {
      int found = DetectEssentialPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف الأنماط المتقدمة
   if(m_enableAdvancedPatterns)
   {
      int found = DetectAdvancedPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف الأنماط المتخصصة
   if(m_enableSpecializedPatterns)
   {
      int found = DetectSpecializedPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف الأنماط اليابانية
   if(m_enableJapanesePatterns)
   {
      int found = DetectJapanesePatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // نسخ النتائج النهائية
   ArrayResize(results, totalFound);
   for(int i = 0; i < totalFound; i++)
      results[i] = allResults[i];
      
   return totalFound;
}

//+------------------------------------------------------------------+
//| كشف الأنماط الأساسية                                            |
//+------------------------------------------------------------------+
int CTripleCandlePatterns::DetectEssentialPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                  const double &open[], const double &high[], const double &low[], 
                                                  const double &close[], const long &volume[], 
                                                  SPatternDetectionResult &results[])
{
   SPatternDetectionResult tempResults[];
   SPatternDetectionResult allResults[];
   ArrayResize(allResults, 0);
   int totalFound = 0;
   
   // كشف أنماط النجوم
   if(m_starPatterns)
   {
      int found = m_starPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف أنماط الجنود والغربان
   if(m_soldierCrowPatterns)
   {
      int found = m_soldierCrowPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف أنماط الداخل والخارج
   if(m_insideOutsidePatterns)
   {
      int found = m_insideOutsidePatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف أنماط الطرق الثلاث
   if(m_threeMethodsPatterns)
   {
      int found = m_threeMethodsPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف أنماط الخطوط الثلاثية
   if(m_tripleLinePatterns)
   {
      int found = m_tripleLinePatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   ArrayResize(results, totalFound);
   for(int i = 0; i < totalFound; i++)
      results[i] = allResults[i];
      
   return totalFound;
}

//+------------------------------------------------------------------+
//| كشف الأنماط المتقدمة                                            |
//+------------------------------------------------------------------+
int CTripleCandlePatterns::DetectAdvancedPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                 const double &open[], const double &high[], const double &low[], 
                                                 const double &close[], const long &volume[], 
                                                 SPatternDetectionResult &results[])
{
   SPatternDetectionResult tempResults[];
   SPatternDetectionResult allResults[];
   ArrayResize(allResults, 0);
   int totalFound = 0;
   
   // كشف أنماط الانفصال
   if(m_breakawayPatterns)
   {
      int found = m_breakawayPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف أنماط الإخفاء
   if(m_concealingPatterns)
   {
      int found = m_concealingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف أنماط كتلة التقدم
   if(m_advanceBlockPatterns)
   {
      int found = m_advanceBlockPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف أنماط التصحيح
   if(m_correctionPatterns)
   {
      int found = m_correctionPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف أنماط الهوية
   if(m_identityPatterns)
   {
      int found = m_identityPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   ArrayResize(results, totalFound);
   for(int i = 0; i < totalFound; i++)
      results[i] = allResults[i];
      
   return totalFound;
}

//+------------------------------------------------------------------+
//| كشف الأنماط المتخصصة                                           |
//+------------------------------------------------------------------+
int CTripleCandlePatterns::DetectSpecializedPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                    const double &open[], const double &high[], const double &low[], 
                                                    const double &close[], const long &volume[], 
                                                    SPatternDetectionResult &results[])
{
   SPatternDetectionResult tempResults[];
   SPatternDetectionResult allResults[];
   ArrayResize(allResults, 0);
   int totalFound = 0;
   
   // كشف أنماط الفجوات
   if(m_gappingPatterns)
   {
      int found = m_gappingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف أنماط التداول
   if(m_deliberationPatterns)
   {
      int found = m_deliberationPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف الأنماط الفريدة
   if(m_uniquePatterns)
   {
      int found = m_uniquePatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   ArrayResize(results, totalFound);
   for(int i = 0; i < totalFound; i++)
      results[i] = allResults[i];
      
   return totalFound;
}

//+------------------------------------------------------------------+
//| كشف الأنماط اليابانية                                          |
//+------------------------------------------------------------------+
int CTripleCandlePatterns::DetectJapanesePatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                 const double &open[], const double &high[], const double &low[], 
                                                 const double &close[], const long &volume[], 
                                                 SPatternDetectionResult &results[])
{
   SPatternDetectionResult tempResults[];
   SPatternDetectionResult allResults[];
   ArrayResize(allResults, 0);
   int totalFound = 0;
   
   // كشف الأنماط التقليدية
   if(m_traditionalPatterns)
   {
      int found = m_traditionalPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   // كشف التكيفات الحديثة
   if(m_modernAdaptations)
   {
      int found = m_modernAdaptations.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(found > 0)
      {
         int oldSize = ArraySize(allResults);
         ArrayResize(allResults, oldSize + found);
         for(int i = 0; i < found; i++)
            allResults[oldSize + i] = tempResults[i];
         totalFound += found;
      }
   }
   
   ArrayResize(results, totalFound);
   for(int i = 0; i < totalFound; i++)
      results[i] = allResults[i];
      
   return totalFound;
}

//+------------------------------------------------------------------+
//| الحصول على عدد الأنماط الكلي                                    |
//+------------------------------------------------------------------+
int CTripleCandlePatterns::GetTotalPatternsCount()
{
   int count = 0;
   
   // عد الأنماط الأساسية (5 مجموعات × متوسط 4 أنماط)
   if(m_enableEssentialPatterns) count += 20;
   
   // عد الأنماط المتقدمة (5 مجموعات × متوسط 3 أنماط)
   if(m_enableAdvancedPatterns) count += 15;
   
   // عد الأنماط المتخصصة (3 مجموعات × متوسط 4 أنماط)
   if(m_enableSpecializedPatterns) count += 12;
   
   // عد الأنماط اليابانية (2 مجموعات × متوسط 4 أنماط)
   if(m_enableJapanesePatterns) count += 8;
   
   return count;
}

//+------------------------------------------------------------------+
//| الحصول على معلومات مجموعة الأنماط                              |
//+------------------------------------------------------------------+
string CTripleCandlePatterns::GetPatternGroupInfo(int groupIndex)
{
   switch(groupIndex)
   {
      case 0: return "Essential Patterns - الأنماط الأساسية";
      case 1: return "Advanced Patterns - الأنماط المتقدمة";
      case 2: return "Specialized Patterns - الأنماط المتخصصة";
      case 3: return "Japanese Patterns - الأنماط اليابانية";
      default: return "Unknown Group - مجموعة غير معروفة";
   }
}
