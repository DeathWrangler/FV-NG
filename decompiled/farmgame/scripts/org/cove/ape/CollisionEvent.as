package org.cove.ape
{
   import flash.events.Event;
   
   public class CollisionEvent extends Event
   {
      
      public static const COLLIDE:String = "collide";
      
      public static const FIRST_COLLIDE:String = "firstCollide";
      
      private var _collidingItem:AbstractItem;
      
      public function CollisionEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, collidingItem:AbstractItem = null)
      {
         super(type,bubbles,cancelable);
         this._collidingItem = collidingItem;
      }
      
      public function get collidingItem() : AbstractItem
      {
         var scp:SpringConstraintParticle = null;
         if(this._collidingItem is SpringConstraintParticle)
         {
            scp = this._collidingItem as SpringConstraintParticle;
            return scp.parent;
         }
         return this._collidingItem;
      }
   }
}

