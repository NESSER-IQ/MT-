//+------------------------------------------------------------------+
//|                                                CandleUtils.mqh    |
//|                        حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//|                                       https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| تعداد أنواع الشموع الأساسية                                        |
//+------------------------------------------------------------------+
enum ENUM_CANDLE_TYPE
{
   CANDLE_TYPE_UNDEFINED = 0,    // غير محدد
   CANDLE_TYPE_BULLISH = 1,      // شمعة صاعدة
   CANDLE_TYPE_BEARISH = 2,      // شمعة هابطة
   CANDLE_TYPE_DOJI = 3,         // دوجي
   CANDLE_TYPE_SPINNING_TOP = 4, // إسفين
   CANDLE_TYPE_MARUBOZU = 5,     // ماروبوزو
   CANDLE_TYPE_HAMMER = 6,       // مطرقة
   CANDLE_TYPE_INVERTED_HAMMER = 7, // مطرقة مقلوبة
   CANDLE_TYPE_DRAGONFLY_DOJI = 8,  // دوجي اليعسوب
   CANDLE_TYPE_GRAVESTONE_DOJI = 9  // دوجي شاهد القبر
};

//+------------------------------------------------------------------+
//| تعداد أنواع الفجوات السعرية                                        |
//+------------------------------------------------------------------+
enum ENUM_GAP_TYPE
{
   GAP_TYPE_NONE = 0,        // لا يوجد فجوة
   GAP_TYPE_UP = 1,          // فجوة صاعدة
   GAP_TYPE_DOWN = 2,        // فجوة هابطة
   GAP_TYPE_ISLAND_TOP = 3,  // فجوة جزيرية علوية
   GAP_TYPE_ISLAND_BOTTOM = 4 // فجوة جزيرية سفلية
};

//+------------------------------------------------------------------+
//| هيكل لتخزين خصائص الشمعة                                          |
//+------------------------------------------------------------------+
struct SCandleProperties
{
   ENUM_CANDLE_TYPE type;       // نوع الشمعة
   double bodySize;             // حجم جسم الشمعة
   double upperShadow;          // طول الظل العلوي
   double lowerShadow;          // طول الظل السفلي
   double totalRange;           // المدى الكلي للشمعة
   double bodyToRangeRatio;     // نسبة الجسم إلى المدى الكلي
   
   SCandleProperties()
   {
      type = CANDLE_TYPE_UNDEFINED;
      bodySize = 0.0;
      upperShadow = 0.0;
      lowerShadow = 0.0;
      totalRange = 0.0;
      bodyToRangeRatio = 0.0;
   }
};

//+------------------------------------------------------------------+
//| مكتبة أدوات للتعامل مع الشموع اليابانية                            |
//+------------------------------------------------------------------+
class CCandleUtils
{
private:
   // بنية للذاكرة المؤقتة
   static bool          m_cacheInitialized;
   static double        m_cachedAvgBody[];
   static double        m_cachedAvgRange[];
   static string        m_cachedSymbol;
   static ENUM_TIMEFRAMES m_cachedTimeframe;
   static datetime      m_cacheTimestamp;
   static int           m_cacheLength;
   
public:
   //--- دوال التهيئة والتنظيف
   static void          Initialize();
   static void          Deinitialize();
   static void          ClearCache();
   
   //--- المتغيرات الأساسية للشموع
   static ENUM_CANDLE_TYPE GetCandleType(const double open, const double high, const double low, const double close, 
                          const double avgBody, const double avgRange, double dojiThreshold = 0.05);
   static bool          IsBullish(const double open, const double close);
   static bool          IsBearish(const double open, const double close);
   static bool          IsDoji(const double open, const double close, const double avgRange, double threshold = 0.05);
   static double        CandleBody(const double open, const double close);
   static double        UpperShadow(const double open, const double high, const double close);
   static double        LowerShadow(const double open, const double low, const double close);
   static double        CandleRange(const double high, const double low);
   static double        BodyToRangeRatio(const double open, const double high, const double low, const double close);
   
   //--- حساب خصائص الشمعة
   static SCandleProperties GetCandleProperties(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[],
                                            const double avgBody, const double avgRange);
   
