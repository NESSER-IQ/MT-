//+------------------------------------------------------------------+
//|                                        TraditionalPatterns.mqh |
//|                                      الأنماط اليابانية التقليدية |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة الأنماط اليابانية التقليدية                                 |
//+------------------------------------------------------------------+
class CTraditionalPatterns : public CPatternDetector
{
private:
   double            m_sankuThreshold;        // حد سانكو (ثلاث فجوات)
   double            m_sanpeiRatio;           // نسبة سانبي (ثلاث جنود)
   double            m_sanpoAlignment;        // محاذاة سانبو (ثلاث طرق)
   double            m_santenBalance;         // توازن سانتن (ثلاث نقاط)
   
public:
   // المنشئ والهادم
                     CTraditionalPatterns();
                     ~CTraditionalPatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // الأنماط التقليدية المحددة
   bool              DetectSanku(const int idx, const double &open[], const double &high[], 
                               const double &low[], const double &close[], 
                               SPatternDetectionResult &result);
                               
   bool              DetectSanpei(const int idx, const double &open[], const double &high[], 
                                const double &low[], const double &close[], 
                                SPatternDetectionResult &result);
                                
   bool              DetectSanpo(const int idx, const double &open[], const double &high[], 
                               const double &low[], const double &close[], 
                               SPatternDetectionResult &result);
                               
   bool              DetectSanten(const int idx, const double &open[], const double &high[], 
                                const double &low[], const double &close[], 
                                SPatternDetectionResult &result);
   
