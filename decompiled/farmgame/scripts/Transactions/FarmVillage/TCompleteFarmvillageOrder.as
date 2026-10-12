package Transactions.FarmVillage
{
   import Managers.FarmVillageManager;
   import Transactions.TFarmTransaction;
   
   public class TCompleteFarmvillageOrder extends TFarmTransaction
   {
      
      private static const METHOD_COMPLETE_ORDER_NOW:String = "completeFarmVillageOrderNow";
      
      private static const METHOD_FILL_ORDER:String = "fillFarmVillageOrder";
      
      private static const NEW_ORDER:String = "newOrder";
      
      private var m_index:int;
      
      private var m_method:String;
      
      public function TCompleteFarmvillageOrder(index:int, completeNow:Boolean = false)
      {
         this.m_index = index;
         this.m_method = completeNow ? METHOD_COMPLETE_ORDER_NOW : METHOD_FILL_ORDER;
         super();
      }
      
      override public function perform() : void
      {
         signedCall(FarmVillageManager.SERVICE_NAME + "." + this.m_method,this.m_index);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = this.m_method;
         result.orderId = this.m_index;
         result.ordersFilled = 1;
         return result;
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(Boolean(result) && Boolean(result[NEW_ORDER]))
         {
            FarmVillageManager.instance.addOrderToReserve(result[NEW_ORDER]);
         }
      }
   }
}

