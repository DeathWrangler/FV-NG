package Widgets.Frames.Storage
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Storage.StorageSlot;
   import Widgets.Windows.Storage.StorageWindow;
   import flash.display.DisplayObject;
   
   public class StorageSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_storageWindow:StorageWindow = null;
      
      private var m_items:Array;
      
      private var m_page:ZwTextField;
      
      private var m_noResultsText:ZwTextField = null;
      
      public function StorageSlotFrame(element:DisplayObject, items:Array, storageWindow:StorageWindow)
      {
         this.m_items = items;
         this.m_storageWindow = storageWindow;
         super(element);
         m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
         m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
         addWidget(m_pageBackWidget);
         addWidget(m_pageForwardWidget);
         this.m_page = addWidget(new ZwTextField(m_element.page_tf)) as ZwTextField;
         this.m_noResultsText = addWidget(new ZwTextField(m_element.noResults_tf,ZLocUtils.t("Dialogs","NoMatchingResults")),false) as ZwTextField;
         this.refresh();
      }
      
      override public function release() : void
      {
         super.release();
         this.m_storageWindow = null;
         this.m_items = null;
         this.m_page = null;
         this.m_noResultsText = null;
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
         this.m_page.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         });
      }
      
      override protected function setupData() : void
      {
         if(this.m_noResultsText)
         {
            if(this.m_items.length == 0)
            {
               this.m_noResultsText.text = ZLocUtils.t("Dialogs","NoMatchingResults");
               this.m_noResultsText.visible = true;
            }
            else
            {
               this.m_noResultsText.visible = false;
            }
         }
         m_slotData = this.m_items;
      }
      
      public function updateSlots(items:Array, page:int) : void
      {
         this.m_items = items;
         this.setupData();
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         m_pagingComponent.currentPageNumber = page;
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new StorageSlot(slotElement,this.m_storageWindow);
      }
      
      public function setButtonEnable(enable:Boolean) : void
      {
         var slot:StorageSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            slot = m_slots[i] as StorageSlot;
            slot.setButtonEnable(enable);
         }
      }
   }
}

