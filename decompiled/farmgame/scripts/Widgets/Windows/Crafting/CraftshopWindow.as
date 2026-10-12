package Widgets.Windows.Crafting
{
   import Classes.Constants.Experiments;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.DailyStatsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Buttons.FarmTabButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftshopExpandFrame;
   import Widgets.Frames.Crafting.CraftshopFriendFrame;
   import Widgets.Frames.Crafting.CraftshopOvenFrame;
   import Widgets.Frames.Crafting.CraftshopRecipeFrame;
   import Widgets.Frames.SearchFrame;
   import Widgets.Menu.DropDownMenu;
   import Widgets.Menu.FarmTabMenu;
   import Widgets.Menu.MenuItem;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   
   public class CraftshopWindow extends FarmWindow
   {
      
      private static var CRAFTSHOP_COUNTER:String = "craftshop";
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static var lastOpenTab:String = "";
      
      private static var lastSortOption:String = "startDate";
      
      private static var lastSortDirection:String = "desc";
      
      private static const SEEN_CRAFTSHOP_SESSION_FLAG:String = "sawCraftshop";
      
      private static const FTUE_FLAG:String = "ftueCraftshop";
      
      private static const FTUE_RECIPE_CRAFT_FLAG:String = "ftueRecipeCraftshop";
      
      public static const CRAFTSHOP_TUTORIAL_EVENT:String = "craftshopTutorialBegin";
      
      public static const CRAFTSHOP_TUTORIAL_EVENT_END:String = "craftshopTutorialEnd";
      
      private static const CRAFTSHOP_PART_TAB:String = "part";
      
      protected var m_building:FeatureBuilding = null;
      
      protected var m_featureName:String = "";
      
      protected var m_recipeFrame:CraftshopRecipeFrame = null;
      
      protected var m_ovenFrame:CraftshopOvenFrame = null;
      
      protected var m_friendFrame:CraftshopFriendFrame = null;
      
      protected var m_expandFrame:CraftshopExpandFrame = null;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      private var m_recipeItem:RecipeItem = null;
      
      protected var m_searchFrame:SearchFrame = null;
      
      private var m_searchString:String = "";
      
      private var m_bushelSearchingVariant:int = 0;
      
      private var m_masteryStarsTooltip:FarmTextTooltip = null;
      
      private var m_selectedTab:String = "";
      
      private var m_sortDirection:String = lastSortDirection;
      
      private const MENU_PREFIX:String = "menu_";
      
      private const SORT_PREFIX:String = "sort_";
      
      private var m_recipeUI:RecipeItemWindow;
      
      private var m_overlay_mc:ZwFrame;
      
      private var m_defaultRecipe:String = null;
      
      private var m_sortByButton:FarmTabButton;
      
      private var m_sortByMenu:DropDownMenu;
      
      private var m_sortBy:String = lastSortOption;
      
      private var m_tutorial:ZwFrame;
      
      private var m_recipeWindowTutorial:ZwFrame;
      
      private var m_tutorialButton:FarmAnimatedTextButton;
      
      private var m_FTUEMovieClip:MovieClip;
      
      private var m_tutorialScene:int;
      
      private var m_shouldUseNewCraftshop:Boolean = CraftingManager.shouldUseNewCraftshopInFeature(this.m_featureName);
      
      private var m_finishRecipeCallback:Function = null;
      
      public function CraftshopWindow(building:FeatureBuilding, featureName:String = "craftingworkshopbuilding", showDefaultRecipe:String = null, searchString:String = "", selectTab:String = null, finishRecipeCallback:Function = null)
      {
         this.m_building = building;
         this.m_featureName = featureName;
         this.m_selectedTab = selectTab == null ? lastOpenTab : selectTab;
         this.m_defaultRecipe = showDefaultRecipe;
         this.m_searchString = searchString;
         this.m_finishRecipeCallback = finishRecipeCallback;
         this.setDefaultTab();
         super(this.getDialogAsset());
         MarketViewManager.getInstance().beginFetchLatestMarketInventory();
      }
      
      public static function resetPreviousSelections() : void
      {
         lastOpenTab = "";
         lastSortOption = "";
      }
      
      private static function displayNotificationForRecipe(recipeItem:RecipeItem) : void
      {
         var pos:Point = new Point(Global.stage.mouseX + 10,Global.stage.mouseY + 10);
         var fontColor:uint = 16776960;
         UI.displayStatus("+1",pos.x,pos.y,Global.getAssetURL(recipeItem.image),null,UI.DEFAULT_STATUS_TWEEN_DURATION,UI.DEFAULT_STATUS_TWEEN_DISPLACEMENT,UI.DEFAULT_STATUS_TWEEN_FONT_SIZE,fontColor);
      }
      
      private function setDefaultTab() : void
      {
         if(!Global.player.getSeenSessionFlag(SEEN_CRAFTSHOP_SESSION_FLAG) && this.m_selectedTab == "")
         {
            this.m_selectedTab = CRAFTSHOP_PART_TAB;
         }
      }
      
      protected function getDialogAsset() : String
      {
         var asset:String = this.m_building.getFarmItem().getDialogConfig("storage").path;
         this.m_bushelSearchingVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_BUSHEL_SORTING);
         if(this.m_bushelSearchingVariant != 0)
         {
            asset = "assets/dialogs/FV_Craftshop_Mainv7.swf";
         }
         else if(this.m_shouldUseNewCraftshop)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CRAFITNG_UI_PLANT_BUTTON) == 1)
            {
               asset = "assets/dialogs/FV_Craft_Shop_v4.swf";
            }
            else
            {
               asset = "assets/dialogs/FV_Craft_Shop_v2.swf";
            }
         }
         return asset;
      }
      
      override protected function postLoadComplete() : void
      {
         var craftSkill:String = null;
         var callBackObject:Object = null;
         var firstTimeSeenFlag:String = null;
         var subMenu:FarmTabMenu = null;
         var tabs:Array = null;
         var items:Array = null;
         var selectedTab:int = 0;
         var i:int = 0;
         var tab:String = null;
         super.postLoadComplete();
         if(m_window)
         {
            if(m_window.hasOwnProperty("title_tf"))
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","CraftshopWindow_title")));
            }
            if(m_window.hasOwnProperty("moreInfo_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window.moreInfo_bt,ZLocUtils.t("Dialogs","CraftshopWindow_moreInfo_btn"),this.pressMoreInfo));
            }
            if(this.m_bushelSearchingVariant != 0 && m_window.hasOwnProperty("inventory_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window.inventory_bt,ZLocUtils.t("Dialogs","CraftshopWindow_inventory_btn"),this.pressInventory));
            }
            if(m_window.hasOwnProperty("totalStars_tf"))
            {
               addWidget(new ZwTextField(m_window.totalStars_tf));
               this.setupStarCountTF();
            }
            if(m_window.hasOwnProperty("frame_expand_mc"))
            {
               this.m_expandFrame = addWidget(new CraftshopExpandFrame(m_window.frame_expand_mc,this,this.m_building,this.m_featureName)) as CraftshopExpandFrame;
            }
            craftSkill = this.m_building.getItem().craftType;
            if(m_window.hasOwnProperty("workstations_mc"))
            {
               this.m_ovenFrame = addWidget(new CraftshopOvenFrame(m_window.workstations_mc,this,craftSkill,this.m_featureName)) as CraftshopOvenFrame;
            }
            callBackObject = {
               "makeRecipe":this.makeRecipe,
               "searchString":this.getSearchString,
               "getSortInfo":this.getSortInfo,
               "finishRecipe":this.finishRecipe,
               "finishRecipeRushed":this.finishRecipeRushed,
               "buyIngredients":this.buyIngredients,
               "buyBushel":this.buyBushel,
               "askForBushel":this.askForBushel,
               "getBushels":this.getBushels,
               "canMakeRecipeInThisWorld":this.canMakeRecipeInThisWorld,
               "openRecipeUI":this.openRecipeUI,
               "closeMainWindow":this.close
            };
            if(m_window.hasOwnProperty("subNav_mc"))
            {
               subMenu = addWidget(new FarmTabMenu(m_window.subNav_mc,this.onSubMenuItemSelected,null,true)) as FarmTabMenu;
               tabs = Global.craftConfigSettings.getCraftSkillDataForKey(craftSkill,"tabs");
               items = new Array();
               if(tabs)
               {
                  selectedTab = 0;
                  for(i = 0; i < tabs.length; i++)
                  {
                     tab = tabs[i];
                     items.push(new MenuItem(tab,ZLocUtils.t("Crafting",this.MENU_PREFIX + tab)));
                     if(tab == this.m_selectedTab)
                     {
                        selectedTab = i;
                     }
                  }
                  subMenu.items = items;
                  subMenu.selectTab(selectedTab);
               }
               if(m_window.hasOwnProperty("crafting_mc"))
               {
                  addWidget(this.m_recipeUI = new RecipeItemWindow(m_window.crafting_mc,callBackObject));
                  this.m_recipeUI.visible = false;
               }
               if(m_window.hasOwnProperty("overlay_mc"))
               {
                  addWidget(this.m_overlay_mc = new ZwFrame(m_window.overlay_mc));
                  this.m_overlay_mc.visible = false;
               }
               if(m_window.hasOwnProperty("sortBy_bt"))
               {
                  this.m_sortByButton = addWidget(new FarmTabButton(m_window.sortBy_bt,ZLocUtils.t("Dialogs","SortBy"))) as FarmTabButton;
                  (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onSortByMouseOver,false,0,true);
                  (this.m_sortByButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
                  this.m_sortByMenu = addWidget(new DropDownMenu(m_window.frame_subNav2_mc,this.onSortByMenuItemSelected),false) as DropDownMenu;
                  (this.m_sortByMenu.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onSortByMouseOut,false,0,true);
                  this.populateSortDropDown(craftSkill);
               }
               if(m_window.hasOwnProperty("howDoes_mc"))
               {
                  addWidget(new FarmButton(m_window.howDoes_mc,this.showTutorial) as FarmButton);
               }
               if(m_window.hasOwnProperty("mc_tutorial"))
               {
                  this.m_tutorial = addWidget(new ZwFrame(m_window.mc_tutorial),false) as ZwFrame;
               }
               if(m_window.hasOwnProperty("mc_tutorial_Plant"))
               {
                  this.m_recipeWindowTutorial = addWidget(new ZwFrame(m_window.mc_tutorial_Plant),false) as ZwFrame;
               }
            }
            if(m_window.hasOwnProperty("frameRecipes_mc"))
            {
               this.m_recipeFrame = addWidget(new CraftshopRecipeFrame(m_window.frameRecipes_mc,callBackObject,craftSkill,this.m_selectedTab,this.m_featureName)) as CraftshopRecipeFrame;
            }
            if(m_window.hasOwnProperty("friendBucket_mc"))
            {
               this.m_friendFrame = addWidget(new CraftshopFriendFrame(m_window.friendBucket_mc,this)) as CraftshopFriendFrame;
            }
            if(m_window.hasOwnProperty("searchBar_mc"))
            {
               this.m_searchFrame = addWidget(new SearchFrame(m_window.searchBar_mc,this.onSearchUpdate,this.m_searchString)) as SearchFrame;
            }
            this.showExpandFrame(false);
            Global.player.setSeenSessionFlag(SEEN_CRAFTSHOP_SESSION_FLAG);
            firstTimeSeenFlag = this.m_featureName + FTUE_FLAG;
            if(!Global.player.getSeenFlag(firstTimeSeenFlag) && this.m_shouldUseNewCraftshop)
            {
               this.showTutorial(null);
               Global.player.setSeenFlag(firstTimeSeenFlag);
            }
            StatsManager.count(CRAFTSHOP_COUNTER,"view");
            if(this.m_defaultRecipe != null)
            {
               this.openRecipeUI(this.m_defaultRecipe);
            }
            if(this.m_searchString != "")
            {
               this.onSearchUpdate(this.m_searchString.substr(0,this.m_searchString.length - 1));
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_building = null;
         this.m_defaultRecipe = null;
         this.m_expandFrame = null;
         this.m_featureName = null;
         this.m_friendFrame = null;
         this.m_FTUEMovieClip = null;
         this.m_impulseBuyDialog = null;
         this.m_masteryStarsTooltip = null;
         this.m_ovenFrame = null;
         this.m_recipeFrame = null;
         this.m_recipeItem = null;
         this.m_recipeUI = null;
         this.m_searchFrame = null;
         this.m_searchString = null;
         this.m_selectedTab = null;
         this.m_sortBy = null;
         this.m_sortByButton = null;
         this.m_sortByMenu = null;
         this.m_sortDirection = null;
         this.m_tutorial = null;
         this.m_tutorialButton = null;
         this.m_recipeWindowTutorial = null;
         super.release();
      }
      
      private function onRecipeTutorialOkayButtonClick(event:MouseEvent) : void
      {
         FarmStatsManager.count(CRAFTSHOP_COUNTER,"RecipePlantFtue","okay");
         this.m_recipeWindowTutorial.visible = false;
      }
      
      private function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(this.m_tutorialScene < NUM_TUTORIAL_SCENES)
         {
            ++this.m_tutorialScene;
            if(this.m_tutorialScene == NUM_TUTORIAL_SCENES)
            {
               this.m_tutorialButton.text = ZLocUtils.t("Crafting","LetsCraft");
            }
         }
         else
         {
            this.hideTutorial();
            StatsManager.count(CRAFTSHOP_COUNTER,"FTUE","finish");
         }
         this.m_FTUEMovieClip.play();
      }
      
      private function showTutorial(e:Event) : void
      {
         this.m_tutorialScene = 1;
         this.m_FTUEMovieClip = m_window.mc_tutorial.tutorialEnd_mc;
         if(!getWidget(this.m_FTUEMovieClip))
         {
            addWidget(new ZwBaseWidget(this.m_FTUEMovieClip));
         }
         if(this.m_FTUEMovieClip.okay_bt)
         {
            addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(this.m_FTUEMovieClip.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onTutorialOkayButtonClick) as FarmAnimatedTextButton);
         }
         this.m_tutorial.visible = true;
         StatsManager.count(CRAFTSHOP_COUNTER,"FTUE","start");
         this.dispatchEvent(new Event(CRAFTSHOP_TUTORIAL_EVENT));
      }
      
      private function showRecipeWindowTutorial() : void
      {
         var plantTutorialMC:MovieClip = null;
         var firstTimeSeenFlag:String = this.m_featureName + FTUE_RECIPE_CRAFT_FLAG;
         if(!Global.player.getSeenFlag(firstTimeSeenFlag) && Boolean(this.m_recipeWindowTutorial))
         {
            Global.player.setSeenFlag(firstTimeSeenFlag);
            plantTutorialMC = m_window.mc_tutorial_Plant.tutorialEndPlant_mc;
            if(!getWidget(plantTutorialMC))
            {
               addWidget(new ZwBaseWidget(plantTutorialMC));
            }
            if(plantTutorialMC.new_okay_bt)
            {
               addWidget(new FarmAnimatedTextButton(plantTutorialMC.new_okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onRecipeTutorialOkayButtonClick) as FarmAnimatedTextButton);
            }
            FarmStatsManager.count(CRAFTSHOP_COUNTER,"RecipePlantFtue","start");
            this.m_recipeWindowTutorial.visible = true;
         }
      }
      
      private function hideTutorial() : void
      {
         (this.m_tutorial.element as MovieClip).stop();
         this.m_tutorial.visible = false;
         removeWidget(this.m_FTUEMovieClip);
         removeWidget(this.m_tutorialButton);
         this.dispatchEvent(new Event(CRAFTSHOP_TUTORIAL_EVENT_END));
      }
      
      private function populateSortDropDown(craftSkill:String) : void
      {
         var sortOption:Object = null;
         var sortByMenuItems:Array = [];
         var sortOptionsForType:Array = Global.craftConfigSettings.getCraftSkillDataForKey(craftSkill,"sortOptions");
         for(var i:int = 0; i < sortOptionsForType.length; i++)
         {
            sortOption = sortOptionsForType[i];
            sortByMenuItems.push(new MenuItem(sortOption,ZLocUtils.t("Crafting",this.SORT_PREFIX + sortOption.name)));
         }
         this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
         this.m_sortByMenu.visible = false;
         if(sortByMenuItems.length > 0)
         {
            this.m_sortByMenu.items = sortByMenuItems;
            this.m_sortByButton.visible = true;
         }
         else
         {
            this.m_sortByButton.visible = false;
         }
      }
      
      private function onSortByMouseOver(evt:MouseEvent) : void
      {
         if(!this.m_sortByMenu.visible)
         {
            this.m_sortByButton.setToggleState(ZwToggleState.SELECTED);
            this.m_sortByMenu.visible = true;
         }
      }
      
      private function onSortByMouseOut(evt:MouseEvent) : void
      {
         if(!FarmGameUtil.isDescendant(this.m_sortByButton.element as MovieClip,evt.relatedObject) && !FarmGameUtil.isDescendant(this.m_sortByMenu.element as MovieClip,evt.relatedObject))
         {
            this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
            this.m_sortByMenu.visible = false;
         }
      }
      
      private function onSortByMenuItemSelected(item:MenuItem) : void
      {
         this.m_sortByButton.setToggleState(ZwToggleState.DESELECTED);
         this.m_sortByMenu.visible = false;
         this.m_sortBy = item.data.name;
         this.m_sortDirection = item.data.direction;
         StatsManager.count(CRAFTSHOP_COUNTER,"button_sort","click",this.m_sortBy);
         this.m_recipeFrame.filterOptionsChanged();
         this.refreshRecipeFrame();
      }
      
      private function onSubMenuItemSelected(item:MenuItem) : void
      {
         this.m_selectedTab = item.data as String;
         this.onSearchUpdate("");
         this.refreshRecipeFrame();
         StatsManager.count(CRAFTSHOP_COUNTER,"tab_selected",this.m_selectedTab);
      }
      
      public function onSearchUpdate(searchString:String) : void
      {
         if(this.m_searchString != searchString)
         {
            this.m_searchString = searchString;
            if(this.m_expandFrame)
            {
               this.m_expandFrame.showExpandFrame(false);
            }
            this.m_recipeFrame.filterOptionsChanged();
            this.refreshRecipeFrame();
         }
      }
      
      private function refreshRecipeFrame() : void
      {
         if(this.m_recipeFrame)
         {
            this.m_recipeFrame.setCurrentTab(this.m_selectedTab);
            this.m_recipeFrame.update();
            this.m_recipeFrame.refresh();
         }
      }
      
      public function getSearchString() : String
      {
         return this.m_searchString;
      }
      
      public function getSortInfo() : Object
      {
         return {
            "sortBy":this.m_sortBy,
            "direction":this.m_sortDirection
         };
      }
      
      public function showExpandFrame(showPanel:Boolean) : void
      {
         if(this.m_expandFrame)
         {
            this.m_expandFrame.showExpandFrame(showPanel);
            this.m_ovenFrame.update();
         }
      }
      
      public function isExpandFrameVisible() : Boolean
      {
         var result:Boolean = false;
         if(this.m_expandFrame)
         {
            result = this.m_expandFrame.isExpandFrameVisible();
         }
         return result;
      }
      
      public function getBuildingStorageLevel() : int
      {
         return this.m_building.storageLevel;
      }
      
      public function get usedOvensInWorld() : int
      {
         var craftshopRecipeQueue:Array = Global.player.craftingState.getRecipeQueueForCraftType(this.m_building.getItem().craftType);
         var usedOvens:int = 0;
         for(var i:int = 0; i < craftshopRecipeQueue.length; i++)
         {
            if((craftshopRecipeQueue[i] as RecipeItem).worldType == Global.worldManager.currentWorldType)
            {
               usedOvens++;
            }
         }
         return usedOvens;
      }
      
      public function get nextAvailableOvenSlot() : int
      {
         var recipe:RecipeItem = null;
         var usedOvenSlots:Array = new Array();
         var craftshopRecipeQueue:Array = Global.player.craftingState.getRecipeQueueForCraftType(this.m_building.getItem().craftType);
         for(var i:int = 0; i < craftshopRecipeQueue.length; i++)
         {
            recipe = craftshopRecipeQueue[i] as RecipeItem;
            if(Boolean(recipe) && Boolean(recipe.ovenSlot) && recipe.worldType == Global.worldManager.currentWorldType)
            {
               usedOvenSlots.push(recipe.ovenSlot);
            }
         }
         var result:int = -1;
         var totalOvensAllowedInWorld:int = this.m_building.storageLevel;
         for(var j:int = 0; j < totalOvensAllowedInWorld; j++)
         {
            if(usedOvenSlots.indexOf(j) == -1)
            {
               result = j;
            }
         }
         return result;
      }
      
      public function canMakeRecipeInThisWorld(recipeItem:RecipeItem = null) : int
      {
         var totalOvensAllowedInWorld:int = this.m_building.storageLevel;
         var canMakeRecipeInThisWorld:int = CraftingConstants.CAN_MAKE_RECIPE;
         if(this.usedOvensInWorld >= totalOvensAllowedInWorld)
         {
            canMakeRecipeInThisWorld = CraftingConstants.OVEN_SLOTS_FULL;
         }
         return canMakeRecipeInThisWorld;
      }
      
      public function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      public function unpause() : void
      {
         if(m_window)
         {
            this.update();
            untintWindow();
            enableInput = true;
         }
      }
      
      public function update() : void
      {
         if(this.m_searchFrame)
         {
            this.m_searchFrame.update();
         }
         this.m_ovenFrame.update();
         this.refreshRecipeFrame();
         if(this.m_friendFrame)
         {
            this.m_friendFrame.refresh();
         }
         if(this.m_recipeUI)
         {
            this.m_recipeUI.populateWithRecipe(this.m_recipeItem);
         }
      }
      
      public function pressMoreInfo(event:MouseEvent = null) : void
      {
         this.pause();
         var craftshopItem:FarmItem = this.m_building.getItem();
         TutorialUI.displayCraftingV2TutorialWindow(false,this.onCloseMoreInfo,craftshopItem.craftType,craftshopItem);
      }
      
      public function pressInventory(event:MouseEvent) : void
      {
         var dialogClass:Class = null;
         var dialog:* = undefined;
         var dialogClassName:String = "Widgets.Windows.Crafting.CraftingSiloWindow";
         var silos:Array = Global.world.getObjectsByCode("i-");
         if(silos.length > 0)
         {
            dialogClass = getDefinitionByName(dialogClassName) as Class;
            dialog = new dialogClass(silos[0]);
            UI.displayPopup(dialog,true,dialogClassName,true);
            this.close();
         }
         else
         {
            this.close();
            UI.displayMessage("Place a crafting silo on this farm in order to access inventory");
            UI.displayMiniMarketDialog(["craftingsilo"]);
         }
      }
      
      public function onCloseMoreInfo() : void
      {
         this.unpause();
      }
      
      override public function close() : void
      {
         lastOpenTab = this.m_selectedTab;
         lastSortOption = this.m_sortBy;
         lastSortDirection = this.m_sortDirection;
         super.close();
      }
      
      public function getBushels(recipeId:String) : void
      {
         this.pause();
         this.setRecipeItem(recipeId);
         CraftingUI.displayShoppingListWindow(this.m_recipeItem,this.onCloseGetBushels,true,true);
      }
      
      public function onCloseGetBushels() : void
      {
         this.unpause();
      }
      
      public function buyIngredients(recipeId:String) : void
      {
         this.setRecipeItem(recipeId);
         CraftingManager.getInstance().beginPurchaseRecipeBundle(this.m_recipeItem,this.onBuyAllClose,this.onBuyAllPurchase);
         this.pause();
      }
      
      public function buyBushel(bushel:String, recipeId:String) : void
      {
         var recipeItem:RecipeItem = null;
         CraftingManager.getInstance().onPurchaseBushel(bushel,recipeId);
         this.m_recipeFrame.refreshRecipe(recipeId);
         if(this.m_recipeUI)
         {
            recipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
            this.m_recipeUI.populateWithRecipe(recipeItem);
         }
      }
      
      public function askForBushel(recipe:RecipeItem, ingredientConfig:Object) : void
      {
         var bushelItem:FarmItem = null;
         var craftingManager:CraftingManager = null;
         var itemCode:String = ingredientConfig[RecipeItem.ITEM_CODE];
         if(itemCode)
         {
            bushelItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(bushelItem)
            {
               craftingManager = CraftingManager.getInstance();
               if(craftingManager.isIngredientGetByFeed(ingredientConfig))
               {
                  craftingManager.startGetByFeedIngredientFlow(recipe,ingredientConfig,this.onCloseAskForItem);
               }
               else if(craftingManager.getCraftTypeofBushel(itemCode) == CraftingManager.BUSHEL_TYPE_SILO)
               {
                  craftingManager.onNoBushelsAvailableShopping(itemCode,"silo",this.onCloseAskForItem,bushelItem.icon);
               }
               else
               {
                  craftingManager.onNoBushelsAvailableShopping(itemCode,recipe.craft,this.onCloseAskForItem);
               }
               enableInput = false;
               tintWindow();
            }
         }
      }
      
      private function onCloseAskForItem(evt:Event = null) : void
      {
         untintWindow();
         enableInput = true;
      }
      
      private function onBuyAllClose(evt:Event = null) : void
      {
         this.unpause();
      }
      
      private function onBuyAllPurchase(recipeId:String) : void
      {
         this.unpause();
         this.m_recipeFrame.refreshRecipe(recipeId);
      }
      
      public function openRecipeUI(recipeId:String) : void
      {
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         this.m_recipeUI.populateWithRecipe(recipeItem);
         this.m_recipeUI.visible = true;
         this.m_overlay_mc.visible = true;
         this.showRecipeWindowTutorial();
      }
      
      public function makeRecipe(recipeId:String) : void
      {
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var ovenSlot:int = this.nextAvailableOvenSlot;
         if(Boolean(recipeItem) && Boolean(this.canMakeRecipeInThisWorld() == CraftingConstants.CAN_MAKE_RECIPE) && ovenSlot >= 0)
         {
            this.pause();
            recipeItem.ovenSlot = ovenSlot;
            recipeItem.worldType = Global.worldManager.currentWorldType;
            CraftingManager.getInstance().beginRecipe(recipeItem,this.onRecipeBeginDone,DailyStatsManager.SOURCE_CRAFT_SHOP);
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","CraftshopWindow_inProgressText"),0,null,"",true,false,"");
         }
      }
      
      protected function onRecipeBeginDone(tResult:Object) : void
      {
         if(tResult.hasOwnProperty("id"))
         {
            this.setRecipeItem(tResult.id);
         }
         var postedFeed:Boolean = CraftingManager.getInstance().handleRecipeBegunResult(tResult,this.onBeginFeedDone);
         this.unpause();
         this.setupStarCountTF();
         this.m_recipeFrame.refreshMasteryLocks();
         if(postedFeed)
         {
            this.pause();
         }
      }
      
      private function onBeginFeedDone() : void
      {
         this.unpause();
      }
      
      public function setRecipeItem(recipeId:String) : void
      {
         this.m_recipeItem = CraftingManager.getRecipeItemFromId(recipeId,this.m_building.getItem().craftType);
      }
      
      public function setSlotRecipeItem(recipeId:String, ovenSlot:int = -2) : void
      {
         if(ovenSlot == -2)
         {
            this.setRecipeItem(recipeId);
         }
         else
         {
            this.m_recipeItem = CraftingManager.getRecipeItemFromIdAndSlot(recipeId,ovenSlot,this.m_building.getItem().craftType);
         }
      }
      
      public function finishRecipe(recipeId:String, ovenSlot:int = -2) : void
      {
         this.m_recipeFrame.refreshRecipe(recipeId);
         this.pause();
         this.setSlotRecipeItem(recipeId,ovenSlot);
         CraftingManager.getInstance().beginClaimFinishedRecipes(this.onEndClaimFinishedRecipes,this.m_recipeItem.id,this.onEndClaimFinishedFeed,this.m_recipeItem.ovenSlot);
      }
      
      public function finishRecipeRushed(recipeId:String, ovenSlot:int = -2) : void
      {
         this.pause();
         this.setSlotRecipeItem(recipeId,ovenSlot);
         if(this.m_recipeItem.isComplete)
         {
            this.finishRecipe(recipeId,this.m_recipeItem.ovenSlot);
         }
         else if(Global.player.cash >= this.m_recipeItem.rushCostCash)
         {
            UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","CraftshopWindow_finishRecipeRushed_popup",{"quantity":this.m_recipeItem.rushCostCash}),GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyClose,Global.getAssetURL(this.m_recipeItem.image)),false);
         }
         else
         {
            this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_recipeItem.rushCostCash,this.m_recipeItem.name);
            if(this.m_impulseBuyDialog != null)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            }
            else
            {
               this.onImpulseBuyCancel(null);
            }
         }
      }
      
      private function onBuyClose(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            CraftingManager.getInstance().beginBuyRecipeRush(this.m_recipeItem,false,this.onEndRecipeRush);
         }
         else
         {
            this.unpause();
         }
      }
      
      private function onImpulseBuyCancel(event:ImpulseBuyEvent) : void
      {
         this.unpause();
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
      }
      
      private function onEndRecipeRush(result:Object) : void
      {
         this.finishRecipe(this.m_recipeItem.id,this.m_recipeItem.ovenSlot);
      }
      
      public function onEndClaimFinishedRecipes(result:Object) : void
      {
         this.unpause();
         this.pause();
         if(this.m_finishRecipeCallback != null)
         {
            this.m_finishRecipeCallback();
         }
      }
      
      private function onEndClaimFinishedFeed() : void
      {
         this.unpause();
         displayNotificationForRecipe(this.m_recipeItem);
      }
      
      private function setupStarCountTF() : void
      {
         var earnedMasteryCount:String = CraftingManager.getInstance().getRecipeMasteryEarnedForCraftType(this.m_building.getItem().craftType).toString();
         var starCountTF:ZwTextField = this.getWidget(m_window.totalStars_tf) as ZwTextField;
         starCountTF.text = earnedMasteryCount;
         var ttText:String = ZLocUtils.t("Crafting","CraftingCottage_recipeMasteryEarned",{"quantity":earnedMasteryCount});
         if(this.m_masteryStarsTooltip == null)
         {
            this.m_masteryStarsTooltip = new FarmTextTooltip(ttText);
            starCountTF.attachTooltip(this.m_masteryStarsTooltip);
         }
         else
         {
            this.m_masteryStarsTooltip.setText(ttText);
         }
      }
      
      public function hideOverlay() : void
      {
         this.m_overlay_mc.visible = false;
      }
      
      public function showOverlay() : void
      {
         this.m_overlay_mc.visible = true;
      }
   }
}

