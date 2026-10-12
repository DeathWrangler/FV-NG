package Managers
{
   import Classes.BuildingPart;
   import Classes.FeatureBuilding;
   import Classes.FeedData;
   import Classes.Player;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TStoreItem;
   
   public class BaseFeatureManager
   {
      
      private static var s_allowInstantiation:Boolean;
      
      private static var s_instances:Object = {};
      
      protected var m_featureName:String;
      
      protected var m_featureConfig:XML;
      
      protected var m_featureConfigManager:FeatureConfigManager;
      
      private var m_actionCountKey:String;
      
      private var m_featureLastShownKey:String;
      
      public function BaseFeatureManager(featureName:String, featureConfig:XML = null)
      {
         super();
         if(s_allowInstantiation)
         {
            s_allowInstantiation = false;
            this.m_featureName = featureName;
            this.m_featureConfig = featureConfig ? featureConfig : Global.farmGameSettingsManager.getFeatureXML(featureName);
            this.m_featureConfigManager = FeatureConfigManager.getFeatureConfiguration(featureName);
            this.m_actionCountKey = featureName + "ActionCount";
            this.m_featureLastShownKey = featureName + "LastShown";
            return;
         }
         throw new Error("Instantiation failed: Use BaseFeatureManager.getInstance");
      }
      
      public static function getInstance(featureName:String) : BaseFeatureManager
      {
         return getInstanceOfClass(featureName,BaseFeatureManager);
      }
      
      protected static function getInstanceOfClass(featureName:String, className:Class) : BaseFeatureManager
      {
         var manager:BaseFeatureManager = null;
         if(s_instances[featureName])
         {
            manager = s_instances[featureName];
         }
         else
         {
            s_allowInstantiation = true;
            manager = new className(featureName);
            s_instances[featureName] = manager;
         }
         return manager;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function get featureConfig() : XML
      {
         return this.m_featureConfig;
      }
      
      public function getFeatureOptionData() : Object
      {
         var result:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,this.m_featureName);
         if(!ObjectUtil.objectHasProperties(result))
         {
            result = this.getNewFeatureOptionData();
            this.setFeatureData(result);
         }
         return result;
      }
      
      protected function getNewFeatureOptionData() : Object
      {
         return {};
      }
      
      public function setFeatureData(featureOptionData:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,this.m_featureName,featureOptionData);
      }
      
      public function getConstantsStringWithKey(key:String) : String
      {
         var result:String = "";
         if(Boolean(this.m_featureConfigManager) && this.m_featureConfigManager.hasConstant(key))
         {
            result = this.m_featureConfigManager.getStringConstant(key);
         }
         return result;
      }
      
      public function getConstantsIntWithKey(key:String) : int
      {
         var result:int = int.MIN_VALUE;
         if(Boolean(this.m_featureConfigManager) && this.m_featureConfigManager.hasConstant(key))
         {
            result = this.m_featureConfigManager.getNumberConstant(key);
         }
         return result;
      }
      
      public function hasConstantsKey(key:String) : Boolean
      {
         return this.m_featureConfigManager.hasConstant(key);
      }
      
      public function getActionCount(keySuffix:String = "") : int
      {
         return Global.player.getActionCount(this.m_actionCountKey + keySuffix);
      }
      
      public function incrementActionCount(amount:int = 1, persist:Boolean = false, keySuffix:String = "") : int
      {
         var maxActionCount:int = 0;
         var amountAboveMax:int = 0;
         var actionCountKey:String = this.m_actionCountKey + keySuffix;
         var player:Player = Global.player;
         var maxActionCountString:String = "maxActionCount";
         if(this.hasConstantsKey(maxActionCountString))
         {
            maxActionCount = this.getConstantsIntWithKey(maxActionCountString);
            amountAboveMax = this.getActionCount() + amount - maxActionCount;
            if(amountAboveMax > 0)
            {
               amount -= amountAboveMax;
            }
         }
         if(amount == 1)
         {
            player.incrementActionCount(actionCountKey,persist);
         }
         else if(amount != 0)
         {
            player.setActionCount(actionCountKey,player.getActionCount(actionCountKey) + amount,persist);
         }
         return amount;
      }
      
      public function incrementActionCountWithOrder(itemCode:String = "") : int
      {
         var multipler:int = 0;
         var bulkGrantCount:int = 0;
         var consumableCount:int = 0;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var count:Number = item.count;
         if(count < 1)
         {
            multipler = 10;
            bulkGrantCount = count * multipler;
            consumableCount = FeatureOptionsInventoryManager.getInstance().getCount(itemCode);
            count = 1;
            if(count + consumableCount >= bulkGrantCount)
            {
               FeatureOptionsInventoryManager.getInstance().removeCount(itemCode,bulkGrantCount - count);
            }
            else
            {
               FeatureOptionsInventoryManager.getInstance().addCount(itemCode,count);
               count = 0;
            }
         }
         return this.incrementActionCount(count);
      }
      
      public function grantBuildingPartsForUpgrade(itemName:String = "", count:int = 0) : Boolean
      {
         var buildings:Array = null;
         var featureBuilding:FeatureBuilding = null;
         var giftItem:FarmItem = null;
         var buildingPart:BuildingPart = null;
         var result:Boolean = false;
         if(Boolean(itemName) && count == 1)
         {
            buildings = Global.world.getObjectsByName("bldg_northpoletoyworks");
            featureBuilding = buildings[0] as FeatureBuilding;
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(giftItem != null)
            {
               buildingPart = new BuildingPart(giftItem.name);
               result = featureBuilding.addItem(buildingPart,0,true,false,true);
               TransactionManager.addTransaction(new TStoreItem(featureBuilding,buildingPart,0,buildingPart.getId(),true,""));
               return true;
            }
         }
         return false;
      }
      
      public function grantBuildingPartsForUpgradeInBrazilInnovation(itemName:String = "", count:int = 0) : Boolean
      {
         var buildings:Array = null;
         var featureBuilding:FeatureBuilding = null;
         var giftItem:FarmItem = null;
         var buildingPart:BuildingPart = null;
         var result:Boolean = false;
         if(Boolean(itemName) && count >= 1)
         {
            buildings = Global.world.getObjectsByName("xsu_girlscoutlily");
            featureBuilding = buildings[0] as FeatureBuilding;
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(giftItem != null)
            {
               buildingPart = new BuildingPart(giftItem.name);
               while(count)
               {
                  result = featureBuilding.addExpansionPart(buildingPart);
                  count--;
               }
               featureBuilding.reloadImage();
               return true;
            }
         }
         return false;
      }
      
      public function getConsumableItemCount(itemCode:String = "") : int
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(itemCode);
      }
      
      public function getFeatureLastShown(keySuffix:String = "") : Number
      {
         return Global.player.getFeatureLastShown(this.m_featureLastShownKey + keySuffix);
      }
      
      public function setFeatureLastShown(keySuffix:String = "", time:Number = NaN, persist:Boolean = false) : void
      {
         if(isNaN(time))
         {
            time = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         }
         Global.player.setFeatureLastShown(this.m_featureLastShownKey + keySuffix,time,persist);
      }
      
      public function canShowFeatureWithFrequencyInSeconds(intervalInSeconds:int, keySuffix:String = "") : Boolean
      {
         return Global.player.canShowFeatureWithFeatureFrequencyInSeconds(this.m_featureLastShownKey + keySuffix,intervalInSeconds);
      }
      
      public function getString(suffix:String, pkg:String = "Dialogs", replacements:Object = null) : String
      {
         return ZLocUtils.t(pkg,this.m_featureName + "_" + suffix,replacements);
      }
      
      public function getAssetURL(type:String) : String
      {
         return this.m_featureConfigManager.getAssetUrl(type);
      }
      
      public function get consumable() : FarmItem
      {
         return this.m_featureConfigManager.consumable;
      }
      
      public function getFeedData(source:String) : FeedData
      {
         return this.m_featureConfigManager.getFeedData(source);
      }
      
      public function postFeed(source:String, callback:Function = null) : void
      {
         var feed:FeedData = this.m_featureConfigManager.getFeedData(source);
         feed.postFeed(callback);
      }
      
      public function getThrottleTimeRemaining(source:String) : int
      {
         var feed:FeedData = this.m_featureConfigManager.getFeedData(source);
         return feed.throttleTimeRemaining;
      }
   }
}

