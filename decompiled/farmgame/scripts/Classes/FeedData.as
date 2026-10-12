package Classes
{
   import Classes.ZItem.FarmItem;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransactionWithFeed;
   
   public class FeedData
   {
      
      private static const INVENTORY_MANAGER_NAME:String = "inventoryManager";
      
      private const THROTTLE_SUFFIX:String = "_frequency";
      
      private const SERVICE_NAME:String = "FeedService";
      
      private var item:FarmItem;
      
      private var throttleId:String;
      
      private var throttleTime:int;
      
      private var featureName:String;
      
      private var source:String;
      
      public function FeedData(featureName:String, data:Object)
      {
         super();
         this.featureName = featureName;
         this.source = data.@source.toString();
         this.throttleId = featureName + this.source + this.THROTTLE_SUFFIX;
         this.item = Global.farmGameSettingsManager.getFarmItemByName(data.@item.toString());
         this.throttleTime = int(data.@throttleTime);
      }
      
      public function get throttleTimeRemaining() : int
      {
         var time:int = 0;
         var now:int = int(GlobalEngine.serverTime / 1000);
         var lastShown:int = Global.player.getFeatureLastShown(this.throttleId);
         if(lastShown != 0)
         {
            time = lastShown + this.throttleTime - now;
         }
         return time;
      }
      
      public function postFeed(callback:Function = null) : void
      {
         if(this.throttleTimeRemaining <= 0)
         {
            TransactionManager.addTransaction(new TGenericTransactionWithFeed(this.SERVICE_NAME,"postFeed",callback,[this.featureName,this.source]));
            Global.player.setFeatureLastShown(this.throttleId,GlobalEngine.serverTime / 1000,true);
         }
      }
      
      public function getInventoryCount() : int
      {
         return int(FeatureOptionsManager.getInstance().getFeatureOption(FeedData.INVENTORY_MANAGER_NAME,this.item.name));
      }
   }
}

