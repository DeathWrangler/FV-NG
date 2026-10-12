package Widgets.Windows
{
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class HoverOverWindow extends FarmWindow
   {
      
      public static const HOVERING_MENU_MOUSE_OVER_VARIANT:int = 1;
      
      public static const HOVERING_MENU_CLICK_VARIANT:int = 2;
      
      protected var m_offsetY:int = 0;
      
      protected var m_offsetX:int = 0;
      
      protected var m_originPoint:Point = null;
      
      protected var m_displayPoint:Point = null;
      
      private var m_viewPortRefreshIndex:uint = 0;
      
      protected var m_fadeOutTimer:Timer;
      
      private var m_recentlyOpened:Boolean = false;
      
      protected var m_timerTime:int = -1;
      
      public function HoverOverWindow(originPoint:Vector3, assetPath:String, timerTime:int = -1)
      {
         super(assetPath,false);
         this.updateOrigin(originPoint);
         this.m_timerTime = timerTime;
         if(this.m_timerTime > 0)
         {
            this.m_fadeOutTimer = new Timer(this.m_timerTime);
         }
         shouldFreeze = false;
      }
      
      protected function updateOrigin(originPoint:Vector3) : void
      {
         this.m_originPoint = new Point(originPoint.x,originPoint.y);
      }
      
      protected function updateTimerUse(timerTime:int = -1) : void
      {
         this.m_timerTime = timerTime;
         if(this.m_fadeOutTimer)
         {
            this.m_fadeOutTimer.removeEventListener(TimerEvent.TIMER,this.hideOnTimer);
         }
         if(timerTime > -1)
         {
            this.m_fadeOutTimer = new Timer(timerTime);
            this.m_fadeOutTimer.addEventListener(TimerEvent.TIMER,this.hideOnTimer);
         }
      }
      
      protected function alignWindowOrigin() : void
      {
         this.m_displayPoint = IsoMath.viewportToStage(IsoMath.tilePosToPixelPos(this.m_originPoint.x,this.m_originPoint.y));
         var posX:int = this.m_displayPoint.x - m_window.width / 2 - this.m_offsetX;
         var posY:int = this.m_displayPoint.y - m_window.height / 2 - this.m_offsetY;
         setAbsolutePos(posX,posY,true);
      }
      
      public function isShown() : Boolean
      {
         return m_shown;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.alignWindowOrigin();
         m_window.addEventListener(MouseEvent.ROLL_OUT,this.mouseOut);
         m_window.addEventListener(MouseEvent.ROLL_OVER,this.mouseOver);
         this.m_viewPortRefreshIndex = GlobalEngine.viewport.addRefreshCallback(this.alignWindowOrigin);
         if(this.m_timerTime > -1)
         {
            this.m_fadeOutTimer.addEventListener(TimerEvent.TIMER,this.hideOnTimer);
         }
         Global.stage.addEventListener(MouseEvent.CLICK,this.stageMouseClickHandler,false,0,true);
      }
      
      protected function stageMouseClickHandler(event:MouseEvent) : void
      {
         if(this.m_timerTime < 0)
         {
            if(!this.m_recentlyOpened)
            {
               hide();
            }
            this.m_recentlyOpened = false;
         }
      }
      
      protected function set recentlyOpened(value:Boolean) : void
      {
         this.m_recentlyOpened = value;
      }
      
      protected function mouseOut(e:MouseEvent) : void
      {
         if(Boolean(this.m_fadeOutTimer) && this.m_timerTime > -1)
         {
            this.m_fadeOutTimer.start();
         }
      }
      
      override public function show() : void
      {
         this.resetTimer();
         super.show();
      }
      
      protected function mouseOver(e:MouseEvent) : void
      {
         this.resetTimer();
      }
      
      private function resetTimer() : void
      {
         if(Boolean(this.m_fadeOutTimer) && this.m_fadeOutTimer.running)
         {
            this.m_fadeOutTimer.stop();
            this.m_fadeOutTimer.reset();
         }
      }
      
      private function hideOnTimer(event:TimerEvent) : void
      {
         this.m_fadeOutTimer.stop();
         hide();
      }
      
      override public function close() : void
      {
         GlobalEngine.viewport.removeRefreshCallback(this.m_viewPortRefreshIndex);
         Global.stage.removeEventListener(MouseEvent.CLICK,this.stageMouseClickHandler);
         m_window.removeEventListener(MouseEvent.ROLL_OUT,this.mouseOut);
         m_window.removeEventListener(MouseEvent.ROLL_OVER,this.mouseOver);
         this.m_fadeOutTimer.removeEventListener(TimerEvent.TIMER,this.hideOnTimer);
         this.m_fadeOutTimer = null;
         super.close();
      }
   }
}

