//+------------------------------------------------------------------+
//|                                                DojiPatterns.mqh |
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
//| الدوجي العادي - إشارة تردد وتوازن في القوى                        |
//+------------------------------------------------------------------+
class CDojiPattern : public CCandlePattern
{
private:
   double m_dojiThreshold;          // عتبة الدوجي كنسبة من متوسط المدى
   double m_shadowRatio;            // نسبة الظلال المقبولة
   
public:
                     CDojiPattern(double threshold = 0.05);
                     ~CDojiPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
};

//+------------------------------------------------------------------+
//| دوجي طويل الأرجل - مؤشر على عدم اليقين الشديد                     |
//+------------------------------------------------------------------+
class CLongLeggedDojiPattern : public CCandlePattern
{
private:
   double m_dojiThreshold;
   double m_minShadowRatio;         // الحد الأدنى لطول الظلال
   
public:
                     CLongLeggedDojiPattern(double threshold = 0.05);
                     ~CLongLeggedDojiPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
};

//+------------------------------------------------------------------+
//| دوجي شاهد القبر - إشارة انعكاس هبوطي قوية                         |
//+------------------------------------------------------------------+
class CGravestoneDojiPattern : public CCandlePattern
{
private:
   double m_dojiThreshold;
   double m_upperShadowRatio;       // نسبة الظل العلوي المطلوبة
   double m_lowerShadowLimit;       // الحد الأقصى للظل السفلي
   
public:
                     CGravestoneDojiPattern(double threshold = 0.05);
                     ~CGravestoneDojiPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            IsInUptrend(const int idx, const double &close[]);
};

//+------------------------------------------------------------------+
//| دوجي اليعسوب - إشارة انعكاس صعودي محتملة                          |
//+------------------------------------------------------------------+
class CDragonflyDojiPattern : public CCandlePattern
{
private:
   double m_dojiThreshold;
   double m_lowerShadowRatio;       // نسبة الظل السفلي المطلوبة
   double m_upperShadowLimit;       // الحد الأقصى للظل العلوي
   
public:
                     CDragonflyDojiPattern(double threshold = 0.05);
                     ~CDragonflyDojiPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
private:
   bool            IsInDowntrend(const int idx, const double &close[]);
};

//+------------------------------------------------------------------+
//| دوجي الأربعة أسعار - حالة نادرة من التوازن المثالي                |
//+------------------------------------------------------------------+
class CFourPriceDojiPattern : public CCandlePattern
{
private:
   double m_priceThreshold;         // عتبة التساوي في الأسعار
   
public:
                     CFourPriceDojiPattern(double threshold = 0.0001);
                     ~CFourPriceDojiPattern();
   
   virtual bool     Detect(const int idx, const double &open[], const double &high[], 
                          const double &low[], const double &close[], const long &volume[]);
   virtual double   PatternStrength(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[]);
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
};

//+------------------------------------------------------------------+
//| تنفيذ الدوجي العادي                                               |
//+------------------------------------------------------------------+
CDojiPattern::CDojiPattern(double threshold)
{
   // تهيئة الفئة الأساسية
   m_name = "الدوجي";
   m_type = PATTERN_SINGLE;
   m_direction = PATTERN_NEUTRAL;
   m_defaultStrength = PATTERN_STRENGTH_MEDIUM;
   m_requiredBars = 1;
   m_reliability = 0.65;
   m_description = "نمط يشير إلى التوازن بين قوى العرض والطلب";
   m_defaultColor = clrYellow;
   
   // تهيئة متغيرات الفئة
   m_dojiThreshold = threshold;
   m_shadowRatio = 0.1;
}

CDojiPattern::~CDojiPattern() {}

bool CDojiPattern::Detect(const int idx, const double &open[], const double &high[], 
                         const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   // حساب متوسط المدى للشموع السابقة
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 14, idx + 1);
   if(avgRange <= 0) return false;
   
   // فحص إذا كانت الشمعة دوجي
   bool isDoji = CCandleUtils::IsDoji(open[idx], close[idx], avgRange, m_dojiThreshold);
   if(!isDoji) return false;
   
   // التأكد من أن الظلال ليست مهيمنة بشكل مفرط (للتمييز عن الأنواع الأخرى)
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // تجنب التداخل مع دوجي شاهد القبر أو دوجي اليعسوب
   if(upperShadow > totalRange * 0.7 || lowerShadow > totalRange * 0.7)
      return false;
      
   return true;
}

double CDojiPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                   const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // زيادة القوة بناءً على الحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.5)
         strength += 0.5;
   }
   
   // زيادة القوة في النقاط الحرجة (مقاومة/دعم)
   double totalRange = high[idx] - low[idx];
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 14, idx + 1);
   
   if(totalRange > avgRange * 1.2)
      strength += 0.3;
      
   return MathMin(3.0, strength);
}

SPatternSignal CDojiPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                           const double &open[], const double &high[], 
                                           const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   // الدوجي إشارة محايدة - انتظار تأكيد
   signal.type = SIGNAL_NONE;
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0;
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   // نصائح للتداول
   signal.entryPrice = (high[idx] + low[idx]) / 2.0;
   signal.stopLoss = 0.0;  // يحتاج تأكيد من الشمعة التالية
   signal.takeProfit = 0.0;
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ دوجي طويل الأرجل                                            |
//+------------------------------------------------------------------+
CLongLeggedDojiPattern::CLongLeggedDojiPattern(double threshold)
{
   // تهيئة الفئة الأساسية
   m_name = "الدوجي طويل الأرجل";
   m_type = PATTERN_SINGLE;
   m_direction = PATTERN_NEUTRAL;
   m_defaultStrength = PATTERN_STRENGTH_STRONG;
   m_requiredBars = 1;
   m_reliability = 0.70;
   m_description = "دوجي بظلال طويلة يشير إلى عدم يقين شديد في السوق";
   m_defaultColor = clrOrange;
   
   // تهيئة متغيرات الفئة
   m_dojiThreshold = threshold;
   m_minShadowRatio = 1.5;
}

CLongLeggedDojiPattern::~CLongLeggedDojiPattern() {}

bool CLongLeggedDojiPattern::Detect(const int idx, const double &open[], const double &high[], 
                                   const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 14, idx + 1);
   if(avgRange <= 0) return false;
   
   // فحص الدوجي الأساسي
   if(!CCandleUtils::IsDoji(open[idx], close[idx], avgRange, m_dojiThreshold))
      return false;
   
   // فحص طول الظلال
   double body = CCandleUtils::CandleBody(open[idx], close[idx]);
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // كلا الظلين يجب أن يكونا طويلين
   if(upperShadow < avgRange * 0.3 || lowerShadow < avgRange * 0.3)
      return false;
      
   // نسبة الظلال إلى الجسم
   if(body > 0 && (upperShadow < body * m_minShadowRatio || lowerShadow < body * m_minShadowRatio))
      return false;
      
   return true;
}

double CLongLeggedDojiPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة أكبر كلما كانت الظلال أطول
   double totalRange = high[idx] - low[idx];
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 14, idx + 1);
   
   if(totalRange > avgRange * 2.0)
      strength += 1.0;
   else if(totalRange > avgRange * 1.5)
      strength += 0.5;
      
   // تأكيد بالحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.3)
         strength += 0.5;
   }
   
   return MathMin(3.0, strength);
}

SPatternSignal CLongLeggedDojiPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                    const double &open[], const double &high[], 
                                                    const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   // إشارة محايدة قوية - توقع تقلبات
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

//+------------------------------------------------------------------+
//| تنفيذ دوجي شاهد القبر                                             |
//+------------------------------------------------------------------+
CGravestoneDojiPattern::CGravestoneDojiPattern(double threshold)
{
   // تهيئة الفئة الأساسية
   m_name = "دوجي شاهد القبر";
   m_type = PATTERN_SINGLE;
   m_direction = PATTERN_BEARISH;
   m_defaultStrength = PATTERN_STRENGTH_STRONG;
   m_requiredBars = 1;
   m_reliability = 0.75;
   m_description = "نمط انعكاس هبوطي قوي يظهر في القمم";
   m_defaultColor = clrRed;
   
   // تهيئة متغيرات الفئة
   m_dojiThreshold = threshold;
   m_upperShadowRatio = 0.6;
   m_lowerShadowLimit = 0.1;
}

