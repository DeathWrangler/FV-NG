package Widgets.Frames.SocialRaffle
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.SocialRaffle.RaffleCrewSlot;
   import flash.display.DisplayObject;
   
   public final class RaffleCrewSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_slotPrefix:String = "friendticket";
      
      private var m_slotSuffix:String = "_mc";
      
      private var m_clickCallback:Function = null;
      
      protected var m_items:Array = null;
      
      public function RaffleCrewSlotFrame(element:DisplayObject, crewData:Array, slotPrefix:String = "friendticket", slotSuffix:String = "_mc", slotCallback:Function = null)
      {
         this.m_slotPrefix = slotPrefix;
         this.m_slotSuffix = slotSuffix;
         this.m_items = crewData;
         this.m_clickCallback = slotCallback;
         super(element);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RaffleCrewSlot(slotElement,this.m_clickCallback);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
      }
      
      public function setSlotPrefix(pre:String) : void
      {
         this.m_slotPrefix = pre;
      }
      
      public function setSlotSuffix(post:String) : void
      {
         this.m_slotSuffix = post;
      }
      
      override protected function getSlotPrefix() : String
      {
         return this.m_slotPrefix;
      }
      
      override protected function getSlotPostfix() : String
      {
         return this.m_slotSuffix;
      }
      
      public function setData(data:Array) : void
      {
         m_slotData = this.m_items = data;
         refresh();
      }
   }
}

