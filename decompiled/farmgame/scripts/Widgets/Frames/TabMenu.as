package Widgets.Frames
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class TabMenu
   {
      
      protected var MOUSE_OUT:int = 1;
      
      protected var MOUSE_OVER:int = 3;
      
      protected var MOUSE_CLICK:int = 2;
      
      protected var MOUSE_DISABLED:int = 4;
      
      protected var m_tabCount:int;
      
      protected var m_tabs:Array;
      
      protected var m_disabledTabs:Dictionary = new Dictionary();
      
      protected var m_element:MovieClip;
      
      protected var m_prefix:String;
      
      protected var m_suffix:String;
      
      protected var m_selectedTab:int;
      
      protected var m_runCallbackImmeidiately:Boolean;
      
      protected var m_clickCallBack:Function;
      
      public function TabMenu(element:DisplayObject, tabCount:int, initialClickIndex:int, callback:Function = null, prefix:String = "tab_", suffix:String = "_mc", disabledTabs:Dictionary = null, runCallbackImmeidiately:Boolean = true)
      {
         super();
         this.m_tabCount = tabCount;
         this.m_element = element as MovieClip;
         this.m_element.visible = true;
         this.m_prefix = prefix;
         this.m_suffix = suffix;
         this.m_tabs = new Array();
         this.m_clickCallBack = callback;
         this.m_runCallbackImmeidiately = runCallbackImmeidiately;
         this.populateTab();
         if(initialClickIndex <= tabCount && initialClickIndex >= 0)
         {
            this.handleClickAction(initialClickIndex,true);
         }
         this.m_disabledTabs = disabledTabs;
         if(this.m_disabledTabs)
         {
            this.updateDisabledStates(this.m_disabledTabs);
         }
      }
      
      protected function populateTab() : void
      {
         var currentTab:MovieClip = null;
         for(var i:int = 0; i < this.m_tabCount; i++)
         {
            currentTab = this.m_tabs[i] = this.m_element[this.m_prefix + i + this.m_suffix] as MovieClip;
            currentTab.visible = true;
            currentTab.gotoAndStop(this.MOUSE_OUT);
            currentTab.addEventListener(MouseEvent.CLICK,this.tabMouseClickCallBack(i));
            currentTab.addEventListener(MouseEvent.MOUSE_OUT,this.tabMouseOutCallBack(i));
            currentTab.addEventListener(MouseEvent.MOUSE_OVER,this.tabMouseOverCallBack(i));
         }
      }
      
      public function updateDisabledStates(disabledStates:Dictionary) : void
      {
         var currentTab:MovieClip = null;
         this.m_disabledTabs = disabledStates;
         for(var i:int = 0; i < this.m_tabCount; i++)
         {
            currentTab = this.m_tabs[i];
            if(disabledStates.hasOwnProperty(i.toString()))
            {
               currentTab.gotoAndStop(this.MOUSE_DISABLED);
            }
            else if(i == this.m_selectedTab)
            {
               currentTab.gotoAndStop(this.MOUSE_CLICK);
            }
            else
            {
               currentTab.gotoAndStop(this.MOUSE_OUT);
            }
         }
      }
      
      protected function tabMouseOverCallBack(tab:int) : Function
      {
         return function(event:Event):void
         {
            if(!m_disabledTabs || !m_disabledTabs.hasOwnProperty(tab.toString()))
            {
               m_tabs[tab].gotoAndStop(MOUSE_OVER);
            }
         };
      }
      
      protected function resetTabSelection() : void
      {
         for(var i:int = 0; i < this.m_tabCount; i++)
         {
            if(this.m_selectedTab != i && (!this.m_disabledTabs || !this.m_disabledTabs.hasOwnProperty(i.toString())))
            {
               (this.m_tabs[i] as MovieClip).gotoAndStop(this.MOUSE_OUT);
            }
         }
      }
      
      protected function tabMouseOutCallBack(tab:int) : Function
      {
         return function(event:Event):void
         {
            if(!m_disabledTabs || !m_disabledTabs.hasOwnProperty(tab.toString()))
            {
               m_tabs[tab].gotoAndStop(MOUSE_OUT);
               m_tabs[m_selectedTab].gotoAndStop(MOUSE_CLICK);
            }
         };
      }
      
      protected function tabMouseClickCallBack(tab:int) : Function
      {
         return function(event:Event):void
         {
            handleClickAction(tab);
         };
      }
      
      protected function handleClickAction(tabIndex:int, forceUpdate:Boolean = false) : void
      {
         if(Boolean(this.m_disabledTabs) && this.m_disabledTabs.hasOwnProperty(tabIndex.toString()))
         {
            return;
         }
         if(this.m_selectedTab != tabIndex || forceUpdate)
         {
            this.m_selectedTab = tabIndex;
            this.resetTabSelection();
            this.m_tabs[tabIndex].gotoAndStop(this.MOUSE_CLICK);
            if(this.m_runCallbackImmeidiately == false)
            {
               this.m_runCallbackImmeidiately = true;
            }
            else if(this.m_clickCallBack != null)
            {
               this.m_clickCallBack(this.m_selectedTab);
            }
         }
      }
      
      public function get selectedTab() : int
      {
         return this.m_selectedTab;
      }
      
      public function setTabName(index:int, name:String) : void
      {
         this.m_tabs[index]["generic_tf"]["text"] = name;
      }
   }
}

