package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Display.ContextMenuItem;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import flash.events.MouseEvent;
   
   public class CarnivalBoothContextMenuManager extends ContextMenuFManager
   {
      
      public function CarnivalBoothContextMenuManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MENU_ACTION_LOOKINSIDE:
                  CarnivalBoothWindow.launchCarnivalBooth();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
   }
}

