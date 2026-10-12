package Transactions
{
   public class TGiftVehiclePart extends TFarmTransaction
   {
      
      public function TGiftVehiclePart()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("EquipmentWorldService.onGiftVehiclePart");
      }
   }
}

