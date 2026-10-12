package Classes.Idle
{
   import Classes.util.FarmGameUtil;
   import Widgets.Windows.LowCashBuyMoneyWindow;
   
   public class LowFCIdleTask extends BaseIdleTask
   {
      
      private var m_startDelay:uint;
      
      public function LowFCIdleTask(params:Object = null)
      {
         super();
         m_displaysPopup = true;
         this.m_startDelay = 5 * FarmGameUtil.NUM_MSECS_IN_SECOND;
      }
      
      override public function get shouldAdd() : Boolean
      {
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         return LowCashBuyMoneyWindow.shouldShowPopup();
      }
      
      override public function fire() : void
      {
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > m_timeAddedMilliseconds + this.m_startDelay;
      }
   }
}

