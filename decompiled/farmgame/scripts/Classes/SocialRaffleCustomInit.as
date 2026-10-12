package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.SocialRaffleManager;
   
   public class SocialRaffleCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function SocialRaffleCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         var motdSeenFlag:String = null;
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(this.m_featureName);
         var motdSeen:Boolean = true;
         if(featureDef.motd != null && featureDef.motd.length > 0)
         {
            motdSeenFlag = featureDef.motd;
            motdSeen = Global.player.isMotdSeenFlagSet(motdSeenFlag);
         }
         if(motdSeen)
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,SocialRaffleManager.getInstance().handleHUDClick);
         }
      }
   }
}

