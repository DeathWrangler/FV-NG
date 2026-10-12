package Managers.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.MarketInventoryItem;
   import Classes.crafting.RecipeItem;
   import Classes.crafting.ShoppingState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetMarketView;
   import Transactions.TGetUserMarketStallInventory;
   import Widgets.Windows.Crafting.GenericCraftingPopup;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class MarketViewManager extends EventDispatcher
   {
      
      private static var m_Instance:MarketViewManager;
      
      public static const MARKET_STALL_INVENTORY_LOADED:String = "marketViewDataLoaded";
      
      private var m_MarketView:MarketView;
      
      private var m_newCraftingSkills:Dictionary;
      
      protected var m_popup:GenericCraftingPopup = null;
      
      protected var m_popupCount:uint = 0;
      
      protected var m_cachedSmartBushelItems:Array;
      
      public function MarketViewManager()
      {
         super();
         this.m_MarketView = new MarketView();
      }
      
      public static function getInstance() : MarketViewManager
      {
         if(m_Instance == null)
         {
            m_Instance = new MarketViewManager();
         }
         return m_Instance;
      }
      
      public function isStale() : Boolean
      {
         return this.getViewAge() > CraftingConstants.MAX_GLOBAL_REFRESH_SECONDS;
      }
      
      public function getViewAge() : Number
      {
         var serverTime:Number = Math.floor(GlobalEngine.serverTime / 1000);
         return Math.max(0,serverTime - this.m_MarketView.lastUpdated);
      }
      
      public function updateViewFromResponse(response:Object) : void
      {
         var marketView:Object = null;
         var compressedResponse:String = null;
         this.m_MarketView = new MarketView();
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_MARKET_VIEW_OOM) == 1)
         {
            compressedResponse = response as String;
            if(compressedResponse != null)
            {
               marketView = FarmGameUtil.JSONDecode(compressedResponse,"MarketViewManager_updateViewFromResponse");
            }
            else
            {
               marketView = response;
            }
         }
         else
         {
            marketView = response;
         }
         this.m_MarketView.lastUpdated = marketView.hasOwnProperty("lastUpdated") ? Number(marketView.lastUpdated) : 0;
         if(marketView)
         {
            this.loadMarketStallData(marketView);
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MARKET_VIEW_CRAFTGOODS_CROP) == 2)
            {
               this.loadNewCraftedSkillState();
            }
            else
            {
               this.loadCraftedSkillState(marketView);
            }
            this.loadCraftedGoodState(marketView);
            this.loadTimeStamps(marketView);
         }
         if(SmartBushelHelper.inExperiment() && Boolean(this.m_cachedSmartBushelItems))
         {
            this.insertSmartBushels(this.m_cachedSmartBushelItems);
         }
      }
      
      private function loadMarketStallData(response:Object) : void
      {
         var offering:Object = null;
         var offeredBy:String = null;
         for(var i:int = 0; i < response.marketStalls.length; i++)
         {
            offering = response.marketStalls[i];
            offeredBy = offering.uid;
            this.m_MarketView.marketStallInventory[offeredBy] = MarketStallOffering.loadFromServerObject(offering);
         }
         dispatchEvent(new Event(MARKET_STALL_INVENTORY_LOADED));
      }
      
      private function loadCraftedGoodState(response:Object) : void
      {
         var offering:Object = null;
         var offeredBy:String = null;
         var userCraftedGoodInfo:CraftedGoodOffering = null;
         Global.farmTimingModule.start("loadCraftedGoodState");
         for(var userIter:int = 0; userIter < response.craftedGoods.length; userIter++)
         {
            offering = response.craftedGoods[userIter];
            offeredBy = offering.uid;
            this.m_MarketView.craftedGoodInventory[offeredBy] = CraftedGoodOffering.loadFromServerObject(offering);
            userCraftedGoodInfo = this.m_MarketView.craftedGoodInventory[offeredBy];
            userCraftedGoodInfo.removeGoodsOfCraftType("craftshop");
         }
         Global.farmTimingModule.end("loadCraftedGoodState");
      }
      
      private function loadCraftedSkillState(response:Object) : void
      {
         var skill:Object = null;
         var owner:String = null;
         for(var i:int = 0; i < response.craftingSkills.length; i++)
         {
            skill = response.craftingSkills[i];
            owner = skill.uid;
            this.m_MarketView.craftingSkills[owner] = CraftingSkillSummary.loadFromServerObject(skill);
         }
      }
      
      private function loadNewCraftedSkillState() : void
      {
         if(this.m_MarketView)
         {
            this.m_MarketView.craftingSkills = this.m_newCraftingSkills;
         }
      }
      
      public function updateCraftSkillState(response:Object) : void
      {
         var i:int = 0;
         var skill:Object = null;
         var owner:String = null;
         if(Boolean(response) && response.length > 0)
         {
            this.m_newCraftingSkills = new Dictionary();
            for(i = 0; i < response.length; i++)
            {
               skill = response[i];
               owner = skill.uid;
               this.m_newCraftingSkills[owner] = CraftingSkillSummary.loadFromServerObject(skill);
            }
         }
      }
      
      public function getNumberOfFriendsWithCraftType(craftType:String) : int
      {
         var owner:String = null;
         var skillState:CraftingSkillSummary = null;
         var result:int = 0;
         for(owner in this.m_MarketView.craftingSkills)
         {
            skillState = this.m_MarketView.craftingSkills[owner];
            if(skillState.isActiveParticipantInSkill(craftType))
            {
               result++;
            }
         }
         return result;
      }
      
      private function loadTimeStamps(response:Object) : void
      {
         var thisAge:Object = null;
         var owner:String = null;
         for(var i:int = 0; i < response.ages.length; i++)
         {
            thisAge = response.ages[i];
            owner = thisAge.uid;
            this.m_MarketView.timestampDictionary[owner] = thisAge.lastUpdated;
         }
      }
      
      public function updateSingleMarketStallViewFromResponse(response:Object) : void
      {
         var offering:Object = null;
         var offeredBy:String = null;
         if(response != null && response.uid != null && response.inventory != null)
         {
            offering = response;
            offeredBy = offering.uid;
            this.m_MarketView.marketStallInventory[offeredBy] = MarketStallOffering.loadFromServerObject(offering);
            this.m_MarketView.timestampDictionary[offeredBy] = offering.lastUpdated;
         }
      }
      
      public function getRecipeSkillLevelForUser(userId:String, recipeId:String) : int
      {
         var result:int = 0;
         if(Boolean(this.m_MarketView) && this.m_MarketView.craftingSkills[userId] != null)
         {
            result = (this.m_MarketView.craftingSkills[userId] as CraftingSkillSummary).getLevelForRecipeId(recipeId);
         }
         return result;
      }
      
      public function getAllBushelsAvailable() : Array
      {
         var offering:MarketStallOffering = null;
         var result:Array = null;
         var bushel:FarmItem = null;
         var items:Array = null;
         var i:int = 0;
         var itemOffered:MarketInventoryItem = null;
         var found:Dictionary = new Dictionary();
         for each(offering in this.m_MarketView.marketStallInventory)
         {
            if(offering.hasValidUser)
            {
               items = offering.inventory;
               for(i = 0; i < items.length; i++)
               {
                  itemOffered = items[i];
                  if(!itemOffered.hasExpired() && found[itemOffered.itemCode] == null)
                  {
                     found[itemOffered.itemCode] = Global.farmGameSettingsManager.getFarmItemByCode(itemOffered.itemCode);
                  }
               }
            }
         }
         result = new Array();
         for each(bushel in found)
         {
            result.push(bushel);
         }
         return result;
      }
      
      public function getAllBushelCodesAvailable(bushelCode:String = null) : Array
      {
         var offering:MarketStallOffering = null;
         var result:Array = null;
         var itemCode:String = null;
         var items:Array = null;
         var i:int = 0;
         var itemOffered:MarketInventoryItem = null;
         var found:Dictionary = new Dictionary();
         for each(offering in this.m_MarketView.marketStallInventory)
         {
            if(offering.hasValidUser)
            {
               items = offering.inventory;
               for(i = 0; i < items.length; i++)
               {
                  itemOffered = items[i];
                  if(!itemOffered.hasExpired())
                  {
                     found[itemOffered.itemCode] = 1;
                  }
               }
            }
         }
         result = new Array();
         for(itemCode in found)
         {
            if(bushelCode == null || itemCode == bushelCode)
            {
               result.push(itemCode);
            }
         }
         return result;
      }
      
      public function getBestCraftedGoodInfoByUser() : Array
      {
         var uid:String = null;
         var offering:CraftedGoodOffering = null;
         var userCraftingInfo:Dictionary = null;
         var items:Array = null;
         var maxItemOffered:MarketInventoryItem = null;
         var i:int = 0;
         var itemOffered:MarketInventoryItem = null;
         var found:Array = [];
         for(uid in this.m_MarketView.craftedGoodInventory)
         {
            offering = this.m_MarketView.craftedGoodInventory[uid];
            if(Boolean(offering.hasValidUser) && Boolean(offering.inventory) && offering.inventory.length > 0)
            {
               userCraftingInfo = new Dictionary();
               items = offering.inventory;
               maxItemOffered = null;
               for(i = 0; i < items.length; i++)
               {
                  itemOffered = items[i] as MarketInventoryItem;
                  if(itemOffered != null)
                  {
                     if(maxItemOffered == null || itemOffered.level > maxItemOffered.level && itemOffered.quantity > 0)
                     {
                        maxItemOffered = itemOffered;
                     }
                  }
               }
               if(maxItemOffered != null && Number(maxItemOffered.level) > 0)
               {
                  userCraftingInfo["uid"] = uid;
                  userCraftingInfo["price"] = maxItemOffered.price;
                  userCraftingInfo["level"] = Number(maxItemOffered.level);
                  userCraftingInfo["quantity"] = maxItemOffered.quantity;
                  userCraftingInfo["bestItem"] = maxItemOffered;
                  userCraftingInfo["inventory"] = this.sortMarketInventoryItemsLevelAscending(offering.inventory);
                  userCraftingInfo["timeToBags"] = CraftingManager.getInstance().timeToNextPurchaseFromUser(uid);
                  found.push(userCraftingInfo);
               }
            }
         }
         return this.sortLevelDecending(found);
      }
      
      private function sortMarketInventoryItemsLevelAscending(arrayIn:Array) : Array
      {
         var itemA:MarketInventoryItem = null;
         var itemB:MarketInventoryItem = null;
         var recipeLevelA:int = 0;
         var recipeLevelb:int = 0;
         var i:int = 0;
         var arrayOut:Array = [];
         for each(itemA in arrayIn)
         {
            if(arrayOut.length == 0)
            {
               arrayOut.push(itemA);
            }
            else
            {
               for(i = 0; i < arrayOut.length; i++)
               {
                  itemB = arrayOut[i];
                  if(itemA["level"] < itemB["level"])
                  {
                     arrayOut.splice(i,0,itemA);
                     break;
                  }
                  if(i == arrayOut.length - 1)
                  {
                     arrayOut.push(itemA);
                     break;
                  }
               }
            }
         }
         return arrayOut;
      }
      
      public function getFriendsWithCraftedGoodsAvailable() : Array
      {
         var uid:String = null;
         var offering:CraftedGoodOffering = null;
         var uids:Array = new Array();
         for(uid in this.m_MarketView.craftedGoodInventory)
         {
            offering = this.m_MarketView.craftedGoodInventory[uid];
            if(Boolean(offering.hasValidUser) && Boolean(offering.inventory) && offering.inventory.length > 0)
            {
               if(CraftingManager.getInstance().timeToNextPurchaseFromUser(uid) == 0)
               {
                  uids.push(uid);
               }
            }
         }
         return uids;
      }
      
      public function getNumFriendsWithCraftedGoodsAvailable() : int
      {
         var numGoods:int = int(this.getFriendsWithCraftedGoodsAvailable().length);
         var shoppingState:ShoppingState = Global.player.craftingState.shoppingState;
         var purchasesLeft:int = shoppingState.maxCraftingPurchasesPerDay - shoppingState.getTotalDailyCraftingPurchases();
         return Math.max(Math.min(numGoods,purchasesLeft),0);
      }
      
      public function getAllCraftedGoodsAvailable() : Array
      {
         var offering:CraftedGoodOffering = null;
         var result:Array = null;
         var itemCode:String = null;
         var items:Array = null;
         var i:int = 0;
         var itemOffered:MarketInventoryItem = null;
         var found:Dictionary = new Dictionary();
         for each(offering in this.m_MarketView.craftedGoodInventory)
         {
            if(offering.hasValidUser)
            {
               items = offering.inventory;
               for(i = 0; i < items.length; i++)
               {
                  itemOffered = items[i];
                  if(!itemOffered.hasExpired() && itemOffered.quantity > 0 && itemOffered.price > 0)
                  {
                     found[itemOffered.itemCode] = 1;
                  }
               }
            }
         }
         result = new Array();
         for(itemCode in found)
         {
            result.push(itemCode);
         }
         return result;
      }
      
      public function getFriendsWithBushel(bushelCode:String) : Array
      {
         var uid:String = null;
         var offering:MarketStallOffering = null;
         var items:Array = null;
         var i:int = 0;
         var itemOffered:MarketInventoryItem = null;
         var result:Dictionary = null;
         var found:Array = new Array();
         for(uid in this.m_MarketView.marketStallInventory)
         {
            offering = this.m_MarketView.marketStallInventory[uid];
            if(offering.hasValidUser || SmartBushelHelper.inExperiment() && offering.offeredBy == SmartBushelHelper.FICTIONAL_CHARACTER_ID)
            {
               items = offering.inventory;
               for(i = 0; i < items.length; i++)
               {
                  itemOffered = items[i];
                  if(!itemOffered.hasExpired() && itemOffered.itemCode == bushelCode)
                  {
                     result = new Dictionary();
                     result["uid"] = uid;
                     result["timeToBags"] = CraftingManager.getInstance().timeToNextBushelFromUser(uid);
                     if(SmartBushelHelper.inExperiment() && offering.offeredBy == SmartBushelHelper.FICTIONAL_CHARACTER_ID)
                     {
                        found.unshift(result);
                     }
                     else
                     {
                        found.push(result);
                     }
                     break;
                  }
               }
            }
         }
         return found;
      }
      
      public function insertSmartBushels(itemsToInsert:Array) : void
      {
         var itemOffered:MarketInventoryItem = null;
         var items:Array = new Array();
         for(var idx:int = 0; idx < itemsToInsert.length; idx++)
         {
            itemOffered = new MarketInventoryItem();
            itemOffered.quantity = itemsToInsert[idx].qty;
            itemOffered.expires = GlobalEngine.serverTime + FarmGameUtil.NUM_SECS_IN_DAY;
            itemOffered.itemCode = itemsToInsert[idx].itemCode;
            items.push(itemOffered);
         }
         this.m_MarketView.marketStallInventory[String(SmartBushelHelper.FICTIONAL_CHARACTER_ID)] = new MarketStallOffering(items,SmartBushelHelper.FICTIONAL_CHARACTER_ID);
         this.m_cachedSmartBushelItems = itemsToInsert;
      }
      
      public function clearSmartBushelItems() : void
      {
         this.m_cachedSmartBushelItems = null;
      }
      
      public function getFriendsWithCraftedGood(itemCode:String) : Array
      {
         var uid:String = null;
         var offering:CraftedGoodOffering = null;
         var items:Array = null;
         var i:int = 0;
         var itemOffered:MarketInventoryItem = null;
         var result:Dictionary = null;
         var found:Array = new Array();
         for(uid in this.m_MarketView.craftedGoodInventory)
         {
            offering = this.m_MarketView.craftedGoodInventory[uid];
            if(offering.hasValidUser)
            {
               items = offering.inventory;
               for(i = 0; i < items.length; i++)
               {
                  itemOffered = items[i];
                  if(!itemOffered.hasExpired() && itemOffered.itemCode == itemCode && itemOffered.level > 0)
                  {
                     result = new Dictionary();
                     result["uid"] = uid;
                     result["price"] = itemOffered.price;
                     result["level"] = itemOffered.level;
                     result["quantity"] = itemOffered.quantity;
                     found.push(result);
                     break;
                  }
               }
            }
         }
         return this.sortLevelDecending(found);
      }
      
      private function sortLevelDecending(arrayIn:Array) : Array
      {
         var itemA:Dictionary = null;
         var itemB:Dictionary = null;
         var recipeLevelA:int = 0;
         var recipeLevelb:int = 0;
         var i:int = 0;
         var arrayOut:Array = [];
         for each(itemA in arrayIn)
         {
            if(arrayOut.length == 0)
            {
               arrayOut.push(itemA);
            }
            else
            {
               for(i = 0; i < arrayOut.length; i++)
               {
                  itemB = arrayOut[i];
                  if(itemA["level"] > itemB["level"])
                  {
                     arrayOut.splice(i,0,itemA);
                     break;
                  }
                  if(i == arrayOut.length - 1)
                  {
                     arrayOut.push(itemA);
                     break;
                  }
               }
            }
         }
         return arrayOut;
      }
      
      public function getBushelCodesAvailableBySubType(subType:String) : Array
      {
         var offering:MarketStallOffering = null;
         var result:Array = null;
         var itemCode:String = null;
         var items:Array = null;
         var i:int = 0;
         var itemOffered:MarketInventoryItem = null;
         var item:FarmItem = null;
         var found:Dictionary = new Dictionary();
         for each(offering in this.m_MarketView.marketStallInventory)
         {
            if(offering.hasValidUser)
            {
               items = offering.inventory;
               for(i = 0; i < items.length; i++)
               {
                  itemOffered = items[i];
                  if(!itemOffered.hasExpired() && found[itemOffered.itemCode] == null)
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByCode(itemOffered.itemCode);
                     if(item.subType == subType)
                     {
                        found[itemOffered.itemCode] = 1;
                     }
                  }
               }
            }
         }
         result = new Array();
         for(itemCode in found)
         {
            result.push(itemCode);
         }
         return result;
      }
      
      public function getCraftedGoodsAvailableBySkill(skillType:String) : Array
      {
         var offering:CraftedGoodOffering = null;
         var result:Array = null;
         var itemCode:String = null;
         var items:Array = null;
         var i:int = 0;
         var itemOffered:MarketInventoryItem = null;
         var recipe:RecipeItem = null;
         var found:Dictionary = new Dictionary();
         for each(offering in this.m_MarketView.craftedGoodInventory)
         {
            if(offering.hasValidUser)
            {
               items = offering.inventory;
               for(i = 0; i < items.length; i++)
               {
                  itemOffered = items[i];
                  if(!itemOffered.hasExpired() && itemOffered.quantity > 0 && itemOffered.price > 0 && found[itemOffered.itemCode] == null)
                  {
                     recipe = Global.craftConfigSettings.getRecipeById(itemOffered.itemCode);
                     if(recipe.craft == skillType)
                     {
                        found[itemOffered.itemCode] = 1;
                     }
                  }
               }
            }
         }
         result = new Array();
         for(itemCode in found)
         {
            result.push(itemCode);
         }
         return result;
      }
      
      public function beginEnsureMarketViewAge(callback:Function) : void
      {
         var completionThunk:Function = null;
         var transaction:TGetMarketView = null;
         if(this.isStale())
         {
            this.showMarketWaitPopup();
            completionThunk = function():void
            {
               endEnsureMarketViewAge(callback);
            };
            transaction = new TGetMarketView(completionThunk);
            TransactionManager.addTransaction(transaction,true);
         }
         else
         {
            this.endEnsureMarketViewAge(callback);
         }
      }
      
      private function endEnsureMarketViewAge(callback:Function) : void
      {
         this.hideWaitPopup();
         if(callback != null)
         {
            callback();
         }
      }
      
      public function beginFetchLatestMarketInventory() : void
      {
         var transaction:TGetMarketView = null;
         if(this.isStale())
         {
            transaction = new TGetMarketView();
            TransactionManager.addTransaction(transaction,true);
         }
      }
      
      public function getMarketStallOfferingForUser(uid:String) : MarketStallOffering
      {
         return this.m_MarketView.marketStallInventory[String(uid)];
      }
      
      public function getCraftedGoodOfferingForUser(uid:String) : CraftedGoodOffering
      {
         return this.m_MarketView.craftedGoodInventory[String(uid)];
      }
      
      public function beginGetMarketOfferingForUser(uid:String, callback:Function) : void
      {
         var completionThunk:Function = null;
         var transaction:TGetUserMarketStallInventory = null;
         var currentOffering:MarketStallOffering = this.m_MarketView.marketStallInventory[String(uid)];
         if(currentOffering == null || this.m_MarketView.getUserIsStale(uid))
         {
            completionThunk = function():void
            {
               endGetMarketOfferingForUser(uid,callback);
            };
            transaction = new TGetUserMarketStallInventory(String(uid),completionThunk);
            TransactionManager.addTransaction(transaction,true);
         }
         else
         {
            this.endGetMarketOfferingForUser(uid,callback);
         }
      }
      
      public function adjustAvailableGoodPrice(fromUserId:String, itemCode:String, newPrice:int) : void
      {
         var i:int = 0;
         var thisItem:MarketInventoryItem = null;
         var currentOffering:CraftedGoodOffering = this.m_MarketView.craftedGoodInventory[fromUserId];
         if(currentOffering != null)
         {
            for(i = 0; i < currentOffering.inventory.length; i++)
            {
               thisItem = currentOffering.inventory[i];
               if(thisItem != null && thisItem.itemCode == itemCode)
               {
                  thisItem.price = newPrice;
                  break;
               }
            }
         }
         this.m_MarketView.craftedGoodInventory[fromUserId] = currentOffering;
      }
      
      public function adjustAvailableGoodQuantity(fromUserId:String, itemCode:String, quantityAdjustment:int) : void
      {
         var i:int = 0;
         var thisItem:MarketInventoryItem = null;
         var currentOffering:CraftedGoodOffering = this.m_MarketView.craftedGoodInventory[fromUserId];
         if(currentOffering != null)
         {
            for(i = 0; i < currentOffering.inventory.length; i++)
            {
               thisItem = currentOffering.inventory[i];
               if(thisItem != null && thisItem.itemCode == itemCode)
               {
                  thisItem.quantity += quantityAdjustment;
                  break;
               }
            }
         }
         this.m_MarketView.craftedGoodInventory[fromUserId] = currentOffering;
      }
      
      private function endGetMarketOfferingForUser(uid:String, callback:Function) : void
      {
         if(callback != null)
         {
            callback(uid);
         }
      }
      
      protected function showWaitPopupForUser(uid:String) : void
      {
         var friend:Friend = null;
         var friendGender:String = null;
         var message:String = null;
         if(null == this.m_popup)
         {
            friend = Global.friendManager.getFriendData(uid);
            friendGender = Global.friendManager.getFriendGender(uid);
            message = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_Loading",{"user":ZLocUtils.tn(friend.firstName,ZLocUtils.tg(friendGender))});
            this.m_popup = new GenericCraftingPopup(message,GenericPopup.TYPE_MODAL);
            UI.displayPopup(this.m_popup,false);
         }
         ++this.m_popupCount;
      }
      
      protected function showMarketWaitPopup() : void
      {
         var message:String = null;
         if(null == this.m_popup)
         {
            message = ZLocUtils.t("Crafting","MarketViewDialog_Loading");
            this.m_popup = new GenericCraftingPopup(message,GenericPopup.TYPE_MODAL);
            UI.displayPopup(this.m_popup,false);
         }
         ++this.m_popupCount;
      }
      
      protected function hideWaitPopup() : void
      {
         if(this.m_popup)
         {
            if(this.m_popupCount > 0)
            {
               --this.m_popupCount;
               if(0 == this.m_popupCount)
               {
                  this.m_popup.close();
                  this.m_popup = null;
               }
            }
         }
      }
   }
}

