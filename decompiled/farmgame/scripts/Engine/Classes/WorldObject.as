package Engine.Classes
{
   import Engine.Constants;
   import Engine.Helpers.Vector3;
   import Engine.Interfaces.IEngineObject;
   import Engine.Interfaces.IRenderObject;
   import Engine.IsoMath;
   import flash.display.*;
   import flash.geom.*;
   
   public class WorldObject extends PositionedObject implements IEngineObject, IRenderObject
   {
      
      protected var m_typeName:String;
      
      protected var m_outer:World;
      
      protected var m_skipOuterInRedraw:Boolean;
      
      protected var m_direction:int;
      
      protected var m_depthIndex:int = 0;
      
      protected var m_depthPriority:Number = 0;
      
      protected var m_collisionFlags:int = 32;
      
      private var m_lastUpdateTime:Number = 0;
      
      public var renderBufferDirty:Boolean = true;
      
      private var m_shard:int = 0;
      
      public function WorldObject()
      {
         super();
      }
      
      override public function setId(param1:Number) : void
      {
         var _loc2_:Number = getId();
         super.setId(param1);
         if(_loc2_ != param1 && this.m_outer != null && isAttached())
         {
            this.m_outer.objectIdChanged(this,_loc2_);
         }
      }
      
      public function get children() : Array
      {
         return [];
      }
      
      public function getTypeName() : String
      {
         return this.m_typeName;
      }
      
      public function getReferencedAssets() : Array
      {
         return [];
      }
      
      override public function getSaveObject() : Object
      {
         var _loc1_:Object = super.getSaveObject();
         _loc1_.direction = this.m_direction;
         return _loc1_;
      }
      
      override public function loadObject(param1:Object) : void
      {
         super.loadObject(param1);
         this.m_direction = param1.direction;
      }
      
      public function cleanUp() : void
      {
         this.m_outer = null;
      }
      
      final public function update() : void
      {
         var _loc1_:Number = NaN;
         if(this.m_outer != null)
         {
            _loc1_ = this.m_outer.getShardDelta(this.m_shard);
            if(_loc1_ >= 0)
            {
               onUpdate(_loc1_);
            }
         }
      }
      
      public function render(param1:RenderContext) : void
      {
      }
      
      protected function setObjectsDirty() : void
      {
         if(this.m_outer != null)
         {
            this.m_outer.setObjectsDirty();
         }
      }
      
      override public function markForDeletion(param1:Boolean) : void
      {
         super.markForDeletion(param1);
         if(param1)
         {
            this.m_outer.addToDeletionList(this);
         }
         else
         {
            this.m_outer.removeFromDeletionList(this);
         }
      }
      
      public function isIntersecting(param1:WorldObject) : Boolean
      {
         var _loc2_:Vector3 = this.getDepthPosition();
         var _loc3_:Vector3 = this.getDepthSize();
         var _loc4_:Vector3 = param1.getDepthPosition();
         var _loc5_:Vector3 = param1.getDepthSize();
         var _loc6_:Vector3 = _loc2_.add(_loc3_);
         var _loc7_:Vector3 = _loc4_.add(_loc5_);
         var _loc8_:Boolean = false;
         if(_loc6_.x < _loc4_.x || _loc2_.x > _loc7_.x || _loc6_.y < _loc4_.y || _loc2_.y > _loc7_.y || _loc6_.z < _loc4_.z || _loc2_.z > _loc7_.z)
         {
            _loc8_ = false;
         }
         else
         {
            if(_loc3_.x == 0 && _loc5_.x > 0 && (_loc4_.x >= _loc2_.x || _loc7_.x <= _loc2_.x) || _loc3_.y == 0 && _loc5_.y > 0 && (_loc4_.y >= _loc2_.y || _loc7_.y <= _loc2_.y) || _loc5_.x == 0 && _loc3_.x > 0 && (_loc2_.x >= _loc4_.x || _loc6_.x <= _loc4_.x) || _loc5_.y == 0 && _loc3_.y > 0 && (_loc2_.y >= _loc4_.y || _loc6_.y <= _loc4_.y))
            {
               return false;
            }
            _loc8_ = true;
         }
         return _loc8_;
      }
      
      override public function setPosition(param1:Number, param2:Number, param3:Number = 0) : void
      {
         if(m_position.x != param1 || m_position.y != param2 || m_position.z != param3)
         {
            m_position = new Vector3(param1,param2,param3);
            if(this.m_outer != null)
            {
               m_screenPosition = IsoMath.tilePosToPixelPos(m_position.x,m_position.y,m_position.z,true);
            }
            m_transformDirty = true;
         }
      }
      
      public function setAvatarDecoPosition(param1:Number, param2:Number, param3:Number = 0) : void
      {
         m_position = new Vector3(param1,param2,param3);
         if(this.m_outer != null)
         {
            m_screenPosition = IsoMath.tilePosToPixelPos(m_position.x,m_position.y,m_position.z,true);
         }
         m_transformDirty = true;
      }
      
      public function setDirection(param1:int) : void
      {
         this.m_direction = param1;
      }
      
      public function setCollisionFlags(param1:uint) : void
      {
         this.m_collisionFlags = param1;
      }
      
      public function getCollisionFlags(param1:int, param2:int) : int
      {
         return this.m_collisionFlags;
      }
      
      public function checkInternalCollision(param1:int, param2:int, param3:int) : Boolean
      {
         return true;
      }
      
      public function setOuter(param1:World) : void
      {
         this.m_outer = param1;
         if(param1 != null)
         {
            this.m_skipOuterInRedraw = false;
            this.m_shard = this.m_outer.getRandomShard();
         }
      }
      
      public function getOuter() : PositionedObjectContainer
      {
         return this.m_outer;
      }
      
      public function get skipOuterInRedraw() : Boolean
      {
         return this.m_skipOuterInRedraw;
      }
      
      public function set skipOuterInRedraw(param1:Boolean) : void
      {
         this.m_skipOuterInRedraw = param1;
      }
      
      public function getDirection() : int
      {
         return this.m_direction;
      }
      
      public function getDepthSize() : Vector3
      {
         return m_size.clone();
      }
      
      public function getDepthPriority() : Number
      {
         return this.m_depthPriority;
      }
      
      public function setDepthPriority(param1:Number) : void
      {
         this.m_depthPriority = param1;
      }
      
      public function getDepthPosition() : Vector3
      {
         return m_position.clone();
      }
      
      public function getDepthPositionNoClone() : Vector3
      {
         return m_position;
      }
      
      public function getDepthEndPositionNoClone() : Vector3
      {
         var _loc1_:Vector3 = this.getDepthPositionNoClone();
         m_endPosition.x = _loc1_.x + m_size.x;
         m_endPosition.y = _loc1_.y + m_size.y;
         m_endPosition.z = _loc1_.z + m_size.z;
         return m_endPosition;
      }
      
      public function isCollidable() : Boolean
      {
         return this.m_collisionFlags != 0;
      }
      
      protected function getLayerName() : String
      {
         return null;
      }
      
      public function attach() : void
      {
         GlobalEngine.assert(this.m_outer != null,"Outer for WorldObject is null!");
         if(m_attachPosition == null)
         {
            this.m_outer.attach(this);
            this.calculateDepthIndex();
            this.m_outer.insertObjectIntoDepthArray(this,this.getLayerName());
            this.m_outer.insertObjectIntoCollisionMap(this);
            this.setObjectsDirty();
            updateDisplayObjectTransform();
            updateCulling();
            m_attachPosition = m_position.clone();
            m_attachSize = m_size.clone();
            m_transformDirty = false;
         }
      }
      
      public function detach() : void
      {
         if(m_attachPosition != null && this.m_outer != null)
         {
            this.m_outer.detach(this);
            this.m_outer.removeObjectFromCollisionMap(this);
            this.m_outer.removeObjectFromDepthArray(this);
            m_attachPosition = null;
            m_attachSize = null;
            m_displayObjectDirty = true;
            this.setObjectsDirty();
         }
      }
      
      public function conditionallyRedraw(param1:Boolean = false) : void
      {
         if((this.m_skipOuterInRedraw || this.m_outer != null && !this.m_outer.isRedrawLocked()) && (m_displayObjectDirty || param1))
         {
            drawDisplayObject();
            updateCulling();
            this.toggleAnimation();
            m_displayObjectDirty = false;
         }
      }
      
      public function conditionallyReattach(param1:Boolean = false) : void
      {
         if(isAttached() == false)
         {
            this.attach();
         }
         else if(param1 || m_transformDirty || m_displayObjectDirty || m_attachPosition == null)
         {
            this.m_outer.removeObjectFromCollisionMap(this);
            this.setObjectsDirty();
            if(m_displayObjectDirty)
            {
               drawDisplayObject();
               m_displayObjectDirty = false;
            }
            else
            {
               updateDisplayObjectTransform();
            }
            this.calculateDepthIndex();
            this.m_outer.updateObjectInDepthArray(this);
            this.m_outer.insertObjectIntoCollisionMap(this);
            this.m_outer.updateObjectInRTree(this);
            updateCulling();
            m_attachPosition = m_position.clone();
            m_attachSize = m_size.clone();
            m_transformDirty = false;
         }
      }
      
      public function getFurthestTilePosition() : Vector3
      {
         var _loc1_:Vector3 = this.getDepthPosition();
         var _loc2_:Vector3 = this.getDepthSize();
         var _loc3_:World = World.getInstance();
         var _loc4_:Vector3 = new Vector3();
         switch(_loc3_.getRotation())
         {
            case Constants.ROTATION_0:
               _loc4_.x = _loc2_.x;
               _loc4_.y = _loc2_.y;
               break;
            case Constants.ROTATION_90:
               _loc4_.y = _loc2_.y;
               break;
            case Constants.ROTATION_180:
               break;
            case Constants.ROTATION_270:
               _loc4_.x = _loc2_.x;
         }
         return _loc1_.add(_loc4_);
      }
      
      protected function calculateDepthIndex() : void
      {
         var _loc1_:Vector3 = this.getNearestTilePosition();
         var _loc2_:Vector3 = this.getFurthestTilePosition();
         var _loc3_:Number = (_loc1_.x + _loc2_.x) / 2;
         this.m_depthIndex = (_loc3_ + (_loc1_.y + _loc2_.y) / 2) * 1000 + _loc3_;
      }
      
      public function get depthIndex() : Number
      {
         return this.m_depthIndex;
      }
      
      public function getNearestTilePosition() : Vector3
      {
         return this.getOriginPoint(this.m_outer.getRotation());
      }
      
      public function getOriginPoint(param1:int) : Vector3
      {
         var _loc2_:Vector3 = this.getDepthPosition();
         var _loc3_:Vector3 = this.getDepthSize();
         var _loc4_:Vector3 = new Vector3();
         switch(param1)
         {
            case Constants.ROTATION_0:
               break;
            case Constants.ROTATION_90:
               _loc4_.x = Math.max(0,_loc3_.x);
               break;
            case Constants.ROTATION_180:
               _loc4_.x = Math.max(0,_loc3_.x);
               _loc4_.y = Math.max(0,_loc3_.y);
               break;
            case Constants.ROTATION_270:
               _loc4_.y = Math.max(0,_loc3_.y);
         }
         return _loc2_.add(_loc4_);
      }
      
      public function compareDepth(param1:WorldObject) : int
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:int = 0;
         if(this.isIntersecting(param1))
         {
            _loc5_ = this.getDepthPriority();
            _loc6_ = param1.getDepthPriority();
            if(_loc5_ < _loc6_)
            {
               return 1;
            }
            if(_loc5_ > _loc6_)
            {
               return -1;
            }
         }
         var _loc3_:Number = this.depthIndex;
         var _loc4_:Number = param1.depthIndex;
         if(_loc3_ < _loc4_)
         {
            _loc2_ = -1;
         }
         else if(_loc4_ < _loc3_)
         {
            _loc2_ = 1;
         }
         else
         {
            _loc2_ = 0;
         }
         return _loc2_;
      }
      
      public function onParentChanged() : void
      {
      }
      
      public function toggleAnimation() : void
      {
      }
      
      public function centerOn() : void
      {
         var _loc1_:IsoViewport = GlobalEngine.viewport as IsoViewport;
         if(_loc1_)
         {
            _loc1_.centerOnTilePos(m_position.x,m_position.y);
         }
      }
      
      public function cleanup() : void
      {
         this.m_skipOuterInRedraw = false;
      }
   }
}

