package com.troyer.widget.controller
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.geom.Rectangle;
   
   public class ResizeController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_RESIZE_WIDTHS:String = "resizeWidths";
      
      public static const ATTRIBUTE_RESIZE_HEIGHTS:String = "resizeHeights";
      
      public static const ATTRIBUTE_PAD_X:String = "padX";
      
      public static const ATTRIBUTE_PAD_Y:String = "padY";
      
      public static const ATTRIBUTE_MARGIN_LEFT:String = "marginLeft";
      
      public static const ATTRIBUTE_MARGIN_RIGHT:String = "marginRight";
      
      public static const ATTRIBUTE_MARGIN_TOP:String = "marginTop";
      
      public static const ATTRIBUTE_MARGIN_BOTTOM:String = "marginBottom";
      
      public static const ATTRIBUTE_VIEW_TO_PIN:String = "viewToPin";
      
      public static const ATTRIBUTE_PIN_HORIZONTAL:String = "pinHorizontal";
      
      public static const ATTRIBUTE_PIN_VERTICAL:String = "pinVertical";
      
      public static const ATTRIBUTE_PIN_OFFSET_X:String = "pinOffsetX";
      
      public static const ATTRIBUTE_PIN_OFFSET_Y:String = "pinOffsetY";
      
      private var m_paddingX:Number = 0;
      
      private var m_paddingY:Number = 0;
      
      private var m_childrenToChangeWidths:Array;
      
      private var m_childrenToChangeHeights:Array;
      
      private var m_marginLeft:Number;
      
      private var m_marginRight:Number;
      
      private var m_marginTop:Number;
      
      private var m_marginBottom:Number;
      
      private var m_pinView:BaseWidgetView;
      
      private var m_pinHorizontal:int = 0;
      
      private var m_pinVertical:int = 0;
      
      private var m_pinOffsetX:int = 0;
      
      private var m_pinOffsetY:int = 0;
      
      public function ResizeController(param1:BaseWidgetView)
      {
         super(param1);
         addGlobalListener(WidgetControllerEvent.VIEW_PINNED);
      }
      
      override public function destroy() : void
      {
         this.m_childrenToChangeWidths = null;
         this.m_childrenToChangeHeights = null;
         if(this.m_pinView)
         {
            this.m_pinView.destroy();
            this.m_pinView = null;
         }
         super.destroy();
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_RESIZE_WIDTHS,ATTRIBUTE_RESIZE_HEIGHTS,ATTRIBUTE_VIEW_TO_PIN);
         return _loc1_;
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_VIEW_TO_PIN)
         {
            _loc2_ = this.m_pinView;
         }
         else if(param1 == ATTRIBUTE_PAD_X)
         {
            _loc2_ = this.m_paddingX;
         }
         else if(param1 == ATTRIBUTE_PAD_Y)
         {
            _loc2_ = this.m_paddingY;
         }
         else if(param1 == ATTRIBUTE_MARGIN_LEFT)
         {
            _loc2_ = this.m_marginLeft;
         }
         else if(param1 == ATTRIBUTE_MARGIN_TOP)
         {
            _loc2_ = this.m_marginTop;
         }
         else if(param1 == ATTRIBUTE_MARGIN_RIGHT)
         {
            _loc2_ = this.m_marginRight;
         }
         else if(param1 == ATTRIBUTE_MARGIN_BOTTOM)
         {
            _loc2_ = this.m_marginBottom;
         }
         else if(param1 == ATTRIBUTE_PIN_HORIZONTAL)
         {
            if(this.m_pinHorizontal < 0)
            {
               _loc2_ = Constants.ALIGN_LEFT;
            }
            else if(this.m_pinHorizontal > 0)
            {
               _loc2_ = Constants.ALIGN_RIGHT;
            }
            else
            {
               _loc2_ = Constants.ALIGN_CENTER;
            }
         }
         else if(param1 == ATTRIBUTE_PIN_VERTICAL)
         {
            if(this.m_pinVertical < 0)
            {
               _loc2_ = Constants.ALIGN_TOP;
            }
            else if(this.m_pinVertical > 0)
            {
               _loc2_ = Constants.ALIGN_BOTTOM;
            }
            else
            {
               _loc2_ = Constants.ALIGN_CENTER;
            }
         }
         else if(param1 == ATTRIBUTE_PIN_OFFSET_X)
         {
            _loc2_ = this.m_pinOffsetX;
         }
         else if(param1 == ATTRIBUTE_PIN_OFFSET_Y)
         {
            _loc2_ = this.m_pinOffsetY;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         if(param1 == ATTRIBUTE_PAD_X)
         {
            this.m_paddingX = parseInt(param2);
            this.updateSize();
         }
         else if(param1 == ATTRIBUTE_PAD_Y)
         {
            this.m_paddingY = parseInt(param2);
            this.updateSize();
         }
         else if(param1 == ATTRIBUTE_RESIZE_WIDTHS && param2 is String)
         {
            this.m_childrenToChangeWidths = String(param2).split(",");
         }
         else if(param1 == ATTRIBUTE_RESIZE_HEIGHTS && param2 is String)
         {
            this.m_childrenToChangeHeights = String(param2).split(",");
         }
         else if(param1 == ATTRIBUTE_MARGIN_LEFT && param2 is String)
         {
            this.m_marginLeft = parseFloat(param2);
            this.updateSize();
         }
         else if(param1 == ATTRIBUTE_MARGIN_RIGHT && param2 is String)
         {
            this.m_marginRight = parseFloat(param2);
            this.updateSize();
         }
         else if(param1 == ATTRIBUTE_MARGIN_TOP && param2 is String)
         {
            this.m_marginTop = parseFloat(param2);
            this.updateSize();
         }
         else if(param1 == ATTRIBUTE_MARGIN_BOTTOM && param2 is String)
         {
            this.m_marginBottom = parseFloat(param2);
            this.updateSize();
         }
         else if(param1 == ATTRIBUTE_VIEW_TO_PIN && param2 is BaseWidgetView)
         {
            if(this.m_pinView)
            {
               this.m_pinView.destroy();
               this.m_pinView = null;
            }
            this.m_pinView = param2;
            this.updatePinnedView();
         }
         else if(param1 == ATTRIBUTE_PIN_HORIZONTAL && param2 is String)
         {
            if(param2 == Constants.ALIGN_LEFT)
            {
               this.m_pinHorizontal = -1;
               this.updatePinnedView();
            }
            else if(param2 == Constants.ALIGN_CENTER)
            {
               this.m_pinHorizontal = 0;
               this.updatePinnedView();
            }
            else if(param2 == Constants.ALIGN_RIGHT)
            {
               this.m_pinHorizontal = 1;
               this.updatePinnedView();
            }
            else
            {
               addError("Invalid value " + param2 + " for attribute " + param1 + " in view " + m_name);
            }
         }
         else if(param1 == ATTRIBUTE_PIN_VERTICAL && param2 is String)
         {
            if(param2 == Constants.ALIGN_TOP)
            {
               this.m_pinVertical = -1;
               this.updatePinnedView();
            }
            else if(param2 == Constants.ALIGN_CENTER)
            {
               this.m_pinVertical = 0;
               this.updatePinnedView();
            }
            else if(param2 == Constants.ALIGN_BOTTOM)
            {
               this.m_pinVertical = 1;
               this.updatePinnedView();
            }
            else
            {
               addError("Invalid value " + param2 + " for attribute " + param1 + " in view " + m_name);
            }
         }
         else if(param1 == ATTRIBUTE_PIN_OFFSET_X)
         {
            if(param2 is String)
            {
               this.m_pinOffsetX = parseInt(param2);
            }
            else if(param2 is Number)
            {
               this.m_pinOffsetX = param2;
            }
            this.updatePinnedView();
         }
         else if(param1 == ATTRIBUTE_PIN_OFFSET_Y)
         {
            if(param2 is String)
            {
               this.m_pinOffsetY = parseInt(param2);
            }
            else if(param2 is Number)
            {
               this.m_pinOffsetY = param2;
            }
            this.updatePinnedView();
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         this.updateSize();
      }
      
      protected function getEligibleChildren() : Array
      {
         return getViewChildren();
      }
      
      private function updateSize() : void
      {
         var _loc10_:BaseWidgetView = null;
         var _loc11_:Rectangle = null;
         var _loc15_:Number = NaN;
         var _loc16_:BaseWidgetController = null;
         var _loc17_:String = null;
         var _loc18_:BaseWidgetController = null;
         var _loc19_:String = null;
         var _loc20_:BaseWidgetController = null;
         var _loc1_:Number = isNaN(this.m_marginLeft) ? this.m_paddingX : this.m_marginLeft;
         var _loc2_:Number = isNaN(this.m_marginRight) ? this.m_paddingX : this.m_marginRight;
         var _loc3_:Number = isNaN(this.m_marginTop) ? this.m_paddingY : this.m_marginTop;
         var _loc4_:Number = isNaN(this.m_marginBottom) ? this.m_paddingY : this.m_marginBottom;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:Number = 0;
         var _loc8_:Number = 0;
         var _loc9_:Array = this.getEligibleChildren();
         var _loc12_:Boolean = false;
         var _loc13_:BaseStyle = m_view.getStyle();
         var _loc14_:Number = 0;
         if(Boolean(_loc13_) && _loc13_.hasData(BaseStyle.DATA_BORDER))
         {
            _loc14_ = parseInt(_loc13_.getData(BaseStyle.DATA_BORDER));
         }
         if(!m_view.hasFixedWidth())
         {
            for each(_loc10_ in _loc9_)
            {
               _loc15_ = _loc10_.width;
               if(_loc10_ is BaseWidgetView)
               {
                  if(!_loc10_.getAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT))
                  {
                     continue;
                  }
                  _loc11_ = BaseWidgetView(_loc10_).getAdjustedSize();
                  if(_loc11_)
                  {
                     _loc15_ = _loc11_.width;
                  }
               }
               if(_loc15_ > _loc7_)
               {
                  _loc7_ = _loc15_;
               }
            }
            _loc5_ = _loc7_ + _loc14_ * 2 + (_loc1_ + _loc2_);
            _loc12_ = true;
         }
         else
         {
            _loc7_ = _loc5_ = m_view.getSize().width;
         }
         if(!m_view.hasFixedHeight())
         {
            for each(_loc10_ in _loc9_)
            {
               if(_loc10_.getAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT))
               {
                  _loc11_ = BaseWidgetView(_loc10_).getAdjustedSize();
                  if((Boolean(_loc11_)) && _loc11_.height > _loc8_)
                  {
                     _loc8_ = _loc11_.height;
                  }
               }
            }
            _loc6_ = _loc8_ + _loc14_ * 2 + (_loc3_ + _loc4_);
            _loc12_ = true;
         }
         else
         {
            _loc8_ = _loc6_ = m_view.getSize().height;
         }
         if(_loc12_)
         {
            m_view.setSize(new Rectangle(0,0,_loc5_,_loc6_));
            for each(_loc10_ in _loc9_)
            {
               _loc16_ = _loc10_.getController();
               _loc16_.setAttribute(BaseWidgetController.ATTRIBUTE_X,_loc1_ + _loc14_ + _loc10_.getOffsetLeft());
               _loc16_.setAttribute(BaseWidgetController.ATTRIBUTE_Y,_loc3_ + _loc14_ + _loc10_.getOffsetTop());
            }
            if(this.m_childrenToChangeWidths)
            {
               for each(_loc17_ in this.m_childrenToChangeWidths)
               {
                  _loc18_ = getChildController(_loc17_);
                  if(_loc18_)
                  {
                     _loc11_ = _loc18_.getView().getSize();
                     if((Boolean(_loc11_)) && _loc11_.width < _loc7_)
                     {
                        _loc18_.setAttribute(BaseWidgetController.ATTRIBUTE_WIDTH,_loc7_);
                     }
                  }
               }
            }
            if(this.m_childrenToChangeHeights)
            {
               for each(_loc19_ in this.m_childrenToChangeHeights)
               {
                  _loc20_ = getChildController(_loc19_);
                  if(_loc20_)
                  {
                     _loc11_ = _loc20_.getView().getSize();
                     if((Boolean(_loc11_)) && _loc11_.height < _loc8_)
                     {
                        _loc20_.setAttribute(BaseWidgetController.ATTRIBUTE_HEIGHT,_loc8_);
                     }
                  }
               }
            }
         }
         this.updatePinnedView();
      }
      
      private function updatePinnedView() : void
      {
         var _loc1_:Rectangle = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Rectangle = null;
         if(this.m_pinView)
         {
            _loc1_ = m_view.getSize();
            if(_loc1_)
            {
               if(!this.m_pinView.parent)
               {
                  m_view.addChild(this.m_pinView);
                  dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.VIEW_PINNED,this.m_pinView.getController()));
               }
               _loc2_ = _loc1_.width / 2;
               _loc3_ = _loc1_.height / 2;
               this.m_pinView.x = _loc2_ + this.m_pinHorizontal * _loc2_ + this.m_pinOffsetX;
               this.m_pinView.y = _loc3_ + this.m_pinVertical * _loc3_ + this.m_pinOffsetY;
               _loc4_ = this.m_pinView.getSize();
               if(_loc4_)
               {
                  this.m_pinView.x -= _loc4_.width >> 1;
                  this.m_pinView.y -= _loc4_.height >> 1;
               }
            }
         }
      }
   }
}

