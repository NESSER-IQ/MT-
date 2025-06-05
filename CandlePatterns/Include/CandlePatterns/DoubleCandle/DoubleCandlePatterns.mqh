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
   
public:
   // المنشئ والهادم
                     CDoubleCandlePatterns();
                     ~CDoubleCandlePatterns();
   
   // تهيئة المحرك
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   
   // إعدادات التفعيل
   void              EnableEngulfingPatterns(bool enable) { m_enableEngulfing = enable; }
   void              EnableHaramiPatterns(bool enable) { m_enableHarami = enable; }
   void              EnableTweezerPatterns(bool enable) { m_enableTweezer = enable; }
   void              EnablePiercingPatterns(bool enable) { m_enablePiercing = enable; }
   void              EnableKickingPatterns(bool enable) { m_enableKicking = enable; }
   void              EnableGapPatterns(bool enable) { m_enableGap = enable; }
   void              EnableCounterAttackPatterns(bool enable) { m_enableCounterAttack = enable; }
   void              EnableOverlapPatterns(bool enable) { m_enableOverlap = enable; }
   void              EnableStarPatterns(bool enable) { m_enableStar = enable; }
   void              EnableContinuationPatterns(bool enable) { m_enableContinuation = enable; }
   void              EnableSpecialPatterns(bool enable) { m_enableSpecial = enable; }
   void              EnableAllPatterns(bool enable);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // دوال مساعدة
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
   int               GetActivePatternCount();
   void              GetPatternStatistics(int &totalPatterns, int &activePatterns, double &avgReliability);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CDoubleCandlePatterns::CDoubleCandlePatterns()
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
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CDoubleCandlePatterns::~CDoubleCandlePatterns()
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| تهيئة المحرك                                                     |
//+------------------------------------------------------------------+
bool CDoubleCandlePatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   // تهيئة المحرك الأساسي
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
   
   // إنشاء كائنات الأنماط
   m_engulfingPatterns = new CEngulfingPatterns();
   m_haramiPatterns = new CHaramiPatterns();
   m_tweezerPatterns = new CTweezerPatterns();
   m_piercingPatterns = new CPiercingPatterns();
   m_kickingPatterns = new CKickingPatterns();
   m_gapPatterns = new CGapPatterns();
   m_counterAttackPatterns = new CCounterAttackPatterns();
   m_overlapPatterns = new COverlapPatterns();
   m_starPatterns = new CStarPatterns();
   m_continuationPatterns = new CContinuationPatterns();
   m_specialPatterns = new CSpecialPatterns();
   
   // تهيئة جميع محركات الأنماط
   bool success = true;
   
   if(m_engulfingPatterns) success &= m_engulfingPatterns.Initialize(symbol, timeframe);
   if(m_haramiPatterns) success &= m_haramiPatterns.Initialize(symbol, timeframe);
   if(m_tweezerPatterns) success &= m_tweezerPatterns.Initialize(symbol, timeframe);
   if(m_piercingPatterns) success &= m_piercingPatterns.Initialize(symbol, timeframe);
   if(m_kickingPatterns) success &= m_kickingPatterns.Initialize(symbol, timeframe);
   if(m_gapPatterns) success &= m_gapPatterns.Initialize(symbol, timeframe);
   if(m_counterAttackPatterns) success &= m_counterAttackPatterns.Initialize(symbol, timeframe);
   if(m_overlapPatterns) success &= m_overlapPatterns.Initialize(symbol, timeframe);
   if(m_starPatterns) success &= m_starPatterns.Initialize(symbol, timeframe);
   if(m_continuationPatterns) success &= m_continuationPatterns.Initialize(symbol, timeframe);
   if(m_specialPatterns) success &= m_specialPatterns.Initialize(symbol, timeframe);
   
   return success;
}

