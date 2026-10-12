package Classes
{
   import Managers.FarmRunQuestManager;
   import Managers.FeatureMessagingManager;
   
   public class FarmRunQuestsCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function FarmRunQuestsCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,FarmRunQuestManager.getInstance().handleHUDClick);
      }
   }
}

