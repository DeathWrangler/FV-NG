package Classes.crafting
{
   import Classes.ZItem.FarmItem;
   
   public class CraftingFeed
   {
      
      public function CraftingFeed()
      {
         super();
      }
      
      public static function fullBushelFeed(rewardUrl:String, bushelCode:String) : void
      {
         var params:Object = new Object();
         var bundleId:String = "CraftingBushelReward";
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(bushelCode);
         var iconUrl:String = item.icon;
         params.bushelName = item.friendlyName;
         params.actor = Global.player.snUser.firstName;
         params.images = [{
            "src":iconUrl,
            "href":"{SN_APP_URL}"
         }];
         params.rewardLink = rewardUrl;
         GlobalEngine.socialNetwork.publishFeedStory(bundleId,params,[],false);
      }
   }
}

