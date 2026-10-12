package Managers
{
   import Classes.ZItem.FarmItem;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   
   public class PerformancePromotionManager
   {
      
      private static var m_instance:PerformancePromotionManager = null;
      
      private static const SERVICE_CLASS:String = "PerformancePromotionService";
      
      private static const FRIEND_REWARD:String = "performance_promotion";
      
      private static const BUNDLE_ID:String = "performancePromotionFeedReward";
      
      private var m_featureName:String = "PerformancePromotion";
      
      public function PerformancePromotionManager()
      {
         super();
      }
      
      public static function getInstance() : PerformancePromotionManager
      {
         if(!m_instance)
         {
            m_instance = new PerformancePromotionManager();
         }
         return m_instance;
      }
      
      public function rewardItem(gift:FarmItem, runTimeKey:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"onGiftItem"));
         if(!FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,gift.code))
         {
            Global.player.addGift(gift.name);
            FeatureOptionsManager.getInstance().setFeatureOption(this.m_featureName,gift.code,1);
         }
      }
      
      public function onBragFeed(itemName:String) : void
      {
         TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"onBragFeed",this.onBragFeedCallBack));
      }
      
      private function onBragFeedCallBack(reward:Object) : void
      {
         var itemName:String = null;
         var rewardFarmItem:FarmItem = null;
         var bundleData:Object = null;
         if(Boolean(reward) && reward.hasOwnProperty("rewardUrl"))
         {
            itemName = null;
            if(reward.hasOwnProperty("itemName"))
            {
               itemName = reward["itemName"];
            }
            if(Boolean(itemName) && itemName != "")
            {
               rewardFarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
               bundleData = {
                  "reward_link":reward["rewardUrl"],
                  "giftName":rewardFarmItem.friendlyName,
                  "creative":FRIEND_REWARD,
                  "subcategory":BUNDLE_ID,
                  "images":[{
                     "href":"{SN_APP_URL}" + reward["rewardUrl"],
                     "src":rewardFarmItem.getImageByName(FarmItem.ICON_FEED)
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory(BUNDLE_ID,bundleData,[],false);
            }
         }
      }
   }
}

