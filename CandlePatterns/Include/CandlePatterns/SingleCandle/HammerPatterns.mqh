//+------------------------------------------------------------------+
//|                                              HammerPatterns.mqh |
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
//| المطرقة - نمط انعكاس صعودي في القيعان                            |
//+------------------------------------------------------------------+
class CHammerPattern : public CCandlePattern
{
private:
   double m_bodyRatio;              // نسبة الجسم إلى المدى الكلي
   double m_shadowRatio;            // نسبة الظل السفلي إلى الجسم
   double m_upperShadowLimit;       // الحد الأقصى للظل العلوي
   int    m_trendBars;              // عدد الشموع لتحديد الاتجاه
   
public:
                     CHammerPattern();
                     ~CHammerPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            IsInDowntrend(const int idx, const double &close[]);
   double          CalculateTrendStrength(const int idx, const double &close[]);
};

//+------------------------------------------------------------------+
//| المطرقة المعكوسة - نمط انعكاس صعودي محتمل في القيعان              |
//+------------------------------------------------------------------+
class CInvertedHammerPattern : public CCandlePattern
{
private:
   double m_bodyRatio;
   double m_shadowRatio;            // نسبة الظل العلوي إلى الجسم
   double m_lowerShadowLimit;       // الحد الأقصى للظل السفلي
   int    m_trendBars;
   
public:
                     CInvertedHammerPattern();
                     ~CInvertedHammerPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            IsInDowntrend(const int idx, const double &close[]);
   bool            RequiresConfirmation(const int idx, const double &open[], const double &close[]);
};

//+------------------------------------------------------------------+
//| الرجل المعلق - نمط انعكاس هبوطي في القمم                         |
//+------------------------------------------------------------------+
class CHangingManPattern : public CCandlePattern
{
private:
   double m_bodyRatio;
   double m_shadowRatio;            // نسبة الظل السفلي إلى الجسم
   double m_upperShadowLimit;
   int    m_trendBars;
   
public:
                     CHangingManPattern();
                     ~CHangingManPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            IsInUptrend(const int idx, const double &close[]);
   double          CalculateUptrendStrength(const int idx, const double &close[]);
};

//+------------------------------------------------------------------+
//| النجم الساقط - نمط انعكاس هبوطي قوي في القمم                     |
//+------------------------------------------------------------------+
class CShootingStarPattern : public CCandlePattern
{
private:
   double m_bodyRatio;
   double m_shadowRatio;            // نسبة الظل العلوي إلى الجسم
   double m_lowerShadowLimit;
   int    m_trendBars;
   
public:
                     CShootingStarPattern();
                     ~CShootingStarPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            IsInUptrend(const int idx, const double &close[]);
   bool            IsAtResistanceLevel(const int idx, const double &high[]);
};

//+------------------------------------------------------------------+
//| تنفيذ نمط المطرقة                                                |
//+------------------------------------------------------------------+
CHammerPattern::CHammerPattern() : 
   CCandlePattern("المطرقة", PATTERN_SINGLE, PATTERN_BULLISH, PATTERN_STRENGTH_STRONG, 
                  1, 0.78, "نمط انعكاس صعودي يظهر في نهاية الاتجاهات الهبوطية", clrLime)
{
   m_bodyRatio = 0.3;       // الجسم لا يزيد عن 30% من المدى
   m_shadowRatio = 2.0;     // الظل السفلي ضعف الجسم على الأقل
   m_upperShadowLimit = 0.1; // الظل العلوي محدود
   m_trendBars = 5;         // فحص 5 شموع للاتجاه
}

CHammerPattern::~CHammerPattern() {}

bool CHammerPattern::Detect(const int idx, const double &open[], const double &high[], 
                           const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, m_trendBars + 1, idx))
      return false;
      
   // حساب خصائص الشمعة
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   
   // تجنب القسمة على صفر
   if(totalRange <= 0 || body <= 0)
      return false;
      
   // فحص نسبة الجسم إلى المدى الكلي
   if(body / totalRange > m_bodyRatio)
      return false;
      
   // فحص نسبة الظل السفلي إلى الجسم
   if(lowerShadow < body * m_shadowRatio)
      return false;
      
   // فحص الظل العلوي (يجب أن يكون محدود)
   if(upperShadow > body * m_upperShadowLimit)
      return false;
      
   // فحص الاتجاه الهبوطي السابق
   if(!IsInDowntrend(idx, close))
      return false;
      
   return true;
}

