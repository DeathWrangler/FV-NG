package Transactions
{
   import Classes.RewardCreditsBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   
   public class TTradeSubcredits extends TWorldState
   {
      
      protected var m_rewardCreditsBuilding:RewardCreditsBuilding = null;
      
      protected var m_rewardUrl:String = "";
      
      public function TTradeSubcredits(building:RewardCreditsBuilding)
      {
         this.m_rewardCreditsBuilding = building;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("tradeSubcredits");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var tradeInValue:uint = 0;
         var dialogText:String = null;
         var dialog:GenericPopup = null;
         var isFeedPrompted:Boolean = this.m_rewardCreditsBuilding.processCreditsGainedResult(result);
         if(Boolean(result.rewardUrl) && !isFeedPrompted)
         {
            this.m_rewardUrl = result.rewardUrl;
            tradeInValue = uint(Global.farmGameSettingsManager.getInt(this.m_rewardCreditsBuilding.getCreditsFeatureName() + "TradeInValue",5));
            dialogText = ZLocUtils.t("Dialogs",this.m_rewardCreditsBuilding.getLocKeyPrefix() + "TradeInMessage",{"quantity":tradeInValue});
            dialog = new GenericPopup(dialogText,GenericPopup.TYPE_SHARECANCEL,this.onCloseFeedPrompt);
            dialog.setTrackerKey("feed_" + this.m_rewardCreditsBuilding.getLocKeyPrefix() + "TradeIn");
            UI.displayPopup(dialog);
         }
      }
      
      protected function onCloseFeedPrompt(event:GenericPopupEvent) : void
      {
         var iconUrl:String = null;
         var params:Object = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            iconUrl = this.m_rewardCreditsBuilding.getSubcreditsTradeFeedUrl();
            params = new Object();
            params.images = [{
               "src":Global.getAssetURL(iconUrl),
               "href":"{SN_APP_URL}" + this.m_rewardUrl
            }];
            params.reward_link = this.m_rewardUrl;
            GlobalEngine.socialNetwork.publishFeedStory(this.m_rewardCreditsBuilding.getBundlePrefix() + "FavorIncrease",params,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardUrl]));
         }
      }
   }
}

