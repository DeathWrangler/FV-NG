package Classes.consumables
{
   import Classes.Consumable;
   import Widgets.Windows.Pigo.PigoWindow;
   
   public class CPigoGameToken extends Consumable
   {
      
      public static const PROMO_MODE:String = "pigo";
      
      public function CPigoGameToken(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         PigoWindow.displayActiveGame("consume",true);
      }
   }
}

