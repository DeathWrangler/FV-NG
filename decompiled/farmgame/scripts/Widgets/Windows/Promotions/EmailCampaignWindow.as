package Widgets.Windows.Promotions
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TSubscribeToEmail;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class EmailCampaignWindow extends FarmWindow
   {
      
      public static var EMAIL_CHANNEL:String = "consumableCampaign";
      
      public static const CC_EMAIL_WINDOW_STATUS:String = "CCEmailWindowStatus";
      
      public static const CC_EMAIL_SUBSCRIBE:int = 3;
      
      public static const CC_EMAIL_UNSUBSCRIBE:int = 2;
      
      public static const CC_EMAIL_FIRST_OPT_OUT:int = 1;
      
      public static const EMAIL_PERMANENT_LAST_SEND:String = "lastCCEmailSend";
      
      public static const EMAIL_LAST_RECEIVED_KEY:String = "CC_EmailLastCollectTS";
      
      private const ASSET_URL:String = "assets/dialogs/FV_motd_EmailCampaign.swf";
      
      private var m_title_tf:ZwTextField;
      
      private var m_description_tf:ZwTextField;
      
      private var m_yes_bt:FarmAnimatedTextButton;
      
      private var m_no_bt:FarmAnimatedTextButton;
      
      private var rewards:Array = new Array("consume_farm_hands","consume_turbo_charger","consume_arborists","fuel1","part_toycrane");
      
      public function EmailCampaignWindow()
      {
         FarmStatsManager.count("view","ingamepopup","consumable_boost_email");
         super(this.ASSET_URL);
      }
      
      public static function canShow() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.getActionCount(EmailCampaignWindow.CC_EMAIL_WINDOW_STATUS) == EmailCampaignWindow.CC_EMAIL_SUBSCRIBE)
         {
            result = true;
         }
         return result;
      }
      
      public static function showStatic() : void
      {
         UI.displayPopup(new EmailCampaignWindow());
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardList:String = null;
         var i:int = 0;
         var reward:String = null;
         var emailRewards:Array = null;
         var prizeItem:FarmItem = null;
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.title_tf))
         {
            addWidget(this.m_title_tf = new ZwTextField(m_window.mainWindow.title_tf,ZLocUtils.t("Dialogs","EmailCampaignWindow_Title")));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.body_tf))
         {
            addWidget(this.m_description_tf = new ZwTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","EmailCampaignWindow_Body")));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.yes_bt))
         {
            addWidget(this.m_yes_bt = new FarmAnimatedTextButton(m_window.mainWindow.yes_bt,ZLocUtils.t("Dialogs","ConsumableCampaignWindow_YesBTText"),this.onClickSignUp));
         }
         if(Boolean(m_window.mainWindow) && Boolean(m_window.mainWindow.no_bt))
         {
            addWidget(this.m_no_bt = new FarmAnimatedTextButton(m_window.mainWindow.no_bt,ZLocUtils.t("Dialogs","ConsumableCampaignWindow_NoBTText"),this.onCancel));
         }
         if(m_window.mainWindow.gift_mc_0)
         {
            rewardList = String(Global.flashHotParams["CC_EMAIL_REWARD"]);
            if(Boolean(rewardList) && Boolean(rewardList != "") && rewardList != "null")
            {
               emailRewards = rewardList.split(",");
               if(Boolean(emailRewards) && emailRewards.length >= 2)
               {
                  this.rewards = emailRewards;
               }
            }
            i = 0;
            for each(reward in this.rewards)
            {
               prizeItem = Global.farmGameSettingsManager.getFarmItemByName(reward);
               addWidget(new FarmIcon(m_window.mainWindow["gift_mc_" + i.toString()],prizeItem.icon),true) as FarmIcon;
               i++;
            }
         }
      }
      
      private function onClickSignUp(event:Event) : void
      {
         FarmStatsManager.count("view","ingamepopup","consumable_boost_email","accept");
         TransactionManager.addTransaction(new TSubscribeToEmail(EMAIL_CHANNEL),false);
         Global.player.setActionCount(EmailCampaignWindow.CC_EMAIL_WINDOW_STATUS,EmailCampaignWindow.CC_EMAIL_SUBSCRIBE,true);
         UI.displayPopup(new EmailCampaignConfirmWindow());
         this.onClose(event);
      }
      
      private function onCancel(event:Event) : void
      {
         FarmStatsManager.count("view","ingamepopup","consumable_boost_email","decline");
         var status:int = Global.player.getActionCount(EmailCampaignWindow.CC_EMAIL_WINDOW_STATUS);
         if(status == 0)
         {
            Global.player.setActionCount(EmailCampaignWindow.CC_EMAIL_WINDOW_STATUS,EmailCampaignWindow.CC_EMAIL_FIRST_OPT_OUT,true);
         }
         else
         {
            Global.player.setActionCount(EmailCampaignWindow.CC_EMAIL_WINDOW_STATUS,EmailCampaignWindow.CC_EMAIL_UNSUBSCRIBE,true);
         }
         this.close();
      }
      
      override public function close() : void
      {
         super.close();
      }
   }
}

