package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.RegionAchievementManager;
   
   public class RegionAchievementFeatureMessagingInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function RegionAchievementFeatureMessagingInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,RegionAchievementManager.getInstance(this.m_featureName).showUI);
      }
   }
}

