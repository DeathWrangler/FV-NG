package Transactions.BreedingProjects
{
   import Transactions.TFarmTransaction;
   
   public class TGetBreedingLevelUpShareLink extends TFarmTransaction
   {
      
      private static const FEED_ICON_LEVEL_UP_PATH:String = "assets/newsfeed/breeding/";
      
      private static const FEED_ICON_LEVEL_UP_SUFFIX:String = "_newsfeed_levelup_";
      
      private static const BUNDLE_ID_SUFFIX:String = "_level_up";
      
      private var m_featureName:String = "";
      
      private var m_levelNumber:int;
      
      public function TGetBreedingLevelUpShareLink(featureName:String, levelNumber:int)
      {
         super();
         this.m_featureName = featureName;
         this.m_levelNumber = levelNumber;
      }
      
      override public function perform() : void
      {
         signedCall("AnimalBreedingService.getBreedingLevelUpShareLink",this.m_featureName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var bundleId:String = null;
         var imageUrl:String = null;
         var bundleData:Object = null;
         if(result.rewardLink)
         {
            bundleId = this.m_featureName + BUNDLE_ID_SUFFIX;
            imageUrl = Global.getAssetURL(FEED_ICON_LEVEL_UP_PATH + this.m_featureName + FEED_ICON_LEVEL_UP_SUFFIX + this.m_levelNumber + ".png");
            bundleData = {};
            bundleData.images = [{
               "src":imageUrl,
               "href":"{SN_APP_URL}" + result.rewardLink
            }];
            bundleData.levelNumber = this.m_levelNumber;
            bundleData.rewardLink = result.rewardLink;
            GlobalEngine.socialNetwork.publishFeedStory(bundleId,bundleData,null,false);
         }
      }
   }
}

