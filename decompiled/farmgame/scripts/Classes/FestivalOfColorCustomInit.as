package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.FestivalOfColorManager;
   import flash.events.Event;
   
   public class FestivalOfColorCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function FestivalOfColorCustomInit(xml:XML)
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
         FestivalOfColorManager.getInstance().showHUDWindow();
      }
   }
}

