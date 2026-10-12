package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.StencilManager;
   import flash.events.Event;
   
   public class StencilCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function StencilCustomInit(xml:XML)
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
         StencilManager.instance(this.m_featureName).showMainUI();
      }
   }
}

