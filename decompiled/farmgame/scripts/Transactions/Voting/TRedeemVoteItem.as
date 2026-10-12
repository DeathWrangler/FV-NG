package Transactions.Voting
{
   import Classes.FeatureComponents.VotingComponent;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Engine.Transactions.Transaction;
   import Events.GenericPopupEvent;
   
   public class TRedeemVoteItem extends Transaction
   {
      
      protected var m_featureName:String;
      
      protected var m_redeemItemIdentifier:String = "";
      
      protected var m_voteIndex:uint = 0;
      
      protected var m_voters:String = "";
      
      protected var m_stage:int;
      
      protected var m_rewardItem:Object = null;
      
      protected var m_rewardUrl:String = "";
      
      protected var m_voteStr:String;
      
      protected var m_voteStrFeed:String;
      
      public function TRedeemVoteItem(featureName:String, redeemItemIdentifier:String, voteIndex:int, voters:String, stage:int)
      {
         super();
         this.m_featureName = featureName;
         this.m_redeemItemIdentifier = redeemItemIdentifier;
         this.m_voteIndex = voteIndex;
         this.m_voters = voters;
         this.m_stage = stage;
      }
      
      override public function perform() : void
      {
         signedCall("VotingService.onRedeemVoteItem",this.m_featureName,this.m_redeemItemIdentifier,this.m_voteIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var strPK:String = null;
         var outcomeKey:String = null;
         var PKOutcome:String = null;
         var outcomeKeyFeed:String = null;
         var PKOutcomeFeed:String = null;
         var voteStr:String = null;
         var voteStrFeed:String = null;
         var messageText:String = null;
         var imageSize:Number = NaN;
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         if(Boolean(result && result.hasOwnProperty("rewardUrl") && result.rewardUrl) && Boolean(result.hasOwnProperty("rewardCode")) && Boolean(result.rewardCode))
         {
            this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(result.rewardCode);
            if(this.m_rewardItem)
            {
               this.m_rewardUrl = result.rewardUrl;
               strPK = VotingComponent.getLocalizedKey(this.m_featureName,"RedeemVoteItem");
               if("" == strPK)
               {
                  strPK = "Voting:RedeemVoteItem";
               }
               outcomeKey = "Outcome_" + this.m_stage + "_" + this.m_voteIndex + "_Text";
               PKOutcome = VotingComponent.getLocalizedKey(this.m_featureName,outcomeKey);
               outcomeKeyFeed = "OutcomeFeed_" + this.m_stage + "_" + this.m_voteIndex + "_Text";
               PKOutcomeFeed = VotingComponent.getLocalizedKey(this.m_featureName,outcomeKeyFeed);
               voteStr = ZLocUtils.t_pk(PKOutcome);
               voteStrFeed = ZLocUtils.t_pk(PKOutcomeFeed);
               this.m_voteStr = voteStr;
               this.m_voteStrFeed = voteStrFeed;
               messageText = ZLocUtils.t_pk(strPK,null,{
                  "item":ZLocUtils.tk_pk(this.m_rewardItem.friendlyName),
                  "vote":voteStr
               });
               imageSize = 100;
               centerIconUrl = Global.reverseAssetURL(this.m_rewardItem.icon,2);
               dialog = new GenericXMLDialog(null,"",null,centerIconUrl,imageSize,imageSize,messageText,this.onCloseFeedPrompt,true,ZLocUtils.t("Dialogs","JustShare"),null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
               UI.displayPopup(dialog,false);
            }
         }
      }
      
      protected function onCloseFeedPrompt(event:GenericPopupEvent) : void
      {
         var params:Object = null;
         var bundleSuffix:String = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            params = new Object();
            params.itemname = this.m_rewardItem.friendlyName;
            params.images = [{
               "src":this.m_rewardItem.icon,
               "href":"{SN_APP_URL}" + this.m_rewardUrl
            }];
            params.reward_link = this.m_rewardUrl;
            params.vote = this.m_voteStrFeed;
            params.voters = this.m_voters;
            params.creative = this.m_rewardItem.name;
            bundleSuffix = "VotingComplete";
            GlobalEngine.socialNetwork.publishFeedStory(this.m_featureName + bundleSuffix,params,[],false);
         }
      }
   }
}

