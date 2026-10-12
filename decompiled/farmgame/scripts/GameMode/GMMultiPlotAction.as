package GameMode
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.FarmGameWorld;
   import Classes.Idle.PromoIdleTask;
   import Classes.Plot;
   import Classes.Terrain.TerrainUtil;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Classes.util.CurrencyConversionUtil;
   import Display.TurboPPHDialog;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Helpers.IntVector2;
   import Engine.Helpers.Vector3;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Managers.TurboPPHManager;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMMultiPlotAction extends GMDefault
   {
      
      protected static const TILE_OUTLINE_WIDTH:int = 4;
      
      protected var m_actionSize:IntVector2 = new IntVector2(2,1);
      
      protected var m_highlightedPoint:Point;
      
      protected var m_plots:Array = [];
      
      protected var m_dirty:Boolean = true;
      
      protected var m_fuelOverride:Boolean = false;
      
      protected var m_seedOverride:Boolean = false;
      
      protected var m_arrAcceptableTerrain:Array = null;
      
      public function GMMultiPlotAction()
      {
         super();
      }
      
      override protected function getSelectableTypes() : int
      {
         return WorldObjectTypes.PLOT;
      }
      
      override protected function getCursor() : Object
      {
         return m_cursorImage;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         super.onMouseMove(event);
         if(!m_dragging)
         {
            this.pickHighlightedPoint();
         }
         else
         {
            this.deselectPlots();
            this.m_highlightedPoint = null;
         }
         this.updateOverlay();
         return true;
      }
      
      override protected function pickObject(stagePosition:Point, event:MouseEvent, forceRepick:Boolean = false) : void
      {
         super.pickObject(m_mouseMovePosition,m_mouseMoveEvent,forceRepick);
         this.pickHighlightedPoint();
         this.updateOverlay();
      }
      
      protected function pickHighlightedPoint() : void
      {
         var highlightedObjectPosition:Vector3 = null;
         var newPoint:Point = getMouseTilePos();
         if(m_highlightedObject)
         {
            highlightedObjectPosition = m_highlightedObject.getPosition();
            newPoint.x = highlightedObjectPosition.x;
            newPoint.y = highlightedObjectPosition.y;
         }
         if(!this.m_highlightedPoint || !newPoint.equals(this.m_highlightedPoint))
         {
            this.m_highlightedPoint = newPoint;
            if(this.isInTurboMode())
            {
               this.m_highlightedPoint.x = Utilities.clamp(this.m_highlightedPoint.x,0,Global.world.getGridWidth());
               this.m_highlightedPoint.y = Utilities.clamp(this.m_highlightedPoint.y,0,Global.world.getGridHeight());
            }
            else
            {
               this.m_highlightedPoint.x = Math.floor(Utilities.clamp(this.m_highlightedPoint.x,0,Global.world.getGridWidth() - this.m_actionSize.x * Plot.SIZE_X));
               this.m_highlightedPoint.y = Math.floor(Utilities.clamp(this.m_highlightedPoint.y,0,Global.world.getGridHeight() - this.m_actionSize.y * Plot.SIZE_Y));
            }
            this.reselectPlots();
         }
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         if(object != m_highlightedObject)
         {
            m_highlightedObject = object;
         }
      }
      
      override protected function deselectObject() : void
      {
         if(m_highlightedObject)
         {
            m_highlightedObject = null;
         }
      }
      
      protected function performResourceCheck() : Boolean
      {
         return true;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         super.onMouseUp(event);
         this.deselectObject();
         return true;
      }
      
      protected function getTileSquareStart() : Point
      {
         var startPoint:Point = this.m_highlightedPoint.clone();
         var dragSize:Point = this.getTileDragSize();
         var diff:Point = this.m_highlightedPoint.subtract(startPoint);
         if(diff.x < 0)
         {
            startPoint.x = startPoint.x - dragSize.x + Plot.SIZE_X;
         }
         if(diff.y < 0)
         {
            startPoint.y = startPoint.y - dragSize.y + Plot.SIZE_Y;
         }
         return startPoint;
      }
      
      protected function getTileDragSize() : Point
      {
         var size:Point = new Point();
         size.x = (size.x + 1) * Plot.SIZE_X;
         size.y = (size.y + 1) * Plot.SIZE_Y;
         return size;
      }
      
      protected function canPlow() : Boolean
      {
         var result:Boolean = false;
         for(var plotIdx:int = 0; plotIdx > this.m_plots.length; plotIdx++)
         {
            if(this.m_plots[plotIdx].valid)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      protected function getPlowPoints() : Array
      {
         var y:int = 0;
         var newPoint:Point = null;
         var result:Array = [];
         var basePoint:Point = new Point(this.m_highlightedPoint.x,this.m_highlightedPoint.y);
         for(var x:int = 0; x < this.m_actionSize.x; x++)
         {
            for(y = 0; y < this.m_actionSize.y; y++)
            {
               newPoint = new Point(basePoint.x + x * Plot.SIZE_X,basePoint.y + y * Plot.SIZE_Y);
               result.push(newPoint);
            }
         }
         return result;
      }
      
      protected function deselectPlots() : void
      {
         var plot:Plot = null;
         for(var plotIdx:int = 0; plotIdx < this.m_plots.length; plotIdx++)
         {
            plot = this.m_plots[plotIdx].object as Plot;
            if(plot)
            {
               plot.setHighlighted(false);
               plot.setToolTip(null);
            }
         }
         this.m_dirty = true;
      }
      
      protected function reselectPlots() : void
      {
         var plotIdx:int = 0;
         var plot:Plot = null;
         var oldplots:Array = this.m_plots;
         var newplots:Array = this.getValidPlots();
         if(oldplots != newplots)
         {
            this.m_dirty = true;
            this.deselectPlots();
            this.m_plots = newplots;
            for(plotIdx = 0; plotIdx < this.m_plots.length; plotIdx++)
            {
               plot = this.m_plots[plotIdx].object as Plot;
               if(plot)
               {
                  plot.setHighlighted(true,this.getValidOutlineColor());
               }
            }
         }
      }
      
      protected function isSelectable(plot:Plot) : Boolean
      {
         return false;
      }
      
      protected function isPlotOnAcceptableTerrain(plot:Plot) : Boolean
      {
         return TerrainUtil.isItemInstanceOnAcceptableTerrain(plot,this.m_arrAcceptableTerrain);
      }
      
      protected function getValidPlots() : Array
      {
         var acceptableTerrainCode:int = 0;
         var pointIdx:int = 0;
         var point:Point = null;
         var colliders:Array = null;
         var object:Object = null;
         var valid:Boolean = false;
         var bNewPlot:Boolean = false;
         var endX:int = 0;
         var endY:int = 0;
         var curTerrainCode:int = 0;
         var curTerrainCodeKey:String = null;
         var colliderIdx:int = 0;
         var plot:Plot = null;
         var arrTerrain:Array = null;
         var result:Array = [];
         var plowPoints:Array = this.getPlowPoints();
         var arrCurPlotIncrementTerrain:Array = new Array();
         var arrPlotAllowed:Array = new Array();
         var arrNewPlotCount:Array = new Array();
         for each(acceptableTerrainCode in this.m_arrAcceptableTerrain)
         {
            arrPlotAllowed[int(acceptableTerrainCode)] = Global.worldManager.getRemainingPlotsAllowed(acceptableTerrainCode);
            arrNewPlotCount[int(acceptableTerrainCode)] = 0;
         }
         for(pointIdx = 0; pointIdx < plowPoints.length; pointIdx++)
         {
            point = plowPoints[pointIdx] as Point;
            colliders = [];
            object = null;
            valid = false;
            bNewPlot = false;
            endX = point.x + Plot.SIZE_X;
            endY = point.y + Plot.SIZE_Y;
            if(Global.world.checkCollision(point.x,point.y,endX,endY,[],colliders,Constants.WORLDOBJECT_ALL_EXCEPT_AVATAR,null,true))
            {
               for(colliderIdx = 0; colliderIdx < colliders.length; colliderIdx++)
               {
                  plot = colliders[colliderIdx] as Plot;
                  if(Boolean(plot && plot.getPosition().x == point.x) && Boolean(plot.getPosition().y == point.y) && this.isSelectable(plot))
                  {
                     object = plot;
                     valid = true;
                     break;
                  }
               }
            }
            else
            {
               valid = this.isSelectable(null);
               if(valid)
               {
                  bNewPlot = true;
               }
            }
            if(valid && this.m_arrAcceptableTerrain != null)
            {
               for(curTerrainCodeKey in arrCurPlotIncrementTerrain)
               {
                  arrCurPlotIncrementTerrain[int(curTerrainCodeKey)] = false;
               }
               arrTerrain = TerrainUtil.getTerrainCodesInArea(point.x,point.y,endX,endY);
               for each(curTerrainCode in arrTerrain)
               {
                  if(this.m_arrAcceptableTerrain.indexOf(curTerrainCode) < 0)
                  {
                     valid = false;
                     break;
                  }
                  arrCurPlotIncrementTerrain[int(curTerrainCode)] = true;
               }
            }
            if(valid && bNewPlot)
            {
               for(curTerrainCodeKey in arrCurPlotIncrementTerrain)
               {
                  if(arrCurPlotIncrementTerrain[int(curTerrainCodeKey)] == true)
                  {
                     if(!arrPlotAllowed.hasOwnProperty(curTerrainCodeKey) || arrNewPlotCount[int(curTerrainCodeKey)] >= arrPlotAllowed[int(curTerrainCodeKey)])
                     {
                        valid = false;
                     }
                     else
                     {
                        ++arrNewPlotCount[int(curTerrainCodeKey)];
                     }
                  }
               }
            }
            result.push({
               "point":point,
               "object":object,
               "valid":valid
            });
         }
         return result;
      }
      
      override protected function updateOverlay() : void
      {
         var pointIdx:int = 0;
         var color:uint = 0;
         var alpha:Number = NaN;
         var startPoint:Point = null;
         var tileSize:Point = null;
         if(this.m_dirty)
         {
            m_displayObject.graphics.clear();
         }
         if(this.m_dirty && Boolean(this.m_highlightedPoint))
         {
            this.m_dirty = false;
            for(pointIdx = 0; pointIdx < this.m_plots.length; pointIdx++)
            {
               if(this.m_plots[pointIdx].valid)
               {
                  color = Constants.COLOR_VALID_PLACEMENT;
                  alpha = Constants.ALPHA_VALID_PLACEMENT;
               }
               else
               {
                  color = Constants.COLOR_NOT_VALID_PLACEMENT;
                  alpha = Constants.ALPHA_NOT_VALID_PLACEMENT;
               }
               startPoint = this.m_plots[pointIdx].point;
               tileSize = this.getTileDragSize();
               m_displayObject.graphics.lineStyle(TILE_OUTLINE_WIDTH,color,1);
               m_displayObject.graphics.beginFill(color,0.5);
               FarmGameWorld.drawTileArea(m_displayObject.graphics,startPoint,tileSize.x,tileSize.y);
               m_displayObject.graphics.endFill();
            }
         }
      }
      
      protected function getValidOutlineColor() : uint
      {
         return Constants.COLOR_HIGHLIGHT;
      }
      
      private function isSuperAvatarMode() : Boolean
      {
         return this is GMSuperAvatarPlow || this is GMSuperAvatarPlant || this is GMSuperAvatarHarvest;
      }
      
      private function isInTurboMode() : Boolean
      {
         var topMode:GameMode = Global.world.getTopGameMode();
         var result:Boolean = false;
         if(topMode is GMTractorPlowAll)
         {
            result = true;
         }
         else if(topMode is GMSeederAll)
         {
            result = true;
         }
         else if(topMode is GMHarvesterAll)
         {
            result = true;
         }
         else if(topMode is GMCombineAll)
         {
            result = true;
         }
         return result;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         if(!this.isSuperAvatarMode() && !this.isPlotRemover())
         {
            TurboPPHManager.getInstance().onMultiPlotEnabled();
         }
      }
      
      protected function isPlotRemover() : Boolean
      {
         return false;
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
         if(!this.isSuperAvatarMode() && this.shouldShowTurbo() && !this.isPlotRemover())
         {
            TurboPPHManager.getInstance().onMultiPlotDisabled();
         }
      }
      
      protected function shouldShowTurbo() : Boolean
      {
         return true;
      }
      
      protected function isMouseOverValidPlot() : Boolean
      {
         var colliderIdx:int = 0;
         var plot:Plot = null;
         var result:Boolean = false;
         var colliders:Array = [];
         var object:Object = null;
         if(Global.world.checkCollision(this.m_highlightedPoint.x,this.m_highlightedPoint.y,this.m_highlightedPoint.x + Plot.SIZE_X,this.m_highlightedPoint.y + Plot.SIZE_Y,[],colliders,Constants.WORLDOBJECT_ALL_EXCEPT_AVATAR,null,true))
         {
            for(colliderIdx = 0; colliderIdx < colliders.length; colliderIdx++)
            {
               plot = colliders[colliderIdx] as Plot;
               if(Boolean(plot && plot.getPosition().x == this.m_highlightedPoint.x) && Boolean(plot.getPosition().y == this.m_highlightedPoint.y) && this.isSelectable(plot))
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      protected function outOfTurbosDialogHandler(result:int) : void
      {
         switch(result)
         {
            case TurboPPHDialog.RESULT_CANCEL:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outofchargers","button_cancel");
               this.deselectPlots();
               TurboPPHManager.getInstance().disableTurboMode();
               break;
            case TurboPPHDialog.RESULT_OK:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outofchargers","button_buy");
               UI.displayMarketDialog("actionMenuSeeder","aide",null,"fuel");
         }
      }
      
      protected function outOfFuelDialogHandler(result:int) : void
      {
         switch(result)
         {
            case TurboPPHDialog.RESULT_CANCEL:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outoffuel","button_stop");
               UI.removeAllCursors();
               Global.world.popGameMode();
               Global.world.addGameMode(new GMDefault());
               break;
            case TurboPPHDialog.RESULT_OK:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outoffuel","button_fewerplots");
               this.m_fuelOverride = true;
               handleClick(null);
         }
      }
      
      protected function outOfSeedsDialogHandler(result:int) : void
      {
         switch(result)
         {
            case TurboPPHDialog.RESULT_CANCEL:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outofseeds","button_selectdifferent");
               UI.removeAllCursors();
               Global.world.popGameMode();
               Global.world.addGameMode(new GMDefault());
               UI.displayMarketDialog("actionMenuSeeder","seed",UI.MARKET_LAUNCH_REFERENCE_COMBINE,"seeds");
               break;
            case TurboPPHDialog.RESULT_OK:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outofseeds","button_continue");
               this.m_seedOverride = true;
               handleClick(null);
         }
      }
      
      protected function outOfCoinsDialogHandler(result:int) : void
      {
         switch(result)
         {
            case TurboPPHDialog.RESULT_CANCEL:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outofcoins","button_cancel");
               UI.removeAllCursors();
               Global.world.popGameMode();
               Global.world.addGameMode(new GMDefault());
               break;
            case TurboPPHDialog.RESULT_OK:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outofcoins","button_buy");
               PromoIdleTask.navigateToMoneyPage();
         }
      }
      
      protected function outOfWorldCurrencyHandler(result:int) : void
      {
         var currencyExchangeItems:Array = null;
         var currencyExchangeItem:FarmItem = null;
         var currencyExchangeItemsLength:int = 0;
         var miniMarketItems:Array = null;
         var currencyUnit:String = Global.worldManager.getCurrencyForWorld(Global.worldManager.currentWorldType);
         switch(result)
         {
            case TurboPPHDialog.RESULT_CANCEL:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outof" + currencyUnit,"button_cancel");
               UI.removeAllCursors();
               this.deselectPlots();
               Global.world.popGameMode();
               Global.world.addGameMode(new GMDefault());
               break;
            case TurboPPHDialog.RESULT_OK:
               FarmStatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,"turbopph_outof" + currencyUnit,"button_buy");
               currencyExchangeItems = Global.farmGameSettingsManager.getFarmItemsArrayByType("aide","othercurrency_exchange");
               currencyExchangeItem = null;
               currencyExchangeItemsLength = int(currencyExchangeItems.length);
               miniMarketItems = [];
               for each(currencyExchangeItem in currencyExchangeItems)
               {
                  if(null != currencyExchangeItem && CurrencyConversionUtil.isCurrencyExchangeItem(currencyExchangeItem.name))
                  {
                     if(CurrencyConversionUtil.isValidCurrencyExchangeItem(currencyExchangeItem.name,Global.worldManager.currentWorldCurrency))
                     {
                        miniMarketItems.push(currencyExchangeItem.name);
                     }
                  }
               }
               if(miniMarketItems.length > 0)
               {
                  UI.displayMiniMarketDialog(miniMarketItems);
               }
         }
      }
   }
}

