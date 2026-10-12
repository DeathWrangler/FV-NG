package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Building;
   import Classes.FeedTroughBuilding;
   import Classes.VisitorManager;
   import Classes.util.ZLocUtils;
   
   public class AMFillFeedTrough extends AMBuildingInteraction
   {
      
      public function AMFillFeedTrough(avatar:FarmAvatar, feedTroughBuilding:FeedTroughBuilding)
      {
         super(avatar,feedTroughBuilding as Building);
      }
      
      override protected function doAction() : void
      {
         VisitorManager.getInstance().onNeighborFillFeedTrough(m_targetBuilding as FeedTroughBuilding);
      }
      
      override protected function getProgressText() : String
      {
         return ZLocUtils.t("FarmGame","Filling");
      }
   }
}

