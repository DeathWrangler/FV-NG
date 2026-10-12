package Widgets.Windows
{
   import Classes.StorageBuilding;
   import Display.UI;
   import flash.events.Event;
   
   public class ContingencyBuildableDialog extends MultiStageBuildingDialog
   {
      
      private var m_motdData:Object;
      
      public function ContingencyBuildableDialog(building:StorageBuilding)
      {
         super(building);
      }
      
      override protected function howDoesThisWorkClick(event:Event) : void
      {
         UI.displayPopup(new ContingencyBuildableTutorialWindow(m_dialogTemplateXML),false);
      }
   }
}

