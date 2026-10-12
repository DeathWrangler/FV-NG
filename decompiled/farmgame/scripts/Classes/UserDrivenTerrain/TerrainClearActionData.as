package Classes.UserDrivenTerrain
{
   public class TerrainClearActionData
   {
      
      public var m_x:int = 0;
      
      public var m_y:int = 0;
      
      public function TerrainClearActionData(x:int, y:int)
      {
         super();
         this.m_x = x;
         this.m_y = y;
      }
      
      public function get x() : int
      {
         return this.m_x;
      }
      
      public function get y() : int
      {
         return this.m_y;
      }
   }
}

