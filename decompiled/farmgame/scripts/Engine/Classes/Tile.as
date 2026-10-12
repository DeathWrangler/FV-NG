package Engine.Classes
{
   import Engine.Constants;
   import flash.display.BitmapData;
   
   public class Tile extends Asset
   {
      
      public function Tile()
      {
         super();
      }
      
      override public function getType() : String
      {
         return Constants.ASSET_TILE;
      }
      
      override public function getServiceName() : String
      {
         return "TileService";
      }
      
      public function getBitmapData() : BitmapData
      {
         return null;
      }
      
      public function get tileWidth() : Number
      {
         var _loc1_:Number = 0.5 / GlobalEngine.viewport.getZoom();
         return Constants.TILE_WIDTH + _loc1_;
      }
      
      public function get tileHeight() : Number
      {
         var _loc1_:Number = 0.5 / GlobalEngine.viewport.getZoom();
         return Constants.TILE_HEIGHT + _loc1_ * 2;
      }
   }
}

