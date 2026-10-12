package Classes.MatchMaking
{
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class ZoomHeartbeatHandler
   {
      
      public static const TYPE:String = "heartbeat";
      
      private static const HEARTBEAT_INTERVAL:uint = 275 * 1000;
      
      private var m_timer:Timer;
      
      private var m_manager:MatchMakingManager;
      
      public function ZoomHeartbeatHandler(zoomManager:MatchMakingManager)
      {
         super();
         this.m_manager = zoomManager;
         this.m_timer = new Timer(HEARTBEAT_INTERVAL);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.sendHeartbeat);
      }
      
      public function start() : void
      {
         this.m_timer.start();
      }
      
      public function stop() : void
      {
         this.m_timer.stop();
      }
      
      private function sendHeartbeat(event:Event) : void
      {
         var message:String = "heartbeat";
         this.m_manager.sendMessage(message,Global.player.uid);
      }
      
      public function onHeartbeat(sender:String) : void
      {
      }
   }
}

