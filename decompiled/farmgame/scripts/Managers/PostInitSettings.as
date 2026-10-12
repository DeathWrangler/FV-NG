package Managers
{
   import Cache.Classes.ZCacheUtil;
   import Classes.AsyncCall;
   import Classes.BushelReportActionDropHandler;
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.DooberUpdateActionDropHandler;
   import Classes.FlowerShackDooberUpdateActionDropHandler;
   import Classes.GypsyTraderActionDropHandler;
   import Classes.Idle.*;
   import Classes.LoyaltyProgramPostInit;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.ExpansionEarlyAccessGiftingData;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.DynamicIconQueue;
   import Display.GenericPopup;
   import Display.HUD.HUDWidgets.HudBottomBookmarkOptButton;
   import Display.HUD.HUDWidgets.HudBottomFVTECurrencyConversionButton;
   import Display.HUD.HUDWidgets.HudBottomFvPluginButton;
   import Display.HUD.HUDWidgets.HudBottomLEBundleButton;
   import Display.HUD.HUDWidgets.HudMessageNotification;
   import Display.HUD.HudBookMarkButton;
   import Display.MOTD;
   import Display.RevisedTOSPopUp;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Init.PostInitActionHandlers.PostInitToaster;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Managers.OrderBoard.CanadaInnovationManager;
   import Managers.OrderBoard.FarmersMarketInnovationManager;
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Managers.OrderBoard.IrelandInnovationManager;
   import Managers.OrderBoard.TropicalMarketInnovationManager;
   import Transactions.TBuyAndSendPresent;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.Amex.AmexTreeStatusWindow;
   import Widgets.Windows.Amex.AmexTreeToasterWindow;
   import Widgets.Windows.BookmarkOpt2019InstallWindow;
   import Widgets.Windows.BookmarkOpt2019RewardWindow;
   import Widgets.Windows.CoOpFinalGrantReward;
   import Widgets.Windows.ContingencyBuildableBonusRewardWindow;
   import Widgets.Windows.FVFlashHelper2018FeatureWindow;
   import Widgets.Windows.GenericRewardWindow;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.IconToasterWindow;
   import Widgets.Windows.MFSEarlyAccessGift;
   import Widgets.Windows.MarketingEmailOptinFeatureWindow;
   import Widgets.Windows.PrizeMachine.PrizeMachineWindow;
   import Widgets.Windows.SpecialLEBundleWindow;
   import Widgets.Windows.VIPPhoneFeatureWindow;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.utils.getDefinitionByName;
   
   public class PostInitSettings
   {
      
      private static var m_bookmarkOptRewardWindow:BookmarkOpt2019RewardWindow;
      
      private static var m_bookmarkOptInstallWindow:BookmarkOpt2019InstallWindow;
      
      private static var m_LEBundleWindow:SpecialLEBundleWindow;
      
      private static var m_LEBundleHud:HudBottomLEBundleButton;
      
      private static var m_FvPluginHud:HudBottomFvPluginButton;
      
      private static var m_BookmarkOptHud:HudBottomBookmarkOptButton;
      
      private static var m_FvPluginWindow:FVFlashHelper2018FeatureWindow;
      
      private static var m_ContigencyBonusWindow:ContingencyBuildableBonusRewardWindow;
      
      private static var m_messageNotification:HudMessageNotification;
      
      private static var m_bookmarkButton:HudBookMarkButton;
      
      private static var m_FVTEHud:HudBottomFVTECurrencyConversionButton;
      
      public static const ZRUNTIME_KEY_DREAMFISH_PREMARKETING_POPUP:String = "DREAMFISH_PREMARKETING_POPUP";
      
      public static const ZRUNTIME_KEY_FORCE_FLASHPLAYER_PLUGIN_WINDOW:String = "FORCE_FLASHPLAYER_PLUGIN_WINDOW";
      
      private static const MARKETING_OPTIN_SERVICE_NAME:String = "MarketingEmailOptinService";
      
      public static const MARKETING_OPTIN_ELIGIBLILITY_CHECKED:String = "MarketingEmailOpt_checked";
      
      public static const MARKETING_OPTIN_ELIGIBLE:String = "MarketingEmailOpt_Eligible";
      
      public static const MARKETING_OPTIN_REWARD_GRANT_FLAG:String = "MarketingEmailOptinRewardGranted";
      
      public static const MARKETING_OPTIN_DECLINE_FLAG:String = "MarketingEmailOptin_DECLINE";
      
      private static const BOOKMARK_OPT2019_SERVICE_NAME:String = "BookmarkOpt2019Service";
      
      public static const BOOKMARKOPT_REWARDGRANTED_FLAG:String = "BookmarkOpt2019_RewardGranted";
      
      public static const BOOKMARKOPT_POPUP_SHOWN_FLAG:String = "BookmarkOpt2019_PopupShown";
      
      public static const BOOKMARK_OPT_REWARD_FC:* = 5;
      
      public static const SESSION_SEEN_MOTD:String = "SessionSeenMOTD";
      
      public static const SESSION_SEEN_NEXT_SEASON_MOTD:String = "SessionSeenNSMOTD";
      
      public static const FEATURE_NAME:String = "chromeplugin2018";
      
      public static const GUILD_STOP_FLAG:String = "gguild_stop_flag";
      
      public static const ZRUNTIME_KEY_TOP_BOOKMARK_HUD:String = "ENABLE_TOP_BOOKMARK_HUD";
      
      public static const ZRUNTIME_KEY_BOTTOM_BOOKMARK_HUD:String = "ENABLE_BOTTOM_BOOKMARK_HUD";
      
      public static const GRANT_FC_FLAG:String = "FC_GRANT_FV_SUNSET";
      
      public static const FC_VALUE:* = 200;
      
      public static const DIALOG_SUPPRESS_NONE:int = 0;
      
      public static const DIALOG_SUPPRESS_ALL:int = 1;
      
      public static var suppressDialogs:int = 0;
      
      private static const CORE_CLICK_FLOW_TOASTER_ICON:String = "assets/hud/Action_Menu/FV_Main_Walk_Icon.png";
      
      private static const CLICK_FLOW_IMPROVEMENTS:String = "CoreClickFlowImprovements";
      
      private static var m_classCompilingArray:Array = [GypsyTraderActionDropHandler,DooberUpdateActionDropHandler,BushelReportActionDropHandler,LoyaltyProgramPostInit,FlowerShackDooberUpdateActionDropHandler];
      
      protected var m_xml:XML = null;
      
      private var m_hasExecuted:Boolean = false;
      
      private var m_initUserResult:Object = null;
      
      private var m_postInitUserResult:Object = null;
      
      private var m_userActionLookup:Object = {};
      
      private var m_idleTaskLookup:Object = {};
      
      public var zCachePreloads:Array = [];
      
      public function PostInitSettings(xml:XML)
      {
         super();
         this.m_xml = xml;
      }
      
      public static function showVIPPhoneFeatureWindow(params:Object = null) : void
      {
         VIPPhoneFeatureWindow.launchVipPhoneFeature();
      }
      
      public static function simulatedNeighborVisitInit() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("SimulatedNeighborVisitService","simulateVisit"));
      }
      
      public static function showMOTD(params:Object = null) : void
      {
         var currentMOTD:Object = null;
         if(Global.player.getSeenSessionFlag(SESSION_SEEN_MOTD))
         {
            throw new Error("InitPopupSettings.showMOTD - motd has already been seen this session");
         }
         Global.player.setSeenSessionFlag(SESSION_SEEN_MOTD);
         if(Global.experimentManager.getExperimentVariant("fv_hg_motd_dont_suppress") > 0 || Global.worldManager.currentWorldType != HangingGardensManager.HANGING_GARDENS)
         {
            currentMOTD = Global.player.currentMOTD;
            if(currentMOTD)
            {
               MOTD.displayMOTD(currentMOTD,true);
            }
         }
      }
      
      public static function showRevisedTOS(params:Object = null) : void
      {
         var tosMessage:String = null;
         if(!Global.player.getSeenFlag("tos_revised_2020"))
         {
            tosMessage = ZLocUtils.t("Dialogs","UpdatedTOS2018");
            tosMessage = "Zynga has revised its <a href=\"https://www.zynga.com/legal/terms-of-service\" style=\'text-decoration: underline;\' target=\'_blank\'>Terms of Service</a> and <a href=\"https://www.zynga.com/privacy/policy\" style=\'text-decoration: underline;\' target=\'_blank\'>Privacy Policy</a>.\n\nPlease take some time to read and understand these important legal documents.\n\nBy clicking the \"Accept\" button below, you agree to the Terms of Service and acknowledge the Privacy Policy applies.";
            UI.displayPopup(new RevisedTOSPopUp(tosMessage,GenericPopup.TYPE_OK,onTOSAccepted,"assets/dialogs/FV_GDPR_PopUp.swf","",true),false,"showRevisedTOS",true,true);
         }
      }
      
      private static function onTOSAccepted(e:Event) : void
      {
         FarmStatsManager.count("TOS_Clicked","tos_revised_2020",GlobalEngine.currentTime.toString());
         Global.player.setSeenFlag("tos_revised_2020",true);
      }
      
      public static function showNextSeasonMOTD(initParams:Object, params:Object = null) : void
      {
         var worldType:String = null;
         var nextPlayerSeason:int = 0;
         if(!Global.player.getSeenSessionFlag(SESSION_SEEN_NEXT_SEASON_MOTD) && params.hasOwnProperty("worldType"))
         {
            worldType = params.worldType;
            nextPlayerSeason = WorldSeasonsManager.getInstance().getNextPlayerSeason(worldType);
            WorldSeasonsManager.getInstance().showGrantMOTDForSeason(worldType,nextPlayerSeason,loadNextSeason);
            Global.player.setSeenSessionFlag(SESSION_SEEN_NEXT_SEASON_MOTD);
         }
      }
      
      public static function showGenericNextSeasonMOTD(initParams:Object, params:Object = null) : void
      {
         var worldType:String = null;
         var nextPlayerSeason:int = 0;
         if(params.hasOwnProperty("worldType") && params["worldType"] != null)
         {
            worldType = params.worldType;
            if(!Global.player.getSeenSessionFlag(worldType + "_" + SESSION_SEEN_NEXT_SEASON_MOTD))
            {
               nextPlayerSeason = WorldSeasonsManager.getInstance().getNextPlayerSeason(worldType);
               WorldSeasonsManager.getInstance().showGrantMOTDForSeason(worldType,nextPlayerSeason,loadNextSeason);
               Global.player.setSeenSessionFlag(worldType + "_" + SESSION_SEEN_NEXT_SEASON_MOTD);
            }
         }
      }
      
      private static function loadNextSeason(worldType:String) : void
      {
         if(Global.worldManager.currentWorldType != worldType)
         {
            Global.worldManager.swapFarm(worldType,true,true);
         }
         else
         {
            Global.worldManager.loadNextSeason(worldType);
         }
      }
      
      public static function showLQCongratulationsWindow(params:Object = null) : void
      {
         var LQManager:LimitedQuantityBundleManager = LimitedQuantityBundleManager.getInstance();
         LQManager.showCongratulationsWindow(LimitedQuantityBundleManager.EL_DORADO_BUNDLE_NAME);
      }
      
      public static function forceGrantWhiteWinterRewards(params:Object = null) : void
      {
         var WWManager:WhitewinterInnovationManager = WhitewinterInnovationManager.getInstance();
         if(WWManager)
         {
            WWManager.forceGrantWhiteWinterRewards();
         }
      }
      
      public static function forceGrantTuscanyInnovationBonusReward(params:Object = null) : void
      {
         var tuscanyInnovationManager:TuscanyInnovationManager = TuscanyInnovationManager.getInstance();
         if(!tuscanyInnovationManager)
         {
         }
      }
      
      public static function forceGrantHalloween2019InnovationBonusReward(params:Object = null) : void
      {
         var spookyInnovationManager:Halloween2019InnovationManager = Halloween2019InnovationManager.getInstance();
         if(spookyInnovationManager)
         {
            spookyInnovationManager.featureEnd();
         }
      }
      
      public static function forceGrantCanadaInnovationBonusReward(params:Object = null) : void
      {
         var canadaInnovationManager:CanadaInnovationManager = CanadaInnovationManager.getInstance();
         if(canadaInnovationManager)
         {
            canadaInnovationManager.featureEnd();
         }
      }
      
      public static function forceGrantBoraboraInnovationBonusReward(params:Object = null) : void
      {
         var boraboraInnovationManager:BoraBoraInnovationManager = BoraBoraInnovationManager.getInstance();
         if(Boolean(boraboraInnovationManager) && Global.player.getSeenFlag("bbiShown"))
         {
            boraboraInnovationManager.featureEnd();
         }
      }
      
      public static function forceShowAnimalSAnctuaryV2FinalWindow(params:Object = null) : void
      {
         var animalSanctuaryV2Manager:AnimalSanctuaryV2Manager = AnimalSanctuaryV2Manager.getInstance();
         if(Boolean(animalSanctuaryV2Manager) && !Global.player.getSeenFlag("asV2"))
         {
            animalSanctuaryV2Manager.featureEnd();
            Global.player.setSeenFlag("asV2");
         }
      }
      
      public static function forceGrantGiftRacing2019BonusReward(params:Object = null) : void
      {
         var winterRacing2019Manager:WinterRacingFeatureManager = WinterRacingFeatureManager.getInstance();
         if(winterRacing2019Manager)
         {
            winterRacing2019Manager.grantBonusReward();
         }
      }
      
      public static function forceGrantBoatRacing2020BonusReward(params:Object = null) : void
      {
         var boatRacing2020Manager:BoatRushManager = BoatRushManager.getInstance();
         if(boatRacing2020Manager)
         {
            boatRacing2020Manager.grantBonusReward();
         }
      }
      
      public static function forceGrantRussiaInnovationBonusReward(params:Object = null) : void
      {
         var russiaInnovationManager:RussiaInnovationManager = RussiaInnovationManager.getInstance();
         if(russiaInnovationManager)
         {
            russiaInnovationManager.grantBonusReward();
         }
      }
      
      public static function forceGrantIsraelInnovationBonusReward(params:Object = null) : void
      {
         var israelInnovationManager:IsraelInnovationManager = IsraelInnovationManager.getInstance();
         if(israelInnovationManager)
         {
            israelInnovationManager.grantBonusReward();
         }
      }
      
      public static function forceGrantWinternordInnovationCommunityReward(params:Object = null) : void
      {
         var winternordInnovationManger:WinternordInnovationManager = WinternordInnovationManager.getInstance();
         if(winternordInnovationManger)
         {
            winternordInnovationManger.initializeCommunityProgress();
         }
      }
      
      public static function forceGrantWinternordInnovationWeeklyReward(params:Object = null) : void
      {
         var winternordInnovationManger:WinternordInnovationManager = WinternordInnovationManager.getInstance();
         if(winternordInnovationManger)
         {
            winternordInnovationManger.onRedeemStarted();
         }
      }
      
      public static function forceGrantTwentiesInnovationWeeklyReward(params:Object = null) : void
      {
         var twentiesInnovationManger:TwentiesInnovationManager = TwentiesInnovationManager.getInstance();
         if(twentiesInnovationManger)
         {
            twentiesInnovationManger.onRedeemStarted();
         }
      }
      
      public static function forceGrantPumpkinPartyInnovationWeeklyReward(params:Object = null) : void
      {
         var pumpkinpartyInnovationManger:PumpkinPartyInnovationManager = PumpkinPartyInnovationManager.getInstance();
         if(pumpkinpartyInnovationManger)
         {
            pumpkinpartyInnovationManger.onRedeemStarted();
         }
      }
      
      public static function forceGrantIrelandInnovationWeeklyReward(params:Object = null) : void
      {
         var irelandInnovationManger:IrelandInnovationManager = IrelandInnovationManager.getInstance();
         if(irelandInnovationManger)
         {
            irelandInnovationManger.onRedeemStarted();
         }
      }
      
      public static function forceGrantWinternordInnovationChristmasReward(params:Object = null) : void
      {
         var winternordInnovationManger:WinternordInnovationManager = WinternordInnovationManager.getInstance();
         if(winternordInnovationManger)
         {
            winternordInnovationManger.grantChristmasRewardOnFeatureExpiry();
         }
      }
      
      public static function forceGrantSouthindiaInnovationBonusReward(params:Object = null) : void
      {
         var southindiaInnovationManager:SouthindiaInnovationManager = SouthindiaInnovationManager.getInstance();
         if(southindiaInnovationManager)
         {
            southindiaInnovationManager.grantBonusReward();
         }
      }
      
      public static function forceGrantDec19InnovationBonusReward(params:Object = null) : void
      {
         var dec19InnovationManager:Dec19InnovationManager = Dec19InnovationManager.getInstance();
         if(dec19InnovationManager)
         {
            dec19InnovationManager.grantBonusReward();
         }
      }
      
      public static function forceGrantFarmersMarketInnovationBonusReward(params:Object = null) : void
      {
         var farmersMarketInnovationManager:FarmersMarketInnovationManager = FarmersMarketInnovationManager.getInstance();
         if(farmersMarketInnovationManager)
         {
            farmersMarketInnovationManager.grantFinalReward();
         }
      }
      
      public static function forceGrantFarmersMarketInnovationLeaderBoardReward(params:Object = null) : void
      {
         var farmersMarketInnovationManager:FarmersMarketInnovationManager = FarmersMarketInnovationManager.getInstance();
         if(farmersMarketInnovationManager)
         {
            farmersMarketInnovationManager.onRedeemStarted();
         }
      }
      
      public static function forceGrantTropicalMarketInnovationBonusReward(params:Object = null) : void
      {
         var tropicalMarketInnovationManager:TropicalMarketInnovationManager = TropicalMarketInnovationManager.getInstance();
         if(tropicalMarketInnovationManager)
         {
            tropicalMarketInnovationManager.grantFinalReward();
         }
      }
      
      public static function forceGrantTropicalMarketInnovationLeaderBoardReward(params:Object = null) : void
      {
         var tropicalMarketInnovationManager:TropicalMarketInnovationManager = TropicalMarketInnovationManager.getInstance();
         if(tropicalMarketInnovationManager)
         {
            tropicalMarketInnovationManager.onRedeemStarted();
         }
      }
      
      public static function forceGrantBoraboraInnovationLeaderBoardReward(params:Object = null) : void
      {
         var boraboraInnovationManager:BoraBoraInnovationManager = BoraBoraInnovationManager.getInstance();
         if(Boolean(boraboraInnovationManager) && Global.player.getSeenFlag("bbiShown"))
         {
            boraboraInnovationManager.onRedeemStarted();
         }
      }
      
      public static function forceGrantMadagascarInnovationCommunityReward(params:Object = null) : void
      {
         var madagascarInnovationManger:MadagascarInnovationManager = MadagascarInnovationManager.getInstance();
         if(madagascarInnovationManger)
         {
            madagascarInnovationManger.initializeCommunityProgress();
         }
      }
      
      public static function forceGrantMadagascarInnovationWeeklyReward(params:Object = null) : void
      {
         var madagascarInnovationManger:MadagascarInnovationManager = MadagascarInnovationManager.getInstance();
         if(madagascarInnovationManger)
         {
            madagascarInnovationManger.onRedeemStarted();
         }
      }
      
      public static function forceGrantAmsterdamInnovationBonusReward(params:Object = null) : void
      {
         var amsterdamInnovationManager:AmsterdamInnovationManager = AmsterdamInnovationManager.getInstance();
         if(amsterdamInnovationManager)
         {
            amsterdamInnovationManager.grantBonusReward();
         }
      }
      
      public static function forceGrantWreathFestivalInnovationBonusReward(params:Object = null) : void
      {
         var wreathFestivalInnovationManager:WreathFestivalInnovationManager = WreathFestivalInnovationManager.getInstance();
         if(wreathFestivalInnovationManager)
         {
            wreathFestivalInnovationManager.grantBonusReward();
         }
      }
      
      public static function forcePopupSpecialLEBundleWindow(initParams:Object, params:XML) : void
      {
         if(!Global.player.getSeenFlag(params.itemName))
         {
            m_LEBundleWindow = new SpecialLEBundleWindow("assets/dialogs/FV_LEBundle_Feb2020/FV_motd_Feb_LEBundle2020.swf","MOTD");
            UI.displayPopup(m_LEBundleWindow);
            Global.player.setSeenFlag(params.itemName);
            FarmStatsManager.count("LE_Bundle","MOTD","","impressions",Global.worldManager.currentWorldType,"LE_Bundle");
         }
      }
      
      public static function forcePopupContingencyBuildableBonusRewardWindow(initParams:Object, params:XML) : void
      {
         if(!Global.player.getSeenFlag(params.itemName))
         {
            m_ContigencyBonusWindow = new ContingencyBuildableBonusRewardWindow("assets/dialogs/FV_GingerbreadCastle2019/FV_GingerbreadCastle2019.swf");
            UI.displayPopup(m_ContigencyBonusWindow);
            Global.player.setSeenFlag(params.itemName);
            FarmStatsManager.count("ContigencyBuildable","daily","popup");
         }
      }
      
      public static function setupLEBundleHud(params:Object = null) : void
      {
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("fv_lebundle_v9");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            m_LEBundleHud = new HudBottomLEBundleButton("assets/dialogs/FV_LEBundle_Feb2020/FV_hud_Feb_LEBundle2020.swf");
            Global.hud.setBottomHudLEBundleButton(m_LEBundleHud as HudBottomLEBundleButton);
         }
      }
      
      public static function setupFVTECurrencyConversionHud(params:Object = null) : void
      {
         if(SubscriptionsManager.getBucketForCurrencyConversion() > 0)
         {
            if(!Global.player.getSeenFlag("FVTE_CURRENCY_OFFER_ACCEPTED"))
            {
               if(!Global.player.getSeenFlag("FVTE_CURRENCY_tropic_escape_first_travel"))
               {
                  showFVTECurrencyHud();
               }
               else
               {
                  isOfferAcceptedinTE();
               }
            }
         }
      }
      
      public static function grantFcForPlayersSunSetProgram(params:Object = null) : void
      {
         grantFCasSunset();
      }
      
      public static function grantFCasSunset() : void
      {
         if(!Global.player.getSeenFlag(GRANT_FC_FLAG))
         {
            TransactionManager.addTransaction(new TGenericTransaction(BOOKMARK_OPT2019_SERVICE_NAME,"grantFCAsSunsetProgram",onGrantFCAsSnst));
         }
      }
      
      public static function onGrantFCAsSnst(result:Object) : void
      {
         if(result.success)
         {
            Global.player.cash += FC_VALUE;
            Global.player.setSeenFlag(GRANT_FC_FLAG,true);
            StatsManager.count("FC_GRANT_SNTS_PGM","granted");
         }
      }
      
      public static function isOfferAcceptedinTE() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("PumpkinPartyInnovationService","isOfferAcceptedinTE",onTropicEscapeOfferAccepted,["FVTE"]));
      }
      
      private static function onTropicEscapeOfferAccepted(result:Object) : void
      {
         var response:Object = null;
         if(result)
         {
            if(result.hasOwnProperty("response") && Boolean(result["response"]))
            {
               response = result["response"];
               if(response != null && Boolean(response["exchange"]))
               {
                  if(response["exchange"] == "YES")
                  {
                     Global.player.setSeenFlag("FVTE_CURRENCY_OFFER_ACCEPTED");
                  }
                  else
                  {
                     showFVTECurrencyHud();
                  }
               }
            }
         }
      }
      
      public static function showFVTECurrencyHud() : void
      {
         m_FVTEHud = new HudBottomFVTECurrencyConversionButton("assets/dialogs/FV_LoyaltyBenefits_2020/FV_LoyaltyBenefits_hud_2020.swf");
         Global.hud.setBottomHudFVTECurrencyButton(m_FVTEHud as HudBottomFVTECurrencyConversionButton);
      }
      
      public static function postFarmvilleNeighboursToTropicEscape(params:Object = null) : void
      {
         if(!Global.player.getSeenFlag("PostFarmvilleNeighboursToTropicEscape"))
         {
            TropicalMarketInnovationManager.getInstance().postNeighbours();
         }
      }
      
      public static function postFarmvilleNeighboursToTropicEscapePumpkinParty(params:Object = null) : void
      {
         if(!Global.player.getSeenFlag("PostFarmvilleNeighboursToTropicEscapePumpkinParty"))
         {
            PumpkinPartyInnovationManager.getInstance().postNeighbours();
         }
      }
      
      public static function setupFvPluginHud(params:Object = null) : void
      {
         if(isForcePluginWindow() || isEligibleforPluginFeature)
         {
            m_FvPluginHud = new HudBottomFvPluginButton("assets/dialogs/ChromePlugin2018/FV_hud_ChromePlugin2018.swf");
            Global.hud.setBottomHudFvPluginButton(m_FvPluginHud as HudBottomFvPluginButton);
         }
      }
      
      public static function forceStopCoOpAndGrantGift(params:Object = null) : void
      {
         if(!Global.player.getSeenFlag(GUILD_STOP_FLAG))
         {
            UI.displayPopup(new CoOpFinalGrantReward("assets/dialogs/CoopFeature2019_V3/FV_CoopFeature2019_Kill.swf"));
            Global.player.setSeenFlag(GUILD_STOP_FLAG);
         }
      }
      
      public static function setMessageNotificationHud(params:Object = null) : void
      {
         if(Global.flashHotParams.hasOwnProperty("MESSAGEBOARD_ENABLED") && Boolean(Global.flashHotParams["MESSAGEBOARD_ENABLED"]))
         {
            m_messageNotification = new HudMessageNotification("assets/dialogs/message_board_dec_2019/FV_hud_message_board.swf");
            Global.hud.setMessageNotificationHud(m_messageNotification as HudMessageNotification);
         }
      }
      
      public static function setupBookmarkOptHud(params:Object = null) : void
      {
         checkEligibilityForBookmarkOpt();
      }
      
      public static function checkEligibilityForBookmarkOpt() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(BOOKMARK_OPT2019_SERVICE_NAME,"isEligible",onIsEligibleForBookmarkOpt),true);
      }
      
      public static function onIsEligibleForBookmarkOpt(result:Object) : void
      {
         var isEligible:Boolean = Boolean(result["value"]);
         if(isEligible)
         {
            showBookmarkOptHud();
            showBookmarkTutorial();
         }
         else
         {
            grantBookmarkOptReward();
            Global.hud.removeBottomHudBookmarkOpt();
            Global.hud.removeHudBookmarkOpt();
         }
      }
      
      public static function showBookmarkTutorial() : void
      {
         if(!Global.player.getSeenFlag(BOOKMARKOPT_POPUP_SHOWN_FLAG))
         {
            m_bookmarkOptInstallWindow = new BookmarkOpt2019InstallWindow("assets/dialogs/dau_contingency/FV_motd_daucontingency_2019.swf");
            UI.displayPopup(m_bookmarkOptInstallWindow,false);
            Global.player.setSeenFlag(BOOKMARKOPT_POPUP_SHOWN_FLAG,true);
            StatsManager.count("bookmarkopt2019","installed");
         }
      }
      
      public static function grantBookmarkOptReward() : void
      {
         if(!Global.player.getSeenFlag(BOOKMARKOPT_REWARDGRANTED_FLAG))
         {
            TransactionManager.addTransaction(new TGenericTransaction(BOOKMARK_OPT2019_SERVICE_NAME,"grantReward",onGrantBookMarkRewards));
         }
      }
      
      public static function onGrantBookMarkRewards(result:Object) : void
      {
         if(result.success)
         {
            Global.player.addGift("consume_instagrow","0",2);
            Global.player.addGift("consume_turbo_charger","0",1);
            Global.player.cash += BOOKMARK_OPT_REWARD_FC;
            m_bookmarkOptRewardWindow = new BookmarkOpt2019RewardWindow("assets/dialogs/dau_contingency/FV_motd_daucontingency_rewards.swf");
            UI.displayPopup(m_bookmarkOptRewardWindow,false);
            Global.player.setSeenFlag(BOOKMARKOPT_REWARDGRANTED_FLAG,true);
            StatsManager.count("bookmarkopt2019","installed");
         }
      }
      
      public static function showBookmarkOptHud() : void
      {
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_BOTTOM_BOOKMARK_HUD) && Boolean(Global.flashHotParams[ZRUNTIME_KEY_BOTTOM_BOOKMARK_HUD]))
         {
            m_BookmarkOptHud = new HudBottomBookmarkOptButton("assets/dialogs/dau_contingency/FV_dau_hud.swf");
            Global.hud.setBottomHudBookmarkOptButton(m_BookmarkOptHud as HudBottomBookmarkOptButton);
         }
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_TOP_BOOKMARK_HUD) && Boolean(Global.flashHotParams[ZRUNTIME_KEY_TOP_BOOKMARK_HUD]))
         {
            m_bookmarkButton = new HudBookMarkButton("assets/hud/FV_hud_bookmark_2020.swf",null);
            Global.hud.setHudBookmarkButton(m_bookmarkButton as HudBookMarkButton);
         }
      }
      
      public static function setupmarketingOptinChecks(params:Object = null) : void
      {
         if(!(Global.player.getSeenFlag(MARKETING_OPTIN_REWARD_GRANT_FLAG) || Global.player.getSeenFlag(MARKETING_OPTIN_DECLINE_FLAG)))
         {
            if(Global.player.getSeenFlag(MARKETING_OPTIN_ELIGIBLILITY_CHECKED) && Global.player.getSeenFlag(MARKETING_OPTIN_ELIGIBLE))
            {
               MarketingEmailOptinFeatureWindow.onEligibleForOptIn();
            }
            else
            {
               checkEligibilityForMarketingOptinFlow();
            }
         }
      }
      
      public static function checkEligibilityForMarketingOptinFlow() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(MARKETING_OPTIN_SERVICE_NAME,"isEligible",ZCacheUtil.applyPartial(onIsEligibleForMarketingOptIn,null,[])),true);
      }
      
      public static function onIsEligibleForMarketingOptIn(result:Object) : void
      {
         var isEligible:Boolean = false;
         if(result)
         {
            Global.player.setSeenFlag(MARKETING_OPTIN_ELIGIBLILITY_CHECKED,true);
            isEligible = Boolean(result["iseligible"]);
            if(isEligible)
            {
               Global.player.setSeenFlag(MARKETING_OPTIN_ELIGIBLE,true);
               MarketingEmailOptinFeatureWindow.onEligibleForOptIn();
            }
         }
      }
      
      public static function isForcePluginWindow() : Boolean
      {
         var isForceChrome:Boolean = false;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_FORCE_FLASHPLAYER_PLUGIN_WINDOW))
         {
            isForceChrome = Boolean(Global.flashHotParams[ZRUNTIME_KEY_FORCE_FLASHPLAYER_PLUGIN_WINDOW]);
         }
         return isForceChrome;
      }
      
      public static function get isEligibleforPluginFeature() : Boolean
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
      
      public static function showMoneyTreeToaster(params:Object = null) : void
      {
         var MTManager:MoneyTree2017Manager = MoneyTree2017Manager.getInstance();
         if(MTManager)
         {
            MTManager.showConditionalToaster();
         }
      }
      
      public static function showXmasCharityBundleCongratsWindow(initParams:Object, params:XML) : void
      {
         var XmsCharityManager:ChristmasCharityBundleManager = ChristmasCharityBundleManager.getInstance();
         XmsCharityManager.showCongratulationsWindow(params.itemName);
      }
      
      public static function showCommunityGoalsRewardWindow(params:Object = null) : void
      {
         CommunityGoalsManager.getInstance().displayRewardDialog();
      }
      
      public static function showConsumableBundleBuyWindow(params:Object = null) : void
      {
         if(false && ConsumableBundleManager.getInstance().canDisplayPopup())
         {
         }
      }
      
      public static function showDreamFishPremarketingWindow(params:Object = null) : void
      {
         var popupCount:int = 0;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_DREAMFISH_PREMARKETING_POPUP))
         {
            popupCount = int(Global.flashHotParams[ZRUNTIME_KEY_DREAMFISH_PREMARKETING_POPUP]);
         }
         var feature_popup_count:int = int(FeatureOptionsManager.getInstance().getFeatureOption("DreamFishPremarketing",DreamFishPremarketingManager.FEATURE_OPTIONS_KEY));
         if(feature_popup_count < popupCount)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(DreamFishPremarketingManager.FEATURE_NAME,DreamFishPremarketingManager.FEATURE_OPTIONS_KEY,popupCount);
            FeatureOptionsManager.getInstance().saveSingleFeature(DreamFishPremarketingManager.FEATURE_NAME,DreamFishPremarketingManager.FEATURE_OPTIONS_KEY);
            if(DreamFishPremarketingManager.instance(DreamFishPremarketingManager.FEATURE_NAME))
            {
               StatsManager.count("DreamFishPremarketing",StatsTrackingConstants.MAIN_UI,"autopopup","");
               DreamFishPremarketingManager.instance(DreamFishPremarketingManager.FEATURE_NAME).showMainUI();
            }
         }
      }
      
      public static function onSuperCropUnlocked(params:Object = null) : void
      {
         var superCrop:FarmItem = null;
         var toasterTitle:String = null;
         var body:String = null;
         var callback:Function = null;
         var superCropsToaster:IconTitleToasterWindow = null;
         if(Boolean(params) && Boolean(params.unlockedSuperCrop))
         {
            superCrop = Global.farmGameSettingsManager.getFarmItemByCode(params.unlockedSuperCrop);
            if(superCrop)
            {
               toasterTitle = ZLocUtils.t("Dialogs","SuperCrops_New_Unlock_Toaster_Title");
               body = ZLocUtils.t("Dialogs","SuperCrops_New_Unlock_Toaster_Body",{"item":ZLocUtils.tk_pk(superCrop.friendlyName)});
               callback = function():void
               {
                  UI.displayMiniMarketDialog([superCrop.name],"market","seed",null);
               };
               superCropsToaster = new IconTitleToasterWindow(toasterTitle,body,superCrop.icon,"assets/dialogs/FV_Craft_BannerAd.swf",0.75,null,callback);
               Global.postInitActionsManager.addInitAction(new PostInitToaster(superCropsToaster));
            }
         }
      }
      
      public static function startPowerHour() : void
      {
         PowerHourManager.getInstance().initialize();
      }
      
      public static function giveRetentionFreeGifts() : void
      {
         RetentionGiftItemUtil.awardRetentionGifts();
      }
      
      public static function showPrizeMachineWindow(showHUDIcon:Boolean = false) : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PRIZE_MACHINE) >= 3)
         {
            if(showHUDIcon || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PRIZE_MACHINE_HUD) > 0)
            {
               if(Global.hud.rightSideIconQueue.getIconByName("PrizeMachine") == null)
               {
                  FarmStatsManager.count(PrizeMachineWindow.STAT_COUNTER,"surface_hud","view");
                  Global.hud.rightSideIconQueue.addIcon("PrizeMachine",DynamicIconQueue.ADD_BY_PRIORITY,null,null,false);
               }
            }
         }
      }
      
      public static function finishAllBuildingsInit() : void
      {
         FinishAllBuildingsUtil.conditionallyShowHudIcon();
      }
      
      public static function showUpgradeReceipt() : void
      {
         var lastUpgrade:Number = NaN;
         var lastSeen:Number = NaN;
         var level:int = 0;
         var rewards:Array = null;
         var bonusGrant:Number = NaN;
         var textReplacements:Object = null;
         var movieClips:Object = null;
         var dialog:GenericRewardWindow = null;
         var amexToaster:AmexTreeToasterWindow = null;
         var treeData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FEATURE_AMEX_TREE,"tree_data");
         if(treeData != null && treeData.hasOwnProperty("level") && treeData.hasOwnProperty("lastUpgrade"))
         {
            lastUpgrade = Number(treeData.lastUpgrade);
            lastSeen = Global.player.getFeatureLastShown("amextreeLastUpgrade");
            if(lastUpgrade > lastSeen)
            {
               if(treeData.hasOwnProperty("level") && treeData.level < 4)
               {
                  level = int(treeData.level);
                  rewards = new Array();
                  bonusGrant = Global.farmGameSettingsManager.getNumber("amextreeUpgradeBonus_lvl" + (level - 1).toString(),0);
                  rewards.push({
                     "type":"cash",
                     "value":bonusGrant
                  });
                  textReplacements = new Object();
                  textReplacements["title_tf"] = "amextree_title";
                  textReplacements["generic_tf"] = ZLocUtils.t("Dialogs","amextree_harvest_level_" + level.toString(),{"cash":bonusGrant.toString()});
                  if(AmexTreeStatusWindow.isConvertedUser() && level == 2)
                  {
                     textReplacements["generic_tf"] = ZLocUtils.t("Dialogs","amextree_harvest_level_" + level.toString() + "_convert",{"cash":bonusGrant.toString()});
                  }
                  movieClips = new Object();
                  movieClips["amextree_level_" + treeData.level + "_mc"] = true;
                  FarmStatsManager.count("serve_tree","harvest_custom_dialog","view","stage_" + level.toString());
                  dialog = new GenericRewardWindow("assets/dialogs/FV_ServeTree_Congrats.swf",function(event:Event = null):void
                  {
                     if(dialog != null)
                     {
                        dialog.close();
                     }
                     FarmStatsManager.count("serve_tree","harvest_custom_dialog","ok","stage_" + level.toString());
                  },rewards,textReplacements,movieClips);
                  UI.displayPopup(dialog,false,"amex_harvestPopup");
                  Global.player.setFeatureLastShown("amextreeLastUpgrade",GlobalEngine.serverTime,true);
               }
               else
               {
                  amexToaster = new AmexTreeToasterWindow();
                  ToasterManager.getInstance().addImmediate(amexToaster);
               }
            }
         }
      }
      
      public static function addCoreClickFlowImprovementsToaster() : void
      {
         var message:String = ZLocUtils.t("Dialogs","RetentionCoreClickFlow");
         var toaster:IconToasterWindow = new IconToasterWindow(CORE_CLICK_FLOW_TOASTER_ICON,message);
         Global.player.setSeenFlag(CLICK_FLOW_IMPROVEMENTS);
         ToasterManager.getInstance().add(toaster);
      }
      
      public static function scheduleAutomatedMessagesCheck() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("AutomatedMessagesService","scheduleChecks"));
      }
      
      public static function showEarlyAccessPaidGifting(params:Object) : void
      {
         var featureKey:String = null;
         var lastShown:Number = NaN;
         var buyItem:MFSEarlyAccessGift = null;
         var settings:ExpansionEarlyAccessGiftingData = Global.farmGameSettingsManager.getEarlyAccessGiftingExpansion();
         if(settings)
         {
            featureKey = settings.expansionId + TBuyAndSendPresent.ITEMCONTEXT_EARLYACCESS;
            lastShown = Global.player.getFeatureLastShown(featureKey);
            if(lastShown + settings.featureFrequency < GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND)
            {
               if(Global.player.getActionCount(featureKey) < settings.maxShowTimes)
               {
                  Global.player.setFeatureLastShown(featureKey,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,true);
                  Global.player.incrementActionCount(featureKey);
                  buyItem = new MFSEarlyAccessGift(settings,null);
                  UI.displayPopup(buyItem);
               }
            }
         }
      }
      
      public static function parseFriends(params:Object) : void
      {
         AsyncCall.call(Global.friendManager.refreshFriendsData,null,30000);
      }
      
      public function set initUserResult(result:Object) : void
      {
         this.m_initUserResult = result;
      }
      
      public function set postInitUserResult(result:Object) : void
      {
         this.m_postInitUserResult = result;
      }
      
      public function getUserActionXML(name:String) : XML
      {
         var result:XML = null;
         if(this.m_userActionLookup.hasOwnProperty(name))
         {
            result = this.m_userActionLookup[name];
         }
         return result;
      }
      
      public function executeUserActionByName(name:String) : Boolean
      {
         var result:Boolean = false;
         var userActionXML:XML = this.getUserActionXML(name);
         if(userActionXML != null)
         {
            result = this.executeUserAction(userActionXML);
         }
         return result;
      }
      
      public function getIdleTaskXML(name:String) : XML
      {
         var result:XML = null;
         if(this.m_idleTaskLookup.hasOwnProperty(name))
         {
            result = this.m_idleTaskLookup[name];
         }
         return result;
      }
      
      public function executeIdleTaskByName(name:String) : Boolean
      {
         var task:BaseIdleTask = null;
         var result:Boolean = false;
         var idleTaskXML:XML = this.getIdleTaskXML(name);
         if(idleTaskXML != null)
         {
            task = idleTaskXML.hasOwnProperty("@legacyClass") ? this.getLegacyIdleTask(idleTaskXML) : this.getDataDrivenIdleTask(idleTaskXML);
            if(task.shouldAdd)
            {
               IdleTaskQueue.getInstance().addTask(task);
               result = true;
            }
         }
         return result;
      }
      
      public function diagnoseInitQueue() : String
      {
         var diagnosis:Object = null;
         var userActionXML:XML = null;
         var idleTaskXMLList:XMLList = null;
         var idleTaskXML:XML = null;
         var task:BaseIdleTask = null;
         var output:String = "";
         var userActionXMLList:XMLList = this.m_xml.userActionQueue.userAction;
         output += "*** USER ACTION QUEUE ***\n";
         var name:String = "";
         for each(userActionXML in userActionXMLList)
         {
            name = userActionXML.@name;
            diagnosis = PrerequisiteUtility.diagnosePrerequisite(userActionXML);
            output += "UserAction name:" + name;
            if(diagnosis.result)
            {
               output += " can execute\n";
            }
            else
            {
               output += " cannot execute\n";
            }
            output += PrerequisiteUtility.parseConsoleDiagnosis(diagnosis);
            output += "\n";
         }
         output += "\n*** IDLE TASK QUEUE ***\n";
         idleTaskXMLList = this.m_xml.idleTaskQueue.idleTask;
         for each(idleTaskXML in idleTaskXMLList)
         {
            name = idleTaskXML.@name;
            task = idleTaskXML.hasOwnProperty("@legacyClass") ? this.getLegacyIdleTask(idleTaskXML) : this.getDataDrivenIdleTask(idleTaskXML);
            output += "IdleTask name:" + name;
            if(task.shouldAdd)
            {
               output += " can be queued\n";
            }
            else
            {
               output += " cannot be queued\n";
            }
            diagnosis = PrerequisiteUtility.diagnosePrerequisite(idleTaskXML);
            output += PrerequisiteUtility.parseConsoleDiagnosis(diagnosis);
            output += "\n";
         }
         return output;
      }
      
      public function loadPostInitQueue() : void
      {
         if(!this.m_hasExecuted)
         {
            this.loadUserActionQueue();
            this.loadIdleTaskQueue();
            this.m_hasExecuted = true;
         }
         else
         {
            ErrorManager.addError("loadPostInitQueue error : post init queue has already been loaded");
         }
      }
      
      private function loadUserActionQueue() : void
      {
         var userActionXML:XML = null;
         var name:String = null;
         var userActionXMLList:XMLList = this.m_xml.userActionQueue.userAction;
         for each(userActionXML in userActionXMLList)
         {
            if(userActionXML.hasOwnProperty("@name"))
            {
               name = userActionXML.@name;
               if(this.m_userActionLookup.hasOwnProperty(name))
               {
               }
               this.m_userActionLookup[name] = userActionXML;
            }
            this.executeUserAction(userActionXML);
         }
      }
      
      private function executeUserAction(userActionXML:XML) : Boolean
      {
         var actionTarget:String = null;
         var actionMethod:String = null;
         var myclass:Class = null;
         var params:Object = null;
         var staticParams:XML = null;
         var result:Boolean = false;
         var prereqs:Array = PrerequisiteUtility.parseXmlNodePrereqs(userActionXML.prereqs.children());
         if(PrerequisiteUtility.arePrerequisitesMet(prereqs))
         {
            actionTarget = userActionXML.action.@target;
            actionMethod = userActionXML.action.@method;
            if(Boolean(actionTarget) && Boolean(actionMethod))
            {
               myclass = getDefinitionByName(actionTarget) as Class;
               if(myclass != null && (myclass as Object).hasOwnProperty(actionMethod))
               {
                  params = this.getInitParamsFromXML(userActionXML);
                  staticParams = userActionXML.params[0];
                  if(params !== null)
                  {
                     if(staticParams == null)
                     {
                        myclass[actionMethod](params);
                        result = true;
                     }
                     else
                     {
                        myclass[actionMethod](params,staticParams);
                        result = true;
                     }
                  }
               }
               else
               {
                  ErrorManager.addError("InitPopupSettings error executing target:" + actionTarget + " method:" + actionMethod);
               }
            }
         }
         return result;
      }
      
      private function getInitParamsFromXML(xml:XML) : Object
      {
         var initUserParam:String = null;
         var postInitUserParam:String = null;
         var params:Object = {};
         var canExecute:Boolean = true;
         for each(initUserParam in xml.initParams.initParam)
         {
            if(!(canExecute && this.m_initUserResult.hasOwnProperty(initUserParam)))
            {
               canExecute = false;
               break;
            }
            params[initUserParam] = this.m_initUserResult[initUserParam];
         }
         for each(postInitUserParam in xml.postInitParams.postInitParam)
         {
            if(!(canExecute && this.m_postInitUserResult.hasOwnProperty(postInitUserParam)))
            {
               canExecute = false;
               break;
            }
            params[postInitUserParam] = this.m_postInitUserResult[postInitUserParam];
         }
         if(!canExecute)
         {
            params = null;
         }
         return params;
      }
      
      private function loadIdleTaskQueue() : void
      {
         var idleTaskXML:XML = null;
         var task:BaseIdleTask = null;
         var name:String = null;
         var idleTaskXMLList:XMLList = this.m_xml.idleTaskQueue.idleTask;
         for each(idleTaskXML in idleTaskXMLList)
         {
            if(idleTaskXML.hasOwnProperty("@name"))
            {
               name = idleTaskXML.@name;
               if(this.m_idleTaskLookup.hasOwnProperty(name))
               {
               }
               this.m_idleTaskLookup[name] = idleTaskXML;
            }
            task = idleTaskXML.hasOwnProperty("@legacyClass") ? this.getLegacyIdleTask(idleTaskXML) : this.getDataDrivenIdleTask(idleTaskXML);
            IdleTaskQueue.getInstance().addTask(task);
         }
      }
      
      private function getLegacyIdleTask(idleTaskXML:XML) : BaseIdleTask
      {
         var prereqs:Array = null;
         var task:BaseIdleTask = null;
         var className:String = idleTaskXML.@legacyClass;
         var myclass:Class = getDefinitionByName(className) as Class;
         var params:Object = this.getInitParamsFromXML(idleTaskXML);
         if(params !== null)
         {
            prereqs = PrerequisiteUtility.parseXmlNodePrereqs(idleTaskXML.prereqs.children());
            if(!prereqs || prereqs.length == 0 || PrerequisiteUtility.arePrerequisitesMet(prereqs))
            {
               task = new myclass(params);
            }
         }
         return task;
      }
      
      private function getDataDrivenIdleTask(idleTaskXML:XML) : BaseIdleTask
      {
         var task:BaseIdleTask = null;
         var params:Object = this.getInitParamsFromXML(idleTaskXML);
         if(params != null)
         {
            task = DataDrivenIdleTask.createFromXML(idleTaskXML);
         }
         return task;
      }
   }
}

