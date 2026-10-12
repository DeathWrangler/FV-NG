package Classes.Idle
{
   import Managers.CrossPromoManager;
   
   public class CrossPromoToasterIdleTask extends BaseIdleTask
   {
      
      protected var m_timeToPop:int = 0;
      
      protected var m_promoId:String;
      
      public function CrossPromoToasterIdleTask(promoId:String, timeToPop:int = 0)
      {
         this.m_promoId = promoId;
         this.m_timeToPop = timeToPop * 1000;
         m_displaysPopup = true;
         super();
      }
      
      override public function fire() : void
      {
         CrossPromoManager.getInstance().showToaster(this.m_promoId);
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > this.m_timeToPop;
      }
   }
}

