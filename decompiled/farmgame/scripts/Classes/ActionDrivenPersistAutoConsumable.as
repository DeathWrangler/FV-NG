package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.BaseFeatureManager;
   import Widgets.Windows.ActionDrivenWindow;
   
   public class ActionDrivenPersistAutoConsumable extends AutoConsumable
   {
      
      public function ActionDrivenPersistAutoConsumable(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume() : void
      {
         var featureName:String = null;
         var manager:BaseFeatureManager = null;
         var itemCode:String = null;
         var item:FarmItem = getItem();
         if(item)
         {
            featureName = item.featureName;
            if(featureName)
            {
               manager = BaseFeatureManager.getInstance(featureName);
               itemCode = item.code;
               manager.incrementActionCountWithOrder(itemCode);
               ActionDrivenWindow.refreshStatic(featureName);
            }
         }
      }
   }
}

