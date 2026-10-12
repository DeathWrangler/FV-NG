package Classes
{
   import com.greensock.TweenLite;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TextDecoder
   {
      
      private var m_onFinishLetterCallback:Function = null;
      
      private var m_onFinishWordCallback:Function = null;
      
      private var m_onScrambleWordCallback:Function = null;
      
      private var m_numCharactersDecoded:int = 0;
      
      private var m_targetText:String = "";
      
      private var m_scrambleTimer:Timer = null;
      
      private var m_letterDecodeTimes:Array = null;
      
      private var DEFAULT_DECODE_TIME:int = 100;
      
      private var m_text:String = "";
      
      public function TextDecoder(initialText:String = "")
      {
         super();
         this.m_text = initialText;
      }
      
      public function release() : void
      {
         this.cleanUpTimers();
      }
      
      public function startDecode(targetText:String = "", letterDecodeTimes:Array = null, onFinishLetterCallback:Function = null, onFinishWordCallback:Function = null, onScrambleWordCallback:Function = null) : void
      {
         this.cleanUpTimers();
         if(letterDecodeTimes == null || letterDecodeTimes.length == 0)
         {
            letterDecodeTimes = [this.DEFAULT_DECODE_TIME];
         }
         this.m_onFinishLetterCallback = onFinishLetterCallback;
         this.m_onFinishWordCallback = onFinishWordCallback;
         this.m_onScrambleWordCallback = onScrambleWordCallback;
         this.m_targetText = targetText;
         this.m_numCharactersDecoded = 0;
         this.m_letterDecodeTimes = letterDecodeTimes;
         var targetLength:int = targetText.length;
         TweenLite.to(this,this.m_letterDecodeTimes[this.m_numCharactersDecoded] / 1000,{"onComplete":this.onFinishLetter});
         this.m_scrambleTimer = new Timer(80);
         this.m_scrambleTimer.addEventListener(TimerEvent.TIMER,this.scrambleWord);
         this.m_scrambleTimer.start();
      }
      
      public function get text() : String
      {
         return this.m_text;
      }
      
      public function instantDecode() : void
      {
         this.cleanUpTimers();
         this.m_text = this.m_targetText;
      }
      
      private function onFinishLetter() : void
      {
         var timeIndex:int = 0;
         ++this.m_numCharactersDecoded;
         if(this.m_onFinishLetterCallback != null)
         {
            this.m_onFinishLetterCallback(this.m_targetText,this.m_numCharactersDecoded);
         }
         if(this.m_numCharactersDecoded < this.m_targetText.length)
         {
            timeIndex = this.m_numCharactersDecoded;
            if(timeIndex >= this.m_letterDecodeTimes.length)
            {
               timeIndex = this.m_letterDecodeTimes.length - 1;
            }
            TweenLite.to(this,this.m_letterDecodeTimes[this.m_numCharactersDecoded] / 1000,{"onComplete":this.onFinishLetter});
         }
         else
         {
            this.onFinishWord();
         }
      }
      
      private function onFinishWord() : void
      {
         this.cleanUpTimers();
         this.m_text = this.m_targetText;
         if(this.m_onFinishWordCallback != null)
         {
            this.m_onFinishWordCallback();
         }
      }
      
      private function cleanUpTimers() : void
      {
         if(this.m_scrambleTimer)
         {
            if(this.m_scrambleTimer.running)
            {
               this.m_scrambleTimer.stop();
            }
            if(this.m_scrambleTimer.hasEventListener(TimerEvent.TIMER))
            {
               this.m_scrambleTimer.removeEventListener(TimerEvent.TIMER,this.scrambleWord);
            }
         }
         TweenLite.killTweensOf(this);
      }
      
      private function scrambleWord(event:TimerEvent = null) : void
      {
         var randchar:String = null;
         var newText:Array = this.m_targetText.split("");
         var range:int = "9".charCodeAt(0) - "0".charCodeAt(0);
         for(var i:* = this.m_targetText.length; i > this.m_numCharactersDecoded; i--)
         {
            randchar = String.fromCharCode(Math.round(Math.random() * range) + "0".charCodeAt(0));
            newText[i - 1] = randchar;
         }
         this.m_text = newText.join("");
         if(this.m_onScrambleWordCallback != null)
         {
            this.m_onScrambleWordCallback(this.m_text);
         }
      }
   }
}

