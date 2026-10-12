package Classes.Idle.Crafting
{
   import Classes.Idle.BaseIdleTask;
   import Display.UI;
   import GameMode.GMBuild;
   import Managers.Crafting.CraftingManager;
   
   public class CraftingImpulseBuyTask extends BaseIdleTask
   {
      
      public function CraftingImpulseBuyTask()
      {
         super();
      }
      
      override public function fire() : void
      {
         var currentGMs:Array = Global.world.getActiveGameModes();
         var shouldFire:Boolean = true;
         if(currentGMs.length > 0 && currentGMs[0] is GMBuild)
         {
            shouldFire = false;
         }
         if(CraftingManager.getInstance().getPlacedMarketStalls() == 0)
         {
            shouldFire = false;
         }
         if(shouldFire)
         {
            UI.displayBuyMarketStallWindow();
         }
      }
   }
}

