package Widgets.Core.Frames
{
   import Widgets.Core.Interfaces.IZwDataPopulator;
   import flash.display.DisplayObject;
   
   public class ZwSlotFrame extends ZwFrame implements IZwDataPopulator
   {
      
      public function ZwSlotFrame(element:DisplayObject)
      {
         super(element);
      }
      
      public function populate(data:Object) : void
      {
         this.clearView();
      }
      
      public function clearView() : void
      {
         m_widgetManager.hideAllWidgets();
      }
   }
}

