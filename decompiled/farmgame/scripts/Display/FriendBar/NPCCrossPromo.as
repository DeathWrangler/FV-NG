package Display.FriendBar
{
   import Display.UI;
   import Managers.FarmStatsManager;
   import Widgets.Windows.CrossPromo.CrossPromoWindow;
   import flash.events.MouseEvent;
   
   public class NPCCrossPromo extends NPCSlot
   {
      
      protected var m_crossPromoName:String = null;
      
      protected var m_promoGameID:String = null;
      
      public function NPCCrossPromo(slotIndex:int, crossPromoName:String, promoGameId:String = null)
      {
         super(slotIndex);
         var npcIndex:int = crossPromoName.indexOf("NPC");
         if(npcIndex > -1)
         {
            crossPromoName = crossPromoName.slice(0,npcIndex);
         }
         this.m_crossPromoName = crossPromoName;
         this.m_promoGameID = promoGameId;
         FarmStatsManager.count("neighbor_bar_card","xpromo","view",this.promoGameID,this.m_crossPromoName);
      }
      
      private static function dialogFactory(crossPromoName:String) : CrossPromoWindow
      {
         return null;
      }
      
      override public function onClickFriend(event:MouseEvent) : void
      {
         if(Global.worldManager.getVisiting() != uid.toString() && Boolean(m_sprite))
         {
            UI.displayPopup(dialogFactory(this.m_crossPromoName));
         }
         FarmStatsManager.count("neighbor_bar_card","xpromo","click",this.promoGameID,this.m_crossPromoName);
      }
      
      protected function get promoGameID() : String
      {
         return this.m_promoGameID;
      }
   }
}

