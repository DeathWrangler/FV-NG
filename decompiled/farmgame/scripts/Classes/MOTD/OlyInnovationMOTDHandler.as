package Classes.MOTD
{
   import Managers.OlyInnovationManager;
   
   public class OlyInnovationMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function OlyInnovationMOTDHandler(currentMotd:Object)
      {
         super(currentMotd);
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         var worldType:String = m_currentMOTD["worldType"];
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            OlyInnovationManager.getInstance().showUI();
         }
      }
   }
}

