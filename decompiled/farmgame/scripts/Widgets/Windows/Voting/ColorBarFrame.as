package Widgets.Windows.Voting
{
   import Managers.TemplateUIUtility;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   
   public class ColorBarFrame extends ZwFrame
   {
      
      public function ColorBarFrame(element:DisplayObject, textColor:String)
      {
         super(element);
         var barFrame:ZwFrame = addWidget(new ZwFrame(m_element.color_mc)) as ZwFrame;
         TemplateUIUtility.applyBackgroundColor(barFrame.element as DisplayObject,TemplateUIUtility.VOTING,textColor);
         barFrame.visible = true;
      }
   }
}

