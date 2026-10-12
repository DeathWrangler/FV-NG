package Classes.FeatureComponents
{
   import Classes.FeatureBuilding;
   import Classes.SocialRaffle.SocialRaffleConstants;
   import Classes.SocialRaffle.SocialRaffleDataView;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.SocialRaffleManager;
   import flash.events.MouseEvent;
   
   public class SocialRaffleContextMenuFManager extends ContextMenuFManager
   {
      
      private var m_loadingUI:GenericPopup = null;
      
      public function SocialRaffleContextMenuFManager(owner:FeatureBuilding)
      {
         super(owner);
      }
      
      override public function appendMenuItems(menuItems:Array) : Array
      {
         var dataView:SocialRaffleDataView = SocialRaffleManager.getInstance().raffleDataView;
         if(dataView != null)
         {
            menuItems = super.appendMenuItems(menuItems);
         }
         return menuItems;
      }
      
      override protected function checkMenuItemGate(menuItem:Object) : Boolean
      {
         var friendAcceptsForToday:Array = null;
         var result:Boolean = super.checkMenuItemGate(menuItem);
         if(menuItem.action == MENU_ACTION_ASK_FOR_CREW)
         {
            friendAcceptsForToday = SocialRaffleManager.getInstance().raffleDataView.friendAcceptsForToday;
            if(friendAcceptsForToday.length >= SocialRaffleConstants.FRIENDS_PER_DAY)
            {
               result = false;
            }
         }
         return result;
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
                  this.m_loadingUI = new GenericPopup(ZLocUtils.t("Dialogs","socialrafflebuilding_Loading"),GenericPopup.TYPE_MODAL,null,GenericPopup.GENERIC_ASSET,"",false,false,true);
                  UI.displayPopup(this.m_loadingUI,false);
                  SocialRaffleManager.getInstance().reloadData(this.onDataLoaded);
                  FarmStatsManager.count(owner.getItem().name + "_feature","context_menu","context_lookinside");
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      private function onDataLoaded() : void
      {
         if(this.m_loadingUI != null)
         {
            this.m_loadingUI.close();
            this.m_loadingUI = null;
         }
         owner.displayStorageDialog();
      }
   }
}

