package Classes.UserDrivenTerrain
{
   public class UDTDataPoint
   {
      
      public var code:int;
      
      public function UDTDataPoint()
      {
         super();
      }
      
      public function setCode(a_type:int) : void
      {
         this.code = a_type;
      }
      
      public function getPalette() : UDTPaletteEntry
      {
         return UDTConfig.getPaletteByType(this.code);
      }
      
      public function getHeight() : int
      {
         return this.getPalette().height;
      }
   }
}

