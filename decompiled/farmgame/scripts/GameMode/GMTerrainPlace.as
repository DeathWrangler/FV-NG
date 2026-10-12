package GameMode
{
   import Classes.Terrain.TerrainUtil;
   import Classes.UserDrivenTerrain.TerrainActionConstants;
   import Classes.UserDrivenTerrain.UDTConfig;
   import Display.UI;
   import Engine.Constants;
   import Managers.UDTManager;
   import flash.events.MouseEvent;
   
   public class GMTerrainPlace extends GMTerrainDefault
   {
      
      protected var m_terrainCode:int;
      
      public function GMTerrainPlace()
      {
         super();
      }
      
      public function setTerrainCode(terrainCode:int) : void
      {
         this.m_terrainCode = terrainCode;
      }
      
      override public function disableMode() : void
      {
         UDTManager.udt.clearLastDataPoint();
         super.disableMode();
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         UDTManager.udt.multiUpdateUDTMap(TerrainActionConstants.ACTION_PLACE,event,this.m_terrainCode);
         super.handleClick(event);
         UI.hideMenu();
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         return super.onMouseMove(event);
      }
      
      override protected function updateHighlightPoint(event:MouseEvent) : void
      {
         super.updateHighlightPoint(event);
         m_positionValid = true;
      }
      
      override protected function getHighlightColor() : int
      {
         var lastDataPointType:int = 0;
         var color:int = int(Constants.COLOR_VALID_PLACEMENT);
         if(m_positionValid)
         {
            lastDataPointType = UDTManager.udt.getLastDataPointCode();
            if(this.m_terrainCode == lastDataPointType)
            {
               color = int(Constants.COLOR_NOT_VALID_PLACEMENT);
               m_toolTip.toolTip = "Can\'t Place Here";
               m_showToolTip = true;
            }
            else if(lastDataPointType != int(TerrainUtil.DEFAULT_TERRAIN_CODE))
            {
               color = int(Constants.COLOR_OVERLAP);
               m_toolTip.toolTip = "Replacing " + UDTConfig.getConfigObject(lastDataPointType).name;
               m_showToolTip = true;
            }
            else
            {
               m_toolTip.toolTip = "Valid";
               m_showToolTip = true;
            }
         }
         return color;
      }
   }
}

