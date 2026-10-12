package Display.Quests
{
   import Classes.EmbeddedArt;
   import com.greensock.TweenLite;
   import com.greensock.plugins.FramePlugin;
   import com.greensock.plugins.TweenPlugin;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class QuestProgressBar extends Sprite
   {
      
      private static const PROGRESS_BAR_ANIMATION_TIME_IN_SECONDS:int = 2;
      
      private static const PROGRESS_BAR_SHOW_TIME_IN_MILLISECONDS:int = 5000;
      
      private static const BAR_ANIMATION_CONTENT_NAME:String = "bar_mc";
      
      private static const PROGRESS_EFFECT_CONTENT_NAME:String = "progressEffect_mc";
      
      public static const ANIMATION_COMPLETE_EVENT:String = "Progress_Bar_Animation_Complete";
      
      private var m_progressBarAsset:Object = null;
      
      private var m_progressBarShowTimer:Timer = null;
      
      public function QuestProgressBar(xPos:Number = 0, yPos:Number = 0, xScale:Number = 1, yScale:Number = 1)
      {
         super();
         this.x = xPos;
         this.y = yPos;
         this.scaleX = xScale;
         this.scaleY = yScale;
         this.m_progressBarAsset = new EmbeddedArt.questProgressBar();
         var progressBarDisplayObject:DisplayObject = this.m_progressBarAsset as DisplayObject;
         addChild(progressBarDisplayObject);
      }
      
      public function playAnimation(questProgressByTask:Number, shouldPlaySpecialEffect:Boolean = true) : void
      {
         var bar_mc:MovieClip = null;
         if(!this.m_progressBarAsset.visible)
         {
            this.showProgressBar();
         }
         else
         {
            this.clearProgressBarTimer();
         }
         TweenPlugin.activate([FramePlugin]);
         if(this.m_progressBarAsset.hasOwnProperty(BAR_ANIMATION_CONTENT_NAME))
         {
            bar_mc = this.m_progressBarAsset.bar_mc;
            TweenLite.to(bar_mc,PROGRESS_BAR_ANIMATION_TIME_IN_SECONDS,{
               "frame":int(questProgressByTask * (bar_mc.totalFrames - 1)),
               "onComplete":this.progressBarAnimationOnComplete
            });
         }
         if(this.m_progressBarAsset.hasOwnProperty(PROGRESS_EFFECT_CONTENT_NAME) && shouldPlaySpecialEffect)
         {
            this.m_progressBarAsset.progressEffect_mc.addFrameScript(this.m_progressBarAsset.progressEffect_mc.totalFrames - 1,this.stopMe);
            this.m_progressBarAsset.progressEffect_mc.gotoAndPlay(2);
         }
         else
         {
            this.stopMe();
         }
      }
      
      private function stopMe() : void
      {
         if(this.m_progressBarAsset.hasOwnProperty(PROGRESS_EFFECT_CONTENT_NAME))
         {
            this.m_progressBarAsset.progressEffect_mc.stop();
         }
      }
      
      private function progressBarAnimationOnComplete() : void
      {
         dispatchEvent(new Event(ANIMATION_COMPLETE_EVENT));
      }
      
      private function clearProgressBarTimer() : void
      {
         if(this.m_progressBarShowTimer)
         {
            this.m_progressBarShowTimer.removeEventListener(TimerEvent.TIMER,this.hideProgressBar);
            this.m_progressBarShowTimer.stop();
         }
      }
      
      public function showProgressBar() : void
      {
         this.clearProgressBarTimer();
         if(this.m_progressBarAsset)
         {
            this.m_progressBarAsset.visible = true;
         }
      }
      
      public function hideProgressBar(event:Event = null) : void
      {
         this.clearProgressBarTimer();
         if(this.m_progressBarAsset)
         {
            this.m_progressBarAsset.visible = false;
         }
      }
      
      public function hideProgressBarWithDelay() : void
      {
         this.m_progressBarShowTimer = new Timer(PROGRESS_BAR_SHOW_TIME_IN_MILLISECONDS,1);
         this.m_progressBarShowTimer.addEventListener(TimerEvent.TIMER,this.hideProgressBar);
         this.m_progressBarShowTimer.start();
      }
   }
}

