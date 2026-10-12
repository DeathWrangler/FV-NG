package Widgets.Frames.SocialRaffle
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.SocialRaffle.RaffleProgressSlot;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   
   public class RaffleProgressSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      public function RaffleProgressSlotFrame(element:DisplayObject, items:Array)
      {
         this.m_items = items;
         super(element);
         if(this.element.day_tf)
         {
            addWidget(new FarmTextField(this.element.day_tf,ZLocUtils.t("Dialogs","socialrafflebuilding_main_presenttext")));
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RaffleProgressSlot(slotElement);
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
      
      override protected function getSlotPrefix() : String
      {
         return "day";
      }
      
      override protected function getSlotPostfix() : String
      {
         return "_mc";
      }
      
      public function setData(data:Array) : void
      {
         m_slotData = this.m_items = data;
         refresh();
      }
   }
}

