package Widgets.Windows.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.CraftingCottageBuilding;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftLevel;
   import Classes.crafting.CraftTypeState;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.FarmStatsManager;
   import Managers.FreezeManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TCottageHistorySeen;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftingMainProductionSlotFrame;
   import Widgets.Frames.Crafting.CraftingMainRecipeSlotFrame;
   import Widgets.Frames.SearchFrame;
   import Widgets.Menu.DropDownMenu;
   import Widgets.Menu.MenuItem;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FarmWindowWithTutorial;
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   
   public class CraftingMainWindow extends FarmWindow
   {
      
      private static var m_soundNameArray:Array = ["achieve1","achieve2","achieve3","achieve4","achieve4"];
      
      public static const TUTORIAL_NOT_RUNNING:int = -1;
      
      public static const TUTORIAL_INTRO:int = 0;
      
      public static const TUTORIAL_MAKE_IT:int = TUTORIAL_INTRO + 1;
      
      public static const TUTORIAL_FINISH_IT:int = TUTORIAL_MAKE_IT + 1;
      
      public static const TUTORIAL_GET_BUSHELS:int = TUTORIAL_FINISH_IT + 1;
      
      public static const TUTORIAL_SHOPPING_LIST:int = TUTORIAL_GET_BUSHELS + 1;
      
      public static const TUTORIAL_MARKET_STALL:int = TUTORIAL_SHOPPING_LIST + 1;
      
      public static const TUTORIAL_GET_GOODS:int = TUTORIAL_MARKET_STALL + 1;
      
      public static const TUTORIAL_AVAILABLE_GOODS:int = TUTORIAL_GET_GOODS + 1;
      
      public static const TUTORIAL_USE_GOODS:int = TUTORIAL_AVAILABLE_GOODS + 1;
      
      public static const TUTORIAL_TRADE_FOR_FUEL:int = TUTORIAL_USE_GOODS + 1;
      
      public static const TUTORIAL_FINISH:int = TUTORIAL_TRADE_FOR_FUEL + 1;
      
      public static const TUTORIAL_LAST_INDEX:int = TUTORIAL_FINISH + 1;
      
      public static const TUTORIAL_FLAG_SUFFIX:String = "_Tutorial";
      
      public var cottage:CraftingCottageBuilding;
      
      private var m_getGoodsFrame:ZwFrame = null;
      
      private var m_getGoodsToolTip:FarmTextTooltip = null;
      
      private var m_numGetGoods:int = 0;
      
      private var m_useGoodsFrame:ZwFrame = null;
      
      private var m_useGoodsToolTip:FarmTextTooltip = null;
      
      private var m_numUseGoods:int = 0;
      
      private var m_upgradeFrame:ZwFrame = null;
      
      private var m_recipeSlotFrame:CraftingMainRecipeSlotFrame = null;
      
      protected var m_searchFrame:SearchFrame = null;
      
      protected var m_filterBy:FarmTabButton;
      
      protected var m_filterByMenu:DropDownMenu;
      
      protected var m_filterByName:String = "";
      
      private var m_searchString:String = "";
      
      private var m_productionSlotFrame:CraftingMainProductionSlotFrame = null;
      
      private var m_starNamesArray:Array = ["progressStar1_mc","progressStar2_mc","progressStar3_mc","progressStar4_mc","progressStar5_mc"];
      
      private var m_progressStarFrameArray:Array = null;
      
      private var m_upgradeToolTip:FarmTextTooltip = null;
      
      private var m_buyUpgradeToolTip:FarmTextTooltip = null;
      
      private var m_lastTime:int;
      
      private var m_secondaryPopup:int;
      
      private var m_sheenCurrentFrame:Number = 0;
      
      private var m_sheenTotalFrames:int;
      
      private var m_animatingStar:MovieClip = null;
      
      private var m_animatingStarCurrentFrame:Number = 0;
      
      private var m_animatingStarTotalFrames:int;
      
      private const START_TUTORIAL_TIMER_SECONDS:int = 2000;
      
      private var m_showTutorialTimer:Timer = null;
      
      private var m_lastRequestedTutorialIndex:int = TUTORIAL_NOT_RUNNING;
      
      private var m_stateError:Boolean = false;
      
      private var m_timer:Timer = null;
      
      private var m_bushelSearchingVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUSHEL_SORTING);
      
      public function CraftingMainWindow(cottageIn:CraftingCottageBuilding, secondaryPopup:int = 0, searchString:String = "")
      {
         this.cottage = cottageIn;
         this.m_secondaryPopup = secondaryPopup;
         var asset:String = "assets/dialogs/FV_Craft_Main2.swf";
         if(this.m_bushelSearchingVariant != 0)
         {
            asset = "assets/dialogs/FV_Craft_Main3.swf";
         }
         else if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFITNG_UI_PLANT_BUTTON) == 1)
         {
            asset = "assets/dialogs/FV_Craft_Main4.swf";
         }
         SoundManager.addSound("achieve1",Global.getAssetURL("assets/sounds/ui/sfx_achieve_stage1.mp3"),false);
         SoundManager.addSound("achieve2",Global.getAssetURL("assets/sounds/ui/sfx_achieve_stage2.mp3"),false);
         SoundManager.addSound("achieve3",Global.getAssetURL("assets/sounds/ui/sfx_achieve_stage3.mp3"),false);
         SoundManager.addSound("achieve4",Global.getAssetURL("assets/sounds/ui/sfx_achieve_stage4.mp3"),false);
         this.m_searchString = searchString;
         super(asset);
         MarketViewManager.getInstance().beginFetchLatestMarketInventory();
      }
      
      public function assertTutorialIndexIs(expectedIndex:int) : Boolean
      {
         var outputMessage:String = null;
         var result:Boolean = true;
         if(Config.DEBUG_MODE && this.m_lastRequestedTutorialIndex > TUTORIAL_NOT_RUNNING && this.m_lastRequestedTutorialIndex < TUTORIAL_LAST_INDEX && this.m_lastRequestedTutorialIndex != expectedIndex)
         {
            this.m_stateError = true;
            outputMessage = "Expected to be in state: " + this.getTutorialIndexAsDebugText(expectedIndex) + " but currently in state: " + this.getTutorialIndexAsDebugText(this.m_lastRequestedTutorialIndex) + ". ";
            switch(expectedIndex)
            {
               case TUTORIAL_INTRO:
               case TUTORIAL_MAKE_IT:
               case TUTORIAL_FINISH_IT:
                  break;
               case TUTORIAL_GET_BUSHELS:
                  if(this.m_lastRequestedTutorialIndex == TUTORIAL_MAKE_IT)
                  {
                     outputMessage += "\nCOMMON CAUSES:";
                     outputMessage += "\n1. wrong recipie is in slot 0 (Design); ";
                     outputMessage += "\n2. bushels for the recipe were not correctly config\'ed (Designer); ";
                     outputMessage += "\n3. XyzWorldState.class.php is not setting m_worldSpecificCraftingCottage. (Coder)";
                  }
                  break;
               case TUTORIAL_SHOPPING_LIST:
               case TUTORIAL_MARKET_STALL:
               case TUTORIAL_GET_GOODS:
               case TUTORIAL_AVAILABLE_GOODS:
               case TUTORIAL_USE_GOODS:
               case TUTORIAL_TRADE_FOR_FUEL:
               case TUTORIAL_FINISH:
            }
            outputMessage += "\n\n Aborting Tutorial. ";
            UI.clearPopupQueue();
            this.onClosePopup();
            this.close();
            UI.showMessage(outputMessage,UI.BUTTON_LAYOUT_OK,"Tutorial State Error");
            result = false;
         }
         return result;
      }
      
      public function getTutorialIndexAsDebugText(tutorialIndex:int) : String
      {
         var result:String = "";
         if(Config.DEBUG_MODE)
         {
            result = "unknown tutorial index";
            switch(tutorialIndex)
            {
               case TUTORIAL_INTRO:
                  result = "TUTORIAL_INTRO";
                  break;
               case TUTORIAL_MAKE_IT:
                  result = "TUTORIAL_MAKE_IT";
                  break;
               case TUTORIAL_FINISH_IT:
                  result = "TUTORIAL_FINISH_IT";
                  break;
               case TUTORIAL_GET_BUSHELS:
                  result = "TUTORIAL_GET_BUSHELS";
                  break;
               case TUTORIAL_SHOPPING_LIST:
                  result = "TUTORIAL_SHOPPING_LIST";
                  break;
               case TUTORIAL_MARKET_STALL:
                  result = "TUTORIAL_MARKET_STALL";
                  break;
               case TUTORIAL_GET_GOODS:
                  result = "TUTORIAL_GET_GOODS";
                  break;
               case TUTORIAL_AVAILABLE_GOODS:
                  result = "TUTORIAL_AVAILABLE_GOODS";
                  break;
               case TUTORIAL_USE_GOODS:
                  result = "TUTORIAL_USE_GOODS";
                  break;
               case TUTORIAL_TRADE_FOR_FUEL:
                  result = "TUTORIAL_TRADE_FOR_FUEL";
                  break;
               case TUTORIAL_FINISH:
                  result = "TUTORIAL_FINISH";
            }
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var progressStarFrame:ZwFrame = null;
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,this.cottage.ownCottageName));
         var backgroundMCName:String = Global.craftConfigSettings.getCraftingBackgroundStyle(this.cottage.craftType);
         if(Boolean(backgroundMCName) && m_window.hasOwnProperty(backgroundMCName))
         {
            addWidget(new ZwFrame(m_window[backgroundMCName])) as ZwFrame;
         }
         if(this.m_bushelSearchingVariant != 0)
         {
            addWidget(new FarmAnimatedTextButton(m_window.inventory_bt,ZLocUtils.t("Dialogs","CraftshopWindow_inventory_btn"),this.pressInventory));
         }
         var tutorialAssetPath:String = Global.craftConfigSettings.getTutorialAssetPath(this.cottage.craftType);
         if(tutorialAssetPath != "")
         {
            addWidget(new FarmAnimatedTextButton(m_window.moreInfo_bt,ZLocUtils.t("Crafting","CraftingMain_MoreInfo"),this.onMoreInfoClickWithAlternateTut));
            if(!Global.player.getSeenFlag(this.cottage.getItemName() + TUTORIAL_FLAG_SUFFIX))
            {
               this.onMoreInfoClickWithAlternateTut(null);
            }
         }
         else
         {
            addWidget(new FarmAnimatedTextButton(m_window.moreInfo_bt,ZLocUtils.t("Crafting","CraftingMain_MoreInfo"),this.onMoreInfoClick));
         }
         addWidget(new FarmAnimatedTextButton(m_window.mySales_bt,ZLocUtils.t("Crafting","CraftingMain_MySales"),this.onMySalesClick));
         var numGetGoods:int = MarketViewManager.getInstance().getNumFriendsWithCraftedGoodsAvailable();
         var getGoodsVisible:Boolean = numGetGoods > 0;
         this.m_getGoodsFrame = new ZwFrame(m_window.goodsGet_mc);
         addWidget(this.m_getGoodsFrame);
         this.m_getGoodsFrame.addWidget(new ZwWidget(m_window.goodsGet_mc.counterCircle_mc),getGoodsVisible);
         this.m_getGoodsFrame.addWidget(new ZwTextField(m_window.goodsGet_mc.counter_tf,numGetGoods.toString()),getGoodsVisible);
         this.m_getGoodsFrame.addWidget(new ZwTextField(m_window.goodsGet_mc.generic_tf,ZLocUtils.t("Crafting","CraftingMain_GetGoods")));
         this.m_getGoodsFrame.addWidget(new ZwWidget(m_window.goodsGet_mc.on_mc),true);
         this.m_getGoodsFrame.addWidget(new ZwWidget(m_window.goodsGet_mc.over_mc),false);
         this.m_getGoodsToolTip = new FarmTextTooltip("");
         this.m_getGoodsFrame.element.buttonMode = true;
         this.m_getGoodsFrame.attachTooltip(this.m_getGoodsToolTip);
         this.m_getGoodsFrame.registerEventListener(MouseEvent.CLICK,this.onGetGoodsClick);
         this.m_getGoodsFrame.registerEventListener(MouseEvent.MOUSE_OVER,this.onGetGoodsOver);
         this.m_getGoodsFrame.registerEventListener(MouseEvent.MOUSE_OUT,this.onGetGoodsOut);
         var numUseGoods:int = Global.player.craftingState.totalCraftedGoods;
         var useGoodsVisible:Boolean = numUseGoods != 0;
         this.m_useGoodsFrame = new ZwFrame(m_window.goodsUse_mc);
         addWidget(this.m_useGoodsFrame);
         this.m_useGoodsFrame.addWidget(new ZwWidget(m_window.goodsUse_mc.counterCircle_mc),useGoodsVisible);
         this.m_useGoodsFrame.addWidget(new ZwTextField(m_window.goodsUse_mc.counter_tf,numUseGoods.toString()),useGoodsVisible);
         this.m_useGoodsFrame.addWidget(new ZwTextField(m_window.goodsUse_mc.generic_tf,ZLocUtils.t("Crafting","CraftingMain_UseGoods")));
         this.m_useGoodsFrame.addWidget(new ZwWidget(m_window.goodsUse_mc.on_mc),true);
         this.m_useGoodsFrame.addWidget(new ZwWidget(m_window.goodsUse_mc.over_mc),false);
         this.m_useGoodsToolTip = new FarmTextTooltip("");
         this.m_useGoodsFrame.element.buttonMode = true;
         this.m_useGoodsFrame.attachTooltip(this.m_useGoodsToolTip);
         this.m_useGoodsFrame.registerEventListener(MouseEvent.CLICK,this.onUseGoodsClick);
         this.m_useGoodsFrame.registerEventListener(MouseEvent.MOUSE_OVER,this.onUseGoodsOver);
         this.m_useGoodsFrame.registerEventListener(MouseEvent.MOUSE_OUT,this.onUseGoodsOut);
         this.m_upgradeFrame = new ZwFrame(m_window.frameUpgrade_mc);
         addWidget(this.m_upgradeFrame);
         this.m_upgradeFrame.addWidget(new FarmAnimatedTextButton(m_window.frameUpgrade_mc.coinUpgrade_bt,ZLocUtils.t("Crafting","CraftingMain_CoinUpgrade"),this.onCoinUpgrade));
         this.m_upgradeFrame.addWidget(new FarmAnimatedTextButton(m_window.frameUpgrade_mc.buyUpgrade_bt,ZLocUtils.t("Crafting","CraftingMain_BuyUpgrade"),this.onBuyUpgrade));
         this.m_upgradeFrame.addWidget(new ZwTextField(m_window.frameUpgrade_mc.generic_tf,ZLocUtils.t("Crafting","CraftingMain_CottageLevel" + this.cottage.craftLevel,{"cottage":ZLocUtils.tk("Items","crafting" + this.cottage.craftType + "_friendlyName")})));
         this.m_upgradeFrame.addWidget(new ZwTextField(m_window.frameUpgrade_mc.upgradeMessage_tf,ZLocUtils.t("Crafting","CraftingMain_CoinUpgradeMessage",{"quantity":1})));
         this.m_upgradeFrame.addWidget(new ZwTextField(m_window.frameUpgrade_mc.level1_tf,ZLocUtils.t("Crafting","CraftingMain_Level",{"levelNum":1})));
         this.m_upgradeFrame.addWidget(new ZwTextField(m_window.frameUpgrade_mc.level2_tf,ZLocUtils.t("Crafting","CraftingMain_Level",{"levelNum":2})));
         this.m_upgradeFrame.addWidget(new ZwTextField(m_window.frameUpgrade_mc.level3_tf,ZLocUtils.t("Crafting","CraftingMain_Level",{"levelNum":3})));
         this.m_upgradeFrame.addWidget(new ZwTextField(m_window.frameUpgrade_mc.level4_tf,ZLocUtils.t("Crafting","CraftingMain_Level",{"levelNum":4})));
         this.m_upgradeFrame.addWidget(new ZwTextField(m_window.frameUpgrade_mc.level5_tf,ZLocUtils.t("Crafting","CraftingMain_Level",{"levelNum":5})));
         this.m_upgradeFrame.addWidget(new ZwWidget(m_window.frameUpgrade_mc.meter_mc));
         this.m_upgradeFrame.addWidget(new ZwWidget(m_window.frameUpgrade_mc.meter_mc.bar_mc));
         this.m_progressStarFrameArray = [];
         this.m_upgradeToolTip = new FarmTextTooltip("");
         (this.m_upgradeFrame.getWidget(m_window.frameUpgrade_mc.meter_mc) as ZwWidget).attachTooltip(this.m_upgradeToolTip);
         for(var i:int = 0; i < this.m_starNamesArray.length; i++)
         {
            progressStarFrame = new ZwFrame(m_window.frameUpgrade_mc[this.m_starNamesArray[i]]);
            this.m_progressStarFrameArray[i] = progressStarFrame;
            this.m_upgradeFrame.addWidget(progressStarFrame);
            progressStarFrame.addWidget(new ZwWidget(m_window.frameUpgrade_mc[this.m_starNamesArray[i]].progressStarBurst_mc));
            progressStarFrame.addWidget(new ZwWidget(m_window.frameUpgrade_mc[this.m_starNamesArray[i]].progressStarOff_mc));
            progressStarFrame.addWidget(new ZwWidget(m_window.frameUpgrade_mc[this.m_starNamesArray[i]].progressStarOn_mc));
            progressStarFrame.attachTooltip(this.m_upgradeToolTip);
         }
         this.m_animatingStarTotalFrames = m_window.frameUpgrade_mc.progressStar1_mc.progressStarBurst_mc.totalFrames;
         this.m_buyUpgradeToolTip = new FarmTextTooltip("");
         (this.m_upgradeFrame.getWidget(m_window.frameUpgrade_mc.buyUpgrade_bt) as FarmAnimatedTextButton).attachTooltip(this.m_buyUpgradeToolTip);
         this.updateUpgradeFrame();
         if(m_window.frameUpgrade_mc.coinUpgrade_bt.sheen_mc != null)
         {
            this.m_sheenTotalFrames = m_window.frameUpgrade_mc.coinUpgrade_bt.sheen_mc.totalFrames;
         }
         else
         {
            this.m_sheenTotalFrames = 1;
         }
         if(this.cottage.craftType == "xdwcrafttype")
         {
            this.m_recipeSlotFrame = new CraftingMainRecipeSlotFrame(m_window.frameRecipes_mc,Global.craftConfigSettings.getAllRecipes(this.cottage.craftType,0,true,true),this);
         }
         else
         {
            this.m_recipeSlotFrame = new CraftingMainRecipeSlotFrame(m_window.frameRecipes_mc,Global.craftConfigSettings.getAllRecipes(this.cottage.craftType,this.cottage.craftLevel + 1),this);
         }
         addWidget(this.m_recipeSlotFrame);
         if(m_window.hasOwnProperty("searchBar_mc"))
         {
            this.m_searchFrame = addWidget(new SearchFrame(m_window.searchBar_mc,this.onSearchUpdate,this.m_searchString)) as SearchFrame;
            if(this.m_searchString != "")
            {
               this.m_recipeSlotFrame.filterOptionsChanged();
            }
         }
         if(this.m_recipeSlotFrame.isRegionSufixPresent() && Boolean(m_window.frameRecipes_mc.hasOwnProperty("filterBy_bt")))
         {
            this.m_filterBy = addWidget(new FarmTabButton(m_window.frameRecipes_mc.filterBy_bt,"Filter By")) as FarmTabButton;
            (this.m_filterBy.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onFilterByMouseOver,false,0,true);
            (this.m_filterBy.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onFilterByMouseOut,false,0,true);
            this.m_filterByMenu = addWidget(new DropDownMenu(m_window.frameRecipes_mc.frame_subNav2_mc,this.onFilterByMenuItemSelected),false) as DropDownMenu;
            (this.m_filterByMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onFilterByMouseOut,false,0,true);
            this.populateFilterByDropDown();
         }
         this.m_productionSlotFrame = new CraftingMainProductionSlotFrame(m_window.frameProduction_mc,this.cottage.recipeQueue,this);
         addWidget(this.m_productionSlotFrame);
         this.m_lastTime = GlobalEngine.currentTime;
         if(this.isInTutorial())
         {
            this.clearTutorial();
            CraftingManager.getInstance().inTutorialMode = false;
         }
         else if(!Global.player.getSeenFlag("recipeTut0"))
         {
            tintWindow();
            enableInput = false;
            this.m_showTutorialTimer = new Timer(this.START_TUTORIAL_TIMER_SECONDS,1);
            this.m_showTutorialTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onStartTutorialTimer);
            this.m_showTutorialTimer.start();
            CraftingManager.getInstance().inTutorialMode = true;
         }
         if(!CraftingManager.getInstance().inTutorialMode)
         {
            switch(this.m_secondaryPopup)
            {
               case CraftingConstants.SECONDARY_POPUP_GET_GOODS:
                  tintWindow();
                  enableInput = false;
                  CraftingUI.displayCraftingGetGoodsWindow(this.onClosePopup);
                  FarmStatsManager.count("cottage_ui_new","view_get_good_page","user_automatically_brought_to_page");
                  break;
               case CraftingConstants.SECONDARY_POPUP_USE_GOODS:
                  tintWindow();
                  enableInput = false;
                  CraftingUI.displayCraftingUseGoodsWindow(this,this.onClosePopup);
                  FarmStatsManager.count("cottage_ui_new","view_use_good_page","user_automatically_brought_to_page");
            }
         }
         if(!Global.player.getSeenFlag("cottagesV2Notif"))
         {
            Global.player.setSeenFlag("cottagesV2Notif");
            if(Global.player.getSeenFlag("recipeTut0"))
            {
               UI.displayMessage(ZLocUtils.t("Crafting","General_V2Notif"),GenericPopup.TYPE_OK,null,"",true);
            }
         }
         MarketViewManager.getInstance().addEventListener(MarketViewManager.MARKET_STALL_INVENTORY_LOADED,this.onMarketStallInventoryDataUpdated);
         this.checkShowSalesReport();
         FarmStatsManager.count("cottage_ui_new","view_makes_good_page");
      }
      
      private function populateFilterByDropDown() : void
      {
         var regionName:String = null;
         var regionNameFull:String = null;
         var sortByMenuItems:Array = [];
         for each(regionName in this.m_recipeSlotFrame.getRegionSufixArray())
         {
            regionNameFull = ZLocUtils.t("Dialogs",regionName + "_fullName");
            if(regionNameFull == "")
            {
               regionNameFull = regionName;
            }
            sortByMenuItems.push(new MenuItem(regionName,regionNameFull));
         }
         this.m_filterBy.setToggleState(ZwToggleState.DESELECTED);
         this.m_filterByMenu.visible = false;
         if(sortByMenuItems.length > 0)
         {
            this.m_filterByMenu.items = sortByMenuItems;
            this.m_filterBy.visible = true;
         }
         else
         {
            this.m_filterBy.visible = false;
         }
      }
      
      private function onFilterByMenuItemSelected(item:MenuItem) : void
      {
         this.m_filterBy.setToggleState(ZwToggleState.DESELECTED);
         this.m_filterByMenu.visible = false;
         if(this.m_filterByName != item.data)
         {
            this.m_filterByName = item.data as String;
            this.m_recipeSlotFrame.filterByOptionsChanged();
         }
      }
      
      private function onFilterByMouseOver(evt:MouseEvent) : void
      {
         if(!this.m_filterByMenu.visible)
         {
            this.m_filterBy.setToggleState(ZwToggleState.SELECTED);
            this.m_filterByMenu.visible = true;
         }
      }
      
      public function onSearchUpdate(searchString:String) : void
      {
         if(this.m_searchString != searchString)
         {
            this.m_searchString = searchString;
            this.m_recipeSlotFrame.filterOptionsChanged();
         }
      }
      
      public function getFilterByString() : String
      {
         return this.m_filterByName;
      }
      
      public function getSearchString() : String
      {
         return this.m_searchString;
      }
      
      private function onFilterByMouseOut(evt:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_filterBy.element as MovieClip,evt.relatedObject) && !FarmGameUtil.isDescendant(this.m_filterByMenu.element as MovieClip,evt.relatedObject))
         {
            this.m_filterBy.setToggleState(ZwToggleState.DESELECTED);
            this.m_filterByMenu.visible = false;
         }
      }
      
      public function onMarketStallInventoryDataUpdated(event:Event) : void
      {
         this.updateRecipeSlotFrame();
      }
      
      public function buyBushel(bushelId:String, recipeId:String) : void
      {
         CraftingManager.getInstance().onPurchaseBushel(bushelId,recipeId);
         this.m_recipeSlotFrame.refresh();
      }
      
      public function clearTutorial() : void
      {
         for(var i:int = 0; i < TUTORIAL_LAST_INDEX; i++)
         {
            Global.player.setSeenFlag("recipeTut" + i);
         }
         this.m_lastRequestedTutorialIndex = TUTORIAL_NOT_RUNNING;
      }
      
      private function checkShowSalesReport() : void
      {
         var tMarkSeen:TCottageHistorySeen = null;
         var slotFrameItems:Array = null;
         var historyItem:Object = null;
         var item:FarmItem = null;
         var uid:* = undefined;
         if(Boolean(this.cottage.transactionHistory) && this.cottage.transactionHistory.hasFreshTransactions())
         {
            tintWindow();
            enableInput = false;
            CraftingUI.displaySalesReportWindow(this.cottage,this.onClosePopup);
            this.cottage.transactionHistory.setViewed();
            tMarkSeen = new TCottageHistorySeen(this.cottage.craftType);
            TransactionManager.addTransaction(tMarkSeen);
            slotFrameItems = this.cottage.transactionHistory.getSlotFrameItems(false);
            for each(historyItem in slotFrameItems)
            {
               item = Global.farmGameSettingsManager.getFarmItemByCode(historyItem[CraftingConstants.LOGDATA_ITEMCODE]);
               for each(uid in historyItem[CraftingConstants.LOGDATA_UID])
               {
                  StatsManager.social("notify",String(uid),"craft_buy","craft",item.name,historyItem[CraftingConstants.LOGDATA_RECIPE_LVL]);
               }
            }
         }
      }
      
      override protected function release() : void
      {
         super.release();
         this.cottage = null;
         this.m_getGoodsFrame = null;
         this.m_getGoodsToolTip = null;
         this.m_useGoodsFrame = null;
         this.m_useGoodsToolTip = null;
         this.m_upgradeFrame = null;
         this.m_recipeSlotFrame = null;
         this.m_productionSlotFrame = null;
         for(var i:int = 0; i < this.m_starNamesArray.length; i++)
         {
            this.m_progressStarFrameArray[i] = null;
         }
         this.m_progressStarFrameArray = null;
         this.m_upgradeToolTip = null;
         this.m_buyUpgradeToolTip = null;
         this.m_animatingStar = null;
         this.m_filterBy = null;
         this.m_filterByMenu = null;
         this.m_filterByName = null;
         MarketViewManager.getInstance().removeEventListener(MarketViewManager.MARKET_STALL_INVENTORY_LOADED,this.onMarketStallInventoryDataUpdated);
      }
      
      public function enterFrame() : void
      {
         var deltaTime:Number = (GlobalEngine.currentTime - this.m_lastTime) / 33.333;
         this.m_lastTime = GlobalEngine.currentTime;
         if(m_window)
         {
            this.updateGetGoods();
            this.updateUseGoods();
            this.m_recipeSlotFrame.enterFrame(deltaTime);
            this.m_productionSlotFrame.enterFrame(deltaTime);
            if(m_window.frameUpgrade_mc.coinUpgrade_bt.visible)
            {
               this.m_sheenCurrentFrame = (this.m_sheenCurrentFrame + deltaTime) % this.m_sheenTotalFrames;
               if(m_window.frameUpgrade_mc.coinUpgrade_bt.sheen_mc)
               {
                  m_window.frameUpgrade_mc.coinUpgrade_bt.sheen_mc.gotoAndStop(int(this.m_sheenCurrentFrame));
               }
            }
            if(this.m_animatingStar)
            {
               this.m_animatingStarCurrentFrame += deltaTime;
               if(this.m_animatingStarCurrentFrame >= this.m_animatingStarTotalFrames)
               {
                  this.m_animatingStarCurrentFrame = 0;
                  this.m_animatingStar.gotoAndStop(int(this.m_animatingStarCurrentFrame));
                  this.m_animatingStar = null;
                  FreezeManager.pushPostThawCallback(this.generateCallback(this.cottage));
                  this.close();
               }
               else
               {
                  this.m_animatingStar.gotoAndStop(int(this.m_animatingStarCurrentFrame));
               }
            }
         }
      }
      
      private function generateCallback(cottageIn:CraftingCottageBuilding) : Function
      {
         return function():void
         {
            cottageIn.animateUpgrade();
         };
      }
      
      public function updateGetGoods() : void
      {
         var getGoodsVisible:Boolean = false;
         var numGetGoods:int = MarketViewManager.getInstance().getNumFriendsWithCraftedGoodsAvailable();
         if(this.m_numGetGoods != numGetGoods)
         {
            getGoodsVisible = numGetGoods != 0;
            this.m_numGetGoods = numGetGoods;
            m_window.goodsGet_mc.counterCircle_mc.visible = getGoodsVisible;
            m_window.goodsGet_mc.counter_tf.visible = getGoodsVisible;
            if(getGoodsVisible)
            {
               (this.m_getGoodsFrame.getWidget(m_window.goodsGet_mc.counter_tf) as ZwTextField).text = numGetGoods.toString();
               if(numGetGoods == 1)
               {
                  this.m_getGoodsToolTip.setText(ZLocUtils.t("Crafting","CraftingMain_GetGoodsFriendToolTip"));
               }
               else
               {
                  this.m_getGoodsToolTip.setText(ZLocUtils.t("Crafting","CraftingMain_GetGoodsFriendsToolTip",{"quantity":numGetGoods}));
               }
            }
            else
            {
               this.m_getGoodsToolTip.setText("");
            }
         }
      }
      
      public function updateUseGoods() : void
      {
         var useGoodsVisible:Boolean = false;
         var numUseGoods:int = Global.player.craftingState.totalCraftedGoods;
         if(this.m_numUseGoods != numUseGoods)
         {
            useGoodsVisible = numUseGoods != 0;
            this.m_numUseGoods = numUseGoods;
            m_window.goodsUse_mc.counterCircle_mc.visible = useGoodsVisible;
            m_window.goodsUse_mc.counter_tf.visible = useGoodsVisible;
            if(useGoodsVisible)
            {
               (this.m_useGoodsFrame.getWidget(m_window.goodsUse_mc.counter_tf) as ZwTextField).text = numUseGoods.toString();
               if(numUseGoods == 1)
               {
                  this.m_useGoodsToolTip.setText(ZLocUtils.t("Crafting","CraftingMain_UseGoodToolTip"));
               }
               else
               {
                  this.m_useGoodsToolTip.setText(ZLocUtils.t("Crafting","CraftingMain_UseGoodsToolTip",{"quantity":numUseGoods}));
               }
            }
            else
            {
               this.m_useGoodsToolTip.setText("");
            }
         }
      }
      
      public function updateUpgradeFrame() : void
      {
         var i:int = 0;
         var progressStarFrame:ZwFrame = null;
         var remainingExp:int = 0;
         var deltaExp:int = 0;
         var percentExp:Number = NaN;
         var meterPercent:Number = NaN;
         var currentRegionId:int = 0;
         var waitMessage:String = null;
         var statusMessage:String = null;
         var currentLevelInfo:CraftLevel = this.getCurrentCraftLevelInfo();
         var nextLevelInfo:CraftLevel = this.getNextCraftLevelInfo();
         var currentLevel:int = this.cottage.craftLevel;
         var maxCraftLevel:int = Global.craftConfigSettings.getMaxCraftLevel();
         for(i = 0; i < this.m_starNamesArray.length; i++)
         {
            progressStarFrame = this.m_progressStarFrameArray[i];
            if(currentLevel > i)
            {
               progressStarFrame.getWidget(m_window.frameUpgrade_mc[this.m_starNamesArray[i]].progressStarOff_mc).visible = false;
               progressStarFrame.getWidget(m_window.frameUpgrade_mc[this.m_starNamesArray[i]].progressStarOn_mc).visible = true;
            }
            else
            {
               progressStarFrame.getWidget(m_window.frameUpgrade_mc[this.m_starNamesArray[i]].progressStarOff_mc).visible = true;
               progressStarFrame.getWidget(m_window.frameUpgrade_mc[this.m_starNamesArray[i]].progressStarOn_mc).visible = false;
            }
         }
         if(nextLevelInfo)
         {
            remainingExp = nextLevelInfo.experience - this.getCraftTypeState().experience;
            deltaExp = nextLevelInfo.experience;
            percentExp = (deltaExp - Math.max(0,remainingExp)) / deltaExp;
            meterPercent = Math.min(currentLevel - 1 + percentExp,currentLevel) / (maxCraftLevel - 1);
            currentRegionId = WorldSeasonsManager.getInstance().getCurrentSeason(Global.worldManager.currentWorldType);
            waitMessage = ZLocUtils.t("Dialogs","CraftingCottageLockedMessageForRegion" + currentRegionId);
            m_window.frameUpgrade_mc.meter_mc.bar_mc.width = m_window.frameUpgrade_mc.meter_mc.width * meterPercent;
            if(remainingExp > 0)
            {
               statusMessage = ZLocUtils.t("Crafting","CraftingMain_CoinUpgradeMessage",{"quantity":remainingExp});
               m_window.frameUpgrade_mc.coinUpgrade_bt.visible = false;
               m_window.frameUpgrade_mc.buyUpgrade_bt.visible = true;
               if(nextLevelInfo.prereqName != "" && !PrerequisiteUtility.checkPrereqByName(nextLevelInfo.prereqName))
               {
                  (this.m_upgradeFrame.getWidget(m_window.frameUpgrade_mc.buyUpgrade_bt) as FarmAnimatedTextButton).toggleClickableButton(false,waitMessage);
               }
            }
            else
            {
               statusMessage = ZLocUtils.t("Crafting","CraftingMain_CoinUpgradeReady");
               m_window.frameUpgrade_mc.coinUpgrade_bt.visible = true;
               m_window.frameUpgrade_mc.buyUpgrade_bt.visible = false;
               if(nextLevelInfo.prereqName != "" && !PrerequisiteUtility.checkPrereqByName(nextLevelInfo.prereqName))
               {
                  (this.m_upgradeFrame.getWidget(m_window.frameUpgrade_mc.coinUpgrade_bt) as FarmAnimatedTextButton).toggleClickableButton(false,waitMessage);
               }
            }
         }
         else
         {
            statusMessage = ZLocUtils.t("Crafting","CraftingCottages_MaxLevelMessage");
            m_window.frameUpgrade_mc.meter_mc.bar_mc.width = m_window.frameUpgrade_mc.meter_mc.width;
            m_window.frameUpgrade_mc.coinUpgrade_bt.visible = false;
            m_window.frameUpgrade_mc.buyUpgrade_bt.visible = false;
         }
         m_window.frameUpgrade_mc.upgradeMessage_tf.text = statusMessage;
         this.m_upgradeToolTip.setText(statusMessage);
         if(currentLevel < maxCraftLevel)
         {
            this.m_buyUpgradeToolTip.setText(ZLocUtils.t("Crafting","CraftingCottagesLevel" + (currentLevel + 1) + "_CashUpgradeTooltip",{
               "quantity":nextLevelInfo.cashCost,
               "item":ZLocUtils.tk("Items","crafting" + this.cottage.craftType + "_friendlyName"),
               "slot":ZLocUtils.tk("Items",this.cottage.craftType + "Slot_friendlyName")
            }));
         }
      }
      
      public function updateRecipeSlotFrame() : void
      {
         if(this.m_recipeSlotFrame)
         {
            this.m_recipeSlotFrame.updateSlots();
         }
      }
      
      public function updateProductionSlotFrame() : void
      {
         this.m_productionSlotFrame.updateSlots(this.cottage.recipeQueue);
      }
      
      private function onMoreInfoClick(event:MouseEvent) : void
      {
         tintWindow();
         enableInput = false;
         TutorialUI.displayCraftingCottageTutorial2Window(false,this.onClosePopup);
      }
      
      private function onMoreInfoClickWithAlternateTut(event:MouseEvent) : void
      {
         var tutorialAssetPath:String = Global.craftConfigSettings.getTutorialAssetPath(this.cottage.craftType);
         UI.displayPopup(new FarmWindowWithTutorial(this.cottage.getItemName(),tutorialAssetPath,4,true,false,true,true),false);
      }
      
      public function pressInventory(event:MouseEvent) : void
      {
         var dialogClass:Class = null;
         var dialog:* = undefined;
         var dialogClassCash:Class = null;
         var dialogCash:* = undefined;
         var dialogClassName:String = "Widgets.Windows.Crafting.HomeMarketStallWindow";
         var marketStalls:Array = Global.world.getObjectsByCode("mc");
         var marketStallsCash:Array = Global.world.getObjectsByCode("ms");
         if(marketStalls.length > 0)
         {
            dialogClass = getDefinitionByName(dialogClassName) as Class;
            dialog = new dialogClass(marketStalls[0]);
            UI.displayPopup(dialog,true,dialogClassName,true);
            this.close();
         }
         else if(marketStallsCash.length > 0)
         {
            dialogClassCash = getDefinitionByName(dialogClassName) as Class;
            dialogCash = new dialogClassCash(marketStallsCash[0]);
            UI.displayPopup(dialogCash,true,dialogClassName,true);
            this.close();
         }
         else
         {
            this.close();
            UI.displayMessage("Place a Market Stall on this farm in order to access inventory");
            UI.displayMiniMarketDialog(["marketstall"]);
         }
      }
      
      private function onMySalesClick(event:MouseEvent) : void
      {
         tintWindow();
         enableInput = false;
         CraftingUI.displayCraftingMySalesWindow(this.cottage,this.onClosePopup);
      }
      
      private function onGetGoodsClick(event:MouseEvent) : void
      {
         tintWindow();
         enableInput = false;
         TutorialUI.closeTutorialWindow();
         CraftingUI.displayCraftingGetGoodsWindow(this.onClosePopup);
      }
      
      private function onGetGoodsOver(event:MouseEvent) : void
      {
         (this.m_getGoodsFrame.getWidget(m_window.goodsGet_mc.on_mc) as ZwWidget).visible = false;
         (this.m_getGoodsFrame.getWidget(m_window.goodsGet_mc.over_mc) as ZwWidget).visible = true;
      }
      
      private function onGetGoodsOut(event:MouseEvent) : void
      {
         (this.m_getGoodsFrame.getWidget(m_window.goodsGet_mc.on_mc) as ZwWidget).visible = true;
         (this.m_getGoodsFrame.getWidget(m_window.goodsGet_mc.over_mc) as ZwWidget).visible = false;
      }
      
      private function onUseGoodsClick(event:MouseEvent) : void
      {
         tintWindow();
         enableInput = false;
         TutorialUI.closeTutorialWindow();
         CraftingUI.displayCraftingUseGoodsWindow(this,this.onClosePopup);
      }
      
      private function onClosePopup() : void
      {
         untintWindow();
         enableInput = true;
         this.enableWindow(true);
      }
      
      private function onUseGoodsOver(event:MouseEvent) : void
      {
         (this.m_useGoodsFrame.getWidget(m_window.goodsUse_mc.on_mc) as ZwWidget).visible = false;
         (this.m_useGoodsFrame.getWidget(m_window.goodsUse_mc.over_mc) as ZwWidget).visible = true;
      }
      
      private function onUseGoodsOut(event:MouseEvent) : void
      {
         (this.m_useGoodsFrame.getWidget(m_window.goodsUse_mc.on_mc) as ZwWidget).visible = true;
         (this.m_useGoodsFrame.getWidget(m_window.goodsUse_mc.over_mc) as ZwWidget).visible = false;
      }
      
      private function onCoinUpgrade(event:MouseEvent) : void
      {
         var nextLevelInfo:CraftLevel = this.getNextCraftLevelInfo();
         var nextLevelStatus:String = ZLocUtils.t("Crafting","CraftingCottages_Status" + nextLevelInfo.level);
         var statusMessage:String = CraftingManager.getCraftingStatusCottageNameLocString(nextLevelInfo.level,this.cottage.craftType);
         var message:String = ZLocUtils.t("Crafting","Cottage_Upgrade_Message",{
            "cottage":ZLocUtils.tk_pk(this.cottage.getItemFriendlyName()),
            "craftingCottageStatus":nextLevelStatus,
            "quantity":nextLevelInfo.goldCost,
            "craftingStatusCottageName":statusMessage
         });
         tintWindow();
         enableInput = false;
         UI.displayMessage(message,GenericPopup.TYPE_ASKBUY,this.onCloseCoinUpgrade,"",true);
      }
      
      private function onCloseCoinUpgrade(event:GenericPopupEvent) : void
      {
         untintWindow();
         enableInput = true;
         if(event.button == GenericPopup.ACCEPT)
         {
            if(CraftingManager.getInstance().buyCraftTypeUpgrade(this.cottage.craftType,false))
            {
               SoundManager.playSound(m_soundNameArray[this.cottage.craftLevel]);
               this.m_animatingStar = m_window.frameUpgrade_mc[this.m_starNamesArray[this.getCurrentCraftLevelInfo().level - 1]].progressStarBurst_mc;
            }
         }
         this.updateUpgradeFrame();
      }
      
      private function onBuyUpgrade(event:MouseEvent) : void
      {
         var nextLevelInfo:CraftLevel = this.getNextCraftLevelInfo();
         var nextLevelStatus:String = ZLocUtils.t("Crafting","CraftingCottages_Status" + nextLevelInfo.level);
         var statusMessage:String = CraftingManager.getCraftingStatusCottageNameLocString(nextLevelInfo.level,this.cottage.craftType);
         var message:String = ZLocUtils.t("Crafting","Cottage_InstantUpgrade_Message",{
            "cottage":ZLocUtils.tk_pk(this.cottage.getItemFriendlyName()),
            "craftingCottageStatus":nextLevelStatus,
            "quantity":nextLevelInfo.cashCost,
            "craftingStatusCottageName":statusMessage
         });
         tintWindow();
         enableInput = false;
         UI.displayMessageWithOffset(message,new Point(CraftingManager.CRAFTING_COTTAGE_POPUP_OFFSET_X,CraftingManager.CRAFTING_COTTAGE_POPUP_OFFSET_Y),GenericPopup.TYPE_ASKBUY,this.onCloseBuyUpgrade,"",true);
      }
      
      private function onCloseBuyUpgrade(event:GenericPopupEvent) : void
      {
         var meterPercent:Number = NaN;
         untintWindow();
         enableInput = true;
         if(event.button == GenericPopup.ACCEPT)
         {
            SoundManager.playSound(m_soundNameArray[this.cottage.craftLevel]);
            meterPercent = this.getCurrentCraftLevelInfo().level / 4;
            TweenLite.to(m_window.frameUpgrade_mc.meter_mc.bar_mc,0.5,{
               "width":m_window.frameUpgrade_mc.meter_mc.width * meterPercent,
               "onComplete":this.onCloseBuyUpgradeComplete
            });
            CraftingManager.getInstance().buyCraftTypeUpgrade(this.cottage.craftType,true);
         }
      }
      
      private function onCloseBuyUpgradeComplete() : void
      {
         this.m_animatingStar = m_window.frameUpgrade_mc[this.m_starNamesArray[this.getCurrentCraftLevelInfo().level - 1]].progressStarBurst_mc;
      }
      
      private function getCraftCategoryName() : String
      {
         return ZLocUtils.t("Crafting","CraftedGoodMarketViewDialog_Category_" + this.cottage.craftType);
      }
      
      private function getCurrentCraftLevelInfo() : CraftLevel
      {
         return Global.craftConfigSettings.getCraftLevel(this.cottage.craftLevel);
      }
      
      private function getNextCraftLevelInfo() : CraftLevel
      {
         return Global.craftConfigSettings.getCraftLevel(this.cottage.craftLevel + 1,this.cottage.craftType);
      }
      
      private function getCraftTypeState() : CraftTypeState
      {
         return Global.player.craftingState.craftingSkillState.getCraftTypeState(this.cottage.craftType);
      }
      
      override public function centerPopup(pAbsolutePos:Point = null) : void
      {
         var bounds:Rectangle = this.getBounds(this);
         if(parent)
         {
            this.x = (Global.stage.stageWidth - bounds.width - bounds.x) / 2;
            this.y = 13 + (Global.stage.stageHeight - bounds.height - bounds.y) / 2;
         }
      }
      
      public function findEmptySlot() : int
      {
         return this.m_productionSlotFrame.findEmptySlot();
      }
      
      public function enableWindow(enable:Boolean) : void
      {
         m_window.close_bt.enabled = enable;
         (getWidget(m_window.moreInfo_bt) as FarmAnimatedTextButton).enabled = enable;
         (getWidget(m_window.mySales_bt) as FarmAnimatedTextButton).enabled = enable;
         (this.m_upgradeFrame.getWidget(m_window.frameUpgrade_mc.coinUpgrade_bt) as FarmAnimatedTextButton).enabled = enable;
         (this.m_upgradeFrame.getWidget(m_window.frameUpgrade_mc.buyUpgrade_bt) as FarmAnimatedTextButton).enabled = enable;
         this.m_productionSlotFrame.setEnabled(enable);
         this.m_recipeSlotFrame.setEnabled(enable);
         this.m_getGoodsFrame.enabled = enable;
         this.m_useGoodsFrame.enabled = enable;
      }
      
      public function isInTutorial() : Boolean
      {
         return Global.player.getSeenFlag("recipeTut0") && !Global.player.getSeenFlag("recipeTut10");
      }
      
      public function displayTutorialMessage(tutorialIndex:int) : void
      {
         if(!this.m_stateError && !Global.player.getSeenFlag("recipeTut" + tutorialIndex.toString()))
         {
            Global.player.setSeenFlag("recipeTut" + tutorialIndex.toString());
            this.m_lastRequestedTutorialIndex = tutorialIndex;
            switch(tutorialIndex)
            {
               case TUTORIAL_INTRO:
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","see_tutorial_intro");
                  tintWindow();
                  enableInput = false;
                  TutorialUI.displayCraftingTutorialWindow(this.cottage.craftType,this.startTutorial,this.skipTutorial);
                  break;
               case TUTORIAL_MAKE_IT:
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_1st_start_tutorial");
                  this.enableWindow(false);
                  this.m_recipeSlotFrame.setEnabled(true,0);
                  TutorialUI.addBouncingArrows(m_window,new Matrix(0,1,1,0,m_window.x + 500,m_window.y + 233),new Matrix(0,1,-1,0,m_window.x + 740,m_window.y + 233));
                  TutorialUI.displayTutorialWindow(this.getCratingTutorialMakeText(),new Point(0,-200),this.skipTutorial);
                  break;
               case TUTORIAL_FINISH_IT:
                  TutorialUI.closeTutorialWindow();
                  TutorialUI.removeBouncingArrows(m_window);
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_2nd_make_it");
                  this.m_recipeSlotFrame.setEnabled(false);
                  this.m_productionSlotFrame.setEnabled(true,0);
                  TutorialUI.addBouncingArrows(m_window,new Matrix(0,1,1,0,m_window.x - 60,m_window.y + 90),new Matrix(0,1,-1,0,m_window.x + 190,m_window.y + 90));
                  TutorialUI.displayTutorialWindow(this.getCraftingTutorialFinishText(),new Point(0,-200),this.skipTutorial);
                  break;
               case TUTORIAL_GET_BUSHELS:
                  TutorialUI.closeTutorialWindow();
                  TutorialUI.removeBouncingArrows(m_window);
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_3rd_finish_it");
                  this.enableWindow(false);
                  this.m_recipeSlotFrame.setEnabled(true,0);
                  TutorialUI.addBouncingArrows(m_window,new Matrix(0,1,1,0,m_window.x + 485,m_window.y + 233),new Matrix(0,1,-1,0,m_window.x + 755,m_window.y + 233));
                  TutorialUI.displayTutorialWindow(this.getCraftingTutorialGetBushelsText(),new Point(0,-200),this.skipTutorial);
                  break;
               case TUTORIAL_SHOPPING_LIST:
                  TutorialUI.closeTutorialWindow();
                  TutorialUI.removeBouncingArrows(m_window);
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_4th_get_bushels");
                  TutorialUI.displayTutorialAcceptButtonWindow(ZLocUtils.t("Crafting","CraftingTutorial_ShoppingList"),ZLocUtils.t("Crafting","CraftingTutorial_NextStep"),new Point(0,100),this.closeShopping,this.skipTutorial);
                  break;
               case TUTORIAL_MARKET_STALL:
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_5th_next");
                  TutorialUI.displayTutorialAcceptButtonWindow(ZLocUtils.t("Crafting","CraftingTutorial_MarketStall"),ZLocUtils.t("Crafting","CraftingTutorial_NextStep"),new Point(-170,-200),this.closeMarket,this.skipTutorial);
                  break;
               case TUTORIAL_GET_GOODS:
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_6th_next");
                  this.enableWindow(false);
                  this.m_getGoodsFrame.enabled = true;
                  TutorialUI.addBouncingArrows(m_window,new Matrix(0,1,1,0,m_window.x - 60,m_window.y + 15),new Matrix(0,1,-1,0,m_window.x + 185,m_window.y + 15));
                  TutorialUI.displayTutorialWindow(this.getCraftingTutorialGetGoodsText(),new Point(0,-100),this.skipTutorial);
                  break;
               case TUTORIAL_AVAILABLE_GOODS:
                  TutorialUI.closeTutorialWindow();
                  TutorialUI.removeBouncingArrows(m_window);
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_7th_get_goods");
                  TutorialUI.displayTutorialAcceptButtonWindow(ZLocUtils.t("Crafting","CraftingTutorial_AvailableGoods"),ZLocUtils.t("Crafting","CraftingTutorial_NextStep"),new Point(0,100),this.closeGetGoods,this.skipTutorial);
                  break;
               case TUTORIAL_USE_GOODS:
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_8th_next");
                  this.enableWindow(false);
                  this.m_useGoodsFrame.enabled = true;
                  TutorialUI.addBouncingArrows(m_window,new Matrix(0,1,1,0,m_window.x + 50,m_window.y + 15),new Matrix(0,1,-1,0,m_window.x + 295,m_window.y + 15));
                  TutorialUI.displayTutorialWindow(ZLocUtils.t("Crafting","CraftingTutorial_UseGoods"),new Point(0,-100),this.skipTutorial);
                  break;
               case TUTORIAL_TRADE_FOR_FUEL:
                  TutorialUI.closeTutorialWindow();
                  TutorialUI.removeBouncingArrows(m_window);
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_9th_use_goods");
                  TutorialUI.displayTutorialWindow(ZLocUtils.t("Crafting","CraftingTutorial_TradeForFuel"),new Point(0,100),this.skipTutorial);
                  break;
               case TUTORIAL_FINISH:
                  TutorialUI.closeTutorialWindow();
                  TutorialUI.removeBouncingArrows(m_window);
                  FarmStatsManager.count("crafting_cottages_new","on_rails_tutorial_new","click_10th_use");
                  TutorialUI.displayTutorialTitleButtonWindow(ZLocUtils.t("Crafting","CraftingTutorial_Finish_Title"),ZLocUtils.t("Crafting","CraftingTutorial_Finish_Message"),ZLocUtils.t("Crafting","General_Okay"),this.finishTutorial);
                  break;
               default:
                  untintWindow();
                  this.enableWindow(true);
                  enableInput = true;
            }
         }
      }
      
      private function getCratingTutorialMakeText() : String
      {
         var failoverEntryArray:Array = new Array(new ZLocFailoverEntry("Crafting","CraftingTutorial_Make_" + this.cottage.craftType),new ZLocFailoverEntry("Crafting","CraftingTutorial_Make_failoverDefault"));
         var recipeFarmItem:FarmItem = Global.craftConfigSettings.getTutorialRecipeItem(this.cottage.craftType);
         return ZLocUtils.getFailoverLocString(failoverEntryArray,{"recipe_name":recipeFarmItem.friendlyTitle});
      }
      
      private function getCraftingTutorialFinishText() : String
      {
         var failoverEntryArray:Array = new Array(new ZLocFailoverEntry("Crafting","CraftingTutorial_Finish_" + this.cottage.craftType),new ZLocFailoverEntry("Crafting","CraftingTutorial_Finish_failoverDefault"));
         var recipeFarmItem:FarmItem = Global.craftConfigSettings.getTutorialRecipeItem(this.cottage.craftType);
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeFarmItem.code);
         var cookTime:String = recipeItem.getCookTimeText(recipeItem.secondsToCook,"Crafting","CraftingMain_Hours","CraftingMain_Mins","CraftingMain_Secs");
         return ZLocUtils.getFailoverLocString(failoverEntryArray,{
            "recipe_name":recipeFarmItem.friendlyTitle,
            "cook_time":cookTime
         });
      }
      
      private function getCraftingTutorialGetBushelsText() : String
      {
         var failoverEntryArray:Array = new Array(new ZLocFailoverEntry("Crafting","CraftingTutorial_GetBushels_" + this.cottage.craftType),new ZLocFailoverEntry("Crafting","CraftingTutorial_GetBushels_failoverDefault"));
         return ZLocUtils.getFailoverLocString(failoverEntryArray,{"slot_name":this.cottage.slotName});
      }
      
      private function getCraftingTutorialGetGoodsText() : String
      {
         var failoverEntryArray:Array = new Array(new ZLocFailoverEntry("Crafting","CraftingTutorial_GetGoods_" + this.cottage.craftType),new ZLocFailoverEntry("Crafting","CraftingTutorial_GetGoods_failoverDefault"));
         var recipeFarmItem:FarmItem = Global.craftConfigSettings.getTutorialRecipeItem(this.cottage.craftType);
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeFarmItem.code);
         var cookTime:String = recipeItem.getCookTimeText(recipeItem.secondsToCook,"Crafting","CraftingMain_Hours","CraftingMain_Mins","CraftingMain_Secs");
         return ZLocUtils.getFailoverLocString(failoverEntryArray,{
            "recipe_name":recipeFarmItem.friendlyTitle,
            "cook_time":cookTime
         });
      }
      
      private function startTutorial() : void
      {
         this.onClosePopup();
         if(this.assertTutorialIndexIs(CraftingMainWindow.TUTORIAL_INTRO))
         {
            this.displayTutorialMessage(TUTORIAL_MAKE_IT);
         }
      }
      
      private function closeShopping() : void
      {
         var friends:Array = null;
         var friend:Dictionary = null;
         var bushelCodes:Array = MarketViewManager.getInstance().getAllBushelCodesAvailable();
         if(bushelCodes.length > 0)
         {
            friends = MarketViewManager.getInstance().getFriendsWithBushel(bushelCodes[0]);
            friend = friends[0];
            CraftingUI.displayVisitingMarketStallWindow(friend["uid"],"bushels");
         }
         else
         {
            CraftingUI.closeShoppingListWindow();
            this.onClosePopup();
            if(this.assertTutorialIndexIs(CraftingMainWindow.TUTORIAL_SHOPPING_LIST))
            {
               this.displayTutorialMessage(TUTORIAL_GET_GOODS);
            }
         }
      }
      
      private function closeMarket() : void
      {
         CraftingUI.closeVisitingMarketStallWindow();
         CraftingUI.closeShoppingListWindow();
         this.onClosePopup();
         this.displayTutorialMessage(TUTORIAL_GET_GOODS);
      }
      
      private function closeGetGoods() : void
      {
         CraftingUI.closeCraftingGetGoodsWindow();
         this.onClosePopup();
         this.displayTutorialMessage(TUTORIAL_USE_GOODS);
      }
      
      private function skipTutorial() : void
      {
         this.clearTutorial();
         TutorialUI.removeBouncingArrows(m_window);
         this.onClosePopup();
         CraftingManager.getInstance().inTutorialMode = false;
      }
      
      private function finishTutorial(event:Event = null) : void
      {
         this.clearTutorial();
         TutorialUI.removeBouncingArrows(m_window);
         CraftingManager.getInstance().inTutorialMode = false;
         this.onClosePopup();
         this.close();
      }
      
      protected function onStartTutorialTimer(event:TimerEvent) : void
      {
         m_window.enabled = true;
         if(this.assertTutorialIndexIs(CraftingMainWindow.TUTORIAL_NOT_RUNNING))
         {
            this.displayTutorialMessage(TUTORIAL_INTRO);
         }
         if(Boolean(this.m_showTutorialTimer) && this.m_showTutorialTimer.hasEventListener(TimerEvent.TIMER_COMPLETE))
         {
            this.m_showTutorialTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onStartTutorialTimer);
         }
         this.m_showTutorialTimer = null;
      }
      
      public function closeTutorialWindow(force:Boolean = false) : void
      {
         if(this.isInTutorial() || force)
         {
            TutorialUI.closeTutorialWindow();
            TutorialUI.closeTutorialAcceptButtonWindow();
            TutorialUI.closeTutorialTitleButtonWindow();
            TutorialUI.removeBouncingArrows(m_window);
            CraftingUI.closeShoppingListWindow();
            CraftingUI.closeVisitingMarketStallWindow();
            CraftingUI.closeCraftingGetGoodsWindow();
            CraftingUI.closeCraftingUseGoodsWindow();
         }
      }
      
      override public function close() : void
      {
         if(Boolean(m_window) && Boolean(m_window.close_bt.enabled))
         {
            this.closeTutorialWindow();
            super.close();
         }
         if(Boolean(this.m_showTutorialTimer) && this.m_showTutorialTimer.hasEventListener(TimerEvent.TIMER_COMPLETE))
         {
            this.m_showTutorialTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onStartTutorialTimer);
         }
         this.m_showTutorialTimer = null;
      }
   }
}

