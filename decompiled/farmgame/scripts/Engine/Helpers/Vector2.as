package Engine.Helpers
{
   import flash.geom.Point;
   
   public class Vector2 extends Point
   {
      
      public function Vector2(param1:Number = 0, param2:Number = 0)
      {
         super(param1,param2);
      }
      
      public static function lerp(param1:Vector2, param2:Vector2, param3:Number) : Vector2
      {
         var _loc4_:Vector2 = new Vector2();
         var _loc5_:Number = 1 - param3;
         _loc4_.x = param1.x * _loc5_ + param2.x * param3;
         _loc4_.y = param1.y * _loc5_ + param2.y * param3;
         return _loc4_;
      }
      
      public function cloneVec2() : Vector2
      {
         return new Vector2(x,y);
      }
   }
}

