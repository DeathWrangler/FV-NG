package Widgets.Windows
{
   import Classes.util.FarmGameUtil;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class TimerToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const POPUP_NAME:String = "expiringToaster";
      
      protected static const DEFAULT_POPUP_TIME_TO_LIVE:Number = 15000;
      
      private var m_endTimeSeconds:Number = 0;
      
      private const COUNTDOWN_UPDATE_TIMER:Number = 1000;
      
      private var m_countdownTimer:Timer = null;
      
      protected var m_titleField1:String = "";
      
      protected var m_titleField2:String = "";
      
      protected var m_titleField3:String = "";
      
      protected var m_clickHereLink:String = "";
      
      public function TimerToasterWindow(dialogAsset:String, endTimeSeconds:Number)
      {
         this.m_endTimeSeconds = endTimeSeconds;
         super(dialogAsset);
         m_timeToLive = DEFAULT_POPUP_TIME_TO_LIVE;
         this.name = POPUP_NAME;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwFrame(m_window.foundPopUp_mc));
         addWidget(new ZwWidget(m_window.foundPopUp_mc.clockIcon_mc));
         var titleField1:ZwTextField = new ZwTextField(m_window.foundPopUp_mc.title1_tf);
         titleField1.text = this.m_titleField1;
         addWidget(titleField1);
         var titleField2:ZwTextField = new ZwTextField(m_window.foundPopUp_mc.title2_tf);
         titleField2.text = this.m_titleField2;
         addWidget(titleField2);
         var titleField3:ZwTextField = new ZwTextField(m_window.foundPopUp_mc.title3_tf);
         titleField3.text = this.m_titleField3;
         addWidget(titleField3);
         var clickHereLink:ZwTextField = new ZwTextField(m_window.foundPopUp_mc.clickHere_tf);
         clickHereLink.text = this.m_clickHereLink;
         addWidget(clickHereLink);
         var countdownTimer:ZwWidget = new ZwWidget(m_window.foundPopUp_mc.counter_mc);
         countdownTimer.visible = true;
         addWidget(countdownTimer);
         var digitOneDay_mc:ZwWidget = new ZwWidget(m_window.foundPopUp_mc.counter_mc.digitOneDay_mc);
         addWidget(digitOneDay_mc);
         var digitTenHours:ZwWidget = new ZwWidget(m_window.foundPopUp_mc.counter_mc.digitTenHours_mc);
         addWidget(digitTenHours);
         var digitOneHour_mc:ZwWidget = new ZwWidget(m_window.foundPopUp_mc.counter_mc.digitOneHour_mc);
         addWidget(digitOneHour_mc);
         var digitTenMins:ZwWidget = new ZwWidget(m_window.foundPopUp_mc.counter_mc.digitTenMin_mc);
         addWidget(digitTenMins);
         var digitOneMin_mc:ZwWidget = new ZwWidget(m_window.foundPopUp_mc.counter_mc.digitOneMin_mc);
         addWidget(digitOneMin_mc);
         var digitTenSecs:ZwWidget = new ZwWidget(m_window.foundPopUp_mc.counter_mc.digitTenSec_mc);
         addWidget(digitTenSecs);
         var digitOneSec_mc:ZwWidget = new ZwWidget(m_window.foundPopUp_mc.counter_mc.digitOneSec_mc);
         addWidget(digitOneSec_mc);
         addWidget(new ZwButton(m_window.foundPopUp_mc.hitbox_mc,this.onHitBoxClick));
         addWidget(new ZwButton(m_window.foundPopUp_mc.close_bt,onClose));
         this.m_countdownTimer = new Timer(this.COUNTDOWN_UPDATE_TIMER,0);
         this.m_countdownTimer.addEventListener(TimerEvent.TIMER,this.onTimerRepeat);
         this.m_countdownTimer.start();
         this.updateCountdownTimer();
      }
      
      protected function updateCountdownTimer() : void
      {
         var numDays:Number = NaN;
         var numDaysTens:Number = NaN;
         var numDaysOnes:Number = NaN;
         var digitOneDays:ZwWidget = null;
         var numHours:Number = NaN;
         var numHoursTens:Number = NaN;
         var numHoursOnes:Number = NaN;
         var digitTenHours:ZwWidget = null;
         var digitOneHours:ZwWidget = null;
         var numMinutes:Number = NaN;
         var numMinutesTens:Number = NaN;
         var numMinutesOnes:Number = NaN;
         var digitTenMins:ZwWidget = null;
         var digitOneMin:ZwWidget = null;
         var numSeconds:Number = NaN;
         var numSecondsTens:Number = NaN;
         var numSecondsOnes:Number = NaN;
         var digitTenSecs:ZwWidget = null;
         var digitOneSecs:ZwWidget = null;
         var timeDiff:Number = this.m_endTimeSeconds - GlobalEngine.serverTime / 1000;
         var timeLeftParsed:Array = FarmGameUtil.parseTimeLeft(timeDiff);
         if(timeLeftParsed)
         {
            numDays = Number(timeLeftParsed[0]);
            numDaysTens = numDays / 10;
            numDaysOnes = numDays % 10;
            digitOneDays = getWidget(m_window.foundPopUp_mc.counter_mc.digitOneDay_mc) as ZwWidget;
            digitOneDays.element.digit_tf.text = int(numDaysOnes);
            numHours = Number(timeLeftParsed[1]);
            numHoursTens = numHours / 10;
            numHoursOnes = numHours % 10;
            digitTenHours = getWidget(m_window.foundPopUp_mc.counter_mc.digitTenHours_mc) as ZwWidget;
            digitTenHours.element.digit_tf.text = int(numHoursTens);
            digitOneHours = getWidget(m_window.foundPopUp_mc.counter_mc.digitOneHour_mc) as ZwWidget;
            digitOneHours.element.digit_tf.text = int(numHoursOnes);
            numMinutes = Number(timeLeftParsed[2]);
            numMinutesTens = numMinutes / 10;
            numMinutesOnes = numMinutes % 10;
            digitTenMins = getWidget(m_window.foundPopUp_mc.counter_mc.digitTenMin_mc) as ZwWidget;
            digitTenMins.element.digit_tf.text = int(numMinutesTens);
            digitOneMin = getWidget(m_window.foundPopUp_mc.counter_mc.digitOneMin_mc) as ZwWidget;
            digitOneMin.element.digit_tf.text = int(numMinutesOnes);
            numSeconds = Number(timeLeftParsed[3]);
            numSecondsTens = numSeconds / 10;
            numSecondsOnes = numSeconds % 10;
            digitTenSecs = getWidget(m_window.foundPopUp_mc.counter_mc.digitTenSec_mc) as ZwWidget;
            digitTenSecs.element.digit_tf.text = int(numSecondsTens);
            digitOneSecs = getWidget(m_window.foundPopUp_mc.counter_mc.digitOneSec_mc) as ZwWidget;
            digitOneSecs.element.digit_tf.text = int(numSecondsOnes);
         }
      }
      
      private function onHitBoxClick(event:MouseEvent) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         this.close();
         this.handleBoxClick();
      }
      
      protected function handleBoxClick() : void
      {
      }
      
      override public function close() : void
      {
         if(this.m_countdownTimer)
         {
            this.m_countdownTimer.stop();
            this.m_countdownTimer.removeEventListener(TimerEvent.TIMER,this.onTimerRepeat);
            this.m_countdownTimer = null;
         }
         super.close();
      }
      
      private function onTimerRepeat(event:TimerEvent) : void
      {
         if(this.m_countdownTimer != null)
         {
            this.updateCountdownTimer();
         }
      }
   }
}

