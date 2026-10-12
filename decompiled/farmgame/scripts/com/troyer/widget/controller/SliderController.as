package com.troyer.widget.controller
{
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class SliderController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_AXIS:String = "axis";
      
      public static const ATTRIBUTE_SLIDER:String = "slider";
      
      public static const ATTRIBUTE_SLIDE_REGION:String = "slideRegion";
      
      public static const ATTRIBUTE_SLIDE_PERCENT:String = "slidePercent";
      
      public static const ATTRIBUTE_DECREMENT_BUTTON:String = "decrementButton";
      
      public static const ATTRIBUTE_INCREMENT_BUTTON:String = "incrementButton";
      
      public static const ATTRIBUTE_INCREMENT_DISTANCE:String = "incrementDistance";
      
      public static const AXIS_HORIZONTAL:String = "x";
      
      public static const AXIS_VERTICAL:String = "y";
      
      private var m_sliderController:BaseWidgetController;
      
      private var m_slideRegionController:BaseWidgetController;
      
      private var m_axis:String = "x";
      
      private var m_slidePercent:Number = 0;
      
      private var m_clickPosition:Point;
      
      private var m_incrementDistance:int = 20;
      
      private var m_decrementButtonController:BaseWidgetController;
      
      private var m_incrementButtonController:BaseWidgetController;
      
      public function SliderController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         if(param1 == ATTRIBUTE_SLIDER && param2 is String)
         {
            this.m_sliderController = getChildController(param2);
            if(this.m_sliderController)
            {
               this.m_sliderController.setAttribute(BaseWidgetView.ATTRIBUTE_OBSTRUCT,false);
               this.m_sliderController.addViewListener(MouseEvent.MOUSE_DOWN,this.onSliderPress);
            }
         }
         else if(param1 == ATTRIBUTE_SLIDE_REGION)
         {
            this.m_slideRegionController = getChildController(param2);
         }
         else if(param1 == ATTRIBUTE_AXIS && param2 is String)
         {
            this.m_axis = param2;
         }
         else if(param1 == ATTRIBUTE_DECREMENT_BUTTON && param2 is String)
         {
            this.m_decrementButtonController = getChildController(param2);
            if(this.m_decrementButtonController is ButtonController)
            {
               this.m_decrementButtonController.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onDecrement);
            }
            else
            {
               addError(param2 + " is not a valid " + param1 + " in controller: " + m_name);
            }
         }
         else if(param1 == ATTRIBUTE_INCREMENT_BUTTON && param2 is String)
         {
            this.m_incrementButtonController = getChildController(param2);
            if(this.m_incrementButtonController is ButtonController)
            {
               this.m_incrementButtonController.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onIncrement);
            }
            else
            {
               addError(param2 + " is not a valid " + param1 + " in controller: " + m_name);
            }
         }
         else if(param1 == ATTRIBUTE_INCREMENT_DISTANCE)
         {
            if(param2 is String)
            {
               this.m_incrementDistance = parseInt(param2);
            }
            else if(param2 is Number)
            {
               this.m_incrementDistance = param2;
            }
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_AXIS)
         {
            _loc2_ = this.m_axis;
         }
         else if(param1 == ATTRIBUTE_SLIDE_PERCENT)
         {
            _loc2_ = this.m_slidePercent;
         }
         else if(param1 == ATTRIBUTE_SLIDER)
         {
            _loc2_ = this.m_sliderController;
         }
         else if(param1 == ATTRIBUTE_SLIDE_REGION)
         {
            _loc2_ = this.m_slideRegionController;
         }
         else if(param1 == ATTRIBUTE_INCREMENT_DISTANCE)
         {
            _loc2_ = this.m_incrementDistance;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      private function setSliderPosition(param1:int) : void
      {
         var _loc2_:BaseWidgetView = null;
         var _loc3_:Rectangle = null;
         var _loc4_:Rectangle = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         if(Boolean(this.m_slideRegionController) && Boolean(this.m_sliderController))
         {
            _loc2_ = this.m_slideRegionController.getView();
            _loc3_ = _loc2_.getSize();
            _loc4_ = this.m_sliderController.getView().getSize();
            if(_loc3_)
            {
               _loc5_ = BaseWidgetController.ATTRIBUTE_X;
               _loc6_ = "width";
               if(this.m_axis == AXIS_VERTICAL)
               {
                  _loc5_ = BaseWidgetController.ATTRIBUTE_Y;
                  _loc6_ = "height";
               }
               _loc7_ = int(_loc3_[_loc6_]);
               if(_loc4_)
               {
                  _loc7_ -= _loc4_[_loc6_];
               }
               if(param1 < 0)
               {
                  param1 = 0;
               }
               else if(param1 > _loc7_)
               {
                  param1 = _loc7_;
               }
               this.m_slidePercent = param1 / _loc7_;
               this.m_sliderController.setAttribute(_loc5_,param1);
               dispatchEvent(new WidgetControllerEvent(WidgetControllerEvent.UPDATED,this));
            }
         }
      }
      
      private function getSliderPosition() : int
      {
         var _loc1_:int = 0;
         if(this.m_sliderController)
         {
            _loc1_ = this.m_sliderController.getAttribute(this.m_axis);
         }
         return _loc1_;
      }
      
      private function onSliderPress(param1:MouseEvent) : void
      {
         var _loc2_:BaseWidgetView = null;
         if(this.m_sliderController)
         {
            _loc2_ = this.m_sliderController.getView();
            if(Boolean(_loc2_) && Boolean(_loc2_.stage))
            {
               this.m_clickPosition = new Point(param1.localX,param1.localY);
               addListener(_loc2_.stage,MouseEvent.MOUSE_MOVE,this.onSliderDrag);
               addListener(_loc2_.stage,MouseEvent.MOUSE_UP,this.onSliderRelease);
               addListener(_loc2_,MouseEvent.MOUSE_UP,this.onSliderRelease);
            }
         }
      }
      
      private function onSliderDrag(param1:MouseEvent) : void
      {
         var _loc2_:BaseWidgetView = null;
         var _loc3_:Point = null;
         var _loc4_:int = 0;
         if(this.m_slideRegionController)
         {
            _loc2_ = this.m_slideRegionController.getView();
            if(_loc2_)
            {
               _loc3_ = _loc2_.globalToLocal(new Point(param1.stageX,param1.stageY));
               _loc4_ = _loc3_[this.m_axis] - this.m_clickPosition[this.m_axis];
               this.setSliderPosition(_loc4_);
            }
         }
      }
      
      private function onSliderRelease(param1:MouseEvent) : void
      {
         var _loc2_:BaseWidgetView = null;
         if(this.m_sliderController)
         {
            _loc2_ = this.m_sliderController.getView();
            if(Boolean(_loc2_) && Boolean(_loc2_.stage))
            {
               removeListener(_loc2_.stage,MouseEvent.MOUSE_MOVE);
               removeListener(_loc2_.stage,MouseEvent.MOUSE_UP);
               removeListener(_loc2_,MouseEvent.MOUSE_UP);
            }
         }
      }
      
      private function onDecrement(param1:WidgetControllerEvent) : void
      {
         this.setSliderPosition(this.getSliderPosition() - this.m_incrementDistance);
      }
      
      private function onIncrement(param1:WidgetControllerEvent) : void
      {
         this.setSliderPosition(this.getSliderPosition() + this.m_incrementDistance);
      }
   }
}