   //--- حسابات إحصائية بسيطة
   static double        CalculateAvgBody(const double &open[], const double &close[], const int length, const int startIdx = 0);
   static double        CalculateAvgRange(const double &high[], const double &low[], const int length, const int startIdx = 0);
   static double        CalculateAvgVolume(const long &volume[], const int length, const int startIdx = 0);
   
   //--- دوال الذاكرة المؤقتة
   static double        GetCachedAvgBody(const string symbol, const ENUM_TIMEFRAMES timeframe, const int length, const bool refresh = false);
   static double        GetCachedAvgRange(const string symbol, const ENUM_TIMEFRAMES timeframe, const int length, const bool refresh = false);
   
   //--- دوال التحويل بين الإطارات الزمنية
   static double        GetAvgBodyOnHigherTimeframe(const string symbol, const ENUM_TIMEFRAMES currentTimeframe, 
                                                 const ENUM_TIMEFRAMES targetTimeframe, const int length);
   static double        GetAvgRangeOnHigherTimeframe(const string symbol, const ENUM_TIMEFRAMES currentTimeframe, 
                                                  const ENUM_TIMEFRAMES targetTimeframe, const int length);
   
   //--- دوال الكشف عن الفجوات السعرية
   static ENUM_GAP_TYPE CheckGap(const int idx, const double &open[], const double &high[], 
                               const double &low[], const double &close[]);
   static double        GapSize(const int idx, const double &open[], const double &high[], 
                              const double &low[], const double &close[]);
   static bool          IsGapFilled(const int startIdx, const int currentIdx, const double &open[], 
                                 const double &high[], const double &low[], const double &close[]);
   
   //--- فحص حالة المصفوفات
   static bool          ValidateArrays(const double &open[], const double &high[], const double &low[], const double &close[], const int minSize, const int idx = 0);
   static bool          ValidateArray(const double &array[], const int minSize, const int idx = 0);
   static bool          ValidateArray(const long &array[], const int minSize, const int idx = 0);
};

// تعريف المتغيرات الثابتة
bool CCandleUtils::m_cacheInitialized = false;
double CCandleUtils::m_cachedAvgBody[];
double CCandleUtils::m_cachedAvgRange[];
string CCandleUtils::m_cachedSymbol = "";
ENUM_TIMEFRAMES CCandleUtils::m_cachedTimeframe = PERIOD_CURRENT;
datetime CCandleUtils::m_cacheTimestamp = 0;
int CCandleUtils::m_cacheLength = 0;

//+------------------------------------------------------------------+
//| تهيئة الذاكرة المؤقتة                                              |
//+------------------------------------------------------------------+
void CCandleUtils::Initialize()
{
   if(!m_cacheInitialized)
   {
      ArrayResize(m_cachedAvgBody, 10);
      ArrayResize(m_cachedAvgRange, 10);
      ArrayInitialize(m_cachedAvgBody, 0.0);
      ArrayInitialize(m_cachedAvgRange, 0.0);
      m_cacheInitialized = true;
   }
}

//+------------------------------------------------------------------+
//| تنظيف الذاكرة المؤقتة                                             |
//+------------------------------------------------------------------+
void CCandleUtils::Deinitialize()
{
   if(m_cacheInitialized)
   {
      ArrayFree(m_cachedAvgBody);
      ArrayFree(m_cachedAvgRange);
      m_cacheInitialized = false;
   }
}

//+------------------------------------------------------------------+
//| مسح الذاكرة المؤقتة                                               |
//+------------------------------------------------------------------+
void CCandleUtils::ClearCache()
{
   if(m_cacheInitialized)
   {
      ArrayInitialize(m_cachedAvgBody, 0.0);
      ArrayInitialize(m_cachedAvgRange, 0.0);
      m_cachedSymbol = "";
      m_cachedTimeframe = PERIOD_CURRENT;
      m_cacheTimestamp = 0;
      m_cacheLength = 0;
   }
}

