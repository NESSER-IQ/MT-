//+------------------------------------------------------------------+
//|                                        DoubleCandlePatterns.mqh |
//|                                  محرك أنماط الشموع الثنائية     |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../Base/PatternDetector.mqh"

// تضمين الملفات الأساسية
#include "Core/EngulfingPatterns.mqh"
#include "Core/HaramiPatterns.mqh"
#include "Core/TweezerPatterns.mqh"
#include "Core/PiercingPatterns.mqh"
#include "Core/KickingPatterns.mqh"

// تضمين الملفات المتقدمة
#include "Advanced/GapPatterns.mqh"
#include "Advanced/CounterAttackPatterns.mqh"
#include "Advanced/OverlapPatterns.mqh"
#include "Advanced/StarPatterns.mqh"

// تضمين الملفات المتخصصة
#include "Specialized/ContinuationPatterns.mqh"
#include "Specialized/SpecialPatterns.mqh"

//+------------------------------------------------------------------+
//| محرك الكشف عن أنماط الشموع الثنائية                             |
//+------------------------------------------------------------------+
class CDoubleCandlePatterns : public CPatternDetector
{
private:
   // مصفوفات الأنماط
   CEngulfingPatterns*        m_engulfingPatterns;
   CHaramiPatterns*          m_haramiPatterns;
   CTweezerPatterns*         m_tweezerPatterns;
   CPiercingPatterns*        m_piercingPatterns;
   CKickingPatterns*         m_kickingPatterns;
   CGapPatterns*             m_gapPatterns;
   CCounterAttackPatterns*   m_counterAttackPatterns;
   COverlapPatterns*         m_overlapPatterns;
   CStarPatterns*            m_starPatterns;
   CContinuationPatterns*    m_continuationPatterns;
   CSpecialPatterns*         m_specialPatterns;
   
   // إعدادات المحرك
   bool                      m_enableEngulfing;
   bool                      m_enableHarami;
   bool                      m_enableTweezer;
   bool                      m_enablePiercing;
   bool                      m_enableKicking;
   bool                      m_enableGap;
   bool                      m_enableCounterAttack;
   bool                      m_enableOverlap;
   bool                      m_enableStar;
   bool                      m_enableContinuation;
   bool                      m_enableSpecial;
   
   // متغيرات الحالة
   bool                      m_isInitialized;
   int                       m_initErrorCount;
   string                    m_lastError;
   
   // دوال مساعدة خاصة
   bool                      CreatePatternEngines(void);
   bool                      InitializePatternEngines(const string symbol, const ENUM_TIMEFRAMES timeframe);
   void                      CleanupPatternEngines(void);
   int                       MergePatternResults(SPatternDetectionResult &results[], 
                                               const SPatternDetectionResult &newResults[], 
                                               const int newCount, int &currentTotal);
   
public:
   // المنشئ والهادم
                     CDoubleCandlePatterns(void);
                     ~CDoubleCandlePatterns(void);
   
   // تهيئة المحرك - يجب أن تطابق التوقيع في الفئة الأساسية
   virtual bool      Initialize(string symbol, ENUM_TIMEFRAMES timeframe);
   virtual void      Deinitialize(void);
   
   // الحصول على حالة التهيئة
   bool              IsInitialized(void) const { return m_isInitialized; }
   string            GetLastError(void) const { return m_lastError; }
   int               GetInitErrorCount(void) const { return m_initErrorCount; }
   
   // إعدادات التفعيل
   void              EnableEngulfingPatterns(const bool enable) { m_enableEngulfing = enable; }
   void              EnableHaramiPatterns(const bool enable) { m_enableHarami = enable; }
   void              EnableTweezerPatterns(const bool enable) { m_enableTweezer = enable; }
   void              EnablePiercingPatterns(const bool enable) { m_enablePiercing = enable; }
   void              EnableKickingPatterns(const bool enable) { m_enableKicking = enable; }
   void              EnableGapPatterns(const bool enable) { m_enableGap = enable; }
   void              EnableCounterAttackPatterns(const bool enable) { m_enableCounterAttack = enable; }
   void              EnableOverlapPatterns(const bool enable) { m_enableOverlap = enable; }
   void              EnableStarPatterns(const bool enable) { m_enableStar = enable; }
   void              EnableContinuationPatterns(const bool enable) { m_enableContinuation = enable; }
   void              EnableSpecialPatterns(const bool enable) { m_enableSpecial = enable; }
   void              EnableAllPatterns(const bool enable);
   
