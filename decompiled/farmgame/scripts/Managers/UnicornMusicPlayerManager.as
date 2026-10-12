package Managers
{
   import Classes.Constants.QuestConstants;
   import Engine.Managers.TransactionManager;
   import Transactions.TRefreshMusicPlayerHudIcon;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Managers.QuestManager;
   import flash.external.ExternalInterface;
   
   public class UnicornMusicPlayerManager
   {
      
      private static var s_instance:UnicornMusicPlayerManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      private static const HUD_ICON_NAME:String = "MusicPlayer";
      
      private static const HUD_ICON_INTRO_URL:String = "assets/hud/hud_icon_queue/unicorn/uni_stage1_intro.swf";
      
      private static const SEEN_SESSION_FLAG_MUSIC_HEARD:String = "fv_uni_music_heard";
      
      public function UnicornMusicPlayerManager()
      {
         super();
      }
      
      public static function getInstance() : UnicornMusicPlayerManager
      {
         if(null == s_instance)
         {
            m_canInstantiate = true;
            s_instance = new UnicornMusicPlayerManager();
            m_canInstantiate = false;
         }
         return s_instance;
      }
      
      public function addMusicPlayerHudIcon() : void
      {
         var iconUrl:String = null;
         if(!Global.player.getSeenSessionFlag(SEEN_SESSION_FLAG_MUSIC_HEARD))
         {
            iconUrl = HUD_ICON_INTRO_URL;
         }
         Global.hud.rightSideIconQueue.addIconToTop(HUD_ICON_NAME,iconUrl);
      }
      
      public function removeMusicPlayerHudIcon() : void
      {
         Global.hud.rightSideIconQueue.removeIconByName(HUD_ICON_NAME);
      }
      
      public function addRelatedEventListeners() : void
      {
         QuestManager.getInstance().addEventListener(QuestConstants.USER_EVENT_MUSICPLAYER_REFRESH,this.onMusicPlayerRefresh);
         QuestManager.getInstance().addEventListener(QuestConstants.USER_EVENT_MUSICPLAYER_UNLOCK,this.onMusicPlayerUnlock);
      }
      
      private function refreshHudIcon(event:QuestEvent) : void
      {
         TransactionManager.addTransaction(new TRefreshMusicPlayerHudIcon(),true);
      }
      
      private function onMusicPlayerUnlock(event:QuestEvent) : void
      {
         this.refreshHudIcon(event);
      }
      
      private function onMusicPlayerRefresh(event:QuestEvent) : void
      {
         this.refreshHudIcon(event);
      }
      
      public function showMusicPlayerPopUp() : void
      {
         ExternalInterface.call("theFarmOverlay.showMusicPlayer");
         if(!Global.player.getSeenSessionFlag(SEEN_SESSION_FLAG_MUSIC_HEARD))
         {
            Global.player.setSeenSessionFlag(SEEN_SESSION_FLAG_MUSIC_HEARD);
            this.addMusicPlayerHudIcon();
         }
      }
   }
}

