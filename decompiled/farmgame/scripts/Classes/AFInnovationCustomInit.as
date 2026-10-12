package Classes
{
   import Managers.AFInnovationManager;
   import Managers.FeatureMessagingManager;
   import flash.events.Event;
   
   public class AFInnovationCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function AFInnovationCustomInit(xml:XML)
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
         AFInnovationManager.getInstance().showMainUI();
      }
   }
}

