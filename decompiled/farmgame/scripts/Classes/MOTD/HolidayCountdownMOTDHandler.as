package Classes.MOTD
{
   import Managers.HolidayCountdownManager;
   
   public class HolidayCountdownMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function HolidayCountdownMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         if(m_currentMOTD["autoAccept"] == "true")
         {
            this.acceptMOTD();
            m_isFinished = true;
         }
         else
         {
            super.execute();
         }
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         HolidayCountdownManager.displayDialog();
      }
   }
}

