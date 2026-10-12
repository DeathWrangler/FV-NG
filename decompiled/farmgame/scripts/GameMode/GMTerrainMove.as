package GameMode
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.EmbeddedArt;
   import Classes.FarmGameObject;
   import Classes.Terrain.TerrainUtil;
   import Classes.UserDrivenTerrain.UDTMap;
   import Engine.Constants;
   import Managers.ClickTrackingManager;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMTerrainMove extends GMTerrainDefault
   {
      
      private var m_dragStartPos:Point;
      
      protected var m_selectedObject:FarmGameObject = null;
      
      public function GMTerrainMove()
      {
         super();
         m_cursorImage = EmbeddedArt.cursor_hand_open;
      }
      
      override protected function getHighlightColor() : int
      {
         var highlightedPointType:int = 0;
         var color:int = int(Constants.COLOR_NOT_VALID_PLACEMENT);
         if(m_highlightedPoint)
         {
            highlightedPointType = (Global.world.terrainMap as UDTMap).getDataPointCode(m_highlightedPoint.x / 2,m_highlightedPoint.y / 2);
            if(highlightedPointType != int(TerrainUtil.DEFAULT_TERRAIN_CODE))
            {
               color = int(Constants.COLOR_VALID_PLACEMENT);
            }
         }
         return color;
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         return true;
      }
      
      override public function onMouseDown(event:MouseEvent) : Boolean
      {
         super.onMouseDown(event);
         m_viewDragStartPos = GlobalEngine.viewport.getScrollPosition().clone();
         m_dragging = false;
         return true;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         if(m_dragging == false)
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_PLACE_ITEM);
            this.handleObjectDrop(event);
         }
         m_dragging = false;
         m_viewDragStartPos = null;
         super.onMouseUp(event);
         return true;
      }
      
      protected function handleObjectDrop(event:MouseEvent) : void
      {
      }
   }
}

