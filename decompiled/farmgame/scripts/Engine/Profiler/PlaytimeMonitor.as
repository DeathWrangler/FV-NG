package Engine.Profiler
{
   import Engine.Classes.TimerUtil;
   import cipro.Profiler.GameTagManager;
   import cipro.Profiler.GameTagObject;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class PlaytimeMonitor
   {
      
      private static const PLAYTHRESHOLD:int = 10000;
      
      public static const PLAYACTIVE:String = "Active";
      
      public static const PLAYIDLE:String = "Idle";
      
      private static const THROTTLE_EVENT:String = "throttle";
      
      private static const THROTTLE_EVENT_THROTTLED:String = "throttle";
      
      private static const THROTTLE_EVENT_RESUME:String = "resume";
      
      private static var s_enabled:Boolean = false;
      
      private static var s_lastMove:int = 0;
      
      private static var s_throttled:Boolean = false;
      
      private static var s_stage:Stage = null;
      
      private static var s_playStateString:String = null;
      
      private static var s_timer:Timer = null;
      
      private static var s_playState:GameTagObject = null;
      
      private static var s_lastActivity:GameTagObject = null;
      
      public function PlaytimeMonitor()
      {
         super();
      }
      
      public static function enable() : void
      {
         if(!s_enabled)
         {
            s_enabled = true;
            s_lastMove = -PLAYTHRESHOLD;
            s_playStateString = PLAYIDLE;
            s_lastActivity = GameTagManager.registerGameTag("LastActivity",function():Number
            {
               return s_lastMove;
            },GameTagManager.TYPE_COUNT_NUMBER,GameTagManager.UPDATE_POLLING);
            s_playState = GameTagManager.registerGameTag("PlayState",getPlayState,GameTagManager.TYPE_STRING,GameTagManager.UPDATE_ASSIGN);
            GameTagManager.registerGameModeTag(s_playState.name);
            if(s_stage != null)
            {
               s_stage.addEventListener(MouseEvent.MOUSE_MOVE,playtimeOnMouseMove,false,3);
               s_stage.addEventListener(THROTTLE_EVENT,playtimeOnThrottle);
            }
         }
      }
      
      protected static function getPlayState() : String
      {
         return s_playStateString;
      }
      
      public static function enableFrameCapture(param1:Stage) : void
      {
         if(s_stage == null)
         {
            s_stage = param1;
            if(s_enabled)
            {
               s_stage.addEventListener(MouseEvent.MOUSE_MOVE,playtimeOnMouseMove,false,3);
               s_stage.addEventListener(THROTTLE_EVENT,playtimeOnThrottle);
            }
         }
      }
      
      protected static function playtimeOnThrottle(param1:Event) : void
      {
         if(param1["state"] == THROTTLE_EVENT_THROTTLED)
         {
            s_throttled = true;
            s_playStateString = PLAYIDLE;
            s_playState.refresh();
         }
      }
      
      protected static function playtimeOnMouseMove(param1:Event) : void
      {
         var _loc2_:int = getTimer();
         if(s_throttled || _loc2_ - s_lastMove > PLAYTHRESHOLD)
         {
            s_playStateString = PLAYACTIVE;
            s_throttled = false;
            s_playState.refresh();
            s_timer = TimerUtil.callLater(onPlayTimeOut,PLAYTHRESHOLD);
         }
         s_lastMove = _loc2_;
      }
      
      protected static function onPlayTimeOut() : void
      {
         var _loc1_:int = getTimer();
         s_timer = null;
         if(_loc1_ - s_lastMove > PLAYTHRESHOLD)
         {
            s_playStateString = PLAYIDLE;
            s_playState.refresh();
         }
         else
         {
            s_timer = TimerUtil.callLater(onPlayTimeOut,PLAYTHRESHOLD - (_loc1_ - s_lastMove));
         }
      }
   }
}

