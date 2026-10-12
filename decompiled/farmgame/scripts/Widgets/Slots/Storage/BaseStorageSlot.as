package Widgets.Slots.Storage
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.MarketEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.Storage.StorageWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class BaseStorageSlot extends ZwSlotFrame
   {
      
      protected var m_storageWindow:StorageWindow = null;
      
      protected var m_data:Object = null;
      
      protected var m_farmItem:FarmItem = null;
      
      protected var m_title_tf:ZwTextField;
      
      protected var m_itemCount_tf:ZwTextField;
      
      protected var m_icon_mc:FarmIcon;
      
      public function BaseStorageSlot(element:DisplayObject, storageWindow:StorageWindow)
      {
         this.m_storageWindow = storageWindow;
         super(element);
      }
      
      protected function onUseClick(event:MouseEvent) : void
      {
         var useDataSource:Boolean = false;
         var itemKey:String = this.m_data.itemKey;
         var itemType:String = this.m_data.type;
         var name:String = this.m_data.itemName;
         var featureName:String = Global.animalBreedingSettings.getFeatureNameByItem(name);
         var extraData:Object = new Object();
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         if(Boolean(this.m_data) && this.m_data.hasOwnProperty("expansionLevel"))
         {
            extraData.expansionLevel = this.m_data.expansionLevel;
         }
         FarmStatsManager.sample(100,"Storage","goods","removed",name);
         extraData.isGift = false;
         if(name != farmItem.name)
         {
            extraData.realItemName = name;
         }
         if(itemKey != farmItem.code)
         {
            extraData.inventoryKey = itemKey;
         }
         var useRealItemNameEnabled:Boolean = Boolean(Global.flashHotParams["REALITEMNAME_ENABLED"]);
         if(useRealItemNameEnabled && name != farmItem.name)
         {
            useDataSource = FarmGameSettingsManager.isInDataSourceExperiment();
            if(name.indexOf(FarmItem.ITEM_POSTFIX_SALE) > 0)
            {
               if(useDataSource)
               {
                  farmItem.swapToSaleData();
               }
               else
               {
                  farmItem.xml = farmItem.saleXML;
               }
               StatsManager.count("REALITEMNAME_ENABLED","StorageSlot","farmItem.xml","farmItem.saleXML");
            }
            else if(name.indexOf(FarmItem.ITEM_POSTFIX_CASH) > 0)
            {
               if(useDataSource)
               {
                  farmItem.swapToCashData();
               }
               else
               {
                  farmItem.xml = farmItem.cashXML;
               }
               StatsManager.count("REALITEMNAME_ENABLED","StorageSlot","farmItem.xml","farmItem.cashXML");
            }
         }
         if(!AnimalBreedingManager.isMutableAnimal(farmItem) || AnimalBreedingManager.canAddUGCToWorld(featureName))
         {
            farmItem.onUse(this.storageWorldId(),extraData);
            dispatchEvent(new MarketEvent(MarketEvent.MARKET_GIFT,MarketEvent.NONE));
         }
         else
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","UGCFarmCapacityOvershot")));
         }
         if(this.shouldCloseOnUse())
         {
            this.m_storageWindow.close();
         }
      }
      
      protected function storageWorldId() : int
      {
         return Global.player.currentStorageWorldId;
      }
      
      protected function shouldCloseOnUse() : Boolean
      {
         return true;
      }
   }
}

