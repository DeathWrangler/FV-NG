package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Windows.Amex.AmexTreeStatusWindow;
   import Widgets.Windows.GenericRewardWindow;
   import flash.events.Event;
   
   public class AmexHarvestFManager extends RewardHarvestFManager
   {
      
      public static const AMEX_PHASE_SPEND:int = 4;
      
      public static const HARVEST_PERIOD_FLAG:String = "amextree_harvestPeriodStart";
      
      public static const MAX_HARVEST_TIME:int = 1296000;
      
      private var m_rewardWindow:GenericRewardWindow;
      
      private var m_treeData:Object;
      
      public function AmexHarvestFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function canHarvest() : Boolean
      {
         var harvestPeriodStart:Number = NaN;
         var currentTime:Number = NaN;
         var expirationTime:Number = NaN;
         var charges:int = 0;
         var result:Boolean = false;
         if(this.m_treeData == null)
         {
            this.m_treeData = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FEATURE_AMEX_TREE,"tree_data");
         }
         if(owner.storageLevel < AMEX_PHASE_SPEND)
         {
            harvestPeriodStart = Global.player.getFeatureLastShown(HARVEST_PERIOD_FLAG);
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            expirationTime = harvestPeriodStart + AmexHarvestFManager.MAX_HARVEST_TIME;
            if(harvestPeriodStart > 0)
            {
               result = currentTime < expirationTime && Boolean(super.canHarvest());
            }
            else
            {
               result = super.canHarvest();
            }
         }
         else if(this.m_treeData != null && this.m_treeData.hasOwnProperty("charges"))
         {
            charges = int(this.m_treeData.charges);
            if(charges > 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      override public function onPreHarvest() : void
      {
         super.onPreHarvest();
         var message:String = ZLocUtils.t("Dialogs",m_owner.getItemName() + "_floating_text");
         if(message != "")
         {
            m_owner.displayStatus(message);
         }
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var rewardsVector:Vector.<Object> = null;
         var i:int = 0;
         var rewardObject:Object = null;
         var postHarvestData:Object = result.hasOwnProperty("postHarvestData") ? result.postHarvestData : null;
         if(postHarvestData != null && postHarvestData.hasOwnProperty("dialogAsset") && postHarvestData.hasOwnProperty("rewards"))
         {
            rewardsVector = new Vector.<Object>();
            for(i = 0; i < postHarvestData.rewards.length; i++)
            {
               rewardObject = postHarvestData.rewards[i];
               if(rewardObject.hasOwnProperty("type"))
               {
                  rewardsVector.push(rewardObject);
               }
               else if(rewardObject.length > 0)
               {
                  rewardsVector.push(rewardObject[0]);
               }
            }
            UserRewardUtil.grantUserRewards(rewardsVector);
            FarmStatsManager.count("serve_tree","harvest_drip_dialog","view");
            this.m_rewardWindow = new GenericRewardWindow(postHarvestData.dialogAsset,this.openAmexTreeMainWindow,postHarvestData.rewards,postHarvestData.textReplacements,postHarvestData.movieClips);
            UI.displayPopup(this.m_rewardWindow,false,owner.bldgName + "_harvestPopup");
         }
      }
      
      private function openAmexTreeMainWindow(event:Event = null) : void
      {
         FarmStatsManager.count("serve_tree","harvest_drip_dialog","view");
         if(this.m_rewardWindow != null)
         {
            this.m_rewardWindow.close();
         }
         var amexMainWindow:AmexTreeStatusWindow = new AmexTreeStatusWindow();
         UI.displayPopup(amexMainWindow);
      }
   }
}

