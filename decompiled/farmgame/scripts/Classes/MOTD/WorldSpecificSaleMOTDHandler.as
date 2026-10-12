package Classes.MOTD
{
   import Display.UI;
   
   public class WorldSpecificSaleMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function WorldSpecificSaleMOTDHandler(currentMOTD:Object)
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
         UI.displayMarketDialog("world_sale_motd","sale");
      }
   }
}

