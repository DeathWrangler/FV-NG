package Managers
{
   import Classes.Managers.HUDTutorialManager;
   import Classes.MapResource;
   import Display.*;
   import MyLife.Events.GlobalEventManager;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FarmWindowWithTutorial;
   import Widgets.Windows.FeaturePackagesBuyWindow;
   import Widgets.Windows.FestivalOfColorHudWindow;
   import Widgets.Windows.FestivalOfColorWindow;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class FestivalOfColorManager extends BaseFeatureManager
   {
      
      private static const FEATURE_NAME:String = "festivalOfColor";
      
      private static const OPTION_PROGRESS:String = "progress";
      
      private static const FIELD_PROGRESS:String = "progress";
      
      private static const MAGIC_COLOR_COST:Number = 1;
      
      public static const TUTORIAL_FLAG_1:String = FEATURE_NAME + "_1";
      
      public static const TUTORIAL_FLAG_2:String = FEATURE_NAME + "_2";
      
      public static const TUTORIAL_FLAG_3:String = FEATURE_NAME + "_3";
      
      public static const TUTORIAL_FLAG_SUFFIX:String = "_Tutorial";
      
      public static const STATS_COUNTER:String = "FestivalOfColor";
      
      public static const STATS_KINGDOM_ANIMAL_UI:String = "animal_ui";
      
      private static const EVENT_SPECIAL_TILE_UNLOCK:String = "festivalOfColorTut";
      
      private var m_buildingTypes:Dictionary = new Dictionary();
      
      private var m_bucketPackages:Array = null;
      
      private var m_animalsByType:Array = null;
      
      public function FestivalOfColorManager(featureName:String, featureConfig:XML = null)
      {
         super(featureName,featureConfig);
         this.m_buildingTypes["xin_bigbuildable"] = 0;
         this.m_buildingTypes["bldg_xin_harvestbuildable"] = 1;
         this.m_buildingTypes["xin_elitehorses"] = 2;
      }
      
      public static function getInstance(featureName:String = "festivalOfColor") : FestivalOfColorManager
      {
         return BaseFeatureManager.getInstanceOfClass(featureName,FestivalOfColorManager) as FestivalOfColorManager;
      }
      
      public function isEnabled() : Boolean
      {
         return true;
      }
      
      public function isCommunityGoalsActive() : Boolean
      {
         return CommunityGoalsManager.getInstance().getActiveTask() != null;
      }
      
      public function getItemsByType(index:Number) : Array
      {
         var itemXML:XML = null;
         var type:Number = NaN;
         if(!this.m_animalsByType)
         {
            this.m_animalsByType = [];
            for each(itemXML in featureConfig.items.item)
            {
               type = Number(this.m_buildingTypes[itemXML.@type.toString()]);
               if(!this.m_animalsByType[type])
               {
                  this.m_animalsByType[type] = [];
               }
               this.m_animalsByType[type].push(itemXML.@name.toString());
            }
         }
         return this.m_animalsByType[index];
      }
      
      public function getBuildingNameForAnimal(animalName:String) : String
      {
         var type:Number = NaN;
         var animals:Array = null;
         var buildingName:String = null;
         var result:String = "";
         if(animalName)
         {
            for(buildingName in this.m_buildingTypes)
            {
               type = Number(this.m_buildingTypes[buildingName]);
               animals = this.getItemsByType(type);
               if(animals)
               {
                  if(animals.indexOf(animalName) > -1)
                  {
                     result = buildingName;
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      public function showAnimalWindow(obj:MapResource, showTutorialOnly:Boolean = false) : void
      {
         UI.displayPopup(new FestivalOfColorWindow(obj,showTutorialOnly),!showTutorialOnly);
      }
      
      public function showHUDWindow(showTutorialOnly:Boolean = false) : void
      {
         UI.displayPopup(new FestivalOfColorHudWindow(showTutorialOnly),!showTutorialOnly);
      }
      
      public function conditionallyTriggerTutorialOne() : void
      {
         if(!Global.player.getSeenFlag(TUTORIAL_FLAG_1 + TUTORIAL_FLAG_SUFFIX))
         {
            this.showHUDWindow();
         }
      }
      
      public function conditionallyTriggerTutorialTwo() : void
      {
         if(!Global.player.getSeenFlag(TUTORIAL_FLAG_2 + TUTORIAL_FLAG_SUFFIX))
         {
            this.showAnimalWindow(null,true);
         }
      }
      
      public function initEventListener() : void
      {
         GlobalEventManager.getInstance().addEventListener(EVENT_SPECIAL_TILE_UNLOCK,this.conditionallyTriggerTutorialThree);
      }
      
      public function deleteEventListener() : void
      {
         GlobalEventManager.getInstance().removeEventListener(EVENT_SPECIAL_TILE_UNLOCK,this.conditionallyTriggerTutorialThree);
      }
      
      public function conditionallyTriggerTutorialThree(e:Event = null) : void
      {
         if(!Global.player.getSeenFlag(TUTORIAL_FLAG_3 + TUTORIAL_FLAG_SUFFIX))
         {
            UI.displayPopup(new FarmWindowWithTutorial(TUTORIAL_FLAG_3,"assets/dialogs/India/FV_xin_RangDeFTUE3_2015.swf",3,true,false,true),false);
            HUDTutorialManager.instance.initializeBottomHud(TUTORIAL_FLAG_3);
         }
      }
      
      public function registerAnimalByCode(code:String) : void
      {
         var animals:Array = null;
         var type:Number = NaN;
         var name:String = Global.farmGameSettingsManager.getFarmItemNameByCode(code);
         if(name)
         {
            for each(type in this.m_buildingTypes)
            {
               animals = this.getItemsByType(type);
               if(animals.indexOf(name) > -1)
               {
                  this.updateProgressByType(code,type);
               }
            }
         }
      }
      
      public function getProgressByType(type:Number) : Number
      {
         var animalsByType:Object = null;
         var result:Number = 0;
         var animals:Object = FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,OPTION_PROGRESS);
         if(animals)
         {
            animalsByType = animals[type];
            if(animalsByType)
            {
               result = Number(animalsByType.progress);
            }
         }
         return result;
      }
      
      public function getTotalAnimalsOfType(type:Number) : Number
      {
         var animals:Array = this.getItemsByType(type);
         return animals.length;
      }
      
      public function allAnimalsUnlocked() : Boolean
      {
         var type:Number = NaN;
         var result:Boolean = false;
         var animals:Object = this.getProgressFeatureOption();
         if(animals)
         {
            for each(type in this.m_buildingTypes)
            {
               if(animals[type])
               {
                  result = animals[type].progress == this.getTotalAnimalsOfType(type);
                  if(!result)
                  {
                     break;
                  }
               }
            }
         }
         return result;
      }
      
      private function getProgressFeatureOption() : Object
      {
         return FeatureOptionsManager.getInstance().getFeatureOption(FEATURE_NAME,OPTION_PROGRESS);
      }
      
      private function setProgressFeatureOption(progArray:Object) : void
      {
         FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,OPTION_PROGRESS,progArray);
      }
      
      private function updateProgressByType(code:String, type:Number) : void
      {
         var animals:Object = this.getProgressFeatureOption();
         var showFTUE:Boolean = false;
         if(!animals)
         {
            animals = {};
            showFTUE = true;
         }
         if(!animals[type])
         {
            animals[type] = {};
         }
         if(!animals[type][code])
         {
            animals[type][code] = true;
            if(animals[type][FIELD_PROGRESS] == null)
            {
               animals[type][FIELD_PROGRESS] = 0;
            }
            ++animals[type][FIELD_PROGRESS];
         }
         this.setProgressFeatureOption(animals);
         if(showFTUE)
         {
            this.conditionallyTriggerTutorialTwo();
         }
      }
      
      private function getPurchasePackages() : Array
      {
         var itemXML:XML = null;
         if(!this.m_bucketPackages)
         {
            this.m_bucketPackages = new Array();
            for each(itemXML in featureConfig.bucketPackages.bucketPackage)
            {
               this.m_bucketPackages.push(itemXML.@name.toString());
            }
         }
         return this.m_bucketPackages;
      }
      
      private function getBuyWindowAssetPath() : String
      {
         return featureConfig.UI.buyDialog.@path.toString();
      }
      
      private function getFeatureCurrencyCode() : String
      {
         var name:String = featureConfig.currency.@name.toString();
         return Global.farmGameSettingsManager.getFarmItemCodeByName(name);
      }
      
      public function getColorPackCount() : int
      {
         return int(FeatureOptionsInventoryManager.getInstance().getCount(this.getFeatureCurrencyCode()));
      }
      
      public function deductColorPack() : void
      {
         FeatureOptionsInventoryManager.getInstance().removeCount(this.getFeatureCurrencyCode(),MAGIC_COLOR_COST);
      }
      
      public function openBuyWindow(owner:FarmWindow) : void
      {
         UI.displayPopup(new FeaturePackagesBuyWindow(this.getBuyWindowAssetPath(),FEATURE_NAME,this.getPurchasePackages(),owner),false);
      }
   }
}

