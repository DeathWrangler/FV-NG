package Classes.UserDrivenTerrain
{
   public class TerrainMoveActionData
   {
      
      public var m_x1:int = 0;
      
      public var m_y1:int = 0;
      
      public var m_x2:int = 0;
      
      public var m_y2:int = 0;
      
      public function TerrainMoveActionData(x1:int, y1:int, x2:int, y2:int)
      {
         super();
         this.m_x1 = x1;
         this.m_y1 = y1;
         this.m_x2 = x2;
         this.m_y2 = y2;
      }
      
      public function get x1() : int
      {
         return this.m_x1;
      }
      
      public function get y1() : int
      {
         return this.m_y1;
      }
      
      public function get x2() : int
      {
         return this.m_x2;
      }
      
      public function get y2() : int
      {
         return this.m_y2;
      }
   }
}

