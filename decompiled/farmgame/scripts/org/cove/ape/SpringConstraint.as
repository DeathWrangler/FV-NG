package org.cove.ape
{
   import flash.display.DisplayObject;
   
   public class SpringConstraint extends AbstractConstraint
   {
      
      private var p1:AbstractParticle;
      
      private var p2:AbstractParticle;
      
      private var _restLength:Number;
      
      private var _collidable:Boolean;
      
      private var _scp:SpringConstraintParticle;
      
      public function SpringConstraint(p1:AbstractParticle, p2:AbstractParticle, stiffness:Number = 0.5, collidable:Boolean = false, rectHeight:Number = 1, rectScale:Number = 1, scaleToLength:Boolean = false)
      {
         super(stiffness);
         this.p1 = p1;
         this.p2 = p2;
         this.checkParticlesLocation();
         this._restLength = this.currLength;
         this.setCollidable(collidable,rectHeight,rectScale,scaleToLength);
      }
      
      public function get radian() : Number
      {
         var d:CartesianVector = this.delta;
         return Math.atan2(d.y,d.x);
      }
      
      public function get angle() : Number
      {
         return this.radian * MathUtil.ONE_EIGHTY_OVER_PI;
      }
      
      public function get center() : CartesianVector
      {
         return this.p1.curr.plus(this.p2.curr).divEquals(2);
      }
      
      public function set rectScale(s:Number) : void
      {
         if(this.scp == null)
         {
            return;
         }
         this.scp.rectScale = s;
      }
      
      public function get rectScale() : Number
      {
         return this.scp.rectScale;
      }
      
      public function get currLength() : Number
      {
         return this.p1.curr.distance(this.p2.curr);
      }
      
      public function get rectHeight() : Number
      {
         return this.scp.rectHeight;
      }
      
      public function set rectHeight(h:Number) : void
      {
         if(this.scp == null)
         {
            return;
         }
         this.scp.rectHeight = h;
      }
      
      public function get restLength() : Number
      {
         return this._restLength;
      }
      
      public function set restLength(r:Number) : void
      {
         if(r <= 0)
         {
            throw new ArgumentError("restLength must be greater than 0");
         }
         this._restLength = r;
      }
      
      public function get collidable() : Boolean
      {
         return this._collidable;
      }
      
      public function get fixedEndLimit() : Number
      {
         return this.scp.fixedEndLimit;
      }
      
      public function set fixedEndLimit(f:Number) : void
      {
         if(this.scp == null)
         {
            return;
         }
         this.scp.fixedEndLimit = f;
      }
      
      public function setCollidable(b:Boolean, rectHeight:Number, rectScale:Number, scaleToLength:Boolean = false) : void
      {
         this._collidable = b;
         this._scp = null;
         if(this._collidable)
         {
            this._scp = new SpringConstraintParticle(this.p1,this.p2,this,rectHeight,rectScale,scaleToLength);
         }
      }
      
      public function isConnectedTo(p:AbstractParticle) : Boolean
      {
         return p == this.p1 || p == this.p2;
      }
      
      public function get fixed() : Boolean
      {
         return this.p1.fixed && this.p2.fixed;
      }
      
      override public function init() : void
      {
         cleanup();
         if(this.collidable)
         {
            this.scp.init();
         }
         else if(displayObject != null)
         {
            this.initDisplay();
         }
         this.paint();
      }
      
      override public function paint() : void
      {
         var c:CartesianVector = null;
         if(this.collidable)
         {
            this.scp.paint();
         }
         else if(displayObject != null)
         {
            c = this.center;
            sprite.x = c.x;
            sprite.y = c.y;
            sprite.rotation = this.angle;
         }
         else
         {
            sprite.graphics.clear();
            sprite.graphics.lineStyle(lineThickness,lineColor,lineAlpha);
            sprite.graphics.moveTo(this.p1.px,this.p1.py);
            sprite.graphics.lineTo(this.p2.px,this.p2.py);
         }
      }
      
      public function setDisplay(d:DisplayObject, offsetX:Number = 0, offsetY:Number = 0, rotation:Number = 0) : void
      {
         if(this.collidable)
         {
            this.scp.setDisplay(d,offsetX,offsetY,rotation);
         }
         else
         {
            displayObject = d;
            displayObjectRotation = rotation;
            displayObjectOffset = new CartesianVector(offsetX,offsetY);
         }
      }
      
      override public function resolve() : void
      {
         if(this.p1.fixed && this.p2.fixed)
         {
            return;
         }
         var deltaLength:Number = this.currLength;
         var diff:Number = (deltaLength - this.restLength) / (deltaLength * (this.p1.invMass + this.p2.invMass));
         var dmds:CartesianVector = this.delta.mult(diff * stiffness);
         this.p1.curr.minusEquals(dmds.mult(this.p1.invMass));
         this.p2.curr.plusEquals(dmds.mult(this.p2.invMass));
      }
      
      internal function initDisplay() : void
      {
         if(this.collidable)
         {
            this.scp.initDisplay();
         }
         else
         {
            displayObject.x = displayObjectOffset.x;
            displayObject.y = displayObjectOffset.y;
            displayObject.rotation = displayObjectRotation;
            sprite.addChild(displayObject);
         }
      }
      
      internal function get delta() : CartesianVector
      {
         return this.p1.curr.minus(this.p2.curr);
      }
      
      internal function get scp() : SpringConstraintParticle
      {
         return this._scp;
      }
      
      private function checkParticlesLocation() : void
      {
         if(this.p1.curr.x == this.p2.curr.x && this.p1.curr.y == this.p2.curr.y)
         {
            this.p2.curr.x += 0.0001;
         }
      }
   }
}

