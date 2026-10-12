package Classes.Idle
{
   import Managers.DragonBreedingManager;
   
   public class DragonBreedingTask extends BaseIdleTask
   {
      
      public function DragonBreedingTask()
      {
         super();
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get requireMouseIdle() : Boolean
      {
         return false;
      }
      
      override public function get requirePopupQueueEmpty() : Boolean
      {
         return false;
      }
      
      override public function get canFire() : Boolean
      {
         return Global.eosManager.getEosVariant("fv_dragonbreeding") >= 2;
      }
      
      override public function fire() : void
      {
         var featureName:String = DragonBreedingManager.getFeatureName();
         var canShowToaster:Boolean = false;
         var vdItemCode:String = "";
         var vdItemCodes:Array = DragonBreedingManager.getInstance(featureName).getVisitingDragonItemCodeAsArray();
         if(Boolean(vdItemCodes) && vdItemCodes.length > 0)
         {
            vdItemCode = vdItemCodes[0];
         }
         if(Global.world.getObjectsByName(featureName))
         {
            if(DragonBreedingManager.getInstance(featureName).isAnyBreedingComplete())
            {
               canShowToaster = true;
               DragonBreedingManager.getInstance(featureName).toasterWindowType = DragonBreedingManager.TOASTER_SHOW_EGG_READY;
            }
            if(Boolean(DragonBreedingManager.getInstance(featureName).getHatchReadyParentItems()) && DragonBreedingManager.getInstance(featureName).getHatchReadyParentItems().length > 0)
            {
               canShowToaster = true;
               DragonBreedingManager.getInstance(featureName).toasterWindowType = DragonBreedingManager.TOASTER_SHOW_HATCH_READY;
            }
            if(vdItemCode != "")
            {
               if(DragonBreedingManager.getInstance(featureName).isValidVisitingDragonByItemCode(vdItemCode))
               {
                  if(DragonBreedingManager.getInstance(featureName).getVistingDragonTimeRemainingByItemCode(vdItemCode) > 0 && DragonBreedingManager.getInstance(featureName).getVistingDragonTimeRemainingByItemCode(vdItemCode) <= DragonBreedingManager.VISITING_DRAGON_DURATION / 4)
                  {
                     canShowToaster = true;
                     DragonBreedingManager.getInstance(featureName).toasterWindowType = DragonBreedingManager.TOASTER_SHOW_VISITING_DRAGON;
                  }
               }
            }
            if(canShowToaster)
            {
               DragonBreedingManager.getInstance(DragonBreedingManager.getFeatureName()).openToasterWindow();
            }
         }
      }
   }
}

