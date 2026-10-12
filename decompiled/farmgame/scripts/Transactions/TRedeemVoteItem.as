package Transactions
{
   import Classes.RewardCreditsBuilding;
   import Classes.TicketPartyBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   
   public class TRedeemVoteItem extends TWorldState
   {
      
      public static const SERVER_ACTION:String = "redeemVoteItem";
      
      protected var m_ticketPartyBuilding:TicketPartyBuilding = null;
      
      protected var m_redeemItemIdentifier:String = "";
      
      protected var m_voteIndex:uint = 0;
      
      protected var m_voters:String = "";
      
      protected var m_rewardItem:Object = null;
      
      protected var m_rewardUrl:String = "";
      
      public function TRedeemVoteItem(building:TicketPartyBuilding, redeemItemIdentifier:String, voteIndex:int, voters:String)
      {
         super(building);
         this.m_ticketPartyBuilding = building;
         this.m_redeemItemIdentifier = redeemItemIdentifier;
         this.m_voteIndex = voteIndex;
         this.m_voters = voters;
      }
      
      override public function perform() : void
      {
         signedWorldAction(SERVER_ACTION,this.m_redeemItemIdentifier,this.m_voteIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var strPK:String = null;
         var voteStrPK:String = null;
         var voteStr:String = null;
         var messageText:String = null;
         var imageSize:Number = NaN;
         var centerIconUrl:String = null;
         var dialog:GenericXMLDialog = null;
         if(result.rewardUrl)
         {
            this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_redeemItemIdentifier);
            if(this.m_rewardItem)
            {
               this.m_rewardUrl = result.rewardUrl;
               strPK = RewardCreditsBuilding.getLocalizedKey(this.m_ticketPartyBuilding.getCreditsFeatureName(),"RedeemVoteItem");
               if("" == strPK)
               {
                  strPK = "RewardCreditsBuilding:RedeemVoteItem";
               }
               voteStrPK = RewardCreditsBuilding.getLocalizedKey(this.m_ticketPartyBuilding.getCreditsFeatureName(),this.m_ticketPartyBuilding.getCreditsFeatureName() + "_voteName_" + this.m_voteIndex);
               voteStr = ZLocUtils.tk_pk_asTitle(voteStrPK);
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
         var voteStr:String = null;
         var bundleSuffix:String = null;
         if(GenericPopup.ACCEPT == event.button)
         {
            params = new Object();
            voteStr = this.m_ticketPartyBuilding.getCreditsFeatureName() + "_voteName_" + this.m_voteIndex;
            params.itemname = this.m_rewardItem.friendlyName;
            params.images = [{
               "src":this.m_rewardItem.icon,
               "href":"{SN_APP_URL}" + this.m_rewardUrl
            }];
            params.reward_link = this.m_rewardUrl;
            params.basketname = RewardCreditsBuilding.getBasketFriendlyName(this.m_ticketPartyBuilding.getCreditsFeatureName());
            params.vote = ZLocUtils.t("Dialogs",voteStr);
            params.voters = this.m_voters;
            params.credititemname = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_ticketPartyBuilding.getCreditsFeatureName());
            params.credititemname_single = RewardCreditsBuilding.getCreditItemFriendlyName(this.m_ticketPartyBuilding.getCreditsFeatureName());
            bundleSuffix = "VoteComplete_" + this.m_ticketPartyBuilding.stage;
            GlobalEngine.socialNetwork.publishFeedStory(this.m_ticketPartyBuilding.getBundlePrefix() + bundleSuffix,params,[],false);
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = SERVER_ACTION;
         result.building = this.m_ticketPartyBuilding;
         result.item = this.m_ticketPartyBuilding.getItem();
         result.voteIndex = this.m_voteIndex;
         return result;
      }
   }
}

