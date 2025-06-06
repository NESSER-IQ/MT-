//+------------------------------------------------------------------+
//|                                                StarPatterns.mqh |
//|                                   أنماط النجوم المزدوجة اليابانية |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "../../Base/PatternDetector.mqh"
#include "../../Base/CandleUtils.mqh"

//+------------------------------------------------------------------+
//| فئة نجمة الدوجي                                                |
//+------------------------------------------------------------------+
class CDojiStar : public CPatternDetector
{
private:
   double            m_dojiThreshold;         // حد الدوجي
   double            m_minGapSize;            // الحد الأدنى لحجم الفجوة
   double            m_minFirstBodyRatio;     // نسبة الجسم الأول الدنيا
   bool              m_requireGap;            // يتطلب فجوة
   
public:
                     CDojiStar();
                     ~CDojiStar();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetDojiThreshold(double threshold) { m_dojiThreshold = MathMax(0.01, MathMin(0.1, threshold)); }
   void              SetMinGapSize(double size) { m_minGapSize = MathMax(0.001, MathMin(0.02, size)); }
   void              SetMinFirstBodyRatio(double ratio) { m_minFirstBodyRatio = MathMax(0.4, MathMin(0.9, ratio)); }
   void              SetRequireGap(bool require) { m_requireGap = require; }
   
