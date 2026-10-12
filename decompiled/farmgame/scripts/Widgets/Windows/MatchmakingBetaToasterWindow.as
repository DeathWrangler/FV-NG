package Widgets.Windows
{
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MatchmakingBetaToasterWindow extends ToasterWindow
   {
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 5000;
      
      private var m_acceptCallback:Function;
      
      private var m_rejectCallback:Function;
      
      private var m_playerName:String;
      
      private var m_playerPicUrl:String;
      
      private var m_icon:FarmIcon;
      
      private var m_genericTf:FarmTextField;
      
      protected var m_timeToLive:Number = 5000;
      
      protected var m_timer:Timer = null;
      
      public function MatchmakingBetaToasterWindow(windowAssetPath:String, timeToLive:int, playerName:String, playerPicUrl:String, acceptCallBack:Function, rejectCallback:Function = null)
      {
         this.m_acceptCallback = acceptCallBack;
         this.m_rejectCallback = rejectCallback;
         this.m_playerName = playerName;
         this.m_playerPicUrl = playerPicUrl;
         if(timeToLive > 0)
         {
            this.m_timeToLive = timeToLive;
         }
         super(windowAssetPath);
      }
      
      override protected function release() : void
      {
         if(this.m_timer != null)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         super.release();
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window["icon_mc"])
         {
            addWidget(this.m_icon = new FarmIcon(m_window["icon_mc"],this.m_playerPicUrl));
            this.m_icon.setIconSize(60,60);
         }
         if(m_window["title_tf"])
         {
            addWidget(new FarmTextField(m_window["title_tf"],"Hand of Destiny"));
         }
         if(m_window["generic_tf"])
         {
            addWidget(this.m_genericTf = new FarmTextField(m_window["generic_tf"],this.m_playerName + " is inviting you to play a game. Want to join?"));
         }
         addWidget(new FarmAnimatedButton(m_window.yes_bt,this.onAccept));
         addWidget(new FarmAnimatedButton(m_window.no_bt,this.onReject));
         this.startHideTimer();
      }
      
      private function onAccept(e:Event) : void
      {
         this.close();
         if(this.m_acceptCallback is Function)
         {
            this.m_acceptCallback();
         }
         FarmStatsManager.count("Hand_of_Destiny","Matchmaking_Track","Toaster","accept");
      }
      
      private function onReject(e:Event) : void
      {
         this.close();
         if(this.m_rejectCallback is Function)
         {
            this.m_rejectCallback(false);
         }
         FarmStatsManager.count("Hand_of_Destiny","Matchmaking_Track","Toaster","decline");
      }
      
      override protected function hideTween(callback:Function) : void
      {
         if(Boolean(m_window) && Boolean(this.m_timer))
         {
            this.m_timer.stop();
         }
         super.hideTween(callback);
      }
      
      override protected function showTweenComplete() : void
      {
         if(m_window)
         {
            this.m_timer.start();
         }
         super.showTweenComplete();
      }
      
      private function startHideTimer() : void
      {
         this.m_timer = new Timer(this.m_timeToLive);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      override public function show() : void
      {
         super.show();
      }
      
      protected function onTimer(event:TimerEvent) : void
      {
         close();
         if(this.m_rejectCallback is Function)
         {
            this.m_rejectCallback(true);
         }
         FarmStatsManager.count("Hand_of_Destiny","Matchmaking_Track","Toaster","timeout");
      }
   }
}

