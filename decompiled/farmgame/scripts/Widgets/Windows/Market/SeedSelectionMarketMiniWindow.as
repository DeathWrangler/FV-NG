package Widgets.Windows.Market
{
   import Classes.TernaryTree;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Managers.FarmGameSettingsManager;
   
   public class SeedSelectionMarketMiniWindow extends MarketWindow
   {
      
      private var m_searchData:TernaryTree;
      
      public function SeedSelectionMarketMiniWindow(terrain:Array)
      {
         super("seed",null,null,null,null,-1,"unknown",false,terrain);
         var seedItems:Array = Global.farmGameSettingsManager.getFarmItemsArray("seed","seeds",FarmGameSettingsManager.ALL,FarmGameSettingsManager.NAME,FarmGameSettingsManager.ASCENDING,true,"",terrain,true);
         this.populateSearchData(seedItems);
      }
      
      override protected function refreshItems() : void
      {
         var itemsToShow:Array = null;
         var itemNames:Array = null;
         var currentItems:Array = null;
         var item:FarmItem = null;
         m_type = "seed";
         this.disableNormalView();
         var searchString:String = getSearchString();
         if(searchString != "")
         {
            this.m_searchData.buildPhraseMatchStrings(searchString);
            itemNames = this.m_searchData.getMatchedStrings();
            itemsToShow = Global.farmGameSettingsManager.getFarmItemsArrayByNames(itemNames);
         }
         else
         {
            itemsToShow = [];
            super.refreshItems();
            currentItems = m_marketSlotFrame.items;
            for each(item in currentItems)
            {
               if(item is SeedItem)
               {
                  itemsToShow.push(item);
               }
            }
         }
         m_marketSlotFrame.items = itemsToShow;
      }
      
      override protected function shouldInitializeHomepage() : Boolean
      {
         return false;
      }
      
      private function disableNormalView() : void
      {
         m_mainMenu.visible = false;
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
      }
      
      private function populateSearchData(seedItems:Array) : void
      {
         var item:FarmItem = null;
         this.m_searchData = new TernaryTree();
         for each(item in seedItems)
         {
            if(item is SeedItem)
            {
               this.m_searchData.addNewString(item.friendlyTitle,item.name);
            }
         }
      }
      
      override protected function getSubTypes(type:String) : Array
      {
         var index:int = 0;
         var subTypes:Array = super.getSubTypes(type);
         if(Boolean(subTypes) && subTypes.length > 0)
         {
            index = subTypes.indexOf("blooms");
            if(index != -1)
            {
               subTypes.splice(index,1);
            }
         }
         return subTypes;
      }
   }
}

