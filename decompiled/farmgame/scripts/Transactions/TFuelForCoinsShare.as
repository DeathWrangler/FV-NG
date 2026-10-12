package Transactions
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class TFuelForCoinsShare extends TFarmTransaction
   {
      
      public function TFuelForCoinsShare()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("FarmService.getFuelForCoinsRewardUrl");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var message:String = null;
         var fuelForCoinsPopup:GenericPopup = null;
         if(result.fuelForCoinsReward)
         {
            message = ZLocUtils.t("Dialogs","FuelForCoinsFeedPopup");
            fuelForCoinsPopup = new GenericPopup(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onFuelDiscoveryPromptClick,GenericPopup.GENERIC_ASSET,result.fuelForCoinsReward);
            fuelForCoinsPopup.setAcceptTextName("Share");
            UI.displayPopup(fuelForCoinsPopup);
         }
      }
      
      protected function onFuelDiscoveryPromptClick(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "reward_link":event.rewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + event.rewardLink,
                  "src":Global.getAssetURL("assets/newsfeed/givefuel_feed.png")
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("feed_FuelForCoinsPurchase",bundleData,[],false);
            FarmStatsManager.featureSample("Fuel","Share_Fuel_4_Coins","Feeds_Shown","Accept");
         }
         else
         {
            FarmStatsManager.featureSample("Fuel","Share_Fuel_4_Coins","Feeds_Shown","Cancel");
         }
      }
   }
}

