package com.troyer.widget.controller
{
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   
   public class ProgressBarController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_TARGET:String = "target";
      
      public static const ATTRIBUTE_AXIS:String = "axis";
      
      public static const ATTRIBUTE_PERCENT:String = "percent";
      
      public static const ATTRIBUTE_DIRECTION:String = "direction";
      
      public static const AXIS_X:String = "x";
      
      public static const AXIS_Y:String = "y";
      
      private var m_targetController:BaseWidgetController;
      
      private var m_axis:String = "x";
      
      private var m_mask:Sprite = new Sprite();
      
      private var m_percent:Number = 1;
      
      private var m_direction:Number = 1;
      
      public function ProgressBarController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override public function getAttributeOrder() : Array
      {
         var _loc1_:Array = super.getAttributeOrder();
         _loc1_.push(ATTRIBUTE_TARGET,ATTRIBUTE_AXIS,ATTRIBUTE_PERCENT);
         return _loc1_;
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         if(param1 == ATTRIBUTE_TARGET && param2 is String)
         {
            this.m_targetController = this.getChildController(param2);
         }
         else if(param1 == ATTRIBUTE_AXIS && param2 is String)
         {
            param2 = String(param2).toLowerCase();
            if(param2 == AXIS_X || param2 == AXIS_Y)
            {
               this.m_axis = param2;
            }
         }
         else if(param1 == ATTRIBUTE_PERCENT)
         {
            if(param2 is String)
            {
               this.m_percent = parseFloat(param2);
               this.updateBar();
            }
            else if(param2 is Number)
            {
               this.m_percent = param2;
               this.updateBar();
            }
         }
         else if(param1 == ATTRIBUTE_DIRECTION)
         {
            if(param2 is String)
            {
               this.m_direction = parseInt(param2);
               this.updateBar();
            }
            else if(param2 is Number)
            {
               this.m_direction = param2;
               this.updateBar();
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
         if(param1 == ATTRIBUTE_PERCENT)
         {
            _loc2_ = this.m_percent;
         }
         else if(param1 == ATTRIBUTE_AXIS)
         {
            _loc2_ = this.m_axis;
         }
         else if(param1 == ATTRIBUTE_DIRECTION)
         {
            _loc2_ = this.m_direction;
         }
         else if(param1 == ATTRIBUTE_TARGET)
         {
            _loc2_ = this.m_targetController;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         this.updateBar();
         super.onChildViewResized(param1);
      }
      
      private function updateBar() : void
      {
         var _loc1_:BaseWidgetView = null;
         var _loc2_:Rectangle = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.m_targetController)
         {
            _loc1_ = this.m_targetController.getView();
            _loc2_ = _loc1_.getSize();
            if(_loc2_)
            {
               _loc3_ = _loc2_.width;
               _loc4_ = _loc2_.height;
               if(this.m_axis == AXIS_X)
               {
                  _loc3_ *= this.m_percent;
               }
               else if(this.m_axis == AXIS_Y)
               {
                  _loc4_ *= this.m_percent;
               }
               this.m_mask.graphics.clear();
               this.m_mask.graphics.beginFill(0);
               if(this.m_direction >= 0)
               {
                  this.m_mask.graphics.drawRect(0,0,_loc3_,_loc4_);
               }
               else
               {
                  this.m_mask.graphics.drawRect(_loc2_.width - _loc3_,_loc2_.height - _loc4_,_loc3_,_loc4_);
               }
               this.m_mask.graphics.endFill();
               if(this.m_mask.parent != _loc1_)
               {
                  _loc1_.addChild(this.m_mask);
                  _loc1_.mask = this.m_mask;
               }
            }
         }
      }
   }
}

