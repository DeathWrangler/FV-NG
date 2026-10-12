package Widgets.Windows
{
   import Classes.ItemFinderFoundItem;
   import Classes.ItemFinderItemDescriptor;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.ItemFinderManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ItemFinderSlotFrame;
   import flash.display.MovieClip;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class ItemFinderWindow extends FarmWindow
   {
      
      private static const ACTION_GIFT_PRIORITY:int = 0;
      
      private static const ACTION_WORLD_PRIORITY:int = 1;
      
      private static const ACTION_STORAGE_PRIORITY:int = 2;
      
      private static const ACTION_INVENTORY_PRIORITY:int = 3;
      
      private static const ACTION_TRAVEL_PRIORITY:int = 4;
      
      private static const SWF_FILE:String = "assets/dialogs/FV_SearchFarm.swf";
      
      private static const SWF_EXPORT_NAME_TITLE:String = "title_tf";
      
      private static const SWF_EXPORT_NAME_SLOTS:String = "slots_mc";
      
      private static const SWF_EXPORT_NAME_MORE_INFO:String = "moreInfo_bt";
      
      private static const SWF_EXPORT_TUTORIAL:String = "tutorial_mc";
      
      private static const SWF_EXPORT_NAME_PAGE_UP:String = "arrowLt_bt";
      
      private static const SWF_EXPORT_NAME_PAGE_DOWN:String = "arrowRt_bt";
      
      private static const LOC_PKG_DIALOG:String = "Dialogs";
      
      private static const LOC_KEY_TITLE:String = "ItemFinder_Title";
      
      private static const LOC_KEY_FOUND_WORLD_BODY:String = "ItemFinder_FoundWorld_Body";
      
      private static const LOC_KEY_FOUND_WORLD_BUTTON:String = "ItemFinder_FoundWorld_Button";
      
      private static const LOC_KEY_FOUND_STORAGE_BODY:String = "ItemFinder_FoundStorage_Body";
      
      private static const LOC_KEY_FOUND_STORAGE_BUTTON:String = "ItemFinder_FoundStorage_Button";
      
      private static const LOC_KEY_FOUND_GIFT_BODY:String = "ItemFinder_FoundGift_Body";
      
      private static const LOC_KEY_FOUND_GIFT_BUTTON:String = "ItemFinder_FoundGift_Button";
      
      private static const LOC_KEY_FOUND_INVENTORY_BODY:String = "ItemFinder_FoundInventory_Body";
      
      private static const LOC_KEY_FOUND_INVENTORY_BUTTON:String = "ItemFinder_FoundInventory_Button";
      
      private static const LOC_KEY_FOUND_NONE_TITLE:String = "ItemFinder_FoundNone_Title";
      
      private static const LOC_KEY_FOUND_NONE_BODY:String = "ItemFinder_FoundNone_Body";
      
      private static const LOC_KEY_FOUND_NONE_BUTTON:String = "ItemFinder_FoundNone_Button";
      
      private static const TUTORIAL_SEEN_FLAG:String = "item_finder_tutorial";
      
      private var m_itemDictionary:Dictionary = null;
      
      private var m_foundItemList:Array = new Array();
      
      private var m_searchBar_mc:ZwWidget = null;
      
      private var m_searchField_tf:ZwTextField = null;
      
      private var m_moreInfoButton:FarmAnimatedButton = null;
      
      private var m_tutorial:MovieClip = null;
      
      private var m_accept:FarmAnimatedButton = null;
      
      private var m_itemFinderSlotFrame:ItemFinderSlotFrame = null;
      
      private var m_pagingComponent:ZwSimplePagingComponent = null;
      
      private var m_pageBackWidget:ZwWidget = null;
      
      private var m_pageForwardWidget:ZwWidget = null;
      
      private var m_bPageUpdateEnabled:Boolean = true;
      
      public function ItemFinderWindow()
      {
         super(SWF_FILE);
         ItemFinderManager.getInstance().clearHighlightedItems();
         Global.farmGame.switchOutFullScreen();
         FarmStatsManager.count("item_finder","open");
      }
      
      public static function launchItemFinder() : void
      {
         UI.displayPopup(new ItemFinderWindow(),true,"ItemFinder",true);
      }
      
      override protected function postLoadComplete() : void
      {
         var titleTextField:ZwTextField = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty(SWF_EXPORT_NAME_TITLE) && m_window[SWF_EXPORT_NAME_TITLE] != null)
         {
            titleTextField = new ZwTextField(m_window[SWF_EXPORT_NAME_TITLE],ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_TITLE));
            addWidget(titleTextField);
         }
         if(m_window.hasOwnProperty(SWF_EXPORT_NAME_MORE_INFO) && m_window[SWF_EXPORT_NAME_MORE_INFO] != null)
         {
            this.m_moreInfoButton = new FarmAnimatedButton(m_window[SWF_EXPORT_NAME_MORE_INFO],this.onMoreInfoClick);
            addWidget(this.m_moreInfoButton);
         }
         if(m_window.hasOwnProperty(SWF_EXPORT_TUTORIAL) && m_window[SWF_EXPORT_TUTORIAL] != null)
         {
            this.m_tutorial = m_window[SWF_EXPORT_TUTORIAL] as MovieClip;
            this.m_tutorial.visible = false;
            if(!Global.player.getSeenFlag(TUTORIAL_SEEN_FLAG))
            {
               this.onMoreInfoClick(null);
            }
         }
         this.m_searchBar_mc = addWidget(new ZwWidget(m_window.searchBar_mc)) as ZwWidget;
         this.m_searchField_tf = addWidget(new ZwTextField(m_window.searchBar_mc.searchField_tf,"")) as ZwTextField;
         m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
         m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
         m_window.searchBar_mc.searchField_tf.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
         this.m_searchField_tf.restrict("0-9 a-zA-Z\\-\'");
         Global.stage.focus = m_window.searchBar_mc.searchField_tf;
         this.m_itemDictionary = ItemFinderManager.getInstance().getItemDictionary();
         this.updateVisibleItems("");
         if(m_window.hasOwnProperty(SWF_EXPORT_NAME_SLOTS) && m_window[SWF_EXPORT_NAME_SLOTS] != null)
         {
            this.m_itemFinderSlotFrame = new ItemFinderSlotFrame(m_window[SWF_EXPORT_NAME_SLOTS],this.m_foundItemList);
            addWidget(this.m_itemFinderSlotFrame);
            this.m_pagingComponent = new ZwSimplePagingComponent(0,this.updatePage);
            this.updateMaxPageNumber();
            this.updatePageWidgets();
         }
      }
      
      override public function close() : void
      {
         m_window.searchBar_mc.searchField_tf.removeEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
         m_window.searchBar_mc.searchField_tf.removeEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
         m_window.searchBar_mc.searchField_tf.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
         super.close();
      }
      
      private function updateVisibleItems(searchString:String) : void
      {
         var itemName:String = null;
         var farmItem:FarmItem = null;
         var friendlyName:String = null;
         var lowerFriendlyName:String = null;
         var bVisible:Boolean = false;
         var itemDescriptor:ItemFinderItemDescriptor = null;
         searchString = searchString.toLowerCase();
         this.m_foundItemList = new Array();
         for(itemName in this.m_itemDictionary)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(farmItem)
            {
               friendlyName = farmItem.friendlyTitle;
               if(friendlyName.length > 0)
               {
                  lowerFriendlyName = friendlyName.toLowerCase();
                  bVisible = lowerFriendlyName.indexOf(searchString) >= 0;
                  if(bVisible)
                  {
                     itemDescriptor = this.m_itemDictionary[itemName];
                     if(itemDescriptor.worldCount > 0)
                     {
                        this.m_foundItemList.push(new ItemFinderFoundItem(friendlyName,farmItem,farmItem.icon,ACTION_WORLD_PRIORITY,this.onWorldClick,ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_WORLD_BODY,{"quantity":itemDescriptor.worldCount}),ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_WORLD_BUTTON)));
                     }
                     if(itemDescriptor.storageCount > 0)
                     {
                        this.m_foundItemList.push(new ItemFinderFoundItem(friendlyName,farmItem,farmItem.icon,ACTION_STORAGE_PRIORITY,this.onStorageClick,ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_STORAGE_BODY,{"quantity":itemDescriptor.storageCount}),ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_STORAGE_BUTTON)));
                     }
                     if(itemDescriptor.giftCount > 0)
                     {
                        this.m_foundItemList.push(new ItemFinderFoundItem(friendlyName,farmItem,farmItem.icon,ACTION_GIFT_PRIORITY,this.onGiftClick,ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_GIFT_BODY,{"quantity":itemDescriptor.giftCount}),ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_GIFT_BUTTON)));
                     }
                     if(itemDescriptor.inventoryCount > 0)
                     {
                        this.m_foundItemList.push(new ItemFinderFoundItem(friendlyName,farmItem,farmItem.icon,ACTION_INVENTORY_PRIORITY,this.onInventoryClick,ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_INVENTORY_BODY,{"quantity":itemDescriptor.inventoryCount}),ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_INVENTORY_BUTTON)));
                     }
                  }
               }
            }
         }
         this.m_foundItemList.sort(ItemFinderFoundItem.compare);
         if(searchString != "" && this.m_foundItemList.length == 0)
         {
            this.m_foundItemList.push(new ItemFinderFoundItem(ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_NONE_TITLE),null,"",ACTION_TRAVEL_PRIORITY,this.onTravelClick,ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_NONE_BODY),ZLocUtils.t(LOC_PKG_DIALOG,LOC_KEY_FOUND_NONE_BUTTON)));
         }
         if(this.m_itemFinderSlotFrame != null)
         {
            if(this.m_pagingComponent != null)
            {
               this.m_bPageUpdateEnabled = false;
               this.updateMaxPageNumber();
               this.m_pagingComponent.currentPageNumber = 0;
               this.m_bPageUpdateEnabled = true;
               this.updatePageWidgets();
            }
            this.m_itemFinderSlotFrame.updateFoundItems(this.m_foundItemList,this.m_pagingComponent.currentPageNumber);
            this.m_itemFinderSlotFrame.refresh();
         }
      }
      
      private function updateMaxPageNumber() : void
      {
         var nPage:int = int(this.m_foundItemList.length);
         if(nPage > 0)
         {
            nPage = Math.floor((nPage - 1) / this.m_itemFinderSlotFrame.getSlotsPerPage());
         }
         this.m_pagingComponent.maxPageNumber = nPage;
      }
      
      private function onWorldClick(farmItem:FarmItem) : void
      {
         FarmStatsManager.count("item_finder","world_click",farmItem.name);
         this.close();
         ItemFinderManager.getInstance().highlightWorldItems(farmItem.name);
      }
      
      private function onStorageClick(farmItem:FarmItem) : void
      {
         FarmStatsManager.count("item_finder","storage_click",farmItem.name);
         this.close();
         ItemFinderManager.getInstance().highlightStorageItems(farmItem.name);
      }
      
      private function onGiftClick(farmItem:FarmItem) : void
      {
         FarmStatsManager.count("item_finder","gift_click",farmItem.name);
         var friendlyName:String = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
         this.close();
         UI.displayGiftBoxWindow(false,friendlyName,false);
      }
      
      private function onInventoryClick(farmItem:FarmItem) : void
      {
         FarmStatsManager.count("item_finder","inventory_click",farmItem.name);
         var friendlyName:String = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
         this.close();
         UI.displayInventoryDialogWithSearch(friendlyName);
      }
      
      private function onTravelClick(farmItem:FarmItem) : void
      {
         var searchString:String = "";
         if(this.m_searchField_tf != null && this.m_searchField_tf.text != null)
         {
            searchString = this.m_searchField_tf.text;
         }
         FarmStatsManager.count("item_finder","travel_click",searchString);
         this.close();
         Global.worldManager.showTravelConfirmation(Global.worldManager.currentWorldType);
      }
      
      private function onMoreInfoClick(event:MouseEvent) : void
      {
         if(this.m_tutorial)
         {
            this.m_tutorial.visible = true;
            this.m_tutorial.gotoAndPlay(2);
            this.m_accept = new FarmAnimatedButton(this.m_tutorial.accept_bt,this.onAcceptTutorial) as FarmAnimatedButton;
         }
         if(!Global.player.getSeenFlag(TUTORIAL_SEEN_FLAG))
         {
            Global.player.setSeenFlag(TUTORIAL_SEEN_FLAG);
         }
      }
      
      public function onAcceptTutorial(event:MouseEvent) : void
      {
         this.m_tutorial.visible = false;
      }
      
      private function updatePage() : void
      {
         var currentPage:int = int(this.m_pagingComponent.currentPageNumber);
         this.updatePageWidgets();
         this.m_itemFinderSlotFrame.updateFoundItems(this.m_foundItemList,currentPage);
         this.m_itemFinderSlotFrame.refresh();
      }
      
      private function updatePageWidgets() : void
      {
         if(this.m_bPageUpdateEnabled)
         {
            if(this.m_pageBackWidget)
            {
               removeWidget(this.m_pageBackWidget);
               this.m_pageBackWidget = null;
            }
            if(this.m_pageForwardWidget)
            {
               removeWidget(this.m_pageForwardWidget);
               this.m_pageForwardWidget = null;
            }
            if(!this.m_pagingComponent.isOnFirstPage() && !this.m_pageBackWidget && m_window.hasOwnProperty(SWF_EXPORT_NAME_PAGE_UP) && m_window[SWF_EXPORT_NAME_PAGE_UP] != null)
            {
               this.m_pageBackWidget = new ZwButton(m_window[SWF_EXPORT_NAME_PAGE_UP],this.m_pagingComponent.onPageBack);
               addWidget(this.m_pageBackWidget);
            }
            if(!this.m_pagingComponent.isOnLastPage() && !this.m_pageForwardWidget && m_window.hasOwnProperty(SWF_EXPORT_NAME_PAGE_DOWN) && m_window[SWF_EXPORT_NAME_PAGE_DOWN] != null)
            {
               this.m_pageForwardWidget = new ZwButton(m_window[SWF_EXPORT_NAME_PAGE_DOWN],this.m_pagingComponent.onPageForward);
               addWidget(this.m_pageForwardWidget);
            }
         }
      }
      
      private function onKeyUpHandler(event:KeyboardEvent) : void
      {
         if(this.m_searchField_tf != null && this.m_searchField_tf.text != null)
         {
            this.updateVisibleItems(this.m_searchField_tf.text);
         }
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = true;
      }
   }
}

