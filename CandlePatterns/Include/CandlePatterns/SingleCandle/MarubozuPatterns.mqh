//+------------------------------------------------------------------+
//|                                            MarubozuPatterns.mqh |
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
//| الماروبوزو الصاعد - شمعة قوية بدون ظلال تظهر قوة المشترين        |
//+------------------------------------------------------------------+
class CBullishMarubozuPattern : public CCandlePattern
{
private:
   double m_shadowThreshold;        // العتبة المسموحة للظلال
   double m_minBodySize;            // الحد الأدنى لحجم الجسم
   double m_volumeMultiplier;       // مضاعف الحجم المطلوب
   
public:
                     CBullishMarubozuPattern();
                     ~CBullishMarubozuPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            IsVolumeConfirmed(const int idx, const long &volume[]);
   double          CalculateBodyDominance(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| الماروبوزو الهابط - شمعة قوية بدون ظلال تظهر قوة البائعين        |
//+------------------------------------------------------------------+
class CBearishMarubozuPattern : public CCandlePattern
{
private:
   double m_shadowThreshold;
   double m_minBodySize;
   double m_volumeMultiplier;
   
public:
                     CBearishMarubozuPattern();
                     ~CBearishMarubozuPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            IsVolumeConfirmed(const int idx, const long &volume[]);
   double          CalculateBodyDominance(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[]);
};

//+------------------------------------------------------------------+
//| الماروبوزو الافتتاحي الأبيض - قوة في الافتتاح                     |
//+------------------------------------------------------------------+
class CWhiteOpeningMarubozuPattern : public CCandlePattern
{
private:
   double m_lowerShadowThreshold;   // العتبة للظل السفلي
   double m_upperShadowLimit;       // الحد المسموح للظل العلوي
   double m_minBodySize;
   
public:
                     CWhiteOpeningMarubozuPattern();
                     ~CWhiteOpeningMarubozuPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
};

//+------------------------------------------------------------------+
//| الماروبوزو الإغلاقي الأبيض - قوة في الإغلاق                       |
//+------------------------------------------------------------------+
class CWhiteClosingMarubozuPattern : public CCandlePattern
{
private:
   double m_upperShadowThreshold;   // العتبة للظل العلوي
   double m_lowerShadowLimit;       // الحد المسموح للظل السفلي
   double m_minBodySize;
   
public:
                     CWhiteClosingMarubozuPattern();
                     ~CWhiteClosingMarubozuPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
};

//+------------------------------------------------------------------+
//| الماروبوزو الأسود - الإصدار الهبوطي القوي                         |
//+------------------------------------------------------------------+
class CBlackMarubozuPattern : public CCandlePattern
{
private:
   double m_shadowThreshold;
   double m_minBodySize;
   double m_volumeMultiplier;
   
public:
                     CBlackMarubozuPattern();
                     ~CBlackMarubozuPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            IsBreakoutConfirmed(const int idx, const double &close[]);
};

//+------------------------------------------------------------------+
//| تنفيذ الماروبوزو الصاعد                                           |
//+------------------------------------------------------------------+
CBullishMarubozuPattern::CBullishMarubozuPattern() : 
   CCandlePattern("الماروبوزو الصاعد", PATTERN_SINGLE, PATTERN_BULLISH, PATTERN_STRENGTH_STRONG, 
                  1, 0.82, "شمعة صاعدة قوية بدون ظلال تظهر هيمنة المشترين", clrLime)
{
   m_shadowThreshold = 0.05;    // 5% من حجم الجسم
   m_minBodySize = 1.5;         // 1.5 ضعف متوسط الجسم
   m_volumeMultiplier = 1.2;    // 20% زيادة في الحجم
}

CBullishMarubozuPattern::~CBullishMarubozuPattern() {}

bool CBullishMarubozuPattern::Detect(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   // يجب أن تكون شمعة صاعدة
   if(!CCandleUtils::IsBullish(open[idx], close[idx]))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // فحص حجم الجسم
   double avgBody = CCandleUtils::CalculateAvgBody(open, close, 14, idx + 1);
   if(body < avgBody * m_minBodySize)
      return false;
      
   // فحص الظلال (يجب أن تكون ضئيلة جداً أو غير موجودة)
   double shadowThreshold = body * m_shadowThreshold;
   
   if(upperShadow > shadowThreshold || lowerShadow > shadowThreshold)
      return false;
      
   return true;
}

bool CBullishMarubozuPattern::IsVolumeConfirmed(const int idx, const long &volume[])
{
   if(idx >= ArraySize(volume) - 1)
      return true; // لا يمكن التحقق
      
   double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
   return volume[idx] >= avgVolume * m_volumeMultiplier;
}

double CBullishMarubozuPattern::CalculateBodyDominance(const int idx, const double &open[], const double &high[], 
                                                     const double &low[], const double &close[])
{
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   
   if(totalRange <= 0)
      return 0.0;
      
   return body / totalRange; // نسبة الجسم إلى المدى الكلي
}

double CBullishMarubozuPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة أكبر بناءً على هيمنة الجسم
   double bodyDominance = CalculateBodyDominance(idx, open, high, low, close);
   if(bodyDominance > 0.95)
      strength += 1.0;
   else if(bodyDominance > 0.90)
      strength += 0.5;
      
   // تأكيد الحجم
   if(IsVolumeConfirmed(idx, volume))
      strength += 0.8;
      
   // حجم الجسم مقارنة بالمتوسط
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double avgBody = CCandleUtils::CalculateAvgBody(open, close, 14, idx + 1);
   
   if(body > avgBody * 2.5)
      strength += 1.0;
   else if(body > avgBody * 2.0)
      strength += 0.5;
      
   // الموقع في الاتجاه العام
   if(idx + 3 < ArraySize(close))
   {
      double recentTrend = (close[idx] - close[idx + 3]) / close[idx + 3];
      if(recentTrend > 0.01) // اتجاه صاعد 1%
         strength += 0.3;
   }
      
   return MathMin(3.0, strength);
}

SPatternSignal CBullishMarubozuPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // استراتيجية الشراء القوية
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   
   signal.entryPrice = close[idx] + body * 0.02; // دخول فوق الإغلاق قليلاً
   signal.stopLoss = open[idx] - body * 0.1;     // وقف تحت الافتتاح
   signal.takeProfit = signal.entryPrice + (signal.entryPrice - signal.stopLoss) * 3.0; // نسبة 1:3
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ الماروبوزو الهابط                                           |
//+------------------------------------------------------------------+
CBearishMarubozuPattern::CBearishMarubozuPattern() : 
   CCandlePattern("الماروبوزو الهابط", PATTERN_SINGLE, PATTERN_BEARISH, PATTERN_STRENGTH_STRONG, 
                  1, 0.82, "شمعة هابطة قوية بدون ظلال تظهر هيمنة البائعين", clrRed)
{
   m_shadowThreshold = 0.05;
   m_minBodySize = 1.5;
   m_volumeMultiplier = 1.2;
}

CBearishMarubozuPattern::~CBearishMarubozuPattern() {}

bool CBearishMarubozuPattern::Detect(const int idx, const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   // يجب أن تكون شمعة هابطة
   if(!CCandleUtils::IsBearish(open[idx], close[idx]))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // فحص حجم الجسم
   double avgBody = CCandleUtils::CalculateAvgBody(open, close, 14, idx + 1);
   if(body < avgBody * m_minBodySize)
      return false;
      
   // فحص الظلال
   double shadowThreshold = body * m_shadowThreshold;
   
   if(upperShadow > shadowThreshold || lowerShadow > shadowThreshold)
      return false;
      
   return true;
}

bool CBearishMarubozuPattern::IsVolumeConfirmed(const int idx, const long &volume[])
{
   if(idx >= ArraySize(volume) - 1)
      return true;
      
   double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
   return volume[idx] >= avgVolume * m_volumeMultiplier;
}

double CBearishMarubozuPattern::CalculateBodyDominance(const int idx, const double &open[], const double &high[], 
                                                      const double &low[], const double &close[])
{
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   
   if(totalRange <= 0)
      return 0.0;
      
   return body / totalRange;
}

double CBearishMarubozuPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                               const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // هيمنة الجسم
   double bodyDominance = CalculateBodyDominance(idx, open, high, low, close);
   if(bodyDominance > 0.95)
      strength += 1.0;
   else if(bodyDominance > 0.90)
      strength += 0.5;
      
