package Widgets.Frames
{
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SubscriberWalletRewardCollectionTabMenu
   {
      
      private static const MOUSE_OUT:int = 0;
      
      private static const MOUSE_OVER:int = 3;
      
      private static const MOUSE_CLICK:int = 2;
      
      private static const REWARDTYPES:Array = ["common","rare","superrare","ultrarare"];
      
      private var m_prefix:String;
      
      private var m_suffix:String;
      
      private var m_tabCount:int;
      
      private var m_selectedTab:int;
      
      private var m_tabs:Array;
      
      private var m_element:MovieClip;
      
      private var m_clickCallBack:Function;
      
      public function SubscriberWalletRewardCollectionTabMenu(element:DisplayObject, tabCount:int, clickCallBack:Function = null, prefix:String = "tab_", suffix:String = "_mc")
      {
         super();
         this.m_element = element as MovieClip;
         this.m_element.visible = true;
         this.m_prefix = prefix;
         this.m_suffix = suffix;
         this.m_tabCount = tabCount;
         this.m_tabs = new Array();
         this.m_clickCallBack = clickCallBack;
         this.populateTab();
         this.handleClickAction(0,true);
      }
      
      private function populateTab() : void
      {
         var currentTab:MovieClip = null;
         for(var i:int = 0; i < this.m_tabCount; i++)
         {
            currentTab = this.m_tabs[i] = this.m_element[this.m_prefix + i + this.m_suffix] as MovieClip;
            currentTab.gotoAndStop(MOUSE_OUT);
            currentTab.addEventListener(MouseEvent.CLICK,this.tabMouseClickCallBack(i));
            currentTab.addEventListener(MouseEvent.MOUSE_OUT,this.tabMouseOutCallBack(i));
            currentTab.addEventListener(MouseEvent.MOUSE_OVER,this.tabMouseOverCallBack(i));
            if(currentTab.hasOwnProperty("tabName_tf"))
            {
               new ZwTextField(currentTab["tabName_tf"],"tab " + i);
            }
            currentTab.gotoAndStop(1);
            if(currentTab.hasOwnProperty("tabName_down_tf"))
            {
               new ZwTextField(currentTab["tabName_down_tf"],"tab " + i);
            }
            currentTab.gotoAndStop(2);
            if(currentTab.hasOwnProperty("tabName_hover_tf"))
            {
               new ZwTextField(currentTab["tabName_hover_tf"],"tab " + i);
            }
            currentTab.gotoAndStop(3);
            if(currentTab.hasOwnProperty("tabName_disable_tf"))
            {
               new ZwTextField(currentTab["tabName_disable_tf"],"tab " + i);
            }
         }
      }
      
      private function setText(tab:MovieClip) : void
      {
      }
      
      private function tabMouseOverCallBack(tab:int) : Function
      {
         return function(event:Event):void
         {
            m_tabs[tab].gotoAndStop(MOUSE_OVER);
         };
      }
      
      private function resetTabSelection() : void
      {
         for(var i:int = 0; i < this.m_tabCount; i++)
         {
            if(this.m_selectedTab != i)
            {
               (this.m_tabs[i] as MovieClip).gotoAndStop(MOUSE_OUT);
            }
         }
      }
      
      private function tabMouseOutCallBack(tab:int) : Function
      {
         return function(event:Event):void
         {
            m_tabs[tab].gotoAndStop(MOUSE_OUT);
            m_tabs[m_selectedTab].gotoAndStop(MOUSE_CLICK);
         };
      }
      
      private function tabMouseClickCallBack(tab:int) : Function
      {
         return function(event:Event):void
         {
            handleClickAction(tab);
         };
      }
      
      private function handleClickAction(tabIndex:int, forceUpdate:Boolean = false) : void
      {
         if(this.m_selectedTab != tabIndex || forceUpdate)
         {
            this.m_selectedTab = tabIndex;
            this.resetTabSelection();
            this.m_tabs[tabIndex].gotoAndStop(MOUSE_CLICK);
            if(this.m_clickCallBack != null)
            {
               this.m_clickCallBack(REWARDTYPES[this.m_selectedTab]);
            }
         }
      }
   }
}

