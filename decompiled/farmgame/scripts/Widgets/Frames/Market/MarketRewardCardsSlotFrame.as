package Widgets.Frames.Market
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.RewardCardsManager;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Market.MarketRewardCardsDetailSlot;
   import Widgets.Slots.Market.MarketRewardCardsSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MarketRewardCardsSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "loyaltyCard_";
      
      private var m_callbacks:Object;
      
      private var m_details:MarketRewardCardsDetailSlot;
      
      private var m_isOnloadMouseOver:Boolean = false;
      
      private var m_currentSlot:MarketRewardCardsSlot;
      
      private var m_detailCards:Vector.<MarketRewardCardsDetailSlot>;
      
      public function MarketRewardCardsSlotFrame(element:MovieClip, callbacks:Object)
      {
         var detailsSlot:MarketRewardCardsDetailSlot = null;
         super(element);
         addWidget(m_pageBackWidget = new ZwButton(m_element.leftSmallArrow_bt,m_pagingComponent.onPageBack));
         addWidget(m_pageForwardWidget = new ZwButton(m_element.rightSmallArrow_bt,m_pagingComponent.onPageForward));
         var tooltip:FarmTextTooltip = new FarmTextTooltip(ZLocUtils.t("Dialogs","RewardCardsInstructionsTooltip"));
         var instructionsWidget:ZwFrame = new ZwFrame(m_element.instructions_mc);
         addWidget(instructionsWidget);
         instructionsWidget.attachTooltip(tooltip);
         var rewardCardTypes:Array = RewardCardsManager.getInstance().getRewardTypes();
         this.m_detailCards = new Vector.<MarketRewardCardsDetailSlot>();
         var mouseEventListeners:Object = {};
         mouseEventListeners[MouseEvent.MOUSE_OUT] = this.onDetailsMouseOut;
         for(var i:int = 0; i < rewardCardTypes.length; i++)
         {
            if(m_element.hasOwnProperty(rewardCardTypes[i] + "Card_mc"))
            {
               detailsSlot = new MarketRewardCardsDetailSlot(m_element[rewardCardTypes[i] + "Card_mc"],null,callbacks,rewardCardTypes[i],mouseEventListeners);
               this.m_detailCards.push(detailsSlot);
               addWidget(detailsSlot,false);
            }
         }
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
      
      private function onSlotMouseOver(event:MouseEvent) : void
      {
         var slot:MarketRewardCardsSlot = null;
         var detailsCard:MarketRewardCardsDetailSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            slot = m_slots[i] as MarketRewardCardsSlot;
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
            for each(detailsCard in this.m_detailCards)
            {
               if(detailsCard.type == slot.data.name)
               {
                  detailsCard.visible = true;
                  this.m_details = detailsCard;
               }
               else
               {
                  detailsCard.visible = false;
               }
            }
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
         var detailsCard:MarketRewardCardsDetailSlot = null;
         if(Boolean(this.m_currentSlot) && Boolean(!FarmGameUtil.isDescendant(this.m_currentSlot.element as DisplayObjectContainer,event.relatedObject as DisplayObject)) && !FarmGameUtil.isDescendant(this.m_details.element as DisplayObjectContainer,event.relatedObject as DisplayObject))
         {
            this.m_isOnloadMouseOver = false;
            this.m_currentSlot = null;
            for each(detailsCard in this.m_detailCards)
            {
               detailsCard.visible = false;
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var slot:MarketRewardCardsSlot = new MarketRewardCardsSlot(slotElement,this,this.m_callbacks);
         (slot.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onSlotMouseOver,false,0,true);
         (slot.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSlotMouseOut,false,0,true);
         return slot;
      }
      
      override protected function setupData() : void
      {
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      private function onDetailsMouseOut(event:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_details.element as DisplayObjectContainer,event.relatedObject as DisplayObject))
         {
            this.m_details.visible = false;
            this.m_currentSlot = null;
         }
      }
   }
}

