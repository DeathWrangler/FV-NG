package Display
{
   import Engine.Classes.Viewport;
   import Engine.Helpers.Vector2;
   import Engine.Interfaces.ITerrainMap;
   import flash.display.BitmapData;
   
   public interface FarmTerrainMap extends ITerrainMap
   {
      
      function renderFast(param1:BitmapData) : void;
      
      function renderSlow(param1:Viewport, param2:int, param3:int, param4:int, param5:int) : void;
      
      function isDirty() : Boolean;
      
      function setDirty(param1:Boolean) : void;
      
      function setTileType(param1:String, param2:Boolean = false) : void;
      
      function setOriginPosition(param1:Vector2) : void;
   }
}

