//+------------------------------------------------------------------+
//|                                              BeltHoldPatterns.mqh |
//|                                  أنماط حزام الحمل |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\Base\CandlePattern.mqh"
#include "..\Base\CandleUtils.mqh"

//+------------------------------------------------------------------+
//| حزام الحمل الصاعد - نمط انعكاس صعودي قوي                       |
//+------------------------------------------------------------------+
class CBullishBeltHoldPattern : public CCandlePattern
{
private:
   double m_shadowThreshold;              // عتبة الظل المسموحة
   double m_bodyRatioThreshold;           // نسبة الجسم إلى المدى الكلي
   
public:
                            CBullishBeltHoldPattern(double shadowThreshold = 0.05);
                            ~CBullishBeltHoldPattern();
   
   virtual bool            Detect(const int idx, const double &open[], const double &high[],
                                 const double &low[], const double &close[], const long &volume[]);
   virtual double          PatternStrength(const int idx, const double &open[], const double &high[],
                                         const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal  GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                         const double &open[], const double &high[],
                                         const double &low[], const double &close[], const long &volume[]);

private:
   bool                    IsInDowntrend(const int idx, const double &close[]);
};

//+------------------------------------------------------------------+
//| حزام الحمل الهابط - نمط انعكاس هبوطي قوي                       |
//+------------------------------------------------------------------+
class CBearishBeltHoldPattern : public CCandlePattern
{
private:
   double m_shadowThreshold;              // عتبة الظل المسموحة
   double m_bodyRatioThreshold;           // نسبة الجسم إلى المدى الكلي
   
public:
                            CBearishBeltHoldPattern(double shadowThreshold = 0.05);
                            ~CBearishBeltHoldPattern();
   
   virtual bool            Detect(const int idx, const double &open[], const double &high[],
                                 const double &low[], const double &close[], const long &volume[]);
   virtual double          PatternStrength(const int idx, const double &open[], const double &high[],
                                         const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal  GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                         const double &open[], const double &high[],
                                         const double &low[], const double &close[], const long &volume[]);

private:
   bool                    IsInUptrend(const int idx, const double &close[]);
};

//+------------------------------------------------------------------+
//| تنفيذ حزام الحمل الصاعد                                         |
//+------------------------------------------------------------------+
CBullishBeltHoldPattern::CBullishBeltHoldPattern(double shadowThreshold)
{
   // تهيئة الفئة الأساسية
   m_name = "حزام الحمل الصاعد";
   m_type = PATTERN_SINGLE;
   m_direction = PATTERN_BULLISH;
   m_defaultStrength = PATTERN_STRENGTH_STRONG;
   m_requiredBars = 1;
   m_reliability = 0.70;
   m_description = "نمط انعكاس صعودي قوي يفتح عند الأدنى";
   m_defaultColor = clrLime;
   
   // تهيئة متغيرات الفئة
   m_shadowThreshold = shadowThreshold;
   m_bodyRatioThreshold = 0.7;
}

CBullishBeltHoldPattern::~CBullishBeltHoldPattern() { }

bool CBullishBeltHoldPattern::Detect(const int idx, const double &open[], const double &high[],
                                    const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 5, idx))
      return false;
   
   // يجب أن تكون الشمعة صاعدة
   if(!CCandleUtils::IsBullish(open[idx], close[idx]))
      return false;
   
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = CCandleUtils::CandleRange(high[idx], low[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   
   // يجب أن يكون الظل السفلي صغير جداً (يفتح عند الأدنى أو قريب منه)
   if(lowerShadow > totalRange * m_shadowThreshold)
      return false;
   
   // يجب أن يكون الجسم كبير نسبياً
   if(body < totalRange * m_bodyRatioThreshold)
      return false;
   
   // يفضل أن يكون في اتجاه هابط سابق
   if(!IsInDowntrend(idx, close))
      return false;
   
   return true;
}

bool CBullishBeltHoldPattern::IsInDowntrend(const int idx, const double &close[])
{
   if(idx + 5 >= ArraySize(close))
      return false;
   
   // فحص بسيط للاتجاه الهابط
   int downCount = 0;
   for(int i = 1; i <= 4; i++)
   {
      if(close[idx + i] > close[idx + i - 1])
         downCount++;
   }
   
   return downCount >= 2; // على الأقل نصف الشموع السابقة هابطة
}

double CBullishBeltHoldPattern::PatternStrength(const int idx, const double &open[], const double &high[],
                                               const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
   
   double strength = m_defaultStrength;
   
   // قوة أكبر كلما كان الجسم أكبر
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = CCandleUtils::CandleRange(high[idx], low[idx]);
   double bodyRatio = body / totalRange;
   
   if(bodyRatio > 0.9)
      strength += 1.0;
   else if(bodyRatio > 0.8)
      strength += 0.5;
   
   // تأكيد بالحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.5)
         strength += 0.5;
   }
   
   return MathMin(3.0, strength);
}

