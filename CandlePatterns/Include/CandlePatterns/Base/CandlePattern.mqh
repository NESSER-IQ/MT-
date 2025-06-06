//+------------------------------------------------------------------+
//|                                               CandlePattern.mqh   |
//|                        حقوق النشر 2025, مكتبة أنماط الشموع اليابانية |
//|                                       https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "حقوق النشر 2025, مكتبة أنماط الشموع اليابانية"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

#include <Arrays\ArrayObj.mqh>
#include "CandleUtils.mqh"  // إضافة تضمين لـ CandleUtils

//+------------------------------------------------------------------+
//| تصنيفات أنماط الشموع اليابانية                                     |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_TYPE
{
   PATTERN_SINGLE,       // أنماط الشمعة الواحدة
   PATTERN_DOUBLE,       // أنماط الشمعتين
   PATTERN_TRIPLE,       // أنماط الثلاث شموع
   PATTERN_MULTIPLE,     // أنماط متعددة الشموع
   PATTERN_CHART         // أنماط المخططات
};

//+------------------------------------------------------------------+
//| تصنيف اتجاه النمط                                                 |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_DIRECTION
{
   PATTERN_BULLISH,      // صعودي
   PATTERN_BEARISH,      // هبوطي
   PATTERN_NEUTRAL       // محايد
};

//+------------------------------------------------------------------+
//| قوة إشارة النمط                                                   |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_STRENGTH
{
   PATTERN_STRENGTH_WEAK = 1,       // ضعيف
   PATTERN_STRENGTH_MEDIUM = 2,     // متوسط
   PATTERN_STRENGTH_STRONG = 3      // قوي
};

//+------------------------------------------------------------------+
//| نوع إشارة التداول                                                 |
//+------------------------------------------------------------------+
enum ENUM_SIGNAL_TYPE
{
   SIGNAL_NONE,          // لا إشارة
   SIGNAL_BUY,           // إشارة شراء
   SIGNAL_SELL,          // إشارة بيع
   SIGNAL_EXIT_BUY,      // إشارة خروج من الشراء
   SIGNAL_EXIT_SELL      // إشارة خروج من البيع
};

//+------------------------------------------------------------------+
//| هيكل إشارة النمط                                                  |
//+------------------------------------------------------------------+
struct SPatternSignal
{
   ENUM_SIGNAL_TYPE   type;           // نوع الإشارة
   double             strength;        // قوة الإشارة (0.0-1.0)
   double             entryPrice;      // سعر الدخول المقترح
   double             stopLoss;        // وقف الخسارة المقترح
   double             takeProfit;      // الهدف المقترح
   datetime           time;            // وقت الإشارة
   string             patternName;     // اسم النمط
   int                barIndex;        // رقم الشمعة
   
   SPatternSignal()
   {
      type = SIGNAL_NONE;
      strength = 0.0;
      entryPrice = 0.0;
      stopLoss = 0.0;
      takeProfit = 0.0;
      time = 0;
      patternName = "";
      barIndex = -1;
   }
};

//+------------------------------------------------------------------+
//| خيارات الرسم للنمط                                                |
//+------------------------------------------------------------------+
struct SDrawOptions
{
   bool        enabled;         // تمكين الرسم
   color       arrowColor;      // لون السهم
   int         arrowSize;       // حجم السهم
   bool        showLabel;       // عرض التسمية النصية
   color       labelColor;      // لون النص
   int         labelFontSize;   // حجم خط النص
   
   SDrawOptions()
   {
      enabled = true;
      arrowColor = clrDodgerBlue;
      arrowSize = 2;
      showLabel = true;
      labelColor = clrWhite;
      labelFontSize = 8;
   }
};

//+------------------------------------------------------------------+
//| خيارات التنبيه للنمط                                              |
//+------------------------------------------------------------------+
struct SAlertOptions
{
   bool        enabled;         // تمكين التنبيهات
   bool        soundAlert;      // تنبيه صوتي
   string      soundFile;       // ملف الصوت
   bool        emailAlert;      // تنبيه عبر البريد الإلكتروني
   bool        pushAlert;       // تنبيه عبر الهاتف
   
