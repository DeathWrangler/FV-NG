package Display
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Managers.ClickTrackingManager;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class GenericIconPopup extends GenericPopup
   {
      
      protected static const MAX_ICON_SIZE:int = 70;
      
      public static const GENERIC_CALLOUT_ASSET:String = "assets/dialogs/FV_Feature_Callout.swf";
      
      public static const GENERIC_CALLOUT_ASSET_CHECKBOX:String = "assets/dialogs/FV_Feature_Callout_checkbox.swf";
      
      public static const GENERIC_CALLOUT_ASSET_CHECKBOX_SIDECARD:String = "assets/dialogs/JungleMungle/JMInnovation/FV_xjm_Feature_Callout.swf";
      
      protected var m_icon:Object;
      
      protected var m_iconLoader:Loader;
      
      protected var m_additionalText:String;
      
      protected var m_disableIconResize:Boolean;
      
      protected var m_forceSize:Boolean;
      
      protected var m_iconFilter:Array = null;
      
      private var m_checkMark:MovieClip = null;
      
      private var m_checkBox:MovieClip = null;
      
      private var m_checkboxText:String = "";
      
      private var m_sideCardAdditionalText:String = "";
      
      public function GenericIconPopup(message:String, type:int = 1, closeCallback:Function = null, icon:Object = null, disableIconResize:Boolean = false, showX:Boolean = true, additionalText:String = "", useHtmlText:Boolean = false, dialogAsset:String = "assets/dialogs/FV_Feature_Callout.swf", iconFilter:Array = null, forceSize:Boolean = false, addClickBlocker:Boolean = false, checkboxText:String = "")
      {
         m_dialogAsset = dialogAsset;
         this.m_icon = icon;
         this.m_disableIconResize = disableIconResize;
         this.m_forceSize = forceSize;
         super(message,type,closeCallback,m_dialogAsset,"",useHtmlText,addClickBlocker,showX);
         if(m_type == GenericPopup.TYPE_SHARECANCEL || m_type == GenericPopup.TYPE_SHARE)
         {
            m_acceptTextName = "ShareItem";
            m_cancelTextName = "Cancel";
         }
         if(m_type == GenericPopup.TYPE_BUY)
         {
            m_acceptTextName = GenericPopup.BUYNOW_TEXT_NAME;
         }
         if(Global.player.inExperimentFeedCheckBoxV2())
         {
            this.m_checkboxText = checkboxText;
            if(m_type == GenericPopup.TYPE_SHARECHECKBOX)
            {
               m_acceptTextName = "Continue";
            }
         }
         this.m_additionalText = additionalText;
      }
      
      public function get selected() : Boolean
      {
         return m_selected;
      }
      
      override protected function hideExtras() : void
      {
         if(m_window)
         {
            if(m_window.popupBox_mc)
            {
               if(m_window.popupBox_mc.okay_bt)
               {
                  m_window.popupBox_mc.okay_bt.visible = false;
               }
               if(m_window.popupBox_mc.bouquets_mc)
               {
                  m_window.popupBox_mc.bouquets_mc.visible = false;
               }
               if(m_window.popupBox_mc.share_bt)
               {
                  m_window.popupBox_mc.share_bt.visible = false;
               }
               if(m_window.popupBox_mc.cancel_bt)
               {
                  m_window.popupBox_mc.cancel_bt.visible = false;
               }
               if(m_window.popupBox_mc.ask_bt)
               {
                  m_window.popupBox_mc.ask_bt.visible = false;
               }
               if(m_window.popupBox_mc.buy_bt)
               {
                  m_window.popupBox_mc.buy_bt.visible = false;
               }
               if(Global.player.inExperimentFeedCheckBoxV2())
               {
                  if(m_window.popupBox_mc.checkbox_tf)
                  {
                     m_window.popupBox_mc.checkbox_tf.visible = false;
                  }
                  if(m_window.popupBox_mc.checkMark_mc)
                  {
                     this.m_checkMark = m_window.popupBox_mc.checkMark_mc as MovieClip;
                     this.m_checkMark.visible = false;
                  }
                  if(m_window.popupBox_mc.checkBox_mc)
                  {
                     this.m_checkBox = m_window.popupBox_mc.checkBox_mc as MovieClip;
                     this.m_checkBox.visible = false;
                  }
               }
            }
         }
         super.hideExtras();
      }
      
      override protected function setMessage() : void
      {
         super.setMessage();
      }
      
      protected function setIcon() : void
      {
         if(this.m_icon is String)
         {
            this.m_iconLoader = LoadingManager.load(this.m_icon as String,this.onIconLoaded);
         }
         else if(this.m_icon is DisplayObject)
         {
            this.handleContent(this.m_icon as DisplayObject);
         }
      }
      
      public function setSideCardText(text:String) : void
      {
         this.m_sideCardAdditionalText = text;
      }
      
      override protected function onLoadComplete() : void
      {
         var rg:TextField = null;
         var checkboxText:String = null;
         var format:TextFormat = null;
         m_window = m_loader.content as MovieClip;
         this.hideExtras();
         this.setMessage();
         m_accept = new GenericButton(m_window.popupBox_mc.okay_bt,onAccept);
         if(m_window)
         {
            if(m_window.popupBox_mc)
            {
               if(m_window.popupBox_mc.free_tf)
               {
                  if(this.m_additionalText != "")
                  {
                     m_window.free_tf.textColor = 16711680;
                     m_window.free_tf.text = this.m_additionalText;
                     m_window.free_tf.visible = true;
                  }
                  else
                  {
                     m_window.popupBox_mc.free_tf.visible = false;
                  }
               }
            }
         }
         if(m_type == TYPE_OK || m_type == TYPE_SHARE || m_type == TYPE_BUY)
         {
            if(m_window)
            {
               if(m_window.popupBox_mc)
               {
                  if(m_window.popupBox_mc.okay_bt)
                  {
                     m_window.popupBox_mc.okay_bt.visible = true;
                     m_window.popupBox_mc.okay_bt.x = (m_window.width - m_window.popupBox_mc.okay_bt.width) / 2;
                  }
               }
            }
         }
         else if(m_type == GenericPopup.TYPE_SHARECANCEL || m_type == GenericPopup.TYPE_ACCEPTCANCEL || m_type == GenericPopup.TYPE_YESNO)
         {
            if(m_window)
            {
               if(m_window.popupBox_mc)
               {
                  if(m_window.popupBox_mc.cancel_bt)
                  {
                     m_window.popupBox_mc.cancel_bt.visible = true;
                     m_reject = new GenericButton(m_window.popupBox_mc.cancel_bt,this.onCancel);
                     m_reject.text = ZLocUtils.t("Dialogs",m_cancelTextName);
                  }
                  if(m_window.popupBox_mc.okay_bt)
                  {
                     m_window.popupBox_mc.okay_bt.visible = false;
                  }
                  if(m_window.popupBox_mc.share_bt)
                  {
                     m_window.popupBox_mc.share_bt.visible = true;
                  }
                  if(m_window.popupBox_mc.share_bt)
                  {
                     m_window.popupBox_mc.share_bt.visible = true;
                     m_accept = new GenericButton(m_window.popupBox_mc.share_bt,onAccept);
                  }
               }
            }
         }
         else if(m_type == TYPE_ASKBUY)
         {
            if(m_window.popupBox_mc.ask_bt)
            {
               m_window.popupBox_mc.ask_bt.visible = true;
               m_accept = new GenericButton(m_window.popupBox_mc.ask_bt,onAccept);
            }
            if(m_window.popupBox_mc.buy_bt)
            {
               m_window.popupBox_mc.buy_bt.visible = true;
               m_reject = new GenericButton(m_window.popupBox_mc.buy_bt,this.onCancel);
               m_reject.text = ZLocUtils.t("Dialogs",m_cancelTextName);
            }
         }
         else if(Global.player.inExperimentFeedCheckBoxV2() && m_type == TYPE_SHARECHECKBOX)
         {
            if(m_window)
            {
               if(m_window.popupBox_mc)
               {
                  if(m_window.popupBox_mc.okay_bt)
                  {
                     m_window.popupBox_mc.okay_bt.visible = true;
                     m_window.popupBox_mc.okay_bt.x = (m_window.width - m_window.popupBox_mc.okay_bt.width) / 2;
                  }
                  if(m_window.popupBox_mc.checkMark_mc)
                  {
                     checkboxText = this.m_checkboxText;
                     m_window.popupBox_mc.checkbox_tf.visible = true;
                     m_window.popupBox_mc.checkbox_tf.text = checkboxText;
                     format = new TextFormat();
                     format.size = 12;
                     m_window.popupBox_mc.checkbox_tf.setTextFormat(format);
                     this.m_checkMark = m_window.popupBox_mc.checkMark_mc as MovieClip;
                     this.m_checkMark.mouseEnabled = true;
                     this.m_checkMark.visible = m_selected = true;
                     this.m_checkMark.addEventListener(MouseEvent.CLICK,this.onClick);
                     this.m_checkBox = m_window.popupBox_mc.checkBox_mc as MovieClip;
                     this.m_checkBox.addEventListener(MouseEvent.CLICK,this.onClick);
                     this.m_checkBox.visible = true;
                  }
               }
            }
         }
         m_accept.text = ZLocUtils.t("Dialogs",m_acceptTextName);
         this.setUpSideCard();
         setupCloseButton();
         this.setIcon();
         addChild(m_window);
      }
      
      protected function setUpSideCard() : void
      {
         if(Boolean(m_window) && Boolean(m_window.popupBox_mc) && Boolean(m_window.popupBox_mc.innovation_mc))
         {
            if(this.m_sideCardAdditionalText != "")
            {
               m_window.popupBox_mc.innovation_mc.visible = true;
               m_window.popupBox_mc.innovation_mc.count_tf.text = this.m_sideCardAdditionalText;
            }
         }
      }
      
      public function onClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = m_selected = !m_selected;
      }
      
      protected function onIconLoaded(event:Event) : void
      {
         var newIcon:DisplayObject = this.m_iconLoader.content;
         if(this.m_iconFilter != null)
         {
            newIcon.filters = this.m_iconFilter;
         }
         this.handleContent(newIcon);
      }
      
      protected function handleContent(newIcon:DisplayObject) : void
      {
         var iconMc:MovieClip = m_window.popupBox_mc.icon_mc;
         iconMc.scaleX = iconMc.scaleY = 1;
         while(iconMc.numChildren)
         {
            iconMc.removeChildAt(0);
         }
         if(!this.m_disableIconResize)
         {
            newIcon.scaleX = newIcon.scaleY = Math.min(1,newIcon.width / 50,newIcon.height / 50);
         }
         if(this.m_forceSize)
         {
            newIcon.width = MAX_ICON_SIZE;
            newIcon.height = MAX_ICON_SIZE;
         }
         newIcon.x = -newIcon.width / 2;
         newIcon.y = -newIcon.height / 2;
         iconMc.addChild(newIcon);
      }
      
      override protected function onClose(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_UI);
         super.onClose(event);
      }
      
      override protected function onCancel(event:MouseEvent) : void
      {
         super.onCancel(event);
      }
   }
}

