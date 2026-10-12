package com.troyer.widget.view
{
   import com.troyer.widget.MT4DContext;
   import com.troyer.widget.style.BaseStyle;
   import flash.geom.Rectangle;
   
   public class XView extends BaseWidgetView
   {
      
      public function XView(param1:BaseStyle = null, param2:Rectangle = null, param3:MT4DContext = null)
      {
         super(param1,param2);
      }
      
      override protected function setup() : void
      {
         if(!m_style || !m_size)
         {
            return;
         }
         var _loc1_:Number = m_size.width;
         var _loc2_:Number = m_size.height;
         var _loc3_:int = 3;
         if(m_style.hasData(BaseStyle.DATA_THICKNESS))
         {
            _loc3_ = parseInt(m_style.getData(BaseStyle.DATA_THICKNESS));
         }
         this.graphics.clear();
         this.graphics.lineStyle(_loc3_,m_style.getColor(0));
         this.graphics.moveTo(0,0);
         this.graphics.lineTo(_loc1_,_loc2_);
         this.graphics.moveTo(0,_loc2_);
         this.graphics.lineTo(_loc1_,0);
      }
   }
}

