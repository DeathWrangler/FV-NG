package Classes
{
   import Managers.ConsumableBundleManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import flash.events.Event;
   
   public class ConsumableBundleCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String = "consumable_bundle";
      
      public function ConsumableBundleCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.showUI);
         FarmStatsManager.count("HUD","impressions","consumable_bundle");
      }
      
      public function showUI(event:Event = null) : void
      {
         ConsumableBundleManager.getInstance(this.m_featureName).handleHUDClick();
         FarmStatsManager.count("HUD","click","consumable_bundle");
      }
   }
}

