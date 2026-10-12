package Classes
{
   import Managers.EquipmentSettingsManager;
   
   public class ResourceEquipment extends Equipment
   {
      
      public static const HARVEST:String = "harvest";
      
      public function ResourceEquipment(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
      }
      
      override public function getEnergyCost() : Number
      {
         return EquipmentSettingsManager.getInstance().getEnergyCost(getItem().code);
      }
      
      public function onActionTransactionAdded() : void
      {
      }
      
      public function onMultiActionComplete(transactionData:Object, result:Object) : void
      {
      }
   }
}

