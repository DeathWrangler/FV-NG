package zasp.Display
{
   import flash.display.Shape;
   
   public class ColorPoly extends Shape
   {
      
      private var vecX:Array = new Array();
      
      private var vecY:Array = new Array();
      
      public function ColorPoly()
      {
         super();
      }
      
      public function addPt(param1:Number, param2:Number) : void
      {
         this.vecX.push(param1);
         this.vecY.push(param2);
      }
      
      public function changeColor(param1:int) : void
      {
         if(0 == this.vecX.length || 0 == this.vecY.length)
         {
            return;
         }
         graphics.clear();
         graphics.lineStyle(1,param1);
         graphics.beginFill(param1);
         graphics.moveTo(this.vecX[0],this.vecY[0]);
         var _loc2_:int = 1;
         while(_loc2_ < this.vecX.length)
         {
            graphics.lineTo(this.vecX[_loc2_],this.vecY[_loc2_]);
            _loc2_++;
         }
         graphics.endFill();
      }
   }
}

