package Classes
{
   import Managers.DollarBundlesManager;
   import Managers.FeatureMessagingManager;
   
   public class DollarBundlesCustomeInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function DollarBundlesCustomeInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         var dollarBundlesManager:DollarBundlesManager = DollarBundlesManager.getInstance();
         if(dollarBundlesManager)
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,dollarBundlesManager.handleHUDClick);
         }
      }
   }
}

