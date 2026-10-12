package Classes.Growable
{
   import Classes.FeatureComponents.FeatureManager;
   import Classes.ZItem.IGrowableItem;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class GrowableItemDelegate
   {
      
      private static var DEFAULT_STAGE_NAME:String = "default";
      
      private var m_staticData:Object = null;
      
      private var m_item:IGrowableItem;
      
      public function GrowableItemDelegate(baseItem:IGrowableItem)
      {
         super();
         this.m_item = baseItem;
      }
      
      public function get staticData() : Object
      {
         var featureData:BaseDataSource = null;
         var stageDataArray:Array = null;
         var stageDataSource:BaseDataSource = null;
         var stageObject:Object = null;
         var staticData:XML = null;
         var stages:XMLList = null;
         var stageData:XML = null;
         var consumable:XMLList = null;
         var maxConsumables:XMLList = null;
         var mastery:String = null;
         var stage:Object = null;
         if(!this.m_staticData)
         {
            this.m_staticData = new Object();
            this.m_staticData.stages = new Object();
            this.m_staticData.growthConsumable = null;
            this.m_staticData.growthMastery = null;
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               featureData = this.m_item.farmItem.getFeatureDataByName(FeatureManager.GROWABLE_CONTEST_FEATURE_NAME);
               if(featureData)
               {
                  if(featureData.hasProperty("growthConsumable"))
                  {
                     this.m_staticData.growthConsumable = featureData.getString("growthConsumable");
                  }
                  if(featureData.hasProperty("maxConsumables"))
                  {
                     this.m_staticData.maxConsumables = featureData.getInt("maxConsumables");
                  }
                  if(featureData.hasProperty("growthMastery"))
                  {
                     this.m_staticData.growthMastery = featureData.getBoolean("growthMastery");
                  }
                  stageDataArray = featureData.getArray("stages","stage");
                  for each(stageDataSource in stageDataArray)
                  {
                     stageObject = new Object();
                     stageObject.name = stageDataSource.getString("name");
                     if(stageObject.name.length == 0)
                     {
                        stageObject.name = DEFAULT_STAGE_NAME;
                     }
                     stageObject.image = stageDataSource.getString("image");
                     stageObject.nextStage = stageDataSource.getString("nextStage");
                     stageObject.consumables = stageDataSource.getInt("consumables");
                     stageObject.mastery = stageDataSource.getInt("mastery");
                     this.m_staticData.stages[stageObject.name] = stageObject;
                  }
               }
            }
            else
            {
               staticData = this.m_item.farmItem.getFeatureXMLByName("Growable");
               if(staticData)
               {
                  if(staticData.hasOwnProperty("growthConsumable"))
                  {
                     consumable = staticData.growthConsumable;
                     this.m_staticData.growthConsumable = consumable.children()[0].toXMLString();
                  }
                  if(staticData.hasOwnProperty("maxConsumables"))
                  {
                     maxConsumables = staticData.maxConsumables;
                     this.m_staticData.maxConsumables = parseInt(maxConsumables.children()[0].toXMLString());
                  }
                  if(staticData.hasOwnProperty("growthMastery"))
                  {
                     mastery = staticData.growthMastery.children()[0].toXMLString();
                     this.m_staticData.growthMastery = mastery == "true";
                  }
                  stages = staticData.child("stages");
                  for each(stageData in stages.stage)
                  {
                     stage = new Object();
                     stage.name = stageData.attribute("name").toXMLString() as String;
                     if(!stage.name || stage.name == "")
                     {
                        stage.name = DEFAULT_STAGE_NAME;
                     }
                     stage.image = stageData.attribute("image").toXMLString() as String;
                     stage.nextStage = stageData.attribute("nextStage").toXMLString() as String;
                     stage.consumables = int(stageData.attribute("consumables").toXMLString());
                     stage.mastery = int(stageData.attribute("mastery").toXMLString() as String);
                     this.m_staticData.stages[stage.name] = stage;
                  }
               }
            }
         }
         return this.m_staticData;
      }
   }
}

