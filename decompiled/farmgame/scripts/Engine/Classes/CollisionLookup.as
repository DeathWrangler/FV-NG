package Engine.Classes
{
   import Engine.Constants;
   import Engine.Helpers.Vector3;
   
   public class CollisionLookup
   {
      
      public var startX:int;
      
      public var startY:int;
      
      public var endX:int;
      
      public var endY:int;
      
      public var ignoreObjects:Array = null;
      
      public var colliders:Array = [];
      
      public var collidingObject:WorldObject = null;
      
      public var colliderTypes:int = 16777215;
      
      public var flags:int = 32;
      
      public var ignorePathable:Boolean = false;
      
      public function CollisionLookup()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:int, param4:int) : void
      {
         this.ignoreObjects = null;
         this.colliders = [];
         this.collidingObject = null;
         this.colliderTypes = Constants.WORLDOBJECT_ALL;
         this.flags = Constants.COLLISION_ALL;
         this.startX = param1;
         this.startY = param2;
         this.endX = param3;
         this.endY = param4;
         this.fixBounds();
      }
      
      public function fixBounds() : void
      {
         var _loc1_:int = 0;
         if(this.startX > this.endX)
         {
            _loc1_ = this.startX;
            this.startX = this.endX;
            this.endX = _loc1_;
         }
         if(this.startY > this.endY)
         {
            _loc1_ = this.startY;
            this.startY = this.endY;
            this.endY = _loc1_;
         }
      }
      
      public function getFlags(param1:int, param2:int) : int
      {
         var _loc4_:Vector3 = null;
         var _loc5_:Vector3 = null;
         var _loc3_:int = 0;
         if(this.collidingObject != null)
         {
            _loc4_ = this.collidingObject.getPositionNoClone();
            _loc5_ = this.collidingObject.getSizeNoClone();
            param1 -= this.startX;
            param2 -= this.startY;
            if(param1 >= 0 && param2 >= 0 && param1 < _loc5_.x && param2 < _loc5_.y)
            {
               _loc3_ = this.collidingObject.getCollisionFlags(param1,param2);
            }
         }
         else
         {
            _loc3_ = this.flags;
         }
         return _loc3_;
      }
      
      public function isLine() : Boolean
      {
         return this.startX == this.endX || this.startY == this.endY;
      }
   }
}

