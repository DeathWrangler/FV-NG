package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Frames.SearchFrame;
   import Widgets.Slots.ItemSelectorSlot;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class ItemSelectorWindow extends FarmWindow
   {
      
      private var m_itemType:String = "";
      
      private var m_requiredCount:uint = 0;
      
      private var m_totalItemList:Array;
      
      private var m_searchedItemList:Array = null;
      
      private var m_onComplete:Function;
      
      private var m_selectedItems:Object = {};
      
      private var m_initialSelectedItems:Object = {};
      
      private var m_quantityList:Object = {};
      
      private var m_initialQuantityList:Object = {};
      
      private var m_omissionList:Object;
      
      public function ItemSelectorWindow(itemType:String, requiredCount:uint, onComplete:Function, selectedItems:Object = null, omissionList:Object = null)
      {
         this.m_itemType = itemType;
         this.m_requiredCount = requiredCount;
         this.m_onComplete = onComplete;
         this.m_selectedItems = selectedItems is Object ? ObjectUtil.uniClone(selectedItems) : {};
         this.m_initialSelectedItems = ObjectUtil.uniClone(this.m_selectedItems);
         this.m_omissionList = omissionList || {};
         super("assets/dialogs/Fv_bushelswap_addbushel.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         var itemCode:String = null;
         var emptyVis:Boolean = false;
         super.postLoadComplete();
         if(m_window.title_tf != null)
         {
            addWidget(new ZwTextField(m_window.title_tf,"Select Bushels"));
         }
         if(m_window.sub_tf != null)
         {
            addWidget(new ZwTextField(m_window.sub_tf,this.m_requiredCount + " Bushels"));
         }
         if(m_window.total_tf != null)
         {
            addWidget(new ZwTextField(m_window.total_tf,this.getNeededCount() + " more needed"));
         }
         if(m_window.searchBar_mc != null)
         {
            addWidget(new SearchFrame(m_window.searchBar_mc,this.onSearchUpdate));
         }
         if(m_window.save_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_window.save_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Done"),this.saveCallback));
         }
         if(m_window.cancel_bt != null)
         {
            addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Reset"),this.cancelCallback));
         }
         this.m_searchedItemList = this.getItems();
         for(itemCode in this.m_selectedItems)
         {
            this.m_quantityList[itemCode] -= this.m_selectedItems[itemCode];
         }
         this.m_initialQuantityList = ObjectUtil.uniClone(this.m_quantityList);
         emptyVis = false;
         if(this.m_searchedItemList == null || this.m_searchedItemList.length == 0)
         {
            emptyVis = true;
         }
         addWidget(new GenericSlotContainerFrame(m_window.bushelSlotFrame_mc,ItemSelectorSlot,this.m_searchedItemList,this));
         if(m_window.empty_tf != null)
         {
            addWidget(new ZwTextField(m_window.empty_tf,"Empty"),emptyVis);
         }
      }
      
      private function getItems() : Array
      {
         var eachItem:MarketInventoryItem = null;
         var underlyingItem:FarmItem = null;
         if(this.m_totalItemList)
         {
            return this.m_totalItemList;
         }
         this.m_totalItemList = [];
         Global.player.craftingState.inventoryState.marketStallItems = CraftingManager.getInstance().pruneCraftingInventory(Global.player.craftingState.inventoryState.marketStallItems);
         for each(eachItem in Global.player.craftingState.inventoryState.marketStallItems)
         {
            underlyingItem = eachItem.underlyingItem;
            if(Boolean(underlyingItem) && underlyingItem.type == this.m_itemType)
            {
               this.m_totalItemList.push(underlyingItem);
               this.m_quantityList[eachItem.itemCode] = eachItem.quantity;
               if(this.m_omissionList[eachItem.itemCode])
               {
                  this.m_quantityList[eachItem.itemCode] -= this.m_omissionList[eachItem.itemCode];
                  if(this.m_quantityList[eachItem.itemCode] <= 0)
                  {
                     delete this.m_quantityList[eachItem.itemCode];
                     this.m_totalItemList.pop();
                  }
               }
               this.m_totalItemList.sort(ZCacheUtil.applyPartial(this.quantitySorting,this));
            }
         }
         return this.m_totalItemList;
      }
      
      public function onSearchUpdate(searchString:String) : void
      {
         var eachItem:FarmItem = null;
         var itemName:String = null;
         var newItems:Array = new Array();
         var items:Array = this.getItems();
         if(searchString != "")
         {
            for each(eachItem in items)
            {
               itemName = eachItem.searchTitle;
               if(itemName.search(searchString) != -1)
               {
                  newItems.push(eachItem);
               }
            }
         }
         else
         {
            newItems = items;
         }
         this.m_searchedItemList = newItems;
         this.refreshWindow();
      }
      
      override public function refreshWindow() : void
      {
         var slotFrame:GenericSlotContainerFrame = getWidget(m_window.bushelSlotFrame_mc) as GenericSlotContainerFrame;
         if(slotFrame != null)
         {
            slotFrame.setData(this.m_searchedItemList);
         }
         this.updateTotalTally();
      }
      
      private function saveCallback(event:MouseEvent) : void
      {
         this.m_onComplete(this.m_selectedItems);
         this.destroyObj();
         close();
      }
      
      private function cancelCallback(event:MouseEvent) : void
      {
         this.resetInputItems();
      }
      
      public function resetInputItems() : void
      {
         this.m_quantityList = ObjectUtil.uniClone(this.m_initialQuantityList);
         this.m_selectedItems = ObjectUtil.uniClone(this.m_initialSelectedItems);
         this.refreshWindow();
      }
      
      override protected function onClose(event:Event) : void
      {
         this.destroyObj();
         close();
      }
      
      private function destroyObj() : void
      {
         this.m_quantityList = {};
         this.m_selectedItems = {};
      }
      
      public function updateTotalTally() : void
      {
         var totalTally:ZwTextField = null;
         var numNeeded:int = 0;
         if(m_window.total_tf != null)
         {
            totalTally = getWidget(m_window.total_tf) as ZwTextField;
            numNeeded = this.getNeededCount();
            if(numNeeded > 0)
            {
               totalTally.text = numNeeded + " more needed";
            }
            else
            {
               totalTally.text = "All required items are selected";
            }
         }
      }
      
      public function getNeededCount() : int
      {
         return Math.max(this.m_requiredCount - this.getSelectedCount(),0);
      }
      
      public function getSelectedCount() : int
      {
         var inputCode:String = null;
         var result:int = 0;
         for(inputCode in this.m_selectedItems)
         {
            result += this.m_selectedItems[inputCode];
         }
         return result;
      }
      
      public function selectItem(itemName:String, quantity:int) : void
      {
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         this.markSelected(itemCode,quantity);
         this.m_quantityList[itemCode] -= quantity;
      }
      
      private function markSelected(itemCode:String, quantity:int = 1) : void
      {
         if(this.m_selectedItems.hasOwnProperty(itemCode))
         {
            this.m_selectedItems[itemCode] += quantity;
         }
         else
         {
            this.m_selectedItems[itemCode] = quantity;
         }
      }
      
      private function quantitySorting(itemA:Object, itemB:Object) : int
      {
         var result:int = 0;
         var prevItem:FarmItem = itemA as FarmItem;
         var nextItem:FarmItem = itemB as FarmItem;
         var prevQuan:int = int(this.m_quantityList[prevItem.code]);
         var nextQuan:int = int(this.m_quantityList[nextItem.code]);
         if(prevQuan > nextQuan)
         {
            result = -1;
         }
         else if(prevQuan < nextQuan)
         {
            result = 1;
         }
         return result;
      }
      
      public function getQuantityOwned(itemCode:String) : int
      {
         var result:int = 0;
         if(this.m_quantityList.hasOwnProperty(itemCode))
         {
            result = int(this.m_quantityList[itemCode]);
         }
         return result;
      }
   }
}

