package Managers
{
   import Classes.Animal;
   import Classes.FeatureBuilding;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.ZItem.ExpansionData;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.SuperBuildingCompleteEvent;
   import Init.Worlds.LimboWorldInit;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.LimboInBonusRewardWindow;
   import Widgets.Windows.LimboInnovationRewardWindow;
   import Widgets.Windows.LimboInnovationWindow;
   
   public class LimboInnovationManager extends BaseFeatureManager
   {
      
      public static const WORLD_TYPE:String = "limbo";
      
      public static const SERVICE_NAME:String = "LimboInnovationService";
      
      public static const ACTION_REWARD_BUILDING:String = "grantSuperBuildingRewards";
      
      public static const SUPER_BUILDING_COMPLETE_STATUS:String = "SBCS";
      
      public static const BONUS_REWARD_GRANTED:String = "BONUS_GRANT";
      
      public static const BONUS_REWARD_ID:String = "BR";
      
      public static const ELITEHORSES_BUILDING:String = "EH";
      
      public static const BIGBUILDABLE_BUILDING:String = "BB";
      
      public static const HARVESTBUILDABLE_BUILDING:String = "HB";
      
      private var m_staticData:Object;
      
      private var m_assetPaths:Object;
      
      private var m_rewards:Object;
      
      private const MAIN_URL_KEY:String = "main";
      
      private const REWARD_URL_KEY:String = "reward";
      
      public var m_limboInnovationWindow:LimboInnovationWindow;
      
      public var m_limboRewardWindow:LimboInnovationRewardWindow;
      
      public var m_limboBonusRewardWindow:LimboInBonusRewardWindow;
      
      private var m_buildingDataArray:Array;
      
      private var m_superBuilding:Object;
      
      public function LimboInnovationManager(featureName:String)
      {
         super(featureName);
         this.populateFeatureConfig();
      }
      
      public static function getInstance(featureName:String = "limbo_innovation") : LimboInnovationManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,LimboInnovationManager) as LimboInnovationManager;
      }
      
      public function populateFeatureConfig() : void
      {
         this.loadStaticData();
         this.setSuperBuildings();
      }
      
      private function loadStaticData() : void
      {
         var asset:XML = null;
         var reward:XML = null;
         var rewardObj:Object = null;
         this.m_staticData = new Object();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            this.m_assetPaths = new Object();
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            this.m_rewards = new Object();
            if(featureXML.rewards != "")
            {
               for each(reward in featureXML.rewards.reward)
               {
                  rewardObj = new Object();
                  rewardObj["name"] = reward.@name.toString();
                  this.m_rewards[reward.@type] = rewardObj;
               }
            }
         }
      }
      
      public function initEventListener() : void
      {
         this.removeEventListeners();
         GlobalEventManager.getInstance().addEventListener(SuperBuildingCompleteEvent.BUILDING_COMPLETED,this.onBuildingCompleted);
      }
      
      public function removeEventListeners() : void
      {
         if(GlobalEventManager.getInstance().hasEventListener(SuperBuildingCompleteEvent.BUILDING_COMPLETED))
         {
            GlobalEventManager.getInstance().removeEventListener(SuperBuildingCompleteEvent.BUILDING_COMPLETED,this.onBuildingCompleted);
         }
      }
      
      private function onBuildingCompleted(event:SuperBuildingCompleteEvent) : void
      {
         var buildingName:String = null;
         if(Boolean(event && event.hasOwnProperty("data")) && Boolean(event.data) && event.data.hasOwnProperty("name"))
         {
            buildingName = event.data.name;
            if(this.isSuperBuilding(buildingName))
            {
               this.grantBuildingReward(buildingName);
            }
         }
      }
      
      public function grantBuildingReward(buildingName:String) : void
      {
         var buildingId:String = null;
         if(!this.isBonusRewarded())
         {
            if(!this.isBuildingRewarded(buildingName))
            {
               buildingId = this.getBuildingIdByName(buildingName);
               this.setFeatureOptionsData(buildingId);
               Global.player.addGift(this.getRewardName(buildingId));
               this.showRewardUI(buildingId);
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,ACTION_REWARD_BUILDING,this.onBuildingCompleteReward,[m_featureName,buildingId]));
            }
         }
      }
      
      private function getRewardName(buildingId:String) : String
      {
         return this.m_rewards[buildingId].name;
      }
      
      public function getRewardFriendlyName(buildingId:String) : String
      {
         var item:FarmItem = null;
         var result:String = "";
         if(Boolean(this.m_rewards) && Boolean(this.m_rewards[buildingId]))
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.getRewardName(buildingId));
            result = item.friendlyTitle;
         }
         return result;
      }
      
      public function getBuildingNameById(id:String) : String
      {
         return this.m_superBuilding[id].name;
      }
      
      private function isSuperBuilding(givenBuildingName:String) : Boolean
      {
         var buildingId:String = null;
         var buildingName:String = null;
         var result:Boolean = false;
         if(this.m_superBuilding != null)
         {
            for(buildingId in this.m_superBuilding)
            {
               buildingName = this.m_superBuilding[buildingId].name;
               if(buildingName != null && buildingName == givenBuildingName)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function getBuildingFriendlyName(id:String) : String
      {
         var result:String = "";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getBuildingNameById(id));
         if(item)
         {
            result = item.friendlyTitle;
         }
         return result;
      }
      
      public function getRewardUrl(buildingId:String) : String
      {
         var result:String = "";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.getRewardName(buildingId));
         if(item)
         {
            result = item.imageRelativeUrl(Animal.STATE_FRONT_IDLE);
         }
         return result;
      }
      
      private function get featureOptionsData() : Object
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(SUPER_BUILDING_COMPLETE_STATUS,m_featureName);
         if(featureData == null)
         {
            featureData = new Object();
         }
         return featureData;
      }
      
      private function setFeatureOptionsData(buildingId:String) : void
      {
         var featureData:Object = this.featureOptionsData;
         if(featureData[buildingId] == null || featureData[buildingId] == false)
         {
            featureData[buildingId] = true;
            FeatureOptionsManager.getInstance().setFeatureOption(SUPER_BUILDING_COMPLETE_STATUS,m_featureName,featureData);
         }
      }
      
      private function isBuildingRewarded(buildingName:String) : Boolean
      {
         var result:Boolean = false;
         var buildingId:String = this.getBuildingIdByName(buildingName);
         if(buildingId)
         {
            result = Boolean(this.featureOptionsData) && this.featureOptionsData[buildingId] != null && this.featureOptionsData[buildingId] == true;
         }
         return result;
      }
      
      public function isBonusRewarded() : Boolean
      {
         return Boolean(this.featureOptionsData) && this.featureOptionsData[BONUS_REWARD_GRANTED] != null && this.featureOptionsData[BONUS_REWARD_GRANTED] == true;
      }
      
      private function areAllBuildingsRewarded() : Boolean
      {
         var buildingId:String = null;
         var buildingName:String = null;
         var result:Boolean = true;
         for(buildingId in this.m_superBuilding)
         {
            buildingName = this.m_superBuilding[buildingId].name;
            if(!this.isBuildingRewarded(buildingName))
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      private function onBuildingCompleteReward(res:Object) : void
      {
         var bonusRewardName:String = null;
         if(this.areAllBuildingsRewarded() && !this.isBonusRewarded())
         {
            this.setFeatureOptionsData(BONUS_REWARD_GRANTED);
            bonusRewardName = this.getRewardName(BONUS_REWARD_ID);
            Global.player.addGift(bonusRewardName);
            this.showBonusUI();
         }
      }
      
      public function buildingConfig() : Array
      {
         var buildingId:String = null;
         if(this.m_buildingDataArray == null)
         {
            this.m_buildingDataArray = new Array();
            for(buildingId in this.m_superBuilding)
            {
               this.m_buildingDataArray.push({
                  "id":buildingId,
                  "name":this.m_superBuilding[buildingId].name,
                  "max":this.m_superBuilding[buildingId].max,
                  "url":this.getRewardUrl(buildingId)
               });
            }
            this.m_buildingDataArray.sortOn("id");
            this.m_buildingDataArray.push({
               "id":BONUS_REWARD_ID,
               "name":"bonusReward",
               "max":0,
               "url":this.getRewardUrl(BONUS_REWARD_ID)
            });
         }
         return this.m_buildingDataArray;
      }
      
      private function setSuperBuildings() : Object
      {
         var expansionData:ExpansionData = null;
         if(this.m_superBuilding == null)
         {
            try
            {
               this.m_superBuilding = (Global.worldManager.worldInit as LimboWorldInit).getBuildingConfig();
            }
            catch(error:Error)
            {
               expansionData = Global.farmGameSettingsManager.getExpansionData(WORLD_TYPE);
               if(expansionData.superBuildings)
               {
                  m_superBuilding = expansionData.superBuildings;
               }
            }
         }
         return this.m_superBuilding;
      }
      
      private function getBuildingIdByName(buildingName:String) : String
      {
         var buildingId:String = null;
         var result:String = null;
         for(buildingId in this.m_superBuilding)
         {
            if(buildingName == this.m_superBuilding[buildingId].name)
            {
               result = buildingId;
               break;
            }
         }
         return result;
      }
      
      public function getCurrentBuildingLevel(buildingId:String) : int
      {
         var buildingName:String = null;
         var craftingSystem:FeatureCraftingSystem = null;
         var npcData:Object = null;
         var objects:Array = null;
         var animalObject:Object = null;
         var level:int = 0;
         buildingName = this.m_superBuilding[buildingId].name;
         switch(buildingId)
         {
            case ELITEHORSES_BUILDING:
               craftingSystem = FeatureCraftingManager.instance.getSystem(buildingName);
               npcData = craftingSystem.npcData;
               for each(animalObject in npcData)
               {
                  if(animalObject.hasOwnProperty("complete"))
                  {
                     if(animalObject["complete"] == true)
                     {
                        level++;
                     }
                  }
               }
               break;
            case HARVESTBUILDABLE_BUILDING:
            case BIGBUILDABLE_BUILDING:
               objects = Global.world.getObjectsByName(buildingName);
               if(objects.length == 1)
               {
                  level = (objects[0] as FeatureBuilding).storageLevel - 1;
               }
         }
         return level;
      }
      
      public function showFeatureUI() : void
      {
         if(Global.worldManager.currentWorldType == WORLD_TYPE && !Global.worldManager.isWorldLoading)
         {
            this.showUI();
         }
      }
      
      private function showUI() : void
      {
         UI.displayPopup(this.m_limboInnovationWindow = new LimboInnovationWindow(this.m_assetPaths[this.MAIN_URL_KEY],m_featureName));
      }
      
      private function showRewardUI(buildingId:String = null, isBonusReward:Boolean = false) : void
      {
         if(this.m_limboInnovationWindow)
         {
            this.m_limboInnovationWindow.close();
         }
         UI.displayPopup(this.m_limboRewardWindow = new LimboInnovationRewardWindow(this.m_assetPaths[this.REWARD_URL_KEY],m_featureName,buildingId,isBonusReward),false);
      }
      
      private function showBonusUI() : void
      {
         if(this.m_limboRewardWindow)
         {
            this.m_limboRewardWindow.close();
            this.m_limboRewardWindow = null;
         }
         UI.displayPopup(this.m_limboBonusRewardWindow = new LimboInBonusRewardWindow(this.m_assetPaths[this.REWARD_URL_KEY],m_featureName,"BR",true),false);
      }
   }
}

