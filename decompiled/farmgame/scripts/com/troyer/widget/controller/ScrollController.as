package com.troyer.widget.controller
{
   import com.troyer.widget.event.WidgetViewEvent;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class ScrollController extends BaseWidgetController
   {
      
      public static const ATTRIBUTE_SCROLL_X:String = "scrollX";
      
      public static const ATTRIBUTE_SCROLL_Y:String = "scrollY";
      
      public static const SCROLL_DATA_SPEED:String = "speed";
      
      public static const SCROLL_DATA_DISTANCE:String = "distance";
      
      private var targetPos:Rectangle;
      
      private var m_speed:Point = new Point(500,500);
      
      public function ScrollController(param1:BaseWidgetView)
      {
         super(param1);
      }
      
      override protected function attribute(param1:String, param2:*) : void
      {
         var _loc3_:Rectangle = null;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         if(param1 == BaseWidgetController.ATTRIBUTE_WIDTH || param1 == BaseWidgetController.ATTRIBUTE_HEIGHT || param1 == BaseWidgetController.ATTRIBUTE_FORCE_WIDTH || param1 == BaseWidgetController.ATTRIBUTE_FORCE_HEIGHT)
         {
            super.attribute(param1,param2);
            m_view.scrollRect = m_view.getSize();
         }
         else if(param1 == ATTRIBUTE_SCROLL_X || param1 == ATTRIBUTE_SCROLL_Y)
         {
            if(!m_view.scrollRect)
            {
               m_view.scrollRect = m_view.getSize();
            }
            _loc3_ = m_view.scrollRect.clone();
            _loc4_ = param1.substr(6).toLowerCase();
            _loc5_ = 0;
            if(param2 is String)
            {
               _loc5_ += parseInt(param2);
            }
            else if(param2 is Number)
            {
               _loc5_ += param2;
            }
            else if(param2 is Dictionary && Boolean(param2[SCROLL_DATA_DISTANCE]))
            {
               _loc5_ += param2[SCROLL_DATA_DISTANCE];
               if(param2[SCROLL_DATA_SPEED])
               {
                  this.m_speed[_loc4_] = param2[SCROLL_DATA_SPEED] / this.m_view.stage.frameRate;
               }
            }
            else
            {
               addError("Invalid value passed as " + param1);
            }
            _loc3_[_loc4_] += _loc5_;
            this.targetPos = _loc3_;
            addViewListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
         else
         {
            super.attribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_SCROLL_X)
         {
            if(Boolean(m_view) && Boolean(m_view.scrollRect))
            {
               _loc2_ = m_view.scrollRect.x;
            }
         }
         else if(param1 == ATTRIBUTE_SCROLL_Y)
         {
            if(Boolean(m_view) && Boolean(m_view.scrollRect))
            {
               _loc2_ = m_view.scrollRect.y;
            }
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override protected function onChildViewResized(param1:WidgetViewEvent) : void
      {
         super.onChildViewResized(param1);
         if(!m_view.hasFixedWidth() && !m_view.hasFixedHeight())
         {
            m_view.setSize(param1.getView().getSize());
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc4_:Rectangle = null;
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         _loc4_ = m_view.scrollRect;
         if(Math.abs(this.m_speed.x) < Math.abs(this.targetPos.x - m_view.scrollRect.x))
         {
            _loc4_.x += this.m_speed.x;
            m_view.scrollRect = _loc4_;
         }
         else
         {
            _loc4_.x = this.targetPos.x;
            m_view.scrollRect = _loc4_;
            _loc2_ = true;
         }
         _loc4_ = m_view.scrollRect;
         if(Math.abs(this.m_speed.y) < Math.abs(this.targetPos.y - m_view.scrollRect.y))
         {
            _loc4_.y += this.m_speed.y;
            m_view.scrollRect = _loc4_;
         }
         else
         {
            m_view.scrollRect.y = this.targetPos.y;
            m_view.scrollRect = _loc4_;
            _loc3_ = true;
         }
         if(_loc2_ && _loc3_)
         {
            removeViewListener(Event.ENTER_FRAME);
         }
      }
   }
}