//+------------------------------------------------------------------+
//| تحديد نوع الشمعة                                                  |
//+------------------------------------------------------------------+
ENUM_CANDLE_TYPE CCandleUtils::GetCandleType(const double open, const double high, const double low, const double close, 
                                         const double avgBody, const double avgRange, double dojiThreshold)
{
   if(IsDoji(open, close, avgRange, dojiThreshold))
   {
      // تحديد نوع الدوجي
      double upperShadow = UpperShadow(open, high, close);
      double lowerShadow = LowerShadow(open, low, close);
      
      if(upperShadow <= dojiThreshold * avgRange && lowerShadow >= 0.5 * avgRange)
         return CANDLE_TYPE_DRAGONFLY_DOJI;
      else if(upperShadow >= 0.5 * avgRange && lowerShadow <= dojiThreshold * avgRange)
         return CANDLE_TYPE_GRAVESTONE_DOJI;
      else
         return CANDLE_TYPE_DOJI;
   }
   
   // الشموع غير الدوجي
   double body = CandleBody(open, close);
   double totalRange = CandleRange(high, low);
   double bodyToRange = body / totalRange;
   
   if(bodyToRange >= 0.9) // 90% من المدى هو جسم
   {
      if(IsBullish(open, close))
         return CANDLE_TYPE_MARUBOZU;
      else
         return CANDLE_TYPE_MARUBOZU;
   }
   
   if(bodyToRange <= 0.3) // جسم صغير
   {
      double upperShadow = UpperShadow(open, high, close);
      double lowerShadow = LowerShadow(open, low, close);
      
      if(lowerShadow >= 2 * body && upperShadow <= 0.1 * body)
      {
         if(IsBullish(open, close))
            return CANDLE_TYPE_HAMMER;
         else
            return CANDLE_TYPE_HAMMER;
      }
      else if(upperShadow >= 2 * body && lowerShadow <= 0.1 * body)
      {
         if(IsBullish(open, close))
            return CANDLE_TYPE_INVERTED_HAMMER;
         else
            return CANDLE_TYPE_INVERTED_HAMMER;
      }
      else if(upperShadow >= 1.5 * body && lowerShadow >= 1.5 * body)
         return CANDLE_TYPE_SPINNING_TOP;
   }
   
   // شمعة عادية
   if(IsBullish(open, close))
      return CANDLE_TYPE_BULLISH;
   else
      return CANDLE_TYPE_BEARISH;
}

//+------------------------------------------------------------------+
//| فحص إذا كانت الشمعة صاعدة                                         |
//+------------------------------------------------------------------+
bool CCandleUtils::IsBullish(const double open, const double close)
{
   return close > open;
}

//+------------------------------------------------------------------+
//| فحص إذا كانت الشمعة هابطة                                         |
//+------------------------------------------------------------------+
bool CCandleUtils::IsBearish(const double open, const double close)
{
   return close < open;
}

//+------------------------------------------------------------------+
//| التحقق مما إذا كانت الشمعة دوجي                                    |
//+------------------------------------------------------------------+
bool CCandleUtils::IsDoji(const double open, const double close, const double avgRange, double threshold)
{
   // تجنب القسمة على صفر
   if(avgRange <= 0.0)
      return false;
      
   double bodyThreshold = threshold * avgRange;  // نسبة من متوسط المدى السعري
   return MathAbs(close - open) <= bodyThreshold;
}

//+------------------------------------------------------------------+
//| حساب حجم جسم الشمعة                                              |
//+------------------------------------------------------------------+
double CCandleUtils::CandleBody(const double open, const double close)
{
   return MathAbs(close - open);
}

//+------------------------------------------------------------------+
//| حساب طول الظل العلوي للشمعة                                       |
//+------------------------------------------------------------------+
double CCandleUtils::UpperShadow(const double open, const double high, const double close)
{
   return high - MathMax(open, close);
}

//+------------------------------------------------------------------+
//| حساب طول الظل السفلي للشمعة                                       |
//+------------------------------------------------------------------+
double CCandleUtils::LowerShadow(const double open, const double low, const double close)
{
   return MathMin(open, close) - low;
}

//+------------------------------------------------------------------+
//| حساب المدى الكلي للشمعة                                           |
//+------------------------------------------------------------------+
double CCandleUtils::CandleRange(const double high, const double low)
{
   return high - low;
}

//+------------------------------------------------------------------+
//| حساب نسبة الجسم إلى المدى الكلي                                   |
//+------------------------------------------------------------------+
double CCandleUtils::BodyToRangeRatio(const double open, const double high, const double low, const double close)
{
   double body = CandleBody(open, close);
   double range = CandleRange(high, low);
   
   if(range <= 0.0)
      return 0.0;
      
   return body / range;
}

