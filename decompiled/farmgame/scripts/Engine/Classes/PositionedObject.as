package Engine.Classes
{
   import Engine.Constants;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.GlowFilter;
   import flash.geom.*;
   
   public class PositionedObject extends EngineObject
   {
      
      public static var viewportOutset:int = 0;
      
      protected var m_objectType:int = 1;
      
      protected var m_objectFlags:int = 0;
      
      protected var m_position:Vector3 = new Vector3();
      
      protected var m_screenPosition:Point;
      
      protected var m_size:Vector3 = new Vector3();
      
      protected var m_displayObject:DisplayObject = null;
      
      protected var m_displayObjectDirty:Boolean = false;
      
      protected var m_transformDirty:Boolean = false;
      
      protected var m_visible:Boolean = true;
      
      protected var m_attachPosition:Vector3 = null;
      
      protected var m_attachSize:Vector3 = null;
      
      protected var m_highlighted:Boolean;
      
      protected var m_culled:Boolean;
      
      protected var m_endPosition:Vector3 = new Vector3();
      
      public function PositionedObject()
      {
         super();
      }
      
      public function isPickable() : Boolean
      {
         return true;
      }
      
      override public function getSaveObject() : Object
      {
         var _loc1_:Object = super.getSaveObject();
         _loc1_.position = this.m_position.toObject();
         return _loc1_;
      }
      
      override public function loadObject(param1:Object) : void
      {
         super.loadObject(param1);
         this.m_position = new Vector3(param1.position.x,param1.position.y,param1.position.z);
      }
      
      public function getObjectType() : int
      {
         return this.m_objectType;
      }
      
      public function getReference() : PositionedObject
      {
         return this;
      }
      
      public function checkObjectType(param1:uint) : Boolean
      {
         return (this.m_objectType & param1) > 0;
      }
      
      public function checkObjectFlags(param1:uint, param2:Boolean = true) : Boolean
      {
         if(param2)
         {
            return (this.m_objectFlags & param1) == param1;
         }
         return (this.m_objectFlags & param1) > 0;
      }
      
      public function getPosition() : Vector3
      {
         return this.m_position.clone();
      }
      
      public function getPositionNoClone() : Vector3
      {
         return this.m_position;
      }
      
      public function getEndPosition() : Vector3
      {
         this.m_endPosition.x = this.m_position.x + this.m_size.x;
         this.m_endPosition.y = this.m_position.y + this.m_size.y;
         this.m_endPosition.z = this.m_position.z + this.m_size.z;
         return this.m_endPosition;
      }
      
      public function getScreenPosition() : Point
      {
         return this.m_screenPosition.clone();
      }
      
      public function getSizeNoClone() : Vector3
      {
         return this.m_size;
      }
      
      public function getSize() : Vector3
      {
         return this.m_size.clone();
      }
      
      public function getTileRect() : Rectangle
      {
         return new Rectangle(this.m_position.x,this.m_position.y,this.m_size.x,this.m_size.y);
      }
      
      public function getDisplayRect() : Rectangle
      {
         if(this.m_displayObject)
         {
            return this.m_displayObject.getRect(GlobalEngine.viewport);
         }
         return null;
      }
      
      public function isWithinViewport() : Boolean
      {
         var _loc2_:Rectangle = null;
         var _loc1_:Boolean = false;
         if(this.m_displayObject)
         {
            _loc1_ = true;
            _loc2_ = this.m_displayObject.getRect(GlobalEngine.viewport);
            if(-viewportOutset >= _loc2_.right || -viewportOutset >= _loc2_.bottom || GlobalEngine.stage.stageWidth + viewportOutset <= _loc2_.x || GlobalEngine.stage.stageHeight + viewportOutset <= _loc2_.y)
            {
               _loc1_ = false;
            }
         }
         return _loc1_;
      }
      
      public function isWithinRect(param1:Rectangle) : Boolean
      {
         var _loc3_:Rectangle = null;
         var _loc2_:Boolean = false;
         if(this.m_displayObject)
         {
            _loc2_ = true;
            _loc3_ = this.m_displayObject.getRect(GlobalEngine.viewport);
            if(param1.x >= _loc3_.right || param1.y >= _loc3_.bottom || param1.right <= _loc3_.x || param1.bottom <= _loc3_.y)
            {
               _loc2_ = false;
            }
         }
         return _loc2_;
      }
      
      public function isPixelInside(param1:Point) : Boolean
      {
         var _loc2_:Boolean = false;
         if(this.m_displayObject)
         {
            if(this.m_displayObject.getRect(this.m_displayObject.parent).containsPoint(param1))
            {
               _loc2_ = true;
            }
         }
         return _loc2_;
      }
      
      public function isWithinBounds(param1:PositionedObject) : Boolean
      {
         var _loc2_:Vector3 = this.getPosition();
         var _loc3_:Vector3 = this.getEndPosition();
         var _loc4_:Vector3 = param1.getPosition();
         var _loc5_:Vector3 = param1.getEndPosition();
         return _loc2_.x <= _loc4_.x && _loc2_.y <= _loc4_.y && _loc3_.x >= _loc5_.x && _loc3_.y >= _loc5_.y;
      }
      
      public function updateCulling() : void
      {
         this.m_culled = this.isWithinViewport() == false;
         this.setVisible(this.m_visible);
      }
      
      public function setVisible(param1:Boolean) : void
      {
         this.m_visible = param1;
         if(this.m_displayObject)
         {
            this.m_displayObject.visible = param1 && this.m_culled == false;
         }
      }
      
      public function isVisible() : Boolean
      {
         return this.m_visible && this.m_culled == false;
      }
      
      public function set alpha(param1:Number) : void
      {
         if(this.m_displayObject)
         {
            this.m_displayObject.alpha = param1;
         }
      }
      
      public function get alpha() : Number
      {
         var _loc1_:Number = 1;
         if(this.m_displayObject)
         {
            _loc1_ = this.m_displayObject.alpha;
         }
         return _loc1_;
      }
      
      public function setPosition(param1:Number, param2:Number, param3:Number = 0) : void
      {
         if(this.m_position.x != param1 || this.m_position.y != param2 || this.m_position.z != param3)
         {
            this.m_position = new Vector3(param1,param2,param3);
            this.m_transformDirty = true;
         }
      }
      
      public function translate(param1:Vector3) : void
      {
         this.setPosition(this.m_position.x + param1.x,this.m_position.y + param1.y,this.m_position.z + param1.z);
      }
      
      public function setSize(param1:Number, param2:Number, param3:Number = 0) : void
      {
         if(this.m_size.x != param1 || this.m_size.y != param2 || this.m_size.z != param3)
         {
            this.m_size = new Vector3(param1,param2,param3);
            this.m_transformDirty = true;
         }
      }
      
      public function isAttached() : Boolean
      {
         return this.m_attachPosition != null;
      }
      
      public function getAttachPosition() : Vector3
      {
         return this.m_attachPosition.clone();
      }
      
      public function getAttachSize() : Vector3
      {
         return this.m_attachSize.clone();
      }
      
      public function intersects(param1:PositionedObject) : Boolean
      {
         var _loc2_:Vector3 = this.getPosition();
         var _loc3_:Vector3 = this.getEndPosition();
         var _loc4_:Vector3 = param1.getPosition();
         var _loc5_:Vector3 = param1.getEndPosition();
         var _loc6_:Boolean = true;
         if(_loc3_.x <= _loc4_.x || _loc2_.x >= _loc5_.x || _loc3_.y <= _loc4_.y || _loc2_.y >= _loc5_.y || _loc3_.z != _loc2_.z && _loc4_.z != _loc5_.z && (_loc3_.z < _loc4_.z || _loc2_.z > _loc5_.z))
         {
            _loc6_ = false;
         }
         return _loc6_;
      }
      
      public function isCurrentPositionValid() : Boolean
      {
         return true;
      }
      
      public function onUpdate(param1:Number) : void
      {
      }
      
      public function onMouseOver(param1:MouseEvent) : void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
      }
      
      public function onMouseOut() : void
      {
         dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
      }
      
      public function onClick() : void
      {
         dispatchEvent(new MouseEvent(MouseEvent.CLICK));
      }
      
      public function getCursor() : Class
      {
         return null;
      }
      
      public function setHighlighted(param1:Boolean, param2:uint = 16755200) : void
      {
         if(this.m_displayObject)
         {
            this.m_highlighted = param1;
            if(param1)
            {
               this.m_displayObject.filters = [new GlowFilter(param2,1,16,16,4)];
            }
            else
            {
               this.m_displayObject.filters = [];
            }
         }
      }
      
      public function isHighlighted() : Boolean
      {
         return this.m_highlighted;
      }
      
      public function isInteractable() : Boolean
      {
         return (this.m_objectFlags & Constants.OBJECTFLAG_INTERACTIVE) > 0;
      }
      
      public function hasMouseOver() : Boolean
      {
         return false;
      }
      
      public function pickObject(param1:Point, param2:uint = 16777215, param3:uint = 0) : PositionedObject
      {
         var _loc4_:PositionedObject = null;
         if(this.isPickable() && this.checkObjectType(param2) && this.checkObjectFlags(param3))
         {
            if(this.isVisible() && this.isPixelInside(param1))
            {
               _loc4_ = this.getReference();
            }
         }
         return _loc4_;
      }
      
      public function drawDisplayObject() : void
      {
      }
      
      public function createDisplayObject() : DisplayObject
      {
         return null;
      }
      
      public function updateDisplayObjectTransform() : void
      {
      }
      
      public function deleteDisplayObject() : void
      {
         if(this.m_displayObject != null)
         {
            if(this.m_displayObject.parent != null)
            {
               this.m_displayObject.parent.removeChild(this.m_displayObject);
            }
            this.m_displayObject = null;
            this.m_displayObjectDirty = true;
         }
      }
      
      public function getDisplayObject() : DisplayObject
      {
         return this.m_displayObject;
      }
      
      public function isDisplayObjectDirty() : Boolean
      {
         return this.m_displayObjectDirty || this.m_displayObject == null;
      }
      
      public function setDisplayObjectDirty(param1:Boolean) : void
      {
         this.m_displayObjectDirty = param1;
      }
      
      public function getActualDisplayObjectSize() : Vector2
      {
         var _loc1_:Vector2 = new Vector2();
         if(this.m_displayObject != null)
         {
            _loc1_.x = this.m_displayObject.width;
            _loc1_.y = this.m_displayObject.height;
         }
         return _loc1_;
      }
   }
}

