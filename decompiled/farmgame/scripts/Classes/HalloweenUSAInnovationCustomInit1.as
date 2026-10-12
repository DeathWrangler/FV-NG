package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import flash.events.Event;
   
   public class HalloweenUSAInnovationCustomInit1 implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function HalloweenUSAInnovationCustomInit1(xml:XML)
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
         HalloweenInnovationManager.getInstance().showMainUI();
      }
   }
}

