package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.MoneyTree2017Manager;
   import flash.events.Event;
   
   public class MoneyTree2017CustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function MoneyTree2017CustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.handleHUDClick);
      }
      
      public function handleHUDClick(event:Event = null) : void
      {
         MoneyTree2017Manager.getInstance(this.m_featureName).showMainUI();
      }
   }
}

