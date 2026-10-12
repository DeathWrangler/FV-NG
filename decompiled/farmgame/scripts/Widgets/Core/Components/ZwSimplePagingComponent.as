package Widgets.Core.Components
{
   import flash.events.Event;
   
   public class ZwSimplePagingComponent extends ZwComponent
   {
      
      protected var m_currentPageNumber:uint = 0;
      
      protected var m_maxPageNumber:uint = 0;
      
      protected var m_pageChangeCallback:Function = null;
      
      public function ZwSimplePagingComponent(maxPageNumber:uint, pageChangeCallback:Function)
      {
         super();
         this.m_maxPageNumber = maxPageNumber;
         this.m_pageChangeCallback = pageChangeCallback;
      }
      
      override public function release() : void
      {
         this.m_pageChangeCallback = null;
         super.release();
      }
      
      public function get currentPageNumber() : uint
      {
         return this.m_currentPageNumber;
      }
      
      public function set currentPageNumber(pageNumber:uint) : void
      {
         this.m_currentPageNumber = pageNumber;
         this.m_pageChangeCallback();
      }
      
      public function get maxPageNumber() : uint
      {
         return this.m_maxPageNumber;
      }
      
      public function set maxPageNumber(pageNumber:uint) : void
      {
         this.m_maxPageNumber = pageNumber;
         this.m_currentPageNumber = Math.min(this.m_currentPageNumber,this.m_maxPageNumber);
      }
      
      public function onPageBack(event:Event) : void
      {
         this.pageBack();
      }
      
      public function onPageForward(event:Event) : void
      {
         this.pageForward();
      }
      
      public function onPageFirst(event:Event) : void
      {
         this.pageFirst();
      }
      
      public function onPageLast(event:Event) : void
      {
         this.pageLast();
      }
      
      public function isOnFirstPage() : Boolean
      {
         return this.m_currentPageNumber == 0;
      }
      
      public function isOnLastPage() : Boolean
      {
         return this.m_currentPageNumber == this.m_maxPageNumber;
      }
      
      protected function pageForward() : void
      {
         if(this.m_currentPageNumber < this.m_maxPageNumber)
         {
            this.currentPageNumber += 1;
         }
      }
      
      protected function pageFirst() : void
      {
         this.currentPageNumber = 0;
      }
      
      protected function pageLast() : void
      {
         this.currentPageNumber = this.m_maxPageNumber;
      }
      
      protected function pageBack() : void
      {
         if(this.m_currentPageNumber > 0)
         {
            --this.currentPageNumber;
         }
      }
      
      public function reset() : void
      {
         this.m_currentPageNumber = 0;
      }
   }
}

