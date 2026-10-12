package Widgets.Windows
{
   import Classes.util.FarmGameUtil;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   
   public class MarketingEmailOptinFeatureWindow extends FarmWindow
   {
      
      public static const SERVICE_CLASS:String = "MarketingEmailOptinService";
      
      public static const REWARD_GRANT_FLAG:String = "MarketingEmailOptinRewardGranted";
      
      public static const OPTIN_DECLINE_FLAG:String = "MarketingEmailOptin_DECLINE";
      
      private static const ITEM_NAME:String = "fuel10";
      
      private static const ITEM_QTY:int = 1;
      
      public static const COOL_DOWN_TIME:int = 86400;
      
      public static const MARKETING_OPTIN_LAST_SHOWN_KEY:String = "marketing_optin_last_shown";
      
      private var m_titletf:ZwTextField;
      
      private var m_sizeMc:ZwWidget;
      
      protected var m_decline_bt:FarmAnimatedTextButton;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function MarketingEmailOptinFeatureWindow(dialogPath:String = "assets/dialogs/Email_campaign2020/FV_motd_Email_Campaign_2020.swf")
      {
         super(dialogPath);
      }
      
      public static function onEligibleForOptIn() : void
      {
         if(!hasDenied() && !hasAlreadyOptedIn() && canPopwindow())
         {
            UI.displayPopup(new MarketingEmailOptinFeatureWindow("assets/dialogs/Email_campaign2020/FV_motd_Email_Campaign_2020.swf"),false);
            StatsManager.count("EmailCompliance","view");
         }
      }
      
      private static function canPopwindow() : Boolean
      {
         var key:String = MARKETING_OPTIN_LAST_SHOWN_KEY;
         var timeSinceLastPopup:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         var timeRemaining:int = COOL_DOWN_TIME - timeSinceLastPopup;
         return timeRemaining < 0;
      }
      
      private static function hasAlreadyOptedIn() : Boolean
      {
         var check:Boolean = false;
         if(Global.player.getSeenFlag(REWARD_GRANT_FLAG))
         {
            check = true;
         }
         return check;
      }
      
      private static function hasDenied() : Boolean
      {
         var check:Boolean = false;
         if(Global.player.getSeenFlag(OPTIN_DECLINE_FLAG))
         {
            check = true;
         }
         return check;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(this.m_titletf = new ZwTextField(m_window["title_tf"],"Email Opt-in"));
            this.m_titletf.visible = true;
         }
         if(m_window["accept_bt"])
         {
            this.m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.accept_bt,"Opt-In",this.onAccept)) as FarmAnimatedTextButton;
            this.m_accept_bt.visible = true;
         }
         if(m_window["cancel_bt"])
         {
            this.m_decline_bt = addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,"No",this.onDecline)) as FarmAnimatedTextButton;
            this.m_decline_bt.visible = true;
         }
         if(m_window["close_bt"])
         {
            m_closeButton = new FarmButton(m_window.close_bt,this.onCloseMarketingOptinWindow);
            m_closeButton.visible = true;
         }
      }
      
      private function onGrantReward(result:Object) : void
      {
         var confirmationText:String = null;
         if(result.success)
         {
            Global.player.addGift(ITEM_NAME,"0",ITEM_QTY);
            Global.player.setSeenFlag(REWARD_GRANT_FLAG);
            StatsManager.count("EmailCompliance","opt-in");
            confirmationText = "Thank you.\nWe have recorded your request to Opt-In for Marketing Emails.\n\nPlease check your gift box for the free fuel!";
            if(!UI.displayMessage(confirmationText,GenericPopup.TYPE_OK,this.confirmationCallBack,"farmAnimatedTextConfirmation",true,true))
            {
            }
         }
         else
         {
            super.close();
         }
      }
      
      private function onDeclineComplete(result:Object) : void
      {
         var confirmationText:String = null;
         if(result.success)
         {
            Global.player.addGift(ITEM_NAME,"0",ITEM_QTY);
            Global.player.setSeenFlag(REWARD_GRANT_FLAG);
            StatsManager.count("email-optin","impresssions","reward",ITEM_NAME);
            super.close();
            confirmationText = "Thank you for Opting-In!";
            if(!UI.displayMessage(confirmationText,GenericPopup.TYPE_OK,this.confirmationCallBack,"farmAnimatedTextConfirmation",true,true))
            {
            }
         }
         else
         {
            super.close();
         }
      }
      
      private function confirmationCallBack(evt:GenericPopupEvent) : *
      {
         super.close();
      }
      
      private function grantReward() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward",this.onGrantReward));
      }
      
      private function recordDeclineStatus() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"decline",null));
      }
      
      protected function onAccept(event:MouseEvent) : void
      {
         if(this.m_accept_bt)
         {
            this.m_accept_bt.enabled = false;
         }
         if(!Global.player.getSeenFlag(REWARD_GRANT_FLAG))
         {
            super.close();
            this.grantReward();
         }
         else
         {
            super.onClose(event);
         }
      }
      
      protected function onDecline(event:MouseEvent) : void
      {
         if(this.m_decline_bt)
         {
            this.m_decline_bt.enabled = false;
         }
         Global.player.setSeenFlag(OPTIN_DECLINE_FLAG);
         this.updatePopupLastShown(event);
         this.recordDeclineStatus();
         StatsManager.count("EmailCompliance","opt-out");
         super.onClose(event);
         var confirmationText:String = "We have received your request. You will not receive marketing emails from Farmville";
         if(!UI.displayMessage(confirmationText,GenericPopup.TYPE_OK,this.confirmationCallBack,"farmAnimatedTextConfirmation",true,true))
         {
         }
      }
      
      private function updatePopupLastShown(evt:MouseEvent) : void
      {
         Global.player.setFeatureLastShown(MARKETING_OPTIN_LAST_SHOWN_KEY,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"updatePopupLastShownTS",null));
      }
      
      private function onCloseMarketingOptinWindow(evt:MouseEvent) : void
      {
         this.updatePopupLastShown(evt);
         super.close();
      }
   }
}

