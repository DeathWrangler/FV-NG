package Classes
{
   import Managers.ChoiceDrivenManager;
   import Managers.FeatureMessagingManager;
   
   public class ChoiceDrivenCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function ChoiceDrivenCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,ChoiceDrivenManager.getInstance(this.m_featureName).showUI);
      }
   }
}

