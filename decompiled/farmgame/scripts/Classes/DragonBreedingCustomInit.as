package Classes
{
   import Managers.DragonBreedingManager;
   import Managers.FeatureMessagingManager;
   
   public class DragonBreedingCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function DragonBreedingCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.openUI);
      }
      
      private function openUI() : void
      {
         DragonBreedingManager.getInstance(this.m_featureName).showEyrieAndOpenWindow(this.m_featureName);
      }
   }
}

