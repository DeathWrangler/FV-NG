package Engine.Classes
{
   import Engine.Constants;
   import Engine.Helpers.Box3D;
   import Engine.Helpers.Vector3;
   import Engine.Interfaces.ITerrainMap;
   import Engine.IsoMath;
   import com.adobe.utils.DictionaryUtil;
   import flash.display.*;
   import flash.geom.*;
   import flash.utils.Dictionary;
   
   public class CollisionMap
   {
      
      private static var m_ignoreObjectsInCollision:Array;
      
      protected static const COLLISIONMAP_COLOR:uint = 16729156;
      
      protected static const COLLISIONMAP_ALPHA:Number = 0.6;
      
      protected var m_width:int;
      
      protected var m_height:int;
      
      protected var m_cells:Array = null;
      
      protected var m_visualCollisionMap:Sprite;
      
      protected var m_pathfinder:Pathfinder;
      
      public function CollisionMap()
      {
         super();
         if(m_ignoreObjectsInCollision == null)
         {
            m_ignoreObjectsInCollision = new Array();
         }
      }
      
      public static function compareCollisionFlags(param1:int, param2:int) : Boolean
      {
         var _loc3_:Boolean = true;
         if((param2 & Constants.COLLISION_AVATAR) << 0 == Constants.COLLISION_AVATAR)
         {
            if((param1 & Constants.COLLISION_ALL_EXCEPT_AVATAR) << 0 == Constants.COLLISION_ALL_EXCEPT_AVATAR)
            {
               _loc3_ = false;
            }
         }
         if((param1 & Constants.COLLISION_OVERLAP) << 0 == Constants.COLLISION_OVERLAP && (param2 & Constants.COLLISION_OVERLAP) << 0 == Constants.COLLISION_OVERLAP)
         {
            _loc3_ = false;
         }
         if((param2 & Constants.COLLISION_SAME_ONLY) << 0 == Constants.COLLISION_SAME_ONLY && (param1 & Constants.COLLISION_SAME_ONLY) << 0 != Constants.COLLISION_SAME_ONLY)
         {
            _loc3_ = false;
         }
         return _loc3_;
      }
      
      public static function getIgnoredCollisionObjects() : Array
      {
         return CollisionMap.m_ignoreObjectsInCollision;
      }
      
      public function dispose() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this.m_cells.length)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_cells[_loc1_].length)
            {
               this.m_cells[_loc1_][_loc2_] = null;
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function initialize(param1:int, param2:int) : void
      {
         var _loc4_:int = 0;
         this.m_width = param1;
         this.m_height = param2;
         this.m_cells = new Array(param1);
         var _loc3_:int = 0;
         while(_loc3_ < param1)
         {
            this.m_cells[_loc3_] = new Array(param2);
            _loc4_ = 0;
            while(_loc4_ < param2)
            {
               this.m_cells[_loc3_][_loc4_] = new CollisionCell(_loc3_,_loc4_);
               _loc4_++;
            }
            _loc3_++;
         }
         this.m_pathfinder = new Pathfinder(this.m_width,this.m_height,this);
      }
      
      public function insertObject(param1:WorldObject) : void
      {
         var _loc2_:Vector3 = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:CollisionCell = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(param1.isCollidable())
         {
            _loc2_ = param1.getSizeNoClone();
            _loc6_ = param1.getPositionNoClone().y;
            _loc7_ = param1.getPositionNoClone().x;
            _loc8_ = _loc6_ + _loc2_.y;
            _loc9_ = _loc7_ + _loc2_.x;
            if(_loc2_.x > 0 && _loc2_.y > 0)
            {
               _loc3_ = _loc7_;
               while(_loc3_ < _loc9_)
               {
                  _loc4_ = _loc6_;
                  while(_loc4_ < _loc8_)
                  {
                     if(this.isValidCellPos(_loc3_,_loc4_))
                     {
                        _loc5_ = this.m_cells[_loc3_][_loc4_] as CollisionCell;
                        _loc5_.addObject(param1);
                        if(_loc3_ > _loc7_ && _loc3_ < _loc9_)
                        {
                           _loc5_.setWall(Constants.DIRECTION_SW,param1);
                           if(_loc3_ > 0)
                           {
                              this.m_cells[_loc3_ - 1][_loc4_].setWall(Constants.DIRECTION_NE,param1);
                           }
                        }
                        if(_loc4_ > _loc6_ && _loc4_ < _loc8_)
                        {
                           _loc5_.setWall(Constants.DIRECTION_SE,param1);
                           if(_loc4_ > 0)
                           {
                              this.m_cells[_loc3_][_loc4_ - 1].setWall(Constants.DIRECTION_NW,param1);
                           }
                        }
                     }
                     _loc4_++;
                  }
                  _loc3_++;
               }
            }
            else
            {
               _loc3_ = _loc7_;
               while(_loc3_ <= _loc9_)
               {
                  _loc4_ = _loc6_;
                  while(_loc4_ <= _loc8_)
                  {
                     if(_loc2_.x == 0)
                     {
                        if(this.isValidCellPos(_loc3_,_loc4_) && _loc4_ < _loc8_)
                        {
                           this.m_cells[_loc3_][_loc4_].setWall(Constants.DIRECTION_SW,param1);
                        }
                        if(this.isValidCellPos(_loc3_ - 1,_loc4_) && _loc4_ < _loc8_)
                        {
                           this.m_cells[_loc3_ - 1][_loc4_].setWall(Constants.DIRECTION_NE,param1);
                        }
                     }
                     if(_loc2_.y == 0)
                     {
                        if(this.isValidCellPos(_loc3_,_loc4_) && _loc3_ < _loc9_)
                        {
                           this.m_cells[_loc3_][_loc4_].setWall(Constants.DIRECTION_SE,param1);
                        }
                        if(this.isValidCellPos(_loc3_,_loc4_ - 1) && _loc3_ < _loc9_)
                        {
                           this.m_cells[_loc3_][_loc4_ - 1].setWall(Constants.DIRECTION_NW,param1);
                        }
                     }
                     _loc4_++;
                  }
                  _loc3_++;
               }
            }
            if(this.m_pathfinder != null)
            {
               this.m_pathfinder.setCollisionMapDirty(_loc7_,_loc9_,_loc6_,_loc8_);
            }
         }
         if(this.m_visualCollisionMap)
         {
            this.drawCollisionMap(this.m_visualCollisionMap);
         }
      }
      
      public function setTerrain(param1:ITerrainMap) : void
      {
         var _loc5_:uint = 0;
         var _loc6_:Tile = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:CollisionCell = null;
         var _loc2_:int = this.m_width / param1.width;
         var _loc3_:int = this.m_height / param1.height;
         var _loc4_:uint = 0;
         while(_loc4_ < param1.width)
         {
            _loc5_ = 0;
            while(_loc5_ < param1.height)
            {
               _loc6_ = param1.tileAt(_loc4_,_loc5_);
               if(param1.isPathable(_loc4_,_loc5_))
               {
                  _loc7_ = 0;
                  while(_loc7_ < _loc2_)
                  {
                     _loc8_ = 0;
                     while(_loc8_ < _loc3_)
                     {
                        _loc9_ = _loc4_ * _loc2_ + _loc7_;
                        _loc10_ = _loc5_ * _loc3_ + _loc8_;
                        _loc11_ = this.m_cells[_loc9_][_loc10_] as CollisionCell;
                        _loc11_.isPathable = true;
                        this.m_pathfinder.setPathable(_loc9_,_loc10_);
                        _loc8_++;
                     }
                     _loc7_++;
                  }
               }
               _loc5_++;
            }
            _loc4_++;
         }
      }
      
      public function isPositionPathable(param1:int, param2:int) : Boolean
      {
         var _loc3_:Boolean = false;
         if(this.m_cells.length > param1 && this.m_cells[param1].length > param2)
         {
            _loc3_ = Boolean(this.m_cells[param1][param2].isPathable);
         }
         return _loc3_;
      }
      
      private function isValidCellPos(param1:int, param2:int) : Boolean
      {
         return param1 >= 0 && param1 < this.m_width && param2 >= 0 && param2 < this.m_height;
      }
      
      public function removeObject(param1:WorldObject) : void
      {
         var _loc2_:Vector3 = null;
         var _loc3_:Vector3 = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1.isCollidable() && param1.isAttached())
         {
            _loc2_ = param1.getAttachSize();
            _loc3_ = param1.getAttachPosition();
            _loc4_ = _loc3_.x;
            while(_loc4_ <= _loc3_.x + _loc2_.x)
            {
               _loc5_ = _loc3_.y;
               while(_loc5_ <= _loc3_.y + _loc2_.y)
               {
                  if(this.isValidCellPos(_loc4_,_loc5_))
                  {
                     this.m_cells[_loc4_][_loc5_].removeObject(param1);
                  }
                  if(this.isValidCellPos(_loc4_ - 1,_loc5_))
                  {
                     this.m_cells[_loc4_ - 1][_loc5_].removeObject(param1);
                  }
                  if(this.isValidCellPos(_loc4_,_loc5_ - 1))
                  {
                     this.m_cells[_loc4_][_loc5_ - 1].removeObject(param1);
                  }
                  _loc5_++;
               }
               _loc4_++;
            }
            if(this.m_pathfinder != null)
            {
               this.m_pathfinder.setCollisionMapDirty(_loc3_.x,_loc3_.x + _loc2_.x,_loc3_.y,_loc3_.y + _loc2_.y);
            }
         }
         if(this.m_visualCollisionMap)
         {
            this.drawCollisionMap(this.m_visualCollisionMap);
         }
      }
      
      public function ignoreObjectForSession(param1:WorldObject) : void
      {
         CollisionMap.m_ignoreObjectsInCollision.push(param1);
      }
      
      public function checkCollision(param1:CollisionLookup, param2:WorldObject = null) : Boolean
      {
         var _loc3_:Boolean = false;
         if(param1.isLine())
         {
            _loc3_ = this.checkCollisionForLine(param1);
         }
         else
         {
            _loc3_ = this.checkCollisionForBox(param1,param2);
         }
         return _loc3_;
      }
      
      private function checkCollisionForBox(param1:CollisionLookup, param2:WorldObject = null) : Boolean
      {
         var _loc6_:int = 0;
         var _loc7_:CollisionCell = null;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = param1.colliders == null;
         var _loc5_:int = param1.startX;
         while(_loc5_ < param1.endX)
         {
            _loc6_ = param1.startY;
            while(_loc6_ < param1.endY)
            {
               if(this.isValidCellPos(_loc5_,_loc6_) && (param1.ignorePathable || this.isPositionPathable(_loc5_,_loc6_)))
               {
                  _loc7_ = this.m_cells[_loc5_][_loc6_];
                  if(param1.startY < _loc6_)
                  {
                     _loc3_ = this.addCollidersToResults(_loc5_,_loc6_,_loc7_.getWalls(Constants.DIRECTION_SE),param1) || _loc3_;
                     if(_loc3_ && _loc4_)
                     {
                        break;
                     }
                  }
                  if(param1.startX < _loc5_)
                  {
                     _loc3_ = this.addCollidersToResults(_loc5_,_loc6_,_loc7_.getWalls(Constants.DIRECTION_SW),param1) || _loc3_;
                     if(_loc3_ && _loc4_)
                     {
                        break;
                     }
                  }
                  _loc3_ = this.addCollidersToResults(_loc5_,_loc6_,_loc7_.items,param1,param2) || _loc3_;
                  if(_loc3_ && _loc4_)
                  {
                     break;
                  }
                  if(_loc3_ && _loc4_)
                  {
                     return _loc3_;
                  }
               }
               else
               {
                  _loc3_ = true;
                  if(_loc4_)
                  {
                     return _loc3_;
                  }
               }
               _loc6_++;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      internal function checkCollisionForCell(param1:CollisionLookup) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:CollisionCell = this.m_cells[param1.startX][param1.startY];
         return this.addCollidersToResults(param1.startX,param1.startY,_loc3_.items,param1,null);
      }
      
      private function checkCollisionForLine(param1:CollisionLookup) : Boolean
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:CollisionCell = null;
         var _loc2_:Boolean = false;
         var _loc7_:Boolean = param1.colliders == null;
         if(param1.startX == param1.endX)
         {
            _loc4_ = param1.startX;
            _loc5_ = param1.startY;
            while(_loc5_ < param1.endY)
            {
               if(this.isValidCellPos(_loc4_,_loc5_))
               {
                  _loc6_ = this.m_cells[_loc4_][_loc5_];
                  _loc3_ = _loc6_.getWalls(Constants.DIRECTION_SW);
                  _loc2_ = this.addCollidersToResults(_loc4_,_loc5_,_loc3_,param1) || _loc2_;
                  if(_loc2_ && _loc7_)
                  {
                     break;
                  }
               }
               else if(this.isValidCellPos(_loc4_ - 1,_loc5_))
               {
                  _loc6_ = this.m_cells[_loc4_ - 1][_loc5_];
                  _loc3_ = _loc6_.getWalls(Constants.DIRECTION_NE);
                  _loc2_ = this.addCollidersToResults(_loc4_,_loc5_,_loc3_,param1) || _loc2_;
                  if(_loc2_ && _loc7_)
                  {
                     break;
                  }
               }
               _loc5_++;
            }
         }
         else
         {
            _loc5_ = param1.startY;
            _loc4_ = param1.startX;
            while(_loc4_ < param1.endX)
            {
               if(this.isValidCellPos(_loc4_,_loc5_))
               {
                  _loc6_ = this.m_cells[_loc4_][_loc5_];
                  _loc3_ = _loc6_.getWalls(Constants.DIRECTION_SE);
                  _loc2_ = this.addCollidersToResults(_loc4_,_loc5_,_loc3_,param1) || _loc2_;
                  if(_loc2_ && _loc7_)
                  {
                     break;
                  }
               }
               else if(this.isValidCellPos(_loc4_,_loc5_ - 1))
               {
                  _loc6_ = this.m_cells[_loc4_][_loc5_ - 1];
                  _loc3_ = _loc6_.getWalls(Constants.DIRECTION_NW);
                  _loc2_ = this.addCollidersToResults(_loc4_,_loc5_,_loc3_,param1) || _loc2_;
                  if(_loc2_ && _loc7_)
                  {
                     break;
                  }
               }
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      private function addCollidersToResults(param1:int, param2:int, param3:Array, param4:CollisionLookup, param5:WorldObject = null) : Boolean
      {
         var _loc9_:WorldObject = null;
         var _loc10_:Boolean = false;
         var _loc11_:Vector3 = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Boolean = false;
         var _loc15_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc7_:int = param4.getFlags(param1,param2);
         var _loc8_:int = 0;
         while(_loc8_ < param3.length)
         {
            _loc9_ = param3[_loc8_] as WorldObject;
            _loc10_ = param4.ignoreObjects == null || param4.ignoreObjects.indexOf(_loc9_) == -1;
            if((_loc10_) && _loc9_ != param5)
            {
               _loc11_ = _loc9_.getPositionNoClone();
               _loc12_ = param1 - _loc11_.x;
               _loc13_ = param2 - _loc11_.y;
               _loc14_ = _loc9_ != null && _loc9_.checkInternalCollision(_loc12_,_loc13_,_loc7_);
               _loc15_ = _loc9_ != null && (param4.colliderTypes & _loc9_.getObjectType()) > 0;
               if(_loc14_ && _loc15_)
               {
                  _loc6_ = true;
                  if(param4.colliders == null)
                  {
                     break;
                  }
                  if(param4.colliders.indexOf(_loc9_) == -1)
                  {
                     param4.colliders.push(_loc9_);
                  }
               }
            }
            _loc8_++;
         }
         return _loc6_;
      }
      
      internal function showCollisionMap(param1:Boolean) : void
      {
         if(this.m_visualCollisionMap == null && param1)
         {
            this.m_visualCollisionMap = new Sprite();
            this.drawCollisionMap(this.m_visualCollisionMap);
            GlobalEngine.viewport.overlayBase.addChild(this.m_visualCollisionMap);
         }
         else if(this.m_visualCollisionMap != null && !param1)
         {
            if(this.m_visualCollisionMap.parent)
            {
               this.m_visualCollisionMap.parent.removeChild(this.m_visualCollisionMap);
            }
            this.m_visualCollisionMap = null;
         }
      }
      
      private function drawCollisionMap(param1:Sprite) : void
      {
         var _loc6_:int = 0;
         var _loc7_:CollisionCell = null;
         var _loc8_:Point = null;
         var _loc2_:Graphics = param1.graphics;
         var _loc3_:Point = IsoMath.getPixelDeltaFromTileDelta(1,0);
         var _loc4_:Point = IsoMath.getPixelDeltaFromTileDelta(0,1);
         _loc2_.clear();
         var _loc5_:int = 0;
         while(_loc5_ < this.m_width)
         {
            _loc6_ = 0;
            while(_loc6_ < this.m_height)
            {
               _loc7_ = this.m_cells[_loc5_][_loc6_] as CollisionCell;
               _loc8_ = IsoMath.tilePosToPixelPos(_loc5_,_loc6_);
               if(_loc7_.items.length)
               {
                  _loc2_.moveTo(_loc8_.x,_loc8_.y);
                  _loc2_.endFill();
               }
               _loc2_.lineStyle(4,COLLISIONMAP_COLOR);
               if(_loc7_.getWalls(Constants.DIRECTION_SW).length > 0)
               {
                  _loc2_.moveTo(_loc8_.x,_loc8_.y);
                  _loc2_.lineTo(_loc8_.x + _loc4_.x,_loc8_.y + _loc4_.y);
               }
               if(_loc7_.getWalls(Constants.DIRECTION_SE).length > 0)
               {
                  _loc2_.moveTo(_loc8_.x,_loc8_.y);
                  _loc2_.lineTo(_loc8_.x + _loc3_.x,_loc8_.y + _loc3_.y);
               }
               if(_loc7_.getWalls(Constants.DIRECTION_NE).length > 0)
               {
                  _loc2_.moveTo(_loc8_.x + _loc3_.x,_loc8_.y + _loc3_.y);
                  _loc2_.lineTo(_loc8_.x + _loc3_.x + _loc4_.x,_loc8_.y + _loc3_.y + _loc4_.y);
               }
               if(_loc7_.getWalls(Constants.DIRECTION_NW).length > 0)
               {
                  _loc2_.moveTo(_loc8_.x + _loc4_.x,_loc8_.y + _loc4_.y);
                  _loc2_.lineTo(_loc8_.x + _loc3_.x + _loc4_.x,_loc8_.y + _loc3_.y + _loc4_.y);
               }
               _loc6_++;
            }
            _loc5_++;
         }
      }
      
      public function getObjectsByPosition(param1:int, param2:int) : Array
      {
         var _loc4_:CollisionCell = null;
         var _loc3_:Array = [];
         if(this.isValidCellPos(param1,param2))
         {
            _loc4_ = this.m_cells[param1][param2];
            _loc3_ = _loc4_.items.concat([]);
         }
         return _loc3_;
      }
      
      public function findCoordinatesForObject(param1:WorldObject) : Array
      {
         var _loc2_:CollisionCell = null;
         var _loc3_:WorldObject = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc4_:Array = new Array();
         _loc4_[0] = -1;
         _loc4_[1] = -1;
         for(_loc5_ in this.m_cells)
         {
            for(_loc6_ in this.m_cells[_loc5_])
            {
               _loc2_ = this.m_cells[_loc5_][_loc6_];
               for(_loc7_ in _loc2_.items)
               {
                  _loc3_ = _loc2_.items[_loc7_];
                  if(_loc3_ as WorldObject == param1)
                  {
                     _loc4_[0] = _loc2_.x;
                     _loc4_[1] = _loc2_.y;
                     return _loc4_;
                  }
               }
            }
         }
         return _loc4_;
      }
      
      public function getIntersectingObjects(param1:Box3D) : Array
      {
         var _loc5_:int = 0;
         var _loc6_:CollisionCell = null;
         var _loc7_:WorldObject = null;
         var _loc2_:Dictionary = new Dictionary();
         var _loc3_:int = param1.min.x;
         while(_loc3_ < param1.max.x)
         {
            _loc5_ = param1.min.y;
            while(_loc5_ < param1.max.y)
            {
               if(this.isValidCellPos(_loc3_,_loc5_))
               {
                  _loc6_ = this.m_cells[_loc3_][_loc5_];
                  for each(_loc7_ in _loc6_.items)
                  {
                     if(_loc2_[_loc7_] == null)
                     {
                        _loc2_[_loc7_] = _loc7_;
                     }
                  }
               }
               _loc5_++;
            }
            _loc3_++;
         }
         return DictionaryUtil.getKeys(_loc2_);
      }
      
      public function getPath(param1:Vector3, param2:Vector3, param3:Array = null, param4:Boolean = false, param5:Number = 0.1, param6:Array = null, param7:WorldObject = null, param8:Boolean = false) : Boolean
      {
         var _loc9_:Boolean = false;
         if(param6 == null)
         {
            param6 = [];
         }
         return this.m_pathfinder.findPath(param1.x,param1.y,param2.x,param2.y,param6,param3,param8,param5);
      }
      
      public function findFirstAvailableCoordsForBox(param1:int, param2:int) : Array
      {
         var _loc3_:Array = new Array();
         _loc3_[0] = -1;
         _loc3_[1] = -1;
         var _loc4_:int = this.m_width / 2;
         var _loc5_:int = this.m_width / 2;
         var _loc6_:int = 0;
         var _loc7_:int = 1;
         var _loc8_:int = 0;
         var _loc9_:CollisionLookup = new CollisionLookup();
         while(_loc4_ < this.m_width && _loc4_ >= 0 && _loc5_ < this.m_height && _loc5_ >= 0)
         {
            _loc9_.startX = _loc4_;
            _loc9_.endX = _loc4_ + param1;
            _loc9_.startY = _loc5_;
            _loc9_.endY = _loc5_ + param2;
            if(!this.checkCollision(_loc9_))
            {
               _loc3_[0] = _loc4_;
               _loc3_[1] = _loc5_;
               return _loc3_;
            }
            if(_loc6_ == 0)
            {
               _loc5_--;
            }
            else if(_loc6_ == 1)
            {
               _loc4_--;
            }
            else if(_loc6_ == 2)
            {
               _loc5_ += 1;
            }
            else if(_loc6_ == 3)
            {
               _loc4_ += 1;
            }
            _loc8_ += 1;
            if(_loc8_ >= _loc7_)
            {
               _loc6_ += 1;
               _loc6_ = _loc6_ % 4;
               _loc8_ = 0;
               if(_loc6_ == 0 || _loc6_ == 2)
               {
                  _loc7_ += 1;
               }
            }
         }
         return _loc3_;
      }
   }
}

class CollisionWall
{
   
   public var x:int;
   
   public var y:int;
   
   public var walls:Array = [];
   
   public function CollisionWall(param1:int, param2:int)
   {
      super();
      this.x = param1;
      this.y = param2;
   }
}
