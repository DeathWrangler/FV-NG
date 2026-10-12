package Widgets.Windows.Market
{
   import Managers.FarmGameSettingsManager;
   import Widgets.Menu.MenuItem;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class MarketMiniVIPWindow extends MarketMiniWindow
   {
      
      public function MarketMiniVIPWindow(itemNames:Array, hideCloseButton:Boolean = false, checkVisible:Boolean = false)
      {
         super(itemNames,hideCloseButton,checkVisible);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(Boolean(m_window) && "VIPOnlyBanner_mc" in m_window)
         {
            (m_window.VIPOnlyBanner_mc as MovieClip).visible = true;
         }
      }
      
      override protected function refreshItems() : void
      {
         var menuItem:MenuItem = null;
         super.refreshItems();
         m_mainMenu.visible = true;
         var mainMenuItems:Array = getMainMenuItems();
         for each(menuItem in mainMenuItems)
         {
            if(menuItem.data == FarmGameSettingsManager.TYPE_VIP)
            {
               m_mainMenu.setTabVisibility(menuItem.data as String,true);
            }
            else
            {
               m_mainMenu.setTabVisibility(menuItem.data as String,false);
            }
         }
      }
   }
}

