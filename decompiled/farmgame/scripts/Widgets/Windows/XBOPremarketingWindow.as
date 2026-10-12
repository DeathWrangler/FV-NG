package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Managers.XBOPremarketingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class XBOPremarketingWindow extends FarmWindowWithTutorial
   {
      
      private const TUTORIAL_SCENES_FRAMES_COUNT:int = 4;
      
      private const BUFFER_FRAMES:int = 16;
      
      private const TITLE_SUFFIX:String = "_title";
      
      private const REWARD_CLOSE_SUFFIX:String = "_rewards_close_btn_text";
      
      private const KEY_SUFFIX:String = "_keyText";
      
      private const PEEK_BTN_SUFFIX:String = "_peek_BtnText";
      
      private const DESCRIPTION_SUFFIX:String = "_description";
      
      private const REWARD_OVERLAY_TITLE_SUFFIX:String = "_reward_overlay_title";
      
      private const DECO_TITLE_SUFFIX:String = "_deco_title";
      
      private const DECO_BTN_SUFFIX:String = "_deco_BtnText";
      
      private const ASK_BTN_TEXT:String = "Ask";
      
      private const REQUEST_BTN_TEXT:String = "Request";
      
      private var m_chestPeekFrame:ZwFrame = null;
      
      private var m_progressFrame:ZwFrame = null;
      
      private var m_rewardFrame:ZwFrame = null;
      
      private var m_rewardFrames:Array = new Array();
      
      private var m_progressRequestFrame:ZwFrame = null;
      
      private var m_askBtn:FarmAnimatedTextButton = null;
      
      private var m_requestBtn:FarmAnimatedTextButton = null;
      
      private var m_milestoneFrames:Array = new Array();
      
      private var m_progressBar:FarmProgressBar = null;
      
      private var m_keyFrame:ZwFrame = null;
      
      private var m_npcFrame:ZwFrame = null;
      
      private var m_decoAnimationFrame:ZwFrame = null;
      
      private var m_currencyCount:ZwTextField = null;
      
      private var m_featureName:String;
      
      public function XBOPremarketingWindow(featureName:String, assetURL:String)
      {
         this.m_featureName = featureName;
         super(featureName,assetURL,this.TUTORIAL_SCENES_FRAMES_COUNT,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TITLE_SUFFIX)));
         if(m_window.timer_tf)
         {
            addWidget(new ZwTextField(m_window.timer_tf,this.manager.timeRemaining));
         }
         if(m_window.description_tf)
         {
            addWidget(new ZwTextField(m_window.description_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.DESCRIPTION_SUFFIX)));
         }
         if(m_window.npc_mc)
         {
            addWidget(this.m_npcFrame = new ZwFrame(m_window.npc_mc));
         }
         if(m_window.key_mc)
         {
            addWidget(this.m_keyFrame = new ZwFrame(m_window.key_mc));
            this.m_keyFrame.addWidget(new ZwTextField(this.m_keyFrame.element.key_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.KEY_SUFFIX)));
         }
         if(m_window.progress_mc)
         {
            addWidget(this.m_progressFrame = new ZwFrame(m_window.progress_mc));
            this.setupDecoAnimationFrame();
            this.setupTicketsCollectionFrame();
            this.setupMilestoneFrames();
            this.setupProgressBar();
            this.setupDecoText();
            this.showNextMilestoneCard();
            this.showMilestoneCheckMarks();
         }
         if(m_window.rewards_mc)
         {
            this.m_rewardFrame = new ZwFrame(m_window.rewards_mc);
            addWidget(this.m_rewardFrame);
            this.setupRewardsOverlay();
            this.manager.hideRewardsOverlay();
            this.displayOverlayRewardCards();
            this.displayRewardBackgroundAnimation();
         }
         if(m_window.chestPeek_mc)
         {
            addWidget(this.m_chestPeekFrame = new ZwFrame(m_window.chestPeek_mc));
            this.setupChestPeekFrame();
         }
         if(m_window.whatisthis_mc)
         {
            addWidget(new FarmAnimatedButton(m_window.whatisthis_mc,this.onClickMoreInfo));
         }
      }
      
      private function setupDecoAnimationFrame() : void
      {
         if(this.m_progressFrame.element.interactable_mc)
         {
            this.m_progressFrame.addWidget(this.m_decoAnimationFrame = new ZwFrame(this.m_progressFrame.element.interactable_mc));
            this.m_decoAnimationFrame.addWidget(new FarmButton(this.m_decoAnimationFrame.element.close_bt,this.hideDecoAnimation));
            this.hideDecoAnimation();
         }
      }
      
      public function refreshCurrencyCount() : void
      {
         this.progressMeter = this.manager.playerTicketCount;
         this.m_currencyCount.text = "x" + this.manager.playerTicketCount;
      }
      
      private function hideDecoAnimation(e:Event = null) : void
      {
         this.m_decoAnimationFrame.visible = false;
         (this.m_progressFrame.element.interactable_mc as MovieClip).stop();
      }
      
      private function displayDecoAnimation(e:Event = null) : void
      {
         this.m_decoAnimationFrame.visible = true;
         MovieClipUtils.recursivePlay(this.m_progressFrame.element.interactable_mc as MovieClip);
      }
      
      private function onClickMoreInfo(e:Event) : void
      {
         super.showTutorial();
      }
      
      public function set rewardsOverlayVisibility(value:Boolean) : void
      {
         if(this.m_rewardFrame)
         {
            this.m_rewardFrame.visible = value;
         }
      }
      
      private function get milestoneFrames() : Array
      {
         return this.m_milestoneFrames;
      }
      
      private function setupChestPeekFrame() : void
      {
         if(this.m_chestPeekFrame.element.chestReward_mc)
         {
            this.m_chestPeekFrame.addWidget(new ZwFrame(this.m_chestPeekFrame.element.chestReward_mc));
            this.m_chestPeekFrame.addWidget(new FarmAnimatedTextButton(this.m_chestPeekFrame.element.task_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.PEEK_BTN_SUFFIX),this.manager.showRewardsOverlay));
            (this.m_chestPeekFrame.element.chestReward_mc as MovieClip).stop();
            if(this.manager.currentMilestone > 0)
            {
               if(this.manager.lastSeenReward < this.manager.currentMilestone)
               {
                  this.displayRewardChestAnimation();
               }
               else
               {
                  (this.m_chestPeekFrame.element.chestReward_mc as MovieClip).gotoAndStop(this.getRewardFrame(this.manager.currentMilestone));
               }
            }
         }
      }
      
      private function displayRewardChestAnimation() : void
      {
         (this.m_chestPeekFrame.element.chestReward_mc as MovieClip).gotoAndPlay(this.getRewardFrame(this.manager.lastSeenReward));
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function getRewardFrame(reward:int) : int
      {
         return (reward + 1) * this.BUFFER_FRAMES + 1;
      }
      
      private function setupDecoText() : void
      {
         if(this.m_progressFrame.element.deco1_tf)
         {
            this.m_progressFrame.addWidget(new ZwTextField(this.m_progressFrame.element.deco1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.DECO_TITLE_SUFFIX)));
            this.m_progressFrame.addWidget(new FarmAnimatedTextButton(this.m_progressFrame.element.show_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.DECO_BTN_SUFFIX),this.displayDecoAnimation));
         }
      }
      
      private function setupRewardsOverlay() : void
      {
         if(this.m_rewardFrame.element.description1_tf)
         {
            this.m_rewardFrame.addWidget(new ZwTextField(this.m_rewardFrame.element.description1_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.REWARD_OVERLAY_TITLE_SUFFIX)));
         }
         if(this.m_rewardFrame.element.close_bt)
         {
            this.m_rewardFrame.addWidget(new FarmAnimatedTextButton(this.m_rewardFrame.element.close_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.REWARD_CLOSE_SUFFIX),this.manager.hideRewardsOverlay));
         }
         if(this.m_rewardFrame.element.chestProgress_mc)
         {
            this.m_rewardFrame.addWidget(new ZwFrame(this.m_rewardFrame.element.chestProgress_mc));
            (this.m_rewardFrame.element.chestProgress_mc as MovieClip).stop();
         }
      }
      
      private function displayRewardBackgroundAnimation() : void
      {
         var currentRewardFrame:ZwFrame = this.m_rewardFrames[this.manager.currentMilestone - 1];
         if(!currentRewardFrame)
         {
            return;
         }
         currentRewardFrame.element.ray_mc.visible = true;
      }
      
      private function onEnterFrame(e:Event) : void
      {
         var clip:MovieClip = this.m_chestPeekFrame.element.chestReward_mc as MovieClip;
         if(clip.currentFrame >= this.getRewardFrame(this.manager.currentMilestone))
         {
            clip.stop();
            this.manager.showRewardsOverlay();
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.manager.lastSeenReward = this.manager.currentMilestone;
         }
      }
      
      private function displayOverlayRewardCards() : void
      {
         var rewardSlot:String = null;
         var icon:FarmIcon = null;
         var rewardFrame:ZwFrame = null;
         for(var i:int = 1; i <= this.manager.currentMilestone; i++)
         {
            rewardSlot = "item_" + i + "_mc";
            rewardFrame = new ZwFrame(this.m_rewardFrame.element[rewardSlot]);
            rewardFrame.addWidget(icon = new FarmIcon(rewardFrame.element.icon_mc) as FarmIcon);
            rewardFrame.addWidget(new ZwFrame(rewardFrame.element.ray_mc),false);
            icon.loadIcon(this.manager.getRewardIconUrl(i - 1));
            this.m_rewardFrames.push(rewardFrame);
            this.m_rewardFrame.addWidget(rewardFrame);
         }
      }
      
      private function setupTicketsCollectionFrame() : void
      {
         if(this.m_progressFrame.element.totalCount_mc)
         {
            this.m_progressFrame.addWidget(this.m_progressRequestFrame = new ZwFrame(m_window.progress_mc.totalCount_mc));
            if(this.m_progressRequestFrame.element.totalCount_tf)
            {
               this.m_progressRequestFrame.addWidget(this.m_currencyCount = new ZwTextField(this.m_progressRequestFrame.element.totalCount_tf,"x" + this.manager.playerTicketCount));
               this.m_progressRequestFrame.addWidget(this.m_askBtn = new FarmAnimatedTextButton(this.m_progressRequestFrame.element.ask_bt,this.ASK_BTN_TEXT,this.onAskButtonClick));
               this.refreshAskButton();
               this.m_progressRequestFrame.addWidget(this.m_requestBtn = new FarmAnimatedTextButton(this.m_progressRequestFrame.element.request_bt,this.REQUEST_BTN_TEXT,this.manager.requestTickets));
            }
         }
      }
      
      public function onAskButtonClick(e:Event) : void
      {
         if(this.m_askBtn.enabled)
         {
            this.m_askBtn.enabled = false;
            this.manager.askForTickets();
            this.refreshAskButton();
         }
      }
      
      public function refreshAskButton() : void
      {
         var timeRemaining:Array = null;
         var xPostTimeRemaining:int = this.manager.getThrottleTimeRemaining(this.manager.ASK_FEED_FREQUENCY_KEY);
         if(xPostTimeRemaining > 0)
         {
            timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
            if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_askBtn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                  "hrs":timeRemaining[1],
                  "min":timeRemaining[2]
               }));
            }
            else
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_askBtn,"Ask again in " + timeRemaining[3] + " seconds");
            }
         }
         else
         {
            this.m_askBtn.enabled = true;
            this.m_askBtn.detachTooltip();
         }
      }
      
      private function setupMilestoneFrames() : void
      {
         var stageMCName:String = null;
         var milestoneFrame:ZwFrame = null;
         for(var i:int = 1; i <= this.manager.milestones.length; i++)
         {
            stageMCName = "count_" + i + "_mc";
            if(this.m_progressFrame.element.hasOwnProperty(stageMCName))
            {
               milestoneFrame = new ZwFrame(this.m_progressFrame.element[stageMCName]);
               milestoneFrame.addWidget(new ZwTextField(milestoneFrame.element.count_tf,"x" + this.manager.getTicketsForMilestone(i)));
               this.m_progressFrame.addWidget(milestoneFrame);
               this.m_milestoneFrames.push(milestoneFrame);
            }
         }
      }
      
      private function setupProgressBar() : void
      {
         if(this.m_progressFrame.element.progressBar_mc)
         {
            this.m_progressBar = new FarmProgressBar(this.m_progressFrame.element.progressBar_mc);
            this.m_progressBar.minimum = 0;
            this.m_progressBar.maximum = this.manager.MaxTickets;
            this.progressMeter = this.manager.playerTicketCount;
            this.m_progressFrame.addWidget(this.m_progressBar);
            this.m_progressBar.animated = true;
         }
      }
      
      public function set progressMeter(value:Number) : void
      {
         this.m_progressBar.progress = value;
      }
      
      public function showNextMilestoneCard() : void
      {
         var icon:FarmIcon = null;
         if(isNaN(this.manager.nextMilestone) || this.manager.nextMilestone == 0 || this.manager.nextMilestone == this.manager.milestones.length)
         {
            return;
         }
         var nextFrame:ZwFrame = this.milestoneFrames[this.manager.nextMilestone - 1];
         nextFrame.addWidget(new ZwFrame(nextFrame.element.reward_mc));
         nextFrame.addWidget(icon = new FarmIcon(nextFrame.element.reward_mc.icon_mc) as FarmIcon);
         icon.loadIcon(this.manager.getRewardIconUrl(this.manager.nextMilestone - 1));
      }
      
      public function showMilestoneCheckMarks() : void
      {
         for(var i:int = 0; i < this.manager.currentMilestone; i++)
         {
            if(this.milestoneFrames[i])
            {
               this.milestoneFrames[i].element.completeIcon_mc.visible = true;
            }
         }
      }
      
      protected function get manager() : XBOPremarketingManager
      {
         return XBOPremarketingManager.instance();
      }
      
      override protected function hideTutorial() : void
      {
         super.hideTutorial();
         this.manager.displayGrantPopup();
      }
      
      override protected function release() : void
      {
         this.m_chestPeekFrame = null;
         this.m_progressFrame = null;
         this.m_rewardFrame = null;
         this.m_rewardFrames = null;
         this.m_progressRequestFrame = null;
         this.m_askBtn = null;
         this.m_requestBtn = null;
         this.m_milestoneFrames = null;
         this.m_progressBar = null;
         this.m_keyFrame = null;
         this.m_npcFrame = null;
         this.m_decoAnimationFrame = null;
         super.release();
      }
   }
}

