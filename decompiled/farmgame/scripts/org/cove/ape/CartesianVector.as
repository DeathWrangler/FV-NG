package org.cove.ape
{
   public class CartesianVector
   {
      
      public var x:Number;
      
      public var y:Number;
      
      public function CartesianVector(px:Number = 0, py:Number = 0)
      {
         super();
         this.x = px;
         this.y = py;
      }
      
      public function setTo(px:Number, py:Number) : void
      {
         this.x = px;
         this.y = py;
      }
      
      public function copy(v:CartesianVector) : void
      {
         this.x = v.x;
         this.y = v.y;
      }
      
      public function dot(v:CartesianVector) : Number
      {
         return this.x * v.x + this.y * v.y;
      }
      
      public function cross(v:CartesianVector) : Number
      {
         return this.x * v.y - this.y * v.x;
      }
      
      public function plus(v:CartesianVector) : CartesianVector
      {
         return new CartesianVector(this.x + v.x,this.y + v.y);
      }
      
      public function plusEquals(v:CartesianVector) : CartesianVector
      {
         this.x += v.x;
         this.y += v.y;
         return this;
      }
      
      public function minus(v:CartesianVector) : CartesianVector
      {
         return new CartesianVector(this.x - v.x,this.y - v.y);
      }
      
      public function minusEquals(v:CartesianVector) : CartesianVector
      {
         this.x -= v.x;
         this.y -= v.y;
         return this;
      }
      
      public function mult(s:Number) : CartesianVector
      {
         return new CartesianVector(this.x * s,this.y * s);
      }
      
      public function multEquals(s:Number) : CartesianVector
      {
         this.x *= s;
         this.y *= s;
         return this;
      }
      
      public function times(v:CartesianVector) : CartesianVector
      {
         return new CartesianVector(this.x * v.x,this.y * v.y);
      }
      
      public function divEquals(s:Number) : CartesianVector
      {
         if(s == 0)
         {
            s = 0.0001;
         }
         this.x /= s;
         this.y /= s;
         return this;
      }
      
      public function magnitude() : Number
      {
         return Math.sqrt(this.x * this.x + this.y * this.y);
      }
      
      public function distance(v:CartesianVector) : Number
      {
         var delta:CartesianVector = this.minus(v);
         return delta.magnitude();
      }
      
      public function normalize() : CartesianVector
      {
         var m:Number = this.magnitude();
         if(m == 0)
         {
            m = 0.0001;
         }
         return this.mult(1 / m);
      }
      
      public function normalizeEquals() : CartesianVector
      {
         var m:Number = this.magnitude();
         if(m == 0)
         {
            m = 0.0001;
         }
         return this.multEquals(1 / m);
      }
      
      public function toString() : String
      {
         return this.x + " : " + this.y;
      }
   }
}

