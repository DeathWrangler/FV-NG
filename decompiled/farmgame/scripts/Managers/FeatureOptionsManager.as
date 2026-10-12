package Managers
{
   import Classes.Constants.FarmClubConstants;
   import Classes.util.ObjectUtil;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Managers.Clubs.FarmClubDataManager;
   import Transactions.TSaveFeatureOptions;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class FeatureOptionsManager extends EventDispatcher
   {
      
      private static var m_objInstance:FeatureOptionsManager;
      
      public static const EVENT_FEATURE_OPTIONS_UPDATED:String = "eventFeatureOptionsUpdated";
      
      public static const EVENT_FEATURE_OPTIONS_LOADED:String = "eventFeatureOptionsLoaded";
      
      public static const NEW_YEARS_PARTY_2011:String = "newyearseve_partybarn";
      
      public static const EXPANSION_INVITE:String = "expansion_invite";
      
      public static const TRADING_POST:String = "trading_post";
      
      public static const QUEST_MAP_SUFFIX:String = "_questmap";
      
      public static const LE_SLOT_MACHINE:String = "leslotmachine";
      
      public static const FEATURE_MARKET_STALL:String = "craftingmarketstall";
      
      public static const SUBSCRIPTIONS:String = "subscriptions";
      
      public static const SPENDOMETER:String = SpendometerManager.FEATURE_OPTIONS_KEY;
      
      public static const SUBSCRIPTIONS_V2:String = "subscriptions_v2";
      
      public static const FEATURE_AMEX_TREE:String = "amex_tree";
      
      public static const LAB_BUILDING:String = "lab_building";
      
      public static const FEATURE_LIMITED_ITEMS:String = "limited_items";
      
      public static const SLOT_MACHINE:String = "slotMachine";
      
      public static const CONTENT_ACCESS:String = "content_access";
      
      public static const REWARD_CARDS:String = "rewardCards";
      
      public static const PRIZE_MACHINE:String = "prize_machine";
      
      public static const CIP_START_NOW:String = "cip_start_now";
      
      public static const TASK_LIST:String = "taskList";
      
      public static const FISHING_DERBY:String = "fishing_derby";
      
      public static const FEATURE_BOOT:String = "bootunlocked";
      
      public static const PURCHASE_CONTEST:String = "purchase_contest";
      
      public static const ANIMAL_BREEDING:String = "animal_breeding";
      
      public static const PHOTO_CONTEST:String = "photocontest";
      
      public static const EXPANSION_PROMPT_IDLE:String = "expansion_prompt_idle";
      
      public static const MYSTERY_CRATE:String = "mystery_crate";
      
      public static const BINGO:String = "bingo";
      
      public static const FARM_VILLAGE:String = "farmVillage";
      
      public static const TURBO_RINGS:String = "turbo_rings";
      
      public static const TIMED_GIVEAWAY:String = "timedSlotGiveaways";
      
      public static const RTUE:String = "returningUserExperience";
      
      public static const EXCHANGE_MANAGER:String = "exchangeManager";
      
      public static const LIMITED_QUANTITY_BUNDLES:String = "limitedQuantityBundles_v2_6";
      
      public static const CHRISTMAS_CHARITY_BUNDLES:String = "christmasCharityBundles";
      
      public static const ITEMS_RECENT:String = "itemsRecent";
      
      public static const GIFT_ITEMS_RECENT:String = "giftItemsRecent";
      
      public static const AUTO_PUBLISH_STREAM:String = "autopublish_stream";
      
      public static const STORAGE_INCREASE_2012:String = "storage_increase_2012";
      
      public static const VOTING_STATE:String = "votingState";
      
      public static const POST_VOTING_STATE:String = "PostVotingState";
      
      public static const SLOT_MACHINE_FREESPINS:String = "slotMachine_freespins";
      
      public static const CONTENT_ACCESS_HAS_ACCESS:String = "access";
      
      public static const CONTENT_ACCESS_HAS_SEEN_ONBOARDING:String = "seen_onboarding";
      
      public static const CIP_START_NOW_SESSIONS:String = "cip_start_now_sessions";
      
      public static const TASKLIST_CURRENT_TASKS:String = "taskListCurrent";
      
      public static const TASKLIST_AVAILABLE_TASKS:String = "taskListAvailable";
      
      public static const EXPANSION_PROMPT_IDLE_NEXT_TIME:String = "expansion_prompt_idle_next_time";
      
      public static const MYSTERY_CRATE_PLACED_TIME:String = "placedTime";
      
      public static const MYSTERY_CRATE_LEVEL:String = "myterycratelevel";
      
      public static const BINGO_NUMS_ARRAY:String = "bingoNumsArray";
      
      public static const BINGO_PRIZES_ARRAY:String = "bingoPrizesArray";
      
      public static const BINGO_CADENCE_NAME:String = "bingoCadence";
      
      public static const FARM_VILLAGE_FACTORY:String = "farmVillageFactory";
      
      public static const TURBO_RINGS_ACTIVE_WORLDS:String = "turbo_rings_active_worlds";
      
      public static const WORLD_SEASONS:String = "world_seasons";
      
      public static const LONG_WEEKEND_DELIGHT:String = "LongWeekendDeligt";
      
      public static const DIFFICULTY_LEVEL:String = "difficulty_level";
      
      public static const DIFFICULTY_LAST_LEVEL:String = "last_level";
      
      public static const LEVEL_COMPLETE:String = "level_complete";
      
      public static const DIFFICULTY_LEVEL_SWITCH:String = "switch_c";
      
      public static const SEASONS_ACCESS_TYPE:String = "world_atype";
      
      private static var m_featureOptions:Object = {};
      
      private static var m_initialized:Boolean = false;
      
      private static var m_loaded:Boolean = false;
      
      public function FeatureOptionsManager(objEnforcer:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : FeatureOptionsManager
      {
         if(m_objInstance == null)
         {
            m_objInstance = new FeatureOptionsManager(new SingletonEnforcer());
            FeatureOptionsManager.initialize();
         }
         return m_objInstance;
      }
      
      public static function initialize() : void
      {
         if(!m_initialized)
         {
            m_initialized = true;
            TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,onTransactionComplete);
         }
      }
      
      private static function onTransactionComplete(event:TransactionEvent) : void
      {
         var featuresData:Object = null;
         var featureName:String = null;
         var optionName:String = null;
         var value:Object = null;
         if(Boolean(event && event.transaction && event.transaction.rawResult) && Boolean(event.transaction.rawResult.hasOwnProperty("metadata")) && Boolean(event.transaction.rawResult.metadata) && Boolean(event.transaction.rawResult.metadata.hasOwnProperty("FeatureOptions")) && Boolean(event.transaction.rawResult.metadata.FeatureOptions))
         {
            featuresData = event.transaction.rawResult.metadata.FeatureOptions;
            if(featuresData != null)
            {
               for(featureName in featuresData)
               {
                  for(optionName in featuresData[featureName])
                  {
                     value = featuresData[featureName][optionName];
                     FeatureOptionsManager.getInstance().updateFeatureOptionsFromBackend(featureName,optionName,value);
                  }
               }
               FeatureOptionsManager.getInstance().dispatchEvent(new Event(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_UPDATED));
            }
         }
      }
      
      public static function resetFeatureOption(featureName:String, featureOption:String = null) : void
      {
         if(featureName)
         {
            if(featureOption)
            {
               delete m_featureOptions[featureName][featureOption];
            }
            else
            {
               delete m_featureOptions[featureName];
            }
         }
      }
      
      public static function deleteFeatureOption(featureName:String, featureOption:String = null) : void
      {
         if(featureName)
         {
            if(featureOption)
            {
               delete m_featureOptions[featureName][featureOption];
            }
         }
      }
      
      public function loadObject(featureOptions:Object) : void
      {
         m_featureOptions = featureOptions;
         m_loaded = true;
         FeatureOptionsManager.getInstance().dispatchEvent(new Event(FeatureOptionsManager.EVENT_FEATURE_OPTIONS_LOADED));
      }
      
      public function get loaded() : Boolean
      {
         return m_loaded;
      }
      
      public function getFeatureOption(featureName:String, optionName:String = null) : Object
      {
         var result:Object = null;
         if(m_featureOptions.hasOwnProperty(featureName))
         {
            if(optionName)
            {
               if(m_featureOptions[featureName].hasOwnProperty(optionName))
               {
                  result = m_featureOptions[featureName][optionName];
               }
            }
            else
            {
               result = m_featureOptions[featureName];
            }
         }
         return result;
      }
      
      public function getFeatureData(featureName:String) : Object
      {
         var result:Object = null;
         if(m_featureOptions.hasOwnProperty(featureName))
         {
            result = m_featureOptions[featureName];
         }
         return result;
      }
      
      public function getFeatureOptionPath(featureName:String, optionName:String, ... path) : *
      {
         return ObjectUtil.extractPath(this.getFeatureOption(featureName,optionName),path);
      }
      
      public function setFeatureOption(featureName:String, optionName:String, optionValue:Object) : void
      {
         if(!m_featureOptions.hasOwnProperty(featureName))
         {
            m_featureOptions[featureName] = new Object();
         }
         if(optionName)
         {
            m_featureOptions[featureName][optionName] = optionValue;
         }
      }
      
      public function setFeature(featureName:String, featureValue:Object) : void
      {
         if(featureValue)
         {
            m_featureOptions[featureName] = featureValue;
         }
      }
      
      public function save() : void
      {
         TransactionManager.addTransaction(new TSaveFeatureOptions(m_featureOptions));
      }
      
      public function saveSingleFeature(featureName:String, optionName:String = null) : void
      {
         var singleFeatureOption:Object = null;
         if(m_featureOptions.hasOwnProperty(featureName))
         {
            singleFeatureOption = {};
            if(!optionName)
            {
               singleFeatureOption[featureName] = m_featureOptions[featureName];
            }
            else
            {
               if(!m_featureOptions[featureName].hasOwnProperty(optionName))
               {
                  return;
               }
               singleFeatureOption[featureName] = new Object();
               singleFeatureOption[featureName][optionName] = m_featureOptions[featureName][optionName];
            }
            TransactionManager.addTransaction(new TSaveFeatureOptions(singleFeatureOption));
         }
      }
      
      public function updateFeatureOptionsFromBackend(featureName:String, optionName:String, optionValue:Object) : void
      {
         this.setFeatureOption(featureName,optionName,optionValue);
         switch(featureName)
         {
            case GrowableContestManager.GROWABLE_CONTEST_STATE:
               GrowableContestManager.instance.onStateUpdate();
               break;
            case REWARD_CARDS:
               RewardCardsManager.getInstance().rewardCardsUpdated(optionName,optionValue);
               break;
            case PURCHASE_CONTEST:
               if(PurchaseContestHelper.inExperiment())
               {
                  PurchaseContestHelper.checkForWin(optionValue);
               }
               break;
            case FarmClubConstants.FARM_CLUB:
               FarmClubDataManager.getInstance().featureOptionsUpdated(optionName,optionValue);
               break;
            case TURBO_RINGS:
               if(optionName == TURBO_RINGS_ACTIVE_WORLDS)
               {
                  TurboPPHManager.getInstance().turboCountChanged();
               }
         }
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
