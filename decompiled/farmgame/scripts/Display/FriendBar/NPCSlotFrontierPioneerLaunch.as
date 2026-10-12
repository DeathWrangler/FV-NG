package Display.FriendBar
{
   import Classes.Constants.CrossPromoConstants;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Windows.CrossPromo.FrontierPioneerCrossPromoWindow;
   import flash.events.MouseEvent;
   
   public class NPCSlotFrontierPioneerLaunch extends NPCSlot
   {
      
      public function NPCSlotFrontierPioneerLaunch(slotIndex:int)
      {
         super(slotIndex);
         FarmStatsManager.count("pioneertrail_xpromo","neighbor_bar_card","impressions");
      }
      
      override public function onClickFriend(event:MouseEvent) : void
      {
         if(Global.worldManager.getVisiting() != uid.toString() && Boolean(m_sprite))
         {
            Global.player.setSeenFlag(CrossPromoConstants.FRONTIERPIONEER_SEEN_TOASTER);
            UI.displayPopup(new FrontierPioneerCrossPromoWindow(),true,"FrontierPioneerPromo",true);
         }
         FarmStatsManager.count("pioneertrail_xpromo","neighbor_bar_card","clicks");
      }
   }
}

