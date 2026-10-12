package com.troyer.widget.view
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.controller.DynamicDialog;
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.parser.Utility;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.style.DialogLook;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class BaseWidgetView extends Sprite
   {
      
      private static var m_updatingSkin:Boolean;
      
      public static const ATTRIBUTE_NAME:String = "name";
      
      public static const ATTRIBUTE_STYLE:String = "style";
      
      public static const ATTRIBUTE_VISIBLE:String = "visible";
      
      public static const ATTRIBUTE_OBSTRUCT:String = "obstruct";
      
      public static const ATTRIBUTE_WIDTH:String = "width";
      
      public static const ATTRIBUTE_HEIGHT:String = "height";
      
      public static const ATTRIBUTE_DEPTH:String = "depth";
      
      public static const ATTRIBUTE_BLEND_MODE:String = "blendMode";
      
      public static const ATTRIBUTE_OFFSET_LEFT:String = "offsetLeft";
      
      public static const ATTRIBUTE_OFFSET_TOP:String = "offsetTop";
      
      public static const ATTRIBUTE_OFFSET_RIGHT:String = "offsetRight";
      
      public static const ATTRIBUTE_OFFSET_BOTTOM:String = "offsetBottom";
      
      public static const SKIN_VIEW_PREFIX:String = "$";
      
      public static const SKIN_VIEW_SUFFIX:String = "_skin";
      
      private static const IGNORE_ATTRIBUTES:Array = [Constants.ATTRIBUTE_CONTROLLER,Constants.ATTRIBUTE_CLASSNAME,Constants.ATTRIBUTE_VIEW,Constants.ATTRIBUTE_TARGET,Constants.TAG_NAME];
      
      protected var m_controller:BaseWidgetController;
      
      protected var m_context:MT4DContext;
      
      protected var m_style:BaseStyle;
      
      internal var m_skin:Object;
      
      protected var m_size:Rectangle;
      
      protected var m_adjustedSize:Rectangle;
      
      protected var m_fixedWidth:Boolean = false;
      
      protected var m_fixedHeight:Boolean = false;
      
      protected var m_obstruct:Boolean = true;
      
      protected var m_depthIndex:int = 0;
      
      protected var m_logicalChildren:Array = [];
      
      protected var m_offsetLeft:Number = 0;
      
      protected var m_offsetTop:Number = 0;
      
      protected var m_offsetRight:Number = 0;
      
      protected var m_offsetBottom:Number = 0;
      
      internal var m_contentHolderParent:BaseWidgetView;
      
      internal var m_contentHolder:BaseWidgetView;
      
      public function BaseWidgetView(param1:BaseStyle = null, param2:Rectangle = null, param3:MT4DContext = null)
      {
         super();
         if(param3)
         {
            this.m_context = param3;
         }
         else
         {
            this.m_context = MT4DManager.getInstance().getDefaultContext();
         }
         this.m_style = param1;
         this.m_size = param2 != null ? param2.clone() : null;
         this.m_adjustedSize = param2 != null ? param2.clone() : null;
         this.m_offsetLeft = this.m_offsetTop = this.m_offsetRight = this.m_offsetBottom = 0;
         this.setup();
      }
      
      public static function getFactoryWidgetView(param1:String, param2:MT4DContext = null) : BaseWidgetView
      {
         var ClassName:Class = null;
         var name:String = param1;
         var context:MT4DContext = param2;
         var result:BaseWidgetView = null;
         if(context == null)
         {
            context = MT4DManager.getInstance().getDefaultContext();
         }
         try
         {
            ClassName = getDefinitionByName("com.troyer.widget.view." + name + "View") as Class;
         }
         catch(error:Error)
         {
            MT4DManager.getInstance().getErrorList().addError("Unable to find view class \'" + name + "View\'. Did you misspell it?");
            return null;
         }
         result = new ClassName(null,null,context);
         if(!result)
         {
            MT4DManager.getInstance().getErrorList().addError("Widget Class " + name + "View does not exist");
         }
         return result;
      }
      
      protected static function addError(param1:String) : void
      {
         MT4DManager.getInstance().getErrorList().addError(param1);
      }
      
      protected static function addWarning(param1:String) : void
      {
         MT4DManager.getInstance().getErrorList().addWarning(param1);
      }
      
      public function destroy() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:BaseWidgetController = null;
         var _loc3_:BaseWidgetView = null;
         this.m_style = null;
         this.m_size = null;
         this.m_adjustedSize = null;
         while(numChildren > 0)
         {
            _loc1_ = this.getChildAt(0);
            if(Boolean(_loc1_) && _loc1_ is BaseWidgetView)
            {
               this.removeChild(_loc1_);
               _loc2_ = BaseWidgetView(_loc1_).getController();
               if(_loc2_)
               {
                  _loc2_.destroy();
               }
            }
            else
            {
               if(_loc1_ is DisplayObjectContainer)
               {
                  if(DisplayObjectContainer(_loc1_).numChildren > 0)
                  {
                  }
               }
               this.removeChild(_loc1_);
            }
         }
         if(parent)
         {
            _loc3_ = parent as BaseWidgetView;
            parent.removeChild(this);
            if(_loc3_)
            {
               _loc3_.getController().forceResize();
            }
         }
         this.m_logicalChildren = null;
         this.m_controller = null;
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      public function clone() : BaseWidgetView
      {
         var _loc1_:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
         var _loc2_:BaseWidgetView = new _loc1_(this.m_style,this.m_size);
         if(this.hasFixedHeight())
         {
            _loc2_.lockHeight();
         }
         if(this.hasFixedWidth())
         {
            _loc2_.lockWidth();
         }
         return _loc2_;
      }
      
      protected function setup() : void
      {
      }
      
      public function getViewName() : String
      {
         var _loc2_:Array = null;
         var _loc1_:String = getQualifiedClassName(this);
         _loc2_ = _loc1_.split("::");
         _loc1_ = _loc2_[_loc2_.length - 1];
         if(_loc1_.indexOf("View") != -1)
         {
            _loc1_ = _loc1_.replace("View","");
         }
         return _loc1_;
      }
      
      public function getAttributeNames() : Array
      {
         return [ATTRIBUTE_NAME,ATTRIBUTE_STYLE,ATTRIBUTE_VISIBLE,ATTRIBUTE_OBSTRUCT];
      }
      
      public function setStyle(param1:BaseStyle) : void
      {
         var _loc2_:BaseStyle = null;
         var _loc3_:Array = null;
         if(param1)
         {
            _loc2_ = this.m_style;
            this.m_style = param1;
            if(_loc2_ != param1 && this.m_skin != param1.getSkinViewData() && !ViewBuilder.isBuildingView() && !m_updatingSkin)
            {
               this.updateStyleSkin(param1);
            }
            this.setup();
            _loc3_ = this.m_style.getFilters();
            if(Boolean(_loc3_) && _loc3_.length > 0)
            {
               this.applyFilters(_loc3_);
            }
            else
            {
               this.filters = [];
            }
            if(this.m_style.hasData(BaseStyle.DATA_ALPHA))
            {
               this.alpha = parseFloat(this.m_style.getData(BaseStyle.DATA_ALPHA));
            }
         }
      }
      
      public function getStyle() : BaseStyle
      {
         return this.m_style;
      }
      
      private function updateStyleSkin(param1:BaseStyle) : void
      {
         var saveContentChildren:Array;
         var contentHolder:BaseWidgetView;
         var i:int = 0;
         var saveContentLogicalChildren:Array = null;
         var childView:BaseWidgetView = null;
         var style:BaseStyle = param1;
         var look:DialogLook = null;
         var dialog:DynamicDialog = this.getDialog();
         if(dialog == null)
         {
            look = this.m_context.getDefaultLook();
         }
         else
         {
            look = dialog.getLook();
         }
         saveContentChildren = [];
         contentHolder = this.m_contentHolder;
         if(contentHolder != null)
         {
            i = 0;
            while(i < contentHolder.numChildren)
            {
               saveContentChildren.push(contentHolder.getChildAt(i));
               i++;
            }
            saveContentLogicalChildren = contentHolder.m_logicalChildren;
            while(contentHolder.numChildren > 0)
            {
               contentHolder.removeChildAt(0);
            }
            contentHolder.m_logicalChildren = null;
         }
         while(this.numChildren != 0)
         {
            childView = this.getChildAt(0) as BaseWidgetView;
            if(childView != null)
            {
               childView.destroy();
            }
            this.removeChildAt(0);
         }
         this.m_logicalChildren = [];
         this.m_contentHolder = null;
         if(style.hasSkin())
         {
            m_updatingSkin = true;
            try
            {
               ViewBuilder.updateViewStyleSkin(this,style,look,this.m_context);
            }
            finally
            {
               m_updatingSkin = false;
            }
         }
         contentHolder = this.m_contentHolder;
         if(!contentHolder)
         {
            contentHolder = this;
         }
         if(saveContentChildren.lenght > 0)
         {
            i = 0;
            while(i < saveContentChildren.length)
            {
               contentHolder.addChild(saveContentChildren[i]);
               i++;
            }
            contentHolder.m_logicalChildren = [];
         }
      }
      
      public function getContext() : MT4DContext
      {
         return this.m_context;
      }
      
      protected function applyFilters(param1:Array) : void
      {
         this.filters = param1;
      }
      
      public function setSize(param1:Rectangle) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:Rectangle = null;
         var _loc4_:Boolean = false;
         if(param1)
         {
            _loc2_ = this.m_size;
            _loc3_ = this.m_adjustedSize;
            this.m_size = param1.clone();
            if(this.m_offsetLeft + this.m_offsetRight == 0 && this.m_offsetTop + this.m_offsetBottom == 0)
            {
               this.m_adjustedSize = this.m_size;
            }
            else
            {
               this.m_adjustedSize = new Rectangle(0,0,param1.width + this.m_offsetLeft + this.m_offsetRight,param1.height + this.m_offsetTop + this.m_offsetBottom);
            }
            _loc4_ = false;
            if(Boolean(_loc3_) && Boolean(_loc2_))
            {
               if(_loc3_.equals(this.m_adjustedSize) && _loc2_.equals(this.m_size))
               {
                  _loc4_ = true;
               }
            }
            this.setup();
            if(!_loc4_)
            {
               this.notifyResized();
            }
         }
      }
      
      private function resetSize() : void
      {
         var _loc1_:Rectangle = this.m_size;
         this.m_size = null;
         this.setSize(_loc1_);
      }
      
      public function lockWidth() : void
      {
         this.m_fixedWidth = true;
      }
      
      public function unlockWidth() : void
      {
         this.m_fixedWidth = false;
      }
      
      public function lockHeight() : void
      {
         this.m_fixedHeight = true;
      }
      
      public function unlockHeight() : void
      {
         this.m_fixedHeight = false;
      }
      
      public function hasFixedWidth() : Boolean
      {
         return this.m_fixedWidth;
      }
      
      public function hasFixedHeight() : Boolean
      {
         return this.m_fixedHeight;
      }
      
      public function getSize() : Rectangle
      {
         return this.m_size;
      }
      
      public function getAdjustedSize() : Rectangle
      {
         return this.m_adjustedSize;
      }
      
      public function getDepthIndex() : int
      {
         return this.m_depthIndex;
      }
      
      public function getOffsetLeft() : Number
      {
         return this.m_offsetLeft;
      }
      
      public function getOffsetTop() : Number
      {
         return this.m_offsetTop;
      }
      
      public function getOffsetRight() : Number
      {
         return this.m_offsetRight;
      }
      
      public function getOffsetBottom() : Number
      {
         return this.m_offsetBottom;
      }
      
      public function getContentHolder() : BaseWidgetView
      {
         return this.m_contentHolder != null ? this.m_contentHolder : this;
      }
      
      public function getContentHolderParent() : BaseWidgetView
      {
         return this.m_contentHolderParent != null ? this.m_contentHolderParent : this.parent as BaseWidgetView;
      }
      
      public function setAttribute(param1:String, param2:*) : void
      {
         var _loc3_:Rectangle = null;
         if(param1 == ATTRIBUTE_NAME && param2 is String)
         {
            this.name = param2;
         }
         else if(param1 == ATTRIBUTE_DEPTH)
         {
            if(param2 is String)
            {
               this.m_depthIndex = parseInt(param2);
            }
            else if(param2 is Number)
            {
               this.m_depthIndex = param2;
            }
            if(Boolean(parent) && parent is BaseWidgetView)
            {
               (parent as BaseWidgetView).reorderDisplayChild(this);
            }
         }
         else if(param1 == ATTRIBUTE_STYLE)
         {
            if(param2 is BaseStyle)
            {
               this.setStyle(param2);
            }
         }
         else if(param1 == ATTRIBUTE_OBSTRUCT)
         {
            if(param2 is String)
            {
               this.m_obstruct = Utility.stringIsTrue(param2);
               this.notifyResized();
            }
            else if(param2 is Boolean)
            {
               this.m_obstruct = param2;
               this.notifyResized();
            }
         }
         else if(param1 == ATTRIBUTE_VISIBLE)
         {
            if(param2 is String)
            {
               this.visible = Utility.stringIsTrue(param2);
            }
            else if(param2 is Boolean)
            {
               this.visible = param2;
            }
            else
            {
               addError("Attribute " + param1 + " recieved unexpected value \'" + param2 + "\' in view \'" + this.name + "\'.");
            }
         }
         else if(param1 == ATTRIBUTE_BLEND_MODE && param2 is String)
         {
            this.blendMode = param2;
         }
         else if(param1 == ATTRIBUTE_OFFSET_LEFT)
         {
            this.m_offsetLeft = Number(parseInt(param2));
            this.resetSize();
         }
         else if(param1 == ATTRIBUTE_OFFSET_TOP)
         {
            this.m_offsetTop = Number(parseInt(param2));
            this.resetSize();
         }
         else if(param1 == ATTRIBUTE_OFFSET_RIGHT)
         {
            this.m_offsetRight = Number(parseInt(param2));
            this.resetSize();
         }
         else if(param1 == ATTRIBUTE_OFFSET_BOTTOM)
         {
            this.m_offsetBottom = Number(parseInt(param2));
            this.resetSize();
         }
         else if(IGNORE_ATTRIBUTES.indexOf(param1) == -1)
         {
            addError("Unknown attribute: \'" + param1 + "\' with value \'" + param2 + "\' in view \'" + this.name + "\'.");
         }
      }
      
      public function getAttribute(param1:String) : *
      {
         if(param1 == ATTRIBUTE_NAME)
         {
            return this.name;
         }
         if(param1 == ATTRIBUTE_VISIBLE)
         {
            return Boolean(this.visible);
         }
         if(param1 == ATTRIBUTE_OBSTRUCT)
         {
            return this.m_obstruct;
         }
         if(param1 == ATTRIBUTE_DEPTH)
         {
            return this.m_depthIndex;
         }
         if(param1 == ATTRIBUTE_WIDTH)
         {
            return this.m_size != null ? this.m_size.width : 0;
         }
         if(param1 == ATTRIBUTE_HEIGHT)
         {
            return this.m_size != null ? this.m_size.height : 0;
         }
         if(param1 == ATTRIBUTE_OFFSET_LEFT)
         {
            return this.m_offsetLeft;
         }
         if(param1 == ATTRIBUTE_OFFSET_TOP)
         {
            return this.m_offsetTop;
         }
         if(param1 == ATTRIBUTE_OFFSET_RIGHT)
         {
            return this.m_offsetRight;
         }
         if(param1 == ATTRIBUTE_OFFSET_BOTTOM)
         {
            return this.m_offsetBottom;
         }
         if(param1 == ATTRIBUTE_BLEND_MODE)
         {
            return this.blendMode;
         }
         addWarning("Unknown attribute: \'" + param1 + "\' in getAttribute() in view " + this.name);
         return null;
      }
      
      public function localizeAttributeValue(param1:MT4DManager, param2:String, param3:String) : String
      {
         return param3;
      }
      
      public function setController(param1:BaseWidgetController) : void
      {
         this.m_controller = param1;
      }
      
      public function getController() : BaseWidgetController
      {
         return this.m_controller;
      }
      
      public function onChildResized(param1:BaseWidgetView) : void
      {
         dispatchEvent(new WidgetViewEvent(WidgetViewEvent.CHILD_RESIZE,param1));
      }
      
      public function onSkinExpanded(param1:BaseWidgetView, param2:BaseWidgetView) : void
      {
      }
      
      public function notifyResized(param1:BaseWidgetView = null) : void
      {
         if(Boolean(this.parent) && this.parent is BaseWidgetView)
         {
            if(param1 == null)
            {
               param1 = this;
            }
            BaseWidgetView(parent).onChildResized(param1);
         }
      }
      
      public function getLogicalChildren() : Array
      {
         return Utility.cloneArray(this.m_logicalChildren);
      }
      
      public function clearLogicalChildren() : void
      {
         this.m_logicalChildren = null;
      }
      
      public function getDisplayPath(param1:String = null) : String
      {
         var _loc3_:String = null;
         var _loc2_:String = "";
         if(param1 == null || param1 != name)
         {
            if(Boolean(parent) && parent is BaseWidgetView)
            {
               _loc3_ = BaseWidgetView(parent).getDisplayPath(param1);
               if(Boolean(_loc3_) && _loc3_ != "")
               {
                  _loc2_ = _loc3_ + "." + name;
               }
               else
               {
                  _loc2_ = name;
               }
            }
         }
         return _loc2_;
      }
      
      public function center(param1:DisplayObject = null) : void
      {
         var _loc2_:Rectangle = null;
         var _loc3_:BaseWidgetView = null;
         var _loc4_:Rectangle = null;
         if(param1 == null)
         {
            param1 = this.parent;
         }
         if(Boolean(param1) && Boolean(this.m_size))
         {
            _loc2_ = param1.getBounds(param1.stage);
            _loc3_ = param1 as BaseWidgetView;
            if(Boolean(_loc3_) && Boolean(_loc3_.getSize()))
            {
               _loc4_ = _loc3_.getSize();
               _loc2_.width = _loc4_.width;
               _loc2_.height = _loc4_.height;
            }
            x = _loc2_.width - this.m_size.width >> 1;
            y = _loc2_.height - this.m_size.height >> 1;
         }
      }
      
      override public function getChildByName(param1:String) : DisplayObject
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:DisplayObject = null;
         var _loc2_:DisplayObject = null;
         var _loc3_:int = param1.indexOf(".");
         if(_loc3_ != -1)
         {
            _loc4_ = param1.substring(0,_loc3_);
            _loc5_ = param1.substr(_loc3_ + 1);
            _loc6_ = super.getChildByName(_loc4_);
            if((Boolean(_loc6_)) && _loc6_ is DisplayObjectContainer)
            {
               _loc2_ = DisplayObjectContainer(_loc6_).getChildByName(_loc5_);
            }
            else
            {
               addWarning("View \'" + _loc4_ + "\' not found in view \'" + this.name + "\' for path: " + param1);
            }
         }
         else
         {
            _loc2_ = super.getChildByName(param1);
         }
         return _loc2_;
      }
      
      public function findChildViewByName(param1:String) : BaseWidgetView
      {
         var _loc5_:BaseWidgetView = null;
         var _loc2_:BaseWidgetView = super.getChildByName(param1) as BaseWidgetView;
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         var _loc3_:int = this.numChildren;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = this.getChildAt(_loc4_) as BaseWidgetView;
            if(_loc5_)
            {
               _loc2_ = _loc5_.findChildViewByName(param1);
               if(_loc2_ != null)
               {
                  return _loc2_;
               }
            }
            _loc4_++;
         }
         return null;
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:BaseWidgetView = null;
         var _loc4_:BaseWidgetView = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1 is BaseWidgetView && numChildren > 0)
         {
            _loc3_ = BaseWidgetView(param1);
            _loc5_ = 0;
            while(_loc6_ < this.numChildren)
            {
               _loc4_ = this.getChildAt(_loc6_) as BaseWidgetView;
               if(_loc4_)
               {
                  if(_loc4_.getDepthIndex() > _loc3_.getDepthIndex())
                  {
                     _loc2_ = super.addChildAt(param1,_loc6_);
                     break;
                  }
                  if(_loc6_ == numChildren - 1)
                  {
                     _loc2_ = super.addChild(param1);
                  }
               }
               else
               {
                  _loc2_ = super.addChild(param1);
               }
               _loc6_++;
            }
         }
         else
         {
            _loc2_ = super.addChild(param1);
         }
         if(param1 is BaseWidgetView)
         {
            if(this.m_logicalChildren == null)
            {
               this.m_logicalChildren = [];
            }
            this.m_logicalChildren.push(param1);
         }
         return _loc2_;
      }
      
      public function getLogicalChildIndex(param1:BaseWidgetView) : int
      {
         return this.m_logicalChildren.indexOf(param1);
      }
      
      public function reorderDisplayChild(param1:BaseWidgetView) : void
      {
         var _loc4_:BaseWidgetView = null;
         var _loc2_:int = getChildIndex(param1);
         var _loc3_:* = 0;
         while(_loc3_ < this.numChildren)
         {
            if(_loc3_ != _loc2_)
            {
               _loc4_ = this.getChildAt(_loc3_) as BaseWidgetView;
               if(_loc4_)
               {
                  if(_loc4_.getDepthIndex() > param1.getDepthIndex())
                  {
                     if(_loc3_ > 0)
                     {
                        _loc3_--;
                     }
                     super.setChildIndex(param1,_loc3_);
                     break;
                  }
                  if(_loc3_ == numChildren - 1 && param1.getDepthIndex() > _loc4_.getDepthIndex())
                  {
                     super.setChildIndex(param1,_loc3_);
                  }
               }
            }
            _loc3_++;
         }
      }
      
      public function reorderLogicalChild(param1:BaseWidgetView, param2:int) : void
      {
         var _loc3_:int = this.getLogicalChildIndex(param1);
         if(_loc3_ >= 0)
         {
            if(param2 >= this.m_logicalChildren.length - 1)
            {
               param2 = this.m_logicalChildren.length - 1;
            }
            if(_loc3_ != param2)
            {
               this.m_logicalChildren.splice(_loc3_,1);
               this.m_logicalChildren.splice(param2,0,param1);
            }
         }
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         var _loc2_:int = 0;
         if(param1 is BaseWidgetView)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_logicalChildren.length)
            {
               if(this.m_logicalChildren[_loc2_] == param1)
               {
                  this.m_logicalChildren.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
         }
         return super.removeChild(param1);
      }
      
      public function getDialog() : DynamicDialog
      {
         var _loc2_:DynamicDialog = null;
         var _loc1_:BaseWidgetView = this;
         while(_loc1_)
         {
            _loc2_ = _loc1_.getController() as DynamicDialog;
            if(_loc2_)
            {
               return _loc2_;
            }
            _loc1_ = _loc1_.parent as BaseWidgetView;
         }
         return null;
      }
   }
}

