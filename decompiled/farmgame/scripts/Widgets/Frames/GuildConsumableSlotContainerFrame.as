package Widgets.Frames
{
   import Managers.GuildManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.GuildConsumableSlot;
   import flash.display.DisplayObject;
   
   public class GuildConsumableSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_featureName:String = null;
      
      public function GuildConsumableSlotContainerFrame(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         super(element);
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         m_slotData = GuildManager.getInstance().getGuildConsumableData();
      }
      
      public function setupSlotData(slotData:Array) : void
      {
         m_slotData = slotData;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GuildConsumableSlot(slotElement,this.m_featureName);
      }
      
      override protected function getSlotPrefix() : String
      {
         return "req";
      }
      
      override public function refresh() : void
      {
         this.setupData();
         super.refresh();
      }
   }
}

