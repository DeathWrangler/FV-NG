package fai
{
   public class Position
   {
      
      public var x:Number = 0;
      
      public var y:Number = 0;
      
      public function Position(param1:Number = 0, param2:Number = 0)
      {
         super();
         this.set(param1,param2);
      }
      
      public function set(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function deltaPosition(param1:Position) : Position
      {
         return new Position(this.x - param1.x,this.y - param1.y);
      }
      
      public function vectorLength() : Number
      {
         return Math.sqrt(this.x * this.x + this.y * this.y);
      }
      
      public function isequal(param1:Position) : Boolean
      {
         return this.x == param1.x && this.y == param1.y;
      }
      
      public function toString() : String
      {
         return "(" + this.x + ", " + this.y + ")";
      }
   }
}

