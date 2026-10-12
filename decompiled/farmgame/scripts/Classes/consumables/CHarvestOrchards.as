package Classes.consumables
{
   import Classes.FeatureDataObjects.AnimalBreedingHarvestReward.IAnimalBreedingReward;
   import Classes.FeatureDataObjects.AnimalBreedingHarvestReward.OrchardBuildingReward;
   import Classes.HarvestYieldsGroup;
   import Classes.HarvestableResource;
   import Classes.HarvestableStorageBuilding;
   import Classes.OrchardBuilding;
   import Classes.OrchardFeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Transactions.TCancelFriendReward;
   
   public class CHarvestOrchards extends CHarvestBuildings
   {
      
      private var m_response:Object;
      
      private var m_savedData:Array;
      
      private var m_savedDataCounter:int;
      
      public function CHarvestOrchards(itemName:String)
      {
         super(itemName);
      }
      
      override protected function getHarvestables() : Array
      {
         var harvestBuilding:HarvestableStorageBuilding = null;
         var buildingItem:FarmItem = null;
         var buildingName:String = null;
         var item:XML = null;
         var itemType:String = null;
         var itemName:String = null;
         var results:Array = new Array();
         var orchardBuildings:Array = Global.world.getObjectsByClass(OrchardBuilding);
         var orchardFBuildings:Array = Global.world.getObjectsByClass(OrchardFeatureBuilding);
         orchardBuildings = orchardBuildings.concat(orchardFBuildings);
         var blackListVar:String = Global.flashHotParams["FARMWORKER_BLACKLIST"] as String;
         var blackList:Array = blackListVar.split(",");
         for each(harvestBuilding in orchardBuildings)
         {
            if(harvestBuilding is OrchardBuilding || harvestBuilding is OrchardFeatureBuilding)
            {
               if(Boolean(harvestBuilding) && Boolean(harvestBuilding.getItem()))
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     buildingItem = harvestBuilding.getItem();
                     if(buildingItem.getStringFromDataSource("type") == "building")
                     {
                        buildingName = buildingItem.getStringFromDataSource("name");
                        if(Boolean(buildingName) && blackList.indexOf(buildingName) == -1)
                        {
                           results.push(harvestBuilding);
                        }
                     }
                  }
                  else
                  {
                     item = harvestBuilding.getItem().xml;
                     if(item.attribute("type"))
                     {
                        itemType = item.attribute("type").toString();
                        if(itemType == "building")
                        {
                           if(item.attribute("name"))
                           {
                              itemName = item.attribute("name").toString();
                              if(blackList.indexOf(itemName) == -1)
                              {
                                 results.push(harvestBuilding);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         return results;
      }
      
      override public function initialize(data:Object) : void
      {
         this.m_response = data;
      }
      
      override public function onUse() : void
      {
         var worldCurrency:String = null;
         var harvestable:HarvestableStorageBuilding = null;
         var avatarStatus:String = null;
         var result:Object = null;
         var contentCount:Number = NaN;
         var key:String = null;
         var itemObject:FarmItem = null;
         var count:int = 0;
         var multiplier:Number = NaN;
         var totalCoinYield:uint = 0;
         var totalMasteryYield:int = 0;
         var totalXPYield:int = 0;
         var aoeCoinMult:Number = 0;
         var harvestYieldGroup:HarvestYieldsGroup = new HarvestYieldsGroup();
         var harvestCoins:int = 0;
         var masteryYield:int = 0;
         this.addRewardsToGiftBox();
         this.m_savedData = new Array();
         this.m_savedDataCounter = 0;
         var objectToBeHarvested:Array = getObjectsToBeHarvested();
         for each(harvestable in objectToBeHarvested)
         {
            if(Boolean(harvestable) && (harvestable is OrchardBuilding || harvestable is OrchardFeatureBuilding))
            {
               harvestable.harvest(HarvestableResource.ENERGY_SOURCE_AVATAR,0,true,false);
               result = new Object();
               contentCount = 0;
               for(key in harvestable.contents)
               {
                  if(harvestable.contents[key] > 0)
                  {
                     contentCount += harvestable.contents[key];
                  }
               }
               if(contentCount > 0 || harvestable.getHarvestAmount() > 0)
               {
                  harvestCoins = Math.round(harvestable.getHarvestAmount() * harvestable.coinBonusMultiplier);
                  masteryYield = Math.round(harvestable.getMasteryYield() * harvestable.masteryBonusMultiplier);
                  worldCurrency = harvestable.getHarvestCurrency();
                  Global.player.updateWorldCurrency(worldCurrency,int(harvestCoins),true);
                  harvestCoins *= Global.player.getWorldCurrencyMultiplier(worldCurrency);
                  for(key in harvestable.contents)
                  {
                     if(harvestable.contents[key] > 0)
                     {
                        itemObject = Global.farmGameSettingsManager.getFarmItemByCode(key);
                        if(itemObject is HarvestableItem)
                        {
                           count = int(harvestable.contents[key]);
                           multiplier = 1;
                           if(Boolean(harvestable) && Boolean(harvestable.getBounsMultiplier().harvestYield))
                           {
                              multiplier = Number(harvestable.getBounsMultiplier().harvestYield);
                           }
                           harvestYieldGroup.applyHarvestYieldsForItem(itemObject as HarvestableItem,count,multiplier);
                        }
                     }
                  }
               }
               this.generateRewardToasters(harvestable,harvestCoins);
               if(harvestCoins > 0)
               {
                  totalCoinYield += harvestCoins;
               }
               if(harvestable.xpBonusCumulative > 0)
               {
                  totalXPYield += harvestable.xpBonusCumulative;
               }
               if(masteryYield > 0)
               {
                  totalMasteryYield += masteryYield;
               }
            }
         }
         Global.player.xp += totalXPYield;
         avatarStatus = harvestYieldGroup.getDooberStatus();
         if(totalMasteryYield)
         {
            avatarStatus += ZLocUtils.t("FarmGame","Status_HarvestPlotMastery",{
               "coinNum":totalCoinYield,
               "masteryNum":totalMasteryYield
            });
         }
         else
         {
            avatarStatus += ZLocUtils.t("FarmGame","Status_HarvestPlot",{"coinNum":totalCoinYield});
         }
         if(totalXPYield > 0)
         {
            avatarStatus += ZLocUtils.t("FarmGame","Status_HarvestPlotXP",{"xpNum":totalXPYield});
         }
         Global.player.avatar.displayStatus(avatarStatus);
         displayHarvestResults(totalCoinYield,totalMasteryYield);
      }
      
      private function addRewardsToGiftBox() : void
      {
         var rewardArray:Array = null;
         var iReward:Number = NaN;
         var rewardGift:String = null;
         if(Boolean(this.m_response != null && this.m_response.hasOwnProperty("rewards") && this.m_response.rewards != null) && Boolean(this.m_response.rewards.hasOwnProperty("items")) && this.m_response.rewards.items is Array)
         {
            rewardArray = this.m_response.rewards.items as Array;
            for(iReward = 0; iReward < rewardArray.length; iReward++)
            {
               if(rewardArray[iReward] is String)
               {
                  rewardGift = rewardArray[iReward];
                  Global.player.addGift(rewardGift);
               }
            }
         }
      }
      
      private function generateRewardToasters(building:HarvestableStorageBuilding, buildingYield:int = 0) : void
      {
         var rewardArray:Array = null;
         var iReward:Number = NaN;
         var reward:IAnimalBreedingReward = null;
         var buildingRewardObject:Object = null;
         var indexToRemove:int = -1;
         var ignoreReward:Boolean = false;
         if(Boolean(this.m_response != null && this.m_response.hasOwnProperty("rewards") && this.m_response.rewards.hasOwnProperty("rewards")) && Boolean(this.m_response.rewards.rewards is Array) && building != null)
         {
            rewardArray = this.m_response.rewards.rewards as Array;
            for(iReward = 0; iReward < rewardArray.length; iReward++)
            {
               if(rewardArray[iReward] != null && Boolean(rewardArray[iReward].hasOwnProperty("src")))
               {
                  if(building.getItemName() == rewardArray[iReward].src)
                  {
                     buildingRewardObject = rewardArray[iReward];
                     indexToRemove = iReward;
                     break;
                  }
               }
            }
            if(buildingRewardObject != null)
            {
               if(indexToRemove != -1)
               {
                  (this.m_response.rewards.rewards as Array).slice(indexToRemove,1);
               }
               ignoreReward = buildingRewardObject.hasOwnProperty("suppressBabyFoundPopup") ? Boolean(buildingRewardObject.suppressBabyFoundPopup) : false;
               if(!ignoreReward)
               {
                  if(building is OrchardBuilding)
                  {
                     reward = new OrchardBuildingReward(buildingRewardObject,building as OrchardBuilding,buildingYield," ");
                  }
               }
               if(reward != null)
               {
                  this.showFeatureBuildingToaster(reward);
                  this.m_savedData.push(reward);
               }
            }
         }
      }
      
      private function showFeatureBuildingToaster(reward:IAnimalBreedingReward) : void
      {
         var dialogText:String = reward.dialogText;
         var imageUrl:String = reward.imageUrl;
         var dialogType:int = reward.rewardLink ? GenericPopup.TYPE_SHARE : GenericPopup.TYPE_OK;
         UI.handlePopupDisplayForRetention(dialogText,dialogType,this.onRewardDialogClosed,imageUrl,"",{"dontCloseToaster":true},true);
      }
      
      private function onRewardDialogClosed(event:GenericPopupEvent) : void
      {
         var animalBreedingReward:IAnimalBreedingReward = null;
         var reward:IAnimalBreedingReward = null;
         if(this.m_savedData != null && this.m_savedData.length > 0 && this.m_savedDataCounter < this.m_savedData.length)
         {
            if(event.button == GenericPopup.ACCEPT)
            {
               if(this.m_savedData[this.m_savedDataCounter] is IAnimalBreedingReward)
               {
                  animalBreedingReward = this.m_savedData[this.m_savedDataCounter];
                  Global.farmSocialNetwork.publishFeedStory(animalBreedingReward.feedType,animalBreedingReward.feedBundleData,[],false);
               }
            }
            else
            {
               reward = this.m_savedData[this.m_savedDataCounter];
               if(this.m_savedData[this.m_savedDataCounter] is IAnimalBreedingReward)
               {
                  TransactionManager.addTransaction(new TCancelFriendReward([reward.rewardLink]));
               }
            }
            ++this.m_savedDataCounter;
         }
      }
   }
}