bool CHammerPattern::IsInDowntrend(const int idx, const double &close[])
{
   if(idx + m_trendBars >= ArraySize(close))
      return false;
      
   // فحص الاتجاه الهبوطي
   int downCount = 0;
   double totalDecline = 0.0;
   
   for(int i = 1; i <= m_trendBars; i++)
   {
      if(close[idx + i] > close[idx + i - 1])
         downCount++;
         
      totalDecline += close[idx + i] - close[idx];
   }
   
   // على الأقل 60% من الشموع هبوطية وانخفاض إجمالي
   return (downCount >= m_trendBars * 0.6) && (totalDecline < 0);
}

double CHammerPattern::CalculateTrendStrength(const int idx, const double &close[])
{
   if(idx + m_trendBars >= ArraySize(close))
      return 0.0;
      
   double priceChange = (close[idx + m_trendBars] - close[idx]) / close[idx + m_trendBars];
   return MathAbs(priceChange);
}

double CHammerPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة أكبر بناءً على نسبة الظل السفلي
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   double shadowToBodyRatio = lowerShadow / body;
   if(shadowToBodyRatio > 3.0)
      strength += 1.0;
   else if(shadowToBodyRatio > 2.5)
      strength += 0.5;
      
   // قوة الاتجاه الهبوطي السابق
   double trendStrength = CalculateTrendStrength(idx, close);
   if(trendStrength > 0.05) // انخفاض 5% أو أكثر
      strength += 0.5;
      
   // تأكيد الحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.2)
         strength += 0.5;
   }
   
   // لون الشمعة (الصاعدة أقوى)
   if(CCandleUtils::IsBullish(open[idx], close[idx]))
      strength += 0.3;
      
   return MathMin(3.0, strength);
}

SPatternSignal CHammerPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                             const double &open[], const double &high[], 
                                             const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   signal.type = SIGNAL_BUY;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   // استراتيجية التداول
   double bodyTop = MathMax(open[idx], close[idx]);
   double range = high[idx] - low[idx];
   
   signal.entryPrice = bodyTop + range * 0.05; // دخول أعلى الجسم قليلاً
   signal.stopLoss = low[idx] - range * 0.1;   // وقف تحت أدنى سعر
   signal.takeProfit = signal.entryPrice + (signal.entryPrice - signal.stopLoss) * 2.5; // نسبة 1:2.5
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ نمط المطرقة المعكوسة                                        |
//+------------------------------------------------------------------+
CInvertedHammerPattern::CInvertedHammerPattern() : 
   CCandlePattern("المطرقة المعكوسة", PATTERN_SINGLE, PATTERN_BULLISH, PATTERN_STRENGTH_MEDIUM, 
                  1, 0.65, "نمط انعكاس صعودي محتمل يحتاج تأكيد", clrYellow)
{
   m_bodyRatio = 0.3;
   m_shadowRatio = 2.0;     // الظل العلوي ضعف الجسم
   m_lowerShadowLimit = 0.1;
   m_trendBars = 5;
}

CInvertedHammerPattern::~CInvertedHammerPattern() {}

bool CInvertedHammerPattern::Detect(const int idx, const double &open[], const double &high[], 
                                   const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, m_trendBars + 1, idx))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(totalRange <= 0 || body <= 0)
      return false;
      
   // فحص نسبة الجسم
   if(body / totalRange > m_bodyRatio)
      return false;
      
   // فحص الظل العلوي
   if(upperShadow < body * m_shadowRatio)
      return false;
      
   // فحص الظل السفلي
   if(lowerShadow > body * m_lowerShadowLimit)
      return false;
      
   // فحص الاتجاه الهبوطي
   if(!IsInDowntrend(idx, close))
      return false;
      
   return true;
}

bool CInvertedHammerPattern::IsInDowntrend(const int idx, const double &close[])
{
   if(idx + m_trendBars >= ArraySize(close))
      return false;
      
   int downCount = 0;
   for(int i = 1; i <= m_trendBars; i++)
   {
      if(close[idx + i] > close[idx + i - 1])
         downCount++;
   }
   
   return downCount >= m_trendBars * 0.6;
}

