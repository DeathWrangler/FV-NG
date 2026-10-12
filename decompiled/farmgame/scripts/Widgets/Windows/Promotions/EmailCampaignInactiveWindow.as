package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TSubscribeToEmail;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class EmailCampaignInactiveWindow extends FarmWindow
   {
      
      private const ASSET_URL:String = "assets/dialogs/FV_unsubscribe_EmailCampaign.swf";
      
      private var m_title_tf:ZwTextField;
      
      private var m_description_tf:ZwTextField;
      
      private var m_yes_bt:FarmAnimatedTextButton;
      
      private var m_no_bt:FarmAnimatedTextButton;
      
      public function EmailCampaignInactiveWindow()
      {
         FarmStatsManager.count("view","ingamepopup","consumable_boost_email_unsubscribe","view");
         super(this.ASSET_URL);
      }
      
      public static function showStatic() : void
      {
         UI.displayPopup(new EmailCampaignInactiveWindow());
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.title_tf))
         {
            addWidget(this.m_title_tf = new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","EmailCampaignWindowUnsubscribe_Title")));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.body_tf))
         {
            addWidget(this.m_description_tf = new ZwTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","EmailCampaignUnsubscribeWindow_Body")));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.yes_bt))
         {
            addWidget(this.m_yes_bt = new FarmAnimatedTextButton(m_window.mainWindow.yes_bt,ZLocUtils.t("Dialogs","ConsumableCampaignUnsubscribeWindow_NoBTText"),this.onClickSignUp));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.no_bt))
         {
            addWidget(this.m_no_bt = new FarmAnimatedTextButton(m_window.mainWindow.no_bt,ZLocUtils.t("Dialogs","ConsumableCampaignUnsubscribeWindow_YesBTText"),this.onCancel));
         }
      }
      
      private function onClickSignUp(event:Event) : void
      {
         FarmStatsManager.count("view","ingamepopup","consumable_boost_email_unsubscribe","accept");
         TransactionManager.addTransaction(new TSubscribeToEmail(EmailCampaignWindow.EMAIL_CHANNEL),false);
         Global.player.setActionCount(EmailCampaignWindow.CC_EMAIL_WINDOW_STATUS,EmailCampaignWindow.CC_EMAIL_SUBSCRIBE,true);
         UI.displayPopup(new EmailCampaignConfirmWindow());
         this.close();
      }
      
      private function onCancel(event:Event) : void
      {
         FarmStatsManager.count("view","ingamepopup","consumable_boost_email_unsubscribe","view");
         Global.player.setActionCount(EmailCampaignWindow.CC_EMAIL_WINDOW_STATUS,EmailCampaignWindow.CC_EMAIL_UNSUBSCRIBE,true);
         this.close();
      }
   }
}

