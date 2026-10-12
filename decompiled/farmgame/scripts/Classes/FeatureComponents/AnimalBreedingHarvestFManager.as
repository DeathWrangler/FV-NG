package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.AnimalBreedingHarvestReward.BabyFoundReward;
   import Classes.FeatureDataObjects.AnimalBreedingHarvestReward.BabyNotFoundReward;
   import Classes.FeatureDataObjects.AnimalBreedingHarvestReward.IAnimalBreedingReward;
   import Classes.FeatureDataObjects.AnimalBreedingHarvestReward.ShareBabyBundleFoundReward;
   import Classes.ZItem.BuildingItem;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.ItemMembershipManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Windows.BuildingSurfaceWindow;
   import com.adobe.serialization.json.JSON;
   
   public class AnimalBreedingHarvestFManager extends HarvestFManager implements IHarvestComponent
   {
      
      private static const FEATUREFREQUENCY_BREEDINGPEND_ONHARVEST_FEEDTHROTTLE:String = "AnimalBreedingHarvestFManager_onHarvestComplete";
      
      private var m_postHarvestRewardInfo:IAnimalBreedingReward;
      
      private var m_postHarvestRewards:Array;
      
      public function AnimalBreedingHarvestFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function getPostHarvestData() : Array
      {
         var postHarvestData:Array = new Array();
         if(this.m_postHarvestRewards.length > 0)
         {
            postHarvestData = this.m_postHarvestRewards;
         }
         else if(this.m_postHarvestRewardInfo)
         {
            postHarvestData.push(this.m_postHarvestRewardInfo);
         }
         return postHarvestData;
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var showedBuildingSurfaceWindow:Boolean;
         var postHarvestData:Object = null;
         var obj:Object = null;
         var i:int = 0;
         var contextualBuildings:Array = null;
         var contextualBuildingsVar:String = null;
         var contextualListLenght:int = 0;
         var index:int = 0;
         var building:BuildingItem = null;
         var babyFound:Boolean = true;
         this.m_postHarvestRewards = new Array();
         this.m_postHarvestRewardInfo = null;
         if(result)
         {
            postHarvestData = result.postHarvestData;
         }
         if(postHarvestData)
         {
            if(Boolean(postHarvestData.rewardItem) && Boolean(postHarvestData.rewardLink) && Boolean(postHarvestData.babyFound))
            {
               if(postHarvestData.rewardItem as Array != null)
               {
                  obj = new Object();
                  for(i = 0; i < (postHarvestData.rewardItem as Array).length; i++)
                  {
                     obj["rewardItem"] = postHarvestData.rewardItem[i];
                     obj["rewardLink"] = postHarvestData.rewardLink[i];
                     this.m_postHarvestRewards.push(new BabyFoundReward(obj,m_owner,getHarvestAmount()));
                  }
                  this.m_postHarvestRewardInfo = this.m_postHarvestRewards[0];
               }
               else
               {
                  this.m_postHarvestRewardInfo = new BabyFoundReward(postHarvestData,m_owner,getHarvestAmount());
               }
            }
            else if(postHarvestData.shareBabyBundleIndex != null && Boolean(postHarvestData.lootTableName))
            {
               this.m_postHarvestRewardInfo = new ShareBabyBundleFoundReward(postHarvestData,m_owner);
            }
            else if(postHarvestData.suppressBabyFoundPopup)
            {
               this.m_postHarvestRewardInfo = null;
               babyFound = false;
            }
            else
            {
               this.m_postHarvestRewardInfo = new BabyNotFoundReward(postHarvestData,m_owner,getHarvestAmount(),m_owner.harvestYieldsGroup);
               babyFound = false;
            }
            if(this.m_postHarvestRewardInfo != null)
            {
               if(this.m_postHarvestRewardInfo.giftBoxReward)
               {
                  Global.player.addGift(this.m_postHarvestRewardInfo.giftBoxReward);
                  if(this.m_postHarvestRewardInfo.forcePlaceGift && !result.multiAction)
                  {
                     Global.world.enterForcePlaceMode(this.m_postHarvestRewardInfo.giftBoxReward,false,-1);
                  }
               }
               if(!result.multiAction)
               {
                  this.showRewardDialog(babyFound);
               }
            }
         }
         showedBuildingSurfaceWindow = false;
         if(BuildingSurfaceWindow.isOnContextualPlacementPromptExperiement())
         {
            contextualBuildingsVar = Global.flashHotParams["ANIMALPEN_CONTEXTUAL_BUILDINGS"] as String;
            try
            {
               contextualBuildings = com.adobe.serialization.json.JSON.decode(contextualBuildingsVar) as Array;
            }
            catch(error:Error)
            {
               contextualBuildings = [];
            }
            contextualListLenght = int(contextualBuildings.length);
            for(index = 0; index < contextualListLenght; index++)
            {
               building = Global.farmGameSettingsManager.getFarmItemByName(contextualBuildings[index]) as BuildingItem;
               if(building != null)
               {
                  if(BuildingSurfaceWindow.checkShouldDisplayPlacementPrompt(building))
                  {
                     UI.displayPopup(new BuildingSurfaceWindow(building,null,false,null,null,null,false,true));
                     showedBuildingSurfaceWindow = true;
                     break;
                  }
               }
            }
         }
         if(!showedBuildingSurfaceWindow)
         {
            ItemMembershipManager.conditionallyOnboardFromBuilding(m_owner);
         }
      }
      
      private function showRewardDialog(babyFound:Boolean) : void
      {
         var tmpPopup:GenericIconPopup = null;
         var dialogText:String = this.m_postHarvestRewardInfo.dialogText;
         var imageUrl:String = this.m_postHarvestRewardInfo.imageUrl;
         var dialogType:int = this.m_postHarvestRewardInfo.rewardLink ? GenericPopup.TYPE_SHARE : GenericPopup.TYPE_OK;
         if(!babyFound && UI.shouldBlockPopupForRetention())
         {
            UI.handlePopupDisplayForRetention(dialogText,dialogType,this.onRewardDialogClosed,imageUrl,"",{
               "addToQueue":false,
               "popupName":m_owner.bldgName + "_BabyFoundDialog",
               "checkDuplicates":true
            });
         }
         else
         {
            tmpPopup = new GenericIconPopup(dialogText,dialogType,this.onRewardDialogClosed,imageUrl);
            UI.displayPopup(tmpPopup,false,m_owner.bldgName + "_BabyFoundDialog",true);
         }
      }
      
      private function onRewardDialogClosed(event:GenericPopupEvent) : void
      {
         var rewardName:String = null;
         if(this.m_postHarvestRewardInfo.rewardLink)
         {
            rewardName = this.m_postHarvestRewardInfo.rewardName;
            if(event.button == GenericPopup.ACCEPT)
            {
               FarmStatsManager.count(m_owner.getItemName(),"harvest",rewardName,"clickShare");
               FarmStatsManager.count(m_owner.bldgName,"share",rewardName);
               Global.farmSocialNetwork.publishFeedStory(this.m_postHarvestRewardInfo.feedType,this.m_postHarvestRewardInfo.feedBundleData,[],false);
            }
            else
            {
               TransactionManager.addTransaction(new TCancelFriendReward([this.m_postHarvestRewardInfo.rewardLink]));
               FarmStatsManager.count(m_owner.getItemName(),"harvest",this.m_postHarvestRewardInfo.rewardName,"clickCancel");
            }
         }
         this.showExtraRewardDialogs();
      }
      
      private function showExtraRewardDialogs() : void
      {
         var babyReward:IAnimalBreedingReward = null;
         if(this.m_postHarvestRewards != null && this.m_postHarvestRewards.length > 0)
         {
            this.m_postHarvestRewards.splice(0,1);
            if(this.m_postHarvestRewards.length > 0)
            {
               this.m_postHarvestRewardInfo = this.m_postHarvestRewards[0];
               babyReward = this.m_postHarvestRewardInfo;
               if(babyReward.giftBoxReward)
               {
                  Global.player.addGift(babyReward.giftBoxReward);
               }
               this.showRewardDialog(this.m_postHarvestRewardInfo is BabyFoundReward);
            }
         }
      }
   }
}

