package Classes
{
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TransactionWithCallBack;
   import Widgets.Windows.RuntimeDrivenBuildingRewardWindow;
   
   public class RuntimeDrivenLootableFixedFeatureBuilding extends LootableFixedFeatureBuilding
   {
      
      private static const RUNTIME_POSTFIX:String = "_EXPANSION_LEVEL";
      
      public static const RUNTIME_BUILDING:String = "runtimeBuilding";
      
      private static const EXPANSION_LEVEL:String = "expansionLevel";
      
      public function RuntimeDrivenLootableFixedFeatureBuilding(itemName:String = null)
      {
         super(itemName);
      }
      
      public static function getRuntimeBuildingConfig(buildingName:String) : XML
      {
         var runtimeBuildingGroupConfigs:XMLList = null;
         var j:int = 0;
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML("runtimeBuilding");
         var runtimeBuildingConfig:XML = null;
         if(feature)
         {
            runtimeBuildingGroupConfigs = feature["runtimeBuildings"].runtimeBuilding;
            if(runtimeBuildingGroupConfigs)
            {
               for(j = 0; j < runtimeBuildingGroupConfigs.length(); j++)
               {
                  if(runtimeBuildingGroupConfigs[j].@name == buildingName)
                  {
                     runtimeBuildingConfig = runtimeBuildingGroupConfigs[j];
                     break;
                  }
               }
            }
         }
         return runtimeBuildingConfig;
      }
      
      public static function generateRuntimeKey(itemName:String) : String
      {
         var runtimeKey:String = null;
         if(itemName)
         {
            runtimeKey = itemName.toUpperCase() + RUNTIME_POSTFIX;
         }
         return runtimeKey;
      }
      
      public function getExpansionLevelFromFeatureOptions() : int
      {
         var exchangeObject:Object = null;
         var expansionLevel:int = 0;
         var runtimeBuildingFeatureOptions:Object = FeatureOptionsManager.getInstance().getFeatureOption(RUNTIME_BUILDING,RUNTIME_BUILDING);
         if(runtimeBuildingFeatureOptions != null && runtimeBuildingFeatureOptions[featureName] != null)
         {
            exchangeObject = runtimeBuildingFeatureOptions[featureName];
            if(exchangeObject.hasOwnProperty(EXPANSION_LEVEL))
            {
               expansionLevel = int(exchangeObject[EXPANSION_LEVEL]);
            }
         }
         return expansionLevel;
      }
      
      override public function onClick() : void
      {
         var itemName:String = this.getItem().name;
         m_dialogConfig = Global.farmGameSettingsManager.getBuildingDialogConfig(itemName);
         this.showLookInsideDialogFromConfig(m_dialogConfig);
         StatsManager.sample(100,RUNTIME_BUILDING,itemName,"click");
      }
      
      public function getExpansionLevelFromRuntime() : int
      {
         var runtimeLevel:int = 0;
         var runtimeKey:String = generateRuntimeKey(featureName);
         if(Global.flashHotParams.hasOwnProperty(runtimeKey))
         {
            runtimeLevel = int(Global.flashHotParams[runtimeKey]);
         }
         return runtimeLevel;
      }
      
      public function conditionallyUpgradeBuilding() : void
      {
         var expansionLevel:int = this.getExpansionLevelFromFeatureOptions();
         var runtimeLevel:int = this.getExpansionLevelFromRuntime();
         if(runtimeLevel > expansionLevel)
         {
            this.upgradeAndGiveRewards(this,expansionLevel,runtimeLevel);
         }
      }
      
      private function upgradeAndGiveRewards(building:RuntimeDrivenLootableFixedFeatureBuilding, expansionLevel:int, runtimeLevel:int) : void
      {
         var runtimeBuildingConfig:XML = null;
         var rewardData:Array = null;
         var finalRewardItemName:String = null;
         var expansionLevels:XMLList = null;
         var runtimeBuildingFeatureOptions:Object = null;
         var itemsLength:int = 0;
         var i:int = 0;
         var rewardItem:FarmItem = null;
         if(building)
         {
            runtimeBuildingConfig = getRuntimeBuildingConfig(building.featureName);
            rewardData = [];
            if(runtimeBuildingConfig)
            {
               if(Global.experimentManager.getExperimentVariant(runtimeBuildingConfig.@experiment))
               {
                  expansionLevels = runtimeBuildingConfig.expansionConfig.expansionLevel;
                  if(expansionLevels)
                  {
                     itemsLength = expansionLevels.length();
                     for(i = 0; i < itemsLength; i++)
                     {
                        rewardData[expansionLevels[i].@level] = {
                           "itemName":expansionLevels[i].@rewardItemName,
                           "milestone1":expansionLevels[i].@milestone1,
                           "milestone2":expansionLevels[i].@milestone2
                        };
                        if(Boolean(expansionLevels[i].@finalStage) && expansionLevels[i].@finalStage.toString() === "true")
                        {
                           finalRewardItemName = expansionLevels[i].@rewardItemName;
                        }
                     }
                  }
                  for(expansionLevel++; expansionLevel <= runtimeLevel; )
                  {
                     if(rewardData[expansionLevel])
                     {
                        Global.player.addGift(rewardData[expansionLevel].itemName);
                        rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardData[expansionLevel].itemName);
                        if(Boolean(rewardItem) && rewardItem.name != finalRewardItemName)
                        {
                           UI.displayPopup(new RuntimeDrivenBuildingRewardWindow(building,rewardData[expansionLevel]),true);
                        }
                     }
                     expansionLevel++;
                  }
                  runtimeBuildingFeatureOptions = FeatureOptionsManager.getInstance().getFeatureOption(RUNTIME_BUILDING,RUNTIME_BUILDING);
                  if(runtimeBuildingFeatureOptions == null)
                  {
                     runtimeBuildingFeatureOptions = new Object();
                  }
                  runtimeBuildingFeatureOptions[building.featureName] = {"expansionLevel":runtimeLevel};
                  FeatureOptionsManager.getInstance().setFeatureOption(RUNTIME_BUILDING,RUNTIME_BUILDING,runtimeBuildingFeatureOptions);
                  TransactionManager.addTransaction(new TransactionWithCallBack("RuntimeDrivenFeatureBuildingService.upgradeAndGiveRewards",this.onUpgradeAndGiveReward,building.featureName),true);
               }
            }
         }
      }
      
      public function onUpgradeAndGiveReward(results:Object) : void
      {
         var rewardObject:Object = null;
         if(Boolean(results.finalStage) && Boolean(results.finalStage === true) && Boolean(results.finalPrize) && Boolean(results.milestone1) && Boolean(results.milestone2))
         {
            rewardObject = {
               "itemName":results.finalPrize,
               "milestone1":results.milestone1,
               "milestone2":results.milestone2
            };
            UI.displayPopup(new RuntimeDrivenBuildingRewardWindow(this,rewardObject,true));
         }
      }
   }
}

