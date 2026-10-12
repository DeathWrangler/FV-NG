package Widgets.Windows.Subscriptions
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.SubscriptionsEvent;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   import flash.globalization.DateTimeFormatter;
   import flash.globalization.LocaleID;
   import flash.text.TextField;
   
   public class SubscriptionPostSignupCongratsWindow extends FarmWindow
   {
      
      private static const ASSET_NAME:String = "assets/dialogs/Subscriptions/SubUpgrade2016/FV_SubUpgrade2016_PostSignUp_MOTD.swf";
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function SubscriptionPostSignupCongratsWindow(dialogAsset:String = "assets/dialogs/Subscriptions/SubUpgrade2016/FV_SubUpgrade2016_PostSignUp_MOTD.swf")
      {
         super(dialogAsset);
      }
      
      public static function display() : void
      {
         var popUp:SubscriptionPostSignupCongratsWindow = null;
         var assetname:String = ASSET_NAME;
         popUp = new SubscriptionPostSignupCongratsWindow(assetname);
         UI.displayPopup(popUp);
      }
      
      override protected function postLoadComplete() : void
      {
         var body1:TextField = null;
         var date:Date = null;
         var df:DateTimeFormatter = null;
         super.postLoadComplete();
         if(m_window.mainWindow)
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t_pk("Dialogs:subscriptions_VIP_POST_SIGNUP_2016_Title")));
            }
            if(m_window.mainWindow["subtitle_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.subtitle_tf,ZLocUtils.t_pk("Dialogs:subscriptions_VIP_POST_SIGNUP_2016_Subtitle")));
            }
            if(m_window.mainWindow["body_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t_pk("Dialogs:subscriptions_VIP_POST_SIGNUP_2016_Npc1")));
            }
            if(m_window.mainWindow["body1_tf"])
            {
               body1 = m_window.mainWindow.body1_tf as TextField;
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ENABLE_VIP_POSTSIGNUP_WINDOW) >= 2)
               {
                  date = new Date(Number(SubscriptionsManager.getTrialEndTS(false) * 1000));
                  df = new DateTimeFormatter(LocaleID.DEFAULT);
                  df.setDateTimePattern("EEEE MMM dd yyyy");
                  addWidget(new FarmTextField(body1,ZLocUtils.t_pk("Dialogs:subscriptions_VIP_POST_SIGNUP_2016_Npc2",null,{"date":df.format(date)})));
               }
               else
               {
                  body1.visible = false;
               }
            }
            if(m_window.mainWindow["accept_bt"])
            {
               this.m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","subscriptions_VIP_POST_SIGNUP_2016_buttonText"),this.onAccept)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow["close_bt"])
            {
               m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose)) as FarmButton;
            }
         }
         FarmStatsManager.count("MOTD","impressions","MOTD_subs_trialv2_postsignup");
      }
      
      protected function onAccept(event:MouseEvent) : void
      {
         this.close();
         FarmStatsManager.count("MOTD","click","MOTD_subs_trialv2_postsignup");
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_BENEFITS_POPUP,{
            "source":"SubscriptionPostSignupMOTDWindow",
            "sub_type":SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE
         }));
      }
   }
}

