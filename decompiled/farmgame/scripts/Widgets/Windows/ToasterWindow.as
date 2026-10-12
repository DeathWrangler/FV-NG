package Widgets.Windows
{
   import Engine.Utilities;
   import flash.events.Event;
   import flash.geom.Point;
   import gs.TweenLite;
   
   public class ToasterWindow extends FarmWindow
   {
      
      protected static const POPUP_NAME:String = "toaster";
      
      protected static const DEFAULT_SHOW_TWEEN_TIME:Number = 2;
      
      protected static const DEFAULT_HIDE_TWEEN_TIME:Number = 2;
      
      protected var m_toasterYOffset:Number = 120;
      
      protected var m_showTweenTime:Number = 2;
      
      protected var m_hideTweenTime:Number = 2;
      
      protected var m_allowToasterManangerToClose:Boolean = true;
      
      private var m_pauseable:Boolean = true;
      
      public function ToasterWindow(windowAssetPath:String)
      {
         super(windowAssetPath,false);
         this.name = POPUP_NAME;
         m_showTween = true;
      }
      
      override protected function onClose(event:Event) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         super.onClose(event);
         this.postClose();
      }
      
      override protected function showTween() : void
      {
         var tweenParams:Object = null;
         if(m_window)
         {
            Utilities.toggleInputAndChildren(m_window,false);
            this.positionToasterWindow();
            this.setToasterDepth();
            tweenParams = {
               "y":-1 * this.getToasterHeight(),
               "alpha":1,
               "onComplete":this.showTweenComplete
            };
            TweenLite.to(m_window,this.m_showTweenTime,tweenParams);
         }
      }
      
      protected function setToasterDepth() : void
      {
         Global.ui.swapToasterDepth(this,false);
      }
      
      protected function getToasterOffsetY() : Number
      {
         return this.m_toasterYOffset;
      }
      
      public function setToasterOffsetY(toasterOffsetY:Number) : void
      {
         this.m_toasterYOffset = toasterOffsetY;
      }
      
      protected function getToasterHeight() : Number
      {
         return m_window.height;
      }
      
      override protected function hideTween(callback:Function) : void
      {
         var tweenParams:Object = null;
         if(m_window)
         {
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
                  "y":this.getToasterHeight() / 2,
                  "alpha":0,
                  "onComplete":callback
               };
               TweenLite.to(m_window,this.m_hideTweenTime,tweenParams);
            }
         }
      }
      
      protected function showTweenComplete() : void
      {
         if(m_window)
         {
            Utilities.toggleInputAndChildren(m_window,true);
            Global.ui.swapToasterDepth(this,true);
         }
         this.postShow();
      }
      
      override public function centerPopup(pAbsolutePos:Point = null) : void
      {
         this.positionToasterWindow();
      }
      
      protected function positionToasterWindow() : void
      {
         this.x = GlobalEngine.stage.stageWidth - this.m_window.width >> 1;
         this.y = GlobalEngine.stage.stageHeight - this.getToasterOffsetY();
      }
      
      protected function postShow() : void
      {
      }
      
      protected function postClose() : void
      {
      }
      
      override public function get shouldFreeze() : Boolean
      {
         return false;
      }
      
      public function get allowToasterManangerToClose() : Boolean
      {
         return this.m_allowToasterManangerToClose;
      }
      
      public function get isPauseable() : Boolean
      {
         return this.m_pauseable;
      }
      
      public function set isPauseable(pauseable:Boolean) : void
      {
         this.m_pauseable = pauseable;
      }
   }
}

