package Widgets.Frames.Market
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Market.Market3Slot;
   import Widgets.Slots.Market.MarketSlot;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class MarketSlotFrame extends FarmSlotContainerFrame
   {
      
      public static const LOWER_LEFT_SLOT_INDEX:int = 3;
      
      public static const MARKET_3_LOWER_LEFT_SLOT_INDEX:int = 1;
      
      public static const NUM_SLOT_ROWS:int = 2;
      
      private var m_callbacks:Object;
      
      private var m_numSlotColumns:int = 3;
      
      private var m_container:FarmWindow = null;
      
      public function MarketSlotFrame(element:MovieClip, callbacks:Object, numSlotCols:int = 3, container:FarmWindow = null)
      {
         this.m_callbacks = callbacks;
         this.m_numSlotColumns = numSlotCols;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
         this.adjustPagingComponent();
         this.m_container = container;
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.reset();
         this.refresh();
      }
      
      public function getSlotByItem(item:FarmItem) : MarketSlot
      {
         var slot:MarketSlot = null;
         var result:MarketSlot = null;
         for each(slot in m_slots)
         {
            if(slot.data == item)
            {
               result = slot;
               break;
            }
         }
         return result;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slot:MarketSlot = null;
         return new Market3Slot(slotElement,this,this.m_callbacks);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         this.m_callbacks = null;
         super.release();
      }
      
      override public function refresh() : void
      {
         var firstItem:FarmItem = null;
         var marketSize:String = null;
         super.refresh();
         if(Boolean(m_pagingComponent) && m_pagingComponent.currentPageNumber == 0)
         {
            if(m_slotData[0] is FarmItem)
            {
               firstItem = m_slotData[0] as FarmItem;
               if(Boolean(firstItem) && Boolean(firstItem.marketCardDescriptor) && firstItem.marketCardDescriptor.slotHeight > 1)
               {
                  this.toggleVisibilityForPromoCard(false);
               }
            }
         }
         var marketTypeTab:String = "";
         var marketSubtypeTab:String = "";
         if(this.m_container)
         {
            marketTypeTab = (this.m_container as MarketWindow).type;
            marketSubtypeTab = (this.m_container as MarketWindow).subtype;
            marketSize = this.m_numSlotColumns == MarketWindow.NUM_MED_MARKET_COLS ? "view_market_wide" : "view_market_regular";
            FarmStatsManager.count("marketplace",marketSize,marketTypeTab,marketSubtypeTab,m_pagingComponent.currentPageNumber.toString());
         }
      }
      
      private function toggleVisibilityForPromoCard(onOff:Boolean) : void
      {
         var lowerLeftSlot:ZwSlotFrame = m_slots[LOWER_LEFT_SLOT_INDEX] as ZwSlotFrame;
         if(Boolean(lowerLeftSlot) && lowerLeftSlot.visible != onOff)
         {
            lowerLeftSlot.visible = onOff;
         }
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var index:uint = 0;
         var maxSlot:int = this.slotCount;
         while(index < maxSlot)
         {
            if(m_element[getSlotPrefix() + index + getSlotPostfix()])
            {
               slot = this.createSlot(m_element[getSlotPrefix() + index + getSlotPostfix()]);
               addWidget(slot,false);
               m_slots.push(slot);
               index++;
            }
         }
      }
      
      public function get slotCount() : int
      {
         return this.m_numSlotColumns * NUM_SLOT_ROWS;
      }
      
      public function set numSlotColumns(numCols:int) : void
      {
         this.m_numSlotColumns = numCols;
      }
      
      public function adjustPagingComponent() : void
      {
         if(this.m_numSlotColumns == MarketWindow.NUM_MED_MARKET_COLS)
         {
            m_pageForwardWidget.x += MarketWindow.MARKETCARD_WIDTH;
            m_currentPageLabel.x += MarketWindow.MARKETCARD_WIDTH;
         }
      }
   }
}

