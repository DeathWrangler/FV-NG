package Display
{
   import Events.EmailPopupEvent;
   import Events.GenericPopupEvent;
   import flash.events.MouseEvent;
   
   public class EmailPopup extends GenericPopup
   {
      
      public static const EMAIL_NEW_USER:int = 0;
      
      public static const EMAIL_EXISTING_USER:int = 1;
      
      public static const EMAIL_LOCKED_BOX:int = 3;
      
      public static const EMAIL_LOCKED_BOX_RETRY:int = 4;
      
      public static const EMAIL_LOCKED_BOX_PROACTIVE_USER:int = 5;
      
      public static const EMAIL_PROACTIVE_USER:int = 6;
      
      public static const EMAIL_MARKET:int = 7;
      
      public static const EMAIL_HUD_ICON:int = 8;
      
      public static const EMAIL_PROMO_BAR:int = 9;
      
      public static const EMAIL_NEW_USER_START_TUTORIAL_COIN:int = 10;
      
      public static const EMAIL_NEW_USER_START_TUTORIAL_COW:int = 11;
      
      public static const EMAIL_SOCIAL_COMM_USER:int = 12;
      
      public static const EMAIL_COMMENT_BOX_VARIANT_SOFTGATE:int = 13;
      
      public static const EMAIL_REVAMPED_VERBIAGE_USER:int = 14;
      
      public static const EMAIL_PROXY_USER:int = 15;
      
      public static const EMAIL_PROXY_LOCKED_BOX_USER:int = 16;
      
      public static const EMAIL_WILD_MUSTANG:int = 17;
      
      public static const EMAIL_REACTIVATION:int = 18;
      
      private var m_onFinishEmailPermissionsCallback:Function = null;
      
      private var m_permissionSource:int = 0;
      
      public function EmailPopup(message:String, type:int = 0, closeCallback:Function = null, permissionSource:int = 0, finishEmailPermissionCallback:Function = null, dialogAsset:String = "assets/dialogs/FV_GenericPopUp.swf")
      {
         super(message,type,null,dialogAsset,"",true);
         this.m_permissionSource = permissionSource;
         if(finishEmailPermissionCallback != null)
         {
            this.m_onFinishEmailPermissionsCallback = finishEmailPermissionCallback;
         }
         if(closeCallback != null)
         {
            m_closeCallback = closeCallback;
            addEventListener(GenericPopupEvent.SELECTED,closeCallback);
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         dispatchEvent(new EmailPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.YES,this.m_permissionSource,this.m_onFinishEmailPermissionsCallback));
         if(m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,m_closeCallback);
         }
         close();
      }
      
      override protected function onCancel(event:MouseEvent) : void
      {
         dispatchEvent(new EmailPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.NO,this.m_permissionSource,this.m_onFinishEmailPermissionsCallback));
         if(m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,m_closeCallback);
         }
         close();
      }
   }
}

