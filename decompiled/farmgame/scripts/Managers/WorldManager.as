package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.DisplayLoading.DLManager;
   import Classes.Idle.ExpansionPromptIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.LonelyAnimalIdleTask;
   import Classes.NPCConfigData;
   import Classes.Quest.FarmQuestManager;
   import Classes.VisitorManager;
   import Classes.WorldLicenseRequirement;
   import Classes.WorldSummary;
   import Classes.WorldSwapOptions;
   import Classes.ZItem.ChangeFarmItem;
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Classes.ZItem.ExpansionPlotLimits;
   import Classes.ZItem.FarmItem;
   import Classes.instagrow.InstagrowUtils;
   import Classes.unwither.UnwitherUtils;
   import Classes.util.ExternalUtil;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.TravelOptionsDialog;
   import Display.FarmDynamicDialog;
   import Display.GenericPopup;
   import Display.HUD.HUDSkinConfig;
   import Display.HUD.TravelNameDisplay;
   import Display.TravelAnimation;
   import Display.UI;
   import Engine.Events.LoaderEvent;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import GameMode.GameMode;
   import Init.Worlds.BaseWorldInit;
   import Init.Worlds.HomeWorldInit;
   import Init.Worlds.NPCWorldInit;
   import Init.Worlds.NeighborWorldInit;
   import Init.Worlds.StaticWorldInit;
   import Managers.BeatExpansion.BeatAfricaManager;
   import Managers.BeatExpansion.BeatAlaskaExpansionManager;
   import Managers.BeatExpansion.BeatAtlantisManager;
   import Managers.BeatExpansion.BeatAustraliaManager;
   import Managers.BeatExpansion.BeatAvalonManager;
   import Managers.BeatExpansion.BeatBloomExpansionManager;
   import Managers.BeatExpansion.BeatBoraExpansionManager;
   import Managers.BeatExpansion.BeatCandyManager;
   import Managers.BeatExpansion.BeatCoastalExpansionManager;
   import Managers.BeatExpansion.BeatCocolandExpansionManager;
   import Managers.BeatExpansion.BeatEnchantedGlenManager;
   import Managers.BeatExpansion.BeatFantasyForestManager;
   import Managers.BeatExpansion.BeatHauntedHallowManager;
   import Managers.BeatExpansion.BeatHawaiiManager;
   import Managers.BeatExpansion.BeatHolidayLightsManager;
   import Managers.BeatExpansion.BeatHolidayTownManager;
   import Managers.BeatExpansion.BeatIndiaExpansionManager;
   import Managers.BeatExpansion.BeatIrelandExpansionManager;
   import Managers.BeatExpansion.BeatJadeFallsManager;
   import Managers.BeatExpansion.BeatJungleExpansionManager;
   import Managers.BeatExpansion.BeatKingdomManager;
   import Managers.BeatExpansion.BeatMapleExpansionManager;
   import Managers.BeatExpansion.BeatMediterraneanManager;
   import Managers.BeatExpansion.BeatOasisManager;
   import Managers.BeatExpansion.BeatOzManager;
   import Managers.BeatExpansion.BeatRainForestManager;
   import Managers.BeatExpansion.BeatSecretExpansionManager;
   import Managers.BeatExpansion.BeatSleepyhollowManager;
   import Managers.BeatExpansion.BeatSoireeExpansionManager;
   import Managers.BeatExpansion.BeatSpaceManager;
   import Managers.BeatExpansion.BeatSpookOWeenExpansionManager;
   import Managers.BeatExpansion.BeatStorybookManager;
   import Managers.BeatExpansion.BeatToylandManager;
   import Managers.BeatExpansion.BeatTrailsExpansionManager;
   import Managers.BeatExpansion.BeatTransylvaniaManager;
   import Managers.BeatExpansion.BeatTreasureTidesManager;
   import Managers.BeatExpansion.BeatValleyExpansionManager;
   import Managers.BeatExpansion.BeatWildWestManager;
   import Managers.BeatExpansion.BeatWinterExpansionManager;
   import Managers.BeatExpansion.BeatanglofrenchExpansionManager;
   import Managers.BeatExpansion.BeatbrazilExpansionManager;
   import Managers.BeatExpansion.BeatcaribbeanExpansionManager;
   import Managers.BeatExpansion.BeatcasablancaExpansionManager;
   import Managers.BeatExpansion.BeatdragonvalleyExpansionManager;
   import Managers.BeatExpansion.BeatdreamworldExpansionManager;
   import Managers.BeatExpansion.BeathalloweenmadExpansionManager;
   import Managers.BeatExpansion.BeathalloweenusaExpansionManager;
   import Managers.BeatExpansion.BeatisraelExpansionManager;
   import Managers.BeatExpansion.BeatlimboExpansionManager;
   import Managers.BeatExpansion.BeatmidwestExpansionManager;
   import Managers.BeatExpansion.BeatmountExpansionManager;
   import Managers.BeatExpansion.BeatnewfrontierExpansionManager;
   import Managers.BeatExpansion.BeatrussiaExpansionManager;
   import Managers.BeatExpansion.BeatrussiaExpansion_aManager;
   import Managers.BeatExpansion.BeatsouthindiaExpansionManager;
   import Managers.BeatExpansion.BeatturtleislandExpansionManager;
   import Managers.BeatExpansion.BeattuscanyExpansionManager;
   import Managers.BeatExpansion.BeattwentiesExpansionManager;
   import Managers.BeatExpansion.BeatunderwaterExpansionManager;
   import Managers.BeatExpansion.BeatwhitewinterExpansionManager;
   import Managers.BeatExpansion.BeatwinternordExpansionManager;
   import Transactions.TExpansionWorldAccess;
   import Transactions.TFarmTransaction;
   import Transactions.TLoadNPC;
   import Transactions.TLoadNeighbor;
   import Transactions.TLoadStaticWorld;
   import Transactions.TRefreshGifts;
   import Transactions.TWorldLoad;
   import Transactions.TWorldLoadAfterCache;
   import Transactions.TWorldPeek;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.Crafting.CraftshopWindow;
   import Widgets.Windows.Market.MarketWindow;
   import Widgets.Windows.PPHLimitWindow;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getTimer;
   
   public class WorldManager extends EventDispatcher
   {
      
      public static const YULETIDE_INVENTORY_ID:Number = -78;
      
      public static const PUMPKIN_INVENTORY_ID:Number = -77;
      
      public static const ALOHA_INVENTORY_ID:Number = -76;
      
      public static const CANADA_INVENTORY_ID:Number = -75;
      
      public static const AMSTERDAM_INVENTORY_ID:Number = -74;
      
      public static const MADAGASCAR_INVENTORY_ID:Number = -72;
      
      public static const FARMFEST_INVENTORY_ID:Number = -71;
      
      public static const BORABORA_INVENTORY_ID:Number = -73;
      
      public static const SANTAVILLAGE_INVENTORY_ID:Number = -70;
      
      public static const SPOOKY_INVENTORY_ID:Number = -69;
      
      public static const IRELAND_INVENTORY_ID:Number = -68;
      
      public static const COCOLAND_INVENTORY_ID:Number = -67;
      
      public static const ALASKA_INVENTORY_ID:Number = -66;
      
      public static const TWENTIES_INVENTORY_ID:Number = -65;
      
      public static const SOUTHINDIA_INVENTORY_ID:Number = -64;
      
      public static const WINTERNORD_INVENTORY_ID:Number = -62;
      
      public static const CASABLANCA_INVENTORY_ID:Number = -63;
      
      public static const HALLOWEENMAD_INVENTORY_ID:Number = -61;
      
      public static const ISRAEL_INVENTORY_ID:Number = -60;
      
      public static const NEWFRONTIER_INVENTORY_ID:Number = -59;
      
      public static const RUSSIA_INVENTORY_ID:Number = -58;
      
      public static const CARIBBEAN_INVENTORY_ID:Number = -57;
      
      public static const DRAGONVALLEY_INVENTORY_ID:Number = -56;
      
      public static const TUSCANY_INVENTORY_ID:Number = -55;
      
      public static const WHITEWINTER_INVENTORY_ID:Number = -54;
      
      public static const HALLOWEENUSA_INVENTORY_ID:Number = -53;
      
      public static const ANGLOFRENCH_INVENTORY_ID:Number = -51;
      
      public static const INVALID_EXP_SCORE_LEVEL:int = -1;
      
      public static const HOME_INVENTORY_ID:Number = -2;
      
      public static const ENGLAND_INVENTORY_ID:Number = -8;
      
      public static const FISHERMAN_INVENTORY_ID:Number = -9;
      
      public static const WINTER_WONDERLAND_INVENTORY_ID:Number = -10;
      
      public static const HAWAII_INVENTORY_ID:Number = -11;
      
      public static const HALLOW_INVENTORY_ID:Number = -14;
      
      public static const ASIA_INVENTORY_ID:Number = -13;
      
      public static const ANGLER_INVENTORY_ID:Number = -17;
      
      public static const HTOWN_INVENTORY_ID:Number = -15;
      
      public static const MEADOWS_INVENTORY_ID:Number = -16;
      
      public static const GLEN_INVENTORY_ID:Number = -18;
      
      public static const ATLANTIS_INVENTORY_ID:Number = -19;
      
      public static const GARDEN_INVENTORY_ID:Number = -20;
      
      public static const AUSTRALIA_INVENTORY_ID:Number = -21;
      
      public static const SPACE_INVENTORY_ID:Number = -22;
      
      public static const CANDY_INVENTORY_ID:Number = -23;
      
      public static const FFOREST_INVENTORY_ID:Number = -24;
      
      public static const HLIGHTS_INVENTORY_ID:Number = -25;
      
      public static const RAINFOREST_INVENTORY_ID:Number = -26;
      
      public static const OZ_INVENTORY_ID:Number = -28;
      
      public static const VILLAGE_INVENTORY_ID:Number = -27;
      
      public static const MEDITERRANEAN_INVENTORY_ID:Number = -29;
      
      public static const OASIS_INVENTORY_ID:Number = -31;
      
      public static const STORYBOOK_INVENTORY_ID:Number = -32;
      
      public static const SLEEPYHOLLOW_INVENTORY_ID:Number = -33;
      
      public static const EASTEROS_INVENTORY_ID:Number = -35;
      
      public static const TOYLAND_INVENTORY_ID:Number = -34;
      
      public static const AVALON_INVENTORY_ID:Number = -35;
      
      public static const WILDWEST_INVENTORY_ID:Number = -36;
      
      public static const TREASURETIDES_INVENTORY_ID:Number = -37;
      
      public static const AFRICA_INVENTORY_ID:Number = -38;
      
      public static const TRANSYLVANIA_INVENTORY_ID:Number = -39;
      
      public static const WINTER_INVENTORY_ID:Number = -40;
      
      public static const JAPAN_INVENTORY_ID:Number = -42;
      
      public static const INDIA_INVENTORY_ID:Number = -41;
      
      public static const JUNGLE_INVENTORY_ID:Number = -43;
      
      public static const MOUNT_INVENTORY_ID:Number = -44;
      
      public static const LIMBO_INVENTORY_ID:Number = -45;
      
      public static const XMAS_INVENTORY_ID:Number = -46;
      
      public static const MIDWEST_INVENTORY_ID:Number = -47;
      
      public static const TURTLEISLAND_INVENTORY_ID:Number = -49;
      
      public static const UNDERWATER_INVENTORY_ID:Number = -48;
      
      public static const DREAMWORLD_INVENTORY_ID:Number = -50;
      
      public static const BRAZIL_INVENTORY_ID:Number = -52;
      
      public static const WORLD_INVENTORY_IDS:Array = [HOME_INVENTORY_ID,ENGLAND_INVENTORY_ID,FISHERMAN_INVENTORY_ID,WINTER_WONDERLAND_INVENTORY_ID,HAWAII_INVENTORY_ID,ASIA_INVENTORY_ID,HALLOW_INVENTORY_ID,HTOWN_INVENTORY_ID,MEADOWS_INVENTORY_ID,ANGLER_INVENTORY_ID,GLEN_INVENTORY_ID,ATLANTIS_INVENTORY_ID,GARDEN_INVENTORY_ID,AUSTRALIA_INVENTORY_ID,SPACE_INVENTORY_ID,CANDY_INVENTORY_ID,FFOREST_INVENTORY_ID,HLIGHTS_INVENTORY_ID,RAINFOREST_INVENTORY_ID,OZ_INVENTORY_ID,MEDITERRANEAN_INVENTORY_ID,OASIS_INVENTORY_ID,STORYBOOK_INVENTORY_ID,SLEEPYHOLLOW_INVENTORY_ID,TOYLAND_INVENTORY_ID,AVALON_INVENTORY_ID,WILDWEST_INVENTORY_ID,TREASURETIDES_INVENTORY_ID,AFRICA_INVENTORY_ID,TRANSYLVANIA_INVENTORY_ID,INDIA_INVENTORY_ID,WINTER_INVENTORY_ID,JAPAN_INVENTORY_ID,JUNGLE_INVENTORY_ID,VILLAGE_INVENTORY_ID,MOUNT_INVENTORY_ID,LIMBO_INVENTORY_ID,XMAS_INVENTORY_ID,MIDWEST_INVENTORY_ID,TURTLEISLAND_INVENTORY_ID,UNDERWATER_INVENTORY_ID,ANGLOFRENCH_INVENTORY_ID,DREAMWORLD_INVENTORY_ID,BRAZIL_INVENTORY_ID,HALLOWEENUSA_INVENTORY_ID
      ,DRAGONVALLEY_INVENTORY_ID,WHITEWINTER_INVENTORY_ID,TUSCANY_INVENTORY_ID,RUSSIA_INVENTORY_ID,TUSCANY_INVENTORY_ID,ISRAEL_INVENTORY_ID,CARIBBEAN_INVENTORY_ID,NEWFRONTIER_INVENTORY_ID,HALLOWEENMAD_INVENTORY_ID,WINTERNORD_INVENTORY_ID,CASABLANCA_INVENTORY_ID,SOUTHINDIA_INVENTORY_ID,TWENTIES_INVENTORY_ID,ALASKA_INVENTORY_ID,COCOLAND_INVENTORY_ID,IRELAND_INVENTORY_ID,SPOOKY_INVENTORY_ID,SANTAVILLAGE_INVENTORY_ID,BORABORA_INVENTORY_ID,CANADA_INVENTORY_ID,FARMFEST_INVENTORY_ID,MADAGASCAR_INVENTORY_ID,AMSTERDAM_INVENTORY_ID,ALOHA_INVENTORY_ID,PUMPKIN_INVENTORY_ID,YULETIDE_INVENTORY_ID];
      
      public static const STATS_COUNTER_WORLD_SWITCH:String = "switch_farms";
      
      public static const INVALID_VISIT_ID:String = "";
      
      public static const FASTTRAVELSMALLICON:String = "fastTravelsmallIcon";
      
      public static const FASTTRAVELSMALLICON1:String = "fastTravelsmallIcon1";
      
      public static const FASTTRAVELSMALLICON2:String = "fastTravelsmallIcon2";
      
      public static const FASTTRAVELSMALLICON3:String = "fastTravelsmallIcon3";
      
      public static const FASTTRAVELSMALLICON4:String = "fastTravelsmallIcon4";
      
      public static const FASTTRAVELLARGEICON:String = "fastTravellargeIcon";
      
      public static const FASTTRAVELLARGEICON1:String = "fastTravellargeIcon1";
      
      public static const FASTTRAVELLARGEICON2:String = "fastTravellargeIcon2";
      
      public static const FASTTRAVELLARGEICON3:String = "fastTravellargeIcon3";
      
      public static const FASTTRAVELLARGEICON4:String = "fastTravellargeIcon4";
      
      public static const FASTTRAVELBUYICON:String = "fastTravelbuyIcon";
      
      public static const FASTTRAVELBUYICON1:String = "fastTravelbuyIcon1";
      
      public static const FASTTRAVELBUYICON2:String = "fastTravelbuyIcon2";
      
      public static const FASTTRAVELBUYICON3:String = "fastTravelbuyIcon3";
      
      public static const FASTTRAVELBUYICON4:String = "fastTravelbuyIcon4";
      
      public static const FASTTRAVELSEASON2ICON:String = "fastTravelseason2Icon";
      
      public static const CIPHER_PREFIX:String = "CM_SUGGEST_";
      
      public static const RECENT_VISIT_INTERVAL_HOURS:int = 144;
      
      private static const EXPERIMENT_HIDE_PPH_COUNTER_NAME:String = "fv_hide_pph_counter";
      
      public var visitingNotification:String = null;
      
      private var m_startTime:Number = 0;
      
      private var m_isVisiting:Boolean = false;
      
      private var m_isInStaticWorld:Boolean = false;
      
      private var m_isNPC:Boolean = false;
      
      private var m_visitId:String = "";
      
      private var m_farmId:String = "";
      
      private var m_worldStorageId:Number = -2;
      
      private var m_destination:String = "home";
      
      private var m_prevDestination:String = "";
      
      private var m_postInitDestination:String = "";
      
      private var m_postInitDestIsNPC:Boolean = false;
      
      private var m_worldSummaryData:Object = {};
      
      private var m_currentWorldPlotLimits:ExpansionPlotLimits = null;
      
      private var m_currentWorldType:String;
      
      private var m_currentWorldCurrency:String;
      
      private var m_currentWorldScoreId:String = "";
      
      private var m_currentWorldScore2Id:String = "";
      
      private var m_previousWorldType:String;
      
      private var m_currentWorldUniqueMarketCard:String;
      
      private var m_currentWorldUniqueMarketCard2:String;
      
      private var m_unlockedWorldTypes:Array = [];
      
      private var m_unlockedWorldContentLicenses:Object = {};
      
      private var m_worldInit:BaseWorldInit;
      
      private var m_oldWorldInit:BaseWorldInit;
      
      private var m_serverWorldTime:Number;
      
      private var m_lastWorldSyncTime:Number;
      
      private var m_travelAnimation:TravelAnimation;
      
      private var m_npcClickEnabled:Boolean = false;
      
      private var m_worldCache:WorldCache = new WorldCache();
      
      private var m_pendingWorldSwap:WorldSwapOptions = null;
      
      private var m_worldSpecificClassLocks:Array = null;
      
      private var m_isWorldLoading:Boolean = false;
      
      private var m_waitingSwapTransactions:Vector.<TFarmTransaction> = new Vector.<TFarmTransaction>();
      
      private var m_pendingInitialPreloadWorldTypes:Array;
      
      private var m_worldSwapStable:Boolean = true;
      
      private var m_PostswapFarmCallback:Function = null;
      
      public function WorldManager()
      {
         super();
      }
      
      public static function isInHidePPHCounterExperiment() : Boolean
      {
         var variant:Number = Global.experimentManager.getExperimentVariant(EXPERIMENT_HIDE_PPH_COUNTER_NAME);
         switch(variant)
         {
            case 3:
            case 4:
               return true;
            case 0:
            case 1:
            case 2:
         }
         return false;
      }
      
      public static function enablePPHLimiting() : void
      {
         Global.world.addEventListener(GameMode.EVENT_PPH_WARNING_PLOW,Global.worldManager.checkPPHLimitPlowEvent);
         Global.world.addEventListener(GameMode.EVENT_PPH_WARNING_TRACTOR,Global.worldManager.checkPPHLimitTractorEvent);
      }
      
      public static function disablePPHLimiting() : void
      {
         Global.world.removeEventListener(GameMode.EVENT_PPH_WARNING_PLOW,Global.worldManager.checkPPHLimitPlowEvent);
         Global.world.removeEventListener(GameMode.EVENT_PPH_WARNING_TRACTOR,Global.worldManager.checkPPHLimitTractorEvent);
      }
      
      public static function externalNeighborVisit(uid:*, depreciated:String) : void
      {
         if(Boolean(Global.worldManager) && Boolean(Global.player))
         {
            if(Global.player.uid == uid)
            {
               if(Global.worldManager.isVisiting())
               {
                  Global.worldManager.goHome();
               }
            }
            else
            {
               Global.worldManager.visitNeighbor(uid.toString());
            }
         }
      }
      
      public static function userActionLoadWorlds(params:Object = null) : void
      {
         Global.worldManager.conditionallyPreloadWorlds();
      }
      
      public static function isInPreCacheWorldExperiment() : Boolean
      {
         return Global.experimentManager.getExperimentVariant("fv_postinit_loadexpansion") >= 2;
      }
      
      public static function isWorldCacheEnabled() : Boolean
      {
         var optOutSeenFlag:String = Global.flashHotParams["CACHED_WORLD_OPTOUT_SEENFLAG"] as String;
         return isInPreCacheWorldExperiment() && (optOutSeenFlag == null || !Global.player.getSeenFlag(optOutSeenFlag));
      }
      
      public static function getWorldRequirementTypeFromWorldType(worldType:String) : String
      {
         var result:String = worldType;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
         if(expansionData)
         {
            result = expansionData.worldRequirementType;
         }
         return result;
      }
      
      public static function trackFastTravelStat(kingdom:String, phylum:String, worldType:String, family:String = "", genus:String = "") : void
      {
         FarmStatsManager.count("cached_world_travel",kingdom,phylum,worldType,family,genus);
      }
      
      public function get isWorldSwapStable() : Boolean
      {
         return this.m_worldSwapStable || !WorldManager.isInPreCacheWorldExperiment();
      }
      
      public function onTWorldLoadFinalCompleted() : void
      {
         this.m_worldSwapStable = true;
         if(this.m_PostswapFarmCallback != null)
         {
            this.m_PostswapFarmCallback();
         }
      }
      
      public function setWorldSummaryData(worldSummaryData:Object) : void
      {
         var worldType:String = null;
         for(worldType in worldSummaryData)
         {
            this.m_worldSummaryData[worldType] = new WorldSummary(worldType,worldSummaryData[worldType]);
         }
      }
      
      public function getWorldSummaryData() : Object
      {
         return this.m_worldSummaryData;
      }
      
      public function setCurrentWorldType(worldType:String) : void
      {
         this.m_previousWorldType = this.m_currentWorldType;
         this.m_currentWorldType = worldType;
         Global.player.currentStorageWorldId = this.getCurrentWorldStorageId();
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(this.m_currentWorldType);
         if(expansionData)
         {
            this.m_currentWorldPlotLimits = expansionData.plotLimits;
            this.m_currentWorldCurrency = expansionData.currency;
            if(expansionData.scoreId)
            {
               this.m_currentWorldScoreId = expansionData.scoreId;
            }
            else
            {
               this.m_currentWorldScoreId = "";
            }
            if(expansionData.score2Id)
            {
               this.m_currentWorldScore2Id = expansionData.score2Id;
            }
            else
            {
               this.m_currentWorldScore2Id = "";
            }
         }
         else
         {
            this.m_currentWorldPlotLimits = null;
            this.m_currentWorldCurrency = Currency.COINS;
            this.m_currentWorldScoreId = "";
         }
         this.m_currentWorldUniqueMarketCard = "";
         if(Global.worldSettingsManager.getConfigByWorld(worldType).marketCardUniqueBackground)
         {
            this.m_currentWorldUniqueMarketCard = Global.worldSettingsManager.getConfigByWorld(worldType).marketCardUniqueBackground;
         }
         this.m_currentWorldUniqueMarketCard2 = "";
         if(Global.worldSettingsManager.getConfigByWorld(worldType).marketCardUniqueBackground2)
         {
            this.m_currentWorldUniqueMarketCard2 = Global.worldSettingsManager.getConfigByWorld(worldType).marketCardUniqueBackground2;
         }
         this.m_worldSpecificClassLocks = this.initWorldSpecificClassLocks();
      }
      
      private function initWorldSpecificClassLocks() : Array
      {
         var hudSkinConfig:HUDSkinConfig = null;
         var worldConfig:Object = Global.worldSettingsManager.getConfigByWorld(this.currentWorldType);
         var classLocks:Array = null;
         if(Boolean(worldConfig) && Boolean(worldConfig.hudSkinConfig))
         {
            hudSkinConfig = worldConfig.hudSkinConfig as HUDSkinConfig;
            if(hudSkinConfig)
            {
               classLocks = hudSkinConfig.worldSpecificMarketClassLock;
            }
         }
         return classLocks;
      }
      
      public function get worldSpecificClassLocks() : Array
      {
         return this.m_worldSpecificClassLocks;
      }
      
      public function get currentWorldType() : String
      {
         return this.m_currentWorldType;
      }
      
      public function get currentWorldCurrency() : String
      {
         return this.m_currentWorldCurrency;
      }
      
      public function get currentWorldScoreId() : String
      {
         return this.m_currentWorldScoreId;
      }
      
      public function get currentWorldScore2Id() : String
      {
         return this.m_currentWorldScore2Id;
      }
      
      public function get currentWorldHasPlotLimits() : Boolean
      {
         return this.m_currentWorldPlotLimits != null;
      }
      
      public function hidePPHCounter(terrainCode:int) : Boolean
      {
         var hidePPhCtr:Boolean = false;
         if(isInHidePPHCounterExperiment() && Global.worldManager.currentWorldHasPlotLimits && Global.world.getNumPlots(terrainCode) < this.getMaximumPlotsAllowed(terrainCode) - 5)
         {
            return true;
         }
         return false;
      }
      
      public function get currentWorldUniqueMarketCard() : String
      {
         return this.m_currentWorldUniqueMarketCard;
      }
      
      public function get currentWorldUniqueMarketCard2() : String
      {
         return this.m_currentWorldUniqueMarketCard2;
      }
      
      public function get previousWorldType() : String
      {
         return this.m_previousWorldType;
      }
      
      public function getCurrentPlotLimit(terrainCode:int) : int
      {
         var result:int = -1;
         if(this.m_currentWorldPlotLimits)
         {
            result = this.m_currentWorldPlotLimits.getPlotLimitByTerrainCode(String(Global.world.getGridWidth()),terrainCode);
         }
         return result;
      }
      
      public function getLimitGroupIndexByLimitGroupName(terrainLimitGroupName:String) : int
      {
         var result:int = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_INDEX;
         if(this.m_currentWorldPlotLimits)
         {
            result = this.m_currentWorldPlotLimits.getLimitGroupIndexByLimitGroupName(terrainLimitGroupName);
         }
         return result;
      }
      
      public function getLimitGroupNameByLimitGroupIndex(terrainLimitGroupIndex:int) : String
      {
         var result:String = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_NAME;
         if(this.m_currentWorldPlotLimits)
         {
            result = this.m_currentWorldPlotLimits.getLimitGroupNameByLimitGroupIndex(terrainLimitGroupIndex);
         }
         return result;
      }
      
      public function getLimitGroupIndexByTerrainName(terrainName:String) : int
      {
         var result:int = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_INDEX;
         if(this.m_currentWorldPlotLimits)
         {
            result = this.m_currentWorldPlotLimits.getLimitGroupIndexByTerrainName(terrainName);
         }
         return result;
      }
      
      public function getLimitGroupIndexByTerrainCode(terrainCode:int) : int
      {
         var result:int = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_INDEX;
         if(this.m_currentWorldPlotLimits)
         {
            result = this.m_currentWorldPlotLimits.getLimitGroupIndexByTerrainCode(terrainCode);
         }
         return result;
      }
      
      public function getLimitGroupNameByTerrainName(terrainName:String) : String
      {
         var result:String = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_NAME;
         if(this.m_currentWorldPlotLimits)
         {
            result = this.m_currentWorldPlotLimits.getLimitGroupNameByTerrainName(terrainName);
         }
         return result;
      }
      
      public function getLimitGroupNameByTerrainCode(terrainCode:int) : String
      {
         var result:String = ExpansionPlotLimits.DEFAULT_PLOT_LIMIT_GROUP_NAME;
         if(this.m_currentWorldPlotLimits)
         {
            result = this.m_currentWorldPlotLimits.getLimitGroupNameByTerrainCode(terrainCode);
         }
         return result;
      }
      
      public function convertTerrainCodesToCodesByLimitIndex(arrTerrainCodes:Array) : Array
      {
         var code:int = 0;
         var index:int = 0;
         var result:Array = new Array();
         for each(code in arrTerrainCodes)
         {
            index = this.getLimitGroupIndexByTerrainCode(code);
            result[index] = code;
         }
         return result;
      }
      
      public function convertTerrainCodesToABCArrayOfLimitNames(arrTerrainCodes:Array) : Array
      {
         var code:int = 0;
         var name:String = null;
         var result:Array = new Array();
         for each(code in arrTerrainCodes)
         {
            name = this.getLimitGroupNameByTerrainCode(code);
            result[name] = name;
         }
         result.sort();
         return result;
      }
      
      public function convertTerrainCodesToABCStringOfLimitNames(arrTerrainCodes:Array, separator:String = "_") : String
      {
         var limitGroupName:String = null;
         var result:String = "";
         var abcLimitGroupNames:Array = Global.worldManager.convertTerrainCodesToABCArrayOfLimitNames(arrTerrainCodes);
         for each(limitGroupName in abcLimitGroupNames)
         {
            if(result != "")
            {
               result += separator;
            }
            result += limitGroupName;
         }
         return result;
      }
      
      public function isAtMaxExpansion() : Boolean
      {
         var result:Boolean = true;
         if(this.getNextExpansion())
         {
            result = false;
         }
         return result;
      }
      
      public function getNextExpansion(forceCash:Boolean = false) : ChangeFarmItem
      {
         var expansion:ChangeFarmItem = null;
         var expansionsLength:int = 0;
         var expansionIndex:int = 0;
         var passCashExpansionCheck:Boolean = false;
         var gridX:int = Global.world.getGridWidth();
         var gridY:int = Global.world.getGridHeight();
         var nextExpansion:ChangeFarmItem = null;
         var expansionItems:Array = Global.farmGameSettingsManager.getExpansionFarmItemsForCurrentWorld();
         var squaresExistInItems:Boolean = this.checkIfSquaresExist(expansionItems);
         if(squaresExistInItems)
         {
            expansionItems.sortOn("squares",Array.NUMERIC);
            expansionsLength = int(expansionItems.length);
            for(expansionIndex = 0; expansionIndex < expansionsLength; expansionIndex++)
            {
               expansion = expansionItems[expansionIndex];
               passCashExpansionCheck = expansion.realCashCost > 0 || !forceCash;
               if((expansion.squares > gridX || expansion.squares > gridY) && passCashExpansionCheck)
               {
                  nextExpansion = expansion;
                  break;
               }
            }
         }
         return nextExpansion;
      }
      
      private function checkIfSquaresExist(expansionItems:Array) : Boolean
      {
         var expansionItem:FarmItem = null;
         var result:Boolean = true;
         for each(expansionItem in expansionItems)
         {
            if(!expansionItem.hasOwnProperty("squares"))
            {
               result = false;
               break;
            }
         }
         return result;
      }
      
      public function getAllLargerExpansions() : Array
      {
         var gridX:int = Global.world.getGridWidth();
         var gridY:int = Global.world.getGridHeight();
         var expansionsLarger:Array = [];
         var expansionItems:Array = Global.farmGameSettingsManager.getExpansionFarmItemsForCurrentWorld();
         expansionItems.sortOn("squares",Array.NUMERIC);
         var changeFarmItem:ChangeFarmItem = null;
         for(var expansionIndex:int = 0; expansionIndex < expansionItems.length; expansionIndex++)
         {
            changeFarmItem = expansionItems[expansionIndex];
            if(changeFarmItem.squares > gridX && changeFarmItem.squares > gridY && changeFarmItem.isVisible)
            {
               expansionsLarger.push(expansionItems[expansionIndex]);
            }
         }
         return expansionsLarger;
      }
      
      public function getNextExpansionPlotLimit(terrainCode:int) : int
      {
         var nextExpansion:ChangeFarmItem = this.getNextExpansion();
         var nextPlotLimit:int = 0;
         if(Boolean(nextExpansion) && Boolean(this.m_currentWorldPlotLimits))
         {
            nextPlotLimit = this.m_currentWorldPlotLimits.getPlotLimitByTerrainCode(nextExpansion.squares as String,terrainCode);
         }
         return nextPlotLimit;
      }
      
      private function shouldShowPPHLimitWarning() : Boolean
      {
         var result:Boolean = false;
         if(!Global.player.getSeenFlag(PPHLimitWindow.PPH_LIMIT_WARNING_PLOW_DIALOG) && !Global.player.getSeenFlag(PPHLimitWindow.PPH_LIMIT_WARNING_TRACTOR_DIALOG) && !Global.player.getSeenFlag(PPHLimitWindow.PPH_LIMIT_REACHED_DIALOG))
         {
            result = true;
         }
         return result;
      }
      
      public function checkPPHLimitPlowEvent(e:Event) : void
      {
         if(this.shouldShowPPHLimitWarning())
         {
            UI.displayPopup(new PPHLimitWindow(PPHLimitWindow.PPH_LIMIT_WARNING_TYPE));
            Global.player.setSeenFlag(PPHLimitWindow.PPH_LIMIT_WARNING_PLOW_DIALOG);
         }
      }
      
      public function checkPPHLimitTractorEvent(e:Event) : void
      {
         if(this.shouldShowPPHLimitWarning())
         {
            UI.displayPopup(new PPHLimitWindow(PPHLimitWindow.PPH_LIMIT_WARNING_TYPE));
            Global.player.setSeenFlag(PPHLimitWindow.PPH_LIMIT_WARNING_TRACTOR_DIALOG);
         }
      }
      
      public function checkPPHLimitReached(terrainCode:int) : Boolean
      {
         var result:Boolean = false;
         if(!this.getRemainingPlotsAllowed(terrainCode) && !Global.player.getSeenFlag(PPHLimitWindow.PPH_LIMIT_REACHED_DIALOG))
         {
            UI.displayPopup(new PPHLimitWindow(PPHLimitWindow.PPH_LIMIT_REACHED_TYPE,terrainCode));
            result = true;
         }
         return result;
      }
      
      public function getMaximumPlotsAllowed(terrainCode:int) : int
      {
         var maxNumPlots:int = Global.world.maxNumObjects;
         if(this.m_currentWorldPlotLimits != null)
         {
            maxNumPlots = this.m_currentWorldPlotLimits.getPlotLimitByTerrainCode(Global.world.getGridWidth().toString(),terrainCode);
         }
         return maxNumPlots;
      }
      
      public function getCurrentWorldPlotLimitsData() : Array
      {
         var result:Array = null;
         if(this.m_currentWorldPlotLimits)
         {
            result = this.m_currentWorldPlotLimits.getCurrentWorldPlotLimitsData();
         }
         return result;
      }
      
      public function getPlotLimitsForSquares(squares:String) : Array
      {
         var result:Array = null;
         if(this.m_currentWorldPlotLimits != null)
         {
            result = this.m_currentWorldPlotLimits.getPlotLimitsForSquares(squares);
         }
         return result;
      }
      
      public function getSmallestFarmSizeInSquares() : String
      {
         var resultString:String = null;
         if(this.m_currentWorldPlotLimits != null)
         {
            resultString = this.m_currentWorldPlotLimits.getSmallestFarmSizeInSquares();
         }
         return resultString;
      }
      
      public function getRemainingPlotsAllowed(terrainCode:int) : int
      {
         return this.getMaximumPlotsAllowed(terrainCode) - Global.world.getNumPlots(terrainCode);
      }
      
      public function isVisiting() : Boolean
      {
         return this.m_isVisiting || Boolean(this.m_postInitDestination) && this.m_postInitDestination.length > 1;
      }
      
      public function isVisitingNPC() : Boolean
      {
         return this.isVisiting() && this.m_isNPC;
      }
      
      public function isVisitingNeighbor() : Boolean
      {
         return (this.m_isVisiting || this.hasPostInitDestination()) && !this.m_isNPC;
      }
      
      public function isVisitingCommunityNeighbor() : Boolean
      {
         return this.isVisitingNeighbor() && this.m_visitId.substr(0,CIPHER_PREFIX.length) == CIPHER_PREFIX;
      }
      
      public function isInStaticWorld() : Boolean
      {
         return this.m_isInStaticWorld;
      }
      
      public function isVisitingNPCOfType(type:String = "normal") : Boolean
      {
         var npcData:NPCConfigData = null;
         var result:Boolean = false;
         if(this.isVisiting() && this.m_isNPC)
         {
            npcData = NPCManager.getInstance().getNPC(this.m_visitId);
            if(Boolean(npcData) && npcData.type == type)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function canPostVisitFeed() : Boolean
      {
         return Boolean(this.getVisiting()) && !this.isVisitingCommunityNeighbor();
      }
      
      public function getVisiting() : String
      {
         return this.m_visitId;
      }
      
      public function getVisitName(firstNameOnly:Boolean = false) : String
      {
         return Global.friendManager.getFriendName(this.getVisiting(),firstNameOnly);
      }
      
      public function getVisitGender() : String
      {
         return Global.friendManager.getFriendGender(this.getVisiting());
      }
      
      public function visitNeighbor(uid:String, sendImmediately:Boolean = true) : void
      {
         this.m_prevDestination = this.m_destination;
         this.m_destination = "neighbor";
         this.m_isVisiting = true;
         this.m_isNPC = false;
         this.m_visitId = uid;
         this.m_farmId = "";
         this.m_worldInit = new NeighborWorldInit(uid);
         VisitorManager.getInstance().setVisitMode(VisitorManager.VISIT_MODE_FRIEND);
         NPCManager.getInstance().isVisitingNPC = false;
         this.preWorldLoad();
         TransactionManager.addTransaction(new TLoadNeighbor(this.m_visitId.toString(),this),sendImmediately);
      }
      
      public function visitNPC(npcid:String) : void
      {
         this.m_prevDestination = this.m_destination;
         this.m_destination = "npc:" + npcid;
         this.m_isVisiting = true;
         this.m_isNPC = true;
         this.m_visitId = npcid;
         this.m_farmId = "";
         this.m_worldInit = new NPCWorldInit(npcid);
         VisitorManager.getInstance().setVisitMode(VisitorManager.VISIT_MODE_NPC);
         this.preWorldLoad();
         TransactionManager.addTransaction(new TLoadNPC(this.m_visitId.toString(),this),true);
      }
      
      public function visitStaticFarm(worldType:String) : void
      {
         this.m_isInStaticWorld = true;
         this.m_prevDestination = this.m_destination;
         this.m_destination = "staticFarm:" + worldType;
         this.m_worldInit = new StaticWorldInit();
         this.preWorldLoad();
         this.startTravelAnimation(worldType);
         TransactionManager.addTransaction(new TLoadStaticWorld(worldType.toString(),this),true);
      }
      
      public function goHome() : void
      {
         var msg:String = null;
         if(Boolean(Global.player) && Global.player.uid != "0")
         {
            this.m_isVisiting = false;
            this.m_isInStaticWorld = false;
            this.m_isNPC = false;
            this.m_prevDestination = this.m_destination;
            this.m_destination = "home";
            this.m_visitId = INVALID_VISIT_ID;
            this.m_farmId = "";
            NPCManager.getInstance().isVisitingNPC = false;
            this.m_worldInit = new HomeWorldInit();
            this.preWorldLoad();
            trackFastTravelStat("startLoad","transactionLoad",this.m_farmId);
            TransactionManager.addTransaction(new TWorldLoad("",this),true);
         }
         else if(Config.DEBUG_MODE)
         {
            if(Global.player)
            {
               UI.displayMessage("Error, Player id = " + Global.player.uid,0,FarmGameUtil.redirectHome);
            }
            else
            {
               UI.displayMessage("Error, Player is null",0,FarmGameUtil.redirectHome);
            }
         }
         else
         {
            TransactionManager.lastError = FarmGame.CLIENT_SIDE_OOS_ERROR_CODE;
            msg = "Client Side OOS: ";
            if(Global.player)
            {
               msg += "Player Id " + Global.player.uid + " is Invalid";
            }
            else
            {
               msg += "Player is null";
            }
            TransactionManager.lastMsg = msg;
            TransactionManager.lastFunc = "WorldManager.goHome";
            FarmGameUtil.redirectHome();
         }
      }
      
      public function setStateOnFailedNeighborVisit() : void
      {
         this.m_isVisiting = false;
         this.m_isInStaticWorld = false;
         this.m_isNPC = false;
         this.m_destination = "home";
         this.m_visitId = INVALID_VISIT_ID;
         this.m_farmId = "";
         NPCManager.getInstance().isVisitingNPC = false;
         this.m_worldInit = new HomeWorldInit();
         if(this.m_prevDestination != "home")
         {
            this.m_prevDestination = this.m_destination;
            this.preWorldLoad();
            trackFastTravelStat("startLoad","transactionLoad",this.m_farmId);
            TransactionManager.addTransaction(new TWorldLoad("",this),true);
         }
         else
         {
            this.updateGamePreTransaction();
            this.unfreezeWorld();
         }
      }
      
      public function showTravelConfirmation(worldType:String) : void
      {
         if(this.isWorldSwapStable)
         {
            if(TravelNameDisplay.showImprovedTravelDialog() && Boolean(Global.hud.travelNameDisplay))
            {
               Global.hud.travelNameDisplay.showNewTravelWindow();
            }
            else
            {
               this.showTravelFreezeConfirmation(worldType);
            }
         }
      }
      
      public function showTravelFreezeConfirmation(worldType:String) : void
      {
         var worldFreezeSelect:FarmDynamicDialog = FarmDynamicDialog.createDialog("travelFreezeSelect",TravelOptionsDialog);
         worldFreezeSelect.addImport(TravelOptionsDialog.IMPORT_DESTINATION_WORLD_TYPE,worldType);
         worldFreezeSelect.addImport(TravelOptionsDialog.IMPORT_TRAVEL_CALLBACK,this.swapFarm);
         worldFreezeSelect.setup();
         worldFreezeSelect.show();
      }
      
      public function swapFarmAndPanToItem(worldType:String, shouldFreezeFarm:Boolean = true, callback:Function = null) : void
      {
         this.m_PostswapFarmCallback = callback;
         this.swapFarm(worldType,shouldFreezeFarm);
      }
      
      public function loadNextSeason(worldType:String) : void
      {
         var accessInfo:ExpansionAccess = null;
         var rewards:Vector.<Object> = null;
         var currentSeasonID:int = 0;
         var nextseasonID:int = 0;
         WorldSeasonsManager.getInstance().showSeasonLoading(worldType);
         var data:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
         if(Boolean(data) && WorldSeasonsManager.getInstance().isEAUser(worldType))
         {
            accessInfo = data.getAccessOfType("earlyAccess");
            if(accessInfo)
            {
               rewards = accessInfo.rewards;
               if(WorldSeasonsManager.getInstance().hasSeasons(worldType))
               {
                  currentSeasonID = WorldSeasonsManager.getInstance().getCurrentSeason(worldType);
                  nextseasonID = WorldSeasonsManager.getInstance().getNextSeasonId(currentSeasonID);
                  UserRewardUtil.grantSeasonRewards(rewards,nextseasonID);
               }
            }
         }
         TransactionManager.addTransaction(new TWorldLoad(worldType,this,true,true,true),true);
         TransactionManager.sendAllTransactions(true);
      }
      
      public function swapFarm(worldType:String, shouldFreezeFarm:Boolean = true, nextSeasonUnlock:Boolean = false) : void
      {
         var priorWorldType:String = null;
         var worldData:Object = null;
         try
         {
            if(this.hasUnlockedWorld(worldType) && this.isWorldSwapStable)
            {
               priorWorldType = this.currentWorldType;
               this.m_isVisiting = false;
               this.m_isInStaticWorld = false;
               this.m_isNPC = false;
               this.m_destination = "swap:" + worldType;
               this.m_visitId = INVALID_VISIT_ID;
               this.m_farmId = worldType;
               this.m_worldInit = HomeWorldInit.createWorldInitByWorldType(worldType);
               MarketWindow.resetPreviousSelections();
               CraftshopWindow.resetPreviousSelections();
               Global.farmGameSettingsManager.clearFriendlyNameArray();
               this.preWorldLoad();
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SUPRESS_QUEST_POP_ON_WORLD_SWITCH) == 0)
               {
                  FarmQuestManager.getInstance().showInitQuestsImmediately = true;
               }
               if(!isWorldCacheEnabled())
               {
                  trackFastTravelStat("startLoad","transactionLoad",worldType);
                  this.startTravelAnimation(worldType);
                  this.doTransactionLoad(worldType,shouldFreezeFarm,nextSeasonUnlock);
               }
               else
               {
                  worldData = this.m_worldCache.get(worldType);
                  if(worldData)
                  {
                     trackFastTravelStat("startLoad","fromCache",worldType,"noPending");
                     this.loadWorldFromCache(worldType,worldData);
                  }
                  else
                  {
                     this.startTravelAnimation(worldType);
                     if(this.m_worldCache.isPeekInFlight(worldType))
                     {
                        trackFastTravelStat("startLoad","fromCache",worldType,"pending");
                        this.m_pendingWorldSwap = new WorldSwapOptions(worldType,priorWorldType,shouldFreezeFarm);
                        TransactionManager.sendAllTransactions(true);
                     }
                     else
                     {
                        trackFastTravelStat("startLoad","transactionLoad",worldType);
                        this.doTransactionLoad(worldType,shouldFreezeFarm,nextSeasonUnlock);
                        this.addWorldPeek(priorWorldType);
                     }
                  }
               }
            }
         }
         catch(error:Error)
         {
            trackFastTravelStat("clientException","swapFarm",worldType,error.message);
         }
      }
      
      public function ReLoadFarm(worldType:String, shouldFreezeFarm:Boolean = true) : void
      {
         this.doTransactionLoad(worldType,shouldFreezeFarm);
      }
      
      private function doTransactionLoad(worldType:String, shouldFreezeFarm:Boolean, nextSeasonUnlock:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TWorldLoad(worldType,this,true,shouldFreezeFarm,nextSeasonUnlock),true);
         TransactionManager.sendAllTransactions(true);
      }
      
      private function addWorldPeek(worldType:String) : void
      {
         this.m_worldCache.setPeekInFlight(worldType);
         trackFastTravelStat("startPreload","",worldType);
         TransactionManager.addTransaction(new TWorldPeek(worldType,this));
      }
      
      private function preWorldLoad() : void
      {
         this.m_startTime = GlobalEngine.currentTime;
         if(StencilManager.instance())
         {
            StencilManager.instance().clearAllStencilEffect();
         }
         this.updateGamePreTransaction();
         FreezeManager.freezeAll(false,0.5);
         this.m_isWorldLoading = true;
      }
      
      public function worldRecieved() : void
      {
         GlobalEngine.info("WorldManager","tWorldLoad completed :" + this.m_destination + " - " + (GlobalEngine.currentTime - this.m_startTime).toString());
         LoadingManager.getInstance().addEventListener(LoaderEvent.ALL_HIGH_PRIORITY_LOADED,this.onAssetLoadingComplete);
      }
      
      public function worldLoaded(result:Object, fromCache:Boolean = false) : void
      {
         try
         {
            this.updateGamePostTransaction(result,fromCache);
            GlobalEngine.info("WorldManager","tWorldLoad popupDropped :" + this.m_destination + " - " + (GlobalEngine.currentTime - this.m_startTime).toString());
            ExternalUtil.instance.call("onWorldLoad");
            dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.WORLD_LOADED));
            this.m_isWorldLoading = false;
            Global.ui.m_friendBar.refreshFriendSlots();
            if(!fromCache)
            {
               trackFastTravelStat("endLoad","transactionLoad",this.m_farmId,"success");
            }
         }
         catch(error:Error)
         {
            ErrorManager.addError("World Load Failed for world" + m_farmId + ": " + error.message);
            trackFastTravelStat("clientException","worldLoaded",m_farmId,error.message);
         }
      }
      
      public function onFault(errorType:int, errorData:String) : void
      {
         FreezeManager.thaw();
         FarmStatsManager.d1drop("tWorldLoad failed",GlobalEngine.currentTime - this.m_startTime,this.m_destination);
         if(LoadingManager.getInstance().hasEventListener(LoaderEvent.ALL_HIGH_PRIORITY_LOADED))
         {
            LoadingManager.getInstance().removeEventListener(LoaderEvent.ALL_HIGH_PRIORITY_LOADED,this.onAssetLoadingComplete);
         }
         UI.displayMessage(ZLocUtils.t("FarmGame","UnableToLoadFarm"),GenericPopup.TYPE_OK,this.onErrorPopupClose);
      }
      
      private function onErrorPopupClose(event:GenericPopupEvent) : void
      {
         FarmGameUtil.redirectHome();
      }
      
      public function getCurrentWorldStorageId() : Number
      {
         return this.getStorageIdByWorld(this.m_currentWorldType);
      }
      
      public function getStorageIdByWorld(worldType:String) : Number
      {
         var result:Number = WorldManager.HOME_INVENTORY_ID;
         var currentWorldSummary:WorldSummary = null;
         if(this.m_worldSummaryData[worldType])
         {
            currentWorldSummary = this.m_worldSummaryData[worldType];
         }
         if(currentWorldSummary)
         {
            result = currentWorldSummary.getStorageId();
         }
         return result;
      }
      
      private function onAssetLoadingComplete(event:Event) : void
      {
         LoadingManager.getInstance().removeEventListener(LoaderEvent.ALL_HIGH_PRIORITY_LOADED,this.onAssetLoadingComplete);
         GlobalEngine.info("WorldManager","tWorldLoad assetsLoaded :" + this.m_destination + " - " + (GlobalEngine.currentTime - this.m_startTime).toString());
      }
      
      private function updateGamePreTransaction() : void
      {
         if(this.visitingNotification != null)
         {
            GlobalEngine.socialNetwork.sendNotification(this.visitingNotification,[],[this.m_visitId]);
            this.visitingNotification = null;
         }
         UI.stopPopups(true);
         UI.clearPopupQueue();
         IdleTaskQueue.getInstance().clearQueue();
         UI.closeMarketDialog();
         DLManager.lockLoading();
         if(Global.selectedAvatar)
         {
            Global.selectedAvatar.stopWalking();
            Global.selectedAvatar.getStateMachine().removeAllStates();
         }
         if(Global.hud != null)
         {
            Global.hud.setVisiting(this.m_isVisiting);
         }
         if(Global.ui)
         {
            Global.ui.visit = this.m_isVisiting;
         }
      }
      
      private function updateGamePostTransaction(resultData:Object, fromCache:Boolean = false) : void
      {
         var crossPromoManager:CrossPromoManager = null;
         if(null != this.m_oldWorldInit)
         {
            this.m_oldWorldInit.onLeaveWorld(this.m_isVisiting);
         }
         this.m_oldWorldInit = this.m_worldInit;
         if(!fromCache)
         {
            this.m_worldInit.resyncToBackendData(resultData);
         }
         this.m_worldInit.onEnterWorld(resultData);
         if(!this.isVisiting())
         {
            VisitorManager.getInstance().placeNeighborVisitAvatars();
         }
         this.stopTravelAnimation();
         if(!(this.m_worldInit is NPCWorldInit))
         {
            crossPromoManager = CrossPromoManager.getInstance();
            crossPromoManager.showOutOfBoundPromo();
         }
         if(!this.isInStaticWorld() && Global.worldManager.currentWorldType != HangingGardensManager.HANGING_GARDENS)
         {
            UnwitherUtils.showUnwitherIconIfNecessary();
            InstagrowUtils.conditionallyShowInstagrowIcon();
            if(Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_AVALON)
            {
               MapTriggerManager.getInstance().createMapTriggers();
            }
            LonelyAnimalIdleTask.conditionallyRedrawLonelyAnimal();
            TaskListManager.getInstance().showHUDIcon();
            BeatlimboExpansionManager.instance.init();
            BeatmidwestExpansionManager.instance.init();
            BeatmountExpansionManager.instance.init();
            BeatJungleExpansionManager.instance.init();
            BeatIndiaExpansionManager.instance.init();
            BeatWinterExpansionManager.instance.init();
            BeatJadeFallsManager.instance.init();
            BeatHauntedHallowManager.instance.init();
            BeatHolidayTownManager.instance.init();
            BeatHawaiiManager.instance.init();
            BeatEnchantedGlenManager.instance.init();
            BeatAtlantisManager.instance.init();
            BeatAustraliaManager.instance.init();
            BeatSpaceManager.instance.init();
            BeatCandyManager.instance.init();
            BeatFantasyForestManager.instance.init();
            BeatHolidayLightsManager.instance.init();
            BeatRainForestManager.instance.init();
            BeatOzManager.instance.init();
            BeatMediterraneanManager.instance.init();
            BeatOasisManager.instance.init();
            BeatStorybookManager.instance.init();
            BeatSleepyhollowManager.instance.init();
            BeatToylandManager.instance.init();
            BeatAvalonManager.instance.init();
            BeatKingdomManager.instance.init();
            BeatWildWestManager.instance.init();
            BeatTreasureTidesManager.instance.init();
            BeatAfricaManager.instance.init();
            BeatTransylvaniaManager.instance.init();
            BeatunderwaterExpansionManager.instance.init();
            BeatturtleislandExpansionManager.instance.init();
            BeatdreamworldExpansionManager.instance.init();
            BeatanglofrenchExpansionManager.instance.init();
            BeatbrazilExpansionManager.instance.init();
            BeathalloweenusaExpansionManager.instance.init();
            BeatwhitewinterExpansionManager.instance.init();
            BeattuscanyExpansionManager.instance.init();
            BeatdragonvalleyExpansionManager.instance.init();
            BeatcaribbeanExpansionManager.instance.init();
            BeatrussiaExpansionManager.instance.init();
            BeatrussiaExpansion_aManager.instance.init();
            BeatnewfrontierExpansionManager.instance.init();
            BeatisraelExpansionManager.instance.init();
            BeathalloweenmadExpansionManager.instance.init();
            BeatwinternordExpansionManager.instance.init();
            BeattwentiesExpansionManager.instance.init();
            BeatAlaskaExpansionManager.instance.init();
            BeatcasablancaExpansionManager.instance.init();
            BeatsouthindiaExpansionManager.instance.init();
            BeatCocolandExpansionManager.instance.init();
            BeatIrelandExpansionManager.instance.init();
            BeatSpookOWeenExpansionManager.instance.init();
            BeatSecretExpansionManager.instance.init();
            BeatValleyExpansionManager.instance.init();
            BeatTrailsExpansionManager.instance.init();
            BeatBoraExpansionManager.instance.init();
            BeatBloomExpansionManager.instance.init();
            BeatMapleExpansionManager.instance.init();
            BeatCoastalExpansionManager.instance.init();
            BeatSoireeExpansionManager.instance.init();
         }
         if(!ReturningUserExperienceManager.isInExperiment() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EXPANSION_PROMPT_IDLE) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            IdleTaskQueue.getInstance().addTask(new ExpansionPromptIdleTask());
         }
      }
      
      public function visitAfterInit(uid:String, isNPC:Boolean = false) : void
      {
         this.m_postInitDestination = uid;
         this.m_postInitDestIsNPC = isNPC;
      }
      
      private function hasPostInitDestination() : Boolean
      {
         return Boolean(this.m_postInitDestination) && this.m_postInitDestination.length > 1;
      }
      
      public function onUserInit(resultData:Object, shouldLoadWorld:Boolean = true) : void
      {
         var userData:Object = null;
         var worldData:Object = null;
         var expansionData:ExpansionData = null;
         if(resultData.userInfo)
         {
            userData = resultData.userInfo;
            if(userData.worldSummaryData)
            {
               this.setWorldSummaryData(userData.worldSummaryData);
            }
            if(userData.currentWorldType)
            {
               this.setCurrentWorldType(userData.currentWorldType);
            }
            else
            {
               this.setCurrentWorldType(WorldsConstants.WORLD_ID_HOME);
            }
            if(userData.unlockedWorldTypes)
            {
               this.unlockedWorldTypes = userData.unlockedWorldTypes as Array;
            }
            if(userData.unlockedWorldContentLicenses)
            {
               this.unlockedWorldContentLicenses = userData.unlockedWorldContentLicenses;
            }
         }
         if(this.isVisiting() && this.hasPostInitDestination())
         {
            if(this.m_postInitDestIsNPC)
            {
               this.visitNPC(this.m_postInitDestination);
            }
            else
            {
               this.visitNeighbor(this.m_postInitDestination,true);
            }
            this.m_postInitDestination = INVALID_VISIT_ID;
         }
         else
         {
            if(shouldLoadWorld && Boolean(resultData.world))
            {
               worldData = resultData.world;
               if(Boolean(worldData.objectsArray) && worldData.objectsArray.length > 0)
               {
                  Global.world.loadObject(worldData);
                  expansionData = Global.farmGameSettingsManager.getExpansionData(this.currentWorldType);
                  this.m_currentWorldPlotLimits = expansionData ? expansionData.plotLimits : null;
               }
            }
            this.m_worldInit = HomeWorldInit.createWorldInitByWorldType(this.currentWorldType);
            this.m_oldWorldInit = this.m_worldInit;
            if(Boolean(resultData.userInfo) && Boolean(resultData.craftingState))
            {
               this.m_worldInit.onEnterWorld({
                  "user":resultData.userInfo,
                  "craftingState":resultData.craftingState
               });
               this.m_worldInit.resyncToBackendData(resultData);
            }
         }
      }
      
      public function syncWorldTime(newWorldTime:Number) : void
      {
         if(this.isWorldSwapStable)
         {
            this.m_lastWorldSyncTime = getTimer();
            this.m_serverWorldTime = newWorldTime;
         }
      }
      
      public function get worldTime() : Number
      {
         return getTimer() - this.m_lastWorldSyncTime + this.m_serverWorldTime * 1000;
      }
      
      public function getWorldFriendlyName(worldType:String = null) : String
      {
         var data:ExpansionData = null;
         if(worldType == null)
         {
            worldType = this.currentWorldType;
         }
         var result:String = worldType;
         if(worldType == WorldsConstants.WORLD_ID_HOME)
         {
            result = ZLocUtils.t("FarmGame","HomeWorldName");
         }
         else
         {
            data = Global.farmGameSettingsManager.getExpansionData(worldType);
            if(data)
            {
               result = data.friendlyName;
            }
         }
         return result;
      }
      
      public function getAvailableTravelWorlds() : Array
      {
         var worldType:String = null;
         var expansionData:ExpansionData = null;
         var allUnlockedWorlds:Array = this.unlockedWorldTypes;
         var availableWorlds:Array = new Array();
         for each(worldType in allUnlockedWorlds)
         {
            if(worldType != this.currentWorldType)
            {
               expansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
               if(!expansionData || expansionData.showInTravelDialog)
               {
                  availableWorlds.push(worldType);
               }
            }
         }
         return availableWorlds;
      }
      
      private function startTravelAnimation(worldType:String) : void
      {
         this.m_travelAnimation = new TravelAnimation(this.unfreezeWorld,this.currentWorldType,worldType);
      }
      
      private function stopTravelAnimation() : void
      {
         if(this.m_travelAnimation)
         {
            this.m_travelAnimation.stopTravelAnimation();
            this.m_travelAnimation = null;
         }
         else
         {
            this.unfreezeWorld();
         }
      }
      
      private function unfreezeWorld() : void
      {
         FreezeManager.thaw();
         Global.worldSettingsManager.zoomCenterViewportPostWorldLoad();
         UI.stopPopups(false);
      }
      
      public function set unlockedWorldTypes(worldTypes:Array) : void
      {
         this.m_unlockedWorldTypes = worldTypes;
      }
      
      public function get unlockedWorldTypes() : Array
      {
         return this.m_unlockedWorldTypes;
      }
      
      public function hasUnlockedWorld(worldType:String) : Boolean
      {
         var result:Boolean = false;
         var worldTypeIdx:int = this.unlockedWorldTypes.indexOf(worldType);
         if(worldTypeIdx >= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function setWorldUnlocked(worldType:String) : void
      {
         if(!this.hasUnlockedWorld(worldType) && this.isInExperiment(worldType))
         {
            this.unlockedWorldTypes.push(worldType);
            if(this.getAvailableTravelWorlds().length > 0)
            {
               Global.hud.showTravelNameDisplay();
            }
         }
      }
      
      public function isInExperiment(worldType:String) : Boolean
      {
         var key:String = "";
         switch(worldType)
         {
            case WorldsConstants.WORLD_ID_ENGLAND:
               return true;
            case WorldsConstants.WORLD_ID_FISHERMAN:
               return true;
            case WorldsConstants.WORLD_ID_WINTER_WONDERLAND:
               return true;
            case WorldsConstants.WORLD_ID_HAWAII:
               return true;
            case WorldsConstants.WORLD_ID_ASIA:
               key = Experiments.EXPERIMENT_ASIA;
               break;
            case WorldsConstants.WORLD_ID_ANGLER:
               key = Experiments.EXPERIMENT_FLASH_FISHING_DERBY;
               break;
            case WorldsConstants.WORLD_ID_HALLOW:
               key = Experiments.EXPERIMENT_HALLOW;
               break;
            case WorldsConstants.WORLD_ID_HTOWN:
               key = Experiments.EXPERIMENT_HTOWN;
               break;
            case WorldsConstants.WORLD_ID_MEADOWS:
               key = Experiments.EXPERIMENT_MEADOWS;
               break;
            case WorldsConstants.WORLD_ID_GLEN:
               key = Experiments.EXPERIMENT_GLEN;
               break;
            case WorldsConstants.WORLD_ID_ATLANTIS:
               key = Experiments.EXPERIMENT_ATLANTIS;
               break;
            case WorldsConstants.WORLD_ID_AUSTRALIA:
               key = Experiments.EXPERIMENT_AUSTRALIA;
               break;
            case WorldsConstants.WORLD_ID_SPACE:
               key = Experiments.EXPERIMENT_SPACE;
               break;
            case WorldsConstants.WORLD_ID_GARDEN:
               key = Experiments.EXPERIMENT_GARDEN;
               break;
            case WorldsConstants.WORLD_ID_CANDY:
               key = Experiments.EXPERIMENT_CANDY;
               break;
            case WorldsConstants.WORLD_ID_FFOREST:
               key = Experiments.EXPERIMENT_FFOREST;
               break;
            case WorldsConstants.WORLD_ID_HLIGHTS:
               key = Experiments.EXPERIMENT_HLIGHTS;
               break;
            case WorldsConstants.WORLD_ID_RAINFOREST:
               key = Experiments.EXPERIMENT_RAINFOREST;
               break;
            case WorldsConstants.WORLD_ID_OZ:
               key = Experiments.EXPERIMENT_OZ;
               break;
            case WorldsConstants.WORLD_ID_MEDITERRANEAN:
               key = Experiments.EXPERIMENT_MEDITERRANEAN;
               break;
            case WorldsConstants.WORLD_ID_OASIS:
               key = Experiments.EXPERIMENT_OASIS;
               break;
            case WorldsConstants.WORLD_ID_STORYBOOK:
               key = Experiments.EXPERIMENT_STORYBOOK;
               break;
            case WorldsConstants.WORLD_ID_SLEEPYHOLLOW:
               key = Experiments.EXPERIMENT_SLEEPYHOLLOW;
               break;
            case WorldsConstants.WORLD_ID_VILLAGE:
               key = Experiments.EXPERIMENT_VILLAGE;
               break;
            case WorldsConstants.WORLD_ID_TOYLAND:
               key = Experiments.EXPERIMENT_TOYLAND;
               break;
            case WorldsConstants.WORLD_ID_AVALON:
               key = Experiments.EXPERIMENT_AVALON;
               break;
            case WorldsConstants.WORLD_ID_WILDWEST:
               key = Experiments.EXPERIMENT_WILDWEST;
               break;
            case WorldsConstants.WORLD_ID_TREASURETIDES:
               key = Experiments.EXPERIMENT_TREASURETIDES;
               break;
            case WorldsConstants.WORLD_ID_AFRICA:
               key = Experiments.EXPERIMENT_AFRICA;
               break;
            case WorldsConstants.WORLD_ID_TRANSYLVANIA:
               key = Experiments.EXPERIMENT_TRANSYLVANIA;
               break;
            case WorldsConstants.WORLD_ID_WINTER:
               key = Experiments.EXPERIMENT_WINTER;
               break;
            case WorldsConstants.WORLD_ID_JAPAN:
               key = Experiments.EXPERIMENT_JAPAN;
               break;
            case WorldsConstants.WORLD_ID_INDIA:
               key = Experiments.EXPERIMENT_INDIA;
               break;
            case WorldsConstants.WORLD_ID_JUNGLE:
               key = Experiments.EXPERIMENT_JUNGLE;
               break;
            case WorldsConstants.WORLD_ID_MOUNT:
               key = Experiments.EXPERIMENT_MOUNT;
               break;
            case WorldsConstants.WORLD_ID_LIMBO:
               key = Experiments.EXPERIMENT_LIMBO;
               break;
            case WorldsConstants.WORLD_ID_XMAS:
               key = Experiments.EXPERIMENT_XMAS;
               break;
            case WorldsConstants.WORLD_ID_TURTLEISLAND:
               key = Experiments.EXPERIMENT_TURTLEISLAND;
               break;
            case WorldsConstants.WORLD_ID_MIDWEST:
               key = Experiments.EXPERIMENT_MIDWEST;
               break;
            case WorldsConstants.WORLD_ID_UNDERWATER:
               key = Experiments.EXPERIMENT_UNDERWATER;
               break;
            case WorldsConstants.WORLD_ID_ANGLOFRENCH:
               key = Experiments.EXPERIMENT_ANGLOFRENCH;
               break;
            case WorldsConstants.WORLD_ID_DREAMWORLD:
               key = Experiments.EXPERIMENT_DREAMWORLD;
               break;
            case WorldsConstants.WORLD_ID_HALLOWEENUSA:
               key = Experiments.EXPERIMENT_HALLOWEENUSA;
               break;
            case WorldsConstants.WORLD_ID_BRAZIL:
               key = Experiments.EXPERIMENT_BRAZIL;
               break;
            case WorldsConstants.WORLD_ID_TUSCANY:
               key = Experiments.EXPERIMENT_TUSCANY;
               break;
            case WorldsConstants.WORLD_ID_WHITEWINTER:
               key = Experiments.EXPERIMENT_WHITEWINTER;
               break;
            case WorldsConstants.WORLD_ID_CARIBBEAN:
               key = Experiments.EXPERIMENT_CARIBBEAN;
               break;
            case WorldsConstants.WORLD_ID_DRAGONVALLEY:
               key = Experiments.EXPERIMENT_DRAGONVALLEY;
               break;
            case WorldsConstants.WORLD_ID_RUSSIA:
               key = Experiments.EXPERIMENT_RUSSIA;
               break;
            case WorldsConstants.WORLD_ID_NEWFRONTIER:
               key = Experiments.EXPERIMENT_NEWFRONTIER;
               break;
            case WorldsConstants.WORLD_ID_ISRAEL:
               key = Experiments.EXPERIMENT_ISRAEL;
               break;
            case WorldsConstants.WORLD_ID_HALLOWEENMAD:
               key = Experiments.EXPERIMENT_HALLOWEENMAD;
               break;
            case WorldsConstants.WORLD_ID_CASABLANCA:
               key = Experiments.EXPERIMENT_CASABLANCA;
               break;
            case WorldsConstants.WORLD_ID_WINTERNORD:
               key = Experiments.EXPERIMENT_WINTERNORD;
               break;
            case WorldsConstants.WORLD_ID_TWENTIES:
               key = Experiments.EXPERIMENT_TWENTIES;
               break;
            case WorldsConstants.WORLD_ID_SOUTHINDIA:
               key = Experiments.EXPERIMENT_SOUTHINDIA;
               break;
            case WorldsConstants.WORLD_ID_ALASKA:
               key = Experiments.EXPERIMENT_ALASKA;
               break;
            case WorldsConstants.WORLD_ID_IRELAND:
               key = Experiments.EXPERIMENT_IRELAND;
               break;
            case WorldsConstants.WORLD_ID_COCOLAND:
               key = Experiments.EXPERIMENT_COCOLAND;
               break;
            case WorldsConstants.WORLD_ID_SANTAVILLAGE:
               key = Experiments.EXPERIMENT_SANTAVILLAGE;
               break;
            case WorldsConstants.WORLD_ID_BORABORA:
               key = Experiments.EXPERIMENT_BORABORA;
               break;
            case WorldsConstants.WORLD_ID_CANADA:
               key = Experiments.EXPERIMENT_CANADA;
               break;
            case WorldsConstants.WORLD_ID_SPOOKY:
               key = Experiments.EXPERIMENT_SPOOKY;
               break;
            case WorldsConstants.WORLD_ID_FARMFEST:
               key = Experiments.EXPERIMENT_FARMFEST;
               break;
            case WorldsConstants.WORLD_ID_MADAGASCAR:
               key = Experiments.EXPERIMENT_MADAGASCAR;
               break;
            case WorldsConstants.WORLD_ID_AMSTERDAM:
               key = Experiments.EXPERIMENT_AMSTERDAM;
               break;
            case WorldsConstants.WORLD_ID_PUMPKIN:
               key = Experiments.EXPERIMENT_PUMPKIN;
               break;
            case WorldsConstants.WORLD_ID_ALOHA:
               key = Experiments.EXPERIMENT_ALOHA;
               break;
            case WorldsConstants.WORLD_ID_YULETIDE:
               key = Experiments.EXPERIMENT_YULETIDE;
         }
         return Global.experimentManager.getExperimentVariant(key) > 0;
      }
      
      public function set unlockedWorldContentLicenses(licenses:Object) : void
      {
         this.m_unlockedWorldContentLicenses = licenses;
      }
      
      public function get unlockedWorldContentLicenses() : Object
      {
         return this.m_unlockedWorldContentLicenses;
      }
      
      public function hasWorldContentLicense(worldId:String, type:String = null) : Boolean
      {
         if(type == null)
         {
            type = WorldLicenseRequirement.DEFAULT_WORLD_LICENSE_TYPE;
         }
         var result:Boolean = false;
         var worldContentLicenseBucket:Object = this.m_unlockedWorldContentLicenses[worldId];
         if(worldContentLicenseBucket != null)
         {
            if(worldContentLicenseBucket[type] != null)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function getWorldsWithLicenseType(type:String) : Array
      {
         var worldId:String = null;
         var result:Array = [];
         for(worldId in this.m_unlockedWorldContentLicenses)
         {
            if(this.hasWorldContentLicense(worldId,type))
            {
               result.push(worldId);
            }
         }
         return result;
      }
      
      public function addWorldContentLicense(worldId:String, licenseType:String) : void
      {
         if(this.m_unlockedWorldContentLicenses != null)
         {
            if(this.m_unlockedWorldContentLicenses[worldId] == null)
            {
               this.m_unlockedWorldContentLicenses[worldId] = {};
            }
            this.m_unlockedWorldContentLicenses[worldId][licenseType] = true;
         }
      }
      
      public function getCurrencyForWorld(worldId:String) : String
      {
         var unit:String = null;
         var result:String = Currency.COINS;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
         if(expansionData)
         {
            unit = expansionData.currency;
            if(unit)
            {
               result = unit;
            }
         }
         return result;
      }
      
      public function getCurrentHudCurrencyUnit() : String
      {
         var currencyUnit:String = null;
         if(Global.worldManager.isVisiting())
         {
            currencyUnit = this.getCurrencyForWorld(WorldsConstants.WORLD_ID_HOME);
         }
         else
         {
            currencyUnit = this.getCurrencyForWorld(Global.worldManager.currentWorldType);
         }
         return currencyUnit;
      }
      
      public function set npcClickEnabled(enabled:Boolean) : void
      {
         this.m_npcClickEnabled = enabled;
      }
      
      public function get npcClickEnabled() : Boolean
      {
         return this.m_npcClickEnabled;
      }
      
      public function get isWorldLoading() : Boolean
      {
         return this.m_isWorldLoading;
      }
      
      public function isValidInventoryStorageId(storageId:int) : Boolean
      {
         var result:Boolean = false;
         if(WORLD_INVENTORY_IDS.indexOf(storageId) >= 0)
         {
            result = true;
         }
         return result;
      }
      
      public function getWorldTravelAssetUrl(worldName:String, type:String) : String
      {
         var currentWorldFlagUrl:String = null;
         var currentWorldConfig:Object = Global.worldSettingsManager.getConfigByWorld(worldName);
         if(ObjectUtil.pathExists(currentWorldConfig,"travelOptionsDialog",type))
         {
            switch(type)
            {
               case FASTTRAVELSMALLICON:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelsmallIcon.toString();
                  break;
               case FASTTRAVELSMALLICON1:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelsmallIcon1.toString();
                  break;
               case FASTTRAVELSMALLICON2:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelsmallIcon2.toString();
                  break;
               case FASTTRAVELSMALLICON3:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelsmallIcon3.toString();
                  break;
               case FASTTRAVELSMALLICON4:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelsmallIcon4.toString();
                  break;
               case FASTTRAVELLARGEICON:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravellargeIcon.toString();
                  break;
               case FASTTRAVELLARGEICON1:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravellargeIcon1.toString();
                  break;
               case FASTTRAVELLARGEICON2:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravellargeIcon2.toString();
                  break;
               case FASTTRAVELLARGEICON3:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravellargeIcon3.toString();
                  break;
               case FASTTRAVELLARGEICON4:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravellargeIcon4.toString();
                  break;
               case FASTTRAVELBUYICON:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelbuyIcon.toString();
                  break;
               case FASTTRAVELBUYICON1:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelbuyIcon1.toString();
                  break;
               case FASTTRAVELBUYICON2:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelbuyIcon2.toString();
                  break;
               case FASTTRAVELBUYICON3:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelbuyIcon3.toString();
                  break;
               case FASTTRAVELBUYICON4:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelbuyIcon4.toString();
                  break;
               case FASTTRAVELSEASON2ICON:
                  currentWorldFlagUrl = currentWorldConfig.travelOptionsDialog.fastTravelseason2Icon.toString();
            }
         }
         return currentWorldFlagUrl;
      }
      
      public function loadWorldFromCache(worldType:String, txData:Object) : void
      {
         var priorFarm:String = null;
         try
         {
            if(!WorldCache.validateWorldData(txData))
            {
               trackFastTravelStat("loadWorldFromCacheFailure","",worldType);
               throw new Error("Could not find expected world of type :" + worldType + " in local cache");
            }
            priorFarm = this.currentWorldType;
            this.syncWorldTime(txData["currentTime"]);
            this.m_worldSwapStable = false;
            this.m_worldCache.remove(worldType);
            Global.player.initFeatureCredits(txData.user.player.featureCredits);
            Global.player.setFeatureCreditsForWorld(worldType);
            if(txData.user.worldSummaryData)
            {
               Global.worldManager.setWorldSummaryData(txData.user.worldSummaryData);
            }
            this.worldRecieved();
            this.setCurrentWorldType(worldType);
            Global.world.cleanup();
            try
            {
               Global.world.loadObject(txData.world);
            }
            catch(error:Error)
            {
               trackFastTravelStat("clientException","loadWorldFromCache-loadObject",worldType,error.message);
            }
            this.worldLoaded(txData,true);
            if(txData["storageExpansionBuildingId"])
            {
               StorageExpandManager.getInstance().updateStorageExpansionData(txData.storageExpansionBuildingId);
            }
            TransactionManager.addTransaction(new TWorldLoadAfterCache(worldType,this,true));
            this.addWorldPeek(priorFarm);
            this.stopTravelAnimation();
            TransactionManager.addTransaction(new TRefreshGifts());
            TransactionManager.sendAllTransactions(true);
         }
         catch(error:Error)
         {
            trackFastTravelStat("clientException","loadWorldFromCache",worldType,error.message);
         }
      }
      
      public function finalizeLoadFromCache(txData:Object) : void
      {
         var worldType:String = null;
         try
         {
            if(this.currentWorldType == txData.user.currentWorldType)
            {
               trackFastTravelStat("endLoad","fromCache",txData.user.currentWorldType,"success");
               this.m_worldInit.resyncToBackendData(txData);
               this.m_worldSwapStable = true;
               this.queueAndClearWaitingTransactions();
            }
            else
            {
               GlobalEngine.info("WorldManager","finalizeLoadFromCache currentWorld:" + this.currentWorldType + " doesn\'t match transaction result:" + txData.user.currentWorldType);
            }
         }
         catch(error:Error)
         {
            worldType = Boolean(txData) && Boolean(txData.user) && Boolean(txData.user.currentWorldType) ? txData.user.currentWorldType : "";
            trackFastTravelStat("clientException","finalizeLoadFromCache",worldType,error.message);
         }
      }
      
      public function onWorldPreloadResult(worldType:String, txData:Object) : void
      {
         var numPreloadsLeft:int = 0;
         try
         {
            if(this.isWorldSwapStable)
            {
               this.m_worldCache.add(worldType,txData);
               if(this.m_pendingWorldSwap != null && this.m_pendingWorldSwap.worldType == worldType)
               {
                  if(WorldCache.validateWorldData(txData))
                  {
                     this.loadWorldFromCache(worldType,txData);
                     trackFastTravelStat("endPreload","pendingSuccess",worldType,this.m_pendingWorldSwap.worldType);
                  }
                  else
                  {
                     GlobalEngine.info("WorldManager","Error peeking at worldType:" + worldType);
                     this.doTransactionLoad(worldType,this.m_pendingWorldSwap.shouldFreezeFarm);
                     this.addWorldPeek(this.m_pendingWorldSwap.priorWorldType);
                     trackFastTravelStat("endPreload","pendingInvalid",worldType);
                  }
                  this.m_pendingWorldSwap = null;
               }
               else if(this.m_pendingWorldSwap)
               {
                  trackFastTravelStat("endPreload","pendingMismatch",worldType,this.m_pendingWorldSwap.worldType);
               }
               else
               {
                  trackFastTravelStat("endPreload","noPending",worldType);
               }
            }
            else
            {
               trackFastTravelStat("endPreload","worldSwapUnstable",worldType);
            }
            if(this.m_pendingInitialPreloadWorldTypes)
            {
               numPreloadsLeft = int(this.m_pendingInitialPreloadWorldTypes.length);
               if(numPreloadsLeft > 0)
               {
                  this.addWorldPeek(this.m_pendingInitialPreloadWorldTypes.shift());
                  numPreloadsLeft--;
               }
               if(numPreloadsLeft == 0)
               {
                  this.m_pendingInitialPreloadWorldTypes = null;
               }
            }
         }
         catch(error:Error)
         {
            trackFastTravelStat("clientException","onWorldPreloadResult",worldType,error.message);
         }
      }
      
      public function getLastWorldVisitTime(worldType:String, asEllapsed:Boolean = false) : Number
      {
         var result:Number = 0;
         var worldSummary:WorldSummary = this.m_worldSummaryData[worldType] as WorldSummary;
         if(worldSummary)
         {
            result = worldSummary.getLastLoaded();
         }
         if(asEllapsed)
         {
            result = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - result;
         }
         return result;
      }
      
      private function shouldPreloadWorld(worldType:String) : Boolean
      {
         var result:Boolean = false;
         if(this.currentWorldType != worldType && !this.m_worldCache.exists(worldType))
         {
            if(worldType == WorldsConstants.WORLD_ID_HOME)
            {
               result = true;
            }
            else
            {
               result = this.getLastWorldVisitTime(worldType,true) < RECENT_VISIT_INTERVAL_HOURS * FarmGameUtil.NUM_SECS_IN_HOUR;
            }
         }
         return result;
      }
      
      public function conditionallyPreloadWorlds() : Array
      {
         var worldType:String = null;
         var worldsToPreload:Array = null;
         var maxNumWorldsToPreload:int = 0;
         var numWorldsToPreload:int = 0;
         var worldData:Object = null;
         var result:Array = [];
         if(isWorldCacheEnabled())
         {
            worldsToPreload = new Array();
            maxNumWorldsToPreload = 3;
            for each(worldType in this.m_unlockedWorldTypes)
            {
               if(this.shouldPreloadWorld(worldType))
               {
                  worldsToPreload.push({
                     "worldType":worldType,
                     "lastVisitTime":this.getLastWorldVisitTime(worldType)
                  });
               }
            }
            numWorldsToPreload = int(worldsToPreload.length);
            if(numWorldsToPreload > maxNumWorldsToPreload)
            {
               worldsToPreload.sortOn("lastVisitTime",Array.NUMERIC | Array.DESCENDING);
               worldsToPreload.splice(maxNumWorldsToPreload,numWorldsToPreload - maxNumWorldsToPreload);
            }
            for each(worldData in worldsToPreload)
            {
               this.addWorldPeek(worldData.worldType);
               result.push(worldData.worldType);
            }
            if(result.length > 0)
            {
               TransactionManager.sendAllTransactions(true);
            }
         }
         return result;
      }
      
      public function getCachedWorlds() : Array
      {
         var worldType:String = null;
         var result:Array = [];
         for each(worldType in this.m_unlockedWorldTypes)
         {
            if(this.m_worldCache.exists(worldType))
            {
               result.push(worldType);
            }
         }
         return result;
      }
      
      public function getDaysSinceLastExpansionAccess() : Number
      {
         var worldType:String = null;
         var secondsSinceLastAccessTime:Number = NaN;
         var result:Number = NaN;
         var summaryData:WorldSummary = null;
         var lastLoaded:Number = NaN;
         var allWorldTypes:Array = WorldsConstants.ALL_WORLDS;
         var latestAccessTime:Number = 0;
         for each(worldType in allWorldTypes)
         {
            if(worldType != WorldsConstants.WORLD_ID_HOME)
            {
               summaryData = this.m_worldSummaryData[worldType];
               if(summaryData)
               {
                  lastLoaded = summaryData.getLastLoaded();
                  if(!isNaN(lastLoaded) && lastLoaded > latestAccessTime)
                  {
                     latestAccessTime = lastLoaded;
                  }
               }
            }
         }
         secondsSinceLastAccessTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - latestAccessTime;
         return secondsSinceLastAccessTime / FarmGameUtil.NUM_SECS_IN_DAY;
      }
      
      public function addPostSwapTransaction(tx:TFarmTransaction) : void
      {
         if(this.isWorldSwapStable)
         {
            TransactionManager.addTransaction(tx);
         }
         else
         {
            this.m_waitingSwapTransactions.push(tx);
         }
      }
      
      public function get worldInit() : BaseWorldInit
      {
         return this.m_worldInit;
      }
      
      public function accessExpansionTransactionInProgress() : Boolean
      {
         return Global.player.getSeenSessionFlag(TExpansionWorldAccess.EXPANSION_ACCESS_PENDING) || Global.player.getSeenSessionFlag(TExpansionWorldAccess.EXPANSION_ACCESS_SENT);
      }
      
      private function queueAndClearWaitingTransactions() : void
      {
         var tx:TFarmTransaction = null;
         if(Boolean(this.m_waitingSwapTransactions) && this.m_waitingSwapTransactions.length > 0)
         {
            for each(tx in this.m_waitingSwapTransactions)
            {
               TransactionManager.addTransaction(tx);
            }
         }
         this.m_waitingSwapTransactions = new Vector.<TFarmTransaction>();
      }
      
      public function trackWorldLoadAfterCacheMismatch(otherWorldType:String) : void
      {
         trackFastTravelStat("endLoad","fromCache",this.currentWorldType,"mismatch",otherWorldType);
      }
   }
}