   // دوال مساعدة
   bool              IsValidDojiStar(const int idx, const double &open[], const double &high[], 
                                   const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   ENUM_PATTERN_DIRECTION DetermineDirection(const int idx, const double &open[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة نمط النجمة الساقطة                                          |
//+------------------------------------------------------------------+
class CShootingStarPattern : public CPatternDetector
{
private:
   double            m_minUpperShadowRatio;   // نسبة الظل العلوي الدنيا
   double            m_maxLowerShadowRatio;   // نسبة الظل السفلي القصوى
   double            m_maxBodyRatio;          // نسبة الجسم القصوى
   double            m_minFirstBodyRatio;     // نسبة الجسم الأول الدنيا
   bool              m_requireUptrend;        // يتطلب اتجاه صاعد
   
public:
                     CShootingStarPattern();
                     ~CShootingStarPattern();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMinUpperShadowRatio(double ratio) { m_minUpperShadowRatio = MathMax(1.5, MathMin(4.0, ratio)); }
   void              SetMaxLowerShadowRatio(double ratio) { m_maxLowerShadowRatio = MathMax(0.1, MathMin(0.5, ratio)); }
   void              SetMaxBodyRatio(double ratio) { m_maxBodyRatio = MathMax(0.2, MathMin(0.5, ratio)); }
   void              SetMinFirstBodyRatio(double ratio) { m_minFirstBodyRatio = MathMax(0.4, MathMin(0.9, ratio)); }
   void              SetRequireUptrend(bool require) { m_requireUptrend = require; }
   
   // دوال مساعدة
   bool              IsValidShootingStarPattern(const int idx, const double &open[], const double &high[], 
                                              const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   bool              IsShootingStar(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| فئة نجمة المطرقة                                               |
//+------------------------------------------------------------------+
class CHammerStar : public CPatternDetector
{
private:
   double            m_minLowerShadowRatio;   // نسبة الظل السفلي الدنيا
   double            m_maxUpperShadowRatio;   // نسبة الظل العلوي القصوى
   double            m_maxBodyRatio;          // نسبة الجسم القصوى
   double            m_minFirstBodyRatio;     // نسبة الجسم الأول الدنيا
   bool              m_requireDowntrend;      // يتطلب اتجاه هابط
   
public:
                     CHammerStar();
                     ~CHammerStar();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
                                     
   // إعدادات النمط
   void              SetMinLowerShadowRatio(double ratio) { m_minLowerShadowRatio = MathMax(1.5, MathMin(4.0, ratio)); }
   void              SetMaxUpperShadowRatio(double ratio) { m_maxUpperShadowRatio = MathMax(0.1, MathMin(0.5, ratio)); }
   void              SetMaxBodyRatio(double ratio) { m_maxBodyRatio = MathMax(0.2, MathMin(0.5, ratio)); }
   void              SetMinFirstBodyRatio(double ratio) { m_minFirstBodyRatio = MathMax(0.4, MathMin(0.9, ratio)); }
   void              SetRequireDowntrend(bool require) { m_requireDowntrend = require; }
   
   // دوال مساعدة
   bool              IsValidHammerStar(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   double            CalculateStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[]);
   bool              IsHammer(const int idx, const double &open[], const double &high[], 
                            const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| محرك أنماط النجوم المزدوجة الموحد                               |
//+------------------------------------------------------------------+
class CStarPatterns : public CPatternDetector
{
private:
   CDojiStar*           m_dojiStar;
   CShootingStarPattern* m_shootingStarPattern;
   CHammerStar*         m_hammerStar;
   
   bool                 m_enableDojiStar;
   bool                 m_enableShootingStarPattern;
   bool                 m_enableHammerStar;
   
   // دالة مساعدة للتحقق من صحة المؤشر
   bool                 IsValidPointer(void* ptr);
   
public:
                     CStarPatterns();
                     ~CStarPatterns();
   
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   virtual void      Deinitialize();
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // إعدادات التفعيل
   void              EnableDojiStar(bool enable) { m_enableDojiStar = enable; }
   void              EnableShootingStarPattern(bool enable) { m_enableShootingStarPattern = enable; }
   void              EnableHammerStar(bool enable) { m_enableHammerStar = enable; }
   void              EnableAllStarPatterns(bool enable);
   
   // دوال الوصول لكائنات الأنماط الفرعية
   CDojiStar*        GetDojiStar() { return m_dojiStar; }
   CShootingStarPattern* GetShootingStarPattern() { return m_shootingStarPattern; }
   CHammerStar*      GetHammerStar() { return m_hammerStar; }
};

//+------------------------------------------------------------------+
//| تنفيذ CDojiStar                                                 |
//+------------------------------------------------------------------+
CDojiStar::CDojiStar()
{
   m_dojiThreshold = 0.05;      // 5% حد الدوجي
   m_minGapSize = 0.002;        // 0.2% حد أدنى للفجوة
   m_minFirstBodyRatio = 0.6;   // 60% نسبة جسم أول دنيا
   m_requireGap = true;         // يتطلب فجوة افتراضياً
}

CDojiStar::~CDojiStar()
{
}

bool CDojiStar::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

ENUM_PATTERN_DIRECTION CDojiStar::DetermineDirection(const int idx, const double &open[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return PATTERN_NEUTRAL;
   
   // الاتجاه يحدد بناءً على الشمعة الأولى (عكسها)
   bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
   return firstBullish ? PATTERN_BEARISH : PATTERN_BULLISH;
}

bool CDojiStar::IsValidDojiStar(const int idx, const double &open[], const double &high[], 
                               const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون قوية
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   
   if(firstRange > 0 && (firstBodySize / firstRange) < m_minFirstBodyRatio)
      return false;
   
   // الشمعة الثانية يجب أن تكون دوجي
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 10, idx);
   if(!CCandleUtils::IsDoji(open[idx], close[idx], avgRange, m_dojiThreshold))
      return false;
   
   // فحص الفجوة إذا كان مطلوباً
   if(m_requireGap)
   {
      bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
      double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
      double gapSize = 0.0;
      
      if(firstBullish)
      {
         // فجوة صعودية - يجب أن يفتح الدوجي أعلى من إغلاق الشمعة الأولى
         gapSize = (open[idx] - close[idx+1]) / avgPrice;
      }
      else
      {
         // فجوة هبوطية - يجب أن يفتح الدوجي أسفل إغلاق الشمعة الأولى
         gapSize = (close[idx+1] - open[idx]) / avgPrice;
      }
      
      if(gapSize < m_minGapSize)
         return false;
   }
   
   return true;
}

double CDojiStar::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                   const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الشمعة الأولى
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double firstStrength = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   
   // دقة الدوجي (كلما كان الجسم أصغر، كانت القوة أكبر)
   double dojiBodySize = MathAbs(close[idx] - open[idx]);
   double dojiRange = high[idx] - low[idx];
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 10, idx);
   double dojiAccuracy = 1.0 - (dojiBodySize / (avgRange * m_dojiThreshold));
   dojiAccuracy = MathMax(0.0, MathMin(1.0, dojiAccuracy));
   
   // قوة الفجوة
   double gapStrength = 0.0;
   if(m_requireGap)
   {
      bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
      double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
      double gapSize = 0.0;
      
      if(firstBullish)
         gapSize = (open[idx] - close[idx+1]) / avgPrice;
      else
         gapSize = (close[idx+1] - open[idx]) / avgPrice;
      
      gapStrength = MathMin(1.0, gapSize / (m_minGapSize * 3.0));
   }
   else
   {
      gapStrength = 0.5; // حيادي
   }
   
   // القوة الإجمالية
   double totalStrength = 1.2 + firstStrength * 0.6 + dojiAccuracy * 0.8 + gapStrength * 0.4;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CDojiStar::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                const double &open[], const double &high[], const double &low[], 
                                const double &close[], const long &volume[], 
                                SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidDojiStar(idx, open, high, low, close))
      return 0;
   
   // تحديد الاتجاه
   ENUM_PATTERN_DIRECTION direction = DetermineDirection(idx, open, close);
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "نجمة الدوجي";
   result.direction = direction;
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.65 + (result.strength - 1.0) * 0.1; // موثوقية جيدة
   result.confidence = MathMin(1.0, result.reliability * 1.1);
   result.barIndex = idx;
   
   // تعامل آمن مع دالة iTime
   datetime bar_time = 0;
   if(StringLen(symbol) > 0)
   {
      bar_time = iTime(symbol, timeframe, idx);
   }
   else
   {
      bar_time = iTime(_Symbol, timeframe, idx);
   }
   result.time = bar_time;
   
   ArrayResize(results, 1);
   results[0] = result;
   
   return 1;
}

//+------------------------------------------------------------------+
//| تنفيذ CShootingStarPattern                                      |
//+------------------------------------------------------------------+
CShootingStarPattern::CShootingStarPattern()
{
   m_minUpperShadowRatio = 2.0; // الظل العلوي يجب أن يكون ضعف الجسم
   m_maxLowerShadowRatio = 0.2; // الظل السفلي لا يزيد عن 20% من الجسم
   m_maxBodyRatio = 0.3;        // الجسم لا يزيد عن 30% من المدى
   m_minFirstBodyRatio = 0.6;   // الشمعة الأولى قوية
   m_requireUptrend = true;     // يتطلب اتجاه صاعد
}

CShootingStarPattern::~CShootingStarPattern()
{
}

bool CShootingStarPattern::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CShootingStarPattern::IsShootingStar(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[])
{
   if(idx >= ArraySize(open)) return false;
   
   double bodySize = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(range <= 0 || bodySize <= 0) return false;
   
   // فحص نسبة الجسم
   if((bodySize / range) > m_maxBodyRatio) return false;
   
   // فحص الظل العلوي
   if(upperShadow < bodySize * m_minUpperShadowRatio) return false;
   
   // فحص الظل السفلي
   if(lowerShadow > bodySize * m_maxLowerShadowRatio) return false;
   
   return true;
}

bool CShootingStarPattern::IsValidShootingStarPattern(const int idx, const double &open[], const double &high[], 
                                                    const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون صعودية وقوية (إذا كان الاتجاه مطلوب)
   if(m_requireUptrend)
   {
      bool firstBullish = CCandleUtils::IsBullish(open[idx+1], close[idx+1]);
      if(!firstBullish) return false;
      
      double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
      double firstRange = high[idx+1] - low[idx+1];
      
      if(firstRange > 0 && (firstBodySize / firstRange) < m_minFirstBodyRatio)
         return false;
   }
   
   // الشمعة الثانية يجب أن تكون نجمة ساقطة
   if(!IsShootingStar(idx, open, high, low, close))
      return false;
   
   // يجب أن تفتح الشمعة الثانية بفجوة صعودية
   if(open[idx] <= close[idx+1])
      return false;
   
   return true;
}

double CShootingStarPattern::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الشمعة الأولى
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double firstStrength = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   
   // قوة النجمة الساقطة
   double bodySize = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // نسبة الظل العلوي إلى الجسم
   double upperShadowRatio = (bodySize > 0) ? upperShadow / bodySize : 0.0;
   double upperShadowStrength = MathMin(1.0, upperShadowRatio / (m_minUpperShadowRatio * 2.0));
   
   // صغر الظل السفلي
   double lowerShadowRatio = (bodySize > 0) ? lowerShadow / bodySize : 0.0;
   double lowerShadowStrength = 1.0 - MathMin(1.0, lowerShadowRatio / m_maxLowerShadowRatio);
   
   // صغر الجسم
   double bodyRatio = (range > 0) ? bodySize / range : 0.0;
   double bodyStrength = 1.0 - (bodyRatio / m_maxBodyRatio);
   bodyStrength = MathMax(0.0, MathMin(1.0, bodyStrength));
   
   // حجم الفجوة
   double gapSize = open[idx] - close[idx+1];
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   double gapStrength = (avgPrice > 0) ? MathMin(1.0, gapSize / (avgPrice * 0.01)) : 0.0;
   
   // القوة الإجمالية
   double totalStrength = 1.3 + firstStrength * 0.3 + upperShadowStrength * 0.4 + 
                         lowerShadowStrength * 0.4 + bodyStrength * 0.5 + gapStrength * 0.3;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CShootingStarPattern::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                          const double &open[], const double &high[], const double &low[], 
                                          const double &close[], const long &volume[], 
                                          SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidShootingStarPattern(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "نمط النجمة الساقطة";
   result.direction = PATTERN_BEARISH; // إشارة هبوطية
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.70 + (result.strength - 1.0) * 0.1; // موثوقية عالية
   result.confidence = MathMin(1.0, result.reliability * 1.15);
   result.barIndex = idx;
   
   // تعامل آمن مع دالة iTime
   datetime bar_time = 0;
   if(StringLen(symbol) > 0)
   {
      bar_time = iTime(symbol, timeframe, idx);
   }
   else
   {
      bar_time = iTime(_Symbol, timeframe, idx);
   }
   result.time = bar_time;
   
   ArrayResize(results, 1);
   results[0] = result;
   
   return 1;
}

//+------------------------------------------------------------------+
//| تنفيذ CHammerStar                                               |
//+------------------------------------------------------------------+
CHammerStar::CHammerStar()
{
   m_minLowerShadowRatio = 2.0; // الظل السفلي يجب أن يكون ضعف الجسم
   m_maxUpperShadowRatio = 0.2; // الظل العلوي لا يزيد عن 20% من الجسم
   m_maxBodyRatio = 0.3;        // الجسم لا يزيد عن 30% من المدى
   m_minFirstBodyRatio = 0.6;   // الشمعة الأولى قوية
   m_requireDowntrend = true;   // يتطلب اتجاه هابط
}

CHammerStar::~CHammerStar()
{
}

bool CHammerStar::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

bool CHammerStar::IsHammer(const int idx, const double &open[], const double &high[], 
                         const double &low[], const double &close[])
{
   if(idx >= ArraySize(open)) return false;
   
   double bodySize = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(range <= 0 || bodySize <= 0) return false;
   
   // فحص نسبة الجسم
   if((bodySize / range) > m_maxBodyRatio) return false;
   
   // فحص الظل السفلي
   if(lowerShadow < bodySize * m_minLowerShadowRatio) return false;
   
   // فحص الظل العلوي
   if(upperShadow > bodySize * m_maxUpperShadowRatio) return false;
   
   return true;
}

bool CHammerStar::IsValidHammerStar(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[])
{
   // التحقق من صحة الفهارس
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open))
      return false;
   
   // الشمعة الأولى يجب أن تكون هبوطية وقوية (إذا كان الاتجاه مطلوب)
   if(m_requireDowntrend)
   {
      bool firstBearish = CCandleUtils::IsBearish(open[idx+1], close[idx+1]);
      if(!firstBearish) return false;
      
      double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
      double firstRange = high[idx+1] - low[idx+1];
      
      if(firstRange > 0 && (firstBodySize / firstRange) < m_minFirstBodyRatio)
         return false;
   }
   
   // الشمعة الثانية يجب أن تكون مطرقة
   if(!IsHammer(idx, open, high, low, close))
      return false;
   
   // يجب أن تفتح الشمعة الثانية بفجوة هبوطية
   if(open[idx] >= close[idx+1])
      return false;
   
   return true;
}

double CHammerStar::CalculateStrength(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[])
{
   if(idx < 1 || idx >= ArraySize(open) || (idx + 1) >= ArraySize(open)) 
      return 0.0;
   
   // قوة الشمعة الأولى
   double firstBodySize = MathAbs(close[idx+1] - open[idx+1]);
   double firstRange = high[idx+1] - low[idx+1];
   double firstStrength = (firstRange > 0) ? firstBodySize / firstRange : 0.0;
   
   // قوة المطرقة
   double bodySize = MathAbs(close[idx] - open[idx]);
   double range = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // نسبة الظل السفلي إلى الجسم
   double lowerShadowRatio = (bodySize > 0) ? lowerShadow / bodySize : 0.0;
   double lowerShadowStrength = MathMin(1.0, lowerShadowRatio / (m_minLowerShadowRatio * 2.0));
   
   // صغر الظل العلوي
   double upperShadowRatio = (bodySize > 0) ? upperShadow / bodySize : 0.0;
   double upperShadowStrength = 1.0 - MathMin(1.0, upperShadowRatio / m_maxUpperShadowRatio);
   
   // صغر الجسم
   double bodyRatio = (range > 0) ? bodySize / range : 0.0;
   double bodyStrength = 1.0 - (bodyRatio / m_maxBodyRatio);
   bodyStrength = MathMax(0.0, MathMin(1.0, bodyStrength));
   
   // حجم الفجوة
   double gapSize = close[idx+1] - open[idx];
   double avgPrice = (high[idx+1] + low[idx+1] + high[idx] + low[idx]) / 4.0;
   double gapStrength = (avgPrice > 0) ? MathMin(1.0, gapSize / (avgPrice * 0.01)) : 0.0;
   
   // القوة الإجمالية
   double totalStrength = 1.3 + firstStrength * 0.3 + lowerShadowStrength * 0.4 + 
                         upperShadowStrength * 0.4 + bodyStrength * 0.5 + gapStrength * 0.3;
   
   return MathMin(3.0, MathMax(1.0, totalStrength));
}

int CHammerStar::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                 const double &open[], const double &high[], const double &low[], 
                                 const double &close[], const long &volume[], 
                                 SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   
   if(!IsValidHammerStar(idx, open, high, low, close))
      return 0;
   
   // إنشاء نتيجة النمط
   SPatternDetectionResult result;
   result.patternName = "نجمة المطرقة";
   result.direction = PATTERN_BULLISH; // إشارة صعودية
   result.type = PATTERN_DOUBLE;
   result.strength = CalculateStrength(idx, open, high, low, close);
   result.reliability = 0.70 + (result.strength - 1.0) * 0.1; // موثوقية عالية
   result.confidence = MathMin(1.0, result.reliability * 1.15);
   result.barIndex = idx;
   
   // تعامل آمن مع دالة iTime
   datetime bar_time = 0;
   if(StringLen(symbol) > 0)
   {
      bar_time = iTime(symbol, timeframe, idx);
   }
   else
   {
      bar_time = iTime(_Symbol, timeframe, idx);
   }
   result.time = bar_time;
   
   ArrayResize(results, 1);
   results[0] = result;
   
   return 1;
}

//+------------------------------------------------------------------+
//| تنفيذ CStarPatterns                                             |
//+------------------------------------------------------------------+
CStarPatterns::CStarPatterns()
{
   m_dojiStar = NULL;
   m_shootingStarPattern = NULL;
   m_hammerStar = NULL;
   
   m_enableDojiStar = true;
   m_enableShootingStarPattern = true;
   m_enableHammerStar = true;
}

CStarPatterns::~CStarPatterns()
{
   Deinitialize();
}

bool CStarPatterns::IsValidPointer(void* ptr)
{
   return (CheckPointer(ptr) != POINTER_INVALID);
}

bool CStarPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   if(!CPatternDetector::Initialize(symbol, timeframe))
      return false;
   
   // إنشاء كائنات الأنماط
   m_dojiStar = new CDojiStar();
   m_shootingStarPattern = new CShootingStarPattern();
   m_hammerStar = new CHammerStar();
   
   // تهيئة جميع الأنماط
   bool success = true;
   if(IsValidPointer(m_dojiStar)) 
      success = success && m_dojiStar.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_shootingStarPattern)) 
      success = success && m_shootingStarPattern.Initialize(symbol, timeframe);
   else
      success = false;
      
