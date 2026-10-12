package Classes
{
   import Display.ContextMenuItem;
   import Engine.Managers.StatsManager;
   import Managers.AOEManager;
   import Managers.FestivalOfColorManager;
   import flash.events.MouseEvent;
   
   public class FestivalOfColorAnimal extends Animal
   {
      
      protected static const OPEN_MAGICCOLORWINDOW:String = "openMagicColorWindow";
      
      public function FestivalOfColorAnimal(animalType:String = null)
      {
         super(animalType);
      }
      
      private function populateMagicColorMenu() : void
      {
         m_menuItems.push({
            "label":"Apply Color",
            "action":OPEN_MAGICCOLORWINDOW
         });
      }
      
      private function openMagicColorWindow() : void
      {
         FestivalOfColorManager.getInstance().showAnimalWindow(this);
         var animalName:String = this.getItemName();
         var buildingName:String = FestivalOfColorManager.getInstance().getBuildingNameForAnimal(animalName);
         StatsManager.count(FestivalOfColorManager.STATS_COUNTER,FestivalOfColorManager.STATS_KINGDOM_ANIMAL_UI,animalName,buildingName);
      }
      
      override public function postProcessImageName(name:String) : String
      {
         if(AOEManager.getInstance().hasAOELicense(this) && AOEManager.getInstance().getAoeResourceIdsAffecting(this).length > 0)
         {
            return name;
         }
         return super.postProcessImageName(name);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(m_wanderingObject != this)
            {
               generateWanderTime();
               switch(item.action)
               {
                  case OPEN_MAGICCOLORWINDOW:
                     this.openMagicColorWindow();
                     break;
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
      
      override protected function populateAltGraphicMenu() : void
      {
         this.populateMagicColorMenu();
      }
   }
}