   // دوال مساعدة للأنماط اليابانية
   bool              IsSankuPattern(const double &highArray[], const double &lowArray[], int startIdx);
   bool              IsSanpeiFormation(const double &openArray[], const double &closeArray[], int startIdx);
   bool              IsSanpoMethod(const double &openArray[], const double &highArray[], const double &lowArray[], 
                                 const double &closeArray[], int startIdx);
   bool              IsSantenBalance(const double &openArray[], const double &highArray[], const double &lowArray[], 
                                   const double &closeArray[], int startIdx);
   double            CalculateTraditionalStrength(const double &open[], const double &high[], 
                                                 const double &low[], const double &close[], int startIdx);
   bool              HasTraditionalHarmony(const double &open[], const double &close[], int startIdx);
   double            GetSankuGapQuality(const double &highArray[], const double &lowArray[], int startIdx);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CTraditionalPatterns::CTraditionalPatterns()
{
   m_sankuThreshold = 0.002;     // 0.2% حد أدنى لفجوات سانكو
   m_sanpeiRatio = 0.8;          // 80% تشابه لجنود سانبي
   m_sanpoAlignment = 0.7;       // 70% محاذاة لطرق سانبو
   m_santenBalance = 0.6;        // 60% توازن لنقاط سانتن
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CTraditionalPatterns::~CTraditionalPatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع الأنماط التقليدية                                 |
//+------------------------------------------------------------------+
int CTraditionalPatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف سانكو (ثلاث فجوات)
   if(DetectSanku(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف سانبي (ثلاث جنود)
   if(DetectSanpei(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف سانبو (ثلاث طرق)
   if(DetectSanpo(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف سانتن (ثلاث نقاط)
   if(DetectSanten(idx, open, high, low, close, result))
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
//| كشف سانكو (Sanku - ثلاث فجوات)                                 |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::DetectSanku(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[], 
                                      SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من نمط سانكو (ثلاث فجوات متتالية)
   if(!IsSankuPattern(high, low, idx-2)) return false;
   
   // سانكو التقليدي: ثلاث فجوات في نفس الاتجاه
   bool upwardSanku = true;
   bool downwardSanku = true;
   
   // التحقق من الفجوات الصاعدة
   for(int i = 0; i < 2; i++)
   {
      if(low[idx-1+i] <= high[idx-2+i])
         upwardSanku = false;
   }
   
   // التحقق من الفجوات الهابطة
   for(int i = 0; i < 2; i++)
   {
      if(high[idx-1+i] >= low[idx-2+i])
         downwardSanku = false;
   }
   
   if(!upwardSanku && !downwardSanku) return false;
   
   // حساب جودة الفجوات
   double gapQuality = GetSankuGapQuality(high, low, idx-2);
   
   // في التقليد الياباني، سانكو يشير لذروة وانعكاس محتمل
   bool extremeReached = false;
   ENUM_PATTERN_DIRECTION direction = PATTERN_NEUTRAL;
   
   if(upwardSanku)
   {
      // ثلاث فجوات صاعدة تشير لذروة شراء
      extremeReached = true;
      direction = PATTERN_BEARISH; // انعكاس هبوطي محتمل
   }
   else if(downwardSanku)
   {
      // ثلاث فجوات هابطة تشير لذروة بيع
      extremeReached = true;
      direction = PATTERN_BULLISH; // انعكاس صعودي محتمل
   }
   
   // التحقق من علامات الإنهاك التقليدية
   bool showsExhaustion = false;
   
   // حجم الفجوة الأخيرة أصغر (علامة ضعف)
   double gap1 = 0, gap2 = 0;
   if(upwardSanku)
   {
      gap1 = low[idx-1] - high[idx-2];
      gap2 = low[idx] - high[idx-1];
   }
   else
   {
      gap1 = low[idx-2] - high[idx-1];
      gap2 = low[idx-1] - high[idx];
   }
   
   if(gap2 < gap1 * 0.8) // الفجوة الأخيرة أصغر بـ 20%
      showsExhaustion = true;
   
   result.patternName = upwardSanku ? "Sanku Up" : "Sanku Down";
   result.strength = gapQuality * 2.0;
   result.reliability = showsExhaustion ? 0.80 : 0.70;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف سانبي (Sanpei - ثلاث جنود)                                 |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::DetectSanpei(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من تشكيل سانبي (ثلاث جنود)
   if(!IsSanpeiFormation(open, close, idx-2)) return false;
   
   // سانبي التقليدي: ثلاث شموع في نفس الاتجاه مع انتظام
   bool whiteSanpei = true; // جنود بيض (صاعد)
   bool blackSanpei = true; // جنود سود (هابط)
   
   // التحقق من الجنود البيض
   for(int i = 0; i < 3; i++)
   {
      if(close[idx-2+i] <= open[idx-2+i])
         whiteSanpei = false;
   }
   
   // التحقق من الجنود السود
   for(int i = 0; i < 3; i++)
   {
      if(close[idx-2+i] >= open[idx-2+i])
         blackSanpei = false;
   }
   
   if(!whiteSanpei && !blackSanpei) return false;
   
   // التحقق من الانتظام التقليدي
   bool regularFormation = true;
   
   for(int i = 1; i < 3; i++)
   {
      // كل جندي يفتح ضمن جسم السابق أو قريباً منه
      bool properOpening = false;
      
      if(whiteSanpei)
      {
         properOpening = (open[idx-2+i] >= open[idx-2+i-1]) && 
                        (open[idx-2+i] <= close[idx-2+i-1]);
      }
      else
      {
         properOpening = (open[idx-2+i] <= open[idx-2+i-1]) && 
                        (open[idx-2+i] >= close[idx-2+i-1]);
      }
      
      if(!properOpening)
      {
         regularFormation = false;
         break;
      }
   }
   
   if(!regularFormation) return false;
   
   // التحقق من التشابه في الحجم (تقليد ياباني)
   bool similarSizes = true;
   double firstBody = MathAbs(close[idx-2] - open[idx-2]);
   
   for(int i = 1; i < 3; i++)
   {
      double currentBody = MathAbs(close[idx-2+i] - open[idx-2+i]);
      double ratio = (firstBody > 0) ? currentBody / firstBody : 1.0;
      
      if(ratio < m_sanpeiRatio || ratio > (1.0 / m_sanpeiRatio))
      {
         similarSizes = false;
         break;
      }
   }
   
   // التحقق من التناغم التقليدي
   bool hasHarmony = HasTraditionalHarmony(open, close, idx-2);
   
   result.patternName = whiteSanpei ? "Sanpei White" : "Sanpei Black";
   result.strength = firstBody * 100; // تحويل لنقاط
   result.reliability = (similarSizes && hasHarmony) ? 0.85 : 0.75;
   result.direction = whiteSanpei ? PATTERN_BULLISH : PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف سانبو (Sanpo - ثلاث طرق)                                   |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::DetectSanpo(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[], 
                                      SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من طريقة سانبو
   if(!IsSanpoMethod(open, high, low, close, idx-2)) return false;
   
   // سانبو التقليدي: اتجاه، تراجع، استئناف
   bool upwardSanpo = false;
   bool downwardSanpo = false;
   
   // تحليل الطريقة الصاعدة
   if((close[idx-2] > open[idx-2]) && // أولى صاعدة
      (close[idx-1] < open[idx-1]) && // ثانية هابطة (تراجع)
      (close[idx] > open[idx]) &&     // ثالثة صاعدة (استئناف)
      (close[idx] > close[idx-2]))    // تجاوز الأولى
   {
      upwardSanpo = true;
   }
   
   // تحليل الطريقة الهابطة
   if((close[idx-2] < open[idx-2]) && // أولى هابطة
      (close[idx-1] > open[idx-1]) && // ثانية صاعدة (تراجع)
      (close[idx] < open[idx]) &&     // ثالثة هابطة (استئناف)
      (close[idx] < close[idx-2]))    // تجاوز الأولى
   {
      downwardSanpo = true;
   }
   
   if(!upwardSanpo && !downwardSanpo) return false;
   
   // التحقق من أن التراجع محدود (تقليد ياباني)
   bool limitedRetracement = false;
   
   if(upwardSanpo)
   {
      // التراجع لا يتجاوز 50% من الحركة الأولى
      double firstMove = close[idx-2] - open[idx-2];
      double retracement = open[idx-1] - close[idx-1];
      limitedRetracement = retracement <= firstMove * 0.5;
   }
   else if(downwardSanpo)
   {
      double firstMove = open[idx-2] - close[idx-2];
      double retracement = close[idx-1] - open[idx-1];
      limitedRetracement = retracement <= firstMove * 0.5;
   }
   
   if(!limitedRetracement) return false;
   
   // التحقق من قوة الاستئناف
   bool strongResumption = false;
   
   if(upwardSanpo)
   {
      double resumptionMove = close[idx] - open[idx];
      double firstMove = close[idx-2] - open[idx-2];
      strongResumption = resumptionMove >= firstMove * 0.8; // 80% من القوة الأولى
   }
   else if(downwardSanpo)
   {
      double resumptionMove = open[idx] - close[idx];
      double firstMove = open[idx-2] - close[idx-2];
      strongResumption = resumptionMove >= firstMove * 0.8;
   }
   
   result.patternName = upwardSanpo ? "Sanpo Up" : "Sanpo Down";
   result.strength = 1.8;
   result.reliability = strongResumption ? 0.80 : 0.70;
   result.direction = upwardSanpo ? PATTERN_BULLISH : PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف سانتن (Santen - ثلاث نقاط)                                 |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::DetectSanten(const int idx, const double &open[], const double &high[], 
                                       const double &low[], const double &close[], 
                                       SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من توازن سانتن
   if(!IsSantenBalance(open, high, low, close, idx-2)) return false;
   
   // سانتن التقليدي: ثلاث نقاط توازن
   // النقطة الأولى: شمعة قوية
   double firstRange = high[idx-2] - low[idx-2];
   double firstBody = MathAbs(close[idx-2] - open[idx-2]);
   bool firstStrong = (firstRange > 0) && (firstBody / firstRange > 0.6);
   
   // النقطة الثانية: شمعة توازن (أصغر)
   double secondRange = high[idx-1] - low[idx-1];
   double secondBody = MathAbs(close[idx-1] - open[idx-1]);
   bool secondBalance = (secondRange > 0) && (secondBody / secondRange < 0.5) && 
                       (secondRange < firstRange * 0.8);
   
   // النقطة الثالثة: شمعة قرار
   double thirdRange = high[idx] - low[idx];
   double thirdBody = MathAbs(close[idx] - open[idx]);
   bool thirdDecision = (thirdRange > 0) && (thirdBody / thirdRange > 0.5);
   
   if(!firstStrong || !secondBalance || !thirdDecision) return false;
   
   // التحقق من التوازن التقليدي
   // النقاط الثلاث يجب أن تكون متوازنة في الموقع
   double point1 = (high[idx-2] + low[idx-2]) / 2.0;
   double point2 = (high[idx-1] + low[idx-1]) / 2.0;
   double point3 = (high[idx] + low[idx]) / 2.0;
   
   // التحقق من أن النقطة الوسطى تقع بين الأخريتين أو قريبة منهما
   double minPoint = MathMin(point1, point3);
   double maxPoint = MathMax(point1, point3);
   double range = maxPoint - minPoint;
   
   bool balancedPoints = (range > 0) && 
                        (point2 >= minPoint - range * 0.1) && 
                        (point2 <= maxPoint + range * 0.1);
   
   if(!balancedPoints) return false;
   
   // تحديد الاتجاه بناء على النقطة الثالثة
   ENUM_PATTERN_DIRECTION direction = PATTERN_NEUTRAL;
   
   if(close[idx] > open[idx] && point3 > point1)
      direction = PATTERN_BULLISH;
   else if(close[idx] < open[idx] && point3 < point1)
      direction = PATTERN_BEARISH;
   
   // حساب قوة التوازن
   double balanceStrength = CalculateTraditionalStrength(open, high, low, close, idx-2);
   
   result.patternName = "Santen";
   result.strength = balanceStrength;
   result.reliability = 0.70;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من نمط سانكو                                             |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::IsSankuPattern(const double &highArray[], const double &lowArray[], int startIdx)
{
   // التحقق من صحة البيانات
   if(startIdx < 0 || ArraySize(highArray) <= startIdx + 2 || ArraySize(lowArray) <= startIdx + 2)
      return false;
   
   // التحقق من وجود فجوتين متتاليتين
   int gapCount = 0;
   
   for(int i = 0; i < 2; i++)
   {
      int currentIdx = startIdx + i;
      int nextIdx = startIdx + i + 1;
      
      // التحقق من حدود المصفوفة
      if(nextIdx >= ArraySize(highArray) || nextIdx >= ArraySize(lowArray))
         continue;
      
      // فجوة صاعدة
      if(lowArray[nextIdx] > highArray[currentIdx] && highArray[currentIdx] > 0)
      {
         double gapSize = (lowArray[nextIdx] - highArray[currentIdx]) / highArray[currentIdx];
         if(gapSize >= m_sankuThreshold)
            gapCount++;
      }
      // فجوة هابطة
      else if(highArray[nextIdx] < lowArray[currentIdx] && lowArray[currentIdx] > 0)
      {
         double gapSize = (lowArray[currentIdx] - highArray[nextIdx]) / lowArray[currentIdx];
         if(gapSize >= m_sankuThreshold)
            gapCount++;
      }
   }
   
   return gapCount >= 2;
}

//+------------------------------------------------------------------+
//| التحقق من تشكيل سانبي                                           |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::IsSanpeiFormation(const double &openArray[], const double &closeArray[], int startIdx)
{
   // التحقق من صحة البيانات
   if(startIdx < 0 || ArraySize(openArray) <= startIdx + 2 || ArraySize(closeArray) <= startIdx + 2)
      return false;
   
   // التحقق من أن الشموع الثلاث في نفس الاتجاه
   bool allBullish = true;
   bool allBearish = true;
   
   for(int i = 0; i < 3; i++)
   {
      int currentIdx = startIdx + i;
      
      // التحقق من حدود المصفوفة
      if(currentIdx >= ArraySize(openArray) || currentIdx >= ArraySize(closeArray))
         return false;
      
      if(closeArray[currentIdx] <= openArray[currentIdx])
         allBullish = false;
      if(closeArray[currentIdx] >= openArray[currentIdx])
         allBearish = false;
   }
   
   return allBullish || allBearish;
}

//+------------------------------------------------------------------+
//| التحقق من طريقة سانبو                                           |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::IsSanpoMethod(const double &openArray[], const double &highArray[], const double &lowArray[], 
                                        const double &closeArray[], int startIdx)
{
   // التحقق من صحة البيانات
   if(startIdx < 0 || 
      ArraySize(openArray) <= startIdx + 2 || ArraySize(highArray) <= startIdx + 2 ||
      ArraySize(lowArray) <= startIdx + 2 || ArraySize(closeArray) <= startIdx + 2)
      return false;
   
   // التحقق من نمط: اتجاه - تراجع - استئناف
   
   // النمط الأول: صاعد - هابط - صاعد
   bool pattern1 = (closeArray[startIdx] > openArray[startIdx]) &&     // صاعد
                  (closeArray[startIdx+1] < openArray[startIdx+1]) &&   // هابط (تراجع)
                  (closeArray[startIdx+2] > openArray[startIdx+2]);     // صاعد (استئناف)
   
   // النمط الثاني: هابط - صاعد - هابط
   bool pattern2 = (closeArray[startIdx] < openArray[startIdx]) &&     // هابط
                  (closeArray[startIdx+1] > openArray[startIdx+1]) &&   // صاعد (تراجع)
                  (closeArray[startIdx+2] < openArray[startIdx+2]);     // هابط (استئناف)
   
   return pattern1 || pattern2;
}

//+------------------------------------------------------------------+
//| التحقق من توازن سانتن                                           |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::IsSantenBalance(const double &openArray[], const double &highArray[], const double &lowArray[], 
                                          const double &closeArray[], int startIdx)
{
   // التحقق من صحة البيانات
   if(startIdx < 0 || 
      ArraySize(openArray) <= startIdx + 2 || ArraySize(highArray) <= startIdx + 2 ||
      ArraySize(lowArray) <= startIdx + 2 || ArraySize(closeArray) <= startIdx + 2)
      return false;
   
   // التحقق من أن الشموع تكون نقاط توازن
   double range1 = highArray[startIdx] - lowArray[startIdx];
   double range2 = highArray[startIdx+1] - lowArray[startIdx+1];
   double range3 = highArray[startIdx+2] - lowArray[startIdx+2];
   
   // التحقق من صحة القيم
   if(range1 <= 0 || range2 <= 0 || range3 <= 0)
      return false;
   
   // النقطة الوسطى يجب أن تكون أصغر (نقطة توازن)
   bool middleSmaller = (range2 < range1 * m_santenBalance) && 
                       (range2 < range3 * m_santenBalance);
   
   return middleSmaller;
}

//+------------------------------------------------------------------+
//| حساب القوة التقليدية                                            |
//+------------------------------------------------------------------+
double CTraditionalPatterns::CalculateTraditionalStrength(const double &openArray[], const double &highArray[], 
                                                         const double &lowArray[], const double &closeArray[], int startIdx)
{
   // التحقق من صحة البيانات
   if(startIdx < 0 || 
      ArraySize(openArray) <= startIdx + 2 || ArraySize(highArray) <= startIdx + 2 ||
      ArraySize(lowArray) <= startIdx + 2 || ArraySize(closeArray) <= startIdx + 2)
      return 0.0;
   
   double totalRange = 0;
   double totalBody = 0;
   
   for(int i = 0; i < 3; i++)
   {
      int currentIdx = startIdx + i;
      
      // التحقق من حدود المصفوفة
      if(currentIdx >= ArraySize(highArray) || currentIdx >= ArraySize(lowArray) ||
         currentIdx >= ArraySize(openArray) || currentIdx >= ArraySize(closeArray))
         continue;
      
      double range = highArray[currentIdx] - lowArray[currentIdx];
      double body = MathAbs(closeArray[currentIdx] - openArray[currentIdx]);
      
      // تجاهل القيم السالبة أو الصفر
      if(range > 0)
      {
         totalRange += range;
         totalBody += body;
      }
   }
   
   double avgRange = totalRange / 3.0;
   double avgBody = totalBody / 3.0;
   
   return (avgRange > 0) ? MathMin((avgBody / avgRange) * 2.0, 3.0) : 0.0; // حد أقصى 3.0
}

//+------------------------------------------------------------------+
//| التحقق من التناغم التقليدي                                      |
//+------------------------------------------------------------------+
bool CTraditionalPatterns::HasTraditionalHarmony(const double &open[], const double &close[], int startIdx)
{
   // التناغم: كل شمعة تكمل السابقة بطريقة متوازنة
   bool harmony = true;
   
   for(int i = 1; i < 3; i++)
   {
      // كل شمعة تفتح قريباً من إغلاق السابقة
      double gap = MathAbs(open[startIdx + i] - close[startIdx + i - 1]);
      double prevRange = high[startIdx + i - 1] - low[startIdx + i - 1];
      
      if(prevRange > 0 && gap > prevRange * 0.1) // فجوة أكبر من 10%
      {
         harmony = false;
         break;
      }
   }
   
   return harmony;
}

//+------------------------------------------------------------------+
//| حساب جودة فجوات سانكو                                           |
//+------------------------------------------------------------------+
double CTraditionalPatterns::GetSankuGapQuality(const double &highArray[], const double &lowArray[], int startIdx)
{
   double totalGapSize = 0;
   int gapCount = 0;
   
   // التحقق من صحة البيانات
   if(startIdx < 0 || ArraySize(highArray) <= startIdx + 2 || ArraySize(lowArray) <= startIdx + 2)
      return 0;
   
   for(int i = 0; i < 2; i++)
   {
      double gapSize = 0;
      int currentIdx = startIdx + i;
      int nextIdx = startIdx + i + 1;
      
      // التحقق من حدود المصفوفة
      if(nextIdx >= ArraySize(highArray) || nextIdx >= ArraySize(lowArray))
         continue;
      
      // فجوة صاعدة
      if(lowArray[nextIdx] > highArray[currentIdx] && highArray[currentIdx] > 0)
      {
         gapSize = (lowArray[nextIdx] - highArray[currentIdx]) / highArray[currentIdx];
      }
      // فجوة هابطة
      else if(highArray[nextIdx] < lowArray[currentIdx] && lowArray[currentIdx] > 0)
      {
         gapSize = (lowArray[currentIdx] - highArray[nextIdx]) / lowArray[currentIdx];
      }
      
      if(gapSize > 0)
      {
         totalGapSize += gapSize;
         gapCount++;
      }
   }
   
   return (gapCount > 0) ? (totalGapSize / gapCount) * 1000 : 0; // تحويل لنقاط
}
