package Engine.Interfaces
{
   import Engine.Classes.Tile;
   
   public interface ITerrainMap
   {
      
      function get width() : uint;
      
      function get height() : uint;
      
      function tileAt(param1:uint, param2:uint) : Tile;
      
      function setTile(param1:uint, param2:uint, param3:Tile) : void;
      
      function isPathable(param1:uint, param2:uint) : Boolean;
   }
}

