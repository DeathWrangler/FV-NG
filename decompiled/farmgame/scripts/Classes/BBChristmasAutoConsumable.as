package Classes
{
   import Classes.ZItem.FarmItem;
   import Engine.Events.TransactionEvent;
   import Managers.BringBackWinterManager;
   import Managers.CommunityGoalsManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TBringBackChristmas;
   
   public class BBChristmasAutoConsumable extends AutoConsumable
   {
      
      public function BBChristmasAutoConsumable(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume() : void
      {
         var item:FarmItem = getItem();
         var itemName:String = item.name;
         var count:int = item.count;
         var data:Object = BringBackWinterManager.getInstance(item.featureName).getFeatureData();
         var sfType:String = item.subType;
         var index:String = BringBackWinterManager.getSftypeToFeatureDataIndex(sfType);
         data[index] += count;
         FeatureOptionsManager.getInstance().setFeatureOption(item.featureName,BringBackWinterManager.FEATURE_OPTIONS_KEY,data);
         var transaction:TBringBackChristmas = new TBringBackChristmas(item.code,count);
         var event:TransactionEvent = new TransactionEvent(TransactionEvent.ADDED,transaction);
         CommunityGoalsManager.onTransactionAdded(event);
      }
   }
}

