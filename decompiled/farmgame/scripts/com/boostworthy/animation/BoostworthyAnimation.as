package com.boostworthy.animation
{
   import com.boostworthy.utils.logger.LogFactory;
   
   public final class BoostworthyAnimation
   {
      
      private static var c_bIsLogged:Boolean;
      
      public static const NAME:String = "Boostworthy Animation System";
      
      public static const VERSION:String = "2.1";
      
      public static const DATE:String = "06.07.2007";
      
      public static const AUTHOR:String = "Copyright (c) 2007 Ryan Taylor | http://www.boostworthy.com";
      
      public function BoostworthyAnimation()
      {
         super();
      }
      
      public static function log() : void
      {
         if(!c_bIsLogged)
         {
            LogFactory.getInstance().getLog(NAME).info("Version " + VERSION + " :: " + AUTHOR);
            c_bIsLogged = true;
         }
      }
   }
}

