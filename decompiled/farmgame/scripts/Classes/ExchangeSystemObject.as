package Classes
{
   import Managers.FeatureOptionsManager;
   
   public class ExchangeSystemObject
   {
      
      private var m_traderName:String;
      
      private var m_itemNames:Array;
      
      private var m_endTimes:Array;
      
      private var m_unlockedArray:Array;
      
      private var m_expandPrices:Array;
      
      private var m_finishNowPrice:int;
      
      private var m_cookHours:int;
      
      private var m_ovenCount:int;
      
      private var m_unlockIncrements:int;
      
      private var m_exchangesMade:int;
      
      private var m_inputList:Object;
      
      private var m_queuedInputList:Object;
      
      private var m_selectedOutput:String = null;
      
      public function ExchangeSystemObject(exchangeGroupConfig:XML)
      {
         var exchanges:Array = null;
         var featureOptionMan:FeatureOptionsManager = null;
         var exchangeFeatureOptions:Object = null;
         var exchangeObject:Object = null;
         var ovensArray:Object = null;
         var index:int = 0;
         var oven:Object = null;
         var unlockedOven:String = null;
         var slotNum:int = 0;
         this.m_inputList = {};
         this.m_queuedInputList = {};
         super();
         this.m_itemNames = new Array();
         this.m_endTimes = new Array();
         this.m_unlockedArray = new Array();
         this.m_expandPrices = new Array();
         this.m_exchangesMade = 0;
         this.m_traderName = exchangeGroupConfig.@name;
         var expandPrice:int = int(exchangeGroupConfig.@expandPrice);
         this.m_finishNowPrice = exchangeGroupConfig.@finishNowPrice;
         this.m_cookHours = exchangeGroupConfig.@cookHours;
         this.m_ovenCount = exchangeGroupConfig.@ovens;
         this.m_unlockIncrements = exchangeGroupConfig.@exchangeIncrementForUnlock;
         if(Boolean(exchangeGroupConfig && expandPrice) && Boolean(this.m_finishNowPrice) && Boolean(this.m_cookHours))
         {
            exchanges = new Array();
            featureOptionMan = FeatureOptionsManager.getInstance();
            exchangeFeatureOptions = featureOptionMan.getFeatureOption(FeatureOptionsManager.EXCHANGE_MANAGER,FeatureOptionsManager.EXCHANGE_MANAGER);
            if(exchangeFeatureOptions != null && exchangeFeatureOptions[this.m_traderName] != null)
            {
               exchangeObject = exchangeFeatureOptions[this.m_traderName];
               if(exchangeObject.hasOwnProperty("exchangesMade"))
               {
                  this.m_exchangesMade = exchangeObject["exchangesMade"];
               }
               ovensArray = exchangeObject["ovens"];
               for(index = 0; index < this.m_ovenCount; index++)
               {
                  oven = ovensArray[index];
                  unlockedOven = "false";
                  if(Boolean(oven) && Boolean(oven.hasOwnProperty("unlocked")) && oven.unlocked == "true")
                  {
                     unlockedOven = "true";
                  }
                  this.m_unlockedArray[index] = unlockedOven;
                  this.m_expandPrices[index] = expandPrice;
                  if(Boolean(oven) && Boolean(oven.hasOwnProperty("itemCode")) && oven.itemCode != null)
                  {
                     this.m_itemNames[index] = Global.farmGameSettingsManager.getFarmItemNameByCode(oven.itemCode);
                     this.m_endTimes[index] = oven.endTime;
                  }
                  else
                  {
                     this.m_itemNames[index] = null;
                     this.m_endTimes[index] = null;
                  }
               }
            }
            else
            {
               if(exchangeFeatureOptions == null)
               {
                  exchangeFeatureOptions = new Object();
               }
               this.m_unlockedArray[0] = "true";
               this.m_expandPrices[0] = expandPrice;
               this.m_itemNames[0] = null;
               this.m_endTimes[0] = null;
               exchanges["ovens"] = [{
                  "itemName":null,
                  "unlocked":"true",
                  "slotNumber":0
               }];
               for(slotNum = 1; slotNum < this.m_ovenCount; slotNum++)
               {
                  exchanges.push({
                     "itemName":null,
                     "unlocked":"false",
                     "expandPrice":expandPrice,
                     "slotNumber":slotNum
                  });
                  this.m_unlockedArray[slotNum] = "false";
                  this.m_expandPrices[slotNum] = expandPrice;
                  this.m_itemNames[slotNum] = null;
                  this.m_endTimes[slotNum] = null;
               }
               exchangeFeatureOptions[this.m_traderName] = exchanges;
               featureOptionMan.setFeatureOption(FeatureOptionsManager.EXCHANGE_MANAGER,FeatureOptionsManager.EXCHANGE_MANAGER,exchangeFeatureOptions);
            }
         }
      }
      
      public function get traderName() : String
      {
         return this.m_traderName;
      }
      
      public function get finishNowPrice() : int
      {
         return this.m_finishNowPrice;
      }
      
      public function get cookHours() : int
      {
         return this.m_cookHours;
      }
      
      public function get ovenCount() : int
      {
         return this.m_ovenCount;
      }
      
      public function getUnlocked(ovenSlot:int) : String
      {
         return this.m_unlockedArray[ovenSlot];
      }
      
      public function canUnlock(ovenSlot:int) : Boolean
      {
         var unlockLen:int = 0;
         var index:int = 0;
         var result:Boolean = true;
         result = this.m_unlockedArray[ovenSlot] == "false";
         if(result)
         {
            unlockLen = int(this.m_unlockedArray.length);
            index = 0;
            while(result && index < unlockLen && index < ovenSlot)
            {
               result = this.m_unlockedArray[index] == "true";
               index++;
            }
         }
         return result;
      }
      
      public function hasAvailableSlot() : Boolean
      {
         var result:Boolean = false;
         var itemsLen:int = int(this.m_itemNames.length);
         for(var index:int = 0; index < itemsLen; index++)
         {
            if(this.m_unlockedArray[index] == "true" && (this.m_itemNames[index] == "" || this.m_itemNames[index] == null))
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      public function getExpandPrice(ovenSlot:int) : int
      {
         return this.m_expandPrices[ovenSlot];
      }
      
      public function getItemName(ovenSlot:int) : String
      {
         return this.m_itemNames[ovenSlot];
      }
      
      public function getEndTime(ovenSlot:int) : int
      {
         return this.m_endTimes[ovenSlot];
      }
      
      public function neededForUnlock(ovenSlot:int) : int
      {
         var result:int = -1;
         if(ovenSlot < this.m_ovenCount)
         {
            result = this.m_unlockIncrements * ovenSlot - this.m_exchangesMade;
         }
         return result;
      }
      
      public function incrementExchangesMade() : void
      {
         var slotUnlocked:int = 0;
         ++this.m_exchangesMade;
         if(this.m_exchangesMade % this.m_unlockIncrements == 0)
         {
            slotUnlocked = this.m_exchangesMade / this.m_unlockIncrements;
            if(slotUnlocked < this.m_ovenCount)
            {
               this.m_unlockedArray[this.m_exchangesMade / this.m_unlockIncrements] = "true";
            }
         }
      }
      
      public function setUnlocked(ovenSlot:int, unlocked:String) : void
      {
         this.m_unlockedArray[ovenSlot] = unlocked;
         var featureOptionMan:FeatureOptionsManager = FeatureOptionsManager.getInstance();
         var exchangeFeatureOptions:Object = featureOptionMan.getFeatureOption(FeatureOptionsManager.EXCHANGE_MANAGER,FeatureOptionsManager.EXCHANGE_MANAGER);
         if(exchangeFeatureOptions != null && exchangeFeatureOptions[this.m_traderName] != null)
         {
            if(!exchangeFeatureOptions[this.m_traderName].hasOwnProperty("ovens"))
            {
               exchangeFeatureOptions[this.m_traderName]["ovens"] = {};
            }
            if(!exchangeFeatureOptions[this.m_traderName]["ovens"].hasOwnProperty(ovenSlot))
            {
               exchangeFeatureOptions[this.m_traderName]["ovens"][ovenSlot] = {};
            }
            exchangeFeatureOptions[this.m_traderName]["ovens"][ovenSlot]["unlocked"] = "true";
            featureOptionMan.setFeatureOption(FeatureOptionsManager.EXCHANGE_MANAGER,FeatureOptionsManager.EXCHANGE_MANAGER,exchangeFeatureOptions);
         }
      }
      
      public function setExpandPrice(ovenSlot:int, expandPrice:int) : void
      {
         this.m_expandPrices[ovenSlot] = expandPrice;
      }
      
      public function setItemName(ovenSlot:int, itemName:String) : void
      {
         this.m_itemNames[ovenSlot] = itemName;
         var featureOptionMan:FeatureOptionsManager = FeatureOptionsManager.getInstance();
         var exchangeFeatureOptions:Object = featureOptionMan.getFeatureOption(FeatureOptionsManager.EXCHANGE_MANAGER,FeatureOptionsManager.EXCHANGE_MANAGER);
         if(exchangeFeatureOptions != null && exchangeFeatureOptions[this.m_traderName] != null)
         {
            if(!exchangeFeatureOptions[this.m_traderName].hasOwnProperty("ovens"))
            {
               exchangeFeatureOptions[this.m_traderName]["ovens"] = {};
            }
            if(!exchangeFeatureOptions[this.m_traderName]["ovens"].hasOwnProperty(ovenSlot))
            {
               exchangeFeatureOptions[this.m_traderName]["ovens"][ovenSlot] = {};
            }
            exchangeFeatureOptions[this.m_traderName]["ovens"][ovenSlot]["itemCode"] = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
            featureOptionMan.setFeatureOption(FeatureOptionsManager.EXCHANGE_MANAGER,FeatureOptionsManager.EXCHANGE_MANAGER,exchangeFeatureOptions);
         }
      }
      
      public function setEndTime(ovenSlot:int, endTime:int) : void
      {
         this.m_endTimes[ovenSlot] = endTime;
         var featureOptionMan:FeatureOptionsManager = FeatureOptionsManager.getInstance();
         var exchangeFeatureOptions:Object = featureOptionMan.getFeatureOption(FeatureOptionsManager.EXCHANGE_MANAGER,FeatureOptionsManager.EXCHANGE_MANAGER);
         if(exchangeFeatureOptions != null && exchangeFeatureOptions[this.m_traderName] != null)
         {
            if(!exchangeFeatureOptions[this.m_traderName].hasOwnProperty("ovens"))
            {
               exchangeFeatureOptions[this.m_traderName]["ovens"] = {};
            }
            if(!exchangeFeatureOptions[this.m_traderName]["ovens"].hasOwnProperty(ovenSlot))
            {
               exchangeFeatureOptions[this.m_traderName]["ovens"][ovenSlot] = {};
            }
            exchangeFeatureOptions[this.m_traderName]["ovens"][ovenSlot]["endTime"] = endTime;
            featureOptionMan.setFeatureOption(FeatureOptionsManager.EXCHANGE_MANAGER,FeatureOptionsManager.EXCHANGE_MANAGER,exchangeFeatureOptions);
         }
      }
      
      public function getInputCount() : int
      {
         var queuedInputCode:String = null;
         var inputCode:String = null;
         var result:int = 0;
         for(queuedInputCode in this.m_queuedInputList)
         {
            result += this.m_queuedInputList[queuedInputCode];
         }
         for(inputCode in this.m_inputList)
         {
            result += this.m_inputList[inputCode];
         }
         return result;
      }
      
      public function get inputList() : Object
      {
         return this.m_inputList;
      }
      
      public function get queuedInputs() : Object
      {
         return this.m_queuedInputList;
      }
      
      public function get selectedOutput() : String
      {
         return this.m_selectedOutput;
      }
      
      public function set selectedOutput(itemCode:String) : void
      {
         this.m_selectedOutput = itemCode;
      }
      
      public function addInputs(itemCode:String, quantity:int) : void
      {
         if(this.m_queuedInputList.hasOwnProperty(itemCode))
         {
            this.m_queuedInputList[itemCode] += quantity;
         }
         else
         {
            this.m_queuedInputList[itemCode] = quantity;
         }
      }
      
      public function clearAllInputs() : void
      {
         this.m_inputList = {};
         this.m_queuedInputList = {};
      }
      
      public function clearQueuedInputs() : void
      {
         this.m_queuedInputList = {};
      }
      
      public function confirmInputs() : void
      {
         var inputCode:String = null;
         for(inputCode in this.m_queuedInputList)
         {
            if(this.m_inputList.hasOwnProperty(inputCode))
            {
               this.m_inputList[inputCode] += this.m_queuedInputList[inputCode];
            }
            else
            {
               this.m_inputList[inputCode] = this.m_queuedInputList[inputCode];
            }
         }
         this.m_queuedInputList = {};
      }
   }
}

