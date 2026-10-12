package Classes.util
{
   import Events.MovieClipEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   [Event(name="loopComplete",type="Events.MovieClipEvent")]
   public class MovieClipAnimation extends EventDispatcher
   {
      
      private var m_mc:MovieClip;
      
      private var m_frame:int;
      
      private var m_frameCount:int;
      
      private var m_loop:Boolean;
      
      private var m_startFrame:int;
      
      public function MovieClipAnimation(mc:MovieClip, startFrame:int = 1, loop:Boolean = true, usePerfectLoop:Boolean = true)
      {
         super();
         if(mc == null)
         {
            throw new Error("Cannot wrap a null MovieClip");
         }
         this.m_mc = mc;
         this.m_frame = startFrame;
         this.m_frameCount = usePerfectLoop ? int(FarmGameUtil.getFramesInPerfectLoop(this.m_mc)) : this.m_mc.totalFrames;
         this.m_loop = loop;
         this.m_startFrame = startFrame;
         this.stop();
      }
      
      private function onEnterFrame(ev:Event) : void
      {
         if(++this.m_frame >= this.m_frameCount)
         {
            if(!this.m_loop)
            {
               this.stop();
            }
            this.m_frame = this.m_startFrame;
            dispatchEvent(new MovieClipEvent(MovieClipEvent.LOOP_COMPLETE));
         }
      }
      
      public function play() : void
      {
         if(this.m_mc)
         {
            this.m_mc.addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
            this.m_mc.play();
         }
      }
      
      public function restart() : void
      {
         if(this.m_mc)
         {
            this.m_mc.gotoAndStop(this.m_startFrame);
         }
         this.play();
      }
      
      public function stop() : void
      {
         if(this.m_mc)
         {
            this.m_mc.gotoAndStop(this.m_startFrame);
            this.m_mc.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      public function destroy() : void
      {
         this.stop();
         if(this.m_mc)
         {
            this.m_mc = null;
            this.m_frame = this.m_frameCount = this.m_startFrame = 0;
         }
      }
   }
}

