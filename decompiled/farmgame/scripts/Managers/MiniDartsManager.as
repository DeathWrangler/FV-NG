package Managers
{
   import Classes.util.FarmGameUtil;
   import Display.MysteryBoxBalloonDialog;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Transactions.TGenericTransactionWithFeed;
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   
   public class MiniDartsManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "minidarts_revamp";
      
      public static const CURRENCY_COUNT:String = "token_count";
      
      public static const SERVICE_CLASS:String = "MiniDartsService";
      
      public static const ON_ASK_FOR_CURRENCY:String = "onAskForCurrency";
      
      public static const MINI_DART_REFRESH_EVENT:String = "miniDartRefreshEvent";
      
      public static const TOTAL_TOKEN_COUNT:int = 5;
      
      public static const ON_BUY_DART:String = "onBuyDart";
      
      public static var VERSION_STRING:String = "version";
      
      public var CURRENCY_ITEM_NAME:String;
      
      public var ASK_FEED_FREQUENCY:int;
      
      public var ASK_FEED_FREQUENCY_KEY:String;
      
      public var REWARD_ITEM_NAME:String = "consume_mystery_game_revamp_dart";
      
      private var m_cost:int = 15;
      
      public var FEATURE_END_DATE:String;
      
      public var VERSION:int;
      
      private var m_miniDartsRuntime:Object = com.adobe.serialization.json.JSON.decode(Global.flashHotParams["MINIDARTS"]) as Object;
      
      public function MiniDartsManager(featureName:String = "minidarts_revamp")
      {
         super(featureName);
         this.populateFeatureConfig();
      }
      
      public static function getInstance(featureName:String = "minidarts_revamp") : MiniDartsManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,MiniDartsManager) as MiniDartsManager;
      }
      
      public function populateFeatureConfig() : void
      {
         if(this.isFeatureActive())
         {
            this.CURRENCY_ITEM_NAME = this.m_miniDartsRuntime.CURRENCY_ITEM;
            this.ASK_FEED_FREQUENCY = this.m_miniDartsRuntime.THROTTLE;
            this.ASK_FEED_FREQUENCY_KEY = m_featureName + "AskCurrency";
            this.REWARD_ITEM_NAME = this.m_miniDartsRuntime.CONSUMABLE;
            this.FEATURE_END_DATE = this.m_miniDartsRuntime.END_DATE;
            this.VERSION = this.m_miniDartsRuntime.VERSION;
            this.resetDartCount();
         }
      }
      
      public function askForCurrencyItem() : void
      {
         TransactionManager.addTransaction(new TGenericTransactionWithFeed(SERVICE_CLASS,ON_ASK_FOR_CURRENCY,this.onAskForCurrencyCallback,[FEATURE_NAME]));
      }
      
      public function resetDartCount() : void
      {
         var dartCount:int = 0;
         var version:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,VERSION_STRING);
         if(Boolean(version) && Boolean(this.VERSION > int(version)) || version == null)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,VERSION_STRING,this.VERSION);
            dartCount = FeatureOptionsInventoryManager.getInstance().getCountByName(this.REWARD_ITEM_NAME);
            if(dartCount > 0)
            {
               FeatureOptionsInventoryManager.getInstance().removeCountByName(this.REWARD_ITEM_NAME,dartCount);
            }
         }
      }
      
      public function onBuyDartItem(itemName:String, cash:int) : Boolean
      {
         var result:Boolean = false;
         if(Global.player.canBuyCash(cash,true))
         {
            Global.player.cash -= cash;
            Global.player.addGift(itemName,"0",1);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ON_BUY_DART,null,[FEATURE_NAME]));
            result = true;
         }
         return result;
      }
      
      public function getCurrencyCount() : int
      {
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,CURRENCY_COUNT);
         return int(data);
      }
      
      public function setCurrencyCount(data:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,CURRENCY_COUNT,data);
      }
      
      public function changeCurrencyCount(count:int = 1) : void
      {
         var tokenCount:int = this.getCurrencyCount();
         tokenCount += count;
         this.giftDartItem(tokenCount);
         tokenCount %= MiniDartsManager.TOTAL_TOKEN_COUNT;
         this.setCurrencyCount(tokenCount);
         Global.stage.dispatchEvent(new Event(MiniDartsManager.MINI_DART_REFRESH_EVENT));
      }
      
      private function giftDartItem(tokensCount:int) : void
      {
         var dartQuantity:int = Math.floor(tokensCount / MiniDartsManager.TOTAL_TOKEN_COUNT);
         if(dartQuantity > 0)
         {
            Global.player.addGift(this.REWARD_ITEM_NAME,"0",dartQuantity);
         }
      }
      
      public function handleHUDClick() : void
      {
         FarmStatsManager.count("HUD","click","DARTGAMEv2","","",Global.worldManager.currentWorldType);
         this.openMiniDartUI();
      }
      
      public function openMiniDartUI() : void
      {
         MysteryBoxBalloonDialog.openDefaultMysteryGame();
      }
      
      public function isFeatureActive() : Boolean
      {
         return this.getSecondsUntilExpiry() >= 0;
      }
      
      public function getSecondsUntilExpiry() : int
      {
         var currentTimeSeconds:int = Math.floor(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
         var endDateString:String = this.m_miniDartsRuntime.END_DATE;
         var expiryTimeSecond:int = 0;
         if(endDateString != "")
         {
            expiryTimeSecond = Math.floor(FarmGameUtil.synchronizedDateTimeToNumber(endDateString) / FarmGameUtil.NUM_MSECS_IN_SECOND);
         }
         return expiryTimeSecond - currentTimeSeconds;
      }
      
      public function get dartItemCost() : int
      {
         return this.m_miniDartsRuntime.CONSUMABLE_COST;
      }
      
      private function onAskForCurrencyCallback(result:Object) : void
      {
         if(result)
         {
            Global.player.setFeatureLastShown(this.ASK_FEED_FREQUENCY_KEY,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         }
      }
      
      public function getMotdItemByKey(key:String) : String
      {
         var rewardName:String = "";
         if(this.m_miniDartsRuntime[key])
         {
            rewardName = this.m_miniDartsRuntime[key];
         }
         return rewardName;
      }
   }
}

