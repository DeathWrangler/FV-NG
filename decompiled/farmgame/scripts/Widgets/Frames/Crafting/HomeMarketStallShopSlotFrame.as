package Widgets.Frames.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.SubscriptionsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Frames.SearchFrame;
   import Widgets.Slots.Crafting.HomeMarketStallShopSlot;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.MOTD.SubscriptionAllBenefitsMOTDWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class HomeMarketStallShopSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_capacityFrame:ZwFrame;
      
      private var m_currentCapacity:ZwTextField;
      
      private var m_emptyFrame:ZwFrame;
      
      private var m_items:Array;
      
      private var m_getItemCallback:Function;
      
      private var m_parentWindow:FarmWindow;
      
      private var m_searchFrame:SearchFrame;
      
      private var m_searchString:String = "";
      
      private var m_getMoreSpaceBt:FarmAnimatedButton;
      
      public function HomeMarketStallShopSlotFrame(element:MovieClip, items:Array, getItemCallback:Function, parentWindow:FarmWindow)
      {
         this.m_items = items;
         this.m_getItemCallback = getItemCallback;
         this.m_parentWindow = parentWindow;
         super(element);
         m_pageBackWidget = addWidget(new ZwButton(m_element.arrowUp_bt,m_pagingComponent.onPageBack)) as ZwButton;
         m_pageForwardWidget = addWidget(new ZwButton(m_element.arrowDown_bt,m_pagingComponent.onPageForward)) as ZwButton;
         if(SubscriptionsManager.isRetentionProgramActivated() && SubscriptionsManager.instance.isSubscriber())
         {
            this.m_capacityFrame = addWidget(new ZwFrame(m_element.capacityMeterVIP_mc),false) as ZwFrame;
            this.m_currentCapacity = this.m_capacityFrame.addWidget(new ZwTextField(m_element.capacityMeterVIP_mc.capacity_tf,"")) as ZwTextField;
            this.setupCapacityText();
         }
         else
         {
            this.m_capacityFrame = addWidget(new ZwFrame(m_element.capacityMeter_mc),false) as ZwFrame;
            this.m_currentCapacity = this.m_capacityFrame.addWidget(new ZwTextField(m_element.capacityMeter_mc.current_tf,ZLocUtils.t("Crafting","HomeMarketStallDialog_CurrentCapacity",{"quantity":Global.player.craftingState.inventoryState.currentCapacity}))) as ZwTextField;
            this.m_capacityFrame.addWidget(new ZwTextField(m_element.capacityMeter_mc.capacity_tf,ZLocUtils.t("Crafting","HomeMarketStallDialog_MaxCapacity",{"quantity":Global.player.craftingState.inventoryState.maxCapacity})));
            this.m_getMoreSpaceBt = this.m_capacityFrame.addWidget(new FarmAnimatedButton(m_element.getMore_bt,this.onGetMoreSpaceClicked),false) as FarmAnimatedButton;
         }
         if(m_element.searchBar_mc)
         {
            this.m_searchFrame = new SearchFrame(m_element.searchBar_mc,this.onSearchUpdate);
            addWidget(this.m_searchFrame);
         }
         this.m_emptyFrame = addWidget(new ZwFrame(m_element.emptyFrame_mc),false) as ZwFrame;
         this.m_emptyFrame.addWidget(new ZwTextField(m_element.emptyFrame_mc.generic_tf,ZLocUtils.t("Crafting","HomeMarketStallDialog_NoBushels")));
      }
      
      protected function onGetMoreSpaceClicked(event:MouseEvent) : void
      {
         this.closeParentWindow();
         FarmStatsManager.count("subs_ingame_marketing","marketstall","click");
         UI.displayPopup(new SubscriptionAllBenefitsMOTDWindow());
      }
      
      private function setupCapacityText() : void
      {
         if(SubscriptionsManager.isRetentionProgramActivated() && SubscriptionsManager.instance.isSubscriber())
         {
            if(this.m_capacityFrame)
            {
               this.m_currentCapacity.text = "Bushels : " + Global.player.craftingState.inventoryState.currentCapacity + "/" + Global.player.craftingState.inventoryState.maxCapacity + " ( Regular Capacity : " + (Global.player.craftingState.inventoryState.maxCapacity - SubscriptionsManager.instance.getMarketStallCapacityBenefit()) + " + VIP Capacity : " + SubscriptionsManager.instance.getMarketStallCapacityBenefit() + " )";
            }
         }
         else
         {
            this.m_currentCapacity.text = ZLocUtils.t("Crafting","HomeMarketStallDialog_CurrentCapacity",{"quantity":Global.player.craftingState.inventoryState.currentCapacity});
         }
      }
      
      override protected function setupData() : void
      {
         m_slotData = this.getItemsToDisplay();
      }
      
      public function updateItems(items:Array, resetPage:Boolean = false) : void
      {
         this.m_items = items;
         this.setupData();
         if(resetPage)
         {
            super.pageNumber = 0;
         }
         this.refresh();
      }
      
      private function getItemsToDisplay() : Array
      {
         var item:FarmItem = null;
         var friendlyName:String = null;
         var filteredItems:Array = new Array();
         if(this.m_searchString != "")
         {
            for each(item in this.m_items)
            {
               friendlyName = item.friendlyTitle.toLowerCase();
               if(friendlyName.search(this.m_searchString) != -1)
               {
                  filteredItems.push(item);
               }
            }
         }
         else
         {
            filteredItems = this.m_items;
         }
         return filteredItems;
      }
      
      private function onSearchUpdate(searchString:String = "") : void
      {
         var itemsToDisplay:Array = null;
         if(searchString == "" || this.m_searchString != searchString)
         {
            this.m_searchString = searchString.toLowerCase();
         }
         this.updateItems(this.m_items,true);
      }
      
      override public function refresh() : void
      {
         super.refresh();
         this.setupCapacityText();
         if(this.m_items.length > 0)
         {
            this.m_capacityFrame.visible = true;
            if(this.m_getMoreSpaceBt)
            {
               this.m_getMoreSpaceBt.visible = false;
            }
            this.m_emptyFrame.visible = false;
         }
         else
         {
            this.m_capacityFrame.visible = false;
            this.m_emptyFrame.visible = true;
            if(this.m_searchFrame)
            {
               this.m_searchFrame.visible = false;
            }
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new HomeMarketStallShopSlot(slotElement,this.m_getItemCallback,this.m_parentWindow);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_items = null;
         this.m_getItemCallback = null;
      }
   }
}

