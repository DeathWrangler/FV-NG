package Widgets.Frames.Crafting
{
   import Managers.Crafting.MarketViewManager;
   import Managers.Crafting.SmartBushelHelper;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Crafting.CraftingMainRecipeSlot;
   import Widgets.Windows.Crafting.CraftingMainWindow;
   import flash.display.DisplayObject;
   
   public class CraftingMainRecipeSlotFrame extends FarmSlotContainerFrame
   {
      
      protected var m_items:Array = null;
      
      private var m_craftingMainWindow:CraftingMainWindow = null;
      
      public function CraftingMainRecipeSlotFrame(element:DisplayObject, items:Array, craftingMainWindow:CraftingMainWindow)
      {
         this.m_items = items;
         this.m_craftingMainWindow = craftingMainWindow;
         super(element);
         m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         m_pageBackWidget = new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack);
         m_pageForwardWidget = new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward);
         addWidget(m_pageBackWidget);
         addWidget(m_pageForwardWidget);
         refresh();
         var recipeBackgroundUrl:String = Global.craftConfigSettings.getCraftingBackgroundImage(this.m_craftingMainWindow.cottage.craftType);
         if(recipeBackgroundUrl)
         {
            addWidget(new FarmIcon(m_element.cottageScene_mc,recipeBackgroundUrl));
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new CraftingMainRecipeSlot(slotElement,this.m_craftingMainWindow);
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.m_items;
         if(SmartBushelHelper.inExperiment())
         {
            SmartBushelHelper.setupSmartBushels(this.m_items,m_slots.length);
         }
      }
      
      override public function release() : void
      {
         if(SmartBushelHelper.inExperiment())
         {
            MarketViewManager.getInstance().clearSmartBushelItems();
         }
         super.release();
         this.m_items = null;
         this.m_craftingMainWindow = null;
      }
      
      public function setEnabled(enable:Boolean, index:int = -1) : void
      {
         var recipeSlot:CraftingMainRecipeSlot = null;
         var i:int = 0;
         enabled = enable;
         if(index == -1)
         {
            for(i = 0; i < m_slots.length; i++)
            {
               recipeSlot = m_slots[i];
               recipeSlot.setEnabled(enable);
            }
            m_pageBackWidget.enabled = enable;
            m_pageForwardWidget.enabled = enable;
         }
         else
         {
            recipeSlot = m_slots[index];
            recipeSlot.setEnabled(enable);
            m_pageBackWidget.enabled = false;
            m_pageForwardWidget.enabled = false;
         }
      }
      
      public function enterFrame(deltaTime:Number) : void
      {
         var recipeSlot:CraftingMainRecipeSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            recipeSlot = m_slots[i];
            recipeSlot.enterFrame(deltaTime);
         }
      }
      
      public function updateSlots() : void
      {
         var recipeSlot:CraftingMainRecipeSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            recipeSlot = m_slots[i];
            recipeSlot.update();
         }
      }
      
      public function filterOptionsChanged() : void
      {
         var item:Object = null;
         m_slotData = new Array();
         for each(item in this.m_items)
         {
            if(item.friendlyTitle.toLowerCase().indexOf(this.m_craftingMainWindow.getSearchString()) != -1)
            {
               m_slotData.push(item);
            }
         }
         refresh();
      }
      
      public function filterByOptionsChanged() : void
      {
         var item:Object = null;
         m_slotData = new Array();
         for each(item in this.m_items)
         {
            if(Boolean(item.regionSufix) && item.regionSufix.indexOf(this.m_craftingMainWindow.getFilterByString()) != -1)
            {
               m_slotData.push(item);
            }
         }
         refresh();
      }
      
      public function isRegionSufixPresent() : Boolean
      {
         return Boolean(this.m_items) && Boolean(this.m_items[0].regionSufix) && this.m_items[0].regionSufix != "";
      }
      
      public function getRegionSufixArray() : Array
      {
         var item:Object = null;
         var regionSuffixString:String = "";
         var regionSuffixArray:Array = [];
         for each(item in this.m_items)
         {
            if(Boolean(item.regionSufix) && regionSuffixString.indexOf(item.regionSufix) == -1)
            {
               regionSuffixString += item.regionSufix + ",";
               regionSuffixArray.push(item.regionSufix);
            }
         }
         return regionSuffixArray;
      }
   }
}

