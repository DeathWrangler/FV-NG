package Engine.Classes
{
   import Engine.Constants;
   import Engine.Helpers.Vector3;
   
   public class Pathfinder
   {
      
      protected static const HEURISTIC:Number = 0.9;
      
      protected static const COLLIDE_DIRTY:int = 2;
      
      protected static const COLLIDE_FALSE:int = 0;
      
      protected static const COLLIDE_TRUE:int = 1;
      
      protected var m_distance:Vector.<Number> = null;
      
      protected var m_score:Vector.<Number> = null;
      
      protected var m_isPathable:Vector.<Boolean> = null;
      
      protected var m_isCollide:Vector.<int> = null;
      
      protected var m_ignoredSpace:Object = null;
      
      protected var m_prevPos:Vector.<Number> = null;
      
      protected var m_openList:Array = null;
      
      protected var m_sizeX:int = -1;
      
      protected var m_sizeY:int = -1;
      
      protected var m_startPos:Number = -1;
      
      protected var m_endPos:Number = -1;
      
      protected var m_endX:int = -1;
      
      protected var m_endY:int = -1;
      
      protected var m_bestLocation:Number = -1;
      
      protected var m_ignoreList:Array;
      
      protected var m_colData:CollisionLookup;
      
      protected var m_colMap:CollisionMap;
      
      protected var m_minDist:Number;
      
      public function Pathfinder(param1:int, param2:int, param3:CollisionMap)
      {
         super();
         this.m_sizeX = param1;
         this.m_sizeY = param2;
         this.m_colMap = param3;
         this.m_distance = new Vector.<Number>(this.m_sizeX * this.m_sizeY,true);
         this.m_score = new Vector.<Number>(this.m_sizeX * this.m_sizeY,true);
         this.m_isPathable = new Vector.<Boolean>(this.m_sizeX * this.m_sizeY,true);
         this.m_isCollide = new Vector.<int>(this.m_sizeX * this.m_sizeY,true);
         this.m_prevPos = new Vector.<Number>(this.m_sizeX * this.m_sizeY,true);
         this.m_ignoredSpace = new Object();
         var _loc4_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < this.m_sizeX * this.m_sizeY)
         {
            this.m_isPathable[_loc4_] = false;
            this.m_isCollide[_loc4_] = COLLIDE_DIRTY;
            _loc4_++;
         }
         this.m_openList = [];
      }
      
      public function setPathable(param1:int, param2:int, param3:Boolean = true) : void
      {
         this.m_isPathable[param2 * this.m_sizeX + param1] = param3;
      }
      
      public function findPath(param1:int, param2:int, param3:int, param4:int, param5:Array, param6:Array = null, param7:Boolean = false, param8:Number = 0.1) : Boolean
      {
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Boolean = false;
         var _loc17_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc15_:int = 0;
         var _loc16_:int = (this.m_sizeX + this.m_sizeY) * 20;
         this.m_minDist = param8;
         this.m_ignoreList = param6;
         this.clear();
         this.setupIgnoredSpace();
         param1 = param1 >= this.m_sizeX ? this.m_sizeX : param1;
         param2 = param2 >= this.m_sizeY ? this.m_sizeY : param2;
         param1 = param1 < 0 ? 0 : param1;
         param2 = param2 < 0 ? 0 : param2;
         param3 = param3 >= this.m_sizeX ? this.m_sizeX : param3;
         param4 = param4 >= this.m_sizeY ? this.m_sizeY : param4;
         param3 = param3 < 0 ? 0 : param3;
         param4 = param4 < 0 ? 0 : param4;
         this.m_endX = param3;
         this.m_endY = param4;
         this.m_startPos = param2 * this.m_sizeX + param1;
         this.m_endPos = param4 * this.m_sizeX + param3;
         this.m_distance[this.m_startPos] = 0;
         this.m_score[this.m_startPos] = 0;
         this.m_isCollide[this.m_startPos] = COLLIDE_DIRTY;
         if(this.m_minDist < 1 && (!this.m_isPathable[this.m_endPos] || !this.canPath(param3,param4)))
         {
            _loc9_ = true;
         }
         this.canPath(param1,param2);
         this.m_openList.push(this.m_startPos);
         while(!_loc9_)
         {
            if(this.m_openList.length == 0)
            {
               if(this.m_bestLocation >= 0)
               {
                  this.pathBack(this.m_bestLocation,this.m_startPos,param5);
               }
               _loc9_ = true;
            }
            else
            {
               _loc11_ = this.m_openList.shift();
               if(this.m_startPos != _loc11_ && (this.m_bestLocation == -1 || this.m_score[this.m_bestLocation] > this.m_score[_loc11_]))
               {
                  this.m_bestLocation = _loc11_;
               }
               _loc12_ = _loc11_ % this.m_sizeX;
               _loc13_ = (_loc11_ - _loc12_) / this.m_sizeX;
               _loc14_ = false;
               _loc17_ = !this.canPath(_loc12_,_loc13_);
               _loc14_ = this.addNode(_loc12_ + 1,_loc13_,_loc11_,_loc17_,1);
               _loc14_ = this.addNode(_loc12_ - 1,_loc13_,_loc11_,_loc17_,1) || _loc14_;
               _loc14_ = this.addNode(_loc12_,_loc13_ + 1,_loc11_,_loc17_,1) || _loc14_;
               _loc14_ = this.addNode(_loc12_,_loc13_ - 1,_loc11_,_loc17_,1) || _loc14_;
               if(!param7)
               {
                  _loc14_ = this.addNode(_loc12_ + 1,_loc13_ + 1,_loc11_,_loc17_,Math.SQRT2,1,1) || _loc14_;
                  _loc14_ = this.addNode(_loc12_ - 1,_loc13_ + 1,_loc11_,_loc17_,Math.SQRT2,-1,1) || _loc14_;
                  _loc14_ = this.addNode(_loc12_ + 1,_loc13_ - 1,_loc11_,_loc17_,Math.SQRT2,1,-1) || _loc14_;
                  _loc14_ = this.addNode(_loc12_ - 1,_loc13_ - 1,_loc11_,_loc17_,Math.SQRT2,-1,-1) || _loc14_;
               }
               if(_loc14_)
               {
                  _loc9_ = true;
                  _loc10_ = true;
                  this.pathBack(this.m_bestLocation,this.m_startPos,param5);
               }
               if(++_loc15_ > _loc16_)
               {
                  this.m_openList = [];
               }
            }
         }
         return _loc10_;
      }
      
      protected function addNode(param1:int, param2:int, param3:Number, param4:Boolean, param5:Number, param6:int = 0, param7:int = 0) : Boolean
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = param1 >= 0 && param1 < this.m_sizeX && param2 >= 0 && param2 < this.m_sizeY;
         var _loc14_:Number = param2 * this.m_sizeX + param1;
         var _loc15_:Boolean = true;
         if(_loc13_ && this.m_score[_loc14_] == -1)
         {
            if(param4)
            {
               _loc15_ = true;
            }
            else if(!this.canPath(param1,param2))
            {
               _loc15_ = false;
            }
            else
            {
               if(param5 != 1)
               {
                  _loc15_ = this.canPath(param1 - param6,param2) && this.canPath(param1,param2 - param7);
               }
               if(_loc15_ && !this.m_isPathable[_loc14_] && this.m_isPathable[param3])
               {
                  _loc15_ = false;
               }
            }
            if(_loc15_)
            {
               this.m_distance[_loc14_] = this.m_distance[param3] + param5;
               _loc11_ = Math.sqrt((param1 - this.m_endX) * (param1 - this.m_endX) + (param2 - this.m_endY) * (param2 - this.m_endY));
               this.m_score[_loc14_] = this.m_distance[_loc14_] + HEURISTIC * _loc11_;
               this.m_prevPos[_loc14_] = param3;
               if(_loc11_ < this.m_minDist || _loc14_ == this.m_endPos)
               {
                  _loc12_ = true;
                  if(_loc14_ == this.m_endPos || this.m_bestLocation == -1 || this.m_score[this.m_bestLocation] - this.m_distance[this.m_bestLocation] > HEURISTIC * _loc11_)
                  {
                     this.m_bestLocation = _loc14_;
                  }
               }
               else
               {
                  _loc8_ = 0;
                  _loc9_ = int(this.m_openList.length);
                  _loc10_ = _loc8_ + _loc9_ >> 1;
                  while(_loc8_ < _loc9_)
                  {
                     if(this.m_score[_loc14_] < this.m_score[this.m_openList[_loc10_]])
                     {
                        _loc9_ = _loc10_;
                        _loc10_ = _loc8_ + _loc9_ >> 1;
                     }
                     else
                     {
                        if(this.m_score[_loc14_] <= this.m_score[this.m_openList[_loc10_]])
                        {
                           break;
                        }
                        _loc8_ = _loc10_ + 1;
                        _loc10_ = _loc8_ + _loc9_ >> 1;
                     }
                  }
                  this.m_openList.splice(_loc10_,0,_loc14_);
               }
            }
         }
         return _loc12_;
      }
      
      protected function canPath(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:Boolean = true;
         var _loc5_:Number = param2 * this.m_sizeX + param1;
         if(this.m_isCollide[_loc5_] == COLLIDE_DIRTY)
         {
            if(this.m_colData == null)
            {
               this.m_colData = new CollisionLookup();
            }
            this.m_colData.init(param1,param2,param1 + 1,param2 + 1);
            this.m_colData.flags = Constants.COLLISION_AVATAR;
            this.m_isCollide[_loc5_] = this.m_colMap.checkCollisionForCell(this.m_colData) ? COLLIDE_TRUE : COLLIDE_FALSE;
         }
         if(this.m_isCollide[_loc5_] == COLLIDE_TRUE)
         {
            if(this.m_ignoredSpace[_loc5_] == COLLIDE_DIRTY)
            {
               if(this.m_colData == null)
               {
                  this.m_colData = new CollisionLookup();
               }
               this.m_colData.init(param1,param2,param1 + 1,param2 + 1);
               this.m_colData.ignoreObjects = this.m_ignoreList;
               this.m_colData.flags = Constants.COLLISION_AVATAR;
               this.m_ignoredSpace[_loc5_] = this.m_colMap.checkCollisionForCell(this.m_colData) ? COLLIDE_TRUE : COLLIDE_FALSE;
            }
            if(this.m_ignoredSpace.hasOwnProperty(_loc5_) && this.m_ignoredSpace[_loc5_] == COLLIDE_FALSE)
            {
               _loc4_ = true;
            }
            else
            {
               _loc4_ = false;
            }
         }
         return _loc4_;
      }
      
      protected function clear() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = this.m_sizeX * this.m_sizeY;
         _loc1_ = 0;
         while(_loc1_ < _loc2_)
         {
            this.m_score[_loc1_] = -1;
            _loc1_++;
         }
         if(this.m_openList.length > 0)
         {
            this.m_openList = [];
         }
         this.m_ignoredSpace = new Object();
         this.m_bestLocation = -1;
      }
      
      protected function pathBack(param1:Number, param2:Number, param3:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Number = param1;
         while(_loc6_ != -1)
         {
            _loc4_ = _loc6_ % this.m_sizeX;
            _loc5_ = (_loc6_ - _loc4_) / this.m_sizeX;
            param3.push(new Vector3(_loc4_,_loc5_));
            if(_loc6_ == param2)
            {
               break;
            }
            _loc6_ = this.m_prevPos[_loc6_];
         }
         param3.reverse();
      }
      
      public function setCollisionMapDirty(param1:int, param2:int, param3:int, param4:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = 0;
         param2 = param2 > this.m_sizeX ? this.m_sizeX : param2;
         param4 = param4 > this.m_sizeY ? this.m_sizeY : param4;
         param1 = param1 < 0 ? 0 : param1;
         param3 = param3 < 0 ? 0 : param3;
         _loc6_ = param3;
         while(_loc6_ < param4)
         {
            _loc7_ = _loc6_ * this.m_sizeX;
            _loc5_ = param1;
            while(_loc5_ < param2)
            {
               this.m_isCollide[_loc7_ + _loc5_] = COLLIDE_DIRTY;
               _loc5_++;
            }
            _loc6_++;
         }
      }
      
      protected function setupIgnoredSpace() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:WorldObject = null;
         var _loc5_:Vector3 = null;
         var _loc6_:Vector3 = null;
         var _loc7_:Number = NaN;
         _loc3_ = 0;
         while(_loc3_ < this.m_ignoreList.length)
         {
            _loc4_ = this.m_ignoreList[_loc3_];
            _loc5_ = _loc4_.getPositionNoClone();
            _loc6_ = _loc4_.getSizeNoClone();
            _loc2_ = _loc5_.y;
            while(_loc2_ < _loc5_.y + _loc6_.y)
            {
               _loc7_ = _loc2_ * this.m_sizeX;
               _loc1_ = _loc5_.x;
               while(_loc1_ < _loc5_.x + _loc6_.x)
               {
                  this.m_ignoredSpace[_loc7_ + _loc1_] = COLLIDE_DIRTY;
                  _loc1_++;
               }
               _loc2_++;
            }
            _loc3_++;
         }
      }
      
      protected function printSurroundings(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = 0;
         var _loc5_:Number = 0;
         param1 = param1 >= this.m_sizeX - 3 ? int(this.m_sizeX - 3) : param1;
         param2 = param2 >= this.m_sizeY - 3 ? int(this.m_sizeY - 3) : param2;
         param1 = param1 < 2 ? 2 : param1;
         param2 = param2 < 2 ? 2 : param2;
         var _loc6_:String = "";
         var _loc7_:String = "";
         var _loc8_:String = "";
         var _loc9_:String = "";
         _loc4_ = int(param2 + 2);
         while(_loc4_ >= param2 - 2)
         {
            _loc5_ = _loc4_ * this.m_sizeX;
            _loc7_ = "";
            _loc9_ = "";
            _loc3_ = param1 - 2;
            while(_loc3_ < param1 + 3)
            {
               _loc7_ += this.m_isCollide[_loc5_ + _loc3_];
               _loc9_ += this.m_ignoredSpace[_loc5_ + _loc3_];
               _loc3_++;
            }
            _loc8_ = _loc8_ + "\n" + _loc9_;
            _loc6_ = _loc6_ + "\n" + _loc7_;
            _loc4_--;
         }
      }
   }
}

