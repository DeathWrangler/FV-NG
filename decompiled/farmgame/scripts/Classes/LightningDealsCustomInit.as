package Classes
{
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.LightningDealManager;
   import flash.events.Event;
   
   public class LightningDealsCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function LightningDealsCustomInit(xml:XML)
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
         var featureDef:FeatureMessagingDefinition = FeatureMessagingManager.getInstance().getFeatureDefinition(LightningDealManager.FEATURE_NAME);
         if(Boolean(featureDef) && featureDef.passesPrereqs())
         {
            LightningDealManager.getInstance().showMainUI();
            FarmStatsManager.count("lightning_deals","HUD","click");
         }
         else
         {
            featureDef.updateIconVisibility();
         }
      }
   }
}

