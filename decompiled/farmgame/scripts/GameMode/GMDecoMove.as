package GameMode
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.EmbeddedArt;
   import Classes.FarmGameObject;
   import Classes.FarmGameWorld;
   import Classes.Plot;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Utilities;
   import Managers.ClickTrackingManager;
   import Managers.FarmStatsManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMDecoMove extends GMDefault
   {
      
      protected static const TILE_OUTLINE_WIDTH:int = 4;
      
      private var m_maxPlowSize:Number = 1;
      
      private var m_highlightedPoint:Point;
      
      private var m_dragStartPos:Point;
      
      protected var m_plot:Plot;
      
      private var m_currentGM:GMObjectMove;
      
      private var m_rotateContainer:Sprite;
      
      private var m_rotateBtn:DisplayObject;
      
      public function GMDecoMove()
      {
         super();
         m_cursorImage = EmbeddedArt.cursor_hand_open;
      }
      
      override protected function getCursor() : Object
      {
         return m_cursorImage;
      }
      
      override public function onMouseDown(event:MouseEvent) : Boolean
      {
         super.onMouseDown(event);
         this.m_dragStartPos = getMouseTilePos();
         this.m_dragStartPos.x = Utilities.clamp(this.m_dragStartPos.x,0,Global.world.getGridWidth() - Plot.SIZE_X);
         this.m_dragStartPos.y = Utilities.clamp(this.m_dragStartPos.y,0,Global.world.getGridHeight() - Plot.SIZE_Y);
         this.m_dragStartPos.x = Math.floor(this.m_dragStartPos.x);
         this.m_dragStartPos.y = Math.floor(this.m_dragStartPos.y);
         return true;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         super.onMouseUp(event);
         this.m_dragStartPos = null;
         return true;
      }
      
      override protected function selectObject(object:WorldObject, event:MouseEvent = null) : void
      {
         var farmObj:FarmGameObject = null;
         if(object != m_highlightedObject)
         {
            farmObj = object as FarmGameObject;
            if(Boolean(farmObj) && !farmObj.isMovable())
            {
               object = null;
            }
         }
         if(object is Plot && (object as Plot).getIsNewPlot())
         {
            object = null;
         }
         super.selectObject(object,event);
      }
      
      override protected function deselectObject() : void
      {
         if(m_highlightedObject)
         {
            m_highlightedObject.onMouseOut();
            m_highlightedObject = null;
         }
         updateCursor();
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_MOVE_ITEM);
         var moveObject:FarmGameObject = m_highlightedObject as FarmGameObject;
         if(moveObject)
         {
            if(moveObject.isDecoMoveSupported())
            {
               FarmStatsManager.count("movetool","movetool_pickup");
               this.m_currentGM = new GMObjectMove(moveObject,null,false,false,true);
               Global.world.addGameMode(this.m_currentGM,true);
            }
            else
            {
               moveObject.handleDecoMoveUnsupported();
            }
         }
      }
      
      protected function getTileSquareStart() : Point
      {
         var startPoint:Point = this.m_highlightedPoint.clone();
         if(this.m_dragStartPos)
         {
            startPoint = this.m_dragStartPos.clone();
         }
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
         var startPoint:Point = this.m_highlightedPoint.clone();
         if(this.m_dragStartPos)
         {
            startPoint = this.m_dragStartPos.clone();
         }
         var size:Point = new Point();
         var diff:Point = this.m_highlightedPoint.subtract(startPoint);
         diff.x /= Plot.SIZE_X;
         if(diff.x < 0)
         {
            size.x = Math.ceil(-diff.x);
         }
         else
         {
            size.x = Math.floor(diff.x);
         }
         diff.y /= Plot.SIZE_Y;
         if(diff.y < 0)
         {
            size.y = Math.ceil(-diff.y);
         }
         else
         {
            size.y = Math.floor(diff.y);
         }
         if(this.m_maxPlowSize == 1)
         {
            size.x = 0;
            size.y = 0;
         }
         size.x = (size.x + 1) * Plot.SIZE_X;
         size.y = (size.y + 1) * Plot.SIZE_Y;
         return size;
      }
      
      override protected function updateOverlay() : void
      {
         var color:uint = 0;
         var alpha:Number = NaN;
         var startPoint:Point = null;
         var tileSize:Point = null;
         m_displayObject.graphics.clear();
         if(this.m_highlightedPoint)
         {
            color = Constants.COLOR_NOT_VALID_PLACEMENT;
            alpha = Constants.ALPHA_NOT_VALID_PLACEMENT;
            startPoint = this.getTileSquareStart();
            tileSize = this.getTileDragSize();
            m_displayObject.graphics.lineStyle(TILE_OUTLINE_WIDTH,color,1);
            m_displayObject.graphics.beginFill(color,0.5);
            FarmGameWorld.drawTileArea(m_displayObject.graphics,startPoint,tileSize.x,tileSize.y);
            m_displayObject.graphics.endFill();
         }
      }
   }
}

