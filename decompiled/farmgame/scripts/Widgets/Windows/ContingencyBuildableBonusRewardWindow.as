package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class ContingencyBuildableBonusRewardWindow extends FarmWindow
   {
      
      protected var m_accept_bt:FarmAnimatedTextButton = null;
      
      protected var m_timerMc:MovieClip = null;
      
      private const TIMER_MC:String = "timer_mc";
      
      private const TIMER_TF:String = "timer_tf";
      
      private var m_timer:Timer;
      
      private var m_timerTf:ZwTextField;
      
      public function ContingencyBuildableBonusRewardWindow(assetPath:String = "")
      {
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("accept_bt"))
            {
               addWidget(this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"Okay!",this.onClose));
               this.m_accept_bt.visible = true;
            }
            if(m_window.hasOwnProperty(this.TIMER_MC))
            {
               this.m_timerMc = m_window.timer_mc as MovieClip;
               if(this.m_timerMc.hasOwnProperty(this.TIMER_TF))
               {
                  addWidget(this.m_timerTf = new ZwTextField(this.m_timerMc[this.TIMER_TF],this.getTimeLeft()));
               }
               this.m_timerMc.visible = true;
            }
         }
         this.startTimer();
         refreshWindow();
      }
      
      public function startTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      public function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         if(Boolean(m_window) && Boolean(this.m_timerTf))
         {
            this.m_timerTf.text = this.getTimeLeft();
            this.m_timerTf.visible = true;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         this.stopTimer();
         super.close();
      }
      
      private function getTimeLeft() : String
      {
         var timeRemaining:Array = this.getFeatureExpiryTimeOnWall();
         var timeLeft:String = "";
         if(parseInt(timeRemaining[0]) > 1)
         {
            timeLeft = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BBWinter_TimeLeftDays",{"time":timeRemaining[0]});
         }
         else
         {
            timeLeft = HUD.getformattedTimeLeftFromArray(timeRemaining);
         }
         return timeLeft;
      }
      
      public function getFeatureExpiryTimeOnWall() : Array
      {
         var remainingDay:int = 0;
         var timeLeftMs:Number = FarmGameUtil.synchronizedDateToNumber("07/14/2019") - GlobalEngine.serverTime;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         var remainingTime:Array = FarmGameUtil.parseTimeLeft(timeLeftMs / 1000);
         if(parseInt(remainingTime[0]) > 0)
         {
            remainingDay = parseInt(remainingTime[0]) + 1;
            remainingTime[0] = remainingDay.toString();
         }
         return remainingTime;
      }
   }
}

