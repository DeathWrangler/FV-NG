package Display
{
   import Events.EmailPopupEvent;
   import Events.GenericPopupEvent;
   import flash.events.MouseEvent;
   
   public class EmailIconPopup extends GenericIconPopup
   {
      
      public static const EMAIL_LAST_SHOWN_STRING:String = "email_pop_last_shown";
      
      public static const EMAIL_ICON_ASSET:String = "assets/hud/FV_Main_Envelope_Icon_alt.png";
      
      public static const EMAIL_PROMPT_ASSET:String = "assets/dialogs/FV_Email_Prompt.swf";
      
      private var m_onFinishEmailPermissionsCallback:Function = null;
      
      private var m_permissionSource:int = 0;
      
      protected var m_genericText1:String;
      
      protected var m_genericText2:String;
      
      protected var m_genericText3:String;
      
      protected var m_genericText4:String;
      
      protected var m_legalText:String;
      
      protected var m_buttonText:String;
      
      public function EmailIconPopup(message:String, type:int = 1, closeCallback:Function = null, icon:Object = null, permissionSource:int = 0, finishEmailPermissionCallback:Function = null, disableIconResize:Boolean = false, showX:Boolean = true, additionalText:String = "", useHtmlText:Boolean = false, dialogAsset:String = "assets/dialogs/FV_Feature_Callout.swf", genericText1:String = "PLACEHOLDER TEXT", genericText2:String = "PLACEHOLDER TEXT", genericText3:String = "PLACEHOLDER TEXT", genericText4:String = "PLACEHOLDER TEXT", legalText:String = "PLACEHOLDER TEXT", buttonText:String = "Okay")
      {
         this.m_genericText1 = genericText1;
         this.m_genericText2 = genericText2;
         this.m_genericText3 = genericText3;
         this.m_genericText4 = genericText4;
         this.m_legalText = legalText;
         this.m_buttonText = buttonText;
         super(message,type,null,icon,disableIconResize,showX,additionalText,useHtmlText,dialogAsset);
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
         var currentTime:Number = GlobalEngine.serverTime / 1000;
         Global.player.setFeatureLastShown(EMAIL_LAST_SHOWN_STRING,currentTime,true);
         dispatchEvent(new EmailPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.YES,this.m_permissionSource,this.m_onFinishEmailPermissionsCallback));
         if(m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,m_closeCallback);
         }
         close();
      }
      
      override protected function onCancel(event:MouseEvent) : void
      {
         var currentTime:Number = GlobalEngine.serverTime / 1000;
         Global.player.setFeatureLastShown(EMAIL_LAST_SHOWN_STRING,currentTime,true);
         dispatchEvent(new EmailPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.NO,this.m_permissionSource,this.m_onFinishEmailPermissionsCallback));
         if(m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,m_closeCallback);
         }
         close();
      }
      
      override protected function onClose(event:MouseEvent) : void
      {
         dispatchEvent(new EmailPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.NO,this.m_permissionSource,this.m_onFinishEmailPermissionsCallback));
         if(m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,m_closeCallback);
         }
         close();
      }
      
      override protected function setMessage() : void
      {
         super.setMessage();
         if(m_window)
         {
            if(m_window.popupBox_mc)
            {
               if(m_window.popupBox_mc.generic1_tf)
               {
                  m_window.popupBox_mc.generic1_tf.htmlText = this.m_genericText1;
               }
               if(m_window.popupBox_mc.generic2_tf)
               {
                  m_window.popupBox_mc.generic2_tf.htmlText = this.m_genericText2;
               }
               if(m_window.popupBox_mc.generic3_tf)
               {
                  m_window.popupBox_mc.generic3_tf.htmlText = this.m_genericText3;
               }
               if(m_window.popupBox_mc.generic4_tf)
               {
                  m_window.popupBox_mc.generic4_tf.htmlText = this.m_genericText4;
               }
               if(m_window.popupBox_mc.legal_tf)
               {
                  m_window.popupBox_mc.legal_tf.htmlText = this.m_legalText;
               }
               if(m_window.popupBox_mc.legal_tf)
               {
                  m_window.popupBox_mc.legal_tf.htmlText = this.m_legalText;
               }
            }
         }
         m_acceptTextName = this.m_buttonText;
      }
   }
}

