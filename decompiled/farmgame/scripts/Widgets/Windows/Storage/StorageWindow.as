package Widgets.Windows.Storage
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.StorageBuilding;
   import Classes.WorldLicenseRequirement;
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Display.InventoryWithdrawal;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Storage.StorageSlotFrame;
   import Widgets.Menu.DropDownMenu;
   import Widgets.Menu.FarmTabMenu;
   import Widgets.Menu.MenuItem;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class StorageWindow extends FarmWindow
   {
      
      private static const STORAGE_PREFIX:String = "storage_";
      
      protected static const DIALOG_ASSET:String = "assets/dialogs/FV_Storage_transfer.swf";
      
      protected static const DIALOG_ASSET_V2:String = "assets/dialogs/FV_Storage_transfer_v2.swf";
      
      private var m_iconHome_mc:ZwWidget = null;
      
      private var m_iconUk_mc:ZwWidget = null;
      
      protected var m_capacity_tf:ZwTextField = null;
      
      protected var m_current_tf:ZwTextField = null;
      
      private var m_searchBar_mc:ZwWidget;
      
      private var m_clearSearchButton_mc:FarmAnimatedButton;
      
      private var m_search_mc:ZwWidget;
      
      private var m_searchField_tf:ZwTextField;
      
      protected var m_worldMenu:FarmTabMenu;
      
      protected var m_mainMenu:FarmTabMenu;
      
      protected var m_subMenu:FarmTabMenu;
      
      private var m_defaultString:String = ZLocUtils.t("Dialogs","Search");
      
      protected var m_world:String = Global.worldManager.currentWorldType;
      
      protected var m_type:String = "all";
      
      protected var m_subType:String = "all";
      
      protected var m_page:int = 0;
      
      protected var m_slotFrame:StorageSlotFrame = null;
      
      private var m_sortBy_tf:ZwTextField;
      
      protected var m_farmSelectBtn:FarmButton;
      
      private var m_farmDropDownMenu:DropDownMenu;
      
      private var m_defaultSubItems:Array = null;
      
      private var m_animalSubItems:Array = null;
      
      private var m_buildingSubItems:Array = null;
      
      private var m_decorationSubItems:Array = null;
      
      private var m_typeHash:Object = {};
      
      private var m_subTypeHash:Object = {};
      
      private var m_pageHash:Object = {};
      
      protected var m_expand_bt:FarmAnimatedTextButton;
      
      protected var m_shippingLicense_bt:FarmAnimatedButton;
      
      public var usedTypes:Object = null;
      
      private var m_items:Array = null;
      
      private var m_storage:StorageBuilding = null;
      
      protected var m_inventoryUsage:int;
      
      protected var m_inventoryCapacity:int;
      
      public function StorageWindow(storage:StorageBuilding = null, assetPath:String = "", modal:Boolean = true)
      {
         this.m_storage = storage;
         if(assetPath == "")
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_STORAGE_WINDOW_DROPDOWN_BUTTON) == 1)
            {
               assetPath = DIALOG_ASSET_V2;
            }
            else
            {
               assetPath = DIALOG_ASSET;
            }
         }
         super(assetPath,modal);
         this.m_inventoryUsage = Global.player.getInventoryUsage();
         this.m_inventoryCapacity = Global.player.getInventoryCapacity(false,Global.player.currentStorageWorldId);
         if(this.m_inventoryCapacity == 0)
         {
            this.m_inventoryCapacity = this.m_inventoryUsage;
         }
      }
      
      public static function hasUpgradableStorage() : Boolean
      {
         var worldObj:StorageBuilding = null;
         var building:FarmItem = null;
         var result:Boolean = false;
         var storageBuildings:Array = Global.world.getObjectsByClass(StorageBuilding);
         for(var idx:int = 0; idx < storageBuildings.length; idx++)
         {
            worldObj = storageBuildings[idx] as StorageBuilding;
            building = worldObj.getItem();
            if(building.getExpansion() != "")
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var worldId:String = null;
         var worldItem:MenuItem = null;
         var typeItem:MenuItem = null;
         var subTypeItem:MenuItem = null;
         var subMenuItems:Array = null;
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","InventoryTitle")));
         this.m_iconHome_mc = addWidget(new ZwWidget(m_window.iconHome_mc),Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME) as ZwWidget;
         this.m_iconUk_mc = addWidget(new ZwWidget(m_window.iconUk_mc),Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_ENGLAND) as ZwWidget;
         this.m_capacity_tf = addWidget(new ZwTextField(m_window.capacity_tf,ZLocUtils.t("Dialogs","Capacity",{"quantity":this.m_inventoryCapacity}))) as ZwTextField;
         this.m_current_tf = addWidget(new ZwTextField(m_window.current_tf,ZLocUtils.t("Dialogs","Current",{"quantity":this.m_inventoryUsage}))) as ZwTextField;
         this.m_searchBar_mc = addWidget(new ZwWidget(m_window.searchBar_mc)) as ZwWidget;
         var searchString:String = UI.storageWindowState != null && UI.storageWindowState["searchString"] != "" ? UI.storageWindowState["searchString"] : (UI.InventoryWindowState != null && UI.InventoryWindowState["searchString"] != "" ? UI.InventoryWindowState["searchString"] : this.m_defaultString);
         this.m_searchField_tf = addWidget(new ZwTextField(m_window.searchBar_mc.searchField_tf,searchString)) as ZwTextField;
         m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_IN,this.disableShortcut);
         m_window.searchBar_mc.searchField_tf.addEventListener(FocusEvent.FOCUS_OUT,this.enableShortcut);
         m_window.searchBar_mc.searchField_tf.addEventListener(MouseEvent.CLICK,this.onSearchTextButtonClick);
         m_window.searchBar_mc.searchField_tf.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUpHandler);
         this.m_searchField_tf.restrict("0-9 a-zA-Z\\-\'");
         this.m_clearSearchButton_mc = addWidget(new FarmAnimatedButton(m_window.searchBar_mc.clearsearch_bt,this.onClearSearchButtonClick)) as FarmAnimatedButton;
         this.m_search_mc = addWidget(new ZwWidget(m_window.searchBar_mc.search_mc)) as ZwWidget;
         this.m_expand_bt = addWidget(new FarmAnimatedTextButton(m_window.expand_bt,ZLocUtils.t("Dialogs",STORAGE_PREFIX + "expand"),this.onExpandButtonClick),hasUpgradableStorage()) as FarmAnimatedTextButton;
         var worldMenuItems:Array = [];
         for each(worldId in WorldsConstants.ALL_WORLDS)
         {
            worldMenuItems.push(new MenuItem(worldId,ZLocUtils.t("Dialogs",STORAGE_PREFIX + worldId)));
         }
         this.m_farmSelectBtn = addWidget(new FarmButton(m_window.farmSelect_bt,this.onFarmSelectButtonMouseOver)) as FarmButton;
         (this.m_farmSelectBtn.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onFarmSelectButtonMouseOver,false,0,true);
         (this.m_farmSelectBtn.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onFarmSelectButtonMouseOut,false,0,true);
         this.m_farmDropDownMenu = addWidget(new DropDownMenu(m_window.farmDropDown_mc,this.onFarmSelected),false) as DropDownMenu;
         (this.m_farmDropDownMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onFarmSelectButtonMouseOver,false,0,true);
         (this.m_farmDropDownMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onFarmSelectButtonMouseOut,false,0,true);
         if(m_window.farmDropDown_mc.baselist_mc)
         {
            this.m_farmDropDownMenu.addWidget(new ZwBaseWidget(m_window.farmDropDown_mc.baselist_mc));
         }
         this.m_shippingLicense_bt = addWidget(new FarmAnimatedTextButton(m_window.shippingLicenses_bt,ZLocUtils.t("Dialogs","InventoryShippingLicenses"),this.onShippingLicensesButtonClick),true) as FarmAnimatedTextButton;
         this.setUpFarmSelectionMenu();
         var mainMenuItems:Array = [new MenuItem("all",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "all"),true),new MenuItem("tree",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "tree")),new MenuItem("animal",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "animal")),new MenuItem("building",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "building")),new MenuItem("decoration",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "decoration"))];
         this.m_mainMenu = addWidget(new FarmTabMenu(m_window.mainNav_mc,this.onMainMenuItemSelected,mainMenuItems)) as FarmTabMenu;
         this.m_mainMenu.selectTab(0);
         this.addSlotFrame();
         this.m_sortBy_tf = addWidget(new ZwTextField(m_window.sortby_tf,ZLocUtils.t("Dialogs","storage_sort_by")),false) as ZwTextField;
         this.m_subMenu = addWidget(new FarmTabMenu(m_window.subNav_mc,this.onSubMenuItemSelected,[],true)) as FarmTabMenu;
         this.m_defaultSubItems = [new MenuItem("all",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "all"),true)];
         this.m_animalSubItems = [new MenuItem("all",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "all"),true),new MenuItem("farming",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "farming"),true),new MenuItem("exotic",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "exotic"),true),new MenuItem("pets",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "pets"),true)];
         this.m_buildingSubItems = [new MenuItem("all",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "all"),true),new MenuItem("decorative",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "decorative")),new MenuItem("home",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "home"))];
         this.m_decorationSubItems = [new MenuItem("all",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "all"),true),new MenuItem("nature",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "nature")),new MenuItem("building",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "building")),new MenuItem("landscaping",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "landscaping")),new MenuItem("ornament",ZLocUtils.t("Dialogs",STORAGE_PREFIX + "ornament"))];
         if(UI.storageWindowState == null)
         {
            UI.storageWindowState = {};
            UI.storageWindowState["lastWorld"] = null;
            for each(worldItem in worldMenuItems)
            {
               this.m_typeHash[worldItem.data] = "all";
               for each(typeItem in mainMenuItems)
               {
                  this.m_subTypeHash[worldItem.data + typeItem.data] = "all";
                  switch(typeItem.data)
                  {
                     case "animal":
                        subMenuItems = this.m_animalSubItems;
                        break;
                     case "building":
                        subMenuItems = this.m_buildingSubItems;
                        break;
                     case "decoration":
                        subMenuItems = this.m_decorationSubItems;
                        break;
                     default:
                        subMenuItems = this.m_defaultSubItems;
                  }
                  for each(subTypeItem in subMenuItems)
                  {
                     this.m_pageHash[worldItem.data + typeItem.data + subTypeItem.data] = 0;
                  }
               }
            }
         }
         else
         {
            this.m_typeHash = UI.storageWindowState["typeHash"];
            this.m_subTypeHash = UI.storageWindowState["subTypeHash"];
            this.m_pageHash = UI.storageWindowState["pageHash"];
            this.m_world = UI.storageWindowState["world"];
            this.m_type = UI.storageWindowState["type"];
            this.m_subType = UI.storageWindowState["subType"];
            this.m_page = UI.storageWindowState["page"];
         }
         if(UI.storageWindowState["lastWorld"] != Global.worldManager.currentWorldType)
         {
            UI.storageWindowState["lastWorld"] = Global.worldManager.currentWorldType;
            this.m_world = UI.storageWindowState["lastWorld"];
            this.m_type = "all";
            this.m_subType = "all";
            this.m_page = 0;
         }
         this.setUpTypeMenu();
         this.setUpSubMenu();
         this.reload();
      }
      
      override protected function release() : void
      {
         var buttonElement:MovieClip = null;
         var dropDownMenuElement:MovieClip = null;
         super.release();
         if(this.m_farmSelectBtn)
         {
            buttonElement = this.m_farmSelectBtn.element as MovieClip;
            if(null != buttonElement)
            {
               buttonElement.removeEventListener(MouseEvent.MOUSE_OVER,this.onFarmSelectButtonMouseOver);
               buttonElement.removeEventListener(MouseEvent.MOUSE_OUT,this.onFarmSelectButtonMouseOut);
            }
            dropDownMenuElement = this.m_farmDropDownMenu.element as MovieClip;
            if(dropDownMenuElement)
            {
               dropDownMenuElement.removeEventListener(MouseEvent.MOUSE_OVER,this.onFarmSelectButtonMouseOver);
               dropDownMenuElement.removeEventListener(MouseEvent.MOUSE_OUT,this.onFarmSelectButtonMouseOut);
            }
         }
         this.m_searchBar_mc = null;
         this.m_searchField_tf = null;
         this.m_clearSearchButton_mc = null;
         this.m_mainMenu = null;
         this.m_slotFrame = null;
         this.m_animalSubItems = null;
         this.m_buildingSubItems = null;
         this.m_decorationSubItems = null;
         this.m_storage = null;
         this.m_farmSelectBtn = null;
         this.m_farmDropDownMenu = null;
         this.m_shippingLicense_bt = null;
         this.m_farmDropDownMenu = null;
         this.m_farmSelectBtn = null;
      }
      
      protected function addSlotFrame() : void
      {
         this.m_slotFrame = addWidget(new StorageSlotFrame(m_window.slotFrame_mc,[],this)) as StorageSlotFrame;
      }
      
      private function onWorldMenuItemSelected(item:MenuItem) : void
      {
         if(this.m_searchField_tf.text == "")
         {
            this.m_pageHash[this.m_world + this.m_type + this.m_subType] = this.m_slotFrame.pageNumber;
         }
         if(this.m_searchField_tf.text != this.m_defaultString)
         {
            this.clearSearch();
         }
         this.m_world = item.data as String;
         this.m_type = this.m_typeHash[this.m_world];
         this.m_subType = this.m_subTypeHash[this.m_world + this.m_type];
         if(this.m_world == WorldsConstants.WORLD_ID_HOME)
         {
            this.m_iconHome_mc.visible = true;
            this.m_iconUk_mc.visible = false;
         }
         else if(this.m_world == WorldsConstants.WORLD_ID_ENGLAND)
         {
            this.m_iconHome_mc.visible = false;
            this.m_iconUk_mc.visible = true;
         }
         this.setUpTypeMenu();
         this.setUpSubMenu();
         this.m_page = this.m_pageHash[this.m_world + this.m_type + this.m_subType];
         this.reload();
      }
      
      private function setUpTypeMenu() : void
      {
         var i:int = 0;
         for(i = 0; i < this.m_mainMenu.items.length; i++)
         {
            if(this.m_mainMenu.getItem(i).data == this.m_type)
            {
               this.m_mainMenu.selectTab(i);
            }
         }
      }
      
      private function setUpFarmSelectionMenu() : void
      {
         var currentFarm:String = null;
         var isCurrentWorldIncluded:Boolean = false;
         var menuItems:Array = null;
         var idx:int = 0;
         var farms:Array = Global.worldManager.getWorldsWithLicenseType(WorldLicenseRequirement.DEFAULT_WORLD_LICENSE_TYPE);
         if(null != farms && farms.length > 0)
         {
            currentFarm = Global.worldManager.currentWorldType;
            isCurrentWorldIncluded = false;
            menuItems = [];
            for(idx = 0; idx < farms.length; idx++)
            {
               if(currentFarm == farms[idx])
               {
                  isCurrentWorldIncluded = true;
               }
               menuItems.push(new MenuItem({"id":farms[idx]},Global.worldManager.getWorldFriendlyName(farms[idx])));
            }
            this.m_farmSelectBtn.visible = false;
            if(isCurrentWorldIncluded && menuItems.length > 1)
            {
               this.m_farmDropDownMenu.items = menuItems;
               this.m_farmSelectBtn.visible = true;
            }
         }
      }
      
      private function onFarmSelectButtonMouseOver(event:MouseEvent) : void
      {
         this.m_farmDropDownMenu.visible = true;
         this.m_farmDropDownMenu.refresh();
      }
      
      private function onFarmSelectButtonMouseOut(event:MouseEvent) : void
      {
         this.m_farmDropDownMenu.visible = false;
      }
      
      private function onFarmSelected(item:MenuItem) : void
      {
         this.m_world = item.data.id;
         this.reload();
      }
      
      private function onMainMenuItemSelected(item:MenuItem) : void
      {
         if(this.m_searchField_tf.text == "")
         {
            this.m_pageHash[this.m_world + this.m_type + this.m_subType] = this.m_slotFrame.pageNumber;
         }
         if(this.m_searchField_tf.text != this.m_defaultString)
         {
            this.clearSearch();
         }
         this.m_type = item.data as String;
         this.m_typeHash[this.m_world] = this.m_type;
         this.m_subType = this.m_subTypeHash[this.m_world + this.m_type];
         this.setUpSubMenu();
         this.m_page = this.m_pageHash[this.m_world + this.m_type + this.m_subType];
         this.reload();
      }
      
      private function setUpSubMenu() : void
      {
         var i:int = 0;
         this.m_sortBy_tf.visible = true;
         this.m_subMenu.visible = true;
         switch(this.m_type)
         {
            case "all":
            case "tree":
            case "animal":
               this.m_sortBy_tf.visible = false;
               this.m_subMenu.visible = false;
               break;
            case "building":
               this.m_subMenu.items = this.m_buildingSubItems;
               break;
            case "decoration":
               this.m_subMenu.items = this.m_decorationSubItems;
         }
         for(i = 0; i < this.m_subMenu.items.length; i++)
         {
            if(this.m_subMenu.getItem(i).data == this.m_subType)
            {
               this.m_subMenu.selectTab(i);
            }
         }
      }
      
      private function onSubMenuItemSelected(item:MenuItem) : void
      {
         if(this.m_searchField_tf.text == "")
         {
            this.m_pageHash[this.m_world + this.m_type + this.m_subType] = this.m_slotFrame.pageNumber;
         }
         if(this.m_searchField_tf.text != this.m_defaultString)
         {
            this.clearSearch();
         }
         this.m_subType = item.data as String;
         this.m_subTypeHash[this.m_world + this.m_type] = this.m_subType;
         this.m_page = this.m_pageHash[this.m_world + this.m_type + this.m_subType];
         this.reload();
      }
      
      public function reload() : void
      {
         var item:Object = null;
         var hashName:String = null;
         var filteredItems:Array = [];
         this.getInventoryItems();
         this.m_inventoryUsage = Global.player.getInventoryUsage(Global.player.currentStorageWorldId);
         this.m_inventoryCapacity = Global.player.getInventoryCapacity(false,Global.player.currentStorageWorldId);
         if(this.m_inventoryCapacity == 0)
         {
            this.m_inventoryCapacity = this.m_inventoryUsage;
         }
         this.m_capacity_tf.text = ZLocUtils.t("Dialogs","Capacity",{"quantity":this.m_inventoryCapacity});
         this.m_current_tf.text = ZLocUtils.t("Dialogs","Current",{"quantity":this.m_inventoryUsage});
         if(this.m_searchField_tf.text == "" || this.m_searchField_tf.text == this.m_defaultString)
         {
            for each(item in this.m_items)
            {
               if(this.m_type == "all")
               {
                  filteredItems.push(item);
               }
               else
               {
                  hashName = this.m_type + (this.m_subType == "all" ? "" : this.m_subType);
                  if(item.type == hashName || Boolean(item.marketEntriesHash.hasOwnProperty(hashName)))
                  {
                     filteredItems.push(item);
                  }
               }
            }
            this.m_clearSearchButton_mc.visible = false;
            this.m_search_mc.visible = true;
         }
         else
         {
            for each(item in this.m_items)
            {
               if(item.localizedName.search(this.m_searchField_tf.text.toLowerCase()) != -1)
               {
                  filteredItems.push(item);
               }
            }
            this.m_clearSearchButton_mc.visible = true;
            this.m_search_mc.visible = false;
         }
         filteredItems.sort(this.sortByName);
         this.m_slotFrame.updateSlots(filteredItems,this.m_page);
      }
      
      private function sortByPopulation(obj1:Object, obj2:Object) : int
      {
         var result:int = 0;
         var score1:String = this.usedTypes[obj1.itemKey];
         var score2:String = this.usedTypes[obj2.itemKey];
         if(score1 > score2)
         {
            result = -1;
         }
         else if(score1 < score2)
         {
            result = 1;
         }
         else
         {
            result = this.sortByName(obj1,obj2);
         }
         return result;
      }
      
      private function sortByName(obj1:Object, obj2:Object) : int
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
      
      private function onSearchTextButtonClick(event:MouseEvent) : void
      {
         Global.farmGame.switchOutFullScreen();
         if(this.m_searchField_tf.text == this.m_defaultString)
         {
            this.m_searchField_tf.text = "";
         }
      }
      
      public function clearSearch() : void
      {
         this.m_searchField_tf.text = "";
         this.m_mainMenu.restoreAllDeselected();
         this.m_page = this.m_pageHash[this.m_world + this.m_type + this.m_subType];
         this.reload();
      }
      
      private function onClearSearchButtonClick(event:MouseEvent) : void
      {
         this.clearSearch();
      }
      
      private function enableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = false;
      }
      
      private function disableShortcut(event:FocusEvent) : void
      {
         Global.overrideDebugKeys = true;
      }
      
      private function onKeyUpHandler(event:KeyboardEvent) : void
      {
         if(this.m_searchField_tf.text == "")
         {
            this.m_mainMenu.restoreAllDeselected();
            this.setUpSubMenu();
            this.m_page = this.m_pageHash[this.m_world + this.m_type + this.m_subType];
         }
         else
         {
            if(this.m_searchField_tf.text.length == 1 && event.charCode != 8)
            {
               this.m_pageHash[this.m_world + this.m_type + this.m_subType] = this.m_slotFrame.pageNumber;
            }
            this.m_mainMenu.deselectAll();
            this.m_sortBy_tf.visible = false;
            this.m_subMenu.visible = false;
            this.m_page = 0;
         }
         this.reload();
      }
      
      protected function onExpandButtonClick(event:MouseEvent) : void
      {
         UI.displayInventoryDialog("upgrade",this.m_storage);
         this.close();
      }
      
      protected function onShippingLicensesButtonClick(event:MouseEvent) : void
      {
         UI.displayInventoryDialog(InventoryWithdrawal.SECTION_SHIPPING_LICENSES,this.m_storage);
         this.close();
      }
      
      private function getInventoryItems() : void
      {
         var worldInventoryId:Number = Global.worldManager.getStorageIdByWorld(this.m_world);
         this.m_items = [];
         if(Global.player.storageData)
         {
            this.m_items = this.getInventoryItemsByWorld(worldInventoryId);
         }
      }
      
      private function getInventoryItemsByWorld(worldId:int) : Array
      {
         var key:String = null;
         var inventoryItem:StorageItem = null;
         var extraData:Array = null;
         var itemCode:String = null;
         var object:Object = null;
         var farmItem:FarmItem = null;
         var returnArray:Array = [];
         this.usedTypes = new Object();
         Global.player.currentStorageWorldId = worldId;
         var objects:Dictionary = Global.player.getInventory(worldId);
         if(objects)
         {
            for(key in objects)
            {
               inventoryItem = objects[key] as StorageItem;
               if(Boolean(inventoryItem) && inventoryItem.quantity > 0)
               {
                  extraData = new Array();
                  itemCode = Global.farmGameSettingsManager.getItemCodeFromInventoryKey(key,extraData);
                  object = new Object();
                  object.allowMultiSell = true;
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                  if(farmItem != null)
                  {
                     if(this.usedTypes[itemCode] == null)
                     {
                        this.usedTypes[itemCode] = inventoryItem.quantity;
                        object.itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
                        object.itemKey = key;
                        object.code = itemCode;
                        if(key != itemCode)
                        {
                           object.allowMultiSell = false;
                        }
                        object.type = farmItem.type;
                        object.localizedName = farmItem.friendlyTitle.toLowerCase();
                        object.cost = farmItem.cost;
                        object.sellPrice = farmItem.sellPrice;
                        object.rank = farmItem.sortPriority;
                        object.marketEntriesHash = farmItem.marketEntriesHash;
                        if(Boolean(extraData) && Boolean(extraData[1]))
                        {
                           object.expansionLevel = extraData[1];
                        }
                        returnArray.push(object);
                     }
                     else
                     {
                        this.usedTypes[itemCode] += inventoryItem.quantity;
                     }
                  }
               }
            }
         }
         return returnArray;
      }
      
      public function setButtonEnable(enable:Boolean) : void
      {
         this.m_mainMenu.enabled = enable;
         this.m_subMenu.enabled = enable;
         this.m_slotFrame.setButtonEnable(enable);
         this.m_expand_bt.enabled = enable;
         this.m_searchBar_mc.enabled = enable;
         this.m_shippingLicense_bt.enabled = enable;
         m_closeButton.enabled = enable;
      }
      
      override public function close() : void
      {
         if(Boolean(m_window) && Boolean(m_window.close_bt.enabled))
         {
            UI.storageWindowState["searchString"] = this.m_searchField_tf.text;
            UI.storageWindowState["typeHash"] = this.m_typeHash;
            UI.storageWindowState["subTypeHash"] = this.m_subTypeHash;
            UI.storageWindowState["pageHash"] = this.m_pageHash;
            UI.storageWindowState["world"] = this.m_world;
            UI.storageWindowState["type"] = this.m_type;
            UI.storageWindowState["subType"] = this.m_subType;
            UI.storageWindowState["page"] = this.m_slotFrame.pageNumber;
            super.close();
            Global.player.currentStorageWorldId = Global.worldManager.getCurrentWorldStorageId();
         }
      }
      
      public function isUseable() : Boolean
      {
         return Global.worldManager.hasWorldContentLicense(this.m_world,WorldLicenseRequirement.DEFAULT_WORLD_LICENSE_TYPE) && Global.worldManager.hasWorldContentLicense(Global.worldManager.currentWorldType,WorldLicenseRequirement.DEFAULT_WORLD_LICENSE_TYPE);
      }
      
      public function get displayedWorld() : String
      {
         return this.m_world;
      }
   }
}

