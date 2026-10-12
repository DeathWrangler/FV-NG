package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.GenericButton;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextFormat;
   
   public class GenericNumberSelectionWindow extends FarmWindow
   {
      
      public static const DEFAULT_MAX_VALUE:Number = 99;
      
      public static const DIALOG_ASSET:String = "assets/dialogs/FV_Feature_Callout.swf";
      
      public static const TWEEN_TIME:Number = 0.5;
      
      protected static var m_isOpen:Boolean = false;
      
      protected var m_accept:GenericButton;
      
      protected var m_reject:GenericButton;
      
      protected var m_maxValue:int = 99;
      
      protected var m_quantityTextField:ZwTextField;
      
      protected var m_item:Object = null;
      
      protected var m_iconFrame:ZwFrame;
      
      protected var m_type:int = 4;
      
      protected var m_bodyText:String = "";
      
      protected var m_units:String = "";
      
      protected var m_centerIcon:Boolean = false;
      
      protected var m_nudgeIcon:Point = null;
      
      protected var m_SharedCallBack:Function;
      
      public function GenericNumberSelectionWindow(item:Object, sharedCallBack:Function, message:String, maximum:int = 99, asset:String = "assets/dialogs/FV_Feature_Callout.swf", unitName:String = null, centerIcon:Boolean = false, nudgeIcon:Point = null)
      {
         super(asset);
         this.m_SharedCallBack = sharedCallBack;
         this.m_item = item;
         this.m_bodyText = message;
         this.m_units = null == unitName ? ZLocUtils.t("Dialogs","Bushel_Plural") : unitName;
         this.m_maxValue = maximum;
         m_isOpen = true;
         this.m_centerIcon = centerIcon;
         this.m_nudgeIcon = nudgeIcon;
      }
      
      public static function get isOpen() : Boolean
      {
         return m_isOpen;
      }
      
      override protected function createLoader(url:String, onLoadCallback:Function) : Loader
      {
         return LoadingManager.load(url,onLoadCallback);
      }
      
      override protected function postLoadComplete() : void
      {
         LoadingManager.load(this.m_item.icon,this.onIconLoaded);
         addWidget(new ZwFrame(m_window.popupBox_mc));
         var bodyTextField:ZwTextField = new ZwTextField(m_window.popupBox_mc.popupBox_tf,this.m_bodyText);
         var textFormat:TextFormat = bodyTextField.getTextFormat();
         textFormat.align = "center";
         bodyTextField.setTextFormat(textFormat);
         addWidget(bodyTextField);
         this.m_iconFrame = new ZwFrame(m_window.popupBox_mc.icon_mc);
         addWidget(this.m_iconFrame);
         addWidget(new ZwFrame(m_window.popupBox_mc.bouquets_mc));
         addWidget(new ZwTextField(m_window.popupBox_mc.bouquets_mc.bouquets_tf,this.m_units));
         this.m_quantityTextField = new ZwTextField(m_window.popupBox_mc.bouquets_mc.number_tf,"");
         addWidget(this.m_quantityTextField);
         addWidget(new ZwButton(m_window.popupBox_mc.bouquets_mc.arrowUp_bt,this.onUpArrowClick));
         addWidget(new ZwButton(m_window.popupBox_mc.bouquets_mc.arrowDown_bt,this.onDownArrowClick));
         this.displayQuantity(1);
         this.setShareButton();
         m_window.popupBox_mc.cancel_bt.visible = true;
         this.m_reject = new GenericButton(m_window.popupBox_mc.cancel_bt,this.onCancelClicked);
         this.m_reject.text = ZLocUtils.t("Dialogs","Cancel");
      }
      
      protected function setShareButton() : void
      {
         switch(this.m_type)
         {
            case GenericPopup.TYPE_SHARECANCEL:
               m_window.popupBox_mc.share_bt.visible = true;
               this.m_accept = new GenericButton(m_window.popupBox_mc.share_bt,this.onShareClicked);
               this.m_accept.text = ZLocUtils.t("Dialogs","ShareItem");
               break;
            case GenericPopup.TYPE_TRADECANCEL:
               m_window.popupBox_mc.share_bt.visible = true;
               this.m_accept = new GenericButton(m_window.popupBox_mc.share_bt,this.onShareClicked);
               this.m_accept.text = ZLocUtils.t("Dialogs","Buy");
         }
      }
      
      protected function onUpArrowClick(e:MouseEvent) : void
      {
         var amount:int = this.currentQuantitySelected + 1 <= this.m_maxValue ? int(this.currentQuantitySelected + 1) : this.m_maxValue;
         this.m_quantityTextField.text = String(amount);
      }
      
      protected function onDownArrowClick(e:MouseEvent) : void
      {
         var amount:int = this.currentQuantitySelected - 1 > 1 ? int(this.currentQuantitySelected - 1) : 1;
         this.m_quantityTextField.text = String(amount);
      }
      
      protected function get currentQuantitySelected() : int
      {
         return int(this.m_quantityTextField.text);
      }
      
      protected function displayQuantity(value:int) : void
      {
         this.m_quantityTextField.text = String(value);
      }
      
      protected function onShareClicked(e:MouseEvent) : void
      {
         if(this.m_SharedCallBack != null)
         {
            this.m_SharedCallBack(this.m_item.code,this.currentQuantitySelected);
         }
         this.close();
      }
      
      protected function onCancelClicked(e:MouseEvent) : void
      {
         this.close();
      }
      
      protected function onIconLoaded(event:Event) : void
      {
         var newIcon:DisplayObject = null;
         if(this.m_iconFrame)
         {
            this.m_iconFrame.element.scaleX = this.m_iconFrame.element.scaleY = 1;
            while(this.m_iconFrame.element.numChildren)
            {
               this.m_iconFrame.element.removeChildAt(0);
            }
            newIcon = event.currentTarget.content;
            if(this.m_centerIcon || this.m_windowAssetPath == GenericNumberSelectionWindow.DIALOG_ASSET)
            {
               newIcon.x = -newIcon.width / 2;
               newIcon.y = -newIcon.height / 2;
            }
            if(this.m_nudgeIcon != null)
            {
               newIcon.x += this.m_nudgeIcon.x;
               newIcon.y += this.m_nudgeIcon.y;
            }
            this.m_iconFrame.element.addChild(newIcon);
         }
      }
      
      override public function close() : void
      {
         var dispObj:DisplayObject = this;
         this.release();
         dispatchEvent(new Event(Event.CLOSE));
         this.onHide();
      }
      
      override public function show() : void
      {
         if(this.m_isLoaded)
         {
            this.visible = true;
            centerPopup();
            this.onShow();
         }
         else
         {
            m_showOnLoad = true;
         }
      }
      
      override public function hide() : void
      {
         this.visible = false;
         this.onHide();
      }
      
      override protected function onShow() : void
      {
         if(m_shown == false)
         {
            m_cursorId = UI.setCursor(null);
            Utilities.toggleInputAndChildren(this,true);
            m_shown = true;
            Global.stage.addEventListener(FullScreenEvent.FULL_SCREEN,onFullScreen);
            Global.stage.addEventListener(Event.RESIZE,onResize);
         }
         else
         {
            m_showOnLoad = true;
         }
         SoundManager.playSound("dialogSpawn");
      }
      
      override protected function onHide() : void
      {
         if(m_shown == true)
         {
            m_shown = false;
            Utilities.toggleInputAndChildren(this,false);
            UI.removeCursor(m_cursorId);
            Global.stage.removeEventListener(FullScreenEvent.FULL_SCREEN,onFullScreen);
            Global.stage.removeEventListener(Event.RESIZE,onResize);
         }
         m_showOnLoad = false;
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_quantityTextField = null;
         this.m_iconFrame = null;
         this.m_item = null;
         this.m_accept = null;
         this.m_reject = null;
      }
   }
}

