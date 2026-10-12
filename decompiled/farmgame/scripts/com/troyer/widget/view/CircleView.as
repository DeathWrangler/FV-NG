package com.troyer.widget.view
{
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.style.BaseStyle;
   import flash.geom.Rectangle;
   
   public class CircleView extends BaseWidgetView
   {
      
      public static const INDEX_BODY_COLOR:int = 0;
      
      public static const INDEX_BORDER_COLOR:int = 1;
      
      public static const DATA_FILL_ALPHA:String = "fillAlpha";
      
      public static const DATA_RADIUS:String = "radius";
      
      private var m_radius:int = 1;
      
      private var m_borderThickness:int = 0;
      
      private var m_fillAlpha:Number = 1;
      
      public function CircleView(param1:BaseStyle = null, param2:Rectangle = null, param3:MT4DContext = null)
      {
         super(param1,param2,param3);
      }
      
      override protected function setup() : void
      {
         if(!m_style || !m_size)
         {
            return;
         }
         this.graphics.clear();
         var _loc1_:Number = 1;
         if(m_style.hasData(BaseStyle.DATA_BORDER))
         {
            this.m_borderThickness = parseInt(m_style.getData(BaseStyle.DATA_BORDER));
         }
         if(m_style.hasData(DATA_RADIUS))
         {
            this.m_radius = parseInt(m_style.getData(DATA_RADIUS));
         }
         if(m_style.hasData(DATA_FILL_ALPHA))
         {
            this.m_fillAlpha = parseFloat(m_style.getData(DATA_FILL_ALPHA));
         }
         if(this.m_borderThickness > 0)
         {
            this.setBorderColor();
            this.graphics.drawCircle(0,0,this.m_radius);
            this.graphics.endFill();
         }
         this.setBodyColor();
         this.graphics.drawCircle(0,0,this.m_radius - this.m_borderThickness);
         if(m_style.hasData(BaseStyle.DATA_SCALE))
         {
            _loc1_ = parseFloat(m_style.getData(BaseStyle.DATA_SCALE));
            this.scaleX = this.scaleY = _loc1_;
            this.x = m_size.width - m_size.width * _loc1_ >> 1;
            this.y = m_size.height - m_size.height * _loc1_ >> 1;
         }
      }
      
      protected function setBorderColor() : void
      {
         this.graphics.beginFill(m_style.getColor(INDEX_BORDER_COLOR));
      }
      
      protected function setBodyColor() : void
      {
         this.graphics.beginFill(m_style.getColor(INDEX_BODY_COLOR),this.m_fillAlpha);
      }
   }
}

