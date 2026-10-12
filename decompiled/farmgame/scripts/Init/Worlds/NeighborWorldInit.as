package Init.Worlds
{
   import Classes.util.ZLocUtils;
   import Display.HUD.FarmNameDisplay;
   
   public class NeighborWorldInit extends VisitWorldInit
   {
      
      public function NeighborWorldInit(destinationUid:String)
      {
         super(destinationUid);
      }
      
      override public function setupHud() : void
      {
         super.setupHud();
         Global.hud.showBasicNameDisplay();
         var playerName:String = Global.worldManager.getVisitName();
         if(playerName == null || playerName == "")
         {
            playerName = ZLocUtils.t("FarmGame","Friend");
         }
         var farmNameDisplay:FarmNameDisplay = Global.hud.farmNameDisplay;
         farmNameDisplay.setFarmNameFromPlayerName(playerName);
      }
   }
}

