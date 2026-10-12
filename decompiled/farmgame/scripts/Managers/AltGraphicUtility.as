package Managers
{
   public class AltGraphicUtility
   {
      
      public static const UNLIMITED_LICENSE:Number = -1;
      
      public static const GRAPHIC_KEY_SNOW:String = "snow";
      
      public static const CREDIT_KEY_SNOW:String = "snow_altgraphic";
      
      public static const ITEM_KEY_CASH_SNOW_SINGLE:String = "snow_altgraphic";
      
      public static const ITEM_KEY_CASH_SNOW_UNLIMITED:String = "snow_altgraphic_unlimited";
      
      public static const GRAPHIC_KEY_LIGHTS:String = "xmaslight";
      
      public static const CREDIT_KEY_LIGHTS:String = "xmaslight";
      
      public static const ITEM_KEY_CASH_LIGHTS_SINGLE:String = "xmaslight";
      
      public static const ITEM_KEY_CASH_LIGHTS_UNLIMITED:String = "xmaslight_unlimited";
      
      public static const GRAPHIC_KEY_LIGHTS_SNOW:String = "lights";
      
      public static const CREDIT_KEY_LIGHTS_SNOW:String = "lights";
      
      public static const ITEM_KEY_CASH_LIGHTS_SNOW_SINGLE:String = "lights";
      
      public static const ITEM_KEY_COINS_LIGHTS_SNOW_UNLIMITED:String = "lights_unlimited";
      
      public static const ITEM_KEY_CASH_LIGHTS_SNOW_UNLIMITED:String = "lights_unlimited_cash";
      
      public function AltGraphicUtility()
      {
         super();
      }
      
      public static function getAltGraphicCreditKey(graphicName:String) : String
      {
         var licIndex:int = 0;
         var result:String = graphicName;
         switch(graphicName)
         {
            case AltGraphicUtility.ITEM_KEY_CASH_SNOW_UNLIMITED:
            case AltGraphicUtility.ITEM_KEY_CASH_SNOW_SINGLE:
            case AltGraphicUtility.GRAPHIC_KEY_SNOW:
               result = AltGraphicUtility.CREDIT_KEY_SNOW;
               break;
            case AltGraphicUtility.ITEM_KEY_CASH_LIGHTS_SINGLE:
            case AltGraphicUtility.ITEM_KEY_CASH_LIGHTS_UNLIMITED:
               result = AltGraphicUtility.CREDIT_KEY_LIGHTS;
               break;
            case AltGraphicUtility.ITEM_KEY_CASH_LIGHTS_SNOW_SINGLE:
            case AltGraphicUtility.ITEM_KEY_CASH_LIGHTS_SNOW_UNLIMITED:
            case AltGraphicUtility.ITEM_KEY_COINS_LIGHTS_SNOW_UNLIMITED:
               result = AltGraphicUtility.CREDIT_KEY_LIGHTS_SNOW;
               break;
            default:
               licIndex = graphicName.indexOf("_unlimited");
               if(licIndex > -1)
               {
                  result = graphicName.slice(0,licIndex);
               }
               else
               {
                  result = graphicName;
               }
         }
         return result;
      }
      
      public static function isOverlayNameDefined(overlayName:String, overlaySet:Array) : Boolean
      {
         var i:int = 0;
         var result:Boolean = false;
         if(overlaySet != null)
         {
            for(i = 0; i < overlaySet.length; i++)
            {
               if(overlayName == overlaySet[i])
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public static function creditOnRemove(name:String) : Boolean
      {
         var result:Boolean = true;
         var overlayXML:XML = Global.farmGameSettingsManager.getOverlayByName(name);
         if(overlayXML == null)
         {
            overlayXML = Global.farmGameSettingsManager.getAltGraphicByName(name);
         }
         if(overlayXML != null && overlayXML.@noCreditOnRemove == "true")
         {
            result = false;
         }
         return result;
      }
   }
}

