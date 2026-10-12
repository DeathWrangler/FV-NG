package Classes.feed
{
   import Classes.ZItem.FarmItem;
   
   public class OpenStallShareFeed extends FarmFeed
   {
      
      private var m_bundle_ID:String;
      
      private var m_idx:int;
      
      private var m_bundleIds:Array = ["CraftingOpenStallShare","CraftingOpenStallShare1","CraftingOpenStallShare2"];
      
      public function OpenStallShareFeed(bushelItem:FarmItem, hours:int, rewardUrl:String)
      {
         super();
         m_bundleId = this.getRandomFeedId();
         m_params.bushelName = bushelItem.friendlyName;
         m_params.hours = hours;
         m_params.rewardLink = rewardUrl;
         var iconUrl:String = bushelItem.icon;
         m_params.images = [{
            "src":iconUrl,
            "href":"{SN_APP_URL}"
         }];
      }
      
      private function getRandomFeedId() : String
      {
         this.m_bundle_ID = "CraftingOpenStallShare";
         this.m_idx = Math.floor(Math.random() * this.m_bundleIds.length);
         if(this.m_bundleIds[this.m_idx])
         {
            this.m_bundle_ID = this.m_bundleIds[this.m_idx];
         }
         return this.m_bundle_ID;
      }
   }
}

