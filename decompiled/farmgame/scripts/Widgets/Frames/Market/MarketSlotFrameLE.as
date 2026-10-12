package Widgets.Frames.Market
{
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.MovieClip;
   
   public class MarketSlotFrameLE extends MarketSlotFrame
   {
      
      public static const NUM_SLOT_LE_ROWS:int = 3;
      
      public static const NUM_MED_COLS:int = 3;
      
      private var m_LESlotColumns:int;
      
      public function MarketSlotFrameLE(element:MovieClip, callbacks:Object, numSlotCols:int = 3, container:FarmWindow = null)
      {
         this.m_LESlotColumns = numSlotCols;
         super(element,callbacks,numSlotCols,container);
      }
      
      override public function get slotCount() : int
      {
         return this.m_LESlotColumns * NUM_SLOT_LE_ROWS;
      }
      
      override public function adjustPagingComponent() : void
      {
         if(this.m_LESlotColumns == NUM_MED_COLS)
         {
            m_pageForwardWidget.x += MarketWindow.MARKETCARD_WIDTH;
            m_currentPageLabel.x += MarketWindow.MARKETCARD_WIDTH;
         }
      }
   }
}

