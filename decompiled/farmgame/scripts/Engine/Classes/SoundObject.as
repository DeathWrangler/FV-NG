package Engine.Classes
{
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   
   public class SoundObject
   {
      
      public var sound:Sound;
      
      protected var m_soundChannel:SoundChannel;
      
      protected var m_pausePoint:Number = 0;
      
      protected var m_isPaused:Boolean = false;
      
      public var isMusic:Boolean = false;
      
      public function SoundObject(param1:Sound, param2:SoundChannel)
      {
         super();
         this.sound = param1;
         this.m_soundChannel = param2;
         this.m_soundChannel.addEventListener(Event.SOUND_COMPLETE,this.onComplete,false,0,true);
      }
      
      public function set volume(param1:Number) : void
      {
         var _loc2_:SoundTransform = new SoundTransform(param1,this.pan);
         this.m_soundChannel.soundTransform = _loc2_;
      }
      
      public function get volume() : Number
      {
         return this.m_soundChannel.soundTransform.volume;
      }
      
      public function set pan(param1:Number) : void
      {
         var _loc2_:SoundTransform = new SoundTransform(this.volume,param1);
         this.m_soundChannel.soundTransform = _loc2_;
      }
      
      public function get pan() : Number
      {
         return this.m_soundChannel.soundTransform.pan;
      }
      
      public function isPlaying() : Boolean
      {
         return this.m_isPaused == false;
      }
      
      public function pause() : void
      {
         if(this.m_isPaused == false)
         {
            this.m_pausePoint = this.m_soundChannel.position;
            this.removeEventListeners();
            this.m_soundChannel.stop();
            this.m_isPaused = true;
         }
      }
      
      public function unpause() : void
      {
         if(this.m_isPaused)
         {
            this.m_isPaused = false;
            this.m_soundChannel = this.sound.play(this.m_pausePoint,0,this.m_soundChannel.soundTransform);
            if(this.isMusic)
            {
               this.m_soundChannel.addEventListener(Event.SOUND_COMPLETE,this.onPausedLoopComplete,false,0,true);
            }
            this.m_pausePoint = 0;
         }
      }
      
      public function stop(param1:Boolean = true) : void
      {
         this.m_soundChannel.stop();
         this.removeEventListeners();
         if(param1)
         {
            this.sound.dispatchEvent(new Event(Event.SOUND_COMPLETE));
         }
      }
      
      private function onComplete(param1:Event) : void
      {
         this.sound.dispatchEvent(new Event(Event.SOUND_COMPLETE));
      }
      
      private function onPausedLoopComplete(param1:Event) : void
      {
         this.m_soundChannel.removeEventListener(Event.SOUND_COMPLETE,this.onPausedLoopComplete);
         this.m_pausePoint = 0;
         this.m_isPaused = true;
         this.onComplete(null);
      }
      
      private function removeEventListeners() : void
      {
         if(Boolean(this.m_soundChannel) && this.m_soundChannel.hasEventListener(Event.SOUND_COMPLETE))
         {
            this.m_soundChannel.removeEventListener(Event.SOUND_COMPLETE,this.onPausedLoopComplete);
            this.m_soundChannel.removeEventListener(Event.SOUND_COMPLETE,this.onComplete);
         }
      }
   }
}

