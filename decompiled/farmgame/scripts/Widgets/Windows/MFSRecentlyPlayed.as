package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGetRecentlyPlayedFriends;
   import Transactions.TSendRequest2Gifts;
   
   public class MFSRecentlyPlayed extends MFSSendGiftBase
   {
      
      public static const MFS_TYPE:String = "RecentlyPlayedFriendsGiftWindow";
      
      private static const STATS_CATEGORY:String = "recently_played_mfs";
      
      public function MFSRecentlyPlayed(giftItem:FarmItem, feedItems:Array, source:String, limitFriends:Boolean, completeCallback:Function, showFeedDialog:Boolean = false)
      {
         super(giftItem,source,limitFriends,completeCallback,MFS_TYPE);
         m_giftItems = feedItems;
         if(showFeedDialog)
         {
            setFeedInterstitialExperiment("recent");
         }
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetRecentlyPlayedFriends(m_limitFriends,onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendRequest2Gifts(m_item.code,requestIds,TSendRequest2Gifts.REF_RECENTLY_PLAYED_GIFT,this.getStatsFlowName(),m_serverTime),true);
      }
      
      override protected function getStatsFlowName() : String
      {
         return STATS_CATEGORY;
      }
      
      override protected function switchFromMFSToFeed() : void
      {
         if(m_giftItems.length > 0)
         {
            switchFromMFSToFeedHelper();
            addGiftSelector(m_giftItems);
         }
         else
         {
            ErrorManager.addError("Unable to find gift items for feed prompt.",ErrorManager.ERROR_UNKNOWN);
            close();
         }
      }
   }
}

