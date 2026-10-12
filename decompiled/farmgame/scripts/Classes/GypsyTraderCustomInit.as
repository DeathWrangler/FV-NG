package Classes
{
   import Managers.FeatureMessagingManager;
   
   public class GypsyTraderCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function GypsyTraderCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         if(Global.player.isMotdSeenFlagSet(this.m_motdName))
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,GypsyTrader.getInstance(this.m_featureName).showUI);
         }
      }
   }
}

