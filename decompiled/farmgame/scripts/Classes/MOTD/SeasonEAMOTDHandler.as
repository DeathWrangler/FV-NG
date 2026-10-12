package Classes.MOTD
{
   import Managers.WorldSeasonsManager;
   
   public class SeasonEAMOTDHandler extends SeasonMOTDHandler
   {
      
      protected static const ACCESS_TYPE:String = "earlyAccess";
      
      public function SeasonEAMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD,ACCESS_TYPE);
      }
      
      override public function execute() : void
      {
         WorldSeasonsManager.getInstance().showGrantMOTDForSeason(m_expansionData.worldId,seasonId,loadNextSeason);
         super.execute();
      }
   }
}

