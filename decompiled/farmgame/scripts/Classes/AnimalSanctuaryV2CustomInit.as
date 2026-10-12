package Classes
{
   import Managers.AnimalSanctuaryV2Manager;
   import Managers.FeatureMessagingManager;
   
   public class AnimalSanctuaryV2CustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function AnimalSanctuaryV2CustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,AnimalSanctuaryV2Manager.getInstance().showMainUI);
      }
   }
}