//+------------------------------------------------------------------+
//| إنهاء المحرك                                                    |
//+------------------------------------------------------------------+
void CDoubleCandlePatterns::Deinitialize()
{
   // حذف جميع كائنات الأنماط
   if(m_engulfingPatterns) { delete m_engulfingPatterns; m_engulfingPatterns = NULL; }
   if(m_haramiPatterns) { delete m_haramiPatterns; m_haramiPatterns = NULL; }
   if(m_tweezerPatterns) { delete m_tweezerPatterns; m_tweezerPatterns = NULL; }
   if(m_piercingPatterns) { delete m_piercingPatterns; m_piercingPatterns = NULL; }
   if(m_kickingPatterns) { delete m_kickingPatterns; m_kickingPatterns = NULL; }
   if(m_gapPatterns) { delete m_gapPatterns; m_gapPatterns = NULL; }
   if(m_counterAttackPatterns) { delete m_counterAttackPatterns; m_counterAttackPatterns = NULL; }
   if(m_overlapPatterns) { delete m_overlapPatterns; m_overlapPatterns = NULL; }
   if(m_starPatterns) { delete m_starPatterns; m_starPatterns = NULL; }
   if(m_continuationPatterns) { delete m_continuationPatterns; m_continuationPatterns = NULL; }
   if(m_specialPatterns) { delete m_specialPatterns; m_specialPatterns = NULL; }
   
   // إنهاء المحرك الأساسي
   CPatternDetector::Deinitialize();
}

//+------------------------------------------------------------------+
//| تفعيل جميع الأنماط                                              |
//+------------------------------------------------------------------+
void CDoubleCandlePatterns::EnableAllPatterns(bool enable)
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
//| الكشف عن جميع الأنماط                                          |
//+------------------------------------------------------------------+
int CDoubleCandlePatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                            const double &open[], const double &high[], const double &low[], 
                                            const double &close[], const long &volume[], 
                                            SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // التحقق من صحة البيانات
   if(!ValidateData(open, high, low, close, volume, idx) || idx < 1)
      return 0;
   
   // كشف أنماط الابتلاع
   if(m_enableEngulfing && m_engulfingPatterns)
   {
      int patternCount = m_engulfingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف أنماط الحامل
   if(m_enableHarami && m_haramiPatterns)
   {
      int patternCount = m_haramiPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف أنماط الملقاط
   if(m_enableTweezer && m_tweezerPatterns)
   {
      int patternCount = m_tweezerPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف أنماط الاختراق
   if(m_enablePiercing && m_piercingPatterns)
   {
      int patternCount = m_piercingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف أنماط الركل
   if(m_enableKicking && m_kickingPatterns)
   {
      int patternCount = m_kickingPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف أنماط الفجوات
   if(m_enableGap && m_gapPatterns)
   {
      int patternCount = m_gapPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف أنماط الهجوم المضاد
   if(m_enableCounterAttack && m_counterAttackPatterns)
   {
      int patternCount = m_counterAttackPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف أنماط التداخل
   if(m_enableOverlap && m_overlapPatterns)
   {
      int patternCount = m_overlapPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف أنماط النجوم
   if(m_enableStar && m_starPatterns)
   {
      int patternCount = m_starPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف أنماط الاستمرار
   if(m_enableContinuation && m_continuationPatterns)
   {
      int patternCount = m_continuationPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف الأنماط الخاصة
   if(m_enableSpecial && m_specialPatterns)
   {
      int patternCount = m_specialPatterns.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         ArrayResize(results, totalPatterns + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[totalPatterns + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   return totalPatterns;
}

//+------------------------------------------------------------------+
//| عدد الأنماط النشطة                                              |
//+------------------------------------------------------------------+
int CDoubleCandlePatterns::GetActivePatternCount()
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
//| إحصائيات الأنماط                                                |
//+------------------------------------------------------------------+
void CDoubleCandlePatterns::GetPatternStatistics(int &totalPatterns, int &activePatterns, double &avgReliability)
{
   totalPatterns = 11; // إجمالي عدد مجموعات الأنماط
   activePatterns = GetActivePatternCount();
   avgReliability = 0.75; // متوسط الموثوقية للأنماط الثنائية
}
