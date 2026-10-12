package org.cove.ape
{
   public class VectorForce implements IForce
   {
      
      private var fvx:Number;
      
      private var fvy:Number;
      
      private var value:CartesianVector;
      
      private var scaleMass:Boolean;
      
      public function VectorForce(useMass:Boolean, vx:Number, vy:Number)
      {
         super();
         this.fvx = vx;
         this.fvy = vy;
         this.scaleMass = useMass;
         this.value = new CartesianVector(vx,vy);
      }
      
      public function set vx(x:Number) : void
      {
         this.fvx = x;
         this.value.x = x;
      }
      
      public function set vy(y:Number) : void
      {
         this.fvy = y;
         this.value.y = y;
      }
      
      public function set useMass(b:Boolean) : void
      {
         this.scaleMass = b;
      }
      
      public function getValue(invmass:Number) : CartesianVector
      {
         if(this.scaleMass)
         {
            this.value.setTo(this.fvx * invmass,this.fvy * invmass);
         }
         return this.value;
      }
   }
}

