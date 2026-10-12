package GameMode
{
   import Classes.EmbeddedArt;
   import Classes.Terrain.TerrainUtil;
   import Classes.UserDrivenTerrain.TerrainActionConstants;
   import Display.UI;
   import Managers.UDTManager;
   import flash.events.MouseEvent;
   
   public class GMTerrainClear extends GMTerrainDefault
   {
      
      public function GMTerrainClear()
      {
         super();
         m_cursorImage = EmbeddedArt.cursor_clear;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         UDTManager.udt.updateUDTMap(TerrainActionConstants.ACTION_CLEAR,event,TerrainUtil.DEFAULT_TERRAIN_CODE,m_highlightedObject == null);
         super.handleClick(event);
         UI.hideMenu();
      }
   }
}

