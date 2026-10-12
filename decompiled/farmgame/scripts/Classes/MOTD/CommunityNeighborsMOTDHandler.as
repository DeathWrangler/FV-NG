package Classes.MOTD
{
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   
   public class CommunityNeighborsMOTDHandler extends BaseDialogMOTDHandler
   {
      
      protected static const MOTD_DIALOG_NAME_NORMAL:String = "MotdCommunityNeighbors";
      
      public function CommunityNeighborsMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         FarmStatsManager.count("community_neighbors","motd","click");
         MFSRequestManager.getInstance().displayR2AddNeighborWindow("FVfriends_coming_soon");
      }
   }
}