SPatternSignal CBullishBeltHoldPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                      const double &open[], const double &high[],
                                                      const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   // إشارة شراء قوية
   signal.type = SIGNAL_BUY;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   // تحديد نقاط الدخول والخروج
   double range = high[idx] - low[idx];
   signal.entryPrice = close[idx] + range * 0.05; // دخول فوق الإغلاق قليلاً
   signal.stopLoss = low[idx] - range * 0.1;      // وقف تحت القاع
   signal.takeProfit = signal.entryPrice + (signal.entryPrice - signal.stopLoss) * 2.0; // نسبة 1:2
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ حزام الحمل الهابط                                         |
//+------------------------------------------------------------------+
CBearishBeltHoldPattern::CBearishBeltHoldPattern(double shadowThreshold)
{
   // تهيئة الفئة الأساسية
   m_name = "حزام الحمل الهابط";
   m_type = PATTERN_SINGLE;
   m_direction = PATTERN_BEARISH;
   m_defaultStrength = PATTERN_STRENGTH_STRONG;
   m_requiredBars = 1;
   m_reliability = 0.70;
   m_description = "نمط انعكاس هبوطي قوي يفتح عند الأعلى";
   m_defaultColor = clrRed;
   
   // تهيئة متغيرات الفئة
   m_shadowThreshold = shadowThreshold;
   m_bodyRatioThreshold = 0.7;
}

CBearishBeltHoldPattern::~CBearishBeltHoldPattern() { }

bool CBearishBeltHoldPattern::Detect(const int idx, const double &open[], const double &high[],
                                    const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 5, idx))
      return false;
   
   // يجب أن تكون الشمعة هابطة
   if(!CCandleUtils::IsBearish(open[idx], close[idx]))
      return false;
   
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = CCandleUtils::CandleRange(high[idx], low[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   
   // يجب أن يكون الظل العلوي صغير جداً (يفتح عند الأعلى أو قريب منه)
   if(upperShadow > totalRange * m_shadowThreshold)
      return false;
   
   // يجب أن يكون الجسم كبير نسبياً
   if(body < totalRange * m_bodyRatioThreshold)
      return false;
   
   // يفضل أن يكون في اتجاه صاعد سابق
   if(!IsInUptrend(idx, close))
      return false;
   
   return true;
}

bool CBearishBeltHoldPattern::IsInUptrend(const int idx, const double &close[])
{
   if(idx + 5 >= ArraySize(close))
      return false;
   
   // فحص بسيط للاتجاه الصاعد
   int upCount = 0;
   for(int i = 1; i <= 4; i++)
   {
      if(close[idx + i] < close[idx + i - 1])
         upCount++;
   }
   
   return upCount >= 2; // على الأقل نصف الشموع السابقة صاعدة
}

double CBearishBeltHoldPattern::PatternStrength(const int idx, const double &open[], const double &high[],
                                               const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
   
   double strength = m_defaultStrength;
   
   // قوة أكبر كلما كان الجسم أكبر
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = CCandleUtils::CandleRange(high[idx], low[idx]);
   double bodyRatio = body / totalRange;
   
   if(bodyRatio > 0.9)
      strength += 1.0;
   else if(bodyRatio > 0.8)
      strength += 0.5;
   
   // تأكيد بالحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.5)
         strength += 0.5;
   }
   
   return MathMin(3.0, strength);
}

SPatternSignal CBearishBeltHoldPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                      const double &open[], const double &high[],
                                                      const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   // إشارة بيع قوية
   signal.type = SIGNAL_SELL;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   // تحديد نقاط الدخول والخروج
   double range = high[idx] - low[idx];
   signal.entryPrice = close[idx] - range * 0.05; // دخول تحت الإغلاق قليلاً
   signal.stopLoss = high[idx] + range * 0.1;     // وقف فوق القمة
   signal.takeProfit = signal.entryPrice - (signal.stopLoss - signal.entryPrice) * 2.0; // نسبة 1:2
   
   return signal;
}
