package org.cove.ape
{
   internal final class CollisionDetector
   {
      
      private static var cpa:AbstractParticle;
      
      private static var cpb:AbstractParticle;
      
      private static var collNormal:CartesianVector;
      
      private static var collDepth:Number;
      
      public function CollisionDetector()
      {
         super();
      }
      
      internal static function test(objA:AbstractParticle, objB:AbstractParticle) : void
      {
         if(objA.fixed && objB.fixed)
         {
            return;
         }
         if(objA.multisample == 0 && objB.multisample == 0)
         {
            normVsNorm(objA,objB);
         }
         else if(objA.multisample > 0 && objB.multisample == 0)
         {
            sampVsNorm(objA,objB);
         }
         else if(objB.multisample > 0 && objA.multisample == 0)
         {
            sampVsNorm(objB,objA);
         }
         else if(objA.multisample == objB.multisample)
         {
            sampVsSamp(objA,objB);
         }
         else
         {
            normVsNorm(objA,objB);
         }
      }
      
      private static function normVsNorm(objA:AbstractParticle, objB:AbstractParticle) : Boolean
      {
         objA.samp.copy(objA.curr);
         objB.samp.copy(objB.curr);
         if(testTypes(objA,objB))
         {
            CollisionResolver.resolve(cpa,cpb,collNormal,collDepth);
            return true;
         }
         return false;
      }
      
      private static function sampVsNorm(objA:AbstractParticle, objB:AbstractParticle) : void
      {
         if(normVsNorm(objA,objB))
         {
            return;
         }
         var s:Number = 1 / (objA.multisample + 1);
         var t:Number = s;
         for(var i:int = 0; i <= objA.multisample; i++)
         {
            objA.samp.setTo(objA.prev.x + t * (objA.curr.x - objA.prev.x),objA.prev.y + t * (objA.curr.y - objA.prev.y));
            if(testTypes(objA,objB))
            {
               CollisionResolver.resolve(cpa,cpb,collNormal,collDepth);
               return;
            }
            t += s;
         }
      }
      
      private static function sampVsSamp(objA:AbstractParticle, objB:AbstractParticle) : void
      {
         if(normVsNorm(objA,objB))
         {
            return;
         }
         var s:Number = 1 / (objA.multisample + 1);
         var t:Number = s;
         for(var i:int = 0; i <= objA.multisample; i++)
         {
            objA.samp.setTo(objA.prev.x + t * (objA.curr.x - objA.prev.x),objA.prev.y + t * (objA.curr.y - objA.prev.y));
            objB.samp.setTo(objB.prev.x + t * (objB.curr.x - objB.prev.x),objB.prev.y + t * (objB.curr.y - objB.prev.y));
            if(testTypes(objA,objB))
            {
               CollisionResolver.resolve(cpa,cpb,collNormal,collDepth);
               return;
            }
            t += s;
         }
      }
      
      private static function testTypes(objA:AbstractParticle, objB:AbstractParticle) : Boolean
      {
         if(objA is RectangleParticle && objB is RectangleParticle)
         {
            return testOBBvsOBB(objA as RectangleParticle,objB as RectangleParticle);
         }
         if(objA is CircleParticle && objB is CircleParticle)
         {
            return testCirclevsCircle(objA as CircleParticle,objB as CircleParticle);
         }
         if(objA is RectangleParticle && objB is CircleParticle)
         {
            return testOBBvsCircle(objA as RectangleParticle,objB as CircleParticle);
         }
         if(objA is CircleParticle && objB is RectangleParticle)
         {
            return testOBBvsCircle(objB as RectangleParticle,objA as CircleParticle);
         }
         return false;
      }
      
      private static function testOBBvsOBB(ra:RectangleParticle, rb:RectangleParticle) : Boolean
      {
         var axisA:CartesianVector = null;
         var depthA:Number = NaN;
         var axisB:CartesianVector = null;
         var depthB:Number = NaN;
         var absA:Number = NaN;
         var absB:Number = NaN;
         var altb:Boolean = false;
         collDepth = Number.POSITIVE_INFINITY;
         for(var i:int = 0; i < 2; i++)
         {
            axisA = ra.axes[i];
            depthA = testIntervals(ra.getProjection(axisA),rb.getProjection(axisA));
            if(depthA == 0)
            {
               return false;
            }
            axisB = rb.axes[i];
            depthB = testIntervals(ra.getProjection(axisB),rb.getProjection(axisB));
            if(depthB == 0)
            {
               return false;
            }
            absA = Math.abs(depthA);
            absB = Math.abs(depthB);
            if(absA < Math.abs(collDepth) || absB < Math.abs(collDepth))
            {
               altb = absA < absB;
               collNormal = altb ? axisA : axisB;
               collDepth = altb ? depthA : depthB;
            }
         }
         cpa = ra;
         cpb = rb;
         return true;
      }
      
      private static function testOBBvsCircle(ra:RectangleParticle, ca:CircleParticle) : Boolean
      {
         var boxAxis:CartesianVector = null;
         var depth:Number = NaN;
         var vertex:CartesianVector = null;
         var mag:Number = NaN;
         collDepth = Number.POSITIVE_INFINITY;
         var depths:Array = new Array(2);
         for(var i:int = 0; i < 2; i++)
         {
            boxAxis = ra.axes[i];
            depth = testIntervals(ra.getProjection(boxAxis),ca.getProjection(boxAxis));
            if(depth == 0)
            {
               return false;
            }
            if(Math.abs(depth) < Math.abs(collDepth))
            {
               collNormal = boxAxis;
               collDepth = depth;
            }
            depths[i] = depth;
         }
         var r:Number = ca.radius;
         if(Math.abs(depths[0]) < r && Math.abs(depths[1]) < r)
         {
            vertex = closestVertexOnOBB(ca.samp,ra);
            collNormal = vertex.minus(ca.samp);
            mag = collNormal.magnitude();
            collDepth = r - mag;
            if(collDepth <= 0)
            {
               return false;
            }
            collNormal.divEquals(mag);
         }
         cpa = ra;
         cpb = ca;
         return true;
      }
      
      private static function testCirclevsCircle(ca:CircleParticle, cb:CircleParticle) : Boolean
      {
         var depthX:Number = testIntervals(ca.getIntervalX(),cb.getIntervalX());
         if(depthX == 0)
         {
            return false;
         }
         var depthY:Number = testIntervals(ca.getIntervalY(),cb.getIntervalY());
         if(depthY == 0)
         {
            return false;
         }
         collNormal = ca.samp.minus(cb.samp);
         var mag:Number = collNormal.magnitude();
         collDepth = ca.radius + cb.radius - mag;
         if(collDepth > 0)
         {
            collNormal.divEquals(mag);
            cpa = ca;
            cpb = cb;
            return true;
         }
         return false;
      }
      
      private static function testIntervals(intervalA:Interval, intervalB:Interval) : Number
      {
         if(intervalA.max < intervalB.min)
         {
            return 0;
         }
         if(intervalB.max < intervalA.min)
         {
            return 0;
         }
         var lenA:Number = intervalB.max - intervalA.min;
         var lenB:Number = intervalB.min - intervalA.max;
         return Math.abs(lenA) < Math.abs(lenB) ? lenA : lenB;
      }
      
      private static function closestVertexOnOBB(p:CartesianVector, r:RectangleParticle) : CartesianVector
      {
         var dist:Number = NaN;
         var d:CartesianVector = p.minus(r.samp);
         var q:CartesianVector = new CartesianVector(r.samp.x,r.samp.y);
         for(var i:int = 0; i < 2; i++)
         {
            dist = d.dot(r.axes[i]);
            if(dist >= 0)
            {
               dist = Number(r.extents[i]);
            }
            else if(dist < 0)
            {
               dist = -r.extents[i];
            }
            q.plusEquals(r.axes[i].mult(dist));
         }
         return q;
      }
   }
}