   SAlertOptions()
   {
      enabled = false;
      soundAlert = true;
      soundFile = "alert.wav";
      emailAlert = false;
      pushAlert = false;
   }
};

//+------------------------------------------------------------------+
//| الفئة الأساسية لجميع أنماط الشموع اليابانية                         |
//+------------------------------------------------------------------+
class CCandlePattern
{
protected:
   string               m_name;                // اسم النمط
   ENUM_PATTERN_TYPE    m_type;                // نوع النمط
   ENUM_PATTERN_DIRECTION m_direction;         // اتجاه النمط
   ENUM_PATTERN_STRENGTH m_defaultStrength;    // قوة النمط الافتراضية
   int                  m_requiredBars;        // عدد الشموع المطلوبة للنمط
   double               m_reliability;         // معدل موثوقية النمط (0.0-1.0)
   string               m_description;         // وصف النمط
   color                m_defaultColor;        // اللون الافتراضي للنمط
   SDrawOptions         m_drawOptions;         // خيارات الرسم
   SAlertOptions        m_alertOptions;        // خيارات التنبيه
   string               m_customSettings;      // إعدادات مخصصة للنمط (للتصدير/الاستيراد)

public:
   // البناء والهدم
                        CCandlePattern();
                        CCandlePattern(const string name, ENUM_PATTERN_TYPE type, ENUM_PATTERN_DIRECTION direction, 
                                     ENUM_PATTERN_STRENGTH strength, int bars, double reliability, 
                                     const string description, color clr);
                        ~CCandlePattern();
   
   // أساليب الوصول
   string               Name() const { return m_name; }
   ENUM_PATTERN_TYPE    Type() const { return m_type; }
   ENUM_PATTERN_DIRECTION Direction() const { return m_direction; }
   ENUM_PATTERN_STRENGTH DefaultStrength() const { return m_defaultStrength; }
   int                  RequiredBars() const { return m_requiredBars; }
   double               Reliability() const { return m_reliability; }
   string               Description() const { return m_description; }
   color                DefaultColor() const { return m_defaultColor; }
   
   // خيارات التخصيص
   void                 SetDrawOptions(const SDrawOptions &options) { m_drawOptions = options; }
   SDrawOptions         GetDrawOptions() const { return m_drawOptions; }
   void                 SetAlertOptions(const SAlertOptions &options) { m_alertOptions = options; }
   SAlertOptions        GetAlertOptions() const { return m_alertOptions; }
   
   // الدوال الافتراضية للكشف عن النمط
   virtual bool         Detect(const int idx, const double &open[], const double &high[], 
                             const double &low[], const double &close[], const long &volume[]);
   virtual double       PatternStrength(const int idx, const double &open[], const double &high[], 
                                      const double &low[], const double &close[], const long &volume[]);
   virtual void         Draw(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe, 
                          const double &open[], const double &high[], const double &low[], const double &close[]);
   
   // دوال الإشارات والتنبيهات
   virtual SPatternSignal GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                    const double &open[], const double &high[], 
                                    const double &low[], const double &close[], const long &volume[]);
   virtual void         SendAlert(const SPatternSignal &signal, const string symbol, ENUM_TIMEFRAMES timeframe);
   
   // دوال التصدير/الاستيراد
   virtual string       ExportSettings();
   virtual bool         ImportSettings(const string settings);
   
   // إعدادات التخصيص
   virtual void         SaveToFile(const string fileName);
   virtual bool         LoadFromFile(const string fileName);
};

//+------------------------------------------------------------------+
//| المنشئ الافتراضي                                                  |
//+------------------------------------------------------------------+
CCandlePattern::CCandlePattern()
{
   m_name = "نمط الشمعة الأساسي";
   m_type = PATTERN_SINGLE;
   m_direction = PATTERN_NEUTRAL;
   m_defaultStrength = PATTERN_STRENGTH_MEDIUM;
   m_requiredBars = 1;
   m_reliability = 0.5;
   m_description = "نمط شمعة أساسي بدون تخصيص";
   m_defaultColor = clrGray;
   m_customSettings = "";
   
   // تهيئة خيارات الرسم والتنبيه
   m_drawOptions = SDrawOptions();
   m_alertOptions = SAlertOptions();
}

