package Widgets.Frames
{
   import Classes.GypsyTrader;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GypsyTraderSlot;
   import Widgets.Windows.GypsyTraderWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GypsyTraderSlotFrame extends BringBackWinterFrame
   {
      
      public function GypsyTraderSlotFrame(element:DisplayObject, featureName:String, parentWindow:GypsyTraderWindow)
      {
         super(element,featureName,parentWindow);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GypsyTraderSlot(slotElement,m_featureName);
      }
      
      override protected function setupData() : void
      {
         var slotItem:Object = null;
         m_slotData = new Array();
         var rewardItems:Array = this.manager.getRewardPkgs();
         for(var i:int = 0; i < rewardItems.length; i++)
         {
            slotItem = rewardItems[i];
            slotItem["checkMarkVisible"] = this.manager.hasCollectedItem(slotItem.name);
            slotItem["toggleRedeemVisible"] = this.manager.areSnowFlakeReqsMetFor(slotItem);
            m_slotData.push(slotItem);
         }
      }
      
      override protected function onPageBack(event:Event) : void
      {
         super.onPageBack(event);
         this.refreshSlots();
      }
      
      override protected function onPageForward(event:Event) : void
      {
         super.onPageForward(event);
         this.refreshSlots();
      }
      
      override public function refreshSlots() : void
      {
         var slot:GypsyTraderSlot = null;
         for each(slot in m_slots)
         {
            slot.refreshSlot();
         }
      }
      
      private function get manager() : GypsyTrader
      {
         return GypsyTrader.getInstance();
      }
   }
}

