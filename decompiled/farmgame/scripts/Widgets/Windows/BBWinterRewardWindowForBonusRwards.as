package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.BringBackWinterManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BBWinterRewardWindowForBonusRwards extends BBWinterRewardWindow
   {
      
      private var m_type:String = null;
      
      private var m_featureName:String = null;
      
      private var m_rewardName:String = null;
      
      private var m_shareBt:FarmAnimatedTextButton;
      
      private var m_BonusIconPreview:FarmIcon;
      
      private var m_icon_animation_main:MovieClip;
      
      private var m_icon_animation:MovieClip;
      
      public function BBWinterRewardWindowForBonusRwards(type:String, featureName:String, rewardName:String)
      {
         this.m_type = type;
         this.m_featureName = featureName;
         this.m_rewardName = rewardName;
         var assetPath:String = BringBackWinterManager.getInstance(this.m_featureName).getRewardDialogPathFor(type);
         super(this.m_type,this.m_featureName,this.m_rewardName);
      }
      
      override protected function postLoadComplete() : void
      {
         var windowName:String = null;
         var bonusRewardPkg:Array = null;
         var stage1:int = 0;
         var stage2:int = 0;
         var stage3:int = 0;
         var badgeName:String = null;
         var item:FarmItem = null;
         var rewardItem:FarmItem = null;
         var replaceObj:Object = null;
         var subText:String = null;
         var shareText:String = null;
         if(m_window)
         {
            windowName = BringBackWinterManager.getInstance(this.m_featureName).getWindowName();
            if(m_window.hasOwnProperty("generic_tf"))
            {
               addWidget(new FarmTextField(m_window["generic_tf"],ZLocUtils.t("Dialogs",windowName + "_sfCounterCongratsTitle")),true);
            }
            bonusRewardPkg = BringBackWinterManager.getInstance(this.m_featureName).getBonusRewardPkgs();
            stage1 = int(bonusRewardPkg[0]["stage"]);
            stage2 = int(bonusRewardPkg[1]["stage"]);
            stage3 = int(bonusRewardPkg[2]["stage"]);
            badgeName = "";
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               if(BringBackWinterManager.getInstance(this.m_featureName).isbonusRewardSatgeCompleted(stage3))
               {
                  badgeName = "GIFT HUNTER LEGEND";
               }
               else if(BringBackWinterManager.getInstance(this.m_featureName).isbonusRewardSatgeCompleted(stage2))
               {
                  badgeName = "GIFT HUNTER VETERAN";
               }
               else if(BringBackWinterManager.getInstance(this.m_featureName).isbonusRewardSatgeCompleted(stage1))
               {
                  badgeName = "GIFT HUNTER AMATEUR";
               }
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
               replaceObj = {"itemName":rewardItem.friendlyTitle};
               subText = this.m_type == BringBackWinterManager.STAGE_REWARD_PATH ? ZLocUtils.t("Dialogs",windowName + "_redeem_bonus_stage_reward",{"badgeName":badgeName}) : ZLocUtils.t("Dialogs",windowName + "_redeem_reward_first_time",replaceObj);
               addWidget(new FarmTextField(m_window["generic2_tf"],subText),true);
            }
            if(m_window.hasOwnProperty("generic4_tf"))
            {
               addWidget(new FarmTextField(m_window["generic4_tf"],ZLocUtils.t("Dialogs","in_your_gift_box")),true);
            }
            if(m_window.hasOwnProperty("icon_animation_main_mc"))
            {
               this.m_icon_animation_main = m_window.icon_animation_main_mc;
               if(this.m_icon_animation_main.hasOwnProperty("icon_animation_mc"))
               {
                  this.m_icon_animation = this.m_icon_animation_main.icon_animation_mc;
                  if(BringBackWinterManager.getInstance(this.m_featureName).isbonusRewardSatgeCompleted(stage3))
                  {
                     this.m_icon_animation.icon_lover_mc.visible = false;
                     this.m_icon_animation.icon_rescuer_mc.visible = false;
                  }
                  else if(BringBackWinterManager.getInstance(this.m_featureName).isbonusRewardSatgeCompleted(stage2))
                  {
                     this.m_icon_animation.icon_rescuer_mc.visible = false;
                     this.m_icon_animation.icon_whisperer_mc.visible = false;
                  }
                  else if(BringBackWinterManager.getInstance(this.m_featureName).isbonusRewardSatgeCompleted(stage1))
                  {
                     this.m_icon_animation.icon_lover_mc.visible = false;
                     this.m_icon_animation.icon_whisperer_mc.visible = false;
                  }
               }
               if(this.m_type == BringBackWinterManager.STAGE_REWARD_PATH)
               {
                  super.recursivelyPlay(m_window);
               }
            }
            if(m_window.hasOwnProperty("base_reward_mc"))
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
               addWidget(this.m_BonusIconPreview = new FarmIcon(m_window.base_reward_mc.reward_mc),false);
               this.m_BonusIconPreview.visible = true;
               this.m_BonusIconPreview.loadIcon(item.getImageByName("icon",false));
               this.m_BonusIconPreview.setIconHeight(75);
               this.m_BonusIconPreview.setIconWidth(75);
            }
            if(m_window.hasOwnProperty("share_bt"))
            {
               if(m_window.hasOwnProperty("share_tf"))
               {
                  shareText = ZLocUtils.t("Dialogs",this.m_featureName + "_share_bonus_stage");
                  m_window.share_tf.text = shareText;
               }
               addWidget(this.m_shareBt = new FarmAnimatedTextButton(m_window["share_bt"],ZLocUtils.t("Dialogs",this.m_featureName + "ShareButtonText"),this.onMileStoneShareFeed),true);
            }
         }
      }
      
      private function onMileStoneShareFeed(event:Event) : void
      {
         if(this.m_shareBt)
         {
            this.m_shareBt.enabled = false;
         }
         BringBackWinterManager.getInstance(this.m_featureName).shareStageBragFeed(this.m_rewardName);
         onClose(null);
      }
   }
}

