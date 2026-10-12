package Classes.feed
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   
   public class ShareMarketStallFeed extends FarmFeed
   {
      
      public function ShareMarketStallFeed(bushelItem:FarmItem, quantity:int, rewardUrl:String, bundleId:String = "CraftingShareFromStall", overrideIconUrl:String = null, craftedItem:String = null)
      {
         super();
         m_bundleId = bundleId;
         m_params.bushelName = bushelItem.friendlyName;
         m_params.quantity = quantity;
         m_params.rewardLink = rewardUrl;
         m_params.creative = "share_bushel_" + bushelItem.name;
         var iconUrl:String = bushelItem.icon;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FACEBOOK_FEED_ICONS) > 1)
         {
            iconUrl = bushelItem.getImageByName("feed",true);
         }
         if(overrideIconUrl != null)
         {
            iconUrl = overrideIconUrl;
         }
         if(craftedItem != null)
         {
            m_params.craftedItem = craftedItem;
         }
         m_params.images = [{
            "src":iconUrl,
            "href":"{SN_APP_URL}"
         }];
      }
   }
}

