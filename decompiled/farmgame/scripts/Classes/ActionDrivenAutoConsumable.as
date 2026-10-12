package Classes
{
   import Classes.ZItem.FarmItem;
   import Managers.BaseFeatureManager;
   import Widgets.Windows.ActionDrivenWindow;
   
   public class ActionDrivenAutoConsumable extends AutoConsumable
   {
      
      public function ActionDrivenAutoConsumable(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume() : void
      {
         var featureName:String = null;
         var count:Number = NaN;
         var manager:BaseFeatureManager = null;
         var item:FarmItem = getItem();
         if(item)
         {
            featureName = item.featureName;
            if(featureName)
            {
               count = item.count;
               manager = BaseFeatureManager.getInstance(featureName);
               manager.incrementActionCount(count);
               ActionDrivenWindow.refreshStatic(featureName);
            }
         }
      }
   }
}

