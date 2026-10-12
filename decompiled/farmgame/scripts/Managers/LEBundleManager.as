package Managers
{
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.LEBundleIdleTask;
   import Classes.LESaleBundle;
   import Classes.ZItem.FarmItem;
   import Classes.util.LEUtil;
   
   public class LEBundleManager
   {
      
      public static const OVERRIDE_SALE_BUNDLE_VIEW_TYPE_FLAG:String = "overrideLESaleBundleViewType";
      
      public static const SINGLE_SALE_VIEW_TYPE:String = "single";
      
      public static const MULTIPLE_SALE_VIEW_TYPE:String = "multiple";
      
      public static const BUNDLE_SALE_VIEW_TYPE:String = "bundle";
      
      private static var m_outstandingTransactions:int = 0;
      
      public function LEBundleManager()
      {
         super();
      }
      
      public static function handleLEBundleTransactionStart(actionItem:FarmItem) : void
      {
         if(LEUtil.isValidLE(actionItem))
         {
            m_outstandingTransactions += 1;
         }
      }
      
      public static function handleLEBundleTransactionComplete(transactionResult:Object, placedItem:FarmItem) : void
      {
         var saleBundle:Object = null;
         var leSaleBundle:LESaleBundle = null;
         if(LEUtil.isValidLE(placedItem))
         {
            m_outstandingTransactions = m_outstandingTransactions - 1;
         }
         if(Boolean(placedItem) && transactionResult.hasOwnProperty("saleBundle"))
         {
            saleBundle = transactionResult["saleBundle"];
            if(saleBundle)
            {
               leSaleBundle = new LESaleBundle(saleBundle["name"],saleBundle["discount"],saleBundle["customer"],saleBundle["salePrices"]);
               IdleTaskQueue.getInstance().addTask(new LEBundleIdleTask(leSaleBundle));
            }
         }
      }
      
      public static function hasOutstandingTransactions() : Boolean
      {
         return m_outstandingTransactions > 0;
      }
   }
}

