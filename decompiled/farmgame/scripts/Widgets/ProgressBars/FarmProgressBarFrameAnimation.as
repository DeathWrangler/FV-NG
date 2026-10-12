package Widgets.ProgressBars
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmProgressBarFrameAnimation extends FarmProgressBar
   {
      
      protected static const BAR_INSTANCE_NAME:String = "";
      
      public function FarmProgressBarFrameAnimation(element:DisplayObject)
      {
         super(element);
      }
      
      override public function getBarInstanceName() : String
      {
         return BAR_INSTANCE_NAME;
      }
      
      private function frameAnimationCallback(event:Event) : void
      {
         var currentPercentComplete:Number = (m_progress - m_minimum) / m_maximum;
         var mc:MovieClip = m_bar as MovieClip;
         if(mc)
         {
            if(mc.currentFrame >= int(currentPercentComplete * (mc.totalFrames - 1) + 1))
            {
               mc.stop();
               m_oldProgress = m_progress;
               mc.removeEventListener(Event.ENTER_FRAME,this.frameAnimationCallback);
            }
            else
            {
               mc.play();
            }
         }
      }
      
      override protected function update() : void
      {
         var oldPercentComplete:Number = (m_oldProgress - m_minimum) / m_maximum;
         var currentPercentComplete:Number = (m_progress - m_minimum) / m_maximum;
         var mc:MovieClip = m_bar as MovieClip;
         if(animated)
         {
            if(mc.hasEventListener(Event.ENTER_FRAME) == false)
            {
               mc.addEventListener(Event.ENTER_FRAME,this.frameAnimationCallback);
            }
            mc.gotoAndPlay(int(oldPercentComplete * ((m_bar as MovieClip).totalFrames - 1) + 1));
            flashProgressBar();
         }
         else
         {
            m_oldProgress = m_progress;
            mc.gotoAndStop(int(currentPercentComplete * ((m_bar as MovieClip).totalFrames - 1) + 1));
         }
      }
      
      override public function release() : void
      {
         var mc:MovieClip = m_bar as MovieClip;
         if(mc)
         {
            if(mc.hasEventListener(Event.ENTER_FRAME) == true)
            {
               mc.removeEventListener(Event.ENTER_FRAME,this.frameAnimationCallback);
            }
         }
         super.release();
      }
   }
}

