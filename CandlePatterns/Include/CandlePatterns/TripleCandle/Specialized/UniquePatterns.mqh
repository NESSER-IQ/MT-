//+------------------------------------------------------------------+
//|                                             UniquePatterns.mqh |
//|                                             الأنماط الفريدة     |
//|                         حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include "..\\..\\Base\\PatternDetector.mqh"

//+------------------------------------------------------------------+
//| فئة الأنماط الفريدة                                             |
//+------------------------------------------------------------------+
class CUniquePatterns : public CPatternDetector
{
private:
   double            m_buddhaThreshold;       // حد نمط بوذا
   double            m_riverComplexity;       // تعقد الأنهار
   double            m_formationRarity;       // ندرة التشكيل
   
public:
   // المنشئ والهادم
                     CUniquePatterns();
                     ~CUniquePatterns();
   
   // تهيئة
   virtual bool      Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT);
   
   // الكشف عن الأنماط
   virtual int       DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                     const double &open[], const double &high[], const double &low[], 
                                     const double &close[], const long &volume[], 
                                     SPatternDetectionResult &results[]);
   
   // الأنماط الفريدة المحددة
   bool              DetectThreeBuddhaTop(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[], 
                                        SPatternDetectionResult &result);
                                        
   bool              DetectThreeBuddhaBottom(const int idx, const double &open[], const double &high[], 
                                           const double &low[], const double &close[], 
                                           SPatternDetectionResult &result);
                                           
   bool              DetectUniqueThreeRiver(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result);
                                          
   bool              DetectRareFormations(const int idx, const double &open[], const double &high[], 
                                        const double &low[], const double &close[], 
                                        SPatternDetectionResult &result);
   
   // دوال مساعدة
   bool              IsBuddhaFormation(const double &high[], const double &low[], int startIdx, bool isTop);
   bool              IsThreeRiverComplex(const double &open[], const double &high[], const double &low[], 
                                       const double &close[], int startIdx);
   bool              IsRareFormation(const double &open[], const double &high[], const double &low[], 
                                   const double &close[], int startIdx);
   double            CalculateBuddhaStrength(const double &high[], const double &low[], int startIdx, bool isTop);
   double            CalculateFormationRarity(const double &open[], const double &high[], const double &low[], 
                                            const double &close[], int startIdx);
   bool              HasSymmetricalPattern(const double &values[], int startIdx, int count);
};

