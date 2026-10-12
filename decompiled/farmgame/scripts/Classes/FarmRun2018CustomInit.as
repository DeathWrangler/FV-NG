package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.FarmRun2018Manager;
   
   public class FarmRun2018CustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function FarmRun2018CustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,FarmRun2018Manager.getInstance().showMainUI);
      }
   }
}

