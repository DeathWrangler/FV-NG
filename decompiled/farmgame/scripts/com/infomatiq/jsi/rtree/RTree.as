package com.infomatiq.jsi.rtree
{
   import com.infomatiq.jsi.IntStack;
   import com.infomatiq.jsi.IntVector;
   import com.infomatiq.jsi.PriorityQueue;
   import com.infomatiq.jsi.RectangleUtil;
   import com.infomatiq.jsi.SpatialIndex;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class RTree implements SpatialIndex
   {
      
      public static const INIT_PROP_DEBUG_LOGGING:String = "DebugLogEnabled";
      
      public static const INIT_PROP_CONSISTENCY_CHECKING:String = "ConsistencyCheckingEnabled";
      
      public static const INIT_PROP_MIN_NODE_ENTRIES:String = "MinNodeEntries";
      
      public static const INIT_PROP_MAX_NODE_ENTRIES:String = "MaxNodeEntries";
      
      public static const DEFAULT_MAX_NODE_ENTRIES:int = 50;
      
      public static const DEFAULT_MIN_NODE_ENTRIES:int = 20;
      
      private static var INTERNAL_CONSISTENCY_CHECKING:Boolean = true;
      
      private static var DEBUG_LOG_ENABLED:Boolean = true;
      
      private static const ENTRY_STATUS_ASSIGNED:int = 0;
      
      private static const ENTRY_STATUS_UNASSIGNED:int = 1;
      
      internal var maxNodeEntries:int;
      
      internal var minNodeEntries:int;
      
      private var nodeMap:Dictionary = new Dictionary();
      
      private var entryMap:Dictionary = new Dictionary();
      
      private var entryStatus:Vector.<int> = null;
      
      private var initialEntryStatus:Vector.<int> = null;
      
      private var parents:IntStack = new IntStack();
      
      private var parentsEntry:IntStack = new IntStack();
      
      private var treeHeight:int = 1;
      
      private var rootNodeId:int = 0;
      
      private var m_size:int = 0;
      
      private var highestUsedNodeId:int = this.rootNodeId;
      
      private var deletedNodeIds:IntStack = new IntStack();
      
      private var nearestIds:IntVector = new IntVector();
      
      private var savedValues:IntVector = new IntVector();
      
      private var savedPriority:Number = 0;
      
      private var nearestNIds:SortedList = new SortedList();
      
      private var distanceQueue:PriorityQueue = new PriorityQueue(PriorityQueue.SORT_ORDER_ASCENDING);
      
      public function RTree()
      {
         super();
      }
      
      public function init(param1:Object) : void
      {
         this.maxNodeEntries = DEFAULT_MAX_NODE_ENTRIES;
         this.minNodeEntries = DEFAULT_MIN_NODE_ENTRIES;
         DEBUG_LOG_ENABLED = false;
         INTERNAL_CONSISTENCY_CHECKING = false;
         if(param1 != null)
         {
            if(param1[INIT_PROP_MAX_NODE_ENTRIES])
            {
               this.maxNodeEntries = parseInt(param1[INIT_PROP_MAX_NODE_ENTRIES]);
            }
            if(param1[INIT_PROP_MIN_NODE_ENTRIES])
            {
               this.minNodeEntries = parseInt(param1[INIT_PROP_MIN_NODE_ENTRIES]);
            }
            if(this.maxNodeEntries < 2)
            {
               this.maxNodeEntries = DEFAULT_MAX_NODE_ENTRIES;
            }
            if(this.minNodeEntries < 1 || this.minNodeEntries > this.maxNodeEntries / 2)
            {
               this.minNodeEntries = this.maxNodeEntries / 2;
            }
            if(param1.hasOwnProperty(INIT_PROP_DEBUG_LOGGING))
            {
               DEBUG_LOG_ENABLED = param1[INIT_PROP_DEBUG_LOGGING];
            }
            if(param1.hasOwnProperty(INIT_PROP_CONSISTENCY_CHECKING))
            {
               INTERNAL_CONSISTENCY_CHECKING = param1[INIT_PROP_CONSISTENCY_CHECKING];
            }
         }
         this.entryStatus = new Vector.<int>(this.maxNodeEntries,true);
         this.initialEntryStatus = new Vector.<int>(this.maxNodeEntries,true);
         var _loc2_:int = 0;
         while(_loc2_ < this.maxNodeEntries)
         {
            this.initialEntryStatus[_loc2_] = ENTRY_STATUS_UNASSIGNED;
            _loc2_++;
         }
         var _loc3_:Node = new Node(this.rootNodeId,1,this.maxNodeEntries);
         this.nodeMap[this.rootNodeId] = _loc3_;
         if(DEBUG_LOG_ENABLED)
         {
         }
      }
      
      public function add(param1:Rectangle, param2:int) : Boolean
      {
         if(DEBUG_LOG_ENABLED)
         {
         }
         if(param1.right < param1.left || param1.bottom < param1.top)
         {
            return false;
         }
         this.entryMap[param2] = param1;
         this.addInternal(param1.left,param1.top,param1.right,param1.bottom,param2,1);
         ++this.m_size;
         if(INTERNAL_CONSISTENCY_CHECKING)
         {
            this.checkConsistency();
         }
         return true;
      }
      
      private function addInternal(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:int) : void
      {
         var _loc10_:int = 0;
         var _loc11_:Node = null;
         var _loc12_:Node = null;
         var _loc7_:Node = this.chooseNode(param1,param2,param3,param4,param6);
         var _loc8_:Node = null;
         if(_loc7_.entryCount < this.maxNodeEntries)
         {
            _loc7_.addEntry(param1,param2,param3,param4,param5);
         }
         else
         {
            _loc8_ = this.splitNode(_loc7_,param1,param2,param3,param4,param5);
         }
         var _loc9_:Node = this.adjustTree(_loc7_,_loc8_);
         if(_loc9_ != null)
         {
            _loc10_ = this.rootNodeId;
            _loc11_ = this.getNode(_loc10_);
            this.rootNodeId = this.getNextNodeId();
            ++this.treeHeight;
            _loc12_ = new Node(this.rootNodeId,this.treeHeight,this.maxNodeEntries);
            _loc12_.addEntry(_loc9_.mbrMinX,_loc9_.mbrMinY,_loc9_.mbrMaxX,_loc9_.mbrMaxY,_loc9_.nodeId);
            _loc12_.addEntry(_loc11_.mbrMinX,_loc11_.mbrMinY,_loc11_.mbrMaxX,_loc11_.mbrMaxY,_loc11_.nodeId);
            this.nodeMap[this.rootNodeId] = _loc12_;
         }
      }
      
      public function remove(param1:Rectangle, param2:int) : Boolean
      {
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         this.parents.reset();
         this.parents.push(this.rootNodeId);
         this.parentsEntry.reset();
         this.parentsEntry.push(-1);
         var _loc3_:Node = null;
         var _loc4_:int = -1;
         while(_loc4_ == -1 && this.parents.size() > 0)
         {
            _loc3_ = this.getNode(this.parents.peek());
            _loc6_ = this.parentsEntry.peek() + 1;
            if(!_loc3_.isLeaf())
            {
               if(DEBUG_LOG_ENABLED)
               {
               }
               _loc7_ = false;
               _loc8_ = _loc6_;
               while(_loc8_ < _loc3_.entryCount)
               {
                  if(RectangleUtil.contains(_loc3_.entriesMinX[_loc8_],_loc3_.entriesMinY[_loc8_],_loc3_.entriesMaxX[_loc8_],_loc3_.entriesMaxY[_loc8_],param1.left,param1.top,param1.right,param1.bottom))
                  {
                     this.parents.push(_loc3_.ids[_loc8_]);
                     this.parentsEntry.pop();
                     this.parentsEntry.push(_loc8_);
                     this.parentsEntry.push(-1);
                     _loc7_ = true;
                     break;
                  }
                  _loc8_++;
               }
               if(_loc7_)
               {
                  continue;
               }
            }
            else
            {
               _loc4_ = _loc3_.findEntry(param1.left,param1.top,param1.right,param1.bottom,param2);
            }
            this.parents.pop();
            this.parentsEntry.pop();
         }
         if(_loc4_ != -1)
         {
            _loc3_.deleteEntry(_loc4_);
            this.condenseTree(_loc3_);
            --this.m_size;
            delete this.entryMap[param2];
         }
         var _loc5_:Node = this.getNode(this.rootNodeId);
         while(_loc5_.entryCount == 1 && this.treeHeight > 1)
         {
            this.deletedNodeIds.push(this.rootNodeId);
            _loc5_.entryCount = 0;
            this.rootNodeId = _loc5_.ids[0];
            --this.treeHeight;
            _loc5_ = this.getNode(this.rootNodeId);
         }
         if(this.m_size == 0)
         {
            _loc5_.mbrMinX = Number.MAX_VALUE;
            _loc5_.mbrMinY = Number.MAX_VALUE;
            _loc5_.mbrMaxX = -Number.MAX_VALUE;
            _loc5_.mbrMaxY = -Number.MAX_VALUE;
         }
         if(INTERNAL_CONSISTENCY_CHECKING)
         {
            this.checkConsistency();
         }
         return _loc4_ != -1;
      }
      
      public function nearest(param1:Point, param2:Number, param3:Function = null) : Vector.<int>
      {
         var _loc4_:Node = this.getNode(this.rootNodeId);
         var _loc5_:Number = param2 * param2;
         this.nearestInternal(param1,_loc4_,_loc5_);
         var _loc6_:Vector.<int> = this.nearestIds.toVector();
         this.nearestIds.reset();
         if(param3 !== null)
         {
            _loc6_.forEach(param3);
         }
         return _loc6_;
      }
      
      private function createNearestNDistanceQueue(param1:Point, param2:int, param3:Number) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Node = null;
         var _loc7_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         this.distanceQueue.reset();
         this.distanceQueue.setSortOrder(PriorityQueue.SORT_ORDER_DESCENDING);
         if(param2 <= 0)
         {
            return;
         }
         this.parents.reset();
         this.parents.push(this.rootNodeId);
         this.parentsEntry.reset();
         this.parentsEntry.push(-1);
         var _loc4_:Number = param3 * param3;
         while(this.parents.size() > 0)
         {
            _loc6_ = this.getNode(this.parents.peek());
            _loc7_ = this.parentsEntry.peek() + 1;
            if(!_loc6_.isLeaf())
            {
               _loc8_ = false;
               _loc5_ = _loc7_;
               while(_loc5_ < _loc6_.entryCount)
               {
                  if(RectangleUtil.distanceSq(_loc6_.entriesMinX[_loc5_],_loc6_.entriesMinY[_loc5_],_loc6_.entriesMaxX[_loc5_],_loc6_.entriesMaxY[_loc5_],param1.x,param1.y) <= _loc4_)
                  {
                     this.parents.push(_loc6_.ids[_loc5_]);
                     this.parentsEntry.pop();
                     this.parentsEntry.push(_loc5_);
                     this.parentsEntry.push(-1);
                     _loc8_ = true;
                     break;
                  }
                  _loc5_++;
               }
               if(_loc8_)
               {
                  continue;
               }
            }
            else
            {
               _loc5_ = 0;
               while(_loc5_ < _loc6_.entryCount)
               {
                  _loc9_ = RectangleUtil.distanceSq(_loc6_.entriesMinX[_loc5_],_loc6_.entriesMinY[_loc5_],_loc6_.entriesMaxX[_loc5_],_loc6_.entriesMaxY[_loc5_],param1.x,param1.y);
                  _loc10_ = _loc6_.ids[_loc5_];
                  if(_loc9_ <= _loc4_)
                  {
                     this.distanceQueue.insert(_loc10_,_loc9_);
                     while(this.distanceQueue.size() > param2)
                     {
                        _loc11_ = this.distanceQueue.getValue();
                        _loc12_ = this.distanceQueue.getPriority();
                        this.distanceQueue.pop();
                        if(_loc12_ == this.distanceQueue.getPriority())
                        {
                           this.savedValues.add(_loc11_);
                           this.savedPriority = _loc12_;
                        }
                        else
                        {
                           this.savedValues.reset();
                        }
                     }
                     if(this.savedValues.size() > 0 && this.savedPriority == this.distanceQueue.getPriority())
                     {
                        _loc13_ = 0;
                        while(_loc13_ < this.savedValues.size())
                        {
                           this.distanceQueue.insert(this.savedValues.get(_loc13_),this.savedPriority);
                           _loc13_++;
                        }
                        this.savedValues.reset();
                     }
                     if(this.distanceQueue.getPriority() < _loc4_ && this.distanceQueue.size() >= param2)
                     {
                        _loc4_ = this.distanceQueue.getPriority();
                     }
                  }
                  _loc5_++;
               }
            }
            this.parents.pop();
            this.parentsEntry.pop();
         }
      }
      
      public function nearestNUnsorted(param1:Point, param2:int, param3:Number, param4:Function = null) : Vector.<int>
      {
         this.createNearestNDistanceQueue(param1,param2,param3);
         return this.nearestNResult(param4);
      }
      
      public function nearestN(param1:Point, param2:int, param3:Number, param4:Function = null) : Vector.<int>
      {
         this.createNearestNDistanceQueue(param1,param2,param3);
         this.distanceQueue.setSortOrder(PriorityQueue.SORT_ORDER_ASCENDING);
         return this.nearestNResult(param4);
      }
      
      private function nearestNResult(param1:Function) : Vector.<int>
      {
         var _loc2_:Vector.<int> = new Vector.<int>(this.distanceQueue.size(),true);
         var _loc3_:* = 0;
         while(this.distanceQueue.size() > 0)
         {
            var _loc4_:Number;
            _loc2_[_loc4_ = _loc3_++] = this.distanceQueue.pop();
         }
         if(param1 !== null)
         {
            _loc2_.forEach(param1);
         }
         return _loc2_;
      }
      
      public function intersects(param1:Rectangle, param2:Function) : void
      {
         var _loc3_:Node = this.getNode(this.rootNodeId);
         this.intersectsInternal(param1,_loc3_,param2);
      }
      
      public function contains(param1:Rectangle, param2:Function = null) : Vector.<int>
      {
         var _loc3_:int = 0;
         var _loc5_:Node = null;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         this.parents.reset();
         this.parents.push(this.rootNodeId);
         this.parentsEntry.reset();
         this.parentsEntry.push(-1);
         var _loc4_:Vector.<int> = new Vector.<int>();
         while(this.parents.size() > 0)
         {
            _loc5_ = this.getNode(this.parents.peek());
            _loc6_ = this.parentsEntry.peek() + 1;
            if(_loc5_.isLeaf())
            {
               _loc3_ = 0;
               while(true)
               {
                  if(_loc3_ < _loc5_.entryCount)
                  {
                     if(RectangleUtil.contains(param1.left,param1.top,param1.right,param1.bottom,_loc5_.entriesMinX[_loc3_],_loc5_.entriesMinY[_loc3_],_loc5_.entriesMaxX[_loc3_],_loc5_.entriesMaxY[_loc3_]))
                     {
                        if(param2 != null && !param2.call(null,_loc5_.ids[_loc3_]))
                        {
                           break;
                        }
                        _loc4_.push(_loc5_.ids[_loc3_]);
                     }
                     continue;
                  }
                  _loc3_++;
               }
               break;
            }
            _loc7_ = false;
            _loc3_ = _loc6_;
            while(_loc3_ < _loc5_.entryCount)
            {
               if(RectangleUtil.intersects(param1.left,param1.top,param1.right,param1.bottom,_loc5_.entriesMinX[_loc3_],_loc5_.entriesMinY[_loc3_],_loc5_.entriesMaxX[_loc3_],_loc5_.entriesMaxY[_loc3_]))
               {
                  this.parents.push(_loc5_.ids[_loc3_]);
                  this.parentsEntry.pop();
                  this.parentsEntry.push(_loc3_);
                  this.parentsEntry.push(-1);
                  _loc7_ = true;
                  break;
               }
               _loc3_++;
            }
            if(_loc7_)
            {
               continue;
            }
            this.parents.pop();
            this.parentsEntry.pop();
         }
         return _loc4_;
      }
      
      public function containing(param1:Rectangle, param2:Function = null) : Vector.<int>
      {
         var _loc3_:int = 0;
         var _loc5_:Node = null;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         this.parents.reset();
         this.parents.push(this.rootNodeId);
         this.parentsEntry.reset();
         this.parentsEntry.push(-1);
         var _loc4_:Vector.<int> = new Vector.<int>();
         while(this.parents.size() > 0)
         {
            _loc5_ = this.getNode(this.parents.peek());
            _loc6_ = this.parentsEntry.peek() + 1;
            if(_loc5_.isLeaf())
            {
               _loc3_ = 0;
               while(true)
               {
                  if(_loc3_ < _loc5_.entryCount)
                  {
                     if(RectangleUtil.contains(_loc5_.entriesMinX[_loc3_],_loc5_.entriesMinY[_loc3_],_loc5_.entriesMaxX[_loc3_],_loc5_.entriesMaxY[_loc3_],param1.left,param1.top,param1.right,param1.bottom))
                     {
                        if(param2 != null && !param2.call(null,_loc5_.ids[_loc3_]))
                        {
                           break;
                        }
                        _loc4_.push(_loc5_.ids[_loc3_]);
                     }
                     continue;
                  }
                  _loc3_++;
               }
               break;
            }
            _loc7_ = false;
            _loc3_ = _loc6_;
            while(_loc3_ < _loc5_.entryCount)
            {
               if(RectangleUtil.intersects(param1.left,param1.top,param1.right,param1.bottom,_loc5_.entriesMinX[_loc3_],_loc5_.entriesMinY[_loc3_],_loc5_.entriesMaxX[_loc3_],_loc5_.entriesMaxY[_loc3_]))
               {
                  this.parents.push(_loc5_.ids[_loc3_]);
                  this.parentsEntry.pop();
                  this.parentsEntry.push(_loc3_);
                  this.parentsEntry.push(-1);
                  _loc7_ = true;
                  break;
               }
               _loc3_++;
            }
            if(_loc7_)
            {
               continue;
            }
            this.parents.pop();
            this.parentsEntry.pop();
         }
         return _loc4_;
      }
      
      public function size() : int
      {
         return this.m_size;
      }
      
      public function getBounds() : Rectangle
      {
         var _loc1_:Rectangle = null;
         var _loc2_:Node = this.getNode(this.getRootNodeId());
         if(_loc2_ != null && _loc2_.entryCount > 0)
         {
            _loc1_ = new Rectangle();
            _loc1_.left = _loc2_.mbrMinX;
            _loc1_.top = _loc2_.mbrMinY;
            _loc1_.right = _loc2_.mbrMaxX;
            _loc1_.bottom = _loc2_.mbrMaxY;
         }
         return _loc1_;
      }
      
      private function getNextNodeId() : int
      {
         var _loc1_:int = 0;
         if(this.deletedNodeIds.size() > 0)
         {
            _loc1_ = this.deletedNodeIds.pop();
         }
         else
         {
            _loc1_ = 1 + this.highestUsedNodeId++;
         }
         return _loc1_;
      }
      
      internal function getNode(param1:int) : Node
      {
         return this.nodeMap[param1];
      }
      
      public function containsNode(param1:int) : Boolean
      {
         return this.nodeMap[param1] != null;
      }
      
      public function getHighestUsedNodeId() : int
      {
         return this.highestUsedNodeId;
      }
      
      public function getRootNodeId() : int
      {
         return this.rootNodeId;
      }
      
      public function getEntryRect(param1:int) : Rectangle
      {
         return this.entryMap[param1] as Rectangle;
      }
      
      public function containsEntry(param1:int) : Boolean
      {
         return this.getEntryRect(param1) != null;
      }
      
      private function splitNode(param1:Node, param2:Number, param3:Number, param4:Number, param5:Number, param6:int) : Node
      {
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Rectangle = null;
         var _loc15_:Rectangle = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc7_:Number = 0;
         if(DEBUG_LOG_ENABLED)
         {
            _loc10_ = Math.min(param1.mbrMinX,param2);
            _loc11_ = Math.min(param1.mbrMinY,param3);
            _loc12_ = Math.max(param1.mbrMaxX,param4);
            _loc13_ = Math.max(param1.mbrMaxY,param5);
            _loc7_ = (_loc12_ - _loc10_) * (_loc13_ - _loc11_);
         }
         IntVector.copyVector(this.initialEntryStatus,this.entryStatus,0,0,this.maxNodeEntries);
         var _loc8_:Node = null;
         _loc8_ = new Node(this.getNextNodeId(),param1.level,this.maxNodeEntries);
         this.nodeMap[_loc8_.nodeId] = _loc8_;
         this.pickSeeds(param1,param2,param3,param4,param5,param6,_loc8_);
         while(param1.entryCount + _loc8_.entryCount < this.maxNodeEntries + 1)
         {
            if(this.maxNodeEntries + 1 - _loc8_.entryCount == this.minNodeEntries)
            {
               _loc9_ = 0;
               while(_loc9_ < this.maxNodeEntries)
               {
                  if(this.entryStatus[_loc9_] == ENTRY_STATUS_UNASSIGNED)
                  {
                     this.entryStatus[_loc9_] = ENTRY_STATUS_ASSIGNED;
                     if(param1.entriesMinX[_loc9_] < param1.mbrMinX)
                     {
                        param1.mbrMinX = param1.entriesMinX[_loc9_];
                     }
                     if(param1.entriesMinY[_loc9_] < param1.mbrMinY)
                     {
                        param1.mbrMinY = param1.entriesMinY[_loc9_];
                     }
                     if(param1.entriesMaxX[_loc9_] > param1.mbrMaxX)
                     {
                        param1.mbrMaxX = param1.entriesMaxX[_loc9_];
                     }
                     if(param1.entriesMaxY[_loc9_] > param1.mbrMaxY)
                     {
                        param1.mbrMaxY = param1.entriesMaxY[_loc9_];
                     }
                     ++param1.entryCount;
                  }
                  _loc9_++;
               }
               break;
            }
            if(this.maxNodeEntries + 1 - param1.entryCount == this.minNodeEntries)
            {
               _loc9_ = 0;
               while(_loc9_ < this.maxNodeEntries)
               {
                  if(this.entryStatus[_loc9_] == ENTRY_STATUS_UNASSIGNED)
                  {
                     this.entryStatus[_loc9_] = ENTRY_STATUS_ASSIGNED;
                     _loc8_.addEntry(param1.entriesMinX[_loc9_],param1.entriesMinY[_loc9_],param1.entriesMaxX[_loc9_],param1.entriesMaxY[_loc9_],param1.ids[_loc9_]);
                     param1.ids[_loc9_] = -1;
                  }
                  _loc9_++;
               }
               break;
            }
            this.pickNext(param1,_loc8_);
         }
         param1.reorganize(this);
         if(INTERNAL_CONSISTENCY_CHECKING)
         {
            _loc14_ = RectangleUtil.create(param1.mbrMinX,param1.mbrMinY,param1.mbrMaxX,param1.mbrMaxY);
            if(RectangleUtil.equals(_loc14_,this.calculateMBR(param1)))
            {
            }
            _loc15_ = RectangleUtil.create(_loc8_.mbrMinX,_loc8_.mbrMinY,_loc8_.mbrMaxX,_loc8_.mbrMaxY);
            if(RectangleUtil.equals(_loc15_,this.calculateMBR(_loc8_)))
            {
            }
         }
         if(DEBUG_LOG_ENABLED)
         {
            _loc16_ = RectangleUtil.area(param1.mbrMinX,param1.mbrMinY,param1.mbrMaxX,param1.mbrMaxY) + RectangleUtil.area(_loc8_.mbrMinX,_loc8_.mbrMinY,_loc8_.mbrMaxX,_loc8_.mbrMaxY);
            _loc17_ = 100 * (_loc16_ - _loc7_) / _loc7_;
         }
         return _loc8_;
      }
      
      private function pickSeeds(param1:Node, param2:Number, param3:Number, param4:Number, param5:Number, param6:int, param7:Node) : void
      {
         var _loc17_:int = 0;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc8_:Number = -1;
         var _loc9_:int = -1;
         var _loc10_:int = -1;
         if(param2 < param1.mbrMinX)
         {
            param1.mbrMinX = param2;
         }
         if(param3 < param1.mbrMinY)
         {
            param1.mbrMinY = param3;
         }
         if(param4 > param1.mbrMaxX)
         {
            param1.mbrMaxX = param4;
         }
         if(param5 > param1.mbrMaxY)
         {
            param1.mbrMaxY = param5;
         }
         var _loc11_:Number = param1.mbrMaxX - param1.mbrMinX;
         var _loc12_:Number = param1.mbrMaxY - param1.mbrMinY;
         if(DEBUG_LOG_ENABLED)
         {
         }
         var _loc13_:Number = param2;
         var _loc14_:int = -1;
         var _loc15_:Number = param4;
         var _loc16_:int = -1;
         _loc17_ = 0;
         while(_loc17_ < param1.entryCount)
         {
            _loc18_ = param1.entriesMinX[_loc17_];
            if(_loc18_ >= _loc13_)
            {
               _loc13_ = _loc18_;
               _loc14_ = _loc17_;
            }
            else
            {
               _loc19_ = param1.entriesMaxX[_loc17_];
               if(_loc19_ <= _loc15_)
               {
                  _loc15_ = _loc19_;
                  _loc16_ = _loc17_;
               }
            }
            _loc20_ = _loc11_ == 0 ? 1 : (_loc13_ - _loc15_) / _loc11_;
            if(_loc20_ > 1 || _loc20_ < -1)
            {
            }
            if(DEBUG_LOG_ENABLED)
            {
            }
            if(_loc20_ >= _loc8_)
            {
               _loc9_ = _loc14_;
               _loc10_ = _loc16_;
               _loc8_ = _loc20_;
            }
            _loc17_++;
         }
         _loc13_ = param3;
         _loc14_ = -1;
         _loc15_ = param5;
         _loc16_ = -1;
         _loc17_ = 0;
         while(_loc17_ < param1.entryCount)
         {
            _loc18_ = param1.entriesMinY[_loc17_];
            if(_loc18_ >= _loc13_)
            {
               _loc13_ = _loc18_;
               _loc14_ = _loc17_;
            }
            else
            {
               _loc19_ = param1.entriesMaxY[_loc17_];
               if(_loc19_ <= _loc15_)
               {
                  _loc15_ = _loc19_;
                  _loc16_ = _loc17_;
               }
            }
            _loc20_ = _loc12_ == 0 ? 1 : (_loc13_ - _loc15_) / _loc12_;
            if(_loc20_ > 1 || _loc20_ < -1)
            {
            }
            if(DEBUG_LOG_ENABLED)
            {
            }
            if(_loc20_ >= _loc8_)
            {
               _loc9_ = _loc14_;
               _loc10_ = _loc16_;
               _loc8_ = _loc20_;
            }
            _loc17_++;
         }
         if(_loc9_ == _loc10_)
         {
            _loc9_ = -1;
            _loc21_ = param3;
            _loc10_ = 0;
            _loc22_ = param1.entriesMaxX[0];
            _loc17_ = 1;
            while(_loc17_ < param1.entryCount)
            {
               if(param1.entriesMinY[_loc17_] < _loc21_)
               {
                  _loc21_ = param1.entriesMinY[_loc17_];
                  _loc9_ = _loc17_;
               }
               else if(param1.entriesMaxX[_loc17_] > _loc22_)
               {
                  _loc22_ = param1.entriesMaxX[_loc17_];
                  _loc10_ = _loc17_;
               }
               _loc17_++;
            }
         }
         if(_loc9_ == -1)
         {
            param7.addEntry(param2,param3,param4,param5,param6);
         }
         else
         {
            param7.addEntry(param1.entriesMinX[_loc9_],param1.entriesMinY[_loc9_],param1.entriesMaxX[_loc9_],param1.entriesMaxY[_loc9_],param1.ids[_loc9_]);
            param1.ids[_loc9_] = -1;
            param1.entriesMinX[_loc9_] = param2;
            param1.entriesMinY[_loc9_] = param3;
            param1.entriesMaxX[_loc9_] = param4;
            param1.entriesMaxY[_loc9_] = param5;
            param1.ids[_loc9_] = param6;
         }
         if(_loc10_ == -1)
         {
            _loc10_ = _loc9_;
         }
         this.entryStatus[_loc10_] = ENTRY_STATUS_ASSIGNED;
         param1.entryCount = 1;
         param1.mbrMinX = param1.entriesMinX[_loc10_];
         param1.mbrMinY = param1.entriesMinY[_loc10_];
         param1.mbrMaxX = param1.entriesMaxX[_loc10_];
         param1.mbrMaxY = param1.entriesMaxY[_loc10_];
      }
      
      private function pickNext(param1:Node, param2:Node) : int
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc3_:Number = Number.NEGATIVE_INFINITY;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         _loc3_ = Number.NEGATIVE_INFINITY;
         if(DEBUG_LOG_ENABLED)
         {
         }
         var _loc6_:int = 0;
         while(_loc6_ < this.maxNodeEntries)
         {
            if(this.entryStatus[_loc6_] == ENTRY_STATUS_UNASSIGNED)
            {
               if(param1.ids[_loc6_] == -1)
               {
               }
               _loc7_ = RectangleUtil.enlargement(param1.mbrMinX,param1.mbrMinY,param1.mbrMaxX,param1.mbrMaxY,param1.entriesMinX[_loc6_],param1.entriesMinY[_loc6_],param1.entriesMaxX[_loc6_],param1.entriesMaxY[_loc6_]);
               _loc8_ = RectangleUtil.enlargement(param2.mbrMinX,param2.mbrMinY,param2.mbrMaxX,param2.mbrMaxY,param1.entriesMinX[_loc6_],param1.entriesMinY[_loc6_],param1.entriesMaxX[_loc6_],param1.entriesMaxY[_loc6_]);
               _loc9_ = Math.abs(_loc7_ - _loc8_);
               if(_loc9_ > _loc3_)
               {
                  _loc4_ = _loc6_;
                  if(_loc7_ < _loc8_)
                  {
                     _loc5_ = 0;
                  }
                  else if(_loc8_ < _loc7_)
                  {
                     _loc5_ = 1;
                  }
                  else if(RectangleUtil.area(param1.mbrMinX,param1.mbrMinY,param1.mbrMaxX,param1.mbrMaxY) < RectangleUtil.area(param2.mbrMinX,param2.mbrMinY,param2.mbrMaxX,param2.mbrMaxY))
                  {
                     _loc5_ = 0;
                  }
                  else if(RectangleUtil.area(param2.mbrMinX,param2.mbrMinY,param2.mbrMaxX,param2.mbrMaxY) < RectangleUtil.area(param1.mbrMinX,param1.mbrMinY,param1.mbrMaxX,param1.mbrMaxY))
                  {
                     _loc5_ = 1;
                  }
                  else if(param2.entryCount < this.maxNodeEntries / 2)
                  {
                     _loc5_ = 0;
                  }
                  else
                  {
                     _loc5_ = 1;
                  }
                  _loc3_ = _loc9_;
               }
               if(DEBUG_LOG_ENABLED)
               {
               }
            }
            _loc6_++;
         }
         this.entryStatus[_loc4_] = ENTRY_STATUS_ASSIGNED;
         if(_loc5_ == 0)
         {
            if(param1.entriesMinX[_loc4_] < param1.mbrMinX)
            {
               param1.mbrMinX = param1.entriesMinX[_loc4_];
            }
            if(param1.entriesMinY[_loc4_] < param1.mbrMinY)
            {
               param1.mbrMinY = param1.entriesMinY[_loc4_];
            }
            if(param1.entriesMaxX[_loc4_] > param1.mbrMaxX)
            {
               param1.mbrMaxX = param1.entriesMaxX[_loc4_];
            }
            if(param1.entriesMaxY[_loc4_] > param1.mbrMaxY)
            {
               param1.mbrMaxY = param1.entriesMaxY[_loc4_];
            }
            ++param1.entryCount;
         }
         else
         {
            param2.addEntry(param1.entriesMinX[_loc4_],param1.entriesMinY[_loc4_],param1.entriesMaxX[_loc4_],param1.entriesMaxY[_loc4_],param1.ids[_loc4_]);
            param1.ids[_loc4_] = -1;
         }
         return _loc4_;
      }
      
      private function nearestInternal(param1:Point, param2:Node, param3:Number) : Number
      {
         var _loc5_:Number = NaN;
         var _loc4_:int = 0;
         while(_loc4_ < param2.entryCount)
         {
            _loc5_ = RectangleUtil.distanceSq(param2.entriesMinX[_loc4_],param2.entriesMinY[_loc4_],param2.entriesMaxX[_loc4_],param2.entriesMaxY[_loc4_],param1.x,param1.y);
            if(param2.isLeaf())
            {
               if(_loc5_ < param3)
               {
                  param3 = _loc5_;
                  this.nearestIds.reset();
               }
               if(_loc5_ <= param3)
               {
                  this.nearestIds.add(param2.ids[_loc4_]);
               }
            }
            else if(_loc5_ <= param3)
            {
               param3 = this.nearestInternal(param1,this.getNode(param2.ids[_loc4_]),param3);
            }
            _loc4_++;
         }
         return param3;
      }
      
      private function intersectsInternal(param1:Rectangle, param2:Node, param3:Function) : Boolean
      {
         var _loc5_:Node = null;
         var _loc4_:int = 0;
         while(_loc4_ < param2.entryCount)
         {
            if(RectangleUtil.intersects(param1.left,param1.top,param1.right,param1.bottom,param2.entriesMinX[_loc4_],param2.entriesMinY[_loc4_],param2.entriesMaxX[_loc4_],param2.entriesMaxY[_loc4_]))
            {
               if(param2.isLeaf())
               {
                  if(!param3.call(null,param2.ids[_loc4_]))
                  {
                     return false;
                  }
               }
               else
               {
                  _loc5_ = this.getNode(param2.ids[_loc4_]);
                  if(!this.intersectsInternal(param1,_loc5_,param3))
                  {
                     return false;
                  }
               }
            }
            _loc4_++;
         }
         return true;
      }
      
      private function condenseTree(param1:Node) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Node = null;
         var _loc11_:int = 0;
         var _loc2_:Node = param1;
         var _loc3_:Node = null;
         var _loc4_:int = 0;
         var _loc5_:IntStack = new IntStack();
         while(_loc2_.level != this.treeHeight)
         {
            _loc3_ = this.getNode(this.parents.pop());
            _loc4_ = this.parentsEntry.pop();
            if(_loc2_.entryCount < this.minNodeEntries)
            {
               _loc3_.deleteEntry(_loc4_);
               _loc5_.push(_loc2_.nodeId);
            }
            else if(_loc2_.mbrMinX != _loc3_.entriesMinX[_loc4_] || _loc2_.mbrMinY != _loc3_.entriesMinY[_loc4_] || _loc2_.mbrMaxX != _loc3_.entriesMaxX[_loc4_] || _loc2_.mbrMaxY != _loc3_.entriesMaxY[_loc4_])
            {
               _loc6_ = _loc3_.entriesMinX[_loc4_];
               _loc7_ = _loc3_.entriesMinY[_loc4_];
               _loc8_ = _loc3_.entriesMaxX[_loc4_];
               _loc9_ = _loc3_.entriesMaxY[_loc4_];
               _loc3_.entriesMinX[_loc4_] = _loc2_.mbrMinX;
               _loc3_.entriesMinY[_loc4_] = _loc2_.mbrMinY;
               _loc3_.entriesMaxX[_loc4_] = _loc2_.mbrMaxX;
               _loc3_.entriesMaxY[_loc4_] = _loc2_.mbrMaxY;
               _loc3_.recalculateMBRIfInfluencedBy(_loc6_,_loc7_,_loc8_,_loc9_);
            }
            _loc2_ = _loc3_;
         }
         while(_loc5_.size() > 0)
         {
            _loc10_ = this.getNode(_loc5_.pop());
            _loc11_ = 0;
            while(_loc11_ < _loc10_.entryCount)
            {
               this.addInternal(_loc10_.entriesMinX[_loc11_],_loc10_.entriesMinY[_loc11_],_loc10_.entriesMaxX[_loc11_],_loc10_.entriesMaxY[_loc11_],_loc10_.ids[_loc11_],_loc10_.level);
               _loc10_.ids[_loc11_] = -1;
               _loc11_++;
            }
            _loc10_.entryCount = 0;
            this.deletedNodeIds.push(_loc10_.nodeId);
         }
      }
      
      private function chooseNode(param1:Number, param2:Number, param3:Number, param4:Number, param5:int) : Node
      {
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc6_:Node = this.getNode(this.rootNodeId);
         this.parents.reset();
         this.parentsEntry.reset();
         var _loc7_:Node = null;
         while(true)
         {
            if(_loc6_ == null)
            {
            }
            if(_loc6_.level == param5)
            {
               break;
            }
            _loc8_ = RectangleUtil.enlargement(_loc6_.entriesMinX[0],_loc6_.entriesMinY[0],_loc6_.entriesMaxX[0],_loc6_.entriesMaxY[0],param1,param2,param3,param4);
            _loc9_ = 0;
            _loc10_ = 1;
            while(_loc10_ < _loc6_.entryCount)
            {
               _loc11_ = _loc6_.entriesMinX[_loc10_];
               _loc12_ = _loc6_.entriesMinY[_loc10_];
               _loc13_ = _loc6_.entriesMaxX[_loc10_];
               _loc14_ = _loc6_.entriesMaxY[_loc10_];
               _loc15_ = RectangleUtil.enlargement(_loc11_,_loc12_,_loc13_,_loc14_,param1,param2,param3,param4);
               if(_loc15_ < _loc8_ || _loc15_ == _loc8_ && RectangleUtil.area(_loc11_,_loc12_,_loc13_,_loc14_) < RectangleUtil.area(_loc6_.entriesMinX[_loc9_],_loc6_.entriesMinY[_loc9_],_loc6_.entriesMaxX[_loc9_],_loc6_.entriesMaxY[_loc9_]))
               {
                  _loc9_ = _loc10_;
                  _loc8_ = _loc15_;
               }
               _loc10_++;
            }
            this.parents.push(_loc6_.nodeId);
            this.parentsEntry.push(_loc9_);
            _loc6_ = this.getNode(_loc6_.ids[_loc9_]);
         }
         return _loc6_;
      }
      
      private function adjustTree(param1:Node, param2:Node) : Node
      {
         var _loc3_:Node = null;
         var _loc4_:int = 0;
         var _loc5_:Node = null;
         while(param1.level != this.treeHeight)
         {
            _loc3_ = this.getNode(this.parents.pop());
            _loc4_ = this.parentsEntry.pop();
            if(_loc3_.ids[_loc4_] != param1.nodeId)
            {
            }
            if(_loc3_.entriesMinX[_loc4_] != param1.mbrMinX || _loc3_.entriesMinY[_loc4_] != param1.mbrMinY || _loc3_.entriesMaxX[_loc4_] != param1.mbrMaxX || _loc3_.entriesMaxY[_loc4_] != param1.mbrMaxY)
            {
               _loc3_.entriesMinX[_loc4_] = param1.mbrMinX;
               _loc3_.entriesMinY[_loc4_] = param1.mbrMinY;
               _loc3_.entriesMaxX[_loc4_] = param1.mbrMaxX;
               _loc3_.entriesMaxY[_loc4_] = param1.mbrMaxY;
               _loc3_.recalculateMBR();
            }
            _loc5_ = null;
            if(param2 != null)
            {
               if(_loc3_.entryCount < this.maxNodeEntries)
               {
                  _loc3_.addEntry(param2.mbrMinX,param2.mbrMinY,param2.mbrMaxX,param2.mbrMaxY,param2.nodeId);
               }
               else
               {
                  _loc5_ = this.splitNode(_loc3_,param2.mbrMinX,param2.mbrMinY,param2.mbrMaxX,param2.mbrMaxY,param2.nodeId);
               }
            }
            param1 = _loc3_;
            param2 = _loc5_;
            _loc3_ = null;
            _loc5_ = null;
         }
         return param2;
      }
      
      public function checkConsistency() : Boolean
      {
         return this.checkConsistencyInternal(this.rootNodeId,this.treeHeight,null);
      }
      
      private function checkConsistencyInternal(param1:int, param2:int, param3:Rectangle) : Boolean
      {
         var _loc8_:Rectangle = null;
         var _loc4_:Node = this.getNode(param1);
         if(_loc4_ == null)
         {
            return false;
         }
         if(param1 == this.rootNodeId && this.m_size == 0)
         {
            if(_loc4_.level != 1)
            {
               return false;
            }
         }
         if(_loc4_.level != param2)
         {
            return false;
         }
         var _loc5_:Rectangle = this.calculateMBR(_loc4_);
         var _loc6_:Rectangle = RectangleUtil.create(_loc4_.mbrMinX,_loc4_.mbrMinY,_loc4_.mbrMaxX,_loc4_.mbrMaxY);
         if(!RectangleUtil.equals(_loc6_,_loc5_))
         {
            if(_loc6_.left != _loc5_.left)
            {
            }
            if(_loc6_.top != _loc5_.top)
            {
            }
            if(_loc6_.right != _loc5_.right)
            {
            }
            if(_loc6_.bottom != _loc5_.bottom)
            {
            }
            return false;
         }
         if(param3 != null && !RectangleUtil.equals(_loc6_,param3))
         {
            if(_loc6_.left != param3.left)
            {
            }
            if(_loc6_.top != param3.top)
            {
            }
            if(_loc6_.right != param3.right)
            {
            }
            if(_loc6_.bottom != param3.bottom)
            {
            }
            return false;
         }
         if(param3 != null && _loc6_ === param3)
         {
            return false;
         }
         var _loc7_:int = 0;
         while(_loc7_ < _loc4_.entryCount)
         {
            if(_loc4_.ids[_loc7_] == -1)
            {
               return false;
            }
            if(_loc4_.level > 1)
            {
               _loc8_ = RectangleUtil.create(_loc4_.entriesMinX[_loc7_],_loc4_.entriesMinY[_loc7_],_loc4_.entriesMaxX[_loc7_],_loc4_.entriesMaxY[_loc7_]);
               if(!this.checkConsistencyInternal(_loc4_.ids[_loc7_],_loc4_.level - 1,_loc8_))
               {
                  return false;
               }
            }
            _loc7_++;
         }
         return true;
      }
      
      private function calculateMBR(param1:Node) : Rectangle
      {
         var _loc2_:Rectangle = new Rectangle();
         var _loc3_:int = 0;
         while(_loc3_ < param1.entryCount)
         {
            if(_loc3_ == 0 || param1.entriesMinX[_loc3_] < _loc2_.left)
            {
               _loc2_.left = param1.entriesMinX[_loc3_];
            }
            if(_loc3_ == 0 || param1.entriesMinY[_loc3_] < _loc2_.top)
            {
               _loc2_.top = param1.entriesMinY[_loc3_];
            }
            if(_loc3_ == 0 || param1.entriesMaxX[_loc3_] > _loc2_.right)
            {
               _loc2_.right = param1.entriesMaxX[_loc3_];
            }
            if(_loc3_ == 0 || param1.entriesMaxY[_loc3_] > _loc2_.bottom)
            {
               _loc2_.bottom = param1.entriesMaxY[_loc3_];
            }
            _loc3_++;
         }
         return _loc2_;
      }
   }
}

