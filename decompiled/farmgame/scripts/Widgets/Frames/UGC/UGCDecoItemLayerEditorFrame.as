package Widgets.Frames.UGC
{
   import Classes.UGC.UGCItemState;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.UGC.UGCDecoItemLayerItemSlot;
   import Widgets.Slots.UGC.UGCItemLayerItemSlot;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class UGCDecoItemLayerEditorFrame extends UGCItemLayerEditorFrame
   {
      
      private var m_slotsListeners:Vector.<ZwSlotFrame> = new Vector.<ZwSlotFrame>();
      
      public function UGCDecoItemLayerEditorFrame(element:DisplayObject, ugcItemState:UGCItemState)
      {
         super(element,ugcItemState);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slot:UGCItemLayerItemSlot = new UGCDecoItemLayerItemSlot(slotElement);
         slot.registerEventListener(MouseEvent.CLICK,onItemClick);
         this.m_slotsListeners.push(slot);
         return slot;
      }
      
      override public function release() : void
      {
         while(this.m_slotsListeners.length > 0)
         {
            this.m_slotsListeners.shift().unregisterEventListener(MouseEvent.CLICK,onItemClick);
         }
         super.release();
      }
   }
}

