package Widgets.Frames.GiftBox
{
   import Widgets.Frames.FarmSlotContainerFrame;
   import flash.display.DisplayObject;
   
   public class GiftBoxPagableSlotFrameContainer extends FarmSlotContainerFrame
   {
      
      public function GiftBoxPagableSlotFrameContainer(element:DisplayObject)
      {
         super(element);
      }
      
      override protected function adjustPagingWidgetVisibility() : void
      {
         if(m_pageBackWidget)
         {
            m_pageBackWidget.visible = true;
         }
         if(m_pageBackLabel)
         {
            m_pageBackLabel.visible = true;
         }
         if(m_pageForwardWidget)
         {
            m_pageForwardWidget.visible = true;
         }
         if(m_pageForwardLabel)
         {
            m_pageForwardLabel.visible = true;
         }
      }
   }
}

