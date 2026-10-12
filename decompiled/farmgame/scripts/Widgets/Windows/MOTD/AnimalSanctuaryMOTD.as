package Widgets.Windows.MOTD
{
   import Display.UI;
   import Managers.AnimalSanctuaryManager;
   import Managers.FarmStatsManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class AnimalSanctuaryMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private static const FEATURE_NAME:String = "AnimalSanctuary";
      
      public function AnimalSanctuaryMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         UI.stopPopups(true);
         FarmStatsManager.count("MOTD","impressions","MOTD_ANIMAL_SANCTUARY");
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         AnimalSanctuaryManager.getInstance().showMainUI();
         FarmStatsManager.count("MOTD","click","MOTD_ANIMAL_SANCTUARY");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
      }
   }
}