//+------------------------------------------------------------------+
//| المنشئ المخصص                                                    |
//+------------------------------------------------------------------+
CCandlePattern::CCandlePattern(const string name, ENUM_PATTERN_TYPE type, ENUM_PATTERN_DIRECTION direction, 
                              ENUM_PATTERN_STRENGTH strength, int bars, double reliability, 
                              const string description, color clr)
{
   m_name = name;
   m_type = type;
   m_direction = direction;
   m_defaultStrength = strength;
   m_requiredBars = (bars > 0) ? bars : 1;
   m_reliability = MathMax(0.0, MathMin(1.0, reliability)); // الحفاظ على القيمة بين 0.0 و 1.0
   m_description = description;
   m_defaultColor = clr;
   m_customSettings = "";
   
   // تهيئة خيارات الرسم والتنبيه
   m_drawOptions = SDrawOptions();
   m_drawOptions.arrowColor = clr;
   m_alertOptions = SAlertOptions();
}

//+------------------------------------------------------------------+
//| الهادم                                                           |
//+------------------------------------------------------------------+
CCandlePattern::~CCandlePattern()
{
}

//+------------------------------------------------------------------+
//| الدالة الافتراضية للكشف عن النمط                                  |
//+------------------------------------------------------------------+
bool CCandlePattern::Detect(const int idx, const double &open[], const double &high[], 
                           const double &low[], const double &close[], const long &volume[])
{
   // الفئة الأساسية لا تكشف عن أي نمط محدد
   // يجب أن تتم إعادة تعريف هذه الدالة في الفئات المشتقة
   return false;
}

//+------------------------------------------------------------------+
//| حساب قوة النمط                                                   |
//+------------------------------------------------------------------+
double CCandlePattern::PatternStrength(const int idx, const double &open[], const double &high[], 
                                     const double &low[], const double &close[], const long &volume[])
{
   // قيمة افتراضية للقوة
   // ينبغي أن تقوم الفئات المشتقة بإعادة تعريف هذه الدالة للحساب الدقيق
   return (double)m_defaultStrength;
}

//+------------------------------------------------------------------+
//| رسم النمط على المخطط                                             |
//+------------------------------------------------------------------+
void CCandlePattern::Draw(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                         const double &open[], const double &high[], const double &low[], const double &close[])
{
   // التحقق من تمكين الرسم
   if(!m_drawOptions.enabled)
      return;
      
   // تنفيذ افتراضي للرسم، ينبغي أن تقوم الفئات المشتقة بإعادة تعريفه
   string objName = m_name + " " + IntegerToString(idx);
   string labelName = m_name + " Label " + IntegerToString(idx);
   
   // تحقق ما إذا كان الكائن موجوداً بالفعل
   if(ObjectFind(0, objName) >= 0)
      ObjectDelete(0, objName);
   if(ObjectFind(0, labelName) >= 0)
      ObjectDelete(0, labelName);
   
   // الحصول على وقت الشمعة
   datetime time = iTime(symbol, timeframe, idx);
   
   // إنشاء وتكوين السهم
   if(m_direction == PATTERN_BULLISH)
   {
      ObjectCreate(0, objName, OBJ_ARROW_UP, 0, time, low[idx] - (high[idx] - low[idx]) * 0.1);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, m_drawOptions.arrowColor);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, m_drawOptions.arrowSize);
      
      // إضافة تسمية إذا كانت مُمكّنة
      if(m_drawOptions.showLabel)
      {
         ObjectCreate(0, labelName, OBJ_TEXT, 0, time, low[idx] - (high[idx] - low[idx]) * 0.2);
         ObjectSetString(0, labelName, OBJPROP_TEXT, m_name);
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, m_drawOptions.labelColor);
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, m_drawOptions.labelFontSize);
         ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_TOP);
      }
   }
   else if(m_direction == PATTERN_BEARISH)
   {
      ObjectCreate(0, objName, OBJ_ARROW_DOWN, 0, time, high[idx] + (high[idx] - low[idx]) * 0.1);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, m_drawOptions.arrowColor);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, m_drawOptions.arrowSize);
      
      // إضافة تسمية إذا كانت مُمكّنة
      if(m_drawOptions.showLabel)
      {
         ObjectCreate(0, labelName, OBJ_TEXT, 0, time, high[idx] + (high[idx] - low[idx]) * 0.2);
         ObjectSetString(0, labelName, OBJPROP_TEXT, m_name);
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, m_drawOptions.labelColor);
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, m_drawOptions.labelFontSize);
         ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
      }
   }
   else // PATTERN_NEUTRAL
   {
      ObjectCreate(0, objName, OBJ_ARROW, 0, time, (high[idx] + low[idx]) / 2.0);
      ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, 3); // استخدام رمز سهم عادي بدلاً من OBJ_ARROW_RIGHT
      ObjectSetInteger(0, objName, OBJPROP_COLOR, m_drawOptions.arrowColor);
      ObjectSetInteger(0, objName, OBJPROP_WIDTH, m_drawOptions.arrowSize);
      
      // إضافة تسمية إذا كانت مُمكّنة
      if(m_drawOptions.showLabel)
      {
         ObjectCreate(0, labelName, OBJ_TEXT, 0, time, (high[idx] + low[idx]) / 2.0 + (high[idx] - low[idx]) * 0.1);
         ObjectSetString(0, labelName, OBJPROP_TEXT, m_name);
         ObjectSetInteger(0, labelName, OBJPROP_COLOR, m_drawOptions.labelColor);
         ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, m_drawOptions.labelFontSize);
         ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT);
      }
   }
}

