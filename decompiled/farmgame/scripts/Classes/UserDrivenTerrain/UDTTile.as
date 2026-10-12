package Classes.UserDrivenTerrain
{
   import Engine.Classes.Tile;
   import flash.display.BitmapData;
   
   public class UDTTile extends Tile
   {
      
      protected static var m_globalZoomLevel:Number;
      
      public var parentPoint:UDTDataPoint;
      
      public var point1:UDTDataPoint;
      
      public var point2:UDTDataPoint;
      
      public var point3:UDTDataPoint;
      
      public var code:int = -1;
      
      public var neighborType1:int = -1;
      
      public var neighborType2:int = -1;
      
      public var neighborType3:int = -1;
      
      protected var m_randomKey:int = 0;
      
      public var heightRendered:Number = -1;
      
      public function UDTTile(a_dataPoint:UDTDataPoint, key:uint)
      {
         this.parentPoint = a_dataPoint;
         this.m_randomKey = key;
      }
      
      public static function set globalZoomLevel(level:Number) : void
      {
         m_globalZoomLevel = level;
      }
      
      public function getData(palette:UDTPaletteEntry) : BitmapData
      {
         var terrainCode:int = 0;
         if(palette == this.parentPoint.getPalette())
         {
            terrainCode = this.code;
         }
         else if(this.point1 != null && palette == this.point1.getPalette())
         {
            terrainCode = this.neighborType1;
         }
         else if(this.point2 != null && palette == this.point2.getPalette())
         {
            terrainCode = this.neighborType2;
         }
         else
         {
            terrainCode = 0;
         }
         return palette.getTileBitmapData(terrainCode,this.m_randomKey,m_globalZoomLevel);
      }
   }
}

