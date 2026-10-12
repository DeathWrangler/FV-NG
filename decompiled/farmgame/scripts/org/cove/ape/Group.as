package org.cove.ape
{
   public class Group extends AbstractCollection
   {
      
      private var _composites:Array;
      
      private var _collisionList:Array;
      
      private var _collideInternal:Boolean;
      
      public function Group(collideInternal:Boolean = false)
      {
         super();
         this._composites = new Array();
         this._collisionList = new Array();
         this.collideInternal = collideInternal;
      }
      
      override public function init() : void
      {
         super.init();
         for(var i:int = 0; i < this.composites.length; i++)
         {
            this.composites[i].init();
         }
      }
      
      public function get composites() : Array
      {
         return this._composites;
      }
      
      public function addComposite(c:Composite) : void
      {
         this.composites.push(c);
         c.isParented = true;
         if(isParented)
         {
            c.init();
         }
      }
      
      public function removeComposite(c:Composite) : void
      {
         var cpos:int = this.composites.indexOf(c);
         if(cpos == -1)
         {
            return;
         }
         this.composites.splice(cpos,1);
         c.isParented = false;
         c.cleanup();
      }
      
      override public function paint() : void
      {
         var c:Composite = null;
         super.paint();
         var len:int = int(this._composites.length);
         for(var i:int = 0; i < len; i++)
         {
            c = this._composites[i];
            c.paint();
         }
      }
      
      public function addCollidable(g:Group) : void
      {
         this.collisionList.push(g);
      }
      
      public function removeCollidable(g:Group) : void
      {
         var pos:int = this.collisionList.indexOf(g);
         if(pos == -1)
         {
            return;
         }
         this.collisionList.splice(pos,1);
      }
      
      public function addCollidableList(list:Array) : void
      {
         var g:Group = null;
         for(var i:int = 0; i < list.length; i++)
         {
            g = list[i];
            this.collisionList.push(g);
         }
      }
      
      public function get collisionList() : Array
      {
         return this._collisionList;
      }
      
      override public function getAll() : Array
      {
         return particles.concat(constraints).concat(this.composites);
      }
      
      public function get collideInternal() : Boolean
      {
         return this._collideInternal;
      }
      
      public function set collideInternal(b:Boolean) : void
      {
         this._collideInternal = b;
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         for(var i:int = 0; i < this.composites.length; i++)
         {
            this.composites[i].cleanup();
         }
      }
      
      override internal function integrate(dt2:Number) : void
      {
         var cmp:Composite = null;
         super.integrate(dt2);
         var len:int = int(this._composites.length);
         for(var i:int = 0; i < len; i++)
         {
            cmp = this._composites[i];
            cmp.integrate(dt2);
         }
      }
      
      override internal function satisfyConstraints() : void
      {
         var cmp:Composite = null;
         super.satisfyConstraints();
         var len:int = int(this._composites.length);
         for(var i:int = 0; i < len; i++)
         {
            cmp = this._composites[i];
            cmp.satisfyConstraints();
         }
      }
      
      internal function checkCollisions() : void
      {
         var g:Group = null;
         if(this.collideInternal)
         {
            this.checkCollisionGroupInternal();
         }
         var len:int = int(this.collisionList.length);
         for(var i:int = 0; i < len; i++)
         {
            g = this.collisionList[i];
            if(g != null)
            {
               this.checkCollisionVsGroup(g);
            }
         }
      }
      
      private function checkCollisionGroupInternal() : void
      {
         var ca:Composite = null;
         var i:int = 0;
         var cb:Composite = null;
         checkInternalCollisions();
         var clen:int = int(this._composites.length);
         for(var j:int = 0; j < clen; j++)
         {
            ca = this._composites[j];
            if(ca != null)
            {
               ca.checkCollisionsVsCollection(this);
               for(i = j + 1; i < clen; i++)
               {
                  cb = this._composites[i];
                  if(cb != null)
                  {
                     ca.checkCollisionsVsCollection(cb);
                  }
               }
            }
         }
      }
      
      private function checkCollisionVsGroup(g:Group) : void
      {
         var gc:Composite = null;
         var c:Composite = null;
         var j:int = 0;
         checkCollisionsVsCollection(g);
         var clen:int = int(this._composites.length);
         var gclen:int = int(g.composites.length);
         for(var i:int = 0; i < clen; i++)
         {
            c = this._composites[i];
            if(c != null)
            {
               c.checkCollisionsVsCollection(g);
               for(j = 0; j < gclen; j++)
               {
                  gc = g.composites[j];
                  if(gc != null)
                  {
                     c.checkCollisionsVsCollection(gc);
                  }
               }
            }
         }
         for(j = 0; j < gclen; j++)
         {
            gc = g.composites[j];
            if(gc != null)
            {
               checkCollisionsVsCollection(gc);
            }
         }
      }
   }
}

