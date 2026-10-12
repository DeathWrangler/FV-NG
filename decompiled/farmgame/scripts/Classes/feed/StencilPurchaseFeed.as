package Classes.feed
{
   import Classes.FarmGameObject;
   import Classes.MapResource;
   import Classes.UGC.UGCFeedImage;
   import Managers.UserContentManager;
   
   public class StencilPurchaseFeed extends FarmFeed
   {
      
      private var m_farmObj:FarmGameObject;
      
      private var m_featureName:String;
      
      private const BUNDLE_ID:String = "stencilBrag";
      
      public function StencilPurchaseFeed(obj:FarmGameObject, featureName:String)
      {
         super();
         this.m_farmObj = obj;
         this.m_featureName = featureName;
      }
      
      public function shareFeed() : void
      {
         var feedImage:UGCFeedImage = new UGCFeedImage(this.m_farmObj,this.m_featureName);
         UserContentManager.getInstance().createFeedImage(feedImage,this.onFeedImageGenerated);
      }
      
      private function onFeedImageGenerated(result:Object) : void
      {
         m_bundleId = this.BUNDLE_ID;
         var iconUrl:String = result.imagePath;
         m_params.images = [{
            "src":iconUrl,
            "href":"{SN_APP_URL}"
         }];
         m_params.userName = Global.player.firstName;
         m_params.itemName = (this.m_farmObj as MapResource).getItemFriendlyName();
         publish();
      }
   }
}

