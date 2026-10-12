package Engine.Classes
{
   import cipro.Profiler.RuntimeProfiler;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TimerUtil
   {
      
      public function TimerUtil()
      {
         super();
      }
      
      public static function callLater(param1:Function, param2:int) : Timer
      {
         var timer:Timer = null;
         var callback:Function = param1;
         var delayMs:int = param2;
         timer = new Timer(delayMs);
         timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
         {
            var _loc3_:int = RuntimeProfiler.enter(ZEngineCoreModules.TimerUtilCallLater);
            timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
            timer.stop();
            timer = null;
            callback();
            RuntimeProfiler.leave(_loc3_);
         });
         timer.start();
         return timer;
      }
      
      public static function callHandlerLater(param1:Function, param2:int) : Timer
      {
         var timer:Timer = null;
         var callback:Function = param1;
         var delayMs:int = param2;
         timer = new Timer(delayMs);
         timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
         {
            var _loc3_:int = RuntimeProfiler.enter(ZEngineCoreModules.TimerUtilCallLater);
            timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
            timer.stop();
            timer = null;
            callback(param1);
            RuntimeProfiler.leave(_loc3_);
         });
         timer.start();
         return timer;
      }
   }
}

