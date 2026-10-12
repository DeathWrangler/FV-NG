package GameMode
{
   import AvatarMode.AMTractorPlow;
   import Classes.Avatar.FarmAvatar;
   import Classes.EmbeddedArt;
   import Classes.Plot;
   import Classes.Terrain.TerrainUtil;
   import Classes.Tractor;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.SoundManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   
   public class GMTractorPlow extends GMMultiPlotPlow
   {
      
      private static var m_soundAdded:Boolean = false;
      
      private static const TRACTOR_CURSOR_BASE_IMG:String = "cursor_tractor_";
      
      private static const TRACTOR_CURSOR_PPH_BASE_IMG:String = "cursor_plow_tractor_PPH_limit_";
      
      protected var m_equipment:Tractor = null;
      
      protected var m_hasWorldPlotLimits:Boolean = false;
      
      private var m_terrainName:String = null;
      
      private var m_terrainCode:int = 0;
      
      private var m_tractorCursorBaseImg:String = null;
      
      public function GMTractorPlow(tractor:Tractor = null, setCursor:Boolean = true)
      {
         super();
         if(!m_soundAdded)
         {
            SoundManager.addSound("tractorPlow",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_plow.mp3"),false);
            SoundManager.addSound("tractorStop",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_off.mp3"),false);
            m_soundAdded = true;
         }
         if(tractor == null)
         {
            tractor = Global.world.getEquipment(Tractor) as Tractor;
         }
         this.m_equipment = tractor;
         if(this.m_equipment)
         {
            m_actionSize = this.m_equipment.getActionSize();
            m_arrAcceptableTerrain = tractor.getSupportedTerrainCodes();
         }
         if(tractor.isHotrod)
         {
            SoundManager.playSound("hotrodTractorStart");
         }
         else
         {
            SoundManager.playSound("tractorStart");
         }
         SoundManager.playSound("tractorIdle",0,9999);
         if(setCursor)
         {
            this.initCursor();
         }
      }
      
      protected function initCursor() : void
      {
         var farmItem:FarmItem = null;
         var embeddedCursorName:String = null;
         var actionCursorImage:Object = null;
         var asset:MovieClip = null;
         var loader:Loader = null;
         if(Boolean(this.m_equipment) && Boolean(this.m_equipment.getItem()))
         {
            this.m_hasWorldPlotLimits = Global.worldManager.currentWorldHasPlotLimits;
            farmItem = this.m_equipment.getItem();
            this.m_tractorCursorBaseImg = this.m_hasWorldPlotLimits ? TRACTOR_CURSOR_PPH_BASE_IMG : TRACTOR_CURSOR_BASE_IMG;
            this.m_terrainName = FarmGameSettingsManager.TERRAIN_GROUND;
            this.m_terrainCode = TerrainUtil.DEFAULT_TERRAIN_CODE;
            embeddedCursorName = this.m_hasWorldPlotLimits ? "cursor_plow_tractor_PPH_limit_ground" : "cursor_tractor_ground";
            actionCursorImage = farmItem.getActionCursorImage(this.m_hasWorldPlotLimits);
            if(Boolean(actionCursorImage) && Boolean(actionCursorImage.symbol))
            {
               embeddedCursorName = actionCursorImage.symbol;
            }
            if(this.m_hasWorldPlotLimits)
            {
               asset = new EmbeddedArt[embeddedCursorName]() as MovieClip;
               loader = asset.getChildAt(0) as Loader;
               loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onCursorLoadedCallback);
            }
            else
            {
               m_cursorImage = new EmbeddedArt[embeddedCursorName]() as MovieClip;
            }
         }
      }
      
      private function onCursorLoadedCallback(event:Event) : void
      {
         var info:LoaderInfo = event.target as LoaderInfo;
         info.removeEventListener(Event.COMPLETE,this.onCursorLoadedCallback);
         m_cursorImage = info.loader.content as MovieClip;
         var terrain:int = this.changeCursor(this.m_terrainName) ? this.m_terrainCode : int(m_arrAcceptableTerrain[0]);
         m_cursorImage.cursor_mc.count_tf.text = Global.world.getNumPlots(terrain);
         m_cursorImage.cursor_mc.count2_tf.text = ZLocUtils.t("FarmGame","of") + " " + Global.worldManager.getMaximumPlotsAllowed(terrain);
         updateCursor();
      }
      
      override public function dispatchAddToStackEvent() : void
      {
         Global.world.dispatchEvent(new Event(EVENT_PPH_WARNING_TRACTOR));
      }
      
      override protected function shouldScaleCursor() : Boolean
      {
         return false;
      }
      
      override protected function getCurrentEquipmentEnergyCost() : Number
      {
         return this.m_equipment.getEnergyCost();
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         super.onMouseMove(event);
         if(this.changeCursor(this.m_terrainName))
         {
            this.setCursorIcons();
            updateOverlay();
         }
         return true;
      }
      
      private function changeCursor(terrainType:String) : Boolean
      {
         var cursorForTractor:Object = null;
         if(terrainType == null)
         {
            terrainType = FarmGameSettingsManager.TERRAIN_GROUND;
         }
         cursorForTractor = EmbeddedArt[this.m_tractorCursorBaseImg + terrainType + "_" + Global.worldManager.currentWorldType];
         return cursorForTractor == null ? false : true;
      }
      
      protected function getPrefixedItemImageForTractor(terrainName:String) : Object
      {
         var embeddedArtKey:String = this.m_tractorCursorBaseImg + terrainName;
         var imageForPlot:Object = null;
         imageForPlot = new EmbeddedArt[embeddedArtKey + "_" + Global.worldManager.currentWorldType]();
         if(imageForPlot == null)
         {
            imageForPlot = new EmbeddedArt[embeddedArtKey]();
         }
         return imageForPlot;
      }
      
      private function setCursorIcons() : void
      {
         var terrrainCode:int = 0;
         var terrainCodeArray:Array = this.getTerrainCodesHighlighted();
         if(terrainCodeArray.length > 0)
         {
            terrrainCode = Global.farmGameSettingsManager.selectPrimaryTerrainCodeFromGivenCodes(terrainCodeArray);
            this.m_terrainCode = terrrainCode;
         }
         else
         {
            this.m_terrainCode = TerrainUtil.DEFAULT_TERRAIN_CODE;
         }
         this.setTerrainCode(Global.worldManager.getLimitGroupNameByTerrainCode(this.m_terrainCode));
      }
      
      private function getTerrainCodesHighlighted() : Array
      {
         var point:Point = null;
         var tempArr:Array = null;
         var i:int = 0;
         var terrainCodeArray:Array = [];
         for(var plotIdx:int = 0; plotIdx < m_plots.length; plotIdx++)
         {
            if(m_plots[plotIdx].valid)
            {
               point = new Point(m_plots[plotIdx].point.x,m_plots[plotIdx].point.y);
               tempArr = TerrainUtil.getTerrainCodesInArea(m_plots[plotIdx].point.x,m_plots[plotIdx].point.y,m_plots[plotIdx].point.x + Plot.SIZE_X,m_plots[plotIdx].point.y + Plot.SIZE_Y);
               for(i = 0; i < tempArr.length; i++)
               {
                  if(terrainCodeArray.indexOf(tempArr[i]) == -1)
                  {
                     terrainCodeArray.push(tempArr[i]);
                  }
               }
            }
         }
         return terrainCodeArray;
      }
      
      private function getTerrainCodesHighlightedForThisPlot(plotIdx:int) : Array
      {
         var point:Point = null;
         var tempArr:Array = null;
         var i:int = 0;
         var terrainCodeArray:Array = [];
         if(m_plots[plotIdx].valid)
         {
            point = new Point(m_plots[plotIdx].point.x,m_plots[plotIdx].point.y);
            tempArr = TerrainUtil.getTerrainCodesInArea(m_plots[plotIdx].point.x,m_plots[plotIdx].point.y,m_plots[plotIdx].point.x + Plot.SIZE_X,m_plots[plotIdx].point.y + Plot.SIZE_Y);
            for(i = 0; i < tempArr.length; i++)
            {
               if(terrainCodeArray.indexOf(tempArr[i]) == -1)
               {
                  terrainCodeArray.push(tempArr[i]);
               }
            }
         }
         return terrainCodeArray;
      }
      
      override protected function checkPopPPHLimitReachedDialog() : void
      {
         var terrainCode:int = 0;
         var terrainCodeArray:Array = this.getTerrainCodesHighlighted();
         for each(terrainCode in terrainCodeArray)
         {
            if(Global.worldManager.getRemainingPlotsAllowed(terrainCode) == 0)
            {
               if(Global.worldManager.checkPPHLimitReached(terrainCode))
               {
                  break;
               }
            }
         }
      }
      
      private function setTerrainCode(terrainName:String) : void
      {
         var baseImg:Object = null;
         var asset:MovieClip = null;
         var loader:Loader = null;
         var info:LoaderInfo = null;
         if(m_cursorImage == null || this.m_terrainName != terrainName)
         {
            this.m_terrainName = terrainName;
            this.m_hasWorldPlotLimits = Global.worldManager.currentWorldHasPlotLimits;
            if(this.m_hasWorldPlotLimits)
            {
               baseImg = this.getPrefixedItemImageForTractor(terrainName);
               asset = baseImg as MovieClip;
               loader = asset.getChildAt(0) as Loader;
               info = loader.contentLoaderInfo;
               info.addEventListener(Event.COMPLETE,this.onCursorLoadedCallback);
               m_cursorImage = null;
            }
            else
            {
               m_cursorImage = new EmbeddedArt.cursor_plow() as MovieClip;
            }
         }
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var terrain:int = 0;
         super.handleClick(event);
         if(this.m_hasWorldPlotLimits)
         {
            terrain = this.changeCursor(this.m_terrainName) ? this.m_terrainCode : int(m_arrAcceptableTerrain[0]);
            m_cursorImage.cursor_mc.count_tf.text = Global.world.getNumPlots(terrain);
         }
      }
      
      override protected function incrementPlotCountArray(plotIdx:int) : void
      {
         var acceptableTerrains:Array = this.getTerrainCodesHighlightedForThisPlot(plotIdx);
         if(acceptableTerrains.length > 0)
         {
            Global.world.incrementPlotCountArray(acceptableTerrains);
         }
      }
      
      override protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
         var abcLimitGroupNames:String = Global.worldManager.convertTerrainCodesToABCStringOfLimitNames(m_arrAcceptableTerrain);
         FarmStatsManager.count("use_vehicle","use_tractor",(m_actionSize.x * m_actionSize.y).toString(),"",abcLimitGroupNames);
         avatar.getStateMachine().addState(new AMTractorPlow(avatar,plots,this.m_equipment as Tractor,centerPos),true);
      }
      
      override public function disableMode() : void
      {
         SoundManager.stopSound("tractorIdle");
         super.disableMode();
         SoundManager.playSound("tractorStop");
      }
      
      public function get tractor() : Tractor
      {
         return this.m_equipment;
      }
   }
}

