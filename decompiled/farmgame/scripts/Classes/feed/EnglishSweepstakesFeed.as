package Classes.feed
{
   public class EnglishSweepstakesFeed extends FarmFeed
   {
      
      public function EnglishSweepstakesFeed(bundleId:String, rewardUrl:String)
      {
         super();
         m_params.reward_link = rewardUrl;
         m_bundleId = bundleId;
      }
      
      public function setImage(imageUrl:String, isAssetURL:Boolean = false) : void
      {
         var image:String = imageUrl;
         if(!isAssetURL)
         {
            image = Global.getAssetURL(imageUrl);
         }
         m_params.images = [{
            "href":"{SN_APP_URL}" + m_params.reward_link,
            "src":image
         }];
      }
   }
}

