package Widgets.Windows.Charity
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.MultiDonateManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class MultiDonateThanksWindow extends FarmWindow
   {
      
      protected var m_rewardItem:FarmItem = null;
      
      protected var m_featureName:String = null;
      
      protected var m_localizationKey:String = null;
      
      protected var m_feedImage:String = null;
      
      protected var m_mainFrame:ZwFrame = null;
      
      protected var m_rewardName:String = "";
      
      protected var m_friendRewardName:String = "";
      
      protected var m_rewardLink:String = "";
      
      protected var m_bonusRewardName:String = null;
      
      protected var m_shared:Boolean = false;
      
      public function MultiDonateThanksWindow(featureName:String, rewardItemName:String = "", friendRewardLink:String = "", friendRewardName:String = "", bonusItemName:String = null)
      {
         var bonusItem:FarmItem = null;
         var receivedItemNewsfeed:String = null;
         this.m_rewardName = rewardItemName;
         this.m_rewardLink = friendRewardLink;
         this.m_friendRewardName = friendRewardName;
         this.m_featureName = featureName;
         this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardItemName);
         this.m_localizationKey = this.m_rewardItem.name;
         this.m_feedImage = this.m_rewardItem.newsfeed;
         this.m_bonusRewardName = bonusItemName;
         if(this.m_bonusRewardName)
         {
            bonusItem = Global.farmGameSettingsManager.getFarmItemByName(bonusItemName);
            this.m_localizationKey = bonusItem.name;
            receivedItemNewsfeed = bonusItem.newsfeed;
            if(receivedItemNewsfeed != null)
            {
               this.m_feedImage = receivedItemNewsfeed;
            }
         }
         this.name = "MultiDonateThanksWindow" + featureName;
         var dialogAsset:String = "assets/dialogs/FV_" + featureName + "_thankyou.swf";
         super(dialogAsset);
      }
      
      override protected function postLoadComplete() : void
      {
         var charityName:String = null;
         var bonusFriendlyName:String = null;
         super.postLoadComplete();
         this.m_mainFrame = addWidget(new ZwFrame(m_window.mainThanks_mc)) as ZwFrame;
         this.m_mainFrame.addWidget(new FarmAnimatedButton(m_window.mainThanks_mc.share_bt,this.onShareClick));
         this.m_mainFrame.addWidget(new ZwTextField(m_window.mainThanks_mc.congrats_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Campaign_DonateThanksTitle")));
         if(!this.m_bonusRewardName)
         {
            if(m_window.mainThanks_mc.hasOwnProperty("body0_tf"))
            {
               this.m_mainFrame.addWidget(new ZwTextField(m_window.mainThanks_mc["body0_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_thankyou_body0",{"reward":ZLocUtils.tk_pk(this.m_rewardItem.friendlyName)})));
            }
            charityName = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"charity_" + MultiDonateManager.getInstance(this.m_featureName).charityForItemName(this.m_rewardName) + "_name");
            if(m_window.mainThanks_mc.hasOwnProperty("body1_tf"))
            {
               this.m_mainFrame.addWidget(new ZwTextField(m_window.mainThanks_mc["body1_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_thankyou_body1",{"charity":charityName})));
            }
         }
         else
         {
            if(m_window.mainThanks_mc.hasOwnProperty("body0_tf"))
            {
               bonusFriendlyName = Global.farmGameSettingsManager.getFarmItemByName(this.m_bonusRewardName).friendlyName;
               this.m_mainFrame.addWidget(new ZwTextField(m_window.mainThanks_mc["body0_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_thankyou_bonus_body0",{
                  "reward":ZLocUtils.tk_pk(this.m_rewardItem.friendlyName),
                  "bonusReward":ZLocUtils.tk_pk(bonusFriendlyName)
               })));
            }
            if(m_window.mainThanks_mc.hasOwnProperty("body1_tf"))
            {
               this.m_mainFrame.addWidget(new ZwTextField(m_window.mainThanks_mc["body1_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_thankyou_bonus_body1")));
            }
         }
      }
      
      private function onShareClick(event:MouseEvent) : void
      {
         GlobalEngine.socialNetwork.publishFeedStory("MultiDonate_" + this.m_featureName,{
            "user":Global.player.firstName,
            "charity":ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"charity_" + MultiDonateManager.getInstance(this.m_featureName).charityForItemName(this.m_rewardName) + "_name"),
            "images":[{
               "href":"{SN_APP_URL}" + this.m_rewardLink,
               "src":this.m_feedImage
            }],
            "reward_link":this.m_rewardLink
         },[],false);
         this.m_shared = true;
         FarmStatsManager.count(this.m_featureName,"feedshare","accept");
         FarmStatsManager.count("Feed","feed","contribute");
         this.close();
      }
      
      override public function close() : void
      {
         if(this.m_shared == false)
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardLink]));
            FarmStatsManager.count(this.m_featureName,"feedshare","cancel");
         }
         super.close();
      }
      
      override protected function release() : void
      {
         this.m_mainFrame = null;
         super.release();
      }
   }
}

