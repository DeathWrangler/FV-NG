package Transactions
{
   import Cache.Classes.ZCacheUtil;
   import Cache.Interfaces.IZCache;
   import Classes.BuildingDecoration;
   import Classes.CIPStartNow;
   import Classes.Constants.Experiments;
   import Classes.Constants.FCSlotMachineRewards;
   import Classes.Constants.ToasterIconPaths;
   import Classes.CreditsBuilding;
   import Classes.CrossPromoDescriptor;
   import Classes.DealOfDayHelper;
   import Classes.EvolutionAnimal;
   import Classes.Idle.ExpansionPromptIdleTask;
   import Classes.Idle.FarmItemDependentPostInitIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.PopupWindowsIdleTask;
   import Classes.MOTD.FlashUpgradeMOTDHandler;
   import Classes.MOTD.ZCacheMOTDHandler;
   import Classes.MatchMaking.MatchMakingManager;
   import Classes.Minigames.MinigameConstants;
   import Classes.PriceFormulaSettings;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.Quest.QuestTool;
   import Classes.Quest.ReplayableFarmQuestData;
   import Classes.Trading.OrderTypes;
   import Classes.Trading.TradingPostManager;
   import Classes.Trading.TradingPostMarketView;
   import Classes.VisitorManager;
   import Classes.WatchToEarnManager;
   import Classes.ZItem.ContentAccessSettings;
   import Classes.instagrow.InstagrowUtils;
   import Classes.unwither.UnwitherUtils;
   import Classes.util.ExternalUtil;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.InventoryWithdrawal;
   import Display.QueuedIcons.CarnivalBoothQueuedIcon;
   import Display.QueuedIcons.FlashGiftQueuedIcon;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import GameMode.GMSetAltGraphic;
   import Init.PostInitActionHandlers.AvatarPostInitAction;
   import Init.PostInitActionHandlers.CraftingWorkshopPostInitAction;
   import Init.PostInitActionHandlers.CrossPromoToasterPostInitAction;
   import Init.PostInitActionHandlers.FleaMarketPostInitAction;
   import Init.PostInitActionHandlers.GenericItemFlagToasterAction;
   import Init.PostInitActionHandlers.GiftCardCalloutAction;
   import Init.PostInitActionHandlers.LENeighborSurfacingPostInitAction;
   import Init.PostInitActionHandlers.LimitedGiftingPostInitAction;
   import Init.PostInitActionHandlers.MapTriggerManagerInit;
   import Init.PostInitActionHandlers.OpenMarketLinkPostInitAction;
   import Init.PostInitActionHandlers.PrizeMachinePostInitAction;
   import Init.PostInitActionHandlers.ProgressBarPostInitAction;
   import Init.PostInitActionHandlers.RightSideHudIconXPromoInitAction;
   import Init.PostInitActionHandlers.UnlockWorldsPostInitAction;
   import Init.PostInitActionHandlers.ZCachePostInitAction;
   import Managers.ArtUploadManager;
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
   import Managers.BeatExpansion.BeatxmasExpansionManager;
   import Managers.BingoManager;
   import Managers.BirthdayFreeGiftsManager;
   import Managers.BuildingManager;
   import Managers.BuriedTreasureManager;
   import Managers.BushelBabyManager;
   import Managers.BuyFromFeedsManager;
   import Managers.CaptureFeatureManager;
   import Managers.ChatManager;
   import Managers.CommunityGoalsManager;
   import Managers.CommunityMatchmakingUtility;
   import Managers.ConsumableBundleManager;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.CrossPromoManager;
   import Managers.DailyStatsManager;
   import Managers.DragonBreedingManager;
   import Managers.EvolutionManager;
   import Managers.FaceOffManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureCraftingManager;
   import Managers.FeatureMessagingManager;
   import Managers.FeatureOptionsManager;
   import Managers.GrowableContestManager;
   import Managers.GuildManager;
   import Managers.HangingGardensManager;
   import Managers.HolidayCountdownManager;
   import Managers.InGameConsole.InGameConsoleManager;
   import Managers.IrrigationManager;
   import Managers.ItemContestManager;
   import Managers.ItemMembershipManager;
   import Managers.JournalManager;
   import Managers.LESurfacingManager;
   import Managers.LeaderboardManager;
   import Managers.LimitedSaleUtility;
   import Managers.LotteryManager;
   import Managers.LoyaltyProgramManager;
   import Managers.MFSRequestManager;
   import Managers.MarketFlashSaleManager;
   import Managers.MessageBoardManager;
   import Managers.MystreeNurseryManager;
   import Managers.OrderBoard.SpecialQuestManager;
   import Managers.PartyManager;
   import Managers.PerformanceExperimentManager;
   import Managers.PlayerReactivation2019Manager;
   import Managers.PphToDoListManager;
   import Managers.QuestManagerDisplay;
   import Managers.ReturningUserExperienceManager;
   import Managers.SocialRaffleManager;
   import Managers.SpendometerManager;
   import Managers.StorageExpandManager;
   import Managers.SubscriptionsManager;
   import Managers.SuperPlotManager;
   import Managers.SurveyManager;
   import Managers.TargetedRewardsManager;
   import Managers.TaskListManager;
   import Managers.ThemedQuestManager;
   import Managers.TimedSlotGiveawaysManager;
   import Managers.ToasterManager;
   import Managers.ToolModeManager;
   import Managers.TrickOrTreatManager;
   import Managers.TurtleInnovationManager;
   import Managers.UGCDecoManager;
   import Managers.UISandboxManager;
   import MyLife.Events.GlobalEventManager;
   import Widgets.Windows.BrowserAppInstallWindow;
   import Widgets.Windows.BrowserAppRewardWindow;
   import Widgets.Windows.FVFlashHelper2018FeatureWindow;
   import Widgets.Windows.FVFlashHelper2018RewardWindow;
   import Widgets.Windows.LESlotMachineWindow;
   import Widgets.Windows.MOTD.FarmExpressMOTDWindow;
   import Widgets.Windows.MOTD.FarmvilleAnniversaryV10BirthdayCard;
   import Widgets.Windows.MOTD.MoneyTreeMOTDWindow;
   import Widgets.Windows.MOTD.TwitterIntegrationWindow;
   import Widgets.Windows.ThemedQuestWindow;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import com.adobe.serialization.json.JSON;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   public class TPostInit extends TFarmTransaction
   {
      
      private static const COMPLETE_FEATURE_FREQUENCY_FLAG:String = "postInitComplete";
      
      public static const ZRUNTIME_KEY_FORCE_FLASHPLAYER_PLUGIN_WINDOW:String = "FORCE_FLASHPLAYER_PLUGIN_WINDOW";
      
      public static const ZRUNTIME_MAC_APP_URL:String = "MAC_APP_URL";
      
      public static const ZRUNTIME_WIN_32_APP_URL:String = "WIN_32_APP_URL";
      
      public static const ZRUNTIME_WIN_64_APP_URL:String = "WIN_64_APP_URL";
      
      public static const ZRUNTIME_MAC_APP_ENABLE:String = "MAC_APP_ENABLE";
      
      public static const ZRUNTIME_WIN_32_APP_ENABLE:String = "WIN_32_APP_ENABLE";
      
      public static const ZRUNTIME_WIN_64_APP_ENABLE:String = "WIN_64_APP_ENABLE";
      
      public static const ZRUNTIME_BROWSER_INSTALL_START_TIME:String = "BROWSER_INSTALL_START_TIME";
      
      public static const ZRUNTIME_GUILD_CONTROL_RUNTIME:String = "GUILD_CONTROL_V1_RUNTIME";
      
      private static const API_CHECK_FVPLUGIN:String = "FarmNS.CheckChromePlugin";
      
      public static const FLASHPLUGIN_REWARDGRANTED_FLAG:String = "FVPlugin_RewardGranted";
      
      private static const SERVICE_NAME:String = "FVFlashHelper2019Service";
      
      private static const BROWSER_APP_SERVICE_NAME:String = "BrowserAppInstall2019Service";
      
      private static const FV_BROWSER_REWARDGRANTED_FLAG:* = "FVBrowser_RewardGranted";
      
      public static const REWARD_FC:* = 10;
      
      private var m_browserAppRewardWindow:BrowserAppRewardWindow;
      
      private var m_browserAppInstallWindow:BrowserAppInstallWindow;
      
      private const SWIM_HOLE_ICON_NAME:String = "AnimalBreedingSwimHole";
      
      public function TPostInit()
      {
         super();
      }
      
      private static function getSocialProofFriendData() : void
      {
         var experimentVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SOCIAL_PROOF_IMPULSE_BUY);
         if(experimentVariant >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            TransactionManager.addTransaction(new TGetSocialProofFriendData());
         }
      }
      
      override public function shouldHaveOwnBatch() : Boolean
      {
         return true;
      }
      
      override public function isPostInitTransaction() : Boolean
      {
         return true;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.postInit");
         Global.farmTimingModule.start("postinit_call");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var postInitTimestampMetric:String;
         var friendsFertilized:Array;
         var totalFriendsFertilized:int;
         var friendsFedAnimals:Array;
         var totalFriendsFedAnimals:int;
         var showBookmark:Boolean;
         var showToolbarThankYou:Boolean;
         var toolbarGiftName:String;
         var isAbleToPlayMusic:Boolean;
         var fofDataObject:Array;
         var prereqDSDataObject:Object;
         var bestSellersVariant:int;
         var fcSlotMachineRewards:Object;
         var pricingTests:Object;
         var lastPphActionType:String;
         var LESlotMachineVariant:int;
         var t8Variant:int;
         var bingoSurfacingVariant:int;
         var errorConfigs:String;
         var faceOffVariant:int;
         var crossPromoManager:CrossPromoManager;
         var xml:XML;
         var tradingPostManager:TradingPostManager;
         var prereq:Object;
         var browserPrereq:Object;
         var dailyStatsManager:DailyStatsManager;
         var postInitTimestamp:String = null;
         var list:Object = null;
         var completedQuestsArray:Array = null;
         var completedQuests:Object = null;
         var value:int = 0;
         var completedReplayableQuests:Vector.<ReplayableFarmQuestData> = null;
         var completedReplayableQuestsObject:Object = null;
         var key:String = null;
         var completedReplayableQuestDatumObject:Object = null;
         var nonExpVar:int = 0;
         var localizedToolBarText:String = null;
         var localizedToolBarTitle:String = null;
         var buildingManager:BuildingManager = null;
         var tutorialSeenFlag:String = null;
         var isCountDownSetUp:Boolean = false;
         var hudIcons:Array = null;
         var hudIconIndex:int = 0;
         var errors:String = null;
         var giftData:Object = null;
         var popupwindow:FVFlashHelper2018FeatureWindow = null;
         var os:String = null;
         var flashVersion:String = null;
         var flashOs:String = null;
         var flashScreenRes:String = null;
         Global.farmTimingModule.end("postinit_call",true);
         Global.loadingMetricsRecorder.addTimingMetric(Global.loadingMetricsRecorder.KEY_LOADTIME_POSTINIT_COMPLETE_START,getTimer().toString());
         getSocialProofFriendData();
         TransactionManager.addTransaction(new TR2InterstitialPostInit());
         postInitTimestampMetric = Global.loadingMetricsRecorder.KEY_LOADTIME_POSTINIT;
         if(result[postInitTimestampMetric] != null)
         {
            postInitTimestamp = new String(result[postInitTimestampMetric]);
            Global.loadingMetricsRecorder.addTimingMetric(postInitTimestampMetric,postInitTimestamp);
            Global.loadingMetricsRecorder.addMetadata(Global.loadingMetricsRecorder.KEY_METADATA_WORLD,Global.worldManager.currentWorldType);
         }
         Global.postInitSettings.postInitUserResult = result;
         friendsFertilized = result.friendsFertilized;
         totalFriendsFertilized = int(result.totalFriendsFertilized);
         friendsFedAnimals = result.friendsFedAnimals;
         totalFriendsFedAnimals = int(result.totalFriendsFedAnimals);
         showBookmark = Boolean(result.showBookmark);
         showToolbarThankYou = Boolean(result.showToolbarThankYou);
         toolbarGiftName = result.toolbarGiftName;
         isAbleToPlayMusic = Boolean(result.isAbleToPlayMusic);
         fofDataObject = result.FOFData;
         prereqDSDataObject = result.prereqDSData;
         Global.player.giftsendBlacklist = result.giftsendBlacklist;
         Global.player.fofData = fofDataObject;
         Global.player.prereqDSObject = prereqDSDataObject;
         Global.friendManager.neighborCount = result.neighborCount;
         if(result.hasOwnProperty(SubscriptionsManager.SUBSCRIPTIONS_DATA_FROM_SERVER) && result[SubscriptionsManager.SUBSCRIPTIONS_DATA_FROM_SERVER] != null)
         {
            SubscriptionsManager.instance.init(result[SubscriptionsManager.SUBSCRIPTIONS_DATA_FROM_SERVER]);
         }
         if(result.hasOwnProperty("spendometerActive") && result["spendometerActive"] != null && result["spendometerActive"] != false)
         {
            if(Boolean(result["spendometerActive"].hasOwnProperty("currentRevision")) && result["spendometerActive"]["currentRevision"] != null)
            {
               SpendometerManager.instance.init(true,result["spendometerActive"]["currentRevision"]);
            }
         }
         if(result["crossGameGiftingState"] != null)
         {
            Global.player.crossGameGiftingStateData = result["crossGameGiftingState"];
            GlobalEventManager.getInstance().dispatchEvent(new Event(BuildingDecoration.CROSS_PROMO_DATA_LOADED));
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_POSTPONE_MARKETVIEW) != 1)
         {
            if(result["marketView"] != null)
            {
               Global.farmTimingModule.start("TPostInit_marketView");
               MarketViewManager.getInstance().updateViewFromResponse(result["marketView"]);
               Global.farmTimingModule.end("TPostInit_marketView");
            }
         }
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKET_VIEW_CRAFTGOODS_CROP) == 2 && result["marketViewCraftingSkills"] != null)
         {
            MarketViewManager.getInstance().updateCraftSkillState(result["marketViewCraftingSkills"]);
         }
         if(result["avatarState"] != null)
         {
            Global.player.avatarState.initAvatarStateFromInitUser(result.avatarState);
         }
         if(result["breedingState"] != null)
         {
            Global.player.breedingState.initBreedingStateFromInitUser(result.breedingState);
         }
         if(result["w2wState"] != null)
         {
            Global.player.w2wState.initW2WState(result.w2wState);
         }
         bestSellersVariant = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_FIX_BEST_SELLERS);
         if(bestSellersVariant >= 2)
         {
            if(Global.flashHotParams.hasOwnProperty("MARKET_BEST_SELLERS"))
            {
               list = com.adobe.serialization.json.JSON.decode(Global.flashHotParams["MARKET_BEST_SELLERS"]);
               switch(bestSellersVariant)
               {
                  case 2:
                     Global.marketRecommendations.initialize(list["byVolume"]);
                     break;
                  case 3:
                     Global.marketRecommendations.initialize(list["byCash"]);
               }
            }
            else if(result["bestSellers"] != null)
            {
               Global.marketRecommendations.initialize(result["bestSellers"]);
            }
         }
         else if(result["bestSellers"] != null)
         {
            Global.marketRecommendations.initialize(result["bestSellers"]);
         }
         if(result["completedQuests"] != null)
         {
            completedQuestsArray = new Array();
            if(result["completedQuests"] is Array)
            {
               completedQuestsArray = result["completedQuests"] as Array;
            }
            else
            {
               completedQuests = result["completedQuests"];
               for each(value in completedQuests)
               {
                  completedQuestsArray.push(value);
               }
            }
            FarmQuestManager.getInstance().setPreviouslyCompletedQuests(completedQuestsArray);
            if(Boolean(JournalManager.getInstance()) && JournalManager.getInstance().isJournalActive())
            {
               JournalManager.getInstance().loadCompletedQuestBubbles();
            }
         }
         if(result["completedReplayableQuests"] != null)
         {
            completedReplayableQuests = new Vector.<ReplayableFarmQuestData>();
            completedReplayableQuestsObject = result["completedReplayableQuests"];
            for(key in completedReplayableQuestsObject)
            {
               completedReplayableQuestDatumObject = completedReplayableQuestsObject[key];
               completedReplayableQuestDatumObject[ReplayableFarmQuestData.MEM_STORE_ID] = key;
               completedReplayableQuests.push(new ReplayableFarmQuestData(completedReplayableQuestDatumObject));
            }
            FarmQuestManager.getInstance().completedReplayableQuests = completedReplayableQuests;
         }
         if(Global.player.getSeenFlag("NonExperimentSetUp") && Boolean(Global.flashHotParams["NONEXPERIMENT_SETUP_TEMPRT"]))
         {
            nonExpVar = Global.experimentManager.getExperimentVariant("fv_non_experiment");
            Global.player.setSeenFlag("NonExperimentSetUp");
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ANIMAL_BREEDING_SWIMHOLE) == 1)
         {
            Global.hud.rightSideIconQueue.addIcon(this.SWIM_HOLE_ICON_NAME);
         }
         else
         {
            Global.hud.rightSideIconQueue.removeIconByName(this.SWIM_HOLE_ICON_NAME);
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PLANET_ORGANIC) == 3)
         {
            Global.hud.rightSideIconQueue.addIcon("planetOrganic");
         }
         fcSlotMachineRewards = result["fcSlotMachineRewards"];
         if(Boolean(fcSlotMachineRewards) && Boolean(fcSlotMachineRewards.allRewards) && Boolean(fcSlotMachineRewards.mgRewards))
         {
            FCSlotMachineRewards.initializeRewards(fcSlotMachineRewards.allRewards,fcSlotMachineRewards.mgRewards);
         }
         else
         {
            ErrorManager.addError("invalid rewards for FC Slot Machine");
         }
         TaskListManager.getInstance().showHUDIcon();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_QUEST_MANAGER) == Experiments.VARIANT_QUEST_MANAGER_ON)
         {
            QuestManagerDisplay.getInstance().showHUDIcon();
         }
         pricingTests = result["pricingTests"] != null ? result["pricingTests"] : {};
         Global.priceFormulaSettings = new PriceFormulaSettings(pricingTests);
         Global.farmGameSettingsManager.generateAvatarClothesMenu();
         if(!Global.farmGameSettingsManager.itemsXMLParsingComplete && PerformanceExperimentManager.isInInterruptFreeItemParsingExperiment)
         {
            IdleTaskQueue.getInstance().addTask(new FarmItemDependentPostInitIdleTask(ZCacheUtil.applyPartial(Global.world.optionallyEnableExpansionMarketing,Global.world,[true])));
         }
         else
         {
            Global.world.optionallyEnableExpansionMarketing(true);
         }
         if(showToolbarThankYou)
         {
            localizedToolBarText = ZLocUtils.t("Dialogs","ToolbarThankYou",{"item":ZLocUtils.tk_pk(toolbarGiftName)});
            localizedToolBarTitle = ZLocUtils.t("Dialogs","ToolbarThankYou_Title",{"item":ZLocUtils.tk_pk(toolbarGiftName)});
            ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(localizedToolBarTitle,localizedToolBarText,ToasterIconPaths.CASH_ICON,ToasterIconPaths.TOOLBAR_ICON,ToasterIconPaths.DIALOG_ASSET,0.5,0.5,new Point(15,8),null,null));
         }
         if(Global.world)
         {
            Global.world.redrawObjectsOfClass(CreditsBuilding);
         }
         StorageExpandManager.getInstance().updateStorageExpansionData(result.storageExpansionBuildingId);
         if(result.overlaySurveyURL)
         {
            SurveyManager.getInstance().initializeSurveyOverlay(result.overlaySurveyURL);
         }
         CraftingManager.getInstance().doPostInit();
         if(!ReturningUserExperienceManager.isInExperiment() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EXPANSION_PROMPT_IDLE) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            IdleTaskQueue.getInstance().addTask(new ExpansionPromptIdleTask());
         }
         if(Boolean(result) && result.hasOwnProperty("seedWishData"))
         {
            Global.player.seedWishData = result.seedWishData;
         }
         VisitorManager.getInstance().placeNeighborVisitAvatars();
         Global.farmTimingModule.start("TPostInit_PartyManager");
         PartyManager.getInstance().initializePartyDataObjects();
         Global.farmTimingModule.end("TPostInit_PartyManager");
         if(DealOfDayHelper.inExperiment())
         {
            DealOfDayHelper.init();
         }
         if(result["buildingActions"] != null)
         {
            buildingManager = BuildingManager.getInstance();
            buildingManager.handlePostInitBuildingActions(result["buildingActions"]);
         }
         lastPphActionType = result.lastPphActionType;
         PphToDoListManager.getInstance().init(lastPphActionType);
         FlashGiftQueuedIcon.conditonallyAddFlashGiftIcon();
         if(LimitedSaleUtility.isEligible)
         {
            if(LimitedSaleUtility.instance().getTimeRemainingOnCurrentSale() > 0)
            {
               Global.hud.rightSideIconQueue.addIcon(LimitedSaleUtility.LIMITED_SALE_ICON_NAME,DynamicIconQueue.ADD_BY_PRIORITY,null,null,false);
            }
         }
         LESlotMachineVariant = Global.experimentManager.getExperimentVariant(LESlotMachineWindow.EXPERIMENT_NAME);
         if(LESlotMachineVariant > 1 && LESlotMachineVariant < 10 && Global.player.canShowFeatureWithBackoff(LESlotMachineWindow.EXPERIMENT_NAME))
         {
            if(Global.player.getBackoffInterval(LESlotMachineWindow.EXPERIMENT_NAME) < 7)
            {
               Global.player.incrementBackoffInterval(LESlotMachineWindow.EXPERIMENT_NAME);
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CARNIVAL_BOOTH_HUD) >= 2)
            {
               CarnivalBoothQueuedIcon.showHUDIcon();
            }
            else
            {
               Global.hud.rightSideIconQueue.addIcon("leSlotMachine",2,null,null,false);
            }
         }
         WatchToEarnManager.getInstance().doPostInit();
         WatchToEarnManager.getInstance().generateDailyTokens();
         this.getUserZid();
         t8Variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ZAP_T8);
         if(t8Variant > 0)
         {
            GlobalEngine.log("ZAP W2E","TGetTargetingGroups");
            TransactionManager.addTransaction(new TGenericTransaction("UserService","getTargetingGroups",function():void
            {
               GlobalEngine.log("ZAP W2E","TGetTargetingGroups::onComplete: " + com.adobe.serialization.json.JSON.encode(result));
               Global.player.targetingGroups = result.groups;
            }));
         }
         else
         {
            GlobalEngine.log("ZAP W2E","Targeting experiment (`" + Experiments.EXPERIMENT_FLASH_ZAP_T8 + "`) disabled: " + t8Variant);
         }
         this.controlContentAccessHudVisibility();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FVWEB_XPROMO) == 1 && !Global.player.getSeenFlag(FarmExpressMOTDWindow.FVWEB_FVXPROMO_REWARDED))
         {
            FarmStatsManager.count("hud_icon","xpromo","view","63","fvx_xpromo");
            Global.hud.rightSideIconQueue.addIcon(FarmExpressMOTDWindow.FVWEB_HUD_FVXPROMO,DynamicIconQueue.ADD_BY_PRIORITY,null,null,false);
         }
         if(result["bingoNums"])
         {
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_BINGO) >= Experiments.VARIANT_BINGO_FEATURE_ON_10)
            {
               tutorialSeenFlag = BingoManager.BINGO_FEATURE_SEEN_FLAG;
               if(!Global.player.getSeenFlag(tutorialSeenFlag))
               {
                  BingoManager.getInstance().setBingoNumsFromCallback(result["bingoNums"]);
               }
            }
         }
         bingoSurfacingVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BINGO_SURFACING);
         errorConfigs = "";
         if(bingoSurfacingVariant >= Experiments.VARIANT_BINGO_SURFACING_AUTOPOP && Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_BINGO) >= Experiments.VARIANT_BINGO_FEATURE_ON_10)
         {
            isCountDownSetUp = false;
            if(result["holidayCountdown"])
            {
               if(Config.DEBUG_MODE && Boolean(result["holidayCountdown"]["configErrors"]))
               {
                  errorConfigs = (result["holidayCountdown"]["configErrors"] as Object).toString();
                  if(Boolean(errorConfigs) && errorConfigs != "")
                  {
                     UI.displayMessage(errorConfigs);
                  }
               }
               if(result["holidayCountdown"]["config"])
               {
                  HolidayCountdownManager.init(result);
               }
            }
            if(!ReturningUserExperienceManager.isInExperiment())
            {
               IdleTaskQueue.getInstance().addTask(new PopupWindowsIdleTask(isCountDownSetUp));
            }
         }
         else if(result["holidayCountdown"])
         {
            if(Config.DEBUG_MODE && Boolean(result["holidayCountdown"]["configErrors"]))
            {
               errorConfigs = (result["holidayCountdown"]["configErrors"] as Object).toString();
               if(Boolean(errorConfigs) && errorConfigs != "")
               {
                  UI.displayMessage(errorConfigs);
               }
            }
            if(result["holidayCountdown"]["config"])
            {
               HolidayCountdownManager.init(result);
            }
         }
         faceOffVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FACE_OFF);
         if(faceOffVariant > 2)
         {
            FeatureOptionsManager.getInstance().setFeature(FaceOffManager.DEFAULT_FEATURE_NAME,result["faceOffFeatureOptions"]);
            FaceOffManager.getInstance().setupFaceOff();
         }
         if(result["hudIcons"])
         {
            hudIcons = result["hudIcons"];
            for(hudIconIndex = 0; hudIconIndex < hudIcons.length; hudIconIndex++)
            {
               Global.hud.rightSideIconQueue.addIcon(hudIcons[hudIconIndex],DynamicIconQueue.ADD_BY_PRIORITY,null,false);
            }
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CARNIVAL_BOOTH_HUD) >= 2)
         {
            CarnivalBoothQueuedIcon.showHUDIcon();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MONEYTREE_2016) >= 2)
         {
            Global.hud.rightSideIconQueue.addIcon(MoneyTreeMOTDWindow.MONEYTREE_HUD,DynamicIconQueue.ADD_BY_PRIORITY,null,false);
         }
         Global.hud.rightSideIconQueue.addIcon(MinigameConstants.MINIGAME_KEY_PEARUP,DynamicIconQueue.ADD_BY_PRIORITY,null,false);
         if(ThemedQuestManager.instance.isFeatureActive(ThemedQuestWindow.PUZZLE_BUILDING))
         {
            Global.hud.rightSideIconQueue.addIcon(ThemedQuestWindow.PUZZLE_FEATURE,DynamicIconQueue.ADD_BY_PRIORITY,null,false);
         }
         BingoManager.getInstance().addHUDIcon();
         CommunityGoalsManager.getInstance().init(result["communityGoalsData"]);
         TurtleInnovationManager.getInstance().initRewardLootTable(result["turtleInnovationData"]);
         DragonBreedingManager.getInstance("dragon_pen_finished").initializeCollection(result["dragonCollection"]);
         MarketFlashSaleManager.instance.init();
         if(MystreeNurseryManager.getInstance().isFeatureActive())
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(MystreeNurseryManager.FEATURE_NAME,MystreeNurseryManager.getInstance().handleHUDClick);
         }
         SpecialQuestManager.initAllOrderBoards(result["worldCurrencies"]);
         CommunityMatchmakingUtility.conditionallyAddNeighborToasterIdleTask();
         LotteryManager.instance.init(result["lotteryData"]);
         TrickOrTreatManager.instance.init(null);
         Global.hud.addSubscriptionsHUDWidget();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CASH_SALE_MOTD) == 1 && result.hasOwnProperty("postInitMOTD") && result.postInitMOTD != false)
         {
            Global.player.currentMOTD = result.postInitMOTD;
         }
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_BUY_FROM_FEEDS) >= Experiments.VARIANT_BUY_FROM_FEEDS_VALID_VARIANT_START)
         {
            BuyFromFeedsManager.conditionallyShowRewardDialogs();
            if(!BuyFromFeedsManager.hasCurrentOfferExpired() && Global.player.isMotdSeenFlagSet(BuyFromFeedsManager.MOTD_NAME))
            {
               BuyFromFeedsManager.addHucIcon();
            }
            BeatIrelandExpansionManager.instance.init();
            BeatSpookOWeenExpansionManager.instance.init();
            BuyFromFeedsManager.conditionallyShowRedemptionDialog(result.failedBuyFromFeedsOffersItemCodes);
         }
         MFSRequestManager.conditionallyDisplayR2AddNeighborWindow("force_view");
         if(result.popupTwitterDialog == true)
         {
            UI.displayPopup(new TwitterIntegrationWindow());
         }
         InventoryWithdrawal.limitCheckInventoryItems();
         crossPromoManager = CrossPromoManager.getInstance();
         crossPromoManager.doAvailable();
         BeatrussiaExpansionManager.instance.init();
         BeatcaribbeanExpansionManager.instance.init();
         BeathalloweenusaExpansionManager.instance.init();
         BeatwhitewinterExpansionManager.instance.init();
         BeattuscanyExpansionManager.instance.init();
         BeatdragonvalleyExpansionManager.instance.init();
         BeatbrazilExpansionManager.instance.init();
         BeatanglofrenchExpansionManager.instance.init();
         BeatdreamworldExpansionManager.instance.init();
         BeatturtleislandExpansionManager.instance.init();
         BeatxmasExpansionManager.instance.init();
         BeatmidwestExpansionManager.instance.init();
         BeatunderwaterExpansionManager.instance.init();
         BeatlimboExpansionManager.instance.init();
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
         BeatSecretExpansionManager.instance.init();
         BeatValleyExpansionManager.instance.init();
         BeatTrailsExpansionManager.instance.init();
         BeatBoraExpansionManager.instance.init();
         BeatBloomExpansionManager.instance.init();
         BeatMapleExpansionManager.instance.init();
         BeatCoastalExpansionManager.instance.init();
         BeatSoireeExpansionManager.instance.init();
         TimedSlotGiveawaysManager.initializeGiveaways();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BIRTHDAY_FREE_GIFTS) == 1)
         {
            if(result["birthdayGiftData"])
            {
               if(result["birthdayGiftData"]["error"])
               {
                  errors = result["birthdayGiftData"]["error"].toString();
                  UI.displayMessage(errors);
               }
               else if(result["birthdayGiftData"]["gifts"])
               {
                  giftData = result["birthdayGiftData"];
                  BirthdayFreeGiftsManager.getInstance().setFeatureOption(giftData);
               }
            }
         }
         this.startPostInitActionsManager();
         xml = Global.farmGameSettingsManager.getXML();
         if(Boolean(xml.featureMessagingManagerSettings) && Boolean(xml.featureMessagingManagerSettings.children()))
         {
            FeatureMessagingManager.getInstance().loadXML(xml.featureMessagingManagerSettings.children());
            FeatureMessagingManager.getInstance().processFeatures();
         }
         if(!Global.farmGameSettingsManager.itemsXMLParsingComplete && PerformanceExperimentManager.isInInterruptFreeItemParsingExperiment)
         {
            IdleTaskQueue.getInstance().addTask(new FarmItemDependentPostInitIdleTask(ZCacheUtil.applyPartial(LESurfacingManager.instance.init,LESurfacingManager.instance,[false]),5000));
         }
         else
         {
            LESurfacingManager.instance.init(false);
         }
         if(result.hasOwnProperty("primeZCache"))
         {
            Global.postInitSettings.zCachePreloads = result["primeZCache"];
         }
         tradingPostManager = TradingPostManager.getInstance();
         tradingPostManager.marketView = new TradingPostMarketView(new Object(),OrderTypes.CROP_ORDER);
         UnwitherUtils.showUnwitherIconIfNecessary();
         InstagrowUtils.conditionallyShowInstagrowIcon();
         if(result.hasOwnProperty("raffleData") && result.raffleData != null)
         {
            SocialRaffleManager.getInstance().init(result.raffleData);
         }
         if(result.hasOwnProperty("fbFeedAutopublishCap") && result.fbFeedAutopublishCap != null)
         {
            Global.player.fbFeedAutopublishCap = result.fbFeedAutopublishCap;
         }
         else
         {
            Global.player.fbFeedAutopublishCap = Global.player.defaultFbFeedAutopublishCap;
         }
         if(result.hasOwnProperty("fbFeedAutopublishCount") && result.fbFeedAutopublishCount != null)
         {
            Global.player.fbFeedAutopublishCount = result.fbFeedAutopublishCount;
         }
         else
         {
            Global.player.fbFeedAutopublishCount = 0;
         }
         if(result.hasOwnProperty("fbFeedAutopublishCapTimeInterval") && result.fbFeedAutopublishCapTimeInterval != null)
         {
            Global.player.fbFeedAutopublishCapTimeInterval = result.fbFeedAutopublishCapTimeInterval;
         }
         else
         {
            Global.player.fbFeedAutopublishCapTimeInterval = Global.player.defaultFbFeedAutopublishCapTimeInterval;
         }
         if(!ReturningUserExperienceManager.isInExperiment() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_LAST_CHANCE) < Experiments.VARIANT_LE_LAST_CHANCE_EXPIRING)
         {
         }
         if(result.hasOwnProperty("unacceptedFbPermissions") && result.unacceptedFbPermissions != null)
         {
            Global.player.unacceptedFbPermissions = result.unacceptedFbPermissions;
         }
         if(result.hasOwnProperty("acceptedFbPermissions") && result.acceptedFbPermissions != null)
         {
            Global.player.acceptedFbPermissions = result.acceptedFbPermissions;
         }
         if(ChatManager.instance.isFarmTalkEnabled())
         {
            setTimeout(ChatManager.countOnlineNeighbors,5000);
         }
         if(Global.player.level >= 5)
         {
            CaptureFeatureManager.instance.init();
         }
         if(BuriedTreasureManager.isFeatureActive())
         {
            BuriedTreasureManager.instance.init();
         }
         if(Global.worldManager.currentWorldType == HangingGardensManager.HANGING_GARDENS && Global.player.getSeenFlag(HangingGardensManager.HANGING_GARDENS_FTUE_SEEN_FLAG))
         {
            HangingGardensManager.instance.addFourPanelHudIcon();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FELINE_EVOLUTION))
         {
            EvolutionManager.instance.init();
            Global.world.loadContextMenusForEvolutionAnimals(EvolutionAnimal);
         }
         if(Config.DEBUG_MODE)
         {
            InGameConsoleManager.autoGenerateLiveCommands();
         }
         LeaderboardManager.initialize();
         ItemMembershipManager.doPostInit(result);
         LoyaltyProgramManager.initialize();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UGC_DECO_BUILDINGS) != 0)
         {
            UGCDecoManager.instance.init();
         }
         MFSRequestManager.executePendingTabClickForR2MFS();
         if(ItemContestManager.inMainExperiment())
         {
            ItemContestManager.registerFeature();
         }
         ItemContestManager.getInstance().init();
         GrowableContestManager.instance.doPostInit();
         FeatureCraftingManager.instance.init();
         BushelBabyManager.instance.init();
         if(IrrigationManager.instance.isInExperiment())
         {
            IrrigationManager.instance.init();
         }
         Global.player.setPostInitUserDone();
         Global.player.setFeatureLastShown(COMPLETE_FEATURE_FREQUENCY_FLAG,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
         Global.world.dispatchEvent(new FarmGameWorldEvent(FarmGameWorldEvent.USER_POST_INIT_COMPLETE));
         Global.loadingMetricsRecorder.addTimingMetric(Global.loadingMetricsRecorder.KEY_LOADTIME_POSTINIT_COMPLETE_END,getTimer().toString());
         TargetedRewardsManager.getInstance().checkAndDisplayUI();
         Global.nopopupManager.resetSupress();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MATCHMAKING_ENABLE) > 0)
         {
            MatchMakingManager.getInstance().initZoom();
            MatchMakingManager.getInstance().createSession(Global.player.uid,[],0);
         }
         prereq = Global.farmGameSettingsManager.getPrereqByName("fv_flashHelper");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            if(this.isForcePluginWindow() || this.isEligibleforPluginFeature)
            {
               popupwindow = new FVFlashHelper2018FeatureWindow();
               if(popupwindow)
               {
                  popupwindow.launchFlashPluginFeature();
               }
            }
         }
         if(this.isEligibleforPluginFeature)
         {
            this.launchFlashPlugin();
         }
         browserPrereq = Global.farmGameSettingsManager.getPrereqByName("fv_browserApp");
         if(PrerequisiteUtility.isPrerequisiteMet(browserPrereq) && this.hasBrowserAppInstallStarted() && this.isEligibleforPluginFeature && !this.isEligibleforBrowserAppRewards && !Global.player.getSeenFlag("app_installed"))
         {
            os = Capabilities.os.substr(0,3);
            if(os == "Win")
            {
               if(Capabilities.supports64BitProcesses)
               {
                  if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_WIN_64_APP_URL) && Global.flashHotParams.hasOwnProperty(ZRUNTIME_WIN_64_APP_ENABLE))
                  {
                     if(Global.flashHotParams[ZRUNTIME_WIN_64_APP_ENABLE] == true)
                     {
                        this.m_browserAppInstallWindow = new BrowserAppInstallWindow("assets/dialogs/BrowserApp2019/FV_BrowserApp2019.swf",Global.flashHotParams[ZRUNTIME_WIN_64_APP_URL].toString());
                     }
                  }
               }
               else if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_WIN_32_APP_URL) && Global.flashHotParams.hasOwnProperty(ZRUNTIME_WIN_32_APP_ENABLE))
               {
                  if(Global.flashHotParams[ZRUNTIME_WIN_32_APP_ENABLE] == true)
                  {
                     this.m_browserAppInstallWindow = new BrowserAppInstallWindow("assets/dialogs/BrowserApp2019/FV_BrowserApp2019.swf",Global.flashHotParams[ZRUNTIME_WIN_32_APP_URL].toString());
                  }
               }
            }
            else if(os == "Mac")
            {
               if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_MAC_APP_URL) && Global.flashHotParams.hasOwnProperty(ZRUNTIME_MAC_APP_ENABLE))
               {
                  if(Global.flashHotParams[ZRUNTIME_MAC_APP_ENABLE] == true)
                  {
                     this.m_browserAppInstallWindow = new BrowserAppInstallWindow("assets/dialogs/BrowserApp2019/FV_BrowserApp2019.swf",Global.flashHotParams[ZRUNTIME_MAC_APP_URL].toString());
                  }
               }
            }
            if(Boolean(this.m_browserAppInstallWindow) && this.m_browserAppInstallWindow.canShowAppInstallWindow())
            {
               UI.displayPopup(this.m_browserAppInstallWindow,false);
            }
         }
         if(PrerequisiteUtility.isPrerequisiteMet(browserPrereq) && this.hasBrowserAppInstallStarted() && this.isEligibleforBrowserAppRewards && !Global.player.getSeenFlag(FV_BROWSER_REWARDGRANTED_FLAG))
         {
            this.grantBrowserAppInstallRewards();
         }
         else if(this.isEligibleforBrowserAppRewards)
         {
            flashVersion = Capabilities.version;
            flashOs = Capabilities.os;
            flashScreenRes = Capabilities.screenResolutionX + " x " + Capabilities.screenResolutionY;
            StatsManager.count("client_info","zynga_browser_" + this.getBrowserAppVersion,flashVersion,flashOs,flashScreenRes,Global.worldManager.currentWorldType);
         }
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_GUILD_CONTROL_RUNTIME) && Boolean(Global.flashHotParams[ZRUNTIME_GUILD_CONTROL_RUNTIME]))
         {
            GuildManager.getInstance().updateUserGuildData();
         }
         dailyStatsManager = DailyStatsManager.getInstance();
         if(dailyStatsManager.shouldDispatch())
         {
            dailyStatsManager.dispatchCounts();
         }
         FarmvilleAnniversaryV10BirthdayCard.showReceivedGiftCard();
         if(Global.flashHotParams.hasOwnProperty("MESSAGEBOARD_ENABLED") && Boolean(Global.flashHotParams["MESSAGEBOARD_ENABLED"]))
         {
            MessageBoardManager.getInstance().loadMessageBoardData();
         }
      }
      
      public function getBrowserAppVersion() : String
      {
         var ind:int = 0;
         var browserString:String = null;
         var spaceInd:int = 0;
         var browserAppVersion:* = "";
         var userAgent:String = ExternalInterface.call("window.navigator.userAgent.toString") || ExternalInterface.call("navigator.userAgent.toString") || ExternalInterface.call("window.navigator.userAgent.toString()") || ExternalInterface.call("navigator.userAgent.toString()");
         if(Boolean(userAgent) && userAgent.indexOf("FarmVille") != -1)
         {
            ind = userAgent.indexOf("FarmVille/");
            browserString = userAgent.substr(ind,userAgent.length);
            spaceInd = browserString.indexOf(" ");
            browserAppVersion = browserString.substr(10,spaceInd);
         }
         return browserAppVersion;
      }
      
      public function launchFlashPlugin() : void
      {
         var result:Object = {};
         ExternalUtil.instance.addCallback("onCheckChromePluginResponse",ZCacheUtil.applyPartial(this.onCheckChromePluginResponse,this,[result]));
         ExternalUtil.instance.call(API_CHECK_FVPLUGIN);
      }
      
      public function onCheckChromePluginResponse(result:Object = null, isPluginInstalled:Boolean = false) : void
      {
         if(isPluginInstalled)
         {
            if(!Global.player.getSeenFlag(FLASHPLUGIN_REWARDGRANTED_FLAG))
            {
               TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"grantReward",this.onGrantPluginReward));
               StatsManager.count("chrome_extension","install_plugin");
            }
            else
            {
               StatsManager.count("chrome_extension","has_plugin");
            }
         }
         else if(Global.player.getSeenFlag(FLASHPLUGIN_REWARDGRANTED_FLAG))
         {
            StatsManager.count("chrome_extension","uninstall_plugin");
         }
      }
      
      public function onGrantPluginReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(FLASHPLUGIN_REWARDGRANTED_FLAG);
            Global.player.addGift("pegasus_royalegold","0",1);
            Global.player.addGift("pegasus_heartking","0",1);
            Global.player.cash += REWARD_FC;
            FVFlashHelper2018RewardWindow.launchPluginRewardWindow();
         }
      }
      
      public function hasBrowserAppInstallStarted() : Boolean
      {
         var startTime:Number = NaN;
         var startDate:String = null;
         var currentTime:Number = NaN;
         var isInstallStarted:Boolean = false;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_BROWSER_INSTALL_START_TIME))
         {
            startDate = String(Global.flashHotParams[ZRUNTIME_BROWSER_INSTALL_START_TIME]);
            startTime = FarmGameUtil.synchronizedDateToNumber(startDate) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(startTime > 0 && startTime <= currentTime)
            {
               isInstallStarted = true;
            }
         }
         return isInstallStarted;
      }
      
      public function grantBrowserAppInstallRewards() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(BROWSER_APP_SERVICE_NAME,"grantReward",this.onGrantBrowserAppInstallRewards));
      }
      
      public function onGrantBrowserAppInstallRewards(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(FV_BROWSER_REWARDGRANTED_FLAG);
            Global.player.addGift("pegasus_heartking","0",1);
            Global.player.cash += REWARD_FC;
            this.m_browserAppRewardWindow = new BrowserAppRewardWindow("assets/dialogs/BrowserApp2019/FV_BrowserApp2019_RewardDialog.swf");
            UI.displayPopup(this.m_browserAppRewardWindow,false);
            StatsManager.count("farmvilleapp","installed");
         }
      }
      
      public function isForcePluginWindow() : Boolean
      {
         var isForceChrome:Boolean = false;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_FORCE_FLASHPLAYER_PLUGIN_WINDOW))
         {
            isForceChrome = Boolean(Global.flashHotParams[ZRUNTIME_KEY_FORCE_FLASHPLAYER_PLUGIN_WINDOW]);
         }
         return isForceChrome;
      }
      
      public function get isEligibleforPluginFeature() : Boolean
      {
         var isChrome:Boolean = false;
         var userAgent:String = ExternalInterface.call("window.navigator.userAgent.toString") || ExternalInterface.call("navigator.userAgent.toString") || ExternalInterface.call("window.navigator.userAgent.toString()") || ExternalInterface.call("navigator.userAgent.toString()");
         if(Boolean(userAgent) && userAgent.indexOf("Chrome") != -1)
         {
            isChrome = true;
            Global.player.setSeenFlag("is_chrome_browser");
         }
         return isChrome;
      }
      
      public function get isEligibleforBrowserAppRewards() : Boolean
      {
         var isBrowserApp:* = false;
         var userAgent:String = ExternalInterface.call("window.navigator.userAgent.toString") || ExternalInterface.call("navigator.userAgent.toString") || ExternalInterface.call("window.navigator.userAgent.toString()") || ExternalInterface.call("navigator.userAgent.toString()");
         if(Boolean(userAgent) && userAgent.indexOf("FarmVille") != -1)
         {
            isBrowserApp = true;
            Global.player.setSeenFlag("app_installed");
         }
         return isBrowserApp;
      }
      
      private function onPopGiftDialog(e:Event) : void
      {
         UI.displayGiftBoxWindow();
      }
      
      private function startPostInitActionsManager() : void
      {
         var flagName:String = null;
         var flag:String = null;
         var realFlag:Array = null;
         var itemFlagAction:String = null;
         var activeCrossPromos:Object = null;
         var crossPromo:CrossPromoDescriptor = null;
         var zCache:IZCache = null;
         var count:int = 0;
         for(flag in Global.player.itemFlags)
         {
            realFlag = flag.split("_");
            if(Boolean(realFlag[0]) && Global.player.getItemFlag(realFlag[0]) != "")
            {
               itemFlagAction = Global.farmGameSettingsManager.getItemFlagAction(realFlag[0]);
               if((itemFlagAction == "GenericItemFlagToasterAction" || itemFlagAction == "") && realFlag[0].indexOf("_lastPresent") < 0)
               {
                  Global.postInitActionsManager.addInitAction(new GenericItemFlagToasterAction(this.onPopGiftDialog,realFlag[0]));
               }
            }
         }
         if(Global.artuploadSandboxMode)
         {
            ArtUploadManager.init();
         }
         if(Global.uiSandboxMode)
         {
            UISandboxManager.init();
         }
         if(Global.questTool2Mode)
         {
            QuestTool.init();
         }
         if(Global.toolMode)
         {
            ToolModeManager.initMode();
         }
         else
         {
            activeCrossPromos = Global.crosspromoDescriptorManager.crossPromos;
            for each(crossPromo in activeCrossPromos)
            {
               if(crossPromo.hasToaster())
               {
                  Global.postInitActionsManager.addInitAction(new CrossPromoToasterPostInitAction(crossPromo));
               }
            }
            Global.postInitActionsManager.addInitAction(new ProgressBarPostInitAction());
            if(!ReturningUserExperienceManager.isInExperiment())
            {
               Global.postInitActionsManager.addInitAction(new OpenMarketLinkPostInitAction());
               Global.postInitActionsManager.addInitAction(new ZCachePostInitAction());
            }
            Global.postInitActionsManager.addInitAction(new GiftCardCalloutAction(this.onPopGiftDialog));
            Global.postInitActionsManager.addInitAction(new AvatarPostInitAction());
            Global.postInitActionsManager.addInitAction(new CraftingWorkshopPostInitAction());
            Global.postInitActionsManager.addInitAction(new RightSideHudIconXPromoInitAction());
            Global.postInitActionsManager.addInitAction(new LimitedGiftingPostInitAction());
            Global.postInitActionsManager.addInitAction(new MapTriggerManagerInit());
            Global.postInitActionsManager.addInitAction(new FleaMarketPostInitAction());
            Global.postInitActionsManager.addInitAction(new LENeighborSurfacingPostInitAction());
            Global.postInitActionsManager.addInitAction(new PrizeMachinePostInitAction());
            Global.player.extendedPermissionState.refreshExtendedPermissions();
            zCache = GlobalZCache.instance;
            if(zCache)
            {
               if(zCache.allowed && !Global.player.getSeenFlag(ZCacheMOTDHandler.ZCACHE_GIFT_GIVEN))
               {
                  TransactionManager.addTransaction(new TGrantZCacheGift(ZCacheMOTDHandler.ZCACHE_GIFT_GIVEN_RETROACTIVELY),true);
               }
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UPGRADE_FLASH_PROMO) > 1)
            {
               if(FlashUpgradeMOTDHandler.isGiftGrantable())
               {
                  TransactionManager.addTransaction(new TGrantFlashUpgradeGift(),true);
               }
            }
            if(CIPStartNow.canShowGDP())
            {
               count = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.CIP_START_NOW,FeatureOptionsManager.CIP_START_NOW_SESSIONS) as int;
               if(CIPStartNow.canShowGDPAtSessionCount(count))
               {
                  CIPStartNow.showStarterPack();
               }
            }
            SuperPlotManager.countGiftBox();
         }
         Global.postInitSettings.loadPostInitQueue();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_UNLOCK_WORLDS) >= 1 && Global.player.level >= 15)
         {
            Global.postInitActionsManager.addInitAction(new UnlockWorldsPostInitAction());
         }
         Global.postInitActionsManager.executeStack();
         if(ConsumableBundleManager.getInstance().canDisplayPopup())
         {
            ConsumableBundleManager.getInstance().handleHUDClick();
         }
         if(PlayerReactivation2019Manager.isEligibleForPlayerReactivation2019())
         {
            PlayerReactivation2019Manager.grantReward();
         }
      }
      
      private function controlContentAccessHudVisibility() : void
      {
         var contentAccessSettings:ContentAccessSettings = null;
         var allContentAccessSettings:Object = Global.farmGameSettingsManager.getAllContentAccessSettingsHash();
         for each(contentAccessSettings in allContentAccessSettings)
         {
            contentAccessSettings.showIcons();
         }
      }
      
      private function onGMSetAltGraphic(e:Event) : void
      {
         Global.world.addGameMode(new GMSetAltGraphic("web"));
      }
      
      public function getUserZid() : *
      {
         TransactionManager.addTransaction(new TGenericTransaction("WatchToEarnRewardGrantService","getUserZid",this.onGetUserZid));
      }
      
      public function onGetUserZid(result:Object) : void
      {
         if(result.success)
         {
            if(result.zid)
            {
               ExternalUtil.instance.call("FarmNS.setZid",result.zid.toString());
            }
         }
      }
   }
}

import Classes.Idle.RetentionItemPopupIdleTask;

RetentionItemPopupIdleTask;