   // تأكيد الحجم
   if(IsVolumeConfirmed(idx, volume))
      strength += 0.8;
      
   // حجم الجسم
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double avgBody = CCandleUtils::CalculateAvgBody(open, close, 14, idx + 1);
   
   if(body > avgBody * 2.5)
      strength += 1.0;
   else if(body > avgBody * 2.0)
      strength += 0.5;
      
   // الموقع في الاتجاه العام
   if(idx + 3 < ArraySize(close))
   {
      double recentTrend = (close[idx + 3] - close[idx]) / close[idx + 3];
      if(recentTrend > 0.01) // اتجاه هابط 1%
         strength += 0.3;
   }
      
   return MathMin(3.0, strength);
}

SPatternSignal CBearishMarubozuPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // استراتيجية البيع القوية
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   
   signal.entryPrice = close[idx] - body * 0.02; // دخول تحت الإغلاق قليلاً
   signal.stopLoss = open[idx] + body * 0.1;     // وقف فوق الافتتاح
   signal.takeProfit = signal.entryPrice - (signal.stopLoss - signal.entryPrice) * 3.0; // نسبة 1:3
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ الماروبوزو الافتتاحي الأبيض                                  |
//+------------------------------------------------------------------+
CWhiteOpeningMarubozuPattern::CWhiteOpeningMarubozuPattern() : 
   CCandlePattern("الماروبوزو الافتتاحي الأبيض", PATTERN_SINGLE, PATTERN_BULLISH, PATTERN_STRENGTH_MEDIUM, 
                  1, 0.72, "شمعة صاعدة قوية الافتتاح بدون ظل سفلي", clrLightGreen)
{
   m_lowerShadowThreshold = 0.02;  // 2% من الجسم
   m_upperShadowLimit = 0.3;       // 30% من الجسم
   m_minBodySize = 1.2;
}

