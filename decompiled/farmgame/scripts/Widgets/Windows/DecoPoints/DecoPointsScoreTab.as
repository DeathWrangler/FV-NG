package Widgets.Windows.DecoPoints
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.DecoPointsManager;
   import Managers.FarmStatsManager;
   import Managers.VotingDataManager;
   import Transactions.TransactionWithCallBack;
   import Transactions.Voting.TAskForVotePublish;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class DecoPointsScoreTab extends ZwFrame
   {
      
      private var m_decoPointsManager:DecoPointsManager;
      
      private var m_askVoteBtn:FarmAnimatedButton;
      
      private var m_askVoteSmallBtn:FarmAnimatedButton;
      
      private var m_userPhotoIcon:FarmIcon;
      
      private var m_galleryVoteRewardLink:String;
      
      private var m_decoMainUI:DecoPointsMainWindow;
      
      private var m_submitBtn:FarmAnimatedTextButton;
      
      private var m_submitNewBtn:FarmAnimatedTextButton;
      
      private var m_voteTallyFrame:ZwFrame;
      
      private var m_promoteFrame:ZwFrame;
      
      private var m_promoteBtn:FarmAnimatedTextButton;
      
      private var m_promotePrice:int;
      
      private const PROMOTE_PRICE_STRING:String = "PhotoContestPromotePrice";
      
      private var m_votesFrame:ZwFrame;
      
      private var m_noVotesFrame:ZwFrame;
      
      private const SEEN_OFFENSIVE:String = "_offensive";
      
      public function DecoPointsScoreTab(element:MovieClip, decoPointsManager:DecoPointsManager, decoUI:DecoPointsMainWindow)
      {
         var decoPoints:String = null;
         var seenFlag:String = null;
         super(element);
         this.m_decoPointsManager = decoPointsManager;
         this.m_decoMainUI = decoUI;
         if(element.vote_bt)
         {
            this.addWidget(new FarmAnimatedTextButton(element.vote_bt,ZLocUtils.t("Dialogs","DPScoreTab_VoteNow"),this.onPressVoteTab)) as FarmAnimatedTextButton;
         }
         if(element.ask_bt)
         {
            this.m_askVoteBtn = this.addWidget(new FarmAnimatedTextButton(element.ask_bt,ZLocUtils.t("Dialogs","DPScoreTab_AskForVote"),this.requestGalleryVotingRewardLink)) as FarmAnimatedTextButton;
         }
         if(element.generic_0_tf)
         {
            this.addWidget(new FarmTextField(element.generic_0_tf,this.m_decoPointsManager.getWeeklyPhotoContestTitle()));
         }
         if(element.challenge_tf)
         {
            this.addWidget(new FarmTextField(element.challenge_tf,this.m_decoPointsManager.getWeeklyPhotoContestTheme()));
         }
         if(element.tally_mc)
         {
            this.m_voteTallyFrame = new ZwFrame(m_element.tally_mc);
            this.m_votesFrame = new ZwFrame(this.m_voteTallyFrame.element.votes_mc);
            this.m_votesFrame.addWidget(new FarmTextField(this.m_votesFrame.element.votes_tf));
            this.m_noVotesFrame = new ZwFrame(this.m_voteTallyFrame.element.noVotes_mc);
            this.m_noVotesFrame.addWidget(new FarmTextField(this.m_noVotesFrame.element.noVotes_tf));
            this.m_voteTallyFrame.addWidget(this.m_votesFrame,false);
            this.m_voteTallyFrame.addWidget(this.m_noVotesFrame);
            if(this.m_voteTallyFrame.element.askSmall_bt)
            {
               this.m_askVoteSmallBtn = new FarmAnimatedTextButton(this.m_voteTallyFrame.element.askSmall_bt,ZLocUtils.t("Dialogs","GenericAsk"),this.requestGalleryVotingRewardLink);
               this.m_voteTallyFrame.addWidget(this.m_askVoteSmallBtn);
            }
            this.addWidget(this.m_voteTallyFrame);
         }
         var promoteVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_PHOTO_CONTEST_PROMOTE);
         if(Boolean(this.m_decoPointsManager.getCurrentContestPhoto()) && Boolean(promoteVariant > Experiments.VARIANT_PHOTO_CONTEST_PROMOTE_CONTROL) && Boolean(element.promote_mc))
         {
            this.m_promoteFrame = new ZwFrame(element.promote_mc);
            this.m_promoteBtn = new FarmAnimatedTextButton(this.m_promoteFrame.element.generic_bt,ZLocUtils.t("Dialogs","DPScoreTab_Btn_Promote"),this.onPromoteClick);
            this.m_promoteFrame.addWidget(this.m_promoteBtn);
            if(this.m_decoPointsManager.isPromotePhotoActive())
            {
               this.m_promoteBtn.enabled = false;
               this.m_promoteBtn.text = ZLocUtils.t("Dialogs","DPScoreTab_Btn_Promoted");
            }
            this.m_promoteFrame.addWidget(new FarmTextField(this.m_promoteFrame.element.generic_tf,ZLocUtils.t("Dialogs","DPScoreTab_Promote")));
            this.m_promotePrice = Global.farmGameSettingsManager.getNumber(this.PROMOTE_PRICE_STRING);
            this.m_promoteFrame.addWidget(new FarmTextField(this.m_promoteFrame.element.cost_tf,this.m_promotePrice.toString()));
            this.m_promoteFrame.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Dialogs","DPScoreTab_Btn_Promote_Tooltip")));
            this.addWidget(this.m_promoteFrame);
         }
         if(element.generic_1_tf)
         {
            this.addWidget(new FarmTextField(element.generic_1_tf,ZLocUtils.t("Dialogs","DPScoreTab_Photo")));
         }
         if(element.tagline_tf)
         {
            decoPoints = ZLocUtils.t("FarmGame",Global.worldManager.currentWorldScoreId);
            this.addWidget(new FarmTextField(element.tagline_tf,ZLocUtils.t("Dialogs","DPScoreTab_DPFeatureTagLine",{"worldscore":decoPoints}))) as FarmTextField;
         }
         if(m_element.submit_bt)
         {
            this.m_submitBtn = this.addWidget(new FarmAnimatedTextButton(m_element.submit_bt,ZLocUtils.t("Dialogs","DPScoreTab_SubmitPhoto"),this.onSubmitPhoto)) as FarmAnimatedTextButton;
         }
         if(this.m_decoPointsManager.isBlockedFromPosting())
         {
            seenFlag = DecoPointsManager.instance.getWeeklyContestName() + this.SEEN_OFFENSIVE;
            if(!Global.player.getSeenFlag(seenFlag))
            {
               Global.player.setSeenFlag(seenFlag);
               this.openUserImageAbusiveNotification();
            }
         }
         if(!this.m_decoPointsManager.isInitialized())
         {
            this.renderCurrentContestPhotoUI();
         }
      }
      
      public function renderCurrentContestPhotoUI(askForVote:Boolean = false) : void
      {
         var submitText:String = null;
         var photoUrl:String = this.m_decoPointsManager.getCurrentContestPhoto();
         if(Boolean(m_element.icon_mc) && Boolean(photoUrl))
         {
            if(!this.m_userPhotoIcon)
            {
               this.m_userPhotoIcon = new FarmIcon(m_element.icon_mc,photoUrl);
               this.addWidget(this.m_userPhotoIcon,true);
            }
            else
            {
               this.m_userPhotoIcon.loadIcon(photoUrl);
            }
            this.m_userPhotoIcon.setIconSize(200,200);
         }
         else if(!this.m_submitNewBtn && Boolean(m_element.submit_new_bt))
         {
            this.m_submitNewBtn = this.addWidget(new FarmAnimatedTextButton(m_element.submit_new_bt,ZLocUtils.t("Dialogs","DPScoreTab_SubmitNewPhoto"),this.onSubmitPhoto)) as FarmAnimatedTextButton;
         }
         if(this.m_submitBtn)
         {
            if(photoUrl)
            {
               submitText = ZLocUtils.t("Dialogs","DPScoreTab_UploadPhoto");
            }
            else
            {
               submitText = ZLocUtils.t("Dialogs","DPScoreTab_SubmitPhoto");
            }
            this.m_submitBtn.text = submitText;
         }
         this.refreshVoteTallyFrame(photoUrl != null);
         this.toggleAskFeedOption(this.isAskForVotesEnabled() && photoUrl != null);
         if(askForVote)
         {
            this.askForVotes();
         }
      }
      
      private function refreshVoteTallyFrame(hasPhoto:Boolean) : void
      {
         var votes:Number = NaN;
         var votesToggle:Boolean = false;
         var noVotesToggle:Boolean = false;
         if(hasPhoto)
         {
            this.m_voteTallyFrame.visible = true;
            if(this.m_decoPointsManager.isInitialized())
            {
               votes = this.m_decoPointsManager.getTotalVotes();
               if(votes > 0)
               {
                  this.m_votesFrame.element.votes_tf.text = votes;
                  votesToggle = true;
               }
               else
               {
                  this.m_noVotesFrame.element.noVotes_tf.text = ZLocUtils.t("Dialogs","DPScoreTab_NoVotes");
                  noVotesToggle = true;
               }
            }
            else
            {
               this.m_noVotesFrame.element.noVotes_tf.text = ZLocUtils.t("Dialogs","DPScoreTab_WaitingVotes");
               noVotesToggle = true;
            }
         }
         else
         {
            this.m_voteTallyFrame.visible = false;
         }
         this.m_votesFrame.visible = votesToggle;
         this.m_noVotesFrame.visible = noVotesToggle;
      }
      
      private function onPressVoteTab(event:MouseEvent) : void
      {
         this.m_decoPointsManager.enableVoteTab();
      }
      
      private function onSubmitPhoto(event:MouseEvent) : void
      {
         if(this.m_decoPointsManager)
         {
            if(!this.m_decoPointsManager.isBlockedFromPosting())
            {
               FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_DIALOG,DecoPointsManager.DECOPOINTS_DIALOG_TAKE_PIC,DecoPointsManager.MODE_SCORE);
               this.m_decoPointsManager.startFarmstamaticGameMode();
            }
            else
            {
               this.openUserImageAbusiveNotification();
            }
         }
      }
      
      private function openUserImageAbusiveNotification() : void
      {
         var dialog:GenericPopup = new GenericPopup(ZLocUtils.t("Dialogs","DPScoreTab_AbusiveImage"),GenericPopup.TYPE_OK);
         UI.displayPopup(dialog);
      }
      
      protected function requestGalleryVotingRewardLink(event:MouseEvent = null) : void
      {
         if(this.isAskForVotesEnabled())
         {
            this.askForVotes();
         }
      }
      
      protected function onPromoteClick(event:MouseEvent = null) : void
      {
         if(Boolean(this.m_decoPointsManager.getCurrentContestPhoto()) && Global.player.canBuyCash(this.m_promotePrice))
         {
            Global.player.cash -= this.m_promotePrice;
            this.m_decoPointsManager.setPromotePhotoActive();
            if(this.m_promoteBtn)
            {
               this.m_promoteBtn.enabled = false;
               this.m_promoteBtn.text = ZLocUtils.t("Dialogs","DPScoreTab_Btn_Promoted");
            }
         }
      }
      
      private function toggleAskFeedOption(flag:Boolean) : void
      {
         if(Boolean(this.m_decoPointsManager) && this.m_decoPointsManager.hasMainWindow())
         {
            if(this.m_askVoteBtn != null)
            {
               this.m_askVoteBtn.enabled = flag;
            }
            if(this.m_askVoteSmallBtn != null)
            {
               this.m_askVoteSmallBtn.enabled = flag;
            }
         }
      }
      
      public function isAskForVotesEnabled() : Boolean
      {
         return VotingDataManager.getInstance().askForVotesTimeRemaining(DecoPointsManager.instance.getWeeklyContestName()) <= 0;
      }
      
      private function askForVotes() : void
      {
         var featureName:String = DecoPointsManager.instance.getWeeklyContestName();
         this.toggleAskFeedOption(false);
         var voteStart:Number = VotingDataManager.getInstance().getDataObject(featureName).startTime;
         if(voteStart <= 0)
         {
            voteStart = GlobalEngine.serverTime / 1000;
            VotingDataManager.getInstance().getDataObject(featureName).startTime = voteStart;
         }
         TransactionManager.addTransaction(new TransactionWithCallBack("PhotoContestService.onGenerateFeedVotingReward",this.getRewardLinkAndPostVotingFeedShare,featureName,this.m_decoPointsManager.getHashKeyOfActiveContestPhoto()),true);
         FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_DIALOG,DecoPointsManager.DECOPOINTS_DIALOG_ASK_VOTES);
      }
      
      private function getShowVoteTabSeenFlag() : String
      {
         return this.m_decoPointsManager.getWeeklyContestName() + "_toVote";
      }
      
      private function shouldOpenGallery(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.m_decoPointsManager.enableVoteTab();
         }
         Global.player.setSeenFlag(this.getShowVoteTabSeenFlag());
      }
      
      protected function postGalleryVotingFeedShare() : void
      {
         var bundleData:Object = {
            "reward_link":this.m_galleryVoteRewardLink,
            "images":[{
               "href":"{SN_APP_URL}" + this.m_galleryVoteRewardLink,
               "src":this.m_decoPointsManager.getCurrentContestPhoto()
            }]
         };
         var messageType:String = this.m_decoPointsManager.getWeeklyContestName();
         TransactionManager.addTransaction(new TAskForVotePublish(messageType,bundleData,[],false,this.feedPostSuccess,this.feedPostFailed),true);
      }
      
      private function feedPostFailed() : void
      {
         this.toggleAskFeedOption(this.isAskForVotesEnabled());
      }
      
      private function feedPostSuccess() : void
      {
         var currentTimeInSec:Number = GlobalEngine.serverTime / 1000;
         var strFeatureFlagName:String = this.m_decoPointsManager.getWeeklyContestName() + "_lastAskForVotes";
         Global.player.setFeatureLastShown(strFeatureFlagName,currentTimeInSec,true);
         this.toggleAskFeedOption(false);
         if(!Global.player.getSeenFlag(this.getShowVoteTabSeenFlag()))
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","DPScoreTab_GotoVote"),GenericPopup.TYPE_OK,this.shouldOpenGallery);
            Global.player.setSeenFlag(this.getShowVoteTabSeenFlag());
         }
      }
      
      protected function getRewardLinkAndPostVotingFeedShare(data:Object) : void
      {
         if(data.hasOwnProperty("rewardUrl"))
         {
            this.m_galleryVoteRewardLink = data.rewardUrl;
            this.postGalleryVotingFeedShare();
         }
      }
   }
}

