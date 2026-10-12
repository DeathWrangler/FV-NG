package Classes.feed
{
   public class W2WFeatureFeed extends FarmFeed
   {
      
      private var m_callback:Function;
      
      private var m_hitUid:String;
      
      public function W2WFeatureFeed(bundleId:String, rewardUrl:String, hitUid:String, targetUid:String = "0", callback:Function = null, additionalParams:Object = null)
      {
         var paramName:String = null;
         super();
         if(additionalParams != null)
         {
            for(paramName in additionalParams)
            {
               m_params[paramName] = additionalParams[paramName];
            }
         }
         m_params.reward_link = rewardUrl;
         m_params.first_name = Global.player.firstName;
         m_params.hit_name = Global.friendManager.getFriendName(hitUid,true);
         m_params.target_name = Global.friendManager.getFriendName(targetUid,true);
         m_params.actor = Global.player.firstName;
         this.m_callback = callback;
         m_bundleId = bundleId;
         this.m_hitUid = hitUid;
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
      
      public function publishFeedWithoutPrompt() : void
      {
         m_targetUids = [this.m_hitUid];
         m_publishCallback = this.m_callback;
         this.publish();
      }
   }
}