//+------------------------------------------------------------------+
//| الحصول على خصائص الشمعة                                           |
//+------------------------------------------------------------------+
SCandleProperties CCandleUtils::GetCandleProperties(const int idx, const double &open[], const double &high[], 
                                                const double &low[], const double &close[],
                                                const double avgBody, const double avgRange)
{
   SCandleProperties props;
   
   if(!ValidateArrays(open, high, low, close, 1, idx))
      return props;
      
   props.bodySize = CandleBody(open[idx], close[idx]);
   props.upperShadow = UpperShadow(open[idx], high[idx], close[idx]);
   props.lowerShadow = LowerShadow(open[idx], low[idx], close[idx]);
   props.totalRange = CandleRange(high[idx], low[idx]);
   
   if(props.totalRange > 0.0)
      props.bodyToRangeRatio = props.bodySize / props.totalRange;
   
   props.type = GetCandleType(open[idx], high[idx], low[idx], close[idx], avgBody, avgRange);
   
   return props;
}

//+------------------------------------------------------------------+
//| فحص صلاحية المصفوفات                                             |
//+------------------------------------------------------------------+
bool CCandleUtils::ValidateArrays(const double &open[], const double &high[], const double &low[], const double &close[], const int minSize, const int idx = 0)
{
   return ValidateArray(open, minSize, idx) && 
          ValidateArray(high, minSize, idx) && 
          ValidateArray(low, minSize, idx) && 
          ValidateArray(close, minSize, idx);
}

//+------------------------------------------------------------------+
//| فحص صلاحية مصفوفة من نوع double                                   |
//+------------------------------------------------------------------+
bool CCandleUtils::ValidateArray(const double &array[], const int minSize, const int idx = 0)
{
   int size = ArraySize(array);
   return size >= minSize && idx < size;
}

//+------------------------------------------------------------------+
//| فحص صلاحية مصفوفة من نوع long                                     |
//+------------------------------------------------------------------+
bool CCandleUtils::ValidateArray(const long &array[], const int minSize, const int idx = 0)
{
   int size = ArraySize(array);
   return size >= minSize && idx < size;
}

//+------------------------------------------------------------------+
//| الدالة المساعدة لحساب متوسط حجم الجسم                             |
//+------------------------------------------------------------------+
double CCandleUtils::CalculateAvgBody(const double &open[], const double &close[], const int length, const int startIdx = 0)
{
   if(length <= 0)
      return 0.0;
   
   // التأكد من أن الحجم والمؤشر المبدئي صالحين
   if(!ValidateArray(open, startIdx + length) || !ValidateArray(close, startIdx + length))
      return 0.0;
      
   double totalBody = 0.0;
   int count = 0;
   
   for(int i = startIdx; i < startIdx + length && i < ArraySize(open); i++)
   {
      totalBody += CandleBody(open[i], close[i]);
      count++;
   }
   
   // تجنب القسمة على صفر
   return (count > 0) ? totalBody / count : 0.0;
}

//+------------------------------------------------------------------+
//| الدالة المساعدة لحساب متوسط المدى السعري                          |
//+------------------------------------------------------------------+
double CCandleUtils::CalculateAvgRange(const double &high[], const double &low[], const int length, const int startIdx = 0)
{
   if(length <= 0)
      return 0.0;
   
   // التأكد من أن الحجم والمؤشر المبدئي صالحين
   if(!ValidateArray(high, startIdx + length) || !ValidateArray(low, startIdx + length))
      return 0.0;
      
   double totalRange = 0.0;
   int count = 0;
   
   for(int i = startIdx; i < startIdx + length && i < ArraySize(high); i++)
   {
      totalRange += CandleRange(high[i], low[i]);
      count++;
   }
   
   // تجنب القسمة على صفر
   return (count > 0) ? totalRange / count : 0.0;
}

//+------------------------------------------------------------------+
//| الدالة المساعدة لحساب متوسط الحجم                                 |
//+------------------------------------------------------------------+
double CCandleUtils::CalculateAvgVolume(const long &volume[], const int length, const int startIdx = 0)
{
   if(length <= 0)
      return 0.0;
   
   // التأكد من أن الحجم والمؤشر المبدئي صالحين
   if(!ValidateArray(volume, startIdx + length))
      return 0.0;
      
   double totalVolume = 0.0;
   int count = 0;
   
   for(int i = startIdx; i < startIdx + length && i < ArraySize(volume); i++)
   {
      totalVolume += (double)volume[i];
      count++;
   }
   
   // تجنب القسمة على صفر
   return (count > 0) ? totalVolume / count : 0.0;
}

