package Transactions.NeighborActions
{
   import Classes.ZItem.FarmItem;
   import Managers.ToasterManager;
   import Transactions.TFarmTransaction;
   import Widgets.Windows.GoodieBagToasterWindow;
   
   public class TSendNeighborGift extends TFarmTransaction
   {
      
      protected var m_neighborId:String;
      
      public function TSendNeighborGift(neighborId:String)
      {
         this.m_neighborId = neighborId;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("NeighborActionService.getVisitGiftW2W",this.m_neighborId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var bundleId:String = null;
         var targetIds:Array = null;
         var rewardItem:FarmItem = null;
         var iconUrl:String = null;
         var params:Object = null;
         var giftItem:FarmItem = null;
         if(result)
         {
            if(Boolean(result.rewardLink) && Boolean(result.itemCode))
            {
               bundleId = this.getBundleId();
               targetIds = [this.m_neighborId];
               rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(result.itemCode);
               iconUrl = rewardItem.icon;
               params = new Object();
               params.sendingUser = Global.player.firstName;
               params.itemName = rewardItem.friendlyName;
               params.rewardLink = result.rewardLink;
               params.images = [{
                  "src":iconUrl,
                  "href":"{SN_APP_URL}" + result["rewardLink"]
               }];
               GlobalEngine.socialNetwork.publishFeedStory(bundleId,params,targetIds,false);
            }
            if(Boolean(result.goodieBagRewardItemCode) && Boolean(result.fertilizeRewardLink))
            {
               giftItem = Global.farmGameSettingsManager.getFarmItemByCode(result.goodieBagRewardItemCode);
               if(giftItem)
               {
                  Global.player.addGift(giftItem.name);
                  ToasterManager.getInstance().add(new GoodieBagToasterWindow(this.m_neighborId,giftItem,result.fertilizeRewardLink));
               }
            }
         }
      }
      
      protected function getBundleId() : String
      {
         return "NeighborVisitGift";
      }
   }
}

