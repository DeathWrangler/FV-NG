package Classes
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.FeatureComponents.AnimalBreedingHarvestFManager;
   import Classes.FeatureDataObjects.AnimalBreedingHarvestReward.IAnimalBreedingReward;
   import Display.TutorialUI;
   import Display.UI;
   import GameMode.GMResourceHarvester;
   import Transactions.TResourceEquipmentAction;
   import Widgets.Windows.Equipment.ResourceHarvesterRewardWindow;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AnimalPenHarvester extends ResourceHarvester
   {
      
      private static var m_coinYield:int;
      
      private static var m_rewards:Object;
      
      private static var m_yields:HarvestYieldsGroup;
      
      private static var m_rewardWindowTimer:Timer;
      
      private static const TUTORIAL_ASSET_PATH_PREFIX:String = "assets/dialogs/FV_Support/FV_AnimalHarvester/AnimalHarvester";
      
      private static const PATTERN_SELECTION_DIALOG_ASSET_PATH:String = "assets/dialogs/FV_AnimalPenHarvester2013_pattern.swf";
      
      private static const REWARD_DIALOG_ASSET_PATH:String = "assets/dialogs/FV_AnimalHarvester_reward.swf";
      
      public function AnimalPenHarvester(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
      }
      
      override public function showTutorial(closeCallback:Function = null) : void
      {
         TutorialUI.displayBundleTutorialWindow("Dialogs","AnimalPenHarvester",TUTORIAL_ASSET_PATH_PREFIX,true,closeCallback);
      }
      
      override public function performEquipmentAction(source:String = null) : void
      {
         super.performEquipmentAction(source);
         Global.world.addGameMode(new GMResourceHarvester(EmbeddedArt.cursor_animalPenharvester_ground,ClickTrackingConstants.CLICK_TYPE_ANIMAL_PEN_HARVESTER,this));
      }
      
      override public function showSelectPatternWindow(source:String = null, assetPath:String = "assets/dialogs/FV_AnimalPenHarvester2013_pattern.swf") : void
      {
         super.showSelectPatternWindow(source,assetPath);
      }
      
      override protected function displayRewardWindow(assetPath:String = "assets/dialogs/FV_AnimalHarvester_reward.swf") : void
      {
         var window:ResourceHarvesterRewardWindow = new ResourceHarvesterRewardWindow(m_coinYield,m_rewards,m_yields,assetPath);
         UI.displayPopup(window,true);
      }
      
      override public function onMultiActionComplete(transactionData:Object, result:Object) : void
      {
         var rewardHash:Object = null;
         var totalCoinYield:int = 0;
         var harvestYieldsGroup:HarvestYieldsGroup = null;
         var i:int = 0;
         var itemCode:String = null;
         var resourceData:Object = null;
         var resourceResult:Object = null;
         var resource:HarvestableStorageBuilding = null;
         var resourceRewards:Array = null;
         var rewards:Array = null;
         var postHarvestReward:IAnimalBreedingReward = null;
         var reward:Object = null;
         var resourceReward:Object = null;
         var resourceBundle:Array = transactionData.resourceBundle as Array;
         if(Boolean(resourceBundle) && resourceBundle.length > 0)
         {
            rewardHash = {};
            totalCoinYield = 0;
            for(harvestYieldsGroup = new HarvestYieldsGroup(); i < resourceBundle.length; )
            {
               resourceData = resourceBundle[i];
               resourceResult = result[i].data;
               resourceResult.multiAction = true;
               resource = Global.world.getObjectById(resourceData.id) as HarvestableStorageBuilding;
               if(resource)
               {
                  resource.onHarvestComplete(resourceResult);
                  resourceResult.coinYield = resource.getHarvestAmount();
                  rewards = new Array();
                  for each(postHarvestReward in ((resource as FeatureBuilding).harvester as AnimalBreedingHarvestFManager).getPostHarvestData())
                  {
                     if(postHarvestReward.rewardLink != null && postHarvestReward.rewardName != "coins")
                     {
                        reward = new Object();
                        if(postHarvestReward.rewardItem)
                        {
                           reward.itemCode = postHarvestReward.rewardItem.code;
                        }
                        else
                        {
                           reward.imageUrl = postHarvestReward.imageUrl;
                           reward.friendlyTitle = postHarvestReward.feedBundleData.item;
                        }
                        reward.itemCount = 1;
                        reward.rewardLink = postHarvestReward.rewardLink;
                        reward.feedBundleData = postHarvestReward.feedBundleData;
                        reward.bundleID = postHarvestReward.feedType;
                        rewards.push(reward);
                     }
                  }
                  if(rewards.length > 0)
                  {
                     resourceResult.reward = rewards;
                  }
               }
               totalCoinYield += resourceResult.coinYield;
               if(resource)
               {
                  harvestYieldsGroup.merge(resource.harvestYieldsGroup);
               }
               resourceRewards = resourceResult.reward;
               if(resourceRewards)
               {
                  for each(resourceReward in resourceRewards)
                  {
                     if(!rewardHash[resourceReward.itemCode])
                     {
                        rewardHash[resourceReward.itemCode] = [];
                     }
                     rewardHash[resourceReward.itemCode].push(resourceReward);
                  }
               }
               i++;
            }
            m_coinYield += totalCoinYield;
            if(!m_rewards)
            {
               m_rewards = {};
            }
            for(itemCode in rewardHash)
            {
               if(m_rewards.hasOwnProperty(itemCode))
               {
                  m_rewards[itemCode] = (m_rewards[itemCode] as Array).concat(rewardHash[itemCode]);
               }
               else
               {
                  m_rewards[itemCode] = rewardHash[itemCode];
               }
            }
            if(m_yields)
            {
               m_yields.merge(harvestYieldsGroup);
            }
            else
            {
               m_yields = harvestYieldsGroup;
            }
            if(TResourceEquipmentAction.getNumPending(this.getItemName()) == 0)
            {
               if(!m_rewardWindowTimer)
               {
                  m_rewardWindowTimer = new Timer(REWARD_WINDOW_TIMER_DELAY,1);
                  m_rewardWindowTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onRewardWindowTimerComplete);
               }
               else
               {
                  m_rewardWindowTimer.reset();
               }
               m_rewardWindowTimer.start();
            }
         }
      }
      
      override public function onActionTransactionAdded() : void
      {
         if(m_rewardWindowTimer)
         {
            m_rewardWindowTimer.stop();
         }
      }
      
      protected function onRewardWindowTimerComplete(event:TimerEvent) : void
      {
         if(TResourceEquipmentAction.getNumPending(this.getItemName()) == 0)
         {
            if(Boolean(m_coinYield > 0) || Boolean(m_rewards) || Boolean(m_yields))
            {
               this.displayRewardWindow();
               m_coinYield = 0;
               m_rewards = null;
               m_yields = null;
            }
            m_rewardWindowTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onRewardWindowTimerComplete);
            m_rewardWindowTimer = null;
         }
         else
         {
            m_rewardWindowTimer.reset();
            m_rewardWindowTimer.start();
         }
      }
   }
}

