package Widgets.Windows.Crafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.crafting.CraftingInventoryStateV2;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.DisplayObjectUtils;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.FarmVillageManager;
   import Transactions.TFarmTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.Crafting.VillageIngredientSlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class VillageIngredientStorageWindow extends FarmWindow
   {
      
      public static const BUILDING_NAME_CONST:String = "villagecraftingsilo";
      
      public static const INGREDIENT_STORAGE_STAT:String = "ingredient_storage";
      
      private var m_featureName:String = "";
      
      private var m_building:FeatureBuilding = null;
      
      private var m_costToUpgrade:String = "";
      
      public function VillageIngredientStorageWindow(ingredientBuilding:FeatureBuilding = null, windowAssetRelUrl:String = "assets/dialogs/Village/FV_village_workshop_expand.swf", locPrefix:String = "IngredientStorage")
      {
         var buildings:Array = null;
         super(windowAssetRelUrl);
         this.m_featureName = locPrefix;
         this.m_building = ingredientBuilding;
         if(this.m_building == null)
         {
            buildings = Global.world.getObjectsByName(VillageIngredientStorageWindow.BUILDING_NAME_CONST);
            if(buildings != null && buildings.length > 0)
            {
               this.m_building = buildings.pop();
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var currentInventory:int = 0;
         var upgradeWidget:FarmAnimatedTextButton = null;
         var popupElement:MovieClip = null;
         var popupWidget:ZwFrame = null;
         var priceObject:Object = null;
         var storageItems:Array = null;
         super.postLoadComplete();
         if(m_window.title_tf != null)
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Title")));
         }
         if(m_window.inventoryTitle_tf != null)
         {
            addWidget(new ZwTextField(m_window.inventoryTitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "InventoryTitle")));
         }
         var inventoryState:CraftingInventoryStateV2 = Global.player.craftingState.inventoryState;
         var maxInventory:int = inventoryState.villageStorageMaxCapacity;
         if(m_window.inventory_tf != null)
         {
            currentInventory = inventoryState.villageStorageCurrentCapacity;
            addWidget(new ZwTextField(m_window.inventory_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Inventory",{
               "curr":currentInventory,
               "max":maxInventory
            })));
         }
         if(m_window.upgrade_mc != null)
         {
            upgradeWidget = new FarmAnimatedTextButton(m_window.upgrade_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "IncreaseStorage"),this.showExpandPopup);
            addWidget(upgradeWidget,!this.m_building.hasReachedMaxExpansionLevel());
         }
         var noResult:ZwBaseWidget = null;
         if(m_window.noResults_tf != null)
         {
            noResult = addWidget(new ZwTextField(m_window.noResults_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "StorageEmpty")),false);
         }
         if(m_window.increaseStorage_mc != null)
         {
            popupElement = m_window.increaseStorage_mc;
            popupWidget = new ZwFrame(m_window.increaseStorage_mc);
            addWidget(popupWidget,false);
            if(popupElement.header_tf != null)
            {
               popupWidget.addWidget(new ZwTextField(popupElement.header_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "TooltipHeader")));
            }
            if(popupElement.subheader_tf != null)
            {
               popupWidget.addWidget(new ZwTextField(popupElement.subheader_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "TooltipSubheader")));
            }
            if(popupElement.unlockFC_bt != null)
            {
               popupWidget.addWidget(new FarmAnimatedCashButton(popupElement.unlockFC_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Upgrade"),this.m_building.nextExpansionCashNeeded().toString(),this.upgradeCallback,false,false,true));
            }
            if(popupElement.unlockVC_bt != null)
            {
               priceObject = this.m_building.getPriceForExpansion();
               if(priceObject.hasOwnProperty(FarmVillageManager.CURRENCY_NAME))
               {
                  this.m_costToUpgrade = priceObject[FarmVillageManager.CURRENCY_NAME];
                  popupWidget.addWidget(new FarmAnimatedCashButton(popupElement.unlockVC_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Upgrade"),this.m_costToUpgrade,this.upgradeCurrencyCallback));
               }
            }
            if(popupElement.closeExpand_bt != null)
            {
               popupWidget.addWidget(new FarmAnimatedButton(popupElement.closeExpand_bt,this.hideExpandPopup));
            }
         }
         if(m_window.ingredientSlots_mc != null)
         {
            storageItems = this.getStorageItems();
            if(noResult != null && storageItems.length == 0)
            {
               noResult.visible = true;
            }
            storageItems = storageItems.sort(this.alphBushelSort);
            addWidget(new GenericSlotContainerFrame(m_window.ingredientSlots_mc,VillageIngredientSlot,storageItems,this));
         }
         StatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,VillageIngredientStorageWindow.INGREDIENT_STORAGE_STAT,"impression");
      }
      
      private function alphBushelSort(a:Object, b:Object) : int
      {
         var aName:String = a is MarketInventoryItem && Boolean((a as MarketInventoryItem).underlyingItem) ? (a as MarketInventoryItem).underlyingItem.friendlyTitle : null;
         var bName:String = b is MarketInventoryItem && Boolean((b as MarketInventoryItem).underlyingItem) ? (b as MarketInventoryItem).underlyingItem.friendlyTitle : null;
         if(aName < bName)
         {
            return -1;
         }
         if(aName > bName)
         {
            return 1;
         }
         return 0;
      }
      
      private function getStorageItems() : Array
      {
         var villageItem:MarketInventoryItem = null;
         var result:Array = new Array();
         var villageItems:Dictionary = Global.player.craftingState.inventoryState.villageStorageItems;
         for each(villageItem in villageItems)
         {
            if(villageItem.quantity > 0)
            {
               result.push(villageItem);
            }
         }
         return result;
      }
      
      public function upgradeCallback(event:Event) : void
      {
         if(Global.player.canBuyCash(this.m_building.nextExpansionCashNeeded(),true))
         {
            this.m_building.frictionlessExpand();
            StatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,VillageIngredientStorageWindow.INGREDIENT_STORAGE_STAT,"expand","cash",this.m_building.nextExpansionCashNeeded().toString());
            DisplayObjectUtils.grayOut(this,true);
            enableInput = false;
            Global.stage.addEventListener(TFarmTransaction.CRAFT_MAX_UPDATED,this.upgradeFinished);
         }
      }
      
      public function upgradeCurrencyCallback(event:Event) : void
      {
         if(Global.player.canBuyWithCurrency(FarmVillageManager.CURRENCY_NAME,Number(this.m_costToUpgrade)))
         {
            this.m_building.expandBuildingUsingCurrencyOrCash();
            StatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,VillageIngredientStorageWindow.INGREDIENT_STORAGE_STAT,"expand","currency",this.m_costToUpgrade);
            DisplayObjectUtils.grayOut(this,true);
            enableInput = false;
            Global.stage.addEventListener(TFarmTransaction.CRAFT_MAX_UPDATED,this.upgradeFinished);
         }
      }
      
      private function upgradeFinished(e:Event) : void
      {
         Global.stage.removeEventListener(TFarmTransaction.CRAFT_MAX_UPDATED,this.upgradeFinished);
         DisplayObjectUtils.grayOut(this,false);
         enableInput = true;
         this.refreshWindow();
      }
      
      private function showExpandPopup(event:Event) : void
      {
         if(m_window.increaseStorage_mc != null)
         {
            getWidget(m_window.increaseStorage_mc).visible = true;
         }
      }
      
      private function hideExpandPopup(event:Event) : void
      {
         if(m_window.increaseStorage_mc != null)
         {
            getWidget(m_window.increaseStorage_mc).visible = false;
         }
      }
      
      override public function refreshWindow() : void
      {
         var inventoryState:CraftingInventoryStateV2 = null;
         var currentInventory:int = 0;
         var maxInventory:int = 0;
         var storageItems:Array = null;
         var noResult:ZwBaseWidget = null;
         var upgradeWidget:FarmAnimatedTextButton = null;
         var popupElement:MovieClip = null;
         var popupWidget:ZwFrame = null;
         var unlockFC:FarmAnimatedCashButton = null;
         var priceObject:Object = null;
         var unlockVC:FarmAnimatedCashButton = null;
         if(m_window.inventory_tf != null)
         {
            inventoryState = Global.player.craftingState.inventoryState;
            currentInventory = inventoryState.villageStorageCurrentCapacity;
            maxInventory = inventoryState.villageStorageMaxCapacity;
            (getWidget(m_window.inventory_tf) as ZwTextField).text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "Inventory",{
               "curr":currentInventory,
               "max":maxInventory
            });
         }
         if(m_window.ingredientSlots_mc != null)
         {
            storageItems = this.getStorageItems();
            if(m_window.noResults_tf != null)
            {
               noResult = getWidget(m_window.noResults_tf);
               if(noResult != null)
               {
                  if(storageItems.length == 0)
                  {
                     noResult.visible = true;
                  }
                  else
                  {
                     noResult.visible = false;
                  }
               }
            }
            (getWidget(m_window.ingredientSlots_mc) as GenericSlotContainerFrame).setData(storageItems);
         }
         if(m_window.upgrade_mc != null)
         {
            upgradeWidget = getWidget(m_window.upgrade_mc) as FarmAnimatedTextButton;
            upgradeWidget.visible = !this.m_building.hasReachedMaxExpansionLevel();
         }
         if(m_window.increaseStorage_mc != null)
         {
            popupElement = m_window.increaseStorage_mc;
            popupWidget = getWidget(m_window.increaseStorage_mc) as ZwFrame;
            if(popupElement.unlockFC_bt != null)
            {
               unlockFC = popupWidget.getWidget(popupElement.unlockFC_bt) as FarmAnimatedCashButton;
               unlockFC.setAmountText(this.m_building.nextExpansionCashNeeded().toString());
            }
            if(popupElement.unlockVC_bt != null)
            {
               priceObject = this.m_building.getPriceForExpansion();
               if(priceObject.hasOwnProperty(FarmVillageManager.CURRENCY_NAME))
               {
                  this.m_costToUpgrade = priceObject[FarmVillageManager.CURRENCY_NAME];
                  unlockVC = popupWidget.getWidget(popupElement.unlockVC_bt) as FarmAnimatedCashButton;
                  unlockVC.setAmountText(this.m_costToUpgrade.toString());
               }
            }
         }
         this.hideExpandPopup(null);
      }
      
      override protected function release() : void
      {
         this.m_building = null;
         super.release();
      }
   }
}

