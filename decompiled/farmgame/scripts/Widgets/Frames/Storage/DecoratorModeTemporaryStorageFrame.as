package Widgets.Frames.Storage
{
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import GameMode.GMObjectMove;
   import GameMode.GameMode;
   import Managers.DecoratorModeManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.Storage.DecoratorModeTemporaryStorageSlot;
   import Widgets.Windows.DecoratorMode.DecoratorModeStorage;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Storage.StorageWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   
   public class DecoratorModeTemporaryStorageFrame extends GenericSlotContainerFrame
   {
      
      private var ERROR_OFFSET_X:int = 0;
      
      private var ERROR_OFFSET_Y:int = 0;
      
      private var m_storedItems:Dictionary = new Dictionary();
      
      private var m_noResults:ZwTextField;
      
      private var m_itemCounts:Object;
      
      private var m_storageEnabled:Boolean = true;
      
      private var m_storageId:int = Global.worldManager.getCurrentWorldStorageId();
      
      public function DecoratorModeTemporaryStorageFrame(element:DisplayObject, itemCounts:Object, parentWindow:FarmWindow)
      {
         this.m_itemCounts = itemCounts;
         super(element,DecoratorModeTemporaryStorageSlot,new Array(),parentWindow);
         if(m_element["noResults_tf"] != null)
         {
            addWidget(this.m_noResults = new ZwTextField(m_element.noResults_tf,ZLocUtils.t("Dialogs","DecoratorMode_TempStorage_empty")));
            m_element["noResults_tf"].addEventListener(MouseEvent.CLICK,this.onStoreClick);
         }
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new DecoratorModeTemporaryStorageSlot(slotElement,m_parentWindow as StorageWindow,this.m_storageId,this);
      }
      
      public function onStoreClick(event:MouseEvent) : void
      {
         var gmMove:GMObjectMove = null;
         var mapResource:MapResource = null;
         var gm:GameMode = Global.world.getTopGameMode();
         if(gm != null)
         {
            if(gm is GMObjectMove)
            {
               gmMove = gm as GMObjectMove;
               mapResource = gmMove.selectedObject as MapResource;
               if(mapResource != null)
               {
                  if(gmMove.isFromStorage())
                  {
                     if(gmMove.storedOrigin == this.m_storageId)
                     {
                        this.addToTempStorage(mapResource);
                        DecoratorModeManager.instance.setGameMode(DecoratorModeManager.MOVE_MODE);
                     }
                     else
                     {
                        Global.player.removeInventoryItem(mapResource.getInventoryCode(),1,gmMove.storedOrigin);
                        this.addToStorage(mapResource,gmMove);
                     }
                  }
                  else
                  {
                     this.addToStorage(mapResource,gmMove);
                  }
               }
            }
         }
      }
      
      private function addToStorage(mapResource:MapResource, gmMove:GMObjectMove) : void
      {
         var loc:Point = null;
         var successfullyAdded:Boolean = DecoratorModeManager.instance.storeItem(mapResource);
         if(successfullyAdded)
         {
            StatsManager.count(DecoratorModeManager.STATS_KINGDOM,"ui_clicks","temp_storage","stored_item");
            gmMove.setStoredSuccess(true);
            this.addToTempStorage(mapResource);
            DecoratorModeManager.instance.setGameMode(DecoratorModeManager.MOVE_MODE);
         }
         else
         {
            loc = new Point(parent.x,parent.y);
            if(m_element.parent["target_mc"] != null)
            {
               loc.x += m_element.parent["target_mc"].width / 2;
               loc.y += m_element.parent["target_mc"].height / 2;
            }
            (m_parentWindow as DecoratorModeStorage).showErrorDialog(loc.x,loc.y);
         }
      }
      
      public function addToTempStorage(resource:MapResource) : void
      {
         var storageKey:String = null;
         var farmItem:FarmItem = resource.getItem();
         if(farmItem != null)
         {
            storageKey = resource.getInventoryCode();
            if(this.m_storedItems[storageKey] != null)
            {
               this.m_storedItems[storageKey].amount += 1;
               this.m_storedItems[storageKey] = this.syncItemWithStorage(storageKey);
            }
            else
            {
               this.m_storedItems[storageKey] = {
                  "item":farmItem,
                  "amount":1,
                  "key":storageKey
               };
            }
            this.refreshData();
         }
      }
      
      public function setItemCounts(itemCounts:Object) : void
      {
         this.m_itemCounts = itemCounts;
      }
      
      public function refreshTemporaryStoredItems() : void
      {
         var key:String = null;
         var newData:Object = null;
         var newStoredItems:Dictionary = new Dictionary();
         for(key in this.m_storedItems)
         {
            newData = this.syncItemWithStorage(key);
            if(newData != null)
            {
               newStoredItems[key] = newData;
            }
         }
         this.m_storedItems = newStoredItems;
         this.refreshData();
      }
      
      public function set StorageEnabled(enable:Boolean) : void
      {
         this.m_storageEnabled = enable;
      }
      
      public function get StorageEnabled() : Boolean
      {
         return this.m_storageEnabled;
      }
      
      private function syncItemWithStorage(storageKey:String) : Object
      {
         var itemData:Object = null;
         storageKey = Global.farmGameSettingsManager.getItemCodeFromInventoryKey(storageKey,null);
         if(this.m_itemCounts.hasOwnProperty(storageKey))
         {
            itemData = this.m_storedItems[storageKey];
            if(itemData)
            {
               if(itemData.amount > this.m_itemCounts[storageKey])
               {
                  itemData.amount = this.m_itemCounts[storageKey];
               }
            }
         }
         return itemData;
      }
      
      public function removeItem(storageKey:String) : void
      {
         var storageData:Object = this.m_storedItems[storageKey];
         if(storageData)
         {
            --storageData.amount;
            if(storageData.amount <= 0)
            {
               delete this.m_storedItems[storageKey];
            }
            this.refreshData();
         }
      }
      
      private function refreshData() : void
      {
         var storedItem:Object = null;
         var item:FarmItem = null;
         var data:Array = new Array();
         var i:int = 0;
         for each(storedItem in this.m_storedItems)
         {
            item = storedItem.item;
            data[i] = {
               "title":item.friendlyTitle,
               "icon":item.icon,
               "amount":storedItem.amount,
               "name":item.name,
               "slotData":this.buildDataObject(storedItem)
            };
            i++;
         }
         if(this.m_noResults)
         {
            this.m_noResults.visible = data.length == 0;
         }
         setData(data);
      }
      
      private function buildDataObject(storedItem:Object) : Object
      {
         var object:Object = new Object();
         var extraData:Array = new Array();
         var itemCode:String = Global.farmGameSettingsManager.getItemCodeFromInventoryKey(storedItem.key,extraData);
         var farmItem:FarmItem = storedItem.item;
         object.allowMultiSell = true;
         object.itemName = farmItem.name;
         object.itemKey = storedItem.key;
         object.code = itemCode;
         if(storedItem.key != itemCode)
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
         return object;
      }
   }
}

