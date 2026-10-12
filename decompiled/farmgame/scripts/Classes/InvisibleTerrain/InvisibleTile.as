package Classes.InvisibleTerrain
{
   import Classes.Terrain.InvisibleTerrainPaletteEntry;
   import Engine.Classes.Tile;
   import flash.display.BitmapData;
   
   public class InvisibleTile extends Tile
   {
      
      private var m_terrainCode:int = -1;
      
      private var m_pathable:Boolean = true;
      
      private var m_terrainName:String = null;
      
      private var m_palette:InvisibleTerrainPaletteEntry = null;
      
      public function InvisibleTile(a_code:int, a_name:String, a_pathable:Boolean)
      {
         super();
         this.m_terrainCode = a_code;
         this.m_pathable = a_pathable;
         this.m_terrainName = a_name;
         if(Config.DEBUG_MODE)
         {
            this.m_palette = InvisibleTerrainPaletteEntry.getInvisiblePaletteEntry(a_code);
         }
      }
      
      public function get terrainCode() : int
      {
         return this.m_terrainCode;
      }
      
      public function get terrainName() : String
      {
         return this.m_terrainName;
      }
      
      public function get pathable() : Boolean
      {
         return this.m_pathable;
      }
      
      public function getDebugBitmapData() : BitmapData
      {
         var result:BitmapData = null;
         if(this.m_palette != null)
         {
            result = this.m_palette.getBitmapData();
         }
         return result;
      }
   }
}