CWhiteOpeningMarubozuPattern::~CWhiteOpeningMarubozuPattern() {}

bool CWhiteOpeningMarubozuPattern::Detect(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   if(!CCandleUtils::IsBullish(open[idx], close[idx]))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // فحص حجم الجسم
   double avgBody = CCandleUtils::CalculateAvgBody(open, close, 14, idx + 1);
   if(body < avgBody * m_minBodySize)
      return false;
      
   // الظل السفلي يجب أن يكون ضئيل جداً (افتتاح قوي)
   if(lowerShadow > body * m_lowerShadowThreshold)
      return false;
      
   // الظل العلوي مسموح لكن محدود
   if(upperShadow > body * m_upperShadowLimit)
      return false;
      
   return true;
}

double CWhiteOpeningMarubozuPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                                    const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة الافتتاح (عدم وجود ظل سفلي)
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   
   if(lowerShadow < body * 0.01)
      strength += 0.8;
   else if(lowerShadow < body * 0.015)
      strength += 0.5;
      
   // حجم الجسم
   double avgBody = CCandleUtils::CalculateAvgBody(open, close, 14, idx + 1);
   if(body > avgBody * 2.0)
      strength += 0.5;
      
   // تأكيد الحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.3)
         strength += 0.4;
   }
      
   return MathMin(3.0, strength);
}

SPatternSignal CWhiteOpeningMarubozuPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // استراتيجية تعتمد على قوة الافتتاح
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   
   signal.entryPrice = close[idx] + body * 0.05;
   signal.stopLoss = open[idx] - body * 0.15;
   signal.takeProfit = signal.entryPrice + (signal.entryPrice - signal.stopLoss) * 2.0;
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ الماروبوزو الإغلاقي الأبيض                                   |
//+------------------------------------------------------------------+
CWhiteClosingMarubozuPattern::CWhiteClosingMarubozuPattern() : 
   CCandlePattern("الماروبوزو الإغلاقي الأبيض", PATTERN_SINGLE, PATTERN_BULLISH, PATTERN_STRENGTH_MEDIUM, 
                  1, 0.75, "شمعة صاعدة قوية الإغلاق بدون ظل علوي", clrLightGreen)
{
   m_upperShadowThreshold = 0.02;
   m_lowerShadowLimit = 0.3;
   m_minBodySize = 1.2;
}

CWhiteClosingMarubozuPattern::~CWhiteClosingMarubozuPattern() {}

