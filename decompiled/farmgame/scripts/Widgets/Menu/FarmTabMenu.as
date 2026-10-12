package Widgets.Menu
{
   import Classes.util.FarmGameUtil;
   import Managers.SubscriptionsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwToggle;
   import Widgets.Frames.Market.MarketSlotItemTimerFrame;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FarmTabMenu extends ZwFrame
   {
      
      protected static const TAB_PREFIX:String = "tab_";
      
      protected static const TAB_SUFFIX:String = "_bt";
      
      protected var m_autoSizeTabs:Boolean = false;
      
      protected var m_autoSizePadding:Number = 10;
      
      protected var m_items:Array;
      
      protected var m_itemSelectedCallback:Function;
      
      protected var m_tabs:Array;
      
      protected var m_newTabs:Array;
      
      protected var m_specialTabs:Array;
      
      protected var m_toggleManager:ZwToggleManager;
      
      public function FarmTabMenu(element:MovieClip, itemSelectedCallback:Function, items:Array = null, autoSizeTabs:Boolean = false, autoSizePadding:Number = 10, textColor:String = null)
      {
         var elementName:String = null;
         var tab:FarmTabMenuButton = null;
         var item:MenuItem = null;
         var tabName:String = null;
         var visibility:Boolean = false;
         this.m_specialTabs = new Array();
         super(element);
         this.m_tabs = new Array();
         this.m_newTabs = new Array();
         this.m_toggleManager = new ZwToggleManager();
         for(var i:int = 0; i < 100; i++)
         {
            elementName = TAB_PREFIX + i + TAB_SUFFIX;
            if(!m_element[elementName])
            {
               break;
            }
            tab = addWidget(new FarmTabMenuButton(m_element[elementName]," ",this.onItemClick,textColor)) as FarmTabMenuButton;
            this.m_tabs[i] = tab;
            this.m_toggleManager.addToggle(new ZwToggle(tab));
            if(textColor != null && Boolean(m_element[elementName]))
            {
               if(Boolean(m_element[elementName]["question_mc"]) && Boolean(m_element[elementName]["question_mc"]["color_mc"]))
               {
                  TemplateUIUtility.applyBackgroundColor(m_element[elementName]["question_mc"]["color_mc"],TemplateUIUtility.VOTING,textColor);
                  m_element[elementName]["question_mc"].visible = i == 12;
               }
               if(Boolean(m_element[elementName]["back_mc"]) && Boolean(m_element[elementName]["back_mc"]["color_mc"]))
               {
                  TemplateUIUtility.applyBackgroundColor(m_element[elementName]["back_mc"]["color_mc"],TemplateUIUtility.VOTING,textColor);
               }
               if(Boolean(m_element[elementName]["stroke_mc"]) && Boolean(m_element[elementName]["stroke_mc"]["color_mc"]))
               {
                  TemplateUIUtility.applyBackgroundColor(m_element[elementName]["stroke_mc"]["color_mc"],TemplateUIUtility.VOTING,textColor);
               }
            }
            if(m_element[elementName].hasOwnProperty("new_mc"))
            {
               this.m_newTabs[i] = m_element[elementName].new_mc;
               (this.m_newTabs[i] as DisplayObject).visible = false;
               if(Boolean(items) && i < items.length)
               {
                  item = items[i] as MenuItem;
                  if(item)
                  {
                     tabName = item.data.toUpperCase();
                     visibility = Global.player.getActionCount(item.data + "_tab_new_sale_market") < Global.flashHotParams[tabName + "_TAB_NEW_SALE"];
                     (this.m_newTabs[i] as DisplayObject).visible = visibility;
                     if(visibility)
                     {
                        Global.player.setActionCount(item.data + "_tab_new_sale_market",Global.flashHotParams[tabName + "_TAB_NEW_SALE"],true);
                     }
                  }
               }
            }
            if(m_element[elementName].hasOwnProperty("expiration_mc"))
            {
               this.m_specialTabs[i] = new MarketSlotItemTimerFrame(m_element[elementName].expiration_mc,this.onMouseOver,this.onMouseOut);
            }
            if(m_element[elementName].hasOwnProperty("saleMainTabNav_mc"))
            {
               (m_element[elementName].saleMainTabNav_mc as DisplayObject).visible = false;
               if(Boolean(items) && i < items.length)
               {
                  item = items[i] as MenuItem;
                  if(item)
                  {
                     tabName = item.data.toString();
                     if(Global.categorySpecificSalesManager.isActive() && tabName == Global.categorySpecificSalesManager.category)
                     {
                        (m_element[elementName].saleMainTabNav_mc as DisplayObject).visible = true;
                     }
                  }
               }
            }
            if(m_element[elementName].hasOwnProperty("vipMainTabNav_mc"))
            {
               if(SubscriptionsManager.isEligibleForVIPBenifit())
               {
                  (m_element[elementName].vipMainTabNav_mc as DisplayObject).visible = true;
               }
               else
               {
                  (m_element[elementName].vipMainTabNav_mc as DisplayObject).visible = false;
               }
            }
            if(m_element[elementName].hasOwnProperty("saleTag_mc"))
            {
               (m_element[elementName].saleTag_mc as DisplayObject).visible = false;
            }
         }
         this.m_autoSizeTabs = autoSizeTabs;
         this.m_autoSizePadding = autoSizePadding;
         this.m_items = items;
         this.m_itemSelectedCallback = itemSelectedCallback;
         this.refresh();
      }
      
      public function get items() : Array
      {
         return this.m_items;
      }
      
      public function set items(items:Array) : void
      {
         this.m_items = items;
         this.refresh();
      }
      
      public function get numItems() : uint
      {
         return this.m_items.length;
      }
      
      public function get numTabs() : uint
      {
         return this.m_tabs.length;
      }
      
      public function getItem(index:uint) : MenuItem
      {
         var item:MenuItem = null;
         if(index < this.m_items.length)
         {
            item = this.m_items[index] as MenuItem;
         }
         return item;
      }
      
      public function getTab(index:uint) : FarmTabMenuButton
      {
         var tab:FarmTabMenuButton = null;
         if(index < this.m_tabs.length)
         {
            tab = this.m_tabs[index] as FarmTabMenuButton;
         }
         return tab;
      }
      
      public function get visibleWidth() : Number
      {
         var tab:FarmTabMenuButton = null;
         var visibleWidth:Number = 0;
         for each(tab in this.m_tabs)
         {
            if(!tab.visible)
            {
               break;
            }
            visibleWidth = tab.x + tab.width;
         }
         return visibleWidth;
      }
      
      public function selectTab(index:uint) : void
      {
         if(index < this.m_tabs.length)
         {
            this.m_toggleManager.setToggle(index);
         }
      }
      
      protected function refresh() : void
      {
         var currentTab:FarmTabMenuButton = null;
         var previousTab:FarmTabMenuButton = null;
         var item:MenuItem = null;
         for(var i:int = 0; i < this.m_tabs.length; i++)
         {
            if(this.m_autoSizeTabs && Boolean(currentTab))
            {
               previousTab = currentTab;
            }
            currentTab = this.m_tabs[i] as FarmTabMenuButton;
            if(Boolean(this.m_items) && i < this.m_items.length)
            {
               item = this.m_items[i] as MenuItem;
               if(currentTab.element.hasOwnProperty("saleTag_mc"))
               {
                  (currentTab.element.saleTag_mc as DisplayObject).visible = false;
                  if(Global.categorySpecificSalesManager.isActive())
                  {
                     if((m_parent as MarketWindow).type == Global.categorySpecificSalesManager.category && item.data == Global.categorySpecificSalesManager.subcategory)
                     {
                        (currentTab.element.saleTag_mc as DisplayObject).visible = true;
                     }
                  }
               }
               currentTab.text = item.text;
               currentTab.visible = true;
               if(item.newTab && this.m_newTabs[i] != null)
               {
                  (this.m_newTabs[i] as DisplayObject).visible = true;
               }
               if(item.isLocked)
               {
                  currentTab.lockIconVisible = true;
                  currentTab.enabled = false;
               }
               if(this.m_autoSizeTabs)
               {
                  currentTab.autoSizeWidth(this.m_autoSizePadding);
                  if(previousTab)
                  {
                     currentTab.x = previousTab.x + previousTab.width;
                  }
                  else
                  {
                     currentTab.x = 0;
                  }
               }
            }
            else
            {
               currentTab.visible = false;
            }
         }
      }
      
      protected function onItemClick(event:MouseEvent) : void
      {
         var i:int = 0;
         var tab:FarmTabMenuButton = null;
         var item:MenuItem = null;
         if(this.m_itemSelectedCallback != null)
         {
            for(i = 0; i < this.m_items.length; i++)
            {
               tab = this.m_tabs[i] as FarmTabMenuButton;
               if(FarmGameUtil.isDescendant(tab.element as DisplayObjectContainer,event.target as DisplayObject))
               {
                  item = this.m_items[i] as MenuItem;
                  this.m_itemSelectedCallback(item);
                  break;
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_items = null;
         this.m_itemSelectedCallback = null;
         this.m_tabs = null;
         this.m_toggleManager = null;
         super.release();
      }
      
      public function deselectAll() : void
      {
         this.m_toggleManager.deselectAll();
      }
      
      public function restoreAllDeselected() : void
      {
         this.m_toggleManager.restoreAllDeselected();
      }
      
      public function setTabVisibility(tabName:String, visibility:Boolean) : void
      {
         var item:MenuItem = null;
         for(var i:* = int(this.numTabs - 1); i >= 0; i--)
         {
            item = this.getItem(i);
            if(item)
            {
               if(item.data == tabName)
               {
                  this.getTab(i).visible = visibility;
                  return;
               }
            }
         }
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
      }
   }
}

