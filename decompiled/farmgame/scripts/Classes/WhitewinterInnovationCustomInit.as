package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.WhitewinterInnovationManager;
   import flash.events.Event;
   
   public class WhitewinterInnovationCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function WhitewinterInnovationCustomInit(xml:XML)
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
         WhitewinterInnovationManager.getInstance().showMainUI();
      }
   }
}

