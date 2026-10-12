package Classes
{
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Terrain.TerrainUtil;
   import Classes.ZItem.FarmItem;
   import Classes.feed.SharePurchaseFeed;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.AOEWorldObject;
   import Engine.Classes.CollisionMap;
   import Engine.Classes.World;
   import Engine.Constants;
   import Engine.Events.LoaderEvent;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Events.FarmGameWorldEvent;
   import Events.GenericPopupEvent;
   import GameMode.GMMultiResourceAction;
   import GameMode.GameMode;
   import Managers.AOEManager;
   import Managers.AltGraphicUtility;
   import Managers.DefconManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.FeatureOptionsManager;
   import Managers.InstanceDataStoreManager;
   import Managers.NPCManager;
   import Managers.PerformanceExperimentManager;
   import Managers.ToasterManager;
   import Managers.ToolModeManager;
   import Managers.TrickOrTreatManager;
   import MyLife.Events.GlobalEventManager;
   import Transactions.TInventoryStore;
   import Transactions.TRemoveAltGraphic;
   import Transactions.TSell;
   import Transactions.TSetAltGraphic;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.AOETooltip;
   import Widgets.Windows.GenericCustomAdToaster;
   import com.infomatiq.jsi.RectangleUtil;
   import com.urbansquall.ginger.AnimationPlayer;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   
   public class MapResource extends ItemInstance
   {
      
      private static var m_overlayLoader:ImageLoader;
      
      public static const OBSERVABLE_EVENT_STATE:String = "STATE";
      
      public static const OBSERVABLE_EVENT_ALPHA:String = "ALPHA";
      
      public static const MC_ANIMATION_MAX_DEPTH:int = 5;
      
      public static const AOE_BONUS_COLOR:uint = 39423;
      
      public static const AOE_HIGHLIGHT_COLOR:uint = 65535;
      
      public static const INVALID_HIGHLIGHT_COLOR:int = -1;
      
      protected static const MAX_ANIMATION_TIME:int = 20;
      
      public static const EVENT_TOGGLE_ANIMATION:String = "toggleAnimation";
      
      protected static const MOVE_OBJECT:String = "moveObject";
      
      protected static const SELL_OBJECT:String = "sellObject";
      
      protected static const ROTATE_OBJECT:String = "rotateObject";
      
      protected static const STORE_OBJECT:String = "storeObject";
      
      protected static const SET_ALT_GRAPHIC:String = "showAltGraphic";
      
      protected static const HIDE_ALT_GRAPHIC:String = "hideAltGraphic";
      
      protected static const HIDE_ALL_ALT_GRAPHIC:String = "hideAllAltGraphic";
      
      protected static const VIEW_DETAILS:String = "viewDetails";
      
      protected static const OPEN_CRATE:String = "openCrate";
      
      protected static const TURN_ON_WITHER:String = "turnOnWither";
      
      protected static const TURN_OFF_WITHER:String = "turnOffWither";
      
      protected static const ENTER_PASSCODE:String = "enterPasscode";
      
      protected static const GET_PASSCODE:String = "getPasscode";
      
      protected static const START_PLOW:String = "startPlow";
      
      protected static const START_PLOTREMOVE:String = "startPlotRemove";
      
      protected static const START_HARVESTER:String = "startHarvester";
      
      protected static const START_SEEDER:String = "startSeeder";
      
      protected static const START_AIRPLANE:String = "startAirplane";
      
      protected static const START_COMBINE:String = "startCombine";
      
      protected static const START_ORCHARD_HARVESTER:String = "startOrchardHarvester";
      
      protected static const START_ANIMAL_PEN_HARVESTER:String = "startAnimalPen";
      
      protected static const START_IRRIGATION_SPRINKLER:String = "startIrrigationSprinkler";
      
      protected static const STORE_VEHICLE:String = "storeVehicle";
      
      protected static const UPGRADE_VEHICLE:String = "upgradeVehicle";
      
      protected static const CHANGE_NAME:String = "changeName";
      
      protected static const LOOK_INSIDE:String = "lookInside";
      
      protected static const DEBUG_SCALE_OBJECT:String = "debugScaleObject";
      
      protected static const DEBUG_GET_INFO:String = "debugGetInfo";
      
      protected static const DEBUG_CHANGE_EXPORT:String = "debugChangeExport";
      
      protected static const DEBUG_VIEW_XML:String = "debugViewXml";
      
      private static var CLASS_COMPILING_ARRAY:Array = [DragonImageProgression];
      
      protected static const PLAY_STATE:int = 0;
      
      protected static const PAUSE_STATE:int = 1;
      
      protected static const STOP_STATE:int = 2;
      
      protected static const LOADING_GRAPHIC_SCALE:Number = 0.75;
      
      protected static const RASTER_CLIP_SCALE:Number = 0.5;
      
      protected static const SHOW_MOUSE_MASK:Boolean = false;
      
      private static const ALT_EFFECT_URL:String = "assets/overlays/effect_fertilizer_fertilizing.swf";
      
      private static const SEEN_FLAG_EXPLAIN_ALT_EFFECT_CREDIT:String = "ExplainAltGraphicCredit";
      
      private static var m_effectLoader:ImageLoader = null;
      
      protected static var m_loadingPlaceholderData:BitmapData = null;
      
      protected var m_aoeImageState:String;
      
      protected var m_itemImage:ItemImage;
      
      protected var m_image:DisplayObject;
      
      private var m_state:String;
      
      protected var m_stateDisplayObjMap:Object;
      
      protected var m_content:DisplayObject;
      
      protected var m_numImageStates:int = 0;
      
      protected var m_maskBitmapData:BitmapData;
      
      protected var m_maskBitmapDisplacement:Vector2;
      
      public var m_isRotated:Boolean = false;
      
      protected var m_allowPlay:Boolean = true;
      
      protected var m_overlay:DisplayObject = null;
      
      protected var m_overlayXML:XML;
      
      protected var m_overlayRequested:Boolean = false;
      
      protected var m_overlayVersion:int;
      
      protected var m_overlayOffset:Number = 155;
      
      protected var m_colorMatrixFilter:ColorMatrixFilter = null;
      
      private var m_depthPosition:Vector3 = null;
      
      protected var m_pattern:String = "";
      
      private var m_fromMarket:Boolean = false;
      
      private var m_effectOverlay:DisplayObject = null;
      
      protected var m_usingLoadingGraphic:Boolean = false;
      
      protected var m_toolTipOverride:String = "";
      
      protected var m_imageLoadedCallback:Function;
      
      protected var m_altGraphic:String = "";
      
      protected var m_animationState:int = 0;
      
      protected var m_perfectLoopFinalFrame:int = -1;
      
      protected var m_perfectLoopFrameCount:int = 0;
      
      protected var m_lastUpdateFrame:int = -1;
      
      protected var m_wasPaused:Boolean = false;
      
      protected var m_currentTerrainName:String = null;
      
      private var m_usePixelPerfectSelection:Boolean = true;
      
      private var m_increasedCount:Boolean = true;
      
      protected var m_highlightColor:int = -1;
      
      protected var m_aoeWorldObjects:Vector.<AOEWorldObject>;
      
      protected var m_aoeBonusShowing:Boolean = false;
      
      private var m_aoeTargets:Array;
      
      protected var m_aoePlaceTime:Number;
      
      protected var m_aoeToolTip:AOETooltip;
      
      protected var m_aoeToolTips:Array;
      
      protected var m_hasStorageDialog:Boolean;
      
      protected var m_storageDialogKey:String;
      
      private var m_imageProgression:IMapResourceImageProgression;
      
      private var m_persistentDataKey:String = null;
      
      protected var m_originalItemName:String = null;
      
      public function MapResource(itemName:String, increaseLimitedCount:Boolean = true)
      {
         var baseName:String = null;
         super(itemName);
         if(m_item)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               this.m_hasStorageDialog = m_item.hasPropertyInDataSource("storageDialog");
               if(this.m_hasStorageDialog)
               {
                  this.m_storageDialogKey = m_item.getStringFromDataSource("storageDialog");
               }
            }
            else
            {
               this.m_hasStorageDialog = m_item.xml.hasOwnProperty("storageDialog");
               if(this.m_hasStorageDialog)
               {
                  this.m_storageDialogKey = m_item.xml.storageDialog;
               }
            }
         }
         m_objectType = Constants.WORLDOBJECT_ITEM;
         m_typeName = "item";
         m_collisionFlags = Constants.COLLISION_ALL;
         this.m_stateDisplayObjMap = new Object();
         this.m_increasedCount = increaseLimitedCount;
         if(this.m_increasedCount)
         {
            if(Boolean(m_item) && m_item.limit > 0)
            {
               baseName = itemName.replace("_cash","");
               Global.player.addLimitedItem(baseName);
            }
         }
         this.m_aoeToolTips = new Array();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TOGGLE_ANIMATION) == Experiments.VARIANT_TOGGLE_ANIMATION)
         {
            GlobalEventManager.getInstance().addEventListener(EVENT_TOGGLE_ANIMATION,this.onToggleAnimation);
            this.onToggleAnimation(null);
         }
      }
      
      private function onToggleAnimation(event:Event) : void
      {
         if(Global.player.isAnimationDisabled())
         {
            if(m_displayObject != null)
            {
               this.stop();
            }
            this.allowAnimation = false;
         }
         else
         {
            if(m_displayObject != null)
            {
               this.play();
            }
            this.allowAnimation = true;
         }
      }
      
      public function get isUsingLoadingGraphic() : Boolean
      {
         return this.m_usingLoadingGraphic;
      }
      
      public function set allowAnimation(value:Boolean) : void
      {
         this.m_allowPlay = value;
      }
      
      protected function get currentTerrainName() : String
      {
         return this.m_currentTerrainName;
      }
      
      override public function cleanUp() : void
      {
         var i:int = 0;
         if(Boolean(this.m_increasedCount) && Boolean(m_item) && m_item.limit > 0)
         {
            Global.player.removeLimitedItem(m_itemName);
         }
         if(this.m_aoeWorldObjects)
         {
            for(i = 0; i < this.m_aoeWorldObjects.length; i++)
            {
               this.m_aoeWorldObjects[i].cleanUp();
               this.m_aoeWorldObjects[i] = null;
            }
            this.m_aoeWorldObjects = null;
         }
         if(this.m_imageProgression != null)
         {
            this.m_imageProgression.cleanUp();
            this.m_imageProgression = null;
         }
         super.cleanUp();
      }
      
      public function getPersistentData(featureName:String, dataName:String = null) : Object
      {
         return InstanceDataStoreManager.getPersistentData(this,featureName,dataName);
      }
      
      public function setPersistentDataVolatile(persistentData:Object, featureName:String, dataName:String = null) : void
      {
         InstanceDataStoreManager.setPersistentDataVolatile(this,persistentData,featureName,dataName);
      }
      
      public function initEmptyPersistentData() : void
      {
      }
      
      public function get persistentDataKey() : String
      {
         return this.m_persistentDataKey;
      }
      
      public function attachToPersistentData(dataKey:String) : void
      {
         if(this.persistentDataKey != dataKey)
         {
            InstanceDataStoreManager.detatchInstanceFromKey(this);
            this.m_persistentDataKey = dataKey;
            InstanceDataStoreManager.attachInstanceToKey(this);
         }
      }
      
      public function attachSuccessCallback(storageKey:String) : void
      {
      }
      
      public function clearPersistentDataKey() : void
      {
         if(this.persistentDataKey)
         {
            InstanceDataStoreManager.detatchInstanceFromKey(this);
         }
         this.m_persistentDataKey = null;
      }
      
      public function getMetadataKey() : String
      {
         return "";
      }
      
      public function getMetadata() : Object
      {
         return null;
      }
      
      internal function getItemImage() : ItemImage
      {
         return this.m_itemImage;
      }
      
      public function setMetadata(value:Object) : void
      {
      }
      
      protected function canShowStoreMenuItem() : Boolean
      {
         return true;
      }
      
      protected function canShowMoveMenuItem() : Boolean
      {
         return true;
      }
      
      protected function canShowSellMenuItem() : Boolean
      {
         return true;
      }
      
      public function set fromMarket(value:Boolean) : void
      {
         this.m_fromMarket = value;
      }
      
      public function get fromMarket() : Boolean
      {
         return this.m_fromMarket;
      }
      
      public function onPlacementFeedPost(url:String) : void
      {
         var shareFeed:SharePurchaseFeed = new SharePurchaseFeed(m_item.name,url);
         shareFeed.startFeedFlow();
      }
      
      public function onFinishPlace(transactionResult:Object = null) : void
      {
         var prereq:String = null;
         var limitedItems:Object = null;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            prereq = m_item.getStringFromDataSource("purchasePrereqs");
         }
         else if(m_item.xml.purchasePrereqs != null)
         {
            prereq = String(m_item.xml.purchasePrereqs);
         }
         if(prereq)
         {
            if(prereq.indexOf(PrerequisiteConstants.PREREQUISITE_GLOBAL_LIMIT) >= 0)
            {
               limitedItems = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FEATURE_LIMITED_ITEMS,FeatureOptionsManager.FEATURE_LIMITED_ITEMS);
               if(limitedItems == null)
               {
                  limitedItems = {};
               }
               if(limitedItems.hasOwnProperty(m_item.name))
               {
                  ++limitedItems[m_item.name];
               }
               else
               {
                  limitedItems[m_item.name] = 1;
               }
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FEATURE_LIMITED_ITEMS,FeatureOptionsManager.FEATURE_LIMITED_ITEMS,limitedItems);
            }
         }
      }
      
      override public function showMenu() : void
      {
         var exports:Array = null;
         var export:String = null;
         if(Global.toolMode && getItem().isToolGenerated || Global.artuploadSandboxMode)
         {
            m_menuItems.push({
               "label":"Art Sandbox: Scale",
               "action":DEBUG_SCALE_OBJECT
            });
         }
         if(Global.toolMode || Global.artuploadSandboxMode)
         {
            m_menuItems.push({
               "label":"Art Sandbox: Get Info",
               "action":DEBUG_GET_INFO
            });
         }
         if(Global.toolMode)
         {
            m_menuItems.push({
               "label":"Art Sandbox: View XML",
               "action":DEBUG_VIEW_XML
            });
         }
         if(Global.toolMode || Global.artuploadSandboxMode)
         {
            exports = m_item.getExpectedExportNames();
            for each(export in exports)
            {
               m_menuItems.push({
                  "label":export,
                  "action":DEBUG_CHANGE_EXPORT
               });
            }
         }
         if(Global.storageSettings.storageCanTake("Inventory",this) && !getItem().specialValentinesItem && this.canShowStoreMenuItem())
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","Store"),
               "action":STORE_OBJECT
            });
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SNOW_AND_LIGHTS) > 0)
         {
            if(this.shouldDisplayAltGraphicMenu() == true && m_item.displayLoader.hasImageNameDefined("bare_lights") && m_item.displayLoader.hasImageNameDefined("mature_lights") && m_item.displayLoader.hasImageNameDefined("bare_snow") && m_item.displayLoader.hasImageNameDefined("mature_snow") && m_item.displayLoader.hasImageNameDefined("bare_xmaslight") && m_item.displayLoader.hasImageNameDefined("mature_xmaslight"))
            {
               this.populateAltGraphicMenu();
            }
         }
         else if(this.shouldDisplayAltGraphicMenu() == true)
         {
            this.populateAltGraphicMenu();
         }
         super.showMenu();
      }
      
      protected function populateAltGraphicMenu() : void
      {
         var altGraphic:String = null;
         if(this.m_altGraphic != "")
         {
            m_menuItems.push({
               "label":ZLocUtils.t("FarmGame","HideAltGraphic_" + this.m_altGraphic),
               "action":HIDE_ALT_GRAPHIC,
               "params":{"graphic":this.m_altGraphic}
            });
            if(FeatureConfigManager.getFeatureConfiguration(TrickOrTreatManager.instance.featureCreditName).isFeatureVisible())
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","HideAllAltGraphics"),
                  "action":HIDE_ALL_ALT_GRAPHIC,
                  "params":{"graphic":this.m_altGraphic}
               });
            }
         }
         else
         {
            for each(altGraphic in getItem().getAltGraphics())
            {
               if(this.canSetAltGraphic(altGraphic) && (Global.player.numAltGraphicCredits(altGraphic) > 0 || Global.player.hasUnlimitedCredits(altGraphic)))
               {
                  m_menuItems.push({
                     "label":ZLocUtils.t("FarmGame","ShowAltGraphic_" + altGraphic),
                     "action":SET_ALT_GRAPHIC,
                     "params":{"graphic":altGraphic}
                  });
               }
            }
            if(altGraphic == null)
            {
               for each(altGraphic in Global.farmGameSettingsManager.getCurrentAltGraphics())
               {
                  if(this.canSetAltGraphic(altGraphic) && (Global.player.numAltGraphicCredits(altGraphic) > 0 || Global.player.hasUnlimitedCredits(altGraphic)))
                  {
                     m_menuItems.push({
                        "label":ZLocUtils.t("FarmGame","ShowAltGraphic_" + altGraphic),
                        "action":SET_ALT_GRAPHIC,
                        "params":{"graphic":altGraphic}
                     });
                  }
               }
            }
         }
      }
      
      public function get altGraphic() : String
      {
         return this.m_altGraphic;
      }
      
      public function get overlay() : String
      {
         return this.m_overlayXML != null ? this.m_overlayXML.@name : "";
      }
      
      public function applyOverlay(name:String, overlayVersion:int = 0) : void
      {
         this.m_overlayXML = Global.farmGameSettingsManager.getOverlayByName(name);
         this.m_overlayVersion = overlayVersion;
         this.conditionallyAttachOverlay();
         m_displayObjectDirty = true;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var altGraphicKey:String = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case STORE_OBJECT:
                  this.onAddToInventory();
                  break;
               case HIDE_ALT_GRAPHIC:
                  altGraphicKey = item.getParam("graphic");
                  this.removeAlternativeGraphic(altGraphicKey,true,true);
                  break;
               case HIDE_ALL_ALT_GRAPHIC:
                  TrickOrTreatManager.instance.clearAllAltGraphics();
                  break;
               case SET_ALT_GRAPHIC:
                  this.setAltGraphic(item.getParam("graphic"),0);
                  break;
               case DEBUG_SCALE_OBJECT:
                  ToolModeManager.showScaleDialog(this,this.getImageScaleFactor(),getSizeNoClone().x,getSizeNoClone().y);
                  break;
               case DEBUG_GET_INFO:
                  ToolModeManager.showDebugInfo(getItem(),this.getImageScaleFactor(),getSizeNoClone().x,getSizeNoClone().y);
                  break;
               case DEBUG_CHANGE_EXPORT:
                  m_item.testAssetExportName = item.label;
                  this.reloadImage();
                  break;
               case DEBUG_VIEW_XML:
                  ToolModeManager.viewItemXml(this);
            }
         }
      }
      
      public function getAlternativeGraphic() : String
      {
         return this.m_altGraphic ? this.m_altGraphic : "";
      }
      
      public function removeAlternativeGraphic(graphic:String, updatePlayer:Boolean, fireTransaction:Boolean = false) : void
      {
         var altGraphicKey:String = graphic;
         altGraphicKey = altGraphicKey == "snow" ? "snow_altgraphic" : altGraphicKey;
         this.m_altGraphic = "";
         if(updatePlayer)
         {
            if(AltGraphicUtility.creditOnRemove(altGraphicKey))
            {
               Global.player.incAltGraphicCredits(altGraphicKey);
            }
            Global.hud.setLightIcon();
         }
         if(fireTransaction)
         {
            addTransaction(new TRemoveAltGraphic(this,altGraphicKey));
         }
         this.reloadImage();
      }
      
      public function removeOverlay(fireTransaction:Boolean = false) : void
      {
         if(this.m_overlay != null && this.m_overlayXML != null)
         {
            (this.m_displayObject as Sprite).removeChild(this.m_overlay);
            if(fireTransaction)
            {
               addTransaction(new TRemoveAltGraphic(this,this.m_overlayXML.@name));
               if(this.m_overlayXML.@altGraphicCredits != "" && AltGraphicUtility.creditOnRemove(this.m_overlayXML.@altGraphicCredits))
               {
                  Global.player.incAltGraphicCredits(this.m_overlayXML.@altGraphicCredits);
               }
               this.m_overlay = null;
               this.m_overlayRequested = false;
            }
         }
      }
      
      protected function conditionallyAttachOverlay() : void
      {
         var assetUrl:String = null;
         var spr:Sprite = null;
         if(this.m_overlayXML != null && Boolean(this.m_overlayXML.offsetY))
         {
            this.m_overlayOffset = Number(this.m_overlayXML.offsetY);
         }
         if(!this.m_overlayRequested && this.m_overlay == null && Boolean(this.m_overlayXML))
         {
            if(this.m_overlayXML.elements("url").length() > 1)
            {
               assetUrl = this.m_overlayXML.elements("url")[this.m_overlayVersion].toString();
            }
            else
            {
               assetUrl = this.m_overlayXML.url.toString();
            }
            m_overlayLoader = ImageLoader.getInstance(Global.getAssetURL(assetUrl),true);
            m_overlayLoader.getContent(this.onOverlayLoad);
            this.m_overlayRequested = true;
         }
         else if(this.m_overlay != null)
         {
            spr = m_displayObject as Sprite;
            if(spr != null && spr.numChildren > 0)
            {
               spr.addChild(this.m_overlay);
               this.m_overlay.y = 0;
               this.m_overlay.scaleX = 1;
               this.m_overlay.scaleY = 1;
            }
         }
      }
      
      public function isValidOverlayTarget(name:String) : Boolean
      {
         var overlayKeyword:String = null;
         var keywords:Array = null;
         var result:Boolean = false;
         var overlay:XML = Global.farmGameSettingsManager.getOverlayByName(name);
         if(overlay)
         {
            for each(overlayKeyword in overlay.allowedItems.keyword)
            {
               keywords = getItem().keywords;
               if(keywords.indexOf(overlayKeyword) != -1)
               {
                  result = true;
                  break;
               }
            }
         }
         return result && this.m_overlay == null;
      }
      
      protected function onOverlayLoad(content:DisplayObject, info:Object = null) : void
      {
         if(content != null)
         {
            this.m_overlay = content;
            this.conditionallyAttachOverlay();
         }
      }
      
      public function canSetAltGraphic(name:String) : Boolean
      {
         var result:Boolean = false;
         if(getItem() != null)
         {
            if(this.isAltGraphicAvailable(name))
            {
               result = true;
            }
         }
         return result;
      }
      
      protected function shouldDisplayAltGraphicMenu() : Boolean
      {
         var result:Boolean = true;
         var item:FarmItem = this.getItem();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(item.hasPropertyInDataSource("allowUserToggleAltGraphic"))
            {
               result = item.getBoolFromDataSource("allowUserToggleAltGraphic");
            }
         }
         else if(item.xml.@allowUserToggleAltGraphic.length() > 0)
         {
            result = item.xml.@allowUserToggleAltGraphic[0] == "true";
         }
         return result;
      }
      
      private function setAltGraphicStopEffectCallback(event:TimerEvent) : void
      {
         this.stopEffect();
         event.currentTarget.removeEventListener(TimerEvent.TIMER_COMPLETE,this.setAltGraphicStopEffectCallback);
      }
      
      public function setAltGraphic(name:String, cash:int, sendTransaction:Boolean = true) : Boolean
      {
         var tm:Timer = null;
         var cost:int = cash;
         var result:Boolean = false;
         if(Global.player.hasUnlimitedCredits(name))
         {
            cost = 0;
         }
         else if(Global.player.numAltGraphicCredits(name) > 0)
         {
            cost = 0;
            Global.player.decAltGraphicCredits(name);
            Global.hud.setLightIcon();
         }
         if(Global.player.canBuyCash(cost,true,"set_alt_graphic_" + name))
         {
            SoundManager.playSound("setgraphic");
            this.useAltGraphic(name);
            Global.player.cash -= cost;
            this.reloadImage();
            this.addEffect(ALT_EFFECT_URL);
            result = true;
            if(sendTransaction)
            {
               addTransaction(new TSetAltGraphic(this,name));
            }
            tm = new Timer(2000,1);
            tm.addEventListener(TimerEvent.TIMER_COMPLETE,this.setAltGraphicStopEffectCallback);
            tm.start();
         }
         return result;
      }
      
      protected function onAddToInventory() : void
      {
         var storeItem:Boolean = false;
         if(Global.player.hasInventorySpace() && !isToolGenerated)
         {
            if(Global.storageSettings.storageCanTake("Inventory",this))
            {
               storeItem = this.preAddToInventoryCheck();
               if(storeItem)
               {
                  addTransaction(new TInventoryStore(this,0,this.getId(),false));
                  FarmStatsManager.sample(100,"Storage","goods","stored","store_it_menu","sucess");
               }
               else
               {
                  this.preAddToInventoryCheckFailed();
               }
            }
            else
            {
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","InventoryInvalid")));
               FarmStatsManager.sample(100,"Storage","goods","stored","store_it_menu","invalid_item");
            }
         }
         else
         {
            if(Global.player.getInventoryUsage() == Global.farmGameSettingsManager.getAttribute("maxInventoryCapacity"))
            {
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","InventoryFullNoExpansion")));
            }
            else
            {
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","InventoryFull")));
            }
            FarmStatsManager.sample(100,"Storage","goods","stored","store_it_menu","inventory_full");
         }
      }
      
      public function addToInventory() : void
      {
         this.onAddToInventory();
      }
      
      public function canAddToInventory() : Boolean
      {
         return Global.player.hasInventorySpace() && this.isStorable() && !isToolGenerated && Global.storageSettings.storageCanTake("Inventory",this) && this.preAddToInventoryCheck();
      }
      
      public function preAddToInventoryCheckFailed() : void
      {
      }
      
      public function preAddToInventoryCheck() : Boolean
      {
         return true;
      }
      
      public function isUsingPerPixelPick() : Boolean
      {
         return false;
      }
      
      override public function getSaveObject() : Object
      {
         var obj:Object = super.getSaveObject();
         obj.state = this.state;
         obj.instanceDataStoreKey = this.persistentDataKey;
         var originalNameRuntimeBlock:Boolean = Boolean(Global.flashHotParams["TRANSACTION_ITEM_ORIGINAL_NAME"]);
         if(originalNameRuntimeBlock == true)
         {
            if(this.m_originalItemName != null && this.m_originalItemName != "" && this.m_originalItemName != obj.itemName)
            {
               obj.itemName = this.m_originalItemName;
            }
         }
         return obj;
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(data.instanceDataStoreKey)
         {
            this.attachToPersistentData(data.instanceDataStoreKey);
         }
         this.state = data.state;
         if(data.usesAltGraphic)
         {
            this.m_altGraphic = data.altGraphic;
         }
         if(data.pattern)
         {
            this.m_pattern = data.pattern;
         }
         if(data.aoePlaceTime)
         {
            this.m_aoePlaceTime = data.aoePlaceTime;
         }
         else
         {
            this.m_aoePlaceTime = 0;
         }
      }
      
      override public function reloadImage() : void
      {
         this.m_image = null;
         this.m_maskBitmapData = null;
         super.reloadImage();
      }
      
      protected function setDisplayForState(value:String, obj:Object) : void
      {
         this.m_stateDisplayObjMap[value] = obj;
      }
      
      override public function setHighlighted(highlighted:Boolean, color:uint = 16755200) : void
      {
         color = this.m_highlightColor != MapResource.INVALID_HIGHLIGHT_COLOR ? uint(this.m_highlightColor) : color;
         super.setHighlighted(highlighted,color);
      }
      
      public function set highlightColor(value:int) : void
      {
         this.m_highlightColor = value;
      }
      
      override protected function onItemImageLoaded(event:Event) : void
      {
         this.m_image = null;
         super.onItemImageLoaded(event);
      }
      
      override public function createDisplayObject() : DisplayObject
      {
         var highlightColorValue:int = 0;
         m_displayObject = new Sprite();
         this.conditionallyRedraw(true);
         if(m_item)
         {
            highlightColorValue = m_item.getHighlightColor();
            if(highlightColorValue != MapResource.INVALID_HIGHLIGHT_COLOR)
            {
               this.highlightColor = highlightColorValue;
            }
         }
         return m_displayObject;
      }
      
      override public function conditionallyRedraw(forceRedraw:Boolean = false) : void
      {
         if(!forceRedraw && this.m_currentTerrainName != this.findTerrainName())
         {
            forceRedraw = true;
         }
         super.conditionallyRedraw(forceRedraw);
      }
      
      override public function conditionallyReattach(force:Boolean = false) : void
      {
         if(!force && this.m_currentTerrainName != this.findTerrainName())
         {
            force = true;
            setDisplayObjectDirty(true);
         }
         super.conditionallyReattach(force);
      }
      
      override public function drawDisplayObject() : void
      {
         var mc:MovieClip = null;
         var ldr:Loader = null;
         var terrainName:String = null;
         var imageName:String = null;
         var spr:Sprite = m_displayObject as Sprite;
         if(spr == null)
         {
            this.createDisplayObject();
         }
         if(spr != null)
         {
            mc = null;
            ldr = null;
            terrainName = this.findTerrainName();
            if(this.m_image == null || this.m_currentTerrainName != terrainName)
            {
               this.m_currentTerrainName = terrainName;
               if((Boolean(Global.toolMode || Global.artuploadSandboxMode)) && Boolean(m_item) && Boolean(m_item.testAssetExportName))
               {
                  this.m_itemImage = m_item.getCachedImage(m_item.testAssetExportName);
               }
               else
               {
                  this.m_itemImage = this.getCurrentImage();
               }
               imageName = "";
               if(this.m_itemImage == null)
               {
                  if(m_item)
                  {
                     m_item.addEventListener(LoaderEvent.LOADED,this.onImageLoaded);
                  }
                  else
                  {
                     GlobalEngine.log("Load Error","m_item not set!");
                  }
               }
               else if(Boolean(this.m_itemImage) && Boolean(this.m_itemImage.image is Class) || this.m_itemImage.image is DisplayObject)
               {
                  if(this.m_itemImage.image is Class)
                  {
                     this.m_image = new this.m_itemImage.image();
                  }
                  else if(!(this.m_itemImage.image is Loader))
                  {
                     this.m_image = this.m_itemImage.image as DisplayObject;
                  }
                  this.m_usePixelPerfectSelection = this.m_itemImage.pixelPerfectPick;
                  if(this.m_animationState == STOP_STATE && this.m_itemImage.image is MovieClip && this.m_itemImage.lowResImage is BitmapData)
                  {
                     this.replaceContentWithBitmap(true);
                  }
                  else if(this.m_itemImage.image is Loader)
                  {
                     ldr = this.m_itemImage.image as Loader;
                     this.m_image = ldr;
                     ldr.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onImageLoaded);
                     if(this.m_itemImage.lowResImage)
                     {
                        this.replaceContentWithBitmap(true);
                     }
                  }
                  else if(this.m_image != null)
                  {
                     this.replaceContent(this.m_image,true);
                  }
               }
            }
            else if(this.m_image is Loader)
            {
               ldr = this.m_image as Loader;
               if(Boolean(ldr) && Boolean(ldr.content))
               {
                  this.replaceContent(ldr.content,true);
               }
            }
            else
            {
               GlobalEngine.log("Loading","ERROR: unkown loading case in MapResource.drawDisplayObject");
            }
            if(this.m_content == null || this.shouldDisplayPlaceholder())
            {
               if(m_loadingPlaceholderData == null)
               {
                  m_loadingPlaceholderData = (new EmbeddedArt.loadingPlaceholder() as Bitmap).bitmapData;
               }
               this.m_itemImage = new ItemImage(m_loadingPlaceholderData);
               this.replaceContentWithPlaceholder();
            }
            drawActionBar();
         }
      }
      
      protected function shouldDisplayPlaceholder() : Boolean
      {
         return false;
      }
      
      protected function restartAnimation() : void
      {
         var ldr:Loader = null;
         var shouldPlay:Boolean = this.isAnimating;
         var mcContent:MovieClip = this.m_content as MovieClip;
         if(mcContent)
         {
            this.toggleAnimationRecursively(mcContent,shouldPlay);
         }
         else if(Boolean(this.m_content is Bitmap) && Boolean(this.m_itemImage) && this.m_itemImage.image is MovieClip)
         {
            mcContent = this.m_itemImage.image as MovieClip;
            this.replaceContent(mcContent,true);
            this.toggleAnimationRecursively(mcContent,shouldPlay);
         }
         else if(this.m_image is MovieClip)
         {
            mcContent = this.m_image as MovieClip;
            if(mcContent.numChildren > 0)
            {
               ldr = mcContent.getChildAt(0) as Loader;
               if(Boolean(ldr) && Boolean(ldr.content))
               {
                  this.replaceContent(ldr.content,true);
               }
            }
         }
         else if(this.m_image is Loader)
         {
            mcContent = (this.m_image as Loader).content as MovieClip;
            if(mcContent)
            {
               this.replaceContent(mcContent,true);
            }
         }
      }
      
      private function makeMaskBitmap() : void
      {
         var dispObj:DisplayObject = this.getMaskDisplayObject();
         if(dispObj)
         {
            if(dispObj is Bitmap)
            {
               this.m_maskBitmapData = (dispObj as Bitmap).bitmapData;
            }
            else if((Boolean(dispObj is MovieClip || dispObj is AnimationPlayer || dispObj is Loader)) && Boolean(this.m_itemImage) && this.m_itemImage.lowResImage is BitmapData)
            {
               this.m_maskBitmapData = this.m_itemImage.lowResImage as BitmapData;
               this.m_maskBitmapDisplacement = this.m_itemImage.lowResImageDisplacement;
            }
            else if(!this.m_usingLoadingGraphic)
            {
               if(Config.DEBUG_MODE)
               {
                  ErrorManager.addError("Art Asset for: " + this.m_item.name + " display object does not have maskBitmapData");
               }
            }
         }
      }
      
      protected function getMaskDisplayObject() : DisplayObject
      {
         var result:DisplayObject = null;
         if(this.isUsingPerPixelPick() && Boolean(this.m_content))
         {
            result = this.m_content;
         }
         return result;
      }
      
      protected function replaceContentWithBitmap(shouldRedrawMask:Boolean = false) : void
      {
         var bitmap:Bitmap = new Bitmap(this.m_itemImage.lowResImage as BitmapData);
         if(this.m_itemImage.lowResImageDisplacement)
         {
            bitmap.x = this.m_itemImage.lowResImageDisplacement.x;
            bitmap.y = this.m_itemImage.lowResImageDisplacement.y;
         }
         this.replaceContent(bitmap,shouldRedrawMask);
      }
      
      protected function replaceContentWithPlaceholder() : void
      {
         var spr:Sprite = m_displayObject as Sprite;
         Utilities.toggleInputAndChildren(spr,false);
         Utilities.removeAllChildren(spr);
         this.m_usingLoadingGraphic = true;
         if(m_loadingPlaceholderData == null)
         {
            m_loadingPlaceholderData = (new EmbeddedArt.loadingPlaceholder() as Bitmap).bitmapData;
         }
         var bitmap:Bitmap = new Bitmap(m_loadingPlaceholderData,"auto",true);
         bitmap.scaleX = bitmap.scaleY = 1;
         this.m_content = bitmap;
         spr.addChild(this.m_content);
         this.makeMaskBitmap();
         this.updateDisplayObjectTransform();
      }
      
      protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         var spr:Sprite = m_displayObject as Sprite;
         var allowClickAction:Boolean = Global.worldManager.isVisitingNPC() && Global.worldManager.npcClickEnabled;
         Utilities.toggleInputAndChildren(spr,allowClickAction);
         this.m_usingLoadingGraphic = false;
         Utilities.removeAllChildren(spr);
         this.m_content = newContent;
         this.addContent(spr,this.m_content);
         if(this.m_content is MovieClip)
         {
            Utilities.toggleSound(this.m_content as MovieClip,!Global.player.isSfxDisabled());
         }
         this.initializeFilters();
         if(shouldRedrawMask)
         {
            this.makeMaskBitmap();
         }
         this.updateDisplayObjectTransform();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_TIMED_ACTION_QUEUE) > 0)
         {
            if(this.hasAreasOfEffect() && AOEManager.getInstance().doesAOESourceGiveStateChange(this.getId()))
            {
               AOEManager.getInstance().addAOEStateChangeSource(this);
            }
         }
      }
      
      protected function addContent(sprite:Sprite, content:DisplayObject) : void
      {
         if(sprite != null && content != null)
         {
            sprite.addChild(content);
         }
      }
      
      protected function initializeFilters() : void
      {
      }
      
      protected function getCurrentImage() : ItemImage
      {
         var currentImageName:String = this.getCurrentImageName();
         if(currentImageName != null && Boolean(m_item))
         {
            currentImageName = this.postProcessImageName(currentImageName);
            return this.getCachedImage(currentImageName);
         }
         return this.getCurrentImageFromState();
      }
      
      public function isCurrentImageFullyLoaded() : Boolean
      {
         return this.getCurrentImage() != null;
      }
      
      public function getCurrentImageName() : String
      {
         return null;
      }
      
      protected function getImageProgression() : IMapResourceImageProgression
      {
         var imageProgressionClass:Class = null;
         if(this.m_imageProgression == null && m_item.imageProgressionClassName != null)
         {
            imageProgressionClass = getDefinitionByName("Classes." + m_item.imageProgressionClassName) as Class;
            this.m_imageProgression = new imageProgressionClass(this) as IMapResourceImageProgression;
         }
         return this.m_imageProgression;
      }
      
      protected function getCurrentImageFromState() : ItemImage
      {
         var result:ItemImage = null;
         if(this.m_stateDisplayObjMap.hasOwnProperty(this.state))
         {
            result = this.m_stateDisplayObjMap[this.state] as ItemImage;
         }
         return result;
      }
      
      protected function getImageScaleFactor() : Number
      {
         var result:Number = 1;
         if(this.m_usingLoadingGraphic)
         {
            result = LOADING_GRAPHIC_SCALE;
         }
         else if(Boolean(m_item) && Boolean(m_item.imageScale))
         {
            result = m_item.imageScale;
         }
         return result;
      }
      
      override public function getDepthPosition() : Vector3
      {
         return this.getDepthPositionNoClone().clone();
      }
      
      override public function getDepthPositionNoClone() : Vector3
      {
         var farmItem:FarmItem = null;
         if(this.m_depthPosition == null)
         {
            farmItem = this.getItem();
            if(farmItem != null)
            {
               this.m_depthPosition = farmItem.getDepthOffset();
            }
            if(this.m_depthPosition == null)
            {
               this.m_depthPosition = new Vector3(m_position.x,m_position.y);
            }
            else
            {
               this.m_depthPosition.x += m_position.x;
               this.m_depthPosition.y += m_position.y;
            }
         }
         return this.m_depthPosition;
      }
      
      protected function getDisplayHorizontalOffset() : Number
      {
         var result:Number = 0;
         if(m_item)
         {
            result = m_item.getDisplayHorizontalOffset();
         }
         return result;
      }
      
      protected function getDisplayVerticalOffset() : Number
      {
         var result:Number = 0;
         if(m_item)
         {
            result = m_item.getDisplayVerticalOffset();
         }
         return result;
      }
      
      override public function updateDisplayObjectTransform() : void
      {
         var contentWidth:Number = NaN;
         var boxWidth:Number = NaN;
         var scale:Number = NaN;
         var deltaX:Vector2 = null;
         super.updateDisplayObjectTransform();
         this.m_depthPosition = null;
         var position:Vector3 = getReference().getPosition();
         var size:Vector3 = getReference().getSize();
         m_screenPosition = IsoMath.tilePosToPixelPos(position.x,position.y,0,true);
         var deltaY:Vector2 = IsoMath.getPixelDeltaFromTileDelta(0,size.y);
         var contentHeight:Number = -1;
         var xOffset:Number = 0;
         var yOffset:Number = 0;
         if(this.m_content)
         {
            if(Boolean(PerformanceExperimentManager.isInRasterMetadataExperiment) && Boolean(this.m_itemImage) && this.m_itemImage.image is AnimationPlayer)
            {
               m_displayObject.scaleX = m_displayObject.scaleY = RASTER_CLIP_SCALE;
               contentHeight = this.m_content.height * RASTER_CLIP_SCALE;
            }
            else
            {
               if(Boolean(this.m_itemImage) && Boolean(this.m_itemImage.forceScale != 0) && !(this.m_content is Bitmap))
               {
                  this.m_content.scaleX = this.m_content.scaleY = this.m_itemImage.forceScale;
               }
               contentWidth = 0;
               if(this.m_maskBitmapData)
               {
                  contentWidth = this.m_maskBitmapData.width;
               }
               else
               {
                  contentWidth = this.m_content.width;
               }
               boxWidth = 0;
               if(Boolean(this.m_itemImage) && this.m_itemImage.boxWidth > 0)
               {
                  boxWidth = this.m_itemImage.boxWidth;
               }
               else
               {
                  deltaX = IsoMath.getPixelDeltaFromTileDelta(size.x,0);
                  boxWidth = Math.abs(deltaX.x - deltaY.x);
               }
               scale = boxWidth / contentWidth * this.getImageScaleFactor();
               m_displayObject.scaleX = m_displayObject.scaleY = scale;
            }
            xOffset = this.getDisplayHorizontalOffset();
            yOffset = this.getDisplayVerticalOffset();
         }
         if(contentHeight <= 0)
         {
            if(Boolean(this.m_itemImage) && Boolean(this.m_itemImage.lowResImage))
            {
               contentHeight = this.m_itemImage.lowResImage.height * m_displayObject.scaleY;
            }
            else if(this.m_maskBitmapData)
            {
               contentHeight = this.m_maskBitmapData.height * m_displayObject.scaleY;
            }
            else if(this.m_content)
            {
               contentHeight = this.m_content.height * m_displayObject.scaleY;
            }
            else
            {
               contentHeight = m_displayObject.height;
            }
         }
         m_displayObject.x = m_screenPosition.x + deltaY.x * this.getImageScaleFactor() + xOffset;
         m_displayObject.y = m_screenPosition.y - contentHeight + yOffset;
         m_screenPosition.x = m_displayObject.x;
         m_screenPosition.y = m_displayObject.y;
         m_displayObject.visible = true;
      }
      
      public function setImageLoadedCallback(callback:Function) : void
      {
         this.m_imageLoadedCallback = callback;
      }
      
      protected function onImageLoaded(event:Event) : void
      {
         event.target.removeEventListener(LoaderEvent.LOADED,this.onImageLoaded);
         this.conditionallyRedraw(true);
         if(this.m_imageLoadedCallback != null)
         {
            this.m_imageLoadedCallback();
            this.m_imageLoadedCallback = null;
         }
      }
      
      public function setState(value:String) : void
      {
         this.state = value;
         this.m_image = null;
         this.m_maskBitmapData = null;
         setDisplayObjectDirty(true);
         this.conditionallyRedraw();
      }
      
      public function getState() : String
      {
         return this.state;
      }
      
      override public function checkInternalCollision(x:int, y:int, flags:int) : Boolean
      {
         return CollisionMap.compareCollisionFlags(this.getCollisionFlags(x,y),flags);
      }
      
      override public function getCollisionFlags(x:int, y:int) : int
      {
         var idx:int = 0;
         var collisionData:Vector.<int> = null;
         var result:int = 0;
         result = m_collisionFlags;
         var item:FarmItem = getItem();
         if(item)
         {
            collisionData = item.getCollisionData();
            if(this.isRotated())
            {
               idx = x * item.sizeX + y;
            }
            else
            {
               idx = y * item.sizeX + x;
            }
            if(idx >= 0 && collisionData.length > idx)
            {
               result = collisionData[idx];
            }
         }
         return result;
      }
      
      protected function isRotated() : Boolean
      {
         return false;
      }
      
      public function get usePixelPerfectSelection() : Boolean
      {
         return this.m_usePixelPerfectSelection;
      }
      
      override public function isPixelInside(pixel:Point) : Boolean
      {
         var localPixel:Point = null;
         var result:Boolean = super.isPixelInside(pixel);
         if(result)
         {
            if(Boolean(this.m_maskBitmapData) && this.m_usePixelPerfectSelection)
            {
               localPixel = pixel.subtract(new Point(m_displayObject.x,m_displayObject.y));
               localPixel.x /= m_displayObject.scaleX;
               localPixel.y /= m_displayObject.scaleY;
               if(this.m_maskBitmapDisplacement)
               {
                  localPixel.x -= this.m_maskBitmapDisplacement.x;
                  localPixel.y -= this.m_maskBitmapDisplacement.y;
               }
               result = this.m_maskBitmapData.hitTest(new Point(0,0),30,localPixel);
            }
         }
         return result;
      }
      
      override public function sell() : void
      {
         if((Global.quickDeleteOn || Global.persistentSell) && m_item.sellPrice < 1000 && !m_item.isLimitedItem() && m_item.storageSize <= 0)
         {
            super.sell();
         }
         else if(m_item)
         {
            UI.displayMessageWithHtml(this.getSellDisplayMessage(),GenericPopup.TYPE_YESNO,this.sellConfirmationHandler);
         }
         else
         {
            super.sell();
         }
      }
      
      protected function getSellDisplayMessage() : String
      {
         var yieldsString:String = "";
         if(m_item.sellCurrency != Currency.COINS)
         {
            yieldsString = m_item.untunedSellPrice + " " + ZLocUtils.t("FarmGame",Currency.COINS) + " and ";
         }
         yieldsString += m_item.sellDisplayPrice + " " + ZLocUtils.t("FarmGame",m_item.sellCurrency);
         return ZLocUtils.t("FarmGame","SellObjectSpecific",{
            "quantity":1,
            "item":ZLocUtils.tk_pk(m_item.friendlyName,"",1),
            "yieldsString":yieldsString
         });
      }
      
      override protected function sellConfirmationHandler(event:GenericPopupEvent = null) : void
      {
         var result:Boolean = false;
         if(event != null)
         {
            result = event.button == GenericPopup.YES;
         }
         else
         {
            result = true;
         }
         if(result == true)
         {
            if(this.zeroWorldPopupNeeded())
            {
               this.handleZeroWorldPopup();
            }
            else if(isSellable())
            {
               this.onSell();
               addTransaction(new TSell(this),true);
               this.detach();
               this.executeSell();
               this.postSellAction();
            }
         }
      }
      
      protected function executeSell() : void
      {
         var sellPrice:int = getSellPrice();
         var sellCurrency:String = Currency.COINS;
         var message:String = ZLocUtils.t("FarmGame","Status_ObjectSold",{
            "coinNum":sellPrice,
            "currency":ZLocUtils.t("FarmGame",Currency.COINS)
         });
         if(this.m_item.marketIsWorldCurrency)
         {
            sellCurrency = this.m_item.market;
            Global.player.updateWorldCurrency(sellCurrency,sellPrice);
            message += " " + ZLocUtils.t("FarmGame","Status_ObjectSold",{
               "coinNum":sellPrice,
               "currency":ZLocUtils.t("FarmGame",sellCurrency)
            });
         }
         Global.player.gold += sellPrice;
         displayStatus(message);
         if(m_item.isTiered)
         {
            Global.farmGameSettingsManager.updateItemByName(m_item.name);
         }
      }
      
      protected function postSellAction() : void
      {
      }
      
      public function zeroWorldPopupNeeded() : Boolean
      {
         return Global.world.getNumObjects() <= 2;
      }
      
      public function handleZeroWorldPopup() : void
      {
         var txt:String = ZLocUtils.t("Dialogs","NoFarmWithoutCrops");
         var genPop:GenericPopup = new GenericPopup(txt);
         Global.stage.addChild(genPop);
         genPop.show();
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if((this.isHighlighted() || this.getToolTip() != null) && !NPCManager.getInstance().isVisitingNPC)
         {
            this.updateToolTipText();
         }
      }
      
      override public function updateAnimation(delta:int) : void
      {
         var isAnimationComplete:Boolean = false;
         var currentUpdateFrame:int = 0;
         if(this.m_content is AnimationPlayer && this.isAnimating)
         {
            (this.m_content as AnimationPlayer).update(delta);
         }
         super.updateAnimation(delta);
         if(this.shouldTrackAnimation)
         {
            isAnimationComplete = false;
            if(this.m_content is AnimationPlayer)
            {
               currentUpdateFrame = this.currentFrame;
               if(currentUpdateFrame >= this.m_lastUpdateFrame)
               {
                  this.m_lastUpdateFrame = currentUpdateFrame;
               }
               else
               {
                  isAnimationComplete = true;
               }
            }
            else if(this.m_content is MovieClip)
            {
               ++this.m_perfectLoopFrameCount;
               if(this.m_perfectLoopFrameCount == this.m_perfectLoopFinalFrame)
               {
                  isAnimationComplete = true;
               }
            }
            if(isAnimationComplete)
            {
               this.resetAnimation();
               this.idle();
               this.onPlayComplete();
            }
         }
      }
      
      public function setOverrideToolTip(toolTip:String) : void
      {
         this.m_toolTipOverride = toolTip;
      }
      
      override protected function getCustomToolTipOffset() : Point
      {
         var screenPos:Point = null;
         var result:Point = null;
         if(this.getItem())
         {
            result = this.getItem().toolTipOffset;
         }
         else
         {
            result = new Point(0,0);
         }
         if(this.m_aoeToolTip)
         {
            screenPos = this.getScreenPosition();
            result.y = screenPos.y - this.m_aoeToolTip.y - 50;
         }
         return result;
      }
      
      override public function setOuter(outer:World) : void
      {
         if(outer != null)
         {
            super.setOuter(outer);
         }
         else
         {
            m_outer = outer;
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         if(this.m_animationState == PAUSE_STATE && this.play())
         {
            this.m_wasPaused = true;
         }
         if(Global.selectedAvatar)
         {
            this.setHighlighted(true);
            this.updateToolTipText();
         }
         this.checkForAOEAffects();
      }
      
      protected function checkForAOEAffects() : void
      {
         if(this.hasAreasOfEffect())
         {
            this.showAreaOfEffect(true);
            if(Boolean(m_item) && Boolean(m_item.aoeConfig) && m_item.aoeConfig.showTargetBonusOnSourceMouseMove)
            {
               this.showTargets(true);
            }
            else if(this.isAoeTarget())
            {
               this.showAoeBonus(null,true);
            }
         }
         else if(this.isAoeTarget())
         {
            this.showAoeBonus(null,true);
         }
      }
      
      override public function onClick() : void
      {
         var farmItem:FarmItem = null;
         if(Global.worldManager.isVisitingNeighbor() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_NEIGHBOR_VISIT_PURCHASE) > 0)
         {
            farmItem = getItem();
            if(Boolean(farmItem) && farmItem.buyableFromNeighbor)
            {
               UI.displayMarketPreviewWindow(farmItem);
            }
         }
         else
         {
            super.onClick();
         }
      }
      
      override public function onMouseOut() : void
      {
         if(this.m_wasPaused && Global.animationState != Global.ANIMATION_STATE_STOP)
         {
            this.m_wasPaused = false;
            this.resetAnimation();
            this.pause();
         }
         if(Global.selectedAvatar)
         {
            this.setHighlighted(false);
            setToolTip(null);
         }
         if(this.hasAreasOfEffect())
         {
            this.showAreaOfEffect(false);
            if(Boolean(m_item) && Boolean(m_item.aoeConfig) && m_item.aoeConfig.showTargetBonusOnSourceMouseMove)
            {
               this.showTargets(false,true,false,true);
            }
            else if(this.isAoeTarget())
            {
               this.hideAoeBonus();
            }
         }
         else if(this.isAoeTarget())
         {
            this.hideAoeBonus();
         }
      }
      
      protected function updateToolTipText() : void
      {
         if(isHighlighted() && Boolean(m_item))
         {
            if("" != this.m_toolTipOverride)
            {
               setToolTip(this.m_toolTipOverride);
            }
            else
            {
               setToolTip(this.defaultTooltip);
            }
            updateToolTipPosition();
         }
      }
      
      protected function get defaultTooltip() : String
      {
         var tooltip:String = ZLocUtils.tk_pk_asTitle(getItemFriendlyName());
         var notes:String = m_item.tooltipNotes;
         if(Boolean(notes) && notes != "")
         {
            tooltip += "\n" + notes;
         }
         return tooltip;
      }
      
      protected function onSfxChanged(e:FarmGameWorldEvent) : void
      {
         if(this.m_content is MovieClip)
         {
            Utilities.toggleSound(this.m_content as MovieClip,!Global.player.isSfxDisabled());
         }
      }
      
      protected function onPlayComplete() : void
      {
         Global.world.onMapResourcePlayComplete(this);
      }
      
      override public function attach() : void
      {
         var position:Vector3 = null;
         var aoeManager:AOEManager = null;
         var areas:Vector.<Rectangle> = null;
         var rect:Rectangle = null;
         var aoeWorldObject:AOEWorldObject = null;
         var aoeWorldObj:AOEWorldObject = null;
         super.attach();
         Global.ui.addEventListener(FarmGameWorldEvent.SFX_CHANGED,this.onSfxChanged);
         this.idle();
         if(m_item != null && m_item.hasAreasOfEffect)
         {
            position = this.getDepthPositionNoClone();
            aoeManager = AOEManager.getInstance();
            if(this.m_aoeWorldObjects == null)
            {
               this.m_aoeWorldObjects = new Vector.<AOEWorldObject>();
               areas = m_item.aoeConfig.areas;
               for each(rect in areas)
               {
                  aoeWorldObject = new AOEWorldObject(rect,aoeManager.getNewId(),this.getId());
                  aoeWorldObject.setOuter(getOuter() as World);
                  aoeWorldObject.setPosition(position.x,position.y,position.z);
                  aoeWorldObject.attach();
                  this.m_aoeWorldObjects.push(aoeWorldObject);
                  aoeManager.addAreaObject(aoeWorldObject);
               }
            }
            else
            {
               for each(aoeWorldObj in this.m_aoeWorldObjects)
               {
                  aoeWorldObject.setPosition(position.x,position.y,position.z);
                  aoeWorldObject.attach();
                  aoeManager.addAreaObject(aoeWorldObject);
               }
            }
         }
      }
      
      override protected function calculateDepthIndex() : void
      {
         var oldPosX:Number = NaN;
         var oldPosY:Number = NaN;
         var offset:Vector3 = null;
         if(m_item)
         {
            offset = m_item.getDepthOffset();
         }
         if(offset != null)
         {
            oldPosX = m_position.x;
            oldPosY = m_position.y;
            m_position.x += offset.x;
            m_position.y += offset.y;
            super.calculateDepthIndex();
            m_position.x = oldPosX;
            m_position.y = oldPosY;
         }
         else
         {
            super.calculateDepthIndex();
         }
      }
      
      override public function detach() : void
      {
         var i:int = 0;
         super.detach();
         Global.ui.removeEventListener(FarmGameWorldEvent.SFX_CHANGED,this.onSfxChanged);
         if(this.shouldTrackAnimation)
         {
            this.onPlayComplete();
         }
         var aoeManager:AOEManager = AOEManager.getInstance();
         if(this.m_aoeWorldObjects)
         {
            for(i = 0; i < this.m_aoeWorldObjects.length; i++)
            {
               aoeManager.removeAreaObject(this.m_aoeWorldObjects[i]);
               this.m_aoeWorldObjects[i].detach();
            }
         }
      }
      
      override public function setPosition(newX:Number, newY:Number, newZ:Number = 0) : void
      {
         var i:int = 0;
         super.setPosition(newX,newY,newZ);
         if(this.m_aoeWorldObjects)
         {
            for(i = 0; i < this.m_aoeWorldObjects.length; i++)
            {
               this.m_aoeWorldObjects[i].setPosition(newX,newY,newZ);
            }
         }
      }
      
      override public function setId(id:Number) : void
      {
         var i:int = 0;
         var oldId:Number = this.getId();
         super.setId(id);
         if(this.m_aoeWorldObjects)
         {
            for(i = 0; i < this.m_aoeWorldObjects.length; i++)
            {
               this.m_aoeWorldObjects[i].setParentId(id);
            }
         }
         Global.world.extraItemFlagsRelocateId(oldId,this.getId());
      }
      
      override public function toggleAnimation() : void
      {
         var shouldPlay:Boolean = false;
         var child:DisplayObject = null;
         var childIdx:int = 0;
         var numChildren:int = 0;
         var spr:Sprite = m_displayObject as Sprite;
         if(spr != null)
         {
            shouldPlay = this.isAnimating;
            childIdx = 0;
            numChildren = spr.numChildren;
            while(childIdx < numChildren)
            {
               child = spr.getChildAt(childIdx);
               this.toggleAnimationRecursively(child,shouldPlay);
               childIdx++;
            }
            this.toggleAnimationRecursively(this.m_image,shouldPlay);
         }
      }
      
      protected function toggleAnimationRecursively(disp:DisplayObject, shouldPlay:Boolean, depth:int = 0) : void
      {
         var spr:Sprite = null;
         var child:DisplayObject = null;
         var childIdx:uint = 0;
         var numChildren:uint = 0;
         var mc:MovieClip = disp as MovieClip;
         if(mc)
         {
            if(shouldPlay)
            {
               mc.play();
            }
            else
            {
               mc.stop();
            }
         }
         if(++depth <= MC_ANIMATION_MAX_DEPTH)
         {
            spr = disp as Sprite;
            if(spr != null)
            {
               childIdx = 0;
               numChildren = uint(spr.numChildren);
               while(childIdx < numChildren)
               {
                  child = spr.getChildAt(childIdx);
                  this.toggleAnimationRecursively(child,shouldPlay,depth);
                  childIdx++;
               }
            }
         }
      }
      
      public function isAltGraphicAvailable(altGraphic:String) : Boolean
      {
         var classEnabled:Boolean = false;
         var graphic:XML = Global.farmGameSettingsManager.getAltGraphicByName(altGraphic);
         var className:String = this.getClassName();
         if(Boolean(graphic) && Boolean(graphic.allowedClasses.classAllow.(@name == className).length()))
         {
            classEnabled = true;
         }
         return this.m_altGraphic == "" && (classEnabled || getItem().hasAltGraphic(altGraphic));
      }
      
      public function useAltGraphic(name:String) : void
      {
         this.m_altGraphic = name;
         m_displayObjectDirty = true;
      }
      
      override public function onSell() : void
      {
         var prereq:String = null;
         var code:String = null;
         var gateCode:String = null;
         var playerGateItem:Object = null;
         var limitedItems:Object = null;
         if(this.m_altGraphic != "")
         {
            addTransaction(new TRemoveAltGraphic(this,this.m_altGraphic));
            if(AltGraphicUtility.creditOnRemove(this.m_altGraphic))
            {
               Global.player.incAltGraphicCredits(this.m_altGraphic);
            }
            Global.hud.setLightIcon();
         }
         var item:FarmItem = this.getItem();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            gateCode = item.getStringFromDataSource("gateCode");
            code = item.getStringFromDataSource("code");
            prereq = item.getStringFromDataSource("purchasePrereqs");
         }
         else
         {
            gateCode = item.xml.@gateCode;
            code = item.xml.@code;
            if(m_item.xml.purchasePrereqs != null)
            {
               prereq = String(item.xml.purchasePrereqs);
            }
         }
         if(gateCode != "")
         {
            playerGateItem = Global.player.incrementalGateArray[gateCode];
            if(Boolean(playerGateItem) && Boolean(playerGateItem.acquired))
            {
               if(playerGateItem.acquired[code])
               {
                  if(playerGateItem.acquired[code] == 1)
                  {
                     delete playerGateItem.acquired[code];
                  }
                  else
                  {
                     --playerGateItem.acquired[code];
                  }
               }
            }
         }
         if(item.limit > 0)
         {
            Global.player.removeLimitedItem(item.name);
         }
         if(prereq)
         {
            if(prereq.indexOf(PrerequisiteConstants.PREREQUISITE_GLOBAL_LIMIT) >= 0)
            {
               limitedItems = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.FEATURE_LIMITED_ITEMS,FeatureOptionsManager.FEATURE_LIMITED_ITEMS);
               if(limitedItems == null)
               {
                  limitedItems = {};
               }
               if(limitedItems.hasOwnProperty(m_item.name))
               {
                  --limitedItems[m_item.name];
                  if(limitedItems[item.name] <= 0)
                  {
                     delete limitedItems[m_item.name];
                  }
               }
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.FEATURE_LIMITED_ITEMS,FeatureOptionsManager.FEATURE_LIMITED_ITEMS,limitedItems);
            }
         }
      }
      
      public function postProcessImageName(name:String) : String
      {
         var tmpAltGraphic:String = null;
         var imageName:String = name;
         if(this.m_altGraphic)
         {
            tmpAltGraphic = this.m_altGraphic == "snow_altgraphic" ? "snow" : this.m_altGraphic;
            imageName = imageName + "_" + tmpAltGraphic;
         }
         var terrainPrefix:String = this.findTerrainPrefix();
         if(terrainPrefix != "")
         {
            imageName = terrainPrefix + imageName;
         }
         return imageName;
      }
      
      protected function findTerrainPrefix() : String
      {
         var terrainPrefix:String = "";
         if(m_item)
         {
            if(this.m_currentTerrainName != null)
            {
               terrainPrefix = m_item.getTerrainPrefix(this.m_currentTerrainName);
            }
         }
         return terrainPrefix;
      }
      
      protected function findTerrainName() : String
      {
         var result:String = null;
         if(this.getOuter() != null)
         {
            result = Global.farmGameSettingsManager.selectPrimaryTerrainNameFromGivenCodes(TerrainUtil.getTerrainCodesForItemInstance(this));
         }
         return result;
      }
      
      protected function setNumImageStates() : void
      {
         var idx:int = 0;
         var imageName:String = null;
         var builtMatch:Array = null;
         var builtState:String = null;
         var imageArr:Array = null;
         var item:XML = null;
         this.m_numImageStates = 0;
         var builtStates:Object = new Object();
         var builtPattern:RegExp = /built_\d+/;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            imageArr = this.getItem().getArrayFromDataSource("image");
            for(idx = 0; idx < imageArr.length; idx++)
            {
               imageName = (imageArr[idx] as BaseDataSource).getString("name");
               builtMatch = imageName.match(builtPattern);
               if(builtMatch)
               {
                  builtStates[builtMatch[0]] = 1;
               }
            }
         }
         else
         {
            item = this.getItem().xml;
            for(idx = 0; idx < item.image.length(); idx++)
            {
               imageName = item.image[idx]["@name"].toString();
               builtMatch = imageName.match(builtPattern);
               if(builtMatch)
               {
                  builtStates[builtMatch[0]] = 1;
               }
            }
         }
         for(builtState in builtStates)
         {
            ++this.m_numImageStates;
         }
      }
      
      public function onStorage() : void
      {
         if(this.m_altGraphic != "")
         {
            addTransaction(new TRemoveAltGraphic(this,this.m_altGraphic));
            this.displayAltGraphicStorageMessage(this.m_altGraphic);
            if(AltGraphicUtility.creditOnRemove(this.m_altGraphic))
            {
               Global.player.incAltGraphicCredits(this.m_altGraphic);
            }
            Global.hud.setLightIcon();
            this.m_altGraphic = "";
         }
      }
      
      public function packStoreItemMetaData() : Object
      {
         return null;
      }
      
      private function displayAltGraphicStorageMessage(altGraphic:String) : void
      {
         var dialogMessage:String = null;
         var delay:int = 0;
         if(!Global.player.getSeenFlag(SEEN_FLAG_EXPLAIN_ALT_EFFECT_CREDIT))
         {
            Global.player.setSeenFlag(SEEN_FLAG_EXPLAIN_ALT_EFFECT_CREDIT);
            dialogMessage = ZLocUtils.t("Dialogs","AltGraphicCredit_" + altGraphic);
            if(dialogMessage != "")
            {
               UI.showMessage(dialogMessage,UI.BUTTON_LAYOUT_OK,null,null,false);
            }
         }
         var toasterMessage:String = ZLocUtils.t("Dialogs","AltGraphicToaster_" + altGraphic);
         if(toasterMessage != "")
         {
            delay = Global.farmGameSettingsManager.getInt("AltGraphicOnStoreToasterDelaySeconds",5);
            ToasterManager.getInstance().add(new GenericCustomAdToaster(toasterMessage,"",delay));
         }
      }
      
      public function addEffect(url:String, forceNewLoader:Boolean = false, useSingleton:Boolean = true) : void
      {
         if(m_effectLoader == null || forceNewLoader)
         {
            m_effectLoader = ImageLoader.getInstance(Global.getAssetURL(url),false,useSingleton);
            m_effectLoader.getContent(this.onEffectLoad);
         }
      }
      
      public function stopEffect() : void
      {
         var spr:Sprite = null;
         if(this.m_effectOverlay != null)
         {
            spr = m_displayObject as Sprite;
            if(spr != null && spr.contains(this.m_effectOverlay))
            {
               spr.removeChild(this.m_effectOverlay);
            }
            (this.m_effectOverlay as MovieClip).stop();
            this.m_effectOverlay = null;
         }
      }
      
      private function onEffectLoad(content:DisplayObject, info:Object = null) : void
      {
         var spr:Sprite = null;
         this.stopEffect();
         if(content != null)
         {
            this.m_effectOverlay = content;
            (this.m_effectOverlay as MovieClip).play();
            spr = m_displayObject as Sprite;
            if(spr != null && spr.numChildren > 0)
            {
               spr.addChild(this.m_effectOverlay);
               this.m_effectOverlay.x = 0;
               this.m_effectOverlay.y = 0;
               this.m_effectOverlay.scaleX = 1;
               this.m_effectOverlay.scaleY = 1;
            }
         }
         m_effectLoader = null;
      }
      
      public function switchRenderSystem() : void
      {
         if(this.m_content is MovieClip || this.m_content is AnimationPlayer)
         {
            this.m_image = null;
            this.drawDisplayObject();
         }
      }
      
      public function canUseConsumable(consumable:String) : Boolean
      {
         return false;
      }
      
      public function onDelete() : void
      {
      }
      
      public function prepForGameMode(mode:GameMode, activating:Boolean) : void
      {
      }
      
      public function getInventoryCode() : String
      {
         return Global.farmGameSettingsManager.getFarmItemCodeByName(this.getItemName());
      }
      
      public function get currentFrame() : int
      {
         var result:int = 0;
         if(this.m_content is AnimationPlayer)
         {
            result = (this.m_content as AnimationPlayer).frameIndex;
         }
         else if(this.m_content is MovieClip)
         {
            if(this.m_perfectLoopFinalFrame > 0 && this.m_perfectLoopFrameCount >= 0)
            {
               result = this.m_perfectLoopFrameCount;
            }
            else
            {
               result = (this.m_content as MovieClip).currentFrame;
            }
         }
         return result;
      }
      
      public function get hasAnimation() : Boolean
      {
         return !(this.m_image is Bitmap);
      }
      
      public function get isAnimating() : Boolean
      {
         return this.m_animationState == PLAY_STATE;
      }
      
      public function get obeysAnimationTracking() : Boolean
      {
         return Boolean(this.m_itemImage) && this.m_itemImage.trackAnimation;
      }
      
      protected function get shouldPlayWhileIdle() : Boolean
      {
         return false;
      }
      
      protected function get shouldTrackAnimation() : Boolean
      {
         return this.hasAnimation && this.isAnimating && this.obeysAnimationTracking && !this.m_wasPaused && !this.shouldPlayWhileIdle;
      }
      
      protected function resetAnimation() : void
      {
         if(this.m_content is AnimationPlayer)
         {
            this.m_lastUpdateFrame = -1;
            (this.m_content as AnimationPlayer).restartAnimation();
         }
         else if(this.m_content is MovieClip)
         {
            this.m_perfectLoopFinalFrame = -1;
            this.m_perfectLoopFrameCount = 0;
            (this.m_content as MovieClip).gotoAndStop(1);
            this.resetAllChildClips(this.m_content as MovieClip);
         }
      }
      
      public function typeOfAnimation() : int
      {
         var result:int = 0;
         if(Boolean(this.m_itemImage) && Boolean(this.m_itemImage.image is AnimationPlayer) || Boolean(this.m_content) && Boolean(this.m_content is AnimationPlayer))
         {
            if((this.m_content as AnimationPlayer).isUsingRasterMetadata)
            {
               result = 3;
            }
            else
            {
               result = 4;
            }
         }
         else if(Boolean(this.m_itemImage) && Boolean(this.m_itemImage.image is MovieClip) || Boolean(this.m_content) && Boolean(this.m_content is MovieClip))
         {
            result = 2;
         }
         else if(Boolean(this.m_itemImage) && Boolean(this.m_itemImage.image is Bitmap) || Boolean(this.m_content) && Boolean(this.m_content is Bitmap))
         {
            result = 1;
         }
         return result;
      }
      
      protected function resetAllChildClips(clip:MovieClip) : void
      {
         var child:MovieClip = null;
         var i:int = 0;
         var numChildren:int = clip.numChildren;
         while(i < numChildren)
         {
            child = clip.getChildAt(i) as MovieClip;
            if(child)
            {
               child.gotoAndPlay(1);
               this.resetAllChildClips(child);
            }
            i++;
         }
      }
      
      public function idle() : void
      {
         switch(Global.animationState)
         {
            case Global.ANIMATION_STATE_PLAY:
               if(this.shouldPlayWhileIdle || !this.obeysAnimationTracking)
               {
                  this.play();
               }
               else
               {
                  this.pause();
               }
               break;
            case Global.ANIMATION_STATE_PAUSE:
               this.pause();
               break;
            case Global.ANIMATION_STATE_STOP:
               this.stop();
         }
      }
      
      public function canPlay(ignoreCanPlay:Boolean = false) : Boolean
      {
         return isVisible() && this.hasAnimation && this.m_animationState != PLAY_STATE && this.m_allowPlay && (ignoreCanPlay || DefconManager.canAnimateMapResource(this)) && !PerformanceExperimentManager.isInExtremePerformanceLimiterExperiment;
      }
      
      public function play(ignoreCanPlay:Boolean = false) : Boolean
      {
         var framesInPerfectLoop:int = 0;
         var result:Boolean = false;
         if(this.canPlay(ignoreCanPlay))
         {
            this.m_animationState = PLAY_STATE;
            (m_displayObject as Sprite).cacheAsBitmap = false;
            this.restartAnimation();
            this.toggleAnimation();
            if(this.m_content is MovieClip && this.shouldTrackAnimation)
            {
               framesInPerfectLoop = FarmGameUtil.getFramesInPerfectLoop(this.m_content as MovieClip);
               if(framesInPerfectLoop != (this.m_content as MovieClip).totalFrames)
               {
                  this.m_perfectLoopFinalFrame = Math.min(framesInPerfectLoop,MAX_ANIMATION_TIME * Global.stage.frameRate);
               }
               else
               {
                  this.m_perfectLoopFinalFrame = framesInPerfectLoop;
               }
            }
            result = true;
         }
         return result;
      }
      
      public function pause() : void
      {
         if(this.m_animationState == PLAY_STATE && this.m_allowPlay)
         {
            this.m_animationState = PAUSE_STATE;
            this.toggleAnimation();
            (m_displayObject as Sprite).cacheAsBitmap = true;
         }
         else if(this.m_animationState == STOP_STATE)
         {
            this.m_animationState = PAUSE_STATE;
         }
      }
      
      public function stop() : void
      {
         if(this.m_animationState != STOP_STATE)
         {
            this.resetAnimation();
            this.m_animationState = STOP_STATE;
            this.toggleAnimation();
            if(Boolean(this.m_itemImage) && Boolean(this.m_content is MovieClip) && this.m_itemImage.lowResImage is BitmapData)
            {
               this.replaceContentWithBitmap();
            }
         }
      }
      
      override public function updateCulling() : void
      {
         var previousCulledValue:Boolean = m_culled;
         super.updateCulling();
         if(m_culled != previousCulledValue)
         {
            if(m_culled)
            {
               if(this.shouldTrackAnimation)
               {
                  this.onPlayComplete();
               }
               this.stop();
            }
            else
            {
               this.idle();
            }
         }
      }
      
      public function playEffect() : void
      {
         var spr:Sprite = m_displayObject as Sprite;
         if(Boolean(this.m_effectOverlay && this.m_effectOverlay is MovieClip) && Boolean(spr != null) && spr.contains(this.m_effectOverlay))
         {
            (this.m_effectOverlay as MovieClip).play();
         }
      }
      
      public function pauseEffect() : void
      {
         if(Boolean(this.m_effectOverlay) && this.m_effectOverlay is MovieClip)
         {
            (this.m_effectOverlay as MovieClip).stop();
         }
      }
      
      public function getImage() : DisplayObject
      {
         return this.m_image;
      }
      
      public function getContent() : DisplayObject
      {
         return this.m_content;
      }
      
      public function showAreaOfEffect(show:Boolean) : void
      {
         if(show)
         {
            Global.world.drawAreaOfEffect(this);
         }
         else
         {
            Global.world.clearAreaOfEffect(this);
         }
      }
      
      public function showStencilEffect(itemImage:ItemImage = null) : void
      {
         Global.world.drawStencilEffect(this,itemImage);
      }
      
      public function hideStencilEffect() : void
      {
         Global.world.clearStencilEffect(this);
      }
      
      public function hideAoeToolTips() : void
      {
         var removeToolTip:AOETooltip = null;
         for each(removeToolTip in this.m_aoeToolTips)
         {
            Global.world.removeAOEToolTip(removeToolTip);
         }
         this.m_aoeToolTips = [];
      }
      
      public function showAoeToolTip(mode:int, rect:Rectangle, bonusObject:AOEBonusData = null, name:String = "") : AOETooltip
      {
         var midPoint:Point = RectangleUtil.midpoint(rect);
         var screenPos:Vector2 = IsoMath.tilePosToPixelPos(midPoint.x,midPoint.y);
         var toolTip:AOETooltip = new AOETooltip(mode,name,bonusObject);
         toolTip.scaleX = toolTip.scaleY = 0.75;
         toolTip.x = screenPos.x - toolTip.width / 2;
         toolTip.y = screenPos.y - toolTip.height;
         this.m_aoeToolTips.push(toolTip);
         Global.world.addAOEToolTip(toolTip);
         return toolTip;
      }
      
      public function showTargets(show:Boolean, showMultipliers:Boolean = true, stateChange:Boolean = false, removeHighlight:Boolean = false) : void
      {
         var target:MapResource = null;
         var targets:Array = null;
         var highlightColor:uint = 0;
         if(show)
         {
            targets = this.getCurrentAoeTargets();
            for each(target in targets)
            {
               target.showAoeBonus(null,showMultipliers);
            }
         }
         else if(this.m_aoeTargets)
         {
            for each(target in this.m_aoeTargets)
            {
               highlightColor = removeHighlight ? uint.MAX_VALUE : MapResource.AOE_HIGHLIGHT_COLOR;
               target.hideAoeBonus(stateChange,highlightColor);
            }
         }
      }
      
      public function getCurrentAoeTargets(refresh:Boolean = false) : Array
      {
         if(!this.m_aoeTargets || refresh)
         {
            this.m_aoeTargets = AOEManager.getInstance().getResourcesAffectedBy(this);
         }
         return this.m_aoeTargets;
      }
      
      public function isAoeTarget() : Boolean
      {
         return AOEManager.getInstance().isAOETarget(this);
      }
      
      public function isAoeSource() : Boolean
      {
         var result:Boolean = false;
         if(m_item)
         {
            result = m_item.hasAreasOfEffect;
         }
         return result;
      }
      
      public function hasAreasOfEffect() : Boolean
      {
         return this.m_aoeWorldObjects != null && this.m_aoeWorldObjects.length > 0;
      }
      
      public function getAOEWorldObjects() : Vector.<AOEWorldObject>
      {
         return this.m_aoeWorldObjects;
      }
      
      public function showAoeBonus(bonusObject:AOEBonusData, showMultipliers:Boolean = true, showHighlight:Boolean = true) : void
      {
         var aoeManager:AOEManager = null;
         var mode:int = 0;
         if(!this.m_aoeToolTip)
         {
            aoeManager = AOEManager.getInstance();
            if(!bonusObject)
            {
               bonusObject = aoeManager.computeBonusesForResource(this,false);
            }
            if(bonusObject.numSources > 0)
            {
               mode = AOETooltip.MODE_SHOW_MULTIPLIERS;
               if(!showMultipliers)
               {
                  mode = bonusObject.numSources > 1 ? AOETooltip.MODE_SHOW_STACKED_BONUS_AVAILABLE : AOETooltip.MODE_SHOW_BONUS_AVAILABLE;
               }
               this.m_aoeBonusShowing = true;
               this.m_aoeToolTip = this.showAoeToolTip(mode,this.getTileRect(),bonusObject,bonusObject.bonusToolTipType);
               this.setHighlighted(showHighlight,AOE_BONUS_COLOR);
               this.applyAoeAffects(bonusObject);
            }
         }
      }
      
      public function hideAoeBonus(stateChange:Boolean = false, newHighlight:uint = 4294967295) : void
      {
         if(this.m_aoeBonusShowing)
         {
            this.setHighlighted(false);
         }
         if(newHighlight != uint.MAX_VALUE)
         {
            if(stateChange)
            {
               this.unapplyAoeAffects();
            }
            this.setHighlighted(true,newHighlight);
         }
         else
         {
            this.m_aoeBonusShowing = false;
         }
         if(this.m_aoeToolTip)
         {
            Global.world.removeAOEToolTip(this.m_aoeToolTip);
            this.m_aoeToolTip = null;
         }
      }
      
      public function applyAoeAffects(bonusObject:AOEBonusData, removeHighlighting:Boolean = false) : void
      {
         var changeState:String = null;
         if(Boolean(bonusObject) && Boolean(bonusObject.possibleStates != null) && bonusObject.possibleStates.length > 0)
         {
            changeState = bonusObject.possibleStates[0];
            this.m_aoeImageState = changeState;
            this.m_image = null;
            this.conditionallyRedraw(true);
            if(removeHighlighting)
            {
               this.setHighlighted(false);
            }
         }
      }
      
      public function unapplyAoeAffects() : void
      {
         this.m_aoeImageState = null;
         this.m_image = null;
         this.conditionallyRedraw(true);
      }
      
      public function getCachedImage(name:String, disallowAltAnimation:Boolean = false) : ItemImage
      {
         return m_item.displayLoader.getImageByName(m_item.mapImageName(name),disallowAltAnimation,this.m_aoeImageState);
      }
      
      override protected function canSetToolTip(toolTip:String) : Boolean
      {
         return !this.m_aoeBonusShowing && !(Global.world.getTopGameMode() is GMMultiResourceAction) && Boolean(super.canSetToolTip(toolTip));
      }
      
      public function refreshAOEPlaceTime() : void
      {
         this.m_aoePlaceTime = Math.floor(GlobalEngine.getTimer() / FarmGameUtil.NUM_MSECS_IN_SECOND);
      }
      
      public function get aoePlaceTime() : Number
      {
         return this.m_aoePlaceTime;
      }
      
      public function getFarmItemClassName() : String
      {
         var result:String = null;
         var item:FarmItem = this.getItem();
         if(Boolean(item) && Boolean(item.className) && item.className != "")
         {
            result = item.className;
         }
         return result;
      }
      
      public function setAlpha(_alpha:Number) : void
      {
         m_observer.notifyObservers(OBSERVABLE_EVENT_ALPHA,{
            "object":this,
            "alpha":_alpha
         });
         this.alpha = _alpha;
      }
      
      protected function get state() : String
      {
         return this.m_state;
      }
      
      protected function set state(_state:String) : void
      {
         m_observer.notifyObservers(OBSERVABLE_EVENT_STATE,{
            "object":this,
            "state":_state
         });
         this.m_state = _state;
      }
      
      public function hasStorageDialog() : Boolean
      {
         return this.m_hasStorageDialog;
      }
      
      public function getStorageDialogText() : String
      {
         return this.m_storageDialogKey;
      }
      
      override public function getObservableEvents() : Vector.<String>
      {
         var events:Vector.<String> = super.getObservableEvents();
         events.push(OBSERVABLE_EVENT_STATE,OBSERVABLE_EVENT_ALPHA);
         return events;
      }
      
      override public function getId() : Number
      {
         return super.getId();
      }
   }
}

