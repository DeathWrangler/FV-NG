package GameMode
{
   import Classes.FarmGameWorld;
   import Classes.Terrain.TerrainUtil;
   import Classes.UserDrivenTerrain.TerrainActionConstants;
   import Classes.UserDrivenTerrain.UDTConfig;
   import Classes.UserDrivenTerrain.UDTMap;
   import Display.ContextMenuItem;
   import Display.ToolTip;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Constants;
   import Engine.Utilities;
   import Managers.UDTManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMTerrainDefault extends GMDefault
   {
      
      protected static const MENU_MOVE:String = "movet";
      
      protected static const MENU_DELETE:String = "delete";
      
      protected static const MENU_EXIT:String = "exit";
      
      protected var m_positionValid:Boolean = false;
      
      protected var m_highlightedPoint:Point;
      
      public var m_toolTip:ToolTip = new ToolTip();
      
      private var m_toolTipShowing:Boolean = false;
      
      public var m_showToolTip:Boolean = false;
      
      private var m_menuItems:Array = [];
      
      private var m_contextMenuMouseEvent:MouseEvent;
      
      public function GMTerrainDefault()
      {
         this.m_menuItems.push({
            "label":"Move",
            "action":MENU_MOVE
         });
         this.m_menuItems.push({
            "label":"Delete",
            "action":MENU_DELETE
         });
         this.m_menuItems.push({
            "label":"Exit Terrain Editor",
            "action":MENU_EXIT
         });
         this.m_contextMenuMouseEvent = null;
         super();
      }
      
      protected function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         UI.hideMenu();
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MENU_DELETE:
                  if(this.m_contextMenuMouseEvent != null)
                  {
                     UDTManager.udt.updateUDTMap(TerrainActionConstants.ACTION_CLEAR,this.m_contextMenuMouseEvent,UDTConfig.getDefaultTerrainCode(),m_highlightedObject == null);
                  }
                  break;
               case MENU_MOVE:
                  break;
               case MENU_EXIT:
                  UI.terrainEditorWindow.closeWindow(new Event(Event.CLOSE));
            }
         }
      }
      
      override protected function setMoveToPosition(position:Point) : void
      {
      }
      
      override protected function getCursor() : Object
      {
         return m_cursorImage;
      }
      
      override public function enableMode() : void
      {
         UI.displayTerrainEditorWindow();
         UDTManager.enableTransparencyMap();
         super.enableMode();
      }
      
      override public function disableMode() : void
      {
         UDTManager.disableTransparencyMap();
         super.disableMode();
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         if(Boolean(this.m_highlightedPoint) && this.m_positionValid)
         {
            UI.displayMenu(this.m_menuItems,this.onMenuClick);
            this.m_contextMenuMouseEvent = event;
         }
         else
         {
            UI.hideMenu();
            this.m_contextMenuMouseEvent = null;
         }
         this.updateHighlightPoint(event);
         super.handleClick(event);
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         this.updateHighlightPoint(event);
         this.updateOverlay();
         this.updateToolTip();
         return super.onMouseMove(event);
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         return false;
      }
      
      protected function updateHighlightPoint(event:MouseEvent) : void
      {
         var highlightedPointCode:int = 0;
         this.m_highlightedPoint = getMouseTilePos(event);
         this.m_highlightedPoint.x = Math.floor(this.m_highlightedPoint.x / 2) * 2;
         this.m_highlightedPoint.y = Math.floor(this.m_highlightedPoint.y / 2) * 2;
         this.m_highlightedPoint.x = Utilities.clamp(this.m_highlightedPoint.x,0,Global.world.getGridWidth() - 2);
         this.m_highlightedPoint.y = Utilities.clamp(this.m_highlightedPoint.y,0,Global.world.getGridHeight() - 2);
         this.m_positionValid = true;
         if(this.m_highlightedPoint)
         {
            highlightedPointCode = (Global.world.terrainMap as UDTMap).getDataPointCode(this.m_highlightedPoint.x / 2,this.m_highlightedPoint.y / 2);
            if(highlightedPointCode == int(TerrainUtil.DEFAULT_TERRAIN_CODE))
            {
               this.m_positionValid = false;
            }
         }
      }
      
      override protected function updateOverlay() : void
      {
         var color:int = 0;
         var size:Number = NaN;
         m_displayObject.graphics.clear();
         if(Boolean(this.m_highlightedPoint) && this.m_positionValid)
         {
            color = this.getHighlightColor();
            m_displayObject.graphics.lineStyle(TILE_OUTLINE_WIDTH,color,Constants.ALPHA_VALID_PLACEMENT);
            m_displayObject.graphics.beginFill(0,0);
            size = UDTManager.setSizeAccordingToZoom();
            FarmGameWorld.drawTileArea(m_displayObject.graphics,this.m_highlightedPoint,size * 2,size * 2);
            m_displayObject.graphics.endFill();
         }
      }
      
      protected function updateToolTip() : void
      {
         if(Boolean(this.m_highlightedPoint) && Boolean(this.m_positionValid) && this.m_showToolTip)
         {
            if(!this.m_toolTipShowing)
            {
               this.m_toolTip.show();
               this.m_toolTipShowing = true;
               this.m_showToolTip = false;
            }
            else
            {
               this.m_toolTip.updatePosition();
            }
         }
         else if(this.m_toolTipShowing)
         {
            this.m_toolTip.hide();
            this.m_toolTipShowing = false;
            this.m_toolTip.toolTip = "";
         }
      }
      
      protected function getHighlightColor() : int
      {
         return Constants.COLOR_NOT_VALID_PLACEMENT;
      }
   }
}