   if(IsValidPointer(m_hammerStar)) 
      success = success && m_hammerStar.Initialize(symbol, timeframe);
   else
      success = false;
   
   return success;
}

void CStarPatterns::Deinitialize()
{
   if(IsValidPointer(m_dojiStar)) 
   { 
      delete m_dojiStar; 
      m_dojiStar = NULL; 
   }
   
   if(IsValidPointer(m_shootingStarPattern)) 
   { 
      delete m_shootingStarPattern; 
      m_shootingStarPattern = NULL; 
   }
   
   if(IsValidPointer(m_hammerStar)) 
   { 
      delete m_hammerStar; 
      m_hammerStar = NULL; 
   }
   
   CPatternDetector::Deinitialize();
}

void CStarPatterns::EnableAllStarPatterns(bool enable)
{
   m_enableDojiStar = enable;
   m_enableShootingStarPattern = enable;
   m_enableHammerStar = enable;
}

int CStarPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                   const double &open[], const double &high[], const double &low[], 
                                   const double &close[], const long &volume[], 
                                   SPatternDetectionResult &results[])
{
   ArrayResize(results, 0);
   SPatternDetectionResult tempResults[];
   int totalPatterns = 0;
   
   // كشف نجمة الدوجي
   if(m_enableDojiStar && IsValidPointer(m_dojiStar))
   {
      int patternCount = m_dojiStar.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         int currentSize = ArraySize(results);
         ArrayResize(results, currentSize + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[currentSize + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف نمط النجمة الساقطة
   if(m_enableShootingStarPattern && IsValidPointer(m_shootingStarPattern))
   {
      int patternCount = m_shootingStarPattern.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         int currentSize = ArraySize(results);
         ArrayResize(results, currentSize + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[currentSize + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   // كشف نجمة المطرقة
   if(m_enableHammerStar && IsValidPointer(m_hammerStar))
   {
      int patternCount = m_hammerStar.DetectAllPatterns(idx, symbol, timeframe, open, high, low, close, volume, tempResults);
      if(patternCount > 0)
      {
         int currentSize = ArraySize(results);
         ArrayResize(results, currentSize + patternCount);
         for(int i = 0; i < patternCount; i++)
         {
            results[currentSize + i] = tempResults[i];
         }
         totalPatterns += patternCount;
      }
   }
   
   return totalPatterns;
}
