package Widgets.View.Buttons
{
   import Widgets.View.Core.*;
   import flash.display.MovieClip;
   
   public class ButtonGroup extends ElementBase
   {
      
      public static const SPACE_BETWEEN_BUTTONS:Number = 20;
      
      private var m_container:MovieClip = new MovieClip();
      
      private var m_buttons:Array = new Array();
      
      public function ButtonGroup(aKeyValuePairs:Array)
      {
         super(aKeyValuePairs);
         m_originType = ElementBase.NUM_ORIGIN_TYPE_CENTER_CENTER;
         addChild(this.m_container);
      }
      
      public function addButton(pBtn:ButtonBase) : void
      {
         this.m_buttons.push(pBtn);
         if(pBtn.parent)
         {
            pBtn.parent.removeChild(pBtn);
         }
         this.m_container.addChild(pBtn);
         if(pBtn.getHeight() > m_heightNoShadow)
         {
            m_heightNoShadow = pBtn.getHeight();
         }
      }
      
      public function refreshVisual() : void
      {
         var pBtn:ButtonBase = null;
         var nCurWidth:Number = 0;
         for(var i:Number = 0; i < this.m_buttons.length; i++)
         {
            pBtn = this.m_buttons[i] as ButtonBase;
            if(pBtn.visible)
            {
               pBtn.x = 0 + nCurWidth + pBtn.getWidth() * 0.5;
               pBtn.y = 0;
               nCurWidth += pBtn.getWidth() + SPACE_BETWEEN_BUTTONS;
            }
         }
         nCurWidth -= SPACE_BETWEEN_BUTTONS;
         m_widthNoShadow = nCurWidth;
         this.m_container.x = nCurWidth * -0.5;
         this.m_container.y = 0;
      }
   }
}

