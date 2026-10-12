package Widgets.TextFields
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.MathUtil;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class CountdownTimeTextField extends ZwTextField
   {
      
      protected var m_timer:Timer;
      
      protected var m_remainingTimeFunction:Function;
      
      protected var m_timeOverCallbackFunction:Function;
      
      protected var m_hideZeroHours:Boolean;
      
      public function CountdownTimeTextField(element:TextField, remainingTimeFunction:Function, timeOverCallbackFunction:Function = null, hideZeroHours:Boolean = false)
      {
         super(element,hideZeroHours ? "00:00" : "00:00:00");
         if(remainingTimeFunction != null)
         {
            this.m_remainingTimeFunction = remainingTimeFunction;
            this.m_timeOverCallbackFunction = timeOverCallbackFunction;
            this.m_hideZeroHours = hideZeroHours;
            this.m_timer = new Timer(1000,0);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.refreshTimer);
            this.m_timer.start();
            this.refreshTimer(null);
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.terminateTimer();
      }
      
      protected function terminateTimer() : void
      {
         if(this.m_timer != null)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.refreshTimer);
            this.m_timer = null;
         }
      }
      
      private function refreshTimer(event:TimerEvent) : void
      {
         var property:String = null;
         var timeRemaining:int = MathUtil.clamp(this.m_remainingTimeFunction(),0,FarmGameUtil.NUM_SECS_IN_DAY - 1);
         if(timeRemaining == 0)
         {
            this.terminateTimer();
            if(this.m_timeOverCallbackFunction != null)
            {
               this.m_timeOverCallbackFunction();
            }
         }
         var parsedLocTime:Array = FarmGameUtil.parseTimeLeftZLoc(timeRemaining);
         var locString:String = "CountdownTime_hours";
         if(this.m_hideZeroHours && parsedLocTime["Hours"] == 0)
         {
            locString = "CountdownTime_nohours";
         }
         for(property in parsedLocTime)
         {
            if(parsedLocTime[property] < 10)
            {
               parsedLocTime[property] = "0" + parsedLocTime[property];
            }
         }
         text = ZLocUtils.t("Dialogs",locString,parsedLocTime);
      }
   }
}

