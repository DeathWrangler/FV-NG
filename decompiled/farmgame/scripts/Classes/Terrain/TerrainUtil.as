package Classes.Terrain
{
   import Classes.InvisibleTerrain.InvisibleTerrainMap;
   import Classes.InvisibleTerrain.InvisibleTile;
   import Classes.ItemInstance;
   import Classes.UserDrivenTerrain.UDTMap;
   import Classes.UserDrivenTerrain.UDTTile;
   import Engine.Helpers.Vector3;
   import Engine.Interfaces.ITerrainMap;
   
   public class TerrainUtil
   {
      
      public static const TERRAIN_SCALE_FACTOR:int = 2;
      
      public static const DEFAULT_TERRAIN_CODE:int = 0;
      
      public static const LAND_TERRAIN_CODE:int = 1;
      
      private static const EXPERIMENT_FLASH_DEV_TERRAIN_MAPPING_CREATION_TOOL:String = "fv_dev_terrain_mapping_creation_tool";
      
      public function TerrainUtil()
      {
         super();
      }
      
      public static function isDevTerrainMappingCreationToolAvailable() : Boolean
      {
         return Config.DEBUG_MODE && (0 < Global.experimentManager.getExperimentVariant(EXPERIMENT_FLASH_DEV_TERRAIN_MAPPING_CREATION_TOOL) || GlobalEngine.getFlashVar(EXPERIMENT_FLASH_DEV_TERRAIN_MAPPING_CREATION_TOOL) > 0);
      }
      
      public static function getTerrainCodesInArea(startX:int, startY:int, endX:int, endY:int) : Array
      {
         var j:int = 0;
         var terrainCode:int = 0;
         if(startX < 0)
         {
            startX = 0;
         }
         if(startY < 0)
         {
            startY = 0;
         }
         if(endX > Global.world.getGridWidth())
         {
            endX = Global.world.getGridWidth();
         }
         if(endY > Global.world.getGridHeight())
         {
            endY = Global.world.getGridHeight();
         }
         var result:Array = new Array();
         var scaleX:int = Global.world.getGridWidth() / Global.world.terrainMap.width;
         var scaleY:int = Global.world.getGridHeight() / Global.world.terrainMap.height;
         startX /= scaleX;
         startY /= scaleY;
         endX = Math.ceil(endX / scaleX);
         endY = Math.ceil(endY / scaleY);
         for(var i:int = startX; i < endX; i++)
         {
            for(j = startY; j < endY; j++)
            {
               terrainCode = getTerrainCode(i,j);
               if(result.indexOf(terrainCode) == -1)
               {
                  result.push(terrainCode);
               }
            }
         }
         return result;
      }
      
      public static function getTerrainCode(tileX:int, tileY:int) : int
      {
         var terrainMap:ITerrainMap = Global.world.terrainMap;
         var terrainCode:int = TerrainUtil.DEFAULT_TERRAIN_CODE;
         if(terrainMap is InvisibleTerrainMap)
         {
            terrainCode = (terrainMap.tileAt(tileX,tileY) as InvisibleTile).terrainCode;
         }
         else if(terrainMap is UDTMap)
         {
            terrainCode = (terrainMap.tileAt(tileX,tileY) as UDTTile).code;
         }
         return terrainCode;
      }
      
      public static function isAreaAcceptable(arrAcceptableTerrainCodes:Array, startX:int, startY:int, endX:int, endY:int) : Boolean
      {
         var terrainCode:int = 0;
         var bAcceptable:Boolean = true;
         var arrTerrainCodes:Array = TerrainUtil.getTerrainCodesInArea(startX,startY,endX,endY);
         for each(terrainCode in arrTerrainCodes)
         {
            if(arrAcceptableTerrainCodes.indexOf(terrainCode) < 0)
            {
               bAcceptable = false;
               break;
            }
         }
         return bAcceptable;
      }
      
      public static function intersectTerrainCodeArrays(arrTerrainCodeA:Array, arrTerrainCodeB:Array) : Boolean
      {
         var terrainCode:int = 0;
         var bResult:Boolean = false;
         if(Boolean(arrTerrainCodeA) && Boolean(arrTerrainCodeB))
         {
            for each(terrainCode in arrTerrainCodeA)
            {
               if(arrTerrainCodeB.indexOf(terrainCode) >= 0)
               {
                  bResult = true;
                  break;
               }
            }
         }
         return bResult;
      }
      
      public static function getTerrainCodesForItemInstance(itemInstance:ItemInstance) : Array
      {
         var vPos:Vector3 = itemInstance.getPositionNoClone();
         var vSize:Vector3 = itemInstance.getSizeNoClone();
         return getTerrainCodesInArea(vPos.x,vPos.y,vPos.x + vSize.x,vPos.y + vSize.y);
      }
      
      public static function isItemInstanceOnAcceptableTerrain(itemInstance:ItemInstance, arrAcceptableTerrainCodes:Array) : Boolean
      {
         var vPos:Vector3 = null;
         var vSize:Vector3 = null;
         var bAcceptable:Boolean = false;
         if(arrAcceptableTerrainCodes != null)
         {
            vPos = itemInstance.getPositionNoClone();
            vSize = itemInstance.getSizeNoClone();
            if(TerrainUtil.isAreaAcceptable(arrAcceptableTerrainCodes,vPos.x,vPos.y,vPos.x + vSize.x,vPos.y + vSize.y))
            {
               bAcceptable = true;
            }
         }
         else
         {
            bAcceptable = true;
         }
         return bAcceptable;
      }
   }
}

