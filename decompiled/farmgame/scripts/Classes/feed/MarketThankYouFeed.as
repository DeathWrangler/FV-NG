package Classes.feed
{
   public class MarketThankYouFeed extends FarmFeed
   {
      
      public function MarketThankYouFeed(bushelName:String, bushelIcon:String, stallOwner:String, rewardUrl:String, bundleName:String = "")
      {
         super();
         if(bundleName == "")
         {
            bundleName = "CraftingThankYou";
         }
         m_bundleId = bundleName;
         m_params.bushelName = bushelName;
         m_params.actor = Global.player.firstName;
         m_params.ownerName = Global.friendManager.getFriendData(stallOwner).firstName;
         m_params.rewardLink = rewardUrl;
         m_params.images = [{
            "src":bushelIcon,
            "href":"{SN_APP_URL}"
         }];
      }
   }
}

