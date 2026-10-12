package Engine.Helpers
{
   public class Vector3
   {
      
      public var x:Number;
      
      public var y:Number;
      
      public var z:Number;
      
      public function Vector3(param1:Number = 0, param2:Number = 0, param3:Number = 0)
      {
         super();
         this.x = param1;
         this.y = param2;
         this.z = param3;
      }
      
      public static function lerp(param1:Vector3, param2:Vector3, param3:Number) : Vector3
      {
         var _loc4_:Vector3 = new Vector3();
         var _loc5_:Number = 1 - param3;
         _loc4_.x = param1.x * _loc5_ + param2.x * param3;
         _loc4_.y = param1.y * _loc5_ + param2.y * param3;
         _loc4_.z = param1.z * _loc5_ + param2.z * param3;
         return _loc4_;
      }
      
      public function clone() : Vector3
      {
         return new Vector3(this.x,this.y,this.z);
      }
      
      public function set(param1:Vector3) : void
      {
         this.x = param1.x;
         this.y = param1.y;
         this.z = param1.z;
      }
      
      public function toObject() : Object
      {
         return {
            "x":this.x,
            "y":this.y,
            "z":this.z
         };
      }
      
      public function add(param1:Vector3) : Vector3
      {
         return new Vector3(this.x + param1.x,this.y + param1.y,this.z + param1.z);
      }
      
      public function subtract(param1:Vector3) : Vector3
      {
         return new Vector3(this.x - param1.x,this.y - param1.y,this.z - param1.z);
      }
      
      public function scale(param1:Number) : Vector3
      {
         return new Vector3(this.x * param1,this.y * param1,this.z * param1);
      }
      
      public function equals(param1:Vector3) : Boolean
      {
         return this.x == param1.x && this.y == param1.y && this.z == param1.z;
      }
      
      public function toString() : String
      {
         return String("(x: " + this.x + ", y: " + this.y + ", z: " + this.z + ")");
      }
      
      public function toVector2() : Vector2
      {
         return new Vector2(this.x,this.y);
      }
      
      public function toIntVector2() : IntVector2
      {
         return new IntVector2(this.x,this.y);
      }
      
      public function isAxisAligned() : Boolean
      {
         return this.x == 0 && this.y == 0 || this.x == 0 && this.z == 0 || this.y == 0 && this.z == 0;
      }
      
      public function dot(param1:Vector3) : Number
      {
         return this.x * param1.x + this.y * param1.y + this.z * param1.z;
      }
      
      public function cross(param1:Vector3) : Vector3
      {
         return new Vector3(this.y * param1.z - this.z * param1.y,this.z * param1.x - this.x * param1.z,this.x * param1.y - this.y * param1.x);
      }
      
      public function length() : Number
      {
         return Math.sqrt(this.dot(this));
      }
      
      public function normalize() : Vector3
      {
         var _loc1_:Number = this.length();
         return new Vector3(this.x / _loc1_,this.y / _loc1_,this.z / _loc1_);
      }
      
      public function floor() : Vector3
      {
         return new Vector3(Math.floor(this.x),Math.floor(this.y),Math.floor(this.z));
      }
      
      public function ceil() : Vector3
      {
         return new Vector3(Math.ceil(this.x),Math.ceil(this.y),Math.ceil(this.z));
      }
   }
}

