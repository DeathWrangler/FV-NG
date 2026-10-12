package Transactions
{
   import Classes.HarvestStorageBuilding;
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   
   public class TGiftFlowerDecorations extends TWorldState
   {
      
      private var m_params:Object;
      
      private var m_closeFeedCallback:Function;
      
      private var m_buildingName:String;
      
      public function TGiftFlowerDecorations(building:HarvestStorageBuilding, itemCode:String, numItems:int, closeFeedCallback:Function)
      {
         super(building);
         this.m_closeFeedCallback = closeFeedCallback;
         this.m_params = new Object();
         this.m_params.storedItemCode = itemCode;
         this.m_params.numItems = numItems;
         this.m_buildingName = building.getItem().name.replace("_cash","");
      }
      
      override public function perform() : void
      {
         signedWorldAction("giftHarvestItem",this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var giftItem:FarmItem = null;
         var giftName:String = null;
         var iconUrl:String = null;
         var images:Array = null;
         if(!result.error)
         {
            giftItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_params.storedItemCode);
            if(giftItem)
            {
               giftName = giftItem.friendlyName;
               iconUrl = giftItem.getImageByName("icon");
               images = [{
                  "src":iconUrl,
                  "href":"{SN_APP_URL}" + result.rewardUrl
               }];
               GlobalEngine.socialNetwork.publishFeedStory("GiftHarvestItemFromStorage_" + this.m_buildingName,{
                  "gift_name":giftName,
                  "gift_amount":this.m_params.numItems,
                  "images":images,
                  "reward_link":result.rewardUrl,
                  "subCategory":giftItem.name
               },[],false,this.m_closeFeedCallback);
               FarmStatsManager.count("Shortfeed",this.m_buildingName,"Gift_From_Storage","give_" + giftItem.name);
            }
         }
      }
   }
}

