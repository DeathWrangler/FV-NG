package Engine.Classes
{
   import Engine.Classes.Observer.IObservable;
   import Engine.Classes.Observer.IObserver;
   import Engine.Classes.Observer.ObserverComponent;
   import Engine.Constants;
   import Engine.Interfaces.IEngineObject;
   import Engine.Interfaces.ITerrainMap;
   import Engine.IsoMath;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.StatsManager;
   import com.infomatiq.jsi.rtree.RTree;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class World extends PositionedObjectContainer implements IEventDispatcher, IObservable
   {
      
      private static const PERF_PROBABILITY:int = 10000;
      
      private static const PERF_UPDATE_INTERVAL:Number = 5000;
      
      private static const PERF_FPS:String = "fps";
      
      private static const PERF_MEM_USAGE:String = "mem_usage";
      
      protected static const DEFAULT_LAYER_NAME:String = "default";
      
      private static const VISUAL_RTREE_COLOR:uint = 16711935;
      
      private static var m_instance:World = null;
      
      private static const VIEWPORT_OFFSET:int = 60;
      
      public static const OBSERVABLE_EVENT_ATTACH:String = "OBSERVABLE_EVENT_ATTACH";
      
      public static const OBSERVABLE_EVENT_DETACH:String = "OBSERVABLE_EVENT_DETACH";
      
      protected var m_tileMap:TileMap = null;
      
      protected var m_terrain:ITerrainMap;
      
      protected var m_dispatcher:EventDispatcher;
      
      protected var m_initialized:Boolean;
      
      protected var m_lastPerfUpdate:Number = 0;
      
      protected var m_perfFrameCount:int = 0;
      
      protected var m_perfTracking:Boolean = false;
      
      protected var m_errorOnNullObject:Boolean = false;
      
      protected var m_collisionMap:CollisionMap = null;
      
      private var m_attachedObjects:Dictionary = new Dictionary();
      
      protected var m_rtree:RTree;
      
      protected var m_visualRTree:Sprite;
      
      protected var m_defaultLayer:ObjectLayer = null;
      
      protected var m_layerLookup:Dictionary = new Dictionary();
      
      private var m_currentShard:int = 0;
      
      protected var m_currentNumShards:int = 2;
      
      private var m_maxNumShards:int = 16;
      
      private var m_lastShardTimeVector:Vector.<Number> = null;
      
      private var m_deltaShardTimeVector:Vector.<Number> = null;
      
      protected var m_visibleObjects:Array = new Array();
      
      public var enableSkipCulling:Boolean = false;
      
      private var m_skipCount:int = 0;
      
      public var skipCullingFlag:Boolean = false;
      
      private var m_observer:ObserverComponent;
      
      public function World(param1:int, param2:int)
      {
         super(param1,param2);
         this.m_dispatcher = new EventDispatcher(this);
         m_instance = this;
         this.m_observer = new ObserverComponent(this.getObservableEvents());
      }
      
      public static function getInstance() : World
      {
         return m_instance;
      }
      
      override public function loadObject(param1:Object) : void
      {
         LoadingManager.startWorldLoad();
         this.cleanUp();
         if(Boolean(param1.sizeX) && Boolean(param1.sizeY))
         {
            m_size.x = param1.sizeX;
            m_size.y = param1.sizeY;
         }
         this.initialize();
         this.m_defaultLayer = new ObjectLayer(DEFAULT_LAYER_NAME);
         this.addLayer(this.m_defaultLayer);
         this.loadWorldObjects(param1);
      }
      
      protected function loadWorldObjects(param1:Object) : void
      {
         var _loc5_:Object = null;
         var _loc2_:Array = param1.objects as Array;
         var _loc3_:int = 0;
         var _loc4_:uint = _loc2_.length;
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc2_[_loc3_];
            if(_loc5_ == null || _loc5_ == "null")
            {
               if(this.m_errorOnNullObject)
               {
                  throw new Error("object data was null");
               }
            }
            this.attachWorldObject(_loc5_);
            _loc3_++;
         }
      }
      
      public function attachWorldObject(param1:Object) : void
      {
         var _loc2_:WorldObject = this.createObjectInstance(param1);
         if(_loc2_)
         {
            _loc2_.loadObject(param1);
            _loc2_.setOuter(this);
            _loc2_.attach();
         }
      }
      
      protected function createObjectInstance(param1:Object) : WorldObject
      {
         return SavedObject.getInstance(param1.className) as WorldObject;
      }
      
      public function initialize() : void
      {
         this.initShards();
         if(GlobalEngine.engineOptions.tileMapClass == null)
         {
            GlobalEngine.engineOptions.tileMapClass = TileMap;
         }
         this.m_tileMap = new GlobalEngine.engineOptions.tileMapClass(getGridWidth(),getGridHeight()) as TileMap;
         this.m_collisionMap = new CollisionMap();
         this.m_collisionMap.initialize(getGridWidth(),getGridHeight());
         this.m_rtree = new RTree();
         var _loc1_:Object = new Object();
         _loc1_[RTree.INIT_PROP_DEBUG_LOGGING] = false;
         _loc1_[RTree.INIT_PROP_CONSISTENCY_CHECKING] = false;
         _loc1_[RTree.INIT_PROP_MIN_NODE_ENTRIES] = RTree.DEFAULT_MIN_NODE_ENTRIES;
         _loc1_[RTree.INIT_PROP_MAX_NODE_ENTRIES] = RTree.DEFAULT_MAX_NODE_ENTRIES;
         this.m_rtree.init(_loc1_);
         this.m_initialized = true;
         GlobalEngine.viewport.clearBitmapData();
         GlobalEngine.viewport.regenerateBitmapData();
      }
      
      public function cleanUp() : void
      {
         var _loc4_:IEngineObject = null;
         var _loc1_:Array = m_children.concat([]);
         var _loc2_:int = 0;
         var _loc3_:uint = _loc1_.length;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc1_[_loc2_] as IEngineObject;
            if(_loc4_ != null)
            {
               _loc4_.detach();
               _loc4_.cleanUp();
            }
            _loc2_++;
         }
         m_children = [];
         this.m_visibleObjects = [];
         this.m_layerLookup = new Dictionary();
         this.m_defaultLayer = null;
         this.m_tileMap = null;
         this.m_collisionMap = null;
         this.m_rtree = null;
         this.m_initialized = false;
      }
      
      public function getTileMap() : TileMap
      {
         return this.m_tileMap;
      }
      
      public function get terrainMap() : ITerrainMap
      {
         return this.m_terrain;
      }
      
      public function getRotation() : int
      {
         return Constants.ROTATION_0;
      }
      
      public function getReferencedAssets() : Array
      {
         var _loc4_:WorldObject = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:uint = 0;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         var _loc3_:uint = m_children.length;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = m_children[_loc2_] as WorldObject;
            _loc5_ = _loc4_.getReferencedAssets();
            _loc6_ = 0;
            _loc7_ = _loc5_.length;
            while(_loc6_ < _loc7_)
            {
               if(_loc1_.indexOf(_loc5_[_loc6_]) == -1)
               {
                  _loc1_.push(_loc5_[_loc6_]);
               }
               _loc6_++;
            }
            _loc2_++;
         }
         return _loc1_.concat(this.m_tileMap.getReferencedAssets());
      }
      
      public function getNumVisibleObjects() : int
      {
         return this.m_visibleObjects.length;
      }
      
      public function getVisibleObjects() : Array
      {
         return this.m_visibleObjects;
      }
      
      public function getObjectById(param1:int, param2:int = 16777215) : WorldObject
      {
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:uint = 0;
         var _loc7_:WorldObject = null;
         var _loc3_:WorldObject = null;
         if(this.m_attachedObjects[param1] != null)
         {
            _loc3_ = this.m_attachedObjects[param1];
         }
         else
         {
            _loc4_ = getObjects();
            _loc5_ = 0;
            _loc6_ = _loc4_.length;
            while(_loc5_ < _loc6_)
            {
               _loc7_ = _loc4_[_loc5_] as WorldObject;
               if(_loc7_.getId() == param1 && (_loc7_.getObjectType() & param2) > 0)
               {
                  _loc3_ = _loc7_;
                  break;
               }
               _loc5_++;
            }
         }
         GlobalEngine.assert(_loc3_ == this.m_attachedObjects[param1],"World#getObjectById hashed lookup differed from array lookup!");
         return _loc3_;
      }
      
      public function getObjectsByType(param1:int = 16777215) : Array
      {
         var _loc6_:WorldObject = null;
         var _loc2_:Array = [];
         var _loc3_:Array = getObjects();
         var _loc4_:int = 0;
         var _loc5_:uint = _loc3_.length;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc3_[_loc4_] as WorldObject;
            if((_loc6_.getObjectType() & param1) > 0)
            {
               _loc2_.push(_loc6_);
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function getObjectsByClass(param1:Class = null) : Array
      {
         var _loc6_:WorldObject = null;
         var _loc2_:Array = new Array();
         var _loc3_:Array = getObjects();
         var _loc4_:int = 0;
         var _loc5_:uint = _loc3_.length;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc3_[_loc4_] as WorldObject;
            if(_loc6_ != null && (param1 == null || _loc6_ is param1))
            {
               _loc2_.push(_loc6_);
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      override public function conditionallyRedrawAllObjects() : void
      {
         var _loc4_:WorldObject = null;
         var _loc1_:Array = getObjects();
         var _loc2_:int = 0;
         var _loc3_:uint = _loc1_.length;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc1_[_loc2_] as WorldObject;
            if(_loc4_ != null)
            {
               _loc4_.conditionallyRedraw();
            }
            _loc2_++;
         }
      }
      
      public function updateWorld(param1:Boolean = false) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:uint = 0;
         var _loc5_:IEngineObject = null;
         if(this.m_perfTracking)
         {
            this.trackPerf();
         }
         if(this.m_initialized)
         {
            this.updateShardTimers();
            _loc2_ = param1 ? this.m_visibleObjects : m_children;
            _loc3_ = 0;
            _loc4_ = _loc2_.length;
            while(_loc3_ < _loc4_)
            {
               _loc5_ = _loc2_[_loc3_] as IEngineObject;
               if(_loc5_)
               {
                  _loc5_.update();
               }
               _loc3_++;
            }
         }
      }
      
      public function updateCulling() : void
      {
         var _loc2_:int = 0;
         var _loc3_:PositionedObject = null;
         var _loc4_:uint = 0;
         var _loc5_:int = 0;
         var _loc1_:Array = getObjects();
         this.m_visibleObjects = [];
         if(!this.enableSkipCulling)
         {
            _loc2_ = 0;
            _loc4_ = _loc1_.length;
            while(_loc2_ < _loc4_)
            {
               _loc3_ = _loc1_[_loc2_] as PositionedObject;
               if(_loc3_ != null)
               {
                  _loc3_.updateCulling();
                  if(_loc3_.isVisible())
                  {
                     this.m_visibleObjects.push(_loc3_);
                  }
               }
               _loc2_++;
            }
         }
         else
         {
            this.skipCullingFlag = true;
            _loc5_ = this.m_skipCount & 1;
            PositionedObject.viewportOutset = VIEWPORT_OFFSET;
            _loc2_ = 0;
            _loc4_ = _loc1_.length;
            while(_loc2_ < _loc4_)
            {
               _loc3_ = _loc1_[_loc2_] as PositionedObject;
               if(_loc3_ != null)
               {
                  if(_loc5_ & 1)
                  {
                     _loc3_.updateCulling();
                  }
                  if(_loc3_.isVisible())
                  {
                     this.m_visibleObjects.push(_loc3_);
                  }
                  _loc5_++;
               }
               _loc2_++;
            }
            ++this.m_skipCount;
            PositionedObject.viewportOutset = 0;
         }
      }
      
      public function attach(param1:WorldObject) : void
      {
         var _loc2_:Number = param1.getId();
         this.m_observer.notifyObservers(OBSERVABLE_EVENT_ATTACH,param1);
         if(!isNaN(_loc2_))
         {
            if(this.m_attachedObjects[_loc2_] == null)
            {
               this.m_attachedObjects[_loc2_] = param1;
               this.insertObjectIntoRTree(param1);
            }
            else if(_loc2_ != 0)
            {
               GlobalEngine.assert(param1.equals(this.m_attachedObjects[param1.getId()]),"World#attach Tried to attach a worldObj with a non-unique id");
            }
         }
      }
      
      public function detach(param1:WorldObject) : void
      {
         var _loc2_:Number = param1.getId();
         this.m_observer.notifyObservers(OBSERVABLE_EVENT_DETACH,param1);
         if(!isNaN(_loc2_))
         {
            if(this.m_attachedObjects[_loc2_] != null && param1.equals(this.m_attachedObjects[_loc2_]))
            {
               delete this.m_attachedObjects[_loc2_];
               this.removeObjectFromRTree(param1);
            }
         }
      }
      
      internal function objectIdChanged(param1:WorldObject, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         if(param1 != null)
         {
            if(!isNaN(param2))
            {
               this.updateObjectIdInRTree(param1,param2);
               if(param2 != 0)
               {
                  GlobalEngine.assert(param1 == this.m_attachedObjects[param2],"World#objectIdChanged hashed object with oldId differs from passed in object (should be the same)");
                  delete this.m_attachedObjects[param2];
               }
            }
            _loc3_ = param1.getId();
            if(!isNaN(_loc3_))
            {
               GlobalEngine.assert(this.m_attachedObjects[_loc3_] == null,"World#objectIdChanged hash table entry should be empty and it is not");
               if(this.m_attachedObjects[_loc3_] == null)
               {
                  this.m_attachedObjects[_loc3_] = param1;
               }
            }
         }
      }
      
      public function addLayer(param1:ObjectLayer) : void
      {
         var _loc2_:ObjectLayer = this.m_layerLookup[param1.name];
         if(_loc2_ == null)
         {
            this.m_layerLookup[param1.name] = param1;
            m_children.push(param1);
            m_children.sortOn("priority",Array.NUMERIC);
            setObjectsDirty();
            param1.attach();
         }
      }
      
      public function removeLayer(param1:ObjectLayer) : void
      {
         param1.cleanUp();
         delete this.m_layerLookup[param1.name];
         param1.detach();
      }
      
      public function getObjectLayerByName(param1:String) : ObjectLayer
      {
         return this.m_layerLookup[param1];
      }
      
      internal function insertObjectIntoDepthArray(param1:PositionedObject, param2:String = null) : void
      {
         var _loc3_:Boolean = false;
         if(param2 == null)
         {
            param2 = DEFAULT_LAYER_NAME;
            _loc3_ = true;
         }
         var _loc4_:ObjectLayer = this.getObjectLayerByName(param2);
         if(_loc4_ == null)
         {
            if(_loc3_)
            {
               _loc4_ = new ObjectLayer(DEFAULT_LAYER_NAME);
               this.m_defaultLayer = _loc4_;
               this.addLayer(this.m_defaultLayer);
            }
            else
            {
               GlobalEngine.error("World","No object layer found with name: " + param2);
            }
         }
         if(_loc4_ != null)
         {
            _loc4_.insertObjectIntoDepthArray(param1);
            this.m_layerLookup[param1] = _loc4_;
         }
      }
      
      internal function updateObjectInDepthArray(param1:PositionedObject) : void
      {
         var _loc2_:ObjectLayer = this.m_layerLookup[param1] as ObjectLayer;
         if(_loc2_)
         {
            _loc2_.updateObjectInDepthArray(param1);
         }
         else if(param1.isAttached())
         {
            this.insertObjectIntoDepthArray(param1);
         }
      }
      
      internal function removeObjectFromDepthArray(param1:PositionedObject) : void
      {
         var _loc2_:ObjectLayer = this.m_layerLookup[param1] as ObjectLayer;
         if(_loc2_)
         {
            delete this.m_layerLookup[param1];
            _loc2_.removeObjectFromDepthArray(param1);
         }
      }
      
      internal function insertObjectIntoCollisionMap(param1:WorldObject) : void
      {
         this.m_collisionMap.insertObject(param1);
      }
      
      internal function removeObjectFromCollisionMap(param1:WorldObject) : void
      {
         this.m_collisionMap.removeObject(param1);
      }
      
      public function showCollisionMap(param1:Boolean) : void
      {
         if(this.m_collisionMap != null)
         {
            this.m_collisionMap.showCollisionMap(param1);
         }
      }
      
      public function checkCollision(param1:int, param2:int, param3:int, param4:int, param5:Array, param6:Array = null, param7:int = 16777215, param8:WorldObject = null, param9:Boolean = false) : Boolean
      {
         var _loc10_:Boolean = false;
         var _loc11_:CollisionLookup = new CollisionLookup();
         _loc11_.init(param1,param2,param3,param4);
         _loc11_.ignoreObjects = param5;
         _loc11_.colliderTypes = param7;
         _loc11_.collidingObject = param8;
         _loc11_.colliders = param6;
         _loc11_.ignorePathable = param9;
         return this.m_collisionMap.checkCollision(_loc11_);
      }
      
      public function getCollisionMap() : CollisionMap
      {
         return this.m_collisionMap;
      }
      
      internal function insertObjectIntoRTree(param1:WorldObject) : Boolean
      {
         var _loc2_:Boolean = false;
         if(param1 != null && this.m_rtree != null && !this.m_rtree.containsEntry(param1.getId()))
         {
            _loc2_ = this.m_rtree.add(param1.getTileRect(),param1.getId());
            if(this.m_visualRTree != null)
            {
               this.drawRTree();
            }
         }
         return _loc2_;
      }
      
      internal function removeObjectFromRTree(param1:WorldObject) : Boolean
      {
         var _loc2_:Boolean = true;
         if(param1 != null && this.m_rtree != null && this.m_rtree.containsEntry(param1.getId()))
         {
            _loc2_ = this.m_rtree.remove(param1.getTileRect(),param1.getId());
            if(this.m_visualRTree != null)
            {
               this.drawRTree();
            }
         }
         return _loc2_;
      }
      
      internal function updateObjectInRTree(param1:WorldObject) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:Rectangle = null;
         var _loc2_:Boolean = false;
         if(param1 != null && this.m_rtree != null)
         {
            _loc3_ = param1.getId();
            _loc4_ = this.m_rtree.getEntryRect(_loc3_);
            if(_loc4_ != null)
            {
               if(this.m_rtree.remove(_loc4_,_loc3_))
               {
                  this.m_rtree.add(param1.getTileRect(),_loc3_);
               }
            }
            else
            {
               this.m_rtree.add(param1.getTileRect(),_loc3_);
            }
            if(this.m_visualRTree != null)
            {
               this.drawRTree();
            }
         }
         return _loc2_;
      }
      
      internal function updateObjectIdInRTree(param1:WorldObject, param2:Number) : Boolean
      {
         var _loc4_:Rectangle = null;
         var _loc3_:Boolean = false;
         if(param1 != null && this.m_rtree != null)
         {
            _loc4_ = this.m_rtree.getEntryRect(param2);
            if(_loc4_ != null)
            {
               if(this.m_rtree.remove(_loc4_,param2))
               {
                  this.m_rtree.add(param1.getTileRect(),param1.getId());
               }
            }
            else
            {
               this.m_rtree.add(param1.getTileRect(),param1.getId());
            }
            if(this.m_visualRTree != null)
            {
               this.drawRTree();
            }
         }
         return _loc3_;
      }
      
      final public function getContainingObjectIds(param1:WorldObject) : Vector.<int>
      {
         var _loc2_:Vector.<int> = null;
         if(param1 != null && this.m_rtree != null)
         {
            _loc2_ = this.m_rtree.containing(param1.getTileRect());
         }
         else
         {
            _loc2_ = new Vector.<int>();
         }
         return _loc2_;
      }
      
      final public function getContainedObjectIds(param1:WorldObject) : Vector.<int>
      {
         var _loc2_:Vector.<int> = null;
         if(param1 != null && this.m_rtree != null)
         {
            _loc2_ = this.m_rtree.contains(param1.getTileRect());
         }
         else
         {
            _loc2_ = new Vector.<int>();
         }
         return _loc2_;
      }
      
      final public function getContainingObjects(param1:WorldObject) : Vector.<WorldObject>
      {
         var _loc3_:Vector.<int> = null;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc2_:Vector.<WorldObject> = new Vector.<WorldObject>();
         if(param1 != null && this.m_rtree != null)
         {
            _loc3_ = this.m_rtree.containing(param1.getTileRect());
            _loc4_ = 0;
            _loc5_ = _loc3_.length;
            while(_loc4_ < _loc5_)
            {
               _loc2_.push(this.getObjectById(_loc3_[_loc4_]));
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      final public function getContainedObjects(param1:WorldObject) : Vector.<WorldObject>
      {
         var _loc2_:Vector.<int> = this.getContainedObjectIds(param1);
         var _loc3_:Vector.<WorldObject> = new Vector.<WorldObject>(_loc2_.length);
         var _loc4_:uint = 0;
         var _loc5_:uint = _loc2_.length;
         while(_loc4_ < _loc5_)
         {
            _loc3_[_loc4_] = this.getObjectById(_loc2_[_loc4_]);
            _loc4_++;
         }
         return _loc3_;
      }
      
      final public function getIntersectingObjects(param1:WorldObject) : Vector.<WorldObject>
      {
         var result:Vector.<WorldObject> = null;
         var worldObj:WorldObject = param1;
         result = new Vector.<WorldObject>();
         if(worldObj != null && this.m_rtree != null)
         {
            this.m_rtree.intersects(worldObj.getTileRect(),function(param1:int):Boolean
            {
               result.push(getObjectById(param1));
               return true;
            });
         }
         return result;
      }
      
      public function debugToggleVisualRTree() : void
      {
         if(this.m_rtree != null)
         {
            if(this.m_visualRTree == null)
            {
               this.m_visualRTree = new Sprite();
               this.drawRTree();
               GlobalEngine.viewport.overlayBase.addChild(this.m_visualRTree);
            }
            else
            {
               if(this.m_visualRTree.parent != null)
               {
                  this.m_visualRTree.parent.removeChild(this.m_visualRTree);
               }
               this.m_visualRTree = null;
            }
         }
      }
      
      private function drawRTree() : void
      {
         var g:Graphics = null;
         if(this.m_rtree != null && this.m_visualRTree != null)
         {
            g = this.m_visualRTree.graphics;
            g.clear();
            this.m_rtree.contains(this.m_rtree.getBounds(),function(param1:int):Boolean
            {
               var _loc3_:Point = null;
               var _loc4_:Point = null;
               var _loc5_:Point = null;
               var _loc2_:Rectangle = m_rtree.getEntryRect(param1);
               if(_loc2_ == null)
               {
                  GlobalEngine.error("World","Possible RTree corruption, rect not found for id=" + param1);
               }
               else
               {
                  _loc3_ = IsoMath.tilePosToPixelPos(_loc2_.x,_loc2_.y);
                  _loc4_ = IsoMath.getPixelDeltaFromTileDelta(_loc2_.width,0);
                  _loc5_ = IsoMath.getPixelDeltaFromTileDelta(0,_loc2_.height);
                  g.lineStyle(4,VISUAL_RTREE_COLOR,1);
                  g.moveTo(_loc3_.x,_loc3_.y);
                  g.lineTo(_loc3_.x + _loc4_.x,_loc3_.y + _loc4_.y);
                  g.lineTo(_loc3_.x + _loc4_.x + _loc5_.x,_loc3_.y + _loc4_.y + _loc5_.y);
                  g.lineTo(_loc3_.x + _loc5_.x,_loc3_.y + _loc5_.y);
                  g.lineTo(_loc3_.x,_loc3_.y);
               }
               return true;
            });
         }
      }
      
      public function pickObject(param1:Point, param2:uint = 16777215, param3:uint = 0) : PositionedObject
      {
         var _loc4_:* = 0;
         var _loc6_:PositionedObject = null;
         var _loc5_:PositionedObject = null;
         _loc4_ = int(m_children.length - 1);
         while(_loc4_ >= 0)
         {
            _loc6_ = m_children[_loc4_] as PositionedObject;
            _loc5_ = _loc6_.pickObject(param1,param2,param3) as PositionedObject;
            if(_loc5_ != null)
            {
               break;
            }
            _loc4_--;
         }
         return _loc5_;
      }
      
      public function startPerformanceTracking() : void
      {
         if(Math.random() * PERF_PROBABILITY < 1)
         {
            this.m_perfTracking = true;
         }
      }
      
      protected function trackPerf() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc1_:Number = getTimer();
         ++this.m_perfFrameCount;
         if(_loc1_ >= this.m_lastPerfUpdate + PERF_UPDATE_INTERVAL)
         {
            _loc2_ = this.m_perfFrameCount / (_loc1_ - this.m_lastPerfUpdate) * 1000;
            if(GlobalEngine)
            {
               _loc3_ = this.getNumObjects();
               if(_loc2_ > 30)
               {
                  _loc4_ = "30-60";
               }
               else if(_loc2_ > 20)
               {
                  _loc4_ = "20-30";
               }
               else if(_loc2_ > 10)
               {
                  _loc4_ = "10-20";
               }
               else if(_loc2_ > 5)
               {
                  _loc4_ = "5-10";
               }
               else if(_loc2_ > 1)
               {
                  _loc4_ = "1-5";
               }
               else
               {
                  _loc4_ = "0-1";
               }
               _loc5_ = Number(System.totalMemory / 1024 / 1024);
               if(_loc5_ < 20)
               {
                  _loc6_ = "0-20";
               }
               else if(_loc5_ < 40)
               {
                  _loc6_ = "20-40";
               }
               else if(_loc5_ < 60)
               {
                  _loc6_ = "40-60";
               }
               else if(_loc5_ < 80)
               {
                  _loc6_ = "60-80";
               }
               else if(_loc5_ < 100)
               {
                  _loc6_ = "80-100";
               }
               else if(_loc5_ < 120)
               {
                  _loc6_ = "100-120";
               }
               else if(_loc5_ < 140)
               {
                  _loc6_ = "120-140";
               }
               else if(_loc5_ < 160)
               {
                  _loc6_ = "140-160";
               }
               else if(_loc5_ < 180)
               {
                  _loc6_ = "160-180";
               }
               else if(_loc5_ < 200)
               {
                  _loc6_ = "180-200";
               }
               else if(_loc5_ < 220)
               {
                  _loc6_ = "200-220";
               }
               else
               {
                  _loc6_ = "180-inf";
               }
               if(_loc3_ < 200)
               {
                  _loc7_ = " 0To200 objects";
               }
               else if(_loc3_ < 400)
               {
                  _loc7_ = " 200To400 objects";
               }
               else if(_loc3_ < 600)
               {
                  _loc7_ = " 400To600 objects";
               }
               else if(_loc3_ < 1000)
               {
                  _loc7_ = " 600To1000 objects";
               }
               else if(_loc3_ < 1500)
               {
                  _loc7_ = " 1000To1500 objects";
               }
               else
               {
                  _loc7_ = " 1500ToInf objects";
               }
               StatsManager.perf(PERF_FPS,"clientPerformance","","","","",_loc2_.toString());
               StatsManager.perf(PERF_MEM_USAGE,"clientPerformance","","","","",_loc3_.toString());
            }
            this.m_lastPerfUpdate = _loc1_;
            this.m_perfFrameCount = 0;
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this.m_dispatcher.addEventListener(param1,param2,param3,param4);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this.m_dispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this.m_dispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this.m_dispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this.m_dispatcher.willTrigger(param1);
      }
      
      public function set errorOnNullObject(param1:Boolean) : void
      {
         this.m_errorOnNullObject = param1;
      }
      
      final private function initShards() : void
      {
         this.m_maxNumShards = GlobalEngine.engineOptions.numShards;
         this.m_lastShardTimeVector = new Vector.<Number>(this.m_maxNumShards,true);
         this.m_deltaShardTimeVector = new Vector.<Number>(this.m_maxNumShards,true);
         var _loc1_:int = 0;
         while(_loc1_ < this.m_maxNumShards)
         {
            this.m_lastShardTimeVector[_loc1_] = GlobalEngine.currentTime;
            this.m_deltaShardTimeVector[_loc1_] = 0;
            _loc1_++;
         }
      }
      
      final public function setNumShards(param1:int) : void
      {
         if(param1 <= this.m_maxNumShards)
         {
            this.m_currentNumShards = param1;
            if(this.m_currentShard > this.m_currentNumShards)
            {
               this.m_currentShard = 0;
            }
         }
      }
      
      final public function getRandomShard() : int
      {
         return Math.floor(Math.random() * this.m_maxNumShards);
      }
      
      final public function getShardDelta(param1:int) : Number
      {
         var _loc2_:Number = -1;
         if(param1 % this.m_currentNumShards == this.m_currentShard && this.m_deltaShardTimeVector[param1] > 0)
         {
            _loc2_ = this.m_deltaShardTimeVector[param1];
         }
         return _loc2_;
      }
      
      final private function updateShardTimers() : void
      {
         this.m_currentShard = ++this.m_currentShard % this.m_currentNumShards;
         var _loc1_:int = this.m_currentShard;
         while(_loc1_ < this.m_maxNumShards)
         {
            if(this.m_lastShardTimeVector[_loc1_] > 0)
            {
               this.m_deltaShardTimeVector[_loc1_] = (GlobalEngine.currentTime - this.m_lastShardTimeVector[_loc1_]) / 1000;
            }
            this.m_lastShardTimeVector[_loc1_] = GlobalEngine.currentTime;
            _loc1_ += this.m_currentNumShards;
         }
      }
      
      public function addObserver(param1:IObserver, param2:Vector.<String> = null) : void
      {
         this.m_observer.addObserver(param1,param2);
      }
      
      public function removeObserver(param1:IObserver, param2:Vector.<String> = null) : void
      {
         this.m_observer.removeObserver(param1,param2);
      }
      
      public function getObservableEvents() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         _loc1_.push(OBSERVABLE_EVENT_ATTACH,OBSERVABLE_EVENT_DETACH);
         return _loc1_;
      }
   }
}

