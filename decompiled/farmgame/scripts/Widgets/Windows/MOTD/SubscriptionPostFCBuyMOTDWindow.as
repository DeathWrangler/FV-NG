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
   import flash.events.Event;
   
   public class SubscriptionPostFCBuyMOTDWindow extends CustomWindowMOTDBase
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/Subscriptions/SubUpgrade2016/FV_SubUpgrade2016_PostFC_MOTD.swf";
      
      public function SubscriptionPostFCBuyMOTDWindow()
      {
         super(ASSET_PATH);
      }
      
      public static function display() : void
      {
         var popup:SubscriptionPostFCBuyMOTDWindow = new SubscriptionPostFCBuyMOTDWindow();
         UI.displayPopup(popup);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         Global.player.setSeenFlag("seenPostFCBuyPopup");
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","MOTD_POSTFC_BUY_SUBSCRIPTION_2016_Title")));
            }
            if(m_window.mainWindow["subtitle_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.subtitle_tf,ZLocUtils.t("Dialogs","MOTD_POSTFC_BUY_SUBSCRIPTION_2016_Subtitle")));
            }
            if(m_window.mainWindow["body_tf"])
            {
               addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","MOTD_POSTFC_BUY_SUBSCRIPTION_2016_Text")));
            }
            if(m_window.mainWindow["accept_bt"])
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","MOTD_POSTFC_BUY_SUBSCRIPTION_2016_ButtonText"),this.onClickMore));
            }
            if(m_window.mainWindow["close_bt"])
            {
               addWidget(new FarmButton(m_window.mainWindow.close_bt,onClose));
            }
         }
         FarmStatsManager.count("MOTD","impressions","MOTD_subs_postfc");
      }
      
      private function onClickMore(event:Event) : void
      {
         this.close();
         FarmStatsManager.count("MOTD","click","MOTD_subs_postfc");
         if(SubscriptionsManager.instance.isExsubscriber())
         {
            SubscriptionRevampExSignUpWindow.display();
         }
         else
         {
            UI.displayPopup(new SubscriptionAllBenefitsMOTDWindow());
         }
      }
   }
}

