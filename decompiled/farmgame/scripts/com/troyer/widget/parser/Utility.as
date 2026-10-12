package com.troyer.widget.parser
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.MT4DConfig;
   import flash.display.DisplayObject;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class Utility
   {
      
      public function Utility()
      {
         super();
      }
      
      public static function traceObject(param1:Object, param2:String = "") : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         for(_loc3_ in param1)
         {
            if(!(param1[_loc3_] is int || param1[_loc3_] is Number))
            {
               if(!(param1[_loc3_] is String))
               {
                  if(param1[_loc3_] != null)
                  {
                     if(param1[_loc3_] is Array)
                     {
                        traceObject(param1[_loc3_],param2 + "   ");
                     }
                     else if(param1[_loc3_] is Object)
                     {
                        traceObject(param1[_loc3_],param2 + "   ");
                     }
                     else
                     {
                        _loc4_ = getQualifiedClassName(param1[_loc3_]);
                     }
                  }
               }
            }
         }
      }
      
      public static function cloneDictionary(param1:Dictionary) : Dictionary
      {
         var _loc3_:String = null;
         var _loc2_:Dictionary = new Dictionary();
         for(_loc3_ in param1)
         {
            if(param1[_loc3_] is Dictionary)
            {
               _loc2_[_loc3_] = cloneDictionary(param1[_loc3_]);
            }
            else if(param1[_loc3_] is Array)
            {
               _loc2_[_loc3_] = cloneArray(param1[_loc3_]);
            }
            else
            {
               _loc2_[_loc3_] = param1[_loc3_];
            }
         }
         return _loc2_;
      }
      
      public static function cloneArray(param1:Array) : Array
      {
         var _loc3_:* = undefined;
         var _loc2_:Array = new Array();
         for each(_loc3_ in param1)
         {
            if(_loc3_ is Dictionary)
            {
               _loc2_.push(cloneDictionary(_loc3_));
            }
            else if(_loc3_ is Array)
            {
               _loc2_.push(cloneArray(param1));
            }
            else
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public static function concatUniqueArray(... rest) : Array
      {
         var _loc3_:* = undefined;
         var _loc4_:* = undefined;
         var _loc2_:Array = new Array();
         for each(_loc3_ in rest)
         {
            if(_loc3_ is Array)
            {
               for each(_loc4_ in _loc3_)
               {
                  if(_loc2_.indexOf(_loc4_) == -1)
                  {
                     _loc2_.push(_loc4_);
                  }
               }
            }
         }
         return _loc2_;
      }
      
      public static function stringIsTrue(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(param1.toLowerCase() == "true" || param1 == "1" || param1.toLowerCase() == "yes")
         {
            _loc2_ = true;
         }
         return _loc2_;
      }
      
      public static function removeDisplayObjectFromParent(param1:DisplayObject) : void
      {
         if(param1)
         {
            if(param1.parent)
            {
               param1.parent.removeChild(param1);
            }
         }
      }
      
      public static function getDictionaryLength(param1:Dictionary) : int
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         if(param1)
         {
            for(_loc3_ in param1)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public static function findViewInDictionary(param1:String, param2:Dictionary) : Dictionary
      {
         var _loc4_:Dictionary = null;
         var _loc3_:Dictionary = null;
         if(Boolean(param2[Constants.ATTRIBUTES].hasOwnProperty(Constants.ATTRIBUTE_NAME)) && param2[Constants.ATTRIBUTES][Constants.ATTRIBUTE_NAME] == param1)
         {
            _loc3_ = param2;
         }
         else if(param2.hasOwnProperty(Constants.CHILDREN))
         {
            for each(_loc4_ in param2[Constants.CHILDREN])
            {
               _loc3_ = findViewInDictionary(param1,_loc4_);
               if(_loc3_)
               {
                  break;
               }
            }
         }
         return _loc3_;
      }
      
      public static function localizeAttributeValue(param1:MT4DConfig, param2:String) : String
      {
         if(param1 != null && param2.length > 0 && param2.charAt(0) == "@")
         {
            return param1.onGetLocalizedString(param2.substr(1));
         }
         return param2;
      }
   }
}

