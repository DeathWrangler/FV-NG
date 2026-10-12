package GameMode
{
   import Display.UI;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class GMGiftReOpen extends GameMode
   {
      
      private static const REOPEN_GIFT_DIALOG_TIMEOUT:Number = 500;
      
      protected var m_isGift:Boolean;
      
      protected var m_shouldReOpenGift:Boolean = true;
      
      protected var m_reopenGiftBoxTimer:Timer = null;
      
      protected var m_giftTimeout:Number = 500;
      
      public function GMGiftReOpen(isGift:Boolean, shouldReOpenGift:Boolean = true)
      {
         this.m_isGift = isGift;
         this.m_shouldReOpenGift = shouldReOpenGift;
         super();
      }
      
      public function reOpenGiftIfNecessary() : void
      {
         if(this.m_isGift && this.m_shouldReOpenGift)
         {
            if(Global.player.getGiftCount() > 0 && this.m_reopenGiftBoxTimer == null)
            {
               this.m_reopenGiftBoxTimer = new Timer(this.m_giftTimeout,1);
               this.m_reopenGiftBoxTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onGiftBoxTimerComplete);
               this.m_reopenGiftBoxTimer.start();
               UI.lockGifts();
            }
         }
      }
      
      protected function onGiftBoxTimerComplete(event:TimerEvent) : void
      {
         if(this.m_reopenGiftBoxTimer != null)
         {
            this.m_reopenGiftBoxTimer.removeEventListener(TimerEvent.TIMER,this.onGiftBoxTimerComplete);
            this.m_reopenGiftBoxTimer = null;
            UI.unlockGifts();
            UI.displayGiftBoxWindow();
         }
      }
   }
}

