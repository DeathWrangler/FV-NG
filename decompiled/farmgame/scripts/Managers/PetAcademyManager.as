package Managers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import Widgets.Windows.PetAcademyExamWindow;
   import Widgets.Windows.PetAcademyMainWindow;
   import Widgets.Windows.PetAcademyMileStoneWindow;
   import Widgets.Windows.PetAcademyProfessionGrantWindow;
   import flash.events.Event;
   
   public class PetAcademyManager extends BaseFeatureManager
   {
      
      private static var m_initialized:Boolean = false;
      
      protected static var m_instance:Object = {};
      
      public static const FEED1_NAME:String = "rainbowOrb";
      
      public static const FEED2_NAME:String = "shamanStone";
      
      public static const FEED3_NAME:String = "hexBall";
      
      private static const CRAFTSHOP_CONSUMABLE_TAB:String = "consumable";
      
      private static const NUM_ADDITONAL_DAYS:int = 2;
      
      private var m_assetPaths:Object = null;
      
      protected var m_featureConfigData:Object;
      
      private var m_mainWindow:PetAcademyMainWindow;
      
      private var m_endTimeString:String;
      
      private var m_endTime:Number;
      
      private const EXAM_STATUS:String = "status";
      
      private const ACTIVE_ANIMAL:String = "aa";
      
      private const ACTIVE_PROFESSION:String = "ap";
      
      private const PROGRESS:String = "ep";
      
      private const IDLE:int = 0;
      
      private const ACTIVE:int = 1;
      
      private const INCOMPLETE:int = 0;
      
      private const COMPLETED:int = 1;
      
      private var m_examWindow:PetAcademyExamWindow;
      
      private const WINDOW_MAIN:String = "main";
      
      private const WINDOW_EXAM:String = "exam";
      
      private const KEY_OWNED_ANIMAL_LIST:String = "owned";
      
      private const ACTIVE_LEVEL:String = "al";
      
      private var m_checkQuestCompelete:Boolean;
      
      private const KEY_ANIMAL_COST:String = "ac";
      
      public const consumableCodeArray:Array = ["336z","to24","vstu"];
      
      private const SERVICE_CLASS:String = "PetAcademyService";
      
      private const SERVICE_FUNC_SINK_CONSUMABLE:String = "sinkConsumable";
      
      private const MILESTONE_STATUS:String = "pms";
      
      private const SERVICE_FUNC_BUY_ANIMAL:String = "buyAnimal";
      
      private const SERVICE_FUNC_INIIALIZE_EXAM:String = "initializeExam";
      
      private const SERVICE_FUNC_BUY_ANIMAL_COST:String = "buyAnimalByCost";
      
      private const SERVICE_FUNC_UNLOCK_ANIMAL:String = "unlockAnimalByPrevious";
      
      private const SERVICE_FUNC_UNLOCK_ALL:String = "buyAllAnimalsByCost";
      
      private var m_configManager:FeatureConfigManager;
      
      public function PetAcademyManager(featureName:String)
      {
         super(featureName);
         this.m_featureConfigData = new Object();
      }
      
      public static function getInstance(featureName:String = "AnimalUniversity2019_V2") : PetAcademyManager
      {
         return getInstanceOfClass(featureName,PetAcademyManager) as PetAcademyManager;
      }
      
      protected function loadFeatureConfig() : void
      {
         var animalXML:XML = null;
         var examPkg:Array = null;
         var name:String = null;
         var professionsXML:XML = null;
         var asset:XML = null;
         var animalName:String = null;
         var animalPrice:int = 0;
         var professionXML:XML = null;
         var professionNameStr:String = null;
         var cost:int = 0;
         var examXML:XML = null;
         var reward:String = null;
         this.m_featureConfigData = {};
         this.m_featureConfigData.animalNames = [];
         this.m_featureConfigData.buyPackages = [];
         this.m_featureConfigData.buyPackages[0] = ["pkg_rainbowOrb_10","pkg_rainbowOrb_20","pkg_rainbowOrb_50"];
         this.m_featureConfigData.buyPackages[1] = ["pkg_shamanStone_10","pkg_shamanStone_20","pkg_shamanStone_50"];
         this.m_featureConfigData.buyPackages[2] = ["pkg_hexBall_10","pkg_hexBall_20","pkg_hexBall_50"];
         this.m_featureConfigData.animalPrices = [];
         this.m_featureConfigData.professions = {};
         this.m_featureConfigData.cost = {};
         this.m_featureConfigData.exmas = {};
         this.m_featureConfigData.rewardForEachProfession = {};
         this.m_featureConfigData.bonusRewardForAnimal = {};
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(m_featureName);
         if(featureXML != null)
         {
            m_initialized = true;
            this.m_endTimeString = featureXML.listEndDate;
            this.m_assetPaths = {};
            if(featureXML.assets != "")
            {
               for each(asset in featureXML.assets.asset)
               {
                  this.m_assetPaths[asset.@name] = asset.@path.toString();
               }
            }
            for each(animalXML in featureXML.petanimals.petanimal)
            {
               animalName = animalXML.@name.toString();
               animalPrice = int(animalXML.@price.toString());
               this.m_featureConfigData.animalNames.push(animalName);
               this.m_featureConfigData.animalPrices.push(animalPrice);
               this.m_featureConfigData.professions[animalName] = [];
               this.m_featureConfigData.cost[animalName] = [];
               this.m_featureConfigData.exmas[animalName] = {};
               for each(professionXML in animalXML.professions.profession)
               {
                  professionNameStr = professionXML.@name.toString();
                  cost = int(professionXML.@cost.toString());
                  this.m_featureConfigData.professions[animalName].push(professionNameStr);
                  this.m_featureConfigData.cost[animalName].push(cost);
                  this.m_featureConfigData.exmas[animalName][professionNameStr] = [];
                  for each(examXML in professionXML.exams.exam)
                  {
                     examPkg = [];
                     examPkg.push(int(examXML.@c1));
                     examPkg.push(int(examXML.@c2));
                     examPkg.push(int(examXML.@c3));
                     this.m_featureConfigData.exmas[animalName][professionNameStr].push(examPkg);
                  }
               }
            }
            for each(animalXML in featureXML.petanimals.petanimal)
            {
               name = animalXML.@name.toString();
               this.m_featureConfigData.bonusRewardForAnimal[name] = {};
               for each(professionsXML in animalXML.professions)
               {
                  reward = professionsXML.@bonus.toString();
                  this.m_featureConfigData.bonusRewardForAnimal[name] = reward;
               }
            }
         }
      }
      
      public function getAminalNames() : Array
      {
         return this.m_featureConfigData.animalNames;
      }
      
      public function get AminalPrices() : Array
      {
         return this.m_featureConfigData.animalPrices;
      }
      
      public function getProfessionsForAnimal(animalName:String) : Array
      {
         return this.m_featureConfigData.professions[animalName];
      }
      
      public function getSlotIndexforAnimal(animalName:String) : int
      {
         var slotIndex:int = 0;
         var animals:Array = this.getAminalNames();
         for(var i:int = 0; i < animals.length; i++)
         {
            if(animals[i] == animalName)
            {
               slotIndex = i;
               break;
            }
         }
         return slotIndex;
      }
      
      public function getProfessionForSlot(animalName:String, slotIndex:int) : String
      {
         return this.m_featureConfigData.professions[animalName][slotIndex];
      }
      
      public function getProfessionsForAnimalCost(animalName:String) : Array
      {
         return this.m_featureConfigData.cost[animalName];
      }
      
      public function getBonusReward(animalName:String) : String
      {
         return this.m_featureConfigData.bonusRewardForAnimal[animalName];
      }
      
      public function getExamForAnimalProfesion(animalName:String, profesionName:String) : Array
      {
         return this.m_featureConfigData.exmas[animalName][profesionName];
      }
      
      public function getConsumableRequiredForAnimalExamLevel(animalName:String, profesionName:String, level:Number) : Array
      {
         var examSet:Array = this.getExamForAnimalProfesion(animalName,profesionName);
         return examSet[level];
      }
      
      public function get mainWindowURL() : String
      {
         return this.m_assetPaths[this.WINDOW_MAIN];
      }
      
      public function get examWindowUrl() : String
      {
         return this.m_assetPaths[this.WINDOW_EXAM];
      }
      
      private function get endTimeNumber() : Number
      {
         if(this.m_endTime)
         {
            return this.m_endTime;
         }
         this.m_endTime = FarmGameUtil.synchronizedDateTimeToNumber(this.m_endTimeString) / 1000;
         return this.m_endTime;
      }
      
      public function handleHUDClick(showEATutorialPage:Boolean = false) : void
      {
         if(!m_initialized)
         {
            this.initialize();
         }
         FarmStatsManager.count("AnimalUniversity","Main_UI","open_window");
         this.m_mainWindow = new PetAcademyMainWindow(m_featureName,this.mainWindowURL,showEATutorialPage);
         UI.displayPopup(this.m_mainWindow);
      }
      
      public function showExamUI(e:Event) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         this.m_examWindow = new PetAcademyExamWindow(m_featureName,this.examWindowUrl);
         UI.displayPopup(this.m_examWindow,false);
         FarmStatsManager.count("animal_academy","click_activeexam",this.activeProfession);
      }
      
      public function initializeExam(animalsName:String, professionName:String) : void
      {
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            featureData[this.EXAM_STATUS] = this.ACTIVE;
            featureData[this.ACTIVE_ANIMAL] = animalsName;
            featureData[this.ACTIVE_PROFESSION] = professionName;
            featureData[this.ACTIVE_LEVEL] = 0;
            for(i = 0; i < 3; i++)
            {
               featureData[this.PROGRESS][i] = this.INCOMPLETE;
            }
            setFeatureData(featureData);
         }
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_INIIALIZE_EXAM,null,[m_featureName,animalsName,professionName]),true);
      }
      
      public function isAnyExamActive() : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(this.EXAM_STATUS) && featureData[this.EXAM_STATUS] == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function buyConsumable(slotIndex:int, owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow("assets/dialogs/AnimalAcademy2019_v2/FV_AnimalAcademy_BuyCraft2019_v2.swf",m_featureName + "_" + this.consumableCodeArray[slotIndex],this.getBucketPackages(slotIndex),owner),false);
      }
      
      public function getBucketPackages(slotIndex:int) : Array
      {
         return this.m_featureConfigData.buyPackages[slotIndex];
      }
      
      public function craftConsumable(slotIndex:int) : void
      {
         if(this.m_examWindow)
         {
            this.m_examWindow.close();
         }
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         var consumableSearchStr:String = this.consumableFarmItem(slotIndex).friendlyTitle;
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),consumableSearchStr,this.m_mainWindow,CRAFTSHOP_CONSUMABLE_TAB);
      }
      
      public function craftConsumableFromMainWindow(slotIndex:int) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.close();
         }
         var consumableSearchStr:String = this.consumableFarmItem(slotIndex).friendlyTitle;
         CraftingManager.getInstance().openCraftshopWindow(CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType),consumableSearchStr,this.m_mainWindow,CRAFTSHOP_CONSUMABLE_TAB);
      }
      
      public function askConsumable(slotIndex:int) : void
      {
         switch(slotIndex)
         {
            case 0:
               this.askForConsumable1();
               §§goto(addr009e);
            case 1:
               this.askForConsumable2();
               addr009e:
               return;
            case 2:
               this.askForConsumable3();
         }
      }
      
      private function initialize() : void
      {
         this.loadFeatureConfig();
      }
      
      public function getFeatureData() : Object
      {
         var i:int = 0;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(m_featureName,m_featureName);
         if(!featureData || !featureData.hasOwnProperty(this.EXAM_STATUS))
         {
            featureData = new Object();
            featureData[this.EXAM_STATUS] = this.IDLE;
            featureData[this.ACTIVE_ANIMAL] = "";
            featureData[this.ACTIVE_PROFESSION] = "";
            featureData[this.ACTIVE_LEVEL] = 0;
            featureData[this.KEY_OWNED_ANIMAL_LIST] = {};
            featureData[this.KEY_OWNED_ANIMAL_LIST]["cat"] = 1;
            featureData[this.KEY_OWNED_ANIMAL_LIST]["dog"] = 1;
            featureData[this.KEY_OWNED_ANIMAL_LIST]["pig"] = 1;
            featureData[this.KEY_OWNED_ANIMAL_LIST]["goat"] = 1;
            featureData[this.KEY_OWNED_ANIMAL_LIST]["cow"] = 0;
            featureData[this.KEY_OWNED_ANIMAL_LIST]["horse"] = 0;
            featureData[this.KEY_ANIMAL_COST] = {};
            featureData[this.KEY_ANIMAL_COST]["dog_tourguide"] = 0;
            featureData[this.KEY_ANIMAL_COST]["monkey_delightbringer"] = 0;
            featureData[this.KEY_ANIMAL_COST]["cow_bartender"] = 0;
            featureData[this.KEY_ANIMAL_COST]["duck_manager"] = 0;
            featureData[this.KEY_ANIMAL_COST]["chicken_topperformer"] = 0;
            featureData[this.KEY_ANIMAL_COST]["duck_toolmaker"] = 0;
            featureData[this.KEY_ANIMAL_COST]["horse_roboticslearner"] = 0;
            featureData[this.KEY_ANIMAL_COST]["cow_techsupport"] = 0;
            featureData[this.KEY_ANIMAL_COST]["goat_aviator"] = 0;
            featureData[this.KEY_ANIMAL_COST]["pig_shipcaptain"] = 0;
            featureData[this.KEY_ANIMAL_COST]["cow_spacetravel"] = 0;
            featureData[this.KEY_ANIMAL_COST]["horse_transportmechanic"] = 0;
            featureData[this.KEY_ANIMAL_COST]["pig_explorer"] = 0;
            featureData[this.KEY_ANIMAL_COST]["goat_forestguide"] = 0;
            featureData[this.KEY_ANIMAL_COST]["cow_zookeeper"] = 0;
            featureData[this.KEY_ANIMAL_COST]["horse_beekeeper"] = 0;
            featureData[this.KEY_ANIMAL_COST]["gorilla_tailor"] = 0;
            featureData[this.KEY_ANIMAL_COST]["bear_makeup"] = 0;
            featureData[this.KEY_ANIMAL_COST]["chicken_barber"] = 0;
            featureData[this.KEY_ANIMAL_COST]["horse_tattooartist"] = 0;
            featureData[this.KEY_ANIMAL_COST]["goat_shaolinmaster"] = 0;
            featureData[this.KEY_ANIMAL_COST]["cow_blacksmith"] = 0;
            featureData[this.KEY_ANIMAL_COST]["dog_potionmaker"] = 0;
            featureData[this.KEY_ANIMAL_COST]["horse_ancienthistorian"] = 0;
            featureData[this.PROGRESS] = new Array();
            for(i = 0; i < 3; i++)
            {
               featureData[this.PROGRESS][i] = this.INCOMPLETE;
            }
            setFeatureData(featureData);
         }
         return featureData;
      }
      
      public function get activeAnimal() : String
      {
         var name:String = "";
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            name = featureData[this.ACTIVE_ANIMAL];
         }
         return name;
      }
      
      public function get activeProfession() : String
      {
         var profession:String = "";
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            profession = featureData[this.ACTIVE_PROFESSION];
         }
         return profession;
      }
      
      public function get activeExamLevel() : int
      {
         var level:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            level = int(featureData[this.ACTIVE_LEVEL]);
         }
         return level;
      }
      
      public function activeExamSetProgress(consumableSlot:int) : int
      {
         var level:int = 0;
         var featureData:Object = this.getFeatureData();
         if(featureData)
         {
            level = int(featureData[this.PROGRESS][consumableSlot]);
         }
         return level;
      }
      
      public function askForConsumable1(event:Event = null) : void
      {
         getFeedData(FEED1_NAME).postFeed(this.onaskForConsumableRefresh);
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButtons();
         }
      }
      
      public function askForConsumable2(event:Event = null) : void
      {
         getFeedData(FEED2_NAME).postFeed(this.onaskForConsumableRefresh);
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButtons();
         }
      }
      
      public function askForConsumable3(event:Event = null) : void
      {
         getFeedData(FEED3_NAME).postFeed(this.onaskForConsumableRefresh);
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButtons();
         }
      }
      
      private function onaskForConsumableRefresh(e:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButtons();
         }
      }
      
      private function onaskForTreatBall(e:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButtons();
         }
      }
      
      private function onaskForTrainingDumbbell(e:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButtons();
         }
      }
      
      private function onaskForRunes(e:Object) : void
      {
         if(this.m_mainWindow)
         {
            this.m_mainWindow.refreshAskButtons();
         }
      }
      
      public function isAnimalUnlocked(animalName:String) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_OWNED_ANIMAL_LIST])
         {
            if(Boolean(featureData[this.KEY_OWNED_ANIMAL_LIST].hasOwnProperty(animalName)) && featureData[this.KEY_OWNED_ANIMAL_LIST][animalName] == 1)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function isAnimalUnlockedByCost(animalName:String) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[this.KEY_ANIMAL_COST])
         {
            if(Boolean(featureData[this.KEY_ANIMAL_COST].hasOwnProperty(animalName)) && featureData[this.KEY_ANIMAL_COST][animalName] > 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function canBuyAnimal(slotIndex:int) : Boolean
      {
         var result:Boolean = false;
         if(Global.player.canBuyCash(int(this.AminalPrices[slotIndex])))
         {
            result = true;
         }
         return result;
      }
      
      public function buyAnimal(slotIndex:int) : void
      {
         var animalName:String = null;
         var featureData:Object = this.getFeatureData();
         if(Global.player.canBuyCash(int(this.AminalPrices[slotIndex])))
         {
            Global.player.cash -= int(this.AminalPrices[slotIndex]);
            animalName = this.getAminalNames()[slotIndex];
            featureData[this.KEY_OWNED_ANIMAL_LIST][animalName] = 1;
            setFeatureData(featureData);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_BUY_ANIMAL,null,[m_featureName,slotIndex]),true);
         }
      }
      
      public function buyAnimalByCost(animalCost:int, animalName:String) : void
      {
         var featureData:Object = this.getFeatureData();
         if(Global.player.canBuyCash(int(animalCost)))
         {
            Global.player.cash -= int(animalCost);
            featureData[this.KEY_ANIMAL_COST][animalName] = 0;
            setFeatureData(featureData);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_BUY_ANIMAL_COST,null,[m_featureName,animalName]),true);
         }
      }
      
      public function getBuyAllAverage(animalName:String) : int
      {
         var featureData:Object = this.getFeatureData();
         var professionsArray:Array = this.getProfessionsForAnimal(animalName);
         var sumCost:int = 0;
         for(var i:int = 1; i < professionsArray.length; i++)
         {
            if(featureData[this.KEY_ANIMAL_COST][professionsArray[i]])
            {
               sumCost += featureData[this.KEY_ANIMAL_COST][professionsArray[i]];
            }
         }
         return int(Math.ceil(sumCost - 0.2 * sumCost));
      }
      
      public function countLockedProfessions(animalName:String) : int
      {
         var featureData:Object = this.getFeatureData();
         var professionsArray:Array = this.getProfessionsForAnimal(animalName);
         var lockCount:* = 0;
         for(var i:int = 0; i < professionsArray.length; i++)
         {
            if(featureData[this.KEY_ANIMAL_COST][professionsArray[i]])
            {
               lockCount++;
            }
         }
         return lockCount;
      }
      
      public function buyAllAnimalsByCost(animalName:String) : void
      {
         var i:int = 0;
         var featureData:Object = this.getFeatureData();
         var professionsArray:Array = this.getProfessionsForAnimal(animalName);
         var animalCost:int = this.getBuyAllAverage(animalName);
         if(Global.player.canBuyCash(animalCost))
         {
            Global.player.cash -= animalCost;
            for(i = 1; i < professionsArray.length; i++)
            {
               if(featureData[this.KEY_ANIMAL_COST][professionsArray[i]])
               {
                  featureData[this.KEY_ANIMAL_COST][professionsArray[i]] = 0;
               }
            }
            setFeatureData(featureData);
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_UNLOCK_ALL,null,[m_featureName,animalName]),true);
         }
      }
      
      public function getProfessionsOwnedForAnimal(animalName:String) : Object
      {
         var result:Object = {};
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(animalName))
         {
            result = featureData[animalName];
         }
         return result;
      }
      
      public function hasCompletedProfession(animal:String, profession:String, slotIndex:int) : Boolean
      {
         var professions:Array = null;
         var n:int = 0;
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData.hasOwnProperty(animal))
         {
            if(Boolean(featureData[animal].hasOwnProperty(profession)) && featureData[animal][profession] == 1)
            {
               result = true;
               professions = this.getProfessionsForAnimal(animal);
               n = int(professions.length);
               if(slotIndex + 1 != n)
               {
                  featureData[this.KEY_ANIMAL_COST][professions[slotIndex + 1]] = 0;
                  TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_UNLOCK_ANIMAL,null,[m_featureName,professions[slotIndex + 1]]),true);
               }
            }
         }
         return result;
      }
      
      public function consumableFarmItem(consumableSlotIndex:int) : FarmItem
      {
         return Global.farmGameSettingsManager.getFarmItemByCode(this.consumableCodeArray[consumableSlotIndex]);
      }
      
      public function consumableCount(consumableSlotIndex:int) : int
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.consumableFarmItem(consumableSlotIndex).code));
      }
      
      public function sinkConsumable(slotIndex:int) : void
      {
         var requiredConsumableCount:int = int(this.getConsumableRequiredForAnimalExamLevel(this.activeAnimal,this.activeProfession,this.activeExamLevel)[slotIndex]);
         FeatureOptionsInventoryManager.getInstance().removeCount(this.consumableCodeArray[slotIndex],requiredConsumableCount);
         var featureData:Object = this.getFeatureData();
         featureData[this.PROGRESS][slotIndex] = 1;
         setFeatureData(featureData);
         var isQuestComplete:Boolean = this.checkStageCompletion();
         this.m_checkQuestCompelete = isQuestComplete;
         if(isQuestComplete)
         {
            this.doPostStageCompletionTask();
         }
         else if(this.m_examWindow)
         {
            this.m_examWindow.refreshWindow();
         }
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_SINK_CONSUMABLE,null,[m_featureName,slotIndex]),true);
      }
      
      public function checkStageCompletion() : Boolean
      {
         var isComplete:Boolean = false;
         var count:int = 0;
         var featureData:Object = this.getFeatureData();
         var consumableCountArray:Array = this.getConsumableRequiredForAnimalExamLevel(this.activeAnimal,this.activeProfession,this.activeExamLevel);
         for(var i:int = 0; i < 3; i++)
         {
            if(consumableCountArray[i] == 0 || featureData[this.PROGRESS][i] == 1)
            {
               count++;
            }
         }
         if(count == 3)
         {
            isComplete = true;
         }
         return isComplete;
      }
      
      public function checkStageCompletionForAnimationToPlay() : Boolean
      {
         return this.m_checkQuestCompelete;
      }
      
      public function get congratsDialogURL() : String
      {
         return "assets/dialogs/AnimalAcademy2019_v2/FV_AnimalAcademy_Prize2019_v2.swf";
      }
      
      private function doPostStageCompletionTask() : void
      {
         var professionComplete:Boolean = false;
         var featureData:Object = this.getFeatureData();
         var professionalItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.activeProfession);
         var animalName:String = this.activeAnimal;
         if(this.activeExamLevel == 4)
         {
            professionComplete = true;
            Global.player.addGift(this.activeProfession);
            if(!featureData.hasOwnProperty(this.activeAnimal))
            {
               featureData[this.activeAnimal] = {};
            }
            featureData[this.activeAnimal][this.activeProfession] = 1;
            setFeatureData(featureData);
            featureData[this.EXAM_STATUS] = this.IDLE;
            featureData[this.ACTIVE_ANIMAL] = "";
            featureData[this.ACTIVE_PROFESSION] = "";
            featureData[this.ACTIVE_LEVEL] = 0;
         }
         else
         {
            featureData[this.ACTIVE_LEVEL] += 1;
         }
         for(var i:int = 0; i < 3; i++)
         {
            featureData[this.PROGRESS][i] = this.INCOMPLETE;
         }
         setFeatureData(featureData);
         if(professionComplete)
         {
            if(this.m_examWindow)
            {
               this.m_examWindow.close();
            }
            if(this.m_mainWindow)
            {
               this.m_mainWindow.tintWindow();
               this.m_mainWindow.enableInput = false;
            }
            UI.displayPopup(new PetAcademyProfessionGrantWindow(this.congratsDialogURL,m_featureName,professionalItem,this.checkForMilestoneReward,animalName),false);
         }
         else if(this.m_examWindow)
         {
            this.m_examWindow.refreshWindow();
         }
      }
      
      public function checkForMilestoneReward(e:Event, animalName:String) : void
      {
         var bonusItem:FarmItem = null;
         var featureData:Object = this.getFeatureData();
         if(this.isEligibleForAnimalCategoryMileStoneReward(animalName) == true)
         {
            featureData[animalName][this.MILESTONE_STATUS] = 1;
            Global.player.addGift(this.getBonusReward(animalName));
            bonusItem = Global.farmGameSettingsManager.getFarmItemByName(this.getBonusReward(animalName));
            UI.displayPopup(new PetAcademyMileStoneWindow(this.congratsDialogURL,m_featureName,bonusItem,null,animalName),false);
         }
         else if(this.m_mainWindow)
         {
            this.m_mainWindow.untintWindow();
            this.m_mainWindow.enableInput = true;
         }
      }
      
      private function isEligibleForAnimalCategoryMileStoneReward(animalName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.isAllProfessionCompletedForAnimal(animalName))
         {
            if(this.hasGrantesMileStoneForAnimal(animalName) == false)
            {
               result = true;
            }
         }
         return result;
      }
      
      private function hasGrantesMileStoneForAnimal(animalName:String) : Boolean
      {
         var result:Boolean = false;
         var featureData:Object = this.getFeatureData();
         if(featureData[animalName][this.MILESTONE_STATUS] == 1)
         {
            result = true;
         }
         return result;
      }
      
      public function isAllProfessionCompletedForAnimal(animalName:String) : Boolean
      {
         var result:Boolean = false;
         if(this.professionProgressForAnimal(animalName) == 6 || this.professionProgressForAnimal(animalName) == 5)
         {
            result = true;
         }
         return result;
      }
      
      public function isAllProfessionCompletedForAnimals() : Boolean
      {
         var animalName:String = null;
         var result:Boolean = false;
         var animalsNames:Array = this.getAminalNames();
         for each(animalName in animalsNames)
         {
            if(!this.isAllProfessionCompletedForAnimal(animalName))
            {
               result = false;
               break;
            }
            result = true;
         }
         return result;
      }
      
      public function professionProgressForAnimal(animalName:String) : int
      {
         var key:String = null;
         var result:int = 0;
         var owenedProfessionObject:Object = this.getProfessionsOwnedForAnimal(animalName);
         for(key in owenedProfessionObject)
         {
            result++;
         }
         return result;
      }
      
      public function get mainWindow() : PetAcademyMainWindow
      {
         return this.m_mainWindow;
      }
      
      public function isFeatureEnd() : Boolean
      {
         var remainingTime:Array = this.getTimeRemaining();
         return parseInt(remainingTime[0]) < NUM_ADDITONAL_DAYS;
      }
      
      public function getTimeRemaining() : Array
      {
         var timeLeftMs:Number = this.endTimeNumber - GlobalEngine.serverTime / 1000;
         timeLeftMs = timeLeftMs < 0 ? 0 : timeLeftMs;
         return FarmGameUtil.parseTimeLeft(timeLeftMs);
      }
      
      public function getTimeRemainingInFreindlyTime() : String
      {
         var remainingTime:Number = NaN;
         var result:String = "0 Hours";
         if(!this.isExpired())
         {
            remainingTime = this.endTimeNumber - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = FarmGameUtil.toFriendlyTime(remainingTime,true);
         }
         return result;
      }
      
      public function isExpired() : Boolean
      {
         var result:Boolean = true;
         var currentTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(this.endTimeNumber > 0 && this.endTimeNumber > currentTime)
         {
            result = false;
         }
         return result;
      }
   }
}

