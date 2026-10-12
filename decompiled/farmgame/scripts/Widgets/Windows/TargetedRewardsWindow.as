package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.buffs.BHarvestHelper;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.TargetedRewardsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.TargetedRewardSlotContainerFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class TargetedRewardsWindow extends FarmWindow
   {
      
      public static const ZLOC_PACKAGE_DIALOGS:String = ZLocConstants.DIALOG_UTIL_PKG;
      
      private static const ASSET_PATH_DAY_1_WINDOW:String = "assets/dialogs/FV_motd_TargetedReward_Day1_2014.swf";
      
      private static const ASSET_PATH_DAY_2_WINDOW:String = "assets/dialogs/FV_motd_TargetedReward_Day2_2014.swf";
      
      private var m_featureName:String = null;
      
      private var m_manager:TargetedRewardsManager;
      
      private var m_titleText:FarmTextField;
      
      private var m_descriptionText:FarmTextField;
      
      private var m_bodyText:FarmTextField;
      
      private var m_acceptButton:FarmAnimatedTextButton;
      
      private var m_isFirstDay:Boolean;
      
      private var m_slots:TargetedRewardSlotContainerFrame;
      
      public function TargetedRewardsWindow(featureName:String, isFirstDay:Boolean)
      {
         this.m_isFirstDay = isFirstDay;
         var assetUrl:String = isFirstDay ? ASSET_PATH_DAY_1_WINDOW : ASSET_PATH_DAY_2_WINDOW;
         super(assetUrl);
         this.m_featureName = featureName;
         this.m_manager = TargetedRewardsManager.getInstance();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window.title_tf)
            {
               addWidget(this.m_titleText = new FarmTextField(m_window.title_tf,"")) as FarmTextField;
            }
            if(m_window.body1_tf)
            {
               addWidget(this.m_descriptionText = new FarmTextField(m_window.body1_tf,"")) as FarmTextField;
            }
            if(m_window.body2_tf)
            {
               addWidget(this.m_bodyText = new FarmTextField(m_window.body2_tf,"")) as FarmTextField;
            }
            if(m_window.slots_mc)
            {
               this.m_slots = new TargetedRewardSlotContainerFrame(m_window.slots_mc,this,this.m_isFirstDay);
               if(this.m_slots)
               {
                  addWidget(this.m_slots);
                  this.m_slots.items = this.m_manager.getRewardsToDisplay(this.m_isFirstDay);
               }
            }
            if(m_window.accept_bt)
            {
               addWidget(this.m_acceptButton = new FarmAnimatedTextButton(m_window.accept_bt,"",this.onClickAccept));
            }
            this.setupText();
         }
         var dayTrack:String = this.m_isFirstDay ? "day1" : "day2";
         FarmStatsManager.count("view","targetedRewards",dayTrack);
      }
      
      private function onClickAccept(event:Event) : void
      {
         this.m_manager.grantRewards(this.m_isFirstDay);
         var dayTrack:String = this.m_isFirstDay ? "day1" : "day2";
         FarmStatsManager.count("accept","targetedRewards",dayTrack);
         super.onClose(event);
      }
      
      private function setupText() : void
      {
         if(this.m_isFirstDay)
         {
            if(this.m_titleText)
            {
               this.m_titleText.text = ZLocUtils.t("Dialogs","Targeted_Rewards_Day_1_Title");
            }
            if(this.m_descriptionText)
            {
               this.m_descriptionText.text = ZLocUtils.t("Dialogs","Targeted_Rewards_Day_1_Body_1");
            }
            if(this.m_bodyText)
            {
               this.m_bodyText.text = ZLocUtils.t("Dialogs","Targeted_Rewards_Day_1_Body_2");
            }
            if(this.m_acceptButton)
            {
               this.m_acceptButton.text = ZLocUtils.t("Dialogs","Targeted_Rewards_Day_1_Button");
            }
         }
         else
         {
            if(this.m_titleText)
            {
               this.m_titleText.text = ZLocUtils.t("Dialogs","Targeted_Rewards_Day_2_Title");
            }
            if(this.m_descriptionText)
            {
               this.m_descriptionText.text = ZLocUtils.t("Dialogs","Targeted_Rewards_Day_2_Body_1");
            }
            if(this.m_bodyText)
            {
               this.m_bodyText.text = ZLocUtils.t("Dialogs","Targeted_Rewards_Day_2_Body_2",{"multiplier":BHarvestHelper.MULTIPLIER_VALUE.toString()});
            }
            if(this.m_acceptButton)
            {
               this.m_acceptButton.text = ZLocUtils.t("Dialogs","Targeted_Rewards_Day_2_Button");
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_manager = null;
         this.m_featureName = null;
         this.m_acceptButton = null;
         this.m_bodyText = null;
         this.m_descriptionText = null;
         this.m_slots = null;
         this.m_titleText = null;
         super.release();
      }
   }
}

