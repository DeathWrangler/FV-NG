package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TAddMultipleCredits;
   import Transactions.TStoreItem;
   import Widgets.Windows.HolidayBasketWindows.RewardCreditsWindow;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class CreditsBuilding extends StorageBuilding
   {
      
      public static const SUM_CREDIT_TYPES:String = "CreditsBuilding_sumTickets";
      
      protected var m_levels:Array = new Array();
      
      protected var m_creditTypes:Array = new Array();
      
      protected var m_creditTypesOrdered:Array = new Array();
      
      protected var m_numCreditTypes:int = 1;
      
      protected var m_stateChangeLevels:Array = new Array();
      
      protected var m_meterStates:Array = [];
      
      protected var m_prevCreditsReceived:Object = new Object();
      
      protected var m_prevLevel:uint = 0;
      
      protected var m_creditsFeatureName:String = "";
      
      protected var m_creditsBuildingXml:XML;
      
      protected var m_meterCreditType:String = "feature";
      
      protected var m_displayDialogOnMeterBroken:Boolean = true;
      
      public function CreditsBuilding(buildingType:String = null, featureName:String = null)
      {
         super(buildingType);
         this.m_creditsFeatureName = featureName;
         this.m_creditsBuildingXml = Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_creditsFeatureName);
         this.populateCreditTypes();
         this.populateLevels();
         this.buildMeterStates();
      }
      
      public function get stateChangeLevels() : Array
      {
         return this.m_stateChangeLevels;
      }
      
      public function get numCreditTypes() : int
      {
         return this.m_numCreditTypes;
      }
      
      public function get creditTypes() : Array
      {
         var creditType:String = null;
         var result:Array = new Array();
         for(creditType in this.m_creditTypes)
         {
            result.push(creditType);
         }
         return result;
      }
      
      public function get meterStates() : Array
      {
         return this.m_meterStates;
      }
      
      public function buildMeterStates() : void
      {
         var creditsXml:XML = null;
         var levels:XMLList = null;
         var index:uint = 0;
         var stateChange:Boolean = false;
         var meterChange:Boolean = false;
         if(this.m_meterStates.length == 0)
         {
            creditsXml = Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_creditsFeatureName);
            if(Boolean(creditsXml) && Boolean(creditsXml.level))
            {
               levels = creditsXml.level;
               for(index = 0; index < levels.length(); index++)
               {
                  stateChange = Boolean(levels[index].creditsNeeded.@stateChange) && levels[index].creditsNeeded.@stateChange.toString() == "false";
                  meterChange = Boolean(levels[index].creditsNeeded.@forceMeter) && levels[index].creditsNeeded.@forceMeter.toString() == "true";
                  if(Boolean(levels[index].creditsNeeded) && (!stateChange || stateChange && meterChange))
                  {
                     this.m_meterStates.push(index);
                  }
               }
            }
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var sellMsg:String = null;
         var sellPK:String = null;
         var basketPK:String = null;
         var itemPK:String = null;
         var sellPopup:GenericPopup = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case REMOVEFROM_OBJECT:
                  this.onRemove();
                  super.onMenuClick(event);
                  break;
               case SELL_OBJECT:
                  sellMsg = "";
                  sellPK = RewardCreditsBuilding.getLocalizedKey(this.getCreditsFeatureName(),"SellConfirm");
                  basketPK = RewardCreditsBuilding.getBasketFriendlyName(this.getCreditsFeatureName());
                  itemPK = RewardCreditsBuilding.getCreditItemFriendlyName(this.getCreditsFeatureName());
                  if("" != sellPK)
                  {
                     if("" != basketPK && ZLocUtils.isObject(basketPK) && "" != itemPK && ZLocUtils.isObject(itemPK))
                     {
                        sellMsg = ZLocUtils.t_pk(sellPK,null,{
                           "basket":ZLocUtils.tk_pk(basketPK),
                           "item":ZLocUtils.tk_pk(itemPK)
                        });
                     }
                     else
                     {
                        sellMsg = ZLocUtils.t_pk(sellPK);
                     }
                  }
                  sellPopup = new GenericPopup(sellMsg,GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmSell);
                  sellPopup.setAcceptTextName("Sell");
                  UI.displayPopup(sellPopup);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function showMenu() : void
      {
         if(!isInventoryBuilding() || Global.player.getInventoryUsage() <= 0)
         {
            if(!m_isOffboarded)
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("Items","storage_remove"),
                  "action":REMOVEFROM_OBJECT
               });
            }
         }
         super.showMenu();
      }
      
      override public function getCurrentSuffix() : int
      {
         var levelInfo:Dictionary = null;
         var suffix:uint = 0;
         var totalCreditsReceived:Object = this.getMultiTypeCredits(true);
         for(var index:uint = 0; index < this.m_stateChangeLevels.length; index++)
         {
            levelInfo = this.m_levels[this.m_stateChangeLevels[index]];
            if(!this.hasReachedLevel(levelInfo["credits"],totalCreditsReceived))
            {
               break;
            }
            if(levelInfo["imageBuildState"] != null)
            {
               suffix = uint(levelInfo["imageBuildState"]);
            }
            else
            {
               suffix = index + 1;
            }
         }
         return suffix;
      }
      
      public function getNumTotalLevels() : int
      {
         return this.m_levels.length + 1;
      }
      
      public function getLevel() : int
      {
         var levelInfo:Dictionary = null;
         var level:int = 0;
         var totalCreditsReceived:Object = this.getMultiTypeCredits(true);
         for(var i:int = 0; i < this.m_levels.length; i++)
         {
            levelInfo = this.m_levels[i];
            if(!this.hasReachedLevel(levelInfo["credits"],totalCreditsReceived))
            {
               break;
            }
            level++;
         }
         return level;
      }
      
      public function hasReachedLevel(creditTypes:Object, currentCredits:Object) : Boolean
      {
         var creditType:String = null;
         var amountNeeded:int = 0;
         var creditToCheck:String = null;
         var hasReachedLevel:Boolean = true;
         var sumCredits:int = this.getCreditsSum(currentCredits);
         for(creditType in creditTypes)
         {
            amountNeeded = int(creditTypes[creditType]);
            creditToCheck = creditType == "feature" ? this.m_creditsFeatureName : creditType;
            if(creditToCheck == SUM_CREDIT_TYPES ? sumCredits < amountNeeded : !currentCredits[creditToCheck] || currentCredits[creditToCheck] < amountNeeded)
            {
               hasReachedLevel = false;
               break;
            }
         }
         return hasReachedLevel;
      }
      
      override public function addItem(resource:MapResource, fromStorage:int = 0, isGift:Boolean = false, sendStoreItem:Boolean = true, force:Boolean = false) : Boolean
      {
         var newLevel:int = 0;
         var levelString:String = null;
         var message:String = null;
         var success:Boolean = false;
         if(this.canTakeItem(resource,false))
         {
            if(resource is VirtualStorageDecoration)
            {
               if(shouldShowOverlayOnAdd())
               {
                  this.dispOverlay(getOverlayUrl());
               }
               if(sendStoreItem)
               {
                  TransactionManager.addTransaction(new TStoreItem(this,resource,fromStorage,resource.getId(),isGift));
               }
               resource.detach();
               this.m_prevCreditsReceived = this.getMultiTypeCredits(true);
               this.m_prevLevel = this.getLevel();
               this.addCreditsFromItem(resource.getItem());
               newLevel = this.getLevel();
               if(newLevel > this.m_prevLevel)
               {
                  levelString = newLevel.toString();
                  if(this.m_levels != null && newLevel == this.m_levels.length)
                  {
                     levelString = "finish";
                  }
                  FarmStatsManager.count(this.m_creditsFeatureName,"stage_complete",levelString,this.getCurrentCredits(SUM_CREDIT_TYPES).toString());
               }
               if(this.isSubcreditsTradePossible())
               {
                  message = ZLocUtils.t("Dialogs",this.getLocKeyPrefix() + "CanNowTrade");
                  UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onTradeNow);
               }
               reloadImage();
               success = true;
            }
            else
            {
               success = super.addItem(resource,fromStorage,isGift,sendStoreItem,force);
            }
         }
         return success;
      }
      
      override public function canTakeItem(item:MapResource, isMouseOver:Boolean = true) : Boolean
      {
         var canTake:Boolean = false;
         if(item is VirtualStorageDecoration)
         {
            canTake = true;
         }
         else
         {
            canTake = super.canTakeItem(item,isMouseOver);
         }
         return canTake;
      }
      
      override public function buildStatusMessage(messageData:Array) : String
      {
         if(messageData.length < 2)
         {
            return " ";
         }
         return ZLocUtils.t("FarmGame","Status_AddPart",{
            "quantity":messageData[0],
            "item":ZLocUtils.tk_pk(messageData[1])
         });
      }
      
      override protected function getOwnerToolTipText() : String
      {
         var totalCredits:uint = this.getTotalCreditsReceived();
         return ZLocUtils.t("Items",m_item.name + "_capacity",{"quantity":totalCredits});
      }
      
      public function addMultipleCredits(creditResource:VirtualStorageDecoration, creditCount:int = 1, isGift:Boolean = true) : Boolean
      {
         var message:String = null;
         FarmGame.cbTrace("User is adding multiple credits. Current giftbox version: " + Global.player.giftsVersion);
         var success:Boolean = false;
         if(this.canTakeCredits(creditResource,creditCount))
         {
            if(shouldShowOverlayOnAdd())
            {
               dispOverlay(getOverlayUrl());
            }
            TransactionManager.addTransaction(new TAddMultipleCredits(this,creditResource,creditCount,isGift));
            this.m_prevCreditsReceived = this.getMultiTypeCredits(true);
            this.m_prevLevel = this.getLevel();
            this.addCreditsFromItem(creditResource.getItem(),creditCount);
            if(this.isSubcreditsTradePossible())
            {
               message = ZLocUtils.t("Dialogs",this.getLocKeyPrefix() + "CanNowTrade");
               UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onTradeNow);
            }
            reloadImage();
            success = true;
         }
         return success;
      }
      
      public function canTakeCredits(credit:VirtualStorageDecoration, creditCount:int = 1) : Boolean
      {
         return true;
      }
      
      public function onAddMultipleCreditsComplete(result:Object) : void
      {
         FarmGame.cbTrace("[DEBUG] Adding multiple credits complete. Current giftbox version: " + Global.player.giftsVersion);
      }
      
      public function getCreditsFeatureName() : String
      {
         return this.m_creditsFeatureName;
      }
      
      protected function useGlobalCredits() : Boolean
      {
         return this.m_creditsBuildingXml != null && this.m_creditsBuildingXml.hasOwnProperty("@globalStorage") && Boolean(this.m_creditsBuildingXml.@globalStorage);
      }
      
      protected function useGlobalReceived() : Boolean
      {
         var toReturn:Boolean = true;
         if(Boolean(this.m_creditsBuildingXml != null) && Boolean(this.m_creditsBuildingXml.hasOwnProperty("@ignoreGlobalReceived")) && this.m_creditsBuildingXml.@ignoreGlobalReceived.toString() == "true")
         {
            toReturn = false;
         }
         return toReturn && this.useGlobalCredits();
      }
      
      public function getCurrentCredits(creditType:String = null) : uint
      {
         var result:uint = 0;
         if(creditType == null)
         {
            if(this.m_meterCreditType == "feature")
            {
               creditType = this.m_creditsFeatureName;
            }
            else
            {
               creditType = this.m_meterCreditType;
            }
         }
         if(creditType == SUM_CREDIT_TYPES)
         {
            result = uint(this.getCreditsSum(this.getMultiTypeCredits(false)));
         }
         else
         {
            result = uint(Global.player.getFeatureCredits(creditType,this.useGlobalReceived()));
         }
         return result;
      }
      
      public function getMultiTypeCredits(getTotal:Boolean) : Object
      {
         var creditType:String = null;
         var useGlobalCredits:Boolean = getTotal ? this.useGlobalReceived() : this.useGlobalCredits();
         var result:Object = {};
         if(this.m_numCreditTypes > 1)
         {
            if(getTotal)
            {
               for(creditType in this.m_creditTypes)
               {
                  result[creditType] = Global.player.getFeatureCreditsReceived(creditType,useGlobalCredits);
               }
            }
            else
            {
               for(creditType in this.m_creditTypes)
               {
                  result[creditType] = Global.player.getFeatureCredits(creditType,useGlobalCredits);
               }
            }
         }
         else if(getTotal)
         {
            result[this.m_creditsFeatureName] = Global.player.getFeatureCreditsReceived(this.m_creditsFeatureName,useGlobalCredits);
         }
         else
         {
            result[this.m_creditsFeatureName] = Global.player.getFeatureCredits(this.m_creditsFeatureName,useGlobalCredits);
         }
         return result;
      }
      
      public function getCurrentSubcredits(subcreditType:String) : uint
      {
         return Global.player.getFeatureCredits(subcreditType);
      }
      
      public function getTotalCreditsReceived(creditType:String = null) : uint
      {
         var result:uint = 0;
         if(creditType == null)
         {
            if(this.m_meterCreditType == "feature")
            {
               creditType = this.m_creditsFeatureName;
            }
            else
            {
               creditType = this.m_meterCreditType;
            }
         }
         if(creditType == SUM_CREDIT_TYPES)
         {
            result = uint(this.getCreditsSum(this.getMultiTypeCredits(true)));
         }
         else
         {
            result = uint(Global.player.getFeatureCreditsReceived(creditType,this.useGlobalReceived()));
         }
         return result;
      }
      
      protected function getCreditsSum(credits:Object) : int
      {
         var creditType:String = null;
         var sumCredits:int = 0;
         for(creditType in credits)
         {
            sumCredits += credits[creditType];
         }
         return sumCredits;
      }
      
      public function addCreditsFromItem(item:FarmItem, itemCount:int = 1) : void
      {
         var creditType:String = null;
         if(this.isSubcreditsItem(item))
         {
            Global.player.addFeatureCredits(item.subcreditsType,item.count * itemCount);
         }
         else
         {
            creditType = this.getCreditTypeFromItem(item);
            if(creditType)
            {
               Global.player.addFeatureCredits(creditType,item.count * itemCount);
            }
         }
         this.checkMeterBroken();
      }
      
      protected function getCreditTypeFromItem(item:FarmItem) : String
      {
         var result:String = null;
         var creditType:String = null;
         var items:Array = null;
         if(Boolean(this.m_creditTypes) && this.m_numCreditTypes > 1)
         {
            for(creditType in this.m_creditTypes)
            {
               items = this.m_creditTypes[creditType];
               if(items.indexOf(item.name) >= 0)
               {
                  result = creditType;
                  break;
               }
            }
         }
         else
         {
            result = this.m_creditsFeatureName;
         }
         return result;
      }
      
      public function addCredits(creditAmount:uint, creditType:String = null, window:RewardCreditsWindow = null) : void
      {
         if(creditType == null)
         {
            creditType = this.m_creditsFeatureName;
         }
         Global.player.addFeatureCredits(creditType,creditAmount);
         this.checkMeterBroken(window);
      }
      
      protected function checkMeterBroken(window:RewardCreditsWindow = null) : void
      {
         var hasBrokenTheMeterBefore:Boolean = Global.player.getSeenFlag(this.m_creditsBuildingXml.@name + "_BrokeMeter");
         var hasMeterBreak:Boolean = Boolean(this.m_creditsBuildingXml.@hasMeterBreak);
         var maxCredits:int = int(this.m_creditsBuildingXml.@meterMaxCredits);
         if(!hasBrokenTheMeterBefore && hasMeterBreak && maxCredits > 0 && this.getTotalCreditsReceived() >= maxCredits)
         {
            Global.player.setSeenFlag(this.m_creditsBuildingXml.@name + "_BrokeMeter");
            if(window)
            {
               window.refreshCreditsMeterAndText();
            }
            else if(this.m_displayDialogOnMeterBroken)
            {
               displayStorageDialog();
            }
         }
         var hasBrokenTheMeterBeforeSecondRelease:Boolean = Global.player.getSeenFlag(this.m_creditsBuildingXml.@name + "_BrokeMeter_BeforeSecondRelease");
         if(!hasBrokenTheMeterBeforeSecondRelease && !hasBrokenTheMeterBefore && !hasMeterBreak && maxCredits > 0 && this.getTotalCreditsReceived() >= maxCredits)
         {
            Global.player.setSeenFlag(getClassName() + "_BrokeMeter_BeforeSecondRelease");
            FarmStatsManager.count(this.m_creditsBuildingXml.@name,"brokeMeterBeforeSecondRelease");
         }
      }
      
      public function useCredits(numCredits:uint, creditType:String = null) : void
      {
         var useGlobablCredits:Boolean = false;
         if(Boolean(this.m_creditsBuildingXml != null) && Boolean(this.m_creditsBuildingXml.hasOwnProperty("@globalStorage")) && Boolean(this.m_creditsBuildingXml.@globalStorage))
         {
            useGlobablCredits = true;
         }
         if(creditType == null)
         {
            creditType = this.m_creditsFeatureName;
         }
         Global.player.useFeatureCredits(creditType,numCredits,useGlobablCredits);
      }
      
      public function getLevelCredits(creditType:String = null) : Array
      {
         if(creditType == null)
         {
            creditType = this.m_meterCreditType;
         }
         var levelCredits:Array = new Array();
         for(var index:int = 0; index < this.m_levels.length; index++)
         {
            levelCredits.push(this.m_levels[index]["credits"][creditType]);
         }
         return levelCredits;
      }
      
      public function getLevelSkipFeeds() : Array
      {
         var levelSkipFeeds:Array = new Array();
         for(var index:int = 0; index < this.m_levels.length; index++)
         {
            levelSkipFeeds.push(this.m_levels[index]["skipFeed "]);
         }
         return levelSkipFeeds;
      }
      
      protected function populateCreditTypes() : void
      {
         var creditTypes:XMLList = null;
         var i:int = 0;
         var creditTypeName:String = null;
         var items:XMLList = null;
         var itemsArray:Array = null;
         var j:int = 0;
         var creditsXml:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_creditsFeatureName);
         if(Boolean(creditsXml) && Boolean(creditsXml.creditType))
         {
            creditTypes = creditsXml.creditType;
            for(i = 0; i < creditTypes.length(); i++)
            {
               ++this.m_numCreditTypes;
               creditTypeName = creditTypes[i].@name;
               items = creditTypes[i].creditItem;
               itemsArray = new Array();
               for(j = 0; j < items.length(); j++)
               {
                  itemsArray.push(items[j].toString());
               }
               this.m_creditTypes[creditTypeName] = itemsArray;
               this.m_creditTypesOrdered.push(creditTypeName);
            }
         }
         else
         {
            this.m_numCreditTypes = 1;
         }
      }
      
      public function getCreditTypes() : Array
      {
         return this.m_creditTypesOrdered;
      }
      
      protected function populateLevels() : void
      {
         var levels:XMLList = null;
         var index:uint = 0;
         var dictionary:Dictionary = null;
         var creditsNeeded:Dictionary = null;
         var hasCredits:Boolean = false;
         var creditTypes:XMLList = null;
         var i:int = 0;
         var creditType:XML = null;
         var ticketType:String = null;
         var imageState:XMLList = null;
         var creditsXml:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_creditsFeatureName);
         if(Boolean(creditsXml) && Boolean(creditsXml.level))
         {
            levels = creditsXml.level;
            for(index = 0; index < levels.length(); index++)
            {
               dictionary = new Dictionary();
               creditsNeeded = new Dictionary();
               hasCredits = false;
               if("@creditsNeeded" in levels[index])
               {
                  creditsNeeded["feature"] = parseInt(levels[index].@creditsNeeded);
                  hasCredits = true;
               }
               else
               {
                  creditTypes = levels[index].creditsNeeded;
                  for(i = 0; i < creditTypes.length(); i++)
                  {
                     creditType = creditTypes[i];
                     if(Boolean(creditType.@sum) && creditType.@sum == "true")
                     {
                        ticketType = SUM_CREDIT_TYPES;
                     }
                     else
                     {
                        ticketType = String(creditType.@type);
                     }
                     creditsNeeded[ticketType] = parseInt(creditType.@amount);
                     if(i == 0)
                     {
                        this.m_meterCreditType = ticketType;
                     }
                     hasCredits = true;
                  }
               }
               dictionary["credits"] = creditsNeeded;
               if(hasCredits)
               {
                  if(Boolean(levels[index].@skipFeed) && levels[index].@skipFeed == "true")
                  {
                     dictionary["skipFeed "] = true;
                  }
                  else
                  {
                     dictionary["skipFeed "] = false;
                  }
                  if(Boolean(levels[index].@stateChange) && Boolean(levels[index].@stateChange == "false") || Boolean(levels[index].creditsNeeded.@stateChange) && Boolean(levels[index].creditsNeeded.@stateChange.toString() == "false"))
                  {
                     dictionary["stateChange "] = false;
                  }
                  else
                  {
                     dictionary["stateChange "] = true;
                     this.m_stateChangeLevels.push(index);
                  }
                  imageState = levels[index].@imageBuildState;
                  if(imageState.length() > 0)
                  {
                     dictionary["imageBuildState"] = parseInt(imageState[0]);
                  }
                  this.m_levels.push(dictionary);
               }
            }
         }
      }
      
      protected function onRemove() : void
      {
      }
      
      protected function onConfirmSell(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.sell();
         }
      }
      
      public function getLocKeyPrefix() : String
      {
         return this.m_creditsFeatureName + "_";
      }
      
      public function isSubcreditsItem(item:FarmItem) : Boolean
      {
         var subcreditsItems:XMLList = null;
         var index:uint = 0;
         var found:Boolean = false;
         var creditsXml:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_creditsFeatureName);
         if(Boolean(creditsXml) && Boolean(creditsXml.subcreditsItem))
         {
            subcreditsItems = creditsXml.subcreditsItem;
            for(index = 0; index < subcreditsItems.length(); index++)
            {
               if(subcreditsItems[index].@name == item.name)
               {
                  found = true;
                  break;
               }
            }
         }
         return found;
      }
      
      public function isSubcreditsTradePossible() : Boolean
      {
         var tradeAmountNeeded:int = 0;
         var index:uint = 0;
         var subcreditsItemXML:XML = null;
         var subcreditsItem:FarmItem = null;
         var currentAmount:int = 0;
         var isTradePossible:Boolean = true;
         var creditsXml:XML = Global.farmGameSettingsManager.getBuildingCreditsXml(this.m_creditsFeatureName);
         var subcreditsItemsXML:XMLList = new XMLList();
         if(creditsXml)
         {
            subcreditsItemsXML = creditsXml.child("subcreditsItem");
         }
         if(subcreditsItemsXML.length() > 0)
         {
            tradeAmountNeeded = Global.farmGameSettingsManager.getInt(this.m_creditsFeatureName + "TradeAmountNeeded",10);
            for(index = 0; index < subcreditsItemsXML.length(); index++)
            {
               subcreditsItemXML = subcreditsItemsXML[index];
               subcreditsItem = Global.farmGameSettingsManager.getFarmItemByName(subcreditsItemXML.@name.toString());
               currentAmount = int(this.getCurrentSubcredits(subcreditsItem.subcreditsType));
               if(currentAmount < tradeAmountNeeded)
               {
                  isTradePossible = false;
                  break;
               }
            }
         }
         else
         {
            isTradePossible = false;
         }
         return isTradePossible;
      }
      
      protected function onTradeNow(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            displayStorageDialog();
         }
      }
   }
}

