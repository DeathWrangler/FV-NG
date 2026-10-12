package Transactions
{
   import Engine.Managers.TransactionManager;
   import flash.utils.Dictionary;
   
   public class TBuyCraftedGood extends TFarmTransaction
   {
      
      public static const GOOD_PURCHASED_OK:int = 0;
      
      public static const SELLING_USER_NOT_FOUND:int = 1;
      
      public static const SELLING_USER_NOT_FRIEND:int = 2;
      
      public static const BUYING_USER_HAD_NO_ROOM:int = 3;
      
      public static const PURCHASE_LIMIT_HIT_USER:int = 4;
      
      public static const PURCHASE_LIMIT_HIT_GLOBAL:int = 5;
      
      public static const GOOD_NOT_FOUND:int = 6;
      
      public static const GOOD_INSUFFICIENT_QUANTITY:int = 7;
      
      public static const GOOD_BAD_PRICE:int = 8;
      
      public static const OFFER_BAD_PRICE:int = 9;
      
      public static const OFFER_INSUFFICIENT_FUNDS:int = 10;
      
      public static const OTHER_ERROR:int = 11;
      
      public static const OFFER_OUT_OF_SYNC:int = 12;
      
      private var m_marketRefreshCallback:Function = null;
      
      private var m_buyGoodsQueue:Array = new Array();
      
      private var m_buyGoodsCallbackQueue:Dictionary = new Dictionary();
      
      private var m_pendingBuyGoodsQueue:Array = new Array();
      
      private var m_pendingBuyGoodsCallbackQueue:Dictionary = new Dictionary();
      
      public function TBuyCraftedGood(marketRefreshCallback:Function = null)
      {
         super();
         this.m_marketRefreshCallback = marketRefreshCallback;
      }
      
      public function queueBuyGood(itemCode:String, fromUserId:String, price:Number, buyGoodsCallback:Function = null) : void
      {
         var buyGood:Object = {};
         buyGood.itemCode = itemCode;
         buyGood.sellingUserId = fromUserId;
         buyGood.priceOffered = price;
         if(this.canPerform)
         {
            if(this.m_buyGoodsQueue.length == 0)
            {
               TransactionManager.addTransaction(this);
            }
            this.m_buyGoodsQueue.push(buyGood);
            this.m_buyGoodsCallbackQueue[fromUserId] = buyGoodsCallback;
         }
         else
         {
            this.m_pendingBuyGoodsQueue.push(buyGood);
            this.m_pendingBuyGoodsCallbackQueue[fromUserId] = buyGoodsCallback;
         }
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onBuyCraftedGoods",this.m_buyGoodsQueue);
         this.canPerform = false;
      }
      
      override protected function onComplete(result:Object) : void
      {
         var buyResults:Array = null;
         var buyResult:Object = null;
         var buyCallback:Function = null;
         if(Boolean(result) && Boolean(result.buyResponse) && Boolean(result.buyResponse.buyResults))
         {
            buyResults = result.buyResponse.buyResults;
            for each(buyResult in buyResults)
            {
               buyCallback = this.m_buyGoodsCallbackQueue[buyResult.sellingUserId];
               if(buyCallback != null)
               {
                  buyCallback(buyResult);
               }
            }
            if(this.m_marketRefreshCallback != null)
            {
               this.m_marketRefreshCallback(result);
            }
         }
         this.m_buyGoodsQueue = new Array();
         if(this.m_pendingBuyGoodsQueue.length > 0)
         {
            this.m_buyGoodsQueue = this.m_pendingBuyGoodsQueue;
            this.m_buyGoodsCallbackQueue = this.m_pendingBuyGoodsCallbackQueue;
            this.m_pendingBuyGoodsQueue = new Array();
            TransactionManager.addTransaction(this);
         }
         this.canPerform = true;
      }
   }
}

