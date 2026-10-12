package org.cove.ape
{
   import flash.display.Sprite;
   
   internal class SpringConstraintParticle extends RectangleParticle
   {
      
      internal var parent:SpringConstraint;
      
      private var p1:AbstractParticle;
      
      private var p2:AbstractParticle;
      
      private var avgVelocity:CartesianVector;
      
      private var lambda:CartesianVector;
      
      private var scaleToLength:Boolean;
      
      private var rca:CartesianVector;
      
      private var rcb:CartesianVector;
      
      private var s:Number;
      
      private var _rectScale:Number;
      
      private var _rectHeight:Number;
      
      private var _fixedEndLimit:Number;
      
      public function SpringConstraintParticle(p1:AbstractParticle, p2:AbstractParticle, p:SpringConstraint, rectHeight:Number, rectScale:Number, scaleToLength:Boolean)
      {
         super(0,0,0,0,0,false);
         this.p1 = p1;
         this.p2 = p2;
         this.lambda = new CartesianVector(0,0);
         this.avgVelocity = new CartesianVector(0,0);
         this.parent = p;
         this.rectScale = rectScale;
         this.rectHeight = rectHeight;
         this.scaleToLength = scaleToLength;
         this.fixedEndLimit = 0;
         this.rca = new CartesianVector();
         this.rcb = new CartesianVector();
      }
      
      internal function set rectScale(s:Number) : void
      {
         this._rectScale = s;
      }
      
      internal function get rectScale() : Number
      {
         return this._rectScale;
      }
      
      internal function set rectHeight(r:Number) : void
      {
         this._rectHeight = r;
      }
      
      internal function get rectHeight() : Number
      {
         return this._rectHeight;
      }
      
      internal function set fixedEndLimit(f:Number) : void
      {
         this._fixedEndLimit = f;
      }
      
      internal function get fixedEndLimit() : Number
      {
         return this._fixedEndLimit;
      }
      
      override public function get mass() : Number
      {
         return (this.p1.mass + this.p2.mass) / 2;
      }
      
      override public function get elasticity() : Number
      {
         return (this.p1.elasticity + this.p2.elasticity) / 2;
      }
      
      override public function get friction() : Number
      {
         return (this.p1.friction + this.p2.friction) / 2;
      }
      
      override public function get velocity() : CartesianVector
      {
         var p1v:CartesianVector = this.p1.velocity;
         var p2v:CartesianVector = this.p2.velocity;
         this.avgVelocity.setTo((p1v.x + p2v.x) / 2,(p1v.y + p2v.y) / 2);
         return this.avgVelocity;
      }
      
      override public function init() : void
      {
         var inner:Sprite = null;
         var w:Number = NaN;
         var h:Number = NaN;
         if(displayObject != null)
         {
            this.initDisplay();
         }
         else
         {
            inner = new Sprite();
            this.parent.sprite.addChild(inner);
            inner.name = "inner";
            w = this.parent.currLength * this.rectScale;
            h = this.rectHeight;
            inner.graphics.clear();
            inner.graphics.lineStyle(this.parent.lineThickness,this.parent.lineColor,this.parent.lineAlpha);
            inner.graphics.beginFill(this.parent.fillColor,this.parent.fillAlpha);
            inner.graphics.drawRect(-w / 2,-h / 2,w,h);
            inner.graphics.endFill();
         }
         this.paint();
      }
      
      override public function paint() : void
      {
         var c:CartesianVector = this.parent.center;
         var s:Sprite = this.parent.sprite;
         if(this.scaleToLength)
         {
            s.getChildByName("inner").width = this.parent.currLength * this.rectScale;
         }
         else if(displayObject != null)
         {
            s.getChildByName("inner").width = this.parent.restLength * this.rectScale;
         }
         s.x = c.x;
         s.y = c.y;
         s.rotation = this.parent.angle;
      }
      
      override internal function initDisplay() : void
      {
         displayObject.x = displayObjectOffset.x;
         displayObject.y = displayObjectOffset.y;
         displayObject.rotation = displayObjectRotation;
         var inner:Sprite = new Sprite();
         inner.name = "inner";
         inner.addChild(displayObject);
         this.parent.sprite.addChild(inner);
      }
      
      override internal function get invMass() : Number
      {
         if(this.p1.fixed && this.p2.fixed)
         {
            return 0;
         }
         return 1 / ((this.p1.mass + this.p2.mass) / 2);
      }
      
      override public function get fixed() : Boolean
      {
         return this.parent.fixed;
      }
      
      internal function updatePosition() : void
      {
         var c:CartesianVector = this.parent.center;
         curr.setTo(c.x,c.y);
         width = this.scaleToLength ? this.parent.currLength * this.rectScale : this.parent.restLength * this.rectScale;
         height = this.rectHeight;
         radian = this.parent.radian;
      }
      
      override internal function resolveCollision(mtd:CartesianVector, vel:CartesianVector, n:CartesianVector, d:Number, o:int, p:AbstractParticle) : void
      {
         var denom:Number = NaN;
         var corrParticle:AbstractParticle = null;
         testParticleEvents(p);
         if(this.fixed || !p.solid)
         {
            return;
         }
         var t:Number = this.getContactPointParam(p);
         var c1:Number = 1 - t;
         var c2:Number = t;
         if(this.p1.fixed)
         {
            if(c2 <= this.fixedEndLimit)
            {
               return;
            }
            this.lambda.setTo(mtd.x / c2,mtd.y / c2);
            this.p2.curr.plusEquals(this.lambda);
            this.p2.velocity = vel;
         }
         else if(this.p2.fixed)
         {
            if(c1 <= this.fixedEndLimit)
            {
               return;
            }
            this.lambda.setTo(mtd.x / c1,mtd.y / c1);
            this.p1.curr.plusEquals(this.lambda);
            this.p1.velocity = vel;
         }
         else
         {
            denom = c1 * c1 + c2 * c2;
            if(denom == 0)
            {
               return;
            }
            this.lambda.setTo(mtd.x / denom,mtd.y / denom);
            this.p1.curr.plusEquals(this.lambda.mult(c1));
            this.p2.curr.plusEquals(this.lambda.mult(c2));
            if(t == 0.5)
            {
               this.p1.velocity = vel;
               this.p2.velocity = vel;
            }
            else
            {
               corrParticle = t < 0.5 ? this.p1 : this.p2;
               corrParticle.velocity = vel;
            }
         }
      }
      
      private function closestParamPoint(c:CartesianVector) : Number
      {
         var ab:CartesianVector = this.p2.curr.minus(this.p1.curr);
         var t:Number = ab.dot(c.minus(this.p1.curr)) / ab.dot(ab);
         return MathUtil.clamp(t,0,1);
      }
      
      private function getContactPointParam(p:AbstractParticle) : Number
      {
         var t:Number = NaN;
         var shortestIndex:Number = NaN;
         var paramList:Array = null;
         var shortestDistance:Number = NaN;
         var i:int = 0;
         var d:Number = NaN;
         if(p is CircleParticle)
         {
            t = this.closestParamPoint(p.curr);
         }
         else if(p is RectangleParticle)
         {
            paramList = new Array(4);
            shortestDistance = Number.POSITIVE_INFINITY;
            for(i = 0; i < 4; i++)
            {
               this.setCorners(p as RectangleParticle,i);
               d = this.closestPtSegmentSegment();
               if(d < shortestDistance)
               {
                  shortestDistance = d;
                  shortestIndex = i;
                  paramList[i] = this.s;
               }
            }
            t = Number(paramList[shortestIndex]);
         }
         return t;
      }
      
      private function setCorners(r:RectangleParticle, i:int) : void
      {
         var rx:Number = r.curr.x;
         var ry:Number = r.curr.y;
         var axes:Array = r.axes;
         var extents:Array = r.extents;
         var ae0_x:Number = axes[0].x * extents[0];
         var ae0_y:Number = axes[0].y * extents[0];
         var ae1_x:Number = axes[1].x * extents[1];
         var ae1_y:Number = axes[1].y * extents[1];
         var emx:Number = ae0_x - ae1_x;
         var emy:Number = ae0_y - ae1_y;
         var epx:Number = ae0_x + ae1_x;
         var epy:Number = ae0_y + ae1_y;
         if(i == 0)
         {
            this.rca.x = rx - epx;
            this.rca.y = ry - epy;
            this.rcb.x = rx + emx;
            this.rcb.y = ry + emy;
         }
         else if(i == 1)
         {
            this.rca.x = rx + emx;
            this.rca.y = ry + emy;
            this.rcb.x = rx + epx;
            this.rcb.y = ry + epy;
         }
         else if(i == 2)
         {
            this.rca.x = rx + epx;
            this.rca.y = ry + epy;
            this.rcb.x = rx - emx;
            this.rcb.y = ry - emy;
         }
         else if(i == 3)
         {
            this.rca.x = rx - emx;
            this.rca.y = ry - emy;
            this.rcb.x = rx - epx;
            this.rcb.y = ry - epy;
         }
      }
      
      private function closestPtSegmentSegment() : Number
      {
         var t:Number = NaN;
         var pp1:CartesianVector = this.p1.curr;
         var pq1:CartesianVector = this.p2.curr;
         var pp2:CartesianVector = this.rca;
         var pq2:CartesianVector = this.rcb;
         var d1:CartesianVector = pq1.minus(pp1);
         var d2:CartesianVector = pq2.minus(pp2);
         var r:CartesianVector = pp1.minus(pp2);
         var a:Number = d1.dot(d1);
         var e:Number = d2.dot(d2);
         var f:Number = d2.dot(r);
         var c:Number = d1.dot(r);
         var b:Number = d1.dot(d2);
         var denom:Number = a * e - b * b;
         if(denom != 0)
         {
            this.s = MathUtil.clamp((b * f - c * e) / denom,0,1);
         }
         else
         {
            this.s = 0.5;
         }
         t = (b * this.s + f) / e;
         if(t < 0)
         {
            t = 0;
            this.s = MathUtil.clamp(-c / a,0,1);
         }
         else if(t > 0)
         {
            t = 1;
            this.s = MathUtil.clamp((b - c) / a,0,1);
         }
         var c1:CartesianVector = pp1.plus(d1.mult(this.s));
         var c2:CartesianVector = pp2.plus(d2.mult(t));
         var c1mc2:CartesianVector = c1.minus(c2);
         return c1mc2.dot(c1mc2);
      }
   }
}

