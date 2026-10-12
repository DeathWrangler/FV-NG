package Engine.Helpers
{
   import flash.geom.Point;
   
   public class IntVector2
   {
      
      public var x:int;
      
      public var y:int;
      
      public function IntVector2(param1:int = 0, param2:int = 0)
      {
         super();
         this.x = param1;
         this.y = param2;
      }
      
      public function clone() : IntVector2
      {
         return new IntVector2(this.x,this.y);
      }
      
      public function add(param1:IntVector2) : IntVector2
      {
         return new IntVector2(this.x + param1.x,this.y + param1.y);
      }
      
      public function subtract(param1:IntVector2) : IntVector2
      {
         return new IntVector2(this.x - param1.x,this.y - param1.y);
      }
      
      public function equals(param1:IntVector2) : Boolean
      {
         return this.x == param1.x && this.y == param1.y;
      }
      
      public function toString() : String
      {
         return String("(x: " + this.x + ", y: " + this.y + ")");
      }
      
      public function toPoint() : Point
      {
         return new Point(this.x,this.y);
      }
   }
}

