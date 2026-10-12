package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.XBOPremarketingManager;
   import flash.events.Event;
   
   public class XBOPremarketingCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function XBOPremarketingCustomInit(xml:XML)
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
         XBOPremarketingManager.instance(this.m_featureName).showMainUI();
      }
   }
}

