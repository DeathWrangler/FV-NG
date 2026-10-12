package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSession;
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.DragonBreedingState;
   import Classes.UGC.UGCDragonBreeding;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.MutableDragonItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.CutsceneDialog;
   import Display.DragonBreedingVideoDialog;
   import Display.FarmDynamicDialog;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.InputManager;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingManager;
   import Transactions.BreedingProjects.TDragonBeginBreeding;
   import Transactions.BreedingProjects.TDragonFinishBreeding;
   import Transactions.TDragonBreeding;
   import Transactions.TGenericTransaction;
   import Widgets.Constants.Market.Currency;
   import Widgets.Windows.DragonBreedingCongratsWindow;
   import Widgets.Windows.DragonBreedingCraftWindow;
   import Widgets.Windows.DragonBreedingLevelUpWindow;
   import Widgets.Windows.DragonBreedingRewardWindow;
   import Widgets.Windows.DragonBreedingToasterWindow;
   import Widgets.Windows.DragonBreedingUnlockNestWindow;
   import Widgets.Windows.DragonBreedingWindow;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import zasp.Util.MD5;
   
   public class DragonBreedingManager extends EventDispatcher
   {
      
      private static var m_instance:Dictionary = null;
      
      public static const fallbackBreedTimes:Array = [24,12,6,3,1,0];
      
      public static const MAX_NUM_POTIONS:Number = 5;
      
      public static const MAIN_WINDOW:int = 0;
      
      public static const SELECTION_WINDOW:int = 1;
      
      private static const NUM_OFFSPRING_PER_TABLE:Number = 16;
      
      private static const NUM_SECONDS_PER_HOUR:Number = 3600;
      
      public static const fallbackUnlockLevelCost:Array = [75,100,125,150,175,200];
      
      public static const FEATURE_OPTION_KEY:String = "dragonBreeding";
      
      public static const FEATURE_HATCHERY_NAME:String = "dragon_breeding_hatchery";
      
      public static const FEATURE_MALE_DRAGON_AVAILABLE:String = "maleDragons";
      
      public static const FEATURE_FEMALE_DRAGON_AVAILABLE:String = "femaleDragons";
      
      public static const FEATURE_TUTORIAL_MODE:String = "tutorial";
      
      public static const FEATURE_DRAGON_BREEDING_STATE:String = "state";
      
      public static const FEATURE_MARKET_DRAGON_UNLOCK_LEVEL:String = "marketDragons";
      
      public static const DRAGONBREEDING_ASSET_URL:String = "assets/animals/Dragon_Breeding/offspring/";
      
      private static const DRANGONEYIRE_INTRO_VIDEO_URL:String = "assets/dialogs/DragonBreeding/intro_dragonbreeding.swf";
      
      public static const BASE_BREEDING_DIALOG_ASSET_PATH:String = "assets/dialogs/FV_Support/FV_BreedingLevels/";
      
      public static const DEFAULT_UNLOCKED_MALE_DRAGAON:String = "w2z7";
      
      public static const DEFAUT_UNLOCKED_FEMALE_DRAGON:String = "7c38";
      
      public static const LOVE_POTION_ITEM_CODE:String = "1gzw";
      
      public static const FIRE_ITEM_CODE:String = "2ety";
      
      public static const LOVE_POTION_RECIPE_ID:String = "1gzw";
      
      public static const FIRE_RECIPE_ID:String = "2ety";
      
      public static const FIRE_FEED:String = "fire";
      
      public static const HERB_FEED:String = "herbs";
      
      public static const HERB_ITEM_NAME:String = "herbsoflove";
      
      public static const FIRE_ITEM_NAME:String = "fire";
      
      public static const DRAGON_MALE_ITEM_KEY:String = "dragon_male";
      
      public static const DRAGON_FEMALE_ITEM_KEY:String = "dragon_female";
      
      public static const MAX_XP_PER_LEVEL:int = 4;
      
      public static const MAX_UNLOCK_LEVEL:int = 5;
      
      public static const PATTERN_GUARANTEE_COST:int = 5;
      
      public static const RANDOM_OFFSPRING_COST:int = 0;
      
      private static const ALTERNATE_BUILDING:String = "dragon_pen_finished_alt";
      
      public static const INIT_FEATURE_OPS:String = "DragonBreedingInit";
      
      public static const SERVICE_CLASS:String = "DragonBreedingService";
      
      public static const ACTION_INIT:String = "onInitFeature";
      
      public static const GRAY_OUT:Number = 0.6;
      
      public static const NORMAL:Number = 1;
      
      public static const FEATURE_VISITING_DRAGON:String = "vistingDragon";
      
      public static const VISTING_DRAGON_CODE:String = "item_code";
      
      public static const VISITING_DRAGON_SENDER:String = "vd_sender";
      
      public static const VISITING_DRAGON_TS:String = "created_ts";
      
      public static const VISITING_DRAGON_DURATION:int = 172800;
      
      public static const VISITING_DRAGON_BREEDING_STATE:String = "vd_state";
      
      public static const EXPERIMENT_NAME:String = "fv_dragonbreeding";
      
      public static const BIG_REWARD:String = "bigReward";
      
      public static const BRAG_FEED:String = "bragFeed";
      
      public static const BRAG_FEED_UNLOCK_LEVEL:String = "dragonBreedingLevelShareReward";
      
      public static const BRAG_FEED_UNLOCK_DRAGON:String = "dragonBreedingDragonShareReward";
      
      public static const BRAG_FEED_UNLOCK_NEST:String = "dragonBreedingNestShareReward";
      
      private static const OPEN_UI_DELAY:int = 4000;
      
      public static const EVENT_INVENTORY_REFRESH:String = "DBInventoryRefresh";
      
      private static var m_videoComplete:Function = null;
      
      public static const VIDEO_SHOWN_FLAG:String = "DBvideoFlag";
      
      public static const DRAGON_BREEDING_FEATURE_NAME:String = "dragon_pen_finished";
      
      public static const TOASTER_NONE:int = 0;
      
      public static const TOASTER_SHOW_VISITING_DRAGON:int = 3;
      
      public static const TOASTER_SHOW_EGG_READY:int = 1;
      
      public static const TOASTER_SHOW_HATCH_READY:int = 2;
      
      public static const VISITING_DRAGON_TUTORIAL_FLAG:String = "vdTutorialFlag";
      
      public static const VISITING_DRAGON_TUTORIAL_GRANT_LEVEL:int = 5;
      
      public static const MAX_LEVEL:int = 30;
      
      protected var m_herbsOfLovePackages:Array = new Array();
      
      private var m_breedStates:Dictionary = new Dictionary();
      
      protected var m_mainAssetPath:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_MainUI.swf";
      
      protected var m_selectDialogPath:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_PopUps_Selection.swf";
      
      protected var m_progressDialogPath:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_PopUps_Progress.swf";
      
      protected var m_familyTreeDialogPath:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_PopUps_FamilyTree.swf";
      
      protected var m_craftBuyDialogPath:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_BuyFireHerbs.swf";
      
      protected var m_craftDialogPath:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_NoFireHerbs.swf";
      
      protected var m_tutorialDialogPath:String = "assets/dialogs/DragonBreeding/DragonBreeding_Tutorial_1.swf";
      
      protected var m_fourpanelPath:String = "assets/dialogs/DragonBreeding/DragonBreeding_tut_";
      
      protected var m_toasterDialogPath:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_toaster.swf";
      
      protected var m_hatcheryManager:DragonBreedingHatcheryManager;
      
      protected var m_thankYouCardSession:DragonBreedingSession;
      
      private var m_selectedMaleDragonId:String = "";
      
      private var m_selectedFemaleDragonId:String = "";
      
      private var m_selectedOffspring:Object;
      
      private var m_collectionData:Dictionary;
      
      private var m_timeRequestedAt:Object = new Object();
      
      private var m_itemCode:Object = new Object();
      
      private var m_featureName:String;
      
      private var m_timer:Timer;
      
      private var m_toasterWindow:DragonBreedingToasterWindow;
      
      private var m_toasterType:int = 0;
      
      private var m_potionsCountForSelection:Number = 0;
      
      private var m_dragonBreedingWindow:DragonBreedingWindow;
      
      private const ACTION_SHARE_BRAG_FEED:String = "onBragFeed";
      
      private var m_bragFeedType:String = "dragonBreedingLevelShareReward";
      
      private var m_lastUnlockedDragonName:String = "";
      
      public function DragonBreedingManager(featureName:String)
      {
         super();
         this.m_featureName = featureName;
         this.m_hatcheryManager = DragonBreedingHatcheryManager.getInstance(FEATURE_HATCHERY_NAME,this);
      }
      
      public static function getHatcheryManager(featureName:String) : DragonBreedingHatcheryManager
      {
         return DragonBreedingManager.getInstance(featureName).m_hatcheryManager;
      }
      
      public static function getInstance(featureName:String) : DragonBreedingManager
      {
         if(!m_instance)
         {
            m_instance = new Dictionary();
         }
         if(!m_instance.hasOwnProperty(featureName))
         {
            m_instance[featureName] = new DragonBreedingManager(featureName);
         }
         return m_instance[featureName] as DragonBreedingManager;
      }
      
      public static function getDefaultBreedTimes(featureName:String) : Array
      {
         var breedTimesArray:Array = null;
         var num:String = null;
         var result:Array = null;
         var breedTimesData:String = DragonBreedingConfigManager.getInstance(featureName).getFeatureConfigAttr("defaultBreedTimes") as String;
         if(breedTimesData != null)
         {
            breedTimesArray = breedTimesData.replace(" ","").split(",");
            if(breedTimesArray != null && breedTimesArray.length > 0)
            {
               result = new Array();
               for each(num in breedTimesArray)
               {
                  result.push(Number(num));
               }
            }
            else
            {
               result = DragonBreedingManager.fallbackBreedTimes;
            }
         }
         else
         {
            result = DragonBreedingManager.fallbackBreedTimes;
         }
         return result;
      }
      
      public static function getUnlockLevelCost(featureName:String) : Array
      {
         var unlockLevelCostArray:Array = null;
         var num:String = null;
         var result:Array = null;
         var unlockLevelCostData:String = DragonBreedingConfigManager.getInstance(featureName).getFeatureConfigAttr("unlockLevelCost") as String;
         if(unlockLevelCostData != null)
         {
            unlockLevelCostArray = unlockLevelCostData.replace(" ","").split(",");
            if(unlockLevelCostArray != null && unlockLevelCostArray.length > 0)
            {
               result = new Array();
               for each(num in unlockLevelCostArray)
               {
                  result.push(Number(num));
               }
            }
            else
            {
               result = DragonBreedingManager.fallbackUnlockLevelCost;
            }
         }
         else
         {
            result = DragonBreedingManager.fallbackUnlockLevelCost;
         }
         result.sort(Array.NUMERIC);
         return result;
      }
      
      public static function showIntroVideo(callbackFunction:Function = null) : void
      {
         m_videoComplete = callbackFunction;
         var view:Object = null;
         view = FarmDynamicDialog.createDialog("cutscene",DragonBreedingVideoDialog);
         var cutsceneUrl:String = DRANGONEYIRE_INTRO_VIDEO_URL;
         view.addImport(CutsceneDialog.CUTSCENE_IMPORT,cutsceneUrl);
         view.toggleVisibleAndObstruct("button",true);
         view.setShortcutAttribute("button",TextFieldView.ATTRIBUTE_TEXT,"Skip");
         var farmDynamicDialog:DragonBreedingVideoDialog = view as DragonBreedingVideoDialog;
         farmDynamicDialog.setup();
         farmDynamicDialog.show(false,farmDynamicDialog.getView().name,false);
      }
      
      public static function showMotd() : void
      {
         if(m_videoComplete != null)
         {
            m_videoComplete();
         }
      }
      
      public static function sortParentDragonItemsBy(itemsData:Array, featureName:String = "") : Array
      {
         var itemObj:Object = null;
         var itemData:Object = null;
         var marketItemObj:Object = null;
         var result:Array = new Array();
         var unlockedItems:Array = new Array();
         var marketItems:Array = new Array();
         var breedingItems:Array = new Array();
         var visitingDragons:Array = new Array();
         var lockedItems:Array = new Array();
         for each(itemObj in itemsData)
         {
            if(Boolean(itemObj) && itemObj.hasOwnProperty("itemData"))
            {
               itemData = itemObj.itemData;
               if(Boolean(itemData.hasOwnProperty("unlocked")) && Boolean(itemData.unlocked) && !itemData.isMarketItem)
               {
                  unlockedItems.push(itemObj);
               }
               else if(itemData.hasOwnProperty("isMarketItem") && itemData.isMarketItem == true)
               {
                  marketItems.push(itemObj);
               }
               else
               {
                  lockedItems.push(itemObj);
               }
            }
         }
         if(lockedItems.length > 0)
         {
            lockedItems = DragonBreedingManager.sortParentDragonItemsByLevel(lockedItems,featureName);
            result.unshift.apply(result,lockedItems);
         }
         if(marketItems.length > 0)
         {
            result.unshift.apply(result,marketItems);
         }
         if(unlockedItems.length > 0)
         {
            unlockedItems = DragonBreedingManager.sortParentDragonItemsByLevel(unlockedItems,featureName);
            result.unshift.apply(result,unlockedItems);
         }
         if(marketItems.length == 1)
         {
            marketItemObj = marketItems[0];
            if(Boolean(marketItemObj.hasOwnProperty("itemData")) && Boolean(marketItemObj.itemData.hasOwnProperty("unlocked")) && Boolean(marketItemObj.itemData.unlocked))
            {
               result.concat(lockedItems,unlockedItems,marketItems);
               result = DragonBreedingManager.sortParentDragonItemsByLevel(result,featureName);
            }
         }
         return result;
      }
      
      public static function sortParentDragonItemsByLevel(itemsData:Array, featureName:String = "") : Array
      {
         var itemObj:Object = null;
         var itemCode:String = null;
         var isMarketitem:Boolean = false;
         var level:int = 0;
         var result:Array = new Array();
         if(Boolean(itemsData) && itemsData.length > 0)
         {
            for each(itemObj in itemsData)
            {
               if(Boolean(itemObj) && Boolean(itemObj.hasOwnProperty("itemCode")) && itemObj.hasOwnProperty("itemData"))
               {
                  itemCode = itemObj.itemCode;
                  isMarketitem = Boolean(itemObj.itemData.isMarketItem);
                  level = 0;
                  if(isMarketitem)
                  {
                     level = DragonBreedingManager.getInstance(featureName).getMarketItemLevelByItemCode(featureName,itemCode);
                  }
                  else
                  {
                     level = DragonBreedingConfigManager.getInstance(featureName).getLevelByRewardItemCode(itemCode);
                  }
                  itemObj.level = level;
                  result.push(itemObj);
               }
            }
         }
         result.sortOn("level",Array.NUMERIC);
         return result;
      }
      
      public static function getFeatureName() : String
      {
         return Global.flashHotParams["DRAGON_BREEDING_FEATURE_NAME"] != null ? Global.flashHotParams["DRAGON_BREEDING_FEATURE_NAME"] : DRAGON_BREEDING_FEATURE_NAME;
      }
      
      public function initializeCollection(collectionData:Object) : void
      {
         var i:int = 0;
         var isSet:uint = 0;
         var j:int = 0;
         if(collectionData)
         {
            this.m_collectionData = new Dictionary();
            i = 0;
            for each(isSet in collectionData)
            {
               for(j = 1; j <= 8; j++)
               {
                  if(isSet & 1)
                  {
                     this.m_collectionData[8 * i + j] = true;
                  }
                  else
                  {
                     this.m_collectionData[8 * i + j] = false;
                  }
                  isSet >>= 1;
               }
               i++;
            }
         }
      }
      
      public function isDragonCollected(maleName:String, femaleName:String, offspringIndex:Number) : Boolean
      {
         var result:Boolean = false;
         var index:Number = this.getCollectionIndex(maleName,femaleName,offspringIndex);
         if(Boolean(index) && Boolean(this.m_collectionData))
         {
            result = Boolean(this.m_collectionData[index]);
         }
         return result;
      }
      
      public function addToCollection(breedingSession:DragonBreedingSession) : void
      {
         var maleName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(breedingSession.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_MALE));
         var femaleName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(breedingSession.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_FEMALE));
         var offspringIndex:Number = breedingSession.getOffspringCode();
         var index:Number = this.getCollectionIndex(maleName,femaleName,offspringIndex);
         if(!this.m_collectionData[index])
         {
            this.m_collectionData[index] = true;
         }
      }
      
      private function getCollectionIndex(maleName:String, femaleName:String, offspringIndex:Number) : Number
      {
         var result:Number = 0;
         var tableId:Number = DragonBreedingConfigManager.getInstance(this.featureName).getParentTableId(maleName,femaleName);
         if(tableId)
         {
            result = (tableId - 1) * NUM_OFFSPRING_PER_TABLE + offspringIndex;
         }
         return result;
      }
      
      public function initFeature() : void
      {
         var lovePotionItem:FarmItem = null;
         var initialGrant:int = 0;
         var lovePotionId:String = DragonBreedingConfigManager.getInstance(this.featureName).getLovePotion();
         if(lovePotionId)
         {
            lovePotionItem = Global.farmGameSettingsManager.getFarmItemByCode(lovePotionId);
            initialGrant = DragonBreedingConfigManager.getInstance(this.featureName).getInitialGrantLovePotion();
            if(Boolean(lovePotionItem) && initialGrant > 0)
            {
               this.grantLovePotions(initialGrant);
            }
         }
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,ACTION_INIT,null,[this.featureName]));
      }
      
      public function grantLovePotions(num:Number) : void
      {
         FeatureOptionsInventoryManager.getInstance().addCount(LOVE_POTION_ITEM_CODE,num);
      }
      
      public function removeLovePotions(num:Number) : void
      {
         FeatureOptionsInventoryManager.getInstance().removeCount(LOVE_POTION_ITEM_CODE,num);
      }
      
      public function grantFire(num:Number) : void
      {
         FeatureOptionsInventoryManager.getInstance().addCount(FIRE_ITEM_CODE,num);
      }
      
      public function getOrderedProgressDragons() : Array
      {
         return DragonBreedingConfigManager.getInstance(this.featureName).getOrderedProgressDragons();
      }
      
      public function initialize() : void
      {
         var initialParents:Array = null;
         var maleFeatureOps:Object = null;
         var femaleFeatureOps:Object = null;
         var tutorialMode:Object = null;
         var ftueFlag:String = DragonBreedingConfigManager.getInstance(this.featureName).getFtueFlag();
         if(ftueFlag != "" && !Global.player.getSeenFlag(ftueFlag))
         {
            this.initFeature();
            initialParents = DragonBreedingConfigManager.getInstance(this.featureName).getInitialParents();
            maleFeatureOps = {};
            if(Boolean(initialParents) && Boolean(initialParents[DragonBreedingConfigManager.GENDER_CODE_MALE]))
            {
               maleFeatureOps[Global.farmGameSettingsManager.getFarmItemCodeByName(initialParents[DragonBreedingConfigManager.GENDER_CODE_MALE])] = 1;
               Global.player.addGift(initialParents[DragonBreedingConfigManager.GENDER_CODE_MALE],"0",1);
            }
            else
            {
               maleFeatureOps[DEFAULT_UNLOCKED_MALE_DRAGAON] = 1;
               Global.player.addGift(DEFAULT_UNLOCKED_MALE_DRAGAON,"0",1);
            }
            femaleFeatureOps = {};
            if(Boolean(initialParents) && Boolean(initialParents[DragonBreedingConfigManager.GENDER_CODE_FEMALE]))
            {
               femaleFeatureOps[Global.farmGameSettingsManager.getFarmItemCodeByName(initialParents[DragonBreedingConfigManager.GENDER_CODE_FEMALE])] = 1;
               Global.player.addGift(initialParents[DragonBreedingConfigManager.GENDER_CODE_FEMALE],"0",1);
            }
            else
            {
               femaleFeatureOps[DEFAUT_UNLOCKED_FEMALE_DRAGON] = 1;
               Global.player.addGift(initialParents[DragonBreedingConfigManager.GENDER_CODE_MALE],"0",1);
            }
            this.updateParentDragonItemCount(Global.farmGameSettingsManager.getFarmItemCodeByName(initialParents[DragonBreedingConfigManager.GENDER_CODE_MALE]));
            this.updateParentDragonItemCount(Global.farmGameSettingsManager.getFarmItemCodeByName(initialParents[DragonBreedingConfigManager.GENDER_CODE_FEMALE]));
            Global.player.setSeenFlag(ftueFlag,true);
            tutorialMode = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,DragonBreedingManager.FEATURE_TUTORIAL_MODE);
            if(tutorialMode == null)
            {
               FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,DragonBreedingManager.FEATURE_TUTORIAL_MODE,true);
            }
         }
         if(Boolean(this.herbsOfLovePackages) && this.herbsOfLovePackages.length < 1)
         {
            this.herbsOfLovePackages = DragonBreedingConfigManager.getInstance(this.featureName).getLovePotionBucketItems();
         }
      }
      
      public function getLovePotionItemCount() : Number
      {
         var lovePotionId:String = DragonBreedingConfigManager.getInstance(this.featureName).getLovePotion();
         var lovePotionItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(lovePotionId);
         return FeatureOptionsInventoryManager.getInstance().getCount(lovePotionId);
      }
      
      public function loadData(rawData:Object) : void
      {
         if(rawData.breedStates != null)
         {
            this.m_breedStates = rawData.breedStates;
         }
      }
      
      public function getNumBreedingSessions(featureBuilding:FeatureBuilding) : Number
      {
         var expandLevel:Number = NaN;
         var i:Number = NaN;
         var sessions:Number = 0;
         var DBState:DragonBreedingState = this.getBreedingState();
         if(null != DBState)
         {
            expandLevel = 4;
            for(i = 0; i < expandLevel; i++)
            {
               if(null != DBState.getBreedSession(i))
               {
                  sessions++;
               }
            }
         }
         return sessions;
      }
      
      public function canBreed() : Boolean
      {
         var result:Boolean = false;
         var maleItemCount:int = this.getDragonCountByItemCode(this.selectedMaleDragonId);
         var femaleItemCount:int = this.getDragonCountByItemCode(this.selectedFemaleDragonId);
         var maleItemInBreeding:int = this.getItemBreedingCountByItemCode(this.selectedMaleDragonId);
         var femaleItemInBreeding:int = this.getItemBreedingCountByItemCode(this.selectedFemaleDragonId);
         if(maleItemCount > 0 && maleItemCount - maleItemInBreeding > 0 && femaleItemCount > 0 && femaleItemCount - femaleItemInBreeding > 0)
         {
            result = true;
         }
         return result;
      }
      
      public function beginBreed(slot:int, isPreselectedOffspring:Boolean, numBreedPotions:Number) : void
      {
         var lovePotionsQty:Number = NaN;
         var finishTimes:Array = null;
         var offspring:Object = null;
         var offspringIndex:int = 0;
         var breedSession:DragonBreedingSession = null;
         var breedingQueues:Array = this.getBreedingData();
         if(Boolean(breedingQueues) && breedingQueues.length > 0)
         {
            breedSession = breedingQueues[slot];
         }
         if(breedSession == null)
         {
            breedSession = new DragonBreedingSession(this.featureName);
            if(isPreselectedOffspring)
            {
               offspring = this.selectedOffspring;
               if(offspring)
               {
                  offspringIndex = int(offspring.index);
               }
               FarmStatsManager.count(this.m_featureName,"breeding","started","","dragonfamilypage");
            }
            else if(this.isTutorialMode())
            {
               offspringIndex = 1;
            }
            breedSession.addBreedObjects(this.selectedMaleDragonId,this.selectedFemaleDragonId,offspringIndex);
            if(breedSession.hasValidBreedObjects())
            {
               breedSession.numPotions = numBreedPotions;
               breedSession.featureName = this.featureName;
               breedSession.patternGuarantee = isPreselectedOffspring;
               breedSession.startTime = GlobalEngine.serverTime / 1000;
               breedSession.suiteSlot = slot;
               breedSession.isMaleVD = this.validateMaleVisitingDragonForBeginBreed();
               if(breedSession.isMaleVD != "")
               {
                  breedSession.maleVDSender = this.getVisitingDragonSenderByGender(this.selectedMaleDragonId,DragonBreedingConfigManager.GENDER_CODE_MALE);
               }
               breedSession.isFemaleVD = this.validateFemaleVisitingDragonForBeginBreed();
               if(breedSession.isFemaleVD != "")
               {
                  breedSession.femaleVDSender = this.getVisitingDragonSenderByGender(this.selectedFemaleDragonId,DragonBreedingConfigManager.GENDER_CODE_FEMALE);
               }
               finishTimes = DragonBreedingManager.getDefaultBreedTimes(this.featureName);
               if(finishTimes)
               {
                  breedSession.finishTime = breedSession.startTime + finishTimes[numBreedPotions] * 3600;
               }
               else
               {
                  breedSession.finishTime = breedSession.startTime;
               }
            }
            lovePotionsQty = breedSession.numPotions;
            if(this.isTutorialMode())
            {
               lovePotionsQty = 1;
            }
            this.removeLovePotions(lovePotionsQty);
            this.updateDragonBreedingSession(breedSession);
            this.dispatchEvent(new Event(EVENT_INVENTORY_REFRESH));
            if(!this.isTutorialMode())
            {
               TransactionManager.addTransaction(new TDragonBeginBreeding(breedSession),true);
            }
         }
      }
      
      private function validateVisitingDragonForBeginBreed() : String
      {
         var isVisitingDragon:String = "";
         if(!this.isVisitingDragonInBreeding())
         {
            if(this.isValidVisitingDragon(this.selectedMaleDragonId))
            {
               isVisitingDragon = DragonBreedingConfigManager.GENDER_CODE_MALE;
               this.setVisitingDragonBreedingState(true);
            }
            else if(this.isValidVisitingDragon(this.selectedFemaleDragonId))
            {
               isVisitingDragon = DragonBreedingConfigManager.GENDER_CODE_FEMALE;
               this.setVisitingDragonBreedingState(true);
            }
         }
         return isVisitingDragon;
      }
      
      private function validateMaleVisitingDragonForBeginBreed() : String
      {
         var isVisitingDragon:String = "";
         if(!this.isVisitingDragonInBreedingByGender(DragonBreedingConfigManager.GENDER_CODE_MALE))
         {
            if(this.isValidVisitingDragonByItemCode(this.selectedMaleDragonId))
            {
               isVisitingDragon = DragonBreedingConfigManager.GENDER_CODE_MALE;
               this.setVistingDragonBreedingStateByGender(true,isVisitingDragon);
            }
         }
         return isVisitingDragon;
      }
      
      private function validateFemaleVisitingDragonForBeginBreed() : String
      {
         var isVisitingDragon:String = "";
         if(!this.isVisitingDragonInBreedingByGender(DragonBreedingConfigManager.GENDER_CODE_FEMALE))
         {
            if(this.isValidVisitingDragonByItemCode(this.selectedFemaleDragonId))
            {
               isVisitingDragon = DragonBreedingConfigManager.GENDER_CODE_FEMALE;
               this.setVistingDragonBreedingStateByGender(true,isVisitingDragon);
            }
         }
         return isVisitingDragon;
      }
      
      public function finishBreed(breedSession:DragonBreedingSession, callback:Function) : void
      {
         if(!this.isTutorialMode())
         {
            TransactionManager.addTransaction(new TDragonFinishBreeding(breedSession,callback,this.featureName),true);
         }
      }
      
      public function addLovePotion(breedingSession:DragonBreedingSession, callback:Function) : void
      {
         var timeNeeded:Number = NaN;
         if(Boolean(breedingSession) && Boolean(breedingSession.featureName))
         {
            if(breedingSession.numPotions < MAX_NUM_POTIONS)
            {
               if(this.getLovePotionItemCount() > 0)
               {
                  breedingSession.numPotions += 1;
                  timeNeeded = Number(DragonBreedingManager.getDefaultBreedTimes(this.featureName)[breedingSession.numPotions]);
                  breedingSession.finishTime = breedingSession.startTime + timeNeeded * NUM_SECONDS_PER_HOUR;
                  this.updateDragonBreedingSession(breedingSession);
                  this.removeLovePotions(1);
                  TransactionManager.addTransaction(new TGenericTransaction("DragonBreedingService","onSpeedUpBreeding",null,[breedingSession.serializeForPhp()]));
                  if(callback != null)
                  {
                     callback();
                  }
               }
               else
               {
                  this.showDragonBreedingCraftWindow(HERB_ITEM_NAME);
               }
            }
         }
      }
      
      public function showDragonBreedingCraftWindow(itemName:String) : void
      {
         var craftWindow:DragonBreedingCraftWindow = new DragonBreedingCraftWindow(DragonBreedingManager.getInstance(this.featureName).getCraftDialogURL(),this.featureName,itemName);
         UI.displayPopup(craftWindow,false,"",true);
      }
      
      public function getEgg(breedingSession:DragonBreedingSession, hatcheryCallback:Function) : void
      {
         if(breedingSession.isComplete() && !breedingSession.collected)
         {
            breedingSession.collected = true;
            if(this.isTutorialMode())
            {
               DragonBreedingManager.getHatcheryManager(this.featureName).plantTutorialSapling(breedingSession.suiteSlot.toString());
            }
            else
            {
               DragonBreedingManager.getHatcheryManager(this.featureName).plantSapling(breedingSession.suiteSlot.toString());
            }
            if(this.isVisitingDragonInBreedingByGender(DragonBreedingConfigManager.GENDER_CODE_MALE) && breedingSession.isMaleVD == DragonBreedingConfigManager.GENDER_CODE_MALE)
            {
               this.setVistingDragonBreedingStateByGender(false,DragonBreedingConfigManager.GENDER_CODE_MALE);
            }
            if(this.isVisitingDragonInBreedingByGender(DragonBreedingConfigManager.GENDER_CODE_FEMALE) && breedingSession.isFemaleVD == DragonBreedingConfigManager.GENDER_CODE_FEMALE)
            {
               this.setVistingDragonBreedingStateByGender(false,DragonBreedingConfigManager.GENDER_CODE_FEMALE);
            }
            this.saveSessionForThankYouCard(breedingSession);
            this.updateDragonBreedingSession(breedingSession);
            this.finishBreed(breedingSession,hatcheryCallback);
            if(hatcheryCallback != null)
            {
               hatcheryCallback();
            }
         }
      }
      
      public function hatchEgg(suiteSlot:Number, dragonBreedingWindow:DragonBreedingWindow = null) : void
      {
         var breedingSession:DragonBreedingSession = null;
         var skillState:DragonBreedingSkillState = null;
         var breedingData:Array = this.getBreedingData();
         if(breedingData)
         {
            breedingSession = breedingData[suiteSlot];
            skillState = this.getBreedingSkillState();
            if(Boolean(breedingSession) && Boolean(skillState))
            {
               if(skillState.level < 30)
               {
                  this.canShowXpUpAnimation(breedingSession,dragonBreedingWindow);
               }
               else
               {
                  this.onLevelUpAnimationComplete(breedingSession,dragonBreedingWindow);
               }
            }
         }
      }
      
      private function canShowXpUpAnimation(breedinSession:DragonBreedingSession, dragonBreedingWindow:DragonBreedingWindow) : void
      {
         if(dragonBreedingWindow)
         {
            dragonBreedingWindow.tintWindow();
            dragonBreedingWindow.enableInput = false;
            dragonBreedingWindow.showXpUpAnimation(breedinSession);
         }
      }
      
      public function saveSessionForThankYouCard(breedingSession:DragonBreedingSession) : void
      {
         this.m_thankYouCardSession = breedingSession;
      }
      
      public function getThankYouCardSession() : DragonBreedingSession
      {
         return this.m_thankYouCardSession;
      }
      
      public function onLevelUpAnimationComplete(breedingSession:DragonBreedingSession, dragonBreedingWindow:DragonBreedingWindow) : void
      {
         this.updateDragonBreedingSession(breedingSession,true);
         this.addToCollection(breedingSession);
         this.showCongratsWindow(breedingSession,dragonBreedingWindow);
         if(dragonBreedingWindow)
         {
            dragonBreedingWindow.refreshHatcheryWindow();
         }
         if(!this.isTutorialMode())
         {
            TransactionManager.addTransaction(new TGenericTransaction("DragonBreedingMystreeService",DragonBreedingHatcheryManager.ACTION_HATCH,this.addOffspringToGiftbox,[this.featureName,breedingSession.serializeForPhp()]));
         }
      }
      
      public function completeTutorialAfterCongratsWindow() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("DragonBreedingService","onTutorialComplete",this.addOffspringToGiftbox,[this.featureName]),true);
         this.setTutorialComplete();
      }
      
      public function testOffspring() : void
      {
         var breedingSession:DragonBreedingSession = new DragonBreedingSession(null);
         breedingSession.addBreedObjects("0hib","0edo",1);
         var maleName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(breedingSession.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_MALE));
         var femaleName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(breedingSession.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_FEMALE));
         var offspringIndex:Number = breedingSession.getOffspringCode();
         var offspringState:Object = this.getOffspringForCouple(maleName,femaleName,offspringIndex.toString());
         var bodyName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(offspringState[DragonBreedingConfigManager.BODY_DATA_KEY]);
         var ugcItem:UGCDragonBreeding = new UGCDragonBreeding(bodyName,offspringState as Dictionary);
         ugcItem.createDragon();
      }
      
      private function grantTutorialOffSpring(data:Object) : void
      {
         if(data)
         {
            if(data != null)
            {
               Global.player.addUgcDragonToGiftbox(data["ugcItemState"]);
               this.grantBreedingXp(2);
               this.dispatchEvent(new Event(EVENT_INVENTORY_REFRESH));
               if(data.xpGain)
               {
                  Global.player.xp += data.xpGain;
               }
            }
         }
         if(this.m_dragonBreedingWindow)
         {
            this.m_dragonBreedingWindow.untintWindow();
            this.m_dragonBreedingWindow.enableInput = true;
         }
      }
      
      private function addOffspringToGiftbox(data:Object) : void
      {
         var skillState:DragonBreedingSkillState = null;
         if(data)
         {
            if(data != null)
            {
               Global.player.addUgcDragonToGiftbox(data["ugcItemState"]);
               this.grantBreedingXp(1);
               skillState = this.getBreedingSkillState();
               if(Boolean(skillState && skillState.xp == 0) && Boolean(skillState.level > 1) && skillState.level <= 30)
               {
                  if(this.dragonBreedingWindow)
                  {
                     this.dragonBreedingWindow.showLevelUpAnimation();
                     this.dragonBreedingWindow.updateProgressBtnText();
                     this.dragonBreedingWindow.updateEggMeter();
                  }
               }
               this.dispatchEvent(new Event(EVENT_INVENTORY_REFRESH));
               if(this.dragonBreedingWindow)
               {
                  this.dragonBreedingWindow.refreshHatcheryWindow();
               }
               if(data.xpGain)
               {
                  Global.player.xp += data.xpGain;
               }
            }
         }
      }
      
      public function showRewardsWindow(rewards:Object) : void
      {
         var consumeableCount:Number = NaN;
         var dragonCode:String = null;
         var breedingSlotUnlocked:Boolean = false;
         var totalConsumableCount:Number = NaN;
         var reward:Object = null;
         var n:Number = NaN;
         var rewardArray:Array = rewards["levelups"] as Array;
         if(rewardArray)
         {
            consumeableCount = 0;
            dragonCode = null;
            breedingSlotUnlocked = false;
            totalConsumableCount = 0;
            for each(reward in rewardArray)
            {
               if(!reward.hasOwnProperty("type"))
               {
                  continue;
               }
               switch(reward["type"])
               {
                  case "item_grant":
                     if(reward["value"] === LOVE_POTION_ITEM_CODE)
                     {
                        consumeableCount = Number(reward["quantity"]);
                        totalConsumableCount += consumeableCount;
                     }
                     else
                     {
                        dragonCode = reward["value"];
                        if(dragonCode)
                        {
                           this.m_lastUnlockedDragonName = Global.farmGameSettingsManager.getFarmItemByCode(dragonCode).friendlyTitle;
                        }
                     }
                     break;
                  case "breedingslot_unlock":
                     breedingSlotUnlocked = true;
               }
            }
            n = rewardArray.length;
            switch(n)
            {
               case 1:
                  UI.displayPopup(new DragonBreedingRewardWindow(this.featureName,consumeableCount),false);
                  break;
               case 2:
                  UI.displayPopup(new DragonBreedingLevelUpWindow(this.featureName,dragonCode,consumeableCount),false);
                  break;
               case 3:
                  UI.displayPopup(new DragonBreedingUnlockNestWindow(this.featureName,dragonCode,consumeableCount),false);
                  break;
               default:
                  if(breedingSlotUnlocked)
                  {
                     UI.displayPopup(new DragonBreedingUnlockNestWindow(this.featureName,dragonCode,totalConsumableCount),false);
                  }
                  else
                  {
                     UI.displayPopup(new DragonBreedingLevelUpWindow(this.featureName,dragonCode,totalConsumableCount),false);
                  }
            }
         }
      }
      
      public function getImageForOffspring(maleName:String, femaleName:String, offspringIndex:Number) : String
      {
         var imagePath:String = "";
         if(offspringIndex > 0)
         {
            imagePath = DRAGONBREEDING_ASSET_URL + maleName + "_" + femaleName + "_" + offspringIndex.toString() + ".png";
         }
         return imagePath;
      }
      
      public function showCongratsWindow(breedingSession:DragonBreedingSession, dragonBreedingWindow:DragonBreedingWindow = null) : void
      {
         var featureName:String = breedingSession.featureName;
         var maleDragonCode:String = breedingSession.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_MALE);
         var femaleDragonCode:String = breedingSession.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_FEMALE);
         var offspringIndex:Number = breedingSession.getOffspringCode();
         var visitingDragon:int = DragonBreedingCongratsWindow.NO_VISITING_DRAGON;
         if(breedingSession.isMaleVD != "" && breedingSession.isFemaleVD != "")
         {
            visitingDragon = DragonBreedingCongratsWindow.BOTH_VISITING_DRAGON;
         }
         else if(breedingSession.isMaleVD != "" && breedingSession.isFemaleVD == "")
         {
            visitingDragon = DragonBreedingCongratsWindow.MALE_VISITING_DRAGON;
         }
         else if(breedingSession.isMaleVD == "" && breedingSession.isFemaleVD != "")
         {
            visitingDragon = DragonBreedingCongratsWindow.FEMALE_VISITING_DRAGON;
         }
         UI.displayPopup(new DragonBreedingCongratsWindow(featureName,maleDragonCode,femaleDragonCode,offspringIndex,visitingDragon,dragonBreedingWindow),false);
         UI.stopPopups(false);
         if(dragonBreedingWindow)
         {
            dragonBreedingWindow.tintWindow();
            dragonBreedingWindow.enableInput = false;
         }
      }
      
      public function findFreeSlot() : Number
      {
         var skillState:DragonBreedingSkillState = null;
         var expandLevel:Number = NaN;
         var i:Number = NaN;
         var hatchery:DragonBreedingHatcheryManager = null;
         var freeSlot:Number = -1;
         var breedingQueues:Array = this.getBreedingData();
         if(breedingQueues != null)
         {
            skillState = this.getBreedingSkillState();
            if(skillState)
            {
               expandLevel = skillState.unlockedSuites;
               for(i = 0; i < expandLevel; i++)
               {
                  if(breedingQueues[i] == null)
                  {
                     hatchery = DragonBreedingManager.getHatcheryManager(this.featureName);
                     if(hatchery.canPlant(i.toString()))
                     {
                        freeSlot = i;
                        break;
                     }
                  }
               }
            }
         }
         return freeSlot;
      }
      
      public function updateBreedingState(breedingSession:DragonBreedingSession, result:Object) : void
      {
         var DBState:DragonBreedingState = null;
         var suiteSlot:int = -1;
         if(Boolean(result) && result.hasOwnProperty("suiteSlot"))
         {
            suiteSlot = int(result.suiteSlot);
         }
         if(Boolean(result) && Boolean(result.extraDataState))
         {
            DBState = this.getBreedingState();
            DBState.loadObject(result.extraDataState,suiteSlot);
            FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,FEATURE_DRAGON_BREEDING_STATE,DBState);
            this.selectedOffspring = null;
         }
      }
      
      public function updateDragonBreedingSession(breedingSession:DragonBreedingSession, shouldReset:Boolean = false) : Boolean
      {
         var result:Boolean = false;
         var DBState:DragonBreedingState = this.getBreedingState();
         if(DBState)
         {
            DBState.setBreedingSession(breedingSession,shouldReset);
            FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,FEATURE_DRAGON_BREEDING_STATE,DBState);
         }
         return result;
      }
      
      public function grantBreedingXp(xpAmount:int) : void
      {
         var skillState:DragonBreedingSkillState = null;
         var rewards:Object = null;
         if(DragonBreedingConfigManager.getInstance(this.featureName).haveLevelDefinitionsForFeature())
         {
            skillState = DragonBreedingManager.getInstance(this.featureName).getBreedingSkillState();
            rewards = new Object();
            skillState.grantXp(xpAmount);
            rewards = skillState.checkAndAwardLevel();
            if(rewards != null)
            {
               this.showRewardsWindow(rewards);
            }
         }
      }
      
      public function getBreedingSkillState() : DragonBreedingSkillState
      {
         return Global.player.getDragonBreedingSkillStateForFeature(this.featureName);
      }
      
      public function getBreedingState() : DragonBreedingState
      {
         var result:DragonBreedingState = new DragonBreedingState(this.featureName);
         var dataObject:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_DRAGON_BREEDING_STATE);
         if(dataObject as DragonBreedingState)
         {
            result = dataObject as DragonBreedingState;
         }
         else
         {
            result.loadObject(dataObject);
         }
         return result;
      }
      
      public function getBreedingData() : Array
      {
         var result:Array = new Array();
         var DBState:DragonBreedingState = this.getBreedingState();
         if(DBState)
         {
            result = DBState.getBreedingQueue();
         }
         return result;
      }
      
      public function getMutableMaleData(shouldCreate:Boolean = true) : Object
      {
         var itemName:String = null;
         var code:String = null;
         var isUnlockedItem:Boolean = false;
         var itemCount:int = 0;
         var featureData:Object = new Object();
         var playerMaleDragons:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_MALE_DRAGON_AVAILABLE);
         var mutableAnimals:Array = DragonBreedingConfigManager.getInstance(this.featureName).getMutableMaleAnimals();
         for each(itemName in mutableAnimals)
         {
            code = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
            isUnlockedItem = false;
            itemCount = 0;
            if(Boolean(playerMaleDragons) && playerMaleDragons.hasOwnProperty(code))
            {
               isUnlockedItem = true;
               itemCount = int(playerMaleDragons[code]);
            }
            featureData[code] = {
               "unlocked":isUnlockedItem,
               "itemCount":itemCount,
               "isMarketItem":DragonBreedingConfigManager.getInstance(this.featureName).isMarketUnlockItem(itemName),
               "itemName":itemName
            };
         }
         return featureData;
      }
      
      public function getMutableFemaleData(shouldCreate:Boolean = true) : Object
      {
         var itemName:String = null;
         var code:String = null;
         var isUnlockedItem:Boolean = false;
         var itemCount:int = 0;
         var featureData:Object = new Object();
         var playerFemaleDragons:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_FEMALE_DRAGON_AVAILABLE);
         var mutableAnimals:Array = DragonBreedingConfigManager.getInstance(this.featureName).getMutableFemaleAnimals();
         for each(itemName in mutableAnimals)
         {
            code = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
            isUnlockedItem = false;
            itemCount = 0;
            if(Boolean(playerFemaleDragons) && playerFemaleDragons.hasOwnProperty(code))
            {
               isUnlockedItem = true;
               itemCount = int(playerFemaleDragons[code]);
            }
            featureData[code] = {
               "unlocked":isUnlockedItem,
               "itemCount":itemCount,
               "isMarketItem":DragonBreedingConfigManager.getInstance(this.featureName).isMarketUnlockItem(itemName),
               "itemName":itemName
            };
         }
         return featureData;
      }
      
      public function setDefaultMarketDragonsLevel() : Object
      {
         var itemData:Object = null;
         var result:Object = new Object();
         var maleDragons:Object = this.getMutableMaleData();
         var femaleDragons:Object = this.getMutableFemaleData();
         var itemCode:String = "";
         for each(itemData in maleDragons)
         {
            if(Boolean(itemData && itemData.hasOwnProperty("isMarketItem")) && Boolean(itemData.isMarketItem == true) && itemData.hasOwnProperty("itemName"))
            {
               itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemData.itemName);
               if(itemCode != "")
               {
                  result[itemCode] = {
                     "gender":DragonBreedingConfigManager.GENDER_CODE_MALE,
                     "sortLevel":1
                  };
                  itemCode = "";
               }
               break;
            }
         }
         for each(itemData in femaleDragons)
         {
            if(Boolean(itemData && itemData.hasOwnProperty("isMarketItem")) && Boolean(itemData.isMarketItem == true) && itemData.hasOwnProperty("itemName"))
            {
               itemCode = Global.farmGameSettingsManager.getFarmItemCodeByName(itemData.itemName);
               if(itemCode != "")
               {
                  result[itemCode] = {
                     "gender":DragonBreedingConfigManager.GENDER_CODE_FEMALE,
                     "sortLevel":1
                  };
                  itemCode = "";
               }
               break;
            }
         }
         return result;
      }
      
      public function setMarketDragonsLevel(featureName:String, itemCode:String, gender:String, level:int = 1) : void
      {
         var marketitemCode:String = null;
         var itemData:Object = null;
         var success:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureName,DragonBreedingManager.FEATURE_MARKET_DRAGON_UNLOCK_LEVEL);
         if(!featureData)
         {
            featureData = this.setDefaultMarketDragonsLevel();
         }
         if(featureData)
         {
            for(marketitemCode in featureData)
            {
               itemData = featureData[marketitemCode];
               if(Boolean(itemData) && Boolean(itemData.hasOwnProperty("gender")) && itemData.hasOwnProperty("sortLevel"))
               {
                  if(marketitemCode == itemCode && gender == itemData.gender)
                  {
                     featureData[marketitemCode] = {
                        "gender":gender,
                        "sortLevel":level
                     };
                     success = true;
                     break;
                  }
               }
            }
         }
         if(success)
         {
            FeatureOptionsManager.getInstance().setFeatureOption(featureName,DragonBreedingManager.FEATURE_MARKET_DRAGON_UNLOCK_LEVEL,featureData);
         }
      }
      
      public function updateMarketDragonLevel(featureName:String, itemCode:String, gender:String) : void
      {
         var skillState:DragonBreedingSkillState = null;
         var level:int = 0;
         var itemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
         if(Boolean(itemName) && DragonBreedingConfigManager.getInstance(featureName).isMarketUnlockItem(itemName))
         {
            skillState = this.getBreedingSkillState();
            if(Boolean(skillState) && skillState.level > 0)
            {
               level = skillState.level;
               if(level % 5 == 0)
               {
                  level--;
               }
               this.setMarketDragonsLevel(featureName,itemCode,gender,level);
            }
         }
      }
      
      public function getMarketItemLevelByItemCode(featureName:String, itemCode:String) : int
      {
         var marketitemCode:String = null;
         var itemData:Object = null;
         var result:int = 1;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(featureName,DragonBreedingManager.FEATURE_MARKET_DRAGON_UNLOCK_LEVEL);
         if(featureData)
         {
            for(marketitemCode in featureData)
            {
               if(marketitemCode == itemCode)
               {
                  itemData = featureData[marketitemCode];
                  if(itemData.hasOwnProperty("sortLevel"))
                  {
                     result = itemData.sortLevel as int;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getVisitingDragonItemCode() : String
      {
         var visitingDragonsState:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON) as Object;
         var result:String = "";
         if(visitingDragonsState)
         {
            if(visitingDragonsState.hasOwnProperty(VISTING_DRAGON_CODE))
            {
               result = visitingDragonsState[VISTING_DRAGON_CODE];
            }
         }
         return result;
      }
      
      public function getVisitingDragonItemCodeByGender(gender:String = "M") : String
      {
         var visitingDragonState:Object = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON);
         var result:String = "";
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(gender)) && Boolean(featureData[gender]))
         {
            visitingDragonState = featureData[gender];
            if(visitingDragonState.hasOwnProperty(VISTING_DRAGON_CODE))
            {
               result = visitingDragonState[VISTING_DRAGON_CODE];
            }
         }
         return result;
      }
      
      public function getVisitingDragonItemCodeAsArray() : Array
      {
         var visitingDragonData:Object = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON);
         var result:Array = new Array();
         if(featureData)
         {
            for each(visitingDragonData in featureData)
            {
               if(Boolean(visitingDragonData) && visitingDragonData.hasOwnProperty(VISTING_DRAGON_CODE))
               {
                  result.push(visitingDragonData[VISTING_DRAGON_CODE]);
               }
            }
         }
         return result;
      }
      
      public function getVisitingDragonGenderType(itemCode:String) : String
      {
         var item:FarmItem = null;
         var keyword:String = null;
         var result:String = "";
         if(this.isValidVisitingDragonByItemCode(itemCode))
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            keyword = item.keyword;
            if(Boolean(keyword) && keyword.length > 0)
            {
               if(keyword == DragonBreedingManager.DRAGON_FEMALE_ITEM_KEY)
               {
                  result = DragonBreedingConfigManager.GENDER_CODE_FEMALE;
               }
               else if(keyword == DragonBreedingManager.DRAGON_MALE_ITEM_KEY)
               {
                  result = DragonBreedingConfigManager.GENDER_CODE_MALE;
               }
            }
         }
         return result;
      }
      
      public function getVisitingDragonStartTime() : Number
      {
         var result:Number = -1;
         var visitingDragonsState:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON) as Object;
         if(visitingDragonsState)
         {
            if(visitingDragonsState.hasOwnProperty(VISITING_DRAGON_TS))
            {
               result = Number(visitingDragonsState[VISITING_DRAGON_TS]);
            }
         }
         return result;
      }
      
      public function getVisitingDragonStartTimeByItemCode(itemCode:String = "") : Number
      {
         var visitingDragonData:Object = null;
         var result:Number = -1;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON);
         if(Boolean(featureData) && itemCode != "")
         {
            for each(visitingDragonData in featureData)
            {
               if(Boolean(visitingDragonData && visitingDragonData.hasOwnProperty(VISTING_DRAGON_CODE)) && Boolean(visitingDragonData[VISTING_DRAGON_CODE] == itemCode) && visitingDragonData.hasOwnProperty(VISITING_DRAGON_TS))
               {
                  result = Number(visitingDragonData[VISITING_DRAGON_TS]);
                  break;
               }
            }
         }
         return result;
      }
      
      public function getVisitingDragonSender() : String
      {
         var visitingDragonState:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON) as Object;
         var result:String = "";
         if(visitingDragonState)
         {
            if(visitingDragonState.hasOwnProperty(VISITING_DRAGON_SENDER))
            {
               result = visitingDragonState[VISITING_DRAGON_SENDER];
            }
         }
         return result;
      }
      
      public function getVisitingDragonSenderByItemCode(itemCode:String = "") : String
      {
         var visitingDragonData:Object = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON);
         var result:String = "";
         if(featureData)
         {
            for each(visitingDragonData in featureData)
            {
               if(Boolean(visitingDragonData && visitingDragonData.hasOwnProperty(VISTING_DRAGON_CODE)) && Boolean(visitingDragonData[VISTING_DRAGON_CODE] == itemCode) && visitingDragonData.hasOwnProperty(VISITING_DRAGON_SENDER))
               {
                  result = visitingDragonData[VISITING_DRAGON_SENDER];
                  break;
               }
            }
         }
         return result;
      }
      
      public function getVisitingDragonSenderByGender(itemCode:String = "", gender:String = "M") : String
      {
         var visitingDragonData:Object = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON);
         var result:String = "";
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(gender)) && Boolean(featureData[gender]))
         {
            visitingDragonData = featureData[gender];
            if(Boolean(visitingDragonData && visitingDragonData.hasOwnProperty(VISTING_DRAGON_CODE)) && Boolean(visitingDragonData[VISTING_DRAGON_CODE] == itemCode) && visitingDragonData.hasOwnProperty(VISITING_DRAGON_SENDER))
            {
               result = visitingDragonData[VISITING_DRAGON_SENDER];
            }
         }
         return result;
      }
      
      public function getVistingDragonTimeRemaining() : Number
      {
         var endTime:Number = NaN;
         var timeRemaining:Number = -1;
         var startTime:Number = this.getVisitingDragonStartTime();
         var serverTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(startTime > 0)
         {
            endTime = startTime + this.visitingDragonDuration;
            if(endTime > 0 && serverTime < endTime)
            {
               timeRemaining = endTime - serverTime;
            }
         }
         return timeRemaining;
      }
      
      public function getVistingDragonTimeRemainingByItemCode(itemCode:String = "") : Number
      {
         var endTime:Number = NaN;
         var timeRemaining:Number = -1;
         var startTime:Number = this.getVisitingDragonStartTimeByItemCode(itemCode);
         var serverTime:Number = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         if(startTime > 0)
         {
            endTime = startTime + this.visitingDragonDuration;
            if(endTime > 0 && serverTime < endTime)
            {
               timeRemaining = endTime - serverTime;
            }
         }
         return timeRemaining;
      }
      
      public function isValidVisitingDragon(itemCode:String) : Boolean
      {
         var visitingDragonItemCode:String = null;
         var result:Boolean = false;
         if(!this.isTutorialMode())
         {
            visitingDragonItemCode = this.getVisitingDragonItemCode();
            if(visitingDragonItemCode != "" && visitingDragonItemCode == itemCode)
            {
               if(this.getVistingDragonTimeRemaining() > 0)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function isValidVisitingDragonByItemCode(itemCode:String = "") : Boolean
      {
         var visitingDragonItemCodes:Array = null;
         var index:int = 0;
         var result:Boolean = false;
         if(!this.isTutorialMode())
         {
            visitingDragonItemCodes = this.getVisitingDragonItemCodeAsArray();
            for(index = 0; index < visitingDragonItemCodes.length; index++)
            {
               if(Boolean(visitingDragonItemCodes[index]) && visitingDragonItemCodes[index] == itemCode)
               {
                  if(this.getVistingDragonTimeRemainingByItemCode(itemCode) > 0)
                  {
                     result = true;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function resetVisitingDragon() : void
      {
         FeatureOptionsManager.deleteFeatureOption(this.featureName,FEATURE_VISITING_DRAGON);
      }
      
      public function resetVisitingDragonByItemCode(itemCode:String = "") : void
      {
         var visitingDragonData:Object = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON);
         if(Boolean(featureData) && itemCode != "")
         {
            for each(visitingDragonData in featureData)
            {
               if(Boolean(visitingDragonData) && Boolean(visitingDragonData.hasOwnProperty(VISTING_DRAGON_CODE)) && visitingDragonData[VISTING_DRAGON_CODE] == itemCode)
               {
                  visitingDragonData = null;
                  FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,FEATURE_VISITING_DRAGON,featureData);
                  break;
               }
            }
         }
      }
      
      public function resetVisitingDragonByGender(gender:String = "M") : void
      {
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON);
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(gender)) && Boolean(featureData[gender]))
         {
            featureData[gender] = null;
            FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,FEATURE_VISITING_DRAGON,featureData);
         }
      }
      
      public function setVisitingDragonItemCode(itemCode:String, gender:String = "M") : void
      {
         var visitingDragonData:Array = null;
         var featureData:Array = new Array();
         if(featureData)
         {
            visitingDragonData = new Array();
            visitingDragonData[VISTING_DRAGON_CODE] = itemCode;
            visitingDragonData[VISITING_DRAGON_TS] = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            visitingDragonData[VISITING_DRAGON_BREEDING_STATE] = false;
            featureData[gender] = visitingDragonData;
         }
         FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,FEATURE_VISITING_DRAGON,featureData);
      }
      
      public function setVisitingDragonByTutorial() : void
      {
         var dragonItem:FarmItem = null;
         var dragonItemName:String = DragonBreedingConfigManager.getInstance(this.m_featureName).getRewardFromLevel(VISITING_DRAGON_TUTORIAL_GRANT_LEVEL);
         var dragonItemCode:String = "";
         var keyword:String = "";
         var gender:String = "";
         if(dragonItemName)
         {
            dragonItem = Global.farmGameSettingsManager.getFarmItemByName(dragonItemName);
            dragonItemCode = dragonItem.code;
            if(dragonItem)
            {
               if(dragonItem.keyword)
               {
                  if(dragonItem.keyword == DragonBreedingManager.DRAGON_FEMALE_ITEM_KEY)
                  {
                     gender = DragonBreedingConfigManager.GENDER_CODE_FEMALE;
                  }
                  else if(dragonItem.keyword == DragonBreedingManager.DRAGON_MALE_ITEM_KEY)
                  {
                     gender = DragonBreedingConfigManager.GENDER_CODE_MALE;
                  }
                  if(gender != "" && dragonItemCode != "")
                  {
                     this.setVisitingDragonItemCode(dragonItemCode,gender);
                  }
               }
            }
         }
      }
      
      public function setVisitingDragonBreedingState(breedingState:Boolean) : void
      {
         var visitingDragonsState:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON) as Object;
         if(Boolean(visitingDragonsState) && visitingDragonsState.hasOwnProperty(VISITING_DRAGON_BREEDING_STATE))
         {
            visitingDragonsState[VISITING_DRAGON_BREEDING_STATE] = breedingState;
            FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,FEATURE_VISITING_DRAGON,visitingDragonsState);
         }
      }
      
      public function setVistingDragonBreedingStateByGender(breedingState:Boolean, gender:String = "M") : void
      {
         var visitingDragonState:Object = null;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON);
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(gender)) && Boolean(featureData[gender]))
         {
            visitingDragonState = featureData[gender];
            if(visitingDragonState.hasOwnProperty(VISITING_DRAGON_BREEDING_STATE))
            {
               visitingDragonState[VISITING_DRAGON_BREEDING_STATE] = breedingState;
               featureData[gender] = visitingDragonState;
            }
         }
         FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,FEATURE_VISITING_DRAGON,featureData);
      }
      
      public function isVisitingDragonInBreeding(itemCode:String = "") : Boolean
      {
         var result:Boolean = false;
         var visitingDragonData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON) as Object;
         if(visitingDragonData)
         {
            if(Boolean(visitingDragonData && visitingDragonData[VISTING_DRAGON_CODE]) && Boolean(visitingDragonData[VISTING_DRAGON_CODE] == itemCode) && visitingDragonData.hasOwnProperty(VISITING_DRAGON_BREEDING_STATE))
            {
               result = Boolean(visitingDragonData[VISITING_DRAGON_BREEDING_STATE]);
            }
         }
         return result;
      }
      
      public function isVisitingDragonInBreedingByGender(gender:String = "M") : Boolean
      {
         var visitingDragonData:Object = null;
         var result:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON) as Object;
         if(Boolean(featureData) && Boolean(featureData.hasOwnProperty(gender)) && Boolean(featureData[gender]))
         {
            visitingDragonData = featureData[gender];
            if(Boolean(visitingDragonData) && Boolean(visitingDragonData[VISTING_DRAGON_CODE]) && visitingDragonData.hasOwnProperty(VISITING_DRAGON_BREEDING_STATE))
            {
               result = Boolean(visitingDragonData[VISITING_DRAGON_BREEDING_STATE]);
            }
         }
         return result;
      }
      
      public function isVisitingDragonInBreedingByItemCode(itemCode:String = "") : Boolean
      {
         var visitingDragonData:Object = null;
         var result:Boolean = false;
         var featureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,FEATURE_VISITING_DRAGON) as Object;
         if(featureData)
         {
            for each(visitingDragonData in featureData)
            {
               if(visitingDragonData)
               {
                  if(Boolean(visitingDragonData && visitingDragonData[VISTING_DRAGON_CODE]) && Boolean(visitingDragonData[VISTING_DRAGON_CODE] == itemCode) && visitingDragonData.hasOwnProperty(VISITING_DRAGON_BREEDING_STATE))
                  {
                     result = Boolean(visitingDragonData[VISITING_DRAGON_BREEDING_STATE]);
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function getOffspringForCouple(maleDragon:String, femaleDragon:String, id:String) : Object
      {
         var offsprings:Array = DragonBreedingConfigManager.getInstance(this.featureName).getOffsprings();
         return offsprings[maleDragon + "_" + femaleDragon][id];
      }
      
      public function getHatcheryData() : Object
      {
         return DragonBreedingManager.getHatcheryManager(this.featureName).getFeatureData();
      }
      
      public function getUnlockCostForLevel(level:int) : int
      {
         var i:int = 0;
         var result:int = 0;
         var levelCosts:Array = DragonBreedingManager.getUnlockLevelCost(this.featureName);
         var bigRewardsLevels:Array = DragonBreedingConfigManager.getInstance(this.featureName).getBigRewardsLevels();
         if(bigRewardsLevels != null)
         {
            for(i = 0; i < bigRewardsLevels.length; i++)
            {
               if(bigRewardsLevels[i] == level)
               {
                  result = int(levelCosts[i]);
                  break;
               }
            }
         }
         return result;
      }
      
      public function getUnlockLevelCostByXp() : int
      {
         var currentLevel:int = 0;
         var nextBigLevel:int = 0;
         var prevBiglevel:int = 0;
         var tierXp:int = 0;
         var totalXpNeeded:int = 0;
         var unlockCost:int = 0;
         var costPerXp:Number = NaN;
         var actualUnlockCost:int = 0;
         var breedingSkillState:DragonBreedingSkillState = this.getBreedingSkillState();
         if(Boolean(breedingSkillState) && Boolean(breedingSkillState.level > 0) && breedingSkillState.xp > -1)
         {
            currentLevel = breedingSkillState.level;
            nextBigLevel = DragonBreedingConfigManager.getInstance(this.featureName).getNextBigReward(currentLevel);
            prevBiglevel = DragonBreedingConfigManager.getInstance(this.featureName).getPreviousBigReward(currentLevel);
            tierXp = (nextBigLevel - prevBiglevel) * MAX_XP_PER_LEVEL;
            totalXpNeeded = (nextBigLevel - (currentLevel + 1)) * MAX_XP_PER_LEVEL + (MAX_XP_PER_LEVEL - breedingSkillState.xp);
            unlockCost = this.getUnlockCostForLevel(nextBigLevel);
            costPerXp = unlockCost / tierXp;
            actualUnlockCost = Math.ceil(costPerXp * totalXpNeeded);
         }
         return actualUnlockCost;
      }
      
      public function getPlayerCurrentLevel() : int
      {
         var result:int = 1;
         if(Boolean(this.getBreedingSkillState()) && Boolean(this.getBreedingSkillState().level))
         {
            result = this.getBreedingSkillState().level;
         }
         return result;
      }
      
      public function getPlayerCurrentXp() : int
      {
         var result:int = 0;
         if(Boolean(this.getBreedingSkillState()) && Boolean(this.getBreedingSkillState().xp))
         {
            result = this.getBreedingSkillState().xp;
         }
         return result;
      }
      
      public function askForLovePotions(source:String = "UI", callback:Function = null, closeCallBack:Function = null) : void
      {
         var limitReached:Boolean = FeatureOptionsInventoryManager.getInstance().limitReachedForItem(LOVE_POTION_ITEM_CODE);
         if(!limitReached || source == BRAG_FEED)
         {
            if(this.canAskForLovePotions())
            {
               TransactionManager.addTransaction(new TDragonBreeding(LOVE_POTION_ITEM_CODE,function(rewardLink:String):void
               {
                  var item:* = Global.farmGameSettingsManager.getFarmItemByCode(LOVE_POTION_ITEM_CODE);
                  var bundle:* = featureName + "_AskLovePotion_" + source;
                  var bundleData:* = {};
                  bundleData["reward_link"] = rewardLink;
                  bundleData["itemName"] = item.friendlyName;
                  bundleData["images"] = [{
                     "src":item.icon,
                     "href":Config.SN_APP_URL + rewardLink
                  }];
                  GlobalEngine.socialNetwork.publishFeedStory(bundle,bundleData,[],false,closeCallBack);
                  Global.player.setFeatureLastShown(FEATURE_OPTION_KEY + "_lovePotion",GlobalEngine.serverTime / 1000,true);
                  if(callback != null)
                  {
                     callback();
                  }
               },HERB_FEED),true);
            }
         }
         else
         {
            this.showLimitReachedMessage();
         }
      }
      
      public function canAskForLovePotions() : Boolean
      {
         var result:Boolean = false;
         var interval:Number = Global.farmGameSettingsManager.getAttribute("BreedingAskLoveHerbsTimeLimit",14400);
         if(GlobalEngine.serverTime / 1000 - Global.player.getFeatureLastShown(FEATURE_OPTION_KEY + "_lovePotion") >= interval)
         {
            result = true;
         }
         return result;
      }
      
      public function canAskForFire() : Boolean
      {
         var result:Boolean = false;
         var interval:Number = Global.farmGameSettingsManager.getAttribute("BreedingAskFireTimeLimit",14400);
         if(GlobalEngine.serverTime / 1000 - Global.player.getFeatureLastShown(FEATURE_OPTION_KEY + "_fire") >= interval)
         {
            result = true;
         }
         return result;
      }
      
      public function getTimeUntilPostFeedEnabled(itemCode:String) : Array
      {
         var intervalFire:Number = NaN;
         var intervalHerbs:Number = NaN;
         var result:Number = 0;
         switch(itemCode)
         {
            case FIRE_ITEM_CODE:
               intervalFire = Global.farmGameSettingsManager.getAttribute("BreedingAskFireTimeLimit",14400);
               result = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(FEATURE_OPTION_KEY + "_fire");
               result = intervalFire - result;
               break;
            case LOVE_POTION_ITEM_CODE:
               intervalHerbs = Global.farmGameSettingsManager.getAttribute("BreedingAskLoveHerbsTimeLimit",14400);
               result = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(FEATURE_OPTION_KEY + "_lovePotion");
               result = intervalHerbs - result;
         }
         if(result < 0)
         {
            result = 0;
         }
         return FarmGameUtil.parseTimeLeft(result);
      }
      
      public function askForFire(source:String = "UI", callback:Function = null, closeCallback:Function = null) : void
      {
         var limitReached:Boolean = FeatureOptionsInventoryManager.getInstance().limitReachedForItem(FIRE_ITEM_CODE);
         if(!limitReached)
         {
            if(this.canAskForFire())
            {
               TransactionManager.addTransaction(new TDragonBreeding(FIRE_ITEM_CODE,function(rewardLink:String):void
               {
                  var item:* = Global.farmGameSettingsManager.getFarmItemByCode(FIRE_ITEM_CODE);
                  var bundle:* = featureName + "_AskFire_" + source;
                  var bundleData:* = {};
                  bundleData["reward_link"] = rewardLink;
                  bundleData["itemName"] = item.friendlyName;
                  bundleData["images"] = [{
                     "src":item.icon,
                     "href":Config.SN_APP_URL + rewardLink
                  }];
                  GlobalEngine.socialNetwork.publishFeedStory(bundle,bundleData,[],false,closeCallback);
                  Global.player.setFeatureLastShown(FEATURE_OPTION_KEY + "_fire",GlobalEngine.serverTime / 1000,true);
                  if(callback != null)
                  {
                     callback();
                  }
               },FIRE_FEED),true);
            }
         }
         else
         {
            this.showLimitReachedMessage();
         }
      }
      
      private function showLimitReachedMessage() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs",FEATURE_OPTION_KEY + "_InventoryLimit_Reached"),0,null,"",true);
      }
      
      public function showCraftingWindowWithItem(craftItemName:String) : Boolean
      {
         var limitReached:Boolean;
         var itemCode:String = null;
         var craftShop:String = null;
         var craftshopOpened:Boolean = false;
         var recipeId:String = null;
         var prompt:GenericXMLDialog = null;
         var result:Boolean = false;
         if(craftItemName == FIRE_ITEM_NAME)
         {
            itemCode = FIRE_ITEM_CODE;
         }
         else if(craftItemName == HERB_ITEM_NAME)
         {
            itemCode = LOVE_POTION_ITEM_CODE;
         }
         limitReached = FeatureOptionsInventoryManager.getInstance().limitReachedForItem(itemCode);
         if(!limitReached)
         {
            craftShop = CraftingManager.getCraftShopNameForCurrentWorld(Global.worldManager.currentWorldType);
            craftshopOpened = false;
            recipeId = LOVE_POTION_RECIPE_ID;
            if(Boolean(craftItemName) && craftItemName == FIRE_ITEM_NAME)
            {
               recipeId = FIRE_RECIPE_ID;
            }
            if(CraftingManager.getInstance().showCraftingWindowForRecipe(recipeId))
            {
               craftshopOpened = true;
            }
            if(!craftshopOpened)
            {
               prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName("craftingworkshop_finished","icon",false),100,100,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Message"),null,true,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SurfaceCraftShop_Button"),function(event:Event):void
               {
                  Global.world.enterForcePlaceMode("craftingworkshop_finished",true,0,false,false,{"suppressGiftRepop":true});
               });
               UI.displayPopup(prompt,true,"",true);
            }
            if(this.dragonBreedingWindow)
            {
               this.dragonBreedingWindow.close();
            }
            result = true;
         }
         else
         {
            this.showLimitReachedMessage();
         }
         return result;
      }
      
      public function buyCraftItemBuckets(buyPackage:String) : void
      {
         var sunshinePackage:FarmItem = null;
         if(buyPackage != null)
         {
            sunshinePackage = Global.farmGameSettingsManager.getFarmItemByName(buyPackage);
            Global.player.buyFarmItem(sunshinePackage,Currency.CASH,1);
            this.dispatchEvent(new Event(EVENT_INVENTORY_REFRESH));
         }
      }
      
      public function getCraftItemCount(itemId:String = "1gzw") : Number
      {
         return FeatureOptionsInventoryManager.getInstance().getCount(itemId);
      }
      
      public function reopenDragaonBreedingUI(val:Boolean) : void
      {
         this.openDragonBreedingUI();
      }
      
      public function openDragonBreedingUI() : void
      {
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_DRAGON_BREEDING) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            if(this.m_dragonBreedingWindow == null)
            {
               this.m_dragonBreedingWindow = new DragonBreedingWindow(this.featureName);
               UI.displayPopup(this.m_dragonBreedingWindow);
               FarmStatsManager.count(this.m_featureName,"playing_db","main_dialog");
            }
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","ComingSoon"));
         }
      }
      
      public function getMainDialogAssetURL() : String
      {
         return this.m_mainAssetPath;
      }
      
      public function getSelectionDialogURL() : String
      {
         return this.m_selectDialogPath;
      }
      
      public function getProgressDialogURL() : String
      {
         return this.m_progressDialogPath;
      }
      
      public function getFamilyTreeDialogURL() : String
      {
         return this.m_familyTreeDialogPath;
      }
      
      public function getCraftBuyDialogURL() : String
      {
         return this.m_craftBuyDialogPath;
      }
      
      public function getCraftDialogURL() : String
      {
         return this.m_craftDialogPath;
      }
      
      public function getTutorialDialogURL() : String
      {
         return this.m_tutorialDialogPath;
      }
      
      public function getFourPanelPath() : String
      {
         return this.m_fourpanelPath;
      }
      
      public function getToasterPath() : String
      {
         return this.m_toasterDialogPath;
      }
      
      public function getCraftBucketPackagesByItemCode(itemName:String) : Array
      {
         var result:Array = null;
         return itemName == HERB_ITEM_NAME ? this.herbsOfLovePackages : this.firePackages;
      }
      
      public function set herbsOfLovePackages(items:Array) : void
      {
         this.m_herbsOfLovePackages = items;
      }
      
      public function get herbsOfLovePackages() : Array
      {
         return this.m_herbsOfLovePackages;
      }
      
      public function get firePackages() : Array
      {
         return getHatcheryManager(this.featureName).getBucketPackages();
      }
      
      public function getDragonUnlockCost() : int
      {
         return 10;
      }
      
      public function get visitingDragonDuration() : int
      {
         var strDuration:String = DragonBreedingConfigManager.getInstance(this.m_featureName).getFeatureConfigAttr("visitingDragonDuration") as String;
         var duration:int = int(strDuration);
         if(duration > 0)
         {
            duration *= FarmGameUtil.NUM_SECS_IN_HOUR;
         }
         else
         {
            duration = VISITING_DRAGON_DURATION;
         }
         return duration;
      }
      
      public function onBuyDragon() : Boolean
      {
         return true;
      }
      
      public function set selectedOffspring(selectedDragon:Object) : void
      {
         this.m_selectedOffspring = selectedDragon;
      }
      
      public function set selectedMaleDragonId(selectedDragonId:String) : void
      {
         this.m_selectedMaleDragonId = selectedDragonId;
      }
      
      public function set selectedFemaleDragonId(selectedDragonId:String) : void
      {
         this.m_selectedFemaleDragonId = selectedDragonId;
      }
      
      public function get selectedOffspring() : Object
      {
         return this.m_selectedOffspring;
      }
      
      public function get selectedMaleDragonId() : String
      {
         return this.m_selectedMaleDragonId;
      }
      
      public function get selectedFemaleDragonId() : String
      {
         return this.m_selectedFemaleDragonId;
      }
      
      public function showInMarket(item:Array) : void
      {
         if(Boolean(item) && item.length > 0)
         {
            UI.displayMiniMarketDialog([item]);
         }
      }
      
      public function isAnyBreedingComplete() : Boolean
      {
         var breedSession:DragonBreedingSession = null;
         var breedObj:Object = null;
         var breedingQueue:Array = this.getBreedingData();
         for each(breedSession in breedingQueue)
         {
            if(breedSession != null)
            {
               breedObj = breedSession.getDragonBreedObjects();
               if(breedObj != null && this.checkStateGetEgg(breedSession))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function getBreedingDragonCount(itemName:String) : int
      {
         var breedSession:DragonBreedingSession = null;
         var breedObj:Object = null;
         var count:int = 0;
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(itemName);
         if(!itemName || itemName == "" || !itemCode)
         {
            return count;
         }
         var breedingQueue:Array = DragonBreedingManager.getInstance(this.m_featureName).getBreedingData();
         for each(breedSession in breedingQueue)
         {
            if(breedSession != null)
            {
               breedObj = breedSession.getDragonBreedObjects();
               if(breedObj != null && !breedSession.collected && (breedObj[DragonBreedingConfigManager.GENDER_CODE_MALE] == itemCode || breedObj[DragonBreedingConfigManager.GENDER_CODE_FEMALE] == itemCode))
               {
                  count++;
               }
            }
         }
         return count;
      }
      
      public function isVisitingDragonBreedingComplete(visitingDragonCode:String) : Boolean
      {
         var breedSession:DragonBreedingSession = null;
         var breedObj:Object = null;
         if(!visitingDragonCode || visitingDragonCode == "")
         {
            return false;
         }
         var breedingQueue:Array = DragonBreedingManager.getInstance(this.m_featureName).getBreedingData();
         for each(breedSession in breedingQueue)
         {
            if(breedSession != null)
            {
               breedObj = breedSession.getDragonBreedObjects();
               if(breedObj != null && breedSession.isComplete() && (breedObj[DragonBreedingConfigManager.GENDER_CODE_MALE] == visitingDragonCode || breedObj[DragonBreedingConfigManager.GENDER_CODE_FEMALE] == visitingDragonCode))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function checkAndSetState(featureBuilding:FeatureBuilding) : void
      {
         var dbskillState:DragonBreedingSkillState = this.getBreedingSkillState();
         var i:int = 0;
         featureBuilding.setState(FeatureBuilding.STATE_BARE);
         while(i < dbskillState.unlockedSuites)
         {
            if(this.isAnyBreedingComplete() || DragonBreedingManager.getHatcheryManager(this.featureName).canGetMystree(i.toString()))
            {
               featureBuilding.setState(FeatureBuilding.STATE_RIPE);
               break;
            }
            i++;
         }
      }
      
      public function getItemBreedingCountByItemCode(itemCode:String) : int
      {
         var breedSession:DragonBreedingSession = null;
         var breedObj:Object = null;
         var breedingCount:int = 0;
         var breedingQueue:Array = this.getBreedingData();
         for each(breedSession in breedingQueue)
         {
            if(breedSession)
            {
               breedObj = breedSession.getDragonBreedObjects();
               if(breedObj != null && !breedSession.collected)
               {
                  if(breedObj.hasOwnProperty(DragonBreedingConfigManager.GENDER_CODE_MALE))
                  {
                     if(breedObj[DragonBreedingConfigManager.GENDER_CODE_MALE] == itemCode)
                     {
                        breedingCount += 1;
                     }
                  }
                  if(breedObj.hasOwnProperty(DragonBreedingConfigManager.GENDER_CODE_FEMALE))
                  {
                     if(breedObj[DragonBreedingConfigManager.GENDER_CODE_FEMALE] == itemCode)
                     {
                        breedingCount += 1;
                     }
                  }
               }
            }
         }
         return breedingCount;
      }
      
      public function getDragonCountByItemCode(itemCode:String) : int
      {
         var featureData:Object = null;
         var keyword:String = null;
         var itemCount:int = 0;
         var featureOpsKey:String = DragonBreedingManager.FEATURE_MALE_DRAGON_AVAILABLE;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(item)
         {
            keyword = item.keyword;
            if(Boolean(keyword) && keyword.length > 0)
            {
               if(keyword == DragonBreedingManager.DRAGON_FEMALE_ITEM_KEY)
               {
                  featureOpsKey = DragonBreedingManager.FEATURE_FEMALE_DRAGON_AVAILABLE;
               }
               featureData = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,featureOpsKey);
               if(Boolean(featureData) && featureData.hasOwnProperty(itemCode))
               {
                  itemCount = int(featureData[itemCode]);
               }
               if(this.isValidVisitingDragonByItemCode(itemCode))
               {
                  itemCount += 1;
               }
               return itemCount;
            }
            throw new Error("Keyword missing for the item " + item.name + " while buying");
         }
         throw new Error("Item not found");
      }
      
      public function getBreedCompletedParentItems() : Array
      {
         var breedSession:DragonBreedingSession = null;
         var breedObj:Object = null;
         var result:Array = new Array();
         var breedingQueue:Array = this.getBreedingData();
         if(Boolean(breedingQueue) && breedingQueue.length > 0)
         {
            for each(breedSession in breedingQueue)
            {
               breedObj = breedSession.getDragonBreedObjects();
               if(breedObj != null && this.checkStateGetEgg(breedSession))
               {
                  result.push(breedObj);
               }
            }
         }
         return result;
      }
      
      public function getHatchReadyParentItems() : Array
      {
         var i:int = 0;
         var breedSession:DragonBreedingSession = null;
         var breedObj:Object = null;
         var result:Array = new Array();
         var dbskillState:DragonBreedingSkillState = this.getBreedingSkillState();
         var totalUnlockedSuites:int = dbskillState.unlockedSuites;
         var breedingQueues:Array = this.getBreedingData();
         if(totalUnlockedSuites > 0)
         {
            for(i = 0; i < totalUnlockedSuites; i++)
            {
               if(DragonBreedingManager.getHatcheryManager(this.featureName).canGetMystree(i.toString()))
               {
                  if(breedingQueues[i] != null)
                  {
                     breedSession = breedingQueues[i] as DragonBreedingSession;
                     if(Boolean(breedSession) && Boolean(breedSession.getDragonBreedObjects()))
                     {
                        breedObj = breedSession.getDragonBreedObjects();
                        result.push(breedObj);
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function getBreedSessionByItemCode(itemCode:String) : DragonBreedingSession
      {
         var breedSession:DragonBreedingSession = null;
         var breedObj:Object = null;
         var dragonBreedSession:DragonBreedingSession = null;
         var breedingQueue:Array = this.getBreedingData();
         if(Boolean(breedingQueue) && breedingQueue.length > 0)
         {
            for each(breedSession in breedingQueue)
            {
               if(Boolean(breedSession) && breedSession is DragonBreedingSession)
               {
                  breedObj = breedSession.getDragonBreedObjects();
                  if(breedObj != null && !breedSession.isComplete())
                  {
                     if(breedObj.hasOwnProperty(DragonBreedingConfigManager.GENDER_CODE_MALE))
                     {
                        if(breedObj[DragonBreedingConfigManager.GENDER_CODE_MALE] == itemCode)
                        {
                           dragonBreedSession = breedSession;
                           break;
                        }
                     }
                     if(breedObj.hasOwnProperty(DragonBreedingConfigManager.GENDER_CODE_FEMALE))
                     {
                        if(breedObj[DragonBreedingConfigManager.GENDER_CODE_FEMALE] == itemCode)
                        {
                           dragonBreedSession = breedSession;
                           break;
                        }
                     }
                  }
               }
            }
         }
         return dragonBreedSession;
      }
      
      public function updateParentDragonItemCount(itemCode:String = "") : void
      {
         var featureData:Object = null;
         var keyword:String = null;
         var featureOpsKey:String = DragonBreedingManager.FEATURE_MALE_DRAGON_AVAILABLE;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         var itemCount:int = 1;
         var gender:String = DragonBreedingConfigManager.GENDER_CODE_MALE;
         if(item)
         {
            keyword = item.keyword;
            if(Boolean(keyword) && keyword.length > 0)
            {
               if(keyword == DragonBreedingManager.DRAGON_FEMALE_ITEM_KEY)
               {
                  featureOpsKey = DragonBreedingManager.FEATURE_FEMALE_DRAGON_AVAILABLE;
                  gender = DragonBreedingConfigManager.GENDER_CODE_FEMALE;
               }
               featureData = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,featureOpsKey);
               if(featureData == null)
               {
                  featureData = {};
                  featureData[item.code] = itemCount;
               }
               else if(featureData.hasOwnProperty(item.code) && featureData[item.code] > 0)
               {
                  featureData[item.code] += itemCount;
               }
               else
               {
                  if(featureData.hasOwnProperty(item.code))
                  {
                     throw new Error("Could not find the item [" + item.name + "] in the FeatureOption");
                  }
                  featureData[item.code] = itemCount;
               }
               FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,featureOpsKey,featureData);
               this.updateMarketDragonLevel(this.featureName,item.code,gender);
               return;
            }
            throw new Error("Keyword missing for the item " + item.name + " while buying");
         }
         throw new Error("Item not found while buying");
      }
      
      public function testPostFeed() : void
      {
         this.postFeedForVisitingDragon("7qcw");
      }
      
      public function postFeedForVisitingDragon(itemCode:String) : void
      {
         var shareableItem:String = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
         if(item)
         {
            shareableItem = (item as MutableDragonItem).getShareableItemCode();
            if(shareableItem)
            {
               TransactionManager.addTransaction(new TGenericTransaction("DragonBreedingService","postFeedForVisitingDragon",this.postFeed,[shareableItem,this.featureName]));
            }
         }
      }
      
      private function postFeed(result:Object) : void
      {
         var callBackName:String = null;
         var data:Object = result.data;
         var actionCountKey:String = this.getActionCountKey(result.itemCode);
         if(Boolean(data) && Boolean(data.showFeedDialog))
         {
            if(Boolean(data.attachment) && Boolean(data.actionLink) && Boolean(data.userMessagePrompt))
            {
               this.m_itemCode = result.itemCode;
               this.m_timeRequestedAt = result.ts;
               callBackName = "feedPostCallback";
               try
               {
                  callBackName = "feedPostCallback_" + MD5.hash(data.actionLink[0].href);
               }
               catch(error:Error)
               {
               }
               ExternalInterface.addCallback(callBackName,this.feedPostCallback);
               GlobalEngine.socialNetwork.streamPublish(data.attachment,data.actionLink,null,data.userMessagePrompt);
            }
            else if(Config.DEBUG_MODE)
            {
               ErrorManager.addError("UserMessagePrompt, actionLink or attachment is missing for: " + actionCountKey);
            }
         }
         else if(Boolean(data) && Boolean(data.published))
         {
            this.registerFeedPublishSuccess(result.itemCode);
            GlobalEngine.socialNetwork.feedPostConfirmation(data);
         }
      }
      
      public function feedPostCallback(result:Object) : void
      {
         var postSuccess:Boolean = false;
         if(Boolean(result.result) && Boolean(result.postId) && Boolean(result.callBackName))
         {
            if(result.result == "posted")
            {
               TransactionManager.addTransaction(new TGenericTransaction("DragonBreedingService","recordVisitingDragonItemRequest",null,[this.m_itemCode,this.m_timeRequestedAt]));
               this.registerFeedPublishSuccess(this.m_itemCode as String);
            }
            postSuccess = true;
            ExternalInterface.addCallback(result.callBackName,null);
         }
      }
      
      public function getActionCountKey(itemCode:String) : String
      {
         return this.featureName + "_" + itemCode;
      }
      
      public function registerFeedPublishSuccess(itemCode:String) : void
      {
         var actionCountKey:String = this.getActionCountKey(itemCode);
         Global.player.incrementIntervalActionCount(actionCountKey,Global.farmGameSettingsManager.getInt(actionCountKey + this.getTimeIntervalSuffix(),21600));
      }
      
      private function getIntervalLimitSuffix() : String
      {
         return "_IntervalLimit";
      }
      
      private function getTimeIntervalSuffix() : String
      {
         return "_TimeInterval";
      }
      
      public function testRewardWindows() : void
      {
         UI.displayPopup(new DragonBreedingRewardWindow("dragon_pen_finished",1),false);
         UI.displayPopup(new DragonBreedingLevelUpWindow("dragon_pen_finished","7c38",5),false);
         UI.displayPopup(new DragonBreedingUnlockNestWindow("dragon_pen_finished","7c38",7),false);
      }
      
      public function showUI() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.showUI);
            InputManager.enableInput();
            UI.stopPopups(false);
         }
         this.openDragonBreedingUI();
      }
      
      private function panToBuildingAndShowUI(buildingName:String) : void
      {
         ItemFinderManager.getInstance().highlightWorldItems(buildingName);
         this.m_timer = new Timer(OPEN_UI_DELAY,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,function(e:Event):void
         {
            showUI();
         });
         this.m_timer.start();
         InputManager.disableInput();
      }
      
      public function showEyrieAndOpenWindow(buildingName:String) : void
      {
         var numObj:Array = Global.world.getObjectsByName(ALTERNATE_BUILDING);
         var numObj2:Array = Global.world.getObjectsByName(buildingName);
         if(numObj.length)
         {
            this.panToBuildingAndShowUI(ALTERNATE_BUILDING);
         }
         else if(numObj2.length)
         {
            this.panToBuildingAndShowUI(buildingName);
         }
         else
         {
            Global.world.enterForcePlaceMode(ALTERNATE_BUILDING,true,0,false,false);
         }
      }
      
      public function isTutorialMode() : Boolean
      {
         var result:Boolean = false;
         var tutorialMode:Boolean = FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,DragonBreedingManager.FEATURE_TUTORIAL_MODE) as Boolean;
         if(tutorialMode)
         {
            result = tutorialMode;
         }
         return result;
      }
      
      public function setTutorialComplete() : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(this.featureName,DragonBreedingManager.FEATURE_TUTORIAL_MODE,false);
      }
      
      public function isTutorialComplete() : Boolean
      {
         var result:Boolean = false;
         if(!FeatureOptionsManager.getInstance().getFeatureOption(this.featureName,DragonBreedingManager.FEATURE_TUTORIAL_MODE))
         {
            result = true;
         }
         return result;
      }
      
      public function canShowVisitingDragonTutorialStep1() : Boolean
      {
         var result:Boolean = false;
         if(this.isTutorialComplete() && this.getVisitingDragonItemCodeAsArray().length == 0 && this.getBreedingSkillState().level >= 2 && Global.player.getSeenFlag(VISITING_DRAGON_TUTORIAL_FLAG) == false)
         {
            result = true;
         }
         return result;
      }
      
      public function canShowVisitingDragonTutorialStep2() : Boolean
      {
         var vdCode:String = null;
         var result:Boolean = false;
         var visitingDragons:Array = this.getVisitingDragonItemCodeAsArray();
         if(this.isTutorialComplete() && visitingDragons.length > 0 && this.getBreedingSkillState().level >= 2 && Global.player.getSeenFlag(VISITING_DRAGON_TUTORIAL_FLAG) == false)
         {
            for each(vdCode in visitingDragons)
            {
               if(this.isValidVisitingDragonByItemCode(vdCode))
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function setVisitingDragonTutorialSeenFlag() : void
      {
         Global.player.setSeenFlag(VISITING_DRAGON_TUTORIAL_FLAG);
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      public function openToasterWindow() : void
      {
         if(!this.isToasterWindow())
         {
            this.initToasterWindow();
         }
      }
      
      private function initToasterWindow() : void
      {
         if(!this.m_toasterWindow)
         {
            this.m_toasterWindow = new DragonBreedingToasterWindow(this.m_toasterDialogPath,this.featureName);
            ToasterManager.getInstance().add(this.m_toasterWindow);
         }
      }
      
      private function isToasterWindow() : Boolean
      {
         return this.m_toasterWindow ? true : false;
      }
      
      public function destoryToasterWindow() : void
      {
         if(this.m_toasterWindow)
         {
            this.m_toasterWindow = null;
         }
      }
      
      public function set toasterWindowType(type:int) : void
      {
         this.m_toasterType = type;
      }
      
      public function get toasterWindowType() : int
      {
         return this.m_toasterType;
      }
      
      public function savePotionsForSelectionPopup(num:Number) : void
      {
         this.m_potionsCountForSelection = num;
      }
      
      public function getPotionsForSelectionPopup() : Number
      {
         return this.m_potionsCountForSelection;
      }
      
      public function resetPotionsForSelectionPopup() : void
      {
         this.m_potionsCountForSelection = 0;
      }
      
      public function getMaxProgressLevel() : int
      {
         return DragonBreedingConfigManager.getInstance(this.featureName).getMaxLevel();
      }
      
      public function checkStateGetEgg(breedSession:DragonBreedingSession) : Boolean
      {
         return breedSession.isComplete() && !breedSession.collected;
      }
      
      public function checkStateCanTend(breedSession:DragonBreedingSession) : Boolean
      {
         return breedSession.isComplete() && breedSession.collected;
      }
      
      public function checkStateCanHatch(breedSession:DragonBreedingSession) : Boolean
      {
         return breedSession.isComplete() && breedSession.collected && this.m_hatcheryManager.canGetMystree(breedSession.suiteSlot.toString());
      }
      
      public function get dragonBreedingWindow() : DragonBreedingWindow
      {
         return this.m_dragonBreedingWindow;
      }
      
      public function set dragonBreedingWindow(dragonBreedingWindow:DragonBreedingWindow) : void
      {
         this.m_dragonBreedingWindow = dragonBreedingWindow;
      }
      
      public function shareBragFeed(bragFeedType:String = "dragonBreedingLevelShareReward") : void
      {
         this.m_bragFeedType = bragFeedType;
         var itemName:String = Global.farmGameSettingsManager.getFarmItemNameByCode(LOVE_POTION_ITEM_CODE);
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,this.ACTION_SHARE_BRAG_FEED,this.onShareBragFeed,[itemName,this.featureName,this.m_bragFeedType]));
      }
      
      private function onShareBragFeed(result:Object) : void
      {
         var rewardName:String = null;
         var rewardLink:String = null;
         var rewardItem:FarmItem = null;
         var level:String = null;
         var bundleData:Object = null;
         if(Boolean(result) && Boolean(result.hasOwnProperty("rewardName")) && result.hasOwnProperty("rewardLink"))
         {
            rewardName = result.rewardName;
            rewardLink = result.rewardLink;
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
            level = this.getPlayerCurrentLevel().toString();
            bundleData = {
               "reward_link":rewardLink,
               "level":level,
               "dragonName":this.m_lastUnlockedDragonName,
               "creative":this.featureName,
               "subcategory":this.m_bragFeedType,
               "images":[{
                  "href":"{SN_APP_URL}" + rewardLink,
                  "src":rewardItem.getImageByName(FarmItem.ICON_FEED)
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory(this.m_bragFeedType,bundleData,[],false);
         }
      }
   }
}

