package Widgets.Frames.GiftBox
{
   import Classes.MutableAnimalBaby;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Menu.FarmTabMenu;
   import Widgets.Menu.MenuItem;
   import Widgets.Slots.GiftBox.GiftBoxSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.GiftBox.GiftBoxWindow;
   import Widgets.Windows.GiftBoxConfirmationDialog;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class GiftBoxSlotFrame extends GiftBoxPagableSlotFrameContainer
   {
      
      protected static const MENU_PREFIX:String = "menu_";
      
      protected static const GIFTS_PREFIX:String = "gifts_";
      
      private static var m_giftItemsRecent:Dictionary = new Dictionary();
      
      private static const SELECT_ALL_ON_PAGE_TEXT:String = ZLocUtils.t("Dialogs","SelectAllOnPage");
      
      private static const DESELECT_ALL_ON_PAGE_TEXT:String = ZLocUtils.t("Dialogs","DeselectAllOnPage");
      
      private static const SELL_SELECTED_TEXT:String = ZLocUtils.t("Dialogs","SellSelected");
      
      private static const CONFIRMATION_DIALOG_ASSET_MEDIUM:String = "assets/dialogs/FV_GiftBox_PopUpM.swf";
      
      private static const CONFIRMATION_DIALOG_ASSET_SMALL:String = "assets/dialogs/FV_GiftBox_PopUpS.swf";
      
      private static const DIALOG_WIDTH_SMALL_CONFIRMATION_DIALOG:int = 527;
      
      private static const DIALOG_WIDTH_MEDIUM_CONFIRMATION_DIALOG:int = 527;
      
      private static var m_sortFunctionHash:Object = {
         "all":sortByAll,
         "animal":sortByDefault,
         "building":sortByDefault,
         "consumable":sortByClassName,
         "decoration":sortByName,
         "tree":sortByClassName,
         "other":sortByName,
         "recent":sortByGiftItemsRecentPriority
      };
      
      private static var m_sortPriorityHash:Object = {
         "animal":2,
         "building":5,
         "consumable":1,
         "decoration":4,
         "tree":3,
         "other":6,
         "recent":7
      };
      
      private static var m_classNameSortPriorityHash:Object = {
         "LootableDecoration":"5",
         "BuildingPart":"6",
         "WateringCan":"3",
         "SocialPlumbingMysteryGift":"2",
         "FeatureCreditItem":"1",
         "MysterySeedling":"4",
         "Collection":"0"
      };
      
      private var m_giftBoxWindow:GiftBoxWindow = null;
      
      private var m_numberOfSellCompletes:int = 0;
      
      protected var m_mainMenu:FarmTabMenu;
      
      private var m_items:Array;
      
      private var m_searchString:String = "";
      
      protected var m_type:String = "recent";
      
      private var m_page_tf:ZwTextField;
      
      private var m_page:int = 0;
      
      private var m_noResultsText:ZwTextField = null;
      
      private var m_pageHash:Object;
      
      private var m_selectAllOrDeselectAll:Boolean = true;
      
      private var m_selectionToSlotsMapping:Object;
      
      private var m_selectAllOrDeselectAllButton:FarmAnimatedTextButton;
      
      private var m_noOfSellBoxesChecked:int = 0;
      
      private var m_giftBoxConfirmationDialog:GiftBoxConfirmationDialog;
      
      private var m_sellSelectedButton:FarmAnimatedTextButton;
      
      public function GiftBoxSlotFrame(element:DisplayObject, items:Array, giftBoxWindow:GiftBoxWindow)
      {
         var mainItem:MenuItem = null;
         this.m_pageHash = {};
         this.m_selectionToSlotsMapping = {};
         this.m_items = items;
         this.m_giftBoxWindow = giftBoxWindow;
         super(element);
         m_pagingComponent = new GiftBoxPagingComponent(0,this.refresh);
         m_pagingComponent.maxPageNumber = Math.floor(m_slotData.length / m_slots.length);
         m_pageBackWidget = new ZwButton(m_element.leftArrow_bt,m_pagingComponent.onPageBack);
         m_pageForwardWidget = new ZwButton(m_element.rightArrow_bt,m_pagingComponent.onPageForward);
         addWidget(m_pageBackWidget);
         addWidget(m_pageForwardWidget);
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            this.m_selectAllOrDeselectAllButton = addWidget(new FarmAnimatedTextButton(m_element.selectAllInPage_btn,SELECT_ALL_ON_PAGE_TEXT,this.onSelectAllorDeselectAllClick)) as FarmAnimatedTextButton;
            this.m_sellSelectedButton = addWidget(new FarmAnimatedTextButton(m_element.sellItemsPage_btn,SELL_SELECTED_TEXT,this.onSellSelectedClick)) as FarmAnimatedTextButton;
         }
         var mainMenuItems:Array = [new MenuItem("recent",ZLocUtils.t("Dialogs",MENU_PREFIX + "recent")),new MenuItem("all",ZLocUtils.t("Dialogs",MENU_PREFIX + "all")),new MenuItem("consumable",ZLocUtils.t("Dialogs",GIFTS_PREFIX + "consumables")),new MenuItem("decoration",ZLocUtils.t("Dialogs",MENU_PREFIX + "decoration")),new MenuItem("animal",ZLocUtils.t("Dialogs",MENU_PREFIX + "animal")),new MenuItem("building",ZLocUtils.t("Dialogs",MENU_PREFIX + "building")),new MenuItem("tree",ZLocUtils.t("Dialogs",MENU_PREFIX + "tree")),new MenuItem("other",ZLocUtils.t("Dialogs",MENU_PREFIX + "other"))];
         this.m_mainMenu = addWidget(new FarmTabMenu(m_element.subNav_mc,this.onMainMenuItemSelected,mainMenuItems,true)) as FarmTabMenu;
         if(UI.windowState == null || UI.windowState.giftbox == null)
         {
            this.m_type = "recent";
         }
         else if(Boolean(UI.windowState.giftbox.hasOwnProperty("type")) && Boolean(UI.windowState.giftbox["type"]))
         {
            this.m_type = UI.windowState.giftbox["type"];
         }
         else
         {
            this.m_type = "recent";
         }
         for(var i:int = 0; i < mainMenuItems.length; i++)
         {
            if(mainMenuItems[i].data == this.m_type)
            {
               this.m_mainMenu.selectTab(i);
            }
         }
         this.m_mainMenu.getTab(0).attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","giftBoxRecentToolTip")));
         addWidget(new ZwTextField(m_element.sortby_tf,ZLocUtils.t("Dialogs","GiftBox_SortBy")));
         this.m_page_tf = addWidget(new ZwTextField(m_element.page_tf)) as ZwTextField;
         this.m_noResultsText = addWidget(new ZwTextField(m_element.noResults_tf,ZLocUtils.t("Dialogs","NoMatchingResults")),false) as ZwTextField;
         if(UI.windowState == null || UI.windowState.giftbox == null || UI.windowState.giftbox["pageHash"] == null)
         {
            for each(mainItem in mainMenuItems)
            {
               this.m_pageHash[mainItem.data] = 0;
            }
            this.m_page = 0;
         }
         if(UI.windowState != null && UI.windowState.giftbox != null)
         {
            if(UI.windowState.giftbox["pageHash"] != null)
            {
               this.m_pageHash = UI.windowState.giftbox["pageHash"];
            }
            this.m_page = UI.windowState.giftbox["page"];
            if(UI.windowState.giftbox["searchString"] != "")
            {
               this.deselectAll();
            }
         }
         this.refresh();
      }
      
      private static function sortByAll(obj1:Object, obj2:Object) : int
      {
         var sortFunction:Function = null;
         var result:int = 0;
         var score1:Number = m_sortPriorityHash[obj1.type] != null ? Number(m_sortPriorityHash[obj1.type]) : 6;
         var score2:Number = m_sortPriorityHash[obj2.type] != null ? Number(m_sortPriorityHash[obj2.type]) : 6;
         if(score1 < score2)
         {
            result = -1;
         }
         else if(score1 > score2)
         {
            result = 1;
         }
         else
         {
            sortFunction = m_sortFunctionHash[obj1.type];
            if(sortFunction == null)
            {
               sortFunction = sortByName;
            }
            result = sortFunction(obj1,obj2);
         }
         return result;
      }
      
      private static function sortByDefault(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:String = obj1.localizedName;
         var score2:String = obj2.localizedName;
         if(obj1.type == "consumable")
         {
            score1 = "!" + score1;
         }
         if(obj2.type == "consumable")
         {
            score2 = "!" + score2;
         }
         if(score1 < score2)
         {
            result = -1;
         }
         else if(score1 > score2)
         {
            result = 1;
         }
         else if(obj1.type == "consumable")
         {
            result = sortByClassName(obj1,obj2);
         }
         return result;
      }
      
      private static function sortByClassName(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:String = obj1.localizedName;
         var score2:String = obj2.localizedName;
         if(obj1.className != "")
         {
            score1 = m_classNameSortPriorityHash[obj1.className] + score1;
         }
         if(obj2.className != "")
         {
            score2 = m_classNameSortPriorityHash[obj2.className] + score2;
         }
         if(score1 < score2)
         {
            result = -1;
         }
         else if(score1 > score2)
         {
            result = 1;
         }
         return result;
      }
      
      private static function sortByGiftItemsRecentPriority(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         if(m_giftItemsRecent[obj1.itemKey] < m_giftItemsRecent[obj2.itemKey])
         {
            result = 1;
         }
         else
         {
            result = -1;
         }
         return result;
      }
      
      private static function sortByName(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:String = obj1.localizedName;
         var score2:String = obj2.localizedName;
         if(score1 < score2)
         {
            result = -1;
         }
         else if(score1 > score2)
         {
            result = 1;
         }
         return result;
      }
      
      private function onSelectAllorDeselectAllClick(ev:MouseEvent) : void
      {
         var farmItem:FarmItem = null;
         var shouldDoSelectAll:Boolean = this.selectAllOrDeselectAll;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            if(Boolean(m_slots[i].data) && Boolean(m_slots[i].data.farmItem))
            {
               farmItem = m_slots[i].data.farmItem;
               if(Boolean(farmItem) && farmItem.sellable)
               {
                  if(shouldDoSelectAll)
                  {
                     m_slots[i].updateSellIcon(GiftBoxSlot.CHECK_FRAME_SELL_BUTTON);
                  }
                  else
                  {
                     m_slots[i].updateSellIcon(GiftBoxSlot.UNCHECK_FRAME_SELL_BUTTON);
                  }
               }
            }
         }
      }
      
      private function onSellSelectedClick(ev:MouseEvent) : void
      {
         var farmItem:FarmItem = null;
         var asset:String = null;
         var dialogWidth:int = 0;
         this.m_giftBoxWindow.grayOutorUngrayOutBG(true);
         var slots:Object = {};
         var numberOfItemsSelected:int = 0;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            if(Boolean(m_slots[i].isSellChecked) && Boolean(m_slots[i].visible))
            {
               if(Boolean(m_slots[i].data) && Boolean(m_slots[i].data.farmItem))
               {
                  farmItem = m_slots[i].data.farmItem;
                  if(Boolean(farmItem) && farmItem.sellable)
                  {
                     this.m_selectionToSlotsMapping[numberOfItemsSelected] = i;
                     slots[numberOfItemsSelected] = m_slots[i].data;
                     numberOfItemsSelected++;
                  }
               }
            }
         }
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            if(numberOfItemsSelected > 3)
            {
               asset = CONFIRMATION_DIALOG_ASSET_MEDIUM;
            }
            else
            {
               asset = CONFIRMATION_DIALOG_ASSET_SMALL;
            }
            if(numberOfItemsSelected > 3)
            {
               dialogWidth = DIALOG_WIDTH_MEDIUM_CONFIRMATION_DIALOG;
            }
            else
            {
               dialogWidth = DIALOG_WIDTH_SMALL_CONFIRMATION_DIALOG;
            }
            this.m_giftBoxConfirmationDialog = new GiftBoxConfirmationDialog(slots,asset,dialogWidth,this.onSellCallBack,this.onConfirmationDialogCloseCallBack);
         }
         UI.displayPopup(this.m_giftBoxConfirmationDialog,false,"GiftBoxConfirmationDialog",true);
      }
      
      private function onSellCallBack(data:Object) : void
      {
         var i:int = 0;
         this.m_numberOfSellCompletes = 0;
         var performTransactionImmediately:Boolean = false;
         var sellHandler:Function = this.onSellCompleteHandler(data.length);
         if(data.length > 0)
         {
            for(i = 0; i < data.length; i++)
            {
               if(i == data.length - 1)
               {
                  performTransactionImmediately = true;
               }
               else
               {
                  performTransactionImmediately = false;
               }
               m_slots[this.m_selectionToSlotsMapping[i]].sellMultipleGiftsHandler(data[i],sellHandler,performTransactionImmediately);
            }
         }
         else
         {
            this.m_giftBoxWindow.grayOutorUngrayOutBG(false);
         }
      }
      
      private function onSellCompleteHandler(numberOfItems:int) : Function
      {
         var f:Function = function():void
         {
            if(++m_numberOfSellCompletes == numberOfItems)
            {
               m_numberOfSellCompletes = 0;
               m_giftBoxWindow.grayOutorUngrayOutBG(false);
               Global.hud.conditionallyRefreshHUD(true);
               m_giftBoxWindow.reload();
            }
         };
         return f;
      }
      
      private function onConfirmationDialogCloseCallBack() : void
      {
         if(this.m_giftBoxWindow != null)
         {
            this.m_giftBoxWindow.grayOutorUngrayOutBG(false);
         }
      }
      
      override protected function setupData() : void
      {
         var item:Object = null;
         var key:String = null;
         var filtered_items:Array = new Array();
         var giftboxSettings:Array = Global.farmGameSettingsManager.getGiftboxSettings();
         var groups:Dictionary = new Dictionary();
         for each(item in this.m_items)
         {
            if(this.m_searchString != "")
            {
               if(item.localizedName.search(this.m_searchString) != -1)
               {
                  this.addItemToGiftbox(groups,filtered_items,giftboxSettings,item);
               }
            }
            else if(this.isVisible(item))
            {
               this.addItemToGiftbox(groups,filtered_items,giftboxSettings,item);
            }
         }
         for(key in groups)
         {
            filtered_items.push({
               "name":key,
               "group":groups[key]
            });
         }
         if(this.m_noResultsText)
         {
            if(filtered_items.length == 0)
            {
               this.m_noResultsText.visible = true;
            }
            else
            {
               this.m_noResultsText.visible = false;
            }
         }
         var sortFunction:Function = m_sortFunctionHash[this.m_type];
         filtered_items.sort(sortFunction);
         m_slotData = filtered_items;
      }
      
      private function addItemToGiftbox(groups:Dictionary, filtered_items:Array, giftboxSettings:Array, item:Object) : void
      {
         var grouping:Object = null;
         var value:String = null;
         var inAGroup:Boolean = false;
         for each(grouping in giftboxSettings)
         {
            value = grouping["value"];
            if(item[grouping["groupBy"]] == value)
            {
               if(groups[value] is Array)
               {
                  (groups[value] as Array).push(item);
               }
               else
               {
                  groups[value] = new Array(item);
               }
               inAGroup = true;
            }
         }
         if(!inAGroup)
         {
            filtered_items.push(item);
         }
      }
      
      private function isVisible(item:Object) : Boolean
      {
         var returnVal:Boolean = false;
         var farmItem:FarmItem = FarmItem(item.farmItem);
         switch(this.m_type)
         {
            case "all":
               returnVal = true;
               break;
            case "animal":
               returnVal = item.type == this.m_type || item.name == "bottle" || item.name.search("xuk_animal_love_potion") != -1 || item.className == MutableAnimalBaby.CLASSNAME_STRING;
               break;
            case "building":
               returnVal = (farmItem.marketEntriesHash["building"] != null || item.className == "BuildingPart") && item.className != MutableAnimalBaby.CLASSNAME_STRING;
               break;
            case "consumable":
               returnVal = item.type == this.m_type;
               break;
            case "decoration":
               returnVal = farmItem.marketEntriesHash["decoration"] != null;
               break;
            case "tree":
               returnVal = item.type == this.m_type || item.className == "MysterySeedling" || item.className == "WateringCan";
               break;
            case "other":
               returnVal = item.type != "animal" && farmItem.marketEntriesHash["building"] == null && item.type != "consumable" && farmItem.marketEntriesHash["decoration"] == null && item.type != "tree";
               break;
            case "recent":
               returnVal = m_giftItemsRecent[item.itemKey] != null;
         }
         return returnVal;
      }
      
      private function onMainMenuItemSelected(item:MenuItem) : void
      {
         if(this.m_searchString == "")
         {
            this.m_pageHash[this.m_type] = pageNumber;
         }
         if(!this.m_giftBoxWindow.isDefaultSearchTextString())
         {
            this.m_giftBoxWindow.clearSearch();
         }
         this.m_type = item.data as String;
         this.setupData();
         this.m_page = this.m_pageHash[this.m_type];
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         m_pagingComponent.currentPageNumber = this.m_page;
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new GiftBoxSlot(slotElement,this.m_giftBoxWindow,this.onSellCheckBoxClick);
      }
      
      private function onSellCheckBoxClick(isChecked:Boolean, hasChanged:Boolean = true) : void
      {
         if(hasChanged)
         {
            if(isChecked)
            {
               ++this.m_noOfSellBoxesChecked;
            }
            else
            {
               --this.m_noOfSellBoxesChecked;
            }
         }
         if(this.m_noOfSellBoxesChecked == 0)
         {
            this.selectAllOrDeselectAll = true;
            this.m_sellSelectedButton.enabled = false;
         }
         else
         {
            this.m_sellSelectedButton.enabled = true;
            this.selectAllOrDeselectAll = false;
         }
      }
      
      private function set selectAllOrDeselectAll(value:Boolean) : void
      {
         if(value)
         {
            this.m_selectAllOrDeselectAllButton.text = SELECT_ALL_ON_PAGE_TEXT;
         }
         else
         {
            this.m_selectAllOrDeselectAllButton.text = DESELECT_ALL_ON_PAGE_TEXT;
         }
         this.m_selectAllOrDeselectAll = value;
      }
      
      private function get selectAllOrDeselectAll() : Boolean
      {
         return this.m_selectAllOrDeselectAll;
      }
      
      override public function refresh() : void
      {
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         populateSlots(m_slots.length * m_pagingComponent.currentPageNumber);
         adjustPagingWidgetVisibility();
         this.m_page_tf.text = ZLocUtils.t("Dialogs","GiftBox_Page",{
            "current":m_pagingComponent.currentPageNumber + 1,
            "total":m_pagingComponent.maxPageNumber + 1
         });
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            this.m_sellSelectedButton.visible = true;
            this.m_sellSelectedButton.enabled = false;
            this.m_selectAllOrDeselectAllButton.visible = true;
            this.m_selectAllOrDeselectAll = true;
            this.m_selectAllOrDeselectAllButton.text = SELECT_ALL_ON_PAGE_TEXT;
            this.m_selectionToSlotsMapping = {};
            this.m_noOfSellBoxesChecked = 0;
         }
      }
      
      public function reload(items:Array, searchString:String) : void
      {
         this.m_items = items;
         this.setm_giftItemsRecent();
         this.m_searchString = searchString.toLocaleLowerCase();
         this.setupData();
         m_pagingComponent.maxPageNumber = calcMaxPageNumber();
         m_pagingComponent.currentPageNumber = this.m_page;
         this.refresh();
      }
      
      private function setm_giftItemsRecent() : void
      {
         var currentItemIndex:int = 0;
         var itemCode:String = null;
         m_giftItemsRecent = new Dictionary();
         var giftItemsRecentObject:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.ITEMS_RECENT,FeatureOptionsManager.GIFT_ITEMS_RECENT);
         if(giftItemsRecentObject)
         {
            currentItemIndex = 0;
            for each(itemCode in giftItemsRecentObject)
            {
               m_giftItemsRecent[itemCode] = currentItemIndex;
               currentItemIndex++;
            }
         }
      }
      
      override public function release() : void
      {
         UI.windowState.giftbox["type"] = this.m_type;
         UI.windowState.giftbox["pageHash"] = this.m_pageHash;
         UI.windowState.giftbox["page"] = pageNumber;
         this.m_giftBoxWindow = null;
         this.m_mainMenu = null;
         this.m_items = null;
         this.m_page_tf = null;
         if(Global.experimentManager.getExperimentVariant(GiftBoxWindow.GIFT_BOX_DELETION_EXPT) == 2)
         {
            this.m_selectAllOrDeselectAllButton = null;
            this.m_giftBoxConfirmationDialog = null;
            this.m_sellSelectedButton = null;
         }
         super.release();
      }
      
      public function setButtonEnable(enable:Boolean) : void
      {
         var slot:GiftBoxSlot = null;
         for(var i:int = 0; i < m_slots.length; i++)
         {
            slot = m_slots[i] as GiftBoxSlot;
            slot.setButtonEnable(enable);
         }
      }
      
      public function deselectAll() : void
      {
         this.m_mainMenu.deselectAll();
         this.setupData();
         this.refresh();
      }
      
      public function restoreAllDeselected() : void
      {
         this.m_mainMenu.restoreAllDeselected();
         this.setupData();
         this.refresh();
      }
      
      public function setPage(pageIn:int, strlen:int, charCode:int) : void
      {
         if(strlen == 1 && charCode != 8)
         {
            this.m_pageHash[this.m_type] = pageNumber;
         }
         this.m_page = pageIn;
      }
      
      public function resetPage() : void
      {
         this.m_page = this.m_pageHash[this.m_type];
      }
   }
}