   // الحصول على حالة التفعيل
   bool              IsEngulfingPatternsEnabled(void) const { return m_enableEngulfing; }
   bool              IsHaramiPatternsEnabled(void) const { return m_enableHarami; }
   bool              IsTweezerPatternsEnabled(void) const { return m_enableTweezer; }
   bool              IsPiercingPatternsEnabled(void) const { return m_enablePiercing; }
   bool              IsKickingPatternsEnabled(void) const { return m_enableKicking; }
   bool              IsGapPatternsEnabled(void) const { return m_enableGap; }
   bool              IsCounterAttackPatternsEnabled(void) const { return m_enableCounterAttack; }
   bool              IsOverlapPatternsEnabled(void) const { return m_enableOverlap; }
   bool              IsStarPatternsEnabled(void) const { return m_enableStar; }
   bool              IsContinuationPatternsEnabled(void) const { return m_enableContinuation; }
   bool              IsSpecialPatternsEnabled(void) const { return m_enableSpecial; }
   
   // الكشف عن الأنماط - يجب أن تطابق التوقيع في الفئة الأساسية تماماً
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // دوال الكشف المتخصصة
   int               DetectEngulfingPatterns(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], const long &volume[], 
                                           SPatternDetectionResult &results[]);
   int               DetectHaramiPatterns(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[], const long &volume[], 
                                        SPatternDetectionResult &results[]);
   int               DetectSpecificPatternGroup(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                              const double &open[], const double &high[], const double &low[], 
                                              const double &close[], const long &volume[], 
                                              SPatternDetectionResult &results[], const string groupName);
   
   // إحصائيات الأنماط
   int               GetActivePatternCount(void) const;
   int               GetTotalPatternCount(void) const;
   void              GetPatternStatistics(int &totalPatterns, int &activePatterns, double &avgReliability) const;
   
   // دوال التحقق
   bool              ValidatePatternEngines(void) const;
   void              ResetErrorState(void);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CDoubleCandlePatterns::CDoubleCandlePatterns(void)
{
   // تهيئة المؤشرات
   m_engulfingPatterns = NULL;
   m_haramiPatterns = NULL;
   m_tweezerPatterns = NULL;
   m_piercingPatterns = NULL;
   m_kickingPatterns = NULL;
   m_gapPatterns = NULL;
   m_counterAttackPatterns = NULL;
   m_overlapPatterns = NULL;
   m_starPatterns = NULL;
   m_continuationPatterns = NULL;
   m_specialPatterns = NULL;
   
   // تفعيل جميع الأنماط افتراضياً
   m_enableEngulfing = true;
   m_enableHarami = true;
   m_enableTweezer = true;
   m_enablePiercing = true;
   m_enableKicking = true;
   m_enableGap = true;
   m_enableCounterAttack = true;
   m_enableOverlap = true;
   m_enableStar = true;
   m_enableContinuation = true;
   m_enableSpecial = true;
   
   // تهيئة متغيرات الحالة
   m_isInitialized = false;
   m_initErrorCount = 0;
   m_lastError = "";
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CDoubleCandlePatterns::~CDoubleCandlePatterns(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| إنشاء محركات الأنماط                                            |
//+------------------------------------------------------------------+
bool CDoubleCandlePatterns::CreatePatternEngines(void)
{
   bool success = true;
   
   // إنشاء كائنات الأنماط مع التحقق من النجاح
   if(m_enableEngulfing)
   {
      m_engulfingPatterns = new CEngulfingPatterns();
      if(m_engulfingPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط الابتلاع";
         success = false;
      }
   }
   
   if(m_enableHarami)
   {
      m_haramiPatterns = new CHaramiPatterns();
      if(m_haramiPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط الحامل";
         success = false;
      }
   }
   
   if(m_enableTweezer)
   {
      m_tweezerPatterns = new CTweezerPatterns();
      if(m_tweezerPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط الملقاط";
         success = false;
      }
   }
   
   if(m_enablePiercing)
   {
      m_piercingPatterns = new CPiercingPatterns();
      if(m_piercingPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط الاختراق";
         success = false;
      }
   }
   
   if(m_enableKicking)
   {
      m_kickingPatterns = new CKickingPatterns();
      if(m_kickingPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط الركل";
         success = false;
      }
   }
   
   if(m_enableGap)
   {
      m_gapPatterns = new CGapPatterns();
      if(m_gapPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط الفجوات";
         success = false;
      }
   }
   
   if(m_enableCounterAttack)
   {
      m_counterAttackPatterns = new CCounterAttackPatterns();
      if(m_counterAttackPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط الهجوم المضاد";
         success = false;
      }
   }
   
   if(m_enableOverlap)
   {
      m_overlapPatterns = new COverlapPatterns();
      if(m_overlapPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط التداخل";
         success = false;
      }
   }
   
   if(m_enableStar)
   {
      m_starPatterns = new CStarPatterns();
      if(m_starPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط النجوم";
         success = false;
      }
   }
   
   if(m_enableContinuation)
   {
      m_continuationPatterns = new CContinuationPatterns();
      if(m_continuationPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك أنماط الاستمرار";
         success = false;
      }
   }
   
   if(m_enableSpecial)
   {
      m_specialPatterns = new CSpecialPatterns();
      if(m_specialPatterns == NULL)
      {
         m_lastError = "فشل في إنشاء محرك الأنماط الخاصة";
         success = false;
      }
   }
   
   return success;
}

//+------------------------------------------------------------------+
//| تهيئة محركات الأنماط                                            |
//+------------------------------------------------------------------+
bool CDoubleCandlePatterns::InitializePatternEngines(const string symbol, const ENUM_TIMEFRAMES timeframe)
{
   bool success = true;
   
   // تهيئة جميع محركات الأنماط المُفعلة
   if(m_engulfingPatterns != NULL)
   {
      if(!m_engulfingPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط الابتلاع";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_haramiPatterns != NULL)
   {
      if(!m_haramiPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط الحامل";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_tweezerPatterns != NULL)
   {
      if(!m_tweezerPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط الملقاط";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_piercingPatterns != NULL)
   {
      if(!m_piercingPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط الاختراق";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_kickingPatterns != NULL)
   {
      if(!m_kickingPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط الركل";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_gapPatterns != NULL)
   {
      if(!m_gapPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط الفجوات";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_counterAttackPatterns != NULL)
   {
      if(!m_counterAttackPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط الهجوم المضاد";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_overlapPatterns != NULL)
   {
      if(!m_overlapPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط التداخل";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_starPatterns != NULL)
   {
      if(!m_starPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط النجوم";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_continuationPatterns != NULL)
   {
      if(!m_continuationPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك أنماط الاستمرار";
         success = false;
         m_initErrorCount++;
      }
   }
   
   if(m_specialPatterns != NULL)
   {
      if(!m_specialPatterns.Initialize(symbol, timeframe))
      {
         m_lastError = "فشل في تهيئة محرك الأنماط الخاصة";
         success = false;
         m_initErrorCount++;
      }
   }
   
   return success;
}

//+------------------------------------------------------------------+
//| تنظيف محركات الأنماط                                           |
//+------------------------------------------------------------------+
void CDoubleCandlePatterns::CleanupPatternEngines(void)
{
   // حذف جميع كائنات الأنماط بأمان
   if(CheckPointer(m_engulfingPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_engulfingPatterns; 
      m_engulfingPatterns = NULL; 
   }
   
   if(CheckPointer(m_haramiPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_haramiPatterns; 
      m_haramiPatterns = NULL; 
   }
   
   if(CheckPointer(m_tweezerPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_tweezerPatterns; 
      m_tweezerPatterns = NULL; 
   }
   
   if(CheckPointer(m_piercingPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_piercingPatterns; 
      m_piercingPatterns = NULL; 
   }
   
   if(CheckPointer(m_kickingPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_kickingPatterns; 
      m_kickingPatterns = NULL; 
   }
   
   if(CheckPointer(m_gapPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_gapPatterns; 
      m_gapPatterns = NULL; 
   }
   
   if(CheckPointer(m_counterAttackPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_counterAttackPatterns; 
      m_counterAttackPatterns = NULL; 
   }
   
   if(CheckPointer(m_overlapPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_overlapPatterns; 
      m_overlapPatterns = NULL; 
   }
   
   if(CheckPointer(m_starPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_starPatterns; 
      m_starPatterns = NULL; 
   }
   
   if(CheckPointer(m_continuationPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_continuationPatterns; 
      m_continuationPatterns = NULL; 
   }
   
   if(CheckPointer(m_specialPatterns) == POINTER_DYNAMIC) 
   { 
      delete m_specialPatterns; 
      m_specialPatterns = NULL; 
   }
}

//+------------------------------------------------------------------+
//| تهيئة المحرك                                                     |
//+------------------------------------------------------------------+
bool CDoubleCandlePatterns::Initialize(string symbol, ENUM_TIMEFRAMES timeframe)
{
   // إعادة تعيين حالة الخطأ
   ResetErrorState();
   
   // تهيئة المحرك الأساسي أولاً
   if(!CPatternDetector::Initialize(symbol, timeframe))
   {
      m_lastError = "فشل في تهيئة المحرك الأساسي";
      return false;
   }
   
   // إنشاء محركات الأنماط
   if(!CreatePatternEngines())
   {
      CleanupPatternEngines();
      return false;
   }
   
   // تهيئة محركات الأنماط
   if(!InitializePatternEngines(symbol, timeframe))
   {
      CleanupPatternEngines();
      return false;
   }
   
   m_isInitialized = true;
   return true;
}

//+------------------------------------------------------------------+
//| إنهاء المحرك                                                    |
//+------------------------------------------------------------------+
void CDoubleCandlePatterns::Deinitialize(void)
{
   // تنظيف محركات الأنماط
   CleanupPatternEngines();
   
   // إنهاء المحرك الأساسي
   CPatternDetector::Deinitialize();
   
   // إعادة تعيين الحالة
   m_isInitialized = false;
   ResetErrorState();
}

//+------------------------------------------------------------------+
//| تفعيل جميع الأنماط                                              |
//+------------------------------------------------------------------+
void CDoubleCandlePatterns::EnableAllPatterns(const bool enable)
{
   m_enableEngulfing = enable;
   m_enableHarami = enable;
   m_enableTweezer = enable;
   m_enablePiercing = enable;
   m_enableKicking = enable;
   m_enableGap = enable;
   m_enableCounterAttack = enable;
   m_enableOverlap = enable;
   m_enableStar = enable;
   m_enableContinuation = enable;
   m_enableSpecial = enable;
}

//+------------------------------------------------------------------+
//| دمج نتائج الأنماط                                               |
//+------------------------------------------------------------------+
int CDoubleCandlePatterns::MergePatternResults(SPatternDetectionResult &results[], 
                                             const SPatternDetectionResult &newResults[], 
                                             const int newCount, int &currentTotal)
{
   if(newCount <= 0) return currentTotal;
   
   int newSize = currentTotal + newCount;
   ArrayResize(results, newSize);
   
   for(int i = 0; i < newCount; i++)
   {
      results[currentTotal + i] = newResults[i];
   }
   
   currentTotal = newSize;
   return currentTotal;
}

//+------------------------------------------------------------------+
//| الكشف عن جميع الأنماط                                          |
//+------------------------------------------------------------------+
int CDoubleCandlePatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                            const double &open[], const double &high[], const double &low[], 
                                            const double &close[], const long &volume[], 
                                            SPatternDetectionResult &results[])
{
   // التحقق من التهيئة
   if(!m_isInitialized)
   {
      m_lastError = "المحرك غير مُهيأ";
      return 0;
   }
   
   // التحقق من صحة البيانات
   if(!ValidateData(open, high, low, close, volume, idx) || idx < 1)
   {
      m_lastError = "بيانات غير صحيحة أو فهرس غير صالح";
      return 0;
   }
   
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // كشف أنماط الابتلاع
   if(m_enableEngulfing && CheckPointer(m_engulfingPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_engulfingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف أنماط الحامل
   if(m_enableHarami && CheckPointer(m_haramiPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_haramiPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف أنماط الملقاط
   if(m_enableTweezer && CheckPointer(m_tweezerPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_tweezerPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف أنماط الاختراق
   if(m_enablePiercing && CheckPointer(m_piercingPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_piercingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف أنماط الركل
   if(m_enableKicking && CheckPointer(m_kickingPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_kickingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف أنماط الفجوات
   if(m_enableGap && CheckPointer(m_gapPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_gapPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف أنماط الهجوم المضاد
   if(m_enableCounterAttack && CheckPointer(m_counterAttackPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_counterAttackPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف أنماط التداخل
   if(m_enableOverlap && CheckPointer(m_overlapPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_overlapPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف أنماط النجوم
   if(m_enableStar && CheckPointer(m_starPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_starPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف أنماط الاستمرار
   if(m_enableContinuation && CheckPointer(m_continuationPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_continuationPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   // كشف الأنماط الخاصة
   if(m_enableSpecial && CheckPointer(m_specialPatterns) == POINTER_DYNAMIC)
   {
      int patternCount = m_specialPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         MergePatternResults(results, tempResults, patternCount, totalPatterns);
      }
   }
   
   return totalPatterns;
}

//+------------------------------------------------------------------+
//| عدد الأنماط النشطة                                              |
//+------------------------------------------------------------------+
int CDoubleCandlePatterns::GetActivePatternCount(void) const
{
   int count = 0;
   if(m_enableEngulfing) count++;
   if(m_enableHarami) count++;
   if(m_enableTweezer) count++;
   if(m_enablePiercing) count++;
   if(m_enableKicking) count++;
   if(m_enableGap) count++;
   if(m_enableCounterAttack) count++;
   if(m_enableOverlap) count++;
   if(m_enableStar) count++;
   if(m_enableContinuation) count++;
   if(m_enableSpecial) count++;
   return count;
}

//+------------------------------------------------------------------+
//| إجمالي عدد الأنماط                                              |
//+------------------------------------------------------------------+
int CDoubleCandlePatterns::GetTotalPatternCount(void) const
{
   return 11; // إجمالي عدد مجموعات الأنماط
}

//+------------------------------------------------------------------+
//| إحصائيات الأنماط                                                |
//+------------------------------------------------------------------+
void CDoubleCandlePatterns::GetPatternStatistics(int &totalPatterns, int &activePatterns, double &avgReliability) const
{
   totalPatterns = GetTotalPatternCount();
   activePatterns = GetActivePatternCount();
   avgReliability = 0.75; // متوسط الموثوقية للأنماط الثنائية
}

//+------------------------------------------------------------------+
//| التحقق من صحة محركات الأنماط                                    |
//+------------------------------------------------------------------+
bool CDoubleCandlePatterns::ValidatePatternEngines(void) const
{
   bool isValid = true;
   
   if(m_enableEngulfing && CheckPointer(m_engulfingPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enableHarami && CheckPointer(m_haramiPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enableTweezer && CheckPointer(m_tweezerPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enablePiercing && CheckPointer(m_piercingPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enableKicking && CheckPointer(m_kickingPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enableGap && CheckPointer(m_gapPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enableCounterAttack && CheckPointer(m_counterAttackPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enableOverlap && CheckPointer(m_overlapPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enableStar && CheckPointer(m_starPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enableContinuation && CheckPointer(m_continuationPatterns) != POINTER_DYNAMIC) isValid = false;
   if(m_enableSpecial && CheckPointer(m_specialPatterns) != POINTER_DYNAMIC) isValid = false;
   
   return isValid;
}

//+------------------------------------------------------------------+
//| إعادة تعيين حالة الخطأ                                          |
//+------------------------------------------------------------------+
void CDoubleCandlePatterns::ResetErrorState(void)
{
   m_initErrorCount = 0;
   m_lastError = "";
}

//+------------------------------------------------------------------+
//| كشف أنماط الابتلاع المتخصص                                      |
//+------------------------------------------------------------------+
int CDoubleCandlePatterns::DetectEngulfingPatterns(const int idx, const double &open[], const double &high[], 
                                                  const double &low[], const double &close[], const long &volume[], 
                                                  SPatternDetectionResult &results[])
{
   if(!m_enableEngulfing || CheckPointer(m_engulfingPatterns) != POINTER_DYNAMIC)
      return 0;
      
   return m_engulfingPatterns.DetectAllPatterns(idx, "", PERIOD_CURRENT, open, high, low, close, volume, results);
}

//+------------------------------------------------------------------+
//| كشف أنماط الحامل المتخصص                                        |
//+------------------------------------------------------------------+
int CDoubleCandlePatterns::DetectHaramiPatterns(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], const long &volume[], 
                                               SPatternDetectionResult &results[])
{
   if(!m_enableHarami || CheckPointer(m_haramiPatterns) != POINTER_DYNAMIC)
      return 0;
      
   return m_haramiPatterns.DetectAllPatterns(idx, "", PERIOD_CURRENT, open, high, low, close, volume, results);
}

//+------------------------------------------------------------------+
//| كشف مجموعة أنماط محددة                                          |
//+------------------------------------------------------------------+
int CDoubleCandlePatterns::DetectSpecificPatternGroup(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                     const double &open[], const double &high[], const double &low[], 
                                                     const double &close[], const long &volume[], 
                                                     SPatternDetectionResult &results[], const string groupName)
{
   ArrayResize(results, 0);
   
   if(groupName == "Engulfing" && m_enableEngulfing && CheckPointer(m_engulfingPatterns) == POINTER_DYNAMIC)
   {
      return m_engulfingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "Harami" && m_enableHarami && CheckPointer(m_haramiPatterns) == POINTER_DYNAMIC)
   {
      return m_haramiPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "Tweezer" && m_enableTweezer && CheckPointer(m_tweezerPatterns) == POINTER_DYNAMIC)
   {
      return m_tweezerPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "Piercing" && m_enablePiercing && CheckPointer(m_piercingPatterns) == POINTER_DYNAMIC)
   {
      return m_piercingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "Kicking" && m_enableKicking && CheckPointer(m_kickingPatterns) == POINTER_DYNAMIC)
   {
      return m_kickingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "Gap" && m_enableGap && CheckPointer(m_gapPatterns) == POINTER_DYNAMIC)
   {
      return m_gapPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "CounterAttack" && m_enableCounterAttack && CheckPointer(m_counterAttackPatterns) == POINTER_DYNAMIC)
   {
      return m_counterAttackPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "Overlap" && m_enableOverlap && CheckPointer(m_overlapPatterns) == POINTER_DYNAMIC)
   {
      return m_overlapPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "Star" && m_enableStar && CheckPointer(m_starPatterns) == POINTER_DYNAMIC)
   {
      return m_starPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "Continuation" && m_enableContinuation && CheckPointer(m_continuationPatterns) == POINTER_DYNAMIC)
   {
      return m_continuationPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   else if(groupName == "Special" && m_enableSpecial && CheckPointer(m_specialPatterns) == POINTER_DYNAMIC)
   {
      return m_specialPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, results);
   }
   
   return 0;
}