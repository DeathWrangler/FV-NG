package Transactions
{
   import Display.ActionMultiButton;
   import Engine.Managers.TransactionManager;
   import Managers.StorageExpandManager;
   import Managers.WorldManager;
   import Managers.WorldSeasonsManager;
   
   public class TWorldLoad extends TBaseWorldLoad
   {
      
      private var m_worldType:String;
      
      private var m_shouldCreateWorld:Boolean;
      
      private var m_shouldFreezeFarm:Boolean;
      
      private var m_nextSeasonUnlock:Boolean;
      
      public function TWorldLoad(worldType:String, manager:WorldManager, shouldCreateWorld:Boolean = false, shouldFreezeFarm:Boolean = true, isNextSeasonUnlock:Boolean = false)
      {
         super(manager);
         this.m_shouldCreateWorld = shouldCreateWorld;
         this.m_worldType = worldType;
         this.m_shouldFreezeFarm = shouldFreezeFarm;
         this.m_nextSeasonUnlock = isNextSeasonUnlock;
      }
      
      protected function get worldType() : String
      {
         return this.m_worldType;
      }
      
      protected function get shouldCreateWorld() : Boolean
      {
         return this.m_shouldCreateWorld;
      }
      
      protected function get shouldFreezeFarm() : Boolean
      {
         return this.m_shouldFreezeFarm;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.loadOwnWorld",this.m_worldType,this.m_shouldCreateWorld,this.m_shouldFreezeFarm,this.m_nextSeasonUnlock);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var bottomLeftActionButton:ActionMultiButton = null;
         if(this.m_nextSeasonUnlock)
         {
            WorldSeasonsManager.getInstance().nextSeasonUnlock = true;
            WorldSeasonsManager.getInstance().hideSeasonLoading();
         }
         if(Boolean(result) && Boolean(result.user) && Boolean(result.user.currentWorldType))
         {
            Global.player.initFeatureCredits(result.user.player.featureCredits);
            Global.player.setFeatureCreditsForWorld(result.user.currentWorldType);
            if(result.user.worldSummaryData)
            {
               Global.worldManager.setWorldSummaryData(result.user.worldSummaryData);
            }
         }
         TransactionManager.addTransaction(new TRefreshGifts(),true);
         if(WorldSeasonsManager.getInstance().hasSeasons(this.worldType) && Boolean(result.currentSeason))
         {
            WorldSeasonsManager.getInstance().setSeasonForUser(this.worldType,result.currentSeason);
         }
         super.onComplete(result);
         if(Boolean(result) && Boolean(result.storageExpansionBuildingId))
         {
            StorageExpandManager.getInstance().updateStorageExpansionData(result.storageExpansionBuildingId);
         }
         WorldSeasonsManager.hideNextSeasonLoadingScreen();
         if(this.m_nextSeasonUnlock)
         {
            bottomLeftActionButton = Global.ui.getActionMenu().getBottomLeftButton();
            bottomLeftActionButton.updateItems(true);
            WorldSeasonsManager.getInstance().showUnlockMOTDForSeason(result.user.currentWorldType,result.currentSeason,null);
         }
         if(Boolean(result) && Boolean(result.seasonData) && Boolean(result.seasonData["nextSeasonAvailable"]))
         {
            WorldSeasonsManager.getInstance().showNextSeasonLoadingScreen(this.worldType,int(result.seasonData["seasonData"]["seasonId"]));
         }
      }
   }
}

