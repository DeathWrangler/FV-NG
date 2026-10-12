package Classes
{
   import Managers.AntiqueMuseumV2Manager;
   import Managers.FeatureMessagingManager;
   
   public class AntiqueMuseumV2CustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function AntiqueMuseumV2CustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,AntiqueMuseumV2Manager.getInstance("AntiqueMuseumV2").showMainWindow);
      }
   }
}

