package Classes
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.DynamicIconQueue;
   import flash.utils.Dictionary;
   
   public class DealOfDayHelper
   {
      
      private static var s_marketCard:String;
      
      private static const DEFAULT_MARKET_CARD:String = "dealofday";
      
      private static const END_TIME:String = "23:30:00";
      
      private static const EXPERIMENT_UNINITIALIZED:int = -1;
      
      private static const EXPERIMENT_INACTIVE:int = 0;
      
      private static const EXPERIMENT_ACTIVE:int = 1;
      
      private static var s_deals:Dictionary = null;
      
      private static var s_inExperiment:int = EXPERIMENT_UNINITIALIZED;
      
      public function DealOfDayHelper()
      {
         super();
      }
      
      public static function parseDealOfDayData() : void
      {
         var variant:int = 0;
         var variantXml:XML = null;
         var itemCode:String = null;
         var dealObj:Object = null;
         var featureXml:XML = Global.farmGameSettingsManager.getFeatureXML("DealOfDay");
         s_deals = new Dictionary();
         if(featureXml)
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DEAL_OF_DAY);
            s_marketCard = featureXml.hasOwnProperty("marketCard") ? featureXml.@marketCard as String : DEFAULT_MARKET_CARD;
            itemCode = featureXml.@itemCode;
            dealObj = null;
            for each(variantXml in featureXml.variant)
            {
               if(variantXml.@value == variant)
               {
                  dealObj = new Object();
                  dealObj.currency = variantXml.@currency;
                  dealObj.price = variantXml.@price;
                  dealObj.endTime = FarmGameUtil.synchronizedDateTimeToNumber(featureXml.@born + " " + END_TIME);
                  break;
               }
            }
            if(dealObj)
            {
               s_deals[itemCode] = dealObj;
            }
         }
      }
      
      public static function isDealOfDayItem(itemCode:String) : Boolean
      {
         var result:Boolean = false;
         if(inExperiment() && Boolean(s_deals))
         {
            result = s_deals[itemCode] != null;
         }
         return result;
      }
      
      public static function getDealOfDayItemPrice(itemCode:String) : Number
      {
         var result:Number = 0;
         if(Boolean(s_deals) && Boolean(s_deals[itemCode]))
         {
            result = Number(s_deals[itemCode].price);
         }
         return result;
      }
      
      public static function getDealOfDayItemCurrency(itemCode:String) : String
      {
         var result:String = "";
         if(Boolean(s_deals) && Boolean(s_deals[itemCode]))
         {
            result = s_deals[itemCode].currency;
         }
         return result;
      }
      
      public static function init() : void
      {
         var itemXML:XML = null;
         var itemName:String = null;
         var farmItem:FarmItem = null;
         var farmItemName:String = null;
         var itemCode:String = null;
         parseDealOfDayData();
         for(itemCode in s_deals)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(farmItem)
            {
               farmItem.isDealOfDaySaleItem = true;
            }
         }
         if(farmItem)
         {
            Global.hud.rightSideIconQueue.addIcon("dealOfDay",DynamicIconQueue.ADD_BY_PRIORITY,null,null,false);
         }
      }
      
      public static function getDealOfDayItem() : FarmItem
      {
         var result:FarmItem = null;
         var itemCode:String = null;
         if(s_deals)
         {
            for(itemCode in s_deals)
            {
               result = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               if(result)
               {
                  break;
               }
            }
         }
         return result;
      }
      
      public static function getDealOfDayItemTimeLeft(itemCode:String) : Number
      {
         var result:Number = 0;
         if(Boolean(s_deals) && Boolean(s_deals[itemCode]))
         {
            result = (s_deals[itemCode].endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         return result;
      }
      
      public static function inExperiment() : Boolean
      {
         return false;
      }
      
      public static function get marketCardDescriptorName() : String
      {
         return s_marketCard;
      }
   }
}

