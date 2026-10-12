package Widgets.Tooltips
{
   import Widgets.Core.Tooltips.ZwAbstractTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MovieClipTooltip extends ZwAbstractTooltip
   {
      
      public static const DEFAULT_SHOW_FRAME_NUM:int = 2;
      
      public static const DEFAULT_HIDE_FRAME_NUM:int = 1;
      
      protected var m_showFrameNum:int;
      
      protected var m_hideFrameNum:int;
      
      protected var m_targetFrame:int;
      
      protected var m_element:MovieClip;
      
      public function MovieClipTooltip(element:MovieClip, showFrameNum:int = 2, hideFrameNum:int = 1)
      {
         super();
         this.m_showFrameNum = showFrameNum;
         this.m_hideFrameNum = hideFrameNum;
         this.m_element = element;
      }
      
      override protected function updatePosition(event:MouseEvent) : void
      {
      }
      
      override protected function show(event:MouseEvent) : void
      {
         this.m_targetFrame = this.m_showFrameNum;
         this.m_element.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      override protected function hide(event:MouseEvent) : void
      {
         this.m_targetFrame = this.m_hideFrameNum;
         this.m_element.addEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      override public function release() : void
      {
         this.m_element.removeEventListener(Event.ENTER_FRAME,this.onFrame);
         this.m_element = null;
         super.release();
      }
      
      private function onFrame(event:Event) : void
      {
         var currentFrame:int = 0;
         if(this.m_element)
         {
            currentFrame = this.m_element.currentFrame;
            if(currentFrame < this.m_targetFrame && currentFrame < this.m_element.totalFrames)
            {
               this.m_element.gotoAndStop(++currentFrame);
            }
            else if(currentFrame > this.m_targetFrame && currentFrame > 1)
            {
               this.m_element.gotoAndStop(--currentFrame);
            }
            else
            {
               this.m_element.removeEventListener(Event.ENTER_FRAME,this.onFrame);
            }
            if(currentFrame == this.m_hideFrameNum)
            {
               this.onHideComplete();
            }
            else if(currentFrame == this.m_showFrameNum)
            {
               this.onShowComplete();
            }
         }
      }
      
      protected function onShowComplete() : void
      {
      }
      
      protected function onHideComplete() : void
      {
      }
   }
}

