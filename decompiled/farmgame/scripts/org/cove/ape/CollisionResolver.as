package org.cove.ape
{
   internal final class CollisionResolver
   {
      
      public function CollisionResolver()
      {
         super();
      }
      
      internal static function resolve(pa:AbstractParticle, pb:AbstractParticle, normal:CartesianVector, depth:Number) : void
      {
         var mtd:CartesianVector = normal.mult(depth);
         var te:Number = pa.elasticity + pb.elasticity;
         var sumInvMass:Number = pa.invMass + pb.invMass;
         var tf:Number = MathUtil.clamp(1 - (pa.friction + pb.friction),0,1);
         var ca:Collision = pa.getComponents(normal);
         var cb:Collision = pb.getComponents(normal);
         var vnA:CartesianVector = cb.vn.mult((te + 1) * pa.invMass).plus(ca.vn.mult(pb.invMass - te * pa.invMass)).divEquals(sumInvMass);
         var vnB:CartesianVector = ca.vn.mult((te + 1) * pb.invMass).plus(cb.vn.mult(pa.invMass - te * pb.invMass)).divEquals(sumInvMass);
         ca.vt.multEquals(tf);
         cb.vt.multEquals(tf);
         var mtdA:CartesianVector = mtd.mult(pa.invMass / sumInvMass);
         var mtdB:CartesianVector = mtd.mult(-pb.invMass / sumInvMass);
         vnA.plusEquals(ca.vt);
         vnB.plusEquals(cb.vt);
         pa.resolveCollision(mtdA,vnA,normal,depth,-1,pb);
         pb.resolveCollision(mtdB,vnB,normal,depth,1,pa);
      }
   }
}