//+------------------------------------------------------------------+
//| الحصول على متوسط حجم الجسم من الذاكرة المؤقتة                      |
//+------------------------------------------------------------------+
double CCandleUtils::GetCachedAvgBody(const string symbol, const ENUM_TIMEFRAMES timeframe, const int length, const bool refresh = false)
{
   // تهيئة الذاكرة المؤقتة إذا لم تكن مهيأة
   if(!m_cacheInitialized)
      Initialize();
   
   // إذا تم تغيير الرمز أو الإطار الزمني أو مدة المتوسط، أو طلب تحديث
   if(m_cachedSymbol != symbol || m_cachedTimeframe != timeframe || 
      m_cacheLength != length || refresh || TimeCurrent() - m_cacheTimestamp > 300) // تحديث كل 5 دقائق
   {
      // مصفوفات البيانات
      double open[], high[], low[], close[];
      
      // استيراد البيانات
      if(CopyOpen(symbol, timeframe, 0, length, open) != length ||
         CopyHigh(symbol, timeframe, 0, length, high) != length ||
         CopyLow(symbol, timeframe, 0, length, low) != length ||
         CopyClose(symbol, timeframe, 0, length, close) != length)
         return 0.0;
      
      // حساب المتوسطات
      m_cachedAvgBody[0] = CalculateAvgBody(open, close, length);
      m_cachedAvgRange[0] = CalculateAvgRange(high, low, length);
      
      // تحديث معلومات الذاكرة المؤقتة
      m_cachedSymbol = symbol;
      m_cachedTimeframe = timeframe;
      m_cacheLength = length;
      m_cacheTimestamp = TimeCurrent();
   }
   
   return m_cachedAvgBody[0];
}

//+------------------------------------------------------------------+
//| الحصول على متوسط المدى السعري من الذاكرة المؤقتة                   |
//+------------------------------------------------------------------+
double CCandleUtils::GetCachedAvgRange(const string symbol, const ENUM_TIMEFRAMES timeframe, const int length, const bool refresh = false)
{
   // استدعاء دالة متوسط حجم الجسم التي ستحدث الذاكرة المؤقتة أيضاً
   GetCachedAvgBody(symbol, timeframe, length, refresh);
   
   return m_cachedAvgRange[0];
}

//+------------------------------------------------------------------+
//| الحصول على متوسط حجم الجسم في إطار زمني أعلى                       |
//+------------------------------------------------------------------+
double CCandleUtils::GetAvgBodyOnHigherTimeframe(const string symbol, const ENUM_TIMEFRAMES currentTimeframe, 
                                            const ENUM_TIMEFRAMES targetTimeframe, const int length)
{
   if(currentTimeframe >= targetTimeframe)
      return GetCachedAvgBody(symbol, currentTimeframe, length);
      
   // مصفوفات البيانات
   double open[], high[], low[], close[];
   
   // استيراد البيانات من الإطار الزمني المستهدف
   if(CopyOpen(symbol, targetTimeframe, 0, length, open) != length ||
      CopyHigh(symbol, targetTimeframe, 0, length, high) != length ||
      CopyLow(symbol, targetTimeframe, 0, length, low) != length ||
      CopyClose(symbol, targetTimeframe, 0, length, close) != length)
      return 0.0;
   
   return CalculateAvgBody(open, close, length);
}

//+------------------------------------------------------------------+
//| الحصول على متوسط المدى السعري في إطار زمني أعلى                    |
//+------------------------------------------------------------------+
double CCandleUtils::GetAvgRangeOnHigherTimeframe(const string symbol, const ENUM_TIMEFRAMES currentTimeframe, 
                                               const ENUM_TIMEFRAMES targetTimeframe, const int length)
{
   if(currentTimeframe >= targetTimeframe)
      return GetCachedAvgRange(symbol, currentTimeframe, length);
      
   // مصفوفات البيانات
   double high[], low[];
   
   // استيراد البيانات من الإطار الزمني المستهدف
   if(CopyHigh(symbol, targetTimeframe, 0, length, high) != length ||
      CopyLow(symbol, targetTimeframe, 0, length, low) != length)
      return 0.0;
   
   return CalculateAvgRange(high, low, length);
}

