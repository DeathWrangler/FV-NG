package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.HarvestYieldsGroup;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Classes.feed.FarmFeed;
   import Classes.feed.ShareHarvestOwnRewardFeed;
   import Classes.util.UserRewardUtil;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.MoneyTree2017ExpiredWindow;
   import Widgets.Windows.MoneyTreeConfirmationWindow;
   import flash.geom.Point;
   
   public class MoneyTree2017HarvestFManager extends FeatureManager implements IHarvestComponent
   {
      
      private var m_feed:FarmFeed;
      
      private var m_finalHarvest:Boolean = false;
      
      public function MoneyTree2017HarvestFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function canHarvest() : Boolean
      {
         return !this.m_finalHarvest;
      }
      
      public function getTHarvestExtraParams() : Object
      {
         return null;
      }
      
      public function onPreHarvest() : void
      {
      }
      
      public function getHarvestCurrency() : String
      {
         return Currency.COINS;
      }
      
      public function getHarvestAmount() : int
      {
         return 0;
      }
      
      public function get harvestReward() : FarmItem
      {
         return null;
      }
      
      public function onHarvestComplete(result:Object) : void
      {
         var rewardsVector:Vector.<Object> = null;
         var i:int = 0;
         var awardItem:FarmItem = null;
         var dialog:MoneyTree2017ExpiredWindow = null;
         var dialog1:MoneyTreeConfirmationWindow = null;
         var postHarvestData:Object = result.hasOwnProperty("postHarvestData") ? result.postHarvestData : null;
         if(Boolean(postHarvestData) && Boolean(postHarvestData.hasOwnProperty("dialogAsset")) && postHarvestData.hasOwnProperty("rewards"))
         {
            rewardsVector = new Vector.<Object>();
            for(i = 0; i < postHarvestData.rewards.length; i++)
            {
               rewardsVector.push(postHarvestData.rewards[i]);
            }
            UserRewardUtil.grantUserRewards(rewardsVector);
            if(Boolean(postHarvestData.rewardLink) && owner.isShareFeedHandledByHarvester())
            {
               this.m_feed = new ShareHarvestOwnRewardFeed(owner,postHarvestData,true);
            }
            else
            {
               this.m_feed = null;
            }
            if(postHarvestData.rewards[0].value)
            {
               awardItem = Global.farmGameSettingsManager.getFarmItemByCode(postHarvestData.rewards[0].value);
            }
            else
            {
               awardItem = null;
            }
            if(postHarvestData.hasOwnProperty("expiredTextReplacements"))
            {
               dialog = new MoneyTree2017ExpiredWindow("Money_Tree_2020",postHarvestData.dialogAsset,owner.bldgName);
               UI.displayPopup(dialog,false,owner.bldgName + "_harvestPopup");
               FarmStatsManager.count("Prosperytree","expiry",owner.bldgName);
            }
            else
            {
               dialog1 = new MoneyTreeConfirmationWindow("Money_Tree_2020",postHarvestData.dialogAsset,owner.bldgName);
               UI.displayPopup(dialog1,false,owner.bldgName + "_harvestPopup");
               FarmStatsManager.count("Prosperytree","harvest",owner.bldgName);
               if(postHarvestData.hasOwnProperty("final_harvest"))
               {
                  this.m_finalHarvest = postHarvestData.final_harvest;
               }
            }
         }
      }
      
      public function get needItemsForHarvest() : Boolean
      {
         return false;
      }
      
      public function getHarvestWindowLocPrefix() : String
      {
         return "";
      }
      
      public function getHarvestWindowClassName() : String
      {
         return "";
      }
      
      public function getHarvestArrowOffset() : Point
      {
         return new Point(0,0);
      }
      
      public function getHarvestWindowDialogUrl() : String
      {
         return "";
      }
      
      public function getHarvestWindowDialogBgUrl() : String
      {
         return "";
      }
      
      public function getHarvestWindowNpcUrl() : String
      {
         return "";
      }
      
      public function getHarvestYieldMultiplier(harvestYieldsGroup:HarvestYieldsGroup, item:FarmItem) : int
      {
         return 1;
      }
      
      private function onRewardWindowOkay() : void
      {
         if(this.m_feed)
         {
            this.m_feed.publish();
            this.m_feed = null;
         }
      }
      
      public function getHarvestArrow() : Class
      {
         return SimpleHarvestableResource.PINK_ARROW;
      }
      
      public function canAcceptHarvestReward() : Boolean
      {
         return true;
      }
      
      public function displayMessageForUnclaimableHarvestReward() : void
      {
      }
   }
}

