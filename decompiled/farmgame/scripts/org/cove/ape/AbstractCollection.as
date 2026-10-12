package org.cove.ape
{
   import flash.display.Sprite;
   import flash.utils.getQualifiedClassName;
   
   public class AbstractCollection
   {
      
      private var _sprite:Sprite;
      
      private var _particles:Array;
      
      private var _constraints:Array;
      
      private var _isParented:Boolean;
      
      public function AbstractCollection()
      {
         super();
         if(getQualifiedClassName(this) == "org.cove.ape::AbstractCollection")
         {
            throw new ArgumentError("AbstractCollection can\'t be instantiated directly");
         }
         this._isParented = false;
         this._particles = new Array();
         this._constraints = new Array();
      }
      
      public function get particles() : Array
      {
         return this._particles;
      }
      
      public function get constraints() : Array
      {
         return this._constraints;
      }
      
      public function addParticle(p:AbstractParticle) : void
      {
         this.particles.push(p);
         if(this.isParented)
         {
            p.init();
         }
      }
      
      public function removeParticle(p:AbstractParticle) : void
      {
         var ppos:int = this.particles.indexOf(p);
         if(ppos == -1)
         {
            return;
         }
         this.particles.splice(ppos,1);
         p.cleanup();
      }
      
      public function addConstraint(c:AbstractConstraint) : void
      {
         this.constraints.push(c);
         if(this.isParented)
         {
            c.init();
         }
      }
      
      public function removeConstraint(c:AbstractConstraint) : void
      {
         var cpos:int = this.constraints.indexOf(c);
         if(cpos == -1)
         {
            return;
         }
         this.constraints.splice(cpos,1);
         c.cleanup();
      }
      
      public function init() : void
      {
         for(var i:int = 0; i < this.particles.length; i++)
         {
            this.particles[i].init();
         }
         for(i = 0; i < this.constraints.length; i++)
         {
            this.constraints[i].init();
         }
      }
      
      public function paint() : void
      {
         var p:AbstractParticle = null;
         var c:SpringConstraint = null;
         var len:int = int(this._particles.length);
         for(var i:int = 0; i < len; i++)
         {
            p = this._particles[i];
            if(!p.fixed || p.alwaysRepaint)
            {
               p.paint();
            }
         }
         len = int(this._constraints.length);
         for(i = 0; i < len; i++)
         {
            c = this._constraints[i];
            if(!c.fixed || c.alwaysRepaint)
            {
               c.paint();
            }
         }
      }
      
      public function cleanup() : void
      {
         for(var i:int = 0; i < this.particles.length; i++)
         {
            this.particles[i].cleanup();
         }
         for(i = 0; i < this.constraints.length; i++)
         {
            this.constraints[i].cleanup();
         }
      }
      
      public function get sprite() : Sprite
      {
         if(this._sprite != null)
         {
            return this._sprite;
         }
         if(APEngine.container == null)
         {
            throw new Error("The container property of the APEngine class has not been set");
         }
         this._sprite = new Sprite();
         APEngine.container.addChild(this._sprite);
         return this._sprite;
      }
      
      public function getAll() : Array
      {
         return this.particles.concat(this.constraints);
      }
      
      internal function get isParented() : Boolean
      {
         return this._isParented;
      }
      
      internal function set isParented(b:Boolean) : void
      {
         this._isParented = b;
      }
      
      internal function integrate(dt2:Number) : void
      {
         var p:AbstractParticle = null;
         var len:int = int(this._particles.length);
         for(var i:int = 0; i < len; i++)
         {
            p = this._particles[i];
            p.update(dt2);
         }
      }
      
      internal function satisfyConstraints() : void
      {
         var c:AbstractConstraint = null;
         var len:int = int(this._constraints.length);
         for(var i:int = 0; i < len; i++)
         {
            c = this._constraints[i];
            c.resolve();
         }
      }
      
      internal function checkInternalCollisions() : void
      {
         var pa:AbstractParticle = null;
         var i:int = 0;
         var clen:int = 0;
         var n:int = 0;
         var pb:AbstractParticle = null;
         var c:SpringConstraint = null;
         var plen:int = int(this._particles.length);
         for(var j:int = 0; j < plen; j++)
         {
            pa = this._particles[j];
            if(!(pa == null || !pa.collidable))
            {
               for(i = j + 1; i < plen; i++)
               {
                  pb = this._particles[i];
                  if(pb != null && pb.collidable)
                  {
                     CollisionDetector.test(pa,pb);
                  }
               }
               clen = int(this._constraints.length);
               for(n = 0; n < clen; n++)
               {
                  c = this._constraints[n];
                  if(c != null && c.collidable && !c.isConnectedTo(pa))
                  {
                     c.scp.updatePosition();
                     CollisionDetector.test(pa,c.scp);
                  }
               }
            }
         }
      }
      
      internal function checkCollisionsVsCollection(ac:AbstractCollection) : void
      {
         var pga:AbstractParticle = null;
         var acplen:int = 0;
         var x:int = 0;
         var acclen:int = 0;
         var pgb:AbstractParticle = null;
         var cgb:SpringConstraint = null;
         var cga:SpringConstraint = null;
         var n:int = 0;
         var plen:int = int(this._particles.length);
         for(var j:int = 0; j < plen; j++)
         {
            pga = this._particles[j];
            if(!(pga == null || !pga.collidable))
            {
               acplen = int(ac.particles.length);
               for(x = 0; x < acplen; x++)
               {
                  pgb = ac.particles[x];
                  if(pgb != null && pgb.collidable)
                  {
                     CollisionDetector.test(pga,pgb);
                  }
               }
               acclen = int(ac.constraints.length);
               for(x = 0; x < acclen; x++)
               {
                  cgb = ac.constraints[x];
                  if(cgb != null && cgb.collidable && !cgb.isConnectedTo(pga))
                  {
                     cgb.scp.updatePosition();
                     CollisionDetector.test(pga,cgb.scp);
                  }
               }
            }
         }
         var clen:int = int(this._constraints.length);
         for(j = 0; j < clen; j++)
         {
            cga = this._constraints[j];
            if(!(cga == null || !cga.collidable))
            {
               acplen = int(ac.particles.length);
               for(n = 0; n < acplen; n++)
               {
                  pgb = ac.particles[n];
                  if(pgb != null && pgb.collidable && !cga.isConnectedTo(pgb))
                  {
                     cga.scp.updatePosition();
                     CollisionDetector.test(pgb,cga.scp);
                  }
               }
            }
         }
      }
   }
}

