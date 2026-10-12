package com.troyer.widget.view
{
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.style.BaseStyle;
   import flash.geom.Rectangle;
   
   public class RectangleView extends BaseWidgetView
   {
      
      public static const INDEX_BORDER_COLOR:int = 0;
      
      public static const INDEX_BODY_COLOR:int = 1;
      
      public static const DATA_FILL_ALPHA:String = "fillAlpha";
      
      public static const DATA_HIGHLIGHT:String = "highlight";
      
      private var m_round:Number = 0;
      
      private var m_borderThickness:int = 0;
      
      private var m_fillAlpha:Number = 1;
      
      public function RectangleView(param1:BaseStyle = null, param2:Rectangle = null, param3:MT4DContext = null)
      {
         super(param1,param2);
      }
      
      override protected function setup() : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         if(!m_style || !m_size)
         {
            return;
         }
         this.graphics.clear();
         var _loc1_:Number = 1;
         if(m_style.hasData(BaseStyle.DATA_ROUND))
         {
            this.m_round = parseFloat(m_style.getData(BaseStyle.DATA_ROUND));
         }
         if(m_style.hasData(BaseStyle.DATA_BORDER))
         {
            this.m_borderThickness = parseInt(m_style.getData(BaseStyle.DATA_BORDER));
         }
         if(m_style.hasData(DATA_FILL_ALPHA))
         {
            this.m_fillAlpha = parseFloat(m_style.getData(DATA_FILL_ALPHA));
         }
         var _loc2_:Number = this.m_round;
         var _loc3_:Number = Math.min(m_size.width,m_size.height);
         if(this.m_round <= 1)
         {
            _loc2_ = _loc3_ * this.m_round;
         }
         if(this.m_borderThickness > 0)
         {
            this.setBorderColor();
            this.graphics.drawRoundRect(0,0,m_size.width,m_size.height,_loc2_,_loc2_);
            _loc4_ = this.m_borderThickness << 1;
            if(this.m_round <= 1)
            {
               _loc2_ = (_loc3_ - _loc4_) * this.m_round;
            }
            else
            {
               _loc2_ = this.m_round - _loc4_;
            }
            this.graphics.endFill();
         }
         this.setBodyColor();
         this.graphics.drawRoundRect(this.m_borderThickness,this.m_borderThickness,m_size.width - _loc4_,m_size.height - _loc4_,_loc2_,_loc2_);
         if(m_style.hasData(DATA_HIGHLIGHT))
         {
            _loc5_ = m_size.width - _loc2_ - 2 * this.m_borderThickness;
            if(_loc5_ > 0)
            {
               _loc6_ = parseInt(m_style.getData(DATA_HIGHLIGHT));
               this.graphics.beginFill(_loc6_);
               _loc7_ = _loc2_ + this.m_borderThickness + 1;
               _loc8_ = Math.floor(_loc2_ * 3 / 4) - this.m_borderThickness - 1;
               if(_loc8_ > m_size.height / 3)
               {
                  _loc8_ = Math.floor(m_size.height / 3);
               }
               this.graphics.endFill();
               this.graphics.lineStyle(0,_loc6_);
               this.graphics.moveTo(this.m_borderThickness + 1,_loc8_);
               this.graphics.curveTo(this.m_borderThickness,this.m_borderThickness,_loc7_,this.m_borderThickness + 1);
               this.graphics.lineTo(m_size.width - _loc7_,this.m_borderThickness + 1);
               this.graphics.curveTo(m_size.width - this.m_borderThickness,this.m_borderThickness,m_size.width - this.m_borderThickness - 1,_loc8_);
            }
         }
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
      
      override public function setStyle(param1:BaseStyle) : void
      {
         super.setStyle(param1);
         this.setup();
      }
   }
}

