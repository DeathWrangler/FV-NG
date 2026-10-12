package Display.HUD
{
   import Classes.Building;
   import Classes.BuyerPromo.BuyerPromoUtility;
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.EmbeddedArt;
   import Classes.TutController;
   import Classes.WatchToEarnManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.CategorizedDynamicIconQueue;
   import Display.CropBoostIcon;
   import Display.DynamicIconQueue;
   import Display.FarmGameSprite;
   import Display.GenericPopup;
   import Display.HUD.HUDWidgets.HUDBottomTutorialButton;
   import Display.HUD.HUDWidgets.HUDFishingDerbyWidget;
   import Display.HUD.HUDWidgets.HUDHomeWidget;
   import Display.HUD.HUDWidgets.HUDSubscriptionsWidget;
   import Display.HUD.HUDWidgets.HUDZoomWidget;
   import Display.HUD.HUDWidgets.HudBoraBoraInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomAchievementButton;
   import Display.HUD.HUDWidgets.HudBottomAmsterdamInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomAnimalSanctuaryV2;
   import Display.HUD.HUDWidgets.HudBottomBoatRush;
   import Display.HUD.HUDWidgets.HudBottomBookmarkOptButton;
   import Display.HUD.HUDWidgets.HudBottomBrazilInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomCanadaInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomCarribeanInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomCasablancaInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomCocowonderlandInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomDec19InnovationButton;
   import Display.HUD.HUDWidgets.HudBottomDragonvalleyInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomFVTECurrencyConversionButton;
   import Display.HUD.HUDWidgets.HudBottomFrontierInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomFvPluginButton;
   import Display.HUD.HUDWidgets.HudBottomGenericButton;
   import Display.HUD.HUDWidgets.HudBottomHalloweenInnovation2019Button;
   import Display.HUD.HUDWidgets.HudBottomHalloweenInnovationGhoulButton;
   import Display.HUD.HUDWidgets.HudBottomIrelandInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomIsraelInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomJournalButton;
   import Display.HUD.HUDWidgets.HudBottomJumbleVillaButton;
   import Display.HUD.HUDWidgets.HudBottomLEBundleButton;
   import Display.HUD.HUDWidgets.HudBottomLandBundleUnlockFeature;
   import Display.HUD.HUDWidgets.HudBottomMadagascarInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomOctoberSidecarFeature;
   import Display.HUD.HUDWidgets.HudBottomPumpkinPartyInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomRussiaInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomShowAnimalsButton;
   import Display.HUD.HUDWidgets.HudBottomSouthindiaInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomTwentiesInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomWinterRacingFeature;
   import Display.HUD.HUDWidgets.HudBottomWinternordInnovationButton;
   import Display.HUD.HUDWidgets.HudBottomWreathFestivalInnovationButton;
   import Display.HUD.HUDWidgets.HudFarmersMarketInnovationButton;
   import Display.HUD.HUDWidgets.HudLandBundle;
   import Display.HUD.HUDWidgets.HudMessageNotification;
   import Display.HUD.HUDWidgets.HudRoyaltyLoyaltyButton;
   import Display.HUD.HUDWidgets.HudTropicalMarketInnovationButton;
   import Display.MessageCenterDialog;
   import Display.OldCategorizedDynamicIconQueue;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import GameMode.GMSetAltGraphic;
   import GameMode.GMSetOverlayGraphic;
   import Managers.ChatManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.HolidayCountdownManager;
   import Managers.InGamePaymentsManager;
   import Managers.LoyaltyProgramManager;
   import Managers.NPCManager;
   import Transactions.TFieldPlantedEvent;
   import Transactions.TGetHarvestEmailPref;
   import Transactions.TSetEmailPref;
   import Widgets.HUD.TrickOrTreatHUD;
   import Widgets.Windows.HelpingHandsWindow;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import gs.TweenLite;
   
   public class HUD extends Sprite
   {
      
      protected static const COUNT_RATE:int = 30;
      
      protected static const TIMER_TICK:int = 50;
      
      private static const ZRUNTIME_KEY_HIDE_STATS_HUD:String = "HIDE_STATS_HUD";
      
      protected static const GETCOINS_FUNCTION_DEFAULT:String = "default";
      
      protected static const GETCOINS_FUNCTION_W2E:String = "w2e";
      
      public static const XP_METER_PADDING:Number = -5;
      
      protected static const FEEDS_AFTER_SEED_DELAY:int = 3000;
      
      protected static const HARVEST_EMAIL_OPT_IN_FEATURE:String = "fv_harvest_opt_in_prompt";
      
      public static const W2E_SLOT_ID_HUD_ICON:String = "WEB_FARM_INC_PP";
      
      public static const NUMBER_OF_DAYS_BEFORE_HARVEST_OPT_IN_POP:int = 60;
      
      protected static const REFUEL_THRESHOLD:int = 5;
      
      private static const Y_POSITION_HOLIDAY_COUNTDOWN_ICON:int = 80;
      
      private static const RESIZE_COIN_STRING_THRESHOLD:int = 90;
      
      private static const RESIZE_COIN_STRING_LIMIT:Number = 0.725;
      
      private static const FARMCLUB_ICON_X_OFFSET:int = 180;
      
      private static const FARMCLUB_ICON_Y_OFFSET:int = -170;
      
      private static var s_isW2EAdAvailable:Boolean = false;
      
      private var m_gold:int;
      
      private var m_worldCurrencyAmount:Number;
      
      private var m_goldChange:Boolean = false;
      
      private var m_currentGold:Number;
      
      private var m_goldChangeRate:int = 0;
      
      private var m_goldTimer:Timer = new Timer(TIMER_TICK);
      
      private var m_cash:int;
      
      private var m_cashChange:Boolean = false;
      
      private var m_currentCash:int;
      
      private var m_cashChangeRate:int = 0;
      
      private var m_cashTimer:Timer = new Timer(TIMER_TICK);
      
      private var m_optionMenu:OptionMenu;
      
      private var m_getCoinsButton:Object = null;
      
      private var m_currentGetCoinFunction:String;
      
      private var m_getCoinsTimer:Timer = new Timer(TIMER_TICK);
      
      private var m_level:int;
      
      private var m_goldTxt:TextField;
      
      private var m_currencyMeter:CurrencyMeter;
      
      private var m_fvCashTxt:TextField;
      
      private var m_xp:String;
      
      private var m_xpChange:Boolean = false;
      
      private var m_currentXp:Number;
      
      private var m_xpChangeRate:Number = 0;
      
      private var m_xpTimer:Timer = new Timer(TIMER_TICK);
      
      private var m_altGraphicIcon:FarmGameSprite;
      
      private var m_altGraphicText:TextField;
      
      private var m_toiletPaper:FarmGameSprite;
      
      private var m_cropBuffIconSprite:CropBoostIcon;
      
      private var m_energy:Number = 0;
      
      private var m_energyMax:Number = 150;
      
      private var m_energyTankText:TextField;
      
      private var m_refuelText:TextField;
      
      private var m_basicNameDisplay:BasicNameDisplay;
      
      private var m_travelNameDisplay:TravelNameDisplay;
      
      private var m_isTravelNameDisplayVisible:Boolean = false;
      
      private var m_isMessageButtonVisible:Boolean = false;
      
      private var m_harvestEmailTransactionAdded:Boolean = false;
      
      public var m_statsDropDown:StatsDropDown;
      
      private var m_goldSprite:FarmGameSprite;
      
      private var m_xpMeter:ScoreMeter;
      
      private var m_worldScoreMeter:ScoreMeter;
      
      private var m_worldScore2Meter:ScoreMeter;
      
      protected var m_hasLoggedFieldPlantedEvent:Object = {};
      
      protected var m_minSeededPlotsActivity:int = 36;
      
      protected var m_minSeededPlots:int = 10;
      
      protected var m_seedingQueued:int = 0;
      
      protected var m_totalSeedsPlanted:int = 0;
      
      protected var m_seedTypesPlanted:Object = {};
      
      protected var m_iconQueue:DynamicIconQueue;
      
      protected var m_rightSideIconQueue:DynamicIconQueue;
      
      protected var m_visitIconQueue:DynamicIconQueue;
      
      protected var m_iconContainerSprite:Sprite;
      
      private var m_topRightContainer:FarmGameSprite;
      
      private var m_messageSignButton:MessageSignButton;
      
      private var m_energySprite:FarmGameSprite;
      
      private var m_energyDisplayObject:DisplayObject;
      
      private var m_energyFlash:DisplayObject;
      
      private var m_unwitherSprite:FarmGameSprite;
      
      private var m_unwitherText:TextField;
      
      private var m_fvCashDisplay:Sprite;
      
      private var m_messageCenterButton:MessageCenterButton;
      
      private var m_cursorId:int = 0;
      
      private var m_dirty:Boolean = false;
      
      private var m_lockVisualEffects:Boolean = false;
      
      private var m_plantFeedItem:FarmItem = null;
      
      protected var m_visit:Boolean = false;
      
      private var m_holidayCountdownButton:FarmGameSprite;
      
      private var m_trickOrTreatIcon:TrickOrTreatHUD;
      
      private var m_hudSkinType:String;
      
      private var m_neighborSearch:NeighborBarSearch = null;
      
      private var m_chatNotification:ChatMessageNotification = null;
      
      private var m_subscriptionsLoader:Loader;
      
      private var m_subscriptionsWidget:HUDSubscriptionsWidget;
      
      private var m_fishingDerbyTackleBox:HUDFishingDerbyWidget = null;
      
      private var m_bottomHudTutorial:HUDBottomTutorialButton = null;
      
      private var m_bottomHudAchievement:HudBottomAchievementButton = null;
      
      private var m_HudLoyaltyRoyaltyButton:HudRoyaltyLoyaltyButton = null;
      
      private var m_buttomHudJournal:HudBottomJournalButton = null;
      
      private var m_bottomHudShowAnimals:Array = new Array();
      
      private var m_bottomHudBrazilInnovationButton:HudBottomBrazilInnovationButton = null;
      
      private var m_HudLandBundle:HudLandBundle = null;
      
      private var m_bottomHudLandBundleUnlockFeature:HudBottomLandBundleUnlockFeature = null;
      
      private var m_bottomHudWinterRacingFeature:HudBottomWinterRacingFeature = null;
      
      private var m_bottomHuBoatRushFeature:HudBottomBoatRush = null;
      
      private var m_bottomHudGenericButton:HudBottomGenericButton = null;
      
      private var m_homeButton:HUDHomeWidget = null;
      
      private var m_loyaltyProgramButton:LoyaltyProgramButton;
      
      private var m_zoomWidget:HUDZoomWidget = null;
      
      private var m_waterHudButton:WaterHudButton;
      
      private var m_harvestHelperHudIcon:HarvestHelperHudIcon;
      
      private var m_bottomHudDargonvalleyInnovationButton:HudBottomDragonvalleyInnovationButton;
      
      private var m_bottomHudCarribeanInnovationButton:HudBottomCarribeanInnovationButton;
      
      private var m_bottomHudRussiaInnovationButton:HudBottomRussiaInnovationButton;
      
      private var m_bottomHudFrontierInnovationButton:HudBottomFrontierInnovationButton;
      
      private var m_bottomHudLEBundleButton:HudBottomLEBundleButton;
      
      private var m_bottomHudFvPluginButton:HudBottomFvPluginButton;
      
      private var m_bottomHudBookmarkOptButton:HudBottomBookmarkOptButton;
      
      private var m_bottomHudIsraelInnovationButton:HudBottomIsraelInnovationButton;
      
      public var m_upHudGuildCreationButton:HudGuildCreationButton;
      
      private var m_bottomHudWinternordInnovationButton:HudBottomWinternordInnovationButton;
      
      private var m_bottomHudTwentiesInnovationButton:HudBottomTwentiesInnovationButton;
      
      private var m_bottomHudCocowonderlandInnovationButton:HudBottomCocowonderlandInnovationButton;
      
      private var m_bottomHudHalloweenInnovationGhoulButton:HudBottomHalloweenInnovationGhoulButton;
      
      private var m_bottomHudCasablancaInnovationButton:HudBottomCasablancaInnovationButton;
      
      private var m_bottomHudSouthindiaInnovationButton:HudBottomSouthindiaInnovationButton;
      
      private var m_bottomHudIrelandInnovationButton:HudBottomIrelandInnovationButton;
      
      private var m_bottomHudHalloweenInnovation2019Button:HudBottomHalloweenInnovation2019Button;
      
      private var m_bottomHudFarmersMarket2020InnovationButton:HudFarmersMarketInnovationButton;
      
      public var m_bottomHudBoraBoraInnovationButton:HudBoraBoraInnovationButton;
      
      private var m_bottomHudDec19InnovationButton:HudBottomDec19InnovationButton;
      
      private var m_bottomHudMadagascarInnovationButton:HudBottomMadagascarInnovationButton;
      
      private var m_bottomHudCanadaInnovationButton:HudBottomCanadaInnovationButton;
      
      private var m_bottomHudJumbleVillaButton:HudBottomJumbleVillaButton;
      
      private var m_bottomHudAmsterdamInnovationButton:HudBottomAmsterdamInnovationButton;
      
      private var m_MessageNotification:HudMessageNotification;
      
      private var m_bottomHudAnimalSanctuaryV2Button:HudBottomAnimalSanctuaryV2;
      
      public var m_hudBookmarkOptButton:HudBookMarkButton;
      
      private var m_bottomHudOctoberSidecarFeatureButton:HudBottomOctoberSidecarFeature;
      
      private var m_bottomHudPumpkinPartyInnovationButton:HudBottomPumpkinPartyInnovationButton;
      
      public var m_bottomHudTropicalMarketInnovationButton:HudTropicalMarketInnovationButton;
      
      private var m_bottomHudWreathFestivalInnovationButton:HudBottomWreathFestivalInnovationButton;
      
      private var m_bottomFVTEButton:HudBottomFVTECurrencyConversionButton;
      
      public function HUD()
      {
         super();
         Global.hud = this;
         this.topRightContainerCreate();
         this.m_goldTimer.addEventListener(TimerEvent.TIMER,this.updateGold);
         this.m_iconContainerSprite = new Sprite();
         this.m_iconContainerSprite.x = 31;
         this.m_iconContainerSprite.y = 120;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CATEGORIZED_HUD_ICON_IMPROVEMENTS) != Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            this.m_iconQueue = new OldCategorizedDynamicIconQueue();
            this.m_rightSideIconQueue = new OldCategorizedDynamicIconQueue(null,DynamicIconQueue.RIGHT_SIDE);
         }
         else
         {
            this.m_iconQueue = new CategorizedDynamicIconQueue();
            this.m_rightSideIconQueue = new CategorizedDynamicIconQueue(DynamicIconQueue.RIGHT_SIDE);
         }
         this.m_iconQueue.visibleIcons = Global.farmGameSettingsManager.getInt("numVisibleHudIcons");
         this.m_visitIconQueue = new DynamicIconQueue();
         this.m_iconContainerSprite.addChild(this.m_iconQueue);
         this.m_iconContainerSprite.addChild(this.m_visitIconQueue);
         addChild(this.m_iconContainerSprite);
         this.m_rightSideIconQueue.visibleIcons = Global.farmGameSettingsManager.getInt("numVisibleRightSideHudIcons");
         this.m_rightSideIconQueue.y = 90;
         addChildAt(this.m_rightSideIconQueue,0);
         this.m_optionMenu = new OptionMenu();
         addChild(this.m_optionMenu);
         this.m_getCoinsTimer.addEventListener(TimerEvent.TIMER,this.updateGetCoinsFunctionality);
         this.m_getCoinsTimer.start();
         this.m_xpMeter = new ScoreMeter();
         this.m_xpMeter.init(new ScoreMeterConfig());
         this.m_xpMeter.trackClicks(false);
         this.m_xpMeter.x = 310;
         this.m_xpMeter.y = 5;
         addChild(this.m_xpMeter);
         this.m_xpTimer.addEventListener(TimerEvent.TIMER,this.updateXp);
         this.m_waterHudButton = new WaterHudButton();
         this.m_topRightContainer.addChild(this.m_waterHudButton);
         this.m_loyaltyProgramButton = new LoyaltyProgramButton();
         this.m_topRightContainer.addChild(this.m_loyaltyProgramButton);
         this.m_fvCashDisplay = new Sprite();
         this.m_fvCashDisplay.addChild(new EmbeddedArt.FV_Cash_Icon());
         this.m_fvCashDisplay.x = 180;
         this.m_fvCashDisplay.y = 3;
         this.m_fvCashTxt = new TextField();
         this.m_fvCashTxt.selectable = false;
         this.m_fvCashTxt.autoSize = TextFieldAutoSize.LEFT;
         this.m_fvCashTxt.embedFonts = true;
         this.m_fvCashTxt.defaultTextFormat = HUDFonts.ResourceText;
         this.m_fvCashTxt.setTextFormat(HUDFonts.ResourceText);
         this.m_fvCashTxt.x = 48;
         this.m_fvCashTxt.y = 6;
         this.m_fvCashTxt.mouseWheelEnabled = false;
         Utilities.toggleInputOnlySelf(this.m_fvCashTxt,false);
         addChild(this.m_fvCashDisplay);
         this.m_fvCashDisplay.addChild(this.m_fvCashTxt);
         this.m_fvCashDisplay.addEventListener(MouseEvent.CLICK,this.onGetCoins);
         this.m_cashTimer.addEventListener(TimerEvent.TIMER,this.updateCash);
         var altGraphicName:String = Global.farmGameSettingsManager.getCurrentAltGraphic();
         if(altGraphicName != "")
         {
            this.setAltGraphicIcon(altGraphicName);
         }
         this.m_toiletPaper = new FarmGameSprite();
         this.m_toiletPaper.buttonMode = true;
         this.m_toiletPaper.useHandCursor = false;
         Utilities.toggleInputOnlyChildren(this.m_toiletPaper,false);
         this.m_toiletPaper.toolTip = ZLocUtils.t("FarmGame","ToiletPaper_ToolTip");
         this.m_toiletPaper.x = 0;
         this.m_toiletPaper.y = 630;
         this.m_toiletPaper.scaleX = this.m_toiletPaper.scaleY = 1;
         this.m_toiletPaper.normalScale = 1;
         this.m_toiletPaper.rollOverScale = 1.15;
         var toiletPaperImage:Bitmap = new EmbeddedArt.hud_resource_tp();
         this.m_toiletPaper.addChild(toiletPaperImage);
         this.m_toiletPaper.visible = false;
         this.m_toiletPaper.addEventListener(MouseEvent.CLICK,this.onToiletPaperAttempt);
         addChild(this.m_toiletPaper);
         this.m_cropBuffIconSprite = new CropBoostIcon();
         this.m_cropBuffIconSprite.x = 900;
         this.m_cropBuffIconSprite.y = 400;
         addChild(this.m_cropBuffIconSprite);
         this.m_energySprite = new FarmGameSprite();
         var FV_Main_Fuel_Gauge:Class = ZLocUtils.tiEmbeddedArt("FV_Main_Fuel_Gauge_noBar");
         this.m_energyDisplayObject = new FV_Main_Fuel_Gauge();
         this.m_energySprite.addEventListener(MouseEvent.CLICK,this.onEnergyPopup);
         this.m_energySprite.addChild(this.m_energyDisplayObject);
         this.m_energyFlash = new EmbeddedArt.FV_Main_Fuel_Glow();
         this.m_energySprite.addChild(this.m_energyFlash);
         this.m_energyFlash.visible = false;
         this.m_energySprite.addEventListener(MouseEvent.MOUSE_OVER,this.onEnergyBarMouseOver);
         addChild(this.m_energySprite);
         var textFormat:TextFormat = new TextFormat("Merkin2",10,16777215,true);
         textFormat.align = TextFormatAlign.CENTER;
         this.m_energyTankText = new TextField();
         this.m_energyTankText.defaultTextFormat = textFormat;
         this.m_energyTankText.x = 0;
         this.m_energyTankText.y = 27;
         this.m_energyTankText.embedFonts = true;
         this.m_energyTankText.width = 36;
         this.m_energyTankText.height = 16;
         this.m_energyTankText.selectable = false;
         Utilities.toggleInputOnlySelf(this.m_energyTankText,false);
         this.m_energySprite.addChild(this.m_energyTankText);
         textFormat = new TextFormat("Merkin2",12,16777215,true);
         textFormat.align = TextFormatAlign.CENTER;
         var refuelStroke:GlowFilter = new GlowFilter();
         refuelStroke.blurX = refuelStroke.blurY = 1.3;
         refuelStroke.color = 7752991;
         refuelStroke.alpha = 1;
         refuelStroke.quality = BitmapFilterQuality.HIGH;
         refuelStroke.strength = 30;
         this.m_refuelText = new TextField();
         this.m_refuelText.selectable = false;
         this.m_refuelText.x = 31;
         this.m_refuelText.y = 12;
         this.m_refuelText.embedFonts = true;
         this.m_refuelText.width = 135;
         this.m_refuelText.height = 32;
         this.m_refuelText.defaultTextFormat = textFormat;
         this.m_refuelText.filters = [refuelStroke];
         this.m_refuelText.addEventListener(MouseEvent.CLICK,this.onRefuelClick);
         this.m_refuelText.addEventListener(MouseEvent.ROLL_OVER,this.onRefuelOver);
         this.m_refuelText.addEventListener(MouseEvent.ROLL_OUT,this.onRefuelOut);
         this.m_energySprite.addChild(this.m_refuelText);
         var unwitherTextFormat:TextFormat = new TextFormat();
         unwitherTextFormat.font = "Merkin2";
         unwitherTextFormat.size = 16;
         unwitherTextFormat.color = 156;
         this.m_unwitherText = new TextField();
         this.m_unwitherText.selectable = false;
         this.m_unwitherText.autoSize = TextFieldAutoSize.LEFT;
         this.m_unwitherText.embedFonts = true;
         this.m_unwitherText.defaultTextFormat = unwitherTextFormat;
         this.m_unwitherText.setTextFormat(unwitherTextFormat);
         this.m_unwitherText.x = 30;
         this.m_unwitherText.y = 600;
         this.m_unwitherText.visible = false;
         this.m_minSeededPlotsActivity = Global.farmGameSettingsManager.getInt("minSeededPlotsActivity",36);
         this.m_minSeededPlots = Global.farmGameSettingsManager.getInt("minSeededPlots",10);
         this.conditionallyRefreshHUD(true);
         this.setVisiting(false);
      }
      
      public static function initializeWatchToEarn() : void
      {
      }
      
      private static function onWatchToEarnServiceInitialized(event:Event) : void
      {
         refreshWatchToEarnAvailability();
      }
      
      private static function onWatchToEarnSlotChanged(event:Event) : void
      {
         refreshWatchToEarnAvailability();
      }
      
      private static function onWatchToEarnActivityComplete(event:Event) : void
      {
         refreshWatchToEarnAvailability();
      }
      
      private static function refreshWatchToEarnAvailability() : void
      {
      }
      
      public static function getformattedTimeLeft(timeLeft:Number) : String
      {
         var days:int = 0;
         var hours:int = 0;
         var minutes:int = 0;
         var seconds:int = 0;
         var result:String = "";
         if(timeLeft < 0)
         {
            timeLeft = 0;
         }
         var timeLeftArray:Array = FarmGameUtil.parseTimeLeft(timeLeft);
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
            hours = int(timeLeftArray[1]);
            if(days > 0)
            {
               if(days > 1 || days == 1 && hours > 9)
               {
                  result = days + 1 + " " + ZLocUtils.t("Dialogs","Days");
               }
               else
               {
                  result = ZLocUtils.t("Dialogs","mysterycrate_day_hours",{"hours":hours});
               }
            }
            else
            {
               result += hours < 10 ? "0" + hours : hours.toString();
               result += ":";
               minutes = int(timeLeftArray[2]);
               result += minutes < 10 ? "0" + minutes : minutes.toString();
               result += ":";
               seconds = int(timeLeftArray[3]);
               result += seconds < 10 ? "0" + seconds : seconds.toString();
            }
         }
         return result;
      }
      
      public static function getformattedTimeLeftFromArray(timeLeftArray:Array) : String
      {
         var days:int = 0;
         var hours:int = 0;
         var minutes:int = 0;
         var seconds:int = 0;
         var result:String = "";
         if(Boolean(timeLeftArray) && timeLeftArray.length > 3)
         {
            days = int(timeLeftArray[0]);
            hours = int(timeLeftArray[1]);
            if(days > 0)
            {
               if(days > 1 || days == 1 && hours > 9)
               {
                  result = days + 1 + " " + ZLocUtils.t("Dialogs","Days");
               }
               else
               {
                  result = ZLocUtils.t("Dialogs","mysterycrate_day_hours",{"hours":hours});
               }
            }
            else
            {
               result += hours < 10 ? "0" + hours : hours.toString();
               result += ":";
               minutes = int(timeLeftArray[2]);
               result += minutes < 10 ? "0" + minutes : minutes.toString();
               result += ":";
               seconds = int(timeLeftArray[3]);
               result += seconds < 10 ? "0" + seconds : seconds.toString();
            }
         }
         return result;
      }
      
      public function setBottomHudTutorialButton(bottomHud:HUDBottomTutorialButton) : void
      {
         this.m_bottomHudTutorial = bottomHud;
      }
      
      public function setBottomHudAchievementButton(bottomHud:HudBottomAchievementButton) : void
      {
         this.m_bottomHudAchievement = bottomHud;
      }
      
      public function setHudRoyaltyLoyaltyButton(bottomHud:HudRoyaltyLoyaltyButton) : void
      {
         this.m_HudLoyaltyRoyaltyButton = bottomHud;
      }
      
      public function setBottomHudGenericButton(bottomHud:HudBottomGenericButton) : void
      {
         this.m_bottomHudGenericButton = bottomHud;
      }
      
      public function setBottomHudJournalButton(bottomHud:HudBottomJournalButton) : void
      {
         this.m_buttomHudJournal = bottomHud;
      }
      
      public function setBottomHudBrazilInnovationButton(bottomHud:HudBottomBrazilInnovationButton) : void
      {
         this.m_bottomHudBrazilInnovationButton = bottomHud;
      }
      
      public function setBottomHudDragonvalleyInnovationButton(bottomHud:HudBottomDragonvalleyInnovationButton) : void
      {
         this.m_bottomHudDargonvalleyInnovationButton = bottomHud;
      }
      
      public function setBottomCarribeanInnovationButton(bottomHud:HudBottomCarribeanInnovationButton) : void
      {
         this.m_bottomHudCarribeanInnovationButton = bottomHud;
      }
      
      public function setBottomCasablancaInnovationButton(bottomHud:HudBottomCasablancaInnovationButton) : void
      {
         this.m_bottomHudCasablancaInnovationButton = bottomHud;
      }
      
      public function setBottomAnimalSanctuaryV2Button(bottomHud:HudBottomAnimalSanctuaryV2) : void
      {
         this.m_bottomHudAnimalSanctuaryV2Button = bottomHud;
      }
      
      public function setBottomHudRussiaInnovationButton(bottomHud:HudBottomRussiaInnovationButton) : void
      {
         this.m_bottomHudRussiaInnovationButton = bottomHud;
      }
      
      public function setBottomHudIsraelInnovationButton(bottomHud:HudBottomIsraelInnovationButton) : void
      {
         this.m_bottomHudIsraelInnovationButton = bottomHud;
      }
      
      public function setUpHudGuildCreationButton(upHud:HudGuildCreationButton) : void
      {
         this.m_upHudGuildCreationButton = upHud;
         this.m_topRightContainer.addChild(this.m_upHudGuildCreationButton);
      }
      
      public function setBottomHudWinternordInnovationButton(bottomHud:HudBottomWinternordInnovationButton) : void
      {
         this.m_bottomHudWinternordInnovationButton = bottomHud;
      }
      
      public function setBottomHudTwentiesInnovationButton(bottomHud:HudBottomTwentiesInnovationButton) : void
      {
         this.m_bottomHudTwentiesInnovationButton = bottomHud;
      }
      
      public function setBottomHudPumpkinPartyInnovationButton(bottomHud:HudBottomPumpkinPartyInnovationButton) : void
      {
         this.m_bottomHudPumpkinPartyInnovationButton = bottomHud;
      }
      
      public function setBottomHudCocowonderlandInnovationButton(bottomHud:HudBottomCocowonderlandInnovationButton) : void
      {
         this.m_bottomHudCocowonderlandInnovationButton = bottomHud;
      }
      
      public function setBottomHudSouthindiaInnovationButton(bottomHud:HudBottomSouthindiaInnovationButton) : void
      {
         this.m_bottomHudSouthindiaInnovationButton = bottomHud;
      }
      
      public function setBottomHudDec19InnovationButton(bottomHud:HudBottomDec19InnovationButton) : void
      {
         this.m_bottomHudDec19InnovationButton = bottomHud;
      }
      
      public function setBottomHudIrelandInnovationButton(bottomHud:HudBottomIrelandInnovationButton) : void
      {
         this.m_bottomHudIrelandInnovationButton = bottomHud;
      }
      
      public function setBottomHudFarmersMarketInnovationButton(bottomHud:HudFarmersMarketInnovationButton) : void
      {
         this.m_bottomHudFarmersMarket2020InnovationButton = bottomHud;
      }
      
      public function setBottomHudTropicalMarketInnovationButton(bottomHud:HudTropicalMarketInnovationButton) : void
      {
         this.m_bottomHudTropicalMarketInnovationButton = bottomHud;
      }
      
      public function setBottomHudBoraBoraInnovationButton(bottomHud:HudBoraBoraInnovationButton) : void
      {
         this.m_bottomHudBoraBoraInnovationButton = bottomHud;
      }
      
      public function setBottomHudFrontierInnovationButton(bottomHud:HudBottomFrontierInnovationButton) : void
      {
         this.m_bottomHudFrontierInnovationButton = bottomHud;
      }
      
      public function setBottomHudHalloweenInnovationGhoulButton(bottomHud:HudBottomHalloweenInnovationGhoulButton) : void
      {
         this.m_bottomHudHalloweenInnovationGhoulButton = bottomHud;
      }
      
      public function setBottomHudHalloweenInnovation2019Button(bottomHud:HudBottomHalloweenInnovation2019Button) : void
      {
         this.m_bottomHudHalloweenInnovation2019Button = bottomHud;
      }
      
      public function setBottomHudJumbleVillaButton(bottomHud:HudBottomJumbleVillaButton) : void
      {
         this.m_bottomHudJumbleVillaButton = bottomHud;
      }
      
      public function setBottomHudLEBundleButton(bottomHud:HudBottomLEBundleButton) : void
      {
         this.m_bottomHudLEBundleButton = bottomHud;
      }
      
      public function setBottomHudFVTECurrencyButton(bottomHud:HudBottomFVTECurrencyConversionButton) : void
      {
         this.m_bottomFVTEButton = bottomHud;
      }
      
      public function setBottomHudFvPluginButton(bottomHud:HudBottomFvPluginButton) : void
      {
         this.m_bottomHudFvPluginButton = bottomHud;
      }
      
      public function setBottomHudBookmarkOptButton(bottomHud:HudBottomBookmarkOptButton) : void
      {
         this.m_bottomHudBookmarkOptButton = bottomHud;
      }
      
      public function setHudBookmarkButton(bottomHud:HudBookMarkButton) : void
      {
         this.m_hudBookmarkOptButton = bottomHud;
         this.m_topRightContainer.addChild(this.m_hudBookmarkOptButton);
      }
      
      public function setMessageNotificationHud(bottomHud:HudMessageNotification) : void
      {
         this.m_MessageNotification = bottomHud;
      }
      
      public function getMessageNotificationHud() : HudMessageNotification
      {
         return this.m_MessageNotification;
      }
      
      public function setHudLandBundle(hud:HudLandBundle) : void
      {
         this.m_HudLandBundle = hud;
      }
      
      public function setHudLandBundleUnlockFeature(hud:HudBottomLandBundleUnlockFeature) : void
      {
         this.m_bottomHudLandBundleUnlockFeature = hud;
      }
      
      public function setHudWinterRacingFeature(hud:HudBottomWinterRacingFeature) : void
      {
         this.m_bottomHudWinterRacingFeature = hud;
      }
      
      public function setHuBoatRushFeature(hud:HudBottomBoatRush) : void
      {
         this.m_bottomHuBoatRushFeature = hud;
      }
      
      public function setBottomHudShowAnimalsButton(bottomHud:HudBottomShowAnimalsButton) : void
      {
         this.m_bottomHudShowAnimals.push(bottomHud);
      }
      
      public function setBottomHudMadagascarInnovationButton(bottomHud:HudBottomMadagascarInnovationButton) : void
      {
         this.m_bottomHudMadagascarInnovationButton = bottomHud;
      }
      
      public function setBottomHudOctoberSidecarFeatureButton(bottomHud:HudBottomOctoberSidecarFeature) : void
      {
         this.m_bottomHudOctoberSidecarFeatureButton = bottomHud;
      }
      
      public function setBottomHudCanadaInnovationButton(bottomHud:HudBottomCanadaInnovationButton) : void
      {
         this.m_bottomHudCanadaInnovationButton = bottomHud;
      }
      
      public function setBottomHudAmsterdamInnovationButton(bottomHud:HudBottomAmsterdamInnovationButton) : void
      {
         this.m_bottomHudAmsterdamInnovationButton = bottomHud;
      }
      
      public function setBottomWreathFestivalInnovationButton(bottomHud:HudBottomWreathFestivalInnovationButton) : void
      {
         this.m_bottomHudWreathFestivalInnovationButton = bottomHud;
      }
      
      public function removeBottomHudBrazilInnovationButton() : void
      {
         if(this.m_bottomHudBrazilInnovationButton)
         {
            this.m_bottomHudBrazilInnovationButton.release();
            this.m_bottomHudBrazilInnovationButton = null;
         }
      }
      
      public function removeBottomHudDragonvaleyInnovationButton() : void
      {
         if(this.m_bottomHudDargonvalleyInnovationButton)
         {
            this.m_bottomHudDargonvalleyInnovationButton.release();
            this.m_bottomHudDargonvalleyInnovationButton = null;
         }
      }
      
      public function removeBottomHudRussiaInnovationButton() : void
      {
         if(this.m_bottomHudRussiaInnovationButton)
         {
            this.m_bottomHudRussiaInnovationButton.release();
            this.m_bottomHudRussiaInnovationButton = null;
         }
      }
      
      public function removeBottomHudIsraelInnovationButton() : void
      {
         if(this.m_bottomHudIsraelInnovationButton)
         {
            this.m_bottomHudIsraelInnovationButton.release();
            this.m_bottomHudIsraelInnovationButton = null;
         }
      }
      
      public function removeBottomHudWinternordInnovationButton() : void
      {
         if(this.m_bottomHudWinternordInnovationButton)
         {
            this.m_bottomHudWinternordInnovationButton.release();
            this.m_bottomHudWinternordInnovationButton = null;
         }
      }
      
      public function removeBottomHudCocowonderlandInnovationButton() : void
      {
         if(this.m_bottomHudCocowonderlandInnovationButton)
         {
            this.m_bottomHudCocowonderlandInnovationButton.release();
            this.m_bottomHudCocowonderlandInnovationButton = null;
         }
      }
      
      public function removeBottomHudTwentiesInnovationButton() : void
      {
         if(this.m_bottomHudTwentiesInnovationButton)
         {
            this.m_bottomHudTwentiesInnovationButton.release();
            this.m_bottomHudTwentiesInnovationButton = null;
         }
      }
      
      public function removeBottomHudPumpkinPartyInnovationButton() : void
      {
         if(this.m_bottomHudPumpkinPartyInnovationButton)
         {
            this.m_bottomHudPumpkinPartyInnovationButton.release();
            this.m_bottomHudPumpkinPartyInnovationButton = null;
         }
      }
      
      public function removeBottomHudSouthindiaInnovationButton() : void
      {
         if(this.m_bottomHudSouthindiaInnovationButton)
         {
            this.m_bottomHudSouthindiaInnovationButton.release();
            this.m_bottomHudSouthindiaInnovationButton = null;
         }
      }
      
      public function removeBottomHudDec19InnovationButton() : void
      {
         if(this.m_bottomHudDec19InnovationButton)
         {
            this.m_bottomHudDec19InnovationButton.release();
            this.m_bottomHudDec19InnovationButton = null;
         }
      }
      
      public function removeBottomHudIrelandInnovationButton() : void
      {
         if(this.m_bottomHudIrelandInnovationButton)
         {
            this.m_bottomHudIrelandInnovationButton.release();
            this.m_bottomHudIrelandInnovationButton = null;
         }
      }
      
      public function removeBottomHudFarmersMarketInnovationButton() : void
      {
         if(this.m_bottomHudFarmersMarket2020InnovationButton)
         {
            this.m_bottomHudFarmersMarket2020InnovationButton.release();
            this.m_bottomHudFarmersMarket2020InnovationButton = null;
         }
      }
      
      public function removeBottomHudTropicalMarketInnovationButton() : void
      {
         if(this.m_bottomHudTropicalMarketInnovationButton)
         {
            this.m_bottomHudTropicalMarketInnovationButton.release();
            this.m_bottomHudTropicalMarketInnovationButton = null;
         }
      }
      
      public function removeBottomHudAmsterdamInnovationButton() : void
      {
         if(this.m_bottomHudAmsterdamInnovationButton)
         {
            this.m_bottomHudAmsterdamInnovationButton.release();
            this.m_bottomHudAmsterdamInnovationButton = null;
         }
      }
      
      public function removeBottomHudWreathFestivalInnovationButton() : void
      {
         if(this.m_bottomHudWreathFestivalInnovationButton)
         {
            this.m_bottomHudWreathFestivalInnovationButton.release();
            this.m_bottomHudWreathFestivalInnovationButton = null;
         }
      }
      
      public function removeBottomHudBoraBoraInnovationButton() : void
      {
         if(this.m_bottomHudBoraBoraInnovationButton)
         {
            this.m_bottomHudBoraBoraInnovationButton.release();
            this.m_bottomHudBoraBoraInnovationButton = null;
         }
      }
      
      public function removeBottomHudLandBundleUnlockFeatureButton() : void
      {
         if(this.m_bottomHudLandBundleUnlockFeature)
         {
            this.m_bottomHudLandBundleUnlockFeature.release();
            this.m_bottomHudLandBundleUnlockFeature = null;
         }
      }
      
      public function removeBottomHudFrontierInnovationButton() : void
      {
         if(this.m_bottomHudFrontierInnovationButton)
         {
            this.m_bottomHudFrontierInnovationButton.release();
            this.m_bottomHudFrontierInnovationButton = null;
         }
      }
      
      public function removeBottomHudHalloweenInnovationGhoulButton() : void
      {
         if(this.m_bottomHudHalloweenInnovationGhoulButton)
         {
            this.m_bottomHudHalloweenInnovationGhoulButton.release();
            this.m_bottomHudHalloweenInnovationGhoulButton = null;
         }
      }
      
      public function removeBottomHudHalloweenInnovation2019Button() : void
      {
         if(this.m_bottomHudHalloweenInnovation2019Button)
         {
            this.m_bottomHudHalloweenInnovation2019Button.release();
            this.m_bottomHudHalloweenInnovation2019Button = null;
         }
      }
      
      public function removesetHudWinterRacingFeature() : void
      {
         if(this.m_bottomHudWinterRacingFeature)
         {
            this.m_bottomHudWinterRacingFeature.release();
            this.m_bottomHudWinterRacingFeature = null;
         }
      }
      
      public function removesetHudBoatRushFeature() : void
      {
         if(this.m_bottomHuBoatRushFeature)
         {
            this.m_bottomHuBoatRushFeature.release();
            this.m_bottomHuBoatRushFeature = null;
         }
      }
      
      public function removeBottomHudJumbleVillaButton() : void
      {
         if(this.m_bottomHudJumbleVillaButton)
         {
            this.m_bottomHudJumbleVillaButton.release();
            this.m_bottomHudJumbleVillaButton = null;
         }
      }
      
      public function removeBottomHudLEBundle() : void
      {
         if(this.m_bottomHudLEBundleButton)
         {
            this.m_bottomHudLEBundleButton.release();
            this.m_bottomHudLEBundleButton = null;
         }
      }
      
      public function removeBottomHudFvPlugin() : void
      {
         if(this.m_bottomHudFvPluginButton)
         {
            this.m_bottomHudFvPluginButton.release();
            this.m_bottomHudFvPluginButton = null;
         }
      }
      
      public function removeBottomHudBookmarkOpt() : void
      {
         if(this.m_bottomHudBookmarkOptButton)
         {
            this.m_bottomHudBookmarkOptButton.release();
            this.m_bottomHudBookmarkOptButton = null;
         }
      }
      
      public function removeHudBookmarkOpt() : void
      {
         if(this.m_hudBookmarkOptButton)
         {
            this.m_hudBookmarkOptButton.releaseHud();
            this.m_hudBookmarkOptButton = null;
         }
      }
      
      public function removeBottomHudCarribeanInnovationButton() : void
      {
         if(this.m_bottomHudCarribeanInnovationButton)
         {
            this.m_bottomHudCarribeanInnovationButton.release();
            this.m_bottomHudCarribeanInnovationButton = null;
         }
      }
      
      public function removeBottomHudCasablancaInnovationButton() : void
      {
         if(this.m_bottomHudCasablancaInnovationButton)
         {
            this.m_bottomHudCasablancaInnovationButton.release();
            this.m_bottomHudCasablancaInnovationButton = null;
         }
      }
      
      public function removeBottomHudAnimalSanctuaryV2Button() : void
      {
         if(this.m_bottomHudAnimalSanctuaryV2Button)
         {
            this.m_bottomHudAnimalSanctuaryV2Button.release();
            this.m_bottomHudAnimalSanctuaryV2Button = null;
         }
      }
      
      public function removeBottomHudOctoberSidecarFeatureButton() : void
      {
         if(this.m_bottomHudOctoberSidecarFeatureButton)
         {
            this.m_bottomHudOctoberSidecarFeatureButton.release();
            this.m_bottomHudOctoberSidecarFeatureButton = null;
         }
      }
      
      public function removeHudLandBundle() : void
      {
         if(this.m_HudLandBundle)
         {
            this.m_HudLandBundle.release();
            this.m_HudLandBundle = null;
         }
      }
      
      public function removeFVTECurrencyHud() : void
      {
         if(this.m_bottomFVTEButton)
         {
            this.m_bottomFVTEButton.release();
            this.m_bottomFVTEButton = null;
         }
      }
      
      public function removeBottomHudAchievementButton() : void
      {
         if(this.m_bottomHudAchievement)
         {
            this.m_bottomHudAchievement.release();
            this.m_bottomHudAchievement = null;
         }
      }
      
      public function removeBottomHudGenericButton() : void
      {
         if(this.m_bottomHudGenericButton)
         {
            this.m_bottomHudGenericButton.release();
            this.m_bottomHudGenericButton = null;
         }
      }
      
      public function removeBottomHudJournalButton() : void
      {
         if(this.m_buttomHudJournal)
         {
            this.m_buttomHudJournal.release();
            this.m_buttomHudJournal = null;
         }
      }
      
      public function removeBottomHudShowAnimalsButton() : void
      {
         var i:int = 0;
         if(Boolean(this.m_bottomHudShowAnimals) && this.m_bottomHudShowAnimals.length > 0)
         {
            for(i = 0; i < this.m_bottomHudShowAnimals.length; i++)
            {
               this.m_bottomHudShowAnimals[i].release();
            }
            this.m_bottomHudShowAnimals = new Array();
         }
      }
      
      public function removeBottomHudMadagascarInnovationButton() : void
      {
         if(this.m_bottomHudMadagascarInnovationButton)
         {
            this.m_bottomHudMadagascarInnovationButton.release();
            this.m_bottomHudMadagascarInnovationButton = null;
         }
      }
      
      public function removeBottomHudCanadaInnovationButton() : void
      {
         if(this.m_bottomHudCanadaInnovationButton)
         {
            this.m_bottomHudCanadaInnovationButton.release();
            this.m_bottomHudCanadaInnovationButton = null;
         }
      }
      
      public function setFishingDerbyTackleBox(tackleBox:HUDFishingDerbyWidget) : void
      {
         this.m_fishingDerbyTackleBox = tackleBox;
      }
      
      public function get fishingDerbyTackleBox() : HUDFishingDerbyWidget
      {
         return this.m_fishingDerbyTackleBox;
      }
      
      public function get homeButtonWidget() : HUDHomeWidget
      {
         return this.m_homeButton;
      }
      
      public function get zoomWidget() : HUDZoomWidget
      {
         return this.m_zoomWidget;
      }
      
      public function setHomeWidget(homeWidget:HUDHomeWidget) : void
      {
         this.m_homeButton = homeWidget;
      }
      
      public function setZoomWidget(zoomWidget:HUDZoomWidget) : void
      {
         this.m_zoomWidget = zoomWidget;
      }
      
      public function setNeighborSearchBarVisibility(visible:Boolean) : void
      {
         if(this.m_neighborSearch)
         {
            this.m_neighborSearch.visible = visible;
         }
      }
      
      public function setFuelIconVisibility(visible:Boolean) : void
      {
         if(this.m_energySprite)
         {
            this.m_energySprite.visible = visible;
         }
      }
      
      public function postExperimentsLoadedInit() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_NEIGHBOR_SEARCH) >= 2)
         {
            this.m_neighborSearch = new NeighborBarSearch();
            addChild(this.m_neighborSearch);
         }
         if(ChatManager.instance.isFarmTalkEnabled())
         {
            this.m_chatNotification = new ChatMessageNotification();
            addChild(this.m_chatNotification);
         }
      }
      
      public function addSubscriptionsHUDWidget() : void
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_COINS_SUBSCRIPTIONS) == 3)
         {
            this.m_fvCashTxt.visible = false;
            this.m_fvCashDisplay.visible = false;
            this.m_subscriptionsWidget = new HUDSubscriptionsWidget(this);
         }
      }
      
      private function setAltGraphicIcon(altGraphicName:String) : void
      {
         this.m_altGraphicIcon = new FarmGameSprite();
         this.m_altGraphicIcon.buttonMode = true;
         this.m_altGraphicIcon.useHandCursor = false;
         Utilities.toggleInputOnlyChildren(this.m_altGraphicIcon,false);
         this.m_altGraphicIcon.toolTip = ZLocUtils.hasString("FarmGame","AltGraphicTooltip_" + altGraphicName) ? ZLocUtils.t("FarmGame","AltGraphicTooltip_" + altGraphicName) : "";
         this.m_altGraphicIcon.x = 0;
         this.m_altGraphicIcon.y = 630;
         this.m_altGraphicIcon.scaleX = this.m_altGraphicIcon.scaleY = 1;
         this.m_altGraphicIcon.normalScale = 1;
         this.m_altGraphicIcon.rollOverScale = 1.15;
         var m_altImage:Bitmap = new EmbeddedArt.FV_Lights_Button_On();
         this.m_altGraphicIcon.addChild(m_altImage);
         this.m_altGraphicIcon.visible = true;
         this.m_altGraphicIcon.addEventListener(MouseEvent.CLICK,this.onLightAndSnow);
         addChild(this.m_altGraphicIcon);
         var graphicTextFormat:TextFormat = new TextFormat();
         graphicTextFormat.font = "Merkin2";
         graphicTextFormat.size = 14;
         graphicTextFormat.color = 15534960;
         this.m_altGraphicText = new TextField();
         this.m_altGraphicText.selectable = false;
         this.m_altGraphicText.autoSize = TextFieldAutoSize.LEFT;
         this.m_altGraphicText.embedFonts = true;
         this.m_altGraphicText.defaultTextFormat = graphicTextFormat;
         this.m_altGraphicText.setTextFormat(graphicTextFormat);
         this.m_altGraphicText.x = 25;
         this.m_altGraphicText.y = 675;
         this.m_altGraphicText.visible = false;
      }
      
      public function updateSeedingQueue(delta:int, seedType:String) : void
      {
         var lastHarvestPromptShownTime:Number = NaN;
         var tGetFarmHarvestEmailPref:TGetHarvestEmailPref = null;
         this.m_seedingQueued += delta;
         if(delta > 0)
         {
            this.m_totalSeedsPlanted += delta;
            if(!this.m_seedTypesPlanted[seedType])
            {
               this.m_seedTypesPlanted[seedType] = 0;
            }
            this.m_seedTypesPlanted[seedType] += delta;
            if(!this.m_hasLoggedFieldPlantedEvent[seedType] && this.m_seedTypesPlanted[seedType] >= this.m_minSeededPlotsActivity)
            {
               TransactionManager.addTransaction(new TFieldPlantedEvent(seedType));
               this.m_hasLoggedFieldPlantedEvent[seedType] = true;
            }
         }
         if(this.m_seedingQueued <= 0 && this.m_totalSeedsPlanted >= this.m_minSeededPlots)
         {
            lastHarvestPromptShownTime = Global.player.getFeatureLastShown(HARVEST_EMAIL_OPT_IN_FEATURE);
            if(Global.experimentManager.getExperimentVariant(HelpingHandsWindow.EXPERIMENT_NAME) > 0 && Global.experimentManager.getExperimentVariant(HelpingHandsWindow.EXPERIMENT_NAME) < 9 && Global.player.getSeenFlag(HelpingHandsWindow.SEEN_FLAG_NAME) == false && Global.player.getSeenSessionFlag(HelpingHandsWindow.SEEN_FLAG_NAME) == false)
            {
               Global.popupManager.addInactiveUserPopup(new HelpingHandsWindow(),"",false,true);
               Global.player.setSeenSessionFlag(HelpingHandsWindow.SEEN_FLAG_NAME);
            }
            else if(!this.m_harvestEmailTransactionAdded && Global.experimentManager.getExperimentVariant(HARVEST_EMAIL_OPT_IN_FEATURE) == 1 && GlobalEngine.socialNetwork.userHasEmailPermission() && GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND > lastHarvestPromptShownTime + NUMBER_OF_DAYS_BEFORE_HARVEST_OPT_IN_POP * FarmGameUtil.NUM_SECS_IN_DAY)
            {
               tGetFarmHarvestEmailPref = new TGetHarvestEmailPref();
               tGetFarmHarvestEmailPref.addEventListener(TransactionEvent.COMPLETED,this.onGetHarvestEmailPref);
               TransactionManager.addTransaction(tGetFarmHarvestEmailPref);
               this.m_harvestEmailTransactionAdded = true;
            }
         }
         if(this.m_seedingQueued <= 0)
         {
            this.checkForPlantFeedPrompt();
         }
      }
      
      public function toggleMessageSignEnable(isShown:Boolean = true) : void
      {
         if(this.m_messageSignButton)
         {
            this.m_messageSignButton.visible = isShown;
         }
         this.m_isMessageButtonVisible = isShown;
      }
      
      private function onGetHarvestEmailPref(event:TransactionEvent) : void
      {
         var message:String = null;
         var harvestPopup:GenericPopup = null;
         var currentTime:Number = NaN;
         event.target.removeEventListener(event.type,arguments.callee);
         if(!TGetHarvestEmailPref(event.target).canSendHarvestEmail)
         {
            message = ZLocUtils.t("Dialogs","EmailPermission_Prompt_Harvest");
            harvestPopup = new GenericPopup(message,GenericPopup.TYPE_YESNO,this.onEmailHarvestPopupClosed,GenericPopup.GENERIC_ASSET,"",true);
            harvestPopup.setAcceptTextName("Yes");
            harvestPopup.setCancelTextName("Cancel");
            UI.displayPopup(harvestPopup);
            FarmStatsManager.count("emailPreferences","harvestReminderEmail","promptImpressions");
            currentTime = GlobalEngine.serverTime / 1000;
            Global.player.setFeatureLastShown(HARVEST_EMAIL_OPT_IN_FEATURE,currentTime,true);
         }
      }
      
      private function onEmailHarvestPopupClosed(evt:GenericPopupEvent) : void
      {
         var thanksMessage:String = null;
         var gp:GenericPopup = null;
         evt.target.removeEventListener(evt.type,arguments.callee);
         if(evt.button == GenericPopup.YES)
         {
            TransactionManager.addTransaction(new TSetEmailPref("harvestReminderEmail","instantly"),false);
            thanksMessage = ZLocUtils.t("Dialogs","EmailPermission_Prompt_HarvestThanks");
            gp = new GenericPopup(thanksMessage,GenericPopup.TYPE_OK,null,GenericPopup.GENERIC_ASSET,"",true);
            gp.setAcceptTextName("Okay");
            UI.displayPopup(gp);
            FarmStatsManager.count("emailPreferences","harvestReminderEmail","optIn");
         }
         else
         {
            FarmStatsManager.count("emailPreferences","harvestReminderEmail","optOut");
         }
      }
      
      public function flashFuelBar(numFlashes:Number = 2, duration:Number = 0.7) : void
      {
         this.m_energyFlash.visible = true;
         if(numFlashes > 0)
         {
            TweenLite.to(this.m_energyFlash,duration,{
               "alpha":1,
               "onComplete":this.fuelFlashTweendown,
               "onCompleteParams":[numFlashes - 1,duration]
            });
         }
         else
         {
            this.m_energyFlash.visible = false;
         }
      }
      
      public function get cropBoostIcon() : CropBoostIcon
      {
         return this.m_cropBuffIconSprite;
      }
      
      private function fuelFlashTweendown(numFlashes:Number, duration:Number = 1) : void
      {
         TweenLite.to(this.m_energyFlash,duration,{
            "alpha":0.1,
            "onComplete":this.flashFuelBar,
            "onCompleteParams":[numFlashes,duration]
         });
      }
      
      private function checkForPlantFeedPrompt() : void
      {
         var itemName:String = null;
         var plantedItem:FarmItem = null;
         var doesSeedPromptFeed:Boolean = false;
         var isMinSeedsPlanted:Boolean = false;
         var bundleName:String = null;
         var promptText:String = null;
         for(itemName in this.m_seedTypesPlanted)
         {
            plantedItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            doesSeedPromptFeed = false;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               doesSeedPromptFeed = plantedItem.getBoolFromDataSource("promptFeedOnPlant");
            }
            else
            {
               doesSeedPromptFeed = Boolean(plantedItem.xml.@promptFeedOnPlant) && plantedItem.xml.@promptFeedOnPlant.toString() == "true";
            }
            isMinSeedsPlanted = this.m_seedTypesPlanted[itemName] >= this.m_minSeededPlots;
            bundleName = this.getPlantFeedBundleName(itemName);
            if(doesSeedPromptFeed && isMinSeedsPlanted && !Global.player.getSeenSessionFlag(bundleName))
            {
               this.m_plantFeedItem = plantedItem;
               Global.player.setSeenSessionFlag(bundleName);
               promptText = ZLocUtils.t("Notifications",bundleName + "_ShortStory_UserMessagePrompt");
               UI.displayMessage(promptText,GenericPopup.TYPE_SHARECANCEL,this.onPlantFeedPromptClose);
            }
         }
      }
      
      private function onPlantFeedPromptClose(event:GenericPopupEvent) : void
      {
         var images:Array = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            images = [{
               "src":this.m_plantFeedItem.getImageByName("icon"),
               "href":"{SN_APP_URL}{creative:plant}index.php"
            }];
            bundleData = {"images":images};
            GlobalEngine.socialNetwork.publishFeedStory(this.getPlantFeedBundleName(this.m_plantFeedItem.name),bundleData,[],false);
         }
      }
      
      protected function onEnergyPopup(e:MouseEvent) : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","FuelIcon_Help"),GenericPopup.TYPE_OK);
      }
      
      private function getPlantFeedBundleName(seedType:String) : String
      {
         return "Plant_" + seedType;
      }
      
      private function onFinishCommentBoxEmailPermissions() : void
      {
         var m_messageCenter:MessageCenterDialog = null;
         if(GlobalEngine.socialNetwork.userHasEmailPermission())
         {
            m_messageCenter = new MessageCenterDialog();
            UI.displayPopup(m_messageCenter);
         }
      }
      
      protected function onToiletPaperAttempt(event:MouseEvent = null) : void
      {
         if(this.canTP())
         {
            FarmStatsManager.count("toiletpaper","enter_tp_mode");
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","ToiletPaperAreYouSure"),GenericPopup.TYPE_YESNO,this.onToiletPaperUse));
         }
         else
         {
            FarmStatsManager.count("toiletpaper","paper_friend_fail");
            UI.displayMessage(ZLocUtils.t("Dialogs","ToiletPaperNoTarget"));
         }
      }
      
      private function canTP() : Boolean
      {
         var mapObject:Building = null;
         var result:Boolean = false;
         var objects:Array = Global.world.getObjects();
         for(var objectIdx:int = 0; objectIdx < objects.length; objectIdx++)
         {
            mapObject = objects[objectIdx] as Building;
            if(mapObject != null && mapObject.isValidOverlayTarget("tp"))
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      protected function onToiletPaperUse(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && this.m_visit)
         {
            Global.world.addGameMode(new GMSetOverlayGraphic("tp"));
         }
      }
      
      protected function onLightAndSnow(event:Event) : void
      {
         if(!this.m_visit)
         {
            Global.world.addGameMode(new GMSetAltGraphic("lights"));
         }
      }
      
      public function setLightIcon() : void
      {
         var doit:Boolean = false;
         if(!this.m_altGraphicIcon.visible && doit)
         {
            this.m_altGraphicIcon.visible = true;
            addChild(this.m_altGraphicIcon);
         }
         else if(this.m_altGraphicIcon.visible && !doit)
         {
            this.m_altGraphicIcon.visible = false;
            this.m_altGraphicText.visible = false;
            if(contains(this.m_altGraphicIcon))
            {
               removeChild(this.m_altGraphicIcon);
            }
            if(contains(this.m_altGraphicText))
            {
               removeChild(this.m_altGraphicText);
            }
         }
         else if(this.m_altGraphicText.visible && Global.player.hasUnlimitedCredits("lights") && contains(this.m_altGraphicText))
         {
            this.m_altGraphicText.visible = false;
            removeChild(this.m_altGraphicText);
         }
         if(!this.m_altGraphicText.visible && doit)
         {
            if(!Global.player.hasUnlimitedCredits("lights") && Global.player.numAltGraphicCredits("lights") > 0)
            {
               this.m_altGraphicText.visible = true;
               addChild(this.m_altGraphicText);
            }
         }
         this.m_altGraphicText.text = Global.player.numAltGraphicCredits("lights").toString();
      }
      
      public function update() : void
      {
         this.m_iconQueue.update();
         this.m_visitIconQueue.update();
         this.m_rightSideIconQueue.update();
         this.conditionallyRefreshHUD();
      }
      
      public function conditionallyRefreshHUD(force:Boolean = false) : void
      {
         var fuelTankHeightOffset:int = 0;
         var cropBuffOffset:int = 0;
         var cropBuffOffsetX:int = 0;
         var lightsOffset:int = 0;
         var lightsTextOffset:int = 0;
         var unwitherOffset:int = 0;
         var unwitherTextOffset:int = 0;
         var xpMetersCenter:Number = NaN;
         var scoreUnit:String = null;
         var score2Unit:String = null;
         var harvestHelperX:Number = NaN;
         var harvestHelperY:Number = NaN;
         var num:String = null;
         var currentWorldCurrencyType:String = null;
         var i:int = 0;
         var barWidth:int = 0;
         var tankCount:Number = NaN;
         var remainder:int = 0;
         var energyPct:Number = NaN;
         var ftueIsActive:Boolean = false;
         var tankString:String = null;
         var FV_Main_Fuel_Gauge:Class = null;
         var FV_Main_Fuel_Free_Fuel:Class = null;
         var text:String = null;
         var currentDay:int = 0;
         if(this.m_dirty || force)
         {
            fuelTankHeightOffset = 150;
            cropBuffOffset = 205;
            cropBuffOffsetX = 137;
            lightsOffset = 220;
            lightsTextOffset = 175;
            unwitherOffset = 220;
            unwitherTextOffset = 190;
            if(this.m_currencyMeter)
            {
               num = Utilities.formatNumber(this.currentWorldCurrencyAmount);
               currentWorldCurrencyType = Global.worldManager.getCurrentHudCurrencyUnit();
               this.m_currencyMeter.toolTip = ZLocUtils.t("FarmGame","Gold_ToolTip",{
                  "quantity":num,
                  "currency":ZLocUtils.t("FarmGame",currentWorldCurrencyType)
               });
            }
            if(this.m_waterHudButton)
            {
               this.m_waterHudButton.refresh();
            }
            if(this.m_loyaltyProgramButton)
            {
               this.m_loyaltyProgramButton.refresh();
            }
            this.m_topRightContainer.x = GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH;
            this.m_rightSideIconQueue.x = GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH + 720;
            xpMetersCenter = GlobalEngine.stage.stageWidth / 2 + 10;
            scoreUnit = Global.worldManager.currentWorldScoreId;
            score2Unit = Global.worldManager.currentWorldScore2Id;
            harvestHelperX = 0;
            harvestHelperY = 0;
            if(Boolean(this.m_worldScoreMeter) && scoreUnit != "")
            {
               if(this.m_worldScoreMeter.scoreUnit == scoreUnit)
               {
                  this.m_worldScoreMeter.level = Global.player.getWorldLevel(scoreUnit);
                  this.m_worldScoreMeter.xp = Global.player.getWorldScore(scoreUnit);
                  this.m_worldScoreMeter.x = xpMetersCenter - this.m_worldScoreMeter.width - HUD.XP_METER_PADDING / 2;
                  this.m_xpMeter.x = xpMetersCenter + HUD.XP_METER_PADDING / 2;
                  harvestHelperX = this.m_worldScoreMeter.x + 30;
                  harvestHelperY = this.m_worldScoreMeter.y;
               }
            }
            else
            {
               this.m_xpMeter.x = xpMetersCenter - this.m_xpMeter.width / 2;
               harvestHelperX = this.m_xpMeter.x + 35;
               harvestHelperY = this.m_xpMeter.y;
            }
            if(Boolean(this.m_worldScore2Meter) && score2Unit != "")
            {
               if(this.m_worldScore2Meter.scoreUnit == score2Unit)
               {
                  this.m_worldScore2Meter.level = Global.player.getWorldLevel(score2Unit);
                  this.m_worldScore2Meter.xp = Global.player.getWorldScore(score2Unit);
                  this.m_worldScore2Meter.x = xpMetersCenter + this.m_worldScore2Meter.width + HUD.XP_METER_PADDING / 2;
               }
            }
            if(this.m_harvestHelperHudIcon)
            {
               this.m_harvestHelperHudIcon.adjustPosition(harvestHelperX,harvestHelperY);
            }
            if(this.m_fishingDerbyTackleBox)
            {
               this.m_fishingDerbyTackleBox.setX(GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH + 500);
            }
            if(this.m_bottomHudTutorial)
            {
               this.m_bottomHudTutorial.setXY();
            }
            if(this.m_bottomHudGenericButton)
            {
               this.m_bottomHudGenericButton.setXY();
            }
            if(this.m_HudLoyaltyRoyaltyButton)
            {
               this.m_HudLoyaltyRoyaltyButton.setXY();
            }
            if(this.m_bottomHudAchievement)
            {
               this.m_bottomHudAchievement.setXY();
            }
            if(this.m_buttomHudJournal)
            {
               this.m_buttomHudJournal.setXY();
            }
            if(this.m_bottomHudBrazilInnovationButton)
            {
               this.m_bottomHudBrazilInnovationButton.setXY();
            }
            if(this.m_bottomHudDargonvalleyInnovationButton)
            {
               this.m_bottomHudDargonvalleyInnovationButton.setXY();
            }
            if(this.m_bottomHudCarribeanInnovationButton)
            {
               this.m_bottomHudCarribeanInnovationButton.setXY();
            }
            if(this.m_bottomHudCasablancaInnovationButton)
            {
               this.m_bottomHudCasablancaInnovationButton.setXY();
            }
            if(this.m_bottomHudRussiaInnovationButton)
            {
               this.m_bottomHudRussiaInnovationButton.setXY();
            }
            if(this.m_bottomHudIsraelInnovationButton)
            {
               this.m_bottomHudIsraelInnovationButton.setXY();
            }
            if(this.m_bottomHudFrontierInnovationButton)
            {
               this.m_bottomHudFrontierInnovationButton.setXY();
            }
            if(this.m_bottomHudHalloweenInnovationGhoulButton)
            {
               this.m_bottomHudHalloweenInnovationGhoulButton.setXY();
            }
            if(this.m_bottomHudHalloweenInnovation2019Button)
            {
               this.m_bottomHudHalloweenInnovation2019Button.setXY();
            }
            if(this.m_bottomHudWinterRacingFeature)
            {
               this.m_bottomHudWinterRacingFeature.setXY();
            }
            if(this.m_bottomHuBoatRushFeature)
            {
               this.m_bottomHuBoatRushFeature.setXY();
            }
            if(this.m_bottomHudWinternordInnovationButton)
            {
               this.m_bottomHudWinternordInnovationButton.setXY();
            }
            if(this.m_bottomHudCocowonderlandInnovationButton)
            {
               this.m_bottomHudCocowonderlandInnovationButton.setXY();
            }
            if(this.m_bottomHudTwentiesInnovationButton)
            {
               this.m_bottomHudTwentiesInnovationButton.setXY();
            }
            if(this.m_bottomHudPumpkinPartyInnovationButton)
            {
               this.m_bottomHudPumpkinPartyInnovationButton.setXY();
            }
            if(this.m_bottomHudSouthindiaInnovationButton)
            {
               this.m_bottomHudSouthindiaInnovationButton.setXY();
            }
            if(this.m_bottomHudDec19InnovationButton)
            {
               this.m_bottomHudDec19InnovationButton.setXY();
            }
            if(this.m_bottomHudIrelandInnovationButton)
            {
               this.m_bottomHudIrelandInnovationButton.setXY();
            }
            if(this.m_bottomHudFarmersMarket2020InnovationButton)
            {
               this.m_bottomHudFarmersMarket2020InnovationButton.setXY();
            }
            if(this.m_bottomHudTropicalMarketInnovationButton)
            {
               this.m_bottomHudTropicalMarketInnovationButton.setXY();
            }
            if(this.m_bottomHudAmsterdamInnovationButton)
            {
               this.m_bottomHudAmsterdamInnovationButton.setXY();
            }
            if(this.m_bottomHudWreathFestivalInnovationButton)
            {
               this.m_bottomHudWreathFestivalInnovationButton.setXY();
            }
            if(this.m_bottomHudBoraBoraInnovationButton)
            {
               this.m_bottomHudBoraBoraInnovationButton.setXY();
            }
            if(this.m_bottomHudAnimalSanctuaryV2Button)
            {
               this.m_bottomHudAnimalSanctuaryV2Button.setXY();
            }
            if(this.m_bottomHudMadagascarInnovationButton)
            {
               this.m_bottomHudMadagascarInnovationButton.setXY();
            }
            if(this.m_bottomHudOctoberSidecarFeatureButton)
            {
               this.m_bottomHudOctoberSidecarFeatureButton.setXY();
            }
            if(this.m_bottomHudCanadaInnovationButton)
            {
               this.m_bottomHudCanadaInnovationButton.setXY();
            }
            if(this.m_bottomHudJumbleVillaButton)
            {
               this.m_bottomHudJumbleVillaButton.setXY();
            }
            if(this.m_bottomHudLEBundleButton)
            {
               this.m_bottomHudLEBundleButton.setXY();
            }
            if(this.m_bottomHudFvPluginButton)
            {
               this.m_bottomHudFvPluginButton.setXY();
            }
            if(this.m_bottomHudBookmarkOptButton)
            {
               this.m_bottomHudBookmarkOptButton.setXY();
            }
            if(this.m_MessageNotification)
            {
               this.m_MessageNotification.setXY();
            }
            if(this.m_HudLandBundle)
            {
               this.m_HudLandBundle.setXY();
            }
            if(this.m_bottomHudLandBundleUnlockFeature)
            {
               this.m_bottomHudLandBundleUnlockFeature.setXY();
            }
            if(Boolean(this.m_bottomHudShowAnimals) && this.m_bottomHudShowAnimals.length > 0)
            {
               for(i = 0; i < this.m_bottomHudShowAnimals.length; i++)
               {
                  this.m_bottomHudShowAnimals[i].setXY();
               }
            }
            if(this.m_homeButton)
            {
               this.m_homeButton.setX(GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH + 500);
            }
            if(this.m_zoomWidget)
            {
               this.m_zoomWidget.setX((GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 + 760);
               this.m_zoomWidget.setY(Global.stage.stageHeight - 43);
            }
            this.m_xpMeter.refreshLevelText();
            if(this.m_energyMax > 0)
            {
               barWidth = 137;
               tankCount = Math.ceil(this.m_energy / this.m_energyMax);
               remainder = this.m_energy % this.m_energyMax;
               energyPct = remainder / this.m_energyMax;
               ftueIsActive = !TutController.hasFinishedTutorial();
               if(this.m_energy > 0 && remainder == 0)
               {
                  energyPct = 1;
               }
               else
               {
                  energyPct = Math.min(1,energyPct);
               }
               tankString = "";
               if(this.m_energyDisplayObject)
               {
                  this.m_energySprite.removeChild(this.m_energyDisplayObject);
               }
               if(LoyaltyProgramManager.getInstance().isGoldenFarmer())
               {
                  if(this.m_energyDisplayObject)
                  {
                     FV_Main_Fuel_Gauge = ZLocUtils.tiEmbeddedArt("FV_Main_Fuel_infinity");
                     this.m_energyDisplayObject = new FV_Main_Fuel_Gauge();
                     this.m_energySprite.addChild(this.m_energyDisplayObject);
                  }
               }
               else if(Global.player.hasNoFuelDayActive())
               {
                  if(this.m_energyDisplayObject)
                  {
                     FV_Main_Fuel_Free_Fuel = ZLocUtils.tiEmbeddedArt("FV_Main_Fuel_free_fuel");
                     this.m_energyDisplayObject = new FV_Main_Fuel_Free_Fuel();
                     this.m_energySprite.addChild(this.m_energyDisplayObject);
                     this.m_energySprite.addChild(this.m_energyTankText);
                  }
                  if(tankCount > 1)
                  {
                     tankString = "+" + int(tankCount - 1).toString();
                  }
               }
               else
               {
                  FV_Main_Fuel_Gauge = ZLocUtils.tiEmbeddedArt("FV_Main_Fuel_Gauge_noBar");
                  this.m_energyDisplayObject = new FV_Main_Fuel_Gauge();
                  this.m_energySprite.addChild(this.m_energyDisplayObject);
                  this.m_energySprite.addChild(this.m_energyTankText);
                  this.m_energySprite.addChild(this.m_energyTankText);
                  if(tankCount > 1)
                  {
                     tankString = "+" + int(tankCount - 1).toString();
                  }
               }
               this.m_energyTankText.text = tankString;
               this.m_energySprite.visible = this.m_energySprite.visible && (Global.player.level >= Global.farmGameSettingsManager.getInt("fuelFeatureMinLevel",12) && !Global.worldManager.isInStaticWorld());
               this.m_energySprite.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2;
               this.m_energySprite.y = Global.stage.stageHeight - fuelTankHeightOffset;
               this.m_energySprite.useHandCursor = this.m_energySprite.visible;
               this.m_energySprite.buttonMode = this.m_energySprite.visible;
               this.m_refuelText.visible = this.m_energy < REFUEL_THRESHOLD;
               if(this.m_refuelText.visible)
               {
                  text = ZLocUtils.t("FarmGame","ClickHereToRefuel_ToolTip");
                  if(Boolean(text) && Boolean(text.length))
                  {
                     this.m_refuelText.text = text;
                  }
               }
               this.m_energySprite.buttonMode = true;
               this.updateEnergyToolTip();
            }
            this.m_cropBuffIconSprite.x = UI.DEFAULT_WIDTH + (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 - cropBuffOffsetX;
            this.m_cropBuffIconSprite.y = Global.stage.stageHeight - cropBuffOffset;
            if(this.m_trickOrTreatIcon)
            {
               this.m_trickOrTreatIcon.adjustPosition();
            }
            if(!Global.worldManager.isVisiting())
            {
               this.m_altGraphicIcon.y = Global.stage.stageHeight - lightsOffset;
               this.m_altGraphicText.y = Global.stage.stageHeight - lightsTextOffset;
               this.m_toiletPaper.visible = false;
            }
            else if(!NPCManager.getInstance().isVisitingNPC)
            {
               this.m_toiletPaper.y = Global.stage.stageHeight - lightsOffset;
               this.m_toiletPaper.visible = Global.player.hasGiftItem("TC");
            }
            else
            {
               this.m_toiletPaper.visible = false;
            }
            this.m_toiletPaper.useHandCursor = this.m_toiletPaper.visible;
            if(!this.m_lockVisualEffects)
            {
               if(this.m_goldChange)
               {
                  this.m_goldChangeRate = this.calculateChangeRate(this.m_currentGold,this.currentWorldCurrencyAmount);
                  this.m_goldTimer.start();
               }
               if(this.m_cashChange)
               {
                  this.m_cashChangeRate = this.calculateChangeRate(this.m_currentCash,this.cash);
                  this.m_cashTimer.start();
               }
               if(this.m_xpChange)
               {
                  this.m_xpChangeRate = this.calculateChangeRate(this.m_currentXp,Number(this.m_xp));
                  this.m_xpTimer.start();
               }
            }
            else
            {
               if(Boolean(this.m_currencyMeter) && Boolean(this.m_currencyMeter.textField))
               {
                  this.m_currentGold = this.currentWorldCurrencyAmount;
                  this.m_currencyMeter.textField.text = num;
                  this.resizeGold();
               }
               this.m_currentCash = this.cash;
               this.m_fvCashTxt.text = Utilities.formatNumber(this.cash);
               this.m_currentXp = Number(this.m_xp);
               if(this.m_subscriptionsWidget != null)
               {
                  this.m_subscriptionsWidget.cash = this.cash;
               }
            }
            this.m_iconQueue.setVisible(!Global.worldManager.isVisiting() && !ftueIsActive);
            this.m_visitIconQueue.setVisible(Global.worldManager.isVisiting());
            if(this.m_holidayCountdownButton)
            {
               currentDay = HolidayCountdownManager.getDaysSinceCampaignStarted();
               this.m_holidayCountdownButton.visible = currentDay >= 0 && !Global.worldManager.isVisiting() && !ftueIsActive;
            }
            if(this.m_neighborSearch)
            {
               this.m_neighborSearch.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 + 43;
               this.m_neighborSearch.y = Global.stage.stageHeight - 138;
            }
            if(this.m_chatNotification)
            {
               this.m_chatNotification.x = (GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH) / 2 + 431;
               this.m_chatNotification.y = Global.stage.stageHeight - 148;
            }
            this.m_goldChange = false;
            this.m_cashChange = false;
            this.m_xpChange = false;
            this.m_dirty = false;
            this.m_lockVisualEffects = false;
         }
      }
      
      protected function calculateChangeRate(current:Number, total:Number) : int
      {
         var result:Number = 0;
         if(total > current)
         {
            result = Math.ceil((total - current) / COUNT_RATE);
         }
         else if(total < current)
         {
            result = Math.floor((total - current) / COUNT_RATE);
         }
         return result;
      }
      
      public function updateHarvestHelperTime(text:String) : void
      {
         if(this.m_harvestHelperHudIcon)
         {
            this.m_harvestHelperHudIcon.updateTimeText(text);
         }
      }
      
      protected function updateCounter(current:Number, total:Number, changeRate:Number, timer:Timer, textField:TextField = null, formatNumber:Boolean = true) : Number
      {
         current += changeRate;
         if(changeRate > 0 && current > total || changeRate < 0 && current < total)
         {
            current = total;
         }
         if(textField)
         {
            if(formatNumber)
            {
               textField.text = Utilities.formatNumber(current);
            }
            else
            {
               textField.text = current.toString();
            }
         }
         if(current == total)
         {
            timer.reset();
            timer.stop();
         }
         return current;
      }
      
      protected function updateGold(event:TimerEvent) : void
      {
         if(this.m_currencyMeter)
         {
            this.m_currentGold = this.updateCounter(this.m_currentGold,this.currentWorldCurrencyAmount,this.m_goldChangeRate,this.m_goldTimer,this.m_currencyMeter.textField);
            this.resizeGold();
            UI.updateMarketCurrencyMeter(Global.worldManager.getCurrentHudCurrencyUnit(),this.m_currentGold);
         }
      }
      
      private function resizeGold() : void
      {
         var goldField:TextField = null;
         var scale:Number = NaN;
         if(this.m_currencyMeter)
         {
            goldField = this.m_currencyMeter.textField;
            if(goldField)
            {
               goldField.autoSize = TextFieldAutoSize.LEFT;
               goldField.multiline = false;
               goldField.wordWrap = false;
               goldField.scaleX = this.m_currencyMeter.textField.scaleY = 1;
               if(goldField.textWidth > RESIZE_COIN_STRING_THRESHOLD)
               {
                  scale = Math.max(RESIZE_COIN_STRING_LIMIT,RESIZE_COIN_STRING_THRESHOLD / goldField.textWidth);
                  goldField.scaleX = this.m_currencyMeter.textField.scaleY = scale;
               }
            }
         }
      }
      
      public function refreshWater() : void
      {
         if(this.m_waterHudButton)
         {
            this.m_waterHudButton.refresh();
         }
      }
      
      public function refreshAchievementHud(state:int) : void
      {
         if(this.m_bottomHudAchievement)
         {
            this.m_bottomHudAchievement.refresh(state);
         }
      }
      
      protected function updateCash(event:TimerEvent) : void
      {
         this.m_currentCash = this.updateCounter(this.m_currentCash,this.cash,this.m_cashChangeRate,this.m_cashTimer,this.m_fvCashTxt);
         if(this.m_subscriptionsWidget != null && Boolean(this.m_subscriptionsWidget.cashTextField))
         {
            this.m_subscriptionsWidget.cashTextField.text = this.m_fvCashTxt.text;
         }
         UI.updateMarketCash(this.m_currentCash);
      }
      
      protected function updateXp(event:TimerEvent) : void
      {
         this.m_currentXp = this.updateCounter(this.m_currentXp,Number(this.m_xp),this.m_xpChangeRate,this.m_xpTimer,null,false);
      }
      
      protected function updateGetCoinsFunctionality(event:TimerEvent) : void
      {
         var assetObject:Object = null;
         var FV_AddCoins_bt:Class = null;
         var activePromoType:String = BuyerPromoUtility.getCurrentPromoType();
         if(activePromoType != "" && Boolean(BuyerPromoUtility.getCurrentPromoRemainingTime()))
         {
            if(activePromoType != this.m_currentGetCoinFunction)
            {
               if(this.m_getCoinsButton)
               {
                  removeChild(this.m_getCoinsButton as DisplayObject);
               }
               this.m_getCoinsButton = null;
               switch(activePromoType)
               {
                  case BuyerPromoUtility.PROMO_DISCOUNT:
                  case BuyerPromoUtility.PROMO_STARTERPACK:
                     FV_AddCoins_bt = EmbeddedArt.FV_addCoinsSale_bt;
                     assetObject = new FV_AddCoins_bt();
                     this.loadGetCoinIcon(assetObject);
                     break;
                  case BuyerPromoUtility.PROMO_TIERED_GIFTS:
                     FV_AddCoins_bt = EmbeddedArt.FV_addCoinsFreeGift_bt;
                     this.m_getCoinsButton = new FV_AddCoins_bt();
                     this.m_getCoinsButton.addEventListener(MouseEvent.CLICK,this.onGetCoinsRepopFlashSale);
               }
               this.placeGetCoinButton();
               this.m_currentGetCoinFunction = activePromoType;
            }
         }
         else if(s_isW2EAdAvailable)
         {
            if(this.m_currentGetCoinFunction != GETCOINS_FUNCTION_W2E)
            {
               this.m_currentGetCoinFunction = GETCOINS_FUNCTION_W2E;
               this.setupW2EButton();
               FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,W2E_SLOT_ID_HUD_ICON,"view");
            }
         }
         else if(this.m_currentGetCoinFunction != GETCOINS_FUNCTION_DEFAULT)
         {
            if(this.m_getCoinsButton)
            {
               removeChild(this.m_getCoinsButton as DisplayObject);
            }
            FV_AddCoins_bt = ZLocUtils.tiEmbeddedArt("FV_addCoins_bt");
            this.m_getCoinsButton = new FV_AddCoins_bt();
            this.m_getCoinsButton.addEventListener(MouseEvent.CLICK,this.onGetCoins);
            if(Global.flashHotParams["W2E_HUD"])
            {
               this.m_getCoinsButton.visible = false;
            }
            this.placeGetCoinButton();
            this.m_currentGetCoinFunction = GETCOINS_FUNCTION_DEFAULT;
         }
      }
      
      private function setupW2EButton() : void
      {
         if(this.m_getCoinsButton)
         {
            removeChild(this.m_getCoinsButton as DisplayObject);
         }
         var FV_AddCoins_bt:Class = EmbeddedArt.FV_earnFreeFC_bt;
         this.m_getCoinsButton = new FV_AddCoins_bt();
         this.m_getCoinsButton.addEventListener(MouseEvent.CLICK,this.onClickW2E);
         if(!Global.flashHotParams["W2E_HUD"])
         {
            this.m_getCoinsButton.visible = false;
         }
         this.placeGetCoinButton();
      }
      
      private function onClickW2E(event:Event) : void
      {
         Global.watchToEarn.startActivity(W2E_SLOT_ID_HUD_ICON);
         FarmStatsManager.count(WatchToEarnManager.STAT_COUNTER,W2E_SLOT_ID_HUD_ICON,"click");
      }
      
      private function placeGetCoinButton() : void
      {
         if(this.m_getCoinsButton)
         {
            this.m_getCoinsButton.x = 58;
            this.m_getCoinsButton.y = 45;
            addChild(this.m_getCoinsButton as DisplayObject);
         }
      }
      
      private function loadGetCoinIcon(assetObject:Object) : void
      {
         var asset:MovieClip = assetObject as MovieClip;
         var loader:Loader = asset.getChildAt(0) as Loader;
         var info:LoaderInfo = loader.contentLoaderInfo;
         info.addEventListener(Event.COMPLETE,this.onGetCoinsIconLoadCallback);
      }
      
      private function onGetCoinsIconLoadCallback(event:Event) : void
      {
         var discount:String = null;
         var message:String = null;
         var info:LoaderInfo = event.target as LoaderInfo;
         info.removeEventListener(Event.COMPLETE,this.onGetCoinsIconLoadCallback);
         this.m_getCoinsButton = info.loader.content as MovieClip;
         switch(this.m_currentGetCoinFunction)
         {
            case BuyerPromoUtility.PROMO_DISCOUNT:
               this.m_getCoinsButton.addEventListener(MouseEvent.CLICK,this.onGetCoinsRepopFlashSale);
               discount = FeatureOptionsManager.getInstance().getFeatureOption("buyerPromo","discount") as String;
               message = ZLocUtils.t("FarmVille","HUDPromoSalePercentOff",{"percentOff":discount});
               this.m_getCoinsButton.addCoins_bt.generic_tf.text = message;
               break;
            case BuyerPromoUtility.PROMO_STARTERPACK:
               this.m_getCoinsButton.addEventListener(MouseEvent.CLICK,this.onGetCoinsRedirect);
               this.m_getCoinsButton.addCoins_bt.generic_tf.text = ZLocUtils.t("FarmVille","HUDPromoSaleStarterPack");
               break;
            case GETCOINS_FUNCTION_W2E:
               this.m_getCoinsButton.addEventListener(MouseEvent.CLICK,this.onClickW2E);
         }
         this.placeGetCoinButton();
      }
      
      public function lockVisualEffectsForNextUpdate() : void
      {
         this.m_lockVisualEffects = true;
      }
      
      public function unlockVisualEffects() : void
      {
         this.m_lockVisualEffects = false;
      }
      
      public function isVisualEffectsLocked() : Boolean
      {
         return this.m_lockVisualEffects;
      }
      
      public function markDirty() : void
      {
         this.m_dirty = true;
      }
      
      public function updateEnergyToolTip(forceUpdate:Boolean = false) : void
      {
         var timeRemaining:Number = NaN;
         if(this.m_energySprite.isToolTipVisible() || forceUpdate)
         {
            if(LoyaltyProgramManager.getInstance().isGoldenFarmer())
            {
               this.m_energySprite.toolTip = "Unlimited Fuel";
            }
            else if(Global.player.hasNoFuelDayActive())
            {
               timeRemaining = Global.player.noFuelEndTime() - GlobalEngine.serverTime / 1000;
               this.m_energySprite.toolTip = ZLocUtils.t("FarmGame","Energy_Freefuel_ToolTip",{"timeLeft":HUD.getformattedTimeLeft(timeRemaining)});
            }
            else
            {
               this.m_energySprite.toolTip = ZLocUtils.t("FarmGame","Energy_ToolTip",{"quantity":this.m_energy});
            }
         }
      }
      
      public function set gold(amount:int) : void
      {
         if(this.m_gold != amount)
         {
            this.m_gold = amount;
            this.m_goldChange = true;
            this.m_dirty = true;
         }
      }
      
      public function get gold() : int
      {
         return this.m_gold;
      }
      
      public function set currentWorldCurrencyAmount(amount:Number) : void
      {
         if(this.m_worldCurrencyAmount != amount)
         {
            this.m_worldCurrencyAmount = amount;
            this.m_goldChange = true;
            this.m_dirty = true;
         }
      }
      
      public function get currentWorldCurrencyAmount() : Number
      {
         return this.m_worldCurrencyAmount;
      }
      
      public function set cash(amount:int) : void
      {
         if(this.m_cash != amount)
         {
            this.m_cash = amount;
            this.m_cashChange = true;
            this.m_dirty = true;
         }
      }
      
      public function get cash() : int
      {
         return this.m_cash;
      }
      
      public function set energy(amount:int) : void
      {
         if(this.m_energy != amount)
         {
            this.m_energy = amount;
            this.m_dirty = true;
         }
      }
      
      public function set energyMax(amount:int) : void
      {
         if(this.m_energyMax != amount)
         {
            this.m_energyMax = amount;
            this.m_dirty = true;
         }
      }
      
      public function setTerrainMode(edit:Boolean) : void
      {
         this.m_energySprite.visible = !edit;
      }
      
      public function setVisiting(visit:Boolean) : void
      {
         var fertIdx:int = 0;
         this.m_visit = visit;
         if(this.m_visit)
         {
            this.m_energySprite.visible = false;
            this.m_cropBuffIconSprite.visible = false;
         }
         else
         {
            this.m_cropBuffIconSprite.visible = this.m_cropBuffIconSprite.hasBuff;
         }
         this.setLightIcon();
         this.setRightSideIconQueuesVisibility(!visit);
      }
      
      public function set xp(amount:Number) : void
      {
         if(Number(this.m_xp) != amount)
         {
            this.m_xpChange = true;
         }
         this.m_xpMeter.xp = amount;
         this.m_dirty = true;
      }
      
      public function set level(amount:Number) : void
      {
         if(this.m_xpMeter.level != amount)
         {
            this.m_xpMeter.level = amount;
            this.m_dirty = true;
         }
      }
      
      public function get level() : Number
      {
         return this.m_xpMeter.level;
      }
      
      public function mysteryBoxMarket(e:MouseEvent) : void
      {
         UI.displayMarketDialog("fuel_gauge_refuel","decoration");
      }
      
      public function highlightFuel() : void
      {
         TweenLite.to(this.m_energySprite,0.25,{
            "scaleX":1.5,
            "scaleY":1.5,
            "onComplete":function():void
            {
               TweenLite.to(m_energySprite,0.25,{
                  "scaleX":1,
                  "scaleY":1
               });
            }
         });
      }
      
      protected function onRefuelClick(event:Event) : void
      {
         if(!Global.worldManager.isVisiting())
         {
            UI.displayMarketDialog("fuel_gauge_refuel","aide",null,"fuel");
            this.m_energySprite.filters = [];
         }
      }
      
      protected function onEnergyBarMouseOver(event:MouseEvent) : void
      {
         this.updateEnergyToolTip(true);
      }
      
      protected function onRefuelOver(event:Event) : void
      {
         this.m_cursorId = UI.setCursor(null,true);
         this.m_energySprite.filters = [new GlowFilter(16777215,1,4,4,20)];
      }
      
      protected function onRefuelOut(event:Event) : void
      {
         if(this.m_cursorId)
         {
            UI.removeCursor(this.m_cursorId);
            this.m_cursorId = 0;
         }
         this.m_energySprite.filters = [];
      }
      
      public function refreshIconVisibility() : void
      {
         this.m_rightSideIconQueue.refreshIconVisibility();
      }
      
      public function get optionsMenu() : OptionMenu
      {
         return this.m_optionMenu;
      }
      
      public function get messageCenterButton() : MessageCenterButton
      {
         return this.m_messageCenterButton;
      }
      
      public function showMessageCenterButton(visible:Boolean = true) : void
      {
         if(this.m_messageCenterButton)
         {
            this.m_messageCenterButton.visible = visible;
         }
      }
      
      public function set holidayCountdownButton(button:FarmGameSprite) : void
      {
         if(this.m_holidayCountdownButton != button)
         {
            if(this.m_holidayCountdownButton)
            {
               this.m_topRightContainer.removeChild(this.m_holidayCountdownButton);
            }
            this.m_holidayCountdownButton = button;
            if(this.m_holidayCountdownButton)
            {
               this.m_topRightContainer.addChildAt(this.m_holidayCountdownButton,0);
               if(this.m_holidayCountdownButton.y != 80 || this.m_holidayCountdownButton.alpha < 1)
               {
                  TweenLite.to(this.m_holidayCountdownButton,1,{
                     "y":80,
                     "alpha":1
                  });
               }
            }
         }
      }
      
      public function set trickOrTreatIcon(ttIcon:TrickOrTreatHUD) : void
      {
         this.m_trickOrTreatIcon = ttIcon;
      }
      
      public function get trickOrTreatIcon() : TrickOrTreatHUD
      {
         return this.m_trickOrTreatIcon;
      }
      
      public function get iconQueue() : DynamicIconQueue
      {
         return this.m_iconQueue;
      }
      
      public function get visitIconQueue() : DynamicIconQueue
      {
         return this.m_visitIconQueue;
      }
      
      public function get rightSideIconQueue() : DynamicIconQueue
      {
         return this.m_rightSideIconQueue;
      }
      
      public function setIconQueuesVisibility(isVisible:Boolean) : void
      {
         if(this.m_iconContainerSprite)
         {
            if(isVisible)
            {
               addChild(this.m_iconContainerSprite);
            }
            else if(this.m_iconContainerSprite.parent)
            {
               this.m_iconContainerSprite.parent.removeChild(this.m_iconContainerSprite);
            }
         }
      }
      
      public function setRightSideIconQueuesVisibility(isVisible:Boolean) : void
      {
         if(this.m_rightSideIconQueue)
         {
            if(isVisible)
            {
               addChildAt(this.m_rightSideIconQueue,0);
            }
            else if(this.m_rightSideIconQueue.parent)
            {
               this.m_rightSideIconQueue.parent.removeChild(this.m_rightSideIconQueue);
            }
         }
      }
      
      private function onGetCoins(event:Event) : void
      {
         var variant:int = Global.experimentManager.getExperimentVariant("fv_ingame_payments");
         if(variant == InGamePaymentsManager.VARIANT_HUD)
         {
            FarmStatsManager.count("Add_cash_payments_test","click_button_add_cash","click_HUD_button");
            FarmStatsManager.count("Add_cash_payments_test","dialog_impresssions",variant.toString());
         }
      }
      
      private function onGetCoinsRedirect(event:Event) : void
      {
         BuyerPromoUtility.displayStarterPackPromo();
      }
      
      private function onGetCoinsRepopFlashSale(event:Event) : void
      {
         BuyerPromoUtility.displayFlashSalePromo();
      }
      
      private function topRightContainerCreate() : void
      {
         this.m_topRightContainer = new FarmGameSprite();
         this.m_topRightContainer.trackClicks(false);
         addChild(this.m_topRightContainer);
         this.m_basicNameDisplay = new BasicNameDisplay();
         this.m_basicNameDisplay.visible = false;
         this.m_topRightContainer.addChild(this.m_basicNameDisplay);
         if(Global.player.postInitFinished)
         {
            this.determineVisibilityOfStatsDropDown();
         }
         else
         {
            Global.world.addEventListener(FarmGameWorldEvent.USER_POST_INIT_COMPLETE,this.determineVisibilityOfStatsDropDown);
         }
         this.m_messageCenterButton = new MessageCenterButton();
         this.m_topRightContainer.addChild(this.m_messageCenterButton);
      }
      
      private function determineVisibilityOfStatsDropDown(e:Event = null) : void
      {
         if(!this.isHideStatsEnabled())
         {
            if(!LoyaltyProgramManager.getInstance().userPassesPrereq())
            {
               this.m_statsDropDown = new StatsDropDown();
               this.m_topRightContainer.addChild(this.m_statsDropDown);
            }
         }
      }
      
      public function set travelNameDisplay(newTravelNameDisplay:TravelNameDisplay) : void
      {
         if(newTravelNameDisplay)
         {
            if(this.m_travelNameDisplay)
            {
               this.m_travelNameDisplay.release();
               this.m_topRightContainer.removeChild(this.m_travelNameDisplay);
            }
            this.m_travelNameDisplay = newTravelNameDisplay;
            this.m_travelNameDisplay.visible = this.m_isTravelNameDisplayVisible;
            this.m_travelNameDisplay.setFarmNameByLocation();
            this.m_topRightContainer.addChild(this.m_travelNameDisplay);
         }
      }
      
      public function isHideStatsEnabled() : Boolean
      {
         var shouldHideStats:Boolean = false;
         if(Global.flashHotParams.hasOwnProperty(ZRUNTIME_KEY_HIDE_STATS_HUD))
         {
            shouldHideStats = Boolean(Global.flashHotParams[ZRUNTIME_KEY_HIDE_STATS_HUD]);
         }
         return shouldHideStats;
      }
      
      public function get travelNameDisplay() : TravelNameDisplay
      {
         return this.m_travelNameDisplay;
      }
      
      public function set currencyMeter(currencyMeter:CurrencyMeter) : void
      {
         if(currencyMeter)
         {
            if(this.m_currencyMeter)
            {
               if(this.m_currencyMeter.parent)
               {
                  this.m_currencyMeter.parent.removeChild(this.m_currencyMeter);
               }
               this.m_currencyMeter.release();
               this.m_currencyMeter = null;
            }
            this.m_currencyMeter = currencyMeter;
            this.m_goldChange = true;
            this.m_dirty = true;
            this.conditionallyRefreshHUD(true);
            this.addChild(this.m_currencyMeter);
         }
      }
      
      public function set xpMeterConfig(scoreMeterConfig:ScoreMeterConfig) : void
      {
         this.m_xpMeter.init(scoreMeterConfig);
      }
      
      public function set worldScoreMeter(scoreMeter:ScoreMeter) : void
      {
         if(this.m_worldScoreMeter)
         {
            if(this.m_worldScoreMeter.parent)
            {
               this.m_worldScoreMeter.parent.removeChild(this.m_worldScoreMeter);
            }
            this.m_worldScoreMeter.release();
            this.m_worldScoreMeter = null;
         }
         if(scoreMeter)
         {
            this.m_worldScoreMeter = scoreMeter;
            this.m_worldScoreMeter.x = this.m_xpMeter.x - this.m_xpMeter.width - 10;
            this.addChild(scoreMeter);
         }
      }
      
      public function set worldScore2Meter(scoreMeter:ScoreMeter) : void
      {
         if(this.m_worldScore2Meter)
         {
            if(this.m_worldScore2Meter.parent)
            {
               this.m_worldScore2Meter.parent.removeChild(this.m_worldScore2Meter);
            }
            this.m_worldScore2Meter.release();
            this.m_worldScore2Meter = null;
         }
         if(scoreMeter)
         {
            this.m_worldScore2Meter = scoreMeter;
            this.m_worldScore2Meter.x = this.m_xpMeter.x + this.m_xpMeter.width + 10;
            this.addChild(scoreMeter);
         }
      }
      
      public function setWorldScoreMeterArrowVisible(visible:Boolean) : void
      {
         if(this.m_worldScoreMeter)
         {
            this.m_worldScoreMeter.setArrowVisible(visible);
         }
      }
      
      public function set messageSignButton(messageSignButton:MessageSignButton) : void
      {
         if(messageSignButton)
         {
            if(Boolean(this.m_messageSignButton) && this.contains(this.m_messageSignButton))
            {
               this.m_topRightContainer.removeChild(this.m_messageSignButton);
            }
            this.m_messageSignButton = messageSignButton;
            if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME)
            {
               this.m_isMessageButtonVisible = false;
            }
            this.m_messageSignButton.visible = this.m_isMessageButtonVisible;
            this.m_topRightContainer.addChild(messageSignButton);
         }
      }
      
      public function shouldAllowTravel() : Boolean
      {
         var availableTravelWorlds:Array = null;
         if(Global.experimentManager.getExperimentVariant("OPS_FORCE_STAY_FARMWORLD") == 1)
         {
            return false;
         }
         availableTravelWorlds = Global.worldManager.getAvailableTravelWorlds();
         return availableTravelWorlds.length > 0;
      }
      
      public function get hudSkinType() : String
      {
         return this.m_hudSkinType;
      }
      
      public function set hudSkinType(newSkinType:String) : void
      {
         this.m_hudSkinType = newSkinType;
      }
      
      public function showBasicNameDisplay() : void
      {
         this.m_basicNameDisplay.visible = true;
         this.m_isTravelNameDisplayVisible = false;
         if(this.m_travelNameDisplay)
         {
            this.m_travelNameDisplay.visible = false;
         }
         this.m_isMessageButtonVisible = !Utilities.isFullScreen() && Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_HOME;
         if(this.m_messageSignButton)
         {
            this.m_messageSignButton.visible = this.m_isMessageButtonVisible;
         }
      }
      
      public function showTravelNameDisplay() : void
      {
         this.m_basicNameDisplay.visible = false;
         this.m_isTravelNameDisplayVisible = true;
         if(this.m_travelNameDisplay)
         {
            this.m_travelNameDisplay.visible = true;
         }
         this.m_isMessageButtonVisible = Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_HOME;
         if(this.m_messageSignButton)
         {
            this.m_messageSignButton.visible = this.m_isMessageButtonVisible;
         }
      }
      
      public function toggleHarvestHelperHudIconVisibility(visible:Boolean, showAnimation:Boolean = false, animationStartX:Number = 0, animationStartY:Number = 0) : void
      {
         if(!this.m_harvestHelperHudIcon && visible)
         {
            this.m_harvestHelperHudIcon = new HarvestHelperHudIcon(showAnimation,animationStartX,animationStartY);
            this.addChild(this.m_harvestHelperHudIcon);
         }
         if(visible == false && Boolean(this.m_harvestHelperHudIcon))
         {
            this.removeChild(this.m_harvestHelperHudIcon);
            this.m_harvestHelperHudIcon = null;
         }
      }
      
      public function hideAllNameDisplays() : void
      {
         this.m_isTravelNameDisplayVisible = false;
         this.m_basicNameDisplay.visible = false;
         if(this.m_travelNameDisplay)
         {
            this.m_travelNameDisplay.visible = false;
         }
         this.m_isMessageButtonVisible = false;
         if(this.m_messageSignButton)
         {
            this.m_messageSignButton.visible = false;
         }
      }
      
      public function get farmNameDisplay() : FarmNameDisplay
      {
         var result:FarmNameDisplay = null;
         if(Boolean(this.m_travelNameDisplay) && this.m_travelNameDisplay.visible)
         {
            result = this.m_travelNameDisplay;
         }
         else if(Boolean(this.m_basicNameDisplay) && this.m_basicNameDisplay.visible)
         {
            result = this.m_basicNameDisplay;
         }
         return result;
      }
      
      public function setVisibilityW2EHud(visible:Boolean) : void
      {
         if(this.m_getCoinsButton)
         {
            this.m_getCoinsButton.visible = visible;
         }
      }
   }
}

