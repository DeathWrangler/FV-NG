package Widgets.Windows.Market
{
   import Classes.BuyPresent;
   import Classes.Constants.CrossPromoConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.SuperCropConstants;
   import Classes.DealOfDayHelper;
   import Classes.FriendSetRequirement;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.MarketReopenIdleTask;
   import Classes.ItemRequirement;
   import Classes.LockedExplanation;
   import Classes.MOTD.ExpansionEarlyAccessMotdHandler;
   import Classes.MarketPromotion;
   import Classes.MultiRewardTreasureConstructionBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.StarterPack.StarterPack;
   import Classes.StarterPack.StarterPackUtility;
   import Classes.UGC.UGCItemDefinition;
   import Classes.VisitorManager;
   import Classes.ZItem.BushelItem;
   import Classes.ZItem.ChangeFarmItem;
   import Classes.ZItem.ClothingItem;
   import Classes.ZItem.DecorationItem;
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionAccessItem;
   import Classes.ZItem.ExpansionData;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.ZItem.FarmItemType;
   import Classes.ZItem.HarvestableItem;
   import Classes.ZItem.IUGCItem;
   import Classes.ZItem.SeedItem;
   import Classes.ZItem.StarterPackItem;
   import Classes.ZItem.StencilPortalItem;
   import Classes.consumables.CPigoGameToken;
   import Classes.util.CurrencyConversionUtil;
   import Classes.util.EventBatchEvent;
   import Classes.util.EventBatcher;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.BuySeedPackages;
   import Display.CityvilleLaunchPromoRound2Dialog;
   import Display.CoconutSurfaceReminder;
   import Display.Dialogs.GenericDialog;
   import Display.Dialogs.InGameCurrencyConversion;
   import Display.Dialogs.SurveyorDialog;
   import Display.EmailPopup;
   import Display.FarmDynamicDialog;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.MOTD;
   import Display.MysteryBoxBalloonDialog;
   import Display.QueuedIcon;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import Events.MarketEvent;
   import Events.SubscriptionsEvent;
   import Managers.EmailManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FarmVillageManager;
   import Managers.FlowerShackManager;
   import Managers.FreezeManager;
   import Managers.HolidayCountdownManager;
   import Managers.InGamePaymentsManager;
   import Managers.ItemMembershipManager;
   import Managers.LESetManager;
   import Managers.LESurfacingManager;
   import Managers.LotteryManager;
   import Managers.LoyaltyProgramManager;
   import Managers.MFSRequestManager;
   import Managers.MarketFlashSaleManager;
   import Managers.MarketStatsManager;
   import Managers.MiniDartsManager;
   import Managers.OrderBoard.BobBerryManager;
   import Managers.RewardCardsManager;
   import Managers.SheepPatternBreedingManager;
   import Managers.StencilManager;
   import Managers.SubscriptionsManager;
   import Managers.SuperPlotManager;
   import Managers.TaskListManager;
   import Managers.ToasterManager;
   import Transactions.TAcquireLicense;
   import Transactions.TBuyAndSendPresent;
   import Transactions.TExpansionWorldAccess;
   import Transactions.TGetMOTD;
   import Transactions.TRareBaby;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Util.ZwWidgetUtils;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Frames.Market.MarketCharityBannerFrame;
   import Widgets.Frames.Market.MarketFlashSaleFrame;
   import Widgets.Frames.Market.MarketMiniSlotFrame;
   import Widgets.Frames.Market.MarketPromoLESlotFrame;
   import Widgets.Frames.Market.MarketPromoSlotFrame;
   import Widgets.Frames.Market.MarketRewardCardsSlotFrame;
   import Widgets.Frames.Market.MarketSlotFrame;
   import Widgets.Frames.Market.MarketSlotFrameLE;
   import Widgets.Menu.DropDownMenu;
   import Widgets.Menu.FarmMultiTabMenu;
   import Widgets.Menu.FarmTabMenu;
   import Widgets.Menu.FarmTabMenuButton;
   import Widgets.Menu.MenuItem;
   import Widgets.Slots.LESet.LERecommendationSurfacingSlot;
   import Widgets.Slots.Market.MarketSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Charity.DonateWindow;
   import Widgets.Windows.Charity.DonateWindowFactory;
   import Widgets.Windows.FCSlotMachineWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FleaMarket.FleaMarketWindow;
   import Widgets.Windows.LimitedGifting.LimitedGiftingWindow;
   import Widgets.Windows.MFSSendPaidGift;
   import Widgets.Windows.MOTD.SubscriptionsMOTDWindow;
   import Widgets.Windows.MarketOverlayWindow;
   import Widgets.Windows.Pigo.PigoWindow;
   import Widgets.Windows.PrizeMachine.PrizeMachineWindow;
   import Widgets.Windows.Promotions.CapitalOnePromoWindow;
   import Widgets.Windows.Promotions.DreyersWhatsThisDialog;
   import Widgets.Windows.ScratchCardWindow;
   import Widgets.Windows.Subscriptions.SubscriptionsMainWindow;
   import Widgets.Windows.WorldMarketSaleOverlayWindow;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.net.URLVariables;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   public class MarketWindow extends FarmWindow
   {
      
      public static var previousType:String;
      
      public static var previousSubType:String;
      
      public static var previousSubSubType:String;
      
      public static var previousSortBy:String;
      
      public static var previousSortDirection:String;
      
      public static var LE_FOR_CHARITY_VARIANT:int;
      
      public static const CALLBACK_BUY_CASH:String = "buyCash";
      
      public static const CALLBACK_BUY_COIN:String = "buyCoin";
      
      public static const CALLBACK_GET:String = "get";
      
      public static const CALLBACK_MORE_INFO:String = "moreInfo";
      
      public static const CALLBACK_HELP:String = "help";
      
      public static const CALLBACK_PLAY:String = "play";
      
      public static const CALLBACK_PREVIEW:String = "preview";
      
      public static const CALLBACK_SEND:String = "send";
      
      public static const CALLBACK_UNLOCK:String = "unlock";
      
      public static const CALLBACK_USE:String = "use";
      
      public static const CALLBACK_DONATE:String = "donate";
      
      public static const CALLBACK_REDEEM:String = "redeem";
      
      public static const CALLBACK_CLOSE:String = "onClose";
      
      public static const CALLBACK_LOCK_EXPLANATION:String = "lockExplanation";
      
      public static const CALLBACK_TRAVEL_WORLD:String = "travel";
      
      public static const PAYMENT_CONFIRMATION_MINIMUM:int = 10;
      
      public static const SEEN_MARKET_SESSION_FLAG:String = "sawMarket";
      
      public static const OPENED_MARKET_ON_GIFTBOX_CLOSE_TIMESTAMP_FLAG:String = "lastMarketGiftboxPopup";
      
      public static const OPENED_MARKET_ON_GIFTBOX_CLOSE_VIEWSOURCE_COUNTER:String = "giftbox_closed";
      
      public static const SEEN_WORLD_LOCK_REMINDER_FLAG:String = "sawMarketWorldLock";
      
      public static const SEEN_NEW_MARKETPLACE_3_HOMEPAGE:String = "seen_new_homepage";
      
      private static const SEEN_MARKET_3_FTUE_FLAG:String = "market_3_ftue";
      
      private static const SEEN_MARKET_VIP_FTUE_FLAG:String = "market_vip_ftue";
      
      protected static const MENU_PREFIX:String = "menu_";
      
      private static const LIGHTS_MARKET_OVERLAY:String = "assets/dialogs/HLights/FV_xhl_buildableTown_market.swf";
      
      protected static const SUB_MENU_CENTER_X_POSITION:Number = 370;
      
      public static const MINIMUM_SEND_LEVEL:Number = 10;
      
      public static const CURRENT_WORLD_MENU_ITEM:String = "currentWorld";
      
      public static const BESTSELLERS_MENU_ITEM:String = "best_sellers";
      
      public static const RECOMMENDED_MENU_ITEM:String = "recommended_items";
      
      public static const MARKETPLACE_SALE_MENU_ITEM:String = "marketplace_sale";
      
      public static const BRANDED_ITEMS_MENU_ITEM:String = "branded_items";
      
      public static const REWARDS_CARDS_ITEM:String = "reward_cards_items";
      
      public static const VAULT_TAB_NEW_SALE:String = "vault_tab_new_sale";
      
      public static const VAULT_TAB_NEW_SALE_RUNTIME:String = "VAULT_TAB_NEW_SALE";
      
      public static const SEARCH_INPUT_BATCHING_MIN_DELAY:int = 250;
      
      public static const SEARCH_INPUT_BATCHING_MAX_DELAY:int = 1000;
      
      public static var prevMiniMarketData:MiniMarketStateData = null;
      
      public static var previousPage:int = -1;
      
      public static var MARKETCARD_WIDTH:int = 240;
      
      public static var MINI_MARKETCARD_WIDTH:int = 127;
      
      public static var NUM_SMALL_MARKET_COLS:int = 3;
      
      public static var NUM_MED_MARKET_COLS:int = 4;
      
      public static var NUM_SMALL_MARKET_MINI_SLOTS:int = 5;
      
      public static var NUM_MED_MARKET_MINI_SLOTS:int = 7;
      
      private static var bottomDisplayObjectIndex:int = 1;
      
      public static const PREREQ_MARKET_SEND_BUTTON_NOT_AVAILABLE:String = "market_send_button_not_available";
      
      private static var m_hasClickedPaidGiftingMarketAdd:Boolean = false;
      
      private static const SEEN_MARKET_LE_FTUE:String = "market_le_ftue";
      
      protected var m_closeCallback:Function;
      
      protected var m_closeIsBuy:Boolean = false;
      
      private var m_hideLESurfacing:Boolean = false;
      
      protected var m_viewSource:String = "unknown";
      
      protected var m_type:String = "special";
      
      protected var m_subType:String = "all";
      
      protected var m_subSubType:String = "all";
      
      protected var m_terrainCodes:Array = null;
      
      protected var m_worldScorePointsWidget:ZwBaseWidget = null;
      
      protected var m_worldScoreMeter:ZwWidget = null;
      
      protected var m_worldScoreText:ZwTextField = null;
      
      protected var m_sortBy:String = "level";
      
      protected var m_sortDirection:String = "asc";
      
      protected var m_page:int = 0;
      
      protected var m_preserveSort:Boolean = false;
      
      protected var m_coinTextField:ZwTextField;
      
      protected var m_coinSlideTextField:ZwTextField;
      
      protected var m_cashTextField:ZwTextField;
      
      protected var m_levelTextField:ZwTextField;
      
      protected var m_titleTextField:ZwTextField;
      
      protected var m_typeTextField:ZwTextField;
      
      protected var m_mainMenu:FarmTabMenu;
      
      protected var m_subMenu:FarmTabMenu;
      
      protected var m_subDropDownMenu:DropDownMenu;
      
      protected var m_currentSubMenuTab:FarmTabMenuButton;
      
      protected var m_sortByButton:FarmTabButton;
      
      protected var m_sortByMenu:DropDownMenu;
      
      protected var m_bestSellersFrame:ZwFrame;
      
      protected var m_bestSellersSlot:GenericSlotContainerFrame;
      
      protected var m_recommendedItemsFrame:ZwFrame;
      
      protected var m_recommendedItemsSlot:GenericSlotContainerFrame;
      
      protected var m_turboSaleFrame:ZwFrame;
      
      protected var m_turboSaleSlot:GenericSlotContainerFrame;
      
      protected var m_latestLEFrame:ZwFrame;
      
      protected var m_latestLESlot:GenericSlotContainerFrame;
      
      protected var m_miniSlotMenu:FarmTabMenu;
      
      protected var m_marketSlotFrame:MarketSlotFrame;
      
      protected var m_promoSlotFrame:MarketPromoSlotFrame;
      
      protected var m_flashSaleFrame:MarketFlashSaleFrame;
      
      protected var m_miniSlotFrame:MarketMiniSlotFrame;
      
      protected var m_rewardCardsSlotFrame:MarketRewardCardsSlotFrame;
      
      protected var m_buyPresent:BuyPresent = null;
      
      protected var m_buyMultiPresent:MFSSendPaidGift = null;
      
      private var m_charityBannerFrame:MarketCharityBannerFrame;
      
      private var m_acquireLicenseItem:FarmItem;
      
      protected var m_searchBar_mc:ZwWidget = null;
      
      private var m_clearSearchButton_mc:FarmAnimatedButton = null;
      
      private var m_clearedSearch:Boolean = false;
      
      private var m_search_mc:ZwWidget = null;
      
      private var m_searchField_tf:ZwTextField = null;
      
      private var m_searchFieldInputBatcher:EventBatcher;
      
      private var m_defaultString:String = ZLocUtils.t("Dialogs","Search");
      
      private var m_noResultsText:ZwTextField = null;
      
      private var m_cashCoinsButton:FarmAnimatedTextButton = null;
      
      private var m_currencyButton:FarmAnimatedButton = null;
      
      private var m_cashButton:FarmAnimatedButton = null;
      
      private var m_coinButton:FarmAnimatedButton = null;
      
      private var m_statusPointsButton:FarmAnimatedButton = null;
      
      private var m_statusPointsText:ZwTextField = null;
      
      private var m_currencyTextField:ZwTextField;
      
      private var m_coinSlideExpanded:FarmButton = null;
      
      private var m_coinSlideContracted:FarmButton = null;
      
      private var m_ftue:MovieClip = null;
      
      private var m_ftueAccept:FarmAnimatedButton = null;
      
      private var m_ftueVip:MovieClip = null;
      
      private var m_ftueVipAccept:FarmAnimatedButton = null;
      
      private var m_vipDiscountTf:FarmTextField;
      
      private var m_worldCurrencyActive:Boolean = false;
      
      private var m_coinSlideExpandedState:Boolean = false;
      
      private var m_tooltipCoin:FarmTextTooltip;
      
      private var m_currentCurrency:String;
      
      private var m_miniSlotsTab:String;
      
      private var m_limitedTab:String;
      
      private var m_filteredItems:Dictionary;
      
      private var m_marketOverlay:MarketOverlayWindow;
      
      private var m_worldMarketSaleOverlay:WorldMarketSaleOverlayWindow;
      
      private var m_cachedMarketSearchOptimizationExperimentVariant:int = -1;
      
      private var m_plotCallback:Function;
      
      private var m_cacheSearch:Boolean = false;
      
      private const LEVEL_ONE_TREES:String = "levelOneTrees";
      
      private const LEVEL_TWO_TREES:String = "levelTwoTrees";
      
      private const HORSES:String = "horses";
      
      private const OTHER_ANIMALS:String = "otherAnimals";
      
      private const DECOS:String = "decos";
      
      private const COIN_ITEMS:String = "coinItems";
      
      private const TREE:String = "tree";
      
      private const ANIMAL_TYPE:String = "animalType";
      
      private const HORSE:String = "horse";
      
      private const ANIMAL:String = "animal";
      
      private const LIMITED:String = "limited";
      
      public var m_LeTabSortVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_TAB_SORT);
      
      protected var m_items:Array = new Array();
      
      private var m_farmItems:Array;
      
      private var m_hasUnlockedWorld:Boolean = false;
      
      private var m_currentItem:FarmItem = null;
      
      private var m_confirmationDialog:GenericDialog = null;
      
      private var m_LeRevamp:Boolean = Global.marketConfigSettings.isLERevampActive() && !(this is MarketMiniWindow);
      
      private var m_ftueLE:MovieClip = null;
      
      private var m_ftueLEAccept:FarmAnimatedButton = null;
      
      private var m_marketSlotFrameLE:MarketSlotFrameLE = null;
      
      private var m_subMenuLE:FarmMultiTabMenu = null;
      
      private var m_lePromoSlotFrame:MarketPromoLESlotFrame = null;
      
      private var m_leItems:Object = {};
      
      private var m_LeHeader:ZwWidget = null;
      
      private var m_LeSubtitle:ZwWidget = null;
      
      private var m_lesubmenuitems:Array = new Array();
      
      public function MarketWindow(type:String = null, subType:String = null, subSubType:String = null, sortBy:String = null, sortDirection:String = null, page:Number = -1, viewSource:String = "unknown", isInHiddenMode:Boolean = false, terrainCodes:Array = null, defaultMiniSlotsTab:String = null, callback:Function = null, hideLESurfacing:Boolean = false)
      {
         this.m_hideLESurfacing = hideLESurfacing;
         LE_FOR_CHARITY_VARIANT = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_LE_FOR_CHARITY);
         if(this.m_LeRevamp && this.getMarketSize() != NUM_MED_MARKET_COLS)
         {
            this.m_LeRevamp = false;
            MarketStatsManager.countLowResolution(Global.stage.stageWidth);
         }
         if(!isInHiddenMode)
         {
            super(this.marketSWF);
            if(type != "seed" && !Global.player.getSeenFlag(SEEN_MARKET_3_FTUE_FLAG) && !MarketWindow.isNewMarketplaceHomepageOn())
            {
               this.m_type = "limited";
            }
            else if(this.m_LeRevamp && (!type || type == "special"))
            {
               this.m_type = "limited";
            }
            else
            {
               this.m_type = type ? type : "special";
            }
            this.m_subType = subType ? subType : FarmGameSettingsManager.ALL;
            this.m_subSubType = subSubType ? subSubType : FarmGameSettingsManager.ALL;
            this.m_terrainCodes = terrainCodes;
            this.m_miniSlotsTab = defaultMiniSlotsTab ? defaultMiniSlotsTab : BESTSELLERS_MENU_ITEM;
            this.m_sortBy = sortBy ? sortBy : FarmGameSettingsManager.REQUIRED_LEVEL;
            this.m_sortDirection = sortDirection ? sortDirection : FarmGameSettingsManager.ASCENDING;
            this.m_page = page >= 0 ? int(page) : 0;
            this.m_viewSource = viewSource;
            this.m_plotCallback = callback;
            if(sortDirection)
            {
               this.m_preserveSort = true;
            }
            if(this.m_miniSlotsTab == BESTSELLERS_MENU_ITEM && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_SORTING_ALGO) == 2)
            {
               this.m_miniSlotsTab = RECOMMENDED_MENU_ITEM;
            }
            this.m_cacheSearch = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MARKET_SEARCH_CACHING) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
            if(this.m_LeRevamp)
            {
               this.createLEMarketEntries();
            }
         }
      }
      
      public static function resetPreviousSelections() : void
      {
         previousType = "special";
         previousPage = 0;
         previousSubType = FarmGameSettingsManager.ALL;
         previousSubSubType = FarmGameSettingsManager.ALL;
      }
      
      public static function onGiftboxClosePopupCheck() : void
      {
         var lastShown:Number = NaN;
         var currentTime:Number = NaN;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POPUP_ON_GIFTBOX_CLOSE) == 3)
         {
            lastShown = Global.player.getFeatureLastShown(OPENED_MARKET_ON_GIFTBOX_CLOSE_TIMESTAMP_FLAG);
            currentTime = Math.round(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
            if(currentTime - lastShown > FarmGameUtil.NUM_SECS_IN_DAY)
            {
               Global.player.setFeatureLastShown(OPENED_MARKET_ON_GIFTBOX_CLOSE_TIMESTAMP_FLAG,currentTime,true);
               UI.displayMarketDialog(OPENED_MARKET_ON_GIFTBOX_CLOSE_VIEWSOURCE_COUNTER,null,null,null);
            }
         }
      }
      
      private static function openLimitedGiftingWindowHelper(data:Object) : void
      {
         var icon:QueuedIcon = null;
         var extraData:Object = null;
         var dialog:LimitedGiftingWindow = null;
         if(data.actionParams != null && data.actionParams.length > 0)
         {
            icon = Global.hud.rightSideIconQueue.getIconByName(data.actionParams[0]);
            if(icon != null)
            {
               extraData = icon.extraData;
               dialog = new LimitedGiftingWindow(extraData);
               UI.displayPopup(dialog,false,extraData.featureName,true);
            }
            else
            {
               m_hasClickedPaidGiftingMarketAdd = true;
            }
         }
      }
      
      public static function openLimitedGiftingWindowOnMarketAddClicked() : void
      {
         var data:Object = null;
         if(MarketWindow.m_hasClickedPaidGiftingMarketAdd)
         {
            MarketWindow.m_hasClickedPaidGiftingMarketAdd = false;
            data = new Object();
            data.actionParams = ["limitedGifting"];
            MarketWindow.openLimitedGiftingWindowHelper(data);
         }
      }
      
      public static function isItemSendable(farmItem:FarmItem) : Boolean
      {
         return Global.player.level >= MarketWindow.MINIMUM_SEND_LEVEL && Global.featureBuyableGifts && !Global.player.isGiftsendBlacklist && farmItem.isPresent && !PrerequisiteUtility.checkPrereqByName(MarketWindow.PREREQ_MARKET_SEND_BUTTON_NOT_AVAILABLE);
      }
      
      public static function isItemRedeemable(farmItem:FarmItem) : Boolean
      {
         return !farmItem.isVipItem() && RewardCardsManager.getInstance().isRewardCardsActive() && Boolean(RewardCardsManager.getInstance().getRedeemableRewardCard(farmItem));
      }
      
      public static function setBottomDisplayIndex(newIndex:int) : void
      {
         bottomDisplayObjectIndex = newIndex;
      }
      
      public static function isNewMarketplaceHomepageOn() : Boolean
      {
         return Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKETPLACE_3_HOMEPAGE) == 2;
      }
      
      private function get marketSWF() : String
      {
         var result:String = "assets/dialogs/FV_Market_7_organic.swf";
         if(this.m_LeRevamp)
         {
            result = "assets/dialogs/FV_Market_11_organic.swf";
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FLOWER_SHACK) >= 1)
         {
            result = "assets/dialogs/FV_Market_10_organic.swf";
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TRAVEL_LITE) == 2)
         {
            result = "assets/dialogs/FV_Market_8_organic.swf";
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var callbacks:Object = null;
         var worldName:String = null;
         var item:MenuItem = null;
         var recommendedMenuItem:MenuItem = null;
         var marketSaleMenuItem:MenuItem = null;
         var brandedItemsMenuItem:MenuItem = null;
         var loyaltyCardItems:MenuItem = null;
         var submenuitems:Array = null;
         var selectedSubTab:int = 0;
         var leTheme:String = null;
         var showExpiry:String = null;
         var isNew:Boolean = false;
         var tabindex:int = 0;
         var desc:String = null;
         var leitem:FarmItem = null;
         var timeleft:Number = NaN;
         var parsedtime:Array = null;
         var menuItem:MenuItem = null;
         this.setupMarket3();
         if(!(this is MarketMiniWindow) && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_LAST_CHANCE) < Experiments.VARIANT_LE_LAST_CHANCE_EXPIRING && !this.m_hideLESurfacing)
         {
            if(Global.flashHotParams["HUD_LE_SURFACING_OVERRIDE"])
            {
               LESurfacingManager.instance.showOnHud();
            }
            else
            {
               LESurfacingManager.instance.showUI();
            }
         }
         if(this.shouldShowHLightsOverlay())
         {
            UI.displayPopup(this.m_marketOverlay = new MarketOverlayWindow(LIGHTS_MARKET_OVERLAY),false);
         }
         if(this.shouldShowWorldMarketSaleOverlay())
         {
            worldName = Global.worldSpecificSalesManager.worldName;
            UI.displayPopup(this.m_worldMarketSaleOverlay = new WorldMarketSaleOverlayWindow(Global.marketConfigSettings.getWorldSaleBannerAssetPath(worldName),worldName),false);
         }
         this.setupCurrencyMeters();
         this.m_titleTextField = addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Market"))) as ZwTextField;
         var formattedLevel:String = FarmGameUtil.numberToStringPadZeros(Global.player.level);
         this.m_levelTextField = addWidget(new ZwTextField(m_window.level_tf,formattedLevel)) as ZwTextField;
         this.m_typeTextField = addWidget(new ZwTextField(m_window.sectionTitle_mc," "),false) as ZwTextField;
         this.m_noResultsText = addWidget(new ZwTextField(m_window.noResults_tf,ZLocUtils.t("Dialogs","NoMatchingResults")),false) as ZwTextField;
         this.m_cashCoinsButton = addWidget(new FarmAnimatedTextButton(m_window.addCoins_bt,ZLocUtils.t("Dialogs","GetCurrencyButton"),this.onGetCurrencyButtonClick,true)) as FarmAnimatedTextButton;
         if(m_window.hasOwnProperty("discount_tf"))
         {
            this.m_vipDiscountTf = addWidget(new FarmTextField(m_window.discount_tf,""),false) as FarmTextField;
         }
         var mainMenuItems:Array = this.getMainMenuItems();
         this.m_mainMenu = addWidget(new FarmTabMenu(m_window.mainNav_mc,this.onMainMenuItemSelected,mainMenuItems,false,10)) as FarmTabMenu;
         this.m_mainMenu.setTabVisibility(FarmGameSettingsManager.TYPE_MANAGED_SALE,false);
         this.m_mainMenu.setTabVisibility(FarmGameSettingsManager.TYPE_VAULT,false);
         this.m_mainMenu.setTabVisibility(FarmGameSettingsManager.TYPE_VILLAGE,FarmVillageManager.isInFarmVillage() && Global.worldManager.currentWorldType == "village");
         this.m_mainMenu.setTabVisibility(FarmGameSettingsManager.TYPE_LOYALTY,LoyaltyProgramManager.getInstance().userPassesPrereq());
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MANAGED_SALE_TAB) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START && Global.managedSalesManager.hasValidOnSaleItems() || Global.worldSpecificSalesManager.isActive() || Global.categorySpecificSalesManager.isActive())
         {
            this.m_mainMenu.setTabVisibility(FarmGameSettingsManager.TYPE_MANAGED_SALE,true);
         }
         if(Global.vipSalesManager.isEnabled() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_VIP_BUY_ITEMS) >= 1)
         {
            this.m_mainMenu.setTabVisibility(FarmGameSettingsManager.TYPE_VIP,true);
         }
         else
         {
            this.m_mainMenu.setTabVisibility(FarmGameSettingsManager.TYPE_VIP,false);
         }
         this.m_mainMenu.setTabVisibility(FarmGameSettingsManager.TYPE_BOBS_FARM,false);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BOBS_BERRY_V1) == Experiments.VARIANT_BOBS_BERRY_V1)
         {
            this.m_mainMenu.setTabVisibility(FarmGameSettingsManager.TYPE_BOBS_FARM,true);
         }
         var showCurrentWorldTab:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MARKET_OPTIM_EXPANSION) >= 2 && Boolean(Global.worldManager.currentWorldUniqueMarketCard);
         this.m_mainMenu.setTabVisibility(Global.worldManager.currentWorldUniqueMarketCard,showCurrentWorldTab);
         for(var i:int = 0; i < this.m_mainMenu.numItems; i++)
         {
            item = this.m_mainMenu.getItem(i);
            if(this.m_type == item.data as String)
            {
               this.m_mainMenu.selectTab(i);
               break;
            }
         }
         this.m_searchBar_mc = addWidget(new ZwWidget(m_window.searchBar_mc)) as ZwWidget;
         var searchString:String = UI.windowState != null && UI.windowState.market != null && UI.windowState.market["searchString"] != "" ? UI.windowState.market["searchString"] : this.m_defaultString;
         this.m_searchField_tf = addWidget(new ZwTextField(m_window.searchBar_mc.searchField_tf,searchString)) as ZwTextField;
         m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
         m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
         m_window.searchBar_mc.searchField_tf.addEventListener(MouseEvent.CLICK,this.onSearchTextButtonClick);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_BATCH_SEARCH_INPUT) == 2)
         {
            this.m_searchFieldInputBatcher = new EventBatcher(m_window.searchBar_mc.searchField_tf,KeyboardEvent.KEY_UP,SEARCH_INPUT_BATCHING_MIN_DELAY,SEARCH_INPUT_BATCHING_MAX_DELAY);
            this.m_searchFieldInputBatcher.addEventListener(EventBatchEvent.EVENT_BATCH,this.onKeyUpBatchHandler);
         }
         else
         {
            m_window.searchBar_mc.searchField_tf.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
         }
         this.m_searchField_tf.restrict("0-9 a-zA-Z\\-\'");
         if(m_window.searchBar_mc.clearsearch_bt == null)
         {
            if(m_window.searchBar_mc.search_bt != null)
            {
               this.m_clearSearchButton_mc = addWidget(new FarmAnimatedButton(m_window.searchBar_mc.search_bt,this.onClearSearchButtonClick)) as FarmAnimatedButton;
            }
         }
         else
         {
            this.m_clearSearchButton_mc = addWidget(new FarmAnimatedButton(m_window.searchBar_mc.clearsearch_bt,this.onClearSearchButtonClick)) as FarmAnimatedButton;
         }
         if(m_window.searchBar_mc.search_mc != null)
         {
            this.m_search_mc = addWidget(new ZwWidget(m_window.searchBar_mc.search_mc)) as ZwWidget;
         }
         this.m_subMenu = addWidget(new FarmTabMenu(m_window.subNav_mc,this.onSubMenuItemSelected,null,true)) as FarmTabMenu;
         (this.m_subMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onSubMenuMouseOver,false,0,true);
         (this.m_subMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSubMenuMouseOut,false,0,true);
         this.m_subDropDownMenu = addWidget(new DropDownMenu(m_window.frame_subNav1_mc,this.onSubDropDownMenuItemSelected),false) as DropDownMenu;
         (this.m_subDropDownMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSubMenuMouseOut,false,0,true);
         this.m_sortByButton = addWidget(new FarmTabButton(m_window.sortBy_bt,ZLocUtils.t("Dialogs","SortBy"))) as FarmTabButton;
         (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onSortByMouseOver,false,0,true);
         (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
         this.m_sortByMenu = addWidget(new DropDownMenu(m_window.frame_subNav2_mc,this.onSortByMenuItemSelected),false) as DropDownMenu;
         (this.m_sortByMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
         this.m_miniSlotMenu = addWidget(new FarmTabMenu(m_window.bottomTabs_mc,this.onMiniSlotMenuItemSelected)) as FarmTabMenu;
         var menuItems:Array = [];
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_SORTING_ALGO) > 1)
         {
            recommendedMenuItem = new MenuItem(RECOMMENDED_MENU_ITEM,ZLocUtils.t("Dialogs","menu_recommended"),false,true);
            menuItems.push(recommendedMenuItem);
         }
         if(MarketFlashSaleManager.instance.isSaleActive())
         {
            marketSaleMenuItem = new MenuItem(MARKETPLACE_SALE_MENU_ITEM,ZLocUtils.t("Dialogs","menu_marketsale"));
            menuItems.push(marketSaleMenuItem);
         }
         var bestSellersMenuItem:MenuItem = new MenuItem(BESTSELLERS_MENU_ITEM,ZLocUtils.t("Dialogs","menu_bestsellers"));
         menuItems.push(bestSellersMenuItem);
         var brandedItems:Array = Global.marketRecommendations.getBrandedItems();
         if(Boolean(brandedItems) && brandedItems.length > 0)
         {
            brandedItemsMenuItem = new MenuItem(BRANDED_ITEMS_MENU_ITEM,ZLocUtils.t("Dialogs","menu_brandedItems"));
            menuItems.push(brandedItemsMenuItem);
         }
         if(RewardCardsManager.getInstance().isRewardCardsActive())
         {
            loyaltyCardItems = new MenuItem(REWARDS_CARDS_ITEM,ZLocUtils.t("Dialogs","menu_loyaltyCards"));
            menuItems.push(loyaltyCardItems);
         }
         this.m_miniSlotMenu.items = menuItems;
         var numMarketSlotCols:int = this.getMarketSize();
         callbacks = new Object();
         callbacks[MarketWindow.CALLBACK_BUY_CASH] = this.onSlotBuyCash;
         callbacks[MarketWindow.CALLBACK_BUY_COIN] = this.onSlotBuyCoin;
         callbacks[MarketWindow.CALLBACK_GET] = this.onSlotGet;
         callbacks[MarketWindow.CALLBACK_MORE_INFO] = this.onSlotMoreInfo;
         callbacks[MarketWindow.CALLBACK_HELP] = this.onHelpButton;
         callbacks[MarketWindow.CALLBACK_PLAY] = this.onSlotPlay;
         callbacks[MarketWindow.CALLBACK_PREVIEW] = this.onSlotPreview;
         callbacks[MarketWindow.CALLBACK_SEND] = this.onSlotSend;
         callbacks[MarketWindow.CALLBACK_UNLOCK] = this.onSlotUnlock;
         callbacks[MarketWindow.CALLBACK_USE] = this.onSlotUse;
         callbacks[MarketWindow.CALLBACK_DONATE] = this.onSlotDonate;
         callbacks[MarketWindow.CALLBACK_REDEEM] = this.onSlotRedeem;
         callbacks[MarketWindow.CALLBACK_LOCK_EXPLANATION] = this.onLockedClicked;
         callbacks[MarketWindow.CALLBACK_TRAVEL_WORLD] = this.onTravelClicked;
         this.m_marketSlotFrame = addWidget(new MarketSlotFrame(m_window.marketCards_mc,callbacks,numMarketSlotCols,this)) as MarketSlotFrame;
         callbacks = new Object();
         callbacks[MarketWindow.CALLBACK_BUY_CASH] = this.onMiniSlotBuyCash;
         callbacks[MarketWindow.CALLBACK_BUY_COIN] = this.onMiniSlotBuyCoin;
         callbacks[MarketWindow.CALLBACK_GET] = this.onSlotGet;
         callbacks[MarketWindow.CALLBACK_MORE_INFO] = this.onSlotMoreInfo;
         callbacks[MarketWindow.CALLBACK_HELP] = this.onHelpButton;
         callbacks[MarketWindow.CALLBACK_PLAY] = this.onSlotPlay;
         callbacks[MarketWindow.CALLBACK_PREVIEW] = this.onMiniSlotPreview;
         callbacks[MarketWindow.CALLBACK_SEND] = this.onMiniSlotSend;
         callbacks[MarketWindow.CALLBACK_UNLOCK] = this.onSlotUnlock;
         callbacks[MarketWindow.CALLBACK_USE] = this.onSlotUse;
         callbacks[MarketWindow.CALLBACK_DONATE] = this.onSlotDonate;
         callbacks[MarketWindow.CALLBACK_REDEEM] = this.onSlotRedeem;
         var numMiniSlots:int = this.getNumMarketMiniSlots();
         this.m_miniSlotFrame = addWidget(new MarketMiniSlotFrame(m_window.miniCards_mc,callbacks,numMiniSlots)) as MarketMiniSlotFrame;
         if(isNewMarketplaceHomepageOn() && this.shouldInitializeHomepage())
         {
            this.m_bestSellersFrame = addWidget(new ZwFrame(m_window.module0_mc)) as ZwFrame;
            this.m_recommendedItemsFrame = addWidget(new ZwFrame(m_window.module1_mc)) as ZwFrame;
            this.m_turboSaleFrame = addWidget(new ZwFrame(m_window.module2_mc)) as ZwFrame;
            this.m_latestLEFrame = addWidget(new ZwFrame(m_window.module3_mc)) as ZwFrame;
            this.m_bestSellersSlot = new GenericSlotContainerFrame(this.m_bestSellersFrame.element.slots_mc,LERecommendationSurfacingSlot,Global.marketRecommendations.getBestSellers(),this);
            this.m_bestSellersFrame.addWidget(this.m_bestSellersSlot);
            this.setSlotsStatsType(this.m_bestSellersSlot,"marketplace_best_sellers");
            this.m_recommendedItemsSlot = new GenericSlotContainerFrame(this.m_recommendedItemsFrame.element.slots_mc,LERecommendationSurfacingSlot,Global.marketRecommendations.getRecommendedItems(),this);
            this.m_recommendedItemsFrame.addWidget(this.m_recommendedItemsSlot);
            this.setSlotsStatsType(this.m_recommendedItemsSlot,"marketplace_recommendations");
            this.m_turboSaleSlot = new GenericSlotContainerFrame(this.m_turboSaleFrame.element.slots_mc,LERecommendationSurfacingSlot,Global.marketRecommendations.getFarmAidsSlot(),this);
            this.m_turboSaleFrame.addWidget(this.m_turboSaleSlot);
            this.setSlotsStatsType(this.m_turboSaleSlot,"marketplace_top_right");
            this.m_latestLESlot = new GenericSlotContainerFrame(this.m_latestLEFrame.element.slots_mc,LERecommendationSurfacingSlot,Global.marketRecommendations.getLatestLESet(),this);
            this.m_latestLEFrame.addWidget(this.m_latestLESlot);
            this.setSlotsStatsType(this.m_latestLESlot,"marketplace_new_arrivals");
         }
         if(RewardCardsManager.getInstance().isRewardCardsActive())
         {
            addWidget(this.m_rewardCardsSlotFrame = new MarketRewardCardsSlotFrame(m_window.miniRewardCards_mc,callbacks),false);
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_REWARD_CARDS_TAB) == 2 || this.m_miniSlotsTab != REWARDS_CARDS_ITEM && !Global.player.getSeenFlag("reward_cards_market_tab") && !isNewMarketplaceHomepageOn())
            {
               this.m_miniSlotsTab = REWARDS_CARDS_ITEM;
               Global.player.setSeenFlag("reward_cards_market_tab");
            }
         }
         if(this.m_LeRevamp)
         {
            submenuitems = [];
            selectedSubTab = 0;
            leTheme = "";
            isNew = false;
            for(tabindex = 0; tabindex < this.m_lesubmenuitems.length; tabindex++)
            {
               leTheme = this.m_lesubmenuitems[tabindex] as String;
               desc = ZLocUtils.t("Dialogs","theme_" + leTheme);
               if(desc == "" && leTheme == "all")
               {
                  desc = ZLocUtils.t("Dialogs","theme_ledefault");
               }
               showExpiry = "";
               isNew = false;
               if(tabindex == 2)
               {
                  leitem = (this.m_leItems[leTheme] as Array)[0];
                  timeleft = leitem.limitedTimeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  parsedtime = FarmGameUtil.parseTimeLeft(timeleft);
                  showExpiry = FarmGameUtil.getFormattedTimeLeftText(parsedtime);
               }
               if(tabindex == 1)
               {
                  isNew = true;
               }
               submenuitems.push(new MenuItem(leTheme,desc,false,isNew,false,showExpiry));
               if(this.m_subType == leTheme)
               {
                  selectedSubTab = tabindex;
               }
            }
            this.m_marketSlotFrameLE = addWidget(new MarketSlotFrameLE(m_window.marketCardsLE_mc,callbacks,3,this)) as MarketSlotFrameLE;
            this.m_marketSlotFrameLE.visible = false;
            this.m_subMenuLE = addWidget(new FarmMultiTabMenu(m_window.subNavLE_mc,this.onLEThemeSelected,submenuitems,false,10,null)) as FarmMultiTabMenu;
            this.m_subMenuLE.selectTab(selectedSubTab);
            this.m_subMenuLE.visible = false;
            this.createMarketLeAds();
            this.m_lePromoSlotFrame.visible = false;
            this.m_mainMenu.setTabVisibility("special",false);
            this.m_miniSlotMenu.visible = false;
            if(this.m_type == FarmGameSettingsManager.TYPE_LIMITED)
            {
               this.toggleLeTab(true);
            }
         }
         if(m_window.miniSale_mc != null)
         {
            this.m_flashSaleFrame = addWidget(new MarketFlashSaleFrame(m_window.miniSale_mc)) as MarketFlashSaleFrame;
         }
         if(MarketFlashSaleManager.instance.isSaleActive())
         {
            this.m_miniSlotsTab = MARKETPLACE_SALE_MENU_ITEM;
         }
         var tabIndex:int = 0;
         for(i = 0; i < menuItems.length; i++)
         {
            menuItem = menuItems[i];
            if(menuItem.data as String == this.m_miniSlotsTab)
            {
               this.onMiniSlotMenuItemSelected(menuItem);
               tabIndex = i;
               break;
            }
         }
         this.m_miniSlotMenu.selectTab(tabIndex);
         if(!this.m_LeRevamp)
         {
            this.createMarketAds();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_SORTING_ALGO) == 2)
         {
            this.m_miniSlotFrame.items = Global.marketRecommendations.getRecommendedItems();
         }
         else
         {
            this.m_miniSlotFrame.items = Global.marketRecommendations.getBestSellers();
         }
         this.attachMenuTooltips(this.m_mainMenu);
         this.m_titleTextField.visible = false;
         this.m_cashCoinsButton.visible = false;
         if(m_window.hasOwnProperty("charitySale_mc") && Boolean(m_window.charitySale_mc))
         {
            this.m_charityBannerFrame = addWidget(new MarketCharityBannerFrame(m_window.charitySale_mc)) as MarketCharityBannerFrame;
            this.m_charityBannerFrame.visible = false;
         }
         this.refreshMenus();
         this.refreshItems();
      }
      
      private function onLeSubMenuSelected(item:MenuItem) : void
      {
         this.m_subType = item.data as String;
         this.m_subSubType = FarmGameSettingsManager.ALL;
         this.refreshItems();
      }
      
      private function onLEThemeSelected(item:MenuItem) : void
      {
         this.m_subType = item.data as String;
         this.m_subSubType = FarmGameSettingsManager.ALL;
         this.refreshMenus();
         this.refreshItems();
      }
      
      private function shouldShowHLightsOverlay() : Boolean
      {
         return Boolean(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LIGHTS_MARKET_OVERLAY)) && !(this is MarketMiniWindow);
      }
      
      private function shouldShowWorldMarketSaleOverlay() : Boolean
      {
         var worldName:String = null;
         var show:Boolean = false;
         if(Global.worldSpecificSalesManager.isActive() && !(this is MarketMiniWindow))
         {
            worldName = Global.worldSpecificSalesManager.worldName;
            show = Global.worldManager.currentWorldType != worldName;
         }
         return show;
      }
      
      protected function shouldInitializeHomepage() : Boolean
      {
         return true;
      }
      
      private function setSlotsStatsType(frame:GenericSlotContainerFrame, statsType:String) : void
      {
         var slot:LERecommendationSurfacingSlot = null;
         for each(slot in frame.slots)
         {
            slot.setItemSource(statsType);
         }
      }
      
      public function addMarketFlashSale() : void
      {
         var menuItems:Array = null;
         var alreadyAdded:Boolean = false;
         var menuItemsLength:int = 0;
         var i:int = 0;
         var menuItem:MenuItem = null;
         var marketSaleMenuItem:MenuItem = null;
         this.m_miniSlotsTab = MARKETPLACE_SALE_MENU_ITEM;
         if(this.m_miniSlotMenu != null)
         {
            menuItems = this.m_miniSlotMenu.items;
            if(menuItems != null)
            {
               alreadyAdded = false;
               menuItemsLength = int(menuItems.length);
               for(i = 0; i < menuItemsLength; i++)
               {
                  menuItem = menuItems[i];
                  if(menuItem.data as String == MARKETPLACE_SALE_MENU_ITEM)
                  {
                     alreadyAdded = true;
                     break;
                  }
               }
               if(!alreadyAdded)
               {
                  marketSaleMenuItem = new MenuItem(MARKETPLACE_SALE_MENU_ITEM,ZLocUtils.t("Dialogs","menu_marketsale"));
                  menuItems.unshift(marketSaleMenuItem);
                  this.m_miniSlotMenu.items = menuItems;
                  this.onMiniSlotMenuItemSelected(marketSaleMenuItem);
                  this.m_miniSlotMenu.selectTab(0);
               }
            }
         }
      }
      
      public function removeMarketFlashSale() : void
      {
         var i:int = 0;
         var menuItems:Array = null;
         var menuItem:MenuItem = null;
         var menuItemsLength:int = 0;
         var removedSale:Boolean = false;
         if(this.m_miniSlotsTab == MARKETPLACE_SALE_MENU_ITEM)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_SORTING_ALGO) == 2)
            {
               this.m_miniSlotsTab = RECOMMENDED_MENU_ITEM;
               this.m_miniSlotFrame.tabType = RECOMMENDED_MENU_ITEM;
            }
            else
            {
               this.m_miniSlotsTab = BESTSELLERS_MENU_ITEM;
            }
         }
         if(this.m_miniSlotMenu != null)
         {
            menuItems = this.m_miniSlotMenu.items;
            if(menuItems != null)
            {
               menuItemsLength = int(menuItems.length);
               removedSale = false;
               for(i = 0; i < menuItemsLength; i++)
               {
                  menuItem = menuItems[i];
                  if(menuItem.data as String == MARKETPLACE_SALE_MENU_ITEM)
                  {
                     menuItems.splice(i,1);
                     this.m_miniSlotMenu.items = menuItems;
                     removedSale = true;
                     break;
                  }
               }
               if(removedSale)
               {
                  menuItemsLength = int(menuItems.length);
                  for(i = 0; i < menuItemsLength; i++)
                  {
                     menuItem = menuItems[i];
                     if(menuItem.data as String == this.m_miniSlotsTab)
                     {
                        this.onMiniSlotMenuItemSelected(menuItem);
                        this.m_miniSlotMenu.selectTab(i);
                        break;
                     }
                  }
                  this.refreshItems();
               }
            }
         }
      }
      
      protected function getMainMenuItems() : Array
      {
         var mainMenuItems:Array = null;
         if(FarmVillageManager.isInFarmVillage())
         {
            mainMenuItems = [new MenuItem("special",ZLocUtils.t("Dialogs",MENU_PREFIX + "special")),new MenuItem("limited",ZLocUtils.t("Dialogs",MENU_PREFIX + "limited")),new MenuItem("seed",ZLocUtils.t("Dialogs",MENU_PREFIX + "seed")),new MenuItem("tree",ZLocUtils.t("Dialogs",MENU_PREFIX + "tree")),new MenuItem("animal",ZLocUtils.t("Dialogs",MENU_PREFIX + "animal")),new MenuItem("building",ZLocUtils.t("Dialogs",MENU_PREFIX + "building")),new MenuItem("decoration",ZLocUtils.t("Dialogs",MENU_PREFIX + "decoration")),new MenuItem("aide",ZLocUtils.t("Dialogs",MENU_PREFIX + "aide")),new MenuItem("landExpansion",ZLocUtils.t("Dialogs",MENU_PREFIX + "landExpansion")),new MenuItem("village",ZLocUtils.t("Dialogs",MENU_PREFIX + "village")),new MenuItem(FarmGameSettingsManager.TYPE_MANAGED_SALE,ZLocUtils.t("Dialogs",MENU_PREFIX + FarmGameSettingsManager.TYPE_MANAGED_SALE)),new MenuItem(FarmGameSettingsManager.TYPE_LOYALTY,ZLocUtils.t("Dialogs",MENU_PREFIX + FarmGameSettingsManager.TYPE_LOYALTY)),new MenuItem(Global
            .worldManager.currentWorldUniqueMarketCard,ZLocUtils.t("Dialogs",MENU_PREFIX + CURRENT_WORLD_MENU_ITEM,{"worldName":Global.worldManager.getWorldFriendlyName()})),new MenuItem("vip",ZLocUtils.t("Dialogs",MENU_PREFIX + "vip")),new MenuItem("bobsFarm",ZLocUtils.t("Dialogs",MENU_PREFIX + "bobsFarm"))];
         }
         else
         {
            mainMenuItems = [new MenuItem("special",ZLocUtils.t("Dialogs",MENU_PREFIX + "special")),new MenuItem("limited",ZLocUtils.t("Dialogs",MENU_PREFIX + "limited")),new MenuItem("seed",ZLocUtils.t("Dialogs",MENU_PREFIX + "seed")),new MenuItem("tree",ZLocUtils.t("Dialogs",MENU_PREFIX + "tree")),new MenuItem("animal",ZLocUtils.t("Dialogs",MENU_PREFIX + "animal")),new MenuItem("building",ZLocUtils.t("Dialogs",MENU_PREFIX + "building")),new MenuItem("decoration",ZLocUtils.t("Dialogs",MENU_PREFIX + "decoration")),new MenuItem("aide",ZLocUtils.t("Dialogs",MENU_PREFIX + "aide")),new MenuItem("landExpansion",ZLocUtils.t("Dialogs",MENU_PREFIX + "landExpansion")),new MenuItem("vault",ZLocUtils.t("Dialogs",MENU_PREFIX + "vault")),new MenuItem(FarmGameSettingsManager.TYPE_MANAGED_SALE,ZLocUtils.t("Dialogs",MENU_PREFIX + FarmGameSettingsManager.TYPE_MANAGED_SALE)),new MenuItem(FarmGameSettingsManager.TYPE_LOYALTY,ZLocUtils.t("Dialogs",MENU_PREFIX + FarmGameSettingsManager.TYPE_LOYALTY)),new MenuItem(Global
            .worldManager.currentWorldUniqueMarketCard,ZLocUtils.t("Dialogs",MENU_PREFIX + CURRENT_WORLD_MENU_ITEM,{"worldName":Global.worldManager.getWorldFriendlyName()})),new MenuItem("vip",ZLocUtils.t("Dialogs",MENU_PREFIX + "vip")),new MenuItem("bobsFarm",ZLocUtils.t("Dialogs",MENU_PREFIX + "bobsFarm"))];
         }
         return mainMenuItems;
      }
      
      private function createLEMarketEntries() : void
      {
         var item:FarmItem = null;
         var marketDesc:String = null;
         var item1:FarmItem = null;
         var expiring:String = null;
         var items:Array = Global.farmGameSettingsManager.getFarmItemsArray(FarmGameSettingsManager.TYPE_LIMITED,FarmGameSettingsManager.ALL,FarmGameSettingsManager.ALL,"timeStart",FarmGameSettingsManager.DESCENDING,true,"",null,true);
         if(!this.m_filteredItems)
         {
            this.setupItemFilters();
         }
         for(var i:* = 0; i < items.length; i++)
         {
            item = items[i] as FarmItem;
            if(this.m_filteredItems.hasOwnProperty(item.name))
            {
               items.splice(i,1);
               i--;
            }
         }
         if(items.length > 0)
         {
            marketDesc = "";
            for each(item1 in items)
            {
               if(item1.marketCardDescriptor)
               {
                  marketDesc = item1.marketCardDescriptor.name;
                  if(marketDesc)
                  {
                     if(!this.m_leItems.hasOwnProperty(marketDesc))
                     {
                        this.m_leItems[marketDesc] = [];
                        if(marketDesc != "lecrop" && marketDesc != "mondaysink")
                        {
                           this.m_lesubmenuitems.push(marketDesc);
                        }
                     }
                     (this.m_leItems[marketDesc] as Array).push(item1);
                  }
               }
            }
            this.m_lesubmenuitems.reverse();
            this.m_lesubmenuitems.unshift("all");
            expiring = this.m_lesubmenuitems.pop();
            this.m_lesubmenuitems.splice(2,0,expiring);
            this.m_lesubmenuitems.splice(5,0,"lecrop");
         }
      }
      
      public function getNumMarketMiniSlots() : int
      {
         var numColumns:int = this.getMarketSize();
         var numMiniSlots:int = 0;
         if(numColumns == NUM_MED_MARKET_COLS)
         {
            numMiniSlots = NUM_MED_MARKET_MINI_SLOTS;
         }
         else
         {
            numMiniSlots = NUM_SMALL_MARKET_MINI_SLOTS;
         }
         return numMiniSlots;
      }
      
      override protected function hideAllInstances() : void
      {
         var obj:DisplayObject = null;
         for(var iChild:* = int(m_window.numChildren - 1); iChild >= 0; iChild--)
         {
            obj = m_window.getChildAt(iChild);
            if(obj is MovieClip && ZwWidgetUtils.isValidElement(obj))
            {
               obj.visible = false;
            }
         }
      }
      
      private function setupCurrencyMeters() : void
      {
         var worldScore:Number = NaN;
         var worldScoreUnitMCName:String = null;
         var worldScoreValue:String = null;
         var currencyElement:String = null;
         this.m_cashButton = addWidget(new FarmAnimatedButton(m_window.fcMeter_mc,null)) as FarmAnimatedButton;
         this.m_cashTextField = addWidget(new ZwTextField(m_window.fcMeter_mc.fcValue_tf,Utilities.formatNumber(Global.player.cash))) as ZwTextField;
         if("loyaltyPoints_bt" in m_window && LoyaltyProgramManager.getInstance().userPassesPrereq())
         {
            addWidget(this.m_statusPointsButton = new FarmAnimatedButton(m_window.loyaltyPoints_bt,null));
            if("loyaltyValue_tf" in m_window.loyaltyPoints_bt)
            {
               addWidget(this.m_statusPointsText = new ZwTextField(m_window.loyaltyPoints_bt.loyaltyValue_tf,Global.player.getWorldCurrencyTotal(Currency.COST_STATUS_POINTS).toString()));
            }
         }
         this.m_currentCurrency = Global.worldManager.getCurrencyForWorld(Global.worldManager.currentWorldType);
         this.m_worldCurrencyActive = this.m_currentCurrency != null && this.m_currentCurrency != "" && this.m_currentCurrency != Currency.GOLD && this.m_currentCurrency != Currency.COINS;
         if(this.m_worldCurrencyActive && this.m_currentCurrency != QuestConstants.REWARD_TROWELS)
         {
            worldScore = Global.player.currentWorldScore;
            this.m_coinButton = addWidget(new FarmAnimatedButton(m_window.coinMeter_mc,null)) as FarmAnimatedButton;
            this.m_coinTextField = addWidget(new ZwTextField(m_window.coinMeter_mc.coinValue_tf,Utilities.formatNumber(Global.player.gold))) as ZwTextField;
            worldScoreUnitMCName = Global.worldManager.currentWorldScoreId + "_mc";
            worldScoreValue = Global.player.getWorldLevel(Global.worldManager.currentWorldScoreId).toString();
            if(ObjectUtil.pathExists(m_window,worldScoreUnitMCName) && Boolean(m_window[worldScoreUnitMCName]["worldScore_tf"]))
            {
               this.m_worldScorePointsWidget = addWidget(new ZwBaseWidget(m_window[worldScoreUnitMCName]),true);
               this.m_worldScoreText = addWidget(new ZwTextField(m_window[worldScoreUnitMCName]["worldScore_tf"],worldScoreValue)) as ZwTextField;
            }
            else if(worldScore != 0 && ObjectUtil.pathExists(m_window,"zpMeter_mc") && ObjectUtil.pathExists(m_window.zpMeter_mc,"levelzp_tf"))
            {
               this.m_worldScoreMeter = addWidget(new ZwWidget(m_window.zpMeter_mc)) as ZwWidget;
               this.m_worldScoreText = addWidget(new ZwTextField(m_window.zpMeter_mc.levelzp_tf,worldScoreValue),true) as ZwTextField;
            }
            currencyElement = this.m_currentCurrency + "_bt";
            if(m_window[currencyElement])
            {
               this.m_currencyButton = addWidget(new FarmAnimatedButton(m_window[currencyElement],this.onCurrencyButtonClick)) as FarmAnimatedButton;
               this.m_currencyTextField = addWidget(new ZwTextField(m_window[currencyElement].value_tf,Utilities.formatNumber(Global.player.currentWorldCurrencyTotal))) as ZwTextField;
            }
         }
         else
         {
            this.m_currencyButton = addWidget(new FarmAnimatedButton(m_window.coinMeter_mc,null)) as FarmAnimatedButton;
            this.m_coinTextField = addWidget(new ZwTextField(m_window.coinMeter_mc.coinValue_tf,Utilities.formatNumber(Global.player.gold))) as ZwTextField;
         }
      }
      
      public function setupMarket3SlotColumns() : void
      {
         var numColumns:int = this.getMarketSize();
         if(numColumns == NUM_MED_MARKET_COLS)
         {
            m_window.gotoAndStop(2);
            if(m_window.hasOwnProperty("bgMed_mc"))
            {
               m_window.bgMed_mc.visible = true;
            }
         }
         else
         {
            m_window.gotoAndStop(1);
            if(m_window.hasOwnProperty("bgSmall_mc"))
            {
               m_window.bgSmall_mc.visible = true;
            }
         }
      }
      
      public function getMarketSize() : int
      {
         var numColumns:int = NUM_SMALL_MARKET_COLS;
         if(Global.stage.stageWidth > MARKETCARD_WIDTH * 4 && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_3_WIDESCREEN) > 1)
         {
            numColumns = NUM_MED_MARKET_COLS;
         }
         return numColumns;
      }
      
      public function refreshMarketWindow() : void
      {
         if(this.m_LeRevamp)
         {
            this.createMarketLeAds(true);
         }
         else
         {
            this.createMarketAds(true);
         }
         this.refreshMenus();
         this.refreshItems();
      }
      
      private function coinSlideToggle(event:MouseEvent) : void
      {
         if(this.m_coinSlideExpandedState)
         {
            this.m_coinSlideExpanded.visible = false;
            this.m_coinSlideContracted.visible = true;
            this.m_coinSlideExpandedState = false;
         }
         else
         {
            this.m_coinSlideExpanded.visible = true;
            this.m_coinSlideContracted.visible = false;
            this.m_coinSlideExpandedState = true;
         }
      }
      
      private function createMarketAds(forceDataRefresh:Boolean = false) : void
      {
         var marketPromoMC:MovieClip = this.getMarketPromoElement();
         if(marketPromoMC)
         {
            if(this.m_promoSlotFrame)
            {
               removeWidget(this.m_promoSlotFrame);
            }
            this.m_promoSlotFrame = addWidget(new MarketPromoSlotFrame(marketPromoMC,this.onPromoClickCallback)) as MarketPromoSlotFrame;
            this.m_promoSlotFrame.items = Global.marketConfigSettings.getActiveMarketPromotions(forceDataRefresh);
         }
      }
      
      private function createMarketLeAds(refresh:Boolean = false) : void
      {
         var marketLePromoMC:MovieClip = null;
         if(m_window.hasOwnProperty("promoCardsLE_mc"))
         {
            if(this.m_LeHeader == null)
            {
               this.m_LeHeader = addWidget(new ZwWidget(m_window.LE_header_mc)) as ZwWidget;
               this.m_LeHeader.element.title_tf.text = ZLocUtils.t("Dialogs","le_maintitle");
            }
            if(this.m_LeSubtitle == null)
            {
               this.m_LeSubtitle = addWidget(new ZwWidget(m_window.LE_subtitle_mc)) as ZwWidget;
               this.m_LeSubtitle.element.body_tf.text = ZLocUtils.t("Dialogs","le_subtitle");
            }
            marketLePromoMC = m_window.promoCardsLE_mc as MovieClip;
            if(this.m_lePromoSlotFrame)
            {
               removeWidget(this.m_lePromoSlotFrame);
            }
            this.m_lePromoSlotFrame = addWidget(new MarketPromoLESlotFrame(marketLePromoMC,this.onPromoClickCallback)) as MarketPromoLESlotFrame;
            this.m_lePromoSlotFrame.items = Global.marketConfigSettings.getActiveLEPromoItems(this.getLePromoBannerThemes(),refresh);
            this.m_LeHeader.visible = true;
            this.m_LeSubtitle.visible = true;
            if(m_window.bgLEDefaultMed_mc)
            {
               m_window.bgLEDefaultMed_mc.visible = true;
            }
         }
      }
      
      private function getLePromoBannerThemes() : Array
      {
         var result:Array = new Array();
         if(Boolean(this.m_lesubmenuitems) && this.m_lesubmenuitems.length >= 5)
         {
            result.push(this.m_lesubmenuitems[1]);
            result.push(this.m_lesubmenuitems[3]);
            result.push(this.m_lesubmenuitems[4]);
         }
         return result;
      }
      
      public function setCloseCallback(closeCallback:Function) : void
      {
         this.m_closeCallback = closeCallback;
      }
      
      private function refresh() : void
      {
      }
      
      private function onGetCurrencyButtonClick(event:MouseEvent) : void
      {
         MarketStatsManager.countClickGetCurrency();
         var variant:int = Global.experimentManager.getExperimentVariant("fv_ingame_payments");
         if(variant == InGamePaymentsManager.VARIANT_MARKET)
         {
            FarmStatsManager.count("Add_cash_payments_test","click_button_add_cash","click_MP_button");
            FarmStatsManager.count("Add_cash_payments_test","dialog_impresssions",variant.toString());
         }
         else if(this is MarketMiniWindow)
         {
            this.displayPaymentsPage("mini_market_add_cash");
         }
         else
         {
            this.displayPaymentsPage("marketplace_add_cash");
         }
      }
      
      private function onSortByMouseOver(evt:MouseEvent) : void
      {
         if(!this.m_sortByMenu.visible)
         {
            this.m_sortByButton.setToggleState(ZwToggleState.SELECTED);
            this.m_sortByMenu.visible = true;
         }
      }
      
      private function onSortByMouseOut(evt:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_sortByButton.element as MovieClip,evt.relatedObject) && !FarmGameUtil.isDescendant(this.m_sortByMenu.element as MovieClip,evt.relatedObject))
         {
            this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
            this.m_sortByMenu.visible = false;
         }
      }
      
      private function onSortByMenuItemSelected(item:MenuItem) : void
      {
         this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
         this.m_sortByMenu.visible = false;
         this.m_sortBy = item.data["sortBy"];
         this.m_sortDirection = item.data["sortDirection"];
         MarketStatsManager.countClickSort(this.m_type,this.m_sortBy,this.m_sortDirection);
         this.refreshItems();
      }
      
      private function onMainMenuItemSelected(item:MenuItem) : void
      {
         var subTypes:Array = null;
         var subType:String = null;
         LESurfacingManager.instance.onCloseMarketDialog();
         if(this.m_searchField_tf.text != this.m_defaultString)
         {
            this.clearSearch();
         }
         this.m_type = item.data as String;
         this.m_subType = FarmGameSettingsManager.ALL;
         this.m_subSubType = FarmGameSettingsManager.ALL;
         MarketStatsManager.countClickTypeMenu(this.m_type);
         if(this.m_type == "clothes")
         {
            FarmStatsManager.count("Avatar","market_avatar","click_on_clothes_tab ");
         }
         if(SubscriptionsManager.isEligibleForVIPBenifit())
         {
            this.m_vipDiscountTf.visible = false;
            if(this.m_type == "landExpansion")
            {
               this.m_vipDiscountTf.text = ZLocUtils.t("Dialogs","vip_ruby_landexpansions");
            }
            else if(this.m_type == "sale")
            {
               subTypes = this.getSubTypes(this.m_type);
               for each(subType in subTypes)
               {
                  if(subType == "landExpansion")
                  {
                     this.m_vipDiscountTf.text = ZLocUtils.t("Dialogs","vip_ruby_saletab_landexpansions");
                     break;
                  }
               }
            }
         }
         if(this.m_type == "limited")
         {
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKET_OPTIM_SORTING) <= 1)
            {
               this.m_sortBy = "limitedStart";
               this.m_sortDirection = "desc";
            }
            this.m_preserveSort = true;
            FarmStatsManager.count("Market","LE_tab","Click");
         }
         this.refreshMenus();
         this.refreshItems();
      }
      
      private function onSubMenuItemSelected(item:MenuItem) : void
      {
         this.m_subType = item.data as String;
         this.m_subSubType = FarmGameSettingsManager.ALL;
         this.refreshItems();
      }
      
      private function onSubMenuMouseOver(evt:MouseEvent) : void
      {
         var isTabFound:Boolean = false;
         var tab:FarmTabMenuButton = null;
         var i:int = 0;
         var item:MenuItem = null;
         var subSubTypes:Array = null;
         var items:Array = null;
         var subSubType:String = null;
         var tabPosition:Point = null;
         var menuPosition:Point = null;
         if(this.m_currentSubMenuTab == null || !FarmGameUtil.isDescendant(this.m_currentSubMenuTab.element as DisplayObjectContainer,evt.target as DisplayObject))
         {
            isTabFound = false;
            for(i = 0; i < this.m_subMenu.numItems; i++)
            {
               tab = this.m_subMenu.getTab(i);
               if(Boolean(tab) && FarmGameUtil.isDescendant(tab.element as DisplayObjectContainer,evt.target as DisplayObject))
               {
                  isTabFound = true;
                  break;
               }
            }
            if(isTabFound)
            {
               this.m_currentSubMenuTab = tab;
               item = this.m_subMenu.getItem(i);
               subSubTypes = this.getSubSubTypes(this.m_type,item.data as String);
               if(subSubTypes)
               {
                  items = new Array();
                  for each(subSubType in subSubTypes)
                  {
                     items.push(new MenuItem(subSubType,ZLocUtils.t("Dialogs",MENU_PREFIX + subSubType)));
                  }
                  this.m_subDropDownMenu.items = items;
                  tabPosition = (this.m_subMenu.element as MovieClip).localToGlobal(new Point(tab.x,tab.y));
                  menuPosition = m_window.localToGlobal(new Point(this.m_subDropDownMenu.x,this.m_subDropDownMenu.y));
                  menuPosition.x = tabPosition.x + (tab.width - this.m_subDropDownMenu.width) / 2;
                  menuPosition = m_window.globalToLocal(menuPosition);
                  this.m_subDropDownMenu.x = menuPosition.x;
                  this.m_subDropDownMenu.visible = true;
               }
            }
            else
            {
               this.m_currentSubMenuTab = null;
               this.m_subDropDownMenu.visible = false;
            }
         }
      }
      
      private function onSubMenuMouseOut(evt:MouseEvent) : void
      {
         if(Boolean(this.m_currentSubMenuTab && this.m_subDropDownMenu.visible) && Boolean(!FarmGameUtil.isDescendant(this.m_currentSubMenuTab.element as DisplayObjectContainer,evt.relatedObject)) && !FarmGameUtil.isDescendant(this.m_subDropDownMenu.element as DisplayObjectContainer,evt.relatedObject))
         {
            this.m_currentSubMenuTab = null;
            this.m_subDropDownMenu.visible = false;
         }
      }
      
      private function onSubDropDownMenuItemSelected(item:MenuItem) : void
      {
         var tab:FarmTabMenuButton = null;
         for(var i:int = 0; i < this.m_subMenu.numItems; i++)
         {
            tab = this.m_subMenu.getTab(i);
            if(tab == this.m_currentSubMenuTab)
            {
               this.m_subType = (this.m_subMenu.getItem(i) as MenuItem).data as String;
               this.m_subMenu.selectTab(i);
               break;
            }
         }
         this.m_subSubType = item.data as String;
         this.m_currentSubMenuTab = null;
         this.m_subDropDownMenu.visible = false;
         this.refreshItems();
      }
      
      private function onMiniSlotMenuItemSelected(item:MenuItem) : void
      {
         this.m_miniSlotsTab = item.data as String;
         this.refreshMiniSlots();
      }
      
      private function refreshMiniSlots() : void
      {
         var items:Array = [];
         if(this.m_flashSaleFrame != null)
         {
            this.m_flashSaleFrame.visible = false;
         }
         if(this.m_miniSlotFrame != null)
         {
            this.m_miniSlotFrame.visible = false;
         }
         if(this.m_rewardCardsSlotFrame != null)
         {
            this.m_rewardCardsSlotFrame.visible = false;
         }
         switch(this.m_miniSlotsTab)
         {
            case RECOMMENDED_MENU_ITEM:
               FarmStatsManager.featureSample("marketplace",RECOMMENDED_MENU_ITEM,"clicks");
               items = Global.marketRecommendations.getRecommendedItems();
               this.m_miniSlotFrame.items = items;
               this.m_miniSlotFrame.visible = true;
               this.m_miniSlotFrame.tabType = RECOMMENDED_MENU_ITEM;
               break;
            case MARKETPLACE_SALE_MENU_ITEM:
               if(this.m_flashSaleFrame != null)
               {
                  this.m_flashSaleFrame.visible = true;
               }
               break;
            case BESTSELLERS_MENU_ITEM:
               FarmStatsManager.featureSample("marketplace",BESTSELLERS_MENU_ITEM,"clicks");
               FarmStatsManager.count("Market","Bestseller_tab","Click");
               items = Global.marketRecommendations.getBestSellers();
               this.m_miniSlotFrame.items = items;
               this.m_miniSlotFrame.visible = true;
               this.m_miniSlotFrame.tabType = BESTSELLERS_MENU_ITEM;
               break;
            case BRANDED_ITEMS_MENU_ITEM:
               items = Global.marketRecommendations.getBrandedItems();
               this.m_miniSlotFrame.items = items ? items : [];
               this.m_miniSlotFrame.visible = true;
               break;
            case REWARDS_CARDS_ITEM:
               FarmStatsManager.count("Market","Myrewards_tab","Click");
               items = RewardCardsManager.getInstance().getRewardCards();
               this.m_rewardCardsSlotFrame.visible = true;
               this.m_rewardCardsSlotFrame.items = items;
         }
      }
      
      private function onMiniSlotBuyCash(slot:MarketSlot) : void
      {
         MarketStatsManager.countClickMarketMiniBuy(slot.data.name,"cash",slot.data.cash,this.m_miniSlotFrame);
         switch(this.m_miniSlotsTab)
         {
            case RECOMMENDED_MENU_ITEM:
               FarmStatsManager.count("Market","Recommended_tab","Purchase",slot.data.name,String(slot.data.cash));
               break;
            case BESTSELLERS_MENU_ITEM:
               FarmStatsManager.count("Market","Bestseller_tab","Purchase",slot.data.name,String(slot.data.cash));
         }
         if(LESetManager.isApartOfCollection(slot.data))
         {
            LESetManager.fireToaster();
         }
         this.onSlotBuyCash(slot);
      }
      
      private function onMiniSlotBuyCoin(slot:MarketSlot) : void
      {
         MarketStatsManager.countClickMarketMiniBuy(slot.data.name,"currency",slot.data.cost,this.m_miniSlotFrame);
         this.onSlotBuyCoin(slot);
      }
      
      private function onMiniSlotPreview(slot:MarketSlot) : void
      {
         MarketStatsManager.countClickMarketMiniPreview(this.m_miniSlotFrame);
         this.onSlotPreview(slot,true);
      }
      
      private function onMiniSlotSend(slot:MarketSlot) : void
      {
         MarketStatsManager.countClickMarketMiniSend(slot.data.name,slot.data.cash,this.m_miniSlotFrame);
         this.onSlotSend(slot);
      }
      
      private function onSlotBuyCash(slot:MarketSlot) : void
      {
         this.onItemBuyCash(slot.data);
      }
      
      private function onSlotBuyCoin(slot:MarketSlot) : void
      {
         this.onItemBuyCoin(slot.data);
      }
      
      private function onSlotGet(slot:MarketSlot) : void
      {
         this.onItemGet(slot.data);
      }
      
      private function onLockedClicked(slot:MarketSlot) : void
      {
         var lastPreReqTested:Object = slot.data.diagnoseFailedPurchasePrereqs();
         var lastType:String = "";
         var lastValue:String = "";
         var lastQuantity:String = "";
         if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_TYPE))
         {
            lastType = lastPreReqTested[PrerequisiteConstants.KEY_TYPE];
         }
         if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_VALUE))
         {
            lastValue = lastPreReqTested[PrerequisiteConstants.KEY_VALUE];
         }
         if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_QUANTITY))
         {
            lastQuantity = lastPreReqTested[PrerequisiteConstants.KEY_QUANTITY];
         }
         var explanation:LockedExplanation = Global.marketConfigSettings.getLockExplanation(lastType,lastValue);
         explanation.showExplanation(lastQuantity);
      }
      
      private function onSlotMoreInfo(slot:MarketSlot) : void
      {
         var babyType:String = null;
         var cashAmount:int = 0;
         MarketStatsManager.countItemInfo();
         var farmItem:FarmItem = slot.data as FarmItem;
         if(slot.data is StarterPackItem)
         {
            MarketStatsManager.countStarterPackMarketStat(StarterPackUtility.STARTER_PACK_MARKET_CARD_KINGDOM,StarterPackUtility.STARTER_PACK_MARKET_CLICK_PHYLUM);
            this.displayBuyStarterPackWindow(slot.data,this.onMCStarterPackWindowBuy,this.onMCStarterPackWindowClose);
         }
         else if(farmItem is StencilPortalItem)
         {
            StencilManager.instance().showMainUI();
            StatsManager.count(StencilManager.instance().featureName,"market_click","open_feature_ui");
            this.close();
         }
         else if(farmItem is ExpansionAccessItem)
         {
            this.showExpansionAccessDialog(farmItem as ExpansionAccessItem);
         }
         else if(farmItem is IUGCItem)
         {
            this.openUGCItemEditor(farmItem);
         }
         else if(Boolean(farmItem) && Boolean(farmItem is SeedItem) && (farmItem as SeedItem).isSuperCrop())
         {
            StatsManager.count(SuperCropConstants.SUPERCROP_COUNTER,"marketcard",farmItem.name,"unlock","",Global.worldManager.currentWorldType);
            this.displaySuperCropUnlockWindow(farmItem as HarvestableItem);
         }
         else if(slot.data.promoMode == "premiumBaby")
         {
            babyType = "";
            switch(farmItem.name)
            {
               case TRareBaby.TYPE_SEEDLING:
                  babyType = TRareBaby.TYPE_SEEDLING;
                  break;
               case TRareBaby.TYPE_BABY_ANIMAL:
                  babyType = TRareBaby.TYPE_BABY_ANIMAL;
                  break;
               default:
                  ErrorManager.addError("Wrong tag rareBaby for item [" + farmItem.name + "]");
            }
            if(babyType != "")
            {
               cashAmount = Global.farmGameSettingsManager.getNumber(farmItem.name + "_cash",2);
               if(Global.player.cash >= cashAmount)
               {
                  Global.player.cash -= cashAmount;
                  this.close();
                  TransactionManager.addTransaction(new TRareBaby(babyType));
               }
               else
               {
                  UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",cashAmount);
               }
            }
         }
         else if(slot.data.promoMode == LESetManager.LESET_PROMO_ID)
         {
            this.openLESetDisplayDialog();
         }
         else if(farmItem.isBerryBuyableLicense())
         {
            this.displayBuyBerryLicenseWindow(slot.data);
         }
         else
         {
            MarketStatsManager.countCashCropsInfoClick(slot.data.name);
            this.displayBuyCashLicenseWindow(slot.data);
         }
      }
      
      private function displayBuyStarterPackWindow(item:FarmItem, acceptCallback:Function, cancelCallback:Function) : void
      {
         FarmStatsManager.count("dialog","starterpack_marketcard_dialog","view");
         UI.displayPopup(new MarketBuyStarterPackWindow(item,acceptCallback,cancelCallback,this),false);
         this.toggleInput(false);
      }
      
      private function cleanupBuyStarterPackWindow() : void
      {
         this.toggleInput();
      }
      
      private function onPromoStarterPackWindowBuy(item:FarmItem) : void
      {
         FarmStatsManager.count("dialog","starterpack_marketad_dialog","button_buy");
         this.cleanupBuyStarterPackWindow();
      }
      
      private function trackBrandPromoView() : void
      {
      }
      
      private function onMCStarterPackWindowBuy(item:FarmItem) : void
      {
         FarmStatsManager.count("dialog","starterpack_marketcard_dialog","button_buy");
         this.cleanupBuyStarterPackWindow();
      }
      
      private function onPromoStarterPackWindowClose(item:FarmItem) : void
      {
         FarmStatsManager.count("dialog","starterpack_marketad_dialog","button_cancel");
         this.cleanupBuyStarterPackWindow();
      }
      
      private function onMCStarterPackWindowClose(item:FarmItem) : void
      {
         FarmStatsManager.count("dialog","starterpack_marketcard_dialog","button_cancel");
         this.cleanupBuyStarterPackWindow();
      }
      
      private function onHelpButton(slot:MarketSlot) : void
      {
         switch((slot.data as FarmItem).whatIsThisDialog)
         {
            case "dreyers":
               UI.displayPopup(new DreyersWhatsThisDialog(),false);
               break;
            case SuperPlotManager.WHAT_IS_THIS_DIALOG_NAME:
               SuperPlotManager.showTutorial();
         }
      }
      
      private function onSlotPlay(slot:MarketSlot) : void
      {
         if(slot.data.promoMode == CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID)
         {
            CityvilleLaunchPromoRound2Dialog.popDialog(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_DIALOG);
            FarmStatsManager.count(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID,"market_card","clicks");
         }
         else if(slot.data.promoMode == CPigoGameToken.PROMO_MODE)
         {
            this.openPigoGame(null,"market_card");
         }
         else if(slot.data.promoMode == "scratchcard")
         {
            this.openScratchCard(null,ScratchCardWindow.SCRATCH_CARD_ENTRY_DESCRIPTOR_CARD);
         }
         else if(slot.data.promoMode == "prizemachine")
         {
            this.openPrizeMachine(null);
         }
         else
         {
            this.displayMiniGameWindow(slot.data);
         }
      }
      
      private function onSlotPreview(slot:MarketSlot, isMiniSlotRequest:Boolean = false) : void
      {
         var item:FarmItem = slot.data;
         MarketStatsManager.countClickPreview(item.name);
         if(item is ClothingItem)
         {
            FarmStatsManager.count("Avatar","market_avatar","click_try_on_clothes");
            this.displayAvatarEditorWindow(item as ClothingItem);
         }
         else
         {
            this.displayMarketPreviewWindow(item,isMiniSlotRequest,false,slot);
         }
      }
      
      private function onSlotSend(slot:MarketSlot) : void
      {
         this.onItemSend(slot.data);
      }
      
      private function onSlotUnlock(slot:MarketSlot) : void
      {
         this.onItemUnlock(slot.data);
      }
      
      private function onSlotUse(slot:MarketSlot) : void
      {
         this.onItemUse(slot.data);
      }
      
      private function onSlotDonate(slot:MarketSlot) : void
      {
         this.onItemDonate(slot.data);
      }
      
      private function onSlotRedeem(slot:MarketSlot) : void
      {
         this.onItemRedeem(slot.data);
      }
      
      private function onItemUse(item:FarmItem) : void
      {
         var seedData:SeedItem = null;
         var seedPackageItem:FarmItem = null;
         if(item != null)
         {
            if(item is SeedItem)
            {
               seedData = item as SeedItem;
               if(seedData)
               {
                  seedPackageItem = Global.farmGameSettingsManager.getFarmItemByName(seedData.seedpackage);
                  if(seedPackageItem)
                  {
                     FarmStatsManager.count("giftable_seeds",seedPackageItem.name,"click_use");
                     if(!Global.player.getSeenFlag(seedPackageItem.name + "_use_first_time"))
                     {
                        Global.player.setSeenFlag(seedPackageItem.name + "_use_first_time");
                        FarmStatsManager.count("giftable_seeds",seedPackageItem.name,"click_use_first_time");
                     }
                     this.onItemBuyCoin(item);
                  }
               }
            }
            else if(item is DecorationItem || item is ChangeFarmItem)
            {
               item.onUse(0);
               this.close();
            }
         }
      }
      
      private function onItemDonate(item:FarmItem) : void
      {
         var seedData:SeedItem = null;
         var donateWindow:DisplayObject = null;
         if(item != null && item is SeedItem)
         {
            seedData = item as SeedItem;
            if(seedData)
            {
               donateWindow = DonateWindowFactory.getInstance(seedData,this.toggleInput,DonateWindow.SOURCE_MARKET);
               if(donateWindow != null)
               {
                  UI.displayPopup(donateWindow,false);
                  this.toggleInput(false);
               }
               else
               {
                  GlobalEngine.log("Donate","Unable to create donation window for item: " + item.name);
               }
            }
         }
      }
      
      private function onItemRedeem(item:FarmItem) : void
      {
         var featureName:String = null;
         if(item != null && !RewardCardsManager.getInstance().redeemRewardCard(item))
         {
            featureName = ItemMembershipManager.getOnboardingFeatureNameForItem(item);
            if(featureName)
            {
               StatsManager.count(featureName,StatsTrackingConstants.MARKETPLACE,StatsTrackingConstants.CLICK_REDEEM,item.name);
               ItemMembershipManager.redeem(featureName,item.code);
            }
         }
         this.close();
      }
      
      private function onItemGet(item:FarmItem) : void
      {
         var seedData:SeedItem = null;
         var seedPackageItem:FarmItem = null;
         if(item != null && item is SeedItem)
         {
            seedData = item as SeedItem;
            if(seedData)
            {
               seedPackageItem = Global.farmGameSettingsManager.getFarmItemByName(seedData.seedpackage);
               if(seedPackageItem)
               {
                  FarmStatsManager.count("giftable_seeds",seedPackageItem.name,"click_ask");
                  UI.displayPopup(new BuySeedPackages(seedPackageItem.name,"get",this.toggleInput),false);
                  this.toggleInput(false);
               }
            }
         }
      }
      
      private function shouldGetPurchaseConfirmation(item:FarmItem) : Boolean
      {
         return (item.getItemPackageHash() != null || item.type == "fuel" || item.type == "turbo") && item.realCashCost >= PAYMENT_CONFIRMATION_MINIMUM && item.className != MultiRewardTreasureConstructionBuilding.NON_PAYER_TILE && item.className != MultiRewardTreasureConstructionBuilding.PAYER_TILE && item.className != MultiRewardTreasureConstructionBuilding.PAYER_LAND_BUNDLE && item.className != MultiRewardTreasureConstructionBuilding.PAYER_BUNDLE_TILE && item.className != MultiRewardTreasureConstructionBuilding.NEW_LAND_BUNDLE;
      }
      
      private function onItemBuyCash(item:FarmItem) : void
      {
         var dialog:GenericDialog = null;
         var callback:Function = null;
         var confirmationText:String = null;
         if(Boolean(item.worldRestrictions) && item.worldRestrictions.length > 0)
         {
            if(Global.worldManager.getAvailableTravelWorlds().length > 0 && !Global.player.getSeenFlag(SEEN_WORLD_LOCK_REMINDER_FLAG) && item.placeable)
            {
               dialog = null;
               callback = function():void
               {
                  dialog.destroy();
                  buyItem(item,Currency.CASH);
               };
               dialog = UI.showMessage(ZLocUtils.t("Dialogs","market_reminder_world_lock"),UI.BUTTON_LAYOUT_ACCEPT_CANCEL,null,null,true,callback);
               Global.player.setSeenFlag(SEEN_WORLD_LOCK_REMINDER_FLAG);
            }
            else if(this.shouldGetPurchaseConfirmation(item))
            {
               this.m_currentItem = item;
               confirmationText = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":item.realCashCost});
               UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup,"farmAnimatedCashConfirmation",true,true);
            }
            else
            {
               this.buyItem(item,Currency.CASH);
            }
         }
         else if(this.shouldGetPurchaseConfirmation(item))
         {
            this.m_currentItem = item;
            confirmationText = ZLocUtils.t("Dialogs","FarmCashBuyConfirmation",{"price":item.realCashCost});
            UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onClickAcceptPopup,"farmAnimatedCashConfirmation",true,true);
         }
         else
         {
            this.buyItem(item,Currency.CASH);
         }
      }
      
      public function onClickAcceptPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && this.m_currentItem != null)
         {
            this.buyItem(this.m_currentItem,Currency.CASH);
         }
      }
      
      private function onItemBuyCoin(item:FarmItem) : void
      {
         var currency:String = item.marketIsCoin ? Currency.COINS : item.market;
         if(item.isDealOfDaySaleItem && DealOfDayHelper.getDealOfDayItemCurrency(item.code) == Currency.COINS)
         {
            currency = Currency.COINS;
         }
         this.buyItem(item,currency);
      }
      
      private function onItemSend(item:FarmItem, quantity:int = 1) : void
      {
         var itemContext:String = null;
         FarmStatsManager.count("fv_buyableGift","click_send");
         var classField:String = MarketPreviewWindow.marketPreviewActive ? "preview_window" : "click";
         FarmStatsManager.featureSample("marketplace",classField,"send",item.name);
         if(Global.worldManager.isVisiting())
         {
            if(Global.worldManager.isVisitingNeighbor())
            {
               itemContext = TBuyAndSendPresent.ITEMCONTEXT_NEIGHBORFARM;
            }
            else
            {
               itemContext = TBuyAndSendPresent.ITEMCONTEXT_MODELFARM;
            }
            FarmStatsManager.count(itemContext,"click_send_item",item.name,String(item.cash));
         }
         else
         {
            itemContext = TBuyAndSendPresent.ITEMCONTEXT_NORMAL;
         }
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item.name);
         var isSpecialValentinesItem:Boolean = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            isSpecialValentinesItem = farmItem.getBoolFromDataSource("specialValentinesItem");
         }
         else
         {
            isSpecialValentinesItem = Boolean(farmItem.xml.@specialValentinesItem) && true == farmItem.xml.@specialValentinesItem;
         }
         if(isSpecialValentinesItem)
         {
            this.m_buyPresent = new BuyPresent(item.name,itemContext,this.toggleInput);
         }
         else if(MFSSendPaidGift.giftingV2Enabled)
         {
            this.m_buyMultiPresent = new MFSSendPaidGift(farmItem,itemContext,this.toggleInput);
            UI.displayPopup(this.m_buyMultiPresent,false);
         }
         else
         {
            this.m_buyPresent = new BuyPresent(item.name,itemContext,this.toggleInput);
         }
         this.toggleInput(false);
      }
      
      private function onItemBuyPutGiftboxCash(item:FarmItem, quantity:int = 1) : void
      {
         if(Global.player.hasGiftBoxCapacity(quantity))
         {
            if(Global.worldManager.isVisitingNeighbor() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_NEIGHBOR_VISIT_PURCHASE) > 0)
            {
               FarmStatsManager.count(VisitorManager.NEIGHBOR_VISIT_COUNTER,"buy_item","cash",item.name,String(item.cash));
            }
            this.buyItem(item,Currency.CASH,quantity,true);
         }
         else
         {
            this.close();
            UI.displayMessage(ZLocUtils.t("Dialogs","TooManyGifts"),GenericPopup.TYPE_OK);
         }
      }
      
      private function onItemBuyPutGiftboxCoin(item:FarmItem, quantity:int = 1) : void
      {
         if(Global.player.hasGiftBoxCapacity(quantity))
         {
            this.buyItem(item,Currency.COINS,quantity,true);
         }
         else
         {
            this.close();
            UI.displayMessage(ZLocUtils.t("Dialogs","TooManyGifts"),GenericPopup.TYPE_OK);
         }
      }
      
      private function onItemUnlock(item:FarmItem, quantity:int = 1) : void
      {
         var lockedStates:Array = null;
         var i:Number = NaN;
         var lockedState:String = null;
         var dialogName:String = null;
         var extraData:Object = null;
         var dialog:FarmDynamicDialog = null;
         lockedStates = item.getLockedStates();
         for(i = 0; i < lockedStates.length; i++)
         {
            lockedState = lockedStates[i];
            if(lockedStates[i] is ItemRequirement)
            {
               lockedState = (lockedStates[i] as ItemRequirement).identifier;
            }
            switch(lockedState)
            {
               case FarmItemLock.EMAIL:
                  this.unlockEmail(item);
                  break;
               case FarmItemLock.NEIGHBOR:
               case FarmItemLock.LEVEL_AND_NEIGHBOR:
               case FarmItemLock.LEVEL_OR_NEIGHBOR:
                  this.unlockAddNeighbor(item);
                  break;
               case FarmItemLock.FRIEND_SET:
                  this.close();
                  dialogName = (lockedStates[i] as FriendSetRequirement).dialogName;
                  extraData = {"friendSet":true};
                  if(Boolean(dialogName) && item.onBuy(item.name,extraData))
                  {
                     dialog = FarmDynamicDialog.createDialog(dialogName,SurveyorDialog);
                     if(dialog)
                     {
                        dialog.addImport("item",item);
                        dialog.setup();
                        dialog.show();
                     }
                  }
            }
         }
      }
      
      private function onPreviewItemBuyCash(item:FarmItem, quantity:int = 1) : void
      {
         MarketStatsManager.countClickPreviewBuy();
         this.onItemBuyCash(item);
      }
      
      private function onPreviewItemBuyCoin(item:FarmItem, quantity:int = 1) : void
      {
         MarketStatsManager.countClickPreviewBuy();
         this.onItemBuyCoin(item);
      }
      
      public function onPromoClickCallback(promoData:MarketPromotion) : void
      {
         if(this[promoData.action] != null)
         {
            this[promoData.action](promoData);
            MarketStatsManager.countClickPromo(promoData.action,promoData.actionParams ? String(promoData.actionParams[0]) : "");
            FarmStatsManager.count("Market",promoData.name,"Click");
         }
      }
      
      private function openMarketWithItems(promoData:MarketPromotion) : void
      {
         var item:FarmItem = null;
         var displayItems:Array = [];
         var potentialItems:Array = Global.farmGameSettingsManager.getFarmItemsArrayByNames(promoData.actionParams);
         for each(item in potentialItems)
         {
            if(item.isVisible)
            {
               displayItems.push(item);
            }
         }
         this.m_type = "special";
         this.m_marketSlotFrame.items = displayItems;
         this.m_marketSlotFrame.visible = true;
         if(this.m_promoSlotFrame)
         {
            this.m_promoSlotFrame.visible = false;
         }
         if(MarketWindow.isNewMarketplaceHomepageOn())
         {
            m_window.backHomeWide_mc.visible = false;
            m_window.backHomeSmall_mc.visible = false;
            this.m_bestSellersFrame.visible = false;
            this.m_recommendedItemsFrame.visible = false;
            this.m_turboSaleFrame.visible = false;
            this.m_latestLEFrame.visible = false;
            this.m_miniSlotMenu.visible = true;
            this.refreshMiniSlots();
            if(this.getMarketSize() === NUM_MED_MARKET_COLS)
            {
               m_window.bottomBackBig_mc.visible = true;
               m_window.bottomBackSmall_mc.visible = false;
            }
            else
            {
               m_window.bottomBackSmall_mc.visible = true;
               m_window.bottomBackBig_mc.visible = false;
            }
         }
         this.refreshMenus();
      }
      
      private function openOrganicMarket(promoData:MarketPromotion) : void
      {
         this.close();
         Global.player.openOrganicMiniMarket();
      }
      
      private function openMarketCategory(promoData:MarketPromotion) : void
      {
         this.m_type = promoData.actionParams[0];
         this.m_subType = promoData.actionParams.length > 1 ? promoData.actionParams[1] : FarmGameSettingsManager.ALL;
         this.m_subSubType = promoData.actionParams.length > 2 ? promoData.actionParams[2] : FarmGameSettingsManager.ALL;
         this.m_sortBy = promoData.actionParams.length > 3 ? promoData.actionParams[3] : FarmGameSettingsManager.REQUIRED_LEVEL;
         this.m_sortDirection = promoData.actionParams.length > 4 ? promoData.actionParams[4] : FarmGameSettingsManager.ASCENDING;
         if(promoData.actionParams.length > 4 && Boolean(promoData.actionParams[4]))
         {
            this.m_preserveSort = true;
         }
         this.refreshMenus();
         this.refreshItems();
      }
      
      private function openMarketSearch(promoData:MarketPromotion) : void
      {
         this.m_searchField_tf.text = promoData.actionParams[0] as String;
         this.reload();
      }
      
      private function showAndOpenBobsBerry(promoData:MarketPromotion) : void
      {
         BobBerryManager.getInstance(promoData.actionParams[0]).showBobAndOpenWindow();
         this.close();
      }
      
      private function openSheepBreedingUI(promoData:MarketPromotion) : void
      {
         SheepPatternBreedingManager.openSheepPenBreedingUI(promoData.actionParams[0]);
         this.close();
      }
      
      private function showFlowerShackAndOpenWindow(promoData:MarketPromotion) : void
      {
         FlowerShackManager.getInstance(promoData.actionParams[0]).showFlowerShackAndOpenWindow();
         this.close();
      }
      
      private function openPrizeMachine(promoData:MarketPromotion) : void
      {
         UI.displayPopup(new PrizeMachineWindow(),false,"PrizeMachineWindow",true);
         this.close();
      }
      
      private function openDealOfDay(promoData:MarketPromotion) : void
      {
         var farmItem:FarmItem = DealOfDayHelper.getDealOfDayItem();
         this.m_searchField_tf.text = farmItem != null ? farmItem.friendlyTitle : "";
         this.reload();
      }
      
      private function openBuyFarmCash(promoData:MarketPromotion) : void
      {
      }
      
      private function openSuperPlots(promoData:MarketPromotion) : void
      {
         this.openMarketSearch(promoData);
         SuperPlotManager.conditionallyShowMOTD();
      }
      
      private function showMarketItemsPreview(promoData:MarketPromotion) : void
      {
         var actionParams:Array = promoData.actionParams;
         this.m_searchField_tf.text = actionParams[0];
         this.refreshMenus();
         this.refreshItems();
      }
      
      private function showExpansionAccessDialog(item:ExpansionAccessItem) : void
      {
         var expansionAccessMotdhandler:ExpansionEarlyAccessMotdHandler = null;
         if(!Global.worldManager.hasUnlockedWorld(item.worldType) && !Global.worldManager.accessExpansionTransactionInProgress())
         {
            expansionAccessMotdhandler = new ExpansionEarlyAccessMotdHandler(item.getMOTDData(),false);
            expansionAccessMotdhandler.execute();
         }
      }
      
      private function onTravelClicked(slot:MarketSlot) : void
      {
         var worldType:String = slot.worldType;
         slot.removeTooltip();
         if(Boolean(worldType) && worldType.length > 0)
         {
            this.m_hasUnlockedWorld = Global.worldManager.hasUnlockedWorld(worldType);
            if(this.m_hasUnlockedWorld)
            {
               Global.worldManager.swapFarm(worldType,false);
               slot.worldType = "";
               Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
            }
         }
      }
      
      private function onWorldLoaded(event:FarmGameWorldEvent) : void
      {
         var item:FarmItem = null;
         var farmItemName:String = null;
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         this.m_farmItems = new Array();
         if(this.m_items)
         {
            for each(item in this.m_items)
            {
               if(item is FarmItem)
               {
                  farmItemName = item.name;
                  this.m_farmItems.push(farmItemName);
               }
            }
         }
         if(Boolean(this.m_hasUnlockedWorld) && Boolean(this.m_farmItems) && this.m_farmItems.length > 0)
         {
            UI.displayMiniMarketDialog(this.m_farmItems);
         }
      }
      
      private function purchaseExpansionEarlyAccess(promoData:MarketPromotion) : void
      {
         var expansionData:ExpansionData = null;
         var access:ExpansionAccess = null;
         var actionParams:Array = promoData.actionParams;
         var worldId:String = promoData.actionParams[0] as String;
         var alreadyUnlockedDialogKey:String = promoData.actionParams[1] as String;
         var errorMsg:String = null;
         if(worldId)
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
            if(expansionData)
            {
               access = expansionData.getAccessOfType(ExpansionAccess.TYPE_EARLY);
               if(access)
               {
                  if(access.checkPrereqs())
                  {
                     if(Global.player.canBuyCash(access.cashCost,true,"expansion_early_access_" + worldId))
                     {
                        Global.player.cash -= access.cashCost;
                        TransactionManager.addTransaction(new TExpansionWorldAccess(worldId,access.type),true);
                        Global.marketConfigSettings.deletePromotion(promoData.name);
                        FreezeManager.freezeRender();
                     }
                  }
                  else if(Global.worldManager.hasUnlockedWorld(worldId))
                  {
                     UI.showMessage(ZLocUtils.t("Dialogs",alreadyUnlockedDialogKey));
                  }
                  else
                  {
                     errorMsg = "Invalid promoItem, early access for \'" + worldId + "\' does not pass prereqs";
                  }
               }
               else
               {
                  errorMsg = "Invalid promoItem, world \'" + worldId + "\' does not support early access.";
               }
            }
            else
            {
               errorMsg = "Invalid promoItem, world \'" + worldId + "\' does not exist";
            }
         }
         else
         {
            errorMsg = "Invalid promoItem, cannot purchase expansion unlock for unknown world.";
         }
         if(errorMsg)
         {
            ErrorManager.addError(errorMsg);
         }
         this.close();
      }
      
      private function openUGCItemEditor(data:*) : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         if(data is FarmItem)
         {
            item = data as FarmItem;
         }
         else if(data is MarketPromotion)
         {
            itemName = (data as MarketPromotion).actionParams[0] as String;
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         this.close();
         var ugcItemDefinition:UGCItemDefinition = Global.farmGameSettingsManager.getUGCItemDefinition(item.name);
         var windowClass:Class = getDefinitionByName(ugcItemDefinition.editorConfig.windowClass) as Class;
         var window:FarmWindow = new windowClass(item as IUGCItem,null,item.gameSettingsFeatureName);
         UI.displayPopup(window,false);
      }
      
      private function openUGCDeco(data:*) : void
      {
         this.close();
         if(data is MarketPromotion && Global.world.getObjectsByName(data.actionParams[1]).length <= 0)
         {
            TransactionManager.addTransaction(new TGetMOTD(data.actionParams[2],this.onGetMOTD),true);
         }
         else
         {
            this.openUGCItemEditor(data);
         }
      }
      
      private function onGetMOTD(amfResult:Object) : void
      {
         if(Boolean(amfResult) && amfResult.hasOwnProperty("motdSeenFlag"))
         {
            MOTD.displayMOTD(amfResult,false);
         }
      }
      
      private function openMysteryGame(promoData:MarketPromotion) : void
      {
         var items:Array = null;
         var item:FarmItem = null;
         if(MiniDartsManager.getInstance().isFeatureActive() || MysteryBoxBalloonDialog.IN_LOOT_TABLE_VARIANT)
         {
            MysteryBoxBalloonDialog.openDefaultMysteryGame();
            this.close();
            return;
         }
         items = Global.farmGameSettingsManager.getFarmItemsArray(FarmGameSettingsManager.TYPE_GAME_TOKEN);
         if(Boolean(items) && items.length > 0)
         {
            for each(item in items)
            {
               if(item.isMysteryItem)
               {
                  this.displayMiniGameWindow(item);
                  return;
               }
            }
         }
         throw new Error("Unable to find an active game token item.");
      }
      
      private function openHolidayCountodwn(promoData:MarketPromotion) : void
      {
         HolidayCountdownManager.displayDialog();
         this.close();
      }
      
      private function openPigoGame(promoData:MarketPromotion = null, entryPoint:String = "market_ad") : void
      {
         PigoWindow.displayActiveGame(entryPoint,true);
         this.close();
      }
      
      private function openScratchCard(promoData:MarketPromotion = null, entryPoint:String = "market_ad") : void
      {
         UI.displayPopup(new ScratchCardWindow(entryPoint),true,ScratchCardWindow.POPUP_NAME,true);
         this.close();
      }
      
      private function openLESetDisplayDialog() : void
      {
         StatsManager.count("marketcard","reward_purch_set","click");
         LESetManager.displayDialog();
         this.close();
      }
      
      private function openPaymentsPage(promoData:MarketPromotion) : void
      {
         this.displayPaymentsPage("marketDialogPromo");
      }
      
      private function openStarterPackPopup(promoData:MarketPromotion) : void
      {
         var starterFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("starter_pack");
         if(starterFarmItem)
         {
            MarketStatsManager.countStarterPackMarketStat(StarterPackUtility.STARTER_PACK_MARKET_AD_KINGDOM,StarterPackUtility.STARTER_PACK_MARKET_CLICK_PHYLUM);
            this.displayBuyStarterPackWindow(starterFarmItem,this.onPromoStarterPackWindowBuy,this.onPromoStarterPackWindowClose);
         }
      }
      
      private function openExternalLink(promoData:MarketPromotion) : void
      {
         var link:String = null;
         if(promoData.actionParams.length > 0)
         {
            link = promoData.actionParams[0];
            Global.farmSocialNetwork.redirectTop(link,null,"_blank",false);
         }
      }
      
      private function openPromoWindow(promoData:MarketPromotion) : void
      {
         var dialogName:String = null;
         var message:String = null;
         var asset:String = null;
         var popup:GenericPopup = null;
         if(promoData.actionParams.length > 0)
         {
            dialogName = promoData.actionParams[0];
            switch(dialogName)
            {
               case "CapitalOnePromoWindow":
                  UI.displayPopup(new CapitalOnePromoWindow(true),false);
                  break;
               case "CharityCampaignWindow":
                  this.onItemDonate(Global.farmGameSettingsManager.getFarmItemByName(promoData.actionParams[1]));
                  break;
               case "Sweepstakes":
                  LotteryManager.instance.queueMainUI();
                  break;
               case "GenericPopupWindow":
                  message = promoData.actionParams[1] != null ? ZLocUtils.t("Dialogs",promoData.actionParams[1]) : " ";
                  asset = promoData.actionParams[2] != null ? promoData.actionParams[2] : GenericPopup.GENERIC_ASSET;
                  popup = new GenericPopup(message,GenericPopup.TYPE_OK,null,asset);
                  UI.displayPopup(popup,false);
                  MarketStatsManager.countClickPromo(promoData.name,promoData.actionParams ? String(promoData.actionParams[0]) : "");
            }
         }
         this.close();
      }
      
      private function beginBuyFlow(promoData:MarketPromotion) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(promoData.actionParams[0]);
         if(item)
         {
            this.buyItem(item,Currency.CASH);
            return;
         }
         throw new Error("Unable to find item.");
      }
      
      private function displayAvatarEditorWindow(item:ClothingItem) : void
      {
         Global.world.displayAvatarCustomizationScreen(false,null,item);
      }
      
      private function openFleaMarketUI(promoData:MarketPromotion) : void
      {
         this.close();
         var dialog:FleaMarketWindow = new FleaMarketWindow();
         UI.displayPopup(dialog,false,"FleaMarketWindow",true);
      }
      
      private function openFCSlotMachine(promoData:MarketPromotion) : void
      {
         this.close();
         FarmStatsManager.count("market_ad","slots","click");
         UI.displayPopup(new FCSlotMachineWindow(FCSlotMachineWindow.ENTRY_POINT_MARKET_AD),true,FCSlotMachineWindow.WINDOW_NAME,true);
      }
      
      private function openTaskList(promoData:MarketPromotion) : void
      {
         this.close();
         FarmStatsManager.count("market_ad",TaskListManager.STATS_COUNTER,"click");
         TaskListManager.getInstance().openTaskListWindow();
      }
      
      private function openGenericWindowClass(promoData:MarketPromotion) : void
      {
         var windowClassName:String = null;
         var windowClass:Class = null;
         var learnMoreWindow:FarmWindow = null;
         windowClassName = promoData.actionParams[0] as String;
         try
         {
            windowClass = getDefinitionByName(windowClassName) as Class;
            learnMoreWindow = new windowClass();
            UI.displayPopup(learnMoreWindow,false,"MarketPromoPopup",true);
         }
         catch(err:Error)
         {
            ErrorManager.addError("Error instantiating " + windowClassName + ". " + err.message);
         }
      }
      
      private function openSubscriptionsWindow(promoData:MarketPromotion) : void
      {
         if(SubscriptionsMainWindow.isSubscriber())
         {
            UI.displayPopup(new SubscriptionsMainWindow(),true,"SubscriptionsMainWindow");
         }
         else if(SubscriptionsMOTDWindow.canTrade())
         {
            UI.displayPopup(new SubscriptionsMOTDWindow(),true,"SubscriptionsMOTDWindow");
         }
      }
      
      public function displayMarketPreviewWindow(item:FarmItem, isMiniSlotRequest:Boolean = false, isStandAlone:Boolean = false, marketSlot:MarketSlot = null) : void
      {
         var showExtraLEInfo:Boolean = false;
         var showQuantity:Boolean = false;
         var callbacks:Object = new Object();
         if(Global.worldManager.isVisiting())
         {
            callbacks[MarketWindow.CALLBACK_BUY_CASH] = this.onItemBuyPutGiftboxCash;
            callbacks[MarketWindow.CALLBACK_BUY_COIN] = this.onItemBuyPutGiftboxCoin;
            callbacks[MarketWindow.CALLBACK_SEND] = this.onItemSend;
            showExtraLEInfo = true;
            showQuantity = true;
         }
         else
         {
            callbacks[MarketWindow.CALLBACK_BUY_CASH] = this.onPreviewItemBuyCash;
            callbacks[MarketWindow.CALLBACK_BUY_COIN] = this.onPreviewItemBuyCoin;
            callbacks[MarketWindow.CALLBACK_SEND] = this.onItemSend;
         }
         callbacks[MarketWindow.CALLBACK_UNLOCK] = this.onItemUnlock;
         if(isStandAlone)
         {
            callbacks[MarketWindow.CALLBACK_CLOSE] = UI.closeMarketDialog;
         }
         UI.displayPopup(new MarketPreviewWindow(item,callbacks,isMiniSlotRequest,showExtraLEInfo,showQuantity,this.m_terrainCodes,marketSlot),false);
         MarketStatsManager.countClickPreview();
      }
      
      private function displayMiniGameWindow(item:FarmItem) : void
      {
         MysteryBoxBalloonDialog.openDefaultMysteryGame(item.name);
         this.close();
      }
      
      private function displayPaymentsPage(ref:String = "") : void
      {
      }
      
      private function displaySuperCropUnlockWindow(crop:HarvestableItem) : void
      {
         var baseCrop:HarvestableItem = null;
         var bushel:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(crop.bushelItemCode) as BushelItem;
         if(bushel)
         {
            baseCrop = Global.farmGameSettingsManager.getFarmItemByCode(bushel.crop) as HarvestableItem;
            if(baseCrop)
            {
               UI.displayPopup(new MarketSuperCropUnlockWindow(crop,baseCrop,this.onSuperCropUnlockPlant,this.onSuperCropUnlockClose),false);
               this.toggleInput(false);
            }
         }
      }
      
      private function onSuperCropUnlockPlant(farmItem:FarmItem) : void
      {
         this.close();
         UI.displayMiniMarketDialog([farmItem.name],"market","seed",null);
      }
      
      private function onSuperCropUnlockClose() : void
      {
         this.toggleInput();
      }
      
      private function displayBuyCashLicenseWindow(item:FarmItem) : void
      {
         UI.displayPopup(new MarketBuyCashLicenseWindow(item,this.onBuyCashLicenseWindowAccept,this.onBuyCashLicenseWindowCancel),false);
         this.toggleInput(false);
      }
      
      private function onBuyCashLicenseWindowAccept(item:FarmItem) : void
      {
         this.toggleInput();
         this.buyCashLicense(item);
      }
      
      private function onBuyCashLicenseWindowCancel() : void
      {
         this.toggleInput();
      }
      
      private function buyCashLicense(item:FarmItem) : void
      {
         if(item.isBuyableLicense() && Global.player.canBuyCash(item.licenseCost,false))
         {
            this.m_acquireLicenseItem = item;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               TransactionManager.addTransaction(new TAcquireLicense(null,item.license,this.onCashLicenseGranted,item.getStringFromDataSource("name")),true);
            }
            else
            {
               TransactionManager.addTransaction(new TAcquireLicense(item.xml,item.license,this.onCashLicenseGranted),true);
            }
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyMarket",item.licenseCost,"license_" + item.type);
            FarmStatsManager.count("fv_cash_buy_fail","view_popup");
         }
      }
      
      public function onCashLicenseGranted(result:Object) : void
      {
         var slot:MarketSlot = null;
         if(this.m_acquireLicenseItem)
         {
            Global.player.cash -= this.m_acquireLicenseItem.licenseCost;
            if(this.m_marketSlotFrame)
            {
               slot = this.m_marketSlotFrame.getSlotByItem(this.m_acquireLicenseItem);
               if(slot)
               {
                  slot.refresh();
               }
            }
         }
         this.m_acquireLicenseItem = null;
      }
      
      private function displayBuyBerryLicenseWindow(item:FarmItem) : void
      {
         UI.displayPopup(new MarketBuyBerryLicenseWindow(item,this.onBuyBerryLicenseWindowAccept,this.onBuyBerryLicenseWindowCancel),false);
         this.toggleInput(false);
      }
      
      private function onBuyBerryLicenseWindowAccept(item:FarmItem) : void
      {
         this.toggleInput();
         this.buyBerryLicense(item);
      }
      
      private function onBuyBerryLicenseWindowCancel() : void
      {
         this.toggleInput();
      }
      
      private function buyBerryLicense(item:FarmItem) : void
      {
         if(item.isBerryBuyableLicense() && Global.player.canBuyWithCurrency("berry",item.licenseCost))
         {
            this.m_acquireLicenseItem = item;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               TransactionManager.addTransaction(new TAcquireLicense(null,item.license,this.onBerryLicenseGranted,item.getStringFromDataSource("name")),true);
            }
            else
            {
               TransactionManager.addTransaction(new TAcquireLicense(item.xml,item.license,this.onBerryLicenseGranted),true);
            }
         }
      }
      
      public function onBerryLicenseGranted(result:Object) : void
      {
         var slot:MarketSlot = null;
         if(this.m_acquireLicenseItem)
         {
            Global.player.updateWorldCurrency("berry",-1 * this.m_acquireLicenseItem.licenseCost);
            if(this.m_marketSlotFrame)
            {
               slot = this.m_marketSlotFrame.getSlotByItem(this.m_acquireLicenseItem);
               if(slot)
               {
                  slot.refresh();
               }
            }
         }
         this.m_acquireLicenseItem = null;
      }
      
      private function buyItem(item:FarmItem, currency:String, quantity:int = 1, putInGiftbox:Boolean = false) : void
      {
         var cash:int = 0;
         var cost:int = 0;
         var itemName:String = null;
         var variant:int = 0;
         var finalCost:int = 0;
         if(item.isLicenseGated)
         {
            MarketStatsManager.countCashCropsItemBuy(item.name);
         }
         switch(this.m_type)
         {
            case FarmGameSettingsManager.TYPE_LIMITED:
               MarketStatsManager.countClickBuyLimited();
               break;
            case FarmGameSettingsManager.TYPE_NEW:
               MarketStatsManager.countClickBuyNew();
         }
         var canBuy:Boolean = Global.player.buyFarmItem(item,currency,quantity,putInGiftbox,true,false,null,false,true);
         switch(currency)
         {
            case Currency.CASH:
               cash = item.realCashCost;
               finalCost = cash;
               break;
            default:
               cost = item.saleCost > 0 ? item.saleCost : item.cost;
               finalCost = cost;
               canBuy = Global.player.canBuyWithCurrency(currency,cost * quantity,false);
         }
         if(canBuy)
         {
            switch(currency)
            {
               case Currency.CASH:
                  itemName = item.hasSale && Boolean(item.saleXML) ? item.saleName : item.cashName;
                  break;
               default:
                  itemName = item.hasSale && Boolean(item.saleXML) ? item.saleName : item.name;
            }
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_RETENTION_CORE_CLICK_FLOW_IMPROVEMENT);
            if(variant == 2 || variant == 4 || variant == 6 || variant == 8)
            {
               if(this.m_plotCallback != null)
               {
                  this.m_plotCallback(itemName);
               }
            }
            if(this.m_marketSlotFrame)
            {
               MarketStatsManager.countBuyItem(this.m_viewSource,this.m_type,itemName,this.m_subType,this.m_subSubType,quantity);
               MarketStatsManager.countBuyItem2(itemName,currency,finalCost,this.m_marketSlotFrame.pageNumber);
            }
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EXPANSION_PROMPT_IDLE) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START || Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_LAST_CHANCE) >= Experiments.VARIANT_LE_LAST_CHANCE_EXPIRING)
            {
               dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.NONE,itemName,currency));
            }
            else
            {
               dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY));
            }
            this.m_closeIsBuy = true;
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
            {
               if(!(this.isItemRepopBlackListed(itemName) || item.subType && item.subType == "expand_farm" || item.type && item.type == FarmItemType.SEED || item.className == MultiRewardTreasureConstructionBuilding.NON_PAYER_TILE || item.className == MultiRewardTreasureConstructionBuilding.PAYER_TILE || item.className == MultiRewardTreasureConstructionBuilding.PAYER_LAND_BUNDLE || item.className == MultiRewardTreasureConstructionBuilding.PAYER_BUNDLE_TILE || item.className == MultiRewardTreasureConstructionBuilding.NEW_LAND_BUNDLE))
               {
                  if(item.className != "MutableDragon")
                  {
                     IdleTaskQueue.getInstance().addTask(new MarketReopenIdleTask());
                  }
               }
            }
            this.close();
         }
      }
      
      public function isItemRepopBlackListed(itemName:String) : Boolean
      {
         var marketRepopBlackListName:String = null;
         var marketRepopBlackList:String = Global.flashHotParams["MARKET_REPOP_BLACKLIST"];
         var marketRepopBlackListArray:Array = marketRepopBlackList.split(",");
         var result:Boolean = false;
         for each(marketRepopBlackListName in marketRepopBlackListArray)
         {
            if(itemName == marketRepopBlackListName)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function checkAndRepopMarketWindow(item:FarmItem) : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            if(Boolean(this.isItemRepopBlackListed(item.name)) || Boolean(item.subType && item.subType == "expand_farm") || Boolean(item.type) && Boolean(item.type == FarmItemType.SEED))
            {
               IdleTaskQueue.getInstance().addTask(new MarketReopenIdleTask());
            }
         }
      }
      
      private function unlockAddNeighbor(item:FarmItem) : void
      {
         var isInvalidType:Boolean = false;
         var variables:URLVariables = new URLVariables();
         switch(item.type)
         {
            case FarmItemType.CHANGE_FARM:
               variables.ref = "neighborsExpansionPage";
               variables.requestType = "expandFarm";
               variables.farm = item.name;
               variables.creative = "market_" + item.size;
               break;
            case FarmItemType.BUILDING:
               variables.ref = "neighborsExpansionPage";
               variables.requestType = "building";
               variables.creative = "building_" + item.name;
               break;
            case FarmItemType.TREE:
               variables.ref = "neighborsTreePage";
               variables.requestType = "trees";
               variables.creative = "tree_" + item.name;
               break;
            case FarmItemType.DECORATION:
               variables.ref = "neighborsExpansionPage";
               variables.requestType = "decoration";
               variables.creative = "market_" + item.size;
               break;
            case FarmItemType.FUEL:
               variables.ref = "neighborsExpansionPage";
               variables.requestType = "fuelcapacity";
               variables.creative = "fuelcapacity_" + item.size;
               break;
            case FarmItemType.ANIMAL:
               variables.ref = "neighborsExpansionPage";
               variables.requestType = "animal";
               variables.creative = "animal_" + item.name;
               break;
            default:
               isInvalidType = true;
         }
         if(item.gateCode)
         {
            FarmStatsManager.count("viral_loot",item.name,"add_neighbor_click");
         }
         if(!isInvalidType)
         {
            MFSRequestManager.getInstance().displayR2AddNeighborWindow("market_window");
         }
      }
      
      private function unlockEmail(item:FarmItem) : void
      {
         EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_MARKET);
         this.close();
      }
      
      protected function getSearchString() : String
      {
         return !(this.m_searchField_tf.text == "" || this.m_searchField_tf.text == this.m_defaultString) ? this.m_searchField_tf.text.toLocaleLowerCase() : "";
      }
      
      protected function refreshItems() : void
      {
         var marketLEItems:Array = null;
         var currencyExchangeItems:Array = null;
         var index:int = 0;
         var currencyExchangeItem:FarmItem = null;
         var isValidCurrencyExchangeItem:Boolean = false;
         var marketItems:Array = null;
         var starterFarmItem:FarmItem = null;
         var availableStarterPack:StarterPack = null;
         var cityXPromo2MarketItem:FarmItem = null;
         var matchedItemNames:Array = null;
         var matchedItemName:String = null;
         var matchedItem:FarmItem = null;
         var item:FarmItem = null;
         var i:* = 0;
         var starterFriendlyName:String = null;
         var addItem:Boolean = false;
         var packGifts:Array = null;
         var giftIndex:Number = NaN;
         var gift:Object = null;
         var farmItem:FarmItem = null;
         var searchString:String = this.getSearchString();
         if(searchString != "")
         {
            MarketStatsManager.countSearch(searchString);
         }
         MarketStatsManager.countViewMarket(this.m_type,this.m_subType,this.m_page.toString());
         if(this.m_sortBy == FarmGameSettingsManager.DEFAULT && this.m_type != Global.worldManager.currentWorldUniqueMarketCard)
         {
            this.m_sortBy = Global.farmGameSettingsManager.getDefaultSortType();
         }
         if(this.m_type == "special" && searchString == "")
         {
            if(this.m_promoSlotFrame)
            {
               this.m_promoSlotFrame.visible = true;
            }
            this.m_marketSlotFrame.visible = false;
            this.m_subMenu.visible = false;
            this.m_typeTextField.visible = false;
            if(MarketWindow.isNewMarketplaceHomepageOn())
            {
               this.m_bestSellersFrame.visible = true;
               this.m_recommendedItemsFrame.visible = true;
               m_window.bottomBackBig_mc.visible = false;
               m_window.bottomBackSmall_mc.visible = false;
               this.m_miniSlotMenu.visible = false;
               this.m_miniSlotFrame.visible = false;
               this.m_flashSaleFrame.visible = false;
               if(this.m_rewardCardsSlotFrame)
               {
                  this.m_rewardCardsSlotFrame.visible = false;
               }
               this.m_bestSellersFrame.element.title_tf.visible = true;
               this.m_recommendedItemsFrame.element.title_tf.visible = true;
               if(this.getMarketSize() === NUM_MED_MARKET_COLS)
               {
                  m_window.backHomeWide_mc.visible = true;
                  this.m_turboSaleFrame.visible = true;
                  this.m_latestLEFrame.visible = true;
                  this.m_turboSaleFrame.element.title_tf.text = Global.flashHotParams["MARKETHOMEPAGE_ITEMS_TITLE"];
                  this.m_latestLEFrame.element.title_tf.text = "New Arrivals";
                  this.m_turboSaleFrame.element.title_tf.visible = true;
                  this.m_latestLEFrame.element.title_tf.visible = true;
               }
               else
               {
                  m_window.backHomeSmall_mc.visible = true;
               }
            }
            if(Boolean(this.m_lePromoSlotFrame) && Boolean(this.m_LeHeader) && Boolean(this.m_LeSubtitle))
            {
               this.m_lePromoSlotFrame.visible = false;
               this.m_LeHeader.visible = false;
               this.m_LeSubtitle.visible = false;
            }
            if(m_window.bgLEDefaultMed_mc)
            {
               m_window.bgLEDefaultMed_mc.visible = false;
            }
            this.trackBrandPromoView();
         }
         else if(this.m_LeRevamp && this.m_type == "limited" && searchString == "")
         {
            this.m_miniSlotMenu.visible = false;
            this.m_miniSlotFrame.visible = false;
            if(this.m_rewardCardsSlotFrame)
            {
               this.m_rewardCardsSlotFrame.visible = false;
            }
            if(this.m_subType == "all")
            {
               this.createMarketLeAds();
               this.m_marketSlotFrameLE.visible = false;
            }
            else
            {
               if(Boolean(this.m_lePromoSlotFrame) && Boolean(this.m_LeHeader) && Boolean(this.m_LeSubtitle))
               {
                  this.m_lePromoSlotFrame.visible = false;
                  this.m_LeHeader.visible = false;
                  this.m_LeSubtitle.visible = false;
               }
               if(m_window.bgLEDefaultMed_mc)
               {
                  m_window.bgLEDefaultMed_mc.visible = false;
               }
               this.m_marketSlotFrameLE.visible = true;
            }
            marketLEItems = this.getLEMarketItems(this.m_subType);
            if(this.m_noResultsText)
            {
               if(marketLEItems.length == 0 && this.m_subType != "all")
               {
                  this.m_noResultsText.visible = true;
               }
               else
               {
                  this.m_noResultsText.visible = false;
               }
            }
            if(this.m_type == this.LIMITED && this.m_LeTabSortVariant > 1)
            {
               marketLEItems = this.subSortLE(marketLEItems);
            }
            this.m_marketSlotFrameLE.items = marketLEItems;
            if(this.m_page > 0)
            {
               this.m_marketSlotFrameLE.pageNumber = this.m_page;
               this.m_page = 0;
            }
            if(this.m_promoSlotFrame)
            {
               this.m_promoSlotFrame.visible = false;
            }
            this.m_marketSlotFrame.visible = false;
         }
         else
         {
            this.toggleLeTab(false);
            if(Boolean(this.m_marketSlotFrameLE) && Boolean(this.m_subMenuLE))
            {
               this.m_marketSlotFrameLE.visible = false;
               this.m_subMenuLE.visible = false;
            }
            if(Boolean(this.m_lePromoSlotFrame) && Boolean(this.m_LeHeader) && Boolean(this.m_LeSubtitle))
            {
               this.m_lePromoSlotFrame.visible = false;
               this.m_LeHeader.visible = false;
               this.m_LeSubtitle.visible = false;
            }
            if(m_window.bgLEDefaultMed_mc)
            {
               m_window.bgLEDefaultMed_mc.visible = false;
            }
            if(MarketWindow.isNewMarketplaceHomepageOn())
            {
               m_window.backHomeWide_mc.visible = false;
               m_window.backHomeSmall_mc.visible = false;
               this.m_bestSellersFrame.visible = false;
               this.m_recommendedItemsFrame.visible = false;
               this.m_turboSaleFrame.visible = false;
               this.m_latestLEFrame.visible = false;
               this.m_miniSlotMenu.visible = true;
               this.refreshMiniSlots();
               if(this.getMarketSize() === NUM_MED_MARKET_COLS)
               {
                  m_window.bottomBackBig_mc.visible = true;
                  m_window.bottomBackSmall_mc.visible = false;
               }
               else
               {
                  m_window.bottomBackSmall_mc.visible = true;
                  m_window.bottomBackBig_mc.visible = false;
               }
            }
            if(this.m_type == "landExpansion")
            {
               if(this.m_subType == "all")
               {
                  this.m_sortBy = FarmGameSettingsManager.SIZE;
               }
               else
               {
                  this.m_sortBy = Global.farmGameSettingsManager.getDefaultSortType();
               }
               this.m_sortDirection = FarmGameSettingsManager.ASCENDING;
            }
            if(Global.experimentManager.getExperimentVariant(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_EXP) > 0)
            {
               if(Global.player.getSeenFlag(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID))
               {
                  cityXPromo2MarketItem = Global.farmGameSettingsManager.getFarmItemByName(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID);
                  if(cityXPromo2MarketItem)
                  {
                     cityXPromo2MarketItem.buyable = false;
                  }
               }
            }
            currencyExchangeItems = Global.farmGameSettingsManager.getFarmItemsArrayByType("aide","other","currency_exchange","",true);
            index = 0;
            currencyExchangeItem = null;
            isValidCurrencyExchangeItem = false;
            for(index = 0; index < currencyExchangeItems.length; index++)
            {
               currencyExchangeItem = currencyExchangeItems[index] as FarmItem;
               if(null != currencyExchangeItem && CurrencyConversionUtil.isCurrencyExchangeItem(currencyExchangeItem.name))
               {
                  currencyExchangeItem.buyable = CurrencyConversionUtil.isValidCurrencyExchangeItem(currencyExchangeItem.name,Global.worldManager.currentWorldCurrency);
               }
            }
            if(this.m_cachedMarketSearchOptimizationExperimentVariant == -1)
            {
               this.m_cachedMarketSearchOptimizationExperimentVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_SEARCH_OPTIMIZATION);
            }
            marketItems = [];
            if(this.m_cachedMarketSearchOptimizationExperimentVariant == Experiments.SINGLE_CONTROL_VALID_VARIANT_START && searchString != "")
            {
               if("MARKET_SEARCH_TREE_FORCE_FINISH_ITEMS_XML_PARSING" in Global.flashHotParams && Global.flashHotParams["MARKET_SEARCH_TREE_FORCE_FINISH_ITEMS_XML_PARSING"] === true)
               {
                  Global.farmGameSettingsManager.parseItemsBatch(true,["marketSearchTree",searchString]);
               }
               FarmGameSettingsManager.m_marketSearchTernaryTree.buildPhraseMatchStrings(searchString);
               matchedItemNames = FarmGameSettingsManager.m_marketSearchTernaryTree.getMatchedStrings();
               for each(matchedItemName in matchedItemNames)
               {
                  matchedItem = Global.farmGameSettingsManager.getFarmItemByName(matchedItemName);
                  if(Boolean(matchedItem) && matchedItem.isVisible)
                  {
                     marketItems.push(matchedItem);
                  }
               }
               marketItems = FarmGameSettingsManager.applyTerrainRestriction(marketItems,this.m_terrainCodes);
               marketItems = FarmGameSettingsManager.sortSuperCrops(this.m_type,this.m_sortBy,searchString,marketItems);
            }
            else
            {
               marketItems = Global.farmGameSettingsManager.getFarmItemsArray(this.m_type,this.m_subType,this.m_subSubType,this.m_sortBy,this.m_sortDirection,true,searchString,this.m_terrainCodes,true);
               if(this.m_type == "vip")
               {
                  marketItems = marketItems.concat(Global.farmGameSettingsManager.getFarmItemsArray("sale",this.m_subType,this.m_subSubType,this.m_sortBy,this.m_sortDirection,true,searchString,this.m_terrainCodes,true));
               }
            }
            if(searchString == "" && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HIDE_MARKET_ITEMS_2013) == 2)
            {
               if(!this.m_filteredItems)
               {
                  this.setupItemFilters();
               }
               for(i = 0; i < marketItems.length; i++)
               {
                  item = marketItems[i] as FarmItem;
                  if(this.m_filteredItems.hasOwnProperty(item.name))
                  {
                     marketItems.splice(i,1);
                     i--;
                  }
               }
            }
            if(this.m_noResultsText)
            {
               if(marketItems.length == 0)
               {
                  this.m_noResultsText.visible = true;
               }
               else
               {
                  this.m_noResultsText.visible = false;
               }
            }
            this.sortItemsPromoSlot(this.m_type,marketItems);
            starterFarmItem = Global.farmGameSettingsManager.getFarmItemByName("starter_pack");
            availableStarterPack = StarterPackUtility.getBestVisibleStarterPack();
            if(Boolean(starterFarmItem) && Boolean(availableStarterPack))
            {
               starterFriendlyName = starterFarmItem.friendlyTitle.toLocaleLowerCase();
               if(searchString == "" || starterFriendlyName.search(searchString) != -1)
               {
                  addItem = false;
                  packGifts = availableStarterPack.gifts;
                  for(giftIndex = 0; giftIndex < packGifts.length; giftIndex++)
                  {
                     gift = packGifts[giftIndex];
                     if(gift.type == "item")
                     {
                        farmItem = Global.farmGameSettingsManager.getFarmItemByCode(gift.value);
                        if(Boolean(farmItem.marketEntriesHash[this.m_type]) && (Boolean(farmItem.marketEntriesHash[this.m_type + this.m_subType] || this.m_subType == "all") || Boolean(this.m_subType == "other")))
                        {
                           addItem = true;
                           break;
                        }
                     }
                  }
                  if(addItem)
                  {
                     marketItems.unshift(starterFarmItem);
                     this.m_noResultsText.visible = false;
                  }
               }
            }
            if(this.m_type == this.LIMITED && this.m_LeTabSortVariant > 1)
            {
               marketItems = this.subSortLE(marketItems);
            }
            this.m_marketSlotFrame.items = marketItems;
            if(this.m_page > 0)
            {
               this.m_marketSlotFrame.pageNumber = this.m_page;
               this.m_page = 0;
            }
            this.m_marketSlotFrame.visible = true;
            this.m_subMenu.visible = true;
            if(this.m_promoSlotFrame)
            {
               this.m_promoSlotFrame.visible = false;
            }
            if((this.m_type == FarmGameSettingsManager.TYPE_LIMITED || this.m_type == FarmGameSettingsManager.TYPE_NEW || this.m_type == FarmGameSettingsManager.TYPE_BRANDED) && searchString == "")
            {
               this.m_typeTextField.text = ZLocUtils.t("Dialogs",MENU_PREFIX + this.m_type);
               this.m_typeTextField.visible = true;
            }
            else
            {
               this.m_typeTextField.visible = false;
            }
            if(this.m_type == FarmGameSettingsManager.TYPE_LIMITED && this.m_subType == FarmGameSettingsManager.SUBTYPE_CHARITY)
            {
               this.toggleCharityBannerAndMiniSlot(true);
            }
            else
            {
               this.toggleCharityBannerAndMiniSlot(false);
            }
         }
      }
      
      private function getLEMarketItems(subtype:String) : Array
      {
         var result:Array = new Array();
         if(this.m_leItems.hasOwnProperty(subtype))
         {
            result = this.m_leItems[subtype];
         }
         return result;
      }
      
      private function toggleCharityBannerAndMiniSlot(visibility:Boolean) : void
      {
         if(Boolean(this.m_charityBannerFrame) && Boolean(this.m_miniSlotMenu))
         {
            this.m_charityBannerFrame.visible = visibility;
            this.m_miniSlotMenu.visible = !visibility;
         }
      }
      
      private function setupItemFilters() : void
      {
         var itemName:String = null;
         var listLength:int = 0;
         var i:int = 0;
         var xml:String = null;
         var blackList:Array = null;
         var whiteList:Array = null;
         this.m_filteredItems = new Dictionary();
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML("MarketItemCleanUp");
         var list:XMLList = feature.items.item;
         if(list)
         {
            listLength = list.length();
            for(i = 0; i < listLength; i++)
            {
               xml = list[i];
               if(xml)
               {
                  this.m_filteredItems[xml] = null;
               }
            }
         }
         if(Global.flashHotParams.hasOwnProperty("MARKETPLACE_ITEM_BLACKLIST"))
         {
            blackList = (Global.flashHotParams["MARKETPLACE_ITEM_BLACKLIST"] as String).split(",");
            for each(itemName in blackList)
            {
               this.m_filteredItems[itemName] = null;
            }
         }
         if(Global.flashHotParams.hasOwnProperty("MARKETPLACE_ITEM_WHITELIST"))
         {
            whiteList = (Global.flashHotParams["MARKETPLACE_ITEM_WHITELIST"] as String).split(",");
            for each(itemName in whiteList)
            {
               delete this.m_filteredItems[itemName];
            }
         }
      }
      
      private function flushCurrentLEGroup(itemsObject:Object) : Array
      {
         var groupArray:Array = new Array();
         if(this.m_LeTabSortVariant == 2)
         {
            groupArray = groupArray.concat(itemsObject[this.LEVEL_ONE_TREES],itemsObject[this.HORSES],itemsObject[this.OTHER_ANIMALS],itemsObject[this.DECOS],itemsObject[this.LEVEL_TWO_TREES],itemsObject[this.COIN_ITEMS]);
         }
         else if(this.m_LeTabSortVariant == 3)
         {
            groupArray = groupArray.concat(itemsObject[this.HORSES],itemsObject[this.LEVEL_ONE_TREES],itemsObject[this.OTHER_ANIMALS],itemsObject[this.DECOS],itemsObject[this.LEVEL_TWO_TREES],itemsObject[this.COIN_ITEMS]);
         }
         else
         {
            groupArray = groupArray.concat(itemsObject[this.LEVEL_ONE_TREES],itemsObject[this.HORSES],itemsObject[this.OTHER_ANIMALS],itemsObject[this.DECOS],itemsObject[this.LEVEL_TWO_TREES],itemsObject[this.COIN_ITEMS]);
            groupArray = Global.marketRecommendations.sortItemsByRecomended(groupArray,3);
         }
         itemsObject[this.LEVEL_ONE_TREES] = new Array();
         itemsObject[this.HORSES] = new Array();
         itemsObject[this.OTHER_ANIMALS] = new Array();
         itemsObject[this.DECOS] = new Array();
         itemsObject[this.LEVEL_TWO_TREES] = new Array();
         itemsObject[this.COIN_ITEMS] = new Array();
         return groupArray;
      }
      
      private function subSortLE(items:Array) : Array
      {
         var item:FarmItem = null;
         var animalType:String = null;
         var itemsObject:Object = new Object();
         itemsObject[this.LEVEL_ONE_TREES] = new Array();
         itemsObject[this.LEVEL_TWO_TREES] = new Array();
         itemsObject[this.HORSES] = new Array();
         itemsObject[this.OTHER_ANIMALS] = new Array();
         itemsObject[this.DECOS] = new Array();
         itemsObject[this.COIN_ITEMS] = new Array();
         var currentGroup:Number = -1;
         var resultArray:Array = new Array();
         var itemsLength:int = int(items.length);
         for(var i:int = 0; i < itemsLength; i++)
         {
            item = items[i];
            if(currentGroup == -1)
            {
               currentGroup = item.limitedStartTime;
            }
            if(item.limitedStartTime != currentGroup)
            {
               resultArray = resultArray.concat(this.flushCurrentLEGroup(itemsObject));
               currentGroup = item.limitedStartTime;
            }
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               animalType = item.getStringFromDataSource(this.ANIMAL_TYPE);
            }
            else
            {
               animalType = item.getXMLProperty(item.xml,this.ANIMAL_TYPE);
            }
            if(item.marketIsCoin)
            {
               itemsObject[this.COIN_ITEMS].push(item);
            }
            else if(item.type == this.TREE && item.getNextLevelItem().code != item.code)
            {
               itemsObject[this.LEVEL_ONE_TREES].push(item);
            }
            else if(item.type == this.TREE)
            {
               itemsObject[this.LEVEL_TWO_TREES].push(item);
            }
            else if(animalType == this.HORSE)
            {
               itemsObject[this.HORSES].push(item);
            }
            else if(item.type == this.ANIMAL)
            {
               itemsObject[this.OTHER_ANIMALS].push(item);
            }
            else
            {
               itemsObject[this.DECOS].push(item);
            }
            if(i == itemsLength - 1)
            {
               resultArray = resultArray.concat(this.flushCurrentLEGroup(itemsObject));
               currentGroup = item.limitedStartTime;
            }
         }
         return resultArray;
      }
      
      private function refreshMenus() : void
      {
         var selectedTab:int = 0;
         var i:int = 0;
         var subType:String = null;
         var submenuitems:Array = null;
         var selectedSubTab:int = 0;
         var leTheme:String = null;
         var showExpiry:String = null;
         var isNew:Boolean = false;
         var tabindex:int = 0;
         var desc:String = null;
         var leitem:FarmItem = null;
         var timeleft:Number = NaN;
         var parsedtime:Array = null;
         var sortOptionsForType:Array = null;
         var sortOpt:Object = null;
         var menuItem:MenuItem = null;
         var item:MenuItem = null;
         var typeForSubTypes:String = this.m_type == Global.worldManager.currentWorldUniqueMarketCard ? CURRENT_WORLD_MENU_ITEM : this.m_type;
         var subTypes:Array = this.getSubTypes(typeForSubTypes);
         var items:Array = new Array();
         var sortByMenuItems:Array = [];
         if(subTypes)
         {
            selectedTab = 0;
            for(i = 0; i < subTypes.length; i++)
            {
               subType = subTypes[i];
               if(!(this.m_type == "building" && subType == "BuildingPart"))
               {
                  if(!(this.m_type == "aide" && subType == "consumable"))
                  {
                     items.push(new MenuItem(subType,ZLocUtils.t("Dialogs",MENU_PREFIX + subType)));
                     if(subType == this.m_subType)
                     {
                        selectedTab = i;
                     }
                  }
               }
            }
            this.m_subMenu.items = items;
            this.m_subMenu.selectTab(selectedTab);
            this.m_subMenu.x = Math.round(SUB_MENU_CENTER_X_POSITION - this.m_subMenu.visibleWidth / 2);
         }
         else
         {
            this.m_subMenu.items = null;
         }
         if(this.m_LeRevamp && this.m_type == "limited")
         {
            submenuitems = [];
            selectedSubTab = 0;
            leTheme = "";
            isNew = false;
            for(tabindex = 0; tabindex < this.m_lesubmenuitems.length; tabindex++)
            {
               leTheme = this.m_lesubmenuitems[tabindex] as String;
               desc = ZLocUtils.t("Dialogs","theme_" + leTheme);
               if(desc == "" && leTheme == "all")
               {
                  desc = ZLocUtils.t("Dialogs","theme_ledefault");
               }
               showExpiry = "";
               isNew = false;
               if(tabindex == 2)
               {
                  leitem = (this.m_leItems[leTheme] as Array)[0];
                  timeleft = leitem.limitedTimeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  parsedtime = FarmGameUtil.parseTimeLeft(timeleft);
                  showExpiry = FarmGameUtil.getFormattedTimeLeftText(parsedtime);
               }
               if(tabindex == 1)
               {
                  isNew = true;
               }
               submenuitems.push(new MenuItem(leTheme,desc,false,isNew,false,showExpiry));
               if(this.m_subType == leTheme)
               {
                  selectedSubTab = tabindex;
               }
            }
            this.m_subMenuLE.items = submenuitems;
            this.m_subMenuLE.visible = true;
            this.m_subMenuLE.selectTab(selectedSubTab);
            this.m_subMenu.visible = false;
            this.toggleLeTab(true);
         }
         else
         {
            this.toggleLeTab(false);
            sortOptionsForType = Global.marketConfigSettings.getSortOptions(typeForSubTypes);
            for each(sortOpt in sortOptionsForType)
            {
               menuItem = new MenuItem(sortOpt,ZLocUtils.t("Dialogs","sort_" + sortOpt["sortBy"] + "_" + sortOpt["sortDirection"]));
               sortByMenuItems.push(menuItem);
            }
         }
         this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
         this.m_sortByMenu.visible = false;
         if(sortByMenuItems.length > 0)
         {
            if(this.m_preserveSort)
            {
               this.m_preserveSort = false;
            }
            else
            {
               item = sortByMenuItems[0];
               this.m_sortBy = item.data["sortBy"];
               this.m_sortDirection = item.data["sortDirection"];
            }
            this.m_sortByMenu.items = sortByMenuItems;
            this.m_sortByButton.visible = true;
         }
         else
         {
            this.m_sortBy = Global.farmGameSettingsManager.getDefaultSortType();
            if(this.m_type == "new" || this.m_type == "limited")
            {
               this.m_sortDirection = FarmGameSettingsManager.DESCENDING;
            }
            else
            {
               this.m_sortDirection = FarmGameSettingsManager.ASCENDING;
            }
            this.m_sortByButton.visible = false;
         }
      }
      
      private function sortWhiteList(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         if(obj1.hasOwnProperty("position") && obj2.hasOwnProperty("position"))
         {
            if(obj1.position < obj2.position)
            {
               result = -1;
            }
            else
            {
               result = 1;
            }
         }
         return result;
      }
      
      protected function getSubTypes(type:String) : Array
      {
         var n:int = 0;
         var vipSubTypes:Array = null;
         var subTypeDict:Dictionary = null;
         var i:int = 0;
         var subTypes:Array = Global.marketConfigSettings.getSubTypes(type);
         if(this.m_LeRevamp && this.m_type == "limited")
         {
            subTypes = new Array();
         }
         else if(type == FarmGameSettingsManager.TYPE_MANAGED_SALE)
         {
            subTypes = new Array();
            if(Global.worldSpecificSalesManager.isActive())
            {
               subTypes = subTypes.concat(Global.worldSpecificSalesManager.getSaleSubTypes());
            }
            if(Global.categorySpecificSalesManager.isActive())
            {
               subTypes = subTypes.concat(Global.categorySpecificSalesManager.getSaleSubTypes());
            }
            if(Global.managedSalesManager.hasValidOnSaleItems())
            {
               subTypes = subTypes.concat(Global.managedSalesManager.getSaleSubTypes());
            }
            if(Global.vipSalesManager.hasValidOnSaleItems())
            {
               n = int(subTypes.length);
               vipSubTypes = Global.vipSalesManager.getSaleSubTypes();
               if(n == 0)
               {
                  subTypes = subTypes.concat(vipSubTypes);
               }
               else
               {
                  subTypeDict = new Dictionary();
                  i = 0;
                  for(i = 0; i < n; i++)
                  {
                     subTypeDict[subTypes[i]] = 1;
                  }
                  for(i = 0; i < vipSubTypes.length; i++)
                  {
                     if(!subTypeDict[vipSubTypes[i]])
                     {
                        subTypes.push(vipSubTypes[i]);
                     }
                  }
               }
            }
         }
         else if(Boolean(type != "special") && Boolean(subTypes) && subTypes.length > 0)
         {
            subTypes.unshift("all");
         }
         return subTypes;
      }
      
      private function getSubSubTypes(type:String, subType:String) : Array
      {
         var subSubTypes:Array = Global.marketConfigSettings.getSubSubTypes(type,subType);
         if(Boolean(subSubTypes) && subSubTypes.length > 0)
         {
            subSubTypes.unshift("all");
         }
         return subSubTypes;
      }
      
      public function toggleInput(enabled:Boolean = true) : void
      {
         if(enabled)
         {
            this.untintWindow();
         }
         else
         {
            this.tintWindow();
         }
         this.enableInput = enabled;
         this.refresh();
         if(this.m_marketSlotFrame != null)
         {
            this.m_marketSlotFrame.refresh();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         CoconutSurfaceReminder.conditionallyShowCoconutReminder();
      }
      
      override public function close() : void
      {
         MarketStatsManager.countCloseMarket();
         previousType = this.m_type;
         previousSubType = this.m_subType;
         previousSubSubType = this.m_subSubType;
         previousSortBy = this.m_sortBy;
         previousSortDirection = this.m_sortDirection;
         if(this.m_marketSlotFrame != null)
         {
            previousPage = this.m_marketSlotFrame.pageNumber;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            ToasterManager.getInstance().toasterHeight = NaN;
         }
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(this.m_closeIsBuy);
         }
         super.close();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LE_LAST_CHANCE) < Experiments.VARIANT_LE_LAST_CHANCE_EXPIRING)
         {
            LESurfacingManager.instance.onCloseMarketDialog();
         }
         if(this.m_marketOverlay)
         {
            this.m_marketOverlay.close();
         }
         if(this.m_worldMarketSaleOverlay)
         {
            this.m_worldMarketSaleOverlay.close();
         }
      }
      
      override protected function release() : void
      {
         if(this.m_subMenu)
         {
            (this.m_subMenu.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onSubMenuMouseOver);
            (this.m_subMenu.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onSubMenuMouseOut);
         }
         if(this.m_subDropDownMenu)
         {
            (this.m_subDropDownMenu.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onSubMenuMouseOut);
         }
         if(this.m_sortByButton)
         {
            (this.m_sortByButton.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onSortByMouseOver);
            (this.m_sortByButton.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut);
         }
         if(this.m_sortByMenu)
         {
            (this.m_sortByMenu.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut);
         }
         if(this.m_charityBannerFrame != null)
         {
            this.m_charityBannerFrame = null;
         }
         this.m_closeCallback = null;
         this.m_coinTextField = null;
         this.m_coinSlideTextField = null;
         this.m_cashTextField = null;
         this.m_levelTextField = null;
         this.m_typeTextField = null;
         this.m_mainMenu = null;
         this.m_subMenu = null;
         this.m_subDropDownMenu = null;
         this.m_sortByButton = null;
         this.m_sortByMenu = null;
         this.m_marketSlotFrame = null;
         this.m_miniSlotFrame = null;
         this.m_flashSaleFrame = null;
         this.m_promoSlotFrame = null;
         this.m_buyPresent = null;
         this.m_buyMultiPresent = null;
         this.m_searchBar_mc = null;
         this.m_clearSearchButton_mc = null;
         this.m_search_mc = null;
         this.m_searchField_tf = null;
         this.m_noResultsText = null;
         this.m_currencyButton = null;
         this.m_currencyTextField = null;
         this.m_coinSlideExpanded = null;
         this.m_coinSlideContracted = null;
         this.m_plotCallback = null;
         this.m_coinButton = null;
         this.m_cashButton = null;
         this.m_worldScoreMeter = null;
         this.m_worldScoreText = null;
         this.m_statusPointsButton = null;
         this.m_statusPointsText = null;
         this.m_titleTextField = null;
         if(Boolean(m_window) && Boolean(m_window.searchBar_mc) && Boolean(m_window.searchBar_mc.searchField_tf))
         {
            m_window.searchBar_mc.searchField_tf.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
         }
         if(this.m_searchFieldInputBatcher)
         {
            this.m_searchFieldInputBatcher.removeEventListener(EventBatchEvent.EVENT_BATCH,this.onKeyUpBatchHandler);
            this.m_searchFieldInputBatcher.release();
            this.m_searchFieldInputBatcher = null;
         }
         this.m_ftueLE = null;
         this.m_ftueLEAccept = null;
         this.m_marketSlotFrameLE = null;
         this.m_subMenuLE = null;
         this.m_lePromoSlotFrame = null;
         this.m_leItems = null;
         this.m_LeHeader = null;
         this.m_LeSubtitle = null;
         this.m_lesubmenuitems = null;
         super.release();
      }
      
      public function set coinTextField(num:Number) : void
      {
         if(this.m_worldCurrencyActive)
         {
            if(this.m_coinSlideTextField)
            {
               this.m_coinSlideTextField.text = num.toString();
            }
         }
         else if(this.m_coinTextField)
         {
            this.m_coinTextField.text = num.toString();
         }
      }
      
      public function setCurrencyTextField(currencyUnit:String, num:Number) : void
      {
         if(Currency.COINS == currencyUnit || Currency.GOLD == currencyUnit)
         {
            this.coinTextField = num;
         }
         else if(this.m_currencyTextField)
         {
            this.m_currencyTextField.text = num.toString();
         }
      }
      
      public function set cashTextField(num:Number) : void
      {
         if(this.m_cashTextField)
         {
            this.m_cashTextField.text = Utilities.formatNumber(num);
         }
      }
      
      private function getMarketPromoElement() : MovieClip
      {
         var numActivePromos:int = 0;
         var promoMCName:String = null;
         var numColumns:int = 0;
         var result:MovieClip = null;
         if(m_window)
         {
            numActivePromos = int(Global.flashHotParams["MARKET_PROMOS_ACTIVE"]);
            promoMCName = "promoCards" + numActivePromos + "_mc";
            numColumns = this.getMarketSize();
            if(numColumns == NUM_MED_MARKET_COLS && m_window.hasOwnProperty("promoCards3Wide_mc"))
            {
               promoMCName = "promoCards" + numActivePromos + "Wide_mc";
            }
            if(numActivePromos > 0 && m_window.hasOwnProperty(promoMCName))
            {
               result = m_window.getChildByName(promoMCName) as MovieClip;
            }
            else if(MarketWindow.isNewMarketplaceHomepageOn())
            {
               result = m_window.promoCards_mc;
            }
            else
            {
               result = m_window.promoCards3_mc;
            }
         }
         return result;
      }
      
      private function sortItemsPromoSlot(type:String, items:Array) : void
      {
         var farmItem:FarmItem = null;
         var indexOf:int = 0;
         var promoSlotData:Object = Global.marketConfigSettings.getPromoItemSlotData(type);
         if(promoSlotData)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(promoSlotData.name);
            if(farmItem)
            {
               farmItem.marketCardName = promoSlotData.marketCard;
               indexOf = items.indexOf(farmItem);
               if(indexOf >= 0)
               {
                  items.splice(indexOf,1);
                  items.unshift(farmItem);
                  if(farmItem.marketCardDescriptor.slotHeight > 1)
                  {
                     items.splice(MarketSlotFrame.LOWER_LEFT_SLOT_INDEX,0,{});
                  }
               }
            }
         }
      }
      
      public function reload() : void
      {
         if(this.m_searchField_tf.text == "" || this.m_searchField_tf.text == this.m_defaultString)
         {
            this.m_clearSearchButton_mc.visible = false;
            if(this.m_search_mc != null)
            {
               this.m_search_mc.visible = true;
            }
            this.refreshItems();
            this.refreshMenus();
         }
         else
         {
            this.m_clearSearchButton_mc.visible = true;
            if(this.m_search_mc != null)
            {
               this.m_search_mc.visible = false;
            }
            this.refreshItems();
            this.m_subMenu.visible = false;
            this.m_sortByButton.visible = false;
         }
      }
      
      private function onCurrencyButtonClick(event:MouseEvent) : void
      {
         InGameCurrencyConversion.showImpulseBuy(this.m_currentCurrency);
      }
      
      private function onSearchTextButtonClick(event:MouseEvent) : void
      {
         Global.farmGame.switchOutFullScreen();
         if(this.m_searchField_tf.text == this.m_defaultString)
         {
            this.m_searchField_tf.text = "";
            this.m_clearedSearch = true;
         }
      }
      
      public function clearSearch() : void
      {
         if(this.m_searchField_tf)
         {
            this.m_searchField_tf.text = "";
            if(UI.windowState == null)
            {
               UI.windowState = {};
            }
            UI.windowState.market = {};
            this.m_clearedSearch = true;
            this.m_mainMenu.restoreAllDeselected();
            this.reload();
         }
      }
      
      private function onClearSearchButtonClick(event:MouseEvent) : void
      {
         this.clearSearch();
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         LESurfacingManager.instance.onCloseMarketDialog();
         Global.overrideDebugKeys = true;
      }
      
      private function onKeyUpBatchHandler(event:EventBatchEvent) : void
      {
         this.onSearchTextChanged();
      }
      
      private function onKeyUpHandler(event:KeyboardEvent) : void
      {
         this.onSearchTextChanged();
      }
      
      private function onSearchTextChanged() : void
      {
         if(this.m_searchField_tf.text == "")
         {
            this.m_mainMenu.restoreAllDeselected();
         }
         else
         {
            this.m_mainMenu.deselectAll();
         }
         if(UI.windowState == null)
         {
            UI.windowState = {"market":{}};
         }
         else if(UI.windowState.market == null)
         {
            UI.windowState.market = {};
         }
         if(this.m_cacheSearch)
         {
            UI.windowState.market["searchString"] = this.m_searchField_tf.text;
         }
         this.reload();
      }
      
      private function openLimitedGiftingWindow(data:Object) : void
      {
         openLimitedGiftingWindowHelper(data);
      }
      
      private function openSocialCharityWindow(data:Object) : void
      {
         var classInstance:Class = null;
         var buildingName:String = null;
         var source:String = null;
         var dialogInstance:FarmWindow = null;
         if(data.actionParams != null && data.actionParams.length > 0)
         {
            try
            {
               classInstance = getDefinitionByName(data.actionParams[0]) as Class;
               buildingName = data.actionParams[1];
               source = data.actionParams[2];
               dialogInstance = new classInstance(buildingName,source);
               UI.displayPopup(dialogInstance);
               this.close();
            }
            catch(error:Error)
            {
               ErrorManager.addError("Class is not found: " + data.actionParams[0],ErrorManager.ERROR_FAILED_TO_LOAD);
            }
         }
      }
      
      private function openSubscriptionsSignupFlow(data:Object) : void
      {
         this.close();
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_SIGNUP_POPUP,{"source":"vip_hud"}));
      }
      
      private function setupMarket3() : void
      {
         this.setupMarket3SlotColumns();
         this.setupMarket3FTUE();
         this.setupMarketVIPFtue();
         if(this.m_LeRevamp && this.m_type == "limited" && Global.player.getSeenFlag(SEEN_MARKET_3_FTUE_FLAG))
         {
            this.setupLeRevampFTUE();
         }
      }
      
      private function setupLeRevampFTUE() : void
      {
         if(this.getMarketSize() == NUM_MED_MARKET_COLS && m_window.hasOwnProperty("ftueMedium_LE_mc"))
         {
            this.m_ftueLE = m_window.ftueMedium_LE_mc as MovieClip;
            if(this.m_ftueLE)
            {
               this.m_ftueLE.visible = false;
            }
            if(!(this is MarketMiniWindow) && !Global.player.getSeenFlag(SEEN_MARKET_LE_FTUE))
            {
               this.m_ftueLE.visible = true;
               this.m_ftueLE.gotoAndStop(1);
               if(this.m_ftueLEAccept == null && this.m_ftueLE.hasOwnProperty("okay_bt"))
               {
                  this.m_ftueLEAccept = new FarmAnimatedButton(this.m_ftueLE.okay_bt,this.onLERevampFTUEClick) as FarmAnimatedButton;
               }
            }
         }
      }
      
      private function onLERevampFTUEClick(event:Event) : void
      {
         var frameNo:int = (this.m_ftueLE as MovieClip).currentFrame;
         if(frameNo < 5)
         {
            (this.m_ftueLE as MovieClip).gotoAndStop(frameNo + 1);
         }
         else
         {
            this.m_ftueLE.visible = false;
            Global.player.setSeenFlag(SEEN_MARKET_LE_FTUE);
         }
      }
      
      private function setupMarketVIPFtue() : void
      {
         if(Boolean(m_window.VIPFTUE_mc) && Global.vipSalesManager.isEnabled())
         {
            this.m_ftueVip = m_window.VIPFTUE_mc as MovieClip;
            if(this.m_ftueVip)
            {
               this.m_ftueVip.visible = false;
            }
            if(!(this is MarketMiniWindow) && !Global.player.getSeenFlag(SEEN_MARKET_VIP_FTUE_FLAG))
            {
               this.m_ftueVip.visible = true;
               this.m_ftueVip.gotoAndStop(1);
               if(this.m_ftueVipAccept == null && this.m_ftueVip.hasOwnProperty("okay_bt"))
               {
                  this.m_ftueVipAccept = new FarmAnimatedButton(this.m_ftueVip.okay_bt,this.onFTUEVIPOkBtnClick) as FarmAnimatedButton;
               }
            }
         }
      }
      
      private function onFTUEVIPOkBtnClick(event:Event) : void
      {
         this.m_ftueVip.visible = false;
         Global.player.setSeenFlag(SEEN_MARKET_VIP_FTUE_FLAG);
      }
      
      private function setupMarket3FTUE() : void
      {
         if(this.getMarketSize() == NUM_MED_MARKET_COLS && m_window.hasOwnProperty("ftueMedium_mc"))
         {
            this.m_ftue = m_window.ftueMedium_mc as MovieClip;
         }
         else if(this.getMarketSize() == NUM_SMALL_MARKET_COLS && m_window.hasOwnProperty("ftueSmall_mc"))
         {
            this.m_ftue = m_window.ftueSmall_mc as MovieClip;
         }
         if(this.m_ftue)
         {
            this.m_ftue.visible = false;
         }
         if(this.m_ftue != null && !(this is MarketMiniWindow) && (!Global.player.getSeenFlag(SEEN_MARKET_3_FTUE_FLAG) || !Global.player.getSeenFlag(SEEN_NEW_MARKETPLACE_3_HOMEPAGE) && MarketWindow.isNewMarketplaceHomepageOn()))
         {
            this.m_ftue.visible = true;
            this.m_ftue.gotoAndStop(1);
            if(this.m_ftueAccept == null && this.m_ftue.hasOwnProperty("okay_bt"))
            {
               this.m_ftueAccept = new FarmAnimatedButton(this.m_ftue.okay_bt,this.onFTUEOkBtnClick) as FarmAnimatedButton;
            }
         }
      }
      
      private function onFTUEOkBtnClick(event:Event) : void
      {
         if((this.m_ftue as MovieClip).currentFrame == 1 && !isNewMarketplaceHomepageOn())
         {
            (this.m_ftue as MovieClip).gotoAndStop(2);
         }
         else
         {
            this.m_ftue.visible = false;
            if(isNewMarketplaceHomepageOn())
            {
               Global.player.setSeenFlag(SEEN_NEW_MARKETPLACE_3_HOMEPAGE);
               Global.player.setSeenFlag(SEEN_MARKET_3_FTUE_FLAG);
            }
            else
            {
               Global.player.setSeenFlag(SEEN_MARKET_3_FTUE_FLAG);
            }
         }
      }
      
      private function attachMenuTooltips(menu:FarmTabMenu) : void
      {
         var tab:FarmTabMenuButton = null;
         for(var i:int = 0; i < menu.numTabs; i++)
         {
            tab = menu.getTab(i);
            if(Boolean(tab) && Boolean(menu.getItem(i)))
            {
               tab.attachTooltip(new FarmTextTooltip(menu.getItem(i).text));
               tab.text = "";
            }
         }
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get subtype() : String
      {
         return this.m_subType;
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            dispatchEvent(new MarketEvent(MarketEvent.MARKET_SHOWN));
         }
      }
      
      public function moveToBottom() : void
      {
         var marketWindowParent:DisplayObjectContainer = this.parent;
         if(Boolean(marketWindowParent) && marketWindowParent.numChildren > bottomDisplayObjectIndex)
         {
            marketWindowParent.setChildIndex(this,bottomDisplayObjectIndex);
         }
      }
      
      public function toggleLeTab(show:Boolean = false) : void
      {
         var cols:int = this.getMarketSize();
         if(cols == NUM_MED_MARKET_COLS)
         {
            m_window.gotoAndStop(2);
            if(m_window.hasOwnProperty("bgMed_mc") && m_window.hasOwnProperty("bgLEMed_mc"))
            {
               m_window.bgMed_mc.visible = !show;
               m_window.bgLEMed_mc.visible = show;
               m_window.bottomMedBG_mc.visible = !show;
               m_window.subNavBG_mc.visible = !show;
            }
            if(m_window.bgLEDefaultMed_mc)
            {
               m_window.bgLEDefaultMed_mc.visible = show;
            }
         }
         else
         {
            m_window.gotoAndStop(1);
            if(m_window.hasOwnProperty("bgSmall_mc") && m_window.hasOwnProperty("bgLESmall_mc"))
            {
               m_window.bgSmall_mc.visible = !show;
               m_window.bgLESmall_mc.visible = show;
               m_window.bottomSmallBG_mc.visible = !show;
               m_window.subNavBG_mc.visible = !show;
            }
            if(m_window.bgLEDefaultSmall_mc)
            {
               m_window.bgLEDefaultSmall_mc.visible = show;
            }
         }
      }
   }
}

