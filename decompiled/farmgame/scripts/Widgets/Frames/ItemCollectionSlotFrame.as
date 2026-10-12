package Widgets.Frames
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.ItemCollectionSlot;
   import flash.display.DisplayObject;
   
   public class ItemCollectionSlotFrame extends FarmSlotContainerFrame
   {
      
      protected static const SLOT_PREFIX:String = "slot_";
      
      protected static const SLOT_POSTFIX:String = "_mc";
      
      protected var m_contents:Array = new Array();
      
      protected var m_page:ZwTextField;
      
      private var m_searchFrame:SearchFrame;
      
      private var m_searchString:String = "";
      
      public function ItemCollectionSlotFrame(element:DisplayObject, contents:Array, buildingName:String)
      {
         this.m_contents = contents;
         super(element);
         m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
         addWidget(m_pageBackWidget);
         m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
         addWidget(m_pageForwardWidget);
         this.m_page = addWidget(new ZwTextField(m_element.page_tf)) as ZwTextField;
         if(m_element.surface_tf)
         {
            addWidget(new ZwTextField(m_element.surface_tf,ZLocUtils.t("Dialogs",buildingName + "_Subtitle")));
         }
         if(m_element.hasOwnProperty("searchBar_mc"))
         {
            this.m_searchFrame = new SearchFrame(m_element.searchBar_mc,this.onSearchUpdate);
            addWidget(this.m_searchFrame);
            this.m_searchFrame.alpha = 100;
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
         pageNumber = 0;
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
         adjustPagingWidgetVisibility();
         this.m_page.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         });
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
         return new ItemCollectionSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_contents;
      }
   }
}

