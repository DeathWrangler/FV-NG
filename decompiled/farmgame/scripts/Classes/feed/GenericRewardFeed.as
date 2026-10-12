package Classes.feed
{
   import Classes.ZItem.FarmItem;
   
   public class GenericRewardFeed extends FarmFeed
   {
      
      private var m_itemName:String;
      
      private var m_rewardUrl:String;
      
      public function GenericRewardFeed(itemName:String, bundleName:String, rewardUrl:String = null)
      {
         super();
         m_bundleId = bundleName;
         this.m_itemName = itemName;
         this.m_rewardUrl = rewardUrl;
      }
      
      public function shareFeed() : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         m_params.images = [{
            "src":item.icon,
            "href":"{SN_APP_URL}" + this.m_rewardUrl
         }];
         m_params.user = Global.player.firstName;
         m_params.item = item.friendlyName;
         publish();
      }
   }
}

