package Classes.consumables
{
   import Classes.Consumable;
   
   public class CSuperPlot extends Consumable
   {
      
      public function CSuperPlot(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
      }
      
      override public function onUse() : void
      {
      }
   }
}

