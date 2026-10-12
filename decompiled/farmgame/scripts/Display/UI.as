package Display
{
   import Cache.Classes.UI.ZCacheUI;
   import Cache.Interfaces.IZCache;
   import Classes.Animal;
   import Classes.BushelReportActionDropHandler;
   import Classes.BuyPresent;
   import Classes.Combine;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.Constants.CrossPromoConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ToasterIconPaths;
   import Classes.Constants.WorldsConstants;
   import Classes.DairyFarmBuilding;
   import Classes.EmbeddedArt;
   import Classes.FarmIsoViewport;
   import Classes.FarmSocialNetwork;
   import Classes.HorseStableBuilding;
   import Classes.ImageLoader;
   import Classes.Seeder;
   import Classes.StorageBuilding;
   import Classes.TutController;
   import Classes.ZItem.ExpansionData;
   import Classes.ZItem.FarmItem;
   import Classes.util.PerformanceTracker;
   import Classes.util.ZCacheTracker;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.Dialogs.GenericDialogConfig;
   import Display.FriendBar.FriendBar;
   import Display.FriendBar.FriendBarLeftNav;
   import Display.FriendBar.FriendBarRightNav;
   import Display.FriendBar.FriendBarSlot;
   import Display.HUD.HUD;
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Init.InitializationManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.CloseEvent;
   import Events.FriendBarEvent;
   import Events.FriendBarSlotEvent;
   import Events.GenericPopupEvent;
   import Events.MarketEvent;
   import Events.UIEvent;
   import GameMode.GMBuild;
   import GameMode.GMCombine;
   import GameMode.GMFarmstamatic;
   import GameMode.GMMarketPlant;
   import GameMode.GMSeeder;
   import GameMode.GMSuperAvatarPlant;
   import GameMode.GameMode;
   import Managers.ChatManager;
   import Managers.CrossPromoManager;
   import Managers.DefconManager;
   import Managers.EmailManager;
   import Managers.EnglishSweepstakesPromoManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FreezeManager;
   import Managers.GiftBoxUseAllManager;
   import Managers.HudWidgetManager;
   import Managers.InGamePaymentsManager;
   import Managers.LicenseManager;
   import Managers.MFSRequestManager;
   import Managers.MarketStatsManager;
   import Managers.RetentionMasterManager;
   import Managers.SmartPopupManager;
   import Managers.ToasterManager;
   import Managers.ToolModeManager;
   import Transactions.Quests.TShareWorldScoreLevelUpReward;
   import Transactions.TBuyAndSendPresent;
   import Transactions.TGetGiftBoxErrors;
   import Transactions.TReceivePresent;
   import Transactions.TRefreshBalance;
   import Widgets.Windows.BushelReportWindow;
   import Widgets.Windows.Crafting.BuyMarketStallWindow;
   import Widgets.Windows.DuckPond.DuckGameWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import Widgets.Windows.GiftBox.GiftBoxWindow;
   import Widgets.Windows.Market.MarketMiniCharityWindow;
   import Widgets.Windows.Market.MarketMiniGreenhouseWindow;
   import Widgets.Windows.Market.MarketMiniVIPWindow;
   import Widgets.Windows.Market.MarketMiniWindow;
   import Widgets.Windows.Market.MarketWindow;
   import Widgets.Windows.Market.MiniMarketStateData;
   import Widgets.Windows.Market.SeedSelectionMarketMiniWindow;
   import Widgets.Windows.ShareButtonToasterWindow;
   import Widgets.Windows.Storage.StorageWindow;
   import Widgets.Windows.TerrainEditor.TerrainEditorWindow;
   import Widgets.Windows.ToasterWindow;
   import com.adobe.serialization.json.JSON;
   import com.troyer.widget.controller.DynamicDialog;
   import com.troyer.widget.view.BaseWidgetView;
   import fl.motion.easing.Quadratic;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   import gs.TweenLite;
   
   public class UI extends Sprite
   {
      
      private static var m_actionMenu:ActionMenu;
      
      public static var s_hoverWindowContainer:Sprite;
      
      private static var m_currentDialog:DisplayObject;
      
      private static var m_menu:ContextMenu;
      
      public static const MARKET_CONTEXT_UNKNOWN:String = "unknown";
      
      public static const MINIMARKET_CONTEXT_GREENHOUSE:String = "greenhouse";
      
      public static const MINIMARKET_CONTEXT_EXPANSIONPROMPT:String = "expansionprompt";
      
      public static const MINIMARKET_CONTEXT_CHARITY:String = "charity";
      
      public static const MINIMARKET_CONTEXT_VIP:String = "vip";
      
      public static const BUTTON_LAYOUT_NONE:int = 0;
      
      public static const BUTTON_LAYOUT_OK:int = 1;
      
      public static const BUTTON_LAYOUT_ACCEPT_CANCEL:int = 2;
      
      public static const BUTTON_LAYOUT_YES_NO:int = 3;
      
      public static const BUTTON_LAYOUT_SHARE_CANCEL:int = 4;
      
      public static const BUTTON_LAYOUT_SHARE:int = 5;
      
      public static const BUTTON_LAYOUT_ACCEPT:int = 6;
      
      public static const MARKET_LAUNCH_REFERENCE_SEEDER:String = "seeder";
      
      public static const MARKET_LAUNCH_REFERENCE_SUPER_AVATAR:String = "superavatar";
      
      public static const MARKET_LAUNCH_REFERENCE_COMBINE:String = "combine";
      
      private static const SCREEN_MENU_BUFFER:int = 10;
      
      private static const MAX_FEED_ITEMS:int = 4;
      
      public static const UI_BUTTON_CLICKS_COUNTER:String = "ui_button_clicks";
      
      public static const DEFAULT_WIDTH:int = 760;
      
      public static const DEFAULT_HEIGHT:int = 590;
      
      public static const DEFAULT_STATUS_TWEEN_DURATION:Number = 1.5;
      
      public static const DEFAULT_STATUS_TWEEN_DISPLACEMENT:int = 32;
      
      public static const DEFAULT_STATUS_TWEEN_FONT_SIZE:int = 16;
      
      public static const DEFAULT_STATUS_TWEEN_FONT_COLOR:Object = null;
      
      public static const STATUS_TWEEN_FONT_COLOR_WHITE:uint = 16777215;
      
      private static const Y_POSITION_NEIGHBOR_BACKGROUND:int = 439;
      
      private static const X_POSITION_ZOOM_OUT_BUTTON:int = 656;
      
      private static const Y_POSITION_ZOOM_OUT_BUTTON:int = 442;
      
      private static const X_POSITION_ZOOM_IN_BUTTON:int = 627;
      
      private static const Y_POSITION_ZOOM_IN_BUTTON:int = 442;
      
      private static const X_POSITION_CAMERA_BUTTON:int = 714;
      
      private static const Y_POSITION_CAMERA_BUTTON:int = 442;
      
      private static const X_POSITION_FULLSCREEN_BUTTON:int = 685;
      
      private static const Y_POSITION_FULLSCREEN_BUTTON:int = 442;
      
      private static const WORLDSCORE_LEVELUP_MAX_ITEMS_IN_FEED:int = 3;
      
      private static const HANDLE_POPUP_FOR_RETENTION_OPTION_ADD_TO_QUEUE:String = "addToQueue";
      
      private static const HANDLE_POPUP_FOR_RETENTION_OPTION_POPUP_NAME:String = "popupName";
      
      private static const HANDLE_POPUP_FOR_RETENTION_OPTION_CHECK_DUPLICATES:String = "checkDuplicates";
      
      private static const HANDLE_POPUP_FOR_RETENTION_OPTION_ADD_INACTIVE_POPUP:String = "addInactiveUserPopup";
      
      private static const HANDLE_POPUP_FOR_RETENTION_OPTION_DONT_CLOSE_TOASTER:String = "dontCloseToaster";
      
      public static var m_bottomUI:Sprite = new Sprite();
      
      private static var m_buyPresentFlow:BuyPresent = null;
      
      private static var m_marketWindow2:MarketWindow = null;
      
      private static var m_buyMarketStallWindow:BuyMarketStallWindow = null;
      
      private static var m_giftBoxWindow:GiftBoxWindow = null;
      
      public static var windowState:Object = null;
      
      private static var m_storageDialog:SlotDialog = null;
      
      private static var m_storageWindow:StorageWindow = null;
      
      public static var storageWindowState:Object = null;
      
      public static var InventoryWindowState:Object = null;
      
      private static var m_duckGameWindow:DuckGameWindow = null;
      
      private static var m_terrainEditorWindow:TerrainEditorWindow = null;
      
      private static var m_popupQueue:Array = [];
      
      private static var s_pendingHoverWindows:Array = [];
      
      protected static var m_cursors:Array = [];
      
      protected static var m_currentCursor:Object = null;
      
      public static var marketLaunchReference:String = null;
      
      public static var marketTerrainCodes:Array = null;
      
      private static var m_buyableItemStr:String = "";
      
      protected static var m_enablePopups:Boolean = true;
      
      protected static var m_isGiftBoxLocked:Boolean = false;
      
      public static var m_showGiftingInterstitial:Boolean = false;
      
      protected static var m_numImmediatePopups:int = 0;
      
      private static var m_flashVersion:Object = null;
      
      private static const REGEX_VERSION:RegExp = /^(\w*) (\d*),(\d*),(\d*),(\d*)$/;
      
      private static var m_suppressPopupQueue:Boolean = false;
      
      private static const TOASTER_Y_OFFSET_TO_BE_IN_MARKET:int = 120;
      
      private const SEND_GIFT_TO:String = "sendGiftTo";
      
      private const SEND_GIFT:String = "sendGift";
      
      private const ADD_NEIGHBOR:String = "addNeighbor";
      
      private const ADD_NEIGHBOREX:String = "addNeighborEx";
      
      private const VISIT_NEIGHBOR:String = "visitNeighbor";
      
      private const SEND_MESSAGE_NEIGHBOR:String = "sendMessageToNeighbor";
      
      public var m_friendBar:FriendBar;
      
      public var m_friendBarX:int;
      
      private var m_neighborBackground:Bitmap;
      
      private var m_friendBarLeftNav:FriendBarLeftNav;
      
      private var m_friendBarRightNav:FriendBarRightNav;
      
      private var m_clickedSlot:FriendBarSlot;
      
      protected var m_performanceTracker:PerformanceTracker;
      
      protected var m_zCacheTracker:ZCacheTracker;
      
      protected var m_cursorId:int;
      
      private var m_fullscreen:SpriteButton;
      
      private var m_zoomIn:SpriteButton;
      
      private var m_zoomOut:SpriteButton;
      
      private var m_takePhoto:SpriteButton;
      
      private var m_zcacheButton:SpriteButton;
      
      private var m_home:FarmGameSprite;
      
      private var m_homeText:StrokeTextField;
      
      private var m_overlaySWFs:Dictionary = new Dictionary();
      
      private var m_inactiveOverlays:Dictionary = new Dictionary();
      
      private var m_activeOverlays:Dictionary = new Dictionary();
      
      protected const MAX_INACTIVE_OVERLAYS:int = 20;
      
      private const WIDTH_MULTIPLIER:Number = 1.1;
      
      public var leSurfacingToaster:ToasterWindow = null;
      
      public var bushelReportWindow:BushelReportWindow = null;
      
      private var m_actionMenuAdded:Boolean = false;
      
      public function UI()
      {
         super();
         Global.ui = this;
         this.m_home = new SpriteButton(EmbeddedArt.FV_Home_Button_Normal,EmbeddedArt.FV_Home_Button_Over,EmbeddedArt.FV_Home_Button_Down,this.onGoHome);
         this.m_home.x = 664;
         this.m_home.y = 407;
         this.m_home.visible = false;
         this.m_home.toolTip = ZLocUtils.t("FarmGame","ReturnHome_ToolTip");
         m_bottomUI.addChild(this.m_home);
         this.m_homeText = new StrokeTextField(0,0.8);
         this.m_homeText.toolTipText = ZLocUtils.t("FarmGame","GoHome");
         this.m_homeText.setTextFormat(new TextFormat("Arial",14,16777215,true));
         this.m_homeText.autoSize = TextFieldAutoSize.LEFT;
         this.m_homeText.x = (this.m_home.width - this.m_homeText.textWidth) / 2;
         this.m_homeText.y = -this.m_homeText.textHeight;
         this.m_home.addChild(this.m_homeText);
         m_bottomUI.addEventListener(MouseEvent.MOUSE_DOWN,this.onMaskBitmapEvent);
         m_bottomUI.addEventListener(MouseEvent.MOUSE_OVER,this.onMaskBitmapEvent);
         m_bottomUI.addEventListener(MouseEvent.MOUSE_MOVE,this.onMaskBitmapEvent);
         m_bottomUI.addEventListener(MouseEvent.CLICK,this.onMaskBitmapEvent);
         this.m_friendBarLeftNav = new FriendBarLeftNav();
         this.m_friendBarLeftNav.addEventListener(FriendBarEvent.MOVE,this.onFriendBarMove);
         this.m_friendBarLeftNav.addEventListener(FriendBarEvent.MOVE_END,this.onFriendBarMoveEnd);
         m_bottomUI.addChild(this.m_friendBarLeftNav);
         this.m_friendBarRightNav = new FriendBarRightNav();
         this.m_friendBarRightNav.addEventListener(FriendBarEvent.MOVE,this.onFriendBarMove);
         this.m_friendBarRightNav.addEventListener(FriendBarEvent.MOVE_END,this.onFriendBarMoveEnd);
         m_bottomUI.addChild(this.m_friendBarRightNav);
         var slotMask:Sprite = new Sprite();
         slotMask.graphics.beginFill(0);
         slotMask.graphics.drawRect(-2,-30,528,230);
         slotMask.alpha = 0.3;
         slotMask.graphics.endFill();
         slotMask.x = 43;
         slotMask.y = 462;
         m_bottomUI.addChild(slotMask);
         this.m_friendBar = new FriendBar();
         this.m_friendBar.addEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onFriendBarClick);
         this.m_friendBar.addEventListener(FriendBarEvent.LOADED,this.onFriendBarLoaded);
         this.m_friendBar.y = 130;
         this.m_friendBar.mask = slotMask;
         m_bottomUI.addChild(this.m_friendBar);
         m_bottomUI.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         m_bottomUI.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.m_performanceTracker = new PerformanceTracker();
         this.m_performanceTracker.x = 40;
         this.m_zCacheTracker = new ZCacheTracker();
         this.m_zCacheTracker.x = 200;
         this.m_performanceTracker.visible = this.m_zCacheTracker.visible = false;
         this.m_performanceTracker.y = this.m_zCacheTracker.y = 330;
         m_bottomUI.addChild(this.m_performanceTracker);
         m_bottomUI.addChild(this.m_zCacheTracker);
         addChild(m_bottomUI);
         var m_hud:HUD = new HUD();
         addChild(m_hud);
         GlobalEngine.stage.addEventListener(Event.RESIZE,this.onResize);
         this.onResize(null);
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback("onFeaturePromo",onFeaturePromo);
               ExternalInterface.addCallback("refreshBalance",refreshBalance);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      public static function showBushelReportWindow(seedItemName:String = null, multiPlot:Boolean = false, harvestMode:Boolean = false) : void
      {
         if(BushelReportActionDropHandler.canPlayerSeeFeature())
         {
            if(Boolean(Global.ui.bushelReportWindow) && BushelReportWindow.isWindowOpen())
            {
               Global.ui.bushelReportWindow.setActiveSeedItemName(seedItemName,multiPlot,harvestMode);
            }
            else
            {
               Global.ui.bushelReportWindow = new BushelReportWindow(seedItemName,multiPlot,harvestMode);
               HudWidgetManager.instance.add(Global.ui.bushelReportWindow);
            }
         }
      }
      
      public static function getEnablePopups() : Boolean
      {
         return m_enablePopups;
      }
      
      public static function get suppressPopupQueue() : Boolean
      {
         return m_suppressPopupQueue;
      }
      
      public static function set suppressPopupQueue(value:Boolean) : void
      {
         m_suppressPopupQueue = value;
      }
      
      public static function onZoomInClick(event:MouseEvent) : void
      {
         FarmGame.cbTrace("UI onZoomInClick");
         var viewport:FarmIsoViewport = GlobalEngine.viewport as FarmIsoViewport;
         if(viewport.zoomIn())
         {
            FarmStatsManager.count(UI_BUTTON_CLICKS_COUNTER,"zoom_in",viewport.getZoom().toFixed(3));
            FarmStatsManager.countOncePerSession("zoom_once","zoom_in");
         }
      }
      
      public static function onZoomOutClick(event:MouseEvent) : void
      {
         FarmGame.cbTrace("UI onZoomOutClick");
         var viewport:FarmIsoViewport = GlobalEngine.viewport as FarmIsoViewport;
         if(viewport.zoomOut())
         {
            FarmStatsManager.count(UI_BUTTON_CLICKS_COUNTER,"zoom_out",viewport.getZoom().toFixed(3));
            FarmStatsManager.countOncePerSession("zoom_once","zoom_out");
         }
      }
      
      public static function confirmAddNeighbor() : void
      {
         var confirmMessage:String = null;
         var reserveLotObj:DisplayObject = Global.stage.getChildByName("reserveLotPopup");
         if(reserveLotObj == null)
         {
            confirmMessage = ZLocUtils.t("FarmGame","ReserveLot");
            UI.displayPopup(new GenericPopup(confirmMessage,GenericPopup.TYPE_YESNO,onConfirmReserve),true,"reserveLotPopup",true);
         }
      }
      
      protected static function onConfirmReserve(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            MFSRequestManager.getInstance().displayR2AddNeighborWindow("neighborsInvitePage");
         }
      }
      
      public static function showMessage(message:String, buttonConfig:int = 1, title:String = null, imageUrl:String = null, closeButton:Boolean = true, actionCallback:Function = null, name:String = null, addToQueue:Boolean = false, acceptText:String = null) : GenericDialog
      {
         FarmGame.cbTrace("UI showMessage " + message);
         var config:GenericDialogConfig = new GenericDialogConfig();
         config.setBodyText(message);
         config.setTitleText(title);
         config.setImageUrl(imageUrl);
         config.showCloseButton(closeButton);
         config.setName(name);
         if(acceptText == null)
         {
            acceptText = ZLocUtils.t("Dialogs","OkButton");
         }
         switch(buttonConfig)
         {
            case BUTTON_LAYOUT_NONE:
               closeButton = true;
               break;
            case BUTTON_LAYOUT_OK:
               config.addButton(ZLocUtils.t("Dialogs","OkButton"),GenericDialogConfig.COLOR_GREEN,actionCallback);
               break;
            case BUTTON_LAYOUT_ACCEPT:
               config.addButton(acceptText,GenericDialogConfig.COLOR_GREEN,actionCallback);
               break;
            case BUTTON_LAYOUT_ACCEPT_CANCEL:
               config.addButton(acceptText,GenericDialogConfig.COLOR_GREEN,actionCallback);
               config.addButton(ZLocUtils.t("Dialogs","Cancel"),GenericDialogConfig.COLOR_RED);
               break;
            case BUTTON_LAYOUT_YES_NO:
               config.addButton(ZLocUtils.t("Dialogs","Yes"),GenericDialogConfig.COLOR_GREEN,actionCallback);
               config.addButton(ZLocUtils.t("Dialogs","NoThanks"),GenericDialogConfig.COLOR_RED);
               break;
            case BUTTON_LAYOUT_SHARE_CANCEL:
               config.addButton(ZLocUtils.t("Dialogs","ShareButton"),GenericDialogConfig.COLOR_BLUE,actionCallback);
               config.addButton(ZLocUtils.t("Dialogs","Cancel"),GenericDialogConfig.COLOR_RED);
               break;
            case BUTTON_LAYOUT_SHARE:
               config.addButton(ZLocUtils.t("Dialogs","ShareButton"),GenericDialogConfig.COLOR_BLUE,actionCallback);
         }
         var dialog:GenericDialog = GenericDialog.createFromConfig(config);
         if(dialog)
         {
            dialog.show(addToQueue);
         }
         return dialog;
      }
      
      public static function displayMessageWithHtml(message:String, type:int = 0, closeHandler:Function = null, dialogName:String = "", displayImmediately:Boolean = false, checkDuplicates:Boolean = false) : GenericPopup
      {
         FarmGame.cbTrace("UI displayMessageWithHtml " + message);
         var dialog:GenericPopup = new GenericPopup(message,type,closeHandler,GenericPopup.GENERIC_ASSET,"",true);
         if(type == GenericPopup.TYPE_OK || type == GenericPopup.TYPE_ACCEPTCANCEL)
         {
            dialog.setAcceptTextName("Okay");
         }
         dialog.name = dialogName;
         UI.displayPopup(dialog,!displayImmediately,dialogName,checkDuplicates);
         return dialog;
      }
      
      public static function displayMessage(message:String, type:int = 0, closeHandler:Function = null, dialogName:String = "", displayImmediately:Boolean = false, checkDuplicates:Boolean = false, trackerKey:String = "") : GenericPopup
      {
         FarmGame.cbTrace("UI displayMessage " + message);
         var dialog:GenericPopup = null;
         var dialogAsset:String = GenericPopup.GENERIC_ASSET;
         if(message.length > GenericPopup.GENERIC_ASSET_MED_MAX_MSG_LEN)
         {
            dialogAsset = GenericPopup.GENERIC_ASSET_LRG;
         }
         else if(message.length > GenericPopup.GENERIC_ASSET_MAX_MSG_LEN)
         {
            dialogAsset = GenericPopup.GENERIC_ASSET_MED;
         }
         dialog = new GenericPopup(message,type,closeHandler,dialogAsset);
         if(type == GenericPopup.TYPE_OK || type == GenericPopup.TYPE_ACCEPTCANCEL)
         {
            dialog.setAcceptTextName("Okay");
         }
         dialog.name = dialogName;
         dialog.setTrackerKey(trackerKey);
         UI.displayPopup(dialog,!displayImmediately,dialogName,checkDuplicates);
         return dialog;
      }
      
      public static function displayMessageWithOffset(message:String, offset:Point, type:int = 0, closeHandler:Function = null, dialogName:String = "", displayImmediately:Boolean = false, checkDuplicates:Boolean = false, trackerKey:String = "") : GenericPopup
      {
         FarmGame.cbTrace("UI displayMessageWithOffset " + message);
         var dialog:GenericPopup = null;
         var dialogAsset:String = GenericPopup.GENERIC_ASSET;
         if(message.length > GenericPopup.GENERIC_ASSET_MED_MAX_MSG_LEN)
         {
            dialogAsset = GenericPopup.GENERIC_ASSET_LRG;
         }
         else if(message.length > GenericPopup.GENERIC_ASSET_MAX_MSG_LEN)
         {
            dialogAsset = GenericPopup.GENERIC_ASSET_MED;
         }
         dialog = new GenericPopup(message,type,closeHandler,dialogAsset);
         if(type == GenericPopup.TYPE_OK || type == GenericPopup.TYPE_ACCEPTCANCEL)
         {
            dialog.setAcceptTextName("Okay");
         }
         dialog.name = dialogName;
         dialog.setTrackerKey(trackerKey);
         UI.displayPopupWithOffset(dialog,offset,!displayImmediately,dialogName,checkDuplicates);
         return dialog;
      }
      
      public static function displayCustomMessage(message:String, type:int = 0, closeHandler:Function = null, dialogName:String = "", displayImmediately:Boolean = false, checkDuplicates:Boolean = false, trackerKey:String = "", acceptText:String = "", cancelText:String = "", dialogPath:String = "") : GenericPopup
      {
         var dialogAsset:String = GenericPopup.GENERIC_ASSET;
         if(message.length > GenericPopup.GENERIC_ASSET_MED_MAX_MSG_LEN)
         {
            dialogAsset = GenericPopup.GENERIC_ASSET_LRG;
         }
         else if(message.length > GenericPopup.GENERIC_ASSET_MAX_MSG_LEN)
         {
            dialogAsset = GenericPopup.GENERIC_ASSET_MED;
         }
         var dialog:GenericPopup = new GenericPopup(message,type,closeHandler,dialogAsset);
         if(type == GenericPopup.TYPE_OK || type == GenericPopup.TYPE_ACCEPTCANCEL)
         {
            if(acceptText)
            {
               dialog.setAcceptTextName(acceptText);
            }
            else
            {
               dialog.setAcceptTextName("Okay");
            }
            if(cancelText)
            {
               dialog.setCancelTextName(cancelText);
            }
            else
            {
               dialog.setCancelTextName("Cancel");
            }
         }
         dialog.name = dialogName;
         dialog.setTrackerKey(trackerKey);
         UI.displayPopup(dialog,!displayImmediately,dialogName,checkDuplicates);
         return dialog;
      }
      
      public static function displayStatus(message:String, screenX:Number, screenY:Number, iconUrl:String = "", iconFilters:Array = null, tweenDuration:Number = 1.5, tweenDisplacement:int = 32, fontSize:int = 16, fontColor:Object = null) : void
      {
         var statusText:StrokeTextField = null;
         var icon:Loader = null;
         FarmGame.cbTrace("UI displayStatus " + message);
         statusText = new StrokeTextField(2105376,0.8);
         statusText.toolTipText = message;
         statusText.setTextFormat(new TextFormat("Arial",fontSize,fontColor,true));
         statusText.x = screenX;
         statusText.y = screenY;
         Global.stage.addChild(statusText);
         statusText.x = screenX - statusText.textWidth / 2;
         TweenStatusObject(statusText,tweenDuration,tweenDisplacement);
         if(iconUrl != "" && iconUrl != null)
         {
            icon = LoadingManager.load(iconUrl,function(event:Event):void
            {
               var dispObj:* = undefined;
               var iconWidth:* = undefined;
               if(Boolean(icon) && Boolean(icon.content))
               {
                  dispObj = icon.content;
                  iconWidth = 60;
                  dispObj.x = statusText.x - iconWidth - 5;
                  dispObj.y = statusText.y - 10;
                  dispObj.width = iconWidth;
                  dispObj.height = iconWidth;
                  if(iconFilters != null)
                  {
                     dispObj.filters = iconFilters;
                  }
                  Global.stage.addChild(dispObj);
                  TweenStatusObject(dispObj,tweenDuration,tweenDisplacement);
               }
            });
         }
      }
      
      public static function displayTransactionLogs(logData:String) : void
      {
         showMessage(logData);
      }
      
      public static function TweenStatusObject(dispObj:DisplayObject, duration:Number, displacement:int) : void
      {
         TweenLite.to(dispObj,duration,{
            "alpha":0,
            "ease":Quadratic.easeIn
         });
         TweenLite.to(dispObj,duration,{
            "overwrite":0,
            "y":dispObj.y - displacement,
            "onComplete":function():void
            {
               if(dispObj.parent)
               {
                  dispObj.parent.removeChild(dispObj);
               }
            }
         });
      }
      
      public static function stopPopups(stop:Boolean) : void
      {
         m_enablePopups = !stop;
         if(!stop)
         {
            pumpPopupQueue();
         }
      }
      
      public static function tracePopupQueue(reason:String) : void
      {
         var popups:String = reason + ": ";
         var i:int = 0;
         while(i < m_popupQueue.length && m_popupQueue.length > 0)
         {
            popups += m_popupQueue[i] + ", ";
            i++;
         }
      }
      
      protected static function closeCurrentDialogs() : void
      {
         if(m_currentDialog != null)
         {
            if(m_currentDialog is Dialog)
            {
               (m_currentDialog as Dialog).close();
            }
            else if(m_currentDialog is FarmWindow)
            {
               (m_currentDialog as FarmWindow).close();
            }
            else if(m_currentDialog is FarmDynamicDialog)
            {
               (m_currentDialog as FarmDynamicDialog).destroy();
            }
         }
      }
      
      public static function clearPopupQueue() : void
      {
         Global.popupManager.clearInactiveUserActions();
         if(m_popupQueue.length > 0)
         {
            m_popupQueue = [];
         }
         closeCurrentDialogs();
      }
      
      public static function getCurrentPopup() : DisplayObject
      {
         return m_currentDialog;
      }
      
      public static function removeFromPopupQueue(displayObj:DisplayObject = null, popupName:String = "") : void
      {
         var i:int = 0;
         if(displayObj != null || popupName != null && popupName != "")
         {
            if(m_popupQueue.length > 0)
            {
               i = 0;
               while(i < m_popupQueue.length && m_popupQueue.length > 0)
               {
                  if(displayObj != null && m_popupQueue[i] == displayObj || popupName != null && popupName != "" && m_popupQueue[i].name == popupName)
                  {
                     m_popupQueue.splice(i,1);
                  }
                  else
                  {
                     i++;
                  }
               }
            }
            if(m_currentDialog != null)
            {
               if(m_currentDialog == displayObj || popupName != null && popupName != "" && m_popupQueue[i].name == popupName)
               {
                  closeCurrentDialogs();
                  if(UI.m_enablePopups)
                  {
                     pumpPopupQueue();
                  }
               }
            }
         }
      }
      
      public static function displayPopup(displayObj:DisplayObject, addToQueue:Boolean = true, popupName:String = "", checkDuplicates:Boolean = false, forceAddToQueueStart:Boolean = false) : void
      {
         var dialog:Dialog = null;
         var xmlDialog:GenericXMLDialog = null;
         var qualifiedClassName:String = null;
         var qualifiedSuperClassName:String = null;
         var queueX:int = 0;
         var popup:Dialog = null;
         displayObj.name = popupName;
         var popupManager:SmartPopupManager = SmartPopupManager.getInstance();
         if(false && Config.DEBUG_MODE)
         {
         }
         if(displayObj as Dialog)
         {
            dialog = displayObj as Dialog;
            if(popupManager.suppressPopup(dialog.getTrackerKey()))
            {
               if(displayObj as GenericXMLDialog)
               {
                  xmlDialog = displayObj as GenericXMLDialog;
                  xmlDialog.forceClose();
               }
               else
               {
                  dialog.dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.NO));
               }
               return;
            }
         }
         if(!Global.nopopupManager.canDisplayPopup(displayObj))
         {
            if(Config.DEBUG_MODE)
            {
               qualifiedClassName = getQualifiedClassName(displayObj);
               qualifiedSuperClassName = getQualifiedSuperclassName(displayObj);
            }
            return;
         }
         if(!m_suppressPopupQueue)
         {
            if(addToQueue)
            {
               if(checkDuplicates && popupName != "")
               {
                  if(m_currentDialog != null && m_currentDialog.name == popupName)
                  {
                     addToQueue = false;
                  }
                  else
                  {
                     for(queueX = 0; queueX < m_popupQueue.length; queueX++)
                     {
                        if(m_popupQueue[queueX].name == popupName)
                        {
                           addToQueue = false;
                           break;
                        }
                     }
                  }
               }
               if(addToQueue)
               {
                  m_popupQueue.push(displayObj);
               }
               if(UI.m_enablePopups)
               {
                  pumpPopupQueue();
               }
            }
            else if((!FreezeManager.isAllFrozen() || UI.m_enablePopups) && Global.world.backgroundRendered && Global.preloaderComplete && !forceAddToQueueStart)
            {
               Global.stage.addChild(displayObj);
               displayObj.addEventListener(Event.CLOSE,onPopupClosed,false,0,true);
               ++m_numImmediatePopups;
               if(displayObj is Dialog)
               {
                  popup = displayObj as Dialog;
                  popup.show();
                  if(popup.getTrackerEnabled())
                  {
                     FarmStatsManager.count("dialog",popup.getTrackerKey(),"View");
                  }
               }
               else if(displayObj is FarmWindow)
               {
                  (displayObj as FarmWindow).show();
               }
               displayObj.dispatchEvent(new UIEvent(UIEvent.DISPLAYED_FROM_DIALOG_QUEUE,""));
               ToasterManager.getInstance().togglePause(true);
               FarmGame.cbTrace("UI displayPopup dialog:" + getQualifiedClassName(displayObj) + " popupName:" + popupName);
            }
            else
            {
               m_popupQueue.splice(0,0,displayObj);
            }
         }
         else if(displayObj is Dialog)
         {
            (displayObj as Dialog).close();
         }
         else if(displayObj is FarmWindow)
         {
            (displayObj as FarmWindow).close();
         }
      }
      
      public static function displayPopupWithOffset(displayObj:DisplayObject, offset:Point, addToQueue:Boolean = true, popupName:String = "", checkDuplicates:Boolean = false, forceAddToQueueStart:Boolean = false) : void
      {
         var popup:Dialog = null;
         if(displayObj is Dialog)
         {
            popup = displayObj as Dialog;
            popup.setDialogOffset(offset);
         }
         displayPopup(displayObj,addToQueue,popupName,checkDuplicates,forceAddToQueueStart);
      }
      
      public static function get canDisplayHoverWindows() : Boolean
      {
         return (!FreezeManager.isAllFrozen() || UI.m_enablePopups) && Global.world.backgroundRendered && Global.preloaderComplete;
      }
      
      public static function addHoverWindow(hoverWindowDisplayObject:DisplayObject) : void
      {
         if(canDisplayHoverWindows)
         {
            addHoverWindowToContainer(hoverWindowDisplayObject);
         }
         else
         {
            s_pendingHoverWindows.push(hoverWindowDisplayObject);
         }
      }
      
      private static function addHoverWindowToContainer(hoverWindowDisplayObject:DisplayObject) : void
      {
         if(s_hoverWindowContainer == null)
         {
            s_hoverWindowContainer = new Sprite();
            Global.ui.addChildAt(s_hoverWindowContainer,0);
         }
         s_hoverWindowContainer.addChild(hoverWindowDisplayObject);
      }
      
      public static function displayPendingHoverWindows() : void
      {
         var hoverWindow:DisplayObject = null;
         if(canDisplayHoverWindows)
         {
            while(s_pendingHoverWindows.length > 0)
            {
               hoverWindow = s_pendingHoverWindows.shift() as DisplayObject;
               addHoverWindowToContainer(hoverWindow);
            }
         }
      }
      
      public static function bringToFront(focusDisplayObject:DisplayObject) : void
      {
         var tmpParent:DisplayObjectContainer = null;
         if(focusDisplayObject.parent != null)
         {
            tmpParent = focusDisplayObject.parent;
            tmpParent.removeChild(focusDisplayObject);
            tmpParent.addChild(focusDisplayObject);
         }
      }
      
      protected static function onPopupClosed(event:Event) : void
      {
         if(m_currentDialog == event.target)
         {
            m_currentDialog = null;
         }
         --m_numImmediatePopups;
         event.currentTarget.removeEventListener(Event.CLOSE,onPopupClosed);
         pumpPopupQueue();
      }
      
      protected static function onQueuedPopupClosed(event:Event) : void
      {
         m_currentDialog = null;
         event.currentTarget.removeEventListener(Event.CLOSE,onQueuedPopupClosed);
         pumpPopupQueue();
      }
      
      public static function isShowingPopup() : Boolean
      {
         return false == (null == m_currentDialog && 0 == m_numImmediatePopups);
      }
      
      public static function pumpPopupQueue() : void
      {
         var results:Array = null;
         var displayObj:DisplayObject = null;
         var view:BaseWidgetView = null;
         var dialog:DynamicDialog = null;
         var popup:Dialog = null;
         if(InitializationManager.getInstance().haveAllCompleted() && Global.world.backgroundRendered && Global.preloaderComplete)
         {
            if(Boolean(m_popupQueue.length) && m_currentDialog == null)
            {
               results = m_popupQueue.splice(0,1);
               displayObj = results[0] as DisplayObject;
               if(displayObj)
               {
                  displayObj.addEventListener(Event.CLOSE,onQueuedPopupClosed,false,0,true);
                  Global.stage.addChild(displayObj);
                  m_currentDialog = displayObj;
                  if(displayObj is Dialog)
                  {
                     (displayObj as Dialog).show();
                  }
                  else if(displayObj is FarmWindow)
                  {
                     (displayObj as FarmWindow).show();
                  }
                  else if(displayObj is BaseWidgetView)
                  {
                     view = displayObj as BaseWidgetView;
                     dialog = view.getController() as DynamicDialog;
                     if(dialog)
                     {
                        dialog.recenter();
                     }
                  }
                  ToasterManager.getInstance().togglePause(true);
                  if(m_currentDialog != null)
                  {
                     m_currentDialog.dispatchEvent(new UIEvent(UIEvent.DISPLAYED_FROM_DIALOG_QUEUE,""));
                  }
                  if(displayObj as Dialog)
                  {
                     popup = displayObj as Dialog;
                     if(popup.getTrackerEnabled())
                     {
                        FarmStatsManager.count("dialog",popup.getTrackerKey(),"View");
                     }
                  }
                  FarmGame.cbTrace("UI pumpPopupQueue dialog:" + UI.getCurrentPopupName());
               }
            }
            else if(0 == m_numImmediatePopups && null == m_currentDialog && 0 == m_popupQueue.length && FreezeManager.isAnythingFrozen())
            {
               FreezeManager.thaw(true);
               ToasterManager.getInstance().togglePause(false);
            }
         }
      }
      
      public static function get numberOfPopupsInQueue() : int
      {
         var result:int = 0;
         if(m_currentDialog != null)
         {
            result++;
         }
         return int(result + m_popupQueue.length);
      }
      
      public static function displayMenu(items:Array, clickCallback:Function, bgColor:uint = 16777215, rollOverColor:uint = 11723263, friendBarException:Boolean = false) : void
      {
         var style:Object = null;
         var yPos:Number = NaN;
         FarmGame.cbTrace("UI displayMenu items:" + com.adobe.serialization.json.JSON.encode(items));
         if(Global.worldManager.isVisiting() == false || friendBarException)
         {
            style = {"contextMenuItem":{
               "backgroundColor":bgColor,
               "hoverBackgroundColor":rollOverColor
            }};
            hideMenu();
            m_menu = new ContextMenu(items,style);
            m_menu.addEventListener(MouseEvent.CLICK,clickCallback);
            yPos = Math.min(Global.stage.mouseY,Global.stage.stageHeight - m_menu.height - SCREEN_MENU_BUFFER);
            m_menu.show(Global.stage.mouseX,yPos);
         }
      }
      
      public static function hideMenu() : void
      {
         if(m_menu != null)
         {
            m_menu.hide();
            m_menu = null;
         }
      }
      
      public static function onStageMouseMove(event:MouseEvent) : void
      {
         if(Boolean(m_currentCursor) && Boolean(m_currentCursor.displayObj))
         {
            m_currentCursor.displayObj.x = event.stageX;
            m_currentCursor.displayObj.y = event.stageY;
         }
      }
      
      public static function hasCursor(cursorId:int) : Boolean
      {
         var cursor:Object = null;
         var result:Boolean = false;
         for(var cursorIdx:int = 0; cursorIdx < m_cursors.length; cursorIdx++)
         {
            cursor = m_cursors[cursorIdx];
            if(cursor.id == cursorId)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public static function setCursor(cursor:Object, keepSystemCursor:Boolean = false, scaleCursor:Boolean = true, maxCursorSize:Number = 48) : int
      {
         var cursorImage:DisplayObject = null;
         var width:Number = NaN;
         var height:Number = NaN;
         var scale:Number = NaN;
         maxCursorSize = maxCursorSize;
         if(cursor is DisplayObject)
         {
            cursorImage = cursor as DisplayObject;
         }
         else if(cursor is Class)
         {
            cursorImage = new (cursor as Class)();
         }
         var result:int = Constants.INDEX_NONE;
         var cursorInfo:Object = {
            "displayObj":cursorImage,
            "id":Utilities.generateUniqueId(),
            "keepSystemCursor":keepSystemCursor
         };
         if(cursorImage)
         {
            if(cursorImage.loaderInfo)
            {
               width = cursorImage.loaderInfo.width;
            }
            else
            {
               width = cursorImage.width;
            }
            if(cursorImage.loaderInfo)
            {
               height = cursorImage.loaderInfo.height;
            }
            else
            {
               height = cursorImage.height;
            }
            if(scaleCursor)
            {
               scale = Math.min(1,maxCursorSize / width,maxCursorSize / height);
               cursorImage.scaleX = cursorImage.scaleY = scale;
            }
         }
         m_cursors.push(cursorInfo);
         updateCurrentCursor();
         return int(cursorInfo.id);
      }
      
      public static function removeCursor(cursorId:int) : void
      {
         var cursor:Object = null;
         for(var cursorIdx:int = 0; cursorIdx < m_cursors.length; cursorIdx++)
         {
            cursor = m_cursors[cursorIdx];
            if(cursor.id == cursorId)
            {
               m_cursors.splice(cursorIdx,1);
               break;
            }
         }
         updateCurrentCursor();
      }
      
      public static function removeAllCursors() : void
      {
         m_cursors = [];
         updateCurrentCursor();
      }
      
      public static function getCursorInfo(cursorId:int) : Object
      {
         var cursor:Object = null;
         var result:Object = null;
         for(var cursorIdx:int = 0; cursorIdx < m_cursors.length; cursorIdx++)
         {
            cursor = m_cursors[cursorIdx];
            if(cursor.id == cursorId)
            {
               result = cursor;
               break;
            }
         }
         return result;
      }
      
      public static function updateCurrentCursorWithVisibility(visible:Boolean) : void
      {
         var currentCursor:Object = null;
         if(visible)
         {
            Mouse.hide();
         }
         else
         {
            Mouse.show();
         }
         if(m_cursors.length)
         {
            currentCursor = m_cursors[m_cursors.length - 1];
            if(Boolean(currentCursor) && Boolean(currentCursor.displayObj))
            {
               currentCursor.displayObj.visible = visible;
            }
         }
      }
      
      public static function updateCurrentCursor(forceRedraw:Boolean = false) : void
      {
         var newCursor:Object = null;
         if(m_cursors.length)
         {
            newCursor = m_cursors[m_cursors.length - 1];
            if(Boolean(newCursor.keepSystemCursor) || newCursor.displayObj == null)
            {
               Mouse.show();
            }
            else
            {
               Mouse.hide();
            }
         }
         else
         {
            Mouse.show();
         }
         if(newCursor != m_currentCursor || forceRedraw)
         {
            if(Boolean(m_currentCursor) && Boolean(m_currentCursor.displayObj) && Boolean(m_currentCursor.displayObj.parent))
            {
               m_currentCursor.displayObj.parent.removeChild(m_currentCursor.displayObj);
            }
            m_currentCursor = newCursor;
            if(Boolean(m_currentCursor) && Boolean(m_currentCursor.displayObj))
            {
               m_currentCursor.displayObj.x = Global.stage.mouseX;
               m_currentCursor.displayObj.y = Global.stage.mouseY;
               if(m_currentCursor.displayObj.hasOwnProperty("mouseChildren"))
               {
                  m_currentCursor.displayObj.mouseChildren = false;
               }
               if(m_currentCursor.displayObj.hasOwnProperty("mouseEnabled"))
               {
                  m_currentCursor.displayObj.mouseEnabled = false;
               }
               Global.stage.addChild(m_currentCursor.displayObj);
            }
         }
      }
      
      public static function displayWorldScoreLevelUpDialog(scoreUnit:String, newLevel:int) : void
      {
         var worldId:String = null;
         var expansionData:ExpansionData = null;
         var cancelCallback:Function = null;
         var shareCallback:Function = null;
         var levelUpDialogUrl:String = null;
         var levelUp:LevelUpWorldScoreWindow = null;
         var canShowDialog:Boolean = false;
         for each(worldId in WorldsConstants.ALL_WORLDS)
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
            if(Boolean(expansionData) && (Boolean(expansionData.scoreId == scoreUnit || expansionData.score2Id == scoreUnit)) && Global.worldManager.hasUnlockedWorld(worldId))
            {
               canShowDialog = true;
               break;
            }
         }
         if(canShowDialog)
         {
            cancelCallback = function(event:MouseEvent = null):void
            {
               TransactionManager.addTransaction(new TShareWorldScoreLevelUpReward(scoreUnit,newLevel,false,null),true);
            };
            shareCallback = function(event:MouseEvent = null):void
            {
               TransactionManager.addTransaction(new TShareWorldScoreLevelUpReward(scoreUnit,newLevel,true,onWorldScoreLevelUpPublishFeed),true);
            };
            levelUpDialogUrl = Global.worldScoreSettingsManager.getLevelUpDialogUrlForScoreUnit(scoreUnit);
            levelUp = new LevelUpWorldScoreWindow(levelUpDialogUrl,newLevel,scoreUnit,cancelCallback,shareCallback);
            UI.displayPopup(levelUp);
         }
      }
      
      public static function onWorldScoreLevelUpPublishFeed(scoreUnit:String, newLevel:int, rewardLink:String = null) : void
      {
         var rewardObj:Object = null;
         var feedIcon:String = null;
         var images:Array = null;
         var bundle:String = null;
         var itemFriendlyNames:Array = null;
         var itemName:String = null;
         var totalItemFriendlyNames:int = 0;
         var itemCount:int = 0;
         var friendRewardItem:FarmItem = null;
         var name:String = Global.player.name;
         if(name.search(" ") > 0)
         {
            name = name.substring(0,name.search(" "));
         }
         var farmItem:FarmItem = null;
         var rewards:Vector.<Object> = Global.worldScoreSettingsManager.getRewardsForLevel(scoreUnit,newLevel);
         var slotCount:Number = 0;
         var totalSlots:Number = 3;
         var itemNames:Object = new Object();
         for each(rewardObj in rewards)
         {
            if(rewardObj.hasOwnProperty("type") && rewardObj.type == QuestConstants.REWARD_DISPLAY_ONLY && rewardObj.hasOwnProperty("value"))
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardObj.value);
               if(farmItem)
               {
                  itemNames[slotCount] = farmItem.name;
                  slotCount++;
               }
            }
            if(slotCount >= totalSlots)
            {
               break;
            }
         }
         feedIcon = Global.worldScoreSettingsManager.getFeedIconUrlForLevel(scoreUnit,newLevel);
         images = [{
            "src":Global.getAssetURL(feedIcon),
            "href":"{SN_APP_URL}index.php"
         }];
         bundle = scoreUnit + "WorldScoreLevelUp";
         itemFriendlyNames = new Array();
         for each(itemName in itemNames)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(farmItem)
            {
               itemFriendlyNames.push(farmItem.friendlyTitle);
            }
            if(itemFriendlyNames.length == UI.WORLDSCORE_LEVELUP_MAX_ITEMS_IN_FEED)
            {
               break;
            }
         }
         totalItemFriendlyNames = int(itemFriendlyNames.length);
         for(itemCount = totalItemFriendlyNames; itemCount < UI.WORLDSCORE_LEVELUP_MAX_ITEMS_IN_FEED; itemCount++)
         {
            if(itemFriendlyNames.length < itemCount + 1)
            {
               itemFriendlyNames[itemCount] = "";
            }
         }
         var newItemsString:String = ZLocUtils.t("Notifications",bundle + "_Items" + totalItemFriendlyNames.toString(),{
            "actor":Global.player.firstName,
            "level_number":newLevel,
            "images":images,
            "item1_name":itemFriendlyNames[0],
            "item2_name":itemFriendlyNames[1],
            "item3_name":itemFriendlyNames[2]
         });
         var bundleData:Object = {
            "level_number":newLevel,
            "first_name":Global.player.firstName,
            "images":images,
            "new_items_string":newItemsString,
            "feed_reward_string":"",
            "item1_name":itemNames[0],
            "item2_name":itemNames[1],
            "item3_name":itemNames[2],
            "reward_link":"index.php"
         };
         var friendRewardItemCode:String = Global.worldScoreSettingsManager.getFriendRewardItemForLevel(scoreUnit,newLevel);
         if(friendRewardItemCode != null && Boolean(rewardLink))
         {
            friendRewardItem = Global.farmGameSettingsManager.getFarmItemByCode(friendRewardItemCode);
            bundleData["feed_reward_string"] = ZLocUtils.t("Notifications",bundle + "_FeedRewardDesc",{
               "actor":Global.player.firstName,
               "level_number":newLevel,
               "images":images,
               "part":ZLocUtils.tk_pk_asTitlePlural(friendRewardItem.friendlyName)
            });
            bundleData["reward_link"] = rewardLink;
            bundleData["images"] = [{
               "href":"{SN_APP_URL}" + rewardLink,
               "src":Global.getAssetURL(feedIcon)
            }];
         }
         GlobalEngine.socialNetwork.publishFeedStory(bundle,bundleData,[],false);
      }
      
      public static function displayLevelUpDialog(newLevel:int) : void
      {
         var assetPath:String = null;
         var feedCheckboxFlow:Number = NaN;
         var levelUp:LevelUpWindow = null;
         var locObject:Object = null;
         var notesPopup:GenericPopup = null;
         FarmGame.cbTrace("UI displayLevelUpDialog " + newLevel);
         var levelUpCashRewardLevelCap:int = Global.farmGameSettingsManager.getLevelUpCashRewardLevelCap();
         if(newLevel == levelUpCashRewardLevelCap + 1)
         {
            UI.doLevelUpCashRewardCapPopup();
         }
         else
         {
            assetPath = "assets/dialogs/FV_LevelUp.swf";
            feedCheckboxFlow = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FEED_CHECKBOX_FLOW);
            if(feedCheckboxFlow > 1)
            {
               assetPath = "assets/dialogs/FV_levelUP_animated_checkbox.swf";
            }
            levelUp = new LevelUpWindow(assetPath,newLevel,onLevelUpWindowClosed);
            UI.displayPopup(levelUp);
         }
         var levelXML:XML = Global.farmGameSettingsManager.getLevelXML(newLevel);
         var notes:String = "";
         if(levelXML != null)
         {
            levelXML.@notes;
         }
         if(notes != "")
         {
            locObject = Utilities.parseLocalizationString(notes);
            notesPopup = new GenericPopup(ZLocUtils.t(locObject.filename,locObject.stringname));
            displayPopup(notesPopup);
         }
         if(Global.farmGameSettingsManager.getAttribute("masteryStartLevel",15) == newLevel)
         {
            displayPopup(new MasteryUnlockedPopup(newLevel));
         }
         if(Global.player.level >= Global.farmGameSettingsManager.getAttribute("collectionStartLevel",15) && !Global.player.getSeenFlag("UnlockedCollections"))
         {
         }
      }
      
      protected static function getItems(items:Array, itemType:String) : String
      {
         var outputItems:String = null;
         outputItems = ZLocUtils.t("Notifications","LevelUp_Now" + itemType) + " " + items[0];
         for(var item:Number = 1; item < items.length; item++)
         {
            if(item >= MAX_FEED_ITEMS)
            {
               outputItems += " " + ZLocUtils.t("Notifications","LevelUp_More");
               break;
            }
            outputItems += ", " + items[item];
         }
         return outputItems;
      }
      
      private static function doLevelUpCashRewardCapPopup() : void
      {
         var levelCapPlusOne:int = Global.farmGameSettingsManager.getLevelUpCashRewardLevelCap() + 1;
         var title:String = ZLocUtils.t("Dialogs","Congratulations");
         var titleMessage:String = ZLocUtils.t("Dialogs","LevelUpCap_message",{
            "levelNum":levelCapPlusOne,
            "caplevelNum":levelCapPlusOne - 1
         });
         var levelCapPopUp:GenericPopupTitle = new GenericPopupTitle(title,titleMessage,true,GenericPopup.TYPE_SHARECANCEL);
         UI.displayPopup(levelCapPopUp);
         levelCapPopUp.addEventListener(GenericPopupEvent.SELECTED,onLevelUpClosed);
      }
      
      private static function onLevelUpClosedHelper(newLevel:int) : void
      {
         var levelImage:String = null;
         var outputItems:String = null;
         var creativeBundleId:String = null;
         var levelName:String = ZLocUtils.t("Levels","Level" + newLevel);
         var giftableItems:Array = [];
         var buyableItems:Array = [];
         Global.farmGameSettingsManager.getNewLevelItems(newLevel,giftableItems,buyableItems,"seed");
         m_buyableItemStr = buyableItems.join(", ");
         var name:String = Global.player.name;
         if(name.search(" ") > 0)
         {
            name = name.substring(0,name.search(" "));
         }
         if(newLevel < 10)
         {
            levelImage = "levelup_00" + newLevel + ".png";
         }
         else if(newLevel < 100)
         {
            levelImage = "levelup_0" + newLevel + ".png";
         }
         else if(newLevel == 100)
         {
            levelImage = "levelup_100.png";
         }
         else
         {
            levelImage = "levelup_100plus.png";
         }
         var gift_item_count:int = int(giftableItems.length);
         var buy_item_count:int = int(buyableItems.length);
         if(gift_item_count == 0 && buy_item_count == 0)
         {
            outputItems = "";
         }
         else if(buy_item_count > 0 && gift_item_count == 0)
         {
            outputItems = " ";
            outputItems += getItems(buyableItems,"Grow");
         }
         else if(gift_item_count > 0 && buy_item_count == 0)
         {
            outputItems = " ";
            outputItems += getItems(giftableItems,"Gift");
         }
         else
         {
            outputItems = getItems(buyableItems,"GrowGift");
            outputItems += " ";
            outputItems += getItems(giftableItems,"GiftGrow");
         }
         var images:Array = [{
            "src":Global.getAssetURL("assets/newsfeed/" + levelImage),
            "href":"{SN_APP_URL}index.php"
         }];
         if(GlobalEngine.getFlashVar("levelUpFeed1") != null || GlobalEngine.getFlashVar("levelUpFeed2") != null && buyableItems.length == 0)
         {
            GlobalEngine.socialNetwork.publishFeedStory("LevelUp1",{
               "level_name":levelName.toString(),
               "level_number":newLevel,
               "actor":name,
               "images":GlobalEngine.socialNetwork.getDefaultFeedImages()
            },[],false);
         }
         else if(GlobalEngine.getFlashVar("levelUpFeed2") != null && buyableItems.length > 0)
         {
            GlobalEngine.socialNetwork.publishFeedStory("LevelUp2",{
               "level_name":levelName.toString(),
               "level_number":newLevel,
               "new_items":m_buyableItemStr,
               "actor":name,
               "images":GlobalEngine.socialNetwork.getDefaultFeedImages()
            },[],false);
         }
         else
         {
            creativeBundleId = newLevel < 101 ? "LevelUp" : "LevelUpPost100";
            GlobalEngine.socialNetwork.publishFeedStory(creativeBundleId,{
               "level_name":levelName.toString(),
               "level_number":newLevel,
               "images":images,
               "items":outputItems
            },[],false);
         }
      }
      
      protected static function onLevelUpWindowClosed(event:MouseEvent) : void
      {
         var newLevel:int = Global.player.level;
         UI.onLevelUpClosedHelper(newLevel);
         if(newLevel == 4 && TutController.hasFinishedTutorial())
         {
            UI.displayPopup(new ExpandFarm(14,0));
         }
      }
      
      protected static function onLevelUpClosed(event:GenericPopupEvent) : void
      {
         event.target.removeEventListener(GenericPopupEvent.SELECTED,onLevelUpClosed);
         var newLevel:int = Global.player.level;
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.onLevelUpClosedHelper(newLevel);
         }
         if(newLevel == 4 && TutController.hasFinishedTutorial())
         {
            UI.displayPopup(new ExpandFarm(14,0));
         }
      }
      
      public static function displayMarketDialog(viewSource:String = "unknown", type:String = "seed", marketLaunchReferenceIn:String = null, subCat:String = "all", closeClickCallback:Function = null, subSubType:String = null, sortBy:String = null, sortDirection:String = null, page:Number = -1, terrainCodes:Array = null, defaultTab:String = null, callback:Function = null, hideLESurfacing:Boolean = false) : Object
      {
         FarmGame.cbTrace("UI displayMarketDialog " + viewSource + "," + type + "," + marketLaunchReferenceIn + "," + subCat);
         if(type == "clothes")
         {
            Global.farmGameSettingsManager.generateAvatarClothesMenu(true);
         }
         if(type == "vehicle")
         {
            type = "aide";
            subCat = "vehicle";
         }
         if(type == "change_farm" && subCat == "expand_farm")
         {
            type = "landExpansion";
            subCat = "expansion";
         }
         if(m_marketWindow2 == null)
         {
            if(TutController.hasFinishedTutorial())
            {
               FarmStatsManager.count("Avatar","market_avatar","open_marketplace");
               MarketStatsManager.countOpenWindow(type);
               m_marketWindow2 = new MarketWindow(type,subCat,subSubType,sortBy,sortDirection,page,viewSource,false,terrainCodes,defaultTab,callback,hideLESurfacing);
            }
            else
            {
               m_marketWindow2 = new MarketMiniWindow(new Array(TutController.DEFAULT_PLANT_SEED_ITEM));
            }
            marketLaunchReference = marketLaunchReferenceIn;
            m_marketWindow2.setCloseCallback(closeClickCallback);
            m_marketWindow2.addEventListener(MarketEvent.MARKET_BUY,onMarketClick);
            m_marketWindow2.addEventListener(MarketEvent.MARKET_PRESENT,onPresentClick);
            m_marketWindow2.addEventListener(CloseEvent.CLOSE,onMarketClose);
            displayPopup(m_marketWindow2);
         }
         Global.player.setSeenSessionFlag(MarketWindow.SEEN_MARKET_SESSION_FLAG);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            m_marketWindow2.addEventListener(MarketEvent.MARKET_SHOWN,setToasterHeight);
         }
         MarketWindow.prevMiniMarketData = null;
         return m_marketWindow2;
      }
      
      private static function setToasterHeight(event:Event) : void
      {
         ToasterManager.getInstance().toasterHeight = m_marketWindow2.y + TOASTER_Y_OFFSET_TO_BE_IN_MARKET;
         m_marketWindow2.removeEventListener(MarketEvent.MARKET_SHOWN,setToasterHeight);
      }
      
      public static function displayMarketDialogAsLastTime() : MarketWindow
      {
         var lastTimeMarketWindow:MarketWindow = null;
         var MMData:MiniMarketStateData = null;
         var type:String = null;
         var subType:String = null;
         var subSubType:String = null;
         var sortBy:String = null;
         var sortDirection:String = null;
         var page:int = 0;
         if(MarketWindow.prevMiniMarketData)
         {
            MMData = MarketWindow.prevMiniMarketData;
            lastTimeMarketWindow = UI.displayMiniMarketDialog(MMData.m_itemNames,MMData.m_context,MMData.m_mmType,MMData.m_closeClickCallBack,MMData.m_addToQueue,MMData.m_showLimitedItems,MMData.m_hideCloseButton,MMData.m_checkVisible,MMData.m_featureName,true) as MarketWindow;
         }
         else
         {
            type = MarketWindow.previousType;
            subType = MarketWindow.previousSubType;
            subSubType = MarketWindow.previousSubSubType;
            sortBy = MarketWindow.previousSortBy;
            sortDirection = MarketWindow.previousSortDirection;
            page = MarketWindow.previousPage;
            lastTimeMarketWindow = UI.displayMarketDialog(UI.MARKET_CONTEXT_UNKNOWN,type,null,subType,null,subSubType,sortBy,sortDirection,page) as MarketWindow;
         }
         return lastTimeMarketWindow;
      }
      
      public static function redisplayMarketDialog(viewSource:String = "unknown", marketLaunchReferenceIn:String = null, closeClickCallback:Function = null) : Object
      {
         return UI.displayMarketDialog(viewSource,MarketWindow.previousType,marketLaunchReferenceIn,MarketWindow.previousSubType,closeClickCallback,MarketWindow.previousSubSubType,MarketWindow.previousSortBy,MarketWindow.previousSortDirection,MarketWindow.previousPage);
      }
      
      public static function updateMarketWindowItems(displayItems:Array) : void
      {
         if(m_marketWindow2 != null)
         {
            m_marketWindow2.refreshMarketWindow();
         }
      }
      
      public static function updateMarketCurrencyMeter(currencyUnit:String, amount:Number) : void
      {
         if(m_marketWindow2)
         {
            m_marketWindow2.setCurrencyTextField(currencyUnit,amount);
         }
      }
      
      public static function updateMarketCash(cashIn:Number) : void
      {
         if(m_marketWindow2)
         {
            m_marketWindow2.cashTextField = cashIn;
         }
      }
      
      public static function displayMarketPreviewWindow(item:FarmItem) : void
      {
         if(m_marketWindow2 == null)
         {
            m_marketWindow2 = new MarketWindow(null,null,null,null,null,-1,"unknown",true);
         }
         m_marketWindow2.displayMarketPreviewWindow(item,false,true);
      }
      
      public static function displaySeedSelectionMiniMarketDialog(terrain:Array, source:String = null) : void
      {
         var miniMarket:SeedSelectionMarketMiniWindow = null;
         if(m_marketWindow2 == null)
         {
            marketLaunchReference = source;
            miniMarket = new SeedSelectionMarketMiniWindow(terrain);
            marketTerrainCodes = terrain;
            miniMarket.addEventListener(MarketEvent.MARKET_BUY,onMarketClick);
            miniMarket.addEventListener(MarketEvent.MARKET_PRESENT,onPresentClick);
            miniMarket.addEventListener(CloseEvent.CLOSE,onMarketClose);
            m_marketWindow2 = miniMarket;
            displayPopup(m_marketWindow2);
         }
      }
      
      public static function displayMiniMarketDialog(itemNames:Array, viewSource:String = "unknown", type:String = "seed", closeClickCallback:Function = null, addToQueue:Boolean = true, showLimitedItems:Boolean = false, hideCloseButton:Boolean = false, checkVisible:Boolean = false, featureName:String = "", shouldReopen:Boolean = false) : Object
      {
         FarmGame.cbTrace("UI displayMiniMarketDialog itemNames:" + com.adobe.serialization.json.JSON.encode(itemNames) + " viewSource:" + viewSource);
         if(m_marketWindow2 == null)
         {
            switch(viewSource)
            {
               case UI.MINIMARKET_CONTEXT_GREENHOUSE:
                  m_marketWindow2 = new MarketMiniGreenhouseWindow(itemNames);
                  m_marketWindow2.setCloseCallback(closeClickCallback);
                  m_marketWindow2.addEventListener(MarketEvent.MARKET_BUY,onGreenhouseSeedSelection);
                  m_marketWindow2.addEventListener(CloseEvent.CLOSE,onMarketClose);
                  break;
               case UI.MINIMARKET_CONTEXT_EXPANSIONPROMPT:
                  m_marketWindow2 = new MarketMiniWindow(itemNames,hideCloseButton,checkVisible);
                  m_marketWindow2.setCloseCallback(closeClickCallback);
                  m_marketWindow2.addEventListener(MarketEvent.MARKET_BUY,onMarketClick);
                  m_marketWindow2.addEventListener(MarketEvent.MARKET_PRESENT,onPresentClick);
                  m_marketWindow2.addEventListener(CloseEvent.CLOSE,onMarketClose);
                  m_marketWindow2.addEventListener(Event.ADDED_TO_STAGE,onMarketShownFromExpansionPrompt);
                  break;
               case UI.MINIMARKET_CONTEXT_CHARITY:
                  m_marketWindow2 = new MarketMiniCharityWindow(itemNames,featureName,hideCloseButton,checkVisible);
                  m_marketWindow2.setCloseCallback(closeClickCallback);
                  m_marketWindow2.addEventListener(MarketEvent.MARKET_BUY,onMarketClick);
                  m_marketWindow2.addEventListener(MarketEvent.MARKET_PRESENT,onPresentClick);
                  m_marketWindow2.addEventListener(CloseEvent.CLOSE,onMarketClose);
                  break;
               case UI.MINIMARKET_CONTEXT_VIP:
                  m_marketWindow2 = new MarketMiniVIPWindow(itemNames,hideCloseButton,checkVisible);
                  m_marketWindow2.setCloseCallback(closeClickCallback);
                  m_marketWindow2.addEventListener(MarketEvent.MARKET_BUY,onMarketClick);
                  m_marketWindow2.addEventListener(MarketEvent.MARKET_PRESENT,onPresentClick);
                  m_marketWindow2.addEventListener(CloseEvent.CLOSE,onMarketClose);
                  break;
               default:
                  m_marketWindow2 = new MarketMiniWindow(itemNames,hideCloseButton,checkVisible);
                  m_marketWindow2.setCloseCallback(closeClickCallback);
                  m_marketWindow2.addEventListener(MarketEvent.MARKET_BUY,onMarketClick);
                  m_marketWindow2.addEventListener(MarketEvent.MARKET_PRESENT,onPresentClick);
                  m_marketWindow2.addEventListener(CloseEvent.CLOSE,onMarketClose);
            }
            displayPopup(m_marketWindow2,addToQueue);
            if(shouldReopen)
            {
               MarketWindow.prevMiniMarketData = new MiniMarketStateData(itemNames,viewSource,type,closeClickCallback,addToQueue,showLimitedItems,hideCloseButton,checkVisible,featureName);
            }
            else
            {
               MarketWindow.prevMiniMarketData = null;
            }
         }
         return m_marketWindow2;
      }
      
      private static function onGreenhouseSeedSelection(event:MarketEvent) : void
      {
      }
      
      protected static function removeMarketEventListeners() : void
      {
         if(m_marketWindow2)
         {
            m_marketWindow2.removeEventListener(CloseEvent.CLOSE,onMarketClose);
            m_marketWindow2.removeEventListener(MarketEvent.MARKET_BUY,onMarketClick);
            m_marketWindow2.removeEventListener(MarketEvent.MARKET_PRESENT,onPresentClick);
         }
      }
      
      protected static function removeStorageEventListeners() : void
      {
         m_storageDialog.removeEventListener(MarketEvent.MARKET_GIFT,onStorageClick);
         m_storageDialog.removeEventListener(CloseEvent.CLOSE,onStorageClose);
      }
      
      public static function refreshStorageDialog() : void
      {
         if(m_storageDialog != null)
         {
            m_storageDialog.refreshLayout(true);
         }
      }
      
      public static function closeMarketDialog() : void
      {
         if(m_marketWindow2 != null)
         {
            m_marketWindow2.close();
            m_marketWindow2 = null;
         }
      }
      
      public static function isMarketWindowOpen() : Boolean
      {
         return m_marketWindow2 != null;
      }
      
      public static function enableMarketFlashSaleUI(enable:Boolean = true) : void
      {
         if(m_marketWindow2 != null)
         {
            if(enable)
            {
               m_marketWindow2.addMarketFlashSale();
            }
            else
            {
               m_marketWindow2.removeMarketFlashSale();
            }
         }
      }
      
      public static function enableMarketDialog() : void
      {
         if(m_marketWindow2 != null)
         {
            m_marketWindow2.toggleInput(true);
         }
      }
      
      public static function displayCraftingCottagesMiniMarketDialog() : Object
      {
         var item:FarmItem = null;
         var cottages:Array = Global.farmGameSettingsManager.getItemsByClassArray("CraftingCottageBuilding");
         var cottageNames:Array = new Array();
         for each(item in cottages)
         {
            cottageNames.push(item.name);
         }
         return UI.displayMiniMarketDialog(cottageNames);
      }
      
      public static function displayGiftBoxWindow(allowInterstitial:Boolean = false, searchString:String = "", fromActionMenu:Boolean = false) : void
      {
         var getGiftBoxError:TGetGiftBoxErrors = null;
         var giftCount:int = 0;
         var conditionalMessageShown:Boolean = false;
         var warningLimit:Number = NaN;
         FarmGame.cbTrace("UI displayGiftBoxWindow");
         if(m_giftBoxWindow == null)
         {
            if(m_showGiftingInterstitial && allowInterstitial)
            {
               m_showGiftingInterstitial = false;
               ExternalInterface.call("theFarmOverlay.showInGameGiftingInterstitialOverlay");
               FarmStatsManager.sample(100,"fv_fbml_depr_inspect","showInGameGiftingInterstitialOverlay","called");
            }
            getGiftBoxError = new TGetGiftBoxErrors();
            TransactionManager.addTransaction(getGiftBoxError);
            giftCount = Global.player.getGiftCount();
            if(giftCount > 0)
            {
               conditionalMessageShown = false;
               warningLimit = Number(GlobalEngine.getFlashVar("GIFTBOX_TOTAL_ITEM_LIMIT")) * Global.farmGameSettingsManager.getNumber("giftLimitWarningThreshold");
               if(!Global.player.getFeatureLastShown(GiftBoxWindow.TOO_MANY_GIFTS_SEEN) && giftCount > warningLimit)
               {
                  Global.player.setFeatureLastShown(GiftBoxWindow.TOO_MANY_GIFTS_SEEN,GlobalEngine.serverTime,true);
                  UI.displayMessage(ZLocUtils.t("Dialogs","TooManyGifts"),GenericPopup.TYPE_OK);
               }
               else if(fromActionMenu)
               {
                  conditionalMessageShown = GiftBoxUseAllManager.conditionallyShowVirtualStorageDecorationHoardingMessage();
               }
               if(GlobalEngine.getFlashVar("FEATURE_FLASHPARAM_GIFTBOX_EXPANSION") > 0 && !Global.player.getSeenFlag("giftbox_expansion_5000"))
               {
                  UI.displayMessage(ZLocUtils.t("Dialogs","GiftboxItemLimitExpansion"),GenericPopup.TYPE_OK);
                  Global.player.setSeenFlag("giftbox_expansion_5000");
               }
               if(QuestConsumableBoxMigrationNotificationPopup.canShow())
               {
                  QuestConsumableBoxMigrationNotificationPopup.showDialog();
               }
               if(searchString)
               {
                  if(UI.windowState == null)
                  {
                     UI.windowState = {"giftbox":{}};
                  }
                  else if(UI.windowState.giftbox == null)
                  {
                     UI.windowState.giftbox = {};
                  }
                  UI.windowState.giftbox["searchString"] = searchString;
               }
               if(!conditionalMessageShown)
               {
                  m_giftBoxWindow = new GiftBoxWindow();
                  UI.displayPopup(m_giftBoxWindow);
                  m_giftBoxWindow.addEventListener(CloseEvent.CLOSE,onGiftBoxWindowClose);
                  UI.stopPopups(true);
                  FarmGame.cbTrace("UI displayGiftBoxWindow no conditionalMessageShown");
               }
               else
               {
                  FarmGame.cbTrace("UI displayGiftBoxWindow conditionalMessageShown");
               }
            }
            else if(Global.farmSocialNetwork.getSocialNetworkId() == FarmSocialNetwork.SNID_FACEBOOK)
            {
               FarmStatsManager.count("farmville_sell_gift_screen","click_sell_all_item","gifts_empty_impression");
               UI.displayMessage(ZLocUtils.t("Dialogs","NoMoreGifts"),GenericPopup.TYPE_YESNO,noMoreGiftsHandler,"noMoreGiftsHandler",true);
            }
         }
      }
      
      public static function refreshGiftBoxWindow() : Boolean
      {
         var result:Boolean = false;
         if(m_giftBoxWindow != null)
         {
            m_giftBoxWindow.reload();
            result = true;
         }
         return result;
      }
      
      private static function onGiftBoxWindowClose(event:Event) : void
      {
         if(m_giftBoxWindow)
         {
            m_giftBoxWindow.removeEventListener(CloseEvent.CLOSE,onGiftBoxWindowClose);
            m_giftBoxWindow = null;
            UI.stopPopups(false);
         }
      }
      
      public static function closeGifts() : void
      {
         if(m_giftBoxWindow)
         {
            m_giftBoxWindow.close();
         }
      }
      
      public static function closeAndLockGifts() : void
      {
         closeGifts();
         UI.m_isGiftBoxLocked = true;
      }
      
      public static function unlockGifts() : void
      {
         UI.m_isGiftBoxLocked = false;
         Global.ui.dispatchEvent(new UIEvent(UIEvent.GIFTBOX_UNLOCKED,""));
         if(Global.flashHotParams["TMP_GIFTBOX_ICON_REFRESH_FIX"])
         {
            Global.ui.getActionMenu().refreshGiftboxIcon();
         }
      }
      
      public static function lockGifts() : void
      {
         UI.m_isGiftBoxLocked = true;
      }
      
      public static function areGiftsLocked() : Boolean
      {
         return UI.m_isGiftBoxLocked;
      }
      
      public static function displayStorageDialog(dialog:SlotDialog, addToQueue:Boolean = true, popupName:String = "", checkDuplicates:Boolean = false) : void
      {
         FarmGame.cbTrace("UI displayStorageDialog");
         if(m_storageDialog != null && checkDuplicates == false)
         {
            removeStorageEventListeners();
            m_storageDialog.close();
            UI.removeFromPopupQueue(m_storageDialog);
            m_storageDialog = null;
         }
         m_storageDialog = dialog;
         m_storageDialog.addEventListener(MarketEvent.MARKET_GIFT,onStorageClick);
         m_storageDialog.addEventListener(CloseEvent.CLOSE,onStorageClose);
         UI.displayPopup(m_storageDialog,addToQueue,popupName,checkDuplicates);
      }
      
      private static function onStorageClose(event:Event) : void
      {
         if(m_storageDialog)
         {
            removeStorageEventListeners();
            m_storageDialog = null;
         }
      }
      
      public static function displayInventoryDialogWithSearch(searchString:String = "") : void
      {
         if(searchString)
         {
            if(UI.InventoryWindowState == null)
            {
               UI.InventoryWindowState = {};
            }
            UI.InventoryWindowState["searchString"] = searchString;
         }
         UI.displayInventoryDialog();
      }
      
      public static function displayInventoryDialog(type:String = "inventory", storage:StorageBuilding = null) : void
      {
         FarmGame.cbTrace("UI displayInventoryDialog type:" + type);
         if(type == "inventory")
         {
            m_storageWindow = new StorageWindow(storage);
            m_storageWindow.addEventListener(CloseEvent.CLOSE,onStorageWindowClose);
            UI.displayPopup(m_storageWindow);
         }
         else
         {
            if(m_storageDialog != null)
            {
               removeStorageEventListeners();
               m_storageDialog.close();
               m_storageDialog = null;
            }
            m_storageDialog = new InventoryWithdrawal(storage,type,false);
            m_storageDialog.addEventListener(MarketEvent.MARKET_GIFT,onStorageClick);
            m_storageDialog.addEventListener(CloseEvent.CLOSE,onStorageClose);
            UI.displayPopup(m_storageDialog);
         }
      }
      
      private static function onStorageWindowClose(event:Event) : void
      {
         if(m_storageWindow)
         {
            m_storageWindow.removeEventListener(CloseEvent.CLOSE,onStorageWindowClose);
            m_storageWindow = null;
         }
      }
      
      private static function onMarketClose(event:Event) : void
      {
         if(m_marketWindow2)
         {
            removeMarketEventListeners();
            m_marketWindow2 = null;
         }
         if(marketLaunchReference == UI.MARKET_LAUNCH_REFERENCE_SEEDER)
         {
            CraftingUI.fuelForGoodsToaster();
         }
         marketLaunchReference = null;
         marketTerrainCodes = null;
      }
      
      private static function noMoreGiftsHandler(event:GenericPopupEvent) : void
      {
         var result:Boolean = event.button == GenericPopup.YES;
         if(result == true)
         {
            FarmStatsManager.count("farmville_sell_gift_screen","click_sell_all_item","gifts_empty_accept");
            GlobalEngine.socialNetwork.redirect("gifts.php?template=wishlist&ref=empty_gift_box");
         }
         else
         {
            FarmStatsManager.count("farmville_sell_gift_screen","click_sell_all_item","gifts_empty_cancel");
         }
      }
      
      private static function onStorageClick(event:MarketEvent) : void
      {
         var storageScr:StorageWithdrawal = null;
         var buildingId:int = 0;
         if(m_storageDialog)
         {
            if(m_storageDialog is StorageWithdrawal)
            {
               storageScr = m_storageDialog as StorageWithdrawal;
               buildingId = storageScr.storageBuildingId;
            }
            else if(m_storageDialog is InventoryWithdrawal)
            {
               buildingId = Global.worldManager.getCurrentWorldStorageId();
            }
            removeStorageEventListeners();
            m_storageDialog = null;
         }
         handleItemClick(event,false,buildingId);
      }
      
      public static function displayBuyMarketStallWindow() : void
      {
         if(null == m_buyMarketStallWindow)
         {
            m_buyMarketStallWindow = new BuyMarketStallWindow();
            m_buyMarketStallWindow.addEventListener(CloseEvent.CLOSE,onBuyMarketStallWindowClose);
            m_buyMarketStallWindow.addEventListener(MarketEvent.MARKET_BUY,onMarketClick);
            UI.displayPopup(m_buyMarketStallWindow,false);
            UI.stopPopups(true);
         }
      }
      
      private static function onBuyMarketStallWindowClose(event:Event) : void
      {
         if(m_buyMarketStallWindow)
         {
            m_buyMarketStallWindow.removeEventListener(CloseEvent.CLOSE,onBuyMarketStallWindowClose);
            m_buyMarketStallWindow.removeEventListener(MarketEvent.MARKET_BUY,onMarketClick);
            m_buyMarketStallWindow = null;
            UI.stopPopups(false);
         }
      }
      
      public static function displayDuckGameWindow(ducklingGameId:Number, worldId:Number, itemName:String) : void
      {
         if(m_duckGameWindow == null)
         {
            m_duckGameWindow = new DuckGameWindow({
               "ducklingGameId":ducklingGameId,
               "worldId":worldId,
               "itemName":itemName
            });
            m_duckGameWindow.addEventListener(CloseEvent.CLOSE,onDuckGameWindowClose);
            UI.displayPopup(m_duckGameWindow,false);
            UI.stopPopups(true);
         }
      }
      
      private static function onDuckGameWindowClose(event:Event) : void
      {
         if(m_duckGameWindow)
         {
            m_duckGameWindow.removeEventListener(CloseEvent.CLOSE,onDuckGameWindowClose);
            m_duckGameWindow = null;
            UI.stopPopups(false);
         }
      }
      
      private static function onMarketClick(event:MarketEvent) : void
      {
         if(marketLaunchReference == UI.MARKET_LAUNCH_REFERENCE_SEEDER)
         {
            CraftingUI.fuelForGoodsToaster();
         }
         handleItemClick(event,false,0);
      }
      
      private static function handleItemClick(event:MarketEvent, isGift:Boolean, buildingId:int) : void
      {
         var item:FarmItem = null;
         Animal.stopAllWandering();
         switch(event.eventType)
         {
            case MarketEvent.NONE:
               break;
            case MarketEvent.BUILDING:
               Global.world.addGameMode(new GMBuild(event.item,isGift,buildingId,true,event.m_extraData));
         }
      }
      
      public static function onCustomizeRingPopupClose(event:Event) : void
      {
         var extraItemData:Object = null;
         var item:FarmItem = null;
         var customizeRingPopup:CustomizeRing = event.target as CustomizeRing;
         if(customizeRingPopup)
         {
            customizeRingPopup.removeEventListener(CloseEvent.CLOSE,onCustomizeRingPopupClose);
            extraItemData = customizeRingPopup.getCustomRingData();
            if(null != extraItemData)
            {
               item = customizeRingPopup.getCustomItem();
               if(Global.player.cash < item.realCashCost)
               {
                  UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",item.cash,item.type);
               }
               else
               {
                  Global.player.addGift(item.name);
                  TransactionManager.addTransaction(new TBuyAndSendPresent(item,[Global.player],TBuyAndSendPresent.ITEMCONTEXT_NORMAL,extraItemData),true);
               }
            }
         }
      }
      
      private static function onSeedItemClick(event:MarketEvent) : void
      {
         var seeder:Seeder = null;
         var combine:Combine = null;
         switch(marketLaunchReference)
         {
            case MARKET_LAUNCH_REFERENCE_SEEDER:
               seeder = Global.world.getEquipment(Seeder,UI.marketTerrainCodes) as Seeder;
               Global.world.addGameMode(new GMSeeder(Global.farmGameSettingsManager.getFarmItemByName(event.item),seeder));
               break;
            case MARKET_LAUNCH_REFERENCE_SUPER_AVATAR:
               Global.world.addGameMode(new GMSuperAvatarPlant(Global.farmGameSettingsManager.getFarmItemByName(event.item)),true);
               break;
            case MARKET_LAUNCH_REFERENCE_COMBINE:
               combine = Global.world.getEquipment(Combine,UI.marketTerrainCodes) as Combine;
               Global.world.addGameMode(new GMCombine(Global.farmGameSettingsManager.getFarmItemByName(event.item),combine));
               break;
            default:
               Global.world.addGameMode(new GMMarketPlant(event.item));
         }
         marketLaunchReference = null;
         marketTerrainCodes = null;
      }
      
      protected static function onPresentClick(event:MarketEvent) : void
      {
         m_buyPresentFlow = new BuyPresent(event.item,TBuyAndSendPresent.ITEMCONTEXT_NORMAL);
         m_buyPresentFlow.addEventListener(CloseEvent.CLOSE,onBuyPresentFlowClose);
      }
      
      protected static function onMarketShownFromExpansionPrompt(event:Event) : void
      {
         FarmStatsManager.count("expansion_prompt_exp","expansionprompt_minimarket","view");
      }
      
      protected static function onBuyPresentFlowClose(event:Event) : void
      {
         m_buyPresentFlow.removeEventListener(CloseEvent.CLOSE,onBuyPresentFlowClose);
         m_buyPresentFlow = null;
      }
      
      public static function pumpPendingPresentsQueue() : void
      {
         if(Global.pendingPresents > 0)
         {
            TransactionManager.addTransaction(new TReceivePresent());
         }
      }
      
      private static function parseFlashVersion() : void
      {
         var versionString:String = null;
         if(m_flashVersion === null)
         {
            versionString = Capabilities.version;
            m_flashVersion = REGEX_VERSION.exec(versionString);
            REGEX_VERSION.lastIndex = 0;
         }
      }
      
      private static function isFlashVersionCompatible() : Boolean
      {
         var majorVersion:int = 0;
         var minorVersion:int = 0;
         var bugVersion:int = 0;
         var isFlashCompatible:Boolean = true;
         if(GlobalEngine.getFlashVar("CHROME_FLASH_FIX_1131_CLONE") === "true")
         {
            parseFlashVersion();
            majorVersion = int(m_flashVersion[2]);
            minorVersion = int(m_flashVersion[3]);
            bugVersion = int(m_flashVersion[4]);
            if(majorVersion === 11 && minorVersion === 3 && bugVersion === 31)
            {
               isFlashCompatible = false;
            }
         }
         return isFlashCompatible;
      }
      
      public static function getBottomLocX() : int
      {
         return m_bottomUI.x;
      }
      
      public static function displayImpulseBuyPopup(type:String, popupName:String = "impulseBuyPopup", attemptedSpend:int = 0, purchaseType:String = "Other") : ImpulseBuy
      {
         var variant:int = 0;
         var notCovered:Boolean = false;
         var popupObj:DisplayObject = null;
         var expVar:Boolean = false;
         var msg:String = null;
         var dialog:ImpulseBuy = null;
         var result:Boolean = Boolean(Global.flashHotParams["SHOW_FC_POPUP"]);
         if(result)
         {
            variant = Global.experimentManager.getExperimentVariant("fv_ingame_payments");
            notCovered = false;
            switch(type)
            {
               case ImpulseBuy.TYPE_MARKET_COINS:
               case ImpulseBuy.TYPE_COINS:
               case ImpulseBuy.TYPE_FUEL:
                  notCovered = true;
            }
            if(notCovered || !InGamePaymentsManager.inNoMoneyFlow() || attemptedSpend <= 0)
            {
               popupObj = Global.stage.getChildByName(popupName);
               if(popupObj == null)
               {
                  dialog = new ImpulseBuy(type,purchaseType);
                  displayPopup(dialog,false,popupName,true);
               }
            }
            else if(InGamePaymentsManager.inNoMoneyFlow())
            {
               if(Utilities.isFullScreen())
               {
                  closeMarketDialog();
                  Utilities.toggleFullScreen();
               }
               expVar = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SOCIAL_PROOF_IMPULSE_BUY) > 1;
               FarmStatsManager.count(StatsTrackingConstants.NOT_ENOUGH_CASH,StatsTrackingConstants.DIALOG_IMPRESSIONS_STAT,variant.toString(),expVar ? StatsTrackingConstants.WITH_FACEPILE_STAT : "",expVar ? String(Global.player.numRecentlyPaidFriends) : "");
            }
         }
         else
         {
            msg = Global.flashHotParams["FC_POPUP_MESSAGE"];
            UI.displayMessage(msg,GenericPopup.TYPE_OK,null,"",true);
         }
         return dialog;
      }
      
      protected static function onFeaturePromo(name:String) : void
      {
         var promo:XML = null;
         var sweetSeedsItemName:String = null;
         var sweetSeedsItem:FarmItem = null;
         var storageBuildings:Array = null;
         var dairyfarms:Array = null;
         var parts:Array = null;
         var iconPopup:GenericIconPopup = null;
         var action:String = null;
         var param:String = null;
         FarmGame.cbTrace("UI onFeaturePromo " + name);
         FarmStatsManager.count("featurePromo","feature_" + name);
         if(Global.worldManager.isVisiting() == false)
         {
            for each(promo in Global.farmGameSettingsManager.getXML().descendants("promoItem"))
            {
               if(promo.attribute("name") == name)
               {
                  break;
               }
            }
            if(null != promo && "" != promo.action.toString())
            {
               switch(promo.action.toString())
               {
                  case "market":
                     MarketWindow.previousPage = 0;
                     if("" == promo.marketSubcategory)
                     {
                        UI.displayMarketDialog("hudIcon",promo.marketCategory);
                     }
                     else
                     {
                        UI.displayMarketDialog("hudIcon",promo.marketCategory,null,promo.marketSubcategory);
                     }
                     break;
                  case "giftPage":
                     closeCurrentDialogs();
                     FreeGiftSelectionWindow.popWindow();
                     break;
                  case "english_sweepstakes_promo":
                     EnglishSweepstakesPromoManager.showDialog(true);
                     break;
                  case "HaitiBackpack":
                     FarmStatsManager.count("haitibackpack","progressbar_donate");
                     sweetSeedsItemName = Global.farmGameSettingsManager.getString("haitiDonateSweetSeedItem");
                     sweetSeedsItem = Global.farmGameSettingsManager.getFarmItemByName(sweetSeedsItemName);
                     if(sweetSeedsItem)
                     {
                        if(!LicenseManager.getInstance().hasCurrentLicense(sweetSeedsItem.code))
                        {
                           if(FarmGameSettingsManager.isInDataSourceExperiment())
                           {
                              UI.displayPopup(new Donate(null,sweetSeedsItem),false,"sweetSeedsPopup",true);
                           }
                           else
                           {
                              UI.displayPopup(new Donate(sweetSeedsItem.xml),false,"sweetSeedsPopup",true);
                           }
                        }
                        else
                        {
                           iconPopup = new GenericIconPopup(ZLocUtils.t("Dialogs","SweetSeeds_AlreadyDonated"));
                           iconPopup.setAcceptTextName("Okay");
                           UI.displayPopup(iconPopup);
                        }
                     }
                     break;
                  case "EmailPermission":
                     EmailManager.displayEmailPermissionPrompt();
                     break;
                  case "externalLink":
                     if("" != promo.actionUrl)
                     {
                        navigateToURL(new URLRequest(promo.actionUrl),"_blank");
                     }
                     break;
                  case "inGameLink":
                     if("" != promo.actionUrl)
                     {
                        GlobalEngine.socialNetwork.redirect(promo.actionUrl);
                     }
                     break;
                  case "stable":
                     HorseStableBuilding.onClickStableExpansionPromo();
                     break;
                  case "storage":
                     storageBuildings = Global.world.getObjectsByClass(StorageBuilding);
                     if(storageBuildings[0])
                     {
                        UI.displayStorageDialog(new InventoryWithdrawal(null,"upgrade",false));
                     }
                     else
                     {
                        UI.displayMarketDialog("promo","building",null,"storage");
                     }
                     break;
                  case "dairyfarm":
                     dairyfarms = Global.world.getObjectsByClass(DairyFarmBuilding);
                     if(dairyfarms[0])
                     {
                        UI.displayStorageDialog(new InventoryWithdrawal(null,"upgrade",false));
                     }
                     else
                     {
                        UI.displayMarketDialog("motd","building",null,"animal_pens");
                     }
                     break;
                  case "startOutBoundPromo":
                     CrossPromoManager.getInstance().startOutBoundPromo(promo.promoId);
                     break;
                  default:
                     parts = promo.action.toString().split(":");
                     if(parts.length == 2)
                     {
                        action = parts[0];
                        param = parts[1];
                        switch(action)
                        {
                           case "openDialog":
                              if(param == CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID)
                              {
                                 CityvilleLaunchPromoRound2Dialog.popDialog(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_DIALOG);
                                 FarmStatsManager.count(CrossPromoConstants.CITY_LAUNCH_XPROMO_ROUND2_PROMO_ID,"promo_bar","clicks");
                              }
                        }
                     }
               }
            }
         }
      }
      
      protected static function refreshBalance() : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(),true);
      }
      
      public static function getCurrentPopupName(dialog:DisplayObject = null) : String
      {
         var result:String = "";
         if(dialog == null)
         {
            dialog = m_currentDialog;
         }
         if(dialog != null)
         {
            result = getQualifiedClassName(dialog);
            if(result.length >= 39)
            {
               result = result.substr(result.lastIndexOf(".") + 1);
               if(result.length >= 39)
               {
                  result = result.substr(result.indexOf("::") + 2);
               }
            }
            result = "popup:" + result;
         }
         else if(m_numImmediatePopups > 0)
         {
            result = "popup:unkownImmediate";
         }
         else
         {
            result = "unkownUI";
         }
         return result;
      }
      
      public static function displayTerrainEditorWindow() : void
      {
         Global.hud.setTerrainMode(true);
         Global.ui.terrain = true;
         if(m_terrainEditorWindow == null)
         {
            m_terrainEditorWindow = new TerrainEditorWindow();
            m_terrainEditorWindow.addEventListener(CloseEvent.CLOSE,onTerrainEditorWindowClose);
            Global.stage.addChild(m_terrainEditorWindow);
            Global.stage.addEventListener(Event.FULLSCREEN,onTerrainEditorFullScreenEvent);
         }
      }
      
      private static function onTerrainEditorWindowClose(event:Event) : void
      {
         Global.hud.setTerrainMode(false);
         Global.ui.terrain = false;
         if(m_terrainEditorWindow)
         {
            m_terrainEditorWindow.removeEventListener(CloseEvent.CLOSE,onTerrainEditorWindowClose);
            m_terrainEditorWindow = null;
            Global.stage.removeEventListener(Event.FULLSCREEN,onTerrainEditorFullScreenEvent);
         }
      }
      
      public static function alignTerrainEditor(heightIn:Number) : void
      {
         --m_bottomUI.x;
         m_terrainEditorWindow.y = m_bottomUI.y + m_bottomUI.height + heightIn - 8;
      }
      
      public static function get terrainEditorWindow() : TerrainEditorWindow
      {
         return m_terrainEditorWindow;
      }
      
      private static function onTerrainEditorFullScreenEvent(event:Event) : void
      {
         alignTerrainEditor(m_terrainEditorWindow.height);
      }
      
      public static function handlePopupDisplayForRetention(messageText:String, type:int = 1, closeCallback:Function = null, icon:String = null, trackerKey:String = "", popupParams:Object = null, forceToaster:Boolean = false) : void
      {
         var variant:int = 0;
         var popup:GenericIconPopup = null;
         var lineBreak:int = 0;
         var buttonTextKey:String = null;
         var onClick:Function = null;
         var onCancel:Function = null;
         var toaster:ShareButtonToasterWindow = null;
         var action:String = "popup";
         var addToQueue:Boolean = true;
         var popupName:String = "";
         var checkDuplicates:Boolean = false;
         var addInactiveUserPopup:Boolean = false;
         var dontCloseToaster:Boolean = false;
         if(popupParams != null)
         {
            if(popupParams.hasOwnProperty(HANDLE_POPUP_FOR_RETENTION_OPTION_ADD_TO_QUEUE))
            {
               addToQueue = Boolean(popupParams.addToQueue);
            }
            if(popupParams.hasOwnProperty(HANDLE_POPUP_FOR_RETENTION_OPTION_POPUP_NAME))
            {
               popupName = popupParams.popupName;
            }
            if(popupParams.hasOwnProperty(HANDLE_POPUP_FOR_RETENTION_OPTION_CHECK_DUPLICATES))
            {
               checkDuplicates = Boolean(popupParams.checkDuplicates);
            }
            if(popupParams.hasOwnProperty(HANDLE_POPUP_FOR_RETENTION_OPTION_ADD_INACTIVE_POPUP))
            {
               addInactiveUserPopup = Boolean(popupParams.addInactiveUserPopup);
            }
            if(popupParams.hasOwnProperty(HANDLE_POPUP_FOR_RETENTION_OPTION_DONT_CLOSE_TOASTER))
            {
               dontCloseToaster = Boolean(popupParams.dontCloseToaster);
            }
         }
         if(RetentionMasterManager.inMasterExperiment())
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BLOCK_POPUP);
            if(variant == 2 || variant == 3 || forceToaster)
            {
               action = "toaster";
               FarmStatsManager.count("retention_popup_block","toaster");
            }
            else if(variant == 5 || variant == 6)
            {
               action = "none";
               FarmStatsManager.count("retention_popup_block","popup_blocked");
            }
            else
            {
               FarmStatsManager.count("retention_popup_block","popup_viewed");
            }
         }
         if(action == "popup")
         {
            popup = new GenericIconPopup(messageText,type,closeCallback,icon);
            if(trackerKey != "")
            {
               popup.setTrackerKey(trackerKey);
            }
            if(addInactiveUserPopup)
            {
               Global.popupManager.addInactiveUserPopup(popup);
            }
            else
            {
               UI.displayPopup(popup,addToQueue,popupName,checkDuplicates);
            }
         }
         else if(action == "toaster")
         {
            lineBreak = messageText.indexOf("\n",0);
            if(lineBreak > 1)
            {
               messageText = messageText.slice(0,lineBreak - 1);
            }
            onClick = function():void
            {
               if(closeCallback != null)
               {
                  closeCallback(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
               }
            };
            onCancel = function():void
            {
               if(closeCallback != null)
               {
                  closeCallback(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
               }
            };
            if(type == GenericPopup.TYPE_SHARE)
            {
               buttonTextKey = "Share";
            }
            else
            {
               buttonTextKey = "Okay";
            }
            toaster = new ShareButtonToasterWindow("",messageText,icon,ToasterIconPaths.DIALOG_ASSET,0.5,new Point(6,6),onClick,onCancel,ZLocUtils.t("Dialogs",buttonTextKey),dontCloseToaster);
            toaster.duration = 8000;
            ToasterManager.getInstance().add(toaster);
         }
         else if(action == "none")
         {
            if(closeCallback != null)
            {
               closeCallback(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
            }
         }
      }
      
      public static function shouldBlockPopupForRetention() : Boolean
      {
         var variant:int = 0;
         var result:Boolean = false;
         if(RetentionMasterManager.inMasterExperiment())
         {
            variant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BLOCK_POPUP);
            if(variant == 2 || variant == 3 || variant == 5 || variant == 6)
            {
               result = true;
            }
            else if(variant == 1 || variant == 4)
            {
               FarmStatsManager.count("retention_popup_block","popup_viewed");
            }
         }
         return result;
      }
      
      public function update() : void
      {
         this.checkOverlayCompletion();
         CraftingUI.enterFrame();
         TutorialUI.enterFrame();
         if(m_duckGameWindow)
         {
            m_duckGameWindow.update();
         }
         if(this.m_performanceTracker)
         {
            this.m_performanceTracker.update();
         }
      }
      
      public function get performanceHudEnabled() : Boolean
      {
         return this.m_performanceTracker.visible;
      }
      
      public function set performanceHudEnabled(value:Boolean) : void
      {
         this.m_performanceTracker.visible = false;
      }
      
      protected function onMaskBitmapEvent(event:MouseEvent) : void
      {
         var clickColor:uint = 0;
         var alpha:uint = 0;
         if(this.m_neighborBackground)
         {
            clickColor = this.m_neighborBackground.bitmapData.getPixel32(this.m_neighborBackground.mouseX,this.m_neighborBackground.mouseY);
            alpha = uint(clickColor >> 24 & 0xFF);
            if(alpha < 32)
            {
               GlobalEngine.viewport.dispatchEvent(new MouseEvent(event.type,event.bubbles,event.cancelable,GlobalEngine.viewport.mouseX,GlobalEngine.viewport.mouseY,GlobalEngine.viewport,event.ctrlKey,event.altKey,event.shiftKey,event.buttonDown,event.delta));
            }
            else if(UI.hasCursor(this.m_cursorId) == false)
            {
               this.m_cursorId = UI.setCursor(null);
            }
         }
      }
      
      protected function onMouseOver(event:Event) : void
      {
         if(UI.hasCursor(this.m_cursorId) == false)
         {
            this.m_cursorId = UI.setCursor(null);
         }
         if(!ZLocUtils.isValid(this.m_home.toolTip))
         {
            this.m_home.toolTip = ZLocUtils.t("FarmGame","ReturnHome_ToolTip");
         }
         if(!ZLocUtils.isValid(this.m_homeText.toolTipText))
         {
            this.m_homeText.toolTipText = ZLocUtils.t("FarmGame","GoHome");
         }
      }
      
      protected function onMouseOut(event:Event) : void
      {
         UI.removeCursor(this.m_cursorId);
      }
      
      public function setFriendBarPos(idx:int) : void
      {
         this.m_friendBar.x = this.m_friendBarX + 66 * idx;
      }
      
      private function onFriendBarLoaded(event:FriendBarEvent) : void
      {
         var visibleSlots:Number = 8;
         var slotWidth:Number = 71;
         this.m_friendBarX = visibleSlots * slotWidth - event.length;
         if(event.resetScroll)
         {
            this.m_friendBar.x = this.m_friendBarX;
         }
      }
      
      private function onFriendBarMove(event:FriendBarEvent) : void
      {
         if(this.m_friendBar.x + event.delta <= 0 && this.m_friendBar.x + event.delta >= this.m_friendBarX)
         {
            if(41 == Math.abs(event.delta))
            {
               TweenLite.to(this.m_friendBar,0.25,{"x":0});
            }
            else
            {
               TweenLite.to(this.m_friendBar,0.1,{"x":this.m_friendBar.x + event.delta});
            }
         }
         else if(this.m_friendBar.x + event.delta > 0)
         {
            TweenLite.to(this.m_friendBar,0.25,{"x":40});
         }
         else if(this.m_friendBar.x + event.delta < this.m_friendBarX)
         {
            TweenLite.to(this.m_friendBar,0.25,{"x":this.m_friendBarX});
         }
      }
      
      private function onFriendBarMoveEnd(event:FriendBarEvent) : void
      {
         if(event.delta == 0)
         {
            TweenLite.to(this.m_friendBar,0.25,{"x":40});
         }
         else
         {
            TweenLite.to(this.m_friendBar,0.25,{"x":this.m_friendBarX});
         }
      }
      
      public function get friendBarLeftNav() : FriendBarLeftNav
      {
         return this.m_friendBarLeftNav;
      }
      
      public function get friendBarRightNav() : FriendBarRightNav
      {
         return this.m_friendBarRightNav;
      }
      
      public function onFullscreenClick(event:MouseEvent) : void
      {
         FarmGame.cbTrace("UI onFullscreenClick");
         FarmStatsManager.count(UI_BUTTON_CLICKS_COUNTER,"full_screen");
         var gameMode:GameMode = Global.world.getTopGameMode();
         if(Boolean(gameMode) && gameMode.isFullscreenEnabled())
         {
            Utilities.toggleFullScreen();
            DefconManager.refresh();
         }
         if(Global.selectedAvatar)
         {
            Global.selectedAvatar.centerOn();
         }
      }
      
      private function onZCacheClick(event:MouseEvent) : void
      {
         var zCache:IZCache = GlobalZCache.instance;
         var sandboxUrl:String = Global.getAssetURL(Global.farmGameSettingsManager.getString("zCacheSandboxUrl"));
         var zCacheUI:ZCacheUI = new ZCacheUI(zCache,Global.stage,sandboxUrl,true,true);
         zCacheUI.offsets = new Point(20,0);
         if(zCacheUI)
         {
            zCacheUI.showPermissionsPrompt(function(allowed:Boolean):void
            {
               FarmStatsManager.count("zcache","flash_permission",allowed ? "allowed" : "denied","hud");
               if(allowed)
               {
                  m_zcacheButton.removeEventListener(MouseEvent.CLICK,onZCacheClick);
                  m_bottomUI.removeChild(m_zcacheButton);
               }
            });
         }
      }
      
      private function onTakePhotoClick(event:MouseEvent) : void
      {
         if(Config.DEBUG_MODE && GlobalEngine.getFlashVar("dbg_tool_mode") == 1)
         {
            ToolModeManager.loadSandboxAsset("/ugcImages/tiger_lava_full.14403061.swf","tiger_lava_full.swf");
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FARMSTAMATIC_FEATURE))
         {
            StatsManager.count("camera","toolbar","button","click");
            Global.world.addGameMode(new GMFarmstamatic(),true);
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("FarmGame","Snapshot_unavailable"));
         }
      }
      
      private function onAllAssetsLoaded(event:Event) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onFriendBarClick(e:FriendBarSlotEvent) : void
      {
         var variant:int = 0;
         var items:Array = null;
         var bgColor:uint = 0;
         var rollOverColor:uint = 0;
         FarmGame.cbTrace("UI onFriendBarClick");
         FarmStatsManager.count(e.m_counter,e.m_kingdom,null,e.m_zClass);
         if(!(e.slot.m_fakeFriend && !e.slot.m_empty))
         {
            if(e.slot.m_empty)
            {
               MFSRequestManager.getInstance().displayR2AddNeighborWindow("neighborsInvitePage");
            }
            else
            {
               removeAllCursors();
               if(ChatManager.instance.isFarmTalkEnabled() && ChatManager.instance.isFarmTalkEnabled(e.slot.uid))
               {
                  e.slot.onClickMessage(e);
               }
               else
               {
                  items = [{
                     "label":ZLocUtils.t("FarmGame","SendGiftTo",{"user":ZLocUtils.tn(e.slot.m_label.text)}),
                     "action":this.SEND_GIFT_TO
                  },{
                     "label":ZLocUtils.t("FarmGame","TendVisitNeighbor",{"user":ZLocUtils.tn(e.slot.m_label.text)}),
                     "action":this.VISIT_NEIGHBOR
                  },{
                     "label":ZLocUtils.t("FarmGame","AddNeighbor",{"user":ZLocUtils.tn(e.slot.m_label.text)}),
                     "action":this.ADD_NEIGHBOR
                  }];
                  variant = Global.experimentManager.getExperimentVariant("fv_send_gifts_redirect");
                  if(1 == variant)
                  {
                     items = new Array();
                     items.push({
                        "label":ZLocUtils.t("FarmGame","SendGift"),
                        "action":this.SEND_GIFT
                     });
                     items.push({
                        "label":ZLocUtils.t("FarmGame","TendVisitNeighbor",{"user":ZLocUtils.tn(e.slot.m_label.text)}),
                        "action":this.VISIT_NEIGHBOR
                     });
                     items.push({
                        "label":ZLocUtils.t("FarmGame","AddNeighbor",{"user":ZLocUtils.tn(e.slot.m_label.text)}),
                        "action":this.ADD_NEIGHBOR
                     });
                  }
                  this.m_clickedSlot = e.slot;
                  bgColor = 16245378;
                  rollOverColor = 16764736;
                  displayMenu(items,this.onMenuClicked,bgColor,rollOverColor,true);
               }
            }
         }
      }
      
      private function onMenuClicked(event:MouseEvent) : void
      {
         var url:String = null;
         var request:URLRequest = null;
         var variables:URLVariables = null;
         var conditionalSubCounter:String = null;
         hideMenu();
         var item:ContextMenuItem = event.target is ContextMenuItem ? event.target as ContextMenuItem : null;
         if(Boolean(item) && Boolean(item.action))
         {
            FarmGame.cbTrace("UI onMenuClicked " + item.action);
            conditionalSubCounter = this.m_clickedSlot.m_rank == 1 ? String(Global.friendManager.numNeighborBarExperimentFriends) : "";
            switch(item.action)
            {
               case this.SEND_GIFT_TO:
                  FarmStatsManager.sampleOrCount("fv_neighbor_bar_populate",1000,ClickTrackingConstants.NEIGHBOR_BAR_STATS_COUNTER,ClickTrackingConstants.NEIGHBOR_BAR_CARD_CLICK,ClickTrackingConstants.NEIGHBOR_BAR_SEND_GIFT,conditionalSubCounter);
                  variables = new URLVariables();
                  variables.rId = Global.player.snUser.uid;
                  FreeGiftSelectionWindow.popWindow();
                  break;
               case this.SEND_GIFT:
                  FarmStatsManager.sampleOrCount("fv_neighbor_bar_populate",1000,ClickTrackingConstants.NEIGHBOR_BAR_STATS_COUNTER,ClickTrackingConstants.NEIGHBOR_BAR_CARD_CLICK,ClickTrackingConstants.NEIGHBOR_BAR_SEND_GIFT,conditionalSubCounter);
                  variables = new URLVariables();
                  variables.rId = Global.player.snUser.uid;
                  FreeGiftSelectionWindow.popWindow();
                  break;
               case this.ADD_NEIGHBOR:
                  FarmStatsManager.sampleOrCount("fv_neighbor_bar_populate",1000,ClickTrackingConstants.NEIGHBOR_BAR_STATS_COUNTER,ClickTrackingConstants.NEIGHBOR_BAR_CARD_CLICK,ClickTrackingConstants.NEIGHBOR_BAR_INVITE_FRIENDS,conditionalSubCounter);
                  MFSRequestManager.getInstance().displayR2AddNeighborWindow("neighborsInvitePage");
                  break;
               case this.ADD_NEIGHBOREX:
                  FarmStatsManager.sampleOrCount("fv_neighbor_bar_populate",1000,ClickTrackingConstants.NEIGHBOR_BAR_STATS_COUNTER,ClickTrackingConstants.NEIGHBOR_BAR_CARD_CLICK,ClickTrackingConstants.NEIGHBOR_BAR_ADD_NEIGHBOR,conditionalSubCounter);
                  MFSRequestManager.getInstance().displayR2AddNeighborWindow("tab");
                  break;
               case this.VISIT_NEIGHBOR:
                  FarmStatsManager.sampleOrCount("fv_neighbor_bar_populate",1000,ClickTrackingConstants.NEIGHBOR_BAR_STATS_COUNTER,ClickTrackingConstants.NEIGHBOR_BAR_CARD_CLICK,ClickTrackingConstants.NEIGHBOR_BAR_VISIT_FRIEND,conditionalSubCounter);
                  Global.worldManager.visitNeighbor(this.m_clickedSlot.uid.toString());
                  break;
               case this.SEND_MESSAGE_NEIGHBOR:
            }
         }
      }
      
      private function onLoadComplete(event:Event) : void
      {
         event.currentTarget.content.width = 760;
      }
      
      private function onResize(event:Event) : void
      {
         m_bottomUI.x = (GlobalEngine.stage.stageWidth - DEFAULT_WIDTH) / 2;
         m_bottomUI.y = GlobalEngine.stage.stageHeight - DEFAULT_HEIGHT;
         Global.hud.markDirty();
      }
      
      private function onGoHome(event:Event) : void
      {
         Global.worldManager.goHome();
      }
      
      public function set visit(visiting:Boolean) : void
      {
         if(visiting)
         {
            removeAllCursors();
            m_actionMenu.visitMode(true);
            this.m_home.visible = true;
         }
         else
         {
            removeAllCursors();
            m_actionMenu.visitMode(false);
            this.m_home.hideToolTip();
            this.m_home.visible = false;
         }
      }
      
      public function onUpgradePromptClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayInventoryDialog("upgrade");
         }
      }
      
      public function onBuyStoragePromptClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayMarketDialog("storage","building",null,"storage");
         }
      }
      
      public function getActionMenu() : ActionMenu
      {
         return m_actionMenu;
      }
      
      public function get bottomUI() : Sprite
      {
         return m_bottomUI;
      }
      
      public function getBottomRight() : Point
      {
         var stageRect:Rectangle = m_bottomUI.getBounds(Global.stage);
         return new Point(stageRect.x + stageRect.width,stageRect.y + stageRect.height - 75);
      }
      
      public function displayOverlaySWF(swfURL:String, placement:Point = null, scale:Vector2 = null, yOffset:Number = 0, mcFinishCallback:Function = null, overlayParams:Object = null) : void
      {
         var activeOverlays:Array = null;
         var inactiveOverlays:Array = null;
         var oldInfo:Object = null;
         var swfLdr:Loader = null;
         if(null == this.m_inactiveOverlays[swfURL] || null == this.m_activeOverlays[swfURL])
         {
            activeOverlays = this.m_activeOverlays[swfURL] = new Array();
            inactiveOverlays = this.m_inactiveOverlays[swfURL] = new Array();
         }
         else
         {
            activeOverlays = this.m_activeOverlays[swfURL] as Array;
            inactiveOverlays = this.m_inactiveOverlays[swfURL] as Array;
         }
         var info:Object = {
            "url":swfURL,
            "scale":scale,
            "position":placement,
            "yOffset":yOffset,
            "callback":mcFinishCallback,
            "params":overlayParams
         };
         if(inactiveOverlays.length > 0)
         {
            oldInfo = inactiveOverlays.pop();
            info.content = oldInfo.content;
            if(info.content != null)
            {
               this.playOverlaySWF(info);
            }
            else
            {
               GlobalEngine.log("overlay","inactive overlay doesn\'t have content attached");
            }
         }
         else if(activeOverlays.length > 0 && activeOverlays[0].content != null && isFlashVersionCompatible())
         {
            info.content = activeOverlays[0].content;
            ImageLoader.clone(info.content,this.onCloneOverlaySWF,info);
         }
         else
         {
            swfLdr = LoadingManager.load(swfURL,this.onLoadOverlaySWF);
            this.m_overlaySWFs[swfLdr] = info;
         }
      }
      
      private function onLoadOverlaySWF(event:Event) : void
      {
         var info:Object = null;
         var overlaySWFLoader:Loader = event.target.loader as Loader;
         if(overlaySWFLoader != null)
         {
            info = this.m_overlaySWFs[overlaySWFLoader];
            delete this.m_overlaySWFs[overlaySWFLoader];
            if(info)
            {
               info.content = overlaySWFLoader.content;
               this.playOverlaySWF(info);
            }
         }
      }
      
      private function onCloneOverlaySWF(content:DisplayObject, info:Object = null) : void
      {
         if(Boolean(content) && Boolean(info))
         {
            info.content = content;
            this.playOverlaySWF(info);
         }
      }
      
      private function playOverlaySWF(info:Object) : void
      {
         var additionalOffsetX:int = 0;
         var additionalOffsetY:int = 0;
         var scaleX:Number = NaN;
         var overlayClip:MovieClip = null;
         var st:SoundTransform = null;
         var overlayMc:DisplayObject = null;
         var overlaySWF_mc:MovieClip = info.content as MovieClip;
         if(Boolean(overlaySWF_mc) && overlaySWF_mc.parent is Loader)
         {
            (this.m_activeOverlays[info.url] as Array).push(info);
            if(Global.player.isSfxDisabled())
            {
               st = new SoundTransform();
               st.volume = 0;
               overlaySWF_mc.soundTransform = st;
            }
            additionalOffsetX = 0;
            additionalOffsetY = 0;
            scaleX = 0;
            if(info.scale != null)
            {
               scaleX = info.scale.x / (overlaySWF_mc.parent as Loader).contentLoaderInfo.width;
               if(Boolean(info.params) && Boolean(info.params.overlayMc))
               {
                  overlayMc = overlaySWF_mc.getChildByName(info.params.overlayMc);
                  if(overlayMc != null)
                  {
                     if(info.params.scale)
                     {
                        overlayMc.scaleX = info.params.scale;
                        overlayMc.scaleY = info.params.scale;
                     }
                     if(info.params.offsetX)
                     {
                        additionalOffsetX += info.params.offsetX;
                     }
                     if(info.params.offsetY)
                     {
                        additionalOffsetY += info.params.offsetY;
                     }
                  }
               }
               else
               {
                  overlaySWF_mc.scaleX = scaleX;
                  overlaySWF_mc.scaleY = scaleX;
               }
            }
            if(info.position != null)
            {
               overlaySWF_mc.x = info.position.x;
               if(info.scale != null && info.yOffset != 0)
               {
                  overlaySWF_mc.y = info.position.y - info.yOffset * ((overlaySWF_mc.parent as Loader).contentLoaderInfo.height * scaleX - info.scale.y);
               }
               else
               {
                  overlaySWF_mc.y = info.position.y;
               }
            }
            if(overlaySWF_mc.origin_mc)
            {
               overlaySWF_mc.x -= overlaySWF_mc.origin_mc.x;
               overlaySWF_mc.y -= overlaySWF_mc.origin_mc.y;
            }
            overlaySWF_mc.x += additionalOffsetX;
            overlaySWF_mc.y += additionalOffsetX;
            if(Boolean(info.params) && info.params.alpha != null)
            {
               overlaySWF_mc.alpha = info.params.alpha;
            }
            if(Boolean(info.params) && Boolean(info.params.freezeAll))
            {
               FreezeManager.freezeAll();
            }
            if(Boolean(info.params) && Boolean(info.params.addToStage))
            {
               Global.stage.addChild(overlaySWF_mc.parent);
            }
            else if(Boolean(info.params) && info.params.objectDepthIndex != null)
            {
               GlobalEngine.viewport.objectBase.addChildAt(overlaySWF_mc.parent,info.params.objectDepthIndex);
            }
            else
            {
               GlobalEngine.viewport.uiBase.addChild(overlaySWF_mc.parent);
            }
            if(Boolean(info.params) && Boolean(info.params.instanceName))
            {
               overlayClip = overlaySWF_mc.getChildByName(info.params.instanceName) as MovieClip;
               overlayClip.play();
            }
            else
            {
               overlaySWF_mc.play();
            }
         }
      }
      
      protected function checkOverlayCompletion() : void
      {
         var activeOverlays:Array = null;
         var index:* = 0;
         var len:* = 0;
         var info:Object = null;
         var overlaySWF_mc:MovieClip = null;
         var isOverlayComplete:Boolean = false;
         var overlayClip:MovieClip = null;
         var keepPlaying:Boolean = false;
         var inactiveOverlays:Array = null;
         var overlayMc:MovieClip = null;
         var playFrame:Boolean = false;
         for each(activeOverlays in this.m_activeOverlays)
         {
            index = 0;
            len = int(activeOverlays.length);
            while(index < len && len > 0)
            {
               info = activeOverlays[index];
               overlaySWF_mc = info.content;
               isOverlayComplete = false;
               if(Boolean(info.params) && Boolean(info.params.instanceName))
               {
                  overlayClip = overlaySWF_mc.getChildByName(info.params.instanceName) as MovieClip;
                  isOverlayComplete = overlayClip.currentFrame >= overlayClip.totalFrames ? true : false;
               }
               else
               {
                  isOverlayComplete = overlaySWF_mc.currentFrame >= overlaySWF_mc.totalFrames ? true : false;
               }
               if(isOverlayComplete)
               {
                  keepPlaying = false;
                  if(info.callback != null)
                  {
                     keepPlaying = Boolean(info.callback());
                  }
                  if(!keepPlaying)
                  {
                     if(overlayClip)
                     {
                        overlayClip.gotoAndStop(0);
                     }
                     else
                     {
                        overlaySWF_mc.gotoAndStop(0);
                     }
                     if(overlaySWF_mc.parent != null && overlaySWF_mc.parent is Loader && overlaySWF_mc.parent.parent != null)
                     {
                        overlaySWF_mc.parent.parent.removeChild(overlaySWF_mc.parent);
                     }
                     activeOverlays.splice(index--,1);
                     len--;
                     if(!(Boolean(info.params) && Boolean(info.params.noReuse)))
                     {
                        inactiveOverlays = this.m_inactiveOverlays[info.url] as Array;
                        if(inactiveOverlays.length < this.MAX_INACTIVE_OVERLAYS)
                        {
                           inactiveOverlays.push(info);
                        }
                        else
                        {
                           GlobalEngine.log("overlay","MAX_INACTIVE_OVERLAYS reached! If you\'re getting this, you\'re probably using DisplayOverlaySWF wrong.");
                        }
                     }
                     if(Boolean(info.params) && Boolean(info.params.freezeAll))
                     {
                        FreezeManager.thaw();
                     }
                  }
                  else if(Boolean(info.params) && Boolean(info.params.overlayMc) && Boolean(info.params.startFrame))
                  {
                     overlayMc = overlaySWF_mc.getChildByName(info.params.overlayMc) as MovieClip;
                     if(overlayMc != null)
                     {
                        playFrame = true;
                        if(Boolean(info.params.noLoop) && Boolean(info.params.hasPlayed))
                        {
                           playFrame = false;
                        }
                        if(playFrame)
                        {
                           overlayMc.gotoAndPlay(info.params.startFrame);
                           info.params.hasPlayed = true;
                        }
                     }
                  }
                  else if(overlayClip)
                  {
                     overlayClip.gotoAndStop(0);
                  }
                  else
                  {
                     overlaySWF_mc.gotoAndStop(0);
                  }
               }
               index++;
            }
         }
      }
      
      public function displayToasterPopup(toaster:ToasterWindow) : void
      {
         if(toaster)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MARKET_POST_PURCHASE_FLOW) < Experiments.SINGLE_CONTROL_VALID_VARIANT_START || toaster.isPauseable)
            {
               addChildAt(toaster,0);
            }
            else
            {
               Global.stage.addChild(toaster);
            }
            toaster.show();
         }
      }
      
      public function displayHudWidget(hudWidget:ToasterWindow) : void
      {
         if(hudWidget)
         {
            addChildAt(hudWidget,0);
            hudWidget.show();
         }
      }
      
      public function swapToasterDepth(toaster:ToasterWindow, front:Boolean = true) : void
      {
         try
         {
            if(front)
            {
               this.setChildIndex(toaster,this.numChildren - 1);
            }
            else
            {
               this.setChildIndex(toaster,0);
            }
         }
         catch(error:Error)
         {
         }
      }
      
      public function chooseSweetSeedsDisplayDialog() : void
      {
         var donateMarketItem:FarmItem = null;
         var marketXML:XML = null;
         var name:String = Global.farmGameSettingsManager.getString("sweetSeedsHaitiCrop");
         var marketItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         if(LicenseManager.getInstance().hasCurrentLicense(name))
         {
            UI.displayMarketDialog("featurePromo");
         }
         else
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               name = marketItem.getPropertyFromItemCashSaleSource("name");
            }
            else
            {
               marketXML = marketItem.xml ? marketItem.xml : (marketItem.cashXML ? marketItem.cashXML : marketItem.saleXML);
               name = marketXML.@name;
            }
            donateMarketItem = Global.farmGameSettingsManager.getFarmItemByName(marketXML.@name);
            UI.displayPopup(new Donate(marketXML,donateMarketItem));
         }
      }
      
      public function set neighborBackground(newBackground:Bitmap) : void
      {
         if(newBackground)
         {
            if(this.m_neighborBackground)
            {
               m_bottomUI.removeChild(this.m_neighborBackground);
            }
            this.m_neighborBackground = newBackground;
            this.m_neighborBackground.y = Y_POSITION_NEIGHBOR_BACKGROUND;
            m_bottomUI.addChildAt(this.m_neighborBackground,0);
         }
      }
      
      public function setNeighborBackgroundOffsetY(offsetY:Number) : void
      {
         if(this.m_neighborBackground)
         {
            this.m_neighborBackground.y = Y_POSITION_NEIGHBOR_BACKGROUND + offsetY;
         }
      }
      
      public function set zoomOutButton(newButton:SpriteButton) : void
      {
         if(Boolean(newButton) && newButton != this.m_zoomOut)
         {
            if(this.m_zoomOut)
            {
               this.m_zoomOut.removeEventListener(MouseEvent.CLICK,onZoomOutClick);
               m_bottomUI.removeChild(this.m_zoomOut);
            }
            this.m_zoomOut = newButton;
            this.m_zoomOut.toolTip = ZLocUtils.t("FarmGame","ZoomOut_ToolTip");
            this.m_zoomOut.addEventListener(MouseEvent.CLICK,onZoomOutClick);
            this.m_zoomOut.x = X_POSITION_ZOOM_OUT_BUTTON;
            this.m_zoomOut.y = Y_POSITION_ZOOM_OUT_BUTTON;
            this.addBehindActionMenu(this.m_zoomOut);
         }
      }
      
      public function set zoomInButton(newButton:SpriteButton) : void
      {
         if(Boolean(newButton) && newButton != this.m_zoomIn)
         {
            if(this.m_zoomIn)
            {
               this.m_zoomIn.removeEventListener(MouseEvent.CLICK,onZoomInClick);
               m_bottomUI.removeChild(this.m_zoomIn);
            }
            this.m_zoomIn = newButton;
            this.m_zoomIn.addEventListener(MouseEvent.CLICK,onZoomInClick);
            this.m_zoomIn.toolTip = ZLocUtils.t("FarmGame","ZoomIn_ToolTip");
            this.m_zoomIn.x = X_POSITION_ZOOM_IN_BUTTON;
            this.m_zoomIn.y = Y_POSITION_ZOOM_IN_BUTTON;
            this.addBehindActionMenu(this.m_zoomIn);
         }
      }
      
      public function set cameraButton(newButton:SpriteButton) : void
      {
         if(newButton)
         {
            if(this.m_takePhoto)
            {
               this.m_takePhoto.removeEventListener(MouseEvent.CLICK,this.onTakePhotoClick);
               m_bottomUI.removeChild(this.m_takePhoto);
            }
            this.m_takePhoto = newButton;
            this.m_takePhoto.addEventListener(MouseEvent.CLICK,this.onTakePhotoClick);
            this.m_takePhoto.toolTip = ZLocUtils.t("FarmGame","TakePhoto_ToolTip");
            this.m_takePhoto.x = X_POSITION_CAMERA_BUTTON;
            this.m_takePhoto.y = Y_POSITION_CAMERA_BUTTON;
            this.addBehindActionMenu(this.m_takePhoto);
         }
      }
      
      public function set zCacheButton(newButton:SpriteButton) : void
      {
         if(newButton)
         {
            if(this.m_zcacheButton)
            {
               this.m_zcacheButton.removeEventListener(MouseEvent.CLICK,this.onZCacheClick);
               m_bottomUI.removeChild(this.m_zcacheButton);
            }
            this.m_zcacheButton = newButton;
            this.m_zcacheButton.addEventListener(MouseEvent.CLICK,this.onZCacheClick);
            this.m_zcacheButton.toolTip = ZLocUtils.t("FarmGame","EnableZCache_ToolTip");
            this.m_zcacheButton.x = X_POSITION_CAMERA_BUTTON;
            this.m_zcacheButton.y = Y_POSITION_CAMERA_BUTTON;
            this.addBehindActionMenu(this.m_zcacheButton);
         }
      }
      
      public function set fullScreenButton(newButton:SpriteButton) : void
      {
         if(newButton)
         {
            if(this.m_fullscreen)
            {
               this.m_fullscreen.removeEventListener(MouseEvent.CLICK,this.onFullscreenClick);
               m_bottomUI.removeChild(this.m_fullscreen);
            }
            this.m_fullscreen = newButton;
            this.m_fullscreen.addEventListener(MouseEvent.CLICK,this.onFullscreenClick);
            this.m_fullscreen.toolTip = ZLocUtils.t("FarmGame","FullScreen_ToolTip");
            this.m_fullscreen.x = X_POSITION_FULLSCREEN_BUTTON;
            this.m_fullscreen.y = Y_POSITION_FULLSCREEN_BUTTON;
            this.addBehindActionMenu(this.m_fullscreen);
         }
      }
      
      private function addBehindActionMenu(hudElement:DisplayObject) : void
      {
         var actionMenuDepth:int = 0;
         if(Boolean(m_bottomUI) && Boolean(m_actionMenu))
         {
            actionMenuDepth = m_bottomUI.getChildIndex(m_actionMenu);
            m_bottomUI.addChildAt(hudElement,actionMenuDepth - 1);
         }
         else
         {
            m_bottomUI.addChild(hudElement);
         }
      }
      
      public function initActionMenu() : void
      {
         m_actionMenu = new ActionMenu();
         m_actionMenu.x = 614;
         m_actionMenu.y = 470;
         m_bottomUI.addChild(m_actionMenu);
      }
      
      public function setBottomUIVisible(visible:Boolean) : void
      {
         m_bottomUI.visible = visible;
      }
      
      public function set terrain(edit:Boolean) : void
      {
         removeAllCursors();
         m_actionMenu.terrainMode(edit);
      }
   }
}

