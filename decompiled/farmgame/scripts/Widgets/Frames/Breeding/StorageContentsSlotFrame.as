package Widgets.Frames.Breeding
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.SearchFrame;
   import Widgets.Slots.Breeding.AnimalBreedingContentsSlot;
   import Widgets.Windows.GiftBoxConfirmationDialog;
   import Widgets.Windows.StorageContentsWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.utils.getQualifiedClassName;
   
   public class StorageContentsSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      private static const SELECT_ALL_ON_PAGE_TEXT:String = ZLocUtils.t("Dialogs","SelectAllOnPage");
      
      private static const DESELECT_ALL_ON_PAGE_TEXT:String = ZLocUtils.t("Dialogs","DeselectAllOnPage");
      
      private static const SELL_SELECTED_TEXT:String = ZLocUtils.t("Dialogs","SellSelected");
      
      private static const CONFIRMATION_DIALOG_ASSET_MEDIUM:String = "assets/dialogs/FV_GiftBox_PopUpM.swf";
      
      private static const CONFIRMATION_DIALOG_ASSET_SMALL:String = "assets/dialogs/FV_GiftBox_PopUpS.swf";
      
      private static const DIALOG_WIDTH_SMALL_CONFIRMATION_DIALOG:int = 527;
      
      private static const DIALOG_WIDTH_MEDIUM_CONFIRMATION_DIALOG:int = 527;
      
      protected var m_mainWindow:StorageContentsWindow = null;
      
      protected var m_contents:Array = new Array();
      
      protected var m_slotClass:Class = null;
      
      protected var m_page:ZwTextField;
      
      private var m_searchFrame:SearchFrame;
      
      private var m_searchString:String = "";
      
      private var m_selectAllOrDeselectAllButton:FarmAnimatedTextButton;
      
      private var m_selectAllOrDeselectAll:Boolean;
      
      private var m_sellSelectedButton:FarmAnimatedTextButton;
      
      private var m_noOfSellBoxesChecked:int = 0;
      
      private var m_selectionToSlotsMapping:Object = {};
      
      private var m_giftBoxConfirmationDialog:GiftBoxConfirmationDialog;
      
      private var m_numberOfSellCompletes:int = 0;
      
      public function StorageContentsSlotFrame(element:DisplayObject, contents:Array, mainWindow:StorageContentsWindow, slotClass:Class)
      {
         this.m_mainWindow = mainWindow;
         this.m_contents = contents;
         this.m_slotClass = slotClass;
         super(element);
         if(m_element.hasOwnProperty("selectAllInPage_btn"))
         {
            this.m_selectAllOrDeselectAllButton = addWidget(new FarmAnimatedTextButton(m_element.selectAllInPage_btn,SELECT_ALL_ON_PAGE_TEXT,this.onSelectAllorDeselectAllClick),true) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("sellItemsPage_btn"))
         {
            this.m_sellSelectedButton = addWidget(new FarmAnimatedTextButton(m_element.sellItemsPage_btn,SELL_SELECTED_TEXT,this.onSellSelectedClick),true) as FarmAnimatedTextButton;
         }
         if(m_element.leftArrow_bt != null)
         {
            m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
            addWidget(m_pageBackWidget);
         }
         if(m_element.rightArrow_bt != null)
         {
            m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
            addWidget(m_pageForwardWidget);
         }
         if(m_element.page_tf != null)
         {
            this.m_page = addWidget(new ZwTextField(m_element.page_tf)) as ZwTextField;
         }
         if(m_element.hasOwnProperty("searchBar_mc"))
         {
            if(m_element.searchBar_mc)
            {
               this.m_searchFrame = new SearchFrame(m_element.searchBar_mc,this.onSearchUpdate);
               addWidget(this.m_searchFrame);
               this.m_searchFrame.alpha = 100;
            }
         }
         this.refresh();
      }
      
      private function onSearchUpdate(searchString:String = "") : void
      {
         if(searchString == "" || this.m_searchString != searchString)
         {
            this.m_searchString = searchString.toLowerCase();
         }
         m_slotData = this.getItemsToDisplay();
         this.refresh();
      }
      
      private function onConfirmationDialogCloseCallBack() : void
      {
         if(this.m_mainWindow != null)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
      }
      
      private function onSellSelectedClick(ev:MouseEvent) : void
      {
         var asset:String = null;
         var dialogWidth:int = 0;
         this.m_mainWindow.tintWindow();
         this.m_mainWindow.enableInput = false;
         var slots:Object = {};
         var numberOfItemsSelected:int = 0;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            if(Boolean(m_slots[i].isSlotEnabled()) && Boolean(m_slots[i].visible) && Boolean(m_slots[i].isSelected()))
            {
               this.m_selectionToSlotsMapping[numberOfItemsSelected] = i;
               slots[numberOfItemsSelected] = m_slots[i].m_slotData;
               numberOfItemsSelected++;
            }
         }
         if(numberOfItemsSelected > 3)
         {
            asset = CONFIRMATION_DIALOG_ASSET_MEDIUM;
         }
         else
         {
            asset = CONFIRMATION_DIALOG_ASSET_SMALL;
         }
         if(numberOfItemsSelected > 3)
         {
            dialogWidth = DIALOG_WIDTH_MEDIUM_CONFIRMATION_DIALOG;
         }
         else
         {
            dialogWidth = DIALOG_WIDTH_SMALL_CONFIRMATION_DIALOG;
         }
         this.m_giftBoxConfirmationDialog = new GiftBoxConfirmationDialog(slots,asset,dialogWidth,this.onSellCallBack,this.onConfirmationDialogCloseCallBack);
         UI.displayPopup(this.m_giftBoxConfirmationDialog,false,"GiftBoxConfirmationDialog",true);
      }
      
      private function onSellCallBack(data:Object) : void
      {
         var eachSlot:AnimalBreedingContentsSlot = null;
         var i:int = 0;
         this.m_numberOfSellCompletes = 0;
         var performTransactionImmediately:Boolean = false;
         var sellHandler:Function = this.onSellCompleteHandler(data.length);
         if(data.length > 0)
         {
            for(i = 0; i < data.length; i++)
            {
               eachSlot = m_slots[this.m_selectionToSlotsMapping[i]];
               if(i == data.length - 1)
               {
                  performTransactionImmediately = true;
               }
               else
               {
                  performTransactionImmediately = false;
               }
               eachSlot.sellMultipleGiftsHandler(data[i],sellHandler,performTransactionImmediately);
            }
         }
         else
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
      }
      
      private function onSellCompleteHandler(numberOfItems:int) : Function
      {
         var f:Function = function():void
         {
            if(++m_numberOfSellCompletes == numberOfItems)
            {
               m_numberOfSellCompletes = 0;
               m_mainWindow.untintWindow();
               m_mainWindow.enableInput = true;
               m_mainWindow.refreshWindow();
            }
         };
         return f;
      }
      
      private function onSellCheckBoxClick(isChecked:Boolean, hasChanged:Boolean = true) : void
      {
         if(hasChanged)
         {
            if(isChecked)
            {
               ++this.m_noOfSellBoxesChecked;
            }
            else
            {
               --this.m_noOfSellBoxesChecked;
            }
         }
         if(this.m_noOfSellBoxesChecked == 0)
         {
            this.selectAllOrDeselectAll = true;
            if(this.m_sellSelectedButton)
            {
               this.m_sellSelectedButton.enabled = false;
            }
         }
         else
         {
            if(this.m_sellSelectedButton)
            {
               this.m_sellSelectedButton.enabled = true;
            }
            this.selectAllOrDeselectAll = false;
         }
      }
      
      private function set selectAllOrDeselectAll(value:Boolean) : void
      {
         if(this.m_selectAllOrDeselectAllButton)
         {
            if(value)
            {
               this.m_selectAllOrDeselectAllButton.text = SELECT_ALL_ON_PAGE_TEXT;
            }
            else
            {
               this.m_selectAllOrDeselectAllButton.text = DESELECT_ALL_ON_PAGE_TEXT;
            }
         }
         this.m_selectAllOrDeselectAll = value;
      }
      
      private function get selectAllOrDeselectAll() : Boolean
      {
         return this.m_selectAllOrDeselectAll;
      }
      
      private function onSelectAllorDeselectAllClick(ev:MouseEvent) : void
      {
         var eachSlot:AnimalBreedingContentsSlot = null;
         var shouldDoSelectAll:Boolean = this.selectAllOrDeselectAll;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            eachSlot = m_slots[i];
            if(eachSlot.m_slotData.quantity > 0 && shouldDoSelectAll)
            {
               eachSlot.updateSellIcon(AnimalBreedingContentsSlot.CHECK_FRAME_SELL_BUTTON);
            }
            else
            {
               eachSlot.updateSellIcon(AnimalBreedingContentsSlot.UNCHECK_FRAME_SELL_BUTTON);
            }
         }
      }
      
      private function getItemsToDisplay() : Array
      {
         var item:Object = null;
         var friendlyName:String = null;
         var filteredItems:Array = new Array();
         if(this.m_searchString != "")
         {
            for each(item in this.m_contents)
            {
               friendlyName = item.name.toLowerCase();
               if(friendlyName.search(this.m_searchString) != -1)
               {
                  filteredItems.push(item);
               }
            }
         }
         else
         {
            filteredItems = this.m_contents;
         }
         return filteredItems;
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         this.setupData();
         adjustPagingWidgetVisibility();
         if(this.m_page != null)
         {
            this.m_page.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
               "current":m_pagingComponent.currentPageNumber + 1,
               "total":m_pagingComponent.maxPageNumber + 1
            });
            if(this.m_selectAllOrDeselectAllButton)
            {
               this.m_selectAllOrDeselectAllButton.visible = true;
               this.m_selectAllOrDeselectAllButton.text = SELECT_ALL_ON_PAGE_TEXT;
               this.m_selectAllOrDeselectAll = true;
            }
         }
      }
      
      override protected function getSlotPrefix() : String
      {
         return SLOT_PREFIX;
      }
      
      override protected function getSlotPostfix() : String
      {
         return SLOT_POSTFIX;
      }
      
      override protected function setupSlots() : void
      {
         var slot:ZwSlotFrame = null;
         var slotIndex:int = 0;
         while(m_element[this.getSlotPrefix() + slotIndex + this.getSlotPostfix()])
         {
            slot = this.createSlot(m_element[this.getSlotPrefix() + slotIndex + this.getSlotPostfix()]);
            addWidget(slot,false);
            m_slots.push(slot);
            slotIndex++;
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         var result:String = getQualifiedClassName(this.m_slotClass);
         if(result == "Widgets.Slots.Breeding::AnimalBreedingContentsSlot")
         {
            return new this.m_slotClass(slotElement,this.m_mainWindow,null,this.onSellCheckBoxClick,this);
         }
         return new this.m_slotClass(slotElement,this.m_mainWindow);
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_contents;
      }
   }
}

