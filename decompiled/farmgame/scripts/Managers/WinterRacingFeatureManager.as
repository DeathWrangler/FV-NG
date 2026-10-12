package Managers
{
   import Classes.Constants.WorldsConstants;
   import Classes.MapTrigger;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.HUD.HUDWidgets.HudBottomWinterRacingFeature;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.GenericSingleRewardPopup;
   import Widgets.Windows.WinterRacingFeatureMainWindow;
   import Widgets.Windows.WinterRacingFeatureMilestoneRewardWindow;
   import Widgets.Windows.WinterRacingFeatureTilesWindow;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class WinterRacingFeatureManager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "GiftRush2019";
      
      private static const FEATURE_TRACKING:String = "giftrush";
      
      private static const SERVICE_NAME:String = "WinterRacingFeatureService";
      
      private static const KEY_GIFT_COUNT:String = "gift_grant_count";
      
      private static const KEY_GIFT_TIMER:String = "gift_timer";
      
      private static const KEY_UNBLOCK_TIMER:String = "auto_unblock_timer";
      
      private static const KEY_USER_MILESTONE_LEVEL:String = "user_milestone_level";
      
      private static const KEY_LOCK_STATES:String = "user_level_lock_states";
      
      public static const REWARD_WINDOW_IMAGE:* = "assets/dialogs/santavillage/RewardDialog.png";
      
      public static const LAST_MILESTONE:* = 13;
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:int = 86400;
      
      public static const DEFAULT_COLLECT_THROTTLE_TIME:int = 86400;
      
      private static const SERVICE_FUNC_HARVEST_BONUS:String = "harvestDecos";
      
      private static const CRAFTSHOP_CONSUMABLE_TAB:String = "consumable";
      
      public static const HUD_INITIALISATION_FLAG_HARVEST:String = "winterracing2019_hud_initialise_flag_harvest";
      
      protected static var m_instance:Object = {};
      
      private static const m_tiles:Array = new Array("xws_rubbletreasure1","xws_rubbletreasure2","xws_rubbletreasure3","xws_rubbletreasure4","xws_rubbletreasure5","xws_rubbletreasure6","xws_rubbletreasure7","xws_rubbletreasure8","xws_rubbletreasure9","xws_rubbletreasure_payer1","xws_rubbletreasure_payer2","xws_rubbletreasure_payer3","xws_rubbletreasure_payer4","xws_rubbletreasure_payer5","xws_rubbletreasure_payer6","xws_rubbletreasure_payer7","xws_rubbletreasure_payer8","xws_rubbletreasure_payer9","xws_rubbletreasure_payer10","xws_rubbletreasure_payer11","xws_rubbletreasure_payer12","xws_rubbletreasure_payer13","xws_rubbletreasure_payer14","xws_rubbletreasure_payer15","xws_rubbletreasure_payer16","xws_rubbletreasure_payer17","xws_rubbletreasure_payer18","xws_rubbletreasure_payer19","xws_rubbletreasure_payer20","xws_rubbletreasure_payer21","xws_rubbletreasure_payer22","xws_rubbletreasure_payer23","xws_rubbletreasure_payer24","xws_rubbletreasure_payer25");
      
      private static const m_tileToGiftMapping:Array = new Array(1,1,6,10,16,29,56,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,123,124,125,126,127,128,129,130,131,132,133,134,135);
      
      private static const m_consumbalesToUnlock:Array = new Array(5,10,15,20,25,30,35,40,45,50,55,60,65,70);
      
      private static const m_giftsToMove:Array = new Array(12,12,12,48,48,72,72,84,84,108,108,120,120);
      
      private static const m_unlockGiftTimer:Array = new Array(1,1,1,1,1,2,2,4,4,5,5,5,5);
      
      private static const m_milestoneRewards:Array = new Array("consume_instagrow","horse_iceking","consume_turbo_charger","unicorn_snowboarding","consume_organic_fertilizer","horse_pinefashion","consume_unwither","unicorn_snowcamo","consume_instagrow","horse_sleighpuller","consume_turbo_charger","unicorn_snowparade","pegacorn_racewinner");
      
      public const LAST_HARVEST_TIME_KEY:String = "_lastHarvestTimeKey";
      
      private const REWARD_POPUP_WINDOW:String = "assets/dialogs/expansion/FV_RewardDialog.swf";
      
      private const KEY_BONUS_HARVEST_START_TIME:* = "bonus_harvest_start_time";
      
      private var KEY_NUMBER_TILES:String = "numbers_tiles";
      
      private var KEY_BONUS_REWARD_GRANTED:String = "key_bonus_reward_granted";
      
      protected var m_featureConfigData:Object;
      
      private var m_mainWindow:WinterRacingFeatureMainWindow;
      
      private var m_resultObject:Object = null;
      
      private var m_tilesWindow:WinterRacingFeatureTilesWindow;
      
      public var harvetBuildings:Object = {
         "elfcabin":"consume_turbo_charger",
         "elfhouse":"consume_organic_fertilizer",
         "elfbunglow":"consume_organic_fertilizer"
      };
      
      private var m_timer:Timer;
      
      private var m_timer1:Timer;
      
      public function WinterRacingFeatureManager(featureName:String)
      {
         super(featureName);
         this.m_featureConfigData = new Object();
         this.startQuest();
      }
      
      public static function getInstance(featureName:String = "GiftRush2019") : WinterRacingFeatureManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,WinterRacingFeatureManager) as WinterRacingFeatureManager;
      }
      
      public static function getTimeLeft(key:String, throttleTime:int = 86400) : int
      {
         var timeSinceLastFeed:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(key);
         return int(throttleTime - timeSinceLastFeed);
      }
      
      public function startQuest(callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",null,[FEATURE_NAME]),true);
      }
      
      public function getFeatureData() : Object
      {
         var level:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         if(!featureData)
         {
            featureData = {};
            featureData[KEY_GIFT_COUNT] = 0;
            featureData[KEY_GIFT_TIMER] = 0;
            featureData[KEY_UNBLOCK_TIMER] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            featureData[KEY_USER_MILESTONE_LEVEL] = 0;
            featureData[this.KEY_BONUS_REWARD_GRANTED] = 0;
            featureData[this.KEY_NUMBER_TILES] = this.getNumberOfTilesUnlocked();
            featureData[KEY_LOCK_STATES] = {};
            for(level = 1; level <= 14; level++)
            {
               if(level % 2 == 0)
               {
                  featureData[KEY_LOCK_STATES][level] = 1;
               }
               else
               {
                  featureData[KEY_LOCK_STATES][level] = 0;
               }
            }
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      private function onInitQuestComplete(callback:Function, result:Object) : void
      {
         this.m_resultObject = result;
         if(Boolean(result) && result.hasOwnProperty("featureData"))
         {
            FeatureOptionsManager.getInstance().setFeature(m_featureName,result["featureData"]);
            if(Boolean(callback))
            {
               callback.call();
            }
         }
      }
      
      public function craftConsumable() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         var consumableSearchStr:String = "golden ski";
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),consumableSearchStr,this.m_mainWindow,CRAFTSHOP_CONSUMABLE_TAB);
         FarmStatsManager.count(FEATURE_TRACKING,"craft","golden_ski",this.getConsumableCount().toString());
      }
      
      public function getConsumableCount() : int
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount("2hzv"));
      }
      
      public function getGiftsCount() : int
      {
         return this.getFeatureOptionsKey(KEY_GIFT_COUNT) as int;
      }
      
      public function sinkConsumable() : void
      {
         this.mainWindow.tintWindow();
         this.mainWindow.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkConsumable",this.onSinkConsumableDone,new Array(FEATURE_NAME)),true);
         FarmStatsManager.count(FEATURE_TRACKING,"sink","ski",this.getSkiCounter().toString(),null,this.getCurrentMilestoneLevel().toString(),this.getConsumableCount() - this.getSkiCounter());
      }
      
      private function onSinkConsumableDone(result:Object) : void
      {
         var currentMilestone:int = 0;
         var rewardItem:FarmItem = null;
         if(Boolean(result) && result.hasOwnProperty("featureOver"))
         {
            this.removeRacingStoneMapTriggers();
            this.removeHud();
            UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_fail.swf",FEATURE_NAME,null,4),false);
            this.mainWindow.close();
         }
         else if(Boolean(result && result.hasOwnProperty("sinked")) && Boolean(result.hasOwnProperty("count")) && result.hasOwnProperty("unblock_timer"))
         {
            if(result["sinked"] == true)
            {
               FeatureOptionsInventoryManager.getInstance().removeCount("2hzv",result["count"]);
               currentMilestone = this.getFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL) as int;
               this.saveFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL,currentMilestone + 1);
               this.saveFeatureOptionsKey(KEY_UNBLOCK_TIMER,result["unblock_timer"]);
               if(result.hasOwnProperty("initial_harvest_time"))
               {
                  this.saveFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME,result["initial_harvest_time"]);
               }
               rewardItem = this.getMilestoneRewardItem(currentMilestone + 1);
               if(this.isLastMilestoneReached())
               {
                  this.grantMilestoneReward(currentMilestone + 1,1);
               }
               else if(!this.isLevelLocked(currentMilestone + 1))
               {
                  this.grantMilestoneReward(currentMilestone + 1,2);
               }
               if(this.mainWindow)
               {
                  if(this.isLevelLocked(this.getCurrentMilestoneLevel()))
                  {
                     if(this.getCurrentMilestoneLevel() != 2)
                     {
                        this.mainWindow.startUnblockTimer();
                        this.mainWindow.showUnblockTimer();
                     }
                     this.mainWindow.showSuccessOverlay(false,rewardItem,true);
                  }
                  else
                  {
                     this.mainWindow.showSuccessOverlay(false,rewardItem,false);
                  }
               }
               this.updateRacingStoneMapTriggers();
               this.updateMapTriggers();
               if(this.mainWindow)
               {
                  this.mainWindow.untintWindow();
                  this.mainWindow.enableInput = true;
               }
            }
         }
      }
      
      public function hasEnoughConsumablesToMove() : Boolean
      {
         var result:Boolean = false;
         var currentLevel:int = this.getCurrentMilestoneLevel();
         if(this.getConsumableCount() >= m_consumbalesToUnlock[currentLevel])
         {
            result = true;
         }
         return result;
      }
      
      public function sinkGifts() : void
      {
         this.mainWindow.stopUnblockTimer();
         this.mainWindow.hideUnblockTimer();
         this.mainWindow.tintWindow();
         this.mainWindow.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGift",this.onSinkGiftsDone,new Array(FEATURE_NAME)),true);
         FarmStatsManager.count(FEATURE_TRACKING,"sink","gift",this.getGiftCounter().toString(),null,this.getCurrentMilestoneLevel().toString(),this.getGiftsCount() - this.getGiftCounter());
      }
      
      private function onSinkGiftsDone(result:Object) : void
      {
         var currentMilestone:int = 0;
         var featureData:Object = null;
         var rewardItem:FarmItem = null;
         if(Boolean(result) && result.hasOwnProperty("featureOver"))
         {
            this.removeRacingStoneMapTriggers();
            this.removeHud();
            UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_fail.swf",FEATURE_NAME,null,4),false);
            this.mainWindow.close();
         }
         else if(Boolean(result) && Boolean(result.hasOwnProperty("sinked")) && result.hasOwnProperty("count"))
         {
            if(result["sinked"] == true)
            {
               currentMilestone = this.getFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL) as int;
               featureData = this.getFeatureData();
               featureData[KEY_GIFT_COUNT] -= result["count"];
               featureData[KEY_LOCK_STATES][currentMilestone] = 0;
               rewardItem = this.getMilestoneRewardItem(currentMilestone);
               this.grantMilestoneReward(currentMilestone,1);
               setFeatureData(featureData);
               if(this.mainWindow)
               {
                  this.mainWindow.stopUnblockTimer();
                  this.mainWindow.hideUnblockTimer();
                  this.mainWindow.refreshWindow();
                  if(rewardItem)
                  {
                     this.mainWindow.showSuccessOverlay(true,rewardItem,false);
                  }
               }
               this.updateRacingStoneMapTriggers();
               this.updateMapTriggers();
               if(this.mainWindow)
               {
                  this.mainWindow.untintWindow();
                  this.mainWindow.enableInput = true;
               }
            }
         }
      }
      
      public function hasUnblockTimerExpired() : Boolean
      {
         var featureObject:Object = this.getFeatureData();
         var expired:Boolean = false;
         var activeTime:Number = featureObject[KEY_UNBLOCK_TIMER] as Number;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currenttime - activeTime > 86400 * m_unlockGiftTimer[this.getCurrentMilestoneLevel()])
         {
            expired = true;
         }
         return expired;
      }
      
      public function getUnblockTimeRemaining() : Number
      {
         var featureObject:Object = this.getFeatureData();
         var activeTime:Number = featureObject[KEY_UNBLOCK_TIMER] as Number;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return 86400 * m_unlockGiftTimer[this.getCurrentMilestoneLevel()] - (currenttime - activeTime);
      }
      
      public function hasEnoughGiftsToUnblock() : Boolean
      {
         var currentMileStone:int = this.getCurrentMilestoneLevel();
         var giftsNedeed:int = int(m_giftsToMove[currentMileStone]);
         return this.getGiftsCount() >= giftsNedeed;
      }
      
      public function getCurrentMilestoneUnblockTimer() : int
      {
         return m_unlockGiftTimer[this.getCurrentMilestoneLevel()];
      }
      
      public function unblockOnTimeEnd(level:int) : void
      {
         var featureData:Object = this.getFeatureData();
         featureData[KEY_LOCK_STATES][level] = 0;
         setFeatureData(featureData);
         var rewardItem:FarmItem = this.getMilestoneRewardItem(level);
         this.grantMilestoneReward(level,1);
         if(Boolean(this.mainWindow) && Boolean(rewardItem))
         {
            this.mainWindow.showSuccessOverlay(true,rewardItem,false);
         }
         this.updateRacingStoneMapTriggers();
         this.updateMapTriggers();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"unblockOnTimeEnd",null,new Array(FEATURE_NAME)),true);
      }
      
      public function getCurrentMilestoneLevel() : int
      {
         return this.getFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL) as int;
      }
      
      public function isLevelLocked(level:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[KEY_LOCK_STATES][level] == 1)
         {
            result = true;
         }
         return result;
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         var featureData:Object = this.getFeatureData();
         var val:Object = null;
         if(featureData.hasOwnProperty(optionName))
         {
            val = featureData[optionName];
         }
         return val;
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         var featureObject:* = this.getFeatureData();
         featureObject[optionName] = optionsValue;
         setFeatureData(featureObject);
      }
      
      public function get mainWindow() : WinterRacingFeatureMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function showMainWindow() : void
      {
         this.tileBuy();
         this.m_mainWindow = new WinterRacingFeatureMainWindow("GiftRush2019","assets/dialogs/gift_rush_dec_2019/FV_racing_main_ui.swf",false);
         UI.displayPopup(this.m_mainWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"mainui","open");
      }
      
      public function getMilestoneRewardItem(level:int) : FarmItem
      {
         var rewardName:String = null;
         var milestoneIndex:int = level - 1;
         if(m_milestoneRewards.hasOwnProperty(milestoneIndex.toString()))
         {
            rewardName = m_milestoneRewards[milestoneIndex];
         }
         return Global.farmGameSettingsManager.getFarmItemByName(rewardName);
      }
      
      public function grantMilestoneReward(level:int, count:int) : void
      {
         var rewardItem:FarmItem = this.getMilestoneRewardItem(level);
         Global.player.addGift(rewardItem.name,null,count);
         FarmStatsManager.count(FEATURE_TRACKING,"Milestone",level.toString(),rewardItem.friendlyTitle,"milestone_rewrd");
      }
      
      public function isLevelCompleted(level:int) : Boolean
      {
         var result:Boolean = false;
         var currentLevel:int = this.getFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL) as int;
         if(this.isLevelLocked(currentLevel))
         {
            result = level < currentLevel;
         }
         else
         {
            result = level <= currentLevel;
         }
         return result;
      }
      
      public function isAllTilesPurchased() : Boolean
      {
         var result:Boolean = false;
         var tileLockedCount:Number = 0;
         for(var index:int = 0; index < m_tiles.length; index++)
         {
            if(Global.world.getObjectsByName(m_tiles[index]).length > 0)
            {
               tileLockedCount++;
            }
         }
         if(tileLockedCount <= 34)
         {
            result = true;
         }
         return result;
      }
      
      public function getNumberOfTilesUnlocked() : int
      {
         var tileLockedCount:Number = 0;
         for(var index:int = 0; index < m_tiles.length; index++)
         {
            if(Global.world.getObjectsByName(m_tiles[index]).length > 0)
            {
               tileLockedCount++;
            }
         }
         return 34 - tileLockedCount;
      }
      
      public function getGiftSpeed() : int
      {
         var numberOfTilesPurchased:int = this.getNumberOfTilesUnlocked();
         if(numberOfTilesPurchased >= 34)
         {
            return m_tileToGiftMapping[34];
         }
         return m_tileToGiftMapping[numberOfTilesPurchased];
      }
      
      public function hasGiftTimerExpired() : Boolean
      {
         var featureObject:Object = this.getFeatureData();
         var expired:Boolean = false;
         var activeTime:Number = featureObject[KEY_GIFT_TIMER] as Number;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currenttime - activeTime > 7200)
         {
            expired = true;
         }
         return expired;
      }
      
      public function getGiftTimeRemain() : int
      {
         var featureObject:Object = this.getFeatureData();
         var activeTime:Number = featureObject[KEY_GIFT_TIMER] as Number;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return 7200 - (currenttime - activeTime);
      }
      
      public function tileBuy() : Boolean
      {
         var result:Boolean = false;
         var tilesCount:int = this.getFeatureOptionsKey(this.KEY_NUMBER_TILES) as int;
         var tilesCurrentCount:int = this.getNumberOfTilesUnlocked();
         result = tilesCurrentCount > tilesCount;
         if(result)
         {
            this.saveFeatureOptionsKey(this.KEY_NUMBER_TILES,tilesCurrentCount);
            this.saveFeatureOptionsKey(KEY_GIFT_TIMER,0);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"onTileBuy",null,new Array(FEATURE_NAME)),true);
         }
         return result;
      }
      
      public function onGiftCollect() : void
      {
         this.m_mainWindow.tintWindow();
         this.m_mainWindow.enableInput = false;
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"collectGift",this.onCollectGift,new Array(FEATURE_NAME)),true);
         FarmStatsManager.count(FEATURE_TRACKING,"collect","gift",this.getGiftSpeed().toString(),null,this.getCurrentMilestoneLevel().toString(),this.getGiftsCount() + this.getGiftSpeed());
      }
      
      public function onCollectGift(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("featureOver"))
         {
            this.removeRacingStoneMapTriggers();
            this.removeHud();
            UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_fail.swf",FEATURE_NAME,null,4),false);
            this.mainWindow.close();
         }
         else
         {
            if(Boolean(result) && !result.hasOwnProperty("error"))
            {
               this.saveFeatureOptionsKey(KEY_GIFT_COUNT,result["gifts"]);
               this.saveFeatureOptionsKey(KEY_GIFT_TIMER,result["giftTimer"]);
            }
            if(this.m_mainWindow)
            {
               this.m_mainWindow.refreshGifts();
               if(!this.isLastMilestoneReached())
               {
                  this.m_mainWindow.updateMoveAndUnblockButton();
                  this.m_mainWindow.moveVisibility();
               }
               else
               {
                  this.m_mainWindow.finalMilestoneReached();
               }
            }
            if(this.m_mainWindow)
            {
               this.m_mainWindow.untintWindow();
               this.m_mainWindow.enableInput = true;
            }
         }
      }
      
      public function openTilesWindow() : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.tintWindow();
            this.m_mainWindow.enableInput = false;
         }
         this.m_tilesWindow = new WinterRacingFeatureTilesWindow(FEATURE_NAME,"assets/dialogs/gift_rush_dec_2019/FV_racing_tiles_info.swf");
         UI.displayPopup(this.m_tilesWindow,false);
         FarmStatsManager.count(FEATURE_TRACKING,"land_purchase","window","open");
      }
      
      public function getTilesIndex() : int
      {
         var numberOfTilesPurchased:int = this.getNumberOfTilesUnlocked();
         if(numberOfTilesPurchased >= 0 && numberOfTilesPurchased <= 1)
         {
            return 0;
         }
         if(numberOfTilesPurchased >= 2 && numberOfTilesPurchased <= 3)
         {
            return 1;
         }
         if(numberOfTilesPurchased >= 4 && numberOfTilesPurchased <= 5)
         {
            return 2;
         }
         if(numberOfTilesPurchased >= 6 && numberOfTilesPurchased <= 7)
         {
            return 3;
         }
         return 4;
      }
      
      public function showBoostUI() : void
      {
         UI.displayMiniMarketDialog(m_tiles,null,"seed",null,true,false,false,true);
         this.mainWindow.close();
      }
      
      public function updateRacingStoneMapTriggers() : void
      {
         var name:String = null;
         var map:MapTrigger = null;
         var count:int = this.getFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL) as int;
         for(var i:int = 0; i <= 12; i++)
         {
            name = "WinterRacingFeatureRacingFlagMapTrigger" + i.toString();
            map = MapTriggerManager.getInstance().getMapTriggerByName(name);
            if(map)
            {
               map.setVisible(false);
               this.stopRacingStoneGamebordTimer();
            }
         }
         if(count <= 12)
         {
            if(count % 2 == 0)
            {
               if(count == 0)
               {
                  name = "WinterRacingFeatureRacingFlagMapTrigger" + (count + 2).toString();
               }
               else if(this.isLevelLocked(count))
               {
                  name = "WinterRacingFeatureRacingFlagMapTrigger" + count.toString();
               }
               else
               {
                  name = "WinterRacingFeatureRacingFlagMapTrigger" + (count + 2).toString();
               }
            }
            else
            {
               name = "WinterRacingFeatureRacingFlagMapTrigger" + (count + 1).toString();
            }
            map = MapTriggerManager.getInstance().getMapTriggerByName(name);
            if(map)
            {
               map.setVisible(true);
            }
         }
      }
      
      public function updateMapTriggers() : void
      {
         var name:String = null;
         var map:MapTrigger = null;
         var count:int = this.getFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL) as int;
         for(var i:int = 0; i <= 14; i++)
         {
            name = "WinterRacingFeatureRacingMapTrigger" + i.toString();
            map = MapTriggerManager.getInstance().getMapTriggerByName(name);
            if(map)
            {
               map.setVisible(count == i);
               this.stopSkighGamebordTimer();
            }
         }
      }
      
      public function isLastMilestoneReached() : Boolean
      {
         var milestoneLevel:int = this.getCurrentMilestoneLevel();
         return milestoneLevel == LAST_MILESTONE;
      }
      
      public function grantBonusRewardItem() : void
      {
         var rewardItem:FarmItem = null;
         var giftCount:int = this.getGiftsCount();
         if(giftCount >= 500 && giftCount < 2000)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName("elfcabin");
            Global.player.addGift("elfcabin");
            FarmStatsManager.count(FEATURE_TRACKING,"reward","bonus","elfcabin","final_reward");
         }
         else if(giftCount >= 2000 && giftCount < 8000)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName("elfhouse");
            Global.player.addGift("elfhouse");
            FarmStatsManager.count(FEATURE_TRACKING,"reward","bonus","elfhouse","final_reward");
         }
         else if(giftCount >= 8000 && giftCount < 16000)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName("elfbunglow");
            Global.player.addGift("elfbunglow");
            FarmStatsManager.count(FEATURE_TRACKING,"reward","bonus","elfbunglow","final_reward");
         }
         else if(giftCount >= 16000)
         {
            Global.player.addGift("elfcabin");
            Global.player.addGift("elfhouse");
            Global.player.addGift("elfbunglow");
            FarmStatsManager.count(FEATURE_TRACKING,"reward","bonus","elfcabin,elfhouse,elfbunglow","final_reward");
         }
      }
      
      public function getBonusRewardItemName() : String
      {
         var giftCount:int = this.getGiftsCount();
         if(giftCount >= 500 && giftCount < 2000)
         {
            return "elfcabin";
         }
         if(giftCount >= 2000 && giftCount < 8000)
         {
            return "elfhouse";
         }
         if(giftCount >= 8000 && giftCount < 16000)
         {
            return "elfbunglow";
         }
         if(giftCount >= 16000)
         {
            return "gift_rush_all_bonus";
         }
         return null;
      }
      
      public function removeHud() : void
      {
         if(Global.hud)
         {
            Global.hud.removesetHudWinterRacingFeature();
         }
      }
      
      public function getSkiCounter() : int
      {
         var currentMilestone:int = this.getCurrentMilestoneLevel();
         return m_consumbalesToUnlock[currentMilestone];
      }
      
      public function getGiftCounter() : int
      {
         var currentMilestone:int = this.getCurrentMilestoneLevel();
         if(currentMilestone < 13)
         {
            return m_giftsToMove[currentMilestone];
         }
         return 0;
      }
      
      public function isDecosReadyForHarvest(itemName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.getTimeLeftForBonusHarvest(itemName) <= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getTimeLeftForBonusHarvest(itemName:String) : int
      {
         var key:String = itemName + this.LAST_HARVEST_TIME_KEY;
         var throttleTime:int = DEFAULT_HARVEST_THROTTLE_TIME;
         return getTimeLeft(key,throttleTime);
      }
      
      public function harvestBonusBuilding(buildingName:String) : void
      {
         var harvestRewardName:String = null;
         var featureKey:String = null;
         var key:String = buildingName + this.LAST_HARVEST_TIME_KEY;
         Global.player.setFeatureLastShown(key,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         if(buildingName == "elfbunglow")
         {
            harvestRewardName = "turbo_plus_organic_fertilizer";
         }
         else
         {
            harvestRewardName = this.getHarvestItem(buildingName);
         }
         var harvestFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(harvestRewardName);
         if(harvestFarmItem)
         {
            if(buildingName == "elfbunglow")
            {
               Global.player.addGift("consume_turbo_charger",null,2);
               Global.player.addGift("consume_organic_fertilizer",null,2);
            }
            else
            {
               Global.player.addGift(harvestRewardName,null,2);
            }
            featureKey = m_featureName + this.LAST_HARVEST_TIME_KEY;
            FarmStatsManager.count(m_featureName,"Harvest",buildingName,harvestRewardName);
            UI.displayPopup(new GenericSingleRewardPopup(this.REWARD_POPUP_WINDOW,"Gift_Rush_Bonus_" + buildingName,harvestFarmItem,null,REWARD_WINDOW_IMAGE),false);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,SERVICE_FUNC_HARVEST_BONUS,null,[m_featureName,buildingName]),true);
         }
      }
      
      public function getHarvestItem(buildingName:String) : String
      {
         return this.harvetBuildings[buildingName];
      }
      
      public function hasHarvestExpiryDatePassedForFeature(itemName:String) : Boolean
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         var timeRemain:int = 0;
         var finishTime:Number = NaN;
         var now:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("12/30/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         timeLeft = endTime - now;
         if(timeLeft < 0)
         {
            timeRemain = this.getTimeLeftForBonusHarvest(itemName);
            finishTime = FarmGameUtil.synchronizedDateTimeToNumber("12/31/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
            return finishTime - now <= timeRemain;
         }
         return false;
      }
      
      public function canHarvestBonusRewardBuilding() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:* = this.getFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME) as int;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 14 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function shouldShowBonusHarvestTimer() : Boolean
      {
         var isStillHarvestable:Boolean = false;
         var bonusStartTime:* = this.getFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME) as int;
         if(bonusStartTime)
         {
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - bonusStartTime < 13 * 86400)
            {
               isStillHarvestable = true;
            }
         }
         return isStillHarvestable;
      }
      
      public function sinkConsumableFTUEMove() : void
      {
         FeatureOptionsInventoryManager.getInstance().removeCount("2hzv",5);
         var currentMilestone:int = this.getFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL) as int;
         this.saveFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL,currentMilestone + 1);
         var rewardItem:FarmItem = this.getMilestoneRewardItem(currentMilestone + 1);
         this.grantMilestoneReward(currentMilestone + 1,2);
         this.updateMapTriggers();
         if(Boolean(this.mainWindow) && Boolean(rewardItem))
         {
            this.mainWindow.showSuccessOverlay(false,rewardItem,false);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkConsumableFTUEMove",null,new Array(FEATURE_NAME)),true);
      }
      
      public function onGiftCollectFTUE() : void
      {
         var featureData:Object = this.getFeatureData();
         featureData[KEY_GIFT_COUNT] += 12;
         featureData[KEY_GIFT_TIMER] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         setFeatureData(featureData);
         this.m_mainWindow.refreshGifts();
         this.m_mainWindow.updateMoveAndUnblockButton();
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"collectGiftFTUE",null,new Array(FEATURE_NAME)),true);
      }
      
      public function sinkGiftsFTUEUnblock() : void
      {
         var currentMilestone:int = this.getFeatureOptionsKey(KEY_USER_MILESTONE_LEVEL) as int;
         var featureData:Object = this.getFeatureData();
         featureData[KEY_LOCK_STATES][currentMilestone] = 0;
         featureData[KEY_GIFT_COUNT] -= 12;
         featureData[KEY_UNBLOCK_TIMER] = 0;
         setFeatureData(featureData);
         var rewardItem:FarmItem = this.getMilestoneRewardItem(currentMilestone);
         this.grantMilestoneReward(currentMilestone,1);
         this.updateRacingStoneMapTriggers();
         if(Boolean(this.mainWindow) && Boolean(rewardItem))
         {
            this.mainWindow.showSuccessOverlay(true,rewardItem,false);
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkGiftFTUE",null,new Array(FEATURE_NAME)),true);
      }
      
      public function setUpHudWinterRacing2019() : void
      {
         Global.hud.setHudWinterRacingFeature(new HudBottomWinterRacingFeature("assets/dialogs/gift_rush_dec_2019/FV_hud_racing.swf","GiftRush2019"));
      }
      
      public function bonusReward() : void
      {
         var rewardItem:FarmItem = null;
         var bonusRewardName:String = WinterRacingFeatureManager.getInstance().getBonusRewardItemName();
         if(bonusRewardName)
         {
            if(bonusRewardName == "elfcabin")
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName("elfcabin");
               UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_0.swf",FEATURE_NAME,rewardItem,1,null,"assets/buildings/elfcabin_icon_200.png"),false);
            }
            else if(bonusRewardName == "elfhouse")
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName("elfhouse");
               UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_0.swf",FEATURE_NAME,rewardItem,1,null,"assets/buildings/elfhouse_icon_200.png"),false);
            }
            else if(bonusRewardName == "elfbunglow")
            {
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName("elfbunglow");
               UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_0.swf",FEATURE_NAME,rewardItem,1,null,"assets/buildings/elfbunglow_icon_200.png"),false);
            }
            else if(bonusRewardName == "gift_rush_all_bonus")
            {
               UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_0.swf",FEATURE_NAME,null,1,null,"assets/dialogs/gift_rush_dec_2019/all_3_200.png"),false);
            }
         }
      }
      
      public function grantBonusReward() : void
      {
         if(this.getFeatureOptionsKey(this.KEY_BONUS_REWARD_GRANTED) as int == 0)
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"featureEnd",this.onFeatureComplete,new Array(FEATURE_NAME)),true);
         }
      }
      
      public function onFeatureComplete(result:Object) : void
      {
         var rewardItem:FarmItem = null;
         Global.player.setSeenFlag(HUD_INITIALISATION_FLAG_HARVEST,true);
         if(result)
         {
            if(result.hasOwnProperty("none"))
            {
               UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_fail.swf",FEATURE_NAME,null,3),false);
            }
            else if(result.hasOwnProperty("insta"))
            {
               Global.player.addGift("consume_instagrow",null,3);
               rewardItem = Global.farmGameSettingsManager.getFarmItemByName("consume_instagrow");
               UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_0.swf",FEATURE_NAME,rewardItem,2),false);
               FarmStatsManager.count(FEATURE_TRACKING,"reward","bonus","instagrow","final_reward");
            }
            else
            {
               this.grantBonusRewardItem();
               this.bonusReward();
            }
            if(result.hasOwnProperty("BONUS_GRANTED"))
            {
               this.saveFeatureOptionsKey(this.KEY_BONUS_REWARD_GRANTED,result["BONUS_GRANTED"]);
            }
            if(result.hasOwnProperty("initial_harvest_time"))
            {
               this.saveFeatureOptionsKey(this.KEY_BONUS_HARVEST_START_TIME,result["initial_harvest_time"]);
            }
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         this.removeHud();
         this.removeRacingStoneMapTriggers();
      }
      
      public function removeRacingStoneMapTriggers() : void
      {
         var name:String = null;
         var map:MapTrigger = null;
         for(var i:int = 0; i <= 12; i++)
         {
            name = "WinterRacingFeatureRacingFlagMapTrigger" + i.toString();
            map = MapTriggerManager.getInstance().getMapTriggerByName(name);
            if(map)
            {
               map.setVisible(false);
            }
         }
      }
      
      public function removeMapTriggers() : void
      {
         var name:String = null;
         var map:MapTrigger = null;
         for(var i:int = 0; i <= 14; i++)
         {
            name = "WinterRacingFeatureRacingMapTrigger" + i.toString();
            map = MapTriggerManager.getInstance().getMapTriggerByName(name);
            if(map)
            {
               map.setVisible(false);
            }
         }
      }
      
      public function startRacingStoneGamebordTimer() : void
      {
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onRacingStoneTimer);
         this.m_timer.start();
      }
      
      private function onRacingStoneTimer(event:TimerEvent) : void
      {
         this.updateRacingStoneMapTriggers();
      }
      
      private function stopRacingStoneGamebordTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onRacingStoneTimer);
            this.m_timer = null;
         }
      }
      
      public function startSkighGamebordTimer() : void
      {
         this.m_timer1 = new Timer(1000);
         this.m_timer1.addEventListener(TimerEvent.TIMER,this.onSkighTimer);
         this.m_timer1.start();
      }
      
      private function onSkighTimer(event:TimerEvent) : void
      {
         this.updateMapTriggers();
      }
      
      private function stopSkighGamebordTimer() : void
      {
         if(this.m_timer1)
         {
            this.m_timer1.stop();
            this.m_timer1.removeEventListener(TimerEvent.TIMER,this.onSkighTimer);
            this.m_timer1 = null;
         }
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var endTime:Number = NaN;
         var timeLeft:Number = NaN;
         endTime = FarmGameUtil.synchronizedDateTimeToNumber("12/30/2019");
         timeLeft = (endTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return this.getformattedDaysLeft(timeLeft);
      }
      
      public function getformattedDaysLeft(timeLeft:Number) : String
      {
         var days:int = 0;
         var result:String = "";
         if(timeLeft < 0)
         {
            timeLeft = 0;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
            result = days.toString();
            if(days < 10)
            {
               result = "0" + result;
            }
            if(days == 0)
            {
               result = "--";
            }
         }
         return result;
      }
      
      public function isWinterRacing2019Active() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("winterracing2019_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(Boolean(WinterRacingFeatureManager.getInstance()) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_SANTAVILLAGE)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function featureEndFlow() : void
      {
         this.removeRacingStoneMapTriggers();
         this.removeHud();
         UI.displayPopup(new WinterRacingFeatureMilestoneRewardWindow("assets/dialogs/gift_rush_dec_2019/FV_end_reward_fail.swf",FEATURE_NAME,null,4),false);
         this.mainWindow.close();
      }
   }
}

