package Widgets.Windows.Clubs
{
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.Clubs.DataObjects.FarmClub;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.FarmClubUtility;
   import Transactions.TRefreshBalance;
   import Transactions.TRefreshGifts;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   
   public class FarmClubReportWindow extends FarmWindow
   {
      
      private static const ASSET_URL:String = "assets/dialogs/fv_clubs_recapture.swf";
      
      private var m_isPromoted:Boolean = false;
      
      private var m_isChampion:Boolean = false;
      
      private var m_aloneAtTop:Boolean = false;
      
      private var m_clubLeaderboardEntry:Object = null;
      
      private var m_userTotal:int = 0;
      
      private var m_userRank:int = 0;
      
      private var m_userMultiplier:int = 0;
      
      private var m_rewards:Array = null;
      
      private var m_isProbation:Boolean = false;
      
      private var m_nextTier:int = 1;
      
      private var m_farmClub:FarmClub = null;
      
      public function FarmClubReportWindow(reportObject:Object, farmClubData:FarmClubDataObject)
      {
         super(ASSET_URL);
         this.m_isPromoted = reportObject.promoted;
         this.m_isChampion = reportObject.isChampion;
         this.m_aloneAtTop = reportObject.hasOwnProperty("aloneAtTop") ? Boolean(reportObject.aloneAtTop) : false;
         this.m_clubLeaderboardEntry = reportObject.clubScore;
         this.m_userTotal = reportObject.score;
         this.m_userRank = reportObject.rank;
         this.m_userMultiplier = 1;
         this.m_rewards = reportObject.hasOwnProperty("rewards") ? reportObject.rewards : null;
         this.m_farmClub = farmClubData.farmClub;
         this.m_isProbation = reportObject.isProbation;
         this.m_nextTier = reportObject.nextTier;
      }
      
      override protected function postLoadComplete() : void
      {
         var reward:Object = null;
         var previousTierItem:FarmItem = null;
         var plantFrame:ZwFrame = null;
         var plantIcon:FarmIcon = null;
         var cropRewardFrame:ZwFrame = null;
         var icon:FarmIcon = null;
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.clubName_tf,this.m_farmClub.clubName));
         var winText:String = "";
         var completeStatus:String = "";
         var unlockStatus:String = "";
         if(this.m_isPromoted)
         {
            winText = ZLocUtils.t("Dialogs","Success");
            completeStatus = ZLocUtils.t("FarmClub","completeStatus_success");
            if(this.m_isProbation)
            {
               unlockStatus = ZLocUtils.t("FarmClub","unlock_fail");
            }
            else
            {
               unlockStatus = ZLocUtils.t("FarmClub","unlock_success");
            }
         }
         else
         {
            if(this.m_aloneAtTop)
            {
               winText = ZLocUtils.t("Dialogs","Success");
               addWidget(new ZwTextField(m_window.numberOneClub_tf,ZLocUtils.t("FarmClub","alone_title")));
            }
            else
            {
               winText = ZLocUtils.t("FarmClub","fail_title");
            }
            completeStatus = ZLocUtils.t("FarmClub","completeStatus_fail");
            unlockStatus = ZLocUtils.t("FarmClub","unlock_fail");
         }
         addWidget(new ZwTextField(m_window.winStatus_tf,winText));
         addWidget(new ZwTextField(m_window.completeStatus_tf,completeStatus));
         addWidget(new ZwTextField(m_window.unlocked_tf,unlockStatus));
         var previousTier:int = this.m_isPromoted ? int(this.m_nextTier - 1) : this.m_nextTier;
         addWidget(new ZwTextField(m_window.stageTitle_tf,ZLocUtils.t("FarmClub","stageName_" + previousTier)));
         if(this.m_isPromoted)
         {
            addWidget(new ZwWidget(m_window.trophy_mc));
         }
         addWidget(new FarmIcon(m_window.clubIcon_mc,FarmClubUtility.getBackgroundLogoPathFromId(this.m_farmClub.clubLogoId)));
         var clubRankText:String = ZLocUtils.t("FarmClub","Rank",{"num":this.m_clubLeaderboardEntry["rank"]});
         addWidget(new ZwTextField(m_window.clubRank_tf,clubRankText));
         var clubHarvestText:String = ZLocUtils.t("FarmClub","numHarvests",{"num":this.m_clubLeaderboardEntry["value"]});
         addWidget(new ZwTextField(m_window.harvestAmount_tf,clubHarvestText));
         var myHarvestText:String = ZLocUtils.t("FarmClub","MyClub_MyTotalTitleNum",{"num":this.m_userTotal});
         addWidget(new ZwTextField(m_window.myHarvestAmount_tf,myHarvestText));
         addWidget(new ZwTextField(m_window.nextChallenge_tf,ZLocUtils.t("FarmClub","nextChallenge")));
         addWidget(new ZwTextField(m_window.cropName_tf,ZLocUtils.t("FarmClub","stageName_" + this.m_nextTier)));
         var nextTierItem:FarmItem = FarmClubUtility.getFarmItemFromTier(this.m_nextTier);
         if(nextTierItem)
         {
            plantFrame = new ZwFrame(m_window.plantIcon_mc);
            plantIcon = new FarmIcon(plantFrame.element.cropIcon_mc,nextTierItem.iconUrl);
            plantIcon.setIconSize(60,60);
            plantFrame.addWidget(plantIcon);
            addWidget(plantFrame);
         }
         for each(reward in this.m_rewards)
         {
            if(reward.type == QuestConstants.REWARD_COINS)
            {
               this.populateRewardFrame("reward_0_mc",reward);
            }
            else if(reward.type == QuestConstants.REWARD_XP)
            {
               this.populateRewardFrame("reward_1_mc",reward);
            }
            else if(reward.type == QuestConstants.REWARD_ACTION_COUNT_INCREMENT && this.m_isPromoted)
            {
               UserRewardUtil.grantUserReward(reward);
            }
         }
         previousTierItem = FarmClubUtility.getFarmItemFromTier(previousTier);
         if(previousTierItem)
         {
            cropRewardFrame = new ZwFrame(m_window.reward_2_mc);
            icon = new FarmIcon(cropRewardFrame.element.icon_mc,previousTierItem.iconUrl);
            icon.setIconSize(70,70);
            cropRewardFrame.addWidget(icon);
            cropRewardFrame.addWidget(new ZwTextField(cropRewardFrame.element.description_tf,ZLocUtils.t("FarmClub","cropLicense")));
            addWidget(cropRewardFrame);
         }
         if(this.m_isPromoted)
         {
            TransactionManager.addTransaction(new TRefreshGifts());
            TransactionManager.addTransaction(new TRefreshBalance());
         }
      }
      
      private function populateRewardFrame(frameName:String, reward:Object) : void
      {
         var amt:int = int(reward.value);
         var rewardFrame:ZwFrame = new ZwFrame(m_window[frameName]);
         var icon:FarmIcon = new FarmIcon(rewardFrame.element.icon_mc,UserRewardUtil.getImageForReward(reward));
         icon.setIconSize(70,70);
         rewardFrame.addWidget(icon);
         rewardFrame.addWidget(new ZwTextField(rewardFrame.element.description_tf,amt.toString()));
         addWidget(rewardFrame);
      }
   }
}

