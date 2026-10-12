package org.cove.ape
{
   public class Composite extends AbstractCollection
   {
      
      private var delta:CartesianVector;
      
      public function Composite()
      {
         super();
         this.delta = new CartesianVector();
      }
      
      public function rotateByRadian(angleRadians:Number, center:CartesianVector) : void
      {
         var p:AbstractParticle = null;
         var radius:Number = NaN;
         var angle:Number = NaN;
         var pa:Array = particles;
         var len:int = int(pa.length);
         for(var i:int = 0; i < len; i++)
         {
            p = pa[i];
            radius = p.center.distance(center);
            angle = this.getRelativeAngle(center,p.center) + angleRadians;
            p.px = Math.cos(angle) * radius + center.x;
            p.py = Math.sin(angle) * radius + center.y;
         }
      }
      
      public function rotateByAngle(angleDegrees:Number, center:CartesianVector) : void
      {
         var angleRadians:Number = angleDegrees * MathUtil.PI_OVER_ONE_EIGHTY;
         this.rotateByRadian(angleRadians,center);
      }
      
      public function get fixed() : Boolean
      {
         for(var i:int = 0; i < particles.length; i++)
         {
            if(!particles[i].fixed)
            {
               return false;
            }
         }
         return true;
      }
      
      public function set fixed(b:Boolean) : void
      {
         for(var i:int = 0; i < particles.length; i++)
         {
            particles[i].fixed = b;
         }
      }
      
      private function getRelativeAngle(center:CartesianVector, p:CartesianVector) : Number
      {
         this.delta.setTo(p.x - center.x,p.y - center.y);
         return Math.atan2(this.delta.y,this.delta.x);
      }
   }
}

