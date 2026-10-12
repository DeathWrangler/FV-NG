package com.troyer.widget.view
{
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.style.BaseStyle;
   import flash.display.GradientType;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class GradientRectangleView extends RectangleView
   {
      
      private static const INDEX_BODY_SECOND_COLOR:int = 2;
      
      public function GradientRectangleView(param1:BaseStyle = null, param2:Rectangle = null, param3:MT4DContext = null)
      {
         super(param1,param2);
      }
      
      override protected function setBodyColor() : void
      {
         var _loc10_:String = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc1_:Number = 0;
         if(m_style.hasData(BaseStyle.DATA_ANGLE))
         {
            _loc1_ = parseInt(m_style.getData(BaseStyle.DATA_ANGLE)) * Math.PI / 180;
         }
         var _loc2_:int = 2;
         if(m_style.hasData(BaseStyle.DATA_COLORS))
         {
            _loc2_ = parseInt(m_style.getData(BaseStyle.DATA_COLORS));
         }
         var _loc3_:String = GradientType.LINEAR;
         if(m_style.hasData(BaseStyle.DATA_GRADIENT_TYPE))
         {
            _loc3_ = m_style.getData(BaseStyle.DATA_GRADIENT_TYPE);
         }
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = null;
         if(m_style.hasData(BaseStyle.DATA_DISTRIBUTION))
         {
            _loc10_ = m_style.getData(BaseStyle.DATA_DISTRIBUTION);
            _loc7_ = _loc10_.split(",");
         }
         var _loc8_:int = 0;
         while(_loc8_ < _loc2_)
         {
            _loc4_.push(m_style.getColor(INDEX_BODY_COLOR + _loc8_));
            _loc5_.push(1);
            _loc11_ = _loc8_ / (_loc2_ - 1);
            if(Boolean(_loc7_) && _loc8_ < _loc7_.length)
            {
               _loc12_ = parseFloat(_loc7_[_loc8_]);
               if(!isNaN(_loc12_))
               {
                  _loc11_ = _loc12_;
               }
            }
            _loc6_.push(_loc11_ * 255);
            _loc8_++;
         }
         var _loc9_:Matrix = new Matrix();
         _loc9_.createGradientBox(m_size.width,m_size.height,_loc1_);
         this.graphics.beginGradientFill(_loc3_,_loc4_,_loc5_,_loc6_,_loc9_);
      }
   }
}

