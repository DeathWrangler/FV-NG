package Classes.UserDrivenTerrain
{
   import Classes.Terrain.Terrain;
   import Classes.Terrain.TerrainConfigManager;
   import Classes.Terrain.TerrainUtil;
   import flash.utils.Dictionary;
   
   public class UDTConfig
   {
      
      protected static var m_palettes:Dictionary;
      
      private static var defaultTerrainCode:int;
      
      public static const INVISIBLE_TERRAIN_CODE:int = 255;
      
      public static const TYPE_COUNT_WET_EDGES:int = 25;
      
      protected static var m_sortedPalettes:Array = [];
      
      private static var m_terrainsArray:Array = null;
      
      protected static var m_initialized:Boolean = false;
      
      public function UDTConfig()
      {
         super();
      }
      
      protected static function getTerrainCodeToObjects() : Object
      {
         return TerrainConfigManager.getInstance().getTerrainCodeToObjects();
      }
      
      public static function getConfigObject(code:int) : Terrain
      {
         return getTerrainCodeToObjects()[getRealCode(code)];
      }
      
      public static function getPaletteByType(code:int) : UDTPaletteEntry
      {
         if(!m_initialized)
         {
            m_palettes = new Dictionary();
            m_initialized = true;
         }
         code = getRealCode(code);
         if(m_palettes[code] == null)
         {
            insertPalette(code);
         }
         return m_palettes[code];
      }
      
      public static function getSortedPalettes() : Array
      {
         return m_sortedPalettes;
      }
      
      protected static function insertPalette(code:int) : void
      {
         code = getRealCode(code);
         var palette:UDTPaletteEntry = new UDTPaletteEntry(code);
         m_palettes[code] = palette;
         m_sortedPalettes.splice(binarySearch(palette),0,palette);
      }
      
      protected static function getRealCode(code:int) : int
      {
         if(TerrainUtil.DEFAULT_TERRAIN_CODE == code)
         {
            code = getDefaultTerrainCode();
         }
         return code;
      }
      
      protected static function binarySearch(palette:UDTPaletteEntry) : int
      {
         var midPalette:UDTPaletteEntry = null;
         var start:int = 0;
         var end:int = int(m_sortedPalettes.length);
         var mid:int = start + end >> 1;
         var compare:int = 0;
         while(start < end)
         {
            midPalette = m_sortedPalettes[mid] as UDTPaletteEntry;
            if(palette.height < midPalette.height)
            {
               end = mid;
               mid = start + end >> 1;
            }
            else
            {
               if(palette.height <= midPalette.height)
               {
                  break;
               }
               start = mid + 1;
               mid = start + end >> 1;
            }
         }
         return mid;
      }
      
      public static function getTerrains() : Array
      {
         var type:Terrain = null;
         if(m_terrainsArray == null)
         {
            m_terrainsArray = [];
            for each(type in getTerrainCodeToObjects())
            {
               if(Boolean(type.name) && Boolean(type.name != "default") && type.code != INVISIBLE_TERRAIN_CODE)
               {
                  m_terrainsArray.push(type);
               }
            }
         }
         return m_terrainsArray;
      }
      
      public static function getDefaultTerrainCode() : int
      {
         return defaultTerrainCode;
      }
      
      public static function setDefaultTerrainCode(a_terrainCode:int) : void
      {
         defaultTerrainCode = a_terrainCode;
      }
      
      public static function getDefaultTerrainName() : String
      {
         return TerrainConfigManager.getInstance().getNameFromCode(getDefaultTerrainCode());
      }
   }
}

