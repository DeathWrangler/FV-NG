package Classes.Idle
{
   import Display.UI;
   
   public class OpenMarketIdleTask extends BaseIdleTask
   {
      
      private var m_timeToPop:uint = 0;
      
      private var m_category:String = "";
      
      public function OpenMarketIdleTask(timeToPop:uint = 0, category:String = "")
      {
         this.m_timeToPop = timeToPop * 1000;
         this.m_category = category;
         super();
      }
      
      override public function fire() : void
      {
         UI.displayMarketDialog("idle_task",this.m_category,null,"");
      }
      
      override public function get canFire() : Boolean
      {
         return !UI.isShowingPopup() && GlobalEngine.currentTime > this.m_timeToPop;
      }
   }
}

