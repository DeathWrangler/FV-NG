package Widgets.Frames.GiftBox
{
   import Widgets.Core.Components.ZwSimplePagingComponent;
   
   public class GiftBoxPagingComponent extends ZwSimplePagingComponent
   {
      
      public function GiftBoxPagingComponent(maxPageNumber:uint, pageChangeCallback:Function)
      {
         super(maxPageNumber,pageChangeCallback);
      }
      
      override protected function pageBack() : void
      {
         if(m_currentPageNumber > 0)
         {
            currentPageNumber = currentPageNumber - 1;
         }
         else
         {
            currentPageNumber = m_maxPageNumber;
         }
      }
      
      override protected function pageForward() : void
      {
         if(m_currentPageNumber < m_maxPageNumber)
         {
            currentPageNumber += 1;
         }
         else
         {
            currentPageNumber = 0;
         }
      }
   }
}

