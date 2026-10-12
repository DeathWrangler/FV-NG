package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Engine.Managers.TransactionManager;
   import Managers.Requests2InterstitialManager;
   import Transactions.TGetSendFreeGiftsFriendsList;
   import Transactions.TSendRequest2Gifts;
   
   public class MFSSendFreeGifts extends MFSSendGiftBase
   {
      
      protected var m_ref:String = "";
      
      public function MFSSendFreeGifts(giftItem:FarmItem, source:String, completeCallback:Function, ref:String = "free_gifts_full_mfs")
      {
         var friendSpec:Object = {
            "tabNameSuggested":["Suggested"],
            "tabNameFarmVille":["FarmVille"],
            "tabNameFacebook":["Facebook"]
         };
         var friendTabOrder:Array = ["tabNameSuggested","tabNameFarmville","tabNameFacebook"];
         this.m_ref = ref;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FEED_INTERSTITIAL_V2) == 2)
         {
            setFeedInterstitialExperiment(STATS_FLOW_NAME);
         }
         super(giftItem,source,false,completeCallback,"FreeGiftsFullMFS",friendSpec);
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGetSendFreeGiftsFriendsList(convertToUniqueValuesArray(friendSpec),onFriendPopulation),true);
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         TransactionManager.addTransaction(new TSendRequest2Gifts(m_item.code,requestIds,this.m_ref,this.getStatsFlowName(),m_serverTime),true);
      }
      
      override protected function getStatsFlowName() : String
      {
         return this.m_ref;
      }
      
      override protected function switchFromMFSToFeed() : void
      {
         m_item = Requests2InterstitialManager.getRecentlyPlayedGift();
         switchFromMFSToFeedHelper();
         addCornerAvatar();
      }
   }
}