bool CInvertedHammerPattern::RequiresConfirmation(const int idx, const double &open[], const double &close[])
{
   // المطرقة المعكوسة تحتاج تأكيد من الشمعة التالية
   if(idx == 0)
      return true; // لا يمكن التأكيد بعد
      
   return CCandleUtils::IsBullish(open[idx-1], close[idx-1]) && close[idx-1] > close[idx];
}

double CInvertedHammerPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة الظل العلوي
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   
   if(upperShadow > body * 3.0)
      strength += 0.5;
      
   // تأكيد من الشمعة التالية
   if(!RequiresConfirmation(idx, open, close))
      strength += 0.8;
      
   // حجم التداول
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.3)
         strength += 0.4;
   }
      
   return MathMin(3.0, strength);
}

SPatternSignal CInvertedHammerPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                     const double &open[], const double &high[], 
                                                     const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   // إشارة شراء مشروطة بالتأكيد
   signal.type = RequiresConfirmation(idx, open, close) ? SIGNAL_BUY : SIGNAL_NONE;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   if(signal.type == SIGNAL_BUY)
   {
      double bodyBottom = MathMin(open[idx], close[idx]);
      double range = high[idx] - low[idx];
      
      signal.entryPrice = bodyBottom + range * 0.1;
      signal.stopLoss = low[idx] - range * 0.1;
      signal.takeProfit = signal.entryPrice + (signal.entryPrice - signal.stopLoss) * 2.0;
   }
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ نمط الرجل المعلق                                            |
//+------------------------------------------------------------------+
CHangingManPattern::CHangingManPattern() : 
   CCandlePattern("الرجل المعلق", PATTERN_SINGLE, PATTERN_BEARISH, PATTERN_STRENGTH_STRONG, 
                  1, 0.75, "نمط انعكاس هبوطي يظهر في نهاية الاتجاهات الصاعدة", clrRed)
{
   m_bodyRatio = 0.3;
   m_shadowRatio = 2.0;
   m_upperShadowLimit = 0.1;
   m_trendBars = 5;
}

CHangingManPattern::~CHangingManPattern() {}

bool CHangingManPattern::Detect(const int idx, const double &open[], const double &high[], 
                               const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, m_trendBars + 1, idx))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   
   if(totalRange <= 0 || body <= 0)
      return false;
      
   // نفس شروط المطرقة من ناحية الشكل
   if(body / totalRange > m_bodyRatio)
      return false;
      
   if(lowerShadow < body * m_shadowRatio)
      return false;
      
   if(upperShadow > body * m_upperShadowLimit)
      return false;
      
   // الفرق: يجب أن يكون في اتجاه صاعد
   if(!IsInUptrend(idx, close))
      return false;
      
   return true;
}

bool CHangingManPattern::IsInUptrend(const int idx, const double &close[])
{
   if(idx + m_trendBars >= ArraySize(close))
      return false;
      
   int upCount = 0;
   double totalGain = 0.0;
   
   for(int i = 1; i <= m_trendBars; i++)
   {
      if(close[idx + i] < close[idx + i - 1])
         upCount++;
         
      totalGain += close[idx] - close[idx + i];
   }
   
   return (upCount >= m_trendBars * 0.6) && (totalGain > 0);
}

double CHangingManPattern::CalculateUptrendStrength(const int idx, const double &close[])
{
   if(idx + m_trendBars >= ArraySize(close))
      return 0.0;
      
   double priceChange = (close[idx] - close[idx + m_trendBars]) / close[idx + m_trendBars];
   return MathMax(0.0, priceChange);
}

double CHangingManPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة الظل السفلي
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(lowerShadow > body * 3.0)
      strength += 1.0;
   else if(lowerShadow > body * 2.5)
      strength += 0.5;
      
   // قوة الاتجاه الصاعد السابق
   double trendStrength = CalculateUptrendStrength(idx, close);
   if(trendStrength > 0.05)
      strength += 0.5;
      
   // لون الشمعة (الهابطة أقوى للانعكاس)
   if(CCandleUtils::IsBearish(open[idx], close[idx]))
      strength += 0.5;
      
   // حجم التداول
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.2)
         strength += 0.5;
   }
      
   return MathMin(3.0, strength);
}

