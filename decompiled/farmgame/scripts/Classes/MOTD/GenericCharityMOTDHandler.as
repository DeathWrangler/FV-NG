package Classes.MOTD
{
   import Display.UI;
   
   public class GenericCharityMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function GenericCharityMOTDHandler(currentMOTD:Object)
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
         var item:String = Global.charityManager.item;
         UI.displayMiniMarketDialog([item]);
      }
   }
}

