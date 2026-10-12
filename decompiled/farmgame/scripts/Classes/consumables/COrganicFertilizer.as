package Classes.consumables
{
   import Classes.Consumable;
   import Managers.OrganicFertilizerHelper;
   
   public class COrganicFertilizer extends Consumable
   {
      
      public function COrganicFertilizer(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         OrganicFertilizerHelper.showMainWindow();
      }
      
      override public function onUse() : void
      {
         OrganicFertilizerHelper.showMainWindow();
      }
   }
}

