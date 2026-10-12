package Widgets.Frames.Crafting
{
   import Classes.FeatureBuilding;
   import Classes.crafting.MarketInventoryItem;
   import Managers.Crafting.CraftingManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.Crafting.CraftingSiloInventorySlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class CraftingSiloInventorySlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_building:FeatureBuilding = null;
      
      protected var m_subtype:String = null;
      
      protected var m_inventoryItems:Array = null;
      
      protected var m_elementMC:MovieClip = null;
      
      protected var m_onItemBuyCallback:Function = null;
      
      protected var m_onItemSharedCallback:Function = null;
      
      protected var m_onItemAskCallback:Function = null;
      
      private var m_locPrefix:String = "";
      
      public function CraftingSiloInventorySlotFrame(building:FeatureBuilding, element:MovieClip, locPrefix:String, items:Array, subType:String, buyCallback:Function = null, shareCallback:Function = null, askCallback:Function = null)
      {
         this.m_building = building;
         this.m_inventoryItems = items;
         this.m_onItemBuyCallback = buyCallback;
         this.m_onItemSharedCallback = shareCallback;
         this.m_onItemAskCallback = askCallback;
         this.m_locPrefix = locPrefix;
         super(element);
         this.m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         this.m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         this.m_subtype = subType;
         this.m_elementMC = element;
         m_pageBackWidget = addWidget(new ZwButton(this.m_elementMC.arrowUp_bt,m_pagingComponent.onPageBack)) as ZwWidget;
         m_pageForwardWidget = addWidget(new ZwButton(this.m_elementMC.arrowDown_bt,m_pagingComponent.onPageForward)) as ZwWidget;
         adjustPagingWidgetVisibility();
      }
      
      override protected function setupData() : void
      {
         this.m_slotData = this.m_inventoryItems;
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftingSiloInventorySlot(this.m_building,slotElement,this.m_locPrefix,this.m_onItemBuyCallback,this.m_onItemSharedCallback,this.m_onItemAskCallback);
      }
      
      public function refreshItemCount(itemCode:String) : void
      {
         var inventoryItem:MarketInventoryItem = null;
         for each(inventoryItem in this.m_inventoryItems)
         {
            if(inventoryItem.itemCode == itemCode)
            {
               inventoryItem.quantity = CraftingManager.getInstance().getBushelQuantityInInventory(itemCode);
               refresh();
               break;
            }
         }
      }
      
      public function updateItems(items:Array) : void
      {
         this.m_inventoryItems = items;
         this.m_slotData = this.m_inventoryItems;
         refresh();
      }
      
      public function refreshBuyButtons() : void
      {
         var slot:CraftingSiloInventorySlot = null;
         var slotIndex:uint = 0;
         while(slotIndex < m_slots.length && Boolean(m_slots[slotIndex]))
         {
            slot = m_slots[slotIndex];
            slot.refreshBuyButton();
            slotIndex++;
         }
      }
   }
}

