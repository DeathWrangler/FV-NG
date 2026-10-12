package Classes
{
   import Managers.BringBackWinterManager;
   import Managers.FeatureMessagingManager;
   
   public class BringBackWinterCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function BringBackWinterCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
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
         if(BringBackWinterManager.getInstance(this.m_featureName).isFeatureEnd())
         {
            featureDef.icon.arrowKey = "Redeem";
         }
         if(motdSeen)
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,BringBackWinterManager.getInstance(this.m_featureName).handleHUDClick);
         }
      }
   }
}

