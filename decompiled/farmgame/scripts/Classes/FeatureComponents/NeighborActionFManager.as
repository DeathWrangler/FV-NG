package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.NeighborActions.BaseNeighborAction;
   import Classes.NeighborActions.HarvestFeatureBuildingNeighborAction;
   import Classes.NeighborActions.NeighborActionConstants;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class NeighborActionFManager extends FeatureManager implements INeighborActionComponent
   {
      
      private var m_type:String;
      
      private var m_key:String;
      
      private var m_limit:int;
      
      public function NeighborActionFManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var featureXML:XMLList = null;
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.NEIGHBOR_ACTION_FEATURE_NAME);
            if(featureData)
            {
               this.m_type = featureData.getString("type");
               this.m_key = featureData.getString("key");
               this.m_limit = featureData.getInt("limit");
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            featureXML = featuresXML.(@name == FeatureManager.NEIGHBOR_ACTION_FEATURE_NAME);
            this.m_type = String(featureXML.type);
            this.m_key = String(featureXML.key);
            this.m_limit = int(featureXML.limit);
         }
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get key() : String
      {
         return this.m_key;
      }
      
      public function get limit() : int
      {
         return this.m_limit;
      }
      
      public function getAction() : BaseNeighborAction
      {
         var action:BaseNeighborAction = null;
         switch(this.m_type)
         {
            case NeighborActionConstants.ACTION_TYPE_NEIGHBOR_HARVEST_FEATURE_BUILDING:
               action = new HarvestFeatureBuildingNeighborAction(m_owner as FeatureBuilding);
         }
         return action;
      }
   }
}

