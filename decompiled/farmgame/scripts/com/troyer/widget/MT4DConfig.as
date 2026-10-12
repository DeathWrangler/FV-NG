package com.troyer.widget
{
   import Engine.Interfaces.IFontMapper;
   import Engine.Interfaces.ILocalizer;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.net.URLLoader;
   
   public class MT4DConfig
   {
      
      public function MT4DConfig()
      {
         super();
      }
      
      public function onGetAssetPath(param1:String) : String
      {
         return param1;
      }
      
      public function onGetLocalizedAssetPath(param1:String) : String
      {
         return param1;
      }
      
      public function onUncompressData(param1:Event) : *
      {
         var _loc2_:URLLoader = param1.target as URLLoader;
         if(_loc2_ == null)
         {
            throw new Error("Event target is not URLLoader.");
         }
         return _loc2_.data;
      }
      
      public function overridesLoadImage() : Boolean
      {
         return false;
      }
      
      public function loadImage(param1:String, param2:Function, param3:Function) : Loader
      {
         return null;
      }
      
      public function getFontMapper() : IFontMapper
      {
         return null;
      }
      
      public function getLocalizer() : ILocalizer
      {
         return null;
      }
      
      public function getLocaleCode() : String
      {
         return "en_US";
      }
      
      public function onGetLocalizedString(param1:String) : String
      {
         return param1;
      }
      
      public function onGetLocalizedFontName(param1:String, param2:String) : String
      {
         return param2;
      }
   }
}

