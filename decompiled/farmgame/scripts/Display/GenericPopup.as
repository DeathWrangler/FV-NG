package Display
{
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Managers.SmartPopupManager;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   
   public class GenericPopup extends Dialog
   {
      
      public static const ASK:int = 2;
      
      public static const ACCEPT:int = 1;
      
      public static const OK:int = 1;
      
      public static const YES:int = 1;
      
      public static const CANCEL:int = 0;
      
      public static const NO:int = 0;
      
      public static const TYPE_OK:int = 0;
      
      public static const TYPE_ACCEPTCANCEL:int = 1;
      
      public static const TYPE_YESNO:int = 2;
      
      public static const TYPE_MODAL:int = 3;
      
      public static const TYPE_SHARECANCEL:int = 4;
      
      public static const TYPE_TRADECANCEL:int = 5;
      
      public static const TYPE_ASKBUY:int = 6;
      
      public static const TYPE_SHARE:int = 7;
      
      public static const TYPE_FRICTIONLESS_BUY:int = 8;
      
      public static const TYPE_FRICTIONLESS_BUYASK:int = 9;
      
      public static const TYPE_SHARECHECKBOX:int = 10;
      
      public static const TYPE_BUY:int = 11;
      
      public static const TYPE_CUSTOM_ACCEPTANCE:int = 12;
      
      public static const BUYNOW_TEXT_NAME:String = "BuyNow";
      
      public static const GENERIC_ASSET:String = "assets/dialogs/FV_GenericPopUp.swf";
      
      public static const GENERIC_ASSET_MED:String = "assets/dialogs/FV_GenericMedPopUp.swf";
      
      public static const GENERIC_ASSET_LRG:String = "assets/dialogs/FV_GenericLrgPopUp.swf";
      
      public static const GENERIC_ASSET_MAX_MSG_LEN:int = 200;
      
      public static const GENERIC_ASSET_MED_MAX_MSG_LEN:int = 400;
      
      protected var m_message:String;
      
      protected var m_type:int;
      
      protected var m_closeCallback:Function;
      
      protected var m_accept:GenericButton;
      
      protected var m_reject:GenericButton;
      
      protected var m_userInputRecieved:Boolean = false;
      
      protected var m_rewardUrl:String;
      
      protected var m_acceptTextName:String = "Accept";
      
      protected var m_cancelTextName:String = "Cancel";
      
      private var m_useHtmlText:Boolean = false;
      
      protected var m_showX:Boolean;
      
      protected var m_selected:Boolean = true;
      
      protected var m_iconUrl:String = null;
      
      protected var m_iconPreview:FarmIcon;
      
      public function GenericPopup(message:String, type:int = 0, closeCallback:Function = null, dialogAsset:String = "assets/dialogs/FV_GenericPopUp.swf", rewardUrl:String = "", useHtmlText:Boolean = false, bAddClickBlocker:Boolean = false, showX:Boolean = false)
      {
         m_dialogAsset = dialogAsset;
         super(true,bAddClickBlocker);
         this.m_useHtmlText = useHtmlText;
         this.m_type = type;
         this.m_message = message;
         this.m_rewardUrl = rewardUrl;
         this.m_showX = showX;
         if(closeCallback != null)
         {
            this.m_closeCallback = closeCallback;
            addEventListener(GenericPopupEvent.SELECTED,closeCallback);
         }
      }
      
      protected function hideExtras() : void
      {
         if(m_window)
         {
            if(Boolean(m_window.popupBox_mc) && Boolean(m_window.popupBox_mc.close_bt))
            {
               if(!this.m_showX)
               {
                  m_window.popupBox_mc.close_bt.visible = false;
               }
            }
         }
      }
      
      protected function setMessage() : void
      {
         if(this.m_message != null)
         {
            if(m_window)
            {
               if(m_window.popupBox_mc)
               {
                  if(m_window.popupBox_mc.popupBox_tf)
                  {
                     if(this.m_useHtmlText)
                     {
                        m_window.popupBox_mc.popupBox_tf.htmlText = this.m_message;
                     }
                     else
                     {
                        m_window.popupBox_mc.popupBox_tf.text = this.m_message;
                     }
                     ZLocUtils.autoFormatSize(m_window.popupBox_mc.popupBox_tf);
                  }
               }
               else if(m_window["body_tf"])
               {
                  if(this.m_useHtmlText)
                  {
                     m_window.body_tf.htmlText = this.m_message;
                  }
                  else
                  {
                     m_window.body_tf.text = this.m_message;
                  }
                  ZLocUtils.autoFormatSize(m_window.body_tf);
               }
            }
         }
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         var data:Array = [];
         if(this.m_type == GenericPopup.TYPE_SHARE)
         {
            this.m_showX = true;
         }
         this.hideExtras();
         this.setMessage();
         switch(this.m_type)
         {
            case TYPE_OK:
               this.centerAcceptButton();
               break;
            case TYPE_MODAL:
               m_window.popupBox_mc.accept_bt.visible = false;
               m_window.popupBox_mc.cancel_bt.visible = false;
               break;
            case TYPE_SHARECANCEL:
               this.m_acceptTextName = "GenericShareButton";
               m_window.popupBox_mc.accept_bt.visible = true;
               m_window.popupBox_mc.cancel_bt.visible = true;
               break;
            case TYPE_TRADECANCEL:
               this.m_acceptTextName = "Trade";
               m_window.popupBox_mc.accept_bt.visible = true;
               m_window.popupBox_mc.cancel_bt.visible = true;
               break;
            case TYPE_SHARE:
               this.m_acceptTextName = "GenericShareButton";
               m_window.popupBox_mc.accept_bt.visible = true;
               this.centerAcceptButton();
            case TYPE_SHARECHECKBOX:
               this.m_acceptTextName = "GenericShareButton";
               if(Global.player.inExperimentFeedCheckBoxV2())
               {
                  if(m_window.popupBox_mc.accept_bt)
                  {
                     m_window.popupBox_mc.accept_bt.visible = true;
                  }
                  if(m_window.popupBox_mc.checkbox_tf)
                  {
                     m_window.popupBox_mc.checkbox_tf.visible = true;
                  }
               }
               this.centerAcceptButton();
               break;
            case TYPE_BUY:
               this.m_acceptTextName = BUYNOW_TEXT_NAME;
               m_window.popupBox_mc.accept_bt.visible = true;
               this.centerAcceptButton();
         }
         if(Boolean(m_window) && Boolean(m_window["popupBox_mc"]) && Boolean(m_window.popupBox_mc.accept_bt) && Boolean(m_window.popupBox_mc.accept_bt.visible))
         {
            this.m_accept = new GenericButton(m_window.popupBox_mc.accept_bt,this.onAccept);
            this.m_accept.text = ZLocUtils.t("Dialogs",this.m_acceptTextName);
         }
         if(Boolean(m_window) && Boolean(m_window["accept_bt"]))
         {
            this.m_accept = new GenericButton(m_window.accept_bt,this.onAccept);
            this.m_accept.text = ZLocUtils.t("Dialogs",this.m_acceptTextName);
            m_window.accept_bt.visible = true;
         }
         if(Boolean(m_window) && Boolean(m_window["cancel_bt"]))
         {
            this.m_reject = new GenericButton(m_window.cancel_bt,this.onCancel);
            this.m_reject.text = ZLocUtils.t("Dialogs",this.m_cancelTextName);
            m_window.cancel_bt.visible = true;
         }
         if(Boolean(m_window) && Boolean(m_window["popupBox_mc"]) && Boolean(m_window.popupBox_mc.cancel_bt) && Boolean(m_window.popupBox_mc.cancel_bt.visible))
         {
            this.m_reject = new GenericButton(m_window.popupBox_mc.cancel_bt,this.onCancel);
            this.m_reject.text = ZLocUtils.t("Dialogs",this.m_cancelTextName);
         }
         this.setupCloseButton();
         if(Boolean(this.m_iconUrl) && Boolean(m_window["icon_mc"]))
         {
            this.m_iconPreview = new FarmIcon(m_window.icon_mc,this.m_iconUrl);
            this.m_iconPreview.setIconSize(FarmIcon.STANDARD_ICON_WIDTH,FarmIcon.STANDARD_ICON_HEIGHT);
         }
      }
      
      private function centerAcceptButton() : void
      {
         if(Boolean(m_window) && Boolean(m_window["popupBox_mc"]) && Boolean(m_window.popupBox_mc["cancel_bt"]) && Boolean(m_window.popupBox_mc.cancel_bt))
         {
            m_window.popupBox_mc.cancel_bt.visible = false;
            m_window.popupBox_mc.accept_bt.x = (m_window.width - m_window.popupBox_mc.accept_bt.width) / 2;
         }
      }
      
      public function setAcceptTextName(name:String) : void
      {
         this.m_acceptTextName = name;
      }
      
      public function setCancelTextName(name:String) : void
      {
         this.m_cancelTextName = name;
      }
      
      public function set rewardUrl(value:String) : void
      {
         this.m_rewardUrl = value;
      }
      
      public function set iconUrl(value:String) : void
      {
         this.m_iconUrl = value;
      }
      
      protected function onAccept(event:MouseEvent) : void
      {
         if(Global.player.inExperimentFeedCheckBoxV2() && this.m_type == TYPE_SHARECHECKBOX)
         {
            if(!this.m_selected)
            {
               this.onCancel(event);
               return;
            }
         }
         if(this.m_userInputRecieved == false)
         {
            this.m_userInputRecieved = true;
            if(getTrackerEnabled())
            {
               if(this.m_acceptTextName == "GenericShareButton")
               {
                  this.m_acceptTextName = "Share";
               }
               SmartPopupManager.getInstance().popupAccepted(m_trackerKey,this.m_acceptTextName);
            }
            dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,YES,this.m_rewardUrl));
            this.close();
         }
      }
      
      protected function onCancel(event:MouseEvent) : void
      {
         if(this.m_userInputRecieved == false)
         {
            this.m_userInputRecieved = true;
            if(getTrackerEnabled())
            {
               SmartPopupManager.getInstance().popupDeclined(m_trackerKey,this.m_cancelTextName);
            }
            dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,NO));
            this.close();
         }
      }
      
      protected function onClose(event:MouseEvent) : void
      {
         if(this.m_userInputRecieved == false)
         {
            this.m_userInputRecieved = true;
            if(getTrackerEnabled())
            {
               SmartPopupManager.getInstance().popupDeclined(m_trackerKey,ZLocUtils.t("Dialogs","ButtonX"));
            }
            dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,NO));
            this.close();
         }
      }
      
      protected function setupCloseButton() : void
      {
         if(Boolean(m_window) && Boolean(m_window.popupBox_mc) && Boolean(m_window.popupBox_mc.close_bt))
         {
            if(this.m_showX)
            {
               m_window.popupBox_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onClose);
            }
         }
         if(Boolean(m_window) && Boolean(m_window.close_bt))
         {
            if(this.m_showX)
            {
               m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onClose);
            }
         }
      }
      
      protected function removeAllEventListeners() : void
      {
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         if(Boolean(m_window) && Boolean(m_window.popupBox_mc) && Boolean(m_window.popupBox_mc.close_bt) && this.m_showX)
         {
            m_window.popupBox_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         }
      }
      
      override public function close() : void
      {
         this.removeAllEventListeners();
         super.close();
      }
   }
}

