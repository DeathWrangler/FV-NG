package Display.FriendBar
{
   import Display.CityvilleLaunchPromoDialog;
   import Display.FarmDynamicDialog;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class NPCSlotCityvilleLaunch extends NPCSlot
   {
      
      public function NPCSlotCityvilleLaunch(slotIndex:int)
      {
         super(slotIndex);
         FarmStatsManager.count("city_xpromo","neighbor_bar_card","impressions");
      }
      
      override public function onClickFriend(event:MouseEvent) : void
      {
         var progressDialog:FarmDynamicDialog = null;
         if(Global.worldManager.getVisiting() != uid.toString() && Boolean(m_sprite))
         {
            m_sprite.hideToolTip();
            progressDialog = FarmDynamicDialog.createDialog("cityvilleLaunchPromo",CityvilleLaunchPromoDialog);
            progressDialog.addImport("cityvilleLaunchPromo",null);
            progressDialog.setup();
            progressDialog.show();
         }
         FarmStatsManager.count("city_xpromo","neighbor_bar_card","clicks");
      }
   }
}

