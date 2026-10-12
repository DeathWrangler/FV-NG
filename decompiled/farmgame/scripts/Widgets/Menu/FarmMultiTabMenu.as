package Widgets.Menu
{
   import Classes.util.FarmGameUtil;
   import Managers.MarketStatsManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Components.ZwSimplePagingComponent;
   import Widgets.Frames.Market.MarketSlotItemTimerFrame;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmMultiTabMenu extends FarmTabMenu
   {
      
      public static const NUM_ROWS:int = 6;
      
      protected var m_pageUpWidget:ZwWidget;
      
      protected var m_pageDownWidget:ZwWidget;
      
      protected var m_pagingComponent:ZwSimplePagingComponent;
      
      protected var m_selectedIndex:int = 0;
      
      public function FarmMultiTabMenu(element:MovieClip, itemSelectedCallback:Function, items:Array, autoSizeTabs:Boolean = false, autoSizePadding:Number = 10, textColor:String = null)
      {
         super(element,itemSelectedCallback,items,autoSizeTabs,autoSizePadding,textColor);
      }
      
      override protected function refresh() : void
      {
         var currentTab:FarmTabMenuButton = null;
         var previousTab:FarmTabMenuButton = null;
         var item:MenuItem = null;
         if(!this.m_pagingComponent)
         {
            this.m_pagingComponent = new ZwSimplePagingComponent(0,this.refresh);
         }
         if(Boolean(this.m_pagingComponent) && m_items != null)
         {
            this.m_pagingComponent.maxPageNumber = Math.ceil(m_items.length / NUM_ROWS) - 1;
         }
         if(!this.m_pageUpWidget)
         {
            this.m_pageUpWidget = addWidget(new ZwButton(m_element.topArrow_bt,this.m_pagingComponent.onPageBack)) as ZwWidget;
         }
         if(!this.m_pageDownWidget)
         {
            this.m_pageDownWidget = addWidget(new ZwButton(m_element.downArrow_bt,this.m_pagingComponent.onPageForward)) as ZwWidget;
         }
         var dataIndex:int = NUM_ROWS * this.m_pagingComponent.currentPageNumber;
         m_toggleManager.deselectAll();
         for(var i:int = 0; i < m_tabs.length; i++)
         {
            if(m_autoSizeTabs && Boolean(currentTab))
            {
               previousTab = currentTab;
            }
            currentTab = m_tabs[i] as FarmTabMenuButton;
            if(Boolean(m_items) && dataIndex < m_items.length)
            {
               item = m_items[dataIndex] as MenuItem;
               currentTab.text = item.text;
               currentTab.visible = true;
               if(m_newTabs[i] != null)
               {
                  if(item.newTab)
                  {
                     (m_newTabs[i] as DisplayObject).visible = true;
                  }
                  else
                  {
                     (m_newTabs[i] as DisplayObject).visible = false;
                  }
               }
               if(m_specialTabs[i] != null)
               {
                  if(item.specialTag != "")
                  {
                     (m_specialTabs[i] as MarketSlotItemTimerFrame).toggleTextVisibility(true);
                     (m_specialTabs[i] as MarketSlotItemTimerFrame).text = item.specialTag;
                     (m_specialTabs[i] as MarketSlotItemTimerFrame).loadIcon("assets/consumables/consume_expire_30.png");
                     (m_specialTabs[i] as MarketSlotItemTimerFrame).toggleIconVisibility(true);
                  }
                  else
                  {
                     (m_specialTabs[i] as MarketSlotItemTimerFrame).toggleTextVisibility(false);
                     (m_specialTabs[i] as MarketSlotItemTimerFrame).toggleIconVisibility(false);
                  }
               }
               if(item.isLocked)
               {
                  currentTab.lockIconVisible = true;
                  currentTab.enabled = false;
               }
               if(item.specialTag != "")
               {
               }
               if(m_autoSizeTabs)
               {
                  currentTab.autoSizeWidth(m_autoSizePadding);
                  if(previousTab)
                  {
                     currentTab.x = previousTab.x + previousTab.width;
                  }
                  else
                  {
                     currentTab.x = 0;
                  }
               }
               if(this.m_selectedIndex == dataIndex)
               {
                  this.selectTab(dataIndex % NUM_ROWS);
               }
               dataIndex++;
            }
            else
            {
               currentTab.visible = false;
            }
         }
         this.adjustPagingWidgetVisibility();
      }
      
      override protected function onItemClick(event:MouseEvent) : void
      {
         var i:int = 0;
         var tab:FarmTabMenuButton = null;
         var index:int = 0;
         var item:MenuItem = null;
         if(m_itemSelectedCallback != null)
         {
            for(i = 0; i < m_items.length; i++)
            {
               tab = m_tabs[i] as FarmTabMenuButton;
               if(FarmGameUtil.isDescendant(tab.element as DisplayObjectContainer,event.target as DisplayObject))
               {
                  index = NUM_ROWS * this.m_pagingComponent.currentPageNumber + i;
                  if(m_items[index])
                  {
                     MarketStatsManager.countTabIndexClick(index);
                     this.m_selectedIndex = index;
                     item = m_items[index] as MenuItem;
                     m_itemSelectedCallback(item);
                     break;
                  }
               }
            }
         }
      }
      
      protected function adjustPagingWidgetVisibility() : void
      {
         if(this.m_pageUpWidget)
         {
            this.m_pageUpWidget.visible = !this.m_pagingComponent.isOnFirstPage();
         }
         if(this.m_pageDownWidget)
         {
            this.m_pageDownWidget.visible = !this.m_pagingComponent.isOnLastPage();
         }
      }
   }
}

