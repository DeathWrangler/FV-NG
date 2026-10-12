package Widgets.Windows
{
   import Engine.Utilities;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.geom.Point;
   import flash.text.TextFieldAutoSize;
   import gs.TweenLite;
   
   public class FeedPostCompleteToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 4000;
      
      protected static const DEFAULT_SHOW_TWEEN_TIME:Number = 0.5;
      
      protected static const DEFAULT_HIDE_TWEEN_TIME:Number = 2;
      
      private static const DEFAULT_XOFFSET:int = 35;
      
      protected var m_text:String;
      
      protected var m_iconUrl:String;
      
      protected var m_iconScale:Number = 1;
      
      protected var m_iconOffset:Point = null;
      
      protected var m_toasterAssetPath:String = "assets/dialogs/FV_FeedComplete.swf";
      
      protected var m_copy1TextField:ZwTextField;
      
      public function FeedPostCompleteToasterWindow(text:String, iconUrl:String = null, iconOffset:Point = null, windowAssetPath:String = null)
      {
         if(windowAssetPath)
         {
            this.m_toasterAssetPath = windowAssetPath;
         }
         super(this.m_toasterAssetPath);
         this.m_text = text;
         this.m_iconUrl = iconUrl;
         this.m_iconOffset = iconOffset;
         m_allowToasterManangerToClose = false;
         m_timeToLive = DEFAULT_TIME_TO_LIVE;
      }
      
      override protected function postLoadComplete() : void
      {
         var icon:FarmIcon = null;
         super.postLoadComplete();
         var frame:ZwFrame = new ZwFrame(m_window);
         m_window.copy1_tf.autoSize = TextFieldAutoSize.CENTER;
         this.m_copy1TextField = new ZwTextField(m_window.copy1_tf,this.m_text);
         frame.addWidget(this.m_copy1TextField);
         if(this.m_iconUrl != null && this.m_iconUrl != "")
         {
            icon = new FarmIcon(m_window.icon_mc,this.m_iconUrl);
            icon.setIconSize(55,55);
            frame.addWidget(icon);
         }
         if(this.m_iconOffset != null)
         {
            m_window.icon_mc.x += this.m_iconOffset.x;
            m_window.icon_mc.y += this.m_iconOffset.y;
         }
         addWidget(frame);
      }
      
      protected function getToasterWidth() : Number
      {
         return m_window.width;
      }
      
      override protected function showTween() : void
      {
         var tweenParams:Object = null;
         if(m_window)
         {
            Utilities.toggleInputAndChildren(m_window,false);
            this.x = GlobalEngine.stage.stageWidth;
            this.y = (GlobalEngine.stage.stageHeight - this.getToasterHeight()) / 2;
            Global.ui.swapToasterDepth(this,false);
            tweenParams = {
               "x":-1 * this.getToasterWidth() + this.xOffset,
               "alpha":1,
               "onComplete":showTweenComplete
            };
            TweenLite.to(m_window,DEFAULT_SHOW_TWEEN_TIME,tweenParams);
         }
      }
      
      protected function get xOffset() : int
      {
         return DEFAULT_XOFFSET;
      }
      
      override protected function hideTween(callback:Function) : void
      {
         var tweenParams:Object = null;
         if(m_window)
         {
            m_timer.stop();
            Utilities.toggleInputAndChildren(m_window,false);
            Global.ui.swapToasterDepth(this,false);
            if(m_loader == null || m_loader.content == null)
            {
               if(callback != null)
               {
                  callback();
               }
            }
            else
            {
               tweenParams = {
                  "x":1 * this.getToasterWidth(),
                  "alpha":0,
                  "onComplete":callback
               };
               TweenLite.to(m_window,DEFAULT_HIDE_TWEEN_TIME,tweenParams);
            }
         }
      }
   }
}

