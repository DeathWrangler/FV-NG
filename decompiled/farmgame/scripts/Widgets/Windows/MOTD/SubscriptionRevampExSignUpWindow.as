package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class SubscriptionRevampExSignUpWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/Subscriptions/SubUpgrade2016/FV_SubUpgrade2016_Ex_Tier_MOTD.swf";
      
      public function SubscriptionRevampExSignUpWindow()
      {
         super(ASSET_PATH);
      }
      
      public static function display() : void
      {
         var popup:SubscriptionRevampExSignUpWindow = new SubscriptionRevampExSignUpWindow();
         UI.displayPopup(popup);
      }
      
      override protected function postLoadComplete() : void
      {
         var level:int = 0;
         var sublevel:String = null;
         var days:int = 0;
         var benefits:MovieClip = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            FarmStatsManager.count("MOTD","impressions","MOTD_subs_strkrest_stage2");
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            level = SubscriptionsManager.instance.getHeighestSubscriptionLevel();
            sublevel = SubscriptionsManager.instance.getSubscriptionLevelText(level);
            if(m_window.mainWindow["title_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","SubscriptionRevampExSignup_title")));
            }
            if(m_window.mainWindow["subtitle_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.subtitle_tf,ZLocUtils.t("Dialogs","SubscriptionRevampExSignup_subtitle")));
            }
            if(m_window.mainWindow["body_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","SubscriptionRevampExSignup_body",{"sublevel":sublevel})));
            }
            if(m_window.mainWindow["body1_tf"])
            {
               days = SubscriptionsManager.getEADaysRemaining();
               if(days >= 1)
               {
                  addWidget(new FarmTextField(m_window.mainWindow.body1_tf,ZLocUtils.t("Dialogs","SubscriptionRevampExSignup_body1",{"days":days})));
               }
               else if(days == 0)
               {
                  addWidget(new FarmTextField(m_window.mainWindow.body1_tf,ZLocUtils.t("Dialogs","MOTD_SubscriptionRevampExSub_body2")));
               }
            }
            if(m_window.mainWindow["body2_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.body2_tf,ZLocUtils.t("Dialogs","SubscriptionRevampExSignup_body2")));
            }
            if(m_window.mainWindow["accept_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","SubscriptionRevampExSignup_accept"),this.onSignUp));
            }
            if(m_window.mainWindow["close_bt"])
            {
               addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClose));
            }
            if(m_window.mainWindow["benefits_mc"])
            {
               benefits = m_window.mainWindow.benefits_mc as MovieClip;
               benefits.gotoAndStop(level - 1);
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
      
      private function onSignUp(event:Event) : void
      {
         FarmStatsManager.count("MOTD","click","MOTD_subs_strkrest_stage2");
         SubscriptionsManager.triggerSignUpFlow("sub_revamp");
      }
   }
}

