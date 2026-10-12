package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Events.FarmGameWorldEvent;
   import Managers.MystreeReskinManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MystreeReskinMOTDWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public function MystreeReskinMOTDWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
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
         var itemName:String = null;
         var giftItem:FarmItem = null;
         var canPlace:Boolean = false;
         Global.worldManager.removeEventListener(FarmGameWorldEvent.WORLD_LOADED,this.onWorldLoaded);
         if(m_currentMOTD.freeGift)
         {
            itemName = m_currentMOTD.freeGift;
            giftItem = Global.farmGameSettingsManager.getFarmItemByCode("2oeg");
            canPlace = !giftItem.checkItemLimit(false);
            if(canPlace)
            {
               Global.world.enterForcePlaceMode(itemName,false,0,true,true,null,true,this.onPlace);
            }
            else
            {
               this.onPlace();
            }
         }
      }
      
      private function onPlace(event:Event = null) : void
      {
         MystreeReskinManager.getInstance(m_currentMOTD.featureName).handleHUDClick();
      }
   }
}

