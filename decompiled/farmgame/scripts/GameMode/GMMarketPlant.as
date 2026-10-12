package GameMode
{
   import AvatarMode.AMPlant;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.Plot;
   import Classes.Terrain.TerrainUtil;
   import Classes.WorldObjectTypes;
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.LoadingManager;
   import Managers.ClickTrackingManager;
   import Managers.ToolModeManager;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMMarketPlant extends GMDefault
   {
      
      private var m_seedType:String;
      
      private var m_highlightedPoint:Point;
      
      protected var m_plot:Plot;
      
      protected var m_cursorLoader:Loader;
      
      private var m_seedItem:FarmItem;
      
      public function GMMarketPlant(seedType:String)
      {
         var iconUrl:String = null;
         if(Global.world.getTopGameMode() is GMObjectMove)
         {
            Global.world.popGameMode();
         }
         super();
         this.m_seedItem = Global.farmGameSettingsManager.getFarmItemByName(seedType);
         this.m_seedType = seedType;
         if(this.m_seedItem)
         {
            if(this.m_seedItem.isToolGenerated)
            {
               iconUrl = ToolModeManager.getSandboxIconUrlFromShortUrl(this.m_seedItem.getImageByName("icon",false));
            }
            else
            {
               iconUrl = this.m_seedItem.getImageByName("icon");
            }
            this.m_cursorLoader = LoadingManager.load(iconUrl,this.onCursorLoaded,LoadingManager.PRIORITY_HIGH);
         }
         UI.showBushelReportWindow(seedType);
      }
      
      override protected function isObjectSelectable(object:WorldObject) : Boolean
      {
         var result:Boolean = false;
         var plot:Plot = object as Plot;
         if(Boolean(plot) && Boolean(plot.isPlantable()) && (!this.m_seedItem || TerrainUtil.isItemInstanceOnAcceptableTerrain(plot,this.m_seedItem.getTerrainCodes())))
         {
            result = true;
         }
         return result;
      }
      
      override protected function updateCursor() : void
      {
         if(Boolean(m_cursorImage) && m_cursorId <= 0)
         {
            m_cursorId = UI.setCursor(m_cursorImage,true,shouldScaleCursor());
         }
      }
      
      protected function onCursorLoaded(event:Event) : void
      {
         if(m_enabled)
         {
            m_cursorImage = this.m_cursorLoader.content;
            m_cursorId = UI.setCursor(this.m_cursorLoader.content,true,shouldScaleCursor());
         }
      }
      
      override protected function getSelectableTypes() : int
      {
         return WorldObjectTypes.PLOT;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var avatar:FarmAvatar = Global.selectedAvatar;
         if(this.canPlant() && m_dragging == false)
         {
            if(m_highlightedObject)
            {
               this.m_plot = m_highlightedObject as Plot;
            }
            if(Boolean(avatar) && Boolean(this.m_plot) && Boolean(this.m_seedType))
            {
               avatar.getStateMachine().addState(new AMPlant(avatar,this.m_plot,this.m_seedType),true);
               event.stopPropagation();
            }
         }
         else if(Boolean(m_dragging == false) && Boolean(this.m_plot) && this.m_plot.getId() == 0)
         {
            this.m_plot.showObjectBusy();
         }
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_PLANT);
      }
      
      private function canPlant() : Boolean
      {
         var plot:Plot = null;
         var result:Boolean = false;
         if(m_highlightedObject)
         {
            plot = m_highlightedObject as Plot;
            if(plot)
            {
               result = plot.isPlantable();
            }
         }
         return result;
      }
      
      public function get seedType() : String
      {
         return this.m_seedType;
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
      }
   }
}

