package Widgets.Windows.MOTD
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Events.FarmGameWorldEvent;
   import Managers.MystreeNurseryManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MystreeWidgetMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public function MystreeWidgetMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var currentFarm:String = Global.worldManager.currentWorldType;
         if(currentFarm == WorldsConstants.WORLD_ID_STORYBOOK)
         {
            if(m_accept_bt)
            {
               m_accept_bt.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"MOTD_MYSTREE_CHECK_IT");
            }
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         var currentFarm:String = Global.worldManager.currentWorldType;
         if(currentFarm != WorldsConstants.WORLD_ID_STORYBOOK)
         {
            Global.worldManager.swapFarm(WorldsConstants.WORLD_ID_STORYBOOK);
         }
         if(Global.worldManager.isWorldLoading)
         {
            Global.worldManager.addEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         }
         else
         {
            this.onWorldLoaded();
         }
      }
      
      private function onWorldLoaded(event:Event = null) : void
      {
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         MystreeNurseryManager.getInstance().handleHUDClick();
      }
   }
}

