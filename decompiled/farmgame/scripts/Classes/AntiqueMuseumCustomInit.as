package Classes
{
   import Managers.AntiqueMuseumManager;
   import Managers.FeatureMessagingManager;
   
   public class AntiqueMuseumCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function AntiqueMuseumCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,AntiqueMuseumManager.getInstance("AntiqueMuseum").showMainWindow);
      }
   }
}

