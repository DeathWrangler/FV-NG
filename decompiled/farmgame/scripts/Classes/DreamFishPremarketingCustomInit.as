package Classes
{
   import Managers.DreamFishPremarketingManager;
   import Managers.FeatureMessagingManager;
   import flash.events.Event;
   
   public class DreamFishPremarketingCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function DreamFishPremarketingCustomInit(xml:XML)
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
         if(DreamFishPremarketingManager.instance(this.m_featureName))
         {
            DreamFishPremarketingManager.instance(this.m_featureName).showMainUI();
         }
      }
   }
}

