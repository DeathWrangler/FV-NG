package Transactions
{
   public class TBringBackChristmas extends TFarmTransaction
   {
      
      private var m_itemCode:String;
      
      private var m_itemCount:int;
      
      public function TBringBackChristmas(itemCode:String, count:int)
      {
         super();
         this.m_itemCode = itemCode;
         this.m_itemCount = count;
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = "collectSnowFlake";
         result.code = this.m_itemCode;
         result.count = this.m_itemCount;
         return result;
      }
   }
}

