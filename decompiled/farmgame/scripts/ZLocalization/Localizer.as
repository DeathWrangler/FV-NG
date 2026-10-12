package ZLocalization
{
   import Engine.Interfaces.IFontMapper;
   import Engine.Interfaces.ILocalizer;
   import ZLocalization.Substituters.SubstituterDe;
   import ZLocalization.Substituters.SubstituterEnFlip;
   import ZLocalization.Substituters.SubstituterEnZy;
   import ZLocalization.Substituters.SubstituterEs;
   import ZLocalization.Substituters.SubstituterFr;
   import ZLocalization.Substituters.SubstituterIt;
   import ZLocalization.Substituters.SubstituterPt;
   import ZLocalization.Substituters.SubstituterSimple;
   import flash.utils.getDefinitionByName;
   
   public class Localizer implements ILocalizer
   {
      
      protected static var substituterMap:Object = {
         "es":SubstituterEs,
         "en_UD":SubstituterEnFlip,
         "en_PI":SubstituterEnZy,
         "it":SubstituterIt,
         "pt":SubstituterPt,
         "fr":SubstituterFr,
         "de":SubstituterDe
      };
      
      public const MASC:String = "masc";
      
      public const FEM:String = "fem";
      
      private const IMAGE_PACKAGE:String = "LocalizedImages";
      
      protected const LOCALE_DELIMITER:String = "_";
      
      private const NO_COUNT:int = -1;
      
      private const DEFAULT_GENDER:String = "masc";
      
      protected var m_substituter:SubstituterSimple;
      
      protected var m_raw:Object;
      
      protected var m_cached:Object;
      
      protected var m_locale:String;
      
      internal var m_fontMapper:IFontMapper;
      
      public function Localizer(param1:Object)
      {
         super();
      }
      
      protected function setSubstituter() : void
      {
         if(substituterMap.hasOwnProperty(this.m_locale))
         {
            this.m_substituter = new substituterMap[this.m_locale]();
         }
         else if(substituterMap.hasOwnProperty(this.langCode))
         {
            this.m_substituter = new substituterMap[this.langCode]();
         }
         else
         {
            this.m_substituter = new SubstituterSimple();
         }
      }
      
      public function get langCode() : String
      {
         return this.m_locale.split(this.LOCALE_DELIMITER)[0];
      }
      
      public function get localeCode() : String
      {
         return this.m_locale;
      }
      
      public function setAsGlobalInstance() : void
      {
         ZLoc.instance = this;
      }
      
      public function t(param1:String, param2:String, param3:Object = null) : String
      {
         return this.translate(param1,param2,param3);
      }
      
      public function tk(param1:String, param2:String, param3:String = "", param4:int = -1) : LocalizationObjectToken
      {
         return this.createToken(param1,param2,param3,param4);
      }
      
      public function tn(param1:String, param2:String = "masc") : LocalizationName
      {
         return this.createName(param1,param2);
      }
      
      public function createToken(param1:String, param2:String, param3:String = "", param4:int = -1) : LocalizationObjectToken
      {
         return new LocalizationObjectToken(this.getString(param1,param2),param3,param4);
      }
      
      public function createName(param1:String, param2:String = "masc") : LocalizationName
      {
         return new LocalizationName(param1,param2);
      }
      
      public function translate(param1:String, param2:String, param3:Object = null) : String
      {
         var _loc4_:LocalizedString = this.getString(param1,param2);
         if(_loc4_ == null)
         {
            return "Cannot find string " + param2 + " in package " + param1 + ".";
         }
         return _loc4_.toString(param3 || {},this.m_substituter);
      }
      
      public function translateImagePath(param1:String) : String
      {
         var _loc2_:LocalizedString = this.getString(this.IMAGE_PACKAGE,param1);
         if(_loc2_ == null)
         {
            return "Cannot find path " + param1;
         }
         return _loc2_.getVariation(LocalizedString.ORIGINAL);
      }
      
      public function getString(param1:String, param2:String) : LocalizedString
      {
         return null;
      }
      
      public function injectString(param1:String, param2:String, param3:String) : void
      {
      }
      
      public function getFontMapper() : IFontMapper
      {
         return this.m_fontMapper;
      }
   }
}

