package Engine
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.StageDisplayState;
   import flash.events.FullScreenEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class Utilities
   {
      
      private static var m_idCounter:Number = 0;
      
      public function Utilities()
      {
         super();
      }
      
      public static function removeAllChildren(param1:DisplayObjectContainer) : void
      {
         var _loc2_:* = 0;
         if(param1 != null)
         {
            _loc2_ = param1.numChildren;
            while(_loc2_ > 0)
            {
               param1.removeChildAt(_loc2_ - 1);
               _loc2_--;
            }
         }
      }
      
      public static function clamp(param1:Number, param2:Number, param3:Number) : Number
      {
         var _loc4_:Number = Math.max(param1,param2);
         return Math.min(_loc4_,param3);
      }
      
      public static function getStackTrace() : String
      {
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc1_:String = null;
         var _loc2_:String = "";
         var _loc3_:Error = new Error();
         try
         {
            _loc1_ = _loc3_.getStackTrace();
         }
         catch(e:Error)
         {
         }
         if(_loc1_ != null && _loc1_ != "")
         {
            _loc4_ = _loc1_.split("\n",5);
            _loc5_ = String(_loc4_[4]);
            _loc2_ = _loc5_.substring(4,_loc5_.indexOf("()",4) + 2);
         }
         return _loc2_;
      }
      
      public static function hexColorToIntColor(param1:String) : uint
      {
         var _loc2_:uint = 0;
         if(param1.length == 7)
         {
            _loc2_ = parseInt("0x" + param1.substr(1));
         }
         else if(param1.length == 6)
         {
            _loc2_ = parseInt("0x" + param1);
         }
         return _loc2_;
      }
      
      public static function getSmoothableBitmap(param1:DisplayObject) : Bitmap
      {
         var _loc2_:BitmapData = new BitmapData(param1.width,param1.height,true,0);
         _loc2_.draw(param1,null,null,null,null,true);
         return new Bitmap(_loc2_,"auto",true);
      }
      
      public static function intColorToHexColor(param1:uint) : String
      {
         var _loc2_:String = param1.toString(16);
         while(_loc2_.length < 6)
         {
            _loc2_ = "0" + _loc2_;
         }
         return _loc2_.toUpperCase();
      }
      
      public static function isURL(param1:String) : Boolean
      {
         var _loc2_:RegExp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/;
         return _loc2_.test(param1);
      }
      
      public static function launchURL(param1:String, param2:String = "_blank", param3:Object = null) : void
      {
         var browser:String = null;
         var url:String = param1;
         var target:String = param2;
         var variables:Object = param3;
         var request:URLRequest = new URLRequest(url);
         var useNavigateToURL:Boolean = true;
         if(variables)
         {
            request.data = variables;
         }
         try
         {
            if(ExternalInterface.available)
            {
               browser = ExternalInterface.call("function a() {return navigator.userAgent;}");
               if(browser != null && browser.indexOf("Firefox") < 1)
               {
                  useNavigateToURL = true;
               }
               else
               {
                  ExternalInterface.call("window.open",url,target,"");
                  useNavigateToURL = false;
               }
            }
            else
            {
               useNavigateToURL = true;
            }
         }
         catch(error:SecurityError)
         {
            useNavigateToURL = true;
         }
         if(useNavigateToURL)
         {
            navigateToURL(request,target);
         }
      }
      
      public static function centerWindow(param1:DisplayObject) : void
      {
         param1.x = (GlobalEngine.stage.stageWidth - param1.width) / 2;
         param1.y = (GlobalEngine.stage.stageHeight - param1.height) / 2;
      }
      
      public static function extractBasicTag(param1:String, param2:String) : String
      {
         var _loc5_:int = 0;
         var _loc3_:String = null;
         var _loc4_:int = param1.indexOf(param2 + "=\"");
         if(_loc4_ != -1)
         {
            _loc4_ += param2.length + 2;
            _loc5_ = param1.indexOf("\"",_loc4_);
            if(_loc5_ != -1)
            {
               _loc3_ = param1.substring(_loc4_,_loc5_);
            }
         }
         return _loc3_;
      }
      
      public static function extractStyle(param1:String, param2:String) : String
      {
         var _loc5_:int = 0;
         param1 += ";";
         var _loc3_:String = null;
         var _loc4_:int = param1.indexOf(param2 + ":");
         if(_loc4_ != -1)
         {
            _loc4_ += param2.length + 1;
            _loc5_ = param1.indexOf(";",_loc4_);
            if(_loc5_ != -1)
            {
               _loc3_ = param1.substring(_loc4_,_loc5_);
            }
         }
         return _loc3_;
      }
      
      public static function createSquareBitmapData(param1:DisplayObject) : BitmapData
      {
         var _loc2_:Number = Math.min(param1.width,param1.height);
         var _loc3_:Point = new Point((param1.width - _loc2_) / 2,(param1.height - _loc2_) / 2);
         var _loc4_:Matrix = new Matrix();
         _loc4_.translate(-_loc3_.x,-_loc3_.y);
         var _loc5_:BitmapData = new BitmapData(_loc2_,_loc2_,true,0);
         _loc5_.draw(param1,_loc4_);
         return _loc5_;
      }
      
      public static function generateUniqueId() : Number
      {
         ++m_idCounter;
         return m_idCounter;
      }
      
      public static function setFullScreen(param1:Boolean) : void
      {
         if(GlobalEngine.stage)
         {
            try
            {
               if(param1)
               {
                  GlobalEngine.stage.displayState = StageDisplayState.FULL_SCREEN;
               }
               else
               {
                  GlobalEngine.stage.displayState = StageDisplayState.NORMAL;
               }
            }
            catch(err:SecurityError)
            {
            }
            GlobalEngine.log("Engine","Toggling Fullscreen, DisplayState: " + GlobalEngine.stage.displayState.toString());
         }
      }
      
      public static function isFullScreen() : Boolean
      {
         return GlobalEngine.stage.displayState == StageDisplayState.FULL_SCREEN;
      }
      
      public static function toggleFullScreen() : void
      {
         setFullScreen(isFullScreen() == false);
      }
      
      private static function onFullScreenChanged(param1:FullScreenEvent) : void
      {
         GlobalEngine.viewport.centerViewport();
      }
      
      public static function randBetween(param1:Number, param2:Number) : Number
      {
         return Math.random() * (param2 - param1) + param1;
      }
      
      public static function padDecimals(param1:Number, param2:int, param3:Boolean = false) : String
      {
         var _loc5_:String = null;
         var _loc4_:String = param1.toString();
         if(!param3 || _loc4_.indexOf(".") >= 0)
         {
            _loc5_ = Math.round(param1 * Math.pow(10,param2)).toString();
            _loc4_ = _loc5_.substr(0,_loc5_.length - param2) + "." + _loc5_.substr(-param2);
         }
         return _loc4_;
      }
      
      public static function formatNumber(param1:Number) : String
      {
         var _loc4_:Number = NaN;
         var _loc2_:String = Math.floor(param1).toString();
         var _loc3_:Array = new Array();
         var _loc5_:Number = _loc2_.length;
         while(_loc5_ > 0)
         {
            _loc4_ = Math.max(_loc5_ - 3,0);
            _loc3_.unshift(_loc2_.slice(_loc4_,_loc5_));
            _loc5_ = _loc4_;
         }
         return _loc3_.join(",");
      }
      
      public static function parseLocalizationString(param1:String) : Object
      {
         var _loc2_:Array = param1.split(":");
         var _loc3_:Object = new Object();
         _loc3_.filename = _loc2_[0];
         _loc3_.stringname = _loc2_[1];
         return _loc3_;
      }
      
      public static function dateToNumber(param1:String, param2:Boolean = false) : Number
      {
         var _loc4_:Array = null;
         var _loc3_:Number = 0;
         if(param2)
         {
            _loc4_ = String(param1).split("/",3);
            _loc3_ = Date.UTC(parseInt(_loc4_[2]),parseInt(_loc4_[0]) - 1,parseInt(_loc4_[1]));
         }
         else
         {
            _loc3_ = new Date(param1).valueOf();
         }
         return _loc3_;
      }
      
      public static function xmlListToArray(param1:XMLList, param2:String = "") : Array
      {
         var _loc4_:XML = null;
         var _loc3_:Array = new Array();
         if(param2 == "")
         {
            for each(_loc4_ in param1)
            {
               _loc3_.push(_loc4_);
            }
         }
         else
         {
            for each(_loc4_ in param1)
            {
               _loc3_.push(String(_loc4_.attribute(param2)));
            }
         }
         return _loc3_;
      }
      
      public static function uncompress(param1:ByteArray) : String
      {
         var compressedData:ByteArray = param1;
         var compressedLength:int = int(compressedData.length);
         try
         {
            compressedData.uncompress();
         }
         catch(e:Error)
         {
            throw e;
         }
         GlobalEngine.msg("Util","Loaded compressed localization file. Originally:",compressedLength,"Decompressed:",compressedData.length);
         return compressedData.toString();
      }
      
      public static function printr(param1:*, param2:int = 0, param3:String = "") : *
      {
         var _loc6_:* = undefined;
         var _loc7_:String = null;
         if(param2 == 0)
         {
            param3 = "(" + Utilities.typeOf(param1) + ") {\n";
         }
         else if(param2 == 10)
         {
            return param3;
         }
         var _loc4_:String = "\t";
         var _loc5_:int = 0;
         while(_loc5_ < param2)
         {
            _loc5_++;
            _loc4_ += "\t";
         }
         for(_loc6_ in param1)
         {
            param3 += _loc4_ + "[" + _loc6_ + "] => (" + Utilities.typeOf(param1[_loc6_]) + ") ";
            if(Utilities.count(param1[_loc6_]) == 0)
            {
               param3 += param1[_loc6_];
            }
            _loc7_ = "";
            if(typeof param1[_loc6_] != "xml")
            {
               _loc7_ = Utilities.printr(param1[_loc6_],param2 + 1);
            }
            if(_loc7_ != "")
            {
               param3 += "{\n" + _loc7_ + _loc4_ + "}";
            }
            param3 += "\n";
         }
         if(param2 == 0)
         {
            return;
         }
         return param3;
      }
      
      public static function typeOf(param1:*) : String
      {
         if(param1 is Array)
         {
            return "array";
         }
         if(param1 is Date)
         {
            return "date";
         }
         return typeof param1;
      }
      
      public static function count(param1:Object) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:* = undefined;
         if(Utilities.typeOf(param1) == "array")
         {
            return param1.length;
         }
         _loc2_ = 0;
         for(_loc3_ in param1)
         {
            if(_loc3_ != "mx_internal_uid")
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public static function trim(param1:String) : String
      {
         return param1.replace(/^(\s| )+|(\s| )+$/g,"");
      }
      
      public static function arrayRand(param1:Array) : Object
      {
         return param1[Math.floor(Math.random() * param1.length)];
      }
      
      public static function arrayDiff(param1:Array, param2:Array) : Array
      {
         var _loc3_:int = 0;
         var _loc6_:Object = null;
         var _loc4_:Array = new Array();
         var _loc5_:Dictionary = new Dictionary();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc5_[param1[_loc3_]] = true;
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            if(_loc5_[param2[_loc3_]])
            {
               delete _loc5_[param2[_loc3_]];
            }
            else
            {
               _loc4_.push(param2[_loc3_]);
            }
            _loc3_++;
         }
         for(_loc6_ in _loc5_)
         {
            _loc4_.push(_loc6_);
         }
         return _loc4_;
      }
      
      public static function arrayIntersect(param1:Array, param2:Array) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:Array = new Array();
         var _loc5_:Dictionary = new Dictionary();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc5_[param1[_loc3_]] = true;
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            if(_loc5_[param2[_loc3_]])
            {
               _loc4_.push(param2[_loc3_]);
            }
            _loc3_++;
         }
         return _loc4_;
      }
      
      public static function toggleInputOnlySelf(param1:InteractiveObject, param2:Boolean) : void
      {
         param1.mouseEnabled = param1.tabEnabled = param2;
      }
      
      public static function toggleInputAndChildren(param1:DisplayObjectContainer, param2:Boolean) : void
      {
         param1.mouseChildren = param1.mouseEnabled = param1.tabChildren = param1.tabEnabled = param2;
      }
      
      public static function toggleInputOnlyChildren(param1:DisplayObjectContainer, param2:Boolean) : void
      {
         param1.mouseChildren = param1.tabChildren = param2;
      }
      
      public static function toggleSound(param1:MovieClip, param2:Boolean) : void
      {
         var _loc3_:SoundTransform = new SoundTransform();
         _loc3_.volume = param2 ? 1 : 0;
         param1.soundTransform = _loc3_;
      }
   }
}

