package Classes.FeatureComponents
{
   import Classes.Constants.XMLKeys;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import DataSources.BaseDataSource;
   import Display.UI;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmGameSettingsManager;
   
   public class CraftingReadyTooltipFManager extends BuildingTooltipFManager implements IStateIndicatorComponent
   {
      
      public static const INDICATOR_STATE_READY:String = "ready";
      
      protected const INDICATOR_CHECK_INTERVAL_MS:Number = 5000;
      
      protected var m_nextCheckTimeMs:Number = 0;
      
      protected var m_item:FarmItem = null;
      
      protected var m_craftSkill:String;
      
      protected var m_craftSpecialization:String;
      
      protected var m_sessionSeenFlag:String;
      
      protected var m_featureFrequency:String;
      
      protected var m_featureInterval:int;
      
      protected var m_featureLimit:int;
      
      public function CraftingReadyTooltipFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var featureFrequencyData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var indicatorFeature:XMLList = null;
         var featureFrequency:XMLList = null;
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(featureName);
            if(featureData)
            {
               if(featureData.hasProperty("craftSkill"))
               {
                  this.m_craftSkill = featureData.getString("craftSkill");
               }
               if(featureData.hasProperty("craftSpecialization"))
               {
                  this.m_craftSpecialization = featureData.getString("craftSpecialization");
               }
               if(featureData.hasProperty("sessionSeenFlag"))
               {
                  this.m_sessionSeenFlag = featureData.getString("sessionSeenFlag");
               }
               featureFrequencyData = featureData.getData("featureFrequency");
               if(featureFrequencyData)
               {
                  this.m_featureFrequency = featureFrequencyData.getString("name");
                  this.m_featureInterval = featureFrequencyData.getInt("interval");
                  this.m_featureLimit = featureFrequencyData.getInt("limit");
               }
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            indicatorFeature = featuresXML.(@name == featureName);
            if(indicatorFeature != null)
            {
               if(indicatorFeature.hasOwnProperty("craftSkill"))
               {
                  this.m_craftSkill = indicatorFeature["craftSkill"];
               }
               if(indicatorFeature.hasOwnProperty("craftSpecialization"))
               {
                  this.m_craftSpecialization = indicatorFeature["craftSpecialization"];
               }
               if(indicatorFeature.hasOwnProperty("sessionSeenFlag"))
               {
                  this.m_sessionSeenFlag = indicatorFeature["sessionSeenFlag"];
               }
               featureFrequency = indicatorFeature.featureFrequency;
               if(featureFrequency != null)
               {
                  this.m_featureFrequency = featureFrequency[XMLKeys.ATTR_NAME];
                  this.m_featureInterval = parseInt(featureFrequency["interval"]);
                  this.m_featureLimit = parseInt(featureFrequency["limit"]);
               }
            }
         }
      }
      
      override public function get featuredItem() : FarmItem
      {
         return this.m_item;
      }
      
      override public function update() : void
      {
         var time:int = GlobalEngine.currentTime;
         if(time > this.m_nextCheckTimeMs && indicatorCurrentlyHidden && this.checkSeenFlag() && this.checkFeatureFrequency())
         {
            this.checkRequirements();
            this.m_nextCheckTimeMs = GlobalEngine.currentTime + this.INDICATOR_CHECK_INTERVAL_MS;
         }
      }
      
      public function checkFeatureFrequency() : Boolean
      {
         if(this.m_featureFrequency)
         {
            return Global.player.getIntervalActionCount(this.m_featureFrequency,this.m_featureInterval) < this.m_featureLimit;
         }
         return true;
      }
      
      public function checkSeenFlag() : Boolean
      {
         if(this.m_sessionSeenFlag)
         {
            return !Global.player.getSeenSessionFlag(this.m_sessionSeenFlag);
         }
         return true;
      }
      
      protected function checkRequirements() : void
      {
         var recipeData:Array = null;
         var len:int = 0;
         var j:int = 0;
         var recipeItem:RecipeItem = null;
         if(!UI.isShowingPopup())
         {
            this.m_item = null;
            recipeData = CraftingManager.getInstance().getRecipeData(this.m_craftSkill,this.m_craftSpecialization);
            len = int(recipeData.length);
            for(j = 0; j < len; j++)
            {
               if(recipeData.hasOwnProperty("" + j) && Boolean(recipeData[j]))
               {
                  recipeItem = Global.craftConfigSettings.getRecipeById(recipeData[j].recipeId);
                  if(!recipeItem.canMake)
                  {
                     break;
                  }
                  this.m_item = Global.farmGameSettingsManager.getFarmItemByName(recipeItem.name);
               }
            }
            if(this.m_item)
            {
               if(this.m_sessionSeenFlag)
               {
                  Global.player.setSeenSessionFlag(this.m_sessionSeenFlag);
               }
               if(this.m_featureFrequency)
               {
                  Global.player.incrementIntervalActionCount(this.m_featureFrequency,this.m_featureInterval,true);
               }
               show(INDICATOR_STATE_READY);
            }
         }
         else
         {
            this.m_item = null;
         }
      }
      
      override public function get lookInsideOnClick() : Boolean
      {
         return true;
      }
      
      override public function onClick() : void
      {
      }
   }
}

