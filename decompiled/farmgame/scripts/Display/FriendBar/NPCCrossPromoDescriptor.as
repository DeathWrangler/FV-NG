package Display.FriendBar
{
   import Classes.CrossPromoDescriptor;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Managers.FarmStatsManager;
   import Widgets.Windows.CrossPromo.CrossPromoDescriptorWindow;
   import flash.events.MouseEvent;
   
   public class NPCCrossPromoDescriptor extends NPCSlot
   {
      
      protected var m_crossPromoDescriptor:CrossPromoDescriptor = null;
      
      public function NPCCrossPromoDescriptor(slotIndex:int, crossPromoDescriptor:CrossPromoDescriptor)
      {
         super(slotIndex);
         this.m_crossPromoDescriptor = crossPromoDescriptor;
         FarmStatsManager.count("neighbor_bar_card","xpromo","view",this.m_crossPromoDescriptor.gameID,this.m_crossPromoDescriptor.promoName);
      }
      
      override public function onClickFriend(event:MouseEvent) : void
      {
         var playUrl:String = null;
         if(Boolean(Global.worldManager.getVisiting() != uid.toString()) && Boolean(m_sprite) && !this.m_crossPromoDescriptor.shouldRedirectOnClick)
         {
            UI.displayPopup(new CrossPromoDescriptorWindow(this.m_crossPromoDescriptor),true,this.m_crossPromoDescriptor.promoName + "_dialog",true);
         }
         else
         {
            playUrl = this.m_crossPromoDescriptor.npcPlayUrl != null ? this.m_crossPromoDescriptor.npcPlayUrl : this.m_crossPromoDescriptor.playUrl;
            GlobalEngine.socialNetwork.redirect(playUrl,null,this.m_crossPromoDescriptor.targetWindow,false);
         }
         FarmStatsManager.count("neighbor_bar_card","xpromo","click",this.m_crossPromoDescriptor.gameID,this.m_crossPromoDescriptor.promoName);
      }
      
      override protected function loadNPCFriendImage() : void
      {
         LoadingManager.load(Global.getAssetURL(this.m_crossPromoDescriptor.npcFriendImage),onNPCFriendImageLoad);
      }
   }
}

