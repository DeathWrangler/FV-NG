package Classes
{
   import Display.TutorialUI;
   import Managers.FeatureMessagingManager;
   
   public class IrrigationFeatureMessagingInit implements IFeatureMessagingCustomInit
   {
      
      private var m_windowSrc:String;
      
      private var m_itemToPlace:String;
      
      private var m_featureName:String;
      
      public function IrrigationFeatureMessagingInit(configXml:XML)
      {
         super();
         if(configXml.hasOwnProperty("@name"))
         {
            this.m_featureName = configXml.@name.toString();
         }
         if(configXml.hasOwnProperty("customInit"))
         {
            if(configXml.customInit.hasOwnProperty("@itemToPlace"))
            {
               this.m_itemToPlace = configXml.customInit.@itemToPlace.toString();
            }
            if(configXml.customInit.hasOwnProperty("@windowSrc"))
            {
               this.m_windowSrc = configXml.customInit.@windowSrc.toString();
            }
         }
      }
      
      public function initialize() : void
      {
         if(Boolean(this.m_featureName) && Boolean(this.m_itemToPlace) && Boolean(this.m_windowSrc))
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.onClickHud);
         }
      }
      
      private function onClickHud() : void
      {
         TutorialUI.showIrrigationFTUEWindow(this.m_windowSrc,this.m_itemToPlace);
      }
   }
}

