package org.cove.ape
{
   import flash.display.DisplayObjectContainer;
   
   public final class APEngine
   {
      
      internal static var forces:Array;
      
      private static var groups:Array;
      
      private static var numGroups:int;
      
      private static var timeStep:Number;
      
      private static var _damping:Number;
      
      private static var _container:DisplayObjectContainer;
      
      private static var _constraintCycles:int;
      
      private static var _constraintCollisionCycles:int;
      
      public function APEngine()
      {
         super();
      }
      
      public static function init(dt:Number = 0.25) : void
      {
         timeStep = dt * dt;
         numGroups = 0;
         groups = new Array();
         forces = new Array();
         _damping = 1;
         _constraintCycles = 0;
         _constraintCollisionCycles = 1;
      }
      
      public static function get damping() : Number
      {
         return _damping;
      }
      
      public static function set damping(d:Number) : void
      {
         _damping = d;
      }
      
      public static function get constraintCycles() : int
      {
         return _constraintCycles;
      }
      
      public static function set constraintCycles(numCycles:int) : void
      {
         _constraintCycles = numCycles;
      }
      
      public static function get constraintCollisionCycles() : int
      {
         return _constraintCollisionCycles;
      }
      
      public static function set constraintCollisionCycles(numCycles:int) : void
      {
         _constraintCollisionCycles = numCycles;
      }
      
      public static function get container() : DisplayObjectContainer
      {
         return _container;
      }
      
      public static function set container(d:DisplayObjectContainer) : void
      {
         _container = d;
      }
      
      public static function addForce(f:IForce) : void
      {
         forces.push(f);
      }
      
      public static function removeForce(f:IForce) : void
      {
         var fpos:int = forces.indexOf(f);
         if(fpos == -1)
         {
            return;
         }
         forces.splice(fpos,1);
      }
      
      public static function removeAllForce() : void
      {
         forces = new Array();
      }
      
      public static function addGroup(g:Group) : void
      {
         groups.push(g);
         g.isParented = true;
         ++numGroups;
         g.init();
      }
      
      public static function removeGroup(g:Group) : void
      {
         var gpos:int = groups.indexOf(g);
         if(gpos == -1)
         {
            return;
         }
         groups.splice(gpos,1);
         g.isParented = false;
         --numGroups;
         g.cleanup();
      }
      
      public static function step() : void
      {
         integrate();
         for(var j:int = 0; j < _constraintCycles; j++)
         {
            satisfyConstraints();
         }
         for(var i:int = 0; i < _constraintCollisionCycles; i++)
         {
            satisfyConstraints();
            checkCollisions();
         }
      }
      
      public static function paint() : void
      {
         var g:Group = null;
         for(var j:int = 0; j < numGroups; j++)
         {
            g = groups[j];
            g.paint();
         }
      }
      
      private static function integrate() : void
      {
         var g:Group = null;
         for(var j:int = 0; j < numGroups; j++)
         {
            g = groups[j];
            g.integrate(timeStep);
         }
      }
      
      private static function satisfyConstraints() : void
      {
         var g:Group = null;
         for(var j:int = 0; j < numGroups; j++)
         {
            g = groups[j];
            g.satisfyConstraints();
         }
      }
      
      private static function checkCollisions() : void
      {
         var g:Group = null;
         for(var j:int = 0; j < numGroups; j++)
         {
            g = groups[j];
            g.checkCollisions();
         }
      }
   }
}