//+------------------------------------------------------------------+
//| توليد إشارة تداول بناءً على النمط                                 |
//+------------------------------------------------------------------+
SPatternSignal CCandlePattern::GenerateSignal(const int idx, const string symbol, ENUM_TIMEFRAMES timeframe,
                                          const double &open[], const double &high[], 
                                          const double &low[], const double &close[], const long &volume[])
{
   SPatternSignal signal;
   
   // التحقق من وجود النمط
   if(!Detect(idx, open, high, low, close, volume))
      return signal;
   
   // تعيين خصائص الإشارة
   signal.barIndex = idx;
   signal.patternName = m_name;
   signal.time = iTime(symbol, timeframe, idx);
   signal.strength = PatternStrength(idx, open, high, low, close, volume) / 3.0; // التحويل من قوة 1-3 إلى 0.0-1.0
   
   // تحديد نوع الإشارة بناءً على اتجاه النمط
   switch(m_direction)
   {
      case PATTERN_BULLISH:
         signal.type = SIGNAL_BUY;
         signal.entryPrice = high[idx] + (high[idx] - low[idx]) * 0.05; // سعر دخول فوق الشمعة
         signal.stopLoss = low[idx] - (high[idx] - low[idx]) * 0.1; // وقف خسارة تحت الشمعة
         signal.takeProfit = signal.entryPrice + (signal.entryPrice - signal.stopLoss) * 2.0; // هدف بنسبة 1:2 للمخاطرة/العائد
         break;
         
      case PATTERN_BEARISH:
         signal.type = SIGNAL_SELL;
         signal.entryPrice = low[idx] - (high[idx] - low[idx]) * 0.05; // سعر دخول تحت الشمعة
         signal.stopLoss = high[idx] + (high[idx] - low[idx]) * 0.1; // وقف خسارة فوق الشمعة
         signal.takeProfit = signal.entryPrice - (signal.stopLoss - signal.entryPrice) * 2.0; // هدف بنسبة 1:2 للمخاطرة/العائد
         break;
         
      case PATTERN_NEUTRAL:
         // للأنماط المحايدة، يمكن استخدام إشارات الخروج أو عدم توليد إشارة
         signal.type = SIGNAL_NONE;
         break;
   }
   
   return signal;
}

