package org.cove.ape
{
   import flash.display.DisplayObject;
   import flash.utils.getQualifiedClassName;
   
   public class AbstractParticle extends AbstractItem
   {
      
      internal var curr:CartesianVector;
      
      internal var prev:CartesianVector;
      
      internal var samp:CartesianVector;
      
      internal var interval:Interval;
      
      private var temp:CartesianVector;
      
      private var forces:CartesianVector;
      
      private var forceList:Array;
      
      private var collision:Collision;
      
      private var firstCollision:Boolean;
      
      private var _kfr:Number;
      
      private var _mass:Number;
      
      private var _invMass:Number;
      
      private var _friction:Number;
      
      private var _fixed:Boolean;
      
      private var _collidable:Boolean;
      
      private var _center:CartesianVector;
      
      private var _multisample:int;
      
      public function AbstractParticle(x:Number, y:Number, isFixed:Boolean, mass:Number, elasticity:Number, friction:Number)
      {
         super();
         if(getQualifiedClassName(this) == "org.cove.ape::AbstractParticle")
         {
            throw new ArgumentError("AbstractParticle can\'t be instantiated directly");
         }
         this.interval = new Interval(0,0);
         this.curr = new CartesianVector(x,y);
         this.prev = new CartesianVector(x,y);
         this.samp = new CartesianVector();
         this.temp = new CartesianVector();
         this.fixed = isFixed;
         this.forces = new CartesianVector();
         this.forceList = new Array();
         this.collision = new Collision(new CartesianVector(),new CartesianVector());
         this.collidable = true;
         this.firstCollision = false;
         this.mass = mass;
         this.elasticity = elasticity;
         this.friction = friction;
         setStyle();
         this._center = new CartesianVector();
         this._multisample = 0;
      }
      
      public function get mass() : Number
      {
         return this._mass;
      }
      
      public function set mass(m:Number) : void
      {
         if(m <= 0)
         {
            throw new ArgumentError("mass may not be set <= 0");
         }
         this._mass = m;
         this._invMass = 1 / this._mass;
      }
      
      public function get elasticity() : Number
      {
         return this._kfr;
      }
      
      public function set elasticity(k:Number) : void
      {
         this._kfr = k;
      }
      
      public function get multisample() : int
      {
         return this._multisample;
      }
      
      public function set multisample(m:int) : void
      {
         this._multisample = m;
      }
      
      public function get center() : CartesianVector
      {
         this._center.setTo(this.px,this.py);
         return this._center;
      }
      
      public function get friction() : Number
      {
         return this._friction;
      }
      
      public function set friction(f:Number) : void
      {
         if(f < 0 || f > 1)
         {
            throw new ArgumentError("Legal friction must be >= 0 and <=1");
         }
         this._friction = f;
      }
      
      public function get fixed() : Boolean
      {
         return this._fixed;
      }
      
      public function set fixed(f:Boolean) : void
      {
         this._fixed = f;
      }
      
      public function get position() : CartesianVector
      {
         return new CartesianVector(this.curr.x,this.curr.y);
      }
      
      public function set position(p:CartesianVector) : void
      {
         this.curr.copy(p);
         this.prev.copy(p);
      }
      
      public function get px() : Number
      {
         return this.curr.x;
      }
      
      public function set px(x:Number) : void
      {
         this.curr.x = x;
         this.prev.x = x;
      }
      
      public function get py() : Number
      {
         return this.curr.y;
      }
      
      public function set py(y:Number) : void
      {
         this.curr.y = y;
         this.prev.y = y;
      }
      
      public function get velocity() : CartesianVector
      {
         return this.curr.minus(this.prev);
      }
      
      public function set velocity(v:CartesianVector) : void
      {
         this.prev = this.curr.minus(v);
      }
      
      public function get collidable() : Boolean
      {
         return this._collidable;
      }
      
      public function set collidable(b:Boolean) : void
      {
         this._collidable = b;
      }
      
      public function setDisplay(d:DisplayObject, offsetX:Number = 0, offsetY:Number = 0, rotation:Number = 0) : void
      {
         displayObject = d;
         displayObjectRotation = rotation;
         displayObjectOffset = new CartesianVector(offsetX,offsetY);
      }
      
      public function addForce(f:IForce) : void
      {
         this.forceList.push(f);
      }
      
      public function update(dt2:Number) : void
      {
         if(this.fixed)
         {
            return;
         }
         this.accumulateForces();
         this.temp.copy(this.curr);
         var nv:CartesianVector = this.velocity.plus(this.forces.multEquals(dt2));
         this.curr.plusEquals(nv.multEquals(APEngine.damping));
         this.prev.copy(this.temp);
         this.clearForces();
      }
      
      public function resetFirstCollision() : void
      {
         this.firstCollision = false;
      }
      
      internal function initDisplay() : void
      {
         displayObject.x = displayObjectOffset.x;
         displayObject.y = displayObjectOffset.y;
         displayObject.rotation = displayObjectRotation;
         sprite.addChild(displayObject);
      }
      
      internal function getComponents(collisionNormal:CartesianVector) : Collision
      {
         var vel:CartesianVector = this.velocity;
         var vdotn:Number = collisionNormal.dot(vel);
         this.collision.vn = collisionNormal.mult(vdotn);
         this.collision.vt = vel.minus(this.collision.vn);
         return this.collision;
      }
      
      internal function resolveCollision(mtd:CartesianVector, vel:CartesianVector, n:CartesianVector, d:Number, o:int, p:AbstractParticle) : void
      {
         this.testParticleEvents(p);
         if(this.fixed || !solid || !p.solid)
         {
            return;
         }
         this.curr.copy(this.samp);
         this.curr.plusEquals(mtd);
         this.velocity = vel;
      }
      
      internal function testParticleEvents(p:AbstractParticle) : void
      {
         if(hasEventListener(CollisionEvent.COLLIDE))
         {
            dispatchEvent(new CollisionEvent(CollisionEvent.COLLIDE,false,false,p));
         }
         if(hasEventListener(CollisionEvent.FIRST_COLLIDE) && !this.firstCollision)
         {
            this.firstCollision = true;
            dispatchEvent(new CollisionEvent(CollisionEvent.FIRST_COLLIDE,false,false,p));
         }
      }
      
      internal function get invMass() : Number
      {
         return this.fixed ? 0 : this._invMass;
      }
      
      private function accumulateForces() : void
      {
         var f:IForce = null;
         var len:int = int(this.forceList.length);
         for(var i:int = 0; i < len; i++)
         {
            f = this.forceList[i];
            this.forces.plusEquals(f.getValue(this._invMass));
         }
         var globalForces:Array = APEngine.forces;
         len = int(globalForces.length);
         for(i = 0; i < len; i++)
         {
            f = globalForces[i];
            this.forces.plusEquals(f.getValue(this._invMass));
         }
      }
      
      private function clearForces() : void
      {
         this.forceList.length = 0;
         this.forces.setTo(0,0);
      }
   }
}

