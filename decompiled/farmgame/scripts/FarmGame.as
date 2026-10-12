package
{
   import Cache.Init.ZCacheInit;
   import Cache.Managers.ZCacheLoadingManager;
   import Classes.BuyerPromo.BuyerPromoUtility;
   import Classes.CIPStartNow;
   import Classes.Constants.AssetSandboxConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestToolConstant;
   import Classes.CrossPromoDescriptorManager;
   import Classes.FarmGameModules;
   import Classes.FarmIsoViewport;
   import Classes.FarmSocialNetworkUser;
   import Classes.Friend;
   import Classes.Idle.ExternalIdleTask;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.InterstitialVideoAdIdleTask;
   import Classes.InvisibleTerrain.InvisibleTerrainMap;
   import Classes.Quest.FarmQuestComponent;
   import Classes.consumables.CQuestProgress;
   import Classes.util.ExternalUtil;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.FarmFacebookSocialNetwork;
   import Classes.util.FarmGameUtil;
   import Classes.util.FarmLoadPhaseMonitor;
   import Classes.util.FarmModeManager;
   import Classes.util.LoadingMetricsRecorder;
   import Classes.util.ZLocUtils;
   import Display.AssetHashMap;
   import Display.Dialog;
   import Display.FarmTileMap;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Classes.ZEngineOptions;
   import Engine.Events.LoaderEvent;
   import Engine.Events.TransactionEvent;
   import Engine.Events.TransactionFaultEvent;
   import Engine.Init.InitializationManager;
   import Engine.Managers.CBReportManager;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Profiler.ProdAggregator;
   import Engine.Transactions.TPublishUserAction;
   import Engine.Transactions.Transaction;
   import Engine.Utilities;
   import Events.SubscriptionsEvent;
   import GameMode.GMDefault;
   import Init.AnimalBreedingSettingsInit;
   import Init.AssetHashInit;
   import Init.AvatarSettingsInit;
   import Init.BatchLimitInit;
   import Init.CollectionsInit;
   import Init.CraftingSettingsInit;
   import Init.CrossPromoSettingsInit;
   import Init.DoobersInit;
   import Init.DynamicDialogsInit;
   import Init.ExpansionWorldScoreInitAction;
   import Init.FacebookInit;
   import Init.FarmFacebookInit;
   import Init.FarmGameSettingsInit;
   import Init.FarmZLiveInit;
   import Init.GlobalWorldScoreInitAction;
   import Init.GlobalsInit;
   import Init.LabBuildingInit;
   import Init.LeaderboardSettingsInit;
   import Init.MarketSettingsInit;
   import Init.PostInitSequenceInit;
   import Init.PreFetchTransactionInit;
   import Init.SocialNetworkInit;
   import Init.SocialPlumbingInit;
   import Init.StorageSettingsAMFInit;
   import Init.StorageSettingsInit;
   import Init.TerrainInit;
   import Init.TransactionsInit;
   import Init.UIInit;
   import Init.UserDataInit;
   import Init.WatchToEarnInit;
   import Init.WorldInit;
   import Init.WorldScoreAMFInitAction;
   import Init.WorldScoreInitAction;
   import Init.WorldSettingsInit;
   import Init.XMLDialogsInit;
   import Init.YimfInit;
   import Init.ZLocalizationInit;
   import Init.ZapCampaignInit;
   import Managers.DefconManager;
   import Managers.EmailManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FarmZCacheManager;
   import Managers.FarmZPreloaderManager;
   import Managers.FarmZaspManager;
   import Managers.FreezeManager;
   import Managers.InGameConsole.InGameConsoleManager;
   import Managers.InGamePaymentsManager;
   import Managers.LeaderboardManager;
   import Managers.MFSRequestManager;
   import Managers.PackPurchaseManager;
   import Managers.SubscriptionsManager;
   import Managers.WorldManager;
   import Transactions.TRefreshGifts;
   import Transactions.TSendUserEnvReport;
   import Transactions.TZFeed;
   import Widgets.Windows.FarmFeedIssueWindow;
   import Widgets.Windows.FarmOOSWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import Widgets.Windows.NeighborPlumbing.AddSpecificNeighborWindow;
   import cipro.Profiler.GameTagManager;
   import cipro.Profiler.RuntimeProfiler;
   import com.adobe.serialization.json.JSON;
   import flash.display.NativeMenu;
   import flash.events.ContextMenuEvent;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.events.UncaughtErrorEvent;
   import flash.external.ExternalInterface;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.system.System;
   import flash.text.TextField;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.ui.Keyboard;
   import flash.utils.Timer;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   public class FarmGame extends BaseGame
   {
      
      protected static var m_giftboxWarningDialog:Dialog;
      
      protected static var m_giftboxDialogTime:Number;
      
      protected static var m_giftboxDialogCount:int = 0;
      
      private static const TRANSACTION_QUEUE_FULL_TIMEOUT_SECS:int = 90;
      
      private static const FEATURE_FLASHPARAM_REPORT_ERRORS:String = "REPORT_ERRORS";
      
      public static const FEATURE_FLASHPARAM_REPORT_SWF_EXPORT_ERRORS:String = "REPORT_SWF_EXPORT_ERRORS";
      
      private static const DELAY_FOR_STATS_SEND:int = 1000;
      
      private static var m_CBTraceLog:Array = [];
      
      private static var m_lastUncaughtException:Object = {};
      
      public static const MAX_LOG_SIZE:int = 40;
      
      public static const MAX_DESYNC_RECOVERY_ATTEMPTS:int = 3;
      
      private static const WAIT_ON_TRANSACTION_EVENT:String = "Wait_Transaction_Begin";
      
      public static const CLIENT_SIDE_OOS_ERROR_CODE:String = "40";
      
      public static const KILLING_CO_OP_STATS_CONST:String = "killingCoop";
      
      private static var m_reconnectingDialog:GenericPopup = null;
      
      private static var m_reconnectSecondAttempt:Boolean = false;
      
      public static const FGSM_AMF_ENABLED_FLASH_VAR:String = "FGSM_AMF_ENABLED";
      
      public static const OPS_FGSM_QUEST_ITEM_CAT_ENABLED_FLASH_VAR:String = "OPS_FGSM_QUEST_ITEM_CAT_ENABLED";
      
      public static const EXPT_PREFETCH_TINIT_USER:String = "fv_ops_prefetch_init_user";
      
      public static const EXPT_DELAYED_WORLD_SCORE_INIT:String = "fv_ops_delayed_world_score";
      
      private static var toggle_s:Boolean = false;
      
      private static var toggle_m:Boolean = false;
      
      protected var m_feedOpenTime:Number;
      
      protected var m_warningDialog:Dialog;
      
      protected var m_warningDialogTime:Number;
      
      protected var m_warningDialogCount:int = 0;
      
      protected var m_initComplete:Boolean = false;
      
      protected var m_initStartTime:int = 0;
      
      protected var m_initialAssetLoadComplete:Boolean = false;
      
      private var m_transactionQueueFullTimer:Timer = null;
      
      private var m_lastStateDetail:String = "";
      
      private var m_prefetchTInitUserOn:Boolean = false;
      
      private var m_delayedWorldScoreInit:Boolean = false;
      
      private var m_lastPerfUpdate:int = 0;
      
      public function FarmGame(params:Object = null)
      {
         Global.preloaderComplete = Security.sandboxType != Security.REMOTE;
         Global.loadingMetricsRecorder = LoadingMetricsRecorder.getInstance();
         if(this.root.loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
         {
            this.root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.uncaughtErrorHandler);
         }
         if(Security.sandboxType != Security.REMOTE && loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
         {
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.uncaughtErrorHandler);
         }
         GameTagManager.initialize(new FarmModeManager());
         FarmGameModules.initialize();
         FarmLoadPhaseMonitor.updateLoadPhase(FarmLoadPhaseMonitor.LOADAPP);
         var profCookie:int = RuntimeProfiler.enter(FarmGameModules.FarmGameConstructor);
         Global.setStartingWaitTime();
         Security.allowDomain("*");
         var options:ZEngineOptions = new ZEngineOptions();
         options.tileWidth = 25;
         options.tileHeight = 12;
         options.tileScale = 2;
         options.viewportClass = FarmIsoViewport;
         options.tileMapClass = FarmTileMap;
         options.socialNetworkUserClass = FarmSocialNetworkUser;
         options.sendLoadingManagerStats = true;
         options.baseService = "FlashService.dispatchBatch";
         options.numShards = 16;
         options.loadingManagerClass = ZCacheLoadingManager;
         options.addComponent(FarmZCacheManager.getComponent());
         options.addComponent(new FarmQuestComponent());
         options.zaspManagerClass = FarmZaspManager;
         super(params,options);
         Global.farmGame = this;
         var curMemory:Number = System.totalMemoryNumber;
         if(curMemory < 0)
         {
            Global.loadingMetricsRecorder.addOptionalMetric(Global.loadingMetricsRecorder.OPT_MEM_NUM_CONSTRUCTION,System.totalMemoryNumber);
         }
         Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_CONSTRUCTION,curMemory);
         Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_PVT_CONSTRUCTION,System.privateMemory);
         RuntimeProfiler.leave(profCookie);
      }
      
      public static function muteAll() : void
      {
         if(!SoundManager.isMuted())
         {
            toggle_s = true;
            SoundManager.mute();
         }
         if(!Global.player.isMusicDisabled())
         {
            toggle_m = true;
            Global.player.options.musicDisabled = true;
            Global.world.syncMusicToPlayerOptions();
         }
      }
      
      public static function unmuteAll() : void
      {
         if(SoundManager.isMuted() && toggle_s)
         {
            toggle_s = false;
            SoundManager.unmute();
         }
         if(Global.player.isMusicDisabled() && toggle_m)
         {
            toggle_m = false;
            Global.player.options.musicDisabled = false;
            Global.world.syncMusicToPlayerOptions();
         }
      }
      
      public static function cbTrace(dialogDescription:String) : void
      {
         m_CBTraceLog.unshift(dialogDescription);
         while(m_CBTraceLog.length > MAX_LOG_SIZE)
         {
            m_CBTraceLog.pop();
         }
      }
      
      public static function getCBTrace() : Array
      {
         return m_CBTraceLog;
      }
      
      public static function getLastUncaughtException() : Object
      {
         return m_lastUncaughtException;
      }
      
      private static function onTransactionReconnecting(event:TransactionFaultEvent) : void
      {
         if(Config.DEBUG_MODE)
         {
            UI.displayMessage("reconnecting: errorData => " + event.errorData);
         }
         showReconnectingDialog();
      }
      
      private static function onLogTransactionRetyInfo(event:TransactionFaultEvent) : void
      {
         var additionalData:String = "";
         var tBatchInfo:Array = event.errorData as Array;
         for(var i:int = 0; i < tBatchInfo.length; i++)
         {
            additionalData += "BATCH::";
            additionalData += "retryCount=" + tBatchInfo[i]["retryCount"] + ",";
            additionalData += "resultError=" + tBatchInfo[i]["resultError"] + ",";
            additionalData += "timestamp=" + tBatchInfo[i]["timestamp"] + ",";
            additionalData += "batchInfo=" + tBatchInfo[i]["batchInfo"] + "\n";
         }
         FarmGameUtil.reportClientLog(additionalData);
      }
      
      private static function showReconnectingDialog() : void
      {
         var message:String = null;
         if(m_reconnectingDialog == null)
         {
            message = "Howdy Farmer! We are backing up your Farm. Please refresh your game to continue Farming !";
            m_reconnectingDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
         }
      }
      
      private static function onReconnectSuccess(event:TransactionEvent) : void
      {
         if(m_reconnectingDialog)
         {
            m_reconnectingDialog.close();
            m_reconnectingDialog = null;
            FarmStatsManager.featureCount(1376629200,"farm95531","client_reconnect","success");
         }
         m_reconnectSecondAttempt = false;
      }
      
      private static function onConnectionDropped(httpStatus:String) : void
      {
         var closeCallback:Function = null;
         FarmGameUtil.reportClientLog("ConnectionDropped: HTTPStatus=" + httpStatus);
         FarmStatsManager.featureCount(1376629200,"farm95531","client_reconnect","failure");
         var message:String = "Connection to the server has been lost. Check that you have a working internet connection then click \"Okay\" to ";
         if(m_reconnectingDialog)
         {
            m_reconnectingDialog.close();
            m_reconnectingDialog = null;
         }
         if(m_reconnectSecondAttempt)
         {
            message += "reload the game";
            closeCallback = FarmGameUtil.redirectHomeNoError;
            FarmStatsManager.featureCount(1376629200,"farm95531","client_reconnect","refresh");
         }
         else
         {
            message += "attempt to reconnect";
            closeCallback = TransactionManager.retryReconnect;
            m_reconnectSecondAttempt = true;
         }
         UI.displayMessage(message,GenericPopup.TYPE_OK,closeCallback,"",true);
      }
      
      public static function resetGameMode() : void
      {
         Global.world.getTopGameMode().disableMode();
         Global.world.popGameMode();
         Global.world.addGameMode(new GMDefault());
      }
      
      public static function onGiftboxDesync() : void
      {
         var message:String = null;
         if(m_giftboxWarningDialog == null && m_giftboxDialogCount < MAX_DESYNC_RECOVERY_ATTEMPTS)
         {
            resetGameMode();
            message = ZLocUtils.t("FarmGame","LoadingGiftbox");
            ++m_giftboxDialogCount;
            FarmStatsManager.count("errors","loadingGiftbox","popup_displayed","","","popups_this_session",m_giftboxDialogCount);
            m_giftboxDialogTime = GlobalEngine.currentTime;
            m_giftboxWarningDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
            TransactionManager.addTransaction(new TRefreshGifts(onGiftboxResync),true);
         }
      }
      
      public static function onGiftboxResync(result:Object) : void
      {
         var timeUp:int = 0;
         if(m_giftboxWarningDialog != null)
         {
            timeUp = Math.floor((GlobalEngine.currentTime - m_giftboxDialogTime) / 1000) as int;
            FarmStatsManager.count("errors","loadingGiftbox","popup_removed","","","popup_display_time",timeUp);
            m_giftboxWarningDialog.close();
            m_giftboxWarningDialog = null;
         }
      }
      
      private function uncaughtErrorHandler(uncaughtErrorEvent:UncaughtErrorEvent) : void
      {
         var error:Error = null;
         var errorEvent:ErrorEvent = null;
         var nonSpaceRegex:RegExp = null;
         var doubleSpaceRegex:RegExp = null;
         var divider:String = null;
         var indexOfDivider:int = 0;
         if(false && Security.sandboxType != Security.REMOTE)
         {
            uncaughtErrorEvent.preventDefault();
         }
         var reportData:Object = {};
         FarmGameUtil.collectEnvironmentInfo(reportData);
         var errorType:String = "none";
         var errorMessage:String = "";
         var stackTrace:String = "";
         var stackRoot:String = "";
         if(uncaughtErrorEvent.error is Error)
         {
            error = uncaughtErrorEvent.error as Error;
            errorType = "Error";
            errorMessage = error.message;
            stackTrace = error.getStackTrace();
         }
         else if(uncaughtErrorEvent.error is ErrorEvent)
         {
            errorEvent = uncaughtErrorEvent.error as ErrorEvent;
            errorType = errorEvent.type;
            errorMessage = errorEvent.text;
         }
         else if(uncaughtErrorEvent.error != null)
         {
            errorType = "unknown";
            errorMessage = uncaughtErrorEvent.error.toString();
         }
         if(stackTrace)
         {
            nonSpaceRegex = /[\n\r\t]/g;
            stackTrace = stackTrace.replace(nonSpaceRegex," ");
            doubleSpaceRegex = /  /g;
            stackTrace = stackTrace.replace(doubleSpaceRegex," ");
            stackRoot = stackTrace;
            stackRoot.replace(errorMessage,"");
            divider = " at ";
            indexOfDivider = stackRoot.indexOf(divider);
            if(indexOfDivider > 0)
            {
               stackRoot = stackRoot.substr(indexOfDivider + divider.length);
            }
            indexOfDivider = stackRoot.indexOf(divider);
            if(indexOfDivider > 0)
            {
               stackRoot = stackRoot.substr(0,indexOfDivider);
            }
         }
         reportData["errorType"] = errorType;
         reportData["errorMessage"] = errorMessage;
         reportData["stackTrace"] = stackTrace;
         reportData["stackRoot"] = stackRoot;
         FarmGameUtil.sendJavaScriptReport("report_exception.php",reportData,"UncaughtException");
         m_lastUncaughtException = reportData;
         FarmStatsManager.count("error","uncaught exception",errorType);
         StatsManager.sendStats(true);
      }
      
      public function get prefetchTInitUserOn() : Boolean
      {
         return this.m_prefetchTInitUserOn;
      }
      
      override protected function init() : void
      {
         var o:Object = null;
         var transactionsInit:TransactionsInit = null;
         var prefetchTransactionInit:PreFetchTransactionInit = null;
         var exceptionsStr:String = null;
         var exceptionsObj:Object = null;
         var profCookie:int = RuntimeProfiler.enter(FarmGameModules.FarmGameOnInit);
         var curMemory:Number = System.totalMemoryNumber;
         if(curMemory < 0)
         {
            Global.loadingMetricsRecorder.addOptionalMetric(Global.loadingMetricsRecorder.OPT_MEM_NUM_GAME_INIT,System.totalMemoryNumber);
         }
         Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_GAME_INIT,curMemory);
         Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_PVT_GAME_INIT,System.privateMemory);
         this.m_initStartTime = getTimer();
         Config.verboseLogging = Config.DEBUG_MODE;
         Global.stage = this.stage;
         if(parameters["locale"] != undefined)
         {
            Global.masterLocale = parameters["locale"];
         }
         else
         {
            Global.masterLocale = ZLocUtils.getDefaultLocale();
         }
         if(parameters["fblocale"])
         {
            Global.fbLocale = parameters["fblocale"];
         }
         else
         {
            Global.fbLocale = ZLocUtils.getDefaultLocale();
         }
         if(parameters.hasOwnProperty(AssetSandboxConstants.ART_SANDBOX_MODE))
         {
            Global.toolMode = parameters[AssetSandboxConstants.ART_SANDBOX_MODE] == 1 ? true : false;
         }
         if(parameters.hasOwnProperty(AssetSandboxConstants.UI_SANDBOX_MODE))
         {
            Global.uiSandboxMode = parameters[AssetSandboxConstants.UI_SANDBOX_MODE] == 1 ? true : false;
         }
         if(parameters.hasOwnProperty(AssetSandboxConstants.ARTUPLOAD_SANDBOX_MODE))
         {
            Global.artuploadSandboxMode = parameters[AssetSandboxConstants.ARTUPLOAD_SANDBOX_MODE] == 1 ? true : false;
         }
         if(parameters.hasOwnProperty(QuestToolConstant.QUEST_TOOL2_MODE))
         {
            Global.questTool2Mode = parameters[QuestToolConstant.QUEST_TOOL2_MODE] == 1 ? true : false;
            QuestToolConstant.questToolOn = Global.questTool2Mode;
         }
         var zLocalizationUrl:String = Global.getXMLPath() + Global.masterLocale + ".swf";
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_STRINGS_REDUCTION) == Experiments.VARIANT_OPS_STRINGS_REDUCTION)
         {
            zLocalizationUrl = Global.getXMLPath() + "en_US_min" + ".swf";
         }
         var configUrl:String = Global.getXMLPath() + "gameSettings.xml.gz";
         var itemsUrl:String = Global.getXMLPath();
         if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
         {
            itemsUrl += "items_opt.amf";
         }
         else if(FarmGameSettingsManager.isInItemsAMFExperiment())
         {
            if(FarmGameSettingsManager.isInItemAMFPristineExperiment())
            {
               itemsUrl += "newItems.amf.gz";
            }
            else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_ITEMS_AMF_REDUCTION) == Experiments.VARIANT_OPS_ITEMS_AMF_REDUCTION)
            {
               itemsUrl += "items_min.amf.gz";
            }
            else if(FarmGameSettingsManager.isInItemsAMFBuildTimeReduction())
            {
               itemsUrl += "deltaItems.amf.gz";
            }
            else
            {
               itemsUrl += "items.amf.gz";
            }
         }
         else
         {
            itemsUrl += "items.xml.gz";
         }
         var gameSettingsCMSUrl:String = Global.getXMLPath() + "gameSettingsCMS.xml.gz";
         var configSwfUrl:String = Global.getXMLPath() + "FarmConfig.swf";
         var dialogsUrl:String = Global.getXMLPath() + "dialogs.xml.gz";
         var doobersUrl:String = Global.getXMLPath() + "doobers.xml.gz";
         var labBuildingsUrl:String = Global.getXMLPath() + "labBuildings.xml.gz";
         var yimfUrl:String = Global.getXMLPath() + "yimf.xml.gz";
         var terrainUrl:String = Global.getXMLPath() + "terrain.xml.gz";
         var crosspromoUrl:String = Global.getXMLPath() + "crosspromo.xml";
         var itemsAmfPristinePath:String = Global.getItemsAmfPristinePath();
         var itemsAmfTrunkPath:String = Global.getXMLPath() + "dev_items_trunk.amf.gz";
         var itemsMasterysignsUrl:String = Global.getMasteryAmfURL() + "masterysign_items.amf.gz";
         Global.crosspromoDescriptorManager = new CrossPromoDescriptorManager();
         if(parameters.game_config_url)
         {
            configUrl = parameters.game_config_url;
         }
         if(GlobalEngine.isFlashVarSetAndTrue(FGSM_AMF_ENABLED_FLASH_VAR))
         {
            if(parameters.fgsm_amf_url)
            {
               itemsUrl = parameters.fgsm_amf_url;
            }
         }
         else if(FarmGameSettingsManager.isInOptItemsAMFExperiment())
         {
            if(parameters.items_opt_amf)
            {
               itemsUrl = parameters.items_opt_amf;
            }
         }
         else if(FarmGameSettingsManager.isInItemsAMFExperiment())
         {
            if(!FarmGameSettingsManager.isInItemAMFPristineExperiment())
            {
               if(parameters.items_amf)
               {
                  itemsUrl = parameters.items_amf;
               }
            }
         }
         else if(parameters.items_url)
         {
            itemsUrl = parameters.items_url;
         }
         if(parameters.gameSettingsCMS_url)
         {
            gameSettingsCMSUrl = parameters.gameSettingsCMS_url;
         }
         var usingHashedAsset:Boolean = false;
         var _loc29_:int = 0;
         var _loc30_:* = AssetHashMap;
         for(o in _loc30_)
         {
            usingHashedAsset = true;
         }
         if(parameters.config_swf_url)
         {
            configSwfUrl = parameters.config_swf_url;
         }
         if(parameters.dialogs_url)
         {
            dialogsUrl = parameters.dialogs_url;
         }
         if(parameters.doobers_url)
         {
            doobersUrl = parameters.doobers_url;
         }
         if(parameters.yimf_url)
         {
            yimfUrl = parameters.yimf_url;
         }
         if(parameters.labBuildings_url)
         {
            labBuildingsUrl = parameters.labBuildings_url;
         }
         if(parameters.terrain_url)
         {
            terrainUrl = parameters.terrain_url;
         }
         if(parameters.crosspromo_url)
         {
            crosspromoUrl = parameters.crosspromo_url;
         }
         if(parameters.visitId)
         {
            Global.worldManager.visitAfterInit(parameters.visitId,false);
         }
         if(parameters.visitNPCId)
         {
            Global.worldManager.visitAfterInit(parameters.visitNPCId,true);
         }
         var popupSequenceUrl:String = parameters.hasOwnProperty("postInitSequenceUrl") && Boolean(parameters.popupSequenceUrl) ? parameters.popupSequenceUrl : "postInitSequence.xml";
         Global.enableDebugKeys = Config.DEBUG_MODE;
         var loadingManager:LoadingManager = LoadingManager.getInstance();
         loadingManager.addEventListener(LoaderEvent.ALL_HIGH_PRIORITY_LOADED,this.onAllHighPriorityLoaded);
         loadingManager.addEventListener(LoaderEvent.WORLD_LOAD_STARTED,this.onWorldLoadStarted);
         GlobalEngine.log("Init","Game Config URL: " + configUrl);
         var initManager:InitializationManager = GlobalEngine.initializationManager;
         var useBatchLimitBool:Boolean = false;
         if(parameters.batch_limit_experiment == "1")
         {
            if(parameters.batch_limit_runtime == "1")
            {
               useBatchLimitBool = true;
            }
            if(useBatchLimitBool)
            {
               exceptionsStr = null;
               if(parameters.batchLimitFunctionExceptions)
               {
                  exceptionsStr = parameters.batchLimitFunctionExceptions;
                  if(exceptionsStr)
                  {
                     exceptionsObj = com.adobe.serialization.json.JSON.decode(exceptionsStr);
                     if(exceptionsObj)
                     {
                        TransactionManager.batchLimiterFunctionExceptions = exceptionsObj;
                     }
                  }
               }
               if(parameters.batchLimiterVerboseData == "1")
               {
                  TransactionManager.batchLimiterVerboseData = true;
               }
               initManager.add(new BatchLimitInit());
            }
         }
         this.m_prefetchTInitUserOn = Global.experimentManager.getExperimentVariant(EXPT_PREFETCH_TINIT_USER) == 2;
         if(this.m_prefetchTInitUserOn)
         {
            initManager.add(new UserDataInit());
            prefetchTransactionInit = new PreFetchTransactionInit(useBatchLimitBool);
            initManager.add(prefetchTransactionInit);
         }
         initManager.add(new AssetHashInit());
         initManager.add(new LeaderboardSettingsInit(parameters.phpRevision));
         initManager.add(new MarketSettingsInit(parameters.phpRevision));
         initManager.add(new FarmGameSettingsInit(configUrl,itemsUrl,configSwfUrl,gameSettingsCMSUrl,itemsAmfPristinePath,itemsAmfTrunkPath,itemsMasterysignsUrl));
         initManager.add(new AnimalBreedingSettingsInit(parameters.phpRevision));
         initManager.add(new CraftingSettingsInit(parameters.phpRevision));
         initManager.add(new AvatarSettingsInit(parameters.phpRevision));
         initManager.add(new ZLocalizationInit(zLocalizationUrl));
         initManager.add(new CrossPromoSettingsInit(parameters.phpRevision));
         initManager.add(new ZapCampaignInit(parameters.phpRevision));
         initManager.add(new PostInitSequenceInit(popupSequenceUrl,parameters.phpRevision));
         if(this.m_prefetchTInitUserOn)
         {
            transactionsInit = new TransactionsInit(useBatchLimitBool);
            transactionsInit.addDependency(PreFetchTransactionInit.INIT_ID);
         }
         else
         {
            transactionsInit = new TransactionsInit(useBatchLimitBool);
         }
         if(initManager.hasAction(ZCacheInit.INIT_ID))
         {
            transactionsInit.addDependency(ZCacheInit.INIT_ID);
         }
         initManager.add(transactionsInit);
         initManager.add(new GlobalsInit());
         initManager.add(new WorldInit());
         initManager.add(new UIInit());
         initManager.add(new XMLDialogsInit(dialogsUrl));
         initManager.add(new DynamicDialogsInit());
         var socialNetwork:SocialNetworkInit = this.pickSocialNetworkInit();
         initManager.add(socialNetwork);
         initManager.add(new SocialPlumbingInit(socialNetwork));
         if(FarmGameSettingsManager.isInStorageConfigAMFExperiment())
         {
            initManager.add(new StorageSettingsAMFInit(parameters.phpRevision));
         }
         else
         {
            initManager.add(new StorageSettingsInit(parameters.phpRevision));
         }
         initManager.add(new DoobersInit(parameters.phpRevision));
         this.m_delayedWorldScoreInit = Global.experimentManager.getExperimentVariant(EXPT_DELAYED_WORLD_SCORE_INIT) == 2 && !FarmGameSettingsManager.isInWorldScoreAMFExperiment();
         if(FarmGameSettingsManager.isInWorldScoreAMFExperiment())
         {
            initManager.add(new WorldScoreAMFInitAction(parameters.phpRevision));
         }
         else if(this.m_delayedWorldScoreInit)
         {
            initManager.add(new GlobalWorldScoreInitAction(parameters.phpRevision));
         }
         else
         {
            initManager.add(new WorldScoreInitAction(parameters.phpRevision));
         }
         initManager.add(new CollectionsInit(parameters.phpRevision));
         initManager.add(new WorldSettingsInit(parameters.phpRevision));
         initManager.add(new YimfInit(parameters.phpRevision));
         initManager.add(new TerrainInit(parameters.phpRevision));
         initManager.add(new WatchToEarnInit());
         initManager.add(new LabBuildingInit(parameters.phpRevision));
         initManager.addEventListener(ProgressEvent.PROGRESS,this.onInitProgress);
         initManager.addEventListener(Event.COMPLETE,this.onAllInitComplete);
         initManager.execute();
         ErrorManager.getInstance().addEventListener(ErrorEvent.ERROR,this.onError);
         var platform:String = Capabilities.supports64BitProcesses ? "64bit" : "32bit";
         StatsManager.count("platform",platform);
         RuntimeProfiler.leave(profCookie);
      }
      
      private function pickSocialNetworkInit() : SocialNetworkInit
      {
         var skipFacebook:Boolean = false;
         var socialNetworkInit:SocialNetworkInit = null;
         var params:* = parameters;
         if(Boolean(parameters.zy_user) || Boolean(parameters.zy_ts) || Boolean(parameters.zy_session))
         {
            socialNetworkInit = new FarmZLiveInit(false,parameters);
         }
         else if(Boolean(parameters.fb_sig_user) || Boolean(parameters.fb_sig_api_key) || Boolean(parameters.fb_sig_session_key))
         {
            skipFacebook = parameters.skipFacebook == true;
            socialNetworkInit = new FarmFacebookInit(skipFacebook,FarmFacebookSocialNetwork);
            if(parameters.oauth_session)
            {
               (socialNetworkInit as FacebookInit).m_isInOAuth = true;
            }
         }
         return socialNetworkInit;
      }
      
      private function onInitProgress(e:ProgressEvent) : void
      {
         dispatchEvent(e);
      }
      
      public function notifyWaitOnTransaction() : void
      {
         dispatchEvent(new Event(WAIT_ON_TRANSACTION_EVENT));
      }
      
      private function onAllInitComplete(ev:Event) : void
      {
         var curMemory:Number;
         var profCookie:int;
         var viewport:FarmIsoViewport;
         var transactionManager:TransactionManager;
         var strPopulationThreshold:String;
         var callbacks:Object;
         var populationThreshold:Number = NaN;
         var uid_string:String = null;
         var name:String = null;
         var delay:Number = NaN;
         var myTimer:Timer = null;
         if(this.m_delayedWorldScoreInit)
         {
            GlobalEngine.initializationManager.removeEventListener(ProgressEvent.PROGRESS,this.onInitProgress);
            GlobalEngine.initializationManager.removeEventListener(Event.COMPLETE,this.onAllInitComplete);
         }
         curMemory = System.totalMemoryNumber;
         if(curMemory < 0)
         {
            Global.loadingMetricsRecorder.addOptionalMetric(Global.loadingMetricsRecorder.OPT_MEM_NUM_INTERACTIVE_PHASE,System.totalMemoryNumber);
         }
         Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_INTERACTIVE_PHASE,curMemory);
         Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_PVT_INTERACTIVE_PHASE,System.privateMemory);
         Global.loadingMetricsRecorder.addMemoryTimestampMetric(Global.loadingMetricsRecorder.KEY_MEM_MILESTONE_INTERACTIVE_PHASE,GlobalEngine.currentTime.toString());
         profCookie = RuntimeProfiler.enter(FarmGameModules.FarmGameInitComplete);
         this.m_initComplete = true;
         ProdAggregator.enableZtrack(true);
         ExternalUtil.instance.call("closeOnLoadPopDialogs");
         GlobalEngine.log("FarmGame","AllInitComplete!");
         this.gameUpdateFunction = this.onEnterFrame;
         GlobalEngine.stage.addEventListener(Event.MOUSE_LEAVE,this.onMouseLeaveFrame);
         viewport = GlobalEngine.viewport as FarmIsoViewport;
         viewport.width = this.stage.stageWidth;
         viewport.height = this.stage.stageHeight;
         addChild(viewport);
         viewport.scaleX = viewport.scaleY = 1;
         Global.worldSettingsManager.zoomCenterViewportPostWorldLoad();
         Global.enableDebugKeys = Config.DEBUG_MODE || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_DEBUG_KEYS) != 0;
         Global.ui.performanceHudEnabled = Config.DEBUG_MODE;
         if(Global.enableDebugKeys)
         {
            if(!(contextMenu is NativeMenu))
            {
               (contextMenu as ContextMenu).customItems.push(this.createContextMenuItem("Toggle Perf Tracker",function(cme:ContextMenuEvent):void
               {
                  Global.ui.performanceHudEnabled = !Global.ui.performanceHudEnabled;
               }),this.createContextMenuItem("Toggle UI",function(cme:ContextMenuEvent):void
               {
                  Global.ui.visible = !Global.ui.visible;
               }),this.createContextMenuItem("Increment Defcon Level",function(cme:ContextMenuEvent):void
               {
                  var cmi:* = cme.target as ContextMenuItem;
                  if(DefconManager.defconLevel < DefconManager.MAX_LEVEL)
                  {
                     DefconManager.debugIncrementLevel();
                     cmi.enabled = DefconManager.defconLevel < DefconManager.MAX_LEVEL;
                  }
               }),this.createContextMenuItem("Decrement Defcon Level",function(cme:ContextMenuEvent):void
               {
                  var cmi:* = cme.target as ContextMenuItem;
                  if(DefconManager.defconLevel > DefconManager.MIN_LEVEL)
                  {
                     DefconManager.debugDecrementLevel();
                     cmi.enabled = DefconManager.defconLevel > DefconManager.MIN_LEVEL;
                  }
               }),this.createContextMenuItem("Lock Defcon Level",function(cme:ContextMenuEvent):void
               {
                  var cmi:* = cme.target as ContextMenuItem;
                  DefconManager.debugToggleLevelLock();
                  cmi.caption = (DefconManager.debugLock ? "Unlock" : "Lock") + " Defcon Level";
               }),this.createContextMenuItem("Toggle Animation Focus Rect",function(cme:ContextMenuEvent):void
               {
                  DefconManager.debugToggleVisualFocusRect();
               }),this.createContextMenuItem("Toggle R-Tree Rects",function(cme:ContextMenuEvent):void
               {
                  Global.world.debugToggleVisualRTree();
               }));
               if(Global.world.terrainMap is InvisibleTerrainMap)
               {
                  (contextMenu as ContextMenu).customItems.push(this.createContextMenuItem("Toggle Terrain",function(cme:ContextMenuEvent):void
                  {
                     var invisibleTerrainMap:* = Global.world.terrainMap as InvisibleTerrainMap;
                     invisibleTerrainMap.debugVisibility = !invisibleTerrainMap.debugVisibility;
                     GlobalEngine.viewport.setDirty();
                     invisibleTerrainMap.setDirty(true);
                  }));
               }
            }
         }
         addChild(Global.ui);
         UI.pumpPopupQueue();
         if(GlobalEngine.zaspManager)
         {
            GlobalEngine.zaspManager.gameNumberCallback = Global.world.getNumObjects;
            GlobalEngine.zaspManager.gameDetailCallback = this.getDetailString;
            GlobalEngine.zaspManager.zaspInteractive();
         }
         GlobalEngine.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onStageMouseMove,false,3);
         GlobalEngine.stage.addEventListener(MouseEvent.CLICK,this.onStageMouseClick,false,3);
         GlobalEngine.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onStageKeyDown,false,3);
         dispatchEvent(new Event(Event.COMPLETE));
         transactionManager = TransactionManager.getInstance();
         transactionManager.addEventListener(TransactionFaultEvent.FAULT,this.onTransactionFault);
         transactionManager.addEventListener(TransactionEvent.QUEUE_LIMIT_EXCEEDED,this.onTransactionQueueLimitExceeded);
         transactionManager.addEventListener(TransactionEvent.QUEUE_LIMIT_NORMAL,this.onTransactionQueueLimitNormal);
         transactionManager.addEventListener(TransactionEvent.VERSION_MISMATCH,this.onTransactionVersionMismatch);
         transactionManager.addEventListener(TransactionFaultEvent.RECONNECTING,onTransactionReconnecting);
         transactionManager.addEventListener(TransactionEvent.RECONNECTED,onReconnectSuccess);
         transactionManager.addEventListener(TransactionFaultEvent.RETRY_LOGGING,onLogTransactionRetyInfo);
         strPopulationThreshold = GlobalEngine.getFlashVar("TRANSACTION_LATENCY_POPULATION") as String;
         if(strPopulationThreshold != null && strPopulationThreshold != "")
         {
            populationThreshold = parseInt(strPopulationThreshold);
            if(populationThreshold > 0 && Global.player != null)
            {
               uid_string = Global.player.uid;
               uid_string = uid_string.slice(-3);
               if(Number(uid_string) < populationThreshold)
               {
                  transactionManager.addEventListener(TransactionEvent.COMPLETED,this.onTransactionCompleted);
               }
            }
         }
         callbacks = {
            "switchOutFullScreen":this.switchOutFullScreen,
            "enableAllInput":this.enableAllInput,
            "disableAllInput":this.disableAllInput,
            "safeDisableAllInput":this.safeDisableAllInput,
            "logShowFeedDialog":this.logShowFeedDialog,
            "logCloseFeedDialog":this.logCloseFeedDialog,
            "logRetryFeed":this.logRetryFeed,
            "permissionDialogClosed":this.permissionDialogClosed,
            "emailPermissionDialogClosed":this.emailPermissionDialogClosed,
            "refreshGifts":this.refreshGifts,
            "adminCall":this.adminCall,
            "toggleTerminal":this.toggleTerminal,
            "visitNeighbor":WorldManager.externalNeighborVisit,
            "openNeighborPlumbing":this.openNeighborPlumbing,
            "addExternalIdleTask":this.addExternalIdleTask,
            "getScreenshot":FreezeManager.exportScreenshot,
            "triggerRequestPopup":FarmFacebookSocialNetwork.triggerRequestsRedirectPopup,
            "onCheckForPublishPermissionComplete":this.onCheckForPublishPermissionComplete,
            "inGamePaymentEnd":InGamePaymentsManager.onInGamePaymentEnd,
            "inGamePackPaymentEnd":PackPurchaseManager.onInGamePackPaymentEnd,
            "setFeedId":FacebookSocialNetwork.setFeedId,
            "addItemToGiftbox":this.addItemToGiftbox,
            "addQuestProgressItem":this.addQuestProgressItem,
            "refreshBuyerPromo":this.refreshBuyerPromo,
            "getCurrentMemoryUsage":this.getCurrentMemoryUsage,
            "getFlashVersion":this.getFlashVersion,
            "sendJsBusterReportData":this.sendJsBusterReportData,
            "showUserEnvInfoSuccessReportWindow":this.showUserEnvInfoSuccessReportWindow,
            "showUserEnvInfoFailureReportWindow":this.showUserEnvInfoFailureReportWindow,
            "popFreeGifts":FreeGiftSelectionWindow.popWindow,
            "popR2AddNeighbor":MFSRequestManager.getInstance().displayR2AddNeighborWindow,
            "shadowFeed":this.shadowFeed,
            "showGDPAtShareCount":CIPStartNow.showGDPAtShareCount,
            "muteAll":muteAll,
            "unmuteAll":unmuteAll,
            "viewSuccessInterstitialAd":InterstitialVideoAdIdleTask.viewSuccess,
            "viewErrorInterstitialAd":InterstitialVideoAdIdleTask.viewError,
            "showSubscriptionsSignupPopup":this.showSubscriptionsSignUpPopup,
            "getFlashValues":this.getFlashValues
         };
         try
         {
            if(ExternalInterface.available)
            {
               for(name in callbacks)
               {
                  ExternalInterface.addCallback(name,callbacks[name]);
               }
            }
            else
            {
               FarmStatsManager.count("errors","external_interface_not_supported");
            }
         }
         catch(error:Error)
         {
            FarmStatsManager.count("errors","external_interface_threw_error");
         }
         FarmLoadPhaseMonitor.updateLoadPhase(FarmLoadPhaseMonitor.INTERACTIVE);
         if(this.m_delayedWorldScoreInit)
         {
            GlobalEngine.initializationManager.add(new ExpansionWorldScoreInitAction(parameters.phpRevision));
         }
         Global.world.startPerformanceTracking();
         FarmGameUtil.logClientInfo();
         RuntimeProfiler.leave(profCookie);
         ExternalUtil.instance.call("farm_startFlashCrashTracking");
         if(GlobalEngine.isFlashVarSetAndTrue("OPS_TRACK_MEMORY_TRENDING"))
         {
            delay = Number(GlobalEngine.getFlashVar("OPS_MEMORY_TRACKING_TIMEINTERVAL_MINUTES")) * 1000 * 60;
            myTimer = new Timer(delay);
            myTimer.addEventListener(TimerEvent.TIMER,this.sendMemoryStats);
            myTimer.start();
         }
      }
      
      public function sendMemoryStats(event:TimerEvent) : void
      {
         var timeInterval:int = 0;
         var world:String = Global.worldManager.currentWorldType;
         var memory:int = System.totalMemory >> 20;
         var sequenceID:String = GlobalEngine.getFlashVar("sequence_id").toString();
         if(!this.m_lastPerfUpdate)
         {
            timeInterval = int(GlobalEngine.getFlashVar("OPS_MEMORY_TRACKING_TIMEINTERVAL_MINUTES"));
         }
         else
         {
            timeInterval = this.m_lastPerfUpdate + int(GlobalEngine.getFlashVar("OPS_MEMORY_TRACKING_TIMEINTERVAL_MINUTES"));
         }
         StatsManager.count("fv_ops_loading_metrics","memory_trending",sequenceID,timeInterval.toString(),"",world,memory);
         this.m_lastPerfUpdate = timeInterval;
      }
      
      public function getFlashValues() : Object
      {
         var statsData:Object = {};
         statsData["sessionTime"] = GlobalEngine.currentTime / 1000 / 60;
         statsData["memory"] = System.totalMemory >> 20;
         return statsData;
      }
      
      public function preloadComplete() : void
      {
         GlobalEngine.info("FarmGame","preloadComplete");
         Global.preloaderComplete = true;
         UI.pumpPopupQueue();
      }
      
      protected function onWorldLoadStarted(ev:Event) : void
      {
         ev.currentTarget.removeEventListener(LoaderEvent.WORLD_LOAD_STARTED,this.onWorldLoadStarted);
      }
      
      protected function onAllHighPriorityLoaded(ev:Event) : void
      {
         var curMemory:Number;
         var sampleStr:String;
         var sampleRate:int = 0;
         var loadingManager:LoadingManager = null;
         var zcLoadingManager:ZCacheLoadingManager = null;
         var statClass:String = null;
         var zcKbLoaded:int = 0;
         var kbLoaded:int = 0;
         ev.currentTarget.removeEventListener(LoaderEvent.ALL_HIGH_PRIORITY_LOADED,this.onAllHighPriorityLoaded);
         curMemory = System.totalMemoryNumber;
         if(curMemory < 0)
         {
            Global.loadingMetricsRecorder.addOptionalMetric(Global.loadingMetricsRecorder.OPT_MEM_NUM_LOAD_COMPLETE_PHASE,System.totalMemoryNumber);
         }
         Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_LOAD_COMPLETE_PHASE,curMemory);
         Global.loadingMetricsRecorder.addMemoryMetric(Global.loadingMetricsRecorder.KEY_MEM_PVT_LOAD_COMPLETE_PHASE,System.privateMemory);
         Global.loadingMetricsRecorder.addMemoryTimestampMetric(Global.loadingMetricsRecorder.KEY_MEM_MILESTONE_LOAD_COMPLETE_PHASE,GlobalEngine.currentTime.toString());
         sampleStr = GlobalEngine.getFlashVar("FLASHVAR_T6_LOAD_STATS_SAMPLE") as String;
         if(sampleStr != null && sampleStr != "")
         {
            sampleRate = 0;
            try
            {
               sampleRate = parseInt(sampleStr);
            }
            catch(err:Error)
            {
               ErrorManager.addError("Error parsing T6 asset load stat sample rate");
            }
            if(sampleRate > 0)
            {
               loadingManager = LoadingManager.getInstance();
               zcLoadingManager = loadingManager as ZCacheLoadingManager;
               statClass = "zcache_off";
               zcKbLoaded = 0;
               if(zcLoadingManager != null && zcLoadingManager.enabled && zcLoadingManager.zCache.allowed)
               {
                  statClass = "zcache_on";
                  zcKbLoaded = zcLoadingManager.zCacheBytesLoaded / 1024;
               }
               kbLoaded = loadingManager.getBytesLoaded() / 1024;
               FarmStatsManager.sample(sampleRate,"perf","asset_load","count",statClass,"","",loadingManager.getObjectsLoaded());
               FarmStatsManager.sample(sampleRate,"perf","asset_load","size",statClass,"","",kbLoaded);
               FarmStatsManager.sample(sampleRate,"perf","asset_load","network_size",statClass,"","",kbLoaded - zcKbLoaded);
               FarmStatsManager.sample(sampleRate,"perf","asset_load","zcache_size",statClass,"","",zcKbLoaded);
            }
         }
         this.m_initialAssetLoadComplete = true;
         FarmLoadPhaseMonitor.updateLoadPhase(FarmLoadPhaseMonitor.LOAD_COMPLETE);
         FarmZPreloaderManager.init();
         Global.hud.optionsMenu.syncOptions();
      }
      
      public function isAllHighPriorityLoadComplete() : Boolean
      {
         return this.m_initialAssetLoadComplete;
      }
      
      private function onTransactionFault(event:TransactionFaultEvent) : void
      {
         var msg:String = null;
         var funcName:String = null;
         this.m_lastStateDetail = this.getDetailString();
         if(Config.DEBUG_MODE)
         {
            UI.displayMessage("errorCode: " + event.errorType + ", errorData: " + event.errorData,0,null,"",true);
         }
         else if(event.errorType == Transaction.OUTDATED_GAME_VERSION)
         {
            this.onTransactionVersionMismatch();
         }
         else if(event.errorType == Transaction.MULTIPLE_GAME_INSTANCES)
         {
            this.showOOSDialogForMultipleLogins();
         }
         else if(event.errorType == Transaction.CONNECTION_DROPPED)
         {
            onConnectionDropped(event.errorData.toString());
         }
         else
         {
            if(Transaction.NO_ERROR.toString() == TransactionManager.lastError)
            {
               if(event.errorType)
               {
                  TransactionManager.lastError = event.errorType.toString();
               }
               else
               {
                  TransactionManager.lastError = FarmGame.CLIENT_SIDE_OOS_ERROR_CODE;
               }
               msg = "Client Side OOS: ";
               if(event.errorData)
               {
                  if(event.errorData is String)
                  {
                     msg += event.errorData;
                  }
                  else
                  {
                     msg += "unknown error, errorData of type " + typeof event.errorData;
                  }
               }
               else
               {
                  msg += "unknown error, no errorData";
               }
               TransactionManager.lastMsg = msg;
               if(event.transaction)
               {
                  funcName = event.transaction.getFunctionName();
                  if(funcName)
                  {
                     TransactionManager.lastFunc = funcName;
                  }
                  else
                  {
                     TransactionManager.lastFunc = "transaction name not set";
                  }
               }
               else
               {
                  TransactionManager.lastFunc = "unknown";
               }
            }
            this.showOOSDialog();
         }
      }
      
      private function showOOSDialog() : void
      {
         var window:FarmWindow = new FarmOOSWindow(this.sendCBReport,this.optedNotSendCBReport);
         UI.stopPopups(false);
         UI.displayPopup(window,false);
      }
      
      private function showOOSDialogForMultipleLogins() : void
      {
         var window:FarmWindow = new FarmOOSWindow(this.sendCBReport,this.optedNotSendCBReport,true);
         UI.stopPopups(false);
         UI.displayPopup(window,false);
      }
      
      private function showCloseGameDialog() : void
      {
         var message:String = ZLocUtils.t("FarmGame","MultipleGameInstances");
         UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
      }
      
      private function optedNotSendCBReport() : void
      {
         FarmStatsManager.count("crashBusters","count","user_opted_not_send");
         StatsManager.sendStats(true);
         setTimeout(FarmGameUtil.redirectHome,DELAY_FOR_STATS_SEND);
      }
      
      private function sendCBReport(event:TransactionFaultEvent = null) : void
      {
         FarmStatsManager.count("crashBusters","count","user_opted_send");
         var userReport:Object = {};
         FarmGameUtil.collectEnvironmentInfo(userReport);
         userReport["transactions"] = CBReportManager.instance.transactionReport;
         userReport["sentTransactions"] = CBReportManager.instance.transactionSentReport;
         userReport["lastTransactionFunc"] = TransactionManager.lastFunc;
         userReport["lastTransactionError"] = TransactionManager.lastError;
         userReport["sessionTime"] = GlobalEngine.currentTime;
         if(Global.player)
         {
            userReport["client_giftbox"] = Global.player.getGiftboxTrace();
         }
         userReport["ui_trace"] = getCBTrace();
         userReport["ui_detail"] = this.m_lastStateDetail;
         userReport["lastUncaughtClientException"] = getLastUncaughtException();
         FarmGameUtil.sendJavaScriptReport("cb.php",userReport,"crashBusters",this.sendUserReportComplete,FarmGameUtil.redirectHome);
         StatsManager.sendStats(true);
      }
      
      private function sendUserReportComplete(evt:Event) : void
      {
         FarmGameUtil.redirectHome(null,true);
      }
      
      private function onTransactionVersionMismatch(event:TransactionEvent = null) : void
      {
         var messageString:String = ZLocUtils.t("FarmGame","OutdatedGameVersion");
         if(event.message == "")
         {
            event.message = messageString;
         }
         if(Boolean(Global.flashHotParams["ENHANCED_DIALOG"]) && Global.flashHotParams["ENHANCED_DIALOG"] == "on")
         {
            UI.displayPopup(new GenericPopup(event.message,GenericPopup.TYPE_OK,FarmGameUtil.redirectHomeNoError,"assets/dialogs/FV_Enhanced.swf","",true));
         }
         else
         {
            UI.displayMessage(messageString,GenericPopup.TYPE_OK,FarmGameUtil.redirectHomeNoError,"",true);
         }
      }
      
      private function onTransactionCompleted(event:TransactionEvent) : void
      {
         var transaction:Transaction = null;
         var id:Number = NaN;
         var strMaxId:String = null;
         var maxId:Number = NaN;
         if(event != null)
         {
            transaction = event.transaction;
            if(transaction != null)
            {
               id = transaction.getId();
               FarmGameUtil.reportClientLog("\"Completed transaction\" func=" + transaction.getFunctionName() + " id=" + id + " queued=" + transaction.getQueueDuration().toFixed(3) + " exec=" + transaction.getExecutionDuration().toFixed(3));
               strMaxId = GlobalEngine.getFlashVar("TRANSACTION_LATENCY_MAX_ID") as String;
               if(strMaxId != null && strMaxId != "")
               {
                  maxId = parseInt(strMaxId);
                  if(id >= maxId)
                  {
                     TransactionManager.getInstance().removeEventListener(TransactionEvent.COMPLETED,this.onTransactionCompleted);
                  }
               }
            }
         }
      }
      
      private function onTransactionQueueLimitExceeded(event:TransactionEvent) : void
      {
         var message:String = null;
         if(this.m_warningDialog == null)
         {
            message = ZLocUtils.t("FarmGame","SavingFarm");
            ++this.m_warningDialogCount;
            FarmStatsManager.count("errors","savingFarm","popup_displayed","","","popups_this_session",this.m_warningDialogCount);
            this.m_warningDialogTime = GlobalEngine.currentTime;
            this.m_warningDialog = UI.displayMessage(message,GenericPopup.TYPE_MODAL,null,"",true);
            this.m_transactionQueueFullTimer = new Timer(TRANSACTION_QUEUE_FULL_TIMEOUT_SECS * FarmGameUtil.NUM_MSECS_IN_SECOND,1);
            this.m_transactionQueueFullTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onQueueLimitTimerDone);
            this.m_transactionQueueFullTimer.start();
         }
      }
      
      private function onTransactionQueueLimitNormal(event:TransactionEvent) : void
      {
         var timeUp:int = 0;
         if(this.m_warningDialog != null)
         {
            timeUp = Math.floor((GlobalEngine.currentTime - this.m_warningDialogTime) / 1000) as int;
            FarmStatsManager.count("errors","savingFarm","popup_removed","","","popup_display_time",timeUp);
            this.m_warningDialog.close();
            this.m_warningDialog = null;
         }
         if(this.m_transactionQueueFullTimer != null)
         {
            this.m_transactionQueueFullTimer.stop();
            this.m_transactionQueueFullTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onQueueLimitTimerDone);
            this.m_transactionQueueFullTimer = null;
         }
      }
      
      private function onQueueLimitTimerDone(event:TimerEvent) : void
      {
         this.m_warningDialog.close();
         this.m_warningDialog = null;
         this.m_transactionQueueFullTimer.stop();
         this.m_transactionQueueFullTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onQueueLimitTimerDone);
         this.m_transactionQueueFullTimer = null;
         FarmStatsManager.count("errors","savingFarm","popup_removed","timer_expired","showed_oos");
         var sessionTime:int = GlobalEngine.currentTime;
         var transactionLength:String = TransactionManager.getInstance().getCurrentTransactionSize() as String;
         FarmStatsManager.count("queue_limit_reached",transactionLength,"time_in_game","","","",sessionTime);
         TransactionManager.lastError = CLIENT_SIDE_OOS_ERROR_CODE;
         TransactionManager.lastMsg = "Client Side OOS: Transaction Queue Limit Timer Expired";
         this.showOOSDialog();
      }
      
      private function onStageMouseMove(e:MouseEvent) : void
      {
         StatsManager.notIdle();
         Global.world.incrementUserMoves();
         Global.appActive = true;
         UI.onStageMouseMove(e);
      }
      
      private function onStageMouseClick(e:MouseEvent) : void
      {
         Global.lastInputTick = GlobalEngine.currentTime;
         Global.appActive = true;
         Global.world.incrementUserClicks();
      }
      
      private function onStageKeyDown(e:KeyboardEvent) : void
      {
         var stop:Boolean = false;
         var w2ePlacement:String = null;
         Global.lastInputTick = GlobalEngine.currentTime;
         Global.appActive = true;
         if(!(e.target is TextField) && Global.enableDebugKeys)
         {
            GlobalEngine.log("Keyboard","Key down! keyCode: " + e.keyCode + ", ctrlKey: " + e.ctrlKey + ", altKey: " + e.altKey + ", shiftKey: " + e.shiftKey);
            stop = false;
            if(e.keyCode == Keyboard.P)
            {
               Global.ui.performanceHudEnabled = !Global.ui.performanceHudEnabled;
               stop = true;
            }
            else if(e.keyCode == Keyboard.U)
            {
               Global.ui.visible = !Global.ui.visible;
               stop = true;
            }
            else if(e.keyCode == Keyboard.F)
            {
               Utilities.toggleFullScreen();
               stop = true;
            }
            else if(e.keyCode == Keyboard.X)
            {
               if(Config.DEBUG_MODE)
               {
                  UI.clearPopupQueue();
               }
               stop = true;
            }
            else if(e.keyCode == Keyboard.EQUAL || e.keyCode == Keyboard.NUMPAD_ADD)
            {
               (GlobalEngine.viewport as FarmIsoViewport).zoomIn();
               stop = true;
            }
            else if(e.keyCode == Keyboard.MINUS || e.keyCode == Keyboard.NUMPAD_SUBTRACT)
            {
               (GlobalEngine.viewport as FarmIsoViewport).zoomOut();
               stop = true;
            }
            else if(e.keyCode == Keyboard.NUMBER_1)
            {
               DefconManager.debugDecrementLevel();
               stop = true;
            }
            else if(e.keyCode == Keyboard.NUMBER_2)
            {
               DefconManager.debugIncrementLevel();
               stop = true;
            }
            else if(e.keyCode == Keyboard.NUMBER_3)
            {
               DefconManager.debugToggleLevelLock();
               stop = true;
            }
            else if(e.keyCode == Keyboard.NUMBER_4)
            {
               DefconManager.debugToggleVisualFocusRect();
               stop = true;
            }
            else if(e.ctrlKey && e.keyCode == Keyboard.SEMICOLON)
            {
               w2ePlacement = HUD.W2E_SLOT_ID_HUD_ICON;
            }
            else if(e.keyCode == Keyboard.F5)
            {
               this.toggleTerminal();
            }
            if(stop)
            {
               e.stopImmediatePropagation();
               e.stopPropagation();
            }
         }
      }
      
      override protected function onError(error:ErrorEvent) : void
      {
         var preloaderComplete:Boolean = false;
         var errorType:String = null;
         var bDisplayError:Boolean = Global.player == null || !Global.player.isAutomatedQA;
         if(Config.DEBUG_MODE)
         {
            preloaderComplete = Global.preloaderComplete;
            if(!preloaderComplete)
            {
               Global.preloaderComplete = true;
            }
            if(bDisplayError)
            {
               UI.displayMessage(error.text);
            }
            if(Global.ui != null && Global.ui.parent == null)
            {
               addChild(Global.ui);
               UI.pumpPopupQueue();
            }
            if(Global.preloaderComplete != preloaderComplete)
            {
               Global.preloaderComplete = preloaderComplete;
            }
         }
         if(bDisplayError && Global.flashHotParams[FEATURE_FLASHPARAM_REPORT_ERRORS] > 0)
         {
            FarmGameUtil.reportClientLog(error.text);
            errorType = "unknown";
            if(error)
            {
               errorType = error.type;
            }
            FarmStatsManager.count("error","ErrorManager",errorType);
            StatsManager.sendStats(true);
         }
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var profCookie:int = RuntimeProfiler.enter(FarmGameModules.FarmGameOnEnterFrame);
         if(GlobalEngine.zaspManager)
         {
            GlobalEngine.zaspManager.preUpdate();
         }
         if(Global.world)
         {
            Global.world.updateWorld();
         }
         if(Global.ui)
         {
            Global.ui.update();
         }
         if(LeaderboardManager.initialized)
         {
            LeaderboardManager.update();
         }
         Global.farmGameSettingsManager.parseItemsBatch();
         if(GlobalEngine.zaspManager)
         {
            GlobalEngine.zaspManager.postUpdate();
         }
         RuntimeProfiler.leave(profCookie);
      }
      
      public function setGameUpdateFunction(updateFunction:Function) : void
      {
         this.gameUpdateFunction = updateFunction;
      }
      
      public function onCheckForPublishPermissionComplete(hasPublishPermission:Boolean, hasEmailPermission:Boolean) : void
      {
         if(GlobalEngine.socialNetwork as FacebookSocialNetwork)
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).onCheckForPublishPermissionComplete(hasPublishPermission,hasEmailPermission);
         }
      }
      
      public function resetGameUpdateFunction() : void
      {
         this.gameUpdateFunction = this.onEnterFrame;
      }
      
      private function onMouseLeaveFrame(event:Event) : void
      {
         Global.appActive = false;
      }
      
      public function switchOutFullScreen() : void
      {
         Utilities.setFullScreen(false);
      }
      
      override public function disableAllInput() : void
      {
         super.disableAllInput();
         if(this.m_initComplete)
         {
            FreezeManager.freezeAll();
         }
      }
      
      public function safeDisableAllInput() : void
      {
         super.disableAllInput();
         if(this.m_initComplete)
         {
            FreezeManager.freezeRender();
         }
      }
      
      override public function enableAllInput() : void
      {
         super.enableAllInput();
         FreezeManager.thaw();
      }
      
      public function logShowFeedDialog() : void
      {
         this.m_feedOpenTime = GlobalEngine.currentTime;
         FarmStatsManager.featureSample("farm_world_action","Feed_Open",TPublishUserAction.category,TPublishUserAction.subcategory,TPublishUserAction.creative);
      }
      
      public function permissionDialogClosed(userAccepted:Boolean) : void
      {
         GlobalEngine.socialNetwork.onPermissionDialogClosed(userAccepted);
      }
      
      public function emailPermissionDialogClosed(userAccepted:Boolean, permissionRequestSource:Number) : void
      {
         EmailManager.emailPermissionDialogClosed(userAccepted,permissionRequestSource);
      }
      
      public function shadowFeed(feedPayload:String) : void
      {
         TransactionManager.addTransaction(new TZFeed(feedPayload));
      }
      
      public function showUserEnvInfoFailureReportWindow(externalReference:String) : void
      {
         var window:FarmWindow = new FarmFeedIssueWindow(ZLocUtils.t("Dialogs","FarmFeedIssueWindowFail_Title"),ZLocUtils.t("Dialogs","FarmFeedIssueWindowFail_mainMessage"),FarmFeedIssueWindow.feedResultFail,externalReference);
         if(window)
         {
            UI.displayPopup(window);
         }
         else
         {
            StatsManager.count("jsbuster","error","FarmGame","showUserEnvInfoFailureReportWindow","couldNotCreateFarmFeedIssueWindow");
         }
      }
      
      public function showUserEnvInfoSuccessReportWindow() : void
      {
         var window:FarmWindow = new FarmFeedIssueWindow(ZLocUtils.t("Dialogs","FarmFeedIssueWindowSuccess_Title"),ZLocUtils.t("Dialogs","FarmFeedIssueWindowSuccess_mainMessage"),FarmFeedIssueWindow.feedResultSuccess,"");
         if(window)
         {
            UI.displayPopup(window);
         }
         else
         {
            StatsManager.count("jsbuster","error","FarmGame","showUserEnvInfoSuccessReportWindow","couldNotCreateFarmFeedIssueWindow");
         }
      }
      
      public function sendJsBusterReportData(userEnvReport:Object) : void
      {
         if(Boolean(userEnvReport) && userEnvReport != "")
         {
            TransactionManager.addTransaction(new TSendUserEnvReport(userEnvReport),true);
         }
         else
         {
            StatsManager.count("jsbuster","error","FarmGame","sendJsBusterReportData","userEnvReportIsNotValid");
         }
      }
      
      public function getCurrentMemoryUsage() : Number
      {
         return System.totalMemory;
      }
      
      public function getFlashVersion() : String
      {
         return Capabilities.version;
      }
      
      public function refreshBuyerPromo() : void
      {
         BuyerPromoUtility.refreshCurrentPromo();
      }
      
      public function refreshGifts() : void
      {
         TransactionManager.addTransaction(new TRefreshGifts(),true);
      }
      
      public function adminCall(namespace:String, functionName:String, parameters:Array) : void
      {
         if(Config.DEBUG_MODE)
         {
            InGameConsoleManager.simulateCommand(functionName,parameters,namespace);
         }
      }
      
      public function toggleTerminal() : void
      {
         if(Config.DEBUG_MODE)
         {
            if(InGameConsoleManager.isConsoleOn() == false)
            {
               InGameConsoleManager.startConsole();
            }
            else
            {
               InGameConsoleManager.closeConsole();
            }
         }
      }
      
      public function addItemToGiftbox(itemName:String, qty:Number) : void
      {
         Global.player.addGift(itemName,"0",qty);
         UI.refreshGiftBoxWindow();
      }
      
      public function addQuestProgressItem(itemName:String, qty:Number) : void
      {
         var consumable:CQuestProgress = new CQuestProgress(itemName);
         if(consumable.canUse())
         {
            consumable.consume(true,false);
         }
         else
         {
            this.addItemToGiftbox(itemName,qty);
         }
      }
      
      public function openNeighborPlumbing(userId:String = "0") : void
      {
         var friendToAdd:Friend = null;
         if(userId != "0")
         {
            friendToAdd = Global.friendManager.getAppFriendData(userId);
            if(Boolean(friendToAdd) && !friendToAdd.hasNeighborData)
            {
               UI.displayPopup(new AddSpecificNeighborWindow(friendToAdd));
            }
         }
      }
      
      public function addExternalIdleTask(callback:String = "") : void
      {
         IdleTaskQueue.getInstance().addTask(new ExternalIdleTask(callback));
      }
      
      public function logCloseFeedDialog(feedback:Object = null, isException:Boolean = false) : void
      {
         var timeString:String = null;
         var feedbackStr:String = null;
         var subcounter:String = null;
         var category:String = null;
         var subcategory:String = null;
         var creative:String = null;
         var timeDiff:int = GlobalEngine.currentTime - this.m_feedOpenTime;
         timeDiff = int(timeDiff / 1000);
         if(timeDiff > 60)
         {
            timeString = ">1 minute";
         }
         else
         {
            timeString = timeDiff.toString() + " seconds";
         }
         if(feedback != null && feedback is String)
         {
            feedbackStr = feedback as String;
            if(isException)
            {
               FarmStatsManager.featureSample("farm_world_action","Feed_Exception",feedbackStr,timeString);
            }
            else
            {
               subcounter = "Feed_Unknown";
               category = TPublishUserAction.category;
               subcategory = TPublishUserAction.subcategory;
               creative = TPublishUserAction.creative;
               switch(feedbackStr)
               {
                  case "posted":
                     subcounter = "Feed_Published";
                     break;
                  case "closed":
                     subcounter = "Feed_Closed";
                     break;
                  case "skipped":
                     subcounter = "Feed_Skipped";
                     break;
                  default:
                     subcounter = "Feed_Unknown";
               }
               FarmStatsManager.featureSample("farm_world_action",subcounter,category,subcategory,creative,timeString);
            }
         }
         else
         {
            FarmStatsManager.featureSample("farm_world_action","Feed_Close",timeString);
         }
         FreezeManager.thaw();
         GlobalEngine.socialNetwork.onFeedClosed();
      }
      
      public function logRetryFeed() : void
      {
         FarmStatsManager.featureSample("farm_world_action","Feed_Retry");
      }
      
      protected function getDetailString() : String
      {
         var result:String = "";
         if(Boolean(Global.ui) && UI.isShowingPopup())
         {
            result = UI.getCurrentPopupName();
         }
         else if(!InitializationManager.getInstance().haveAllCompleted())
         {
            result = "initializing";
         }
         else if(Global.world != null)
         {
            result = getQualifiedClassName(Global.world.getTopGameMode());
         }
         else
         {
            result = "unknown";
         }
         if(result == "")
         {
            result = "emptyString";
         }
         return result;
      }
      
      private function createContextMenuItem(caption:String, handler:Function) : ContextMenuItem
      {
         var cmi:ContextMenuItem = new ContextMenuItem(caption);
         cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,handler);
         return cmi;
      }
      
      private function showSubscriptionsSignUpPopup() : void
      {
         if(SubscriptionsManager.isTrialSubscriptionActive() || SubscriptionsManager.inTrialPeriod())
         {
            SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_SIGNUP_POPUP,{
               "source":"toptab",
               "sub_type":SubscriptionsManager.TRIAL_SUBSCRIPTION_CODE
            }));
         }
         else
         {
            SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_SIGNUP_POPUP,{"source":"toptab"}));
         }
      }
   }
}

