package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextFieldAutoSize;
   
   public class ShareButtonToasterWindow extends IconTitleToasterWindow
   {
      
      private static var CLOSE:String = "ShareButtonToaster_Close";
      
      protected var m_cancelCallback:Function;
      
      protected var m_actionButtonText:String = null;
      
      private const DIALOG_ASSET:String = "assets/dialogs/FV_BannerAd_Rewards_generic.swf";
      
      private var m_frame:ZwFrame;
      
      private var m_closeOnClickOnly:Boolean;
      
      public function ShareButtonToasterWindow(title:String, text:String, iconUrl:String, windowAssetPath:String = "assets/dialogs/FV_BannerAd_Rewards_generic.swf", iconScale:Number = 1, iconOffset:Point = null, clickCallback:Function = null, cancelCallback:Function = null, actionButtonText:String = null, closeOnClickOnly:Boolean = false)
      {
         super(title,text,iconUrl,windowAssetPath,iconScale,iconOffset,clickCallback);
         this.m_cancelCallback = cancelCallback;
         this.m_actionButtonText = actionButtonText;
         this.m_closeOnClickOnly = closeOnClickOnly;
         if(this.m_cancelCallback != null)
         {
            addEventListener(ShareButtonToasterWindow.CLOSE,this.m_cancelCallback);
         }
      }
      
      override public function show() : void
      {
         super.show();
         if(this.m_closeOnClickOnly)
         {
            m_timer.stop();
            m_timer.removeEventListener(TimerEvent.TIMER,onTimer);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var frame:ZwFrame = new ZwFrame(m_window.bannerad_mc);
         frame.addWidget(new ZwButton(m_window.bannerad_mc.close_bt,onClose));
         var icon:FarmIcon = frame.addWidget(new FarmIcon(m_window.bannerad_mc.icon_mc)) as FarmIcon;
         if(m_iconUrl)
         {
            icon.loadIcon(m_iconUrl);
         }
         m_window.bannerad_mc.icon_mc.scaleX = m_iconScale;
         m_window.bannerad_mc.icon_mc.scaleY = m_iconScale;
         if(m_iconOffset != null)
         {
            m_window.bannerad_mc.icon_mc.x += m_iconOffset.x;
            m_window.bannerad_mc.icon_mc.y += m_iconOffset.y;
         }
         m_window.bannerad_mc.generic_desc_tf.autoSize = TextFieldAutoSize.CENTER;
         frame.addWidget(new ZwTextField(m_window.bannerad_mc.generic_tf,m_title));
         frame.addWidget(new ZwTextField(m_window.bannerad_mc.generic_desc_tf,m_text));
         if(this.m_actionButtonText)
         {
            frame.addWidget(new FarmAnimatedTextButton(m_window.bannerad_mc.buy_bt,this.m_actionButtonText));
         }
         m_window.bannerad_mc.icon_mc.scaleX = m_iconScale;
         m_window.bannerad_mc.icon_mc.scaleY = m_iconScale;
         if(m_iconOffset != null)
         {
            m_window.bannerad_mc.icon_mc.x += m_iconOffset.x;
            m_window.bannerad_mc.icon_mc.y += m_iconOffset.y;
         }
         addWidget(frame);
         frame.registerEventListener(MouseEvent.CLICK,this.onClickShare);
         this.m_frame = frame;
      }
      
      private function onClickShare(evt:MouseEvent) : void
      {
         if(hasEventListener(ShareButtonToasterWindow.CLOSE))
         {
            removeEventListener(ShareButtonToasterWindow.CLOSE,this.m_cancelCallback);
         }
         if(this.m_frame.hasEventListener(MouseEvent.CLICK))
         {
            this.m_frame.removeEventListener(MouseEvent.CLICK,this.onClickShare);
         }
         if(m_clickCallback != null)
         {
            m_clickCallback();
         }
         this.close();
      }
      
      override public function close() : void
      {
         if(m_showTween)
         {
            hideTween(function():void
            {
               if(m_cancelCallback != null)
               {
                  dispatchEvent(new Event(ShareButtonToasterWindow.CLOSE));
                  removeEventListener(ShareButtonToasterWindow.CLOSE,m_cancelCallback);
               }
               release();
               dispatchEvent(new Event(Event.CLOSE));
            });
            onHide();
         }
         else
         {
            onHide();
            release();
            dispatchEvent(new Event(Event.CLOSE));
         }
      }
   }
}

