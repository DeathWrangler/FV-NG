package Classes.consumables
{
   import Classes.Consumable;
   import Managers.FishingDerbyManager;
   
   public class CFishingBait extends Consumable
   {
      
      public function CFishingBait(itemName:String)
      {
         super(itemName);
      }
      
      override public function canUse() : Boolean
      {
         var result:Boolean = false;
         return true;
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         super.consume(isGift,allowReshopping,userID,isFree,storageId);
         var baitsCount:int = getItem().count;
         var itemName:String = getItemName();
         FishingDerbyManager.addFishingBaits(itemName,baitsCount);
      }
   }
}