SPatternSignal CHangingManPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                 const double &open[], const double &high[], 
                                                 const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   signal.type = SIGNAL_SELL;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   // استراتيجية البيع
   double bodyBottom = MathMin(open[idx], close[idx]);
   double range = high[idx] - low[idx];
   
   signal.entryPrice = bodyBottom - range * 0.05;
   signal.stopLoss = high[idx] + range * 0.1;
   signal.takeProfit = signal.entryPrice - (signal.stopLoss - signal.entryPrice) * 2.5;
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ نمط النجم الساقط                                            |
//+------------------------------------------------------------------+
CShootingStarPattern::CShootingStarPattern() : 
   CCandlePattern("النجم الساقط", PATTERN_SINGLE, PATTERN_BEARISH, PATTERN_STRENGTH_STRONG, 
                  1, 0.80, "نمط انعكاس هبوطي قوي يظهر في القمم", clrRed)
{
   m_bodyRatio = 0.3;
   m_shadowRatio = 2.0;     // الظل العلوي ضعف الجسم
   m_lowerShadowLimit = 0.1;
   m_trendBars = 5;
}

CShootingStarPattern::~CShootingStarPattern() {}

bool CShootingStarPattern::Detect(const int idx, const double &open[], const double &high[], 
                                 const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, m_trendBars + 1, idx))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   if(totalRange <= 0 || body <= 0)
      return false;
      
   // فحص نسبة الجسم
   if(body / totalRange > m_bodyRatio)
      return false;
      
   // فحص الظل العلوي (يجب أن يكون طويل)
   if(upperShadow < body * m_shadowRatio)
      return false;
      
   // فحص الظل السفلي (يجب أن يكون قصير)
   if(lowerShadow > body * m_lowerShadowLimit)
      return false;
      
   // يجب أن يكون في اتجاه صاعد
   if(!IsInUptrend(idx, close))
      return false;
      
   return true;
}

bool CShootingStarPattern::IsInUptrend(const int idx, const double &close[])
{
   if(idx + m_trendBars >= ArraySize(close))
      return false;
      
   int upCount = 0;
   for(int i = 1; i <= m_trendBars; i++)
   {
      if(close[idx + i] < close[idx + i - 1])
         upCount++;
   }
   
   return upCount >= m_trendBars * 0.6;
}

bool CShootingStarPattern::IsAtResistanceLevel(const int idx, const double &high[])
{
   if(idx + 20 >= ArraySize(high))
      return false;
      
   // فحص إذا كان السعر قريب من مقاومة سابقة
   double currentHigh = high[idx];
   int touchCount = 0;
   
   for(int i = idx + 5; i < idx + 20; i++)
   {
      if(MathAbs(high[i] - currentHigh) / currentHigh < 0.002) // ضمن 0.2%
         touchCount++;
   }
   
   return touchCount >= 2;
}

double CShootingStarPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة الظل العلوي
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   
   if(upperShadow > body * 4.0)
      strength += 1.0;
   else if(upperShadow > body * 3.0)
      strength += 0.5;
      
   // وجود مقاومة سابقة
   if(IsAtResistanceLevel(idx, high))
      strength += 0.7;
      
   // لون الشمعة (الهابطة أقوى)
   if(CCandleUtils::IsBearish(open[idx], close[idx]))
      strength += 0.5;
      
   // حجم التداول العالي
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.5)
         strength += 0.8;
   }
      
   return MathMin(3.0, strength);
}

SPatternSignal CShootingStarPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                   const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   signal.type = SIGNAL_SELL;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   // استراتيجية بيع قوية
   double bodyTop = MathMax(open[idx], close[idx]);
   double range = high[idx] - low[idx];
   
   signal.entryPrice = bodyTop - range * 0.1;  // دخول أسفل الجسم
   signal.stopLoss = high[idx] + range * 0.15; // وقف فوق أعلى سعر
   signal.takeProfit = signal.entryPrice - (signal.stopLoss - signal.entryPrice) * 3.0; // نسبة 1:3
   
   return signal;
}