package Widgets.Windows
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class CraftingArrowIndicatorWindow extends ArrowIndicatorWindow
   {
      
      private static const MAX_LINES_SHOWING:int = 2;
      
      protected var m_body:String;
      
      protected var m_animatedArrow:Boolean = false;
      
      private var m_altBodyText:Array;
      
      public function CraftingArrowIndicatorWindow(iconUrl:String, body:String, counterText:String = null, animatedArrow:Boolean = false, textVisible:Boolean = false, altBodyText:Array = null)
      {
         this.m_body = body;
         this.m_altBodyText = altBodyText;
         this.m_animatedArrow = animatedArrow;
         super(iconUrl,null,null,counterText,textVisible);
      }
      
      private function getBestFitTextField() : ZwTextField
      {
         var len:int = 0;
         var index:int = 0;
         var txtField:ZwTextField = new ZwTextField(m_window.arrowBounce_mc.boxRollover_mc.generic3_tf,this.m_body);
         if(this.m_altBodyText)
         {
            len = int(this.m_altBodyText.length);
            index = 0;
            if(txtField.element.hasOwnProperty("numLines"))
            {
               while(txtField.element.numLines > MAX_LINES_SHOWING && index < len)
               {
                  txtField = new ZwTextField(m_window.arrowBounce_mc.boxRollover_mc.generic3_tf,this.m_altBodyText[index]);
                  index++;
               }
            }
         }
         return txtField;
      }
      
      override protected function buildTextFrame() : ZwFrame
      {
         var textFrame:ZwFrame = new ZwFrame(m_window.arrowBounce_mc.boxRollover_mc);
         var txtField:ZwTextField = this.getBestFitTextField();
         textFrame.addWidget(txtField);
         textFrame.alpha = m_textVisible ? 100 : 0;
         return textFrame;
      }
      
      override protected function setupAnimation() : void
      {
         m_window.arrowBounce_mc.gotoAndStop(0);
         if(this.m_animatedArrow)
         {
            super.setupAnimation();
         }
      }
   }
}

