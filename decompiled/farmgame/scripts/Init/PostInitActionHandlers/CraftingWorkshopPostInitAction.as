package Init.PostInitActionHandlers
{
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.*;
   import Classes.crafting.RecipeItem;
   import DataSources.BaseDataSource;
   import Managers.Crafting.CraftingConstants;
   import Managers.FarmGameSettingsManager;
   
   public class CraftingWorkshopPostInitAction extends AbstractPostInitAction
   {
      
      public static const MAX_POSSIBLE_OVEN_SLOTS:int = 6;
      
      public static const CRAFT_VERSION_CRAFTSHOP:String = "2";
      
      public function CraftingWorkshopPostInitAction(callback:Function = null)
      {
         super(callback);
      }
      
      private static function showCraftingIndicator(craftingworkshop:FeatureBuilding, craftType:String, numMaxOvenSlots:int) : void
      {
         var featureData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var arrowIndicatorFeature:XMLList = null;
         var recipes:Array = null;
         var recipeQueue:Array = null;
         var recipeCount:Number = NaN;
         var readyRecipes:int = 0;
         var lastReadyRecipe:int = 0;
         var i:int = 0;
         var usableStations:Number = NaN;
         var openStations:Number = NaN;
         var unexpandedStations:Number = NaN;
         var recipe:RecipeItem = null;
         var craftingRecipeReadyIndicator:CraftingRecipeReadyIndicatorFManager = craftingworkshop.arrowIndicator as CraftingRecipeReadyIndicatorFManager;
         var experimentName:String = "";
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = craftingworkshop.getFarmItem().getFeatureDataByName(FeatureManager.ARROW_INDICATOR_MENU_FEATURE_NAME);
            if(featureData)
            {
               experimentName = featureData.getString("experiment");
            }
         }
         else
         {
            featuresXML = craftingworkshop.getFarmItem().getFeaturesXML();
            arrowIndicatorFeature = featuresXML.(@name == FeatureManager.ARROW_INDICATOR_MENU_FEATURE_NAME);
            if(arrowIndicatorFeature != null)
            {
               experimentName = String(arrowIndicatorFeature.@experiment);
            }
         }
         if(experimentName != "" && Boolean(Global.experimentManager.getExperimentVariant(experimentName)))
         {
            recipes = new Array();
            recipeQueue = Global.player.craftingState.getRecipeQueueForCraftType(craftType);
            for(recipeCount = 0; recipeCount < recipeQueue.length; recipeCount++)
            {
               if((recipeQueue[recipeCount] as RecipeItem).worldType == Global.worldManager.currentWorldType)
               {
                  recipes.push(recipeQueue[recipeCount]);
               }
            }
            readyRecipes = 0;
            lastReadyRecipe = 0;
            for(i = 0; i < recipes.length; i++)
            {
               recipe = recipes[i];
               if(recipe.serverStartTS > 0 && recipe.realTimeRemaining <= 0)
               {
                  readyRecipes++;
                  lastReadyRecipe = i;
               }
            }
            usableStations = craftingworkshop.storageLevel;
            openStations = usableStations - recipes.length;
            unexpandedStations = numMaxOvenSlots - usableStations;
            if(readyRecipes == 1)
            {
               craftingRecipeReadyIndicator.changeStateIcon(StateIndicatorFManager.DEFAULT_STATE,recipes[lastReadyRecipe].image);
               craftingRecipeReadyIndicator.show();
            }
            else if(readyRecipes > 1)
            {
               craftingRecipeReadyIndicator.changeStateIcon(CraftingRecipeReadyIndicatorFManager.INDICATOR_STATE_PLURAL,recipes[lastReadyRecipe].image);
               craftingRecipeReadyIndicator.show(CraftingRecipeReadyIndicatorFManager.INDICATOR_STATE_PLURAL);
            }
            else if(openStations >= 1)
            {
               craftingRecipeReadyIndicator.show(CraftingRecipeReadyIndicatorFManager.INDICATOR_STATE_STATION_EMPTY);
            }
            else if(unexpandedStations >= 1)
            {
               craftingRecipeReadyIndicator.show(CraftingRecipeReadyIndicatorFManager.INDICATOR_STATE_STATION_EXPAND);
            }
         }
      }
      
      override public function execute() : void
      {
         var itemNames:Array = null;
         var buildingIndex:int = 0;
         var craftingworkshop:FeatureBuilding = null;
         var craftingSiloExpandArrow:CraftingSiloIndicatorFManager = null;
         var buildingList:Array = Global.world.getObjectsByClass(FeatureBuilding);
         if(buildingList.length)
         {
            itemNames = Global.craftConfigSettings.getItemNamesWithCraftVersion(CRAFT_VERSION_CRAFTSHOP);
            for(buildingIndex = 0; buildingIndex < buildingList.length; buildingIndex++)
            {
               craftingworkshop = buildingList[buildingIndex];
               if(itemNames.indexOf(craftingworkshop.getItem().name) != -1)
               {
                  showCraftingIndicator(craftingworkshop,craftingworkshop.getItem().craftType,MAX_POSSIBLE_OVEN_SLOTS);
               }
               else if(craftingworkshop.assetKey == CraftingConstants.BUILDINGNAME_CRAFTINGSILO)
               {
                  craftingSiloExpandArrow = craftingworkshop.arrowIndicator as CraftingSiloIndicatorFManager;
                  craftingSiloExpandArrow.show();
               }
            }
         }
         m_isFinished = true;
      }
   }
}

