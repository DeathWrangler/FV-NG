package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.WanderingPirateManager;
   
   public class WanderingPirateAutoConsumable extends AutoConsumable
   {
      
      public function WanderingPirateAutoConsumable(itemName:String)
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
               if(WanderingPirateManager.getInstance())
               {
                  WanderingPirateManager.getInstance().changeCurrencyCount(count);
               }
            }
         }
      }
   }
}

