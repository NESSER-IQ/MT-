//+------------------------------------------------------------------+
//|                                          SpinningTopPatterns.mqh |
//|                        حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//|                                       https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\Base\CandlePattern.mqh"
#include "..\Base\CandleUtils.mqh"

//+------------------------------------------------------------------+
//| القمة الدوارة الصاعدة - شمعة بجسم صغير وظلال طويلة                |
//+------------------------------------------------------------------+
class CBullishSpinningTopPattern : public CCandlePattern
{
private:
   double m_maxBodyRatio;           // الحد الأقصى لنسبة الجسم
   double m_minShadowRatio;         // الحد الأدنى لنسبة الظلال
   double m_balanceThreshold;       // عتبة التوازن بين الظلال
   
public:
                     CBullishSpinningTopPattern();
                     ~CBullishSpinningTopPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            AreShadowsBalanced(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| القمة الدوارة الهابطة                                             |
//+------------------------------------------------------------------+
class CBearishSpinningTopPattern : public CCandlePattern
{
private:
   double m_maxBodyRatio;
   double m_minShadowRatio;
   double m_balanceThreshold;
   
public:
                     CBearishSpinningTopPattern();
                     ~CBearishSpinningTopPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            AreShadowsBalanced(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| القمة الدوارة المحايدة                                            |
//+------------------------------------------------------------------+
class CNeutralSpinningTopPattern : public CCandlePattern
{
private:
   double m_maxBodyRatio;
   double m_minShadowRatio;
   double m_perfectBalanceThreshold;
   
public:
                     CNeutralSpinningTopPattern();
                     ~CNeutralSpinningTopPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
};

//+------------------------------------------------------------------+
//| القمة الدوارة عالية الموج - تقلبات شديدة                          |
//+------------------------------------------------------------------+
class CHighWaveSpinningTopPattern : public CCandlePattern
{
private:
   double m_maxBodyRatio;
   double m_minShadowRatio;
   double m_highWaveThreshold;
   
public:
                     CHighWaveSpinningTopPattern();
                     ~CHighWaveSpinningTopPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
};

//+------------------------------------------------------------------+
//| تنفيذ القمة الدوارة الصاعدة                                       |
//+------------------------------------------------------------------+
CBullishSpinningTopPattern::CBullishSpinningTopPattern() : 
   CCandlePattern("القمة الدوارة الصاعدة", PATTERN_SINGLE, PATTERN_BULLISH, PATTERN_STRENGTH_MEDIUM, 
                  1, 0.60, "شمعة صاعدة بجسم صغير وظلال طويلة تشير لعدم اليقين", clrLightGreen)
{
   m_maxBodyRatio = 0.3;        // الجسم لا يزيد عن 30% من المدى
   m_minShadowRatio = 1.0;      // الظلال مساوية للجسم على الأقل
   m_balanceThreshold = 0.3;    // عتبة التوازن بين الظلال
}

CBullishSpinningTopPattern::~CBullishSpinningTopPattern() {}

bool CBullishSpinningTopPattern::Detect(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   // يجب أن تكون شمعة صاعدة
   if(!CCandleUtils::IsBullish(open[idx], close[idx]))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(totalRange <= 0 || body <= 0)
      return false;
      
   // فحص نسبة الجسم الصغير
   if(body / totalRange > m_maxBodyRatio)
      return false;
      
   // فحص الظلال الطويلة
   if(upperShadow < body * m_minShadowRatio || lowerShadow < body * m_minShadowRatio)
      return false;
      
   // فحص توازن الظلال
   if(!AreShadowsBalanced(idx, open, high, low, close))
      return false;
      
   return true;
}

bool CBullishSpinningTopPattern::AreShadowsBalanced(const int idx, const double &open[], const double &high[], 
                                                  const double &low[], const double &close[])
{
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(upperShadow <= 0 || lowerShadow <= 0)
      return false;
      
   double ratio = (upperShadow > lowerShadow) ? lowerShadow / upperShadow : upperShadow / lowerShadow;
   return ratio >= m_balanceThreshold; // نسبة التوازن
}

double CBullishSpinningTopPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                                 const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة أكبر كلما كانت الظلال أطول
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   double avgShadow = (upperShadow + lowerShadow) / 2.0;
   if(avgShadow > body * 2.0)
      strength += 0.5;
      
   // قوة إضافية من التوازن المثالي
   double shadowRatio = (upperShadow > lowerShadow) ? lowerShadow / upperShadow : upperShadow / lowerShadow;
   if(shadowRatio > 0.8)
      strength += 0.3;
      
   return MathMin(3.0, strength);
}

SPatternSignal CBullishSpinningTopPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                        const double &open[], const double &high[], 
                                                        const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   // القمة الدوارة إشارة عدم يقين - انتظار تأكيد
   signal.type = SIGNAL_NONE;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   // نقاط مرجعية للكسر
   signal.entryPrice = (high[idx] + low[idx]) / 2.0;
   signal.stopLoss = low[idx];
   signal.takeProfit = high[idx];
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ القمة الدوارة الهابطة                                       |
//+------------------------------------------------------------------+
CBearishSpinningTopPattern::CBearishSpinningTopPattern() : 
   CCandlePattern("القمة الدوارة الهابطة", PATTERN_SINGLE, PATTERN_BEARISH, PATTERN_STRENGTH_MEDIUM, 
                  1, 0.60, "شمعة هابطة بجسم صغير وظلال طويلة تشير لعدم اليقين", clrLightCoral)
{
   m_maxBodyRatio = 0.3;
   m_minShadowRatio = 1.0;
   m_balanceThreshold = 0.3;
}

CBearishSpinningTopPattern::~CBearishSpinningTopPattern() {}

bool CBearishSpinningTopPattern::Detect(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   // يجب أن تكون شمعة هابطة
   if(!CCandleUtils::IsBearish(open[idx], close[idx]))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(totalRange <= 0 || body <= 0)
      return false;
      
   if(body / totalRange > m_maxBodyRatio)
      return false;
      
   if(upperShadow < body * m_minShadowRatio || lowerShadow < body * m_minShadowRatio)
      return false;
      
   if(!AreShadowsBalanced(idx, open, high, low, close))
      return false;
      
   return true;
}

bool CBearishSpinningTopPattern::AreShadowsBalanced(const int idx, const double &open[], const double &high[], 
                                                  const double &low[], const double &close[])
{
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(upperShadow <= 0 || lowerShadow <= 0)
      return false;
      
   double ratio = (upperShadow > lowerShadow) ? lowerShadow / upperShadow : upperShadow / lowerShadow;
   return ratio >= m_balanceThreshold;
}

double CBearishSpinningTopPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                                 const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   double avgShadow = (upperShadow + lowerShadow) / 2.0;
   if(avgShadow > body * 2.0)
      strength += 0.5;
      
   double shadowRatio = (upperShadow > lowerShadow) ? lowerShadow / upperShadow : upperShadow / lowerShadow;
   if(shadowRatio > 0.8)
      strength += 0.3;
      
   return MathMin(3.0, strength);
}

SPatternSignal CBearishSpinningTopPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                        const double &open[], const double &high[], 
                                                        const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   signal.type = SIGNAL_NONE;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   signal.entryPrice = (high[idx] + low[idx]) / 2.0;
   signal.stopLoss = high[idx];
   signal.takeProfit = low[idx];
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ القمة الدوارة المحايدة                                       |
//+------------------------------------------------------------------+
CNeutralSpinningTopPattern::CNeutralSpinningTopPattern() : 
   CCandlePattern("القمة الدوارة المحايدة", PATTERN_SINGLE, PATTERN_NEUTRAL, PATTERN_STRENGTH_MEDIUM, 
                  1, 0.65, "شمعة محايدة بجسم صغير وظلال متوازنة", clrGray)
{
   m_maxBodyRatio = 0.25;
   m_minShadowRatio = 1.2;
   m_perfectBalanceThreshold = 0.8;
}

CNeutralSpinningTopPattern::~CNeutralSpinningTopPattern() {}

bool CNeutralSpinningTopPattern::Detect(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(totalRange <= 0 || body <= 0)
      return false;
      
   // جسم صغير جداً
   if(body / totalRange > m_maxBodyRatio)
      return false;
      
   // ظلال طويلة
   if(upperShadow < body * m_minShadowRatio || lowerShadow < body * m_minShadowRatio)
      return false;
      
   // توازن مثالي في الظلال
   double shadowRatio = (upperShadow > lowerShadow) ? lowerShadow / upperShadow : upperShadow / lowerShadow;
   if(shadowRatio < m_perfectBalanceThreshold)
      return false;
      
   return true;
}

double CNeutralSpinningTopPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                                 const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة أكبر من التوازن المثالي
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   double shadowRatio = (upperShadow > lowerShadow) ? lowerShadow / upperShadow : upperShadow / lowerShadow;
   
   if(shadowRatio > 0.95)
      strength += 1.0;
   else if(shadowRatio > 0.9)
      strength += 0.5;
      
   return MathMin(3.0, strength);
}

SPatternSignal CNeutralSpinningTopPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                        const double &open[], const double &high[], 
                                                        const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   signal.type = SIGNAL_NONE;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   signal.entryPrice = (open[idx] + close[idx]) / 2.0;
   signal.stopLoss = 0.0;
   signal.takeProfit = 0.0;
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ القمة الدوارة عالية الموج                                   |
//+------------------------------------------------------------------+
CHighWaveSpinningTopPattern::CHighWaveSpinningTopPattern() : 
   CCandlePattern("القمة الدوارة عالية الموج", PATTERN_SINGLE, PATTERN_NEUTRAL, PATTERN_STRENGTH_STRONG, 
                  1, 0.75, "شمعة بتقلبات شديدة وعدم يقين عالي", clrOrange)
{
   m_maxBodyRatio = 0.2;
   m_minShadowRatio = 2.0;
   m_highWaveThreshold = 1.5;
}

CHighWaveSpinningTopPattern::~CHighWaveSpinningTopPattern() {}

bool CHighWaveSpinningTopPattern::Detect(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 5, idx))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(totalRange <= 0 || body <= 0)
      return false;
      
   // جسم صغير جداً
   if(body / totalRange > m_maxBodyRatio)
      return false;
      
   // ظلال طويلة جداً
   if(upperShadow < body * m_minShadowRatio || lowerShadow < body * m_minShadowRatio)
      return false;
      
   // المدى أكبر من المتوسط
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 14, idx + 1);
   if(totalRange < avgRange * m_highWaveThreshold)
      return false;
      
   return true;
}

double CHighWaveSpinningTopPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                                  const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة من حجم المدى
   double totalRange = high[idx] - low[idx];
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 14, idx + 1);
   
   if(totalRange > avgRange * 2.5)
      strength += 1.0;
   else if(totalRange > avgRange * 2.0)
      strength += 0.5;
      
   // قوة من الحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.5)
         strength += 0.5;
   }
      
   return MathMin(3.0, strength);
}

SPatternSignal CHighWaveSpinningTopPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                         const double &open[], const double &high[], 
                                                         const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   // إشارة عدم يقين قوية - توقع تقلبات
   signal.type = SIGNAL_NONE;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   // نطاق التداول المتوقع
   double range = high[idx] - low[idx];
   signal.entryPrice = (high[idx] + low[idx]) / 2.0;
   signal.stopLoss = low[idx] - range * 0.1;
   signal.takeProfit = high[idx] + range * 0.1;
   
   return signal;
}