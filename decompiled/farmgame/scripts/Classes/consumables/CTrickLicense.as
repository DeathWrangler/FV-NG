package Classes.consumables
{
   import Classes.Consumable;
   import Classes.ZItem.FarmItem;
   import Managers.TrickOrTreatManager;
   
   public class CTrickLicense extends Consumable
   {
      
      public function CTrickLicense(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         super.consume(isGift,allowReshopping,userID,isFree,storageId);
         var count:int = getItem().count;
         this.addCreditsFromItem(this.getItem(),count);
      }
      
      public function addCreditsFromItem(item:FarmItem, itemCount:int = 1) : void
      {
         for(var i:int = 0; i < itemCount; i++)
         {
            Global.player.incAltGraphicCredits(TrickOrTreatManager.instance.altGraphicCreditName);
         }
      }
   }
}

