package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.FarmRunV7Manager;
   
   public class FarmRunV7CustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function FarmRunV7CustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,FarmRunV7Manager.getInstance().showMainUI);
      }
   }
}

