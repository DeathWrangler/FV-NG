package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.BobBerryManager;
   
   public class BobBerryMessagingInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function BobBerryMessagingInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,BobBerryManager.getInstance(this.m_featureName).showUI);
      }
   }
}