bool CWhiteClosingMarubozuPattern::Detect(const int idx, const double &open[], const double &high[], 
                                         const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   if(!CCandleUtils::IsBullish(open[idx], close[idx]))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // فحص حجم الجسم
   double avgBody = CCandleUtils::CalculateAvgBody(open, close, 14, idx + 1);
   if(body < avgBody * m_minBodySize)
      return false;
      
   // الظل العلوي يجب أن يكون ضئيل جداً (إغلاق قوي)
   if(upperShadow > body * m_upperShadowThreshold)
      return false;
      
   // الظل السفلي مسموح لكن محدود
   if(lowerShadow > body * m_lowerShadowLimit)
      return false;
      
   return true;
}

double CWhiteClosingMarubozuPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                                    const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة الإغلاق (عدم وجود ظل علوي)
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   
   if(upperShadow < body * 0.01)
      strength += 0.8;
   else if(upperShadow < body * 0.015)
      strength += 0.5;
      
   // حجم الجسم
   double avgBody = CCandleUtils::CalculateAvgBody(open, close, 14, idx + 1);
   if(body > avgBody * 2.0)
      strength += 0.5;
      
   // موقع في اتجاه صاعد
   if(idx + 2 < ArraySize(close))
   {
      if(close[idx] > close[idx + 1] && close[idx + 1] > close[idx + 2])
         strength += 0.3;
   }
      
   return MathMin(3.0, strength);
}

SPatternSignal CWhiteClosingMarubozuPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // استراتيجية تعتمد على قوة الإغلاق
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   
   signal.entryPrice = close[idx] + body * 0.03;
   signal.stopLoss = open[idx] - body * 0.1;
   signal.takeProfit = signal.entryPrice + (signal.entryPrice - signal.stopLoss) * 2.5;
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ الماروبوزو الأسود                                            |
//+------------------------------------------------------------------+
CBlackMarubozuPattern::CBlackMarubozuPattern() : 
   CCandlePattern("الماروبوزو الأسود", PATTERN_SINGLE, PATTERN_BEARISH, PATTERN_STRENGTH_STRONG, 
                  1, 0.85, "شمعة هابطة قوية تشير إلى ضغط بيع شديد", clrDarkRed)
{
   m_shadowThreshold = 0.03;
   m_minBodySize = 1.8;     // معايير أكثر صرامة
   m_volumeMultiplier = 1.5;
}

CBlackMarubozuPattern::~CBlackMarubozuPattern() {}

bool CBlackMarubozuPattern::Detect(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   if(!CCandleUtils::IsBearish(open[idx], close[idx]))
      return false;
      
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // معايير أكثر صرامة للماروبوزو الأسود
   double avgBody = CCandleUtils::CalculateAvgBody(open, close, 14, idx + 1);
   if(body < avgBody * m_minBodySize)
      return false;
      
   double shadowThreshold = body * m_shadowThreshold;
   if(upperShadow > shadowThreshold || lowerShadow > shadowThreshold)
      return false;
      
   return true;
}

bool CBlackMarubozuPattern::IsBreakoutConfirmed(const int idx, const double &close[])
{
   if(idx + 5 >= ArraySize(close))
      return false;
      
   // فحص إذا كان هناك اختراق لمستوى دعم
   double currentLow = close[idx];
   int supportBreaks = 0;
   
   for(int i = idx + 1; i < idx + 5; i++)
   {
      if(close[i] > currentLow)
         supportBreaks++;
   }
   
   return supportBreaks >= 3; // اختراق مستوى دعم سابق
}

double CBlackMarubozuPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // الماروبوزو الأسود له قوة أكبر
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double totalRange = high[idx] - low[idx];
   
   if(body / totalRange > 0.98)
      strength += 1.5;
   else if(body / totalRange > 0.95)
      strength += 1.0;
      
   // حجم استثنائي
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 2.0)
         strength += 1.0;
      else if(volume[idx] > avgVolume * 1.5)
         strength += 0.5;
   }
   
   // اختراق مستويات دعم
   if(IsBreakoutConfirmed(idx, close))
      strength += 0.8;
      
   return MathMin(3.0, strength);
}

SPatternSignal CBlackMarubozuPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // استراتيجية بيع قوية جداً
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   
   signal.entryPrice = close[idx] - body * 0.01; // دخول سريع
   signal.stopLoss = open[idx] + body * 0.08;    // وقف ضيق
   signal.takeProfit = signal.entryPrice - (signal.stopLoss - signal.entryPrice) * 4.0; // نسبة 1:4
   
   return signal;
}