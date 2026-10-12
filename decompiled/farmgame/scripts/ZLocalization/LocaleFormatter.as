package ZLocalization
{
   public class LocaleFormatter
   {
      
      public static const CURRENT_LOCALE:String = "current_locale";
      
      public static const CURRENCY_DELIM:String = "{n}";
      
      protected static const PACKAGE_NAME:String = "ZLocDateTimeFormats";
      
      protected static const CURRENCY:String = "currency";
      
      protected static const DATE:String = "date";
      
      protected static const NUMBER:String = "number";
      
      protected static const DURIATION:String = "duriation";
      
      protected static const TIME:String = "time";
      
      protected static const AM:String = "am";
      
      protected static const PM:String = "pm";
      
      private static var currencyFormats:Object = {
         "en_US":"${n}",
         "fr":"{n} €",
         "it":"€ {n}",
         "de":"{n} €",
         "es":"{n} €",
         "pt_BR":"R$ {n}",
         "zh_TW":"NTD {n}",
         "zh_CN":"{n}元",
         "id":"Rp {n}",
         "tr":"{n} TL",
         "ko":"₩{n}",
         "ms":"RM {n}",
         "ja":"￥{n}",
         "th":"฿ {n}"
      };
      
      private static var dateFormats:Object = {
         "{d}":"j",
         "{dd}":"d",
         "{m}":"n",
         "{mm}":"m",
         "{yyyy}":"Y"
      };
      
      private static var timeFormats:Object = {
         "{h}":"g",
         "{hh}":"h",
         "{mm}":"i",
         "{ss}":"s",
         "{H}":"G",
         "{HH}":"H",
         "{a}":"a",
         "{aa}":"aa"
      };
      
      public function LocaleFormatter()
      {
         super();
      }
      
      private static function getFormat(param1:String) : String
      {
         var _loc2_:LocalizedString = ZLoc.instance.getString(LocaleFormatter.PACKAGE_NAME,param1);
         return _loc2_.getVariation(LocalizedString.ORIGINAL);
      }
      
      public static function formatDate(param1:Date) : String
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc2_:String = LocaleFormatter.getFormat(LocaleFormatter.DATE);
         var _loc3_:Array = _loc2_.match(/{([^}]+)}/g);
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc5_];
            _loc4_ = LocaleFormatter.getFormattedDateTime(LocaleFormatter.dateFormats[_loc6_],param1);
            _loc7_ = _loc2_.split(_loc6_);
            _loc2_ = _loc7_.join(_loc4_);
            _loc5_++;
         }
         return _loc2_;
      }
      
      public static function formatTime(param1:Date, param2:Boolean = true) : String
      {
         var _loc5_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc3_:String = LocaleFormatter.getFormat(LocaleFormatter.TIME);
         if(!param2)
         {
            _loc7_ = _loc3_.replace(":{ss}","");
            if(_loc7_ == _loc3_)
            {
               _loc3_ = _loc3_.replace(/({ss}[^{]*)/,"");
            }
            else
            {
               _loc3_ = _loc7_;
            }
         }
         var _loc4_:Array = _loc3_.match(/{([^}]+)}/g);
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_.length)
         {
            _loc8_ = _loc4_[_loc6_];
            _loc5_ = LocaleFormatter.getFormattedDateTime(LocaleFormatter.timeFormats[_loc8_],param1);
            _loc9_ = _loc3_.split(_loc8_);
            if(_loc5_ == "pm")
            {
               _loc5_ = LocaleFormatter.getFormat(LocaleFormatter.PM);
            }
            else if(_loc5_ == "am")
            {
               _loc5_ = LocaleFormatter.getFormat(LocaleFormatter.AM);
            }
            _loc3_ = _loc9_.join(_loc5_);
            _loc6_++;
         }
         return _loc3_;
      }
      
      public static function formatDuration(param1:int, param2:Boolean = true, param3:Boolean = true) : String
      {
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc4_:String = ZLoc.instance.langCode;
         var _loc5_:int = param1 % 60;
         var _loc6_:int = param1 / 60 % 60;
         var _loc7_:int = Math.floor(param1 / 3600);
         var _loc10_:String = LocaleFormatter.getFormat(LocaleFormatter.DURIATION);
         if(!param3)
         {
            if("{h}:{mm}:{ss}" == _loc10_)
            {
               _loc10_ = "{h}:{mm}";
            }
            else
            {
               _loc10_ = _loc10_.replace(/({ss}[^{]*)/,"");
            }
         }
         else
         {
            _loc8_ = _loc5_ < 10 ? "0" + _loc5_ : _loc5_.toString();
            _loc9_ = _loc10_.split("{ss}");
            _loc10_ = _loc9_.join(_loc8_);
         }
         if(!param2 && _loc7_ == 0)
         {
            _loc10_ = _loc10_.replace(/([^{]*{h}[^{]*)/,"");
            _loc8_ = _loc6_.toString();
            _loc9_ = _loc10_.split("{mm}");
            _loc10_ = _loc9_.join(_loc8_);
         }
         else
         {
            _loc8_ = _loc6_ < 10 ? "0" + _loc6_ : _loc6_.toString();
            _loc9_ = _loc10_.split("{mm}");
            _loc10_ = _loc9_.join(_loc8_);
            _loc8_ = _loc7_.toString();
            _loc9_ = _loc10_.split("{h}");
            _loc10_ = _loc9_.join(_loc8_);
         }
         return _loc10_;
      }
      
      public static function formatNumber(param1:Number) : String
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc12_:Array = null;
         var _loc2_:String = LocaleFormatter.getFormat(LocaleFormatter.NUMBER);
         var _loc3_:Array = _loc2_.split("|");
         var _loc4_:String = _loc3_[0];
         var _loc5_:String = _loc3_[1];
         var _loc6_:Array = param1.toString().split(".");
         if(_loc6_.length > 1)
         {
            _loc7_ = _loc6_[0];
            _loc8_ = _loc6_[1];
         }
         else
         {
            _loc5_ = "";
            _loc7_ = _loc6_[0];
            _loc8_ = "";
         }
         var _loc9_:int = _loc7_.length;
         var _loc10_:int = _loc9_ % 3;
         var _loc11_:String = _loc7_.substr(0,_loc10_);
         if(_loc11_.length == 0)
         {
            _loc12_ = new Array();
         }
         else
         {
            _loc12_ = new Array(_loc11_);
         }
         var _loc13_:int = _loc10_;
         while(_loc13_ < _loc9_)
         {
            _loc12_.push(_loc7_.substr(_loc13_,3));
            _loc13_ += 3;
         }
         return _loc12_.join(_loc4_) + _loc5_ + _loc8_;
      }
      
      public static function formatCurrency(param1:Number, param2:String) : String
      {
         var _loc3_:String = null;
         if(param2 == LocaleFormatter.CURRENT_LOCALE)
         {
            _loc3_ = LocaleFormatter.getFormat(LocaleFormatter.CURRENCY);
         }
         else
         {
            if(!LocaleFormatter.currencyFormats.hasOwnProperty(param2))
            {
               throw new Error("Locale: " + param2 + ", is unsupported in LocaleFormatter.currencyFormats");
            }
            _loc3_ = LocaleFormatter.currencyFormats[param2];
         }
         var _loc4_:String = LocaleFormatter.formatNumber(param1);
         var _loc5_:Array = _loc3_.split(LocaleFormatter.CURRENCY_DELIM);
         return _loc5_.join(_loc4_);
      }
      
      public static function getMultiFormattedDateTime(param1:Array, param2:Date) : Array
      {
         var _loc3_:Array = new Array();
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_[_loc4_] = LocaleFormatter.getFormattedDateTime(param1[_loc4_],param2);
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function getFormattedDateTime(param1:String, param2:Date) : String
      {
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         switch(param1)
         {
            case "a":
            case "aa":
               _loc4_ = param2.getHours() < 12;
               if(_loc4_)
               {
                  _loc3_ = "am";
               }
               else
               {
                  _loc3_ = "pm";
               }
               break;
            case "j":
               _loc3_ = param2.getDate().toString();
               break;
            case "d":
               _loc3_ = param2.getDate().toString();
               if(_loc3_.length == 1)
               {
                  _loc3_ = "0" + _loc3_;
               }
               break;
            case "n":
               _loc3_ = (param2.getMonth() + 1).toString();
               break;
            case "m":
               _loc3_ = (param2.getMonth() + 1).toString();
               if(_loc3_.length == 1)
               {
                  _loc3_ = "0" + _loc3_;
               }
               break;
            case "Y":
               _loc3_ = param2.getFullYear().toString();
               break;
            case "g":
               _loc5_ = param2.getHours() % 12;
               if(_loc5_ == 0)
               {
                  _loc5_ = 12;
               }
               _loc3_ = _loc5_.toString();
               break;
            case "h":
               _loc6_ = param2.getHours() % 12;
               if(_loc6_ == 0)
               {
                  _loc6_ = 12;
               }
               _loc3_ = _loc6_.toString();
               if(_loc3_.length == 1)
               {
                  _loc3_ = "0" + _loc3_;
               }
               break;
            case "i":
               _loc3_ = param2.getMinutes().toString();
               if(_loc3_.length == 1)
               {
                  _loc3_ = "0" + _loc3_;
               }
               break;
            case "s":
               _loc3_ = param2.getSeconds().toString();
               if(_loc3_.length == 1)
               {
                  _loc3_ = "0" + _loc3_;
               }
               break;
            case "G":
               _loc3_ = param2.getHours().toString();
               break;
            case "H":
               _loc3_ = param2.getHours().toString();
               if(_loc3_.length == 1)
               {
                  _loc3_ = "0" + _loc3_;
               }
         }
         return _loc3_;
      }
   }
}

