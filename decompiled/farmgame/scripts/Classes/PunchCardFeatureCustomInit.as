package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.PunchCardFeatureManager;
   
   public class PunchCardFeatureCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function PunchCardFeatureCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,PunchCardFeatureManager.getInstance().showMainWindow);
      }
   }
}

