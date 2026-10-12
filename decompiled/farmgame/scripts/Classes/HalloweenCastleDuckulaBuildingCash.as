package Classes
{
   public class HalloweenCastleDuckulaBuildingCash extends HalloweenCastleDuckulaBuilding
   {
      
      public static const MAX_LEVEL:Number = 6;
      
      public function HalloweenCastleDuckulaBuildingCash(buildingType:String = null)
      {
         super(buildingType);
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         this.storageLevel = MAX_LEVEL;
         this.reloadImage();
         super.onFinishPlace(transactionResult);
      }
   }
}

