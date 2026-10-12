package Display.FriendBar
{
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Windows.CrossPromo.EmpiresAlliesCrossPromoWindow;
   import flash.events.MouseEvent;
   
   public class NPCSlotEmpiresAlliesLaunch extends NPCSlot
   {
      
      public function NPCSlotEmpiresAlliesLaunch(slotIndex:int)
      {
         super(slotIndex);
         FarmStatsManager.count("empire_xpromo","neighbor_bar_card","impressions");
      }
      
      override public function onClickFriend(event:MouseEvent) : void
      {
         if(Global.worldManager.getVisiting() != uid.toString() && Boolean(m_sprite))
         {
            UI.displayPopup(new EmpiresAlliesCrossPromoWindow(),true,"EmpiresAlliesPromo",true);
         }
         FarmStatsManager.count("empire_xpromo","neighbor_bar_card","clicks");
      }
   }
}

