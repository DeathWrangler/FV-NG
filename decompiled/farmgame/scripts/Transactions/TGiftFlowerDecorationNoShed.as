package Transactions
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   
   public class TGiftFlowerDecorationNoShed extends TFarmTransaction
   {
      
      private var m_seedName:String;
      
      private var m_buildingName:String;
      
      private var m_plotId:int;
      
      private var m_closeFeedCallback:Function;
      
      public function TGiftFlowerDecorationNoShed(plotId:int, seedName:String, buildingName:String, closeFeedCallback:Function)
      {
         super();
         this.m_plotId = plotId;
         this.m_seedName = seedName;
         this.m_buildingName = buildingName.replace("_cash","");
         this.m_closeFeedCallback = closeFeedCallback;
      }
      
      override public function perform() : void
      {
         signedCall("GiftFlowerDecorationService.giftHarvestedItem",this.m_seedName,this.m_plotId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var harvestName:String = null;
         var iconUrl:String = null;
         var images:Array = null;
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(result.harvestItem);
         if(giftItem)
         {
            harvestName = giftItem.friendlyName;
            iconUrl = giftItem.getImageByName("icon");
            images = [{
               "src":iconUrl,
               "href":"{SN_APP_URL}" + result.rewardUrl
            }];
            GlobalEngine.socialNetwork.publishFeedStory("GiftHarvestItemNoStorage_" + this.m_buildingName,{
               "gift_name":harvestName,
               "images":images,
               "reward_link":result.rewardUrl,
               "subCategory":giftItem.name
            },[],false,this.m_closeFeedCallback);
            FarmStatsManager.count("Shortfeed",this.m_buildingName,"First_Gift_No_Storage","give_" + giftItem.name);
         }
      }
   }
}

