package Widgets.Windows.Market
{
   import Classes.ZItem.FarmItem;
   import flash.events.Event;
   
   public class MarketMiniWindow extends MarketWindow
   {
      
      protected var m_displayItems:Array;
      
      protected var m_hideCloseButton:Boolean = false;
      
      public function MarketMiniWindow(itemNames:Array, hideCloseButton:Boolean = false, checkVisible:Boolean = false)
      {
         var item:FarmItem = null;
         this.m_displayItems = new Array();
         super();
         var potentialItems:Array = Global.farmGameSettingsManager.getFarmItemsArrayByNames(itemNames);
         for each(item in potentialItems)
         {
            if(item.isVisible || !checkVisible)
            {
               this.m_displayItems.push(item);
               m_items.push(item);
            }
         }
         this.m_hideCloseButton = hideCloseButton;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton != null && this.m_hideCloseButton == true)
         {
            m_closeButton.visible = false;
         }
      }
      
      override protected function refreshItems() : void
      {
         this.disableNormalView();
         m_marketSlotFrame.items = this.m_displayItems;
      }
      
      override protected function shouldInitializeHomepage() : Boolean
      {
         return false;
      }
      
      private function disableNormalView() : void
      {
         m_mainMenu.visible = false;
         m_subMenu.visible = false;
         m_subDropDownMenu.visible = false;
         m_sortByButton.visible = false;
         m_sortByMenu.visible = false;
         m_miniSlotFrame.visible = false;
         m_miniSlotMenu.visible = false;
         if(m_rewardCardsSlotFrame != null)
         {
            m_rewardCardsSlotFrame.visible = false;
         }
         if(m_flashSaleFrame != null)
         {
            m_flashSaleFrame.visible = false;
         }
         if(MarketWindow.isNewMarketplaceHomepageOn())
         {
            m_window.backHomeWide_mc.visible = false;
            m_window.backHomeSmall_mc.visible = false;
            if(m_bestSellersFrame)
            {
               m_bestSellersFrame.visible = false;
            }
            if(m_recommendedItemsFrame)
            {
               m_recommendedItemsFrame.visible = false;
            }
            if(m_turboSaleFrame)
            {
               m_turboSaleFrame.visible = false;
            }
            if(m_latestLEFrame)
            {
               m_latestLEFrame.visible = false;
            }
         }
         if(m_promoSlotFrame)
         {
            m_promoSlotFrame.visible = false;
         }
         m_searchBar_mc.visible = false;
      }
   }
}

