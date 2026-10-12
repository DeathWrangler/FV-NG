package Classes.MOTD
{
   import Events.DynamicObjectEvent;
   import Managers.SpendometerManager;
   
   public class SpendometerMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function SpendometerMOTDHandler(currentMotd:Object)
      {
         super(currentMotd);
      }
      
      override public function execute() : void
      {
         this.acceptMOTD();
         m_isFinished = true;
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         SpendometerManager.instance.dispatchEvent(new DynamicObjectEvent(SpendometerManager.SHOW_SPENDOMETER_DIALOG,{"source":"motd"}));
      }
   }
}

