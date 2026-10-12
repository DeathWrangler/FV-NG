package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.FeatureOptionsInventoryManager;
   
   public class FeatureOptionAutoConsumable extends AutoConsumable
   {
      
      public function FeatureOptionAutoConsumable(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume() : void
      {
         var item:FarmItem = getItem();
         var itemCode:String = item.code;
         var count:int = item.count;
         if(count == 0)
         {
            count = 1;
         }
         if(itemCode)
         {
            FeatureOptionsInventoryManager.getInstance().addCount(itemCode,count);
         }
      }
   }
}

