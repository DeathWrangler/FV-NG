package Widgets.Frames.LESet
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.LESet.LESurfacingSlot;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.LESet.LESurfacingWindow;
   import flash.display.DisplayObject;
   
   public class LESurfacingSlotFrame extends LESlotFrame
   {
      
      private var m_featureName:String = "le_display_promo";
      
      public function LESurfacingSlotFrame(element:DisplayObject, leSet:Array, parentWindow:FarmWindow, featureName:String = "le_display_promo")
      {
         this.m_featureName = featureName;
         super(element,leSet,parentWindow);
      }
      
      public function getTotalPriceForShownItems() : int
      {
         var slot:LESurfacingSlot = null;
         var amt:int = 0;
         for each(slot in m_slots)
         {
            if(slot.visible)
            {
               amt += slot.getSlotItemCost();
            }
         }
         return amt;
      }
      
      public function buyItemsFromSlots() : void
      {
         var slot:LESurfacingSlot = null;
         for each(slot in m_slots)
         {
            if(slot.visible)
            {
               slot.buyItem();
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new LESurfacingSlot(slotElement,m_parentWindow,this.m_featureName);
      }
      
      override public function refresh() : void
      {
         super.refresh();
         if(m_parentWindow is LESurfacingWindow)
         {
            (m_parentWindow as LESurfacingWindow).refreshWindow();
         }
      }
   }
}