//+------------------------------------------------------------------+
//| إرسال تنبيه عند اكتشاف النمط                                      |
//+------------------------------------------------------------------+
void CCandlePattern::SendAlert(const SPatternSignal &signal, const string symbol, ENUM_TIMEFRAMES timeframe)
{
   // التحقق من تمكين التنبيهات
   if(!m_alertOptions.enabled || signal.type == SIGNAL_NONE)
      return;
   
   // إعداد نص التنبيه
   string alertText = StringFormat("%s: نمط %s اكتُشف في %s على إطار %s", 
                                 TimeToString(TimeCurrent()),
                                 signal.patternName,
                                 symbol,
                                 EnumToString(timeframe));
                                 
   // إضافة معلومات الإشارة
   if(signal.type == SIGNAL_BUY)
      alertText += StringFormat("\nإشارة: شراء\nسعر الدخول: %.5f\nوقف الخسارة: %.5f\nالهدف: %.5f", 
                                signal.entryPrice, signal.stopLoss, signal.takeProfit);
   else if(signal.type == SIGNAL_SELL)
      alertText += StringFormat("\nإشارة: بيع\nسعر الدخول: %.5f\nوقف الخسارة: %.5f\nالهدف: %.5f", 
                                signal.entryPrice, signal.stopLoss, signal.takeProfit);
                                
   // إرسال التنبيهات حسب الإعدادات
   if(m_alertOptions.soundAlert)
      PlaySound(m_alertOptions.soundFile);
      
   if(m_alertOptions.emailAlert)
      SendMail(StringFormat("إشارة نمط %s في %s", signal.patternName, symbol), alertText);
      
   if(m_alertOptions.pushAlert)
      SendNotification(alertText);
      
   // عرض تنبيه على الشاشة
   Alert(alertText);
}

//+------------------------------------------------------------------+
//| تصدير إعدادات النمط                                              |
//+------------------------------------------------------------------+
string CCandlePattern::ExportSettings()
{
   // بناء سلسلة JSON بالإعدادات
   string settings = StringFormat(
      "{\"name\":\"%s\",\"type\":%d,\"direction\":%d,\"strength\":%d,\"requiredBars\":%d,"
      "\"reliability\":%.2f,\"description\":\"%s\",\"color\":%d,"
      "\"drawOptions\":{\"enabled\":%s,\"arrowColor\":%d,\"arrowSize\":%d,\"showLabel\":%s,"
      "\"labelColor\":%d,\"labelFontSize\":%d},"
      "\"alertOptions\":{\"enabled\":%s,\"soundAlert\":%s,\"soundFile\":\"%s\","
      "\"emailAlert\":%s,\"pushAlert\":%s}%s}",
      m_name, m_type, m_direction, m_defaultStrength, m_requiredBars,
      m_reliability, m_description, m_defaultColor,
      m_drawOptions.enabled ? "true" : "false", m_drawOptions.arrowColor, m_drawOptions.arrowSize,
      m_drawOptions.showLabel ? "true" : "false", m_drawOptions.labelColor, m_drawOptions.labelFontSize,
      m_alertOptions.enabled ? "true" : "false", m_alertOptions.soundAlert ? "true" : "false",
      m_alertOptions.soundFile, m_alertOptions.emailAlert ? "true" : "false",
      m_alertOptions.pushAlert ? "true" : "false", m_customSettings != "" ? ",\"custom\":" + m_customSettings : ""
   );
   
   return settings;
}

