package Classes
{
   import Display.ContextMenuItem;
   import Display.EvolutionShareDialog;
   import Display.UI;
   import Managers.EvolutionManager;
   import Managers.FreezeManager;
   import flash.events.MouseEvent;
   
   public class EvolutionAnimalCrate extends Decoration
   {
      
      private var m_disableMenu:Boolean;
      
      private var m_hasShownShareFeed:Boolean;
      
      public function EvolutionAnimalCrate(itemName:String = null)
      {
         super(itemName);
         this.m_disableMenu = false;
      }
      
      override protected function getMenuItems() : Array
      {
         var menuItems:Array = super.getMenuItems();
         menuItems.push({
            "label":"Open Crate",
            "action":OPEN_CRATE
         });
         return menuItems;
      }
      
      override public function onDelete() : void
      {
         detach();
      }
      
      public function toggleMenu(visible:Boolean) : void
      {
         this.m_disableMenu = visible;
      }
      
      override public function showMenu() : void
      {
         var menuItems:Array = null;
         if(this.m_disableMenu)
         {
            menuItems = this.getMenuItems();
            if(!hasValidId())
            {
               showObjectBusy();
            }
            else if(!FreezeManager.isAnythingFrozen())
            {
               UI.displayMenu(menuItems,this.onMenuClick);
            }
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.m_disableMenu = true;
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         var crateDialog:EvolutionShareDialog = null;
         super.onFinishPlace(transactionResult);
         if(!Global.player.getSeenFlag(EvolutionManager.EVOLVE_ANIMAL_HOWDOESTHISWORK))
         {
            EvolutionManager.instance.showHowDoesThisWork();
            Global.player.setSeenFlag(EvolutionManager.EVOLVE_ANIMAL_HOWDOESTHISWORK);
         }
         if(!this.m_hasShownShareFeed)
         {
            crateDialog = new EvolutionShareDialog("",false,"",true);
            UI.displayPopup(crateDialog);
            this.m_disableMenu = true;
            this.m_hasShownShareFeed = true;
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case OPEN_CRATE:
                  EvolutionManager.instance.openCrate(this);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
   }
}

