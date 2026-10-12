package Classes.UserDrivenTerrain
{
   public class TerrainPlaceActionData
   {
      
      public var m_x:int = 0;
      
      public var m_y:int = 0;
      
      public var m_code:int = 0;
      
      public function TerrainPlaceActionData(x:int, y:int, code:int)
      {
         super();
         this.m_x = x;
         this.m_y = y;
         this.m_code = code;
      }
      
      public function get x() : int
      {
         return this.m_x;
      }
      
      public function get y() : int
      {
         return this.m_y;
      }
      
      public function get code() : int
      {
         return this.m_code;
      }
   }
}

