package Widgets.Windows
{
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MoneyTree2017ToasterWindow extends GenericSingleButtonTitleToaster
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
      
      public function MoneyTree2017ToasterWindow(windowAssetPath:String, title:String, description:String, buttonText:String, buttonCallback:Function, timeToLive:int)
      {
         if(timeToLive > 0)
         {
            this.m_timeToLive = timeToLive;
         }
         super(windowAssetPath,title,description,buttonText,buttonCallback);
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
         this.startHideTimer();
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
      }
   }
}

