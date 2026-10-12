package Widgets.Frames.SocialRaffle
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.SocialRaffle.RafflePrizePreviewSlot;
   import com.greensock.TweenLite;
   import com.greensock.easing.Elastic;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public final class RafflePrizePreviewSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_trackingArrow:ZwFrame = null;
      
      protected var m_items:Array = null;
      
      public function RafflePrizePreviewSlotFrame(element:DisplayObject, prizeData:Array)
      {
         this.m_items = prizeData;
         super(element);
         this.m_trackingArrow = addWidget(new ZwFrame(this.m_element.trackingarrow_mc),false) as ZwFrame;
         (this.element as MovieClip).setChildIndex(this.m_trackingArrow.element as MovieClip,0);
         (this.element as MovieClip).parent.setChildIndex(this.element as MovieClip,(this.element as MovieClip).parent.numChildren - 1);
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new RafflePrizePreviewSlot(slotElement);
      }
      
      public function getRafflePrizeFrame(raffleIndex:Number) : RafflePrizePreviewSlot
      {
         return m_slots[raffleIndex] as RafflePrizePreviewSlot;
      }
      
      public function setArrowPosition(xPos:Number, yPos:Number) : void
      {
         this.m_trackingArrow.visible = true;
         TweenLite.to(this.m_trackingArrow.element,2,{
            "x":xPos,
            "y":yPos,
            "ease":Elastic.easeOut
         });
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_trackingArrow = null;
         this.m_items = null;
      }
      
      override protected function getSlotPrefix() : String
      {
         return "prizeframe";
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

