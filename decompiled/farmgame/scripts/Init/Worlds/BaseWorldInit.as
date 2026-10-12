package Init.Worlds
{
   import Classes.ZItem.ExpansionData;
   
   public class BaseWorldInit
   {
      
      protected var m_config:Object = null;
      
      protected var m_expansionData:ExpansionData = null;
      
      public function BaseWorldInit()
      {
         super();
      }
      
      public function onEnterWorld(resultData:Object) : void
      {
         this.m_config = Global.worldSettingsManager.getConfigByWorld(Global.worldManager.currentWorldType);
         this.m_expansionData = Global.farmGameSettingsManager.getExpansionData(Global.worldManager.currentWorldType);
         if(Global.player.avatar)
         {
            Global.player.avatar.getStateMachine().removeAllStates();
            Global.world.addPlayerAvatar(Global.player.avatar);
            Global.selectedAvatar = Global.player.avatar;
         }
         this.setupMusic();
         this.setupHud();
         this.setupUI();
         Global.hud.conditionallyRefreshHUD(true);
      }
      
      public function resyncToBackendData(resultData:Object) : void
      {
      }
      
      public function setupHud() : void
      {
         Global.hud.currentWorldCurrencyAmount = Global.player.currentWorldCurrencyTotal;
         Global.hud.refreshIconVisibility();
      }
      
      public function setupUI() : void
      {
      }
      
      public function onLeaveWorld(destIsVisiting:Boolean) : void
      {
         if(Global.worldManager.previousWorldType != Global.worldManager.currentWorldType)
         {
            Global.world.stopPreviousWorldMusic();
         }
         Global.player.setSeenSessionFlag(Global.worldManager.currentWorldType + "AOESTATECHANGE_ADDEDTOQUEUE",false);
         Global.ui.getActionMenu().clearTempTopRightItems();
      }
      
      protected function setupMusic() : void
      {
         Global.world.syncMusicToPlayerOptions(true);
         Global.world.syncSoundsToPlayerOptions();
      }
   }
}

