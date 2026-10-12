package Widgets.Frames.Crafting
{
   import Classes.ItemType;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.CraftingInventorySlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class CraftingInventorySlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_Subtype:String = null;
      
      protected var m_InventoryItems:Array = null;
      
      protected var m_Element:MovieClip;
      
      protected var m_OnItemUsedCallback:Function;
      
      protected var m_OnItemSharedCallback:Function;
      
      protected var m_OnItemMakeCallback:Function;
      
      private var m_searchString:String = "";
      
      public function CraftingInventorySlotFrame(element:MovieClip, items:Array, subType:String, onItemUsedCallback:Function, onSharedItemCallback:Function, onItemMakeCallback:Function)
      {
         this.m_InventoryItems = items;
         this.m_OnItemUsedCallback = onItemUsedCallback;
         this.m_OnItemSharedCallback = onSharedItemCallback;
         this.m_OnItemMakeCallback = onItemMakeCallback;
         super(element);
         this.m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         this.m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         this.m_Subtype = subType;
         this.m_Element = element;
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowButtonLeft_mc,m_pagingComponent.onPageBack)) as ZwWidget;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowButtonRight_mc,m_pagingComponent.onPageForward)) as ZwWidget;
         this.setupSubtitleText();
         this.refresh();
      }
      
      override protected function setupData() : void
      {
         var eachItem:MarketInventoryItem = null;
         var object:Object = null;
         this.m_slotData = new Array();
         for each(eachItem in this.m_InventoryItems)
         {
            if(this.m_searchString != "")
            {
               object = new Object();
               object.localizedName = eachItem.friendlyName;
               if(object.localizedName.search(this.m_searchString) != -1)
               {
                  this.m_slotData.push(eachItem);
               }
            }
            else
            {
               this.m_slotData.push(eachItem);
            }
         }
         this.m_InventoryItems = this.m_slotData;
      }
      
      public function updateItems(searchString:String) : void
      {
         this.m_searchString = searchString;
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftingInventorySlot(slotElement,this.m_OnItemUsedCallback,this.m_OnItemSharedCallback,this.m_OnItemMakeCallback);
      }
      
      private function setupSubtitleText() : void
      {
         var localeString:String = null;
         if(this.m_Subtype == null)
         {
            localeString = "SiloInventoryDialog_CategoryAll";
         }
         else
         {
            switch(this.m_Subtype)
            {
               case ItemType.SUBTYPE_CRAFTED:
                  localeString = "SiloInventoryDialog_CategoryCrafted";
                  break;
               case ItemType.SUBTYPE_FLOWERS:
                  localeString = "SiloInventoryDialog_CategoryFlowers";
                  break;
               case ItemType.SUBTYPE_FRUIT:
                  localeString = "SiloInventoryDialog_CategoryFruit";
                  break;
               case ItemType.SUBTYPE_GRAIN:
                  localeString = "SiloInventoryDialog_CategoryGrains";
                  break;
               case ItemType.SUBTYPE_MISC:
                  localeString = "SiloInventoryDialog_CategoryMisc";
                  break;
               case ItemType.SUBTYPE_VEGETABLE:
                  localeString = "SiloInventoryDialog_CategoryVegetables";
            }
         }
         if(this.m_Element.cropType_tf)
         {
            this.addWidget(new ZwTextField(this.m_Element.cropType_tf,ZLocUtils.t("Crafting",localeString)));
         }
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
      }
      
      public function reload(items:Array) : void
      {
         this.m_InventoryItems = items;
         this.setupData();
         this.refresh();
         if(m_pagingComponent.currentPageNumber > m_pagingComponent.maxPageNumber)
         {
            this.m_pagingComponent.currentPageNumber = m_pagingComponent.maxPageNumber;
         }
      }
      
      override protected function setupSlots() : void
      {
         super.setupSlots();
      }
      
      override public function release() : void
      {
         super.release();
      }
   }
}

