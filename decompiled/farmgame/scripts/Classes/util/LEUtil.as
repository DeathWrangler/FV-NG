package Classes.util
{
   import Classes.ZItem.FarmItem;
   import Managers.LEBundleManager;
   import Managers.LESetManager;
   
   public class LEUtil
   {
      
      private static const VALID_LE_ITEM_TYPES:Array = ["animal","building","decoration","tree"];
      
      public function LEUtil()
      {
         super();
      }
      
      public static function isValidLE(leItem:FarmItem) : Boolean
      {
         var validLE:Boolean = false;
         if(Boolean(leItem && leItem.limitedStartDate && leItem.limitedEndDate && leItem.market == FarmItem.MARKET_CONTEXT_CASH) && Boolean(leItem.cash > 0) && LEUtil.VALID_LE_ITEM_TYPES.indexOf(leItem.type) >= 0)
         {
            validLE = true;
         }
         return validLE;
      }
      
      public static function handleLETransactionStart(actionItem:FarmItem) : void
      {
         LEBundleManager.handleLEBundleTransactionStart(actionItem);
      }
      
      public static function handleLETransactionComplete(transactionResult:Object, placedItem:FarmItem) : void
      {
         LESetManager.handleLESetTransaction(transactionResult,placedItem);
         LEBundleManager.handleLEBundleTransactionComplete(transactionResult,placedItem);
      }
   }
}

