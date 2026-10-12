package Engine.Classes
{
   import Engine.Helpers.Vector3;
   import Engine.Interfaces.IEngineObject;
   import Engine.Interfaces.IRenderObject;
   import Engine.Managers.StatsManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class ObjectLayer extends PositionedObject implements IEngineObject, IRenderObject
   {
      
      private var m_children:Array = [];
      
      private var m_name:String;
      
      private var m_priority:Number;
      
      public function ObjectLayer(param1:String, param2:Number = 0)
      {
         super();
         this.m_name = param1;
         this.m_priority = param2;
         m_displayObject = new Sprite();
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get priority() : Number
      {
         return this.m_priority;
      }
      
      public function get children() : Array
      {
         return this.m_children;
      }
      
      public function cleanUp() : void
      {
         var _loc4_:WorldObject = null;
         var _loc1_:Array = this.m_children.concat([]);
         var _loc2_:int = 0;
         var _loc3_:uint = _loc1_.length;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc1_[_loc2_] as WorldObject;
            if(_loc4_ != null)
            {
               _loc4_.detach();
               _loc4_.cleanUp();
            }
            _loc2_++;
         }
         this.m_children = [];
         m_displayObject = new Sprite();
      }
      
      public function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:uint = this.m_children.length;
         while(_loc1_ < _loc2_)
         {
            if(this.m_children[_loc1_])
            {
               this.m_children[_loc1_].update();
            }
            _loc1_++;
         }
      }
      
      public function attach() : void
      {
         var _loc1_:IsoViewport = GlobalEngine.viewport as IsoViewport;
         _loc1_.addObjectLayer(this);
      }
      
      public function detach() : void
      {
         var _loc1_:IsoViewport = GlobalEngine.viewport as IsoViewport;
         _loc1_.removeObjectLayer(this);
      }
      
      public function render(param1:RenderContext) : void
      {
         var _loc2_:int = int(this.m_children.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this.m_children[_loc3_].render(param1);
            _loc3_++;
         }
      }
      
      public function insertObjectIntoDepthArray(param1:PositionedObject, param2:Boolean = true) : void
      {
         var layerSprite:Sprite = null;
         var depthIdx:int = 0;
         var displayObj:DisplayObject = null;
         var insertIdx:int = 0;
         var worldObj:PositionedObject = param1;
         var sanitizeOnError:Boolean = param2;
         if(worldObj)
         {
            layerSprite = getDisplayObject() as Sprite;
            depthIdx = this.m_children.indexOf(worldObj);
            if(depthIdx >= 0)
            {
               this.m_children.splice(depthIdx,1);
            }
            displayObj = worldObj.getDisplayObject();
            if(!displayObj)
            {
               displayObj = worldObj.createDisplayObject();
            }
            if(displayObj != null)
            {
               insertIdx = this.getDepthArrayInsertIndex(worldObj);
               this.m_children.splice(insertIdx,0,worldObj);
               try
               {
                  if(layerSprite.contains(displayObj))
                  {
                     layerSprite.setChildIndex(displayObj,insertIdx);
                  }
                  else
                  {
                     layerSprite.addChildAt(displayObj,insertIdx);
                  }
               }
               catch(e:RangeError)
               {
                  if(sanitizeOnError)
                  {
                     sanitizeChildren();
                     insertObjectIntoDepthArray(worldObj,false);
                  }
                  else
                  {
                     StatsManager.sample(100,"errors","flash","ObjectLayer.insertObjectIntoDepthArray","RangeError");
                  }
               }
            }
            else
            {
               StatsManager.sample(100,"errors","flash","ObjectLayer.insertObjectIntoDepthArray","displayObj_is_null");
            }
         }
      }
      
      public function updateObjectInDepthArray(param1:PositionedObject) : void
      {
         if(Boolean(param1) && param1.isAttached())
         {
            this.insertObjectIntoDepthArray(param1);
         }
      }
      
      final protected function getDepthArrayInsertIndex(param1:PositionedObject) : int
      {
         var _loc6_:PositionedObject = null;
         var _loc2_:int = 0;
         var _loc3_:int = int(this.m_children.length);
         var _loc4_:int = _loc3_ >> 1;
         var _loc5_:int = 0;
         while(_loc2_ < _loc3_)
         {
            _loc6_ = this.m_children[_loc4_] as PositionedObject;
            _loc5_ = this.sortObjects(param1,_loc6_);
            if(_loc5_ == -1)
            {
               _loc3_ = _loc4_;
               _loc4_ = _loc2_ + _loc3_ >> 1;
            }
            else if(_loc5_ == 1)
            {
               _loc2_ = _loc4_ + 1;
               _loc4_ = _loc2_ + _loc3_ >> 1;
            }
            else if(_loc5_ == 0)
            {
               break;
            }
         }
         return _loc4_;
      }
      
      final protected function sortObjects(param1:Object, param2:Object) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:WorldObject = param1 as WorldObject;
         var _loc6_:WorldObject = param2 as WorldObject;
         var _loc7_:Vector3 = _loc5_.getDepthPositionNoClone();
         var _loc8_:Vector3 = _loc6_.getDepthPositionNoClone();
         var _loc9_:Vector3 = _loc5_.getDepthEndPositionNoClone();
         var _loc10_:Vector3 = _loc6_.getDepthEndPositionNoClone();
         var _loc11_:Boolean = _loc5_.getDepthPriority() == _loc6_.getDepthPriority();
         if(_loc6_.depthIndex > _loc5_.depthIndex)
         {
            if(_loc11_ && (_loc7_.x >= _loc10_.x && _loc7_.y < _loc10_.y && _loc9_.y > _loc8_.y || _loc7_.y >= _loc10_.y && _loc7_.x < _loc10_.x && _loc9_.x > _loc8_.x))
            {
               _loc3_ = -1;
            }
            else
            {
               _loc3_ = 1;
            }
         }
         else if(_loc6_.depthIndex < _loc5_.depthIndex)
         {
            if(_loc11_ && (_loc8_.x >= _loc9_.x && _loc8_.y < _loc9_.y && _loc10_.y > _loc7_.y || _loc8_.y >= _loc9_.y && _loc8_.x < _loc9_.x && _loc10_.x > _loc7_.x))
            {
               _loc3_ = 1;
            }
            else
            {
               _loc3_ = -1;
            }
         }
         else if(_loc11_)
         {
            if(_loc7_.x >= _loc10_.x && _loc7_.y < _loc10_.y && _loc9_.y > _loc8_.y || _loc7_.y >= _loc10_.y && _loc7_.x < _loc10_.x && _loc9_.x > _loc8_.x)
            {
               _loc3_ = -1;
            }
            else if(_loc8_.x >= _loc9_.x && _loc8_.y < _loc9_.y && _loc10_.y > _loc7_.y || _loc8_.y >= _loc9_.y && _loc8_.x < _loc9_.x && _loc10_.x > _loc7_.x)
            {
               _loc3_ = 1;
            }
         }
         return _loc3_;
      }
      
      public function removeObjectFromDepthArray(param1:PositionedObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Sprite = null;
         var _loc4_:DisplayObject = null;
         if(param1)
         {
            _loc2_ = this.m_children.indexOf(param1);
            if(_loc2_ >= 0)
            {
               this.m_children.splice(_loc2_,1);
            }
            _loc3_ = getDisplayObject() as Sprite;
            _loc4_ = param1.getDisplayObject();
            if((Boolean(_loc4_)) && _loc3_.contains(_loc4_))
            {
               _loc3_.removeChild(_loc4_);
            }
         }
      }
      
      override public function pickObject(param1:Point, param2:uint = 16777215, param3:uint = 0) : PositionedObject
      {
         var _loc6_:PositionedObject = null;
         var _loc4_:PositionedObject = null;
         var _loc5_:* = int(this.m_children.length - 1);
         while(_loc5_ >= 0)
         {
            _loc6_ = this.m_children[_loc5_] as PositionedObject;
            _loc4_ = _loc6_.pickObject(param1,param2,param3) as PositionedObject;
            if(_loc4_ != null)
            {
               break;
            }
            _loc5_--;
         }
         return _loc4_;
      }
      
      private function sanitizeChildren() : void
      {
         var _loc3_:PositionedObject = null;
         var _loc4_:DisplayObject = null;
         var _loc1_:Sprite = getDisplayObject() as Sprite;
         var _loc2_:Array = [];
         for each(_loc3_ in this.m_children)
         {
            if(_loc3_)
            {
               _loc4_ = _loc3_.getDisplayObject();
               if(_loc4_ != null && _loc1_.contains(_loc4_))
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
         this.m_children = _loc2_;
      }
   }
}

