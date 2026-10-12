package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.PetAcademyManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PetAcademyMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private static const FEATURE_NAME:String = "AnimalUniversity2019_V2";
      
      public function PetAcademyMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         UI.stopPopups(true);
         FarmStatsManager.count("MOTD","impressions","MOTD_ANIMAL_ACADEMY");
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         PetAcademyManager.getInstance(FEATURE_NAME).handleHUDClick();
         FarmStatsManager.count("MOTD","click","MOTD_ANIMAL_ACADEMY");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
      }
   }
}

