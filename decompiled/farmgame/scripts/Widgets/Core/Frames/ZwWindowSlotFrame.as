package Widgets.Core.Frames
{
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class ZwWindowSlotFrame extends ZwSlotFrame
   {
      
      protected var m_parentWindow:FarmWindow;
      
      public function ZwWindowSlotFrame(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
      }
   }
}