CGravestoneDojiPattern::~CGravestoneDojiPattern() {}

bool CGravestoneDojiPattern::Detect(const int idx, const double &open[], const double &high[], 
                                   const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 5, idx))
      return false;
      
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 14, idx + 1);
   if(avgRange <= 0) return false;
   
   // فحص الدوجي الأساسي
   if(!CCandleUtils::IsDoji(open[idx], close[idx], avgRange, m_dojiThreshold))
      return false;
   
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // الظل العلوي يجب أن يكون مهيمناً
   if(upperShadow < totalRange * m_upperShadowRatio)
      return false;
      
   // الظل السفلي يجب أن يكون ضئيلاً أو غير موجود
   if(lowerShadow > totalRange * m_lowerShadowLimit)
      return false;
      
   // يفضل أن يكون في اتجاه صاعد (قمة)
   if(!IsInUptrend(idx, close))
      return false;
      
   return true;
}

bool CGravestoneDojiPattern::IsInUptrend(const int idx, const double &close[])
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

double CGravestoneDojiPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة أكبر كلما كان الظل العلوي أطول
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   
   double shadowRatio = upperShadow / totalRange;
   if(shadowRatio > 0.8)
      strength += 1.0;
   else if(shadowRatio > 0.7)
      strength += 0.5;
      
   // تأكيد الحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.5)
         strength += 0.5;
   }
   
   // قوة الاتجاه السابق
   if(idx + 3 < ArraySize(close))
   {
      double priceChange = (close[idx] - close[idx + 3]) / close[idx + 3];
      if(priceChange > 0.02) // ارتفاع 2% في آخر 3 شموع
         strength += 0.5;
   }
   
   return MathMin(3.0, strength);
}

SPatternSignal CGravestoneDojiPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   signal.entryPrice = low[idx] + range * 0.2; // دخول قريب من القاع
   signal.stopLoss = high[idx] + range * 0.1;  // وقف فوق القمة
   signal.takeProfit = signal.entryPrice - (signal.stopLoss - signal.entryPrice) * 2.0; // نسبة 1:2
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ دوجي اليعسوب                                                |
//+------------------------------------------------------------------+
CDragonflyDojiPattern::CDragonflyDojiPattern(double threshold)
{
   // تهيئة الفئة الأساسية
   m_name = "دوجي اليعسوب";
   m_type = PATTERN_SINGLE;
   m_direction = PATTERN_BULLISH;
   m_defaultStrength = PATTERN_STRENGTH_STRONG;
   m_requiredBars = 1;
   m_reliability = 0.75;
   m_description = "نمط انعكاس صعودي يظهر في القيعان";
   m_defaultColor = clrLime;
   
   // تهيئة متغيرات الفئة
   m_dojiThreshold = threshold;
   m_lowerShadowRatio = 0.6;
   m_upperShadowLimit = 0.1;
}

CDragonflyDojiPattern::~CDragonflyDojiPattern() {}

bool CDragonflyDojiPattern::Detect(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 5, idx))
      return false;
      
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 14, idx + 1);
   if(avgRange <= 0) return false;
   
   // فحص الدوجي الأساسي
   if(!CCandleUtils::IsDoji(open[idx], close[idx], avgRange, m_dojiThreshold))
      return false;
   
   double totalRange = high[idx] - low[idx];
   double upperShadow = CCandleUtils::UpperShadow(open[idx], high[idx], close[idx]);
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   // الظل السفلي يجب أن يكون مهيمناً
   if(lowerShadow < totalRange * m_lowerShadowRatio)
      return false;
      
   // الظل العلوي يجب أن يكون ضئيلاً أو غير موجود
   if(upperShadow > totalRange * m_upperShadowLimit)
      return false;
      
   // يفضل أن يكون في اتجاه هابط (قاع)
   if(!IsInDowntrend(idx, close))
      return false;
      
   return true;
}

bool CDragonflyDojiPattern::IsInDowntrend(const int idx, const double &close[])
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

double CDragonflyDojiPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   double strength = m_defaultStrength;
   
   // قوة أكبر كلما كان الظل السفلي أطول
   double totalRange = high[idx] - low[idx];
   double lowerShadow = CCandleUtils::LowerShadow(open[idx], low[idx], close[idx]);
   
   double shadowRatio = lowerShadow / totalRange;
   if(shadowRatio > 0.8)
      strength += 1.0;
   else if(shadowRatio > 0.7)
      strength += 0.5;
      
   // تأكيد الحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] > avgVolume * 1.5)
         strength += 0.5;
   }
   
   // قوة الاتجاه السابق
   if(idx + 3 < ArraySize(close))
   {
      double priceChange = (close[idx + 3] - close[idx]) / close[idx + 3];
      if(priceChange > 0.02) // انخفاض 2% في آخر 3 شموع
         strength += 0.5;
   }
   
   return MathMin(3.0, strength);
}

SPatternSignal CDragonflyDojiPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   signal.entryPrice = high[idx] - range * 0.2; // دخول قريب من القمة
   signal.stopLoss = low[idx] - range * 0.1;    // وقف تحت القاع
   signal.takeProfit = signal.entryPrice + (signal.entryPrice - signal.stopLoss) * 2.0; // نسبة 1:2
   
   return signal;
}

//+------------------------------------------------------------------+
//| تنفيذ دوجي الأربعة أسعار                                          |
//+------------------------------------------------------------------+
CFourPriceDojiPattern::CFourPriceDojiPattern(double threshold)
{
   // تهيئة الفئة الأساسية
   m_name = "دوجي الأربعة أسعار";
   m_type = PATTERN_SINGLE;
   m_direction = PATTERN_NEUTRAL;
   m_defaultStrength = PATTERN_STRENGTH_STRONG;  // استخدام PATTERN_STRENGTH_STRONG بدلاً من VERY_STRONG
   m_requiredBars = 1;
   m_reliability = 0.95;
   m_description = "نمط نادر جداً يشير إلى توازن مثالي";
   m_defaultColor = clrWhite;
   
   // تهيئة متغيرات الفئة
   m_priceThreshold = threshold;
}

CFourPriceDojiPattern::~CFourPriceDojiPattern() {}

bool CFourPriceDojiPattern::Detect(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[], const long &volume[])
{
   if(!CCandleUtils::ValidateArrays(open, high, low, close, 1, idx))
      return false;
      
   double avgRange = CCandleUtils::CalculateAvgRange(high, low, 14, idx + 1);
   if(avgRange <= 0) return false;
   
   double threshold = m_priceThreshold * avgRange;
   
   // جميع الأسعار متساوية تقريباً
   double basePrice = open[idx];
   
   if(MathAbs(high[idx] - basePrice) > threshold)
      return false;
   if(MathAbs(low[idx] - basePrice) > threshold)
      return false;
   if(MathAbs(close[idx] - basePrice) > threshold)
      return false;
      
   return true;
}

double CFourPriceDojiPattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[], const long &volume[])
{
   if(!Detect(idx, open, high, low, close, volume))
      return 0.0;
      
   // هذا النمط نادر جداً ويحمل قوة عالية
   double strength = 3.0;
   
   // تأكيد إضافي بالحجم
   if(idx < ArraySize(volume) - 1)
   {
      double avgVolume = CCandleUtils::CalculateAvgVolume(volume, 10, idx + 1);
      if(volume[idx] < avgVolume * 0.5) // حجم منخفض يؤكد الركود
         strength = 3.0;
      else
         strength = 2.5;
   }
   
   return strength;
}

SPatternSignal CFourPriceDojiPattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                                   const double &open[], const double &high[], 
                                                   const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   // إشارة محايدة قوية جداً - انتظار اتجاه جديد
   signal.type = SIGNAL_NONE;
   signal.strength = 1.0; // أقصى قوة
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   
   // نقطة التوازن المثالية
   signal.entryPrice = open[idx];
   signal.stopLoss = 0.0;  // يحتاج استراتيجية خاصة
   signal.takeProfit = 0.0;
   
   return signal;
}