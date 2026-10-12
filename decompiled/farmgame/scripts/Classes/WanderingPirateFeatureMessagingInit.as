package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.WanderingPirateManager;
   
   public class WanderingPirateFeatureMessagingInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function WanderingPirateFeatureMessagingInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         if(Global.player.isMotdSeenFlagSet(this.m_motdName))
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,WanderingPirateManager.getInstance().showUI);
         }
      }
   }
}

