package Managers
{
   import Classes.Constants.QuestConstants;
   import Classes.CraftingCottageBuilding;
   import Classes.Quest.FarmQuestUtility;
   import Classes.Quest.FarmTask;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Display.CraftingUI;
   import Display.HUD.HUD;
   import Display.HUD.HUDWidgets.HudBottomAnimalSanctuaryV2;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.FarmGameWorldEvent;
   import Managers.Crafting.CraftingManager;
   import Transactions.TFarmTransaction;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.AnimalSanctuaryV2CraftWindow;
   import Widgets.Windows.AnimalSanctuaryV2EndWindow;
   import Widgets.Windows.AnimalSanctuaryV2MainWindow;
   import Widgets.Windows.AnimalSanctuaryV2MilestonePopup;
   import Widgets.Windows.AnimalSanctuaryV2PackagesBuyWindow;
   import Widgets.Windows.AnimalSanctuaryV2RewardWindow;
   import Widgets.Windows.AnimalSanctuaryV2SelectionWindow;
   import Widgets.Windows.AnimalSanctuaryV2StageCompleteRewardPopup;
   import Widgets.Windows.AnimalSanctuaryV2TasksWindow;
   import Widgets.Windows.AnimalSanctuaryV2TravelFarmWindow;
   import Widgets.Windows.FarmWindow;
   import avmplus.getQualifiedClassName;
   import flash.events.Event;
   
   public class AnimalSanctuaryV2Manager extends BaseFeatureManager
   {
      
      public static const FEATURE_NAME:String = "AnimalSanctuaryV2";
      
      private static const WINDOW_REWARD:String = "reward";
      
      private static const WINDOW_CONGRATS:String = "congrats";
      
      private static const WINDOW_BUY:String = "buyDialog";
      
      public static const FEATURE_OPTIONS_KEY:String = "AnimalSanctuaryV2";
      
      private static var m_initialized:Boolean = false;
      
      private static const SKIP_COST:int = 1;
      
      private static const KEY_SAVED_ACTIVE_TASKS:String = "1";
      
      private static const KEY_SAVED_BUSHEL_PROGRESS:String = "saved_bushel_progress";
      
      private static const SERVICE_NAME:String = "AnimalSanctuaryV2Service";
      
      public static const DEFAULT_HARVEST_THROTTLE_TIME:Number = 86400;
      
      private static const DATE_FEATURE_END:String = "06/15/2020";
      
      private static const KEY_STARV_TIME:* = 21600;
      
      private static const KEY_WARN_TIME:* = 7200;
      
      public static const KEY_STARV_SINK_AMOUNT:* = 30;
      
      private static const KEY_MX_COUPON:* = 100;
      
      private static const REWARD_POPUP_WINDOW:String = "assets/dialogs/Animal_sanctury_2019/FV_Animalsanctury19_prize.swf";
      
      private static const REWARD_WINDOW_IMAGE:String = "assets/dialogs/cocoland/RewardDialog.png";
      
      private static const HUD_CASABLANCA_ASSET:String = "assets/dialogs/animal_sanctuary_april_2020/FV_hud_animal_sanctuary.swf";
      
      public const DEFAULT_THROTTLE_TIME:Number = 86400;
      
      private var m_assetPaths:Object = null;
      
      protected var m_staticData:Object;
      
      private var m_selectionWindow:AnimalSanctuaryV2SelectionWindow;
      
      private var m_mainWindow:AnimalSanctuaryV2MainWindow;
      
      private var m_rewardWindow:AnimalSanctuaryV2RewardWindow;
      
      private var m_craftWindow:AnimalSanctuaryV2CraftWindow;
      
      private var m_featureEndWindow:AnimalSanctuaryV2EndWindow;
      
      private var m_tasksWindow:AnimalSanctuaryV2TasksWindow;
      
      public var m_selectedAnimal:int = 0;
      
      public var m_selectedWorld:int = 0;
      
      private var m_mainWindowUrl:String = "assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary.swf";
      
      private var m_selectionWindowUrl:String = "assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary_choose.swf";
      
      private var m_craftWindowUrl:String = "assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary_craft.swf";
      
      private var m_featureCompletePopUpUrl:String = "assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary_complete_popup.swf";
      
      private var m_featureMilestonePopUpUrl:String = "assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary_milestone_popup.swf";
      
      private var m_rewardsWindowUrl:String = "assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary_rewards.swf";
      
      private var m_buyWindowUrl:String = "assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary_buy.swf";
      
      private var m_hudUrl:String = "assets/dialogs/animal_sanctuary_april_2020/FV_hud_animal_sanctuary.swf";
      
      private var m_featureStageRewardUrl:String = "assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary_complete_popup.swf";
      
      protected const KEY_PROGRESS:String = "progress";
      
      protected const KEY_TOTAL:String = "total";
      
      private var m_resultObject:Object;
      
      private const KEY_SAVED_CRAFTING_PROGRESS:String = "saved_crafting_progress";
      
      private const KEY_SAVED_ANIMALS_PROGRESS:String = "saved_animals_progress";
      
      private const KEY_SAVED_VIRAL_PROGRESS:String = "saved_viral_progress";
      
      private const KEY_LAST_USED_TYPE:String = "lt";
      
      private const KEY_USER_STATE:String = "state";
      
      private const KEY_DAY_POINTS:String = "dp";
      
      private const KEY_DAILY_PROGRESS_POINTS:String = "pts";
      
      private const KEY_ACTIVE_DAY_TIMESTAMP:String = "ts";
      
      public const NO_OF_WEEKS:int = 5;
      
      private const REDEEM_ADDITIONAL_DAYS:int = 0;
      
      public const VAL_ANIMAL_ARRAY:Array = ["bigcat_royalbengaltiger","bear_ice","zebra_savannah","bird_wildwesteagle"];
      
      public const VAL_ANIMAL_NAME_ARRAY:Array = ["Royal Bengal Tiger","Ice Bear","Savannah Zebra","Wild West Eagle"];
      
      public const VAL_MAIN_ANIMAL_NAME_ARRAY:Array = ["Bengal Tiger","Polar Bear","Zebra","Bald Eagle"];
      
      public const VAL_ANIMAL_ICON_NAMES:Array = ["tiger_100.png","panda_100.png","zebra_100.png","eagle_100.png"];
      
      public const VAL_FARM_NAME_ARRAY:Array = ["india","winterwonderland","africa","wildwest"];
      
      public const VAL_FARM_NAMES_ARRAY:Array = ["Namaste India","Winter Wonderland","Savannah Safari","Wild West Golden Trail"];
      
      public const ANIMAL_SANCTUARY_NAME:Array = ["Bengal Tiger Sanctuary","Polar Bear Sanctuary","Zebra Sanctuary","Bald Eagle Sanctuary"];
      
      public const VAL_ANIMAL_INDEX_ARRAY:Array = ["animal0","animal1","animal2","animal3"];
      
      public const VAL_FARM_INDEX_ARRAY:Array = ["world0","world1","world2","world3"];
      
      public const VAL_TASK_ARRAY:Array = ["Plant","Craft","Harvest"];
      
      public const VAL_COUPON_NAME_ARRAY:* = ["food","habitat","health"];
      
      public const VAL_COUPON_NAME_TYPE:* = ["Food","Health","Habitat"];
      
      public var MILESTONE_REWARDS:Object = {
         "1":["tigergazebo","bengaltigerstatue","cub_royaltiger","bigcat_royalbengaltiger"],
         "2":["arcticgazebo","icebearsculpture","icebearcastle","bear_ice"],
         "3":["zebrapole","zebragazebo","zebrastatue","zebra_savannah"],
         "4":["wildeaglepole","eaglesculpture","bird_babyeagle","bird_wildwesteagle"]
      };
      
      public var MILESTONE_CONSUMABLES_REWARDS:Object = {
         "0":["consume_instagrow","consume_turbo_charger"],
         "1":["consume_organic_fertilizer","consume_turbo_charger"],
         "2":["consume_turbo_charger","consume_unwither"]
      };
      
      public const MILESTONE_CONSUMABLE_REWARDS:* = ["pkg_animal_sanctuary_level1","pkg_animal_sanctuary_level2","pkg_animal_sanctuary_level3"];
      
      public const MILESTONE_FINAL_REWARDS:* = ["bengaltigersanctuary","polarbearsanctuary","zebrasanctuary","baldeaglesanctuary"];
      
      private const FEATURE_COMPLETION_REWARD:String = "unicornparadisesanctuary";
      
      public const PANADA_CALLOUT_TEXT:* = ["Coo-Coo! [Excited]","NEEAH! [Hello Farmer!]"];
      
      public const BEAR_CALLOUT_TEXT:* = ["Hnooonnnnn [Excited]","nnnnnnn [Relaxed]"];
      
      public const LEAPORD_CALLOUT_TEXT:* = ["Chuff! [Howdy Farmer!]","Mew [Excited]"];
      
      public const RHINO_CALLOUT_TEXT:* = ["mmwonk! [Thanks Farmer!]","mmmmnnnnnhh [Excited]"];
      
      public const ANIMAL_COUPONS_FOOD_IMAGES:Array = ["tigerfood","polarbearfood","zebrafood","eaglefood"];
      
      public const ANIMAL_COUPONS_HABITAT_IMAGES:Array = ["tigerhabitat","polarbearhabitat","zebrahabitat","eaglehabitat"];
      
      public const ANIMAL_COUPONS_HEALTH_IMAGES:Array = ["tigerhealth","polarbearhealth","zebrahealth","eaglehealth"];
      
      public const ASSET_PATH:* = "assets/dialogs/animal_sanctuary_april_2020/";
      
      public const RESOURCE_STATE_HOVER_TEXTS:Array = ["Provide before animals start starving! If the animals start starving you’ll need to provide extra food to feed the animals","Provide before animals get sick! If the animals get sick you’ll need to provide extra medicine to cure the animals","Provide before animals are unsafe! If the animals become unsafe you’ll need to provide extra shelter to protect the animals"];
      
      public const consumableCodeArray:Array = ["g5q0","43ls","60bv"];
      
      public const CONSUMABLE_COUNT_ARRAY:Array = [200,400,500,600];
      
      public const SINK_COUNT:int = 10;
      
      public const CONSUMABLE_SINK_PREFILL_COUNT:Array = [20,40,50,60];
      
      public const COUPON_COUNT:Array = [50,200,500];
      
      public const COUPON_COST:Array = [10,30,60];
      
      private const COUPONS_ARRAY:Array = ["food_coupon","habitat_coupon","health_coupon"];
      
      private const COUPONS_GRANT_ARRAY:Array = ["food_coupon","habitat_coupon","food_coupon","health_coupon","habitat_coupon","health_coupon","health_coupon","habitat_coupon","food_coupon"];
      
      private const SELECTED_ANIMAL:* = "animal";
      
      private const SELECTED_WORLD:* = "world";
      
      private const STATUS:* = "status";
      
      private const ACTIVE_LEVEL:* = "level";
      
      private const FOOD_SINKED:* = "food";
      
      private const HEALTH_SINKED:* = "health";
      
      private const HABITAT_SINKED:* = "habitat";
      
      private const FOOD_COUPON:* = "food_coupon";
      
      private const HEALTH_COUPON:* = "health_coupon";
      
      private const HABITAT_COUPON:* = "habitat_coupon";
      
      private const KEY_ANIMAL0:* = "animal0";
      
      private const KEY_ANIMAL1:* = "animal1";
      
      private const KEY_ANIMAL2:* = "animal2";
      
      private const KEY_ANIMAL3:* = "animal3";
      
      private const KEY_WORLD0:* = "world0";
      
      private const KEY_WORLD1:* = "world1";
      
      private const KEY_WORLD2:* = "world2";
      
      private const KEY_WORLD3:* = "world3";
      
      private const KEY_FOOD_WAIT_TIME:* = "food_wait_time";
      
      private const KEY_HABITAT_WAIT_TIME:* = "habitat_wait_time";
      
      private const KEY_HEALTH_WAIT_TIME:* = "health_wait_time";
      
      private const KEY_ANIMAL_SLOT:* = "animal_slot";
      
      private const KEY_WORLD_SLOT:* = "world_slot";
      
      private const RAND_COUNT:* = "rand_count";
      
      public const STATE_COMPLETE:int = 3;
      
      public const STATE_NORMAL:int = 2;
      
      public const STATE_WARNING:int = 1;
      
      public const STATE_CRITICAL:int = 0;
      
      private var m_AnimalSanctuaryV2Hud:HudBottomAnimalSanctuaryV2;
      
      private var m_milestoneRewardWindow:AnimalSanctuaryV2MilestonePopup;
      
      private var m_cropsByName:Object;
      
      private var m_recipesByName:Object;
      
      private var m_animalsByName:Object;
      
      private var m_viralData:Object;
      
      private var m_recipesByCode:Object;
      
      private var m_allTasklist:Vector.<FarmTask>;
      
      private var m_harvestHitCount:int;
      
      private var m_isTaskComplete:int;
      
      private var m_isupdatable:Boolean = true;
      
      private var m_farmTravelWindow:AnimalSanctuaryV2TravelFarmWindow;
      
      public var m_packageBuyWindow:AnimalSanctuaryV2PackagesBuyWindow;
      
      private var m_stageRewardWindow:AnimalSanctuaryV2StageCompleteRewardPopup;
      
      private var m_finalRewardWindow:AnimalSanctuaryV2StageCompleteRewardPopup;
      
      public function AnimalSanctuaryV2Manager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.m_resultObject = new Object();
         this.startQuest();
         this.parseFeatureDataFromConfig(FEATURE_NAME);
         if(this.isFeatureActive)
         {
            TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         }
      }
      
      public static function getInstance(featureName:String = "AnimalSanctuaryV2") : AnimalSanctuaryV2Manager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,AnimalSanctuaryV2Manager) as AnimalSanctuaryV2Manager;
      }
      
      protected function onTransactionAdded(event:TransactionEvent) : void
      {
         if(this.getUserState() != -1 && this.isFeatureActive)
         {
            this.checkForTaskUpdates(event);
         }
         this.showHudNotification();
      }
      
      public function showHudNotification() : void
      {
      }
      
      public function showMainWindow() : void
      {
         this.showMainUI();
      }
      
      public function showMainUI() : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         if(this.isFeatureCompleted)
         {
            this.m_featureEndWindow = new AnimalSanctuaryV2EndWindow(FEATURE_NAME,this.endMainWindow);
            UI.displayPopup(this.m_featureEndWindow,false);
            StatsManager.count(FEATURE_NAME,"featureEndUI","open");
         }
         else if(this.isFeatureInMidway)
         {
            this.m_mainWindow = new AnimalSanctuaryV2MainWindow(FEATURE_NAME,this.mainWindowUrl);
            UI.displayPopup(this.m_mainWindow,false);
            StatsManager.count(FEATURE_NAME,"mainui","open",this.getSelectedAnimal(),"",this.getSelectedWorld());
         }
         else
         {
            this.m_selectionWindow = new AnimalSanctuaryV2SelectionWindow(FEATURE_NAME,this.selectionWindowUrl);
            UI.displayPopup(this.m_selectionWindow,false);
            StatsManager.count(FEATURE_NAME,"animalSelectionUI","open");
         }
      }
      
      public function openRewardWindow() : void
      {
         this.mainWindow.tintWindow();
         this.mainWindow.enableInput = false;
         this.m_rewardWindow = new AnimalSanctuaryV2RewardWindow(FEATURE_NAME,this.rewardWindowURL);
         UI.displayPopup(this.m_rewardWindow,false);
      }
      
      public function openCraftWindow(dataList:Array, type:String) : void
      {
         this.mainWindow.tintWindow();
         this.mainWindow.enableInput = false;
         this.m_craftWindow = new AnimalSanctuaryV2CraftWindow(FEATURE_NAME,this.craftWindowUrl,dataList,this.m_mainWindow,type);
         UI.displayPopup(this.m_craftWindow,false);
      }
      
      public function buyConsumable(slotIndex:int, owner:FarmWindow) : void
      {
         this.m_packageBuyWindow = new AnimalSanctuaryV2PackagesBuyWindow("assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary_buy.swf",m_featureName,slotIndex,this.m_mainWindow);
         UI.displayPopup(this.m_packageBuyWindow,false);
      }
      
      public function showFarmTravelWindow() : void
      {
         this.mainWindow.tintWindow();
         this.mainWindow.enableInput = false;
         if(this.m_tasksWindow)
         {
            this.m_tasksWindow.close();
         }
         this.m_farmTravelWindow = new AnimalSanctuaryV2TravelFarmWindow(FEATURE_NAME,this.craftWindowUrl);
         UI.displayPopup(this.m_farmTravelWindow,false);
      }
      
      public function openTasks(type:*) : void
      {
         var cropList:Array = null;
         var animalList:Array = null;
         var recipeList:Array = null;
         if(type == "Plant")
         {
            cropList = this.getCropsByWorld(this.getSelectedWorld());
            if(this.m_craftWindow)
            {
               this.m_craftWindow.forceClose();
            }
            this.openCraftWindow(cropList,type);
         }
         else if(type == "Harvest")
         {
            animalList = this.getAnimalsByWorld(this.getSelectedWorld());
            if(this.m_craftWindow)
            {
               this.m_craftWindow.forceClose();
            }
            this.openCraftWindow(animalList,type);
         }
         else
         {
            recipeList = this.getRecipesByWorld(this.getSelectedWorld());
            if(this.m_craftWindow)
            {
               this.m_craftWindow.forceClose();
            }
            this.openCraftWindow(recipeList,type);
         }
      }
      
      public function openCraftingCottage(recipeCode:String) : void
      {
         var cottage:CraftingCottageBuilding = CraftingManager.getInstance().getCottageByRecipe(recipeCode);
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         if(this.m_tasksWindow)
         {
            this.m_tasksWindow.close();
         }
         var recipeItem:RecipeItem = null;
         recipeItem = Global.craftConfigSettings.getRecipeById(recipeCode);
         StatsManager.count(FEATURE_NAME,"select","task","Crafting",recipeItem.friendlyTitle,this.getSelectedWorld());
         CraftingUI.displayCraftingMainWindow(cottage,0,recipeItem.friendlyTitle.toLowerCase());
      }
      
      public function onClickPlantFromWindow(itemName:String, type:String) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         if(this.m_tasksWindow)
         {
            this.m_tasksWindow.close();
         }
         StatsManager.count(FEATURE_NAME,"select","task","pph",itemName,this.getSelectedWorld());
         var itemNameList:Array = new Array();
         for(var i:int = 0; i < 1; i++)
         {
            itemNameList.push(itemName);
         }
         if(type == "Plant")
         {
            UI.displayMiniMarketDialog(itemNameList,"Animal_Sanctuary_Crops","seed",null,true,false,false,true);
         }
         else
         {
            UI.displayMiniMarketDialog(itemNameList,"Animal_Sanctuary_Animals","animal",null,true,false,false,true);
         }
      }
      
      public function get mainWindow() : AnimalSanctuaryV2MainWindow
      {
         return this.m_mainWindow;
      }
      
      public function get selectionWindow() : AnimalSanctuaryV2SelectionWindow
      {
         return this.m_selectionWindow;
      }
      
      public function startQuest(callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"startQuest",null,[FEATURE_NAME]),true);
      }
      
      public function get selectionWindowUrl() : String
      {
         return this.m_selectionWindowUrl;
      }
      
      public function get craftWindowUrl() : String
      {
         return this.m_craftWindowUrl;
      }
      
      public function get endMainWindow() : String
      {
         return "assets/dialogs/animal_sanctuary_april_2020/FV_animal_sanctuary_end.swf";
      }
      
      public function get mainWindowUrl() : String
      {
         return this.m_mainWindowUrl;
      }
      
      public function get rewardWindowURL() : String
      {
         return this.m_rewardsWindowUrl;
      }
      
      public function get featureCompletePopUpUrl() : String
      {
         return this.m_featureCompletePopUpUrl;
      }
      
      public function get featureMilestonePopUpUrl() : String
      {
         return this.m_featureMilestonePopUpUrl;
      }
      
      public function get featureStageRewardUrl() : String
      {
         return this.m_featureStageRewardUrl;
      }
      
      public function get buyWindowURL() : String
      {
         return this.m_buyWindowUrl;
      }
      
      public function get hudURL() : String
      {
         return this.m_hudUrl;
      }
      
      public function getFeatureData() : Object
      {
         var crop:XML = null;
         var recipe:XML = null;
         var viral:XML = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData)
         {
            featureData = {};
            featureData[this.KEY_USER_STATE] = -1;
            featureData[KEY_SAVED_ACTIVE_TASKS] = {};
            featureData[this.KEY_DAILY_PROGRESS_POINTS] = {};
            featureData[this.KEY_LAST_USED_TYPE] = {};
            featureData[this.KEY_DAY_POINTS] = 0;
            featureData[this.KEY_ANIMAL0] = 0;
            featureData[this.KEY_ANIMAL1] = 0;
            featureData[this.KEY_ANIMAL2] = 0;
            featureData[this.KEY_ANIMAL3] = 0;
            featureData[this.KEY_WORLD0] = 0;
            featureData[this.KEY_WORLD1] = 0;
            featureData[this.KEY_WORLD2] = 0;
            featureData[this.KEY_WORLD3] = 0;
            featureData[this.STATUS] = 0;
            featureData[this.ACTIVE_LEVEL] = 0;
            featureData[this.FOOD_SINKED] = this.CONSUMABLE_SINK_PREFILL_COUNT[0];
            featureData[this.HABITAT_SINKED] = this.CONSUMABLE_SINK_PREFILL_COUNT[0];
            featureData[this.HEALTH_SINKED] = this.CONSUMABLE_SINK_PREFILL_COUNT[0];
            featureData[this.KEY_ANIMAL_SLOT] = -1;
            featureData[this.KEY_WORLD_SLOT] = -1;
            featureData[this.FOOD_COUPON] = 10;
            featureData[this.HEALTH_COUPON] = 10;
            featureData[this.HABITAT_COUPON] = 10;
            featureData[this.RAND_COUNT] = 0;
            featureData[KEY_SAVED_BUSHEL_PROGRESS] = {};
            for each(crop in this.m_cropsByName)
            {
               featureData[KEY_SAVED_BUSHEL_PROGRESS][crop.@name] = 0;
            }
            featureData[this.KEY_SAVED_CRAFTING_PROGRESS] = {};
            for each(recipe in this.m_recipesByName)
            {
               featureData[this.KEY_SAVED_CRAFTING_PROGRESS][recipe.@name] = 0;
            }
            featureData[this.KEY_SAVED_VIRAL_PROGRESS] = {};
            for each(viral in this.m_viralData)
            {
               featureData[this.KEY_SAVED_VIRAL_PROGRESS][viral.@type] = 0;
            }
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      public function initialize() : void
      {
         this.loadStaticData();
      }
      
      protected function parseFeatureDataFromConfig(questName:String) : void
      {
         var featureConfig:XML = null;
         var plant:XML = null;
         var recipe:XML = null;
         var animal:XML = null;
         var viral:XML = null;
         featureConfig = Global.farmGameSettingsManager.getXML().AnimalSanctuaryV2FeatureConfig.AnimalSanctuaryConfigData.(@name == questName)[0];
         this.m_cropsByName = {};
         this.m_recipesByName = {};
         this.m_animalsByName = {};
         this.m_recipesByCode = {};
         this.m_viralData = {};
         if(featureConfig.hasOwnProperty("CropConfigData"))
         {
            for each(plant in featureConfig["CropConfigData"]["plant"])
            {
               this.m_cropsByName[plant.@name] = plant;
            }
         }
         if(featureConfig.hasOwnProperty("CraftingConfigData"))
         {
            for each(recipe in featureConfig["CraftingConfigData"]["recipe"])
            {
               this.m_recipesByName[recipe.@name] = recipe;
            }
         }
         if(featureConfig.hasOwnProperty("CraftingConfigData"))
         {
            for each(recipe in featureConfig["CraftingConfigData"]["recipe"])
            {
               this.m_recipesByCode[recipe.@code] = recipe;
            }
         }
         if(featureConfig.hasOwnProperty("AnimalsConfigData"))
         {
            for each(animal in featureConfig["AnimalsConfigData"]["animal"])
            {
               this.m_animalsByName[animal.@name] = animal;
            }
         }
         if(featureConfig.hasOwnProperty("ViralConfigData"))
         {
            for each(viral in featureConfig["ViralConfigData"]["task"])
            {
               this.m_viralData[viral.@type] = viral;
            }
         }
      }
      
      public function getMaxResourceSinkTime() : int
      {
         return KEY_STARV_TIME;
      }
      
      public function getStarveCouponCount() : int
      {
         return KEY_STARV_SINK_AMOUNT;
      }
      
      public function getResourceSinkWaitTime(slot:String) : int
      {
         var featureData:Object = this.getFeatureData();
         var givenTime:Number = featureData[slot] as Number;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return int(Math.abs(currentTime - givenTime));
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var tile:XML = null;
         var asset:XML = null;
         var tileName:String = null;
         var leaderboardxml:XML = null;
         var weekxml:XML = null;
         this.m_staticData = new Object();
         this.m_staticData.typeArray = [];
         this.m_staticData.rewardCostArray = [];
         this.m_staticData.bucketPackages = [];
         this.m_staticData.tilesArray = [];
         this.m_staticData.endDate = "";
         this.m_staticData.consumable = "";
         this.m_staticData.currencyName = "";
         this.m_staticData.initialGrant = 0;
         this.m_staticData.rewardGrantCount = 0;
         this.m_staticData.gameCost = 0;
         this.m_staticData.p2pTurnCount = 0;
         this.m_staticData.soloTurnCount = 0;
         this.m_staticData.bonusGrantDate = new String();
         this.m_staticData.buyPackages = [];
         this.m_staticData.buyPackages[0] = ["pkg_food_coupon_50","pkg_food_coupon_200","pkg_food_coupon_400"];
         this.m_staticData.buyPackages[1] = ["pkg_health_coupon_50","pkg_health_coupon_200","pkg_health_coupon_400"];
         this.m_staticData.buyPackages[2] = ["pkg_habitat_coupon_50","pkg_habitat_coupon_200","pkg_habitat_coupon_400"];
         this.m_staticData.weeks = new Array();
         this.m_staticData.leaderboardConfigData = new Array();
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            this.m_assetPaths = new Object();
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            this.m_staticData.bonusGrantDate = featureXML.listEndDate.toString();
            this.m_staticData.consumable = featureXML.bucketItem.@code.toString();
            this.m_staticData.initialGrant = featureXML.initialGrant.toString();
            this.m_staticData.currencyName = featureXML.currencyItem.@name.toString();
            for each(tile in featureXML.items.item)
            {
               tileName = tile.@name.toString();
               this.m_staticData.tilesArray.push(tileName);
            }
            if(featureXML.leaderboardConfig)
            {
               for each(leaderboardxml in featureXML.leaderboardConfig.leaderboard)
               {
                  this.m_staticData.leaderboardConfigData.push(leaderboardxml);
               }
            }
            if(featureXML.weeks)
            {
               for each(weekxml in featureXML.weeks.week)
               {
                  this.m_staticData.weeks.push(weekxml);
               }
            }
         }
      }
      
      protected function checkForTaskUpdates(event:TransactionEvent) : void
      {
         var progress:Number = NaN;
         var transaction:TFarmTransaction = null;
         var taskList:Vector.<FarmTask> = null;
         var task:FarmTask = null;
         var itemData:FarmItem = null;
         var hasUpdatedProgress:Boolean = false;
         var hasCompletedCrop:Boolean = false;
         var hasCompletedViral:Boolean = false;
         var hasCompletedAnimal:Boolean = false;
         var hasCompletedCraft:Boolean = false;
         var featureObject:Object = this.getFeatureData();
         var savedCropProgress:* = featureObject[KEY_SAVED_BUSHEL_PROGRESS];
         var savedCraftingProgress:* = featureObject[this.KEY_SAVED_CRAFTING_PROGRESS];
         var savedViralProgress:* = featureObject[this.KEY_SAVED_VIRAL_PROGRESS];
         var transactionType:* = getQualifiedClassName(event.transaction);
         if(Boolean(savedCropProgress) && Boolean(savedCraftingProgress))
         {
            taskList = this.getTasks();
            for each(task in taskList)
            {
               transaction = event.transaction as TFarmTransaction;
               itemData = Global.farmGameSettingsManager.getFarmItemByCode(task.type);
               progress = FarmQuestUtility.getInstance().getProgression(task,transaction,null);
               if(itemData != null && task.helperType == QuestConstants.HELPER_TYPE_PLANT_SEED)
               {
                  savedCropProgress[itemData.name] += progress;
                  if(progress > 0)
                  {
                     hasUpdatedProgress = true;
                     if(Number(savedCropProgress[itemData.name]) >= task["total"])
                     {
                        hasCompletedCrop = true;
                     }
                  }
               }
               else if(itemData != null && task.helperType == QuestConstants.HELPER_TYPE_OPEN_CRAFTING)
               {
                  savedCraftingProgress[itemData.name] += progress;
                  if(progress > 0)
                  {
                     hasUpdatedProgress = true;
                     if(Number(savedCraftingProgress[itemData.name]) >= task["total"])
                     {
                        hasCompletedCraft = true;
                     }
                  }
               }
               else if(itemData != null && task.helperType == QuestConstants.HELPER_TYPE_POST_ASK_FOR_ITEM_FEED_SPECIAL_QUEST)
               {
               }
            }
         }
         if(hasUpdatedProgress)
         {
            this.saveProgressForPlayer(savedCropProgress,savedCraftingProgress,savedViralProgress);
         }
         if(hasCompletedCrop)
         {
            hasCompletedCrop = false;
            this.m_isTaskComplete = 1;
            this.onTaskCompleteUpdate();
            this.resetBushelProgress();
         }
         if(hasCompletedViral)
         {
            hasCompletedViral = false;
            this.m_isTaskComplete = 1;
            this.onTaskCompleteUpdate();
            this.resetViralProgress();
         }
         if(hasCompletedCraft)
         {
            hasCompletedCraft = false;
            this.m_isTaskComplete = 1;
            this.onTaskCompleteUpdate();
            this.resetCraftProgress();
         }
      }
      
      public function getTasks() : Vector.<FarmTask>
      {
         var farmTask:FarmTask = null;
         var cropData:XML = null;
         var taskObj:Object = null;
         var viralData:XML = null;
         var recipesData:XML = null;
         var taskList:Vector.<FarmTask> = new Vector.<FarmTask>();
         var featureObject:Object = this.getFeatureData();
         var savedCropData:* = featureObject[KEY_SAVED_BUSHEL_PROGRESS];
         var savedViralData:* = featureObject[this.KEY_SAVED_VIRAL_PROGRESS];
         var savedCraftingData:* = featureObject[this.KEY_SAVED_CRAFTING_PROGRESS];
         if(savedCropData)
         {
            for each(cropData in this.m_cropsByName)
            {
               if(cropData.@world == this.getSelectedWorld())
               {
                  taskObj = {};
                  taskObj.questName = m_featureName;
                  taskObj.action = "harvestByCode";
                  taskObj.type = cropData.@code;
                  taskObj.helper = "plant_seed";
                  taskObj.total = cropData.@count;
                  taskObj.cashValue = "";
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
            }
         }
         if(savedViralData)
         {
            for each(viralData in this.m_viralData)
            {
               taskObj = {};
               taskObj.questName = m_featureName;
               taskObj.action = "useItemByCode";
               taskObj.type = viralData.@type;
               taskObj.helper = "post_ask_for_item_special_quest";
               taskObj.total = viralData.@total;
               taskObj.cashValue = "";
               farmTask = new FarmTask(taskObj);
               taskList.push(farmTask);
            }
         }
         if(savedCraftingData)
         {
            for each(recipesData in this.m_recipesByName)
            {
               if(recipesData.@world == this.getSelectedWorld())
               {
                  taskObj = {};
                  taskObj.questName = m_featureName;
                  taskObj.action = "makeRecipeByCode";
                  taskObj.type = recipesData.@code;
                  taskObj.helper = "open_crafting";
                  taskObj.total = recipesData.@count;
                  taskObj.cashValue = "";
                  farmTask = new FarmTask(taskObj);
                  taskList.push(farmTask);
               }
            }
         }
         this.m_allTasklist = taskList;
         return taskList;
      }
      
      protected function resetBushelProgress() : void
      {
         var crop:XML = null;
         var cropProgress:int = 0;
         var cropTotalRequired:int = 0;
         var dropRate:int = 0;
         var featureObject:Object = this.getFeatureData();
         for each(crop in this.m_cropsByName)
         {
            cropProgress = int(featureObject[KEY_SAVED_BUSHEL_PROGRESS][crop.@name]);
            cropTotalRequired = int(crop.@count);
            dropRate = int(crop.@drop);
            if(cropProgress >= cropTotalRequired)
            {
               featureObject[KEY_SAVED_BUSHEL_PROGRESS][crop.@name] = cropProgress % cropTotalRequired;
               this.grantCouponsasDrop(cropProgress,cropTotalRequired,dropRate,"pph",crop.@name.toString());
            }
         }
         setFeatureData(featureObject);
      }
      
      protected function resetAnimalProgress() : void
      {
         var animal:XML = null;
         var animalProgress:int = 0;
         var animalTotalRequired:int = 0;
         var dropRate:int = 0;
         var featureObject:Object = this.getFeatureData();
         for each(animal in this.m_animalsByName)
         {
            animalProgress = int(featureObject[this.KEY_SAVED_ANIMALS_PROGRESS][animal.@name]);
            animalTotalRequired = int(animal.@count);
            dropRate = int(animal.@drop);
            if(animalProgress >= animalTotalRequired)
            {
               featureObject[this.KEY_SAVED_ANIMALS_PROGRESS][animal.@name] = animalProgress % animalTotalRequired;
               this.grantCouponsasDrop(animalProgress,animalTotalRequired,dropRate,"animal",animal.@name.toString());
            }
         }
         setFeatureData(featureObject);
      }
      
      protected function resetCraftProgress() : void
      {
         var recipe:XML = null;
         var recipeProgress:int = 0;
         var recipeTotalRequired:int = 0;
         var dropRate:int = 0;
         var featureObject:Object = this.getFeatureData();
         for each(recipe in this.m_recipesByName)
         {
            recipeProgress = int(featureObject[this.KEY_SAVED_CRAFTING_PROGRESS][recipe.@name]);
            recipeTotalRequired = int(recipe.@count);
            dropRate = int(recipe.@drop);
            if(recipeProgress >= recipeTotalRequired)
            {
               featureObject[this.KEY_SAVED_CRAFTING_PROGRESS][recipe.@name] = recipeProgress % recipeTotalRequired;
               this.grantCouponsasDrop(recipeProgress,recipeTotalRequired,dropRate,"craft",recipe.@name.toString());
            }
         }
         setFeatureData(featureObject);
      }
      
      protected function resetViralProgress() : void
      {
         var viral:XML = null;
         var viralProgress:int = 0;
         var viralTotalRequired:int = 0;
         var dropRate:int = 0;
         var featureObject:Object = this.getFeatureData();
         for each(viral in this.m_viralData)
         {
            viralProgress = int(featureObject[this.KEY_SAVED_VIRAL_PROGRESS][viral.@type]);
            viralTotalRequired = int(viral.@total);
            dropRate = int(viral.@drop);
            if(viralProgress >= viralTotalRequired)
            {
               featureObject[this.KEY_SAVED_VIRAL_PROGRESS][viral.@type] = viralProgress % viralTotalRequired;
               this.grantCouponsasDrop(viralProgress,viralTotalRequired,dropRate,"viral","freshwaterbucket");
            }
         }
         setFeatureData(featureObject);
      }
      
      protected function saveProgressForPlayer(savedCropProgress:*, savedCraftingProgress:*, savedViralProgress:*) : void
      {
         var featureObj:Object = this.getFeatureData();
         featureObj[KEY_SAVED_BUSHEL_PROGRESS] = savedCropProgress;
         featureObj[this.KEY_SAVED_CRAFTING_PROGRESS] = savedCraftingProgress;
         featureObj[this.KEY_SAVED_VIRAL_PROGRESS] = savedViralProgress;
         setFeatureData(featureObj);
      }
      
      public function onTaskCompleteUpdate() : void
      {
         if(this.m_isTaskComplete == 1)
         {
            this.m_isTaskComplete = 0;
         }
      }
      
      public function get featureEndWindowURL() : String
      {
         return this.m_assetPaths[WINDOW_CONGRATS];
      }
      
      public function get buyDialogURL() : String
      {
         return this.m_assetPaths[WINDOW_BUY];
      }
      
      public function getBucketPackages(slotIndex:*) : Array
      {
         return this.m_staticData.buyPackages[slotIndex];
      }
      
      public function get ConsumableCode() : String
      {
         return this.m_staticData.consumable;
      }
      
      public function get bonusGrantDate() : String
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         return this.m_staticData.bonusGrantDate;
      }
      
      public function setupAnimalSanctuaryV2Hud() : void
      {
         this.m_AnimalSanctuaryV2Hud = new HudBottomAnimalSanctuaryV2(HUD_CASABLANCA_ASSET,m_featureName);
         Global.hud.setBottomAnimalSanctuaryV2Button(this.m_AnimalSanctuaryV2Hud as HudBottomAnimalSanctuaryV2);
      }
      
      public function removeHud() : void
      {
         if(Global.hud)
         {
            Global.hud.removeBottomHudAnimalSanctuaryV2Button();
         }
      }
      
      public function get isFeatureActive() : Boolean
      {
         var result:Boolean = false;
         var prereq:Object = Global.farmGameSettingsManager.getPrereqByName("animal_sanctuary_v2_feature_enabled");
         if(PrerequisiteUtility.isPrerequisiteMet(prereq))
         {
            result = true;
         }
         return result;
      }
      
      public function sinkConsumable(slotIndex:int) : void
      {
         var count:int = 0;
         var coupon:int = 0;
         var text:String = null;
         var requiredConsumableCount:int = this.SINK_COUNT;
         var featureData:Object = this.getFeatureData();
         if(slotIndex >= 0 && slotIndex <= 2)
         {
            count = int(featureData[this.COUPONS_ARRAY[slotIndex]]);
            if(count >= requiredConsumableCount)
            {
               featureData[this.COUPONS_ARRAY[slotIndex]] = count - requiredConsumableCount;
               coupon = int(featureData[this.VAL_COUPON_NAME_ARRAY[slotIndex]]);
               featureData[this.VAL_COUPON_NAME_ARRAY[slotIndex]] = coupon + this.SINK_COUNT;
               setFeatureData(featureData);
            }
         }
         if(this.m_mainWindow)
         {
            if(this.checkForCallOutText(slotIndex))
            {
               text = this.getCallOutTextByAnimal(this.getSelectedAnimal(),5);
               this.m_mainWindow.showNPCCallouts(this.VAL_ANIMAL_NAME_ARRAY[this.getSelectedAnimalSlot() - 1],text);
            }
         }
         this.updateStages();
         if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_stat_progresses_bt[slotIndex]))
         {
            this.m_mainWindow.m_stat_progresses_bt[slotIndex].enabled = false;
         }
         StatsManager.count(FEATURE_NAME,"sink",this.getSelectedAnimal() + ":" + "normal",featureData[this.COUPONS_ARRAY[slotIndex]],this.COUPONS_ARRAY[slotIndex],this.getSelectedWorld(),10);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkConsumable",this.updateWaitTimeOnSinkConsumable,[m_featureName,slotIndex]),true);
      }
      
      public function sinkConsumableOnStarve(slotIndex:int) : void
      {
         var count:int = 0;
         var requiredConsumableCount:int = KEY_STARV_SINK_AMOUNT;
         var featureData:Object = this.getFeatureData();
         if(slotIndex >= 0 && slotIndex <= 2)
         {
            count = int(featureData[this.COUPONS_ARRAY[slotIndex]]);
            if(count >= requiredConsumableCount)
            {
               featureData[this.COUPONS_ARRAY[slotIndex]] = count - requiredConsumableCount;
               StatsManager.count(FEATURE_NAME,"sink",this.getSelectedAnimal() + ":" + "critical",(count - requiredConsumableCount).toString(),this.COUPONS_ARRAY[slotIndex],this.getSelectedWorld(),30);
            }
         }
         setFeatureData(featureData);
         if(Boolean(this.m_mainWindow) && Boolean(this.m_mainWindow.m_stat_conditions_bt[slotIndex]))
         {
            this.m_mainWindow.m_stat_conditions_bt[slotIndex].enabled = false;
         }
         StatsManager.count(FEATURE_NAME,"critical","exit",this.getSelectedAnimal(),this.COUPONS_ARRAY[slotIndex],this.getSelectedWorld());
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"sinkConsumableOnStarve",this.updateWaitTimeOnSinkConsumable,[m_featureName,slotIndex]),true);
      }
      
      public function updateWaitTimeOnSinkConsumable(result:Object) : void
      {
         var featureData:Object = null;
         var time:Number = NaN;
         var key:String = null;
         if(!result["error"])
         {
            featureData = this.getFeatureData();
            time = result["wait_time"] as Number;
            key = result["wait_time_key"] as String;
            featureData[key] = time;
            setFeatureData(featureData);
            if(this.m_mainWindow)
            {
               this.m_mainWindow.untintWindow();
               this.m_mainWindow.enableInput = true;
            }
            if(this.m_isupdatable && Boolean(this.m_mainWindow))
            {
               this.m_mainWindow.refreshWindow();
               this.m_mainWindow.startSinkWaitTime(result["slot"]);
            }
         }
      }
      
      public function updateStages() : void
      {
         var currentTime:Number = NaN;
         var mileStoneReward:String = null;
         var milestoneCosumable:String = null;
         var milestoneRewards:String = null;
         var reward:FarmItem = null;
         var reward2:FarmItem = null;
         var callback:Function = null;
         var isBonusReward:Boolean = false;
         var lastReward:FarmItem = null;
         var featureData:Object = this.getFeatureData();
         var level:int = int(featureData[this.ACTIVE_LEVEL]);
         var food:int = int(featureData[this.FOOD_SINKED]);
         var health:int = int(featureData[this.HEALTH_SINKED]);
         var habitat:int = int(featureData[this.HABITAT_SINKED]);
         var animalSlot:int = int(featureData[this.KEY_ANIMAL_SLOT]);
         var worldSlot:int = int(featureData[this.KEY_WORLD_SLOT]);
         var isFinalStage:Boolean = false;
         this.m_isupdatable = true;
         if(level <= 4)
         {
            if(food >= this.CONSUMABLE_COUNT_ARRAY[level] && health >= this.CONSUMABLE_COUNT_ARRAY[level] && habitat >= this.CONSUMABLE_COUNT_ARRAY[level])
            {
               level += 1;
               featureData[this.ACTIVE_LEVEL] = level;
               featureData[this.FOOD_SINKED] = this.CONSUMABLE_SINK_PREFILL_COUNT[level];
               featureData[this.HEALTH_SINKED] = this.CONSUMABLE_SINK_PREFILL_COUNT[level];
               featureData[this.HABITAT_SINKED] = this.CONSUMABLE_SINK_PREFILL_COUNT[level];
               currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
               featureData[this.KEY_FOOD_WAIT_TIME] = currentTime;
               featureData[this.KEY_HABITAT_WAIT_TIME] = currentTime;
               featureData[this.KEY_HEALTH_WAIT_TIME] = currentTime;
               if(animalSlot >= 1 && animalSlot <= 4)
               {
                  mileStoneReward = this.MILESTONE_REWARDS[animalSlot][level - 1];
                  Global.player.addGift(mileStoneReward,"",1);
               }
               if(level <= 3)
               {
                  milestoneCosumable = this.MILESTONE_CONSUMABLE_REWARDS[level - 1];
                  Global.player.addGift(milestoneCosumable,"",1);
               }
               if(level == 4)
               {
                  milestoneRewards = this.MILESTONE_FINAL_REWARDS[animalSlot - 1];
                  Global.player.addGift(milestoneRewards,"",1);
                  featureData["animal" + (animalSlot - 1)] = 2;
                  featureData["world" + (worldSlot - 1)] = 2;
                  featureData[this.STATUS] = 0;
                  featureData[this.KEY_ANIMAL_SLOT] = -1;
                  featureData[this.KEY_WORLD_SLOT] = -1;
                  featureData[this.ACTIVE_LEVEL] = 0;
                  featureData[this.FOOD_COUPON] = 10;
                  featureData[this.HEALTH_COUPON] = 10;
                  featureData[this.HABITAT_COUPON] = 10;
                  featureData[this.FOOD_SINKED] = this.CONSUMABLE_SINK_PREFILL_COUNT[0];
                  featureData[this.HEALTH_SINKED] = this.CONSUMABLE_SINK_PREFILL_COUNT[0];
                  featureData[this.HABITAT_SINKED] = this.CONSUMABLE_SINK_PREFILL_COUNT[0];
                  featureData[this.SELECTED_ANIMAL] = "";
                  featureData[this.SELECTED_WORLD] = "";
                  currentTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  featureData[this.KEY_FOOD_WAIT_TIME] = currentTime;
                  featureData[this.KEY_HABITAT_WAIT_TIME] = currentTime;
                  featureData[this.KEY_HEALTH_WAIT_TIME] = currentTime;
                  featureData[this.KEY_USER_STATE] = -1;
                  isFinalStage = true;
                  this.m_isupdatable = false;
                  if(this.m_mainWindow)
                  {
                     this.m_mainWindow.close();
                     this.showMainUI();
                  }
               }
               if(!isFinalStage && Boolean(this.m_mainWindow))
               {
                  this.mainWindow.refreshWindow();
               }
               setFeatureData(featureData);
               if(this.isFeatureCompleted)
               {
                  Global.player.addGift(this.FEATURE_COMPLETION_REWARD,"",1);
               }
               if(level == 4)
               {
                  this.m_stageRewardWindow = new AnimalSanctuaryV2StageCompleteRewardPopup(this.m_featureStageRewardUrl,m_featureName,this.MILESTONE_FINAL_REWARDS[animalSlot - 1],this.MILESTONE_REWARDS[animalSlot][level - 1]);
                  UI.displayPopup(this.m_stageRewardWindow,false);
                  StatsManager.count(FEATURE_NAME,"Milestone","animal_complete",this.getSelectedAnimal(),this.MILESTONE_REWARDS[animalSlot][level - 1],this.getSelectedWorld());
               }
               else
               {
                  reward = Global.farmGameSettingsManager.getFarmItemByName(this.MILESTONE_REWARDS[animalSlot][level - 1]);
                  reward2 = Global.farmGameSettingsManager.getFarmItemByName(this.MILESTONE_CONSUMABLE_REWARDS[level - 1]);
                  callback = this.grantRewardCallback;
                  this.m_milestoneRewardWindow = new AnimalSanctuaryV2MilestonePopup(this.m_featureMilestonePopUpUrl,m_featureName,reward,reward2,callback,REWARD_WINDOW_IMAGE,null,level);
                  UI.displayPopup(this.m_milestoneRewardWindow,false);
                  StatsManager.count(FEATURE_NAME,"Milestone",level.toString(),this.getSelectedAnimal(),reward.friendlyTitle,this.getSelectedWorld());
               }
               if(this.isFeatureCompleted)
               {
                  isBonusReward = this.isFeatureCompleted;
                  lastReward = Global.farmGameSettingsManager.getFarmItemByName(this.FEATURE_COMPLETION_REWARD);
                  this.m_finalRewardWindow = new AnimalSanctuaryV2StageCompleteRewardPopup(this.m_featureStageRewardUrl,m_featureName,this.FEATURE_COMPLETION_REWARD,null,isBonusReward);
                  UI.displayPopup(this.m_finalRewardWindow,false);
                  StatsManager.count(FEATURE_NAME,"Milestone","final_bonus",this.getSelectedAnimal(),lastReward.friendlyTitle,this.getSelectedWorld());
               }
            }
         }
      }
      
      public function grantRewardCallback(event:Event) : void
      {
         if(this.m_milestoneRewardWindow)
         {
            this.m_milestoneRewardWindow.close();
         }
      }
      
      public function getSinkedCouponCountByType(slotIndex:int) : int
      {
         var count:int = 0;
         var featureData:Object = this.getFeatureData();
         return int(featureData[this.VAL_COUPON_NAME_ARRAY[slotIndex]]);
      }
      
      public function getTotalCouponsAverage() : int
      {
         var ans:int = 0;
         for(var i:int = 0; i < 3; i++)
         {
            ans += this.getSinkedCouponCountByType(i);
         }
         return int(ans / 3);
      }
      
      public function getStageOfAnimal() : int
      {
         var stage:int = 0;
         var featureData:Object = this.getFeatureData();
         return int(featureData[this.ACTIVE_LEVEL]);
      }
      
      public function getUserState() : int
      {
         var state:int = -1;
         var featureData:Object = this.getFeatureData();
         return int(featureData[this.KEY_USER_STATE]);
      }
      
      protected function getFeatureOptionsKey(optionName:String) : Object
      {
         var fatureObject:Object = this.getFeatureData();
         return fatureObject[optionName];
      }
      
      protected function saveFeatureOptionsKey(optionName:String, optionsValue:Object) : void
      {
         var fatureObject:Object = this.getFeatureData();
         fatureObject[optionName] = optionsValue;
         setFeatureData(fatureObject);
      }
      
      public function closeMainWindow() : void
      {
         if(this.m_selectionWindow)
         {
            this.m_selectionWindow.close();
         }
      }
      
      public function isFeatureInActivePeriod() : Boolean
      {
         return FarmGameUtil.isFeatureInActivePeriod(this.bonusGrantDate,this.REDEEM_ADDITIONAL_DAYS);
      }
      
      public function isFeatureInRedeemPeriod() : Boolean
      {
         return !this.isFeatureInActivePeriod() && FarmGameUtil.isFeatureInActivePeriod(this.bonusGrantDate);
      }
      
      public function updateSelectedAnimalAndWorld() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"updateSelectedAnimalAndWorld",this.onUpdateAnimalAndWorld,[m_featureName,this.m_selectedAnimal,this.m_selectedWorld]),true);
      }
      
      public function onUpdateAnimalAndWorld(result:Object = null) : void
      {
         var featureData:Object = null;
         var time:Number = NaN;
         if(result)
         {
            this.selectionWindow.untintWindow();
            this.selectionWindow.enableInput = true;
            featureData = this.getFeatureData();
            featureData["animal" + this.m_selectedAnimal] = 1;
            featureData["world" + this.m_selectedWorld] = 1;
            featureData[this.SELECTED_ANIMAL] = this.VAL_ANIMAL_ARRAY[this.m_selectedAnimal];
            featureData[this.SELECTED_WORLD] = this.VAL_FARM_NAME_ARRAY[this.m_selectedWorld];
            featureData[this.STATUS] = 1;
            featureData[this.KEY_ANIMAL_SLOT] = this.m_selectedAnimal + 1;
            featureData[this.KEY_WORLD_SLOT] = this.m_selectedWorld + 1;
            if(result["wait_time"])
            {
               time = result["wait_time"] as Number;
               featureData[this.KEY_FOOD_WAIT_TIME] = time;
               featureData[this.KEY_HEALTH_WAIT_TIME] = time;
               featureData[this.KEY_HABITAT_WAIT_TIME] = time;
            }
            featureData[this.KEY_USER_STATE] = 1;
            setFeatureData(featureData);
            this.selectionWindow.close();
            StatsManager.count(FEATURE_NAME,"Select",this.getSelectedAnimal(),this.getSelectedWorld(),"","");
            this.showMainUI();
         }
      }
      
      public function getSelectedAnimalSlot() : int
      {
         var slot:int = 0;
         var featureData:Object = this.getFeatureData();
         return int(featureData[this.KEY_ANIMAL_SLOT]);
      }
      
      public function getSelectedWorldSlot() : int
      {
         var slot:int = 0;
         var featureData:Object = this.getFeatureData();
         return int(featureData[this.KEY_WORLD_SLOT]);
      }
      
      public function getSelectedAnimal() : String
      {
         var animal:String = null;
         var featureData:Object = this.getFeatureData();
         return featureData[this.SELECTED_ANIMAL];
      }
      
      public function getSelectedWorld() : String
      {
         var world:String = null;
         var featureData:Object = this.getFeatureData();
         return featureData[this.SELECTED_WORLD];
      }
      
      public function isSinkButtonEnabled(slotIndex:int) : Boolean
      {
         var result:Boolean = true;
         var featureObject:Object = this.getFeatureData();
         var level:int = int(featureObject[this.ACTIVE_LEVEL]);
         if(this.consumableCount(slotIndex) < 10 || featureObject[this.VAL_COUPON_NAME_ARRAY[slotIndex]] >= this.CONSUMABLE_COUNT_ARRAY[level])
         {
            result = false;
         }
         return result;
      }
      
      public function checkForCallOutText(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         var featureObject:Object = this.getFeatureData();
         var level:int = int(featureObject[this.ACTIVE_LEVEL]);
         if(featureObject[this.VAL_COUPON_NAME_ARRAY[slotIndex]] >= this.CONSUMABLE_COUNT_ARRAY[level])
         {
            result = true;
         }
         return result;
      }
      
      public function checkToShowStarvTime(slotIndex:int) : Boolean
      {
         var result:Boolean = true;
         var featureObject:Object = this.getFeatureData();
         var level:int = int(featureObject[this.ACTIVE_LEVEL]);
         if(featureObject[this.VAL_COUPON_NAME_ARRAY[slotIndex]] >= this.CONSUMABLE_COUNT_ARRAY[level])
         {
            result = false;
         }
         return result;
      }
      
      public function requiredCosumablesAvailable(slotIndex:int, isForStarve:Boolean = false) : Boolean
      {
         var result:Boolean = true;
         if(this.consumableCount(slotIndex) < 10)
         {
            result = false;
         }
         if(isForStarve && this.consumableCount(slotIndex) < 30)
         {
            result = false;
         }
         return result;
      }
      
      public function consumableCount(consumableSlotIndex:int) : int
      {
         var featureObject:Object = this.getFeatureData();
         return int(featureObject[this.COUPONS_ARRAY[consumableSlotIndex]]);
      }
      
      public function consumableFarmItem(consumableSlotIndex:int) : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.consumableCodeArray[consumableSlotIndex]);
      }
      
      public function hasActiveDayExpired() : Boolean
      {
         var expired:Boolean = false;
         var featureData:Object = this.getFeatureData();
         var activeTime:int = int(featureData[this.KEY_ACTIVE_DAY_TIMESTAMP]);
         var currenttime:int = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(currenttime - activeTime > 86400)
         {
            expired = true;
         }
         return expired;
      }
      
      public function getTimeLeftInDay() : Number
      {
         var dayExpiredTime:Number = FarmGameUtil.getMidnightTimestamp() / 1000 + 86400;
         var currenttime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return dayExpiredTime - currenttime;
      }
      
      public function openRewardViewWindow() : void
      {
         if(this.m_selectionWindow)
         {
            this.m_selectionWindow.tintWindow();
            this.m_selectionWindow.enableInput = false;
         }
         this.m_rewardWindow = new AnimalSanctuaryV2RewardWindow(m_featureName,this.rewardWindowURL);
         UI.displayPopup(this.m_rewardWindow,false);
      }
      
      public function get activeDayIndex() : int
      {
         var dayIndex:int = 0;
         var featureData:Object = this.getFeatureData();
         var activeDayTS:Number = featureData[this.KEY_ACTIVE_DAY_TIMESTAMP] as Number;
         var featureStartDayTS:Number = FarmGameUtil.synchronizedDateTimeToNumber("03/04/2019") / FarmGameUtil.NUM_MSECS_IN_SECOND;
         dayIndex = (activeDayTS - featureStartDayTS) / FarmGameUtil.NUM_SECS_IN_DAY;
         if(dayIndex < 0)
         {
            dayIndex = 0;
         }
         return dayIndex;
      }
      
      public function get isFeatureInMidway() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         for(var ind:int = 0; ind < 4; ind++)
         {
            if(featureData.hasOwnProperty(this.VAL_ANIMAL_INDEX_ARRAY[ind]) && featureData[this.VAL_ANIMAL_INDEX_ARRAY[ind]] == 1)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function get isFeatureCompleted() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.VAL_ANIMAL_INDEX_ARRAY[0]] == 2 && featureData[this.VAL_ANIMAL_INDEX_ARRAY[1]] == 2 && featureData[this.VAL_ANIMAL_INDEX_ARRAY[2]] == 2 && featureData[this.VAL_ANIMAL_INDEX_ARRAY[3]] == 2)
         {
            result = true;
         }
         return result;
      }
      
      public function isAnimalCompleted(index:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         for(var ind:int = 0; ind < 4; ind++)
         {
            if(featureData.hasOwnProperty(this.VAL_ANIMAL_INDEX_ARRAY[ind]))
            {
               if(ind == index && featureData[this.VAL_ANIMAL_INDEX_ARRAY[ind]] == 2)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function isWorldCompleted(index:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         for(var ind:int = 0; ind < 4; ind++)
         {
            if(featureData.hasOwnProperty(this.VAL_FARM_INDEX_ARRAY[ind]))
            {
               if(ind == index && featureData[this.VAL_FARM_INDEX_ARRAY[ind]] == 2)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function isAnimalInProgress(index:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         for(var ind:int = 0; ind < 4; ind++)
         {
            if(featureData.hasOwnProperty(this.VAL_ANIMAL_INDEX_ARRAY[ind]))
            {
               if(ind == index && featureData[this.VAL_ANIMAL_INDEX_ARRAY[ind]] == 1)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function isAnimalCompletedOrSelected(index:int) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         for(var ind:int = 0; ind < 4; ind++)
         {
            if(featureData.hasOwnProperty(this.VAL_ANIMAL_INDEX_ARRAY[ind]))
            {
               if(ind == index && (featureData[this.VAL_ANIMAL_INDEX_ARRAY[ind]] == 2 || featureData[this.VAL_ANIMAL_INDEX_ARRAY[ind]] == 1))
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function saveAnimalAndWorld(animal:String, world:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"saveAnimalAndWorld",null,[m_featureName,animal,world]),true);
         var featureData:Object = this.getFeatureData();
      }
      
      public function buyCoupons(couponIndex:int, slot:int) : void
      {
         if(Global.player.canBuyCash(this.COUPON_COST[slot]))
         {
            Global.player.cash -= this.COUPON_COST[slot];
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_NAME,"buyCoupons",this.onSuccessBuyCoupons,[m_featureName,couponIndex,slot]),true);
         }
      }
      
      public function grantCouponsasDrop(prog:int, reqTot:int, dropRate:int, taskType:String = "none", taskName:String = "none") : void
      {
         var count:int = 0;
         var availCount:int = 0;
         var featureData:Object = this.getFeatureData();
         var randCount:int = int(featureData[this.RAND_COUNT]);
         var remainder:int = prog / reqTot;
         var index:int = 0;
         while(index < remainder)
         {
            count = randCount % 9;
            availCount = int(featureData[this.COUPONS_GRANT_ARRAY[count]]);
            featureData[this.COUPONS_GRANT_ARRAY[count]] = availCount + dropRate;
            randCount++;
            index++;
            StatsManager.count(FEATURE_NAME,"source",taskType + ":" + taskName,featureData[this.COUPONS_GRANT_ARRAY[count]],this.COUPONS_GRANT_ARRAY[count],this.getSelectedWorld(),dropRate);
            if(this.m_AnimalSanctuaryV2Hud)
            {
               if(this.COUPONS_GRANT_ARRAY[count] == "food_coupon")
               {
                  this.m_AnimalSanctuaryV2Hud.showDooberOnTaskComplete("Food Coupon",dropRate,this.getNPCAnimalSlot() + 0);
               }
               else if(this.COUPONS_GRANT_ARRAY[count] == "health_coupon")
               {
                  this.m_AnimalSanctuaryV2Hud.showDooberOnTaskComplete("Habitat Coupon",dropRate,this.getNPCAnimalSlot() + 1);
               }
               else if(this.COUPONS_GRANT_ARRAY[count] == "habitat_coupon")
               {
                  this.m_AnimalSanctuaryV2Hud.showDooberOnTaskComplete("Health Coupon",dropRate,this.getNPCAnimalSlot() + 2);
               }
            }
         }
         featureData[this.RAND_COUNT] = randCount;
         setFeatureData(featureData);
      }
      
      public function getNPCAnimalSlot() : int
      {
         if(this.getSelectedAnimal() == "bigcat_royalbengaltiger")
         {
            return 7;
         }
         if(this.getSelectedAnimal() == "bear_ice")
         {
            return 4;
         }
         if(this.getSelectedAnimal() == "zebra_savannah")
         {
            return 10;
         }
         return 1;
      }
      
      public function getFoodCouponUrl() : String
      {
         return Global.getAssetURL(this.ASSET_PATH + this.ANIMAL_COUPONS_FOOD_IMAGES[this.getAnimalId()] + "_icon_35.png");
      }
      
      public function getHealthCouponUrl() : String
      {
         return Global.getAssetURL(this.ASSET_PATH + this.ANIMAL_COUPONS_HEALTH_IMAGES[this.getAnimalId()] + "_icon_35.png");
      }
      
      public function getHabitatCouponUrl() : String
      {
         return Global.getAssetURL(this.ASSET_PATH + this.ANIMAL_COUPONS_HABITAT_IMAGES[this.getAnimalId()] + "_icon_35.png");
      }
      
      public function onSuccessBuyCoupons(result:Object) : void
      {
         var featureData:Object = null;
         var coupon:String = null;
         var count:int = 0;
         if(!result["error"])
         {
            featureData = this.getFeatureData();
            coupon = result["coupon_type"] as String;
            count = result["coupon_count"] as int;
            featureData[coupon] = count;
            setFeatureData(featureData);
            if(this.m_mainWindow)
            {
               this.m_mainWindow.refreshCouponsCount();
               this.m_mainWindow.refreshWindow();
            }
            if(this.m_packageBuyWindow)
            {
               this.m_packageBuyWindow.untintWindow();
               this.m_packageBuyWindow.enableInput = true;
            }
         }
      }
      
      public function onTravelButtonClick() : void
      {
         var worldType:String = null;
         var hasUnlockedWorld:Boolean = false;
         var selectedFarm:String = this.getSelectedWorld();
         if(Global.worldManager.currentWorldType != selectedFarm)
         {
            worldType = selectedFarm;
            if(Boolean(worldType) && worldType.length > 0)
            {
               hasUnlockedWorld = Global.worldManager.hasUnlockedWorld(worldType);
               if(hasUnlockedWorld)
               {
                  Global.worldManager.swapFarm(worldType,false);
                  Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
               }
            }
         }
         StatsManager.count(FEATURE_NAME,"travel","farm","","",this.getSelectedWorld());
      }
      
      private function onWorldLoaded(event:FarmGameWorldEvent) : void
      {
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
            this.showMainUI();
         }
      }
      
      public function getCropsByWorld(world:String) : Array
      {
         var cropData:XML = null;
         var cropList:Array = [];
         for each(cropData in this.m_cropsByName)
         {
            if(cropData.@world == world)
            {
               cropList.push(cropData.@name);
            }
         }
         return cropList.sort();
      }
      
      public function getAnimalsByWorld(world:String) : Array
      {
         var animalData:XML = null;
         var animalList:Array = [];
         for each(animalData in this.m_animalsByName)
         {
            if(animalData.@world == world)
            {
               animalList.push(animalData.@name);
            }
         }
         return animalList;
      }
      
      public function getRecipesByWorld(world:String) : Array
      {
         var recipeData:XML = null;
         var recipeList:Array = [];
         for each(recipeData in this.m_recipesByCode)
         {
            if(recipeData.@world == world)
            {
               recipeList.push(recipeData.@code);
            }
         }
         return recipeList.sort();
      }
      
      public function getViralTask() : FarmTask
      {
         var farmTask:FarmTask = null;
         var viralData:XML = null;
         var taskObj:Object = null;
         for each(viralData in this.m_viralData)
         {
            taskObj = {};
            taskObj.questName = m_featureName;
            taskObj.action = "useItemByCode";
            taskObj.type = viralData.@type;
            taskObj.helper = "post_ask_for_item_special_quest";
            taskObj.total = viralData.@total;
            taskObj.cashValue = "";
            farmTask = new FarmTask(taskObj);
         }
         return farmTask;
      }
      
      public function isDropLimitReached() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         var food:int = featureData[this.FOOD_COUPON] as int;
         var health:int = featureData[this.HEALTH_COUPON] as int;
         var habitat:int = featureData[this.HABITAT_COUPON] as int;
         if(food >= KEY_MX_COUPON && health >= KEY_MX_COUPON && habitat >= KEY_MX_COUPON)
         {
            result = true;
         }
         return result;
      }
      
      public function getCallOutTextByAnimal(animal:String, type:int) : String
      {
         var text:String = "";
         if(this.getSelectedAnimal() == "bigcat_royalbengaltiger")
         {
            if(type == 0)
            {
               text = "Grrrrrr! [Hungry]";
            }
            else if(type == 1)
            {
               text = "Eeeeeee! [Sick]";
            }
            else if(type == 2)
            {
               text = "Squeel! [Unsafe]";
            }
            else if(type == 5)
            {
               text = "Roarrrr! [Excited]";
            }
         }
         else if(this.getSelectedAnimal() == "bear_ice")
         {
            if(type == 0)
            {
               text = "Grrrrrr! [Hungry]";
            }
            else if(type == 1)
            {
               text = "Yowl! [Sick]";
            }
            else if(type == 2)
            {
               text = "Hissss! [Unsafe]";
            }
            else if(type == 5)
            {
               text = "Chuff! [Excited]";
            }
         }
         else if(this.getSelectedAnimal() == "zebra_savannah")
         {
            if(type == 0)
            {
               text = "Brayyy! [Hungry]";
            }
            else if(type == 1)
            {
               text = "Snortttt! [Sick]";
            }
            else if(type == 2)
            {
               text = "Barkk! [Unsafe]";
            }
            else if(type == 5)
            {
               text = "Neigh! [Excited]";
            }
         }
         else if(this.getSelectedAnimal() == "bird_wildwesteagle")
         {
            if(type == 0)
            {
               text = "Squawkkk! [Hungry]";
            }
            else if(type == 1)
            {
               text = "Cooooo! [Sick]";
            }
            else if(type == 2)
            {
               text = "Squeel! [Unsafe]";
            }
            else if(type == 5)
            {
               text = "Screeee! [Excited]";
            }
         }
         return text;
      }
      
      public function getFeatureEndDaysLeftText() : String
      {
         var timeLeft:Number = NaN;
         timeLeft = (FarmGameUtil.synchronizedDateToNumber(DATE_FEATURE_END) - this.REDEEM_ADDITIONAL_DAYS * FarmGameUtil.NUM_MSECS_IN_DAY - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
         return HUD.getformattedTimeLeft(timeLeft);
      }
      
      public function openTasksWindow() : void
      {
         if(this.mainWindow)
         {
            this.mainWindow.tintWindow();
            this.mainWindow.enableInput = false;
         }
         this.m_tasksWindow = new AnimalSanctuaryV2TasksWindow(m_featureName,this.craftWindowUrl);
         UI.displayPopup(this.m_tasksWindow,false);
      }
      
      public function getCropProgress(itemName:String) : int
      {
         var featureObject:Object = this.getFeatureData();
         var savedCropProgress:* = featureObject[KEY_SAVED_BUSHEL_PROGRESS];
         return int(savedCropProgress[itemName]);
      }
      
      public function getViralProgress(itemCode:String) : int
      {
         var featureObject:Object = this.getFeatureData();
         var savedViralProgress:* = featureObject[this.KEY_SAVED_VIRAL_PROGRESS];
         return int(savedViralProgress[itemCode]);
      }
      
      public function getSinkTimeLeftForResource(resourceId:int) : int
      {
         return int(this.getMaxResourceSinkTime() - this.getResourceSinkWaitTime(this.VAL_COUPON_NAME_ARRAY[resourceId] + "_wait_time"));
      }
      
      public function getResourceStateForCurrentAnimal(resourceId:int) : int
      {
         var state:int = 0;
         var sinkTime:int = this.getSinkTimeLeftForResource(resourceId);
         if(this.checkToShowStarvTime(resourceId))
         {
            if(sinkTime <= 0)
            {
               state = this.STATE_CRITICAL;
            }
            else if(sinkTime < KEY_WARN_TIME)
            {
               state = this.STATE_WARNING;
            }
            else
            {
               state = this.STATE_NORMAL;
            }
         }
         else
         {
            state = this.STATE_COMPLETE;
         }
         return state;
      }
      
      public function isNPCFlagSet(npcFlag:String) : Boolean
      {
         return this.getFeatureOptionsKey(npcFlag) as Boolean;
      }
      
      public function setNPCFlag(npcFlag:String) : void
      {
         this.saveFeatureOptionsKey(npcFlag,true);
      }
      
      public function reSetNPCFlag(npcFlag:String) : void
      {
         this.saveFeatureOptionsKey(npcFlag,false);
      }
      
      public function getAnimalId() : int
      {
         var result:int = 0;
         var featureData:Object = this.getFeatureData();
         for(var ind:int = 0; ind < 4; ind++)
         {
            if(featureData.hasOwnProperty(this.VAL_ANIMAL_INDEX_ARRAY[ind]) && featureData[this.VAL_ANIMAL_INDEX_ARRAY[ind]] == 1)
            {
               result = ind;
            }
         }
         return result;
      }
      
      public function getWorldId() : int
      {
         var result:int = 0;
         var featureData:Object = this.getFeatureData();
         for(var ind:int = 0; ind < 4; ind++)
         {
            if(featureData.hasOwnProperty(this.VAL_ANIMAL_INDEX_ARRAY[ind]) && featureData[this.VAL_ANIMAL_INDEX_ARRAY[ind]] == 1)
            {
               result = ind;
            }
         }
         return result;
      }
      
      public function getOtherAnimalsData() : Array
      {
         var otherAnimalsData:Array = [];
         for(var i:int = 0; i < this.VAL_ANIMAL_NAME_ARRAY.length; i++)
         {
            if(i != this.getAnimalId())
            {
               otherAnimalsData.push({
                  "name":this.VAL_ANIMAL_ARRAY[i],
                  "world":this.VAL_FARM_NAMES_ARRAY[i],
                  "friendlyTitle":this.VAL_MAIN_ANIMAL_NAME_ARRAY[i],
                  "iconUrl":"assets/dialogs/animal_sanctuary_april_2020/" + this.VAL_ANIMAL_ICON_NAMES[i]
               });
            }
         }
         return otherAnimalsData;
      }
      
      public function getSelectedAnimalData() : Object
      {
         for(var i:int = 0; i < this.VAL_ANIMAL_NAME_ARRAY.length; i++)
         {
            if(i == this.getAnimalId())
            {
               return {
                  "name":this.VAL_ANIMAL_ARRAY[i],
                  "world":this.VAL_FARM_NAMES_ARRAY[i],
                  "friendlyTitle":this.VAL_MAIN_ANIMAL_NAME_ARRAY[i],
                  "iconUrl":"assets/dialogs/animal_sanctuary_april_2020/" + this.VAL_ANIMAL_ICON_NAMES[i]
               };
            }
         }
         return {};
      }
      
      public function featureEnd() : void
      {
         this.m_featureEndWindow = new AnimalSanctuaryV2EndWindow(FEATURE_NAME,this.endMainWindow);
         UI.displayPopup(this.m_featureEndWindow,false);
      }
   }
}

