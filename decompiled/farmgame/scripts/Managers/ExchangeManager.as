package Managers
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.ExchangeSystemObject;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingInventoryStateV2;
   import Classes.crafting.MarketInventoryItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import Events.DynamicObjectEvent;
   import Managers.Crafting.CraftingManager;
   import Transactions.TransactionWithCallBack;
   import Widgets.Windows.ExchangeWindow;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class ExchangeManager extends EventDispatcher
   {
      
      public static const UPDATE_EVENT:String = "update";
      
      public static const STATS_COUNTER:String = "Trader";
      
      public static const TRADER_BUSHEL:String = "bushelTrader";
      
      public static const BUSHEL_BABY_SWAP:String = "bushelBabySwap";
      
      public static const ADD_STATE:String = "add";
      
      public static const SELECT_STATE:String = "select";
      
      private static var m_instance:ExchangeManager = null;
      
      private var m_itemListObject:Object = {};
      
      private var m_quantityList:Object = {};
      
      private var m_currentExchanges:Object = null;
      
      public function ExchangeManager()
      {
         super();
         if(m_instance != null)
         {
            throw new Error("Cannot call constructor directly - use getInstance() instead.");
         }
      }
      
      public static function getInstance() : ExchangeManager
      {
         if(null == m_instance)
         {
            m_instance = new ExchangeManager();
         }
         return m_instance;
      }
      
      public static function getExchangeGroupConfig(exchangeGroupName:String) : XML
      {
         var exchangeGroupConfigs:XMLList = null;
         var j:int = 0;
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML("exchangeManager");
         var exchangeGroupConfig:XML = null;
         if(feature)
         {
            exchangeGroupConfigs = feature["exchangeGroups"].exchangeGroup;
            if(exchangeGroupConfigs)
            {
               for(j = 0; j < exchangeGroupConfigs.length(); j++)
               {
                  if(exchangeGroupConfigs[j].@name == exchangeGroupName)
                  {
                     exchangeGroupConfig = exchangeGroupConfigs[j];
                     break;
                  }
               }
            }
         }
         return exchangeGroupConfig;
      }
      
      public function openWindow(traderName:String) : void
      {
         if(this.isInMainExperiment(traderName))
         {
            UI.displayPopup(new ExchangeWindow(traderName),true,traderName + "Exchange",true);
         }
      }
      
      public function isInMainExperiment(traderName:String) : Boolean
      {
         var result:Boolean = false;
         if(traderName == ExchangeManager.TRADER_BUSHEL)
         {
            result = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_BUSHEL_TRADER) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START;
         }
         return result;
      }
      
      public function getExchangeItems(traderName:String, state:String) : Array
      {
         var bushelArray:Dictionary = null;
         var eachItem:MarketInventoryItem = null;
         var underlyingItem:FarmItem = null;
         var possibleSwaps:Array = null;
         var blackListVar:String = null;
         var blackList:Array = null;
         var bushelCraftType:int = 0;
         var swapCandidate:FarmItem = null;
         var itemName:String = null;
         var result:Array = new Array();
         if(!this.m_itemListObject.hasOwnProperty(traderName))
         {
            this.m_itemListObject[traderName] = new Object();
         }
         if(state == ExchangeManager.ADD_STATE)
         {
            if(traderName == ExchangeManager.TRADER_BUSHEL)
            {
               if(!this.m_itemListObject[traderName].hasOwnProperty(state) || this.m_itemListObject[traderName][state] == null)
               {
                  Global.player.craftingState.inventoryState.marketStallItems = CraftingManager.getInstance().pruneCraftingInventory(Global.player.craftingState.inventoryState.marketStallItems);
                  bushelArray = Global.player.craftingState.inventoryState.marketStallItems;
                  for each(eachItem in bushelArray)
                  {
                     underlyingItem = eachItem.underlyingItem;
                     if(underlyingItem)
                     {
                        result.push(underlyingItem);
                        result.sort(ZCacheUtil.applyPartial(this.quantitySorting,this,[traderName]));
                        if(!this.m_quantityList.hasOwnProperty(ExchangeManager.TRADER_BUSHEL))
                        {
                           this.m_quantityList[ExchangeManager.TRADER_BUSHEL] = {};
                        }
                        this.m_quantityList[ExchangeManager.TRADER_BUSHEL][eachItem.itemCode] = eachItem.quantity;
                     }
                  }
                  this.m_itemListObject[ExchangeManager.TRADER_BUSHEL][state] = result;
               }
               else
               {
                  result = this.m_itemListObject[ExchangeManager.TRADER_BUSHEL][state];
               }
            }
         }
         else if(state == ExchangeManager.SELECT_STATE)
         {
            if(traderName == ExchangeManager.TRADER_BUSHEL)
            {
               if(!this.m_itemListObject[traderName].hasOwnProperty(state))
               {
                  possibleSwaps = Global.farmGameSettingsManager.getItemsByClassArray("CBushel");
                  blackListVar = Global.flashHotParams["BUSHEL_SWAP_BLACKLIST"] as String;
                  blackList = new Array();
                  if(blackListVar != null)
                  {
                     blackList = blackListVar.split(",");
                  }
                  bushelCraftType = 0;
                  for each(swapCandidate in possibleSwaps)
                  {
                     bushelCraftType = CraftingManager.getInstance().getCraftTypeofBushel(swapCandidate.code);
                     if(Boolean(swapCandidate) && Boolean(bushelCraftType != CraftingManager.BUSHEL_TYPE_LAB) && bushelCraftType != CraftingManager.BUSHEL_TYPE_VILLAGE)
                     {
                        itemName = swapCandidate.name;
                        if(blackList.indexOf(itemName) == -1)
                        {
                           result.push(swapCandidate);
                        }
                     }
                  }
                  result.sort(this.nameSorting);
                  this.m_itemListObject[ExchangeManager.TRADER_BUSHEL][state] = result;
               }
               else
               {
                  result = this.m_itemListObject[ExchangeManager.TRADER_BUSHEL][state];
               }
            }
         }
         return result;
      }
      
      private function quantitySorting(traderName:String, itemA:Object, itemB:Object) : int
      {
         var result:int = 0;
         var prevItem:FarmItem = itemA as FarmItem;
         var nextItem:FarmItem = itemB as FarmItem;
         var prevQuan:int = int(this.m_quantityList[traderName][prevItem.code]);
         var nextQuan:int = int(this.m_quantityList[traderName][nextItem.code]);
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
      
      private function nameSorting(itemA:Object, itemB:Object) : int
      {
         var result:int = 0;
         var prevItem:FarmItem = itemA as FarmItem;
         var nextItem:FarmItem = itemB as FarmItem;
         var prevName:String = prevItem.friendlyTitle;
         var nextName:String = nextItem.friendlyTitle;
         if(prevName > nextName)
         {
            result = 1;
         }
         else if(prevName < nextName)
         {
            result = -1;
         }
         return result;
      }
      
      public function getTradeInTotalNumberNeeded(traderName:String) : int
      {
         var result:int = 0;
         var exchangeGroupConfig:XML = getExchangeGroupConfig(traderName);
         if(exchangeGroupConfig)
         {
            result = int(exchangeGroupConfig.@quantityIn);
         }
         if(traderName == ExchangeManager.TRADER_BUSHEL && Global.flashHotParams.hasOwnProperty("BUSHEL_TRADE_NEEDED_TEMPRT"))
         {
            result = int(Global.flashHotParams["BUSHEL_TRADE_NEEDED_TEMPRT"]);
         }
         return result;
      }
      
      public function getTradeInNumberNeeded(traderName:String) : int
      {
         var result:int = this.getTradeInTotalNumberNeeded(traderName);
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         if(systemObject == null)
         {
            this.setUpCurrentExchanges(traderName);
            systemObject = this.getExchangeSystemObject(traderName);
         }
         return int(result - systemObject.getInputCount());
      }
      
      public function getExchangeSystemObject(traderName:String) : ExchangeSystemObject
      {
         if(this.m_currentExchanges == null || !this.m_currentExchanges.hasOwnProperty(traderName) || this.m_currentExchanges[traderName] == null)
         {
            this.setUpCurrentExchanges(traderName);
         }
         return this.m_currentExchanges[traderName] as ExchangeSystemObject;
      }
      
      public function isExchangeFinished(traderName:String, slotNumber:int) : Boolean
      {
         var exchangeObject:ExchangeSystemObject = null;
         var result:Boolean = false;
         if(this.m_currentExchanges.hasOwnProperty(traderName))
         {
            exchangeObject = this.getExchangeSystemObject(traderName);
            if(Number(exchangeObject.getEndTime(slotNumber)) <= GlobalEngine.serverTime / 1000)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function canClaim(traderName:String, slotNumber:int) : Boolean
      {
         var exchangeObject:ExchangeSystemObject = null;
         var tradeItemCode:String = null;
         var bushelType:int = 0;
         var inventoryState:CraftingInventoryStateV2 = null;
         var result:Boolean = true;
         if(traderName == ExchangeManager.TRADER_BUSHEL)
         {
            exchangeObject = this.getExchangeSystemObject(traderName);
            tradeItemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(exchangeObject.getItemName(slotNumber));
            bushelType = CraftingManager.getInstance().getCraftTypeofBushel(tradeItemCode);
            inventoryState = Global.player.craftingState.inventoryState;
            if(bushelType == CraftingManager.BUSHEL_TYPE_STALL && inventoryState.isFull)
            {
               result = false;
            }
            else if(bushelType == CraftingManager.BUSHEL_TYPE_SILO && inventoryState.isSiloFull)
            {
               result = false;
            }
            else if(bushelType == CraftingManager.BUSHEL_TYPE_UNSHARABLE && inventoryState.isUnsharableStorageFull)
            {
               result = false;
            }
         }
         return result;
      }
      
      public function getTimeLeftFriendlyText(traderName:String, slotNumber:int) : String
      {
         var exchangeObject:ExchangeSystemObject = null;
         var endTime:Number = NaN;
         var currTime:Number = NaN;
         var timeLeft:Number = NaN;
         var hours:int = 0;
         var minutes:int = 0;
         var result:String = null;
         if(this.m_currentExchanges.hasOwnProperty(traderName))
         {
            exchangeObject = this.getExchangeSystemObject(traderName);
            endTime = Number(exchangeObject.getEndTime(slotNumber));
            currTime = GlobalEngine.serverTime / 1000;
            if(endTime > currTime)
            {
               timeLeft = endTime - currTime;
               hours = int(timeLeft / FarmGameUtil.NUM_SECS_IN_HOUR);
               minutes = int((timeLeft - hours * FarmGameUtil.NUM_SECS_IN_HOUR) / FarmGameUtil.NUM_SECS_IN_MINUTE);
               result = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeTimeLeft",{
                  "Hours":hours,
                  "Minutes":minutes
               });
            }
         }
         return result;
      }
      
      public function setUpCurrentExchanges(traderName:String) : void
      {
         if(this.m_currentExchanges == null)
         {
            this.m_currentExchanges = new Object();
         }
         var exchangeGroupConfig:XML = getExchangeGroupConfig(traderName);
         this.m_currentExchanges[traderName] = new ExchangeSystemObject(exchangeGroupConfig);
      }
      
      public function windowClosed(traderName:String) : void
      {
         this.m_currentExchanges[traderName] = null;
         this.m_quantityList[traderName] = {};
         this.m_itemListObject[traderName] = {};
      }
      
      public function getQuantityOwned(traderName:String, itemCode:String) : int
      {
         var result:int = 0;
         if(this.m_quantityList.hasOwnProperty(traderName) && Boolean(this.m_quantityList[traderName].hasOwnProperty(itemCode)))
         {
            result = int(this.m_quantityList[traderName][itemCode]);
         }
         return result;
      }
      
      public function isThisItemSelected(traderName:String, itemName:String) : Boolean
      {
         return Global.farmGameSettingsManager.getFarmItemCodeByName(itemName) == this.getExchangeSystemObject(traderName).selectedOutput;
      }
      
      public function getOutputItem(traderName:String) : String
      {
         return Global.farmGameSettingsManager.getFarmItemNameByCode(this.getExchangeSystemObject(traderName).selectedOutput);
      }
      
      public function selectOutputItem(traderName:String, itemName:String) : void
      {
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         systemObject.selectedOutput = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         this.m_currentExchanges[traderName] = systemObject;
         this.dispatchEvent(new DynamicObjectEvent(ExchangeManager.UPDATE_EVENT));
      }
      
      public function startTrade(traderName:String) : void
      {
         var inSlotItemName:String = null;
         var inputList:Object = null;
         var selectedOutput:String = null;
         var bushelArray:Dictionary = null;
         var eachItem:MarketInventoryItem = null;
         var inventoryItem:FarmItem = null;
         var quantityRemoved:int = 0;
         var slot:int = -1;
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         var ovenCount:int = systemObject.ovenCount;
         for(var index:int = 0; index < ovenCount; index++)
         {
            inSlotItemName = systemObject.getItemName(index);
            if((inSlotItemName == null || inSlotItemName == "") && systemObject.getUnlocked(index) == "true")
            {
               slot = index;
               break;
            }
         }
         if(slot != -1)
         {
            inputList = systemObject.inputList;
            selectedOutput = systemObject.selectedOutput;
            TransactionManager.addTransaction(new TransactionWithCallBack("ExchangeService.beginExchange",null,traderName,inputList,selectedOutput,slot),true);
            if(traderName == ExchangeManager.TRADER_BUSHEL)
            {
               bushelArray = Global.player.craftingState.inventoryState.marketStallItems;
               for each(eachItem in bushelArray)
               {
                  inventoryItem = eachItem.underlyingItem;
                  if(inventoryItem)
                  {
                     if(inputList[inventoryItem.code])
                     {
                        quantityRemoved = int(inputList[inventoryItem.code]);
                        CraftingManager.getInstance().deductItemFromCraftingInventory(inventoryItem.code,quantityRemoved);
                     }
                  }
               }
            }
            systemObject.setItemName(slot,Global.farmGameSettingsManager.getFarmItemNameByCode(selectedOutput));
            systemObject.setEndTime(slot,GlobalEngine.serverTime / 1000 + systemObject.cookHours * FarmGameUtil.NUM_SECS_IN_HOUR);
            systemObject.clearAllInputs();
            this.m_currentExchanges[traderName] = systemObject;
            this.m_itemListObject[traderName][ExchangeManager.ADD_STATE] = null;
         }
      }
      
      public function getOvenCount(traderName:String) : int
      {
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         if(systemObject == null)
         {
            this.setUpCurrentExchanges(traderName);
         }
         return systemObject.ovenCount;
      }
      
      public function unlockExchangeSlot(traderName:String, slotNumber:int) : void
      {
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         var expandPrice:int = systemObject.getExpandPrice(slotNumber);
         if(Global.player.canBuyCash(expandPrice) && systemObject.getUnlocked(slotNumber) != "true")
         {
            TransactionManager.addTransaction(new TransactionWithCallBack("ExchangeService.unlockExchangeSlot",null,traderName,slotNumber),true);
            systemObject.setUnlocked(slotNumber,"true");
            this.m_currentExchanges[traderName] = systemObject;
            Global.player.cash -= expandPrice;
         }
      }
      
      public function instantFinishExchange(traderName:String, slotNumber:int) : void
      {
         var finishCost:int = this.getFinishCost(traderName);
         if(Global.player.canBuyCash(finishCost) && this.claimHelper(traderName,slotNumber,new TransactionWithCallBack("ExchangeService.instantFinishExchange",null,traderName,slotNumber)))
         {
            Global.player.cash -= finishCost;
         }
      }
      
      public function claimExchange(traderName:String, slotNumber:int) : void
      {
         if(this.isExchangeFinished(traderName,slotNumber))
         {
            this.claimHelper(traderName,slotNumber,new TransactionWithCallBack("ExchangeService.claimFinishedExchange",null,traderName,slotNumber));
         }
      }
      
      private function claimHelper(traderName:String, slotNumber:int, transaction:Transaction) : Boolean
      {
         var status:String = null;
         var tweenDuration:Number = NaN;
         var tweenDisplacement:int = 0;
         var iconUrl:String = null;
         var iconFilters:Array = null;
         var result:Boolean = true;
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         var itemClaimed:String = systemObject.getItemName(slotNumber);
         var claimedItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemClaimed);
         var farmItemClaimed:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemClaimed);
         TransactionManager.addTransaction(transaction,true);
         systemObject.setItemName(slotNumber,null);
         systemObject.incrementExchangesMade();
         this.m_currentExchanges[traderName] = systemObject;
         if(farmItemClaimed.className == "CBushel")
         {
            CraftingManager.getInstance().addItemToInventory(claimedItem.code,1);
            status = ZLocUtils.t("Crafting","General_BushelFound",{"item":claimedItem.friendlyTitle});
            tweenDuration = UI.DEFAULT_STATUS_TWEEN_DURATION;
            tweenDisplacement = UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT;
            iconUrl = claimedItem.icon;
            iconFilters = null;
            Global.player.avatar.displayStatus(status,iconUrl,iconFilters,tweenDuration,tweenDisplacement);
         }
         else
         {
            Global.player.addGift(itemClaimed);
         }
         this.dispatchEvent(new DynamicObjectEvent(ExchangeManager.UPDATE_EVENT));
         return result;
      }
      
      public function getFinishCost(traderName:String) : int
      {
         return this.getExchangeSystemObject(traderName).finishNowPrice;
      }
      
      public function getExpandCost(traderName:String, slotNumber:int) : int
      {
         return this.getExchangeSystemObject(traderName).getExpandPrice(slotNumber);
      }
      
      public function addInputItem(traderName:String, itemName:String, quantity:int) : void
      {
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         systemObject.addInputs(itemCode,quantity);
         this.m_currentExchanges[traderName] = systemObject;
         this.m_quantityList[traderName][itemCode] -= quantity;
      }
      
      public function resetInputItems(traderName:String) : void
      {
         var inputCode:String = null;
         var queuedInputCode:String = null;
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         var inputList:Object = systemObject.inputList;
         var queuedInputs:Object = systemObject.queuedInputs;
         for(inputCode in inputList)
         {
            this.m_quantityList[traderName][inputCode] += inputList[inputCode];
         }
         for(queuedInputCode in queuedInputs)
         {
            this.m_quantityList[traderName][queuedInputCode] += queuedInputs[queuedInputCode];
         }
         systemObject.clearAllInputs();
         this.m_currentExchanges[traderName] = systemObject;
         this.dispatchEvent(new DynamicObjectEvent(ExchangeManager.UPDATE_EVENT));
      }
      
      public function confirmInputs(traderName:String) : void
      {
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         systemObject.confirmInputs();
         this.m_currentExchanges[traderName] = systemObject;
         this.dispatchEvent(new DynamicObjectEvent(ExchangeManager.UPDATE_EVENT));
      }
      
      public function revertInputs(traderName:String) : void
      {
         var inputCode:String = null;
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         var queuedInputs:Object = systemObject.queuedInputs;
         for(inputCode in queuedInputs)
         {
            this.m_quantityList[traderName][inputCode] += queuedInputs[inputCode];
         }
         systemObject.clearQueuedInputs();
         this.m_currentExchanges[traderName] = systemObject;
         this.dispatchEvent(new DynamicObjectEvent(ExchangeManager.UPDATE_EVENT));
      }
      
      public function instantOneToOneExchange(traderName:String, inputList:Object, finalItemCode:String) : Boolean
      {
         var inSlotItemName:String = null;
         var finalItemCount:int = 0;
         var itemCode:String = null;
         var result:Boolean = false;
         var slot:int = -1;
         var systemObject:ExchangeSystemObject = this.getExchangeSystemObject(traderName);
         var ovenCount:int = systemObject.ovenCount;
         for(var index:int = 0; index < ovenCount; index++)
         {
            inSlotItemName = systemObject.getItemName(index);
            if((inSlotItemName == null || inSlotItemName == "") && (systemObject.getUnlocked(index) == null || systemObject.getUnlocked(index) == "true"))
            {
               slot = index;
               break;
            }
         }
         if(slot == -1)
         {
            UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs","CraftshopRecipeSlot_slotFull"),GenericPopup.TYPE_OK),false);
            result = false;
         }
         else
         {
            TransactionManager.addTransaction(new TransactionWithCallBack("ExchangeService.instantOneToOneExchange",null,traderName,inputList,finalItemCode,slot),false);
            finalItemCount = 0;
            for(itemCode in inputList)
            {
               CraftingManager.getInstance().deductItemFromCraftingInventory(itemCode,inputList[itemCode]);
               finalItemCount += inputList[itemCode];
            }
            CraftingManager.getInstance().addItemToInventory(finalItemCode,finalItemCount);
            result = true;
         }
         return result;
      }
   }
}

