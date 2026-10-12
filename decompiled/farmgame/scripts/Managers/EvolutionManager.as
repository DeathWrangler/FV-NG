package Managers
{
   import Classes.EvolutionAnimal;
   import Classes.EvolutionAnimalCrate;
   import Classes.ZItem.EvolutionAnimalItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.EvolutionChoiceDialog;
   import Display.EvolutionDialog;
   import Display.EvolutionShareDialog;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.Evolution.TEvolutionPostFeed;
   import Transactions.TGenericTransaction;
   import Transactions.TSetFeatureFrequencyTimestamp;
   import Widgets.Constants.Market.Currency;
   import flash.filters.GlowFilter;
   import flash.utils.getDefinitionByName;
   
   public class EvolutionManager
   {
      
      private static var s_instance:EvolutionManager;
      
      public static var s_isInitialized:Boolean = false;
      
      private static const FEATURE_NAME:String = "Evolution";
      
      public static const EVOLVE_ANIMAL_FEED:String = "evolve_animal";
      
      public static const OPEN_CRATE_FEED:String = "open_crate";
      
      public static const FEED_COMMON:String = "evolution_feed_common";
      
      public static const FEED_UNCOMMON:String = "evolution_feed_uncommon";
      
      public static const FEED_RARE:String = "evolution_feed_rare";
      
      private static const EVOLUTION_OPTIONS:String = "option_";
      
      private static const EVOLUTION_ELDER:String = "elder";
      
      private static const EVOLUTION_EVOLVE:String = "evolve";
      
      private static const NUMBER_OF_HOW_THIS_WORKS_IMAGES:int = 4;
      
      public static const EVOLVE_ANIMAL_HOWDOESTHISWORK:String = "evolve_animal_howdoesthiswork";
      
      public static const EVOLVE_ANIMAL_MOVE_STORE_WARNING:String = "evolve_animal_move_store";
      
      private static const EVOLVE_ANIMAL_COMPLETE_NOW_PROMPT:String = "EvolutionCompleteNow";
      
      private var m_data:Object = {};
      
      private var m_feedData:Object = {};
      
      private var m_animalsInfo:Object = {};
      
      private var m_crate:FarmItem = null;
      
      private var m_dialogAsset:String = "";
      
      private var m_dialog:EvolutionDialog = null;
      
      private var m_howDoesThisWork:Array = [];
      
      private var m_baseAnimals:Array = [];
      
      private var m_pinkAnimals:Array = [];
      
      private var m_blueAnimals:Array = [];
      
      public function EvolutionManager(key:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(key != null,"[EvolutionManager] :: Use GetInstance()");
      }
      
      public static function get instance() : EvolutionManager
      {
         if(!s_instance)
         {
            s_instance = new EvolutionManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function init() : void
      {
         var feedData:XML = null;
         var animalData:XML = null;
         var nextAnimals:XMLList = null;
         var k:int = 0;
         var nextAnimalData:XML = null;
         var baseAnimalData:XML = null;
         var blueAnimalData:XML = null;
         var pinkAnimalData:XML = null;
         this.m_data = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,FEATURE_NAME);
         var feature:XML = Global.farmGameSettingsManager.getFeatureXML(FEATURE_NAME);
         var feedTypes:XMLList = feature.socialConfig.social;
         for(var j:int = 0; j < feedTypes.length(); j++)
         {
            feedData = feedTypes[j];
            this.m_feedData[feedData.@source] = {
               "source":feedData.@source,
               "throttle":feedData.@throttle,
               "throttleTime":feedData.@throttleTime
            };
         }
         var animals:XMLList = feature.animals.animal;
         for(var i:int = 0; i < animals.length(); i++)
         {
            animalData = animals[i];
            this.m_animalsInfo[animalData.@name] = {
               "elder":animalData.@elder,
               "feedType":animalData.@feedType
            };
            nextAnimals = animalData.nextAnimal;
            for(k = 0; k < nextAnimals.length(); k++)
            {
               nextAnimalData = nextAnimals[k];
               this.m_animalsInfo[animalData.@name][EVOLUTION_OPTIONS + k] = nextAnimalData.@name;
            }
         }
         var baseAnimals:XMLList = feature.baseAnimals.animal;
         for(var l:int = 0; l < baseAnimals.length(); l++)
         {
            baseAnimalData = baseAnimals[l];
            this.m_baseAnimals.push(baseAnimalData.@name);
         }
         var blueAnimals:XMLList = feature.BlueSlotAnimalMappings.animal;
         for(var m:int = 0; m < blueAnimals.length(); m++)
         {
            blueAnimalData = blueAnimals[m];
            this.m_blueAnimals.push(blueAnimalData.@name);
         }
         var pinkAnimals:XMLList = feature.PinkSlotAnimalMappings.animal;
         for(var n:int = 0; n < pinkAnimals.length(); n++)
         {
            pinkAnimalData = pinkAnimals[n];
            this.m_pinkAnimals.push(pinkAnimalData.@name);
         }
         this.m_crate = Global.farmGameSettingsManager.getFarmItemByName(feature.crate.@name);
         this.m_dialogAsset = this.getURLFromImageTag("lookInsideDialog",feature);
         this.m_howDoesThisWork = this.getHowDoesThisWorkImages(feature);
         s_isInitialized = true;
      }
      
      private function getURLFromImageTag(imageName:String, featureXML:XML) : String
      {
         var url:String = "";
         if(Boolean(featureXML) && Boolean(featureXML.image.(@name == imageName)))
         {
            url = featureXML.image.(@name == imageName).@url;
         }
         return url;
      }
      
      private function getHowDoesThisWorkImages(featureXML:XML) : Array
      {
         var result:Array = [];
         var howDoesThisWorkXML:XML = new XML(featureXML.howDoesThisWork);
         for(var i:int = 1; i <= NUMBER_OF_HOW_THIS_WORKS_IMAGES; i++)
         {
            result.push(this.getURLFromImageTag(i.toString(),howDoesThisWorkXML));
         }
         return result;
      }
      
      public function getPinkAnimals() : Array
      {
         return this.m_pinkAnimals;
      }
      
      public function getBlueAnimals() : Array
      {
         return this.m_blueAnimals;
      }
      
      public function postFeed(source:String, callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TEvolutionPostFeed(callback,source));
         StatsManager.count("Feed",FEATURE_NAME,"feline_" + source);
      }
      
      public function getBaseAnimals() : Array
      {
         return this.m_baseAnimals;
      }
      
      public function setAskThrottle(source:String) : void
      {
         var feedData:Object = this.m_feedData[source];
         if(feedData)
         {
            TransactionManager.addTransaction(new TSetFeatureFrequencyTimestamp(feedData.throttle),true);
            Global.player.setFeatureLastShown(feedData.throttle,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
         }
      }
      
      public function getFeatureData() : Object
      {
         return this.m_data;
      }
      
      public function setFeatureData(data:Object) : void
      {
         this.m_data = data;
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,FEATURE_NAME,data);
      }
      
      private function initializeFeatureDataVolatile() : void
      {
         if(!this.m_data)
         {
            this.m_data = new Array();
         }
      }
      
      public function addFeedItemToFeatureData(feedType:String, num:int = 1) : void
      {
         var feedItem:FarmItem = null;
         var iconFilter:Array = null;
         if(num > 0)
         {
            if(!this.m_data)
            {
               this.initializeFeatureDataVolatile();
            }
            if(this.m_data[feedType])
            {
               this.m_data[feedType] += num;
            }
            else
            {
               this.m_data[feedType] = num;
            }
            feedItem = Global.farmGameSettingsManager.getFarmItemByName(feedType);
            iconFilter = [new GlowFilter(16776960,1,8,8,20)];
            Global.player.avatar.displayStatus("+1 " + ZLocUtils.tk_pk_asTitle(feedItem.friendlyName),feedItem.iconUrl,iconFilter);
         }
      }
      
      public function isElderAnimal(animalName:String) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(this.m_animalsInfo[animalName]) && this.m_animalsInfo[animalName][EVOLUTION_ELDER] == true)
         {
            result = true;
         }
         return result;
      }
      
      public function getFeedType(animalName:String) : String
      {
         var result:String = "";
         if(Boolean(this.m_animalsInfo[animalName]) && Boolean(this.m_animalsInfo[animalName]["feedType"]))
         {
            result = this.m_animalsInfo[animalName]["feedType"];
         }
         return result;
      }
      
      public function feed(evoAnimal:EvolutionAnimal, feedType:String, numConsumables:int = 1) : void
      {
         var params:Array = null;
         var feedItem:FarmItem = null;
         var iconFilter:Array = null;
         var IDSData:Object = evoAnimal.getPersistentData("EvolutionAnimal");
         if(IDSData == null)
         {
            IDSData = new Object();
            IDSData.feed = numConsumables;
         }
         else if(evoAnimal.feedCompleted < evoAnimal.feedRequired)
         {
            IDSData.feed += numConsumables;
            evoAnimal.feedCompleted += numConsumables;
         }
         this.m_data[feedType] -= numConsumables;
         if(evoAnimal.feedCompleted <= evoAnimal.feedRequired)
         {
            params = [evoAnimal.persistentDataKey,feedType,numConsumables,evoAnimal.getItemName()];
            TransactionManager.addTransaction(new TGenericTransaction("EvolutionService","feedAnimal",null,params));
            StatsManager.count(FEATURE_NAME,"feline_" + evoAnimal.getItemName(),"use_feed",feedType);
         }
         if(evoAnimal.feedRequired <= evoAnimal.feedCompleted)
         {
            if(Boolean(this.m_dialog) && this.m_dialog.isShowing())
            {
               this.m_dialog.close();
            }
            this.showEvolveChoiceDialog(evoAnimal);
         }
         else
         {
            feedItem = Global.farmGameSettingsManager.getFarmItemByName(evoAnimal.feedType);
            iconFilter = [new GlowFilter(16776960,1,8,8,20)];
            evoAnimal.displayStatus("+1 " + ZLocUtils.tk_pk_asTitle(feedItem.friendlyName),feedItem.iconUrl,iconFilter);
         }
         if(IDSData.feed > evoAnimal.feedRequired)
         {
            IDSData.feed = evoAnimal.feedRequired;
         }
         if(evoAnimal.feedCompleted < IDSData.feed)
         {
            evoAnimal.feedCompleted = IDSData.feed;
         }
         evoAnimal.setPersistentDataVolatile(IDSData,"EvolutionAnimal");
      }
      
      public function openCrate(crate:EvolutionAnimalCrate) : void
      {
         this.showEvolveChoiceDialog(null,crate);
      }
      
      private function openCrateCallback(result:Object) : void
      {
         var crateDialog:EvolutionShareDialog = null;
         var crateToRemove:EvolutionAnimalCrate = null;
         if(result["newAnimal"])
         {
            crateDialog = new EvolutionShareDialog(result["newAnimal"]);
            UI.displayPopup(crateDialog);
            if(result["callingAnimal"])
            {
               crateToRemove = this.getCrateByStorageKey(result["callingAnimal"]);
               if(crateToRemove)
               {
                  crateToRemove.onDelete();
               }
            }
            Global.player.addGift(result["newAnimal"]);
            Global.world.enterForcePlaceMode(result["newAnimal"]);
            StatsManager.count(FEATURE_NAME,"feline_crate","placement");
         }
      }
      
      private function shareFeed(e:GenericPopupEvent) : void
      {
         if(e.button == GenericPopup.ACCEPT)
         {
            this.postFeed(EVOLVE_ANIMAL_FEED);
         }
      }
      
      private function getAnimalByStorageKey(storageKey:String) : EvolutionAnimal
      {
         var evoAnimal:EvolutionAnimal = null;
         var result:EvolutionAnimal = null;
         if(storageKey)
         {
            for each(evoAnimal in Global.world.getObjectsByClass(EvolutionAnimal))
            {
               if(evoAnimal.persistentDataKey == storageKey)
               {
                  result = evoAnimal;
                  break;
               }
            }
         }
         return result;
      }
      
      private function getCrateByStorageKey(storageKey:String) : EvolutionAnimalCrate
      {
         var crate:EvolutionAnimalCrate = null;
         var result:EvolutionAnimalCrate = null;
         for each(crate in Global.world.getObjectsByClass(EvolutionAnimalCrate))
         {
            if(crate.persistentDataKey == storageKey)
            {
               result = crate;
               break;
            }
         }
         return result;
      }
      
      public function getHowDoesThisWorkAssets() : Array
      {
         return this.m_howDoesThisWork;
      }
      
      public function showHowDoesThisWork() : void
      {
         TutorialUI.displayEvolutionTutorialWindow(this.getHowDoesThisWorkAssets());
      }
      
      public function showEvolutionDialog(animal:EvolutionAnimal) : void
      {
         this.m_dialog = new EvolutionDialog(this.m_dialogAsset,animal);
         StatsManager.count(FEATURE_NAME,"feline_" + animal.getItemName(),"look_inside","open");
         UI.displayPopup(this.m_dialog);
      }
      
      public function askForFeed(feedName:String) : void
      {
         MFSRequestManager.getInstance().makeAskItemsRequest(FEATURE_NAME,feedName);
      }
      
      public function openCraftShop() : void
      {
         var dialog:* = undefined;
         var dialogClassName:String = "Widgets.Windows.Crafting.CraftshopWindow";
         var dialogClass:Class = getDefinitionByName(dialogClassName) as Class;
         var craftshops:Array = Global.world.getObjectsByCode("4z");
         if(craftshops.length > 0)
         {
            dialog = new dialogClass(craftshops[0]);
            UI.displayPopup(dialog,true,dialogClassName,true);
            StatsManager.count(FEATURE_NAME,"feline_","go_to_crafting","click");
         }
         else
         {
            craftshops = Global.world.getObjectsByCode("4Z");
            if(craftshops.length > 0)
            {
               dialog = new dialogClass(craftshops[0]);
               UI.displayPopup(dialog,true,dialogClassName,true);
               StatsManager.count(FEATURE_NAME,"feline_","go_to_crafting","click");
            }
            else
            {
               UI.displayMessage("Place a Craft Shop on this farm in order to craft food!");
            }
         }
      }
      
      public function beginCompleteNowFlow(animal:EvolutionAnimal) : void
      {
         if(!animal.isElderAnimal() && !animal.startedCompletNowFlow)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs",EVOLVE_ANIMAL_COMPLETE_NOW_PROMPT,{
               "cashQuantity":animal.calculateCompleteNowCost(),
               "item":ZLocUtils.tk_pk(animal.getItemFriendlyName())
            }),GenericPopup.TYPE_ACCEPTCANCEL,animal.onCompleteNowAccept,"",true);
         }
      }
      
      public function buyFeed(feed:String, amount:int = 1) : void
      {
         var params:Array = null;
         var feedItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(feed);
         if(Global.player.canBuyCash(feedItem.cash * amount))
         {
            Global.player.cash -= feedItem.cash * amount;
            if(!this.m_data)
            {
               this.initializeFeatureDataVolatile();
            }
            params = [feed,amount];
            TransactionManager.addTransaction(new TGenericTransaction("EvolutionService","buyFeed",null,params));
            if(this.m_data[feed])
            {
               this.m_data[feed] += amount;
            }
            else
            {
               this.m_data[feed] = amount;
            }
         }
      }
      
      public function getCrate() : FarmItem
      {
         return this.m_crate;
      }
      
      public function getfeedAmount(feedType:String) : int
      {
         var result:int = 0;
         if(Boolean(this.m_data) && Boolean(this.m_data[feedType]))
         {
            result = int(this.m_data[feedType]);
         }
         return result;
      }
      
      public function buyCrate() : void
      {
         if(Global.player.buyFarmItem(this.m_crate,Currency.CASH,1,false,true,false))
         {
            TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,null);
         }
      }
      
      public function getAnimalEvolveOptions(animal:EvolutionAnimal) : Array
      {
         var result:Array = null;
         var i:int = 0;
         if(this.m_animalsInfo[animal.getItemName()])
         {
            result = new Array();
            i = 0;
            while(this.m_animalsInfo[animal.getItemName()]["option_" + i])
            {
               result.push(this.m_animalsInfo[animal.getItemName()]["option_" + i]);
               i++;
            }
         }
         return result;
      }
      
      public function evolveToNextLevelFromCrate(crate:EvolutionAnimalCrate, chosenAnimal:String) : void
      {
         var IDSData:Object = crate.getPersistentData("EvolutionAnimalCrate");
         if(IDSData == null)
         {
            IDSData = new Object();
         }
         crate.setPersistentDataVolatile(IDSData,"EvolutionAnimalCrate");
         var params:Array = [crate.persistentDataKey,chosenAnimal];
         TransactionManager.addTransaction(new TGenericTransaction("EvolutionService","openCrate",this.openCrateCallback,params));
         StatsManager.count(FEATURE_NAME,"feline_crate","choose_animal",chosenAnimal);
      }
      
      public function evolveToNextLevelFromCompleteNow(animal:EvolutionAnimal, chosenAnimal:String) : void
      {
         var params:Array = [animal.getItemName(),animal.persistentDataKey,animal.feedType,chosenAnimal,animal.history];
         TransactionManager.addTransaction(new TGenericTransaction("EvolutionService","completeNow",this.evolveAnimalCallback,params));
         StatsManager.count(FEATURE_NAME,"feline_" + animal.getItemName(),"choose_animal",chosenAnimal);
      }
      
      public function evolveToNextLevel(animal:EvolutionAnimal, chosenAnimal:String) : void
      {
         var params:Array = [animal.getItemName(),animal.persistentDataKey,animal.feedType,chosenAnimal,animal.history];
         TransactionManager.addTransaction(new TGenericTransaction("EvolutionService","evolveAnimal",this.evolveAnimalCallback,params));
         StatsManager.count(FEATURE_NAME,"feline_" + animal.getItemName(),"choose_animal",chosenAnimal);
      }
      
      private function evolveAnimalCallback(result:Object) : void
      {
         var evoAnimal:EvolutionAnimal = null;
         var newAnimal:EvolutionAnimalItem = null;
         var crateDialog:EvolutionShareDialog = null;
         var history:Array = null;
         if(result["oldAnimalStorageKey"])
         {
            evoAnimal = this.getAnimalByStorageKey(result["oldAnimalStorageKey"]);
            if(result[EVOLUTION_EVOLVE])
            {
               if(!result[EVOLUTION_ELDER])
               {
                  crateDialog = new EvolutionShareDialog(result["newAnimal"],false,evoAnimal.getItemFriendlyName());
                  UI.displayPopup(crateDialog);
               }
               if(evoAnimal)
               {
                  evoAnimal.onDelete();
               }
               newAnimal = Global.farmGameSettingsManager.getFarmItemByName(result["newAnimal"]) as EvolutionAnimalItem;
               if(newAnimal)
               {
                  Global.player.addGift(result["newAnimal"]);
                  history = result["history"];
                  Global.world.enterForcePlaceMode(newAnimal.name,false,0,true,true,history);
               }
            }
         }
      }
      
      public function showEvolveChoiceDialog(animal:EvolutionAnimal, crate:EvolutionAnimalCrate = null, isCompletNow:int = 0) : void
      {
         var dialog:EvolutionChoiceDialog = null;
         dialog = new EvolutionChoiceDialog(animal,crate,isCompletNow);
         UI.displayPopup(dialog);
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
