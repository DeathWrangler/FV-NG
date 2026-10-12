package com.boostworthy.core
{
   import flash.display.Stage;
   
   public final class Global
   {
      
      private static var c_objStage:Stage;
      
      public static var NULL_INDEX:int = -1;
      
      public function Global()
      {
         super();
         throw new Error("ERROR -> Global :: Constructor :: The \'Global\' class is not meant to be instantiated.");
      }
      
      public static function get stage() : Stage
      {
         return c_objStage;
      }
      
      public static function set stage(param1:Stage) : void
      {
         c_objStage = param1;
      }
   }
}

