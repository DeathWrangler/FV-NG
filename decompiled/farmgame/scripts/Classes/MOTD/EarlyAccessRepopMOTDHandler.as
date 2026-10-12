package Classes.MOTD
{
   public class EarlyAccessRepopMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function EarlyAccessRepopMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         Global.hud.travelNameDisplay.showNewTravelWindow();
      }
   }
}

