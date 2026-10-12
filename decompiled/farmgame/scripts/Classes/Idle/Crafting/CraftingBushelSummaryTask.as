package Classes.Idle.Crafting
{
   import Classes.Idle.BaseIdleTask;
   import Managers.Crafting.CraftingManager;
   
   public class CraftingBushelSummaryTask extends BaseIdleTask
   {
      
      public function CraftingBushelSummaryTask()
      {
         super();
      }
      
      override public function fire() : void
      {
         CraftingManager.getInstance().displayBushelsInformationToaster();
      }
   }
}

