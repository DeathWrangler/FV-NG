package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Display.ConstructionBuildingWithdrawal;
   import flash.utils.getDefinitionByName;
   
   public class BuildingReadyFManager extends FeatureManager implements IBuildingReadyComponent
   {
      
      private var isFeatureReady:Boolean = false;
      
      public function BuildingReadyFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      public function getReadyState() : void
      {
         var item:FarmItem = owner.getFarmItem();
         var withdrawalClassName:String = item.getDialogConfig("storage").className;
         var withdrawalClass:Class = getDefinitionByName(withdrawalClassName) as Class;
         var withdrawal:ConstructionBuildingWithdrawal = new withdrawalClass(item as StorageBuilding) as ConstructionBuildingWithdrawal;
         var isReady:Boolean = withdrawal.getFeatureReadyState();
         if(isReady)
         {
            this.doReadyState(withdrawal);
         }
      }
      
      public function doReadyState(withdrawal:ConstructionBuildingWithdrawal) : void
      {
         withdrawal.doReadyState();
      }
   }
}

