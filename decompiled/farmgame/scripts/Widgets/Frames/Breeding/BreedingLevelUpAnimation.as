package Widgets.Frames.Breeding
{
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BreedingLevelUpAnimation extends ZwFrame
   {
      
      private var m_levelupAnimation:MovieClip = null;
      
      private var m_featureName:String = "";
      
      public function BreedingLevelUpAnimation(element:DisplayObject, featureName:String)
      {
         super(element);
         this.m_levelupAnimation = this.m_element.prizeAnimation_mc as MovieClip;
         this.m_featureName = featureName;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_levelupAnimation.stop();
         this.m_levelupAnimation.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.m_levelupAnimation = null;
      }
      
      public function playAnimation() : void
      {
         if(this.m_levelupAnimation != null)
         {
            this.m_levelupAnimation.visible = true;
            this.m_levelupAnimation.gotoAndPlay(0);
            this.m_levelupAnimation.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(this.m_element.currentFrame == this.m_element.totalFrames)
         {
            if(this.m_levelupAnimation != null)
            {
               this.m_levelupAnimation.stop();
               this.m_levelupAnimation.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
               this.m_levelupAnimation.visible = false;
            }
         }
      }
   }
}

