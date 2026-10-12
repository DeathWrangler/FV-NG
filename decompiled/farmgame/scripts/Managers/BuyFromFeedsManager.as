package Managers
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.DynamicIconQueue;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.ExpiredRewardWindow;
   import Widgets.Windows.GenericSingleRewardPopup;
   import com.adobe.serialization.json.JSON;
   
   public class BuyFromFeedsManager
   {
      
      public static const BUY_FROM_FEEDS_FEATURE_NAME:String = "buy_from_feeds";
      
      public static const RUNTIME_KEY:String = "BUY_FROM_FEEDS_OFFER";
      
      public static const MOTD_NAME:String = "MOTD_BUY_FROM_FEEDS";
      
      public static const REWARD_DIALOG_ASSET_PATH:String = "assets/dialogs/FV_BuyFromFeeds_reward.swf";
      
      public static const LAST_CHANCE_DIALOG_ASSET_PATH:String = "assets/dialogs/FV_BuyFromFeeds_questPurchase.swf";
      
      public static const FEATURE_OPTIONS_KEY_HAS_RECEIVED_REWARD:String = "hasReceivedReward";
      
      public static const FEATURE_OPTIONS_KEY_OFFER_REWARD_ITEM_CODE:String = "offerRewardItemCode";
      
      public static const STATS_COUNTER:String = "buyfromfeeds";
      
      public static const LAST_POSTED_TIME_NEVER:int = -1;
      
      public function BuyFromFeedsManager()
      {
         super();
      }
      
      public static function getCurrentOffer() : Object
      {
         return com.adobe.serialization.json.JSON.decode(Global.flashHotParams[RUNTIME_KEY]);
      }
      
      public static function getCurrentOfferID() : String
      {
         var result:String = null;
         var currentOffer:Object = getCurrentOffer();
         if(Boolean(currentOffer) && currentOffer.hasOwnProperty("offerID"))
         {
            result = currentOffer.offerID;
         }
         return result;
      }
      
      public static function getCurrentOfferFriendRewardItemCode() : String
      {
         var result:String = null;
         var currentOffer:Object = getCurrentOffer();
         if(Boolean(currentOffer) && currentOffer.hasOwnProperty("friendRewardItemCode"))
         {
            result = currentOffer.friendRewardItemCode;
         }
         return result;
      }
      
      public static function getCurrentOfferLengthSeconds() : int
      {
         var result:int = int(FarmGameUtil.NUM_SECS_IN_DAY);
         var currentOffer:Object = getCurrentOffer();
         if(Boolean(currentOffer) && currentOffer.hasOwnProperty("offerLengthSeconds"))
         {
            result = int(currentOffer.offerLengthSeconds);
         }
         return result;
      }
      
      public static function getCurrentOfferNumSharesRequired() : int
      {
         var result:int = int.MAX_VALUE;
         var currentOffer:Object = getCurrentOffer();
         if(Boolean(currentOffer) && currentOffer.hasOwnProperty("numSharesRequired"))
         {
            result = int(currentOffer.numSharesRequired);
         }
         return result;
      }
      
      public static function getCurrentOfferPostingThrottleSeconds() : int
      {
         var result:int = 7200;
         var currentOffer:Object = getCurrentOffer();
         if(Boolean(currentOffer) && currentOffer.hasOwnProperty("postingThrottleSeconds"))
         {
            result = int(currentOffer.postingThrottleSeconds);
         }
         return result;
      }
      
      public static function isWithinCurrentOfferDate() : Boolean
      {
         var prereqs:Array = null;
         var prereq:Object = null;
         var result:Boolean = true;
         var currentOffer:Object = getCurrentOffer();
         if(currentOffer != null && currentOffer.hasOwnProperty("prereq"))
         {
            prereqs = currentOffer.prereq;
            if(prereqs != null)
            {
               for each(prereq in prereqs)
               {
                  if(prereq.type == "start_time" || prereq.type == "end_time")
                  {
                     result = PrerequisiteUtility.isPrerequisiteMet(prereq);
                     if(!result)
                     {
                        result = false;
                        break;
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public static function getCurrentOfferFeatureOption() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(BUY_FROM_FEEDS_FEATURE_NAME,getCurrentOfferID());
      }
      
      public static function getCurrentOfferFeatureOptionLastPostedTime() : Number
      {
         var result:Number = LAST_POSTED_TIME_NEVER;
         var currentOfferFeatureOption:Object = getCurrentOfferFeatureOption();
         if(currentOfferFeatureOption != null && currentOfferFeatureOption.hasOwnProperty("lastPostedTime"))
         {
            result = Number(currentOfferFeatureOption.lastPostedTime);
         }
         return result;
      }
      
      public static function setLastPostedTime(lastPostedTimeMSecs:Number) : void
      {
         var bffFeatureOption:Object = getCurrentOfferFeatureOption();
         bffFeatureOption.lastPostedTime = Math.round(lastPostedTimeMSecs / Number(FarmGameUtil.NUM_MSECS_IN_SECOND));
         var currentOfferID:String = BuyFromFeedsManager.getCurrentOfferID();
         FeatureOptionsManager.getInstance().setFeatureOption(BUY_FROM_FEEDS_FEATURE_NAME,currentOfferID,bffFeatureOption);
         TransactionManager.addTransaction(new TGenericTransaction("BuyFromFeedsService","setLastPostedTime"));
      }
      
      public static function getCurrentOfferFeatureOptionNumFriendsClicked() : int
      {
         var friendsClickedArray:Array = null;
         var result:int = 0;
         var currentOfferFeatureOption:Object = getCurrentOfferFeatureOption();
         if(currentOfferFeatureOption != null && currentOfferFeatureOption.hasOwnProperty("friendsClicked"))
         {
            friendsClickedArray = currentOfferFeatureOption.friendsClicked;
            if(friendsClickedArray != null)
            {
               result = int(friendsClickedArray.length);
            }
         }
         return result;
      }
      
      private static function getBFFFeatureOptions() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(BUY_FROM_FEEDS_FEATURE_NAME);
      }
      
      public static function conditionallyShowRewardDialogs() : void
      {
         var bffFeatureOptionId:String = null;
         var bffFeatureOption:Object = null;
         var rewardItemCode:String = null;
         var rewardItem:FarmItem = null;
         var bffFeatureOptions:Object = getBFFFeatureOptions();
         for(bffFeatureOptionId in bffFeatureOptions)
         {
            bffFeatureOption = bffFeatureOptions[bffFeatureOptionId];
            if(bffFeatureOption != null)
            {
               if(bffFeatureOption[FEATURE_OPTIONS_KEY_HAS_RECEIVED_REWARD] == true && bffFeatureOption[FEATURE_OPTIONS_KEY_OFFER_REWARD_ITEM_CODE] != null && !Global.player.getSeenFlag(bffFeatureOptionId))
               {
                  rewardItemCode = bffFeatureOption[FEATURE_OPTIONS_KEY_OFFER_REWARD_ITEM_CODE];
                  if(rewardItemCode != null)
                  {
                     rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardItemCode);
                     if(rewardItem != null)
                     {
                        UI.displayPopup(new GenericSingleRewardPopup(REWARD_DIALOG_ASSET_PATH,BUY_FROM_FEEDS_FEATURE_NAME,rewardItem));
                        StatsManager.count(STATS_COUNTER,StatsTrackingConstants.SUCCESSDIALOG,StatsTrackingConstants.IMPRESSIONS);
                        Global.player.setSeenFlag(bffFeatureOptionId);
                     }
                  }
               }
            }
         }
      }
      
      public static function conditionallyShowRedemptionDialog(missedItemCodes:Array) : void
      {
         var missedItems:Array = null;
         var missedItemCode:String = null;
         var missedItem:FarmItem = null;
         if(missedItemCodes != null && missedItemCodes.length > 0)
         {
            missedItems = [];
            for each(missedItemCode in missedItemCodes)
            {
               missedItem = Global.farmGameSettingsManager.getFarmItemByCode(missedItemCode);
               if(missedItem != null)
               {
                  missedItems.push(missedItem);
               }
            }
            if(missedItems.length > 0)
            {
               UI.displayPopup(new ExpiredRewardWindow(LAST_CHANCE_DIALOG_ASSET_PATH,BUY_FROM_FEEDS_FEATURE_NAME,missedItems,BUY_FROM_FEEDS_FEATURE_NAME,BUY_FROM_FEEDS_FEATURE_NAME,{
                  "serviceName":"BuyFromFeedsService",
                  "serviceFunctionName":"lastChancePurchase",
                  "callbackFunction":updateClientOnLastChancePurchase
               }));
               StatsManager.count(STATS_COUNTER,StatsTrackingConstants.FAILUREDIALOG,StatsTrackingConstants.IMPRESSIONS);
            }
         }
      }
      
      public static function updateClientOnLastChancePurchase(result:Object) : void
      {
         var purchasedItem:FarmItem = null;
         if(result != null && result.hasOwnProperty("itemName"))
         {
            purchasedItem = Global.farmGameSettingsManager.getFarmItemByName(result.itemName);
            if(purchasedItem != null)
            {
               Global.player.cash -= purchasedItem.cash;
               Global.player.addGift(purchasedItem.name,"0",1);
            }
         }
      }
      
      public static function setCurrentOfferFeatureOption(currentOfferFeatureOption:Object) : void
      {
         var currentOfferID:String = BuyFromFeedsManager.getCurrentOfferID();
         FeatureOptionsManager.getInstance().setFeatureOption(BUY_FROM_FEEDS_FEATURE_NAME,currentOfferID,currentOfferFeatureOption);
         FeatureOptionsManager.getInstance().saveSingleFeature(BUY_FROM_FEEDS_FEATURE_NAME,currentOfferID);
      }
      
      public static function setCurrentOfferExpired() : void
      {
         var bffFeatureOption:Object = getCurrentOfferFeatureOption();
         if(bffFeatureOption != null)
         {
            bffFeatureOption.expired = true;
            setCurrentOfferFeatureOption(bffFeatureOption);
         }
      }
      
      public static function hasCurrentOfferExpired() : Boolean
      {
         var result:Boolean = false;
         var bffFeatureOption:Object = getCurrentOfferFeatureOption();
         if(bffFeatureOption != null && bffFeatureOption.hasOwnProperty("expired") && bffFeatureOption.expired == true)
         {
            result = true;
         }
         if(!isWithinCurrentOfferDate())
         {
            result = true;
         }
         return result;
      }
      
      public static function addHucIcon() : void
      {
         Global.hud.rightSideIconQueue.addIcon("buyFromFeeds",DynamicIconQueue.ADD_BY_PRIORITY,null,null,false);
      }
   }
}

