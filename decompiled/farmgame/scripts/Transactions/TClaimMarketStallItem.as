package Transactions
{
   public class TClaimMarketStallItem extends TFarmTransaction
   {
      
      public static const CLAIMED_OK:int = 0;
      
      public static const BUSHEL_EXPIRED:int = 1;
      
      public static const USERS_NOT_FRIENDS:int = 2;
      
      public static const BUSHEL_NOT_FOUND:int = 3;
      
      public static const BAGS_EXHAUSTED:int = 4;
      
      public static const SILO_FULL:int = 5;
      
      public static const METHOD_CLAIM_MARKET_STALL_ITEM:String = "onClaimMarketStallItem";
      
      private var m_Callback:Function;
      
      private var m_Uid:String;
      
      private var m_BushelItemCode:String;
      
      public function TClaimMarketStallItem(uid:String, bushelItemCode:String, callBack:Function = null)
      {
         super();
         this.m_Callback = callBack;
         this.m_Uid = uid;
         this.m_BushelItemCode = bushelItemCode;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService." + METHOD_CLAIM_MARKET_STALL_ITEM,this.m_Uid,this.m_BushelItemCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != result)
         {
            if(null != this.m_Callback)
            {
               this.m_Callback(this.m_Uid,this.m_BushelItemCode,result.responseCode);
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_CLAIM_MARKET_STALL_ITEM;
         result.friendUid = this.m_Uid;
         result.itemCode = this.m_BushelItemCode;
         return result;
      }
   }
}

