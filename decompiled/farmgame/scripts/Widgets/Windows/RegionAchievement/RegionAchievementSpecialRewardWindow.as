package Widgets.Windows.RegionAchievement
{
   import Classes.util.ZLocUtils;
   import Events.RegionAchievementEvent;
   import Managers.RegionAchievementManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class RegionAchievementSpecialRewardWindow extends FarmWindow
   {
      
      private static const MAIN_MC:String = "mediumTrophyWon_mc";
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const BODYE_TF:String = "body_tf";
      
      private static const CHECKOUT_BT:String = "tileTutorial_bt";
      
      private var m_featureName:String;
      
      private var m_mainMC:ZwFrame;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_checkoutBt:FarmAnimatedTextButton;
      
      public function RegionAchievementSpecialRewardWindow(assetURL:String, featureName:String)
      {
         super(assetURL);
         this.m_featureName = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty(MAIN_MC))
         {
            this.m_mainMC = addWidget(new ZwFrame(m_window[MAIN_MC]),true) as ZwFrame;
         }
         var text:String = "";
         if(this.m_mainMC)
         {
            if(this.m_mainMC.element.hasOwnProperty(TITLE_TF))
            {
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_special_reward_window_title");
               this.m_titleTf = addWidget(new ZwTextField(this.m_mainMC.element[TITLE_TF],text)) as ZwTextField;
            }
            if(this.m_mainMC.element.hasOwnProperty(BODYE_TF))
            {
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_special_reward_window_body");
               this.m_bodyTf = addWidget(new ZwTextField(this.m_mainMC.element[BODYE_TF],text)) as ZwTextField;
            }
            if(this.m_mainMC.element.hasOwnProperty(CHECKOUT_BT))
            {
               text = ZLocUtils.t("Dialogs",this.m_featureName + "_special_reward_window_cta");
               this.m_checkoutBt = addWidget(new FarmAnimatedTextButton(this.m_mainMC.element[CHECKOUT_BT],text,this.onClick)) as FarmAnimatedTextButton;
            }
         }
      }
      
      private function onClick(e:Event) : void
      {
         onClose(e);
         if(RegionAchievementManager.getInstance(this.m_featureName))
         {
            RegionAchievementManager.getInstance(this.m_featureName).dispatchRegionAchievementEvent(new RegionAchievementEvent(RegionAchievementEvent.EXECUTE_NEXT_ACTION));
         }
      }
   }
}

