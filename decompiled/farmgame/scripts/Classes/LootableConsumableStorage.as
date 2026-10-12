package Classes
{
   import Display.LootableConsumableStorageWithdrawal;
   import Display.UI;
   
   public class LootableConsumableStorage extends HarvestStorageBuilding
   {
      
      public function LootableConsumableStorage(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         UI.displayStorageDialog(new LootableConsumableStorageWithdrawal(this));
      }
   }
}

