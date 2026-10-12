package Classes
{
   import Managers.ExternalInterfaceFeatureManager;
   import Managers.FeatureMessagingManager;
   
   public class ExternalInterfaceFeatureMessagingInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      private var m_actionName:String;
      
      public function ExternalInterfaceFeatureMessagingInit(configXml:XML)
      {
         super();
         if(configXml.hasOwnProperty("@name"))
         {
            this.m_featureName = configXml.@name.toString();
         }
         if(configXml.hasOwnProperty("customInit") && configXml.customInit.hasOwnProperty("@action"))
         {
            this.m_actionName = configXml.customInit.@action.toString();
         }
      }
      
      public function initialize() : void
      {
         if(Boolean(this.m_featureName) && Boolean(this.m_actionName))
         {
            FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,ExternalInterfaceFeatureManager.getInstance().wrapCall(this.m_actionName));
         }
      }
   }
}

