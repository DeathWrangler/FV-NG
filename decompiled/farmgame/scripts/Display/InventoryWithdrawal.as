package Display
{
   import Classes.InventoryCellar;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Events.CloseEvent;
   import Events.GenericPopupEvent;
   import Events.MarketEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Transactions.TSellStoredItem;
   import Transactions.TUpgradeStorage;
   import Widgets.Frames.Storage.ShippingLicenseSlotContainerFrame;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class InventoryWithdrawal extends SlotDialog
   {
      
      public static const SECTION_SHIPPING_LICENSES:String = "shippingLicenses";
      
      private var m_building:StorageBuilding;
      
      private const NUM_SLOTS:int = 6;
      
      private const MAX_FRIEND_LIST_LENGTH:int = 100;
      
      private var m_usedTypes:Object = null;
      
      protected var m_buttons:Array;
      
      protected var m_dialogType:String;
      
      private var m_itemObject:Object;
      
      private var m_burstLocation:int = -1;
      
      protected var m_currentSection:String = "inventory";
      
      protected var m_categoryButtons:Object;
      
      protected var m_friendList:Array;
      
      private var m_shippingLicenseSlotContainer:ShippingLicenseSlotContainerFrame;
      
      private var m_cannotExpandTooltip:Array;
      
      public function InventoryWithdrawal(storage:StorageBuilding = null, section:String = "inventory", update:Boolean = true, postLoadFunc:Function = null)
      {
         var storageBuildings:Array = null;
         this.m_buttons = new Array();
         this.m_categoryButtons = new Object();
         this.m_cannotExpandTooltip = new Array();
         m_dialogAsset = "assets/dialogs/FV_Storage_shipping.swf";
         this.m_dialogType = "inventory";
         this.m_currentSection = section;
         if(storage == null)
         {
            storageBuildings = Global.world.getObjectsByClass(StorageBuilding);
            storage = storageBuildings[0];
         }
         this.m_building = storage;
         if(update)
         {
            TransactionManager.addTransaction(new TUpgradeStorage(storage,this,"update",postLoadFunc),true);
         }
         super();
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
      
      public static function sendPostUpgradeFeed() : void
      {
         var url:String = Global.getAssetURL("assets/newsfeed/storage_increase.png");
         var building:StorageBuilding = Global.world.getObjectById(Global.player.upgradeStatus.buildingId) as StorageBuilding;
         var feedType:String = building.getItem().getExpansionIncomplete();
         if(feedType != "")
         {
            url = Global.getAssetURL("assets/newsfeed/" + feedType + ".png");
         }
         var remaining:int = Global.farmGameSettingsManager.getInt("storageExpansionFriendRequirement",10) - Global.player.upgradeStatus.numHelped;
         var params:Object = {
            "numRemaining":remaining,
            "reward_link":Global.player.upgradeStatus.url,
            "images":[{
               "src":url,
               "href":"{SN_APP_URL}" + Global.player.upgradeStatus.url
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory("StorageUpgradeAskForHelp" + feedType,params,[],false);
      }
      
      private static function isVirtualStorageBuilding(building:FarmItem) : Boolean
      {
         var isVirtual:Boolean = false;
         switch(building.name)
         {
            case "holidaytree":
            case "valentinesbox":
            case "potofgold":
            case "chateaufarmhouse":
            case "botanicalgarden":
            case "easterbasket":
            case "haitibackpack":
            case "tuscanwedding":
            case "marketstall":
            case "marketstall_cash":
            case "garage_finished":
               isVirtual = true;
         }
         return isVirtual;
      }
      
      public static function limitCheckInventoryItems() : void
      {
         var key:String = null;
         var inventoryItem:StorageItem = null;
         var itemCode:String = null;
         var giftItem:FarmItem = null;
         var objects:Dictionary = Global.player.getInventory();
         if(objects)
         {
            for(key in objects)
            {
               inventoryItem = objects[key] as StorageItem;
               if(Boolean(inventoryItem) && inventoryItem.quantity > 0)
               {
                  itemCode = Global.farmGameSettingsManager.getItemCodeFromInventoryKey(key);
                  giftItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                  if(giftItem != null)
                  {
                     if(Boolean(giftItem) && giftItem.limit > 0)
                     {
                        Global.player.addLimitedItem(giftItem.name);
                     }
                  }
               }
            }
         }
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.storage_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.storage_mc.arrowLt_bt.addEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.storage_mc.arrowRt_bt.addEventListener(MouseEvent.CLICK,onRtArrowClick);
         ZLocUtils.setText(m_window,"storage_mc.title_tf","Dialogs","InventoryTitle");
         var capacity:int = 0;
         if(this.m_building)
         {
            capacity = Global.player.getInventoryCapacity(false,Global.player.currentStorageWorldId);
         }
         ZLocUtils.setText(m_window,"storage_mc.capacity_tf","Dialogs","Capacity",{"quantity":capacity});
         ZLocUtils.setText(m_window,"storage_mc.current_tf","Dialogs","Current",{"quantity":Global.player.getInventoryUsage()});
         var gb:GenericButton = new GenericButton(m_window.storage_mc.inventory_bt,this.onMenuBarClick);
         gb.m_overlay.name = "inventory";
         gb.enableHitState(true);
         gb.text = ZLocUtils.t("Dialogs","InventoryInventory");
         this.m_categoryButtons["inventory"] = gb;
         gb = new GenericButton(m_window.storage_mc.expandStorage_bt,this.onMenuBarClick);
         gb.m_overlay.name = "upgrade";
         gb.enableHitState(true);
         gb.text = ZLocUtils.t("Dialogs","InventoryExpandStorage");
         this.m_categoryButtons["upgrade"] = gb;
         gb = new GenericButton(m_window.storage_mc.shippingLicenses_bt,this.onMenuBarClick);
         gb.m_overlay.name = SECTION_SHIPPING_LICENSES;
         gb.enableHitState(true);
         gb.text = ZLocUtils.t("Dialogs","InventoryShippingLicenses");
         this.m_categoryButtons[SECTION_SHIPPING_LICENSES] = gb;
         this.m_categoryButtons[this.m_currentSection].state = GenericButton.HITSTATE;
         m_tiles.push(m_window.storage_mc.storagePanel1,m_window.storage_mc.storagePanel2,m_window.storage_mc.storagePanel3,m_window.storage_mc.storagePanel4,m_window.storage_mc.storagePanel5,m_window.storage_mc.storagePanel6);
         removeTiles();
         this.pushNewData();
         var compIdx:int = 0;
         while(compIdx < this.NUM_SLOTS && compIdx < m_data.length)
         {
            this.addComponent(compIdx);
            compIdx++;
         }
         this.m_shippingLicenseSlotContainer = new ShippingLicenseSlotContainerFrame(m_window.storage_mc.shippingLicensesSlotContainerFrame_mc);
         this.m_shippingLicenseSlotContainer.addEventListener(Event.CLOSE,this.onShippingLicenseSlotEvent);
         this.m_shippingLicenseSlotContainer.visible = false;
         var expired:Boolean = Boolean(Global.player.upgradeStatus.expires) && Global.player.upgradeStatus.expires < GlobalEngine.serverTime / 1000;
         var completed:Boolean = Global.player.upgradeStatus.numHelped == Global.farmGameSettingsManager.getInt("storageExpansionFriendRequirement",10);
         if(expired || completed)
         {
            this.refreshLayout(true);
         }
         else if(this.m_currentSection == SECTION_SHIPPING_LICENSES)
         {
            this.setTilesVisible(false);
            this.setShippingLicensesVisible(true);
         }
      }
      
      private function onShippingLicenseSlotEvent(event:Event) : void
      {
         if(event.type == Event.CLOSE)
         {
            this.close();
         }
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_SLOTS;
      }
      
      override protected function fixArrows() : void
      {
         if(m_window)
         {
            m_window.storage_mc.arrowLt_bt.visible = m_tileSet > 0 ? true : false;
            m_window.storage_mc.arrowRt_bt.visible = (m_tileSet + 1) * this.getNumSlots() < m_data.length ? true : false;
         }
      }
      
      protected function onUpgradeCellarClick(event:Event) : void
      {
         var message:String = null;
         var cellar:InventoryCellar = null;
         var cellars:Array = Global.world.getObjectsByClass(InventoryCellar);
         if(cellars.length > 0)
         {
            cellar = cellars[0] as InventoryCellar;
            if(cellar)
            {
               close();
               cellar.displayStorageDialog();
            }
         }
         else if(InventoryCellar.isInCellarExperiment())
         {
            message = ZLocUtils.t("Dialogs","InventoryCellar_ExpandCellarNoBuilding");
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
         }
         else
         {
            message = ZLocUtils.t("Dialogs","InventoryCellar_ExpandCellarNoExperiment");
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"",true);
         }
      }
      
      protected function onMenuBarClick(event:Event) : void
      {
         var name:String = event.target.name;
         if(name != this.m_currentSection)
         {
            this.m_categoryButtons[this.m_currentSection].state = GenericButton.UPSTATE;
            this.m_currentSection = name;
            this.m_categoryButtons[this.m_currentSection].state = GenericButton.HITSTATE;
            if(this.m_currentSection == SECTION_SHIPPING_LICENSES)
            {
               this.setTilesVisible(false);
               this.setShippingLicensesVisible(true);
            }
            else
            {
               this.setTilesVisible(true);
               this.setShippingLicensesVisible(false);
               this.refreshLayout(true);
               if(this.m_currentSection == "upgrade" && !Global.player.getSeenFlag("UpgradeStorageSeen"))
               {
                  Global.player.setSeenFlag("UpgradeStorageSeen");
                  UI.displayMessage(ZLocUtils.t("Dialogs","UpgradeStorageFirst"),0,null,"",true);
               }
               if(this.m_currentSection == "inventory")
               {
                  UI.displayInventoryDialog("inventory",this.m_building);
                  close();
               }
            }
         }
      }
      
      private function setShippingLicensesVisible(isVisible:Boolean) : void
      {
         this.m_shippingLicenseSlotContainer.visible = isVisible;
      }
      
      private function setTilesVisible(isVisible:Boolean) : void
      {
         var tile:MovieClip = null;
         var tilesLength:int = int(m_tiles.length);
         for(var tileIdx:int = 0; tileIdx < tilesLength; tileIdx++)
         {
            tile = MovieClip(m_tiles[tileIdx]);
            if(tile)
            {
               tile.visible = isVisible;
            }
         }
      }
      
      private function pushNewData() : void
      {
         m_data = [];
         m_tileSet = 0;
         if(this.m_currentSection == "inventory")
         {
            this.getInventoryItems();
         }
         else
         {
            this.getStorageItems();
         }
         m_data.sort(getRankComparison);
         this.fixArrows();
      }
      
      private function getInventoryItems() : void
      {
         var key:String = null;
         var inventoryItem:StorageItem = null;
         var extraData:Array = null;
         var itemCode:String = null;
         var object:Object = null;
         var giftItem:FarmItem = null;
         this.m_usedTypes = new Object();
         var objects:Dictionary = Global.player.getInventory();
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
                  giftItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                  if(giftItem != null)
                  {
                     if(this.m_usedTypes[itemCode] == null)
                     {
                        this.m_usedTypes[itemCode] = inventoryItem.quantity;
                        object.name = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
                        object.code = itemCode;
                        object.type = giftItem.type;
                        object.localizedName = giftItem.friendlyName;
                        object.cost = giftItem.cost;
                        object.sellPrice = giftItem.sellPrice;
                        object.rank = giftItem.sortPriority;
                        if(Boolean(extraData) && Boolean(extraData[1]))
                        {
                           object.expansionLevel = extraData[1];
                        }
                        m_data.push(object);
                     }
                     else
                     {
                        this.m_usedTypes[itemCode] += inventoryItem.quantity;
                     }
                  }
               }
            }
         }
      }
      
      private function getStorageItems() : void
      {
         var object:Object = null;
         var worldObj:StorageBuilding = null;
         var building:FarmItem = null;
         var storageBuildings:Array = Global.world.getObjectsByClass(StorageBuilding);
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         for(var idx:int = 0; idx < storageBuildings.length; idx++)
         {
            object = new Object();
            worldObj = storageBuildings[idx] as StorageBuilding;
            building = worldObj.getItem();
            if(worldObj.showInInventoryWithdrawal() && !isVirtualStorageBuilding(building) && (Boolean(building.storageSize > 1) || Boolean(building.expansion)))
            {
               object.name = building.name;
               object.code = building.code;
               object.localizedName = building.friendlyName;
               object.expansion = building.getExpansion();
               object.id = worldObj.getId();
               if(isInDataSourceExperiment)
               {
                  object.rank = -1 * building.getIntFromDataSource("capacity");
                  if(building.getExpansion() != "")
                  {
                     object.rank = building.getIntFromDataSource("capacity");
                  }
               }
               else
               {
                  object.rank = -1 * building.xml.capacity;
                  if(building.getExpansion() != "")
                  {
                     object.rank = building.xml.capacity;
                  }
               }
               m_data.push(object);
            }
         }
         if(this.m_currentSection == "upgrade" && !Global.player.getSeenFlag("UpgradeStorageSeen"))
         {
            Global.player.setSeenFlag("UpgradeStorageSeen");
            UI.displayMessage(ZLocUtils.t("Dialogs","UpgradeStorageFirst"),0,null,"",true);
         }
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         var mc:MovieClip = null;
         var farmItem:FarmItem = null;
         var url:String = null;
         var iconUrlFromActiveXml:String = null;
         var icon:Loader = null;
         var dataObj:Object = m_data[index + compId];
         if(Boolean(m_tiles) && dataObj != null)
         {
            mc = m_tiles[compId] as MovieClip;
            m_tiles[compId].visible = true;
            m_tiles[compId].itemTitle_tf.htmlText = ZLocUtils.tk_pk_asTitle(dataObj.localizedName);
            this.m_buttons[compId] = new Array();
            if(m_tiles[compId].hasOwnProperty("use_bt"))
            {
               this.m_buttons[compId][0] = new GenericButton(m_tiles[compId].use_bt,this.onUse,"","gb_use");
            }
            else if(m_tiles[compId].hasOwnProperty("use_bt1"))
            {
               this.m_buttons[compId][0] = new GenericButton(m_tiles[compId].use_bt1,this.onUse,"","gb_use");
            }
            this.m_buttons[compId][0].text = ZLocUtils.t("Dialogs","Use");
            this.m_buttons[compId][1] = new GenericButton(m_tiles[compId].sell_bt,this.onSell,"","gb_sell");
            this.m_buttons[compId][1].text = ZLocUtils.t("Dialogs","Sell");
            this.m_buttons[compId][2] = new GenericButton(m_tiles[compId].expand_bt,this.onUpgrade,"","gb_upgrade");
            this.m_buttons[compId][2].text = ZLocUtils.t("Dialogs","Upgrade");
            this.m_buttons[compId][3] = new GenericButton(m_tiles[compId].buy_bt,this.onPurchaseUpgrade,"","gb_purchaseUpgrade");
            this.m_buttons[compId][3].text = ZLocUtils.t("Dialogs","Buy");
            this.m_buttons[compId][4] = new GenericButton(m_tiles[compId].cancel_bt,this.onCancelUpgrade,"","gb_cancelUpgrade");
            this.m_buttons[compId][4].text = ZLocUtils.t("Dialogs","Giveup");
            this.m_buttons[compId][4].turnOff();
            if(this.m_currentSection == "inventory")
            {
               m_tiles[compId].burstEffect.visible = false;
               m_tiles[compId].itemAmount_tf.visible = true;
               m_tiles[compId].itemAmount_tf.text = ZLocUtils.t("Dialogs","GiftAmount",{"quantity":this.m_usedTypes[dataObj.code]});
               m_tiles[compId].sell_tf.visible = true;
               m_tiles[compId].sell_tf.text = ZLocUtils.t("Dialogs","Yield",{
                  "coinQuantity":dataObj.sellPrice,
                  "Coin_word":ZLocUtils.tk("Dialogs","Coin_word","",dataObj.sellPrice)
               });
               this.m_buttons[compId][0].turnOn();
               this.m_buttons[compId][1].turnOn();
               this.m_buttons[compId][2].turnOff();
               this.m_buttons[compId][3].turnOff();
               m_tiles[compId].stars_mc.visible = false;
               m_tiles[compId].stars5_mc.visible = false;
               m_tiles[compId].expand_tf.visible = false;
               m_tiles[compId].expandNumbers_tf.visible = false;
               m_tiles[compId].expandProgress_tf.visible = false;
               Utilities.toggleInputAndChildren(m_tiles[compId],true);
            }
            else
            {
               m_tiles[compId].itemAmount_tf.visible = false;
               m_tiles[compId].sell_tf.visible = false;
               m_tiles[compId].burstEffect.visible = true;
               if(compId == this.m_burstLocation)
               {
                  m_tiles[compId].burstEffect.play();
                  this.m_burstLocation = -1;
               }
               else
               {
                  m_tiles[compId].burstEffect.gotoAndStop(1);
               }
               m_tiles[compId].expandProgress_tf.visible = false;
               this.fixStarsAndButtons(compId,index,dataObj.expansion,m_data[index + compId].name);
            }
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(m_data[index + compId].name);
            url = "";
            iconUrlFromActiveXml = farmItem.getIconUrlFromActiveData(m_data[index + compId].name);
            if(m_data[index + compId].name != farmItem.name && iconUrlFromActiveXml != "")
            {
               url = iconUrlFromActiveXml;
            }
            else
            {
               url = farmItem.icon;
            }
            icon = LoadingManager.load(url,function(event:Event):void
            {
               var dispObj:* = undefined;
               if(Boolean(icon) && Boolean(icon.content))
               {
                  if(m_tiles[compId])
                  {
                     Utilities.removeAllChildren(m_tiles[compId].icon);
                  }
                  dispObj = icon.content;
                  dispObj.width = 50;
                  dispObj.height = 50;
                  m_tiles[compId].icon.addChild(dispObj);
               }
            });
         }
      }
      
      private function fixStarsAndButtons(compId:int, index:int, upgradeName:String, currentName:String) : void
      {
         var activeStars:MovieClip = null;
         var hiddenStars:MovieClip = null;
         var capacity:Number = NaN;
         var mc:MovieClip = null;
         var numTotal:int = 0;
         var farmName:String = null;
         var toolTipText:String = null;
         this.m_buttons[compId][0].turnOff();
         this.m_buttons[compId][1].turnOff();
         this.m_buttons[compId][2].turnOn();
         this.m_buttons[compId][3].turnOn();
         var upgradeTo:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(upgradeName);
         var currentItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(currentName);
         if(currentItem.storageSize > 3)
         {
            activeStars = m_tiles[compId].stars5_mc as MovieClip;
            hiddenStars = m_tiles[compId].stars_mc as MovieClip;
         }
         else
         {
            activeStars = m_tiles[compId].stars_mc as MovieClip;
            hiddenStars = m_tiles[compId].stars5_mc as MovieClip;
         }
         if(null != activeStars)
         {
            activeStars.visible = true;
         }
         if(null != hiddenStars)
         {
            hiddenStars.visible = false;
         }
         if(null != activeStars)
         {
            activeStars.gotoAndStop(currentItem.storageSize + 1);
         }
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            capacity = currentItem.getNumberFromDataSource("capacity");
         }
         else
         {
            capacity = Number(currentItem.xml.capacity);
         }
         if(upgradeTo == null)
         {
            this.m_buttons[compId][2].turnOff();
            this.m_buttons[compId][3].turnOff();
            if(!(currentItem is StorageBuilding && (currentItem as StorageBuilding).hasNextExpansion()))
            {
               m_tiles[compId].expand_tf.visible = false;
               m_tiles[compId].expandNumbers_tf.visible = true;
               m_tiles[compId].expandNumbers_tf.text = ZLocUtils.t("Dialogs","StorageCapacity",{"quantity":capacity});
               m_tiles[compId].expandProgress_tf.visible = true;
               m_tiles[compId].expandProgress_tf.text = ZLocUtils.t("Dialogs","UpgradeFull");
            }
            else
            {
               m_tiles[compId].expand_tf.visible = false;
               m_tiles[compId].expandNumbers_tf.visible = false;
               m_tiles[compId].expandProgress_tf.visible = true;
               m_tiles[compId].expandProgress_tf.text = ZLocUtils.t("Dialogs","ComingSoon");
            }
            Utilities.toggleInputAndChildren(m_tiles[compId],false);
         }
         else
         {
            m_tiles[compId].expand_tf.visible = true;
            m_tiles[compId].expand_tf.text = ZLocUtils.t("Dialogs","UpgradeExpand");
            m_tiles[compId].expandNumbers_tf.visible = true;
            m_tiles[compId].expandNumbers_tf.text = ZLocUtils.t("Dialogs","UpgradeChange",{
               "quantity":capacity,
               "quantityTotal":capacity
            });
            mc = m_tiles[compId] as MovieClip;
            if(this.m_cannotExpandTooltip.length > compId && this.m_cannotExpandTooltip[compId] != null)
            {
               (this.m_cannotExpandTooltip[compId] as ZLocToolTip).detachToolTip(mc);
               (this.m_cannotExpandTooltip[compId] as ZLocToolTip).hide();
            }
            else
            {
               this.m_cannotExpandTooltip[compId] = null;
            }
            if(Global.player.upgradeStatus.isActive)
            {
               this.m_buttons[compId][2].turnOff();
               this.m_buttons[compId][3].turnOff();
               if(Global.player.upgradeStatus.buildingId == m_data[index + compId].id)
               {
                  this.m_buttons[compId][3].turnOn();
                  this.m_buttons[compId][4].turnOn();
                  m_tiles[compId].expandProgress_tf.visible = true;
                  numTotal = Global.farmGameSettingsManager.getInt("storageExpansionFriendRequirement",10);
                  m_tiles[compId].expandProgress_tf.text = ZLocUtils.t("Dialogs","UpgradeProgress",{
                     "quantity":Global.player.upgradeStatus.numHelped,
                     "quantityTotal":numTotal
                  });
               }
               else
               {
                  farmName = ZLocUtils.t("FarmGame","FarmName_" + Global.player.upgradeStatus.worldType);
                  if(this.m_cannotExpandTooltip[compId] == null)
                  {
                     this.m_cannotExpandTooltip[compId] = new ZLocToolTip();
                  }
                  this.m_cannotExpandTooltip[compId].attachToolTip(mc);
                  toolTipText = "";
                  if(farmName != "")
                  {
                     toolTipText = ZLocUtils.t("Dialogs","buildingExpansionInProgressFarm",{"world":farmName});
                  }
                  else
                  {
                     toolTipText = ZLocUtils.t("Dialogs","buildingExpansionInProgress");
                  }
                  this.m_cannotExpandTooltip[compId].toolTip = toolTipText;
                  this.m_cannotExpandTooltip[compId].show();
               }
            }
            Utilities.toggleInputAndChildren(m_tiles[compId],true);
         }
      }
      
      private function setItem(e:MouseEvent) : void
      {
         var compName:String = null;
         var compId:int = 0;
         var dataIndex:int = 0;
         if(e)
         {
            compName = e.target.parent.name;
            compId = parseInt(compName.charAt(compName.length - 1)) - 1;
            dataIndex = compId + m_tileSet * this.NUM_SLOTS;
            this.m_itemObject = m_data[dataIndex];
         }
      }
      
      private function onUse(event:MouseEvent) : void
      {
         var compName:String = event.target.parent.name;
         var compId:int = parseInt(compName.charAt(compName.length - 1)) - 1;
         var dataIndex:int = compId + m_tileSet * this.NUM_SLOTS;
         var object:Object = m_data[dataIndex];
         var itemKey:String = m_data.itemKey;
         var itemType:String = object.type;
         var name:String = object.name;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(name);
         var extraData:Object = new Object();
         if(Boolean(object) && object.hasOwnProperty("expansionLevel"))
         {
            extraData.expansionLevel = object.expansionLevel;
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
         farmItem.onUse(Global.worldManager.getCurrentWorldStorageId(),extraData);
         dispatchEvent(new MarketEvent(MarketEvent.MARKET_GIFT,MarketEvent.NONE));
         this.onCloseClick(event);
      }
      
      private function onSell(event:MouseEvent) : void
      {
         this.setItem(event);
         this.disableButtons();
         UI.displayMessage(ZLocUtils.t("FarmGame","SellObjectSpecific",{
            "item":ZLocUtils.tk_pk(this.m_itemObject.localizedName),
            "quantity":this.m_itemObject.sellPrice
         }),GenericPopup.TYPE_YESNO,this.sellHandler,"sellHandler",true);
      }
      
      public function launchUpgradeFeed(itemId:Number) : void
      {
         if(Global.player.upgradeStatus.isActive == false)
         {
            this.m_itemObject = new Object();
            this.m_itemObject.id = itemId;
            if(this.m_itemObject)
            {
               this.onUpgrade(null);
            }
         }
      }
      
      private function onUpgrade(event:MouseEvent) : void
      {
         this.disableButtons(true);
         var message:String = ZLocUtils.t("Dialogs","StorageUpgradeConfirmFeed");
         this.setItem(event);
         var cap:int = Global.farmGameSettingsManager.getAttribute("maxInventoryCapacity");
         var storageBuilding:StorageBuilding = Global.world.getObjectById(this.m_itemObject.id) as StorageBuilding;
         if(cap < Global.player.getInventoryCapacity() + this.getNumAdded() && storageBuilding.isInventoryBuilding())
         {
            message = ZLocUtils.t("Dialogs","CapacityOvershotExpand",{"quantity":cap});
            UI.displayMessage(message,GenericPopup.TYPE_SHARECANCEL,this.upgradeHandler,"",true);
         }
         else
         {
            UI.displayMessage(message,GenericPopup.TYPE_SHARECANCEL,this.upgradeHandler,"",true);
         }
      }
      
      private function upgradeHandler(event:GenericPopupEvent) : void
      {
         var storage:StorageBuilding = null;
         if(event.button == GenericPopup.YES)
         {
            storage = Global.world.getObjectById(this.m_itemObject.id) as StorageBuilding;
            TransactionManager.addTransaction(new TUpgradeStorage(storage,this,"upgrade",sendPostUpgradeFeed),true);
         }
         else
         {
            this.disableButtons(false);
         }
      }
      
      private function onPurchaseUpgrade(event:MouseEvent) : void
      {
         var storage:StorageBuilding = null;
         this.disableButtons(true);
         var numLeft:int = Global.farmGameSettingsManager.getInt("storageExpansionFriendRequirement",10);
         if(Global.player.upgradeStatus.isActive)
         {
            numLeft -= int(Global.player.upgradeStatus.numHelped);
         }
         storage = this.m_building;
         if(storage == null)
         {
            storage = Global.world.getObjectById(this.m_itemObject.id) as StorageBuilding;
         }
         var itemPurchased:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(storage.getItem().getExpansion());
         if(itemPurchased.name.indexOf("chickencoop") >= 0)
         {
            numLeft = itemPurchased.cash;
         }
         var message:String = ZLocUtils.t("Dialogs","StorageUpgradePurchaseConfirm",{"quantity":numLeft});
         this.setItem(event);
         var cap:int = Global.farmGameSettingsManager.getAttribute("maxInventoryCapacity");
         storage = Global.world.getObjectById(this.m_itemObject.id) as StorageBuilding;
         if(cap < Global.player.getInventoryCapacity() + this.getNumAdded() && storage.isInventoryBuilding())
         {
            message = ZLocUtils.t("Dialogs","CapacityOvershotBuy",{
               "quantity":cap,
               "coinQuantity":numLeft
            });
            UI.displayMessage(message,GenericPopup.TYPE_YESNO,this.purchaseUpgradeHandler,"",true);
         }
         else
         {
            UI.displayMessage(message,GenericPopup.TYPE_YESNO,this.purchaseUpgradeHandler,"",true);
         }
      }
      
      private function getNumAdded() : int
      {
         var storage:StorageBuilding = this.m_building;
         if(storage == null)
         {
            storage = Global.world.getObjectById(this.m_itemObject.id) as StorageBuilding;
         }
         var numAdded:int = Global.farmGameSettingsManager.getInt("storageUpgradeOnceBoost",5);
         var expansionSize:int = storage.getItem().storageSize;
         if(expansionSize != 1)
         {
            numAdded = Global.farmGameSettingsManager.getInt("storageUpgradeTwiceBoost",7);
         }
         return numAdded;
      }
      
      private function purchaseUpgradeHandler(event:GenericPopupEvent) : void
      {
         var storage:StorageBuilding = null;
         var itemPurchased:FarmItem = null;
         var expired:Boolean = Global.player.upgradeStatus.expires < GlobalEngine.serverTime / 1000;
         if(event.button == GenericPopup.YES)
         {
            if(Boolean(this.m_itemObject) && Boolean(this.m_itemObject.id))
            {
               storage = Global.world.getObjectById(this.m_itemObject.id) as StorageBuilding;
            }
            else
            {
               storage = this.m_building;
            }
            itemPurchased = Global.farmGameSettingsManager.getFarmItemByName(this.m_building.getItem().getExpansion());
            TransactionManager.addTransaction(new TUpgradeStorage(storage,this,"purchase"),true);
            if(Global.player.upgradeStatus.isActive)
            {
               if(expired)
               {
                  FarmStatsManager.sample(100,"Storage","Buy","OK","failed_expansion");
               }
               else
               {
                  FarmStatsManager.sample(100,"Storage","Buy","OK","in_progress");
               }
            }
            else
            {
               FarmStatsManager.sample(100,"Storage","Buy","OK","not_started");
            }
            storage.upgrade();
         }
         else
         {
            this.disableButtons(false);
            if(Global.player.upgradeStatus.isActive)
            {
               if(expired)
               {
                  FarmStatsManager.sample(100,"Storage","Buy","Cancel","failed_expansion");
               }
               else
               {
                  FarmStatsManager.sample(100,"Storage","Buy","Cancel","in_progress");
               }
            }
            else
            {
               FarmStatsManager.sample(100,"Storage","Buy","Cancel","not_started");
            }
         }
      }
      
      private function onCancelUpgrade(event:MouseEvent) : void
      {
         this.setItem(event);
         var message:String = ZLocUtils.t("Dialogs","StorageUpgradeCancelConfirm");
         UI.displayMessage(message,GenericPopup.TYPE_YESNO,this.cancelHandler,"",true);
      }
      
      private function cancelHandler(event:GenericPopupEvent) : void
      {
         var storage:StorageBuilding = null;
         if(event.button == GenericPopup.YES && Boolean(this.m_itemObject))
         {
            storage = Global.world.getObjectById(this.m_itemObject.id) as StorageBuilding;
            TransactionManager.addTransaction(new TUpgradeStorage(storage,this,"cancel"),true);
            this.disableButtons(true);
         }
      }
      
      private function onFailUpgrade() : void
      {
         var building:StorageBuilding = null;
         var numLeft:int = Global.farmGameSettingsManager.getInt("storageExpansionFriendRequirement",10) - Global.player.upgradeStatus.numHelped;
         var message:String = ZLocUtils.t("Dialogs","StorageUpgradeFailConfirm",{
            "quantity":Global.player.upgradeStatus.numHelped,
            "coinQuantity":numLeft
         });
         UI.displayMessage(message,GenericPopup.TYPE_YESNO,this.failHandler,"upgradeFail",true);
         if(Global.world.getObjectById(this.m_itemObject.id) as StorageBuilding)
         {
            building = Global.world.getObjectById(this.m_itemObject.id) as StorageBuilding;
            FarmStatsManager.count(building.getItemName() + "_expansion","expansionFail","expansion_" + building.storageLevel);
         }
      }
      
      private function failHandler(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.purchaseUpgradeHandler(event);
         }
         else
         {
            event.button = GenericPopup.YES;
            this.cancelHandler(event);
         }
      }
      
      public function onRepostFeed(itemId:Number = -1) : void
      {
         var timeLeft:String = null;
         if(itemId != -1)
         {
            this.m_itemObject = new Object();
            this.m_itemObject.id = itemId;
         }
         var status:Object = Global.player.upgradeStatus;
         var time:int = GlobalEngine.serverTime / 1000;
         var numLeft:int = Global.farmGameSettingsManager.getInt("storageExpansionFriendRequirement",10) - status.numHelped;
         if(status.expires - time < Global.farmGameSettingsManager.getInt("storageUpgradeRepostTime",43200))
         {
            timeLeft = ZLocUtils.t("Dialogs","StorageUpgradeHours",{"quantity":Math.ceil((status.expires - time) / 3600)});
         }
         else
         {
            timeLeft = ZLocUtils.t("Dialogs","StorageUpgradeDays",{"quantity":Math.ceil((status.expires - time) / 86400)});
         }
         var message:String = ZLocUtils.t("Dialogs","StorageUpgradeReminder",{
            "quantity":numLeft,
            "quantityTotal":timeLeft
         });
         UI.displayMessage(message,GenericPopup.TYPE_SHARECANCEL,this.postUpgradeFeed,"",true);
      }
      
      private function postUpgradeFeed(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.upgradeHandler(event);
            FarmStatsManager.sample(100,"Storage","Repost","click_share");
         }
         else
         {
            FarmStatsManager.sample(100,"Storage","Repost","click_cancel");
         }
      }
      
      override public function refreshLayout(force:Boolean = false) : void
      {
         var building:StorageBuilding = null;
         var idx:int = 0;
         var storageBuildings:Array = null;
         var storageBuilding:StorageBuilding = null;
         var capacity:int = 0;
         var status:Object = Global.player.upgradeStatus;
         var starBurst:Boolean = false;
         var time:int = GlobalEngine.serverTime / 1000;
         if(this.m_currentSection == "upgrade")
         {
            if(Boolean(status) && Boolean(status.isActive) && status.worldType == Global.worldManager.currentWorldType)
            {
               building = Global.world.getObjectById(status.buildingId) as StorageBuilding;
               if(building != null)
               {
                  if(status.numHelped >= Global.farmGameSettingsManager.getInt("storageExpansionFriendRequirement",10))
                  {
                     if(!status.alreadyUpgraded)
                     {
                        building.upgrade(this);
                     }
                     Global.player.upgradeStatus.alreadyUpgraded = false;
                     for(idx = 0; idx < m_data.length; idx++)
                     {
                        if(status.buildingId == m_data[idx].id)
                        {
                           this.m_burstLocation = idx % this.NUM_SLOTS;
                           break;
                        }
                     }
                  }
                  else if(status.expires < time)
                  {
                     this.m_itemObject = {};
                     this.m_itemObject.id = building.getId();
                     this.onFailUpgrade();
                  }
                  else if(status.lastClientUpdate - status.initialUpdateTs > Global.farmGameSettingsManager.getInt("storageUpgradeRepostTime",14400))
                  {
                     this.onRepostFeed();
                  }
               }
               else
               {
                  storageBuildings = Global.world.getObjectsByClass(StorageBuilding);
                  if(storageBuildings.length > 0)
                  {
                     storageBuilding = storageBuildings[0];
                  }
                  if(storageBuilding)
                  {
                     TransactionManager.addTransaction(new TUpgradeStorage(storageBuilding,this,"cancel"),true);
                  }
               }
            }
         }
         this.pushNewData();
         if(m_window)
         {
            super.refreshLayout(force);
            capacity = 0;
            if(this.m_building)
            {
               capacity = this.m_building.maxPotentialCapacity;
            }
            m_window.storage_mc.capacity_tf.text = ZLocUtils.t("Dialogs","Capacity",{"quantity":capacity});
            this.disableButtons(false);
         }
      }
      
      protected function onUpgradePostFeedPrompt(uidList:Array = null) : void
      {
         this.m_friendList = new Array();
         uidList = Global.player.upgradeStatus.helpers;
         var idx:int = 0;
         for(idx = 0; idx < uidList.length; idx++)
         {
            this.m_friendList.push(Global.friendManager.getFriendName(uidList[idx]));
         }
         var message:String = ZLocUtils.t("Dialogs","UpgradeSuccessThankyou",{"comma_separated_list_of_users":this.createListString(this.m_friendList,this.m_friendList.length)});
         UI.displayPopup(new GenericPopup(message,GenericPopup.TYPE_SHARECANCEL,this.goThankFriends,GenericPopup.GENERIC_ASSET_MED),false);
      }
      
      protected function createListString(strings:Array, total:int) : String
      {
         var newLength:int = 0;
         var validNameCount:int = 0;
         var needOthersString:Boolean = false;
         var listString:String = "";
         var stringIdx:uint = 0;
         if(strings.length > 0)
         {
            newLength = 0;
            validNameCount = 0;
            needOthersString = true;
            for(stringIdx = 0; stringIdx < strings.length; stringIdx++)
            {
               if(strings[stringIdx].length != 0)
               {
                  newLength = strings[stringIdx].length + listString.length;
                  if(newLength > this.MAX_FRIEND_LIST_LENGTH)
                  {
                     break;
                  }
                  if(newLength <= this.MAX_FRIEND_LIST_LENGTH && stringIdx == strings.length - 1 && strings.length > 1 && validNameCount == strings.length - 1)
                  {
                     listString += " " + ZLocUtils.t("Dialogs","FertilizeNotify_MessageAnd",{"users":strings[stringIdx]});
                     needOthersString = false;
                     break;
                  }
                  if(validNameCount > 0 && validNameCount < strings.length)
                  {
                     listString += ", ";
                  }
                  listString += strings[stringIdx];
                  validNameCount++;
               }
            }
            if(needOthersString)
            {
               if(strings.length == 1)
               {
                  listString = ZLocUtils.t("Dialogs","FertilizeNotify_MessageJustOne");
               }
               else if(validNameCount == 0)
               {
                  listString += " " + ZLocUtils.t("Dialogs","FertilizeNotify_MessageJustOthers",{"quantity":strings.length});
               }
               else if(strings.length - validNameCount == 1)
               {
                  listString += " " + ZLocUtils.t("Dialogs","FertilizeNotify_MessageOther",{"quantity":strings.length - validNameCount});
               }
               else
               {
                  listString += " " + ZLocUtils.t("Dialogs","FertilizeNotify_MessageOthers",{"quantity":strings.length - validNameCount});
               }
            }
         }
         return listString;
      }
      
      protected function goThankFriends(event:GenericPopupEvent) : void
      {
         var building:StorageBuilding = null;
         var url:String = null;
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            building = Global.world.getObjectById(Global.player.upgradeStatus.buildingId) as StorageBuilding;
            url = Global.getAssetURL("assets/newsfeed/storage_complete.png");
            if(building.getItem().getExpansionComplete() != "")
            {
               url = Global.getAssetURL("assets/newsfeed/" + building.getItem().getExpansionComplete() + ".png");
            }
            params = {
               "reward_link":Global.player.upgradeStatus.url,
               "friends":this.createListString(this.m_friendList,this.m_friendList.length),
               "images":[{
                  "src":url,
                  "href":"{SN_APP_URL}" + Global.player.upgradeStatus.url
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("StorageUpgradeThankyou" + building.getItem().getExpansionComplete(),params,[],false);
         }
         this.m_friendList = null;
      }
      
      private function disableButtons(disabled:Boolean = true) : void
      {
         var compIdx:int = 0;
         if(Boolean(m_window) && Boolean(m_window.storage_mc))
         {
            if(disabled)
            {
               m_window.storage_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
            }
            else
            {
               m_window.storage_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
            }
            if(m_window.storage_mc.arrowLt_bt)
            {
               m_window.storage_mc.arrowLt_bt.enabled = !disabled;
               Utilities.toggleInputOnlySelf(m_window.storage_mc.arrowLt_bt,!disabled);
            }
            if(m_window.storage_mc.arrowRt_bt)
            {
               m_window.storage_mc.arrowRt_bt.enabled = !disabled;
               Utilities.toggleInputOnlySelf(m_window.storage_mc.arrowRt_bt,!disabled);
            }
            compIdx = 0;
            while(compIdx < this.NUM_SLOTS && compIdx < m_data.length)
            {
               this.m_buttons[compIdx][0].toggleDisable(!disabled);
               this.m_buttons[compIdx][1].toggleDisable(!disabled);
               this.m_buttons[compIdx][2].toggleDisable(!disabled);
               this.m_buttons[compIdx][3].toggleDisable(!disabled);
               compIdx++;
            }
         }
      }
      
      protected function sellHandler(event:GenericPopupEvent) : void
      {
         var itemCode:String = null;
         var result:Boolean = event.button == GenericPopup.YES;
         if(result == true)
         {
            itemCode = this.m_itemObject.code;
            if(Boolean(this.m_itemObject.expansionLevel) && this.m_itemObject.expansionLevel > 1)
            {
               itemCode = itemCode + ":" + this.m_itemObject.expansionLevel;
            }
            TransactionManager.addTransaction(new TSellStoredItem(itemCode,false,this.onSold,Global.worldManager.getCurrentWorldStorageId()),true);
         }
         this.disableButtons(false);
      }
      
      private function onSold(e:Object) : void
      {
         var compIdx:int = 0;
         var itemCode:String = this.m_itemObject.code;
         if(Boolean(this.m_itemObject.expansionLevel) && this.m_itemObject.expansionLevel > 1)
         {
            itemCode = itemCode + ":" + this.m_itemObject.expansionLevel;
         }
         Global.player.removeInventoryItem(itemCode);
         FarmStatsManager.sample(100,"Storage","goods","sold");
         removeTiles();
         this.pushNewData();
         if(m_data.length == 0)
         {
            this.onCloseClick(new MouseEvent(MouseEvent.CLICK));
         }
         else
         {
            compIdx = 0;
            while(compIdx < this.NUM_SLOTS && compIdx < m_data.length)
            {
               this.addComponent(compIdx);
               compIdx++;
            }
         }
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         removeTiles(false);
         this.m_usedTypes = null;
         m_window.storage_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.storage_mc.arrowLt_bt.removeEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.storage_mc.arrowRt_bt.removeEventListener(MouseEvent.CLICK,onRtArrowClick);
         this.m_shippingLicenseSlotContainer.release();
         event.stopPropagation();
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
   }
}

