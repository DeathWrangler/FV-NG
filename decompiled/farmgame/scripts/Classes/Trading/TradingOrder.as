package Classes.Trading
{
   public class TradingOrder
   {
      
      protected var m_ordererId:* = 0;
      
      protected var m_itemCode:String = "";
      
      protected var m_isFilledOrder:Boolean;
      
      protected var m_orderType:String;
      
      protected var m_orderTime:Number = 0;
      
      protected var m_claimTime:Number = 0;
      
      protected var m_rewardData:Object = null;
      
      public function TradingOrder(ordererId:*, itemCode:String, orderType:String, orderTime:Number, isFilledOrder:Boolean = false, claimTime:Number = 0)
      {
         super();
         this.m_ordererId = ordererId;
         this.m_itemCode = itemCode;
         this.m_isFilledOrder = isFilledOrder;
         this.m_orderType = orderType;
         this.m_orderTime = orderTime;
         this.m_rewardData = null;
         this.m_claimTime = claimTime;
      }
      
      public function get rewardData() : Object
      {
         return this.m_rewardData;
      }
      
      public function set rewardData(value:Object) : void
      {
         this.m_rewardData = value;
      }
      
      public function get orderType() : String
      {
         return this.m_orderType;
      }
      
      public function get isFilledOrder() : Boolean
      {
         return this.m_isFilledOrder;
      }
      
      public function get orderTime() : Number
      {
         return this.m_orderTime;
      }
      
      public function set isFilledOrder(value:Boolean) : void
      {
         this.m_isFilledOrder = value;
      }
      
      public function get ordererId() : *
      {
         return this.m_ordererId;
      }
      
      public function get itemCode() : String
      {
         return this.m_itemCode;
      }
      
      public function set claimTime(value:Number) : void
      {
         this.m_claimTime = value;
      }
      
      public function get claimTime() : Number
      {
         return this.m_claimTime;
      }
   }
}

