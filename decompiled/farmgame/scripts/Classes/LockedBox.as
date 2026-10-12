package Classes
{
   import Classes.util.FarmFacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.EmailPopup;
   import Display.EnterPasscodeDialog;
   import Display.UI;
   import Engine.Utilities;
   import Managers.EmailManager;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class LockedBox extends LootableDecoration
   {
      
      private static const OPEN_OVERLAY_URL:String = "assets/effects/effect_mysterycrate2.swf";
      
      public function LockedBox(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function getOpenOverlayUrl() : String
      {
         return OPEN_OVERLAY_URL;
      }
      
      override protected function getMenuItems() : Array
      {
         return [{
            "label":ZLocUtils.t("FarmGame","EnterPasscode"),
            "action":ENTER_PASSCODE
         },{
            "label":ZLocUtils.t("FarmGame","GetPasscode"),
            "action":GET_PASSCODE
         },{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","Sell"),
            "action":SELL_OBJECT
         }];
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case ENTER_PASSCODE:
                  this.showEnterPasscodePopup();
                  break;
               case GET_PASSCODE:
                  EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_LOCKED_BOX_RETRY);
                  break;
               case MOVE_OBJECT:
                  this.move();
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      protected function showEnterPasscodePopup() : void
      {
         var enterPasscode:EnterPasscodeDialog = new EnterPasscodeDialog(this);
         if(Utilities.isFullScreen())
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","FullScreenTypingWarning"));
         }
         UI.displayPopup(enterPasscode,true);
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         Global.player.setSeenFlag("placedLockedBox");
         FarmStatsManager.count("email_locked_box","placed","locked_box");
         if(GlobalEngine.socialNetwork.userHasEmailPermission())
         {
            (GlobalEngine.socialNetwork as FarmFacebookSocialNetwork).onEmailPermissionDialogClosedWithSource(true,EmailPopup.EMAIL_LOCKED_BOX);
         }
         else
         {
            EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_LOCKED_BOX);
         }
      }
   }
}

