package Classes
{
   import AvatarMode.AMFertilize;
   import AvatarMode.AMHarvest;
   import AvatarMode.AMPlant;
   import AvatarMode.AMPlow;
   import AvatarMode.AMUnwither;
   import Classes.AreasOfEffect.AOEBonusData;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.CollectionsConstants;
   import Classes.Constants.DooberConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.ZapFirstPlacementDialogTask;
   import Classes.NeighborActions.FertNeighborAction;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.NeighborActions.PlowNeighborAction;
   import Classes.NeighborActions.UnwitherNeighborAction;
   import Classes.Terrain.TerrainUtil;
   import Classes.Trading.TradingPostManager;
   import Classes.ZItem.ExpansionData;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.ZItem.SeedItem;
   import Classes.buffs.BBushel;
   import Classes.buffs.BCoinPowerHour;
   import Classes.buffs.BHarvestHelper;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Display.UnwitherDialog;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Helpers.Vector3;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Events.MarketEvent;
   import Events.PlotEvent;
   import GameMode.GMAirplaneFly;
   import GameMode.GMClear;
   import GameMode.GMDecoMove;
   import GameMode.GMPlotRemover;
   import Managers.AOEManager;
   import Managers.AvatarRetentionExperimentUtil;
   import Managers.BreedingManager;
   import Managers.Clubs.DataObjects.FarmClubDataObject;
   import Managers.Clubs.FarmClubDataManager;
   import Managers.Clubs.FarmClubUtility;
   import Managers.CollectionsManager;
   import Managers.DailyStatsManager;
   import Managers.DoobersManager;
   import Managers.ExperimentManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.InstagrowHelper;
   import Managers.OrganicFertilizerHelper;
   import Managers.PowerHourManager;
   import Managers.RetentionMasterManager;
   import Managers.SuperPlotManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TClear;
   import Transactions.TClearWithered;
   import Transactions.TCompleteFertilize;
   import Transactions.THarvest;
   import Transactions.TPlant;
   import Transactions.TPlow;
   import Transactions.TRedeemFertilize;
   import Transactions.TRedeemUnwither;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.Market.MarketWindow;
   import com.urbansquall.ginger.AnimationPlayer;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class Plot extends HarvestableResource
   {
      
      private static var m_marketWindow2:MarketWindow;
      
      private static const APPLY_GROW:String = "applyInstantGrow";
      
      private static const APPLY_ORGANIC_FERTILIZER:String = "applyOrganicFertilizer";
      
      private static const OPEN_BUSHEL_REPORT:String = "openBushelReport";
      
      public static const FERTILIZE_SUCCESS_URL:String = "assets/overlays/effect_fertilizer_fertilizing.swf";
      
      public static const FERTILIZE_WAITING_URL:String = "assets/overlays/effect_fertilizer_loop.swf";
      
      public static const ORGANIC_FERTILIZE_SUCCESS_URL:String = "assets/overlays/effect_organicFertilizer_fertilizing.swf";
      
      public static const ORGANIC_FERTILIZE_WAITING_URL:String = "assets/overlays/effect_organicFertilizer_loop.swf";
      
      public static const FERTILIZE_FUELSUCCESS_URL:String = "assets/overlays/effect_fuel_burst_neighbor.swf";
      
      private static var m_fertOverlayLoader:ImageLoader = ImageLoader.getInstance(Global.getAssetURL(FERTILIZE_WAITING_URL),true);
      
      private static var m_organicFertOverlayLoader:ImageLoader = ImageLoader.getInstance(Global.getAssetURL(ORGANIC_FERTILIZE_WAITING_URL),true);
      
      public static const SUPER_PLOT_OVERLAY_URL:String = "assets/overlays/effect_superplot_100.png";
      
      public static const SUPER_PLOT_OVERLAY_OFFSET_X:Number = 32;
      
      public static const SUPER_PLOT_OVERLAY_OFFSET_Y:Number = 121;
      
      public static const SUPER_PLOT_OVERLAY_SCALE:Number = 1;
      
      private static var m_superPlotOverlayLoader:ImageLoader = ImageLoader.getInstance(Global.getAssetURL(SUPER_PLOT_OVERLAY_URL),true);
      
      public static const SIZE_X:int = 4;
      
      public static const SIZE_Y:int = 4;
      
      public static const ORGANIC_MULT:int = 2;
      
      public static const STATE_PLOWED:String = "plowed";
      
      public static const STATE_PLANTED:String = "planted";
      
      public static const STATE_GROWN:String = "grown";
      
      public static const STATE_FALLOW:String = "fallow";
      
      public static const STATE_WITHERED:String = "withered";
      
      protected static var m_plowedPlotFertilizerExpireTime:Number = 0;
      
      protected static const HARVEST_ICON_TWEEN_DURATION:Number = 7;
      
      protected static const HARVEST_ICON_TWEEN_DISPLACEMENT:int = 96;
      
      private static var m_plotMaskDictionary:Dictionary = new Dictionary();
      
      private static var m_toolTipShowing:Boolean = false;
      
      private var m_itemImageName:String;
      
      private var m_isNewPlot:Boolean = true;
      
      private var m_isJumbo:Boolean;
      
      private var m_fertilized:Boolean;
      
      protected var m_queuedFertilize:Boolean;
      
      private var m_firstTimePeriodicUpdate:Boolean = true;
      
      private var m_dirtyOrganicFertilizer:Boolean = true;
      
      private var m_cachedIsOrganicFertilized:Boolean = false;
      
      private var m_organicFertOverlay:DisplayObject = null;
      
      private var m_organicFertOverlayRequested:Boolean = false;
      
      private var m_fertOverlay:DisplayObject = null;
      
      private var m_fertOverlayRequested:Boolean = false;
      
      private var m_superPlotOverlay:DisplayObject = null;
      
      private var m_superPlotOverlayRequested:Boolean = false;
      
      private var m_showArrow:Boolean = false;
      
      private var m_arrowOverlay:DisplayObject = null;
      
      private var m_arrowOverlayRequested:Boolean = false;
      
      private var m_lastPlantYield:int = 0;
      
      private var m_lastPlowYield:int = 0;
      
      private var m_clubLogoIcon:Bitmap = null;
      
      private var m_clubLogoId:int = 1;
      
      protected var m_bonusMultipliers:Object;
      
      protected var m_bonusCumulativeTypes:Object;
      
      private var mr:MasteryRequirement = null;
      
      private var br:BuildingRequirement = null;
      
      private var spr:SeedPackageRequirement = null;
      
      private var hsr:HybridSeedRequirement = null;
      
      public function Plot(itemName:String = null)
      {
         super(null);
         m_objectType = WorldObjectTypes.PLOT;
         m_size = new Vector3(SIZE_X,SIZE_Y,1);
         this.setDisplayStatesForPlots(FarmGameSettingsManager.TERRAIN_LAND);
         setDisplayForState(STATE_PLANTED,null);
         setDisplayForState(STATE_GROWN,null);
         this.setState(STATE_FALLOW);
      }
      
      public static function playerCanFertilize() : Boolean
      {
         return Global.player.level >= Global.farmGameSettingsManager.getNumber("fertilizeMinLevel");
      }
      
      public static function getWorldPlowPlotCostData() : Object
      {
         var result:Object = {};
         result.cost = Global.farmGameSettingsManager.getInt("plowCost",15);
         result.currencyUnit = Currency.GOLD;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(Global.worldManager.currentWorldType);
         if(expansionData)
         {
            result.cost = expansionData.farmingAttributes.plowCost;
            result.currencyUnit = expansionData.farmingAttributes.plowCurrency;
         }
         return result;
      }
      
      override public function getResourceItemName() : String
      {
         var result:String = "";
         var strState:String = state;
         if(strState != STATE_FALLOW && strState != STATE_PLOWED)
         {
            result = super.getResourceItemName();
         }
         return result;
      }
      
      public function isPlotPlantedAndNotWithered() : Boolean
      {
         var strState:String = state;
         return strState != STATE_WITHERED && strState != STATE_FALLOW && strState != STATE_PLOWED;
      }
      
      protected function setDisplayStatesForPlots(terrainName:String) : void
      {
         setDisplayForState(STATE_PLOWED,new ItemImage(this.getPrefixedItemImageForPlot(terrainName,"plot_plowed")));
         setDisplayForState(STATE_FALLOW,new ItemImage(this.getPrefixedItemImageForPlot(terrainName,"plot_withered")));
      }
      
      protected function getTerrainPrefix(terrainName:String) : String
      {
         var prefix:String = "";
         if(terrainName == FarmGameSettingsManager.TERRAIN_WATER || terrainName == FarmGameSettingsManager.TERRAIN_TERRACE || terrainName == FarmGameSettingsManager.TERRAIN_ZEN || terrainName == FarmGameSettingsManager.TERRAIN_SNOW || terrainName == FarmGameSettingsManager.TERRAIN_TURTLE || terrainName == FarmGameSettingsManager.TERRAIN_DREAM || terrainName == FarmGameSettingsManager.TERRAIN_BORABORA)
         {
            prefix = terrainName + "_";
         }
         return prefix;
      }
      
      protected function getPrefixedItemImageForPlot(terrainName:String, baseImage:String) : Object
      {
         var embeddedArtKey:String = this.getTerrainPrefix(terrainName) + baseImage;
         var imageForPlot:Object = null;
         imageForPlot = EmbeddedArt[embeddedArtKey + "_" + Global.worldManager.currentWorldType];
         if(imageForPlot == null)
         {
            imageForPlot = EmbeddedArt[embeddedArtKey];
         }
         return imageForPlot;
      }
      
      protected function getTerrainPrefixedString(string:String) : String
      {
         return this.getTerrainPrefix(currentTerrainName) + string;
      }
      
      override public function conditionallyRedraw(forceRedraw:Boolean = false) : void
      {
         if(forceRedraw)
         {
            this.m_dirtyOrganicFertilizer = true;
         }
         var terrainName:String = findTerrainName();
         if(currentTerrainName != terrainName)
         {
            this.setDisplayStatesForPlots(terrainName);
         }
         super.conditionallyRedraw(forceRedraw);
         this.conditionallyAttachFertilizerOverlay();
         this.conditionallyAttachSuperPlotOverlay();
      }
      
      override public function conditionallyReattach(force:Boolean = false) : void
      {
         var terrainName:String = findTerrainName();
         if(currentTerrainName != terrainName)
         {
            this.setDisplayStatesForPlots(terrainName);
         }
         super.conditionallyReattach(force);
      }
      
      override public function getSaveObject() : Object
      {
         this.m_isNewPlot = false;
         var result:Object = super.getSaveObject();
         result.isJumbo = this.m_isJumbo;
         result.isBigPlot = m_isBigPlot;
         result.isProduceItem = m_isProduceItem;
         return result;
      }
      
      override public function loadObject(data:Object) : void
      {
         this.m_dirtyOrganicFertilizer = true;
         this.m_isNewPlot = false;
         m_isBigPlot = data.isBigPlot;
         m_isProduceItem = data.isProduceItem;
         super.loadObject(data);
         this.m_isJumbo = Boolean(data.isJumbo) || this.isOrganicFertilized();
         if(state == STATE_FALLOW || state == STATE_WITHERED)
         {
            this.m_isJumbo = false;
            m_isProduceItem = false;
            this.setOrganicFertilized(false);
         }
         if(state == STATE_WITHERED && Global.worldManager.isVisitingNPCOfType(NPCConfigData.TYPE_MODELFARM))
         {
            this.setState(STATE_GROWN);
         }
         this.setDisplayStatesForPlots(findTerrainName());
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         var isDynamicIcon:Boolean;
         var farmClubData:FarmClubDataObject = null;
         var callbackIndex:int = 0;
         super.replaceContent(newContent,shouldRedrawMask);
         isDynamicIcon = false;
         if(state != STATE_FALLOW && state != STATE_PLOWED)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               isDynamicIcon = m_item.getBoolFromDataSource("dynamicIcon");
            }
            else
            {
               isDynamicIcon = m_item.xml.@dynamicIcon == "true";
            }
         }
         if(isDynamicIcon)
         {
            farmClubData = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
            if(farmClubData == null)
            {
               callbackIndex = 0;
               callbackIndex = FarmClubDataManager.getInstance().registerCaller(FarmClubDataManager.FARM_CLUB_DATA,function(data:FarmClubDataObject):void
               {
                  FarmClubDataManager.getInstance().unregisterCaller(callbackIndex);
                  m_clubLogoId = data.farmClub.clubLogoId;
                  loadAndAttachClubLogo();
               });
            }
            else
            {
               this.m_clubLogoId = farmClubData.farmClub.clubLogoId;
               this.loadAndAttachClubLogo();
            }
         }
      }
      
      private function loadAndAttachClubLogo() : void
      {
         if(this.m_clubLogoIcon == null)
         {
            LoadingManager.load(Global.getAssetURL(FarmClubUtility.getLogoPathFromId(this.m_clubLogoId)),this.onLogoLoad);
         }
         else
         {
            this.addLogo();
         }
      }
      
      private function onLogoLoad(event:Event) : void
      {
         var displayObject:DisplayObject = event.target.content as DisplayObject;
         this.m_clubLogoIcon = FarmGameUtil.getSkewedBitmap(displayObject,0,26 * Math.PI / 180);
         this.m_clubLogoIcon.scaleX = 0.28;
         this.m_clubLogoIcon.scaleY = 0.28;
         this.m_clubLogoIcon.x = 60;
         this.m_clubLogoIcon.y = 112;
         this.addLogo();
      }
      
      private function addLogo() : void
      {
         if(this.m_clubLogoIcon != null && this.m_clubLogoIcon.parent != this.m_displayObject as Sprite)
         {
            (this.m_displayObject as Sprite).addChild(this.m_clubLogoIcon);
         }
      }
      
      override public function setState(value:String) : void
      {
         var sprite:Sprite = null;
         this.m_dirtyOrganicFertilizer = true;
         super.setState(value);
         if(value == STATE_FALLOW)
         {
            sprite = m_displayObject as Sprite;
            if(Boolean(this.m_clubLogoIcon) && Boolean(sprite) && this.m_clubLogoIcon.parent == sprite)
            {
               (this.m_displayObject as Sprite).removeChild(this.m_clubLogoIcon);
            }
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = this.getItemImageName();
         this.m_itemImageName = imageName;
         if(state == STATE_FALLOW || state == STATE_PLOWED)
         {
            imageName = null;
         }
         return imageName;
      }
      
      protected function hasPlowedPlotFertilizerExpired() : Boolean
      {
         var delta:Number = NaN;
         var result:Boolean = true;
         if(0 != plantTime)
         {
            delta = Global.worldTime - plantTime;
            if(0 == m_plowedPlotFertilizerExpireTime)
            {
               m_plowedPlotFertilizerExpireTime = Global.farmGameSettingsManager.getNumber("fertilizePlowedPlotExpireTime",604800) * 1000;
            }
            result = delta > m_plowedPlotFertilizerExpireTime;
         }
         return result;
      }
      
      public function showArrow(show:Boolean = false) : void
      {
         this.m_showArrow = show;
         this.conditionallyAttachArrowOverlay();
      }
      
      private function conditionallyAttachArrowOverlay() : void
      {
         if(!this.m_arrowOverlay)
         {
            this.m_arrowOverlay = new EmbeddedArt.bouncing_arrow() as DisplayObject;
            this.m_arrowOverlay.x = 80;
            this.m_arrowOverlay.y = 0;
            this.m_arrowOverlay.scaleX = 1;
            this.m_arrowOverlay.scaleY = 1;
            (this.m_displayObject as Sprite).addChild(this.m_arrowOverlay);
         }
         if(this.m_showArrow)
         {
            this.m_arrowOverlay.visible = true;
         }
         else
         {
            this.m_arrowOverlay.visible = false;
            if(this.m_arrowOverlay)
            {
               if(this.m_arrowOverlay.parent)
               {
                  this.m_arrowOverlay.parent.removeChild(this.m_arrowOverlay);
               }
               this.m_arrowOverlay = null;
            }
         }
      }
      
      private function conditionallyAttachFertilizerOverlay() : void
      {
         var isOrganicFert:Boolean = this.isOrganicFertilized();
         if(isOrganicFert)
         {
            if(!this.m_organicFertOverlayRequested && this.m_organicFertOverlay == null)
            {
               m_organicFertOverlayLoader.getContent(this.onOrganicFertilizerOverlayLoad);
               this.m_organicFertOverlayRequested = true;
            }
            else if(this.m_organicFertOverlay != null && (this.m_displayObject as Sprite).numChildren > 0)
            {
               (this.m_displayObject as Sprite).addChild(this.m_organicFertOverlay);
               this.m_organicFertOverlay.x = 10;
               this.m_organicFertOverlay.y = 100;
               this.m_organicFertOverlay.scaleX = 1;
               this.m_organicFertOverlay.scaleY = 1;
            }
         }
         else if(this.m_organicFertOverlay != null && this.m_organicFertOverlay.parent != null)
         {
            this.removeFertOverlay(this.m_organicFertOverlay);
            this.m_organicFertOverlay = null;
         }
         if(this.m_isJumbo && !isOrganicFert)
         {
            if(!this.m_fertOverlayRequested && this.m_fertOverlay == null)
            {
               m_fertOverlayLoader.getContent(this.onFertilizerOverlayLoad);
               this.m_fertOverlayRequested = true;
            }
            else if(this.m_fertOverlay != null && (this.m_displayObject as Sprite).numChildren > 0)
            {
               (this.m_displayObject as Sprite).addChild(this.m_fertOverlay);
               this.m_fertOverlay.x = 10;
               this.m_fertOverlay.y = 100;
               this.m_fertOverlay.scaleX = 1;
               this.m_fertOverlay.scaleY = 1;
            }
         }
         else if(!this.m_isJumbo && !isOrganicFert && this.m_fertOverlay != null && this.m_fertOverlay.parent != null)
         {
            this.removeFertOverlay(this.m_fertOverlay);
            this.m_fertOverlay = null;
         }
      }
      
      private function removeFertOverlay(overlay:DisplayObject) : void
      {
         var parent:DisplayObjectContainer = overlay.parent;
         if(!(parent is Loader))
         {
            parent.removeChild(overlay);
         }
      }
      
      private function onFertilizerOverlayLoad(content:DisplayObject, info:Object = null) : void
      {
         if(content != null)
         {
            this.m_fertOverlay = content;
            this.conditionallyAttachFertilizerOverlay();
         }
      }
      
      private function onOrganicFertilizerOverlayLoad(content:DisplayObject, info:Object = null) : void
      {
         if(content != null)
         {
            this.m_organicFertOverlay = content;
            this.conditionallyAttachFertilizerOverlay();
         }
      }
      
      public function conditionallyAttachSuperPlotOverlay() : void
      {
         var displaySprite:Sprite = null;
         var isSuperPlot:Boolean = SuperPlotManager.isSuperPlot(this);
         if(isSuperPlot)
         {
            if(!this.m_superPlotOverlayRequested && this.m_superPlotOverlay == null)
            {
               m_superPlotOverlayLoader.getContent(this.onSuperPlotOverlayLoad);
               this.m_superPlotOverlayRequested = true;
            }
            else if(this.m_superPlotOverlay)
            {
               displaySprite = m_displayObject as Sprite;
               if(Boolean(displaySprite) && displaySprite.numChildren > 0)
               {
                  displaySprite.addChild(this.m_superPlotOverlay);
                  this.m_superPlotOverlay.x = SUPER_PLOT_OVERLAY_OFFSET_X;
                  this.m_superPlotOverlay.y = SUPER_PLOT_OVERLAY_OFFSET_Y;
                  this.m_superPlotOverlay.scaleX = SUPER_PLOT_OVERLAY_SCALE;
                  this.m_superPlotOverlay.scaleY = SUPER_PLOT_OVERLAY_SCALE;
               }
            }
         }
         else if(Boolean(this.m_superPlotOverlay) && Boolean(this.m_superPlotOverlay.parent))
         {
            this.m_superPlotOverlay.parent.removeChild(this.m_superPlotOverlay);
            this.m_superPlotOverlay = null;
         }
      }
      
      private function onSuperPlotOverlayLoad(content:DisplayObject, info:Object = null) : void
      {
         if(content != null)
         {
            this.m_superPlotOverlay = content;
            this.conditionallyAttachSuperPlotOverlay();
         }
      }
      
      public function getItemImageName() : String
      {
         var growthStages:Array = null;
         var growthNames:Array = null;
         var imageName:String = null;
         var pct:Number = NaN;
         var stageIdx:* = 0;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CROP_CYCLES) > 0)
         {
            growthStages = [0,50];
            growthNames = ["seeds","growing2"];
         }
         else
         {
            growthStages = [0,33,66];
            growthNames = ["seeds","growing1","growing2"];
         }
         switch(state)
         {
            case STATE_PLANTED:
               pct = getGrowPercentage();
               for(stageIdx = int(growthStages.length - 1); stageIdx >= 0; stageIdx--)
               {
                  if(pct >= growthStages[stageIdx])
                  {
                     imageName = growthNames[stageIdx];
                     break;
                  }
               }
               break;
            case STATE_GROWN:
               if(m_isBigPlot || this.m_isJumbo)
               {
                  imageName = "super";
               }
               else
               {
                  imageName = "grown";
               }
               break;
            case STATE_WITHERED:
               imageName = "withered";
         }
         return imageName;
      }
      
      override public function getCollisionFlags(x:int, y:int) : int
      {
         var result:int = super.getCollisionFlags(x,y);
         if(x == 0 || y == 0 || x == m_size.x - 1 || y == m_size.y - 1)
         {
            result |= Constants.COLLISION_ALL_EXCEPT_AVATAR;
         }
         return result;
      }
      
      override protected function onPeriodicUpdate() : void
      {
         super.onPeriodicUpdate();
         if(this.m_firstTimePeriodicUpdate && Global.player.isDataLoaded)
         {
            this.m_firstTimePeriodicUpdate = false;
            this.conditionallyRedraw(true);
         }
         var isOrganicFert:Boolean = this.isOrganicFertilized();
         if(state == STATE_PLOWED && this.m_isJumbo && (this.hasPlowedPlotFertilizerExpired() && !isOrganicFert))
         {
            this.m_isJumbo = false;
            plantTime = 0;
            this.conditionallyAttachFertilizerOverlay();
         }
         if(this.m_isJumbo && !isOrganicFert && this.m_fertOverlay == null || isOrganicFert && this.m_organicFertOverlay == null)
         {
            this.conditionallyAttachFertilizerOverlay();
         }
      }
      
      override protected function determineState(delta:Number) : void
      {
         var imageName:String = null;
         if(state == STATE_PLANTED)
         {
            if(this.isHarvestable())
            {
               this.setState(STATE_GROWN);
            }
            else
            {
               imageName = this.getItemImageName();
               if(this.m_itemImageName != imageName)
               {
                  this.m_itemImageName = imageName;
                  m_image = null;
                  this.conditionallyRedraw(true);
               }
            }
         }
         else if(state == STATE_GROWN)
         {
            if(this.getWitherPercentage() == 100)
            {
               this.setState(STATE_WITHERED);
               this.m_isJumbo = false;
               if(this.m_fertOverlay != null)
               {
                  this.m_fertOverlay.visible = false;
               }
               if(this.m_organicFertOverlay != null)
               {
                  this.m_organicFertOverlay.visible = false;
               }
            }
         }
      }
      
      override public function getHarvestTimeText(pkgKeyOverride:String = "PlantedPlotTime") : String
      {
         if(this.isOrganicFertilized())
         {
            pkgKeyOverride = "PlantedPlotTimeOrganicFertilized";
         }
         else if(this.m_isJumbo)
         {
            pkgKeyOverride = "PlantedPlotTimeFertilized";
         }
         return super.getHarvestTimeText(pkgKeyOverride);
      }
      
      override protected function updateToolTipText() : void
      {
         var growPercentage:int = 0;
         var cost:int = 0;
         var isActionable:Boolean = false;
         var toolTip:String = null;
         var placementOption:String = TOOLTIP_TOP;
         if(isHighlighted())
         {
            if(!Global.worldManager.isVisiting())
            {
               if(Global.world.getTopGameMode() is GMDecoMove)
               {
                  toolTip = ZLocUtils.t("FarmGame","ClickToMove");
               }
               else if(Global.world.getTopGameMode() is GMPlotRemover)
               {
                  toolTip = ZLocUtils.t("FarmGame","ClickToRemove");
               }
               else if(m_actionState != IS_RESTING)
               {
                  switch(m_actionState)
                  {
                     case IS_PLANTING:
                        toolTip = ZLocUtils.t("FarmGame","Planting");
                        break;
                     case IS_PLOWING:
                        toolTip = ZLocUtils.t("FarmGame","Plowing");
                        break;
                     case IS_HARVESTING:
                        toolTip = ZLocUtils.t("FarmGame","Harvesting");
                        break;
                     case IS_FERTILIZING:
                        toolTip = ZLocUtils.t("FarmGame","Fertilizing");
                  }
               }
               else
               {
                  switch(state)
                  {
                     case STATE_FALLOW:
                        toolTip = ZLocUtils.t("FarmGame",this.getTerrainPrefixedString("FallowPlot"));
                        break;
                     case STATE_PLOWED:
                        if(this.m_isJumbo == false)
                        {
                           toolTip = ZLocUtils.t("FarmGame",this.getTerrainPrefixedString("PlowedPlot"));
                        }
                        else
                        {
                           toolTip = ZLocUtils.t("FarmGame",this.getTerrainPrefixedString("PlowedPlotFertilized"));
                        }
                        break;
                     case STATE_PLANTED:
                        if(RetentionMasterManager.inMasterExperiment() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HARVEST_TIME) == 2)
                        {
                           toolTip = this.getHarvestTimeText();
                        }
                        else
                        {
                           growPercentage = getGrowPercentage();
                           if(this.m_isJumbo == false)
                           {
                              toolTip = ZLocUtils.t("FarmGame","PlantedPlot",{
                                 "item":ZLocUtils.tk_pk(m_item.friendlyName),
                                 "quantity":growPercentage
                              });
                           }
                           else if(this.isOrganicFertilized())
                           {
                              toolTip = ZLocUtils.t("FarmGame","PlantedPlotOrganicFertilized",{
                                 "item":ZLocUtils.tk_pk(m_item.friendlyName),
                                 "quantity":growPercentage
                              });
                           }
                           else
                           {
                              toolTip = ZLocUtils.t("FarmGame","PlantedPlotFertilized",{
                                 "item":ZLocUtils.tk_pk(m_item.friendlyName),
                                 "quantity":growPercentage
                              });
                           }
                        }
                        if(getQualifiedClassName(Global.world.getTopGameMode()) == "GameMode::GMDefault")
                        {
                           if(OrganicFertilizerHelper.playerCanSeeFeature() && !this.isOrganicFertilized() && this.isOrganicFertilizable())
                           {
                              toolTip += "\n" + ZLocUtils.t("FarmGame","ApplyOrganicFertilizerHint");
                           }
                           else if(InstagrowHelper.playerCanSeeFeature())
                           {
                              toolTip += "\n" + ZLocUtils.t("FarmGame","ApplyInstantGrowHint");
                           }
                        }
                        break;
                     case STATE_GROWN:
                        if(this.isOrganicFertilized())
                        {
                           toolTip = ZLocUtils.t("FarmGame","GrownPlotOrganicFertilized",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                        }
                        else if(this.m_isJumbo == false)
                        {
                           toolTip = ZLocUtils.t("FarmGame","GrownPlot",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                        }
                        else if(this.isOrganicFertilized())
                        {
                           toolTip = ZLocUtils.t("FarmGame","GrownPlotOrganicFertilized",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                        }
                        else
                        {
                           toolTip = ZLocUtils.t("FarmGame","GrownPlotFertilized",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                        }
                        break;
                     case STATE_WITHERED:
                        cost = Global.farmGameSettingsManager.getInt("plowCost");
                        if(Global.player.canBuy(cost,false))
                        {
                           toolTip = ZLocUtils.t("FarmGame","WitheredPlot_HasMoney",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                        }
                        else
                        {
                           toolTip = ZLocUtils.t("FarmGame","WitheredPlot",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                        }
                  }
               }
            }
            else
            {
               isActionable = VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
               switch(state)
               {
                  case STATE_FALLOW:
                     if(isActionable)
                     {
                        toolTip = ZLocUtils.t("FarmGame","AskToPlow");
                     }
                     else
                     {
                        toolTip = ZLocUtils.t("FarmGame",this.getTerrainPrefixedString("FallowPlotVisitor"));
                     }
                     break;
                  case STATE_PLOWED:
                     if(this.isFertilizable() && isActionable)
                     {
                        toolTip = ZLocUtils.t("FarmGame","AskToFertilize");
                     }
                     else if(this.m_isJumbo == false)
                     {
                        toolTip = ZLocUtils.t("FarmGame",this.getTerrainPrefixedString("PlowedPlotVisitor"));
                     }
                     else
                     {
                        toolTip = ZLocUtils.t("FarmGame",this.getTerrainPrefixedString("PlowedPlotFertilized"));
                     }
                     break;
                  case STATE_PLANTED:
                     if(this.isFertilizable() && isActionable)
                     {
                        toolTip = ZLocUtils.t("FarmGame","AskToFertilize");
                     }
                     else
                     {
                        growPercentage = getGrowPercentage();
                        if(this.m_isJumbo == false)
                        {
                           toolTip = ZLocUtils.t("FarmGame","PlantedPlot",{
                              "item":ZLocUtils.tk_pk(m_item.friendlyName),
                              "quantity":growPercentage
                           });
                        }
                        else if(this.isOrganicFertilized())
                        {
                           toolTip = ZLocUtils.t("FarmGame","PlantedPlotOrganicFertilized",{
                              "item":ZLocUtils.tk_pk(m_item.friendlyName),
                              "quantity":growPercentage
                           });
                        }
                        else
                        {
                           toolTip = ZLocUtils.t("FarmGame","PlantedPlotFertilized",{
                              "item":ZLocUtils.tk_pk(m_item.friendlyName),
                              "quantity":growPercentage
                           });
                        }
                     }
                     break;
                  case STATE_GROWN:
                     if(this.isFertilizable() && isActionable)
                     {
                        toolTip = ZLocUtils.t("FarmGame","AskToFertilize");
                     }
                     else
                     {
                        growPercentage = getGrowPercentage();
                        if(this.m_isJumbo == false)
                        {
                           toolTip = ZLocUtils.t("FarmGame","GrownPlotVisitor",{
                              "item":ZLocUtils.tk_pk(m_item.friendlyName),
                              "quantity":growPercentage
                           });
                        }
                        else if(this.isOrganicFertilized())
                        {
                           toolTip = ZLocUtils.t("FarmGame","GrownPlotOrganicFertilizedVisitor",{
                              "item":ZLocUtils.tk_pk(m_item.friendlyName),
                              "quantity":growPercentage
                           });
                        }
                        else
                        {
                           toolTip = ZLocUtils.t("FarmGame","GrownPlotFertilizedVisitor",{
                              "item":ZLocUtils.tk_pk(m_item.friendlyName),
                              "quantity":growPercentage
                           });
                        }
                     }
                     break;
                  case STATE_WITHERED:
                     if(isActionable)
                     {
                        toolTip = ZLocUtils.t("FarmGame","AskToUnwither");
                     }
                     else
                     {
                        toolTip = ZLocUtils.t("FarmGame","WitheredPlotVisitor",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                     }
               }
            }
         }
         this.setToolTip(toolTip);
         updateToolTipPosition(placementOption);
      }
      
      override public function setHighlighted(highlighted:Boolean, color:uint = 16755200) : void
      {
         if(Global.worldManager.isVisiting() && Global.player.queuedFertilizer > 0 && !this.isFertilizable() && !this.m_queuedFertilize && !this.isPlowable())
         {
            highlighted = false;
         }
         super.setHighlighted(highlighted,color);
      }
      
      override public function getCursor() : Class
      {
         var cursor:Class = null;
         if(!Global.worldManager.isVisiting())
         {
            switch(state)
            {
               case STATE_PLOWED:
                  cursor = ZLocUtils.tiEmbeddedArt("cursor_plant");
                  break;
               case STATE_FALLOW:
               case STATE_WITHERED:
                  cursor = EmbeddedArt.cursor_plow;
                  break;
               case STATE_GROWN:
                  cursor = EmbeddedArt.cursor_harvest;
            }
         }
         else if(VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION))
         {
            if(this.isFertilizable())
            {
               cursor = ZLocUtils.tiEmbeddedArt("cursor_fertilize");
            }
            else if(state == STATE_FALLOW)
            {
               cursor = EmbeddedArt.cursor_plow;
            }
            else if(state == STATE_WITHERED)
            {
               cursor = EmbeddedArt.cursor_unwither;
            }
         }
         return cursor;
      }
      
      override public function setToolTip(toolTip:String) : void
      {
         if(toolTip == null && getToolTip() != null)
         {
            m_toolTipShowing = false;
         }
         else if(toolTip != null && m_toolTipShowing && getToolTip() == null)
         {
            toolTip = null;
         }
         if(toolTip != null)
         {
            m_toolTipShowing = true;
         }
         super.setToolTip(toolTip);
      }
      
      private function plotSeed(seedName:String) : void
      {
         var avatar:FarmAvatar = Global.selectedAvatar;
         if(Boolean(avatar) && Boolean(seedName))
         {
            avatar.getStateMachine().addState(new AMPlant(avatar,this,seedName),true);
         }
      }
      
      override public function showAoeBonus(bonusObject:AOEBonusData, showMultipliers:Boolean = true, showHighlight:Boolean = true) : void
      {
      }
      
      override public function onClick() : void
      {
         var unwitherDialogShown:Boolean = false;
         var superShowMenu:Boolean = false;
         var terrainCodes:Array = null;
         var subType:String = null;
         var subSubType:String = null;
         var sortBy:String = null;
         var sortDirection:String = null;
         var page:int = 0;
         var limitGroupName:String = Global.worldManager.getLimitGroupNameByTerrainName(findTerrainName());
         onMouseOut();
         if(!hasValidId())
         {
            showObjectBusy();
         }
         else if(Global.selectedAvatar)
         {
            if(!Global.worldManager.isVisiting())
            {
               switch(state)
               {
                  case STATE_PLOWED:
                     if(m_marketWindow2 == null)
                     {
                        terrainCodes = TerrainUtil.getTerrainCodesForItemInstance(this);
                        if(MarketWindow.previousType == "seed" && MarketWindow.previousSubType != "tree")
                        {
                           subType = MarketWindow.previousSubType;
                           subSubType = MarketWindow.previousSubSubType;
                           sortBy = MarketWindow.previousSortBy;
                           sortDirection = MarketWindow.previousSortDirection;
                           page = MarketWindow.previousPage;
                           m_marketWindow2 = UI.displayMarketDialog("contextual","seed",null,subType,null,subSubType,sortBy,sortDirection,page,terrainCodes,null,this.plotSeed) as MarketWindow;
                        }
                        else
                        {
                           m_marketWindow2 = UI.displayMarketDialog("contextual","seed",null,"seeds",null,null,null,null,-1,terrainCodes,null,this.plotSeed,true) as MarketWindow;
                        }
                        if(m_marketWindow2)
                        {
                           m_marketWindow2.addEventListener(MarketEvent.MARKET_BUY,this.onMarketBuyClick);
                           m_marketWindow2.addEventListener(CloseEvent.CLOSE,this.onMarketCloseClick);
                        }
                     }
                     break;
                  case STATE_GROWN:
                     FarmStatsManager.count("farm_world_actions","harvest","Plot","harvest_no_vehicle",limitGroupName);
                     DailyStatsManager.getInstance().incrementCounter(DailyStatsManager.SOURCE_CROP,DailyStatsManager.ACTION_HARVEST,1);
                     Global.selectedAvatar.getStateMachine().addState(new AMHarvest(Global.selectedAvatar,this),true);
                     break;
                  case STATE_FALLOW:
                     if(Global.selectedAvatar != null)
                     {
                        FarmStatsManager.count("farm_world_actions","plow","Plot","plow_no_vehicle",limitGroupName);
                        Global.selectedAvatar.getStateMachine().addState(new AMPlow(Global.selectedAvatar,this),true);
                     }
                     break;
                  case STATE_WITHERED:
                     unwitherDialogShown = UnwitherDialog.showUnwitherDialogIfAppropriate();
                     if(!unwitherDialogShown)
                     {
                        if(Global.selectedAvatar != null)
                        {
                           FarmStatsManager.count("farm_world_actions","plow","Plot","plow_no_vehicle",limitGroupName);
                           Global.selectedAvatar.getStateMachine().addState(new AMPlow(Global.selectedAvatar,this),true);
                        }
                     }
                     break;
                  case STATE_PLANTED:
                     m_menuItems = [];
                     superShowMenu = false;
                     if(OrganicFertilizerHelper.playerCanSeeFeature() && !this.isOrganicFertilized() && this.isOrganicFertilizable())
                     {
                        m_menuItems.push({
                           "label":ZLocUtils.t("FarmGame","ApplyOrganicFertilizer"),
                           "action":APPLY_ORGANIC_FERTILIZER
                        });
                        superShowMenu = true;
                     }
                     if(InstagrowHelper.playerCanSeeFeature())
                     {
                        m_menuItems.push({
                           "label":ZLocUtils.t("FarmGame","ApplyInstantGrow"),
                           "action":APPLY_GROW
                        });
                        superShowMenu = true;
                        FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_open","crop","","","User opens context menu from crop");
                     }
                     if(BushelReportActionDropHandler.canPlayerSeeFeature())
                     {
                        m_menuItems.push({
                           "label":ZLocUtils.t("FarmGame","OpenBushelReport"),
                           "action":OPEN_BUSHEL_REPORT
                        });
                     }
                     if(superShowMenu)
                     {
                        super.showMenu();
                     }
               }
            }
            else if(VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION))
            {
               if(this.isWithered())
               {
                  VisitorManager.getInstance().queueActionType(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
                  Global.selectedAvatar.getStateMachine().addState(new AMUnwither(Global.selectedAvatar,this),true);
               }
               else if(this.isFertilizable())
               {
                  VisitorManager.getInstance().queueActionType(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
                  Global.selectedAvatar.getStateMachine().addState(new AMFertilize(Global.selectedAvatar,this),true);
               }
               else if(this.isPlowable())
               {
                  VisitorManager.getInstance().queueActionType(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
                  Global.selectedAvatar.getStateMachine().addState(new AMPlow(Global.selectedAvatar,this),true);
               }
            }
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var clickedApplyGrow:Boolean = false;
         var message:String = null;
         var dialog:GenericPopup = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            clickedApplyGrow = false;
            switch(item.action)
            {
               case APPLY_GROW:
                  clickedApplyGrow = true;
                  FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","crop",InstagrowUtils.INSTA_GROW_COUNTER,"","User opens context menu from crop, clicks instant_grow");
                  if(Global.world.addGameMode(new GMAirplaneFly(),true) == false)
                  {
                     message = ZLocUtils.t("Dialogs","InstantGrow_OnlyOnePlaneAtATime");
                     dialog = new GenericPopup(message,GenericPopup.TYPE_OK);
                     UI.displayPopup(dialog);
                  }
                  break;
               case APPLY_ORGANIC_FERTILIZER:
                  if(!this.isOrganicFertilized())
                  {
                     OrganicFertilizerHelper.showMainWindow();
                     if(OrganicFertilizerHelper.playerCanSeeFeature())
                     {
                        FarmStatsManager.count(OrganicFertilizerHelper.FEATURE_NAME,StatsTrackingConstants.CONTEXT_MENU,StatsTrackingConstants.CLICKS);
                     }
                  }
                  break;
               case OPEN_BUSHEL_REPORT:
                  UI.showBushelReportWindow();
                  break;
               case DEBUG_CHANGE_EXPORT:
                  m_item.testAssetExportName = item.label;
                  reloadImage();
            }
            if(!clickedApplyGrow)
            {
               FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","crop","all_other_options","","User opens context menu from crop, clicks all_other_options");
            }
         }
      }
      
      protected function onMarketBuyClick(event:MarketEvent) : void
      {
         this.onMarketCloseClick(event as Event);
         if(event.eventType == MarketEvent.SEED)
         {
            Global.selectedAvatar.getStateMachine().addState(new AMPlant(Global.selectedAvatar,this,event.item));
         }
      }
      
      protected function onMarketCloseClick(event:Event) : void
      {
         if(Boolean(m_marketWindow2) && Boolean(m_marketWindow2.parent))
         {
            m_marketWindow2.removeEventListener(MarketEvent.MARKET_BUY,this.onMarketBuyClick);
            m_marketWindow2.removeEventListener(CloseEvent.CLOSE,this.onMarketCloseClick);
            m_marketWindow2.close();
         }
         m_marketWindow2 = null;
      }
      
      override public function isHarvestable() : Boolean
      {
         var tmpState:String = state;
         return getGrowPercentage() == 100 && tmpState != STATE_FALLOW && tmpState != STATE_WITHERED || tmpState == STATE_GROWN;
      }
      
      public function isFertilizable() : Boolean
      {
         var tmpState:String = state;
         return Plot.playerCanFertilize() && !this.m_isJumbo && !this.m_fertilized && (tmpState == STATE_PLOWED || tmpState == STATE_PLANTED || tmpState == STATE_GROWN);
      }
      
      public function isWaterable() : Boolean
      {
         return state == STATE_PLANTED;
      }
      
      public function isOrganicFertilizable() : Boolean
      {
         var isOrganicFert:Boolean = this.isOrganicFertilized();
         var tmpState:String = state;
         return Plot.playerCanFertilize() && OrganicFertilizerHelper.playerCanSeeFeature() && !this.isFertilized() && (tmpState == STATE_PLANTED || tmpState == STATE_GROWN) && !isOrganicFert;
      }
      
      override public function setOrganicFertilized(isSet:Boolean) : void
      {
         super.setOrganicFertilized(isSet);
         this.m_isJumbo = isSet;
         this.conditionallyAttachFertilizerOverlay();
         this.m_cachedIsOrganicFertilized = isSet;
         this.m_dirtyOrganicFertilizer = false;
      }
      
      public function isOrganicFertilized() : Boolean
      {
         var tmpState:String = null;
         if(this.getId() == 0)
         {
            this.m_dirtyOrganicFertilizer = true;
            this.m_cachedIsOrganicFertilized = false;
         }
         else if(this.m_dirtyOrganicFertilizer)
         {
            this.m_dirtyOrganicFertilizer = false;
            tmpState = state;
            this.m_cachedIsOrganicFertilized = OrganicFertilizerHelper.playerCanSeeFeature() && (tmpState == STATE_PLANTED || tmpState == STATE_GROWN) && Global.world.isHarvestableResourceOrganicFertilized(this);
         }
         return this.m_cachedIsOrganicFertilized;
      }
      
      public function isPlantable() : Boolean
      {
         return state == STATE_PLOWED && hasValidId();
      }
      
      public function isPlanted() : Boolean
      {
         return state == STATE_PLANTED;
      }
      
      public function isPlowable() : Boolean
      {
         var tmpState:String = state;
         return tmpState == STATE_FALLOW || tmpState == STATE_WITHERED;
      }
      
      public function isRemovable() : Boolean
      {
         var tmpState:String = state;
         return tmpState == STATE_FALLOW || tmpState == STATE_PLOWED;
      }
      
      public function isWithered() : Boolean
      {
         return state == STATE_WITHERED;
      }
      
      public function isGrown() : Boolean
      {
         return state == STATE_GROWN;
      }
      
      public function isFertilized() : Boolean
      {
         return this.m_isJumbo;
      }
      
      public function getWitherPercentage() : Number
      {
         var worldHasMoreThanOneSeason:Boolean = false;
         var terrainCodePlacedOn:Array = null;
         var terrainCode:int = 0;
         var alpha:Number = NaN;
         var witherOn:Boolean = true;
         if(Global.flashHotParams["UNWITHER_FRONTEND_FIX"] == true)
         {
            worldHasMoreThanOneSeason = WorldSeasonsManager.getInstance().getNumSeasonsForWorld(Global.worldManager.currentWorldType) > 1 ? true : false;
            if(worldHasMoreThanOneSeason)
            {
               terrainCodePlacedOn = TerrainUtil.getTerrainCodesForItemInstance(this);
               for each(terrainCode in terrainCodePlacedOn)
               {
                  witherOn = Global.getCurrentWitherStatusArray(terrainCode);
               }
            }
            else
            {
               witherOn = Global.getCurrentWitherStatus();
            }
         }
         if(plantTime > 0 && witherOn)
         {
            alpha = (Global.worldTime - plantTime) / (m_witherTime - plantTime);
            return Math.min(Math.floor(alpha * 100),100);
         }
         return 0;
      }
      
      public function get lastPlowYield() : int
      {
         return this.m_lastPlowYield;
      }
      
      public function plow(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, showDisplayMessage:Boolean = true) : Boolean
      {
         var xp:int = 0;
         var worldPlotCostData:Object = null;
         var canBuy:Boolean = false;
         var energyMetaData:Object = null;
         var result:Boolean = false;
         if(this.isPlowable())
         {
            if(Global.worldManager.isVisiting())
            {
               if(state == STATE_FALLOW)
               {
                  VisitorManager.getInstance().doAction(new PlowNeighborAction(this));
               }
            }
            else
            {
               xp = Global.farmGameSettingsManager.getInt("plowXp");
               worldPlotCostData = Plot.getWorldPlowPlotCostData();
               canBuy = Global.player.canBuyWithCurrency(worldPlotCostData.currencyUnit,worldPlotCostData.cost,true,"Plowing");
               if(canBuy && hasEnergy(energySource,energy,HarvestableResource.RESOURCE_ACTION_CLEAR,showNoEnergyMessage))
               {
                  Global.player.updateWorldCurrency(worldPlotCostData.currencyUnit,-worldPlotCostData.cost);
                  xp *= PowerHourManager.getXpBuff();
                  xp = Global.player.calculateAndAddXp(xp);
                  this.m_lastPlowYield = xp;
                  energyMetaData = useEnergy(energySource,energy,HarvestableResource.RESOURCE_ACTION_CLEAR);
                  if(HarvestableResource.ENERGY_SOURCE_AVATAR == energySource && showDisplayMessage)
                  {
                     this.displayStatus(ZLocUtils.t("FarmGame","Status_PlowPlot",{
                        "coinNum":worldPlotCostData.cost,
                        "currency":ZLocUtils.t("FarmGame",worldPlotCostData.currencyUnit),
                        "xpNum":xp
                     }));
                  }
                  this.executePlow();
                  Global.world.dispatchEvent(new PlotEvent(PlotEvent.PLOT_PLOWED,this));
                  if(updateBackend)
                  {
                     TransactionManager.addTransaction(new TPlow(this,energySource,energy,energyMetaData));
                  }
                  result = true;
               }
               else if(energy > 0 && this.m_isNewPlot && state == STATE_FALLOW)
               {
                  detach();
               }
               else if(this.isWithered() && canBuy)
               {
                  this.setState(STATE_PLOWED);
                  this.m_isJumbo = false;
                  m_isBigPlot = false;
                  m_isProduceItem = false;
                  if(updateBackend)
                  {
                     TransactionManager.addTransaction(new TClearWithered(this));
                  }
               }
            }
         }
         return result;
      }
      
      public function remove(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, showDisplayMessage:Boolean = true) : Boolean
      {
         var xp:int = 0;
         var worldPlotCostData:Object = null;
         var canBuy:Boolean = false;
         var energyMetaData:Object = null;
         var gmClear:GMClear = null;
         var obj:ItemInstance = null;
         var result:Boolean = false;
         if(this.isRemovable())
         {
            if(!Global.worldManager.isVisiting())
            {
               xp = Global.farmGameSettingsManager.getInt("plowXp");
               worldPlotCostData = Plot.getWorldPlowPlotCostData();
               canBuy = Global.player.canBuyWithCurrency(worldPlotCostData.currencyUnit,worldPlotCostData.cost,true,"Plowing");
               if(canBuy && hasEnergy(energySource,energy,HarvestableResource.RESOURCE_ACTION_CLEAR,showNoEnergyMessage))
               {
                  Global.player.updateWorldCurrency(worldPlotCostData.currencyUnit,-worldPlotCostData.cost);
                  energyMetaData = useEnergy(energySource,energy,HarvestableResource.RESOURCE_ACTION_CLEAR);
                  if(HarvestableResource.ENERGY_SOURCE_AVATAR == energySource && showDisplayMessage)
                  {
                     this.displayStatus(ZLocUtils.t("FarmGame","Status_PlowPlot",{
                        "coinNum":worldPlotCostData.cost,
                        "currency":ZLocUtils.t("FarmGame",worldPlotCostData.currencyUnit),
                        "xpNum":xp
                     }));
                  }
                  gmClear = new GMClear();
                  obj = this as ItemInstance;
                  gmClear.deletePlots(true,this,"plot",obj);
                  if(updateBackend)
                  {
                     TransactionManager.addTransaction(new TClear(this));
                  }
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function unwither() : void
      {
         if(Global.worldManager.isVisiting() && this.isWithered())
         {
            VisitorManager.getInstance().doAction(new UnwitherNeighborAction(this));
         }
      }
      
      public function executePlow() : void
      {
         this.setState(STATE_PLOWED);
         this.m_isJumbo = false;
         m_isBigPlot = false;
         m_isProduceItem = false;
      }
      
      public function executeNeighborPlow(neighborId:String) : void
      {
         var xp:int = 0;
         if(this.isPlowable())
         {
            xp = Global.farmGameSettingsManager.getInt("plowXp");
            Global.player.xp += xp;
            this.executePlow();
            Global.world.dispatchEvent(new PlotEvent(PlotEvent.PLOT_PLOWED,this));
            TransactionManager.addTransaction(new TPlow(this,0,0,null,neighborId));
         }
      }
      
      public function executeFertilize() : void
      {
         this.setFertilized();
      }
      
      public function redeemNeighborFertilize(neighborId:String, xpYield:Number, coinYield:Number) : void
      {
         if(this.isFertilizable())
         {
            this.executeFertilize();
            TransactionManager.addTransaction(new TRedeemFertilize(this,neighborId));
         }
      }
      
      public function executeUnwither() : void
      {
         this.setFullGrown();
      }
      
      public function redeemNeighborUnwither(neighborId:String, xpYield:Number, coinYield:Number) : void
      {
         this.executeUnwither();
         TransactionManager.addTransaction(new TRedeemUnwither(this,neighborId));
      }
      
      public function setFertilized() : void
      {
         this.m_isJumbo = true;
      }
      
      override public function setFullGrown() : void
      {
         super.setFullGrown();
         this.setState(STATE_GROWN);
         m_witherTime = getWitherTime(m_plantTime,m_displayObject.x,m_displayObject.y);
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         var energyMetaData:Object = null;
         var seedItemCode:String = null;
         var aoeResourceIds:Array = null;
         var bonusData:AOEBonusData = null;
         var increment:int = 0;
         var result:Boolean = false;
         if(this.isHarvestable() && hasEnergy(energySource,energy,HarvestableResource.RESOURCE_ACTION_HARVEST,showNoEnergyMessage))
         {
            energyMetaData = useEnergy(energySource,energy,HarvestableResource.RESOURCE_ACTION_HARVEST);
            if(this.state == STATE_GROWN)
            {
               DoobersManager.getInstance().executeDooberAction(DooberConstants.ACTION_HARVEST_PLOT + "_hoober",this);
               DoobersManager.getInstance().executeDooberAction(DooberConstants.ACTION_HARVEST_PLOT,this);
               CollectionsManager.getInstance().executeCollectionAction(CollectionsConstants.ACTION_HARVEST_PLOT,this as HarvestableResource,this.getPosition());
               aoeResourceIds = getAOESourceIds();
               bonusData = AOEManager.getInstance().computeBonusesForAoeResourceIds(aoeResourceIds,this);
               this.m_bonusMultipliers = bonusData.bonusMultiplierTypes;
               this.m_bonusCumulativeTypes = bonusData.bonusCumulativeTypes;
            }
            this.setState(STATE_FALLOW);
            Global.world.dispatchEvent(new PlotEvent(PlotEvent.PLOT_HARVESTED,this));
            if(updateBackend)
            {
               TransactionManager.addTransaction(new THarvest(this,energySource,energy,energyMetaData,"0",null,aoeResourceIds));
            }
            TradingPostManager.getInstance().putGoodUpForSale(getItem().code,plantTime);
            plantTime = 0;
            seedItemCode = getResourceItemCode();
            if(seedItemCode != "")
            {
               increment = SuperPlotManager.getMultiplier(this);
               if(increment != 1 && this.harvestYieldMultiplier != 1)
               {
                  increment += this.harvestYieldMultiplier;
               }
               else if(increment == 1 && this.harvestYieldMultiplier != 1)
               {
                  increment = this.harvestYieldMultiplier;
               }
               Global.player.incrementHarvestCountForSeedSinceLastBushelDrop(seedItemCode,increment);
            }
            result = true;
         }
         return result;
      }
      
      public function get harvestYieldMultiplier() : Number
      {
         return Boolean(this.m_bonusMultipliers) && this.m_bonusMultipliers.hasOwnProperty("harvestYield") ? Number(this.m_bonusMultipliers.harvestYield) : 1;
      }
      
      public function get aoeharvestHelperMultiplier() : Number
      {
         return Boolean(this.m_bonusCumulativeTypes) && this.m_bonusCumulativeTypes.hasOwnProperty("harvestYield") ? Number(this.m_bonusCumulativeTypes.harvestYield) : 1;
      }
      
      public function get masteryYieldMultiplier() : Number
      {
         return Boolean(this.m_bonusMultipliers) && this.m_bonusMultipliers.hasOwnProperty("mastery") ? Number(this.m_bonusMultipliers.mastery) : 1;
      }
      
      override public function doHarvestDropOff(avatar:FarmAvatar, showStatus:Boolean = true) : Object
      {
         var seedItemCoinYield:int = 0;
         var seedItemXpYield:int = 0;
         var isItemOrganicCertified:Boolean = false;
         var seedName:String = null;
         var hasSeedItem:Boolean = false;
         var itemCode:String = null;
         var isOrganicFert:Boolean = false;
         var seedItem:XML = null;
         var superPlotMultiplier:int = 0;
         var coinMultiplier:int = 0;
         var harvestYieldsGroup:HarvestYieldsGroup = null;
         var statusMessage:String = null;
         var iconUrl:String = null;
         var iconFilters:Array = null;
         var tweenDuration:Number = NaN;
         var tweenDisplacement:int = 0;
         var powerHourCoinBuffs:Array = null;
         var harvestStatus:Object = null;
         var result:Object = new Object();
         if(m_item)
         {
            hasSeedItem = false;
            itemCode = m_item.code;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               hasSeedItem = true;
               seedItemCoinYield = m_item.getIntFromDataSource("coinYield");
               seedItemXpYield = m_item.getIntFromDataSource("xpYield");
               isItemOrganicCertified = Global.player.isItemOrganicCertified(seedItem,itemCode);
               seedName = m_item.getStringFromDataSource("name");
            }
            else
            {
               seedItem = m_item.xml;
               if(seedItem)
               {
                  hasSeedItem = true;
                  seedItemCoinYield = int(seedItem.coinYield);
                  seedItemXpYield = int(seedItem.xpYield);
                  isItemOrganicCertified = Global.player.isItemOrganicCertified(seedItem,itemCode);
                  seedName = seedItem.@name;
               }
            }
            isOrganicFert = Global.world.isHarvestableResourceOrganicFertilized(this);
            if(hasSeedItem)
            {
               if(ExperimentManager.isOrganicMainExperimentOn())
               {
                  if(isItemOrganicCertified)
                  {
                     result.coinYield = seedItemCoinYield * ORGANIC_MULT;
                     result.xpYield = seedItemXpYield * Plot.ORGANIC_MULT;
                  }
                  else
                  {
                     result.coinYield = seedItemCoinYield;
                     result.xpYield = seedItemXpYield;
                  }
               }
               else
               {
                  result.coinYield = seedItemCoinYield;
                  result.xpYield = seedItemXpYield;
               }
               if(m_item is HarvestableItem && (m_item as HarvestableItem).hasMastery)
               {
                  result.hasMastery = true;
                  result.masteryObject = Mastery.createMasteryForItem(m_item);
                  result.masteryYield = result.masteryObject.calculateMasteryYield(this.masteryYieldMultiplier);
               }
               else
               {
                  result.hasMastery = false;
               }
               if(BBushel.getBushelBuff(m_item.code) == BBushel.TYPE_CROPEXP)
               {
                  result.xpYield += Global.farmGameSettingsManager.getInt("buffCropExpBonus",1);
               }
               if(PowerHourManager.inExperiment())
               {
                  powerHourCoinBuffs = Global.player.getBuffsByClass(BCoinPowerHour);
                  if(powerHourCoinBuffs.length > 0)
                  {
                     result.coinYield *= 2;
                  }
                  result.xpYield *= PowerHourManager.getXpBuff();
               }
               result.canEarnMasteryPoints = canEarnMasteryPoints(result);
               result.numHarvestedItems = 0;
               if(m_isProduceItem)
               {
                  result.numHarvestedItems = 1;
                  result.harvestItemName = seedName;
                  m_isProduceItem = false;
               }
               if(this.m_isJumbo)
               {
                  if(!isOrganicFert)
                  {
                     result.coinYield *= Global.farmGameSettingsManager.getNumber("fertilizeHarvestCoinMult");
                     result.xpYield += Global.farmGameSettingsManager.getInt("fertilizeHarvestXpGain");
                     this.displayStatus(ZLocUtils.t("FarmGame","Status_FertilizeOnHarvest"));
                  }
                  this.m_isJumbo = false;
                  if(this.m_fertOverlay)
                  {
                     this.m_fertOverlay.visible = false;
                  }
               }
               if(isOrganicFert)
               {
                  result.xpYield += Global.farmGameSettingsManager.getInt("organicFertilizerXPGain",2);
                  result.masteryYield *= Global.farmGameSettingsManager.getInt("organicFertilizerMasteryMultiplier",3);
               }
               if(m_isBigPlot)
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     result.xpYield += (result.masteryObject as Mastery).item.getIntFromDataSource("largeCropXp");
                  }
                  else
                  {
                     result.xpYield += int(result.masteryObject.xml.largeCropXp);
                  }
                  m_isBigPlot = false;
               }
               superPlotMultiplier = SuperPlotManager.getMultiplier(this);
               result.xpYield *= superPlotMultiplier;
               result.masteryYield *= superPlotMultiplier;
               result.coinYield *= superPlotMultiplier;
               coinMultiplier = Global.player.getWorldCurrencyMultiplier(Currency.COINS);
               Global.player.updateWorldCurrency(Currency.COINS,int(result.coinYield),true);
               result.xpYield = Global.player.calculateAndAddXp(int(result.xpYield));
               harvestYieldsGroup = new HarvestYieldsGroup();
               if(this.m_item is HarvestableItem)
               {
                  harvestYieldsGroup.applyHarvestYieldsForItem(this.m_item as HarvestableItem);
                  result.harvestYields = harvestYieldsGroup.harvestYields;
               }
               if(isOrganicFert)
               {
                  this.setOrganicFertilized(false);
               }
               statusMessage = "";
               iconUrl = "";
               iconFilters = null;
               tweenDuration = UI.DEFAULT_STATUS_TWEEN_DURATION;
               tweenDisplacement = UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT;
               if(showStatus)
               {
                  statusMessage = harvestYieldsGroup.getDooberStatus();
                  if(result.xpYield > 0)
                  {
                     if(result.coinYield > 0)
                     {
                        if(result.canEarnMasteryPoints)
                        {
                           statusMessage += ZLocUtils.t("FarmGame","Status_HarvestCoinsXPMastery",{
                              "coinNum":result.coinYield * coinMultiplier,
                              "xpNum":result.xpYield,
                              "masteryNum":result.masteryYield
                           });
                        }
                        else
                        {
                           statusMessage += ZLocUtils.t("FarmGame","Status_HarvestCoinsXP",{
                              "coinNum":result.coinYield * coinMultiplier,
                              "xpNum":result.xpYield
                           });
                        }
                     }
                     else if(result.canEarnMasteryPoints)
                     {
                        statusMessage += ZLocUtils.t("FarmGame","Status_HarvestXPMastery",{
                           "xpNum":result.xpYield,
                           "masteryNum":result.masteryYield
                        });
                     }
                     else
                     {
                        statusMessage += ZLocUtils.t("FarmGame","Status_HarvestXP",{"xpNum":result.xpYield});
                     }
                  }
                  else if(result.coinYield > 0)
                  {
                     if(result.canEarnMasteryPoints)
                     {
                        statusMessage += ZLocUtils.t("FarmGame","Status_HarvestPlotMastery",{
                           "coinNum":result.coinYield * coinMultiplier,
                           "masteryNum":result.masteryYield
                        });
                     }
                     else
                     {
                        statusMessage += ZLocUtils.t("FarmGame","Status_HarvestPlot",{"coinNum":result.coinYield * coinMultiplier});
                     }
                  }
                  if(result.numHarvestedItems > 0)
                  {
                     harvestStatus = this.getHarvestProduceStatusData(result.numHarvestedItems);
                     statusMessage += "\n" + harvestStatus.message;
                     iconUrl = harvestStatus.iconUrl;
                     iconFilters = harvestStatus.iconFilters;
                     tweenDuration = Number(harvestStatus.tweenDuration);
                     tweenDisplacement = int(harvestStatus.tweenDisplacement);
                  }
               }
               if(!RetentionMasterManager.shouldSuppressHarvestStatusText())
               {
                  if(AvatarRetentionExperimentUtil.inNoWaitExperiment())
                  {
                     this.displayStatus(statusMessage,iconUrl,iconFilters,tweenDuration,tweenDisplacement);
                  }
                  else
                  {
                     avatar.displayStatus(statusMessage,iconUrl,iconFilters,tweenDuration,tweenDisplacement);
                  }
               }
            }
            this.m_isJumbo = false;
            super.doHarvestDropOff(avatar);
         }
         return result;
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         var pvpStatName:String = null;
         var seedItem:FarmItem = this.getItem();
         if(Boolean(seedItem) && (seedItem as SeedItem).isHybrid)
         {
            pvpStatName = Global.player.breedingState.getBreedingFeatureState(BreedingManager.GREENHOUSE_FEATURE_NAME).pvpStat;
            Global.player.incrementActionCount(pvpStatName,false);
            BreedingManager.getInstance().checkNeighborPassForPvP(BreedingManager.GREENHOUSE_FEATURE_NAME);
         }
      }
      
      public function getHarvestProduceStatusData(numItems:int = 1) : Object
      {
         var type:String = null;
         var subType:String = null;
         var buildingName:String = null;
         var harvestStatusMsg:String = null;
         var statusData:Object = new Object();
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            type = m_item.getStringFromDataSource("type");
            subType = m_item.getStringFromDataSource("subtype");
         }
         else
         {
            type = m_item.xml.@type;
            subType = m_item.xml.@subtype;
         }
         var harvestBuildings:Array = Global.farmGameSettingsManager.getHarvestStorageBuildings(type,subType);
         var storageBuildingName:String = null;
         for each(buildingName in harvestBuildings)
         {
            if(Global.player.hasLimitedItem(buildingName))
            {
               storageBuildingName = buildingName;
               break;
            }
         }
         if(storageBuildingName)
         {
            harvestStatusMsg = "Status_HarvestHasStorage_" + storageBuildingName;
         }
         else if(harvestBuildings.length > 0)
         {
            harvestStatusMsg = "Status_HarvestHasNoStorage_" + harvestBuildings[0];
         }
         if(harvestStatusMsg == null)
         {
            statusData.message = "";
         }
         else
         {
            statusData.message = ZLocUtils.t("FarmGame",harvestStatusMsg,{"quantity":numItems});
         }
         statusData.iconUrl = m_item.iconUrl;
         statusData.tweenDuration = HARVEST_ICON_TWEEN_DURATION;
         statusData.tweenDisplacement = HARVEST_ICON_TWEEN_DISPLACEMENT;
         statusData.iconFilters = [new GlowFilter(16776960,1,8,8,20)];
         return statusData;
      }
      
      public function get lastPlantYield() : int
      {
         return this.m_lastPlantYield;
      }
      
      public function plant(seedType:String, energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, showDisplayMessage:Boolean = true, testForToaster:Boolean = true) : Boolean
      {
         var seedItem:SeedItem = null;
         var itemCode:String = null;
         var superPlotMultiplier:int = 0;
         var xp:int = 0;
         var cost:int = 0;
         var currencyUnit:String = null;
         var useStoredSeed:Boolean = false;
         var itemXML:XML = null;
         var energyMetadata:Object = null;
         var aoeResourceIds:Array = null;
         var bonusData:AOEBonusData = null;
         var limitGroupName:String = null;
         var worldObjects:Array = null;
         var worldObject:WorldObject = null;
         var hasPlowedPlots:Boolean = false;
         var hasOrganicFertilizedCrops:Boolean = false;
         var plot:Plot = null;
         var result:Boolean = false;
         if(this.isPlantable())
         {
            seedItem = Global.farmGameSettingsManager.getFarmItemByName(seedType) as SeedItem;
            itemCode = seedItem.code;
            if(Boolean(seedItem) && seedItem.type == "seed")
            {
               superPlotMultiplier = SuperPlotManager.getMultiplier(this);
               xp = seedItem.plantXp;
               if(ExperimentManager.isOrganicMainExperimentOn())
               {
                  if(FarmGameSettingsManager.isInDataSourceExperiment())
                  {
                     if(Global.player.isItemOrganicCertifiedData(seedItem,itemCode))
                     {
                        xp *= ORGANIC_MULT;
                     }
                  }
                  else
                  {
                     itemXML = seedItem.xml;
                     if(Global.player.isItemOrganicCertified(itemXML,itemCode))
                     {
                        xp *= ORGANIC_MULT;
                     }
                  }
               }
               cost = seedItem.cost;
               cost *= superPlotMultiplier;
               currencyUnit = seedItem.market ? seedItem.market : Currency.COINS;
               useStoredSeed = false;
               if(Global.player.hasSeed(seedType))
               {
                  useStoredSeed = true;
               }
               if((useStoredSeed || Global.player.canBuyWithCurrency(currencyUnit,cost)) && hasEnergy(energySource,energy,HarvestableResource.RESOURCE_ACTION_PLANT,showNoEnergyMessage))
               {
                  if(useStoredSeed)
                  {
                     Global.player.useSeed(seedType);
                  }
                  else
                  {
                     Global.player.updateWorldCurrency(currencyUnit,-cost);
                  }
                  xp *= PowerHourManager.getXpBuff();
                  xp *= superPlotMultiplier;
                  xp = Global.player.calculateAndAddXp(xp);
                  this.m_lastPlantYield = xp;
                  energyMetadata = useEnergy(energySource,energy,HarvestableResource.RESOURCE_ACTION_PLANT);
                  if(HarvestableResource.ENERGY_SOURCE_AVATAR == energySource && showDisplayMessage)
                  {
                     if(useStoredSeed)
                     {
                        this.displayStatus(ZLocUtils.t("FarmGame","Status_PlantPlot_GiftableSeed",{"xpNum":xp}));
                     }
                     else
                     {
                        this.displayStatus(ZLocUtils.t("FarmGame","Status_PlantPlot",{
                           "coinNum":cost,
                           "currency":ZLocUtils.t("FarmGame",currencyUnit),
                           "xpNum":xp
                        }));
                     }
                  }
                  setItem(seedItem);
                  aoeResourceIds = getAOESourceIds();
                  bonusData = AOEManager.getInstance().computeBonusesForAoeResourceIds(aoeResourceIds,this);
                  this.m_bonusCumulativeTypes = bonusData.bonusCumulativeTypes;
                  this.initPlantTime(seedItem);
                  this.setState(STATE_PLANTED);
                  Global.world.dispatchEvent(new PlotEvent(PlotEvent.PLOT_PLANTED,this));
                  m_witherTime = getWitherTime(plantTime,m_displayObject.x,m_displayObject.y);
                  if(updateBackend)
                  {
                     TransactionManager.addTransaction(new TPlant(this,false,energySource,energy,energyMetadata,0,"",aoeResourceIds));
                  }
                  if(energySource == HarvestableResource.ENERGY_SOURCE_AVATAR)
                  {
                     limitGroupName = Global.worldManager.getLimitGroupNameByTerrainName(findTerrainName());
                     FarmStatsManager.count("farm_world_actions","plant","Plot","plant_no_vehicle",limitGroupName);
                  }
                  IdleTaskQueue.getInstance().addTask(new ZapFirstPlacementDialogTask(seedItem.name));
                  result = true;
               }
            }
            else
            {
               ErrorManager.addError("Invalid seed type specified for planting! type: " + seedType);
            }
         }
         else if(!hasValidId())
         {
            showObjectBusy();
         }
         if(testForToaster)
         {
            worldObjects = Global.world.getObjects();
            hasPlowedPlots = false;
            hasOrganicFertilizedCrops = false;
            plot = null;
            for each(worldObject in worldObjects)
            {
               plot = worldObject as Plot;
               if(plot)
               {
                  if(plot.isPlantable())
                  {
                     hasPlowedPlots = true;
                     break;
                  }
                  if(!hasOrganicFertilizedCrops && plot.isOrganicFertilizable())
                  {
                     hasOrganicFertilizedCrops = true;
                  }
               }
            }
         }
         return result;
      }
      
      public function fertilize(forceFertilize:Boolean = false) : void
      {
         if(this.isFertilizable())
         {
            if(Global.worldManager.isVisiting())
            {
               if(Global.player.fertilizer == Global.player.totalFertilizer)
               {
                  TransactionManager.addTransaction(new TCompleteFertilize(),true);
               }
               this.m_fertilized = true;
               VisitorManager.getInstance().doAction(new FertNeighborAction(this));
               this.m_isJumbo = true;
               if(state == STATE_PLOWED)
               {
                  plantTime = Global.worldTime;
               }
               if(state == STATE_GROWN)
               {
                  this.setState(STATE_GROWN);
               }
               this.conditionallyAttachFertilizerOverlay();
               Global.worldManager.visitingNotification = "FriendVisit_fertilized";
               this.showTellFriendsDialog();
            }
            else if(forceFertilize)
            {
               this.m_fertilized = true;
               this.m_isJumbo = true;
               if(state == STATE_PLOWED)
               {
                  plantTime = Global.worldTime;
               }
               if(state == STATE_GROWN)
               {
                  this.setState(STATE_GROWN);
               }
               this.conditionallyAttachFertilizerOverlay();
               if(this.m_fertOverlay)
               {
                  this.m_fertOverlay.visible = true;
               }
               if(this.m_organicFertOverlay)
               {
                  this.m_organicFertOverlay.visible = true;
               }
            }
         }
      }
      
      protected function showTellFriendsDialog() : void
      {
         if(Global.player.fertilizer == 0 && !Global.player.hasSeenFertPopup)
         {
            Global.player.hasSeenFertPopup = true;
            FarmStatsManager.count("Fertilizer","friend_crowdsource","display");
            UI.displayMessage(ZLocUtils.t("FarmGame","FertilizeTellFriends"),GenericPopup.TYPE_SHARECANCEL,this.onTellFriends);
         }
      }
      
      public function initPlantTime(seedItem:SeedItem) : void
      {
         var daysToMilliseconds:Number = NaN;
         var currentWorldTime:Number = Global.worldTime;
         var harvestHelperMultiplier:Number = BHarvestHelper.getHarvestHelperMultiplier();
         var result:Number = 1;
         if(seedItem is HarvestableItem)
         {
            daysToMilliseconds = Global.farmGameSettingsManager.inGameDaySeconds * 1000;
            result = (seedItem as HarvestableItem).growTime * daysToMilliseconds;
         }
         var growTime:Number = result * Global.farmGameSettingsManager.growMultiplier;
         var aoeTime:Number = 1 / this.aoeharvestHelperMultiplier;
         var reducedGrowTime:Number = growTime * (1 - harvestHelperMultiplier * aoeTime);
         plantTime = currentWorldTime - reducedGrowTime;
      }
      
      protected function onTellFriends(event:GenericPopupEvent) : void
      {
         var images:Array = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("Fertilizer","friend_crowdsource","accept");
            StatsManager.experimentGoal("farmville_extra_fert_xp","friend_crowdsource",int(Global.player.level >= 10));
            images = [];
            images.push({
               "src":Global.getAssetURL("assets/newsfeed/fertilize_help02.png"),
               "href":"{SN_APP_URL}{creative:fertilize_help02}index.php?mission=fertilizer&friendId=" + Global.player.snUser.uid
            });
            GlobalEngine.socialNetwork.publishFeedStory("FertilizeTellFriends",{
               "images":images,
               "target":Global.missionHostFirstName,
               "first_name":Global.player.firstName
            },[],false);
         }
         else
         {
            FarmStatsManager.count("Fertilizer","friend_crowdsource","cancel");
         }
      }
      
      override public function getHarvestTime() : Number
      {
         return Global.farmGameSettingsManager.getNumber("harvestTime");
      }
      
      override public function isPixelInside(pixel:Point) : Boolean
      {
         var deltaY:Number = NaN;
         var result:Boolean = super.isPixelInside(pixel);
         if(result)
         {
            deltaY = m_displayObject.y + m_displayObject.height - pixel.y;
            if(deltaY > Constants.TILE_HEIGHT * m_size.y * 1.5)
            {
               result = false;
            }
         }
         return result;
      }
      
      override protected function getMaskDisplayObject() : DisplayObject
      {
         var terrainName:String = findTerrainName();
         if(!m_plotMaskDictionary.hasOwnProperty(terrainName))
         {
            m_plotMaskDictionary[terrainName] = new (this.getPrefixedItemImageForPlot(findTerrainName(),"plot_mask"))();
         }
         return m_plotMaskDictionary[terrainName];
      }
      
      override public function getItemFriendlyName() : String
      {
         var friendlyName:String = "";
         if(Boolean(m_item) && (this.isPlanted() || this.isHarvestable() || this.isWithered()))
         {
            friendlyName = m_item.friendlyName;
         }
         return friendlyName;
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
      }
      
      override public function canUpdateCursorOnVisit() : Boolean
      {
         return VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION) && (Plot.playerCanFertilize() || this.isPlowable() || this.isWithered());
      }
      
      override public function updateAnimation(delta:int) : void
      {
         super.updateAnimation(delta);
         if(this.m_fertOverlay is AnimationPlayer && Global.playOverlayEffects)
         {
            (this.m_fertOverlay as AnimationPlayer).update(delta);
         }
         if(this.m_organicFertOverlay is AnimationPlayer && Global.playOverlayEffects)
         {
            (this.m_organicFertOverlay as AnimationPlayer).update(delta);
         }
      }
      
      override public function getSupportedTerrainCodes() : Array
      {
         var terrainCodes:Array = null;
         switch(state)
         {
            case STATE_FALLOW:
            case STATE_PLOWED:
               terrainCodes = Global.farmGameSettingsManager.getTerrainCodes(FarmGameSettingsManager.TERRAIN_PLOWABLE);
               break;
            default:
               terrainCodes = super.getSupportedTerrainCodes();
         }
         return terrainCodes;
      }
      
      public function getIsNewPlot() : Boolean
      {
         return this.m_isNewPlot;
      }
   }
}

