package Widgets.Frames
{
   import Classes.util.FarmGameUtil;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Slots.ActionDrivenRewardsSlot;
   import flash.display.DisplayObject;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class ActionDrivenRewardsSlotContainerFrame extends FarmSlotContainerFrame
   {
      
      private var m_nextRevealindex:int;
      
      private var m_timer:Timer;
      
      private var m_randomRevealArray:Array;
      
      private var m_randomRevealArrayLength:int;
      
      private var m_slotDataLength:int;
      
      private var m_numSlots:int;
      
      public function ActionDrivenRewardsSlotContainerFrame(element:DisplayObject)
      {
         super(element);
         if(m_element.leftArrow_bt)
         {
            m_pageBackWidget = addWidget(new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack)) as ZwButton;
         }
         if(m_element.rightArrow_bt)
         {
            m_pageForwardWidget = addWidget(new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward)) as ZwButton;
         }
         this.m_randomRevealArray = [];
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new ActionDrivenRewardsSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      public function revealAll() : void
      {
         this.createRandomRevealArray();
         this.m_slotDataLength = m_slotData.length;
         this.m_numSlots = m_slots.length;
         this.m_timer = new Timer(0);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.revealNextSlot);
         this.m_timer.start();
      }
      
      private function createRandomRevealArray() : void
      {
         var numSlots:int = int(m_slots.length);
         for(var i:int = 0; i < numSlots; i++)
         {
            this.m_randomRevealArray.push(i);
         }
         this.m_randomRevealArray.sort(FarmGameUtil.randomizeArray);
         this.m_randomRevealArrayLength = this.m_randomRevealArray.length;
      }
      
      public function revealNextSlot(event:TimerEvent) : void
      {
         var i:int = 0;
         var datum:Object = null;
         if(this.m_nextRevealindex < this.m_randomRevealArrayLength && this.m_randomRevealArray[this.m_nextRevealindex] < this.m_slotDataLength && this.m_randomRevealArray[this.m_nextRevealindex] < this.m_numSlots)
         {
            if(m_slotData[this.m_randomRevealArray[this.m_nextRevealindex]].revealed)
            {
               ++this.m_nextRevealindex;
               return this.revealNextSlot(new TimerEvent(""));
            }
            (m_slots[this.m_randomRevealArray[this.m_nextRevealindex]] as ActionDrivenRewardsSlot).reveal();
            ++this.m_nextRevealindex;
         }
         else
         {
            for(i = 0; i < this.m_slotDataLength; i++)
            {
               datum = m_slotData[i];
               if(datum)
               {
                  datum.revealed = true;
               }
            }
         }
         this.m_timer.delay = FarmGameUtil.getRandomInt(500,0);
         this.m_timer.start();
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         m_pagingComponent.reset();
         refresh();
      }
   }
}