//+------------------------------------------------------------------+
//| المنشئ                                                           |
//+------------------------------------------------------------------+
CUniquePatterns::CUniquePatterns()
{
   m_buddhaThreshold = 0.7;      // 70% حد نمط بوذا
   m_riverComplexity = 0.5;      // 50% تعقد الأنهار
   m_formationRarity = 0.1;      // 10% ندرة التشكيل
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CUniquePatterns::~CUniquePatterns()
{
}

//+------------------------------------------------------------------+
//| تهيئة النمط                                                     |
//+------------------------------------------------------------------+
bool CUniquePatterns::Initialize(string symbol = "", ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT)
{
   return CPatternDetector::Initialize(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| الكشف عن جميع الأنماط الفريدة                                   |
//+------------------------------------------------------------------+
int CUniquePatterns::DetectAllPatterns(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
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
   
   // كشف قمة بوذا الثلاثية
   if(DetectThreeBuddhaTop(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف قاع بوذا الثلاثي
   if(DetectThreeBuddhaBottom(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف الأنهار الثلاثة الفريدة
   if(DetectUniqueThreeRiver(idx, open, high, low, close, result))
   {
      result.time = iTime(symbol, timeframe, idx);
      result.barIndex = idx;
      tempResults[found++] = result;
   }
   
   // كشف التشكيلات النادرة
   if(DetectRareFormations(idx, open, high, low, close, result))
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
//| كشف قمة بوذا الثلاثية (Three Buddha Top)                        |
//+------------------------------------------------------------------+
bool CUniquePatterns::DetectThreeBuddhaTop(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من تشكيل بوذا للقمة
   if(!IsBuddhaFormation(high, low, idx-2, true)) return false;
   
   // نمط بوذا: الشمعة الوسطى أعلى من الجانبيتين (رأس وكتفين)
   bool middleHighest = (high[idx-1] > high[idx-2]) && (high[idx-1] > high[idx]);
   if(!middleHighest) return false;
   
   // الكتفين (الجانبيتين) يجب أن يكونا متقاربين في الارتفاع
   double leftShoulder = high[idx-2];
   double rightShoulder = high[idx];
   double shoulderDiff = MathAbs(rightShoulder - leftShoulder);
   double avgShoulder = (leftShoulder + rightShoulder) / 2.0;
   
   if(avgShoulder == 0) return false;
   
   bool symmetricalShoulders = (shoulderDiff / avgShoulder) <= 0.05; // 5% تسامح
   if(!symmetricalShoulders) return false;
   
   // الرأس يجب أن يكون أعلى بوضوح من الكتفين
   double head = high[idx-1];
   double headProminence = (head - avgShoulder) / avgShoulder;
   bool prominentHead = headProminence >= 0.02; // 2% على الأقل أعلى
   
   if(!prominentHead) return false;
   
   // التحقق من خط العنق (neck line) بناء على القيعان
   double leftNeck = low[idx-2];
   double rightNeck = low[idx];
   double neckDiff = MathAbs(rightNeck - leftNeck);
   double avgNeck = (leftNeck + rightNeck) / 2.0;
   
   bool levelNeckline = (avgNeck > 0) && ((neckDiff / avgNeck) <= 0.03); // خط عنق مستوي
   
   // التحقق من أن الشمعة الأخيرة تُظهر ضعف (إغلاق منخفض)
   bool weakClose = close[idx] < (high[idx] + low[idx]) / 2.0; // إغلاق تحت المنتصف
   
   // حساب قوة نمط بوذا
   double buddhaStrength = CalculateBuddhaStrength(high, low, idx-2, true);
   
   result.patternName = "Three Buddha Top";
   result.strength = buddhaStrength;
   result.reliability = (levelNeckline && weakClose) ? 0.80 : 0.70;
   result.direction = PATTERN_BEARISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف قاع بوذا الثلاثي (Three Buddha Bottom)                      |
//+------------------------------------------------------------------+
bool CUniquePatterns::DetectThreeBuddhaBottom(const int idx, const double &open[], const double &high[], 
                                             const double &low[], const double &close[], 
                                             SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من تشكيل بوذا للقاع
   if(!IsBuddhaFormation(high, low, idx-2, false)) return false;
   
   // نمط بوذا المقلوب: الشمعة الوسطى أقل من الجانبيتين
   bool middleLowest = (low[idx-1] < low[idx-2]) && (low[idx-1] < low[idx]);
   if(!middleLowest) return false;
   
   // الكتفين (الجانبيتين) يجب أن يكونا متقاربين في العمق
   double leftShoulder = low[idx-2];
   double rightShoulder = low[idx];
   double shoulderDiff = MathAbs(rightShoulder - leftShoulder);
   double avgShoulder = (leftShoulder + rightShoulder) / 2.0;
   
   if(avgShoulder == 0) return false;
   
   bool symmetricalShoulders = (shoulderDiff / avgShoulder) <= 0.05; // 5% تسامح
   if(!symmetricalShoulders) return false;
   
   // الرأس يجب أن يكون أقل بوضوح من الكتفين
   double head = low[idx-1];
   double headDepth = (avgShoulder - head) / avgShoulder;
   bool prominentHead = headDepth >= 0.02; // 2% على الأقل أقل
   
   if(!prominentHead) return false;
   
   // التحقق من خط العنق بناء على القمم
   double leftNeck = high[idx-2];
   double rightNeck = high[idx];
   double neckDiff = MathAbs(rightNeck - leftNeck);
   double avgNeck = (leftNeck + rightNeck) / 2.0;
   
   bool levelNeckline = (avgNeck > 0) && ((neckDiff / avgNeck) <= 0.03);
   
   // التحقق من أن الشمعة الأخيرة تُظهر قوة (إغلاق مرتفع)
   bool strongClose = close[idx] > (high[idx] + low[idx]) / 2.0; // إغلاق فوق المنتصف
   
   // حساب قوة نمط بوذا
   double buddhaStrength = CalculateBuddhaStrength(high, low, idx-2, false);
   
   result.patternName = "Three Buddha Bottom";
   result.strength = buddhaStrength;
   result.reliability = (levelNeckline && strongClose) ? 0.80 : 0.70;
   result.direction = PATTERN_BULLISH;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف الأنهار الثلاثة الفريدة (Unique Three River)                |
//+------------------------------------------------------------------+
bool CUniquePatterns::DetectUniqueThreeRiver(const int idx, const double &open[], const double &high[], 
                                            const double &low[], const double &close[], 
                                            SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من تعقد نمط الأنهار الثلاثة
   if(!IsThreeRiverComplex(open, high, low, close, idx-2)) return false;
   
   // نمط الأنهار الفريد: كل شمعة تمثل "نهر" بخصائص مختلفة
   
   // النهر الأول: شمعة ذات مدى واسع
   double range1 = high[idx-2] - low[idx-2];
   double body1 = MathAbs(close[idx-2] - open[idx-2]);
   bool wideRiver1 = (range1 > 0) && (body1 / range1 < 0.6); // ظلال كبيرة
   
   // النهر الثاني: شمعة ضيقة أو متردد (تجمع الأنهار)
   double range2 = high[idx-1] - low[idx-1];
   double body2 = MathAbs(close[idx-1] - open[idx-1]);
   bool narrowRiver2 = (range2 > 0) && (range2 < range1 * 0.7); // 30% أصغر على الأقل
   
   // النهر الثالث: شمعة قرار (انفصال الأنهار)
   double range3 = high[idx] - low[idx];
   double body3 = MathAbs(close[idx] - open[idx]);
   bool decisiveRiver3 = (range3 > 0) && (body3 / range3 > 0.5); // جسم قوي
   
   if(!wideRiver1 || !narrowRiver2 || !decisiveRiver3) return false;
   
   // تحديد اتجاه تدفق الأنهار
   double avgPrice1 = (high[idx-2] + low[idx-2]) / 2.0;
   double avgPrice2 = (high[idx-1] + low[idx-1]) / 2.0;
   double avgPrice3 = (high[idx] + low[idx]) / 2.0;
   
   // الأنهار تتدفق في اتجاه واحد مع تجمع في الوسط
   bool flowingUp = (avgPrice3 > avgPrice1) && (avgPrice2 >= MathMin(avgPrice1, avgPrice3));
   bool flowingDown = (avgPrice3 < avgPrice1) && (avgPrice2 <= MathMax(avgPrice1, avgPrice3));
   
   bool validFlow = flowingUp || flowingDown;
   if(!validFlow) return false;
   
   // التحقق من تقارب الأنهار في الوسط
   bool convergence = (range2 < range1) && (range2 < range3);
   if(!convergence) return false;
   
   // تحديد قوة التدفق النهائي
   ENUM_PATTERN_DIRECTION direction = PATTERN_NEUTRAL;
   if(flowingUp && close[idx] > open[idx])
      direction = PATTERN_BULLISH;
   else if(flowingDown && close[idx] < open[idx])
      direction = PATTERN_BEARISH;
   else
      direction = PATTERN_NEUTRAL;
   
   result.patternName = "Unique Three River";
   result.strength = (range1 + range3) / 2.0;
   result.reliability = 0.65;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| كشف التشكيلات النادرة (Rare Formations)                         |
//+------------------------------------------------------------------+
bool CUniquePatterns::DetectRareFormations(const int idx, const double &open[], const double &high[], 
                                          const double &low[], const double &close[], 
                                          SPatternDetectionResult &result)
{
   if(idx < 2) return false;
   
   // التحقق من ندرة التشكيل
   if(!IsRareFormation(open, high, low, close, idx-2)) return false;
   
   // البحث عن أنماط نادرة ومعقدة
   bool foundRarePattern = false;
   string patternName = "";
   double strength = 0;
   double reliability = 0.50; // الأنماط النادرة أقل موثوقية
   ENUM_PATTERN_DIRECTION direction = PATTERN_NEUTRAL;
   
   // 1. نمط الهرم المقلوب
   bool pyramidInverted = (high[idx-1] > high[idx-2]) && (high[idx-1] > high[idx]) &&
                         (low[idx-1] > low[idx-2]) && (low[idx-1] > low[idx]);
   
   if(pyramidInverted)
   {
      foundRarePattern = true;
      patternName = "Inverted Pyramid";
      strength = 1.5;
      direction = PATTERN_BEARISH;
      reliability = 0.60;
   }
   
   // 2. نمط الهرم العادي
   bool pyramidNormal = (low[idx-1] < low[idx-2]) && (low[idx-1] < low[idx]) &&
                        (high[idx-1] < high[idx-2]) && (high[idx-1] < high[idx]);
   
   if(!foundRarePattern && pyramidNormal)
   {
      foundRarePattern = true;
      patternName = "Normal Pyramid";
      strength = 1.5;
      direction = PATTERN_BULLISH;
      reliability = 0.60;
   }
   
   // 3. نمط التناظر المثالي
   double mid = (high[idx-2] + low[idx-2] + high[idx] + low[idx]) / 4.0;
   double midRange = (high[idx-1] + low[idx-1]) / 2.0;
   bool perfectSymmetry = MathAbs(midRange - mid) < mid * 0.01; // 1% انحراف
   
   if(!foundRarePattern && perfectSymmetry)
   {
      bool symmetric = HasSymmetricalPattern(high, idx-2, 3) && HasSymmetricalPattern(low, idx-2, 3);
      if(symmetric)
      {
         foundRarePattern = true;
         patternName = "Perfect Symmetry";
         strength = 2.0;
         direction = PATTERN_NEUTRAL;
         reliability = 0.55;
      }
   }
   
   // 4. نمط الموجة المعقدة
   bool complexWave = false;
   double wave1 = high[idx-2] - low[idx-2];
   double wave2 = high[idx-1] - low[idx-1];
   double wave3 = high[idx] - low[idx];
   
   // موجة معقدة: الوسطى أكبر بكثير من الجانبيتين
   if((wave2 > wave1 * 2.0) && (wave2 > wave3 * 2.0))
   {
      complexWave = true;
   }
   
   if(!foundRarePattern && complexWave)
   {
      foundRarePattern = true;
      patternName = "Complex Wave";
      strength = wave2 / ((wave1 + wave3) / 2.0);
      direction = (close[idx] > close[idx-2]) ? PATTERN_BULLISH : PATTERN_BEARISH;
      reliability = 0.45; // غير مؤكد
   }
   
   if(!foundRarePattern) return false;
   
   // حساب ندرة التشكيل
   double formationRarity = CalculateFormationRarity(open, high, low, close, idx-2);
   
   result.patternName = patternName;
   result.strength = strength * formationRarity;
   result.reliability = reliability;
   result.direction = direction;
   result.type = PATTERN_TRIPLE;
   result.confidence = (result.strength + result.reliability) / 2.0;
   
   return true;
}

//+------------------------------------------------------------------+
//| التحقق من تشكيل بوذا                                            |
//+------------------------------------------------------------------+
bool CUniquePatterns::IsBuddhaFormation(const double &high[], const double &low[], int startIdx, bool isTop)
{
   if(isTop)
   {
      // تشكيل بوذا للقمة: الوسطى أعلى من الجانبيتين
      return (high[startIdx+1] > high[startIdx]) && (high[startIdx+1] > high[startIdx+2]);
   }
   else
   {
      // تشكيل بوذا للقاع: الوسطى أقل من الجانبيتين
      return (low[startIdx+1] < low[startIdx]) && (low[startIdx+1] < low[startIdx+2]);
   }
}

//+------------------------------------------------------------------+
//| التحقق من تعقد الأنهار الثلاثة                                  |
//+------------------------------------------------------------------+
bool CUniquePatterns::IsThreeRiverComplex(const double &open[], const double &high[], const double &low[], 
                                         const double &close[], int startIdx)
{
   // تعقد الأنهار: اختلاف في المدى والشكل
   double range1 = high[startIdx] - low[startIdx];
   double range2 = high[startIdx+1] - low[startIdx+1];
   double range3 = high[startIdx+2] - low[startIdx+2];
   
   // كل نهر يجب أن يكون مختلف عن الآخرين
   double maxRange = MathMax(range1, MathMax(range2, range3));
   double minRange = MathMin(range1, MathMin(range2, range3));
   
   if(maxRange == 0) return false;
   
   double rangeVariation = (maxRange - minRange) / maxRange;
   return rangeVariation >= m_riverComplexity;
}

//+------------------------------------------------------------------+
//| التحقق من التشكيل النادر                                        |
//+------------------------------------------------------------------+
bool CUniquePatterns::IsRareFormation(const double &open[], const double &high[], const double &low[], 
                                     const double &close[], int startIdx)
{
   // حساب عوامل الندرة
   double rarityScore = 0;
   
   // 1. تنوع الأحجام
   double body1 = MathAbs(close[startIdx] - open[startIdx]);
   double body2 = MathAbs(close[startIdx+1] - open[startIdx+1]);
   double body3 = MathAbs(close[startIdx+2] - open[startIdx+2]);
   
   double maxBody = MathMax(body1, MathMax(body2, body3));
   double minBody = MathMin(body1, MathMin(body2, body3));
   
   if(maxBody > 0 && (maxBody - minBody) / maxBody > 0.5)
      rarityScore += 0.3;
   
   // 2. أنماط الألوان غير العادية
   bool color1 = close[startIdx] > open[startIdx];
   bool color2 = close[startIdx+1] > open[startIdx+1];
   bool color3 = close[startIdx+2] > open[startIdx+2];
   
   // نمط لوني نادر: أخضر-أحمر-أخضر أو أحمر-أخضر-أحمر
   if((color1 && !color2 && color3) || (!color1 && color2 && !color3))
      rarityScore += 0.4;
   
   // 3. تشكيلات هندسية معقدة
   double avgHigh = (high[startIdx] + high[startIdx+1] + high[startIdx+2]) / 3.0;
   double avgLow = (low[startIdx] + low[startIdx+1] + low[startIdx+2]) / 3.0;
   
   bool geometricComplexity = false;
   for(int i = 0; i < 3; i++)
   {
      if(MathAbs(high[startIdx+i] - avgHigh) > (avgHigh * 0.02) ||
         MathAbs(low[startIdx+i] - avgLow) > (avgLow * 0.02))
      {
         geometricComplexity = true;
         break;
      }
   }
   
   if(geometricComplexity)
      rarityScore += 0.3;
   
   return rarityScore >= m_formationRarity;
}

//+------------------------------------------------------------------+
//| حساب قوة نمط بوذا                                               |
//+------------------------------------------------------------------+
double CUniquePatterns::CalculateBuddhaStrength(const double &high[], const double &low[], int startIdx, bool isTop)
{
   if(isTop)
   {
      double head = high[startIdx+1];
      double leftShoulder = high[startIdx];
      double rightShoulder = high[startIdx+2];
      double avgShoulder = (leftShoulder + rightShoulder) / 2.0;
      
      if(avgShoulder == 0) return 0;
      
      double prominence = (head - avgShoulder) / avgShoulder;
      return prominence * 5.0; // تضخيم النتيجة
   }
   else
   {
      double head = low[startIdx+1];
      double leftShoulder = low[startIdx];
      double rightShoulder = low[startIdx+2];
      double avgShoulder = (leftShoulder + rightShoulder) / 2.0;
      
      if(avgShoulder == 0) return 0;
      
      double depth = (avgShoulder - head) / avgShoulder;
      return depth * 5.0; // تضخيم النتيجة
   }
}

//+------------------------------------------------------------------+
//| حساب ندرة التشكيل                                               |
//+------------------------------------------------------------------+
double CUniquePatterns::CalculateFormationRarity(const double &open[], const double &high[], const double &low[], 
                                                const double &close[], int startIdx)
{
   double totalVariation = 0;
   double totalAvg = 0;
   
   // حساب التنوع في المدى والجسم والظلال
   for(int i = 0; i < 3; i++)
   {
      double range = high[startIdx + i] - low[startIdx + i];
      double body = MathAbs(close[startIdx + i] - open[startIdx + i]);
      
      totalVariation += range + body;
      totalAvg += (high[startIdx + i] + low[startIdx + i]) / 2.0;
   }
   
   if(totalAvg == 0) return 1.0;
   
   return MathMin(totalVariation / totalAvg, 3.0); // حد أقصى 3
}

//+------------------------------------------------------------------+
//| التحقق من النمط المتناظر                                        |
//+------------------------------------------------------------------+
bool CUniquePatterns::HasSymmetricalPattern(const double &values[], int startIdx, int count)
{
   if(count < 3) return false;
   
   // التحقق من التناظر: القيم الجانبية متشابهة
   for(int i = 0; i < count/2; i++)
   {
      double left = values[startIdx + i];
      double right = values[startIdx + count - 1 - i];
      
      if(left == 0) return false;
      
      double diff = MathAbs(right - left) / left;
      if(diff > 0.05) // 5% تسامح
         return false;
   }
   
   return true;
}
