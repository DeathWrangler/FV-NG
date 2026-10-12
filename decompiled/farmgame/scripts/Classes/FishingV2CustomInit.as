package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.FishingV2Manager;
   
   public class FishingV2CustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function FishingV2CustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,FishingV2Manager.getInstance().showMainUI);
      }
   }
}

