package Classes.MOTD
{
   import Managers.WorldSeasonsManager;
   
   public class SeasonGAMOTDHandler extends SeasonMOTDHandler
   {
      
      protected static const ACCESS_TYPE:String = "generalAccess";
      
      public function SeasonGAMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD,ACCESS_TYPE);
      }
      
      override public function execute() : void
      {
         WorldSeasonsManager.getInstance().showUnlockMOTDForSeason(m_expansionData.worldId,seasonId,loadNextSeason);
         super.execute();
      }
   }
}