//+------------------------------------------------------------------+
//| استيراد إعدادات النمط                                            |
//+------------------------------------------------------------------+
bool CCandlePattern::ImportSettings(const string settings)
{
   // يجب تنفيذ تحليل JSON هنا. نظرًا لتعقيد ذلك، هذه خطوط عريضة للمنهجية:
   
   // 1. التحقق من أن السلسلة تمثل JSON صالح
   if(StringLen(settings) < 5 || StringSubstr(settings, 0, 1) != "{" || StringSubstr(settings, StringLen(settings) - 1, 1) != "}")
      return false;
      
   // 2. (ملاحظة: في التنفيذ الفعلي، ستحتاج إلى مكتبة تحليل JSON أو كتابة محلل JSON)
   // هذا مجرد رمز وهمي لتوضيح المفهوم
   
   /* يجب تنفيذ هذا الجزء بمحلل JSON حقيقي
   JSONParser parser;
   JSONObject json = parser.parse(settings);
   
   m_name = json.getString("name");
   m_type = (ENUM_PATTERN_TYPE)json.getInt("type");
   m_direction = (ENUM_PATTERN_DIRECTION)json.getInt("direction");
   m_defaultStrength = (ENUM_PATTERN_STRENGTH)json.getInt("strength");
   m_requiredBars = json.getInt("requiredBars");
   m_reliability = json.getDouble("reliability");
   m_description = json.getString("description");
   m_defaultColor = json.getInt("color");
   
   JSONObject drawOptions = json.getObject("drawOptions");
   m_drawOptions.enabled = drawOptions.getBool("enabled");
   m_drawOptions.arrowColor = drawOptions.getInt("arrowColor");
   m_drawOptions.arrowSize = drawOptions.getInt("arrowSize");
   m_drawOptions.showLabel = drawOptions.getBool("showLabel");
   m_drawOptions.labelColor = drawOptions.getInt("labelColor");
   m_drawOptions.labelFontSize = drawOptions.getInt("labelFontSize");
   
   JSONObject alertOptions = json.getObject("alertOptions");
   m_alertOptions.enabled = alertOptions.getBool("enabled");
   m_alertOptions.soundAlert = alertOptions.getBool("soundAlert");
   m_alertOptions.soundFile = alertOptions.getString("soundFile");
   m_alertOptions.emailAlert = alertOptions.getBool("emailAlert");
   m_alertOptions.pushAlert = alertOptions.getBool("pushAlert");
   
   if(json.hasKey("custom"))
      m_customSettings = json.getString("custom");
   */
   
   // في هذه المرحلة، نحن فقط نفترض النجاح للتوضيح
   return true;
}

//+------------------------------------------------------------------+
//| حفظ إعدادات النمط إلى ملف                                         |
//+------------------------------------------------------------------+
void CCandlePattern::SaveToFile(const string fileName)
{
   // إنشاء اسم ملف كامل
   string fullFileName = fileName;
   if(StringLen(fullFileName) < 5 || StringSubstr(fullFileName, StringLen(fullFileName) - 5, 5) != ".json")
      fullFileName += ".json";
   
   // الحصول على إعدادات كسلسلة JSON
   string settings = ExportSettings();
   
   // فتح ملف للكتابة
   int fileHandle = FileOpen(fullFileName, FILE_WRITE|FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
   {
      // كتابة الإعدادات إلى الملف
      FileWriteString(fileHandle, settings);
      FileClose(fileHandle);
      Print("تم حفظ إعدادات النمط إلى: ", fullFileName);
   }
   else
   {
      Print("خطأ في حفظ إعدادات النمط: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| تحميل إعدادات النمط من ملف                                        |
//+------------------------------------------------------------------+
bool CCandlePattern::LoadFromFile(const string fileName)
{
   // إنشاء اسم ملف كامل
   string fullFileName = fileName;
   if(StringLen(fullFileName) < 5 || StringSubstr(fullFileName, StringLen(fullFileName) - 5, 5) != ".json")
      fullFileName += ".json";
   
   // فحص وجود الملف
   if(!FileIsExist(fullFileName))
   {
      Print("ملف الإعدادات غير موجود: ", fullFileName);
      return false;
   }
   
   // فتح الملف للقراءة
   int fileHandle = FileOpen(fullFileName, FILE_READ|FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
   {
      // قراءة المحتوى
      ulong fileSize = FileSize(fileHandle);
      string settings = FileReadString(fileHandle, (int)fileSize);
      FileClose(fileHandle);
      
      // استيراد الإعدادات
      bool result = ImportSettings(settings);
      if(result)
         Print("تم تحميل إعدادات النمط من: ", fullFileName);
      else
         Print("خطأ في تحليل ملف الإعدادات: ", fullFileName);
         
      return result;
   }
   else
   {
      Print("خطأ في فتح ملف الإعدادات: ", GetLastError());
      return false;
   }
}