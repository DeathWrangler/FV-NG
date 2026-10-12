package Widgets.Frames
{
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.WanderingPiratesCraftSlot;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class WanderingPirateCraftSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      protected var m_owner:DisplayObject;
      
      private var m_close_bt:FarmButton;
      
      public function WanderingPirateCraftSlotContainerFrame(element:DisplayObject, owner:DisplayObject)
      {
         this.m_owner = owner;
         super(element);
         if(m_element.hasOwnProperty("close_bt"))
         {
            this.m_close_bt = addWidget(new FarmButton(m_element.close_bt,this.onHide),true) as FarmButton;
         }
      }
      
      public function onHide(event:Event) : void
      {
         m_element.visible = false;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new WanderingPiratesCraftSlot(slotElement,this.m_owner);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         refresh();
      }
   }
}

