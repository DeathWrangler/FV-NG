package Widgets.Frames.FleaMarket
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.FleaMarket.FleaMarketSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class FleaMarketSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_parentWindow:FarmWindow;
      
      public function FleaMarketSlotFrame(element:DisplayObject, parentWindow:FarmWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         addWidget(new ZwTextField(m_element.body_tf,ZLocUtils.t("Dialogs","fleaMarket_mainText")));
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var pattern:String = "\\d+";
         var regExp:RegExp = new RegExp(pattern,slotElement.name as String);
         var slotIndex:int = regExp.exec(slotElement.name as String);
         return new FleaMarketSlot(slotElement,this.m_parentWindow,slotIndex);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         super.release();
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
   }
}

