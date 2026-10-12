package org.cove.ape
{
   internal final class Collision
   {
      
      internal var vn:CartesianVector;
      
      internal var vt:CartesianVector;
      
      public function Collision(vn:CartesianVector, vt:CartesianVector)
      {
         super();
         this.vn = vn;
         this.vt = vt;
      }
   }
}

