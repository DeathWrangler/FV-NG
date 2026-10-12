package Managers
{
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Events.DynamicObjectEvent;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingContentsWindow;
   import flash.events.EventDispatcher;
   
   public class FeatureCraftingManager extends EventDispatcher
   {
      
      private static var s_instance:FeatureCraftingManager;
      
      public static const FEATURE_NAME:String = "FeatureCrafting";
      
      public static const SERVICE_NAME:String = "FeatureCraftingService";
      
      public static const EVENT_INIT:String = "featureCraftingInit";
      
      public static const EVENT_LEVEL_CHANGE:String = "featureCraftingLevelChange";
      
      public static const EVENT_NEW_ORDER_BOARD:String = "featureCraftingNewOrderBoard";
      
      private var m_dataLoaded:Boolean;
      
      private var m_systems:Object;
      
      private var m_buildingsToCraftingSystems:Object;
      
      private var m_worldType:String;
      
      public function FeatureCraftingManager(enforcer:SingletonEnforcer)
      {
         super();
         GlobalEngine.assert(enforcer != null,"[FeatureCraftingManager] :: Use instance()");
         this.m_dataLoaded = false;
         this.m_systems = {};
         this.m_buildingsToCraftingSystems = {};
      }
      
      public static function get instance() : FeatureCraftingManager
      {
         if(!s_instance)
         {
            s_instance = new FeatureCraftingManager(new SingletonEnforcer());
         }
         return s_instance;
      }
      
      public function get initialized() : Boolean
      {
         return this.m_dataLoaded;
      }
      
      public function init() : void
      {
         var craftingSystems:XMLList = null;
         var craftingSystemXml:XML = null;
         var system:FeatureCraftingSystem = null;
         var systemName:String = null;
         var featureConfig:XML = Global.farmGameSettingsManager.getFeatureXML(FEATURE_NAME);
         if(featureConfig)
         {
            craftingSystems = featureConfig.craftingSystem;
            for each(craftingSystemXml in craftingSystems)
            {
               system = new FeatureCraftingSystem(craftingSystemXml);
               systemName = system.name;
               this.m_systems[systemName] = system;
               if(craftingSystemXml.hasOwnProperty("@buildingName"))
               {
                  this.m_buildingsToCraftingSystems[craftingSystemXml.@buildingName.toString()] = systemName;
               }
            }
         }
         this.m_dataLoaded = true;
         Global.ui.getActionMenu().refresh();
         dispatchEvent(new DynamicObjectEvent(FeatureCraftingManager.EVENT_INIT));
      }
      
      public function showUI(systemName:String, worldType:String = "") : void
      {
         var system:FeatureCraftingSystem = null;
         this.m_worldType = worldType;
         if(this.m_dataLoaded)
         {
            system = this.getSystem(systemName);
            if(system)
            {
               FeatureCraftingContentsWindow.display(system);
            }
         }
      }
      
      public function get worldType() : String
      {
         return this.m_worldType;
      }
      
      public function showBuildingUI(buildingName:String) : void
      {
         var systemName:String = this.getSystemNameForBuilding(buildingName);
         if(systemName)
         {
            FeatureCraftingManager.instance.showUI(systemName);
         }
      }
      
      public function getSystem(systemName:String) : FeatureCraftingSystem
      {
         return this.m_systems[systemName];
      }
      
      public function getRecipeForMasterySign(recipeName:String) : FeatureCraftingRecipe
      {
         var result:FeatureCraftingRecipe = null;
         var featureCraftingSystem:FeatureCraftingSystem = null;
         var craftingRecipe:FeatureCraftingRecipe = null;
         for each(featureCraftingSystem in this.m_systems)
         {
            craftingRecipe = featureCraftingSystem.getRecipe(recipeName);
            if(craftingRecipe != null)
            {
               result = craftingRecipe;
               break;
            }
         }
         return result;
      }
      
      public function getImageUrlForRecipe(recipeName:String) : String
      {
         var result:String = null;
         var featureCraftingSystem:FeatureCraftingSystem = null;
         for each(featureCraftingSystem in this.m_systems)
         {
            if(featureCraftingSystem.getRecipe(recipeName) != null)
            {
               result = featureCraftingSystem.getRecipe(recipeName).iconUrl;
               break;
            }
         }
         return result;
      }
      
      public function getSystemForBuilding(buildingName:String) : FeatureCraftingSystem
      {
         return this.getSystem(this.m_buildingsToCraftingSystems[buildingName]);
      }
      
      public function getSystemNameForBuilding(buildingName:String) : String
      {
         return this.m_buildingsToCraftingSystems[buildingName];
      }
      
      public function arePrerequisitesMet(systemName:String) : Boolean
      {
         var system:FeatureCraftingSystem = null;
         var result:Boolean = false;
         if(this.m_dataLoaded)
         {
            system = this.getSystem(systemName);
            if(system)
            {
               result = system.arePrerequisitesMet();
            }
         }
         return result;
      }
      
      public function adminResetUserData(systemName:String) : void
      {
         var data:Object = null;
         var system:FeatureCraftingSystem = this.getSystem(systemName);
         if(system)
         {
            data = system.createFeatureData();
            FeatureOptionsManager.getInstance().setFeatureOption(FEATURE_NAME,systemName,data);
            this.init();
         }
      }
      
      public function adminSetPoints(systemName:String, points:int) : Boolean
      {
         var result:Boolean = false;
         var system:FeatureCraftingSystem = this.getSystem(systemName);
         if(system)
         {
            system.adminSetPoints(points);
         }
         return result;
      }
      
      public function adminSetHarvestCount(systemName:String, recipeName:String, harvestCount:int) : Boolean
      {
         var recipes:Array = null;
         var recipe:FeatureCraftingRecipe = null;
         var result:Boolean = false;
         var system:FeatureCraftingSystem = this.getSystem(systemName);
         if(system)
         {
            recipes = system.getRecipes();
            if(recipes)
            {
               for each(recipe in recipes)
               {
                  if(recipe.name == recipeName)
                  {
                     recipe.adminSetMasteryHarvests(harvestCount);
                     result = true;
                     break;
                  }
               }
            }
         }
         return result;
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
