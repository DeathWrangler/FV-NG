package GameMode
{
   import Classes.FarmGameWorld;
   import Classes.MapResource;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Helpers.IntVector2;
   import Engine.Helpers.Vector3;
   import Engine.Utilities;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMMultiResourceAction extends GMDefault
   {
      
      protected static const TILE_OUTLINE_WIDTH:int = 4;
      
      public static const DEFAULT_ACTION_X:int = 2;
      
      public static const DEFAULT_ACTION_Y:int = 2;
      
      public static const DEFAULT_RESOURCE_X:int = 4;
      
      public static const DEFAULT_RESOURCE_Y:int = 4;
      
      protected var m_actionSize:IntVector2 = new IntVector2(DEFAULT_ACTION_X,DEFAULT_ACTION_Y);
      
      protected var m_resourceSize:IntVector2 = new IntVector2(DEFAULT_RESOURCE_X,DEFAULT_RESOURCE_Y);
      
      protected var m_highlightedPoint:Point;
      
      protected var m_resourceData:Array = [];
      
      protected var m_dirty:Boolean = true;
      
      protected var m_fuelOverride:Boolean = false;
      
      public function GMMultiResourceAction()
      {
         super();
      }
      
      override protected function getSelectableTypes() : int
      {
         return Constants.WORLDOBJECT_ALL;
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
            this.deselectResources();
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
            this.m_highlightedPoint.x = Math.floor(Utilities.clamp(this.m_highlightedPoint.x,0,Global.world.getGridWidth() - this.m_actionSize.x * this.m_resourceSize.x));
            this.m_highlightedPoint.y = Math.floor(Utilities.clamp(this.m_highlightedPoint.y,0,Global.world.getGridHeight() - this.m_actionSize.y * this.m_resourceSize.y));
            this.reselectResources();
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
            startPoint.x = startPoint.x - dragSize.x + this.m_resourceSize.x;
         }
         if(diff.y < 0)
         {
            startPoint.y = startPoint.y - dragSize.y + this.m_resourceSize.y;
         }
         return startPoint;
      }
      
      protected function getTileDragSize() : Point
      {
         var size:Point = new Point();
         size.x = (size.x + 1) * this.m_resourceSize.x;
         size.y = (size.y + 1) * this.m_resourceSize.y;
         return size;
      }
      
      protected function getActionPoints() : Array
      {
         var y:int = 0;
         var newPoint:Point = null;
         var result:Array = [];
         var origin:Point = new Point(this.m_highlightedPoint.x,this.m_highlightedPoint.y);
         for(var x:int = 0; x < this.m_actionSize.x; x++)
         {
            for(y = 0; y < this.m_actionSize.y; y++)
            {
               newPoint = new Point(origin.x + this.m_resourceSize.x * x,origin.y + this.m_resourceSize.y * y);
               result.push(newPoint);
            }
         }
         return result;
      }
      
      protected function deselectResources() : void
      {
         var i:int = 0;
         var resource:MapResource = null;
         if(this.m_resourceData.length > 0)
         {
            for(i = 0; i < this.m_resourceData.length; i++)
            {
               resource = this.m_resourceData[i].object as MapResource;
               if(resource)
               {
                  resource.setHighlighted(false);
                  resource.setToolTip(null);
               }
            }
            this.m_dirty = true;
         }
      }
      
      protected function reselectResources() : void
      {
         var i:int = 0;
         var resource:MapResource = null;
         var newResources:Array = this.getValidResources();
         if(newResources != this.m_resourceData)
         {
            this.deselectResources();
            this.m_resourceData = newResources;
            for(i = 0; i < this.m_resourceData.length; i++)
            {
               resource = this.m_resourceData[i].object as MapResource;
               if(resource)
               {
                  resource.setHighlighted(true);
               }
            }
            this.m_dirty = true;
         }
      }
      
      protected function isSelectable(resource:MapResource) : Boolean
      {
         return false;
      }
      
      protected function getValidResources() : Array
      {
         var point:Point = null;
         var colliders:Array = null;
         var object:Object = null;
         var valid:Boolean = false;
         var endX:int = 0;
         var endY:int = 0;
         var curTerrainCode:int = 0;
         var curTerrainCodeKey:String = null;
         var i:int = 0;
         var resource:MapResource = null;
         var position:Vector3 = null;
         var result:Array = [];
         var actionPoints:Array = this.getActionPoints();
         if(actionPoints.length > 0)
         {
            for each(point in actionPoints)
            {
               colliders = [];
               object = null;
               valid = false;
               endX = point.x + this.m_resourceSize.x;
               endY = point.y + this.m_resourceSize.y;
               if(Global.world.checkCollision(point.x,point.y,endX,endY,[],colliders,Constants.WORLDOBJECT_ALL_EXCEPT_AVATAR,null,true))
               {
                  for(i = 0; i < colliders.length; i++)
                  {
                     resource = colliders[i] as MapResource;
                     if(resource)
                     {
                        position = resource.getPosition();
                        if(position.x == point.x && position.y == point.y && this.isSelectable(resource))
                        {
                           object = resource;
                           valid = true;
                           break;
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
         }
         return result;
      }
      
      override protected function updateOverlay() : void
      {
         var i:int = 0;
         var color:uint = 0;
         var alpha:Number = NaN;
         var startPoint:Point = null;
         var tileSize:Point = null;
         if(this.m_dirty)
         {
            m_displayObject.graphics.clear();
            if(this.m_highlightedPoint)
            {
               for(i = 0; i < this.m_resourceData.length; i++)
               {
                  if(this.m_resourceData[i].valid)
                  {
                     color = Constants.COLOR_VALID_PLACEMENT;
                     alpha = Constants.ALPHA_VALID_PLACEMENT;
                  }
                  else
                  {
                     color = Constants.COLOR_NOT_VALID_PLACEMENT;
                     alpha = Constants.ALPHA_NOT_VALID_PLACEMENT;
                  }
                  startPoint = this.m_resourceData[i].point;
                  tileSize = this.getTileDragSize();
                  m_displayObject.graphics.lineStyle(TILE_OUTLINE_WIDTH,color,1);
                  m_displayObject.graphics.beginFill(color,0.5);
                  FarmGameWorld.drawTileArea(m_displayObject.graphics,startPoint,tileSize.x,tileSize.y);
                  m_displayObject.graphics.endFill();
               }
            }
            this.m_dirty = false;
         }
      }
      
      protected function isMouseOverValidPlot() : Boolean
      {
         var i:int = 0;
         var resource:MapResource = null;
         var position:Vector3 = null;
         var result:Boolean = false;
         var colliders:Array = [];
         if(Global.world.checkCollision(this.m_highlightedPoint.x,this.m_highlightedPoint.y,this.m_highlightedPoint.x + this.m_resourceSize.x,this.m_highlightedPoint.y + this.m_resourceSize.y,[],colliders,Constants.WORLDOBJECT_ALL_EXCEPT_AVATAR,null,true))
         {
            for(i = 0; i < colliders.length; i++)
            {
               resource = colliders[i] as MapResource;
               if(resource)
               {
                  position = resource.getPosition();
                  if(position.x == this.m_highlightedPoint.x && position.y == this.m_highlightedPoint.y)
                  {
                     if(this.isSelectable(resource))
                     {
                        result = true;
                        break;
                     }
                  }
               }
            }
         }
         return result;
      }
   }
}

