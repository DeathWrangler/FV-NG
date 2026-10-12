package Classes.Trading
{
   import Classes.Friend;
   
   public class TradingPostMarketView
   {
      
      private var m_userOfferings:Array;
      
      private var m_myUserOffering:UserTradingOfferings = null;
      
      private var m_myPendingGoodOrders:Array = new Array();
      
      public function TradingPostMarketView(rawData:Object, orderType:String)
      {
         super();
         this.parseRawData(rawData,orderType);
      }
      
      public function getMyUserOffering() : UserTradingOfferings
      {
         return this.m_myUserOffering;
      }
      
      public function getAllFriendOfferings() : Array
      {
         return this.m_userOfferings;
      }
      
      public function getAllFriendOfferingsSafe() : Array
      {
         var friend:Friend = null;
         var friendId:String = null;
         var safeArray:Array = new Array();
         var userOffering:UserTradingOfferings = null;
         for(var i:Number = 0; i < this.m_userOfferings.length; i++)
         {
            userOffering = this.m_userOfferings[i];
            friend = Global.friendManager.getAppFriendData(userOffering.sellerId);
            if(friend != null)
            {
               friendId = String(friend.uid);
               if(friendId != Global.player.uid)
               {
                  safeArray.push(userOffering);
               }
            }
         }
         return safeArray;
      }
      
      public function getFriendOffering(sellerId:String) : UserTradingOfferings
      {
         var offering:UserTradingOfferings = null;
         var offeringData:UserTradingOfferings = null;
         for each(offering in this.m_userOfferings)
         {
            if(offering.sellerId == sellerId)
            {
               offeringData = offering;
            }
         }
         return offeringData;
      }
      
      public function addPendingGoodOrder(sellerId:*, itemCode:String) : void
      {
         var tempPendingKey:String = sellerId + ":" + itemCode;
         this.m_myPendingGoodOrders[tempPendingKey] = true;
      }
      
      public function hasPendingGoodOrder(sellerId:*, itemCode:String) : Boolean
      {
         var tempPendingKey:String = sellerId + ":" + itemCode;
         return this.m_myPendingGoodOrders[tempPendingKey] == null ? false : true;
      }
      
      private function parseRawData(rawData:Object, orderType:String) : void
      {
         var sellerId:* = undefined;
         var itemCode:String = null;
         var isFilledOrder:Boolean = false;
         var tradingGood:TradingGood = null;
         var forSaleGoods:Array = null;
         var forOrderGoods:Array = null;
         var ordersFromFriends:Object = null;
         var userOfferings:Object = null;
         var data:Object = null;
         var userOfferingData:UserTradingOfferings = null;
         var hasOfferings:Boolean = false;
         var orderTime:Number = NaN;
         var claimTime:Number = NaN;
         var rewardTime:Number = NaN;
         var fillTime:Number = NaN;
         var purchasesFromFriends:Object = null;
         var ordererItemCode:String = null;
         var userId:String = null;
         var ordererUid:String = null;
         var itemOrder:Object = null;
         this.m_userOfferings = new Array();
         var orderData:Object = null;
         var realOrdererUid:* = 0;
         var realPurchaserUid:String = "0";
         var ordererSingleData:Object = null;
         var realUid:* = 0;
         var purchaseData:Object = null;
         for(userId in rawData)
         {
            hasOfferings = false;
            realUid = userId.substring(1,userId.length);
            userOfferingData = new UserTradingOfferings(realUid,orderType);
            userOfferings = rawData[userId];
            forSaleGoods = userOfferings.forSale;
            forOrderGoods = userOfferings.forOrder;
            ordersFromFriends = userOfferings.orders;
            purchasesFromFriends = userOfferings.purchases;
            for each(data in forSaleGoods)
            {
               hasOfferings = true;
               userOfferingData.addForSaleItem(data.item,data.filledOrder);
            }
            for each(data in forOrderGoods)
            {
               hasOfferings = true;
               userOfferingData.addForOrderItem(data.item,data.ts);
            }
            for(ordererUid in ordersFromFriends)
            {
               orderData = ordersFromFriends[ordererUid];
               if(orderData != null)
               {
                  realOrdererUid = ordererUid.substring(1,ordererUid.length);
                  for(ordererItemCode in orderData)
                  {
                     ordererSingleData = orderData[ordererItemCode];
                     if(ordererSingleData != null)
                     {
                        for each(itemOrder in ordererSingleData)
                        {
                           orderTime = itemOrder.hasOwnProperty("orderTime") ? Number(itemOrder.orderTime) : 0;
                           claimTime = itemOrder.hasOwnProperty("claimed") ? Number(itemOrder.claimed) : 0;
                           rewardTime = itemOrder.hasOwnProperty("rewarded") ? Number(itemOrder.rewarded) : 0;
                           fillTime = itemOrder.hasOwnProperty("filled") ? Number(itemOrder.filled) : 0;
                           realUid = String(realUid);
                           if(Global.player.uid == realUid ? !rewardTime : true)
                           {
                              userOfferingData.addOrderFromFriend(realOrdererUid,ordererItemCode,orderTime,fillTime > 0,claimTime);
                           }
                           if(!fillTime && !claimTime)
                           {
                              this.addPendingGoodOrder(realUid,ordererItemCode);
                           }
                           else if(Boolean(fillTime) && !claimTime)
                           {
                              hasOfferings = true;
                              userOfferingData.updateOrderState(ordererItemCode,TradingGood.FOR_CLAIM);
                           }
                        }
                     }
                  }
               }
            }
            if(Global.player.uid == realUid)
            {
               this.m_myUserOffering = userOfferingData;
            }
            else if(hasOfferings)
            {
               this.m_userOfferings.push(userOfferingData);
            }
         }
      }
   }
}

