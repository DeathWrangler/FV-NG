package Classes
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ExternalUtil;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import flash.events.EventDispatcher;
   
   public class WatchToEarnManager extends EventDispatcher
   {
      
      private static var s_instance:WatchToEarnManager;
      
      public static const STAT_COUNTER:String = "w2e";
      
      public static const DEFAULT_W2E_DIV_ID:String = "zap-w2e-overlay";
      
      public static const ASSET_NAME_HUD_ICON:String = "hudIcon";
      
      private static var initW2eCall:int = 0;
      
      private static const REWARD_SERVICE_NAME:String = "WatchToEarnRewardGrantService";
      
      public static const ZRUNTIME_WATCH_TO_EARN_FC_VALUE:String = "WATCH_TO_EARN_FC_VALUE";
      
      public static const W2E_DAILY_TOKEN_LAST_SHOWN_KEY:* = "w2e_daily_token_last_shown";
      
      public static const COOL_DOWN_TIME:int = 86400;
      
      private static var m_InitIronSource:Boolean = false;
      
      private var m_configXML:XMLList;
      
      private var m_initializedSlotIds:Object = {};
      
      private var m_slotPrereqs:Object = {};
      
      private var m_w2ePrereqs:Array;
      
      private var m_isInitialized:Boolean;
      
      private var m_slotIds:Array;
      
      private var m_dailyToken:Array = [];
      
      public function WatchToEarnManager()
      {
         super();
      }
      
      public static function getInstance() : WatchToEarnManager
      {
         if(!s_instance)
         {
            s_instance = new WatchToEarnManager();
         }
         return s_instance;
      }
      
      public static function getEventName(serviceEventName:String, slotId:String) : String
      {
         return serviceEventName + "_" + slotId;
      }
      
      public function doPostInit() : void
      {
         var gameSettingsXML:XML = Global.farmGameSettingsManager.getXML();
         if(gameSettingsXML)
         {
            this.initializeWatchToEarn(gameSettingsXML.watchToEarn);
         }
      }
      
      public function initializeWatchToEarn(configXML:XMLList) : void
      {
         var w2eDivId:String = null;
         var slotId:String = null;
         var slotXML:XML = null;
         var slotPrereqs:Array = null;
         this.m_configXML = configXML;
         this.m_w2ePrereqs = PrerequisiteUtility.parseXmlNodePrereqs(this.m_configXML.prereqs.prereq);
         if(this.isEnabled)
         {
            w2eDivId = Boolean(configXML.htmlContainer) && Boolean(configXML.htmlContainer.id) ? configXML.htmlContainer.@id : DEFAULT_W2E_DIV_ID;
            this.m_slotIds = [];
            for each(slotXML in this.m_configXML.slots.slot)
            {
               slotId = String(slotXML.@id);
               slotPrereqs = PrerequisiteUtility.parseXmlNodePrereqs(slotXML.prereqs.prereq);
               this.m_slotPrereqs[slotId] = slotPrereqs;
               if(PrerequisiteUtility.arePrerequisitesMet(slotPrereqs))
               {
                  this.m_slotIds.push(slotId);
               }
            }
         }
      }
      
      public function get isInitialized() : Boolean
      {
         return this.m_isInitialized;
      }
      
      public function get isEnabled() : Boolean
      {
         return Boolean(this.m_w2ePrereqs) && PrerequisiteUtility.arePrerequisitesMet(this.m_w2ePrereqs);
      }
      
      public function areSlotPrerequisitesMet(slotId:String) : Boolean
      {
         var result:Boolean = false;
         var slotPrereqs:Array = this.m_slotPrereqs[slotId];
         if(slotPrereqs)
         {
            result = PrerequisiteUtility.arePrerequisitesMet(slotPrereqs);
         }
         return result;
      }
      
      public function startActivity(slotId:String) : void
      {
         if(!m_InitIronSource)
         {
            m_InitIronSource = true;
            ExternalUtil.instance.addCallback("oninitW2e",ZCacheUtil.applyPartial(this.oninitW2e,this));
            ExternalUtil.instance.call("FarmNS.initW2e");
         }
         ExternalUtil.instance.addCallback("onshowW2eAd",ZCacheUtil.applyPartial(this.onshowW2eAd,this));
         ExternalUtil.instance.call("FarmNS.showW2eIron");
      }
      
      private function oninitW2e(result:String) : *
      {
         var shouldShowHud:Boolean = false;
         switch(result)
         {
            case "READY":
               shouldShowHud = true;
               FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,"fillrate","success","beforeload");
               break;
            case "OPEN":
               shouldShowHud = false;
               break;
            case "ERROR":
               FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,"fillrate","error","beforeload");
               break;
            case "NO_CAMPAIGNS":
               FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,"fillrate","error","beforeload");
         }
         var show:Boolean = shouldShowHud && this.m_dailyToken.length > 0 && Boolean(Global.flashHotParams["W2E_HUD"]);
         if(Global.hud)
         {
            Global.hud.setVisibilityW2EHud(show);
         }
      }
      
      private function onshowW2eAd(result:String) : *
      {
         var len:int = 0;
         var rIndex:int = 0;
         var tokenStr:String = null;
         if(result == "COMPLETE")
         {
            if(this.m_dailyToken.length > 0)
            {
               len = int(this.m_dailyToken.length);
               rIndex = Math.floor(Math.random() * len);
               tokenStr = this.m_dailyToken[rIndex];
               this.m_dailyToken.splice(rIndex,1);
               TransactionManager.addTransaction(new TGenericTransaction(REWARD_SERVICE_NAME,"grantReward",this.onGrantReward,[tokenStr]),true);
               FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,"ad","play","click");
            }
         }
         else
         {
            Global.hud.setVisibilityW2EHud(false);
         }
      }
      
      public function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_WATCH_TO_EARN_FC_VALUE))
            {
               Global.player.cash += Global.flashHotParams[ZRUNTIME_WATCH_TO_EARN_FC_VALUE];
            }
         }
      }
      
      private function canGenerateDailyToken() : Boolean
      {
         var key:String = W2E_DAILY_TOKEN_LAST_SHOWN_KEY;
         var timeSinceLastGeneration:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         var timeRemaining:int = COOL_DOWN_TIME - timeSinceLastGeneration;
         return timeRemaining < 0;
      }
      
      public function generateDailyTokens() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(REWARD_SERVICE_NAME,"generateDailyTokens",this.onGenerateDailyToken),true);
      }
      
      public function onGenerateDailyToken(result:Object) : void
      {
         var i:int = 0;
         var index:String = null;
         if(result.success)
         {
            if(result["Tokens"].length > 0)
            {
               for(i = 0; i < result["Tokens"].length; i++)
               {
                  this.m_dailyToken[i] = result["Tokens"][i];
               }
               Global.player.setFeatureLastShown(W2E_DAILY_TOKEN_LAST_SHOWN_KEY,FarmGameUtil.getMidnightTimestamp() / 1000,false);
            }
            else
            {
               i = 0;
               for(index in result["Tokens"])
               {
                  this.m_dailyToken[i] = result["Tokens"][index];
                  i++;
               }
               if(this.m_dailyToken.length <= 0)
               {
                  this.oninitW2e("");
               }
            }
         }
      }
   }
}

