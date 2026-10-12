package Classes.Idle.Crafting
{
   import Classes.CraftingCottageBuilding;
   import Classes.Idle.BaseIdleTask;
   import Managers.Crafting.CraftingManager;
   
   public class CraftingCottageRecipeReadyTask extends BaseIdleTask
   {
      
      public const RECIPE_READY_MOUSE_IDLE_MILLISECONDS:Number = 1500;
      
      public function CraftingCottageRecipeReadyTask()
      {
         super();
      }
      
      override public function fire() : void
      {
         var thisCottage:CraftingCottageBuilding = null;
         var cottages:Array = CraftingManager.getInstance().getPlacedCraftingCottages();
         var focusCottage:CraftingCottageBuilding = null;
         for(var i:int = 0; i < cottages.length; i++)
         {
            thisCottage = cottages[i];
            if(thisCottage != null && thisCottage.readyRecipes.length > 0)
            {
               focusCottage = thisCottage;
               break;
            }
         }
         if(focusCottage != null)
         {
            focusCottage.centerOn();
         }
      }
      
      override public function get minMouseIdleMilliseconds() : Number
      {
         return this.RECIPE_READY_MOUSE_IDLE_MILLISECONDS;
      }
   }
}

