package Classes
{
   import Classes.crafting.CraftLevel;
   import Classes.crafting.CraftTypeState;
   import Classes.crafting.CraftingCottageHistory;
   import Classes.crafting.MarketInventoryItem;
   import Classes.crafting.RecipeItem;
   import Classes.crafting.RecipeState;
   import Classes.feed.CraftingCottageFeed;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.CraftingUI;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Helpers.Vector2;
   import Engine.IsoMath;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.ArrowIndicatorWindow;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class CraftingCottageBuilding extends StorageBuilding
   {
      
      private static const UPGRADE_ANIMATION_URL:String = "assets/effects/effect_stars_burst.swf";
      
      private static const ACTION_MANAGE_COTTAGE:String = "MANAGE_COTTAGE";
      
      private static const COTTAGE_ARROW_INDICATOR_EXPERIMENT:String = "fv_cottages_indicatorarrows";
      
      private static const COTTAGE_ARROW_INDICATOR_VARIANT:int = 1;
      
      private static const ARROW_INDICATOR_GOODS_SOLD_ICON:String = "assets/hud/FV_coins_100x100.png";
      
      public var craftName:String;
      
      public var slotName:String;
      
      public var slotsName:String;
      
      private const ARROW_INDICATOR_NONE:String = "none";
      
      private const ARROW_INDICATOR_SOLD_GOODS:String = "sales_report_arrow";
      
      private const ARROW_INDICATOR_FINISHED_RECIPES:String = "goods_ready_arrow";
      
      private const ARROW_INDICATOR_BUY_FRIEND_GOODS:String = "buy_goods_arrow";
      
      private const ARROW_INDICATOR_MAKE_GOODS:String = "empty_workspace_arrow";
      
      private const ARROW_INDICATOR_LIMITED_RECIPE_EXPIRE:String = "limited_recipe_expire";
      
      private const ARROW_INDICATOR_CHECK_INTERVAL_MS:Number = 5000;
      
      private var m_nextArrowIndicatorCheckTimeMs:Number = 0;
      
      private var m_arrowIndicatorType:String = "none";
      
      private var m_craftType:String;
      
      private var m_craftLevel:Number = 1;
      
      private var m_cottageName:String;
      
      private var m_recipeQueue:Array = [];
      
      private var m_finishedRecipes:Object = {};
      
      private var m_transactionHistory:CraftingCottageHistory;
      
      private var m_showCraftDialogAfterBuildFeed:Boolean = false;
      
      protected var m_arrowCurrentlyHidden:Boolean = true;
      
      private var m_fireworksTimer:Timer = null;
      
      private var m_serverFoundingTS:Number = 0;
      
      public function CraftingCottageBuilding(buildingType:String = null)
      {
         super(buildingType);
         this.m_craftType = m_item.craftType;
         Global.player.craftingState.onCottageModified();
         this.craftName = ZLocUtils.t("Crafting","CraftName_" + this.m_craftType);
         this.slotName = ZLocUtils.t("Crafting","Progress_" + this.m_craftType + "SlotName");
         this.slotsName = ZLocUtils.t("Crafting","Progress_" + this.m_craftType + "SlotsName");
      }
      
      private static function canSellCraftingCottage() : Boolean
      {
         return !isSellingLastBushelCapacity();
      }
      
      private static function isSellingLastBushelCapacity() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.craftingState.inventoryState.currentCapacity > 0 && Global.player.craftingState.inventoryState.placedMarketStallCount == 0 && Global.player.craftingState.inventoryState.placedCraftingCottageCount == 1)
         {
            result = true;
         }
         return result;
      }
      
      private static function displayCannotSellPrompt() : void
      {
         if(isSellingLastBushelCapacity())
         {
            CraftingCottageBuilding.displayCannotSellPromptSellingLastBushelCapacity();
         }
      }
      
      private static function displayCannotSellPromptSellingLastBushelCapacity() : void
      {
         var message:String = ZLocUtils.t("Dialogs","CraftingCottageBuilding_SellLastBushelCapacity");
         var dialog:GenericPopup = new GenericPopup(message,GenericPopup.TYPE_OK,null);
         dialog.setAcceptTextName("Okay");
         UI.displayPopup(dialog,false);
      }
      
      public function get maximumSlots() : int
      {
         var craftState:CraftTypeState = Global.player.craftingState.craftingSkillState.getCraftTypeState(this.m_craftType);
         var levelConfig:CraftLevel = Global.craftConfigSettings.getCraftLevel(craftState.level);
         return levelConfig.recipeSlots;
      }
      
      public function get availableSlots() : int
      {
         return this.maximumSlots - this.m_recipeQueue.length;
      }
      
      public function get craftType() : String
      {
         return this.m_craftType;
      }
      
      public function get recipeQueue() : Array
      {
         var nullRecipeItem:RecipeItem = null;
         var fullQueue:Array = [];
         for(var i:int = 0; i < this.m_recipeQueue.length; i++)
         {
            fullQueue.push(this.m_recipeQueue[i]);
         }
         while(fullQueue.length < this.maximumSlots)
         {
            nullRecipeItem = new RecipeItem();
            fullQueue.push(nullRecipeItem);
         }
         return fullQueue;
      }
      
      public function get readyRecipes() : Array
      {
         var recipe:RecipeItem = null;
         var recipes:Array = [];
         for(var i:int = 0; i < this.m_recipeQueue.length; i++)
         {
            recipe = this.m_recipeQueue[i];
            if(recipe.isComplete)
            {
               recipes.push(recipe);
            }
         }
         return recipes;
      }
      
      override protected function onVisitClick() : void
      {
         var thankYouFeedBundle:String = null;
         if(Global.player.level >= CraftingConstants.CRAFTING_UNLOCK_LEVEL && (Global.player.craftingState.inventoryState.placedMarketStallCount >= 1 || Global.player.craftingState.inventoryState.placedCraftingCottageCount >= 1) && !Global.worldManager.isVisitingCommunityNeighbor())
         {
            thankYouFeedBundle = Global.craftConfigSettings.getThankYouFeedBundle(this.craftType);
            CraftingUI.displayVisitingMarketStallWindow(Global.worldManager.getVisiting(),"crafts",null,thankYouFeedBundle);
         }
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return true;
      }
      
      public function get finishedRecipeMarketInventoryItems() : Array
      {
         var productCode:String = null;
         var finishedRecipe:Object = null;
         var item:MarketInventoryItem = null;
         var results:Array = new Array();
         for(productCode in this.m_finishedRecipes)
         {
            finishedRecipe = this.m_finishedRecipes[productCode];
            item = new MarketInventoryItem();
            item.itemCode = productCode;
            item.quantity = finishedRecipe.qty;
            item.price = finishedRecipe.price;
            results.push(item);
         }
         return results;
      }
      
      public function setFinishedRecipes(finishedRecipeData:Object) : void
      {
         this.m_finishedRecipes = finishedRecipeData;
      }
      
      public function updatePriceForCompletedGood(productCode:String, newPrice:Number, localOnly:Boolean = false, callback:Function = null) : void
      {
         var oldPrice:Number = NaN;
         if(this.m_finishedRecipes[productCode] != null)
         {
            oldPrice = Number(this.m_finishedRecipes[productCode].price);
            this.m_finishedRecipes[productCode].price = newPrice;
            if(!localOnly)
            {
               CraftingManager.getInstance().onBeginSetCraftedGoodPrice(this,productCode,newPrice,oldPrice,callback);
            }
         }
      }
      
      public function get cottageName() : String
      {
         var name:String = null;
         var ownerName:String = null;
         var gender:String = null;
         var failoverEntryArray:Array = null;
         var buildingFriendlyNameKey:String = null;
         var buildingFriendlyName:String = null;
         if("" == this.m_cottageName || this.m_cottageName == null)
         {
            if(Global.worldManager.isVisiting())
            {
               ownerName = Global.worldManager.getVisitName();
               gender = Global.worldManager.getVisitGender();
            }
            else
            {
               ownerName = Global.player.firstName;
               gender = Global.player.snUser.gender;
            }
            failoverEntryArray = new Array(new ZLocFailoverEntry("Crafting","Cottage_NoName_" + this.craftType),new ZLocFailoverEntry("Crafting","Cottage_NoName_failoverDefault"));
            buildingFriendlyNameKey = CraftingManager.getInstance().getCottageFriendlyNameByCraft(this.craftType);
            buildingFriendlyName = ZLocUtils.tk_pk_asTitle(buildingFriendlyNameKey);
            name = ZLocUtils.getFailoverLocString(failoverEntryArray,{
               "owner":ZLocUtils.tn(ownerName,ZLocUtils.tg(gender)),
               "building_name":buildingFriendlyName
            });
         }
         else
         {
            name = this.m_cottageName;
         }
         return name;
      }
      
      public function get ownCottageName() : String
      {
         var failoverEntryArray:Array = new Array(new ZLocFailoverEntry("Crafting","Cottage_OwnName_" + this.craftType),new ZLocFailoverEntry("Crafting","Cottage_OwnName_failoverDefault"));
         var buildingFriendlyNameKey:String = CraftingManager.getInstance().getCottageFriendlyNameByCraft(this.craftType);
         var buildingFriendlyName:String = ZLocUtils.tk_pk_asTitle(buildingFriendlyNameKey);
         return ZLocUtils.getFailoverLocString(failoverEntryArray,{"building_name":buildingFriendlyName});
      }
      
      override public function getCurrentSuffix() : int
      {
         return int(this.craftLevel - 1);
      }
      
      public function getCurrentImageUrl() : String
      {
         return getItem().getImageByName("icon",false);
      }
      
      public function get transactionHistory() : CraftingCottageHistory
      {
         return this.m_transactionHistory;
      }
      
      public function get craftLevel() : int
      {
         var craftTypeState:CraftTypeState = null;
         var level:int = 0;
         if(Global.worldManager.isVisiting())
         {
            level = this.m_craftLevel;
         }
         else
         {
            craftTypeState = Global.player.craftingState.craftingSkillState.getCraftTypeState(this.m_craftType);
            if(craftTypeState)
            {
               level = craftTypeState.level;
            }
         }
         return level;
      }
      
      override protected function onBuilt() : void
      {
         super.onBuilt();
         CraftingManager.getInstance().startCraftType(m_item.craftType);
         if(!Global.player.getSeenFlag("placeCottage"))
         {
            Global.player.setSeenFlag("placeCottage");
            this.m_showCraftDialogAfterBuildFeed = true;
            CraftingManager.getInstance().grantOnboardingGoodies(m_item.craftType);
         }
         Global.farmGameSettingsManager.updateItemByName(m_item.name);
         Global.player.craftingState.craftingSkillState.grantDefaultRecipes();
         ++Global.player.craftingState.inventoryState.placedCraftingCottageCount;
      }
      
      override public function onSell() : void
      {
         super.onSell();
         --Global.player.craftingState.inventoryState.placedCraftingCottageCount;
      }
      
      override public function onDelete() : void
      {
         if(CraftingCottageBuilding.canSellCraftingCottage())
         {
            super.onDelete();
            --Global.player.craftingState.inventoryState.placedCraftingCottageCount;
         }
         else
         {
            displayCannotSellPrompt();
         }
      }
      
      override public function isClearable() : Boolean
      {
         return Boolean(super.isClearable()) && CraftingCottageBuilding.canSellCraftingCottage();
      }
      
      override public function onBuildComplete(result:Object) : void
      {
         var localizationObj:Object = null;
         var feed:CraftingCottageFeed = null;
         super.onBuildComplete(result);
         if(result.rewardLink)
         {
            localizationObj = {
               "cottageName":CraftingManager.getInstance().getCottageFriendlyNameByCraft(this.craftType),
               "item":Global.craftConfigSettings.getBonusRecipe(this.craftType).friendlyName,
               "crafter":"Crafting:CraftChosen_FriendSlotTitle_" + this.craftType
            };
            feed = new CraftingCottageFeed("CraftingCottage_building_placed",result.rewardLink,localizationObj,this.onCloseBuildFeed);
            feed.setImage(this.getCurrentImageUrl());
            feed.startFeedFlow();
         }
      }
      
      private function onCloseBuildFeed() : void
      {
         if(this.m_showCraftDialogAfterBuildFeed)
         {
            CraftingUI.displayCraftingMainWindow(this);
         }
      }
      
      override public function showMenu() : void
      {
         var arrowIndicatorType:String = null;
         if(Global.player.craftingState.isInitialized && Global.worldManager.isWorldSwapStable)
         {
            arrowIndicatorType = this.getArrowIndicatorType();
            switch(arrowIndicatorType)
            {
               case this.ARROW_INDICATOR_SOLD_GOODS:
               case this.ARROW_INDICATOR_FINISHED_RECIPES:
                  this.removeArrowIndicator();
                  CraftingUI.displayCraftingMainWindow(this);
                  break;
               case this.ARROW_INDICATOR_BUY_FRIEND_GOODS:
                  this.removeArrowIndicator();
                  CraftingUI.displayCraftingMainWindow(this,CraftingConstants.SECONDARY_POPUP_GET_GOODS);
                  break;
               case this.ARROW_INDICATOR_LIMITED_RECIPE_EXPIRE:
                  this.removeArrowIndicator();
                  CraftingUI.displayCraftingMainWindow(this);
               case this.ARROW_INDICATOR_NONE:
               default:
                  m_menuItems.push({
                     "label":ZLocUtils.t("Crafting","Cottage_ActionViewCottage"),
                     "action":ACTION_MANAGE_COTTAGE
                  });
                  super.showMenu();
            }
            Global.player.setSeenSessionFlag("clickedArrow");
            FarmStatsManager.count("crafting_cottage","see_" + arrowIndicatorType,"click_cottage");
         }
      }
      
      override public function displayStorageDialog(defaultAction:String = "") : void
      {
         CraftingUI.displayCraftingMainWindow(this);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(Global.worldManager.isWorldSwapStable)
         {
            if(event.target is ContextMenuItem)
            {
               item = event.target as ContextMenuItem;
               switch(item.action)
               {
                  case ACTION_MANAGE_COTTAGE:
                     CraftingUI.displayCraftingMainWindow(this);
                     break;
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
      
      override public function sell() : void
      {
         if(m_item)
         {
            if(CraftingCottageBuilding.canSellCraftingCottage())
            {
               UI.displayMessage(ZLocUtils.t("Crafting","General_SellCraftingCottage",{
                  "item":ZLocUtils.tk_pk(m_item.friendlyName),
                  "number":getSellPrice()
               }),GenericPopup.TYPE_YESNO,sellConfirmationHandler);
            }
            else
            {
               CraftingCottageBuilding.displayCannotSellPrompt();
            }
         }
      }
      
      public function getQueueRecipe(recipeId:String, start_ts:int = 0) : RecipeItem
      {
         var recipe:RecipeItem = null;
         var result:RecipeItem = null;
         for(var i:int = 0; i < this.m_recipeQueue.length; i++)
         {
            recipe = this.m_recipeQueue[i];
            if(recipe.id == recipeId && (start_ts == 0 || recipe.serverStartTS == start_ts))
            {
               result = recipe;
               break;
            }
         }
         return result;
      }
      
      private function deleteQueueRecipe(recipeId:String, start_ts:Number) : void
      {
         var recipe:RecipeItem = null;
         for(var i:int = 0; i < this.m_recipeQueue.length; i++)
         {
            recipe = this.m_recipeQueue[i];
            if(recipe.id == recipeId && (recipe.serverStartTS == start_ts || recipe.serverStartTS == 1))
            {
               this.m_recipeQueue.splice(i,1);
               break;
            }
         }
      }
      
      public function animateUpgrade() : void
      {
         this.playFireWorksEffect();
         this.setState(this.state);
         Global.world.centerOnObject(this,2,60);
      }
      
      override public function centerOn() : void
      {
      }
      
      private function playFireWorksEffect() : void
      {
         var screen:Vector2 = null;
         var spr:Sprite = null;
         var overlayParams:Object = null;
         if(!this.m_fireworksTimer)
         {
            screen = IsoMath.tilePosToPixelPos(this.getPosition().x,this.getPosition().y,this.getPosition().z);
            spr = m_displayObject as Sprite;
            overlayParams = new Object();
            overlayParams.overlayMc = "burst_mc";
            overlayParams.scale = 1;
            overlayParams.offsetX = spr.width / 2;
            overlayParams.offsetY = spr.height / 2;
            overlayParams.startFrame = 1;
            overlayParams.noLoop = true;
            overlayParams.noReuse = true;
            dispOverlay(UPGRADE_ANIMATION_URL,overlayParams);
            this.m_fireworksTimer = new Timer(6533,1);
            this.m_fireworksTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.stopFireWorksEffect);
            this.m_fireworksTimer.start();
         }
      }
      
      private function stopFireWorksEffect(event:TimerEvent) : void
      {
         this.m_fireworksTimer.stop();
         this.m_fireworksTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.stopFireWorksEffect);
         this.m_fireworksTimer = null;
      }
      
      public function onRecipeCancel(recipeItem:RecipeItem) : void
      {
         this.deleteQueueRecipe(recipeItem.id,recipeItem.serverStartTS);
      }
      
      public function beginRecipe(recipeItem:RecipeItem, ignoreServerCheck:Boolean = false) : void
      {
         if(recipeItem.serverStarted && !ignoreServerCheck)
         {
            throw new Error("CraftingCottageBuilding::beginRecipe tried to start a recipe that has already been started");
         }
         this.m_recipeQueue.push(recipeItem);
      }
      
      public function onRecipeBegun(recipeItem:RecipeItem) : void
      {
         var checkRecipe:RecipeItem = null;
         if(!recipeItem.serverStarted)
         {
            throw new Error("CraftingCottageBuilding::onRecipeBegun tried to add a recipe that has not been started on the server");
         }
         var added:Boolean = false;
         for(var i:int = 0; i < this.m_recipeQueue.length; i++)
         {
            checkRecipe = this.m_recipeQueue[i];
            if(checkRecipe.id == recipeItem.id && !checkRecipe.serverStarted)
            {
               this.m_recipeQueue[i] = recipeItem;
               added = true;
               break;
            }
         }
         if(!added)
         {
            throw new Error("CraftingCottageBuilding::onRecipeBegun could not find reserved slot for server response recipe");
         }
      }
      
      public function recordRecipeFinished(recipe:Object) : void
      {
         var productItemCode:String = null;
         var oldQty:int = 0;
         var recipeId:String = recipe.recipeId;
         var startTs:int = int(recipe.start_ts);
         this.deleteQueueRecipe(recipeId,startTs);
         var recipeState:RecipeState = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipeId);
         if(recipe.quantity > 0)
         {
            productItemCode = recipe.productItemCode;
            if(!this.m_finishedRecipes.hasOwnProperty(productItemCode))
            {
               this.m_finishedRecipes[productItemCode] = new Object();
               this.m_finishedRecipes[productItemCode].price = Global.craftConfigSettings.getDefaultSellPrice(recipeState.level);
               this.m_finishedRecipes[productItemCode].id = productItemCode;
               this.m_finishedRecipes[productItemCode].qty = 0;
            }
            oldQty = int(this.m_finishedRecipes[productItemCode].qty);
            this.m_finishedRecipes[productItemCode].qty = oldQty + int(recipe.quantity);
         }
      }
      
      public function isRecipeAppropriateForCottage(recipeId:String) : Boolean
      {
         var result:Boolean = false;
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         if(recipe != null)
         {
            result = recipe.craft == this.craftType;
         }
         return result;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(GlobalEngine.currentTime > this.m_nextArrowIndicatorCheckTimeMs)
         {
            this.checkArrowIndicator();
            this.m_nextArrowIndicatorCheckTimeMs = GlobalEngine.currentTime + this.ARROW_INDICATOR_CHECK_INTERVAL_MS;
         }
      }
      
      override protected function replaceContent(newContent:DisplayObject, shouldRedrawMask:Boolean = false) : void
      {
         super.replaceContent(newContent,shouldRedrawMask);
         this.checkArrowIndicator();
      }
      
      private function checkArrowIndicator() : void
      {
         var arrowIndicatorType:String = null;
         var spr:Sprite = null;
         if(!m_usingLoadingGraphic && !UI.isShowingPopup())
         {
            arrowIndicatorType = this.getArrowIndicatorType();
            m_hideArrow = this.ARROW_INDICATOR_NONE == arrowIndicatorType;
            if(this.m_arrowCurrentlyHidden != m_hideArrow)
            {
               if(m_hideArrow)
               {
                  this.removeArrowIndicator();
               }
               else
               {
                  spr = m_displayObject as Sprite;
                  if(m_arrow == null && spr.numChildren > 0)
                  {
                     m_arrow = this.createArrowIndicator(arrowIndicatorType);
                     if(m_arrow)
                     {
                        m_arrow.visible = true;
                        (m_displayObject as Sprite).addChild(m_arrow);
                        setArrowPosition();
                     }
                     this.m_arrowCurrentlyHidden = false;
                  }
               }
            }
         }
      }
      
      public function removeArrowIndicator() : void
      {
         if(Boolean(m_arrow) && Boolean(m_arrow.visible) && m_arrow.parent != null)
         {
            m_arrow.visible = false;
            m_arrow.parent.removeChild(m_arrow);
            m_arrow = null;
            conditionallyRedraw(true);
            this.m_arrowCurrentlyHidden = true;
            m_hideArrow = true;
         }
      }
      
      private function getArrowIndicatorType() : String
      {
         var pendingHistory:Boolean = false;
         var type:String = this.ARROW_INDICATOR_NONE;
         if(!Global.worldManager.isVisiting())
         {
            pendingHistory = Boolean(this.transactionHistory) && this.transactionHistory.hasFreshTransactions();
            if(CraftingManager.getInstance().getExpiringRecipes(this.craftType).length > 0)
            {
               type = this.ARROW_INDICATOR_LIMITED_RECIPE_EXPIRE;
            }
            else if(Boolean(this.transactionHistory) && this.transactionHistory.hasFreshTransactions())
            {
               type = this.ARROW_INDICATOR_SOLD_GOODS;
            }
            else if(this.readyRecipes.length > 0)
            {
               type = this.ARROW_INDICATOR_FINISHED_RECIPES;
            }
            else if(!Global.player.getSeenSessionFlag("clickedArrow"))
            {
               if(MarketViewManager.getInstance().getNumFriendsWithCraftedGoodsAvailable() > 0)
               {
                  type = this.ARROW_INDICATOR_BUY_FRIEND_GOODS;
               }
               else if(this.availableSlots > 0)
               {
                  type = this.ARROW_INDICATOR_MAKE_GOODS;
               }
            }
         }
         return type;
      }
      
      private function createArrowIndicator(arrowIndicatorType:String) : DisplayObject
      {
         var friendsWithGoods:Array = null;
         var friendIdx:int = 0;
         var friend:Friend = null;
         var arrowIndicator:DisplayObject = null;
         var iconUrl:String = "";
         var counter:int = 0;
         var canShowCounterIcon:Boolean = false;
         var titleLocalizeKey:String = "CottageArrowTitle_" + arrowIndicatorType;
         switch(arrowIndicatorType)
         {
            case this.ARROW_INDICATOR_SOLD_GOODS:
               counter = this.transactionHistory.friendsSold;
               iconUrl = ARROW_INDICATOR_GOODS_SOLD_ICON;
               break;
            case this.ARROW_INDICATOR_FINISHED_RECIPES:
               counter = int(this.readyRecipes.length);
               if(counter > 0)
               {
                  iconUrl = this.readyRecipes[0].image;
               }
               break;
            case this.ARROW_INDICATOR_BUY_FRIEND_GOODS:
               friendsWithGoods = MarketViewManager.getInstance().getFriendsWithCraftedGoodsAvailable();
               counter = int(friendsWithGoods.length);
               canShowCounterIcon = true;
               if(counter > 0)
               {
                  friendIdx = Math.round(Math.random() * (counter - 1));
                  friend = Global.friendManager.getFriendData(friendsWithGoods[friendIdx]);
                  if(friend)
                  {
                     iconUrl = friend.picture;
                  }
               }
               break;
            case this.ARROW_INDICATOR_LIMITED_RECIPE_EXPIRE:
               counter = int(CraftingManager.getInstance().getExpiringRecipes(this.craftType).length);
               iconUrl = CraftingConstants.RECIPE_LIMITED_TIME_INDICATOR;
               break;
            case this.ARROW_INDICATOR_MAKE_GOODS:
               counter = this.availableSlots;
               iconUrl = CraftingUI.getRecipeSlotIcon(this.craftType);
               titleLocalizeKey += "_" + this.craftType;
         }
         if(counter > 1)
         {
            titleLocalizeKey += "_Plural";
         }
         else
         {
            titleLocalizeKey += "_Singular";
         }
         var title:String = ZLocUtils.t("Crafting",titleLocalizeKey,{"quantity":counter});
         var text:String = ZLocUtils.t("Crafting","CottageArrowText_" + arrowIndicatorType);
         var counterText:String = canShowCounterIcon ? counter.toString() : null;
         arrowIndicator = new ArrowIndicatorWindow(iconUrl,title,text,counterText);
         FarmStatsManager.count("crafting_cottage","see_" + arrowIndicatorType);
         return arrowIndicator;
      }
      
      override public function loadObject(data:Object) : void
      {
         var recipeId:String = null;
         super.loadObject(data);
         this.m_recipeQueue = new Array();
         for(recipeId in data.recipeQueue)
         {
            this.m_recipeQueue.push(RecipeItem.fromPhpObject(data.recipeQueue[recipeId]));
         }
         this.m_cottageName = data.cottageName;
         this.m_finishedRecipes = data.finishedRecipes;
         this.loadTransactionHistory(data);
         this.m_craftLevel = data.hasOwnProperty("craftLevel") ? Number(data.craftLevel) : 1;
         this.m_serverFoundingTS = data.hasOwnProperty("foundingTS") ? Number(data.foundingTS) : 0;
      }
      
      public function loadTransactionHistory(data:Object) : void
      {
         var transactionHistory:Array = data.hasOwnProperty("transactionHistory") ? data.transactionHistory : new Array();
         var historyLastViewedTS:Number = data.hasOwnProperty("historyLastViewedTS") ? Number(data.historyLastViewedTS) : 0;
         var historyXPGain:int = data.hasOwnProperty("historyXPGain") ? int(data.historyXPGain) : 0;
         var pendingLevelUpFeed:Object = data.hasOwnProperty("pendingLevelUpFeed") ? data.pendingLevelUpFeed : null;
         this.m_transactionHistory = new CraftingCottageHistory(transactionHistory,historyLastViewedTS,historyXPGain,pendingLevelUpFeed);
      }
      
      public function get foundingDate() : Date
      {
         return new Date(this.m_serverFoundingTS * 1000);
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTip:String = null;
         if(Global.worldManager.isWorldSwapStable)
         {
            if(isHighlighted())
            {
               toolTip = this.cottageName;
               setToolTip(toolTip);
               updateToolTipPosition();
            }
         }
         else
         {
            toolTip = ZLocUtils.t("FarmGame","LoadingFarm");
            setToolTip(toolTip);
            updateToolTipPosition();
         }
      }
      
      override public function onMouseOver(event:MouseEvent) : void
      {
         super.onMouseOver(event);
         this.updateArrowIndicator();
      }
      
      override public function onMouseOut() : void
      {
         super.onMouseOut();
         this.updateArrowIndicator();
      }
      
      private function updateArrowIndicator() : void
      {
         var arrowIndicatorWindow:ArrowIndicatorWindow = null;
         if(Global.selectedAvatar)
         {
            arrowIndicatorWindow = m_arrow as ArrowIndicatorWindow;
            if(arrowIndicatorWindow)
            {
               arrowIndicatorWindow.showRolloverText(isHighlighted());
            }
         }
      }
      
      override public function detach() : void
      {
         super.detach();
         Global.player.craftingState.onCottageModified(true);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         if(Boolean(m_arrow) && Boolean(m_arrow.parent))
         {
            m_arrow.parent.removeChild(m_arrow);
         }
      }
   }
}

