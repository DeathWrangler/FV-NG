package Display
{
   import flash.geom.Point;
   
   public class ZLocToolTip extends ToolTip
   {
      
      public function ZLocToolTip()
      {
         super();
      }
      
      override public function updatePosition() : void
      {
         this.updateToolTipPosition();
      }
      
      override protected function updateToolTipPosition() : void
      {
         var pos:Point = null;
         if(m_toolTipObj)
         {
            pos = new Point(Global.stage.mouseX + 10,Global.stage.mouseY - m_toolTipObj.height - 10);
            if(Global.stage.stageWidth - m_toolTipObj.width < pos.x)
            {
               pos.x = Global.stage.mouseX - m_toolTipObj.width - 10;
            }
            if(Global.stage.stageHeight - m_toolTipObj.height < pos.y)
            {
               pos.y = Global.stage.mouseY - m_toolTipObj.height - 10;
            }
            else if(pos.y < 0)
            {
               pos.y = 0;
            }
            m_toolTipObj.x = pos.x;
            m_toolTipObj.y = pos.y;
         }
      }
   }
}

