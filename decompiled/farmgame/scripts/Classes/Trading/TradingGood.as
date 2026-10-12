package Classes.Trading
{
   public class TradingGood
   {
      
      public static const FOR_SALE:String = "sale";
      
      public static const FOR_ORDER:String = "order";
      
      public static const ORDER_TAKEN:String = "ordered";
      
      public static const ORDER_REMIND:String = "remind";
      
      public static const FOR_CLAIM:String = "claim";
      
      protected var m_goodStatusType:String;
      
      protected var m_sellingUid:String = "0";
      
      protected var m_itemCode:String = "";
      
      protected var m_orderType:String;
      
      protected var m_timestamp:Number = 0;
      
      public function TradingGood(sellingUid:String, itemCode:String, orderType:String, goodStatusType:String, timestamp:Number = 0)
      {
         super();
         this.m_sellingUid = sellingUid;
         this.m_itemCode = itemCode;
         this.m_orderType = orderType;
         this.m_goodStatusType = goodStatusType;
         this.m_timestamp = timestamp;
      }
      
      public function get timestamp() : Number
      {
         return this.m_timestamp;
      }
      
      public function serializeForPhp() : Object
      {
         var phpObject:Object = {};
         phpObject["sellingUid"] = this.m_sellingUid;
         phpObject["itemCode"] = this.m_itemCode;
         return phpObject;
      }
      
      public function get isClaimable() : Boolean
      {
         var orderExistsFilled:Boolean = false;
         var result:Boolean = false;
         var userOffering:UserTradingOfferings = TradingPostManager.getInstance().marketView.getFriendOffering(this.sellingUid);
         if(userOffering != null)
         {
            orderExistsFilled = userOffering.orderExists(Global.player.uid,this.itemCode,true);
            result = orderExistsFilled;
         }
         return result;
      }
      
      public function set goodStatusType(goodStatusType:String) : void
      {
         this.m_goodStatusType = goodStatusType;
      }
      
      public function get goodStatusType() : String
      {
         return this.m_goodStatusType;
      }
      
      public function get orderType() : String
      {
         return this.m_orderType;
      }
      
      public function get sellingUid() : String
      {
         return this.m_sellingUid;
      }
      
      public function get itemCode() : String
      {
         return this.m_itemCode;
      }
   }
}