//+------------------------------------------------------------------+
//| التحقق من وجود فجوة سعرية                                         |
//+------------------------------------------------------------------+
ENUM_GAP_TYPE CCandleUtils::CheckGap(const int idx, const double &open[], const double &high[], 
                                  const double &low[], const double &close[])
{
   if(!ValidateArrays(open, high, low, close, idx + 2))
      return GAP_TYPE_NONE;
   
   // فحص الفجوة الصاعدة: أدنى سعر للشمعة الحالية > أعلى سعر للشمعة السابقة
   if(low[idx] > high[idx+1])
      return GAP_TYPE_UP;
      
   // فحص الفجوة الهابطة: أعلى سعر للشمعة الحالية < أدنى سعر للشمعة السابقة
   if(high[idx] < low[idx+1])
      return GAP_TYPE_DOWN;
      
   // فحص الفجوة الجزيرية
   if(idx >= 2)
   {
      // فجوة جزيرية علوية: فجوة صاعدة تليها فجوة هابطة
      if(low[idx+1] > high[idx+2] && high[idx] < low[idx+1])
         return GAP_TYPE_ISLAND_TOP;
         
      // فجوة جزيرية سفلية: فجوة هابطة تليها فجوة صاعدة
      if(high[idx+1] < low[idx+2] && low[idx] > high[idx+1])
         return GAP_TYPE_ISLAND_BOTTOM;
   }
   
   return GAP_TYPE_NONE;
}

//+------------------------------------------------------------------+
//| حساب حجم الفجوة السعرية                                          |
//+------------------------------------------------------------------+
double CCandleUtils::GapSize(const int idx, const double &open[], const double &high[], 
                           const double &low[], const double &close[])
{
   if(!ValidateArrays(open, high, low, close, idx + 2))
      return 0.0;
   
   ENUM_GAP_TYPE gapType = CheckGap(idx, open, high, low, close);
   
   switch(gapType)
   {
      case GAP_TYPE_UP:
         return low[idx] - high[idx+1];
         
      case GAP_TYPE_DOWN:
         return low[idx+1] - high[idx];
         
      case GAP_TYPE_ISLAND_TOP:
      case GAP_TYPE_ISLAND_BOTTOM:
         {
            double gap1 = MathAbs(low[idx+1] - high[idx+2]);
            double gap2 = MathAbs(high[idx] - low[idx+1]);
            return gap1 + gap2;
         }
   }
   
   return 0.0;
}

//+------------------------------------------------------------------+
//| التحقق مما إذا كانت الفجوة قد تم ملؤها                            |
//+------------------------------------------------------------------+
bool CCandleUtils::IsGapFilled(const int startIdx, const int currentIdx, const double &open[], 
                            const double &high[], const double &low[], const double &close[])
{
   if(!ValidateArrays(open, high, low, close, MathMax(startIdx, currentIdx) + 1))
      return false;
   
   ENUM_GAP_TYPE gapType = CheckGap(startIdx, open, high, low, close);
   
   if(gapType == GAP_TYPE_NONE)
      return false;
      
   // لا يمكن ملء فجوة في نفس الشمعة
   if(currentIdx == startIdx)
      return false;
      
   switch(gapType)
   {
      case GAP_TYPE_UP:
         // تم ملء الفجوة الصاعدة إذا انخفض السعر إلى مستوى الفجوة
         for(int i = startIdx - 1; i >= currentIdx; i--)
         {
            if(low[i] <= high[startIdx+1])
               return true;
         }
         break;
         
      case GAP_TYPE_DOWN:
         // تم ملء الفجوة الهابطة إذا ارتفع السعر إلى مستوى الفجوة
         for(int i = startIdx - 1; i >= currentIdx; i--)
         {
            if(high[i] >= low[startIdx+1])
               return true;
         }
         break;
         
      case GAP_TYPE_ISLAND_TOP:
      case GAP_TYPE_ISLAND_BOTTOM:
         {
            bool gap1Filled = false;
            bool gap2Filled = false;
            
            for(int i = startIdx - 1; i >= currentIdx; i--)
            {
               if(low[i] <= high[startIdx+2])
                  gap1Filled = true;
                  
               if(high[i] >= low[startIdx+1])
                  gap2Filled = true;
            }
            
            return gap1Filled && gap2Filled;
         }
   }
   
   return false;
}