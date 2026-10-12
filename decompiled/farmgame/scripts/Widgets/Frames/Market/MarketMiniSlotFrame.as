package Widgets.Frames.Market
{
   import Classes.util.FarmGameUtil;
   import Managers.FarmStatsManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Market.Market3Slot;
   import Widgets.Slots.Market.MarketMiniSlot;
   import Widgets.Slots.Market.MarketSlot;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MarketMiniSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_callbacks:Object;
      
      private var m_details:MarketSlot;
      
      private var m_isOnloadMouseOver:Boolean = false;
      
      private var m_currentSlot:MarketMiniSlot;
      
      private var m_numSlots:int;
      
      private var m_tabType:String = MarketWindow.BESTSELLERS_MENU_ITEM;
      
      public function MarketMiniSlotFrame(element:MovieClip, callbacks:Object, numSlots:int)
      {
         this.m_callbacks = callbacks;
         this.m_numSlots = numSlots;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.leftSmallArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.rightSmallArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
         this.m_details = addWidget(new Market3Slot(m_element.fullCard_mc,null,callbacks),false) as Market3Slot;
         (this.m_details.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onDetailsMouseOut,false,0,true);
         this.adjustPagingComponent();
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
      
      public function set tabType(type:String) : void
      {
         this.m_tabType = type;
      }
      
      public function get tabType() : String
      {
         return this.m_tabType;
      }
      
      override public function refresh() : void
      {
         super.refresh();
         FarmStatsManager.count("marketplace",this.m_tabType,"view",m_pagingComponent.currentPageNumber.toString());
      }
      
      private function onDetailsMouseOut(event:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_details.element as DisplayObjectContainer,event.relatedObject as DisplayObject))
         {
            this.m_details.visible = false;
            this.m_currentSlot = null;
         }
      }
      
      private function onSlotMouseOver(event:MouseEvent) : void
      {
         var slot:MarketMiniSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            slot = m_slots[i] as MarketMiniSlot;
            if(Boolean(slot) && slot.element as MovieClip == event.currentTarget)
            {
               this.m_currentSlot = slot;
               break;
            }
         }
         if(!FarmGameUtil.isDescendant(m_element.parent.parent as DisplayObjectContainer,event.relatedObject as DisplayObject))
         {
            this.m_isOnloadMouseOver = true;
         }
         else if(!this.m_isOnloadMouseOver)
         {
            if(this.m_details.data != this.m_currentSlot.data)
            {
               this.m_details.populate(this.m_currentSlot.data);
            }
            if(i == 0)
            {
               this.m_details.x = Math.round(this.m_currentSlot.x - 6);
            }
            else if(i == m_slots.length - 1)
            {
               this.m_details.x = Math.round(this.m_currentSlot.x + this.m_currentSlot.width - this.m_details.width + 8);
            }
            else
            {
               this.m_details.x = Math.round(this.m_currentSlot.x + (this.m_currentSlot.width - this.m_details.width) / 2);
            }
            this.m_details.visible = true;
         }
      }
      
      private function onSlotMouseOut(event:MouseEvent) : void
      {
         if(Boolean(this.m_currentSlot) && Boolean(!FarmGameUtil.isDescendant(this.m_currentSlot.element as DisplayObjectContainer,event.relatedObject as DisplayObject)) && !FarmGameUtil.isDescendant(this.m_details.element as DisplayObjectContainer,event.relatedObject as DisplayObject))
         {
            this.m_isOnloadMouseOver = false;
            this.m_currentSlot = null;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slot:MarketMiniSlot = new MarketMiniSlot(slotElement,this,this.m_callbacks);
         (slot.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onSlotMouseOver,false,0,true);
         (slot.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSlotMouseOut,false,0,true);
         return slot;
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
         return this.m_numSlots;
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         var slot:MarketMiniSlot = null;
         (this.m_details.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onDetailsMouseOut);
         for each(slot in m_slots)
         {
            (slot.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onSlotMouseOver);
            (slot.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onSlotMouseOut);
         }
         this.m_callbacks = null;
         this.m_details = null;
         super.release();
      }
      
      public function adjustPagingComponent() : void
      {
         var pagingOffset:int = 0;
         if(this.m_numSlots == MarketWindow.NUM_SMALL_MARKET_MINI_SLOTS)
         {
            pagingOffset = (MarketWindow.NUM_MED_MARKET_MINI_SLOTS - MarketWindow.NUM_SMALL_MARKET_MINI_SLOTS) * MarketWindow.MINI_MARKETCARD_WIDTH;
            m_pageForwardWidget.x -= pagingOffset;
         }
      }
   }
}

