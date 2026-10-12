package Transactions.Voting
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Transactions.Transaction;
   import Events.GenericPopupEvent;
   
   public class TBuyVoteItem extends Transaction
   {
      
      protected var m_featureName:String = "";
      
      protected var m_voteItemName:String = "";
      
      protected var m_expectedPrice:int = 0;
      
      protected var m_completeCallback:Function = null;
      
      protected var m_rewardItem:Object = null;
      
      protected var m_rewardUrl:String = "";
      
      protected var m_postVotingBuy:Boolean = false;
      
      public function TBuyVoteItem(featureName:String, voteItemName:String, expectedPrice:int, completeCallBack:Function = null, postVotingBuy:Boolean = false)
      {
         super();
         this.m_featureName = featureName;
         this.m_voteItemName = voteItemName;
         this.m_expectedPrice = expectedPrice;
         this.m_completeCallback = completeCallBack;
         this.m_postVotingBuy = postVotingBuy;
      }
      
      override public function perform() : void
      {
         if(this.m_postVotingBuy)
         {
            signedCall("VotingService.onBuyPostVoteItem",this.m_featureName,this.m_voteItemName,this.m_expectedPrice);
         }
         else
         {
            signedCall("VotingService.onBuyVoteItem",this.m_featureName,this.m_voteItemName,this.m_expectedPrice);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         var centerIconUrl:String = null;
         var title:String = null;
         var callback:Function = null;
         var buttonString:String = null;
         var message:String = null;
         var dialog:GenericXMLDialog = null;
         if(this.m_completeCallback != null)
         {
            this.m_completeCallback();
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SMART_NAUGHTY_NICE) >= 3)
         {
            this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_voteItemName);
            if(this.m_rewardItem)
            {
               centerIconUrl = this.m_rewardItem.iconRelativeUrl;
               title = null;
               callback = null;
               buttonString = "";
               if(result.rewardUrl)
               {
                  this.m_rewardUrl = result.rewardUrl;
                  callback = this.onCloseFeedPrompt;
                  buttonString = ZLocUtils.t("Dialogs","JustShare");
                  message = ZLocUtils.t("Voting","votingCompleteNowShareFeed_ShortStory_UserMessagePrompt");
               }
               else
               {
                  title = ZLocUtils.t("Dialogs","Congratulations");
                  buttonString = ZLocUtils.t("Dialogs","Okay");
                  message = ZLocUtils.t("Dialogs","GiftboxFind");
               }
               dialog = new GenericXMLDialog(title,"",null,centerIconUrl,100,100,message,callback,true,buttonString,null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
               UI.displayPopup(dialog,false);
            }
         }
      }
      
      private function onCloseFeedPrompt(event:GenericPopupEvent) : void
      {
         var params:Object = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            params = new Object();
            params.images = [{
               "src":this.m_rewardItem.icon,
               "href":"{SN_APP_URL}" + this.m_rewardUrl
            }];
            params.reward_link = this.m_rewardUrl;
            GlobalEngine.socialNetwork.publishFeedStory("votingCompleteNowShareFeed",params,[],false);
         }
      }
   }
}

