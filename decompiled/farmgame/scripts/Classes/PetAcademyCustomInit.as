package Classes
{
   import Managers.FarmStatsManager;
   import Managers.FeatureMessagingManager;
   import Managers.PetAcademyManager;
   import flash.events.Event;
   
   public class PetAcademyCustomInit implements IFeatureMessagingCustomInit
   {
      
      private var m_featureName:String;
      
      public function PetAcademyCustomInit(xml:XML)
      {
         super();
         this.m_featureName = xml.attribute("name").toString();
      }
      
      public function initialize() : void
      {
         FeatureMessagingManager.getInstance().registerFeatureInitialized(this.m_featureName,this.showUI);
         FarmStatsManager.count("HUD","impressions","animal_academy");
      }
      
      public function showUI(event:Event = null) : void
      {
         PetAcademyManager.getInstance(this.m_featureName).handleHUDClick();
         FarmStatsManager.count("HUD","click","animal_academy");
      }
   }
}

