package Display
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GenericPopupTitle extends GenericPopup
   {
      
      protected var m_title:String;
      
      protected var m_dialogAlreadyLocalized:Boolean;
      
      protected var m_centerIconUrl:String;
      
      protected var m_leftIconUrl:String;
      
      protected var m_rightIconUrl:String;
      
      protected var m_centerIconLoader:Loader;
      
      protected var m_leftIconLoader:Loader;
      
      protected var m_rightIconLoader:Loader;
      
      protected var m_centerIconYDisplacement:int = 0;
      
      protected var m_centerIconScale:Number = 0.5;
      
      public function GenericPopupTitle(title:String, message:String, dialogAlreadyLocalized:Boolean = false, type:int = 0, closeCallback:Function = null, dialogAsset:String = "assets/dialogs/FV_Valentines_congrats.swf")
      {
         super(message,type,closeCallback,dialogAsset);
         this.m_title = title;
         this.m_dialogAlreadyLocalized = dialogAlreadyLocalized;
      }
      
      public function setIcons(leftIconUrl:String = null, rightIconUrl:String = null, centerIconUrl:String = null) : void
      {
         this.m_leftIconUrl = leftIconUrl;
         this.m_rightIconUrl = rightIconUrl;
         this.m_centerIconUrl = centerIconUrl;
      }
      
      public function setCenterIconVerticalDisplacement(numPixels:int) : void
      {
         this.m_centerIconYDisplacement = numPixels;
      }
      
      public function setCenterIconScale(scale:Number) : void
      {
         this.m_centerIconScale = scale;
      }
      
      override protected function onLoadComplete() : void
      {
         var bodyText:String = null;
         var buttonBounds:* = undefined;
         var registrationPointOffset:Number = NaN;
         var data:Array = [];
         m_window = m_loader.content as MovieClip;
         var showAcceptButton:Boolean = true;
         var showCancelButton:Boolean = true;
         switch(m_type)
         {
            case TYPE_OK:
               buttonBounds = m_window.goldPopUp_mc.accept_bt.getBounds(m_window.goldPopUp_mc);
               registrationPointOffset = buttonBounds.width / 2 - buttonBounds.left;
               m_window.goldPopUp_mc.accept_bt.x = (m_window.width - m_window.goldPopUp_mc.accept_bt.width) / 2 + registrationPointOffset;
               showCancelButton = false;
               break;
            case TYPE_MODAL:
               showAcceptButton = false;
               showCancelButton = false;
               break;
            case TYPE_SHARECANCEL:
               m_acceptTextName = "GenericShareButton";
         }
         if(!showAcceptButton)
         {
            m_window.goldPopUp_mc.accept_bt.visible = false;
         }
         if(!showCancelButton)
         {
            m_window.goldPopUp_mc.cancel_bt.visible = false;
         }
         m_accept = new GenericButton(m_window.goldPopUp_mc.accept_bt,onAccept);
         m_accept.text = ZLocUtils.t("Dialogs",m_acceptTextName);
         m_reject = new GenericButton(m_window.goldPopUp_mc.cancel_bt,onCancel);
         m_reject.text = ZLocUtils.t("Dialogs",m_cancelTextName);
         if(this.m_dialogAlreadyLocalized)
         {
            m_window.goldPopUp_mc.goldTitle_tf.text = this.m_title;
            bodyText = m_message;
         }
         else
         {
            m_window.goldPopUp_mc.goldTitle_tf.text = ZLocUtils.t("Dialogs",this.m_title);
            bodyText = ZLocUtils.t("Dialogs",m_message);
         }
         if(bodyText)
         {
            m_window.goldPopUp_mc.popupBox_tf.text = bodyText;
            ZLocUtils.autoFormatSize(m_window.goldPopUp_mc.popupBox_tf);
         }
         if(this.m_centerIconUrl)
         {
            this.m_centerIconLoader = LoadingManager.load(this.m_centerIconUrl,this.onCenterIconLoaded);
         }
         if(this.m_leftIconUrl)
         {
            this.m_leftIconLoader = LoadingManager.load(this.m_leftIconUrl,this.onLeftIconLoaded);
         }
         if(this.m_rightIconUrl)
         {
            this.m_rightIconLoader = LoadingManager.load(this.m_rightIconUrl,this.onRightIconLoaded);
         }
         addChild(m_window);
      }
      
      protected function onCenterIconLoaded(event:Event) : void
      {
         var iconMc:MovieClip = m_window.goldPopUp_mc.icon;
         iconMc.scaleX = iconMc.scaleY = this.m_centerIconScale;
         while(iconMc.numChildren)
         {
            iconMc.removeChildAt(0);
         }
         var newIcon:DisplayObject = this.m_centerIconLoader.content;
         newIcon.x = newIcon.width / 5;
         if(0 == this.m_centerIconYDisplacement)
         {
            newIcon.y = -newIcon.height / 7;
         }
         else
         {
            newIcon.y = this.m_centerIconYDisplacement;
         }
         iconMc.addChild(newIcon);
      }
      
      protected function onLeftIconLoaded(event:Event) : void
      {
         this.setupSideIcon(m_window.goldPopUp_mc.eventIconLeft_mc,this.m_leftIconLoader);
      }
      
      protected function onRightIconLoaded(event:Event) : void
      {
         this.setupSideIcon(m_window.goldPopUp_mc.eventIconRight_mc,this.m_rightIconLoader,-0.1);
      }
      
      protected function setupSideIcon(iconMc:MovieClip, iconLoader:Loader, horizDisplacementScale:Number = 0) : void
      {
         iconMc.scaleX = iconMc.scaleY = 0.7;
         while(iconMc.numChildren)
         {
            iconMc.removeChildAt(0);
         }
         var newIcon:DisplayObject = iconLoader.content;
         newIcon.x = newIcon.width * horizDisplacementScale;
         newIcon.y = newIcon.height / 4;
         iconMc.addChild(newIcon);
      }
   }
}

