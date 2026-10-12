package
{
   import ZLocalization.LocalizationName;
   import ZLocalization.LocalizationObjectToken;
   import ZLocalization.Localizer;
   
   public class ZLoc
   {
      
      public static var instance:Localizer;
      
      private static const DEFAULT_GENDER:String = "masc";
      
      private static const NO_COUNT:int = -1;
      
      public function ZLoc()
      {
         super();
      }
      
      public static function t(param1:String, param2:String, param3:Object = null) : String
      {
         return instance.translate(param1,param2,param3);
      }
      
      public static function tk(param1:String, param2:String, param3:String = "", param4:int = -1) : LocalizationObjectToken
      {
         return instance.createToken(param1,param2,param3,param4);
      }
      
      public static function tn(param1:String, param2:String = "masc") : LocalizationName
      {
         return instance.createName(param1,param2);
      }
      
      public static function ti(param1:String) : String
      {
         return instance.translateImagePath(param1);
      }
   }
}

