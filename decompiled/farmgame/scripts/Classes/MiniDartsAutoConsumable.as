package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.MiniDartsManager;
   
   public class MiniDartsAutoConsumable extends AutoConsumable
   {
      
      public function MiniDartsAutoConsumable(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume() : void
      {
         var featureName:String = null;
         var count:Number = NaN;
         var item:FarmItem = getItem();
         if(item)
         {
            featureName = item.featureName;
            if(featureName)
            {
               count = item.count;
               MiniDartsManager.getInstance().changeCurrencyCount(count);
            }
         }
      }
   }
}

