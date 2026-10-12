package com.troyer.widget.view
{
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.style.BaseStyle;
   import flash.display.CapsStyle;
   import flash.geom.Rectangle;
   
   public class TriangleView extends BaseWidgetView
   {
      
      public static const ATTRIBUTE_AXIS:String = "axis";
      
      public static const ATTRIBUTE_DIRECTION:String = "direction";
      
      public static const AXIS_HORIZONTAL:String = "x";
      
      public static const AXIS_VERTICAL:String = "y";
      
      private var m_axis:String = "x";
      
      private var m_direction:int = 1;
      
      public function TriangleView(param1:BaseStyle = null, param2:Rectangle = null, param3:MT4DContext = null)
      {
         super(param1,param2);
      }
      
      override public function setAttribute(param1:String, param2:*) : void
      {
         var _loc3_:Number = NaN;
         if(param1 == ATTRIBUTE_AXIS && param2 is String)
         {
            this.m_axis = param2;
            this.setup();
         }
         else if(param1 == ATTRIBUTE_DIRECTION)
         {
            if(param2 is Number)
            {
               _loc3_ = param2;
            }
            else if(param2 is String)
            {
               _loc3_ = parseInt(param2);
            }
            if(isNaN(_loc3_) == false)
            {
               if(_loc3_ >= 0)
               {
                  this.m_direction = 1;
               }
               else
               {
                  this.m_direction = -1;
               }
               this.setup();
            }
         }
         else
         {
            super.setAttribute(param1,param2);
         }
      }
      
      override public function getAttribute(param1:String) : *
      {
         var _loc2_:* = null;
         if(param1 == ATTRIBUTE_AXIS)
         {
            _loc2_ = this.m_axis;
         }
         else if(param1 == ATTRIBUTE_DIRECTION)
         {
            _loc2_ = this.m_direction;
         }
         else
         {
            _loc2_ = super.getAttribute(param1);
         }
         return _loc2_;
      }
      
      override protected function setup() : void
      {
         var _loc3_:Number = NaN;
         if(!m_style || !m_size)
         {
            return;
         }
         this.graphics.clear();
         var _loc1_:int = BaseStyle.DEFAULT_THICKNESS;
         if(m_style.hasData(BaseStyle.DATA_THICKNESS))
         {
            _loc1_ = parseInt(m_style.getData(BaseStyle.DATA_THICKNESS));
         }
         var _loc2_:String = null;
         if(m_style.hasData(BaseStyle.DATA_ROUND))
         {
            _loc3_ = parseInt(m_style.getData(BaseStyle.DATA_ROUND));
            if(_loc3_ > 0)
            {
               _loc2_ = CapsStyle.ROUND;
            }
         }
         graphics.lineStyle(_loc1_,m_style.getColor(0),1,false,"normal",_loc2_);
         graphics.beginFill(m_style.getColor(1));
         if(this.m_axis == AXIS_HORIZONTAL)
         {
            if(this.m_direction > 0)
            {
               graphics.moveTo(0,0);
               graphics.lineTo(m_size.width,0);
               graphics.lineTo(m_size.width >> 1,m_size.height);
               graphics.lineTo(0,0);
            }
            else
            {
               graphics.moveTo(0,m_size.height);
               graphics.lineTo(m_size.width,m_size.height);
               graphics.lineTo(m_size.width >> 1,0);
               graphics.lineTo(0,m_size.height);
            }
         }
         else if(this.m_axis == AXIS_VERTICAL)
         {
            if(this.m_direction > 0)
            {
               graphics.moveTo(0,0);
               graphics.lineTo(0,m_size.height);
               graphics.lineTo(m_size.width,m_size.height >> 1);
               graphics.lineTo(0,0);
            }
            else
            {
               graphics.moveTo(m_size.width,0);
               graphics.lineTo(m_size.width,m_size.height);
               graphics.lineTo(0,m_size.height >> 1);
               graphics.lineTo(m_size.width,0);
            }
         }
         graphics.endFill();
      }
   }
}

