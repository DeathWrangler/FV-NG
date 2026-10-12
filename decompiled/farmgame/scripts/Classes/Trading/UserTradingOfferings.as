package Classes.Trading
{
   import Classes.Friend;
   import Classes.util.FarmGameUtil;
   
   public class UserTradingOfferings
   {
      
      private var m_itemsForSale:Array;
      
      private var m_itemsForOrder:Array;
      
      private var m_ordersFromFriends:Array;
      
      private var m_purchasesFromFriends:Array;
      
      private var m_sellerId:*;
      
      private var m_orderType:String;
      
      private var m_lastOrderTime:Number = 0;
      
      private var m_lastBuyTime:Number = 0;
      
      private var m_ordersToRemove:Array = new Array();
      
      public function UserTradingOfferings(sellerId:*, orderType:String)
      {
         super();
         this.m_sellerId = sellerId;
         this.m_itemsForSale = new Array();
         this.m_itemsForOrder = new Array();
         this.m_ordersFromFriends = new Array();
         this.m_purchasesFromFriends = new Array();
         this.m_orderType = orderType;
      }
      
      public function get sellerId() : *
      {
         return this.m_sellerId;
      }
      
      public function get itemsForSale() : Array
      {
         return this.m_itemsForSale;
      }
      
      public function get itemsForOrder() : Array
      {
         var good:TradingGood = null;
         var items:Array = new Array();
         for each(good in this.m_itemsForOrder)
         {
            if(this.isItemForOrder(good.itemCode))
            {
               items.push(good);
            }
         }
         return items;
      }
      
      public function get mostRecentGoodTime() : Number
      {
         var good:TradingGood = null;
         var mostRecentTime:Number = 0;
         for each(good in this.m_itemsForOrder)
         {
            if(this.isItemForOrder(good.itemCode) && good.timestamp > mostRecentTime)
            {
               mostRecentTime = good.timestamp;
            }
         }
         return mostRecentTime;
      }
      
      public function get purchasesFromFriends() : Array
      {
         return this.m_purchasesFromFriends;
      }
      
      public function get ordersFromFriends() : Array
      {
         return this.m_ordersFromFriends;
      }
      
      public function get ordersFromFriendsSafe() : Array
      {
         var friend:Friend = null;
         var friendUid:String = null;
         var safeArray:Array = new Array();
         var tradingOrder:TradingOrder = null;
         for(var i:Number = 0; i < this.m_ordersFromFriends.length; i++)
         {
            tradingOrder = this.m_ordersFromFriends[i];
            friend = Global.friendManager.getAppFriendData(tradingOrder.ordererId);
            if(friend != null)
            {
               friendUid = String(friend.uid);
               if(friendUid != Global.player.uid)
               {
                  safeArray.push(tradingOrder);
               }
            }
         }
         return safeArray;
      }
      
      public function getUnfilledOrderTradingGoods(buyerId:String) : Array
      {
         var tradingOrder:TradingOrder = null;
         var unfilledOrders:Array = new Array();
         for(var i:Number = 0; i < this.m_ordersFromFriends.length; i++)
         {
            tradingOrder = this.m_ordersFromFriends[i];
            if(tradingOrder.ordererId == buyerId && !tradingOrder.isFilledOrder)
            {
               unfilledOrders.push(new TradingGood(this.sellerId,tradingOrder.itemCode,OrderTypes.CROP_ORDER,TradingGood.ORDER_TAKEN));
            }
         }
         return unfilledOrders;
      }
      
      public function get lastBuyTime() : Number
      {
         return this.m_lastBuyTime;
      }
      
      public function get lastOrderTime() : Number
      {
         return this.m_lastOrderTime;
      }
      
      public function set lastBuyTime(value:Number) : void
      {
         this.m_lastBuyTime = value;
      }
      
      public function set lastOrderTime(value:Number) : void
      {
         this.m_lastOrderTime = value;
      }
      
      public function get hasClaimableOrders() : Boolean
      {
         var result:Boolean = false;
         var tradingOrder:TradingOrder = null;
         for(var i:Number = 0; i < this.m_ordersFromFriends.length; i++)
         {
            tradingOrder = this.m_ordersFromFriends[i];
            if(tradingOrder.isFilledOrder && tradingOrder.claimTime <= 0)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function addOrderFromFriend(friendUid:*, itemCode:String, orderTime:Number, isFilledOrder:Boolean = false, claimTime:Number = 0) : void
      {
         var tradingOrder:TradingOrder = new TradingOrder(friendUid,itemCode,this.m_orderType,orderTime,isFilledOrder,claimTime);
         this.m_ordersFromFriends.push(tradingOrder);
      }
      
      public function addPurchaseFromFriend(friendUid:*, itemCode:String, orderTime:Number) : void
      {
         var tradingOrder:TradingOrder = new TradingOrder(friendUid,itemCode,this.m_orderType,orderTime,true);
         this.m_purchasesFromFriends.push(tradingOrder);
      }
      
      public function addForSaleItem(itemCode:String, isFilledOrder:Boolean = false) : void
      {
         var type:String = isFilledOrder ? TradingGood.FOR_CLAIM : TradingGood.FOR_SALE;
         var tradingGood:TradingGood = new TradingGood(this.m_sellerId,itemCode,this.m_orderType,type);
         this.m_itemsForSale.push(tradingGood);
      }
      
      public function addForOrderItem(itemCode:String, timestamp:Number) : void
      {
         var tradingGood:TradingGood = new TradingGood(this.m_sellerId,itemCode,this.m_orderType,TradingGood.FOR_ORDER,timestamp);
         this.m_itemsForOrder.push(tradingGood);
      }
      
      public function updateOrderState(itemCode:String, orderState:String) : void
      {
         var forSaleGood:TradingGood = null;
         var tradingGood:TradingGood = null;
         var foundOrder:Boolean = false;
         for each(forSaleGood in this.m_itemsForSale)
         {
            if(forSaleGood.itemCode == itemCode)
            {
               forSaleGood.goodStatusType = orderState;
               foundOrder = true;
               break;
            }
         }
         if(!foundOrder)
         {
            tradingGood = new TradingGood(this.m_sellerId,itemCode,this.m_orderType,orderState);
            this.m_itemsForSale.push(tradingGood);
         }
      }
      
      public function fulfillFriendOrder(itemCode:String, plantTime:Number) : Boolean
      {
         var tradingOrder:TradingOrder = null;
         var orderFulfilled:Boolean = false;
         for each(tradingOrder in this.m_ordersFromFriends)
         {
            if(tradingOrder.itemCode == itemCode && tradingOrder.isFilledOrder == false)
            {
               if(tradingOrder.orderTime * FarmGameUtil.NUM_MSECS_IN_SECOND > plantTime)
               {
                  tradingOrder.isFilledOrder = true;
                  orderFulfilled = true;
               }
            }
         }
         return orderFulfilled;
      }
      
      public function queueOrderToRemove(order:TradingOrder) : void
      {
         this.m_ordersToRemove.push(order);
      }
      
      public function flushOrdersToRemove() : void
      {
         var order:TradingOrder = null;
         for each(order in this.m_ordersToRemove)
         {
            this.removeOrderFromFriend(order.ordererId,order.itemCode);
         }
         this.m_ordersToRemove = new Array();
      }
      
      public function removeOrderFromFriend(friendUid:String, itemCode:String) : void
      {
         var tradingOrder:TradingOrder = null;
         for(var i:Number = 0; i < this.m_ordersFromFriends.length; i++)
         {
            tradingOrder = this.m_ordersFromFriends[i];
            if(tradingOrder.ordererId == friendUid && tradingOrder.itemCode == itemCode)
            {
               this.m_ordersFromFriends.splice(i,1);
               break;
            }
         }
      }
      
      public function orderExists(friendUid:*, itemCode:String, isFilledOrder:Boolean = false, isClaimed:Boolean = false) : Boolean
      {
         var tradingOrder:TradingOrder = null;
         var tradingOrderId:String = null;
         var result:Boolean = false;
         for(var i:Number = 0; i < this.m_ordersFromFriends.length; i++)
         {
            tradingOrder = this.m_ordersFromFriends[i];
            tradingOrderId = String(tradingOrder.ordererId);
            friendUid = String(friendUid);
            if(tradingOrderId == friendUid && tradingOrder.itemCode == itemCode && tradingOrder.claimTime > 0 == isClaimed && tradingOrder.isFilledOrder == isFilledOrder)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function isItemForOrder(itemCode:String) : Boolean
      {
         var tradingGood:TradingGood = null;
         var i:Number = NaN;
         var result:Boolean = false;
         var tradingOrder:TradingOrder = this.getOrder(itemCode,Global.player.uid,true);
         var alreadyOrdered:Boolean = Boolean(tradingOrder) && tradingOrder.claimTime == 0;
         if(!alreadyOrdered)
         {
            tradingGood = null;
            for(i = 0; i < this.m_itemsForOrder.length; i++)
            {
               tradingGood = this.m_itemsForOrder[i];
               if(tradingGood.itemCode == itemCode)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function isItemForSale(itemCode:String) : Boolean
      {
         var result:Boolean = false;
         var tradingGood:TradingGood = null;
         for(var i:Number = 0; i < this.m_itemsForSale.length; i++)
         {
            tradingGood = this.m_itemsForSale[i];
            if(tradingGood.itemCode == itemCode)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      private function getOrder(itemCode:String, buyerId:*, ignoreClaimed:Boolean = false) : TradingOrder
      {
         var result:TradingOrder = null;
         var tradingOrder:TradingOrder = null;
         for(var i:Number = 0; i < this.m_ordersFromFriends.length; i++)
         {
            tradingOrder = this.m_ordersFromFriends[i];
            if(tradingOrder.ordererId == buyerId && tradingOrder.itemCode == itemCode && (!ignoreClaimed || tradingOrder.claimTime == 0))
            {
               result = tradingOrder;
               break;
            }
         }
         return result;
      }
   }
}

