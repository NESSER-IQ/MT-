//+------------------------------------------------------------------+
//|                                        SoldierCrowPatterns.mqh  |
//|                                      أنماط الجنود والغربان      |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة أنماط الجنود والغربان                                      |
//+------------------------------------------------------------------+
class CSoldierCrowPatterns : public CPatternDetector
{
private:
   double            m_minBodySize;           // الحد الأدنى لحجم الجسم
   double            m_progressiveThreshold;  // حد التقدم التدريجي
   
public:
   // المنشئ والهادم
                     CSoldierCrowPatterns();
                     ~CSoldierCrowPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // أنماط الجنود والغربان المحددة
   bool              DetectThreeWhiteSoldiers(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[], 
                                            SPatternDetectionResult &result);
                                            
   bool              DetectThreeBlackCrows(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[], 
                                         SPatternDetectionResult &result);
                                         
   bool              DetectAdvanceBlock(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[], 
                                      SPatternDetectionResult &result);
                                      
   bool              DetectDeliberationPattern(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsProgressivePattern(const double &open[], const double &close[], int start, int count);
   bool              HasSimilarBodies(const double &open[], const double &close[], int start, int count);
   bool              IsStrongCandle(const double open, const double high, const double low, const double close);
   double            CalculateBodyRatio(const double open, const double high, const double low, const double close);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CSoldierCrowPatterns::CSoldierCrowPatterns()
{
   m_minBodySize = 0.6;          // 60% من المدى كحد أدنى للجسم
   m_progressiveThreshold = 0.8; // 80% تشابه في التقدم
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CSoldierCrowPatterns::~CSoldierCrowPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CSoldierCrowPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع أنماط الجنود والغربان                            |
//+------------------------------------------------------------------+
int CSoldierCrowPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                           const double &open[], const double &high[], const double &low[], 
                                           const double &close[], const long &volume[], 
                                           SPatternDetectionResult &results[])
{
   if(idx < 2 || !ValidateData(open, high, low, close, volume, idx))
      return 0;
      
   SPatternDetectionResult tempResults[];
   ArrayResize(tempResults, 4); // أربعة أنماط محتملة
   int found = 0;
   
   SPatternDetectionResult result;
   
   // كشف الجنود البيض الثلاثة
   if(DetectThreeWhiteSoldiers(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف الغربان السود الثلاثة
   if(DetectThreeBlackCrows(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف كتلة التقدم
   if(DetectAdvanceBlock(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف نمط التداول
   if(DetectDeliberationPattern(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // نسخ النتائج
   if(found > 0)
   {
      ArrayResize(results, found);
      for(int i = 0; i < found; i++)
         results[i] = tempResults[i];
   }
   
   return found;
}

//+------------------------------------------------------------------+
//| كشف الجنود البيض الثلاثة (Three White Soldiers)                 |
//+------------------------------------------------------------------+
bool CSoldierCrowPatterns::DetectThreeWhiteSoldiers(const int idx, const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], 
                                                   SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   bool validPattern = true;
   double totalStrength = 0.0;
   
   // التحقق من كل شمعة
   for(int i = 0; i < 3; i++)
   {
      int candleIdx = idx - 2 + i;
      
      // يجب أن تكون صعودية
      if(close[candleIdx] <= open[candleIdx])
      {
         validPattern = false;
         break;
      }
      
      // يجب أن تكون قوية (جسم كبير)
      if(!IsStrongCandle(open[candleIdx], high[candleIdx], low[candleIdx], close[candleIdx]))
      {
         validPattern = false;
         break;
      }
      
      // كل شمعة يجب أن تفتح ضمن جسم السابقة (ما عدا الأولى)
      if(i > 0)
      {
         int prevIdx = candleIdx - 1;
         if(open[candleIdx] <= open[prevIdx] || open[candleIdx] >= close[prevIdx])
         {
            validPattern = false;
            break;
         }
      }
      
      // كل شمعة يجب أن تغلق أعلى من السابقة
      if(i > 0)
      {
         int prevIdx = candleIdx - 1;
         if(close[candleIdx] <= close[prevIdx])
         {
            validPattern = false;
            break;
         }
      }
      
      totalStrength += CalculateBodyRatio(open[candleIdx], high[candleIdx], low[candleIdx], close[candleIdx]);
   }
   
   // التحقق من التقدم التدريجي
   if(validPattern && IsProgressivePattern(open, close, idx-2, 3))
   {
      result.patternName = "Three White Soldiers";
      result.strength = totalStrength / 3.0;
      result.reliability = 0.85;
      result.direction = PATTERN_BULLISH;
      result.type = PATTERN_TRIPLE;
      result.confidence = (result.strength + result.reliability) / 2.0;
      
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف الغربان السود الثلاثة (Three Black Crows)                   |
//+------------------------------------------------------------------+
bool CSoldierCrowPatterns::DetectThreeBlackCrows(const int idx, const double &open[], const double &high[], 
                                                const double &low[], const double &close[], 
                                                SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   bool validPattern = true;
   double totalStrength = 0.0;
   
   // التحقق من كل شمعة
   for(int i = 0; i < 3; i++)
   {
      int candleIdx = idx - 2 + i;
      
      // يجب أن تكون هبوطية
      if(close[candleIdx] >= open[candleIdx])
      {
         validPattern = false;
         break;
      }
      
      // يجب أن تكون قوية (جسم كبير)
      if(!IsStrongCandle(open[candleIdx], high[candleIdx], low[candleIdx], close[candleIdx]))
      {
         validPattern = false;
         break;
      }
      
      // كل شمعة يجب أن تفتح ضمن جسم السابقة (ما عدا الأولى)
      if(i > 0)
      {
         int prevIdx = candleIdx - 1;
         if(open[candleIdx] >= open[prevIdx] || open[candleIdx] <= close[prevIdx])
         {
            validPattern = false;
            break;
         }
      }
      
      // كل شمعة يجب أن تغلق أقل من السابقة
      if(i > 0)
      {
         int prevIdx = candleIdx - 1;
         if(close[candleIdx] >= close[prevIdx])
         {
            validPattern = false;
            break;
         }
      }
      
      totalStrength += CalculateBodyRatio(open[candleIdx], high[candleIdx], low[candleIdx], close[candleIdx]);
   }
   
   // التحقق من التقدم التدريجي
   if(validPattern && IsProgressivePattern(open, close, idx-2, 3))
   {
      result.patternName = "Three Black Crows";
      result.strength = totalStrength / 3.0;
      result.reliability = 0.85;
      result.direction = PATTERN_BEARISH;
      result.type = PATTERN_TRIPLE;
      result.confidence = (result.strength + result.reliability) / 2.0;
      
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف كتلة التقدم (Advance Block)                                 |
//+------------------------------------------------------------------+
bool CSoldierCrowPatterns::DetectAdvanceBlock(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشموع الثلاث يجب أن تكون صعودية
   bool allBullish = true;
   for(int i = 0; i < 3; i++)
   {
      int candleIdx = idx - 2 + i;
      if(close[candleIdx] <= open[candleIdx])
      {
         allBullish = false;
         break;
      }
   }
   
   if(!allBullish) return false;
   
   // التحقق من تناقص حجم الأجسام (إشارة ضعف)
   double body1 = MathAbs(close[idx-2] - open[idx-2]);
   double body2 = MathAbs(close[idx-1] - open[idx-1]);
   double body3 = MathAbs(close[idx] - open[idx]);
   
   // كل جسم يجب أن يكون أصغر من السابق أو متساوي
   if(body2 <= body1 && body3 <= body2)
   {
      // التحقق من الظلال العلوية المتزايدة
      double upperShadow1 = high[idx-2] - MathMax(open[idx-2], close[idx-2]);
      double upperShadow2 = high[idx-1] - MathMax(open[idx-1], close[idx-1]);
      double upperShadow3 = high[idx] - MathMax(open[idx], close[idx]);
      
      if(upperShadow2 >= upperShadow1 && upperShadow3 >= upperShadow2)
      {
         result.patternName = "Advance Block";
         result.strength = 1.5;
         result.reliability = 0.70;
         result.direction = PATTERN_BEARISH; // انعكاس هبوطي محتمل
         result.type = PATTERN_TRIPLE;
         result.confidence = (result.strength + result.reliability) / 2.0;
         
         return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| كشف نمط التداول (Deliberation Pattern)                          |
//+------------------------------------------------------------------+
bool CSoldierCrowPatterns::DetectDeliberationPattern(const int idx, const double &open[], const double &high[], 
                                                    const double &low[], const double &close[], 
                                                    SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // الشمعتان الأوليان يجب أن تكونا صعوديتين قويتين
   bool first_strong = IsStrongCandle(open[idx-2], high[idx-2], low[idx-2], close[idx-2]) && 
                       close[idx-2] > open[idx-2];
   bool second_strong = IsStrongCandle(open[idx-1], high[idx-1], low[idx-1], close[idx-1]) && 
                        close[idx-1] > open[idx-1];
   
   if(!first_strong || !second_strong) return false;
   
   // الشمعة الثالثة يجب أن تكون صعودية لكن ضعيفة أو متردد
   bool third_bullish = close[idx] > open[idx];
   if(!third_bullish) return false;
   
   // الشمعة الثالثة يجب أن تفتح عالياً لكن لا تحرز تقدماً كبيراً
   bool opens_high = open[idx] > close[idx-1] * 0.99; // فتح قريب من إغلاق السابقة
   double third_body = MathAbs(close[idx] - open[idx]);
   double second_body = MathAbs(close[idx-1] - open[idx-1]);
   bool small_progress = third_body < second_body * 0.5; // جسم أصغر بكثير
   
   // ظل علوي طويل في الشمعة الثالثة يشير للتردد
   double upper_shadow = high[idx] - MathMax(open[idx], close[idx]);
   double range = high[idx] - low[idx];
   bool long_upper_shadow = (range > 0) && (upper_shadow > range * 0.4);
   
   if(opens_high && small_progress && long_upper_shadow)
   {
      result.patternName = "Deliberation Pattern";
      result.strength = 1.2;
      result.reliability = 0.65;
      result.direction = PATTERN_BEARISH; // تحذير من انعكاس محتمل
      result.type = PATTERN_TRIPLE;
      result.confidence = (result.strength + result.reliability) / 2.0;
      
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| التحقق من النمط التدريجي                                        |
//+------------------------------------------------------------------+
bool CSoldierCrowPatterns::IsProgressivePattern(const double &open[], const double &close[], int start, int count)
{
   if(count < 2) return true;
   
   for(int i = 1; i < count; i++)
   {
      // للنمط الصعودي: كل إغلاق أعلى من السابق
      if(close[start] > open[start]) // النمط صعودي
      {
         if(close[start + i] <= close[start + i - 1])
            return false;
      }
      // للنمط الهبوطي: كل إغلاق أقل من السابق
      else if(close[start] < open[start]) // النمط هبوطي
      {
         if(close[start + i] >= close[start + i - 1])
            return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من تشابه الأجسام                                         |
//+------------------------------------------------------------------+
bool CSoldierCrowPatterns::HasSimilarBodies(const double &open[], const double &close[], int start, int count)
{
   if(count < 2) return true;
   
   double firstBody = MathAbs(close[start] - open[start]);
   
   for(int i = 1; i < count; i++)
   {
      double currentBody = MathAbs(close[start + i] - open[start + i]);
      double ratio = (firstBody > 0) ? currentBody / firstBody : 1.0;
      
      // يجب أن تكون الأجسام متشابهة (بين 70% و 130%)
      if(ratio < 0.7 || ratio > 1.3)
         return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من قوة الشمعة                                            |
//+------------------------------------------------------------------+
bool CSoldierCrowPatterns::IsStrongCandle(const double open, const double high, const double low, const double close)
{
   double bodyRatio = CalculateBodyRatio(open, high, low, close);
   return bodyRatio >= m_minBodySize;
}

//+------------------------------------------------------------------+
//| حساب نسبة الجسم                                                 |
//+------------------------------------------------------------------+
double CSoldierCrowPatterns::CalculateBodyRatio(const double open, const double high, const double low, const double close)
{
   double range = high - low;
   if(range == 0) return 0.0;
   
   double body = MathAbs(close - open);
   return body / range;
}
