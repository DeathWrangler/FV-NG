package Widgets.Frames.Market
{
   import Classes.Constants.Experiments;
   import Classes.util.FarmGameUtil;
   import Engine.Managers.TransactionManager;
   import Transactions.TSavePromoReloadIndexes;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Market.MarketPromoSlot;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MarketPromoSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_slotItems:Array = null;
      
      protected var m_onPromoClickCallback:Function = null;
      
      private var m_marketPromoRotateTimer:Timer = null;
      
      public function MarketPromoSlotFrame(element:MovieClip, onPromoClickCallback:Function)
      {
         super(element);
         this.m_onPromoClickCallback = onPromoClickCallback;
         refresh();
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function get promoClickCallback() : Function
      {
         return this.m_onPromoClickCallback;
      }
      
      public function set items(items:Array) : void
      {
         var toDisplay:Array = null;
         var val1:int = 0;
         var val2:int = 0;
         m_slotData = items;
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKETPLACE_3_HOMEPAGE_ADS) == 3 && MarketWindow.isNewMarketplaceHomepageOn() && !(this.parent is CarnivalBoothWindow))
         {
            if(!Global.marketRecommendations.m_slot0MarketCards)
            {
               Global.marketRecommendations.m_slot0MarketCards = m_slotData[0];
            }
            toDisplay = new Array();
            val1 = Global.marketRecommendations.m_marketImpressions;
            val2 = int(Global.marketRecommendations.m_slot0MarketCards.length);
            toDisplay.push(Global.marketRecommendations.m_slot0MarketCards[Global.marketRecommendations.m_marketImpressions % Global.marketRecommendations.m_slot0MarketCards.length]);
            m_slotData[0] = toDisplay;
            ++Global.marketRecommendations.m_marketImpressions;
         }
         m_pagingComponent.currentPageNumber = 0;
         refresh();
         this.setupMarketPromoTimer();
         this.setItemsIndexes(Global.player.nextMarketPromos);
      }
      
      private function setItemsIndexes(promoIndexes:Array) : void
      {
         var slotIndex:uint = 0;
         var marketPromoSlot:MarketPromoSlot = null;
         if(promoIndexes)
         {
            slotIndex = 0;
            while(Boolean(slotIndex < m_slots.length) && Boolean(m_slots[slotIndex]) && slotIndex < promoIndexes.length)
            {
               marketPromoSlot = m_slots[slotIndex] as MarketPromoSlot;
               if(marketPromoSlot)
               {
                  marketPromoSlot.switchToPromoIndex(promoIndexes[slotIndex]);
               }
               slotIndex++;
            }
         }
      }
      
      private function getItemsIndexes() : Array
      {
         var marketPromoSlot:MarketPromoSlot = null;
         var returnIndexes:Array = new Array();
         var slotIndex:uint = 0;
         while(slotIndex < m_slots.length && Boolean(m_slots[slotIndex]))
         {
            marketPromoSlot = m_slots[slotIndex] as MarketPromoSlot;
            if(marketPromoSlot)
            {
               returnIndexes[slotIndex] = marketPromoSlot.data_index;
            }
            slotIndex++;
         }
         return returnIndexes;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new MarketPromoSlot(slotElement,this);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function release() : void
      {
         this.removeMarketPromoTimer();
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ROTATE_MARKET_PROMOS);
         if(variant == Experiments.VARIANT_ROTATE_MARKET_PROMO_ON_VIEW)
         {
            this.rotateAllPromos(false);
            Global.player.nextMarketPromos = this.getItemsIndexes();
         }
         else if(variant == Experiments.VARIANT_ROTATE_MARKET_PROMO_ON_LOAD)
         {
            if(!Global.player.getSeenSessionFlag("savedPromosIndexes"))
            {
               this.rotateAllPromos(false);
               TransactionManager.addTransaction(new TSavePromoReloadIndexes(this.getItemsIndexes()));
               Global.player.setSeenSessionFlag("savedPromosIndexes");
            }
         }
         super.release();
      }
      
      private function setupMarketPromoTimer() : void
      {
         var desiredTime:int = 0;
         this.removeMarketPromoTimer();
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_ROTATE_MARKET_PROMOS);
         if(variant >= Experiments.VARIANT_ROTATE_MARKET_PROMO_TIMER_START_INDEX)
         {
            desiredTime = (variant - 1) * FarmGameUtil.NUM_MSECS_IN_SECOND;
            this.m_marketPromoRotateTimer = new Timer(desiredTime);
            this.m_marketPromoRotateTimer.addEventListener(TimerEvent.TIMER,this.onMarketPromoTimerRepeat);
            this.m_marketPromoRotateTimer.start();
         }
      }
      
      private function removeMarketPromoTimer() : void
      {
         if(this.m_marketPromoRotateTimer)
         {
            this.m_marketPromoRotateTimer.stop();
            this.m_marketPromoRotateTimer.removeEventListener(TimerEvent.TIMER,this.onMarketPromoTimerRepeat);
            this.m_marketPromoRotateTimer = null;
         }
      }
      
      private function rotateAllPromos(updateView:Boolean = true) : void
      {
         var marketPromoSlot:MarketPromoSlot = null;
         var slotIndex:uint = 0;
         while(slotIndex < m_slots.length && Boolean(m_slots[slotIndex]))
         {
            marketPromoSlot = m_slots[slotIndex] as MarketPromoSlot;
            if(marketPromoSlot)
            {
               marketPromoSlot.rotatePromos(updateView);
            }
            slotIndex++;
         }
      }
      
      private function onMarketPromoTimerRepeat(event:TimerEvent) : void
      {
         this.rotateAllPromos();
      }
   }
}

