package Classes
{
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.SubscriberWalletManager;
   import flash.events.Event;
   
   public class SubscriberWalletCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function SubscriberWalletCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.showUI);
      }
      
      public function showUI(event:Event = null) : void
      {
         SubscriberWalletManager.getInstance().showMainUI();
         FarmStatsManager.count("subscriber_wallet","HUD","click");
      }
   }
}

