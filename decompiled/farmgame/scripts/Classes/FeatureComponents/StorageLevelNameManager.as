package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class StorageLevelNameManager extends FeatureManager implements INamingComponent
   {
      
      private var m_prefix:String = "";
      
      public function StorageLevelNameManager(owner:FeatureBuilding)
      {
         var featureData:BaseDataSource = null;
         var featuresXML:XMLList = null;
         var NamingFeature:XMLList = null;
         super(owner);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            featureData = owner.getFarmItem().getFeatureDataByName(FeatureManager.NAMING_FEATURE_NAME);
            if(Boolean(featureData) && featureData.hasProperty("prefix"))
            {
               this.m_prefix = featureData.getString("prefix");
            }
         }
         else
         {
            featuresXML = owner.getFarmItem().getFeaturesXML();
            NamingFeature = featuresXML.(@name == FeatureManager.NAMING_FEATURE_NAME);
            if(NamingFeature != null)
            {
               if(NamingFeature.hasOwnProperty("prefix"))
               {
                  this.m_prefix = NamingFeature.prefix;
               }
            }
         }
      }
      
      public function getName() : String
      {
         var result:String = "";
         if(m_owner.expand)
         {
            result = "Items:" + this.m_prefix + "_Level" + m_owner.expand.storageLevel + "_friendlyName";
         }
         else
         {
            result = "Items:" + this.m_prefix + "_Level" + m_owner.storageLevel + "_friendlyName";
         }
         return result;
      }
   }
}

