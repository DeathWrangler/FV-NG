package Classes.Trading
{
   import Classes.Friend;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.TradingPostNoOrderTask;
   import Classes.TradingPostBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.ToasterManager;
   import Transactions.TClaimSellerReward;
   import Transactions.TTradingBuyGood;
   import Transactions.TTradingOrderGood;
   import Transactions.TUpdateTradingPost;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.Trading.TradingPostWindow;
   import flash.display.DisplayObject;
   
   public class TradingPostManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:TradingPostManager = null;
      
      private var m_tradingPostWindow:TradingPostWindow = null;
      
      private var m_marketView:TradingPostMarketView;
      
      private var m_settingsAttrs:Array = null;
      
      private var m_tempResultData:Array = new Array();
      
      private var m_autoPublishCallback:Function = null;
      
      public function TradingPostManager()
      {
         super();
      }
      
      public static function getInstance() : TradingPostManager
      {
         if(m_instance == null)
         {
            m_instance = new TradingPostManager();
         }
         return m_instance;
      }
      
      public function reloadTradingData(callback:Function) : void
      {
         var localCallback:Function = function(result:Object):void
         {
            var tradingPostManager:TradingPostManager = null;
            if(result != null && Boolean(result.crop_order))
            {
               tradingPostManager = TradingPostManager.getInstance();
               tradingPostManager.marketView = new TradingPostMarketView(result.crop_order,OrderTypes.CROP_ORDER);
               if(callback != null)
               {
                  callback();
               }
            }
         };
         TransactionManager.addTransaction(new TUpdateTradingPost(localCallback),true);
      }
      
      public function getSettings(settingsType:String = null) : Array
      {
         var configXML:XMLList = null;
         var orderType:XML = null;
         var orderName:String = null;
         var orderAttr:XML = null;
         var settings:Array = null;
         if(this.m_settingsAttrs == null)
         {
            this.m_settingsAttrs = new Array();
            configXML = Global.farmGameSettingsManager.getXML().trading;
            for each(orderType in configXML.*)
            {
               orderName = String(orderType.name());
               this.m_settingsAttrs[orderName] = new Array();
               for each(orderAttr in orderType.*)
               {
                  this.m_settingsAttrs[orderName][String(orderAttr.name())] = String(orderAttr.valueOf());
               }
            }
         }
         if(settingsType != null)
         {
            settings = this.m_settingsAttrs[settingsType];
         }
         else
         {
            settings = this.m_settingsAttrs;
         }
         return settings;
      }
      
      public function getConfigAttr(settingsType:String, settingName:String) : *
      {
         var settings:Array = this.getSettings(settingsType);
         return settings[settingName];
      }
      
      public function hasPlacedBuilding() : Boolean
      {
         return Global.world.getObjectsByClass(TradingPostBuilding).length > 0;
      }
      
      public function set marketView(marketView:TradingPostMarketView) : void
      {
         this.getSettings();
         this.m_marketView = marketView;
      }
      
      public function get marketView() : TradingPostMarketView
      {
         return this.m_marketView;
      }
      
      public function showTradingPostWindow(defaultTab:String = null) : void
      {
         if(this.m_tradingPostWindow == null && this.m_marketView != null)
         {
            this.m_tradingPostWindow = new TradingPostWindow(this.m_marketView.getAllFriendOfferingsSafe(),this.m_marketView.getMyUserOffering());
            this.m_tradingPostWindow.setDefaultTab(defaultTab);
            UI.displayPopup(this.m_tradingPostWindow,false);
         }
      }
      
      public function clearTradingPostWindow() : void
      {
         this.m_tradingPostWindow = null;
      }
      
      public function getFriendsWithSellingGoods() : Array
      {
         var friendOfferings:Array = null;
         var offeringData:UserTradingOfferings = null;
         var friends:Array = new Array();
         if(this.m_marketView != null)
         {
            friendOfferings = this.m_marketView.getAllFriendOfferings();
            for each(offeringData in friendOfferings)
            {
               if(offeringData.itemsForSale.length > 0 || offeringData.itemsForOrder.length > 0)
               {
                  friends.push(String(offeringData.sellerId));
               }
            }
         }
         return friends;
      }
      
      public function getFriendsWithOrderGoods() : Array
      {
         var friendOfferings:Array = null;
         var offeringData:UserTradingOfferings = null;
         var friends:Array = new Array();
         if(this.m_marketView != null)
         {
            friendOfferings = this.m_marketView.getAllFriendOfferings();
            for each(offeringData in friendOfferings)
            {
               if(offeringData.itemsForOrder.length > 0)
               {
                  friends.push(String(offeringData.sellerId));
               }
            }
         }
         return friends;
      }
      
      public function getTotalFriendOrders() : Number
      {
         var myOffering:UserTradingOfferings = null;
         var counter:Number = 0;
         if(this.m_marketView != null)
         {
            myOffering = this.m_marketView.getMyUserOffering();
            if(myOffering != null)
            {
               counter = myOffering.ordersFromFriendsSafe.length;
            }
         }
         return counter;
      }
      
      public function putGoodUpForSale(itemCode:String, plantTime:Number) : void
      {
         var userOffering:UserTradingOfferings = null;
         var orderFulfilled:Boolean = false;
         var item:FarmItem = null;
         var callbackFunc:Function = null;
         var title:String = null;
         var body:String = null;
         try
         {
            if(this.m_marketView)
            {
               userOffering = this.m_marketView.getMyUserOffering();
               if(userOffering != null)
               {
                  orderFulfilled = userOffering.fulfillFriendOrder(itemCode,plantTime);
                  if(orderFulfilled)
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                     if(item)
                     {
                        callbackFunc = function():void
                        {
                           showTradingPostWindow(TradingPostWindow.TAB_ORDERS);
                        };
                        title = ZLocUtils.t("Dialogs","tradingpost_toaster_fulfilled_title");
                        body = ZLocUtils.t("Dialogs","tradingpost_toaster_fulfilled_body",{"itemName":ZLocUtils.tk_pk(item.friendlyName)});
                        ToasterManager.getInstance().add(new IconTitleToasterWindow(title,body,item.icon,"assets/dialogs/FV_Craft_BannerAd.swf",0.75,null,callbackFunc));
                     }
                  }
                  else if(!Global.player.getSeenSessionFlag(TradingPostConstants.SEEN_TRADING_NO_ORDER_PROMPT))
                  {
                     IdleTaskQueue.getInstance().addTask(new TradingPostNoOrderTask(itemCode));
                  }
               }
            }
         }
         catch(error:Error)
         {
         }
      }
      
      public function remindFriend(remindGood:TradingGood) : void
      {
         var feedImage:String = Global.getAssetURL("assets/newsfeed/feed_tradingpostbountiful.png");
         var hasAutoPublish:Boolean = TradingPostManager.getInstance().hasAutoPublishPermissions();
         var buyer:Friend = Global.friendManager.getAppFriendData(remindGood.sellingUid);
         var harvestedItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(remindGood.itemCode);
         var buyerName:String = "";
         if(buyer != null)
         {
            buyerName = buyer.firstName;
         }
         var bundleData:Object = {
            "buyer":buyerName,
            "user":Global.player.firstName,
            "cropName":harvestedItem.friendlyTitle,
            "images":[{
               "href":"{SN_APP_URL}?ref=trading_post_remind",
               "src":feedImage
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory("tradingpost_RemindOrder",bundleData,[remindGood.sellingUid],false,null,0,false,hasAutoPublish);
         Global.player.setFeatureLastShown(TradingPostConstants.TRADE_REMIND_W2W_FLAG + remindGood.sellingUid,GlobalEngine.serverTime / 1000,true);
      }
      
      public function buyGood(goodToBuy:TradingGood) : Object
      {
         var friendOffering:UserTradingOfferings = null;
         var buyTransaction:TTradingBuyGood = null;
         var buyGoodCallback:Function = function(result:Object):void
         {
            var farmItem:FarmItem = null;
            if(result != null && result.error == null)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(goodToBuy.itemCode);
               if(goodToBuy.goodStatusType == TradingGood.FOR_SALE)
               {
                  FarmStatsManager.count(TradingPostConstants.STATS_TRADINGPOST_COUNTER,"trading_post_ordering","Bought",farmItem.name);
               }
               else
               {
                  FarmStatsManager.count(TradingPostConstants.STATS_TRADINGPOST_COUNTER,"trading_post_ordering","Claimed",farmItem.name);
                  StatsManager.social("claim_order",goodToBuy.sellingUid.toString(),"crop_order","accept",farmItem.name,"",1,Global.worldManager.currentWorldType);
               }
            }
            else if(Boolean(result) && Boolean(result.error))
            {
               displayError(result.error.errorData);
            }
         };
         var rewardData:Object = this.grantBuyReward(goodToBuy);
         if(rewardData)
         {
            friendOffering = this.m_marketView.getFriendOffering(goodToBuy.sellingUid);
            if(friendOffering != null)
            {
               friendOffering.addPurchaseFromFriend(Global.player.uid,goodToBuy.itemCode,GlobalEngine.serverTime / 1000);
            }
            this.displayRewardStatus(goodToBuy.itemCode,rewardData.numCoins,rewardData.numXP,rewardData.numMastery);
            buyTransaction = new TTradingBuyGood(goodToBuy,buyGoodCallback,this.displayError);
            TransactionManager.addTransaction(buyTransaction,false);
         }
         return rewardData;
      }
      
      public function grantBuyReward(goodToBuy:TradingGood) : Object
      {
         var result:Object = null;
         var itemCode:String = null;
         var rewardXpMultiplier:Number = Number(this.getConfigAttr(TradingPostConstants.SETTINGS_TYPE_CROP,"buyerRewardXpMultiplier"));
         var rewardMasteryMultiplier:Number = Number(this.getConfigAttr(TradingPostConstants.SETTINGS_TYPE_CROP,"buyerRewardMasteryMultiplier"));
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(goodToBuy.itemCode);
         var numXP:Number = Number(farmItem.plantXp * rewardXpMultiplier);
         var numMastery:Number = Number(1 * rewardMasteryMultiplier);
         var numGold:Number = Number(farmItem.cost);
         if(Global.player.canBuy(int(numGold),true))
         {
            numXP = Global.player.calculateAndAddXp(numXP);
            itemCode = goodToBuy.itemCode;
            if(Global.player.masteryCounters[itemCode] == null)
            {
               Global.player.masteryCounters[itemCode] = 0;
            }
            Global.player.masteryCounters[itemCode] += numMastery;
            Global.player.gold -= numGold;
            result = {};
            result.numMastery = numMastery;
            result.numXP = numXP;
            result.numCoins = -numGold;
         }
         return result;
      }
      
      public function orderGood(goodToOrder:TradingGood) : void
      {
         var orderTransaction:TTradingOrderGood;
         var orderGoodCallback:Function = function(result:Object):void
         {
            var farmItem:FarmItem = null;
            if(result != null && Boolean(result.error))
            {
               displayError(result.error.errorData);
            }
            else
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(goodToOrder.itemCode);
               FarmStatsManager.count(TradingPostConstants.STATS_TRADINGPOST_COUNTER,"trading_post_ordering","Ordered",farmItem.name);
               StatsManager.social("crop_order",goodToOrder.sellingUid.toString(),"order","crop",farmItem.name,"",1,Global.worldManager.currentWorldType);
            }
         };
         var friendOffering:UserTradingOfferings = this.m_marketView.getFriendOffering(goodToOrder.sellingUid);
         if(friendOffering != null)
         {
            friendOffering.addOrderFromFriend(Global.player.uid,goodToOrder.itemCode,GlobalEngine.serverTime / 1000);
            this.m_marketView.addPendingGoodOrder(goodToOrder.sellingUid,goodToOrder.itemCode);
         }
         orderTransaction = new TTradingOrderGood(goodToOrder,orderGoodCallback,this.displayError);
         TransactionManager.addTransaction(orderTransaction,false);
         Global.player.setFeatureLastShown(TradingPostConstants.TRADE_REMIND_W2W_FLAG + goodToOrder.sellingUid,GlobalEngine.serverTime / 1000,true);
      }
      
      public function postOrderGoodFeed(goodToOrder:TradingGood, displayObj:DisplayObject) : void
      {
         var tradingPost:TradingPostBuilding = null;
         var tradingPostBuildings:Array = Global.world.getObjectsByClass(TradingPostBuilding);
         if(tradingPostBuildings.length > 0)
         {
            tradingPost = tradingPostBuildings[0];
            tradingPost.removeArrowIndicator();
         }
      }
      
      private function onOrderHelper(result:Object) : void
      {
         var goodToOrder:TradingGood = null;
         var feedImage:String = null;
         var hasAutoPublish:Boolean = false;
         var buyer:Friend = null;
         var harvestedItem:FarmItem = null;
         var buyerName:String = null;
         var bundleData:Object = null;
         if(0 < this.m_tempResultData.length)
         {
            goodToOrder = this.m_tempResultData.shift();
            feedImage = result.imagePath;
            hasAutoPublish = TradingPostManager.getInstance().hasAutoPublishPermissions();
            buyer = Global.friendManager.getAppFriendData(goodToOrder.sellingUid);
            harvestedItem = Global.farmGameSettingsManager.getFarmItemByCode(goodToOrder.itemCode);
            buyerName = "";
            if(buyer != null)
            {
               buyerName = buyer.firstName;
            }
            bundleData = {
               "buyer":buyerName,
               "user":Global.player.firstName,
               "cropName":harvestedItem.friendlyTitle,
               "images":[{
                  "href":"{SN_APP_URL}?ref=trading_post_order",
                  "src":feedImage
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("tradingpost_PostOrder",bundleData,[goodToOrder.sellingUid],false,null,0,false,hasAutoPublish);
         }
      }
      
      public function claimSellerReward(order:TradingOrder) : Object
      {
         var claimRewardTransaction:TClaimSellerReward;
         var resultReward:Object = {};
         var claimSellerRewardCallback:Function = function(result:Object):void
         {
            var farmItem:FarmItem = null;
            if(result != null && Boolean(result.error))
            {
               displayError(result.error.errorData);
            }
            else
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(order.itemCode);
               FarmStatsManager.count(TradingPostConstants.STATS_TRADINGPOST_COUNTER,"trading_post_selling","Fulfilled",farmItem.name);
               StatsManager.social("accept_order",String(Global.player.uid),"crop_order","order",farmItem.name,"",1,Global.worldManager.currentWorldType);
            }
         };
         var myOffering:UserTradingOfferings = this.m_marketView.getMyUserOffering();
         if(myOffering != null)
         {
            myOffering.queueOrderToRemove(order);
         }
         resultReward = this.grantClaimOrderReward(order);
         this.displayRewardStatus(order.itemCode,resultReward.numCoins,resultReward.numXP,resultReward.numMastery);
         claimRewardTransaction = new TClaimSellerReward(order,claimSellerRewardCallback,this.displayError);
         TransactionManager.addTransaction(claimRewardTransaction);
         return resultReward;
      }
      
      public function displayRewardStatus(itemCode:String, numCoins:Number, numXP:Number, numMastery:Number) : void
      {
         var statusMessage:String = "";
         if(numCoins > 0)
         {
            statusMessage = ZLocUtils.t("FarmGame","Status_HarvestCoinsXPMastery",{
               "coinNum":numCoins,
               "xpNum":numXP,
               "masteryNum":numMastery
            });
         }
         else
         {
            statusMessage = ZLocUtils.t("FarmGame","Status_HarvestNegCoinsXPMastery",{
               "coinNum":numCoins,
               "xpNum":numXP,
               "masteryNum":numMastery
            });
         }
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var centerX:Number = Global.stage.stageWidth / 2;
         var centerY:Number = Global.stage.stageHeight / 2 - 150;
         UI.displayStatus(statusMessage,centerX,centerY,farmItem.icon);
      }
      
      public function grantClaimOrderReward(order:TradingOrder) : Object
      {
         var result:Object = {};
         var rewardXpMultiplier:Number = Number(this.getConfigAttr(TradingPostConstants.SETTINGS_TYPE_CROP,"sellerRewardXpMultiplier"));
         var rewardMasteryMultiplier:Number = Number(this.getConfigAttr(TradingPostConstants.SETTINGS_TYPE_CROP,"sellerRewardMasteryMultiplier"));
         var rewardCoinsMultiplier:Number = Number(this.getConfigAttr(TradingPostConstants.SETTINGS_TYPE_CROP,"sellerRewardCoinsMultiplier"));
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(order.itemCode);
         var numXP:Number = Number(farmItem.plantXp * rewardXpMultiplier);
         var numMastery:Number = Number(1 * rewardMasteryMultiplier);
         var numGold:Number = Number(farmItem.cost * rewardCoinsMultiplier);
         numXP = Global.player.calculateAndAddXp(numXP);
         var itemCode:String = order.itemCode;
         if(Global.player.masteryCounters[itemCode] == null)
         {
            Global.player.masteryCounters[itemCode] = 0;
         }
         Global.player.masteryCounters[itemCode] += numMastery;
         Global.player.gold += numGold;
         result.numMastery = numMastery;
         result.numXP = numXP;
         result.numCoins = numGold;
         return result;
      }
      
      public function canBuyFromUser(sellerUid:String) : Object
      {
         var availableInOrders:Boolean = false;
         var greatestOrderTime:Number = NaN;
         var order:TradingOrder = null;
         var settings:Array = null;
         var orderingSettings:Array = null;
         var hoursBetweenOrders:Number = NaN;
         var timeToWait:Number = NaN;
         var deltaTime:Number = NaN;
         var nowTime:Number = NaN;
         var result:Object = {};
         result.canBuy = false;
         result.locText = "";
         var marketOffering:UserTradingOfferings = this.m_marketView.getFriendOffering(sellerUid);
         if(marketOffering != null)
         {
            availableInOrders = false;
            greatestOrderTime = 0;
            for each(order in marketOffering.purchasesFromFriends)
            {
               if(order != null)
               {
                  if(order.orderTime > greatestOrderTime)
                  {
                     greatestOrderTime = order.orderTime;
                  }
               }
            }
            settings = this.getSettings();
            orderingSettings = settings[TradingPostConstants.SETTINGS_TYPE_CROP];
            if(orderingSettings != null)
            {
               hoursBetweenOrders = Number(orderingSettings["hoursBetweenPurchases"]) * FarmGameUtil.NUM_SECS_IN_HOUR;
               timeToWait = greatestOrderTime + hoursBetweenOrders;
               deltaTime = nowTime - greatestOrderTime;
               nowTime = GlobalEngine.serverTime / 1000;
               if(greatestOrderTime <= 0 || deltaTime > hoursBetweenOrders)
               {
                  result.canBuy = true;
               }
               else
               {
                  result.locText = FarmGameUtil.getTimeLeftText(timeToWait,"tradingpost_buy_again_");
               }
            }
         }
         return result;
      }
      
      public function canOrderFromUser(sellerUid:String) : Object
      {
         var availableInOrders:Boolean = false;
         var greatestOrderTime:Number = NaN;
         var order:TradingOrder = null;
         var settings:Array = null;
         var orderingSettings:Array = null;
         var secondsBetweenOrders:Number = NaN;
         var timeToWait:Number = NaN;
         var nowTime:Number = NaN;
         var deltaTime:Number = NaN;
         var result:Object = {};
         result.canBeOrdered = false;
         result.hoursLeft = 0;
         result.locText = "";
         var marketOffering:UserTradingOfferings = this.m_marketView.getFriendOffering(sellerUid);
         if(marketOffering != null)
         {
            availableInOrders = false;
            greatestOrderTime = 0;
            for each(order in marketOffering.ordersFromFriends)
            {
               if(order != null)
               {
                  if(order.orderTime > greatestOrderTime)
                  {
                     greatestOrderTime = order.orderTime;
                  }
               }
            }
            settings = this.getSettings();
            orderingSettings = settings[TradingPostConstants.SETTINGS_TYPE_CROP];
            if(orderingSettings != null)
            {
               secondsBetweenOrders = Number(orderingSettings["hoursBetweenOrders"]) * FarmGameUtil.NUM_SECS_IN_HOUR;
               timeToWait = greatestOrderTime + secondsBetweenOrders;
               nowTime = GlobalEngine.serverTime / 1000;
               deltaTime = nowTime - greatestOrderTime;
               if(greatestOrderTime <= 0 || deltaTime > secondsBetweenOrders)
               {
                  result.canBeOrdered = true;
               }
               else
               {
                  result.locText = FarmGameUtil.getTimeLeftText(timeToWait,"tradingpost_order_again_");
               }
            }
         }
         return result;
      }
      
      public function updateTradingGoodState(tradingGood:TradingGood) : void
      {
         var orderExistsAndUnfilled:Boolean = false;
         var orderExistsFilled:Boolean = false;
         var orderExistsClaimed:Boolean = false;
         var currentTime:Number = NaN;
         var lastRemindTime:Number = NaN;
         var canPostReminder:Boolean = false;
         var goodState:String = TradingGood.FOR_ORDER;
         var userOffering:UserTradingOfferings = this.m_marketView.getFriendOffering(tradingGood.sellingUid);
         if(userOffering != null)
         {
            orderExistsAndUnfilled = userOffering.orderExists(Global.player.uid,tradingGood.itemCode);
            orderExistsFilled = userOffering.orderExists(Global.player.uid,tradingGood.itemCode,true);
            orderExistsClaimed = userOffering.orderExists(Global.player.uid,tradingGood.itemCode,true,true);
            currentTime = GlobalEngine.serverTime / 1000;
            lastRemindTime = Global.player.getFeatureLastShown(TradingPostConstants.TRADE_REMIND_W2W_FLAG + userOffering.sellerId);
            canPostReminder = false;
            if(currentTime - lastRemindTime >= FarmGameUtil.NUM_SECS_IN_DAY / 2)
            {
               canPostReminder = true;
            }
            if(orderExistsAndUnfilled && canPostReminder)
            {
               goodState = TradingGood.ORDER_REMIND;
            }
            else if(orderExistsAndUnfilled)
            {
               goodState = TradingGood.ORDER_TAKEN;
            }
            else if(orderExistsFilled)
            {
               goodState = TradingGood.FOR_CLAIM;
            }
            else if(orderExistsClaimed)
            {
               goodState = TradingGood.FOR_ORDER;
            }
         }
         tradingGood.goodStatusType = goodState;
      }
      
      public function hasFeatureStreamPermissions() : Boolean
      {
         return Boolean(FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.TRADING_POST,FeatureOptionsManager.AUTO_PUBLISH_STREAM));
      }
      
      public function hasAutoPublishPermissions() : Boolean
      {
         return this.hasFeatureStreamPermissions() && Global.farmSocialNetwork.userHasStreamPermissions();
      }
      
      public function showFeatureAutoPublishDialog(autoPublishCallback:Function = null) : void
      {
         var imageSize:Number = 100;
         this.m_autoPublishCallback = autoPublishCallback;
         var dialog:GenericXMLDialog = new GenericXMLDialog("","",null,"",imageSize,imageSize,ZLocUtils.t("Dialogs","tradingPost_AutoPublishPrompt"),this.onGiveFeatureAutoPublishPermission,false,ZLocUtils.t("Dialogs","Accept"),null,ZLocUtils.t("Dialogs","Cancel"),null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_LARGE);
         UI.displayPopup(dialog,false,"autoPublish",true);
         Global.player.setSeenSessionFlag(TradingPostConstants.SEEN_TRADING_POST_EXT_PERMISSIONS);
      }
      
      protected function displayError(error:String) : void
      {
         if(error == null)
         {
            error = "";
         }
         var errorString:String = ZLocUtils.t("Dialogs","tradingPost_error_" + error);
         if(!errorString)
         {
            errorString = error;
         }
         UI.displayMessage(errorString,0,null,"",true);
      }
      
      protected function onGiveFeatureAutoPublishPermission(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.TRADING_POST,FeatureOptionsManager.AUTO_PUBLISH_STREAM,true);
            FeatureOptionsManager.getInstance().save();
            FarmStatsManager.count(TradingPostConstants.STATS_TRADINGPOST_COUNTER,"trading_post_selling","trading_post_permissions_grant");
            Global.farmSocialNetwork.showStreamPermissions(this.onStreamPermissionsComplete);
         }
         else
         {
            FarmStatsManager.count(TradingPostConstants.STATS_TRADINGPOST_COUNTER,"trading_post_selling","trading_post_permissions_decline");
            this.onStreamPermissionsComplete();
         }
      }
      
      protected function onStreamPermissionsComplete() : void
      {
         if(null != this.m_autoPublishCallback)
         {
            this.m_autoPublishCallback();
            this.m_autoPublishCallback = null;
         }
      }
   }
}

