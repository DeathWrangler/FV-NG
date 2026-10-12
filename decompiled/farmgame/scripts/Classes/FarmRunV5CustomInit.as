package Classes
{
   import Managers.FeatureMessagingManager;
   import Managers.OrderBoard.FarmRunV5Manager;
   
   public class FarmRunV5CustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_motdName:String;
      
      public function FarmRunV5CustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
         this.m_motdName = xml.motd;
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,FarmRunV5Manager.getInstance().showMainUI);
      }
   }
}

