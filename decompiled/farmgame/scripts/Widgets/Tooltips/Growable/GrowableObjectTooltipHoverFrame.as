package Widgets.Tooltips.Growable
{
   import Classes.Friend;
   import Classes.Growable.GrowableConstants;
   import Classes.Growable.GrowableContest;
   import Classes.Growable.GrowableInstanceDataProxy;
   import Classes.Growable.GrowableUIHelper;
   import Classes.Growable.IGrowableResource;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Managers.GrowableContestManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.Market.MarketTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gs.TweenLite;
   
   public class GrowableObjectTooltipHoverFrame extends ZwFrame
   {
      
      private const FEATURE_DIALOG_PREFIX:String = "Window_";
      
      private const PROGRESS_TIMER_HIDE_DELAY:int = 5000;
      
      private var m_growableResource:IGrowableResource = null;
      
      private var m_contest:GrowableContest;
      
      private var m_friendIcon:FarmIcon;
      
      private var m_partnerId:String;
      
      private var m_progressBar:FarmProgressBar;
      
      private var m_noFriendIcon:ZwWidget;
      
      private var m_hitArea:ZwWidget;
      
      private var m_background:ZwWidget;
      
      private var m_feedButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_nudgeButton:FarmAnimatedTextButton;
      
      private var m_completeButton:FarmAnimatedCashButton;
      
      private var m_weighButton:FarmAnimatedTextButton;
      
      private var m_addFriendButton:FarmAnimatedTextButton;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_statusTextField:ZwTextField;
      
      private var m_friendlyNameTextField:ZwTextField;
      
      private var m_partnerNameText:ZwTextField;
      
      private var m_consumableProgressTextField:ZwTextField;
      
      private var m_progressHideTimer:Timer;
      
      private var m_askForChowPending:Boolean;
      
      private var m_isFrictionlessBuyFeed:Boolean;
      
      private var m_isFrictionlessBuyFeedPending:Boolean;
      
      public function GrowableObjectTooltipHoverFrame(element:DisplayObject, resource:IGrowableResource)
      {
         var toolTipText:String = null;
         this.m_partnerId = String(NaN);
         super(element);
         this.m_growableResource = resource;
         this.m_contest = GrowableContestManager.instance.getContestForInstance(resource);
         GrowableInstanceDataProxy.getInstanceForResource(resource).addEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
         if(ObjectUtil.pathExists(m_element,"pigName_tf"))
         {
            this.m_friendlyNameTextField = new ZwTextField(m_element["pigName_tf"],ZLocUtils.tk_pk_asTitle(this.m_growableResource.growableMapResource.getItemFriendlyName()));
            addWidget(this.m_friendlyNameTextField);
         }
         if(ObjectUtil.pathExists(m_element,"partners_tf"))
         {
            this.m_partnerNameText = new ZwTextField(m_element["partners_tf"],ZLocUtils.tk_pk_asTitle(this.m_growableResource.growableMapResource.getItemFriendlyName()));
            addWidget(this.m_partnerNameText);
         }
         if(ObjectUtil.pathExists(m_element,"noFriend_mc"))
         {
            this.m_noFriendIcon = addWidget(new ZwWidget(m_element["noFriend_mc"])) as ZwWidget;
         }
         if(ObjectUtil.pathExists(m_element,"addFriends_bt"))
         {
            this.m_addFriendButton = addWidget(new FarmAnimatedTextButton(m_element["addFriends_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "AddFriend"),this.handleInvitePartnerClicked)) as FarmAnimatedTextButton;
            toolTipText = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "AddFriendToolTip");
            if(toolTipText)
            {
               this.m_addFriendButton.attachTooltip(new MarketTooltip(toolTipText));
            }
         }
         if(ObjectUtil.pathExists(m_element,"nudge_bt"))
         {
            this.m_nudgeButton = addWidget(new FarmAnimatedTextButton(m_element["nudge_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Nudge"),this.handleNudgeButtonClicked)) as FarmAnimatedTextButton;
         }
         if(ObjectUtil.pathExists(m_element,"timeLeft_tf"))
         {
            this.m_statusTextField = addWidget(new ZwTextField(m_element["timeLeft_tf"])) as ZwTextField;
         }
         if(ObjectUtil.pathExists(m_element,"partnerCopy_tf"))
         {
            this.m_consumableProgressTextField = new ZwTextField(m_element["partnerCopy_tf"]);
            addWidget(this.m_consumableProgressTextField);
            this.m_consumableProgressTextField.alpha = 0;
            this.m_consumableProgressTextField.enabled = false;
         }
         if(ObjectUtil.pathExists(m_element,"meter_mc"))
         {
            this.m_progressBar = addWidget(new FarmProgressBar(m_element["meter_mc"])) as FarmProgressBar;
            (m_element["meter_mc"] as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.progressBarMouseOverHandler);
            (m_element["meter_mc"] as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.progressBarMouseOutHandler);
            this.m_progressHideTimer = new Timer(this.PROGRESS_TIMER_HIDE_DELAY,1);
            this.m_progressHideTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.hideGrowableProgressTimerComplete);
         }
         if(ObjectUtil.pathExists(m_element,"complete_bt"))
         {
            this.m_completeButton = addWidget(new FarmAnimatedCashButton(m_element["complete_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Complete"),"100",this.handleCompleteButtonClicked)) as FarmAnimatedCashButton;
         }
         if(ObjectUtil.pathExists(m_element,"feed_bt"))
         {
            this.m_feedButton = addWidget(new FarmAnimatedTextButton(m_element["feed_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Feed"),this.handleFeedButtonClicked)) as FarmAnimatedTextButton;
         }
         if(ObjectUtil.pathExists(m_element,"ask_bt"))
         {
            this.m_askButton = addWidget(new FarmAnimatedTextButton(m_element["ask_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Ask"),this.handleAskForChowButtonClicked)) as FarmAnimatedTextButton;
         }
         if(ObjectUtil.pathExists(m_element,"buyFeed_mc"))
         {
            this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element["buyFeed_mc"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Feed"),"1",this.handleBuyAndFeedButtonClicked)) as FarmAnimatedCashButton;
         }
         if(ObjectUtil.pathExists(m_element,"weigh_bt"))
         {
            this.m_weighButton = addWidget(new FarmAnimatedTextButton(m_element["weigh_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Weigh"),this.handleWeighButtonClicked)) as FarmAnimatedTextButton;
         }
         if(ObjectUtil.pathExists(m_element,"back_mc"))
         {
            m_element.addChildAt(m_element["back_mc"],0);
            this.m_background = addWidget(new ZwWidget(m_element["back_mc"])) as ZwWidget;
         }
         if(ObjectUtil.pathExists(m_element,"hit_mc"))
         {
            this.m_hitArea = addWidget(new ZwWidget(m_element["hit_mc"])) as ZwWidget;
            this.m_hitArea.visible = false;
         }
         this.refreshUI();
      }
      
      private function handleInstanceDataChanged(e:Event) : void
      {
         this.refreshUI();
      }
      
      public function refreshUI() : void
      {
         var buttonsShouldBeEnabled:Boolean = false;
         var consumableCount:int = 0;
         var consumableConsumedMax:int = 0;
         var completionCost:int = 0;
         var consumableConsumed:int = 0;
         var isCompleted:Boolean = false;
         if(this.contestEntry != null)
         {
            buttonsShouldBeEnabled = !this.m_growableResource.lockFlag;
            this.m_buyButton.visible = false;
            this.m_feedButton.visible = false;
            this.m_weighButton.visible = false;
            this.m_completeButton.visible = false;
            this.m_askButton.visible = false;
            this.m_friendlyNameTextField.text = ZLocUtils.tk_pk_asTitle(this.m_growableResource.growableMapResource.getItemFriendlyName());
            consumableCount = this.m_contest.getConsumableCount();
            consumableConsumedMax = this.m_growableResource.maximumFedCount;
            completionCost = this.m_growableResource.completionCash;
            consumableConsumed = Math.max(this.m_progressBar.progress,this.m_growableResource.totalFedCount);
            isCompleted = this.m_growableResource.checkAgeExpired() || !this.m_growableResource.canStillGrow();
            this.m_progressBar.progress = consumableConsumed;
            this.m_consumableProgressTextField.text = ZLocUtils.t("Dialogs","Growable_ConsumableProgress",{
               "chow":String(consumableConsumed),
               "chowCapacity":String(consumableConsumedMax)
            });
            this.setPartnerId(this.contestEntry.partner,isCompleted);
            if(isCompleted)
            {
               this.m_statusTextField.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "ExpiredStatus");
               this.m_weighButton.visible = true;
               this.m_noFriendIcon.visible = false;
               this.m_addFriendButton.visible = false;
               this.m_nudgeButton.visible = false;
               this.toggleButton(this.m_weighButton,buttonsShouldBeEnabled);
            }
            else
            {
               this.m_statusTextField.text = this.m_growableResource.getTimeTilExpire(false,true);
               this.m_completeButton.visible = true;
               this.m_completeButton.setAmountText(String(completionCost));
               this.toggleButton(this.m_completeButton,buttonsShouldBeEnabled);
               if(consumableCount > 0)
               {
                  this.m_feedButton.visible = true;
                  this.toggleButton(this.m_feedButton,buttonsShouldBeEnabled);
               }
               else if(this.m_contest.canPostFeed(GrowableContest.FEED_TYPE_GENERAL))
               {
                  this.m_askButton.visible = true;
                  this.toggleButton(this.m_askButton,buttonsShouldBeEnabled && !this.m_askForChowPending);
               }
               else
               {
                  this.m_buyButton.visible = true;
                  this.toggleButton(this.m_buyButton,buttonsShouldBeEnabled && !this.m_isFrictionlessBuyFeedPending);
               }
            }
         }
         else
         {
            m_element.visible = false;
         }
      }
      
      private function setPartnerId(partnerId:String, isCompleted:Boolean) : void
      {
         var friend:Friend = null;
         if(partnerId != this.m_partnerId)
         {
            this.m_partnerId = partnerId;
            if(this.m_friendIcon)
            {
               removeWidget(this.m_friendIcon);
            }
            this.m_noFriendIcon.visible = false;
            this.m_partnerNameText.visible = false;
            this.m_addFriendButton.visible = false;
            this.m_nudgeButton.visible = false;
            if(partnerId != "0")
            {
               friend = Global.friendManager.getFriendData(partnerId);
               if(friend != null)
               {
                  this.m_partnerNameText.text = friend.name;
                  if(ObjectUtil.pathExists(m_element,"icon_mc"))
                  {
                     this.m_friendIcon = new FarmIcon(m_element["icon_mc"],friend.picture);
                     addWidget(this.m_friendIcon);
                  }
                  this.m_partnerNameText.visible = true;
               }
               this.m_nudgeButton.visible = true;
            }
            else
            {
               this.m_noFriendIcon.visible = true;
               this.m_addFriendButton.visible = true;
               this.toggleButton(this.m_addFriendButton,!isCompleted);
            }
         }
         if(partnerId != "0")
         {
            this.toggleButton(this.m_nudgeButton,!isCompleted && this.m_contest.canPostFeed(GrowableContest.FEED_TYPE_REMIND,this.m_partnerId.toString()));
         }
      }
      
      public function get backgroundWidget() : ZwWidget
      {
         return this.m_background;
      }
      
      private function get contestEntry() : Object
      {
         return this.m_contest.getContestEntryForKey(this.m_growableResource.persistentDataKey);
      }
      
      private function get instanceData() : Object
      {
         return this.m_growableResource.getGrowableInstanceData();
      }
      
      private function handleInvitePartnerClicked(e:MouseEvent) : void
      {
         this.m_contest.makePartnerRequest(this.m_growableResource.persistentDataKey);
         this.refreshUI();
         this.statCount("invite_friend");
      }
      
      private function handleNudgeButtonClicked(e:Object) : void
      {
         if(this.m_partnerId != "0")
         {
            this.m_contest.postGeneralFeed(GrowableContest.FEED_TYPE_REMIND,this.handleNudgeButtonCallback,String(this.m_partnerId));
         }
         this.refreshUI();
         this.statCount("nudge");
      }
      
      private function handleNudgeButtonCallback(postSuccessful:Boolean) : void
      {
         this.refreshUI();
      }
      
      private function handleCompleteButtonClicked(e:MouseEvent) : void
      {
         GrowableUIHelper.promptAndCompleteAnimal(this.m_growableResource,this.handleCompleteButtonCallback);
         this.statCount("complete_now_click");
      }
      
      private function handleCompleteButtonCallback(result:Object) : void
      {
         this.refreshUI();
      }
      
      private function handleAskForChowButtonClicked(e:Object) : void
      {
         if(this.m_contest.canPostFeed(GrowableContest.FEED_TYPE_GENERAL))
         {
            this.m_askForChowPending = true;
            this.m_contest.postGeneralFeed(GrowableContest.FEED_TYPE_GENERAL,this.handleAskForChowButtonCallback);
         }
         this.refreshUI();
         this.statCount("ask_for_chow");
      }
      
      private function handleAskForChowButtonCallback(result:Boolean) : void
      {
         this.m_askForChowPending = false;
         this.refreshUI();
      }
      
      private function handleFeedButtonClicked(e:MouseEvent) : void
      {
         this.m_isFrictionlessBuyFeed = false;
         this.m_growableResource.feedConsumable(1,this.handleFeedButtonCallback,false);
         this.refreshUI();
         this.statCount("feed_chow");
      }
      
      private function handleFeedButtonCallback(result:Object) : void
      {
         this.showGrowableProgress();
         this.refreshUI();
      }
      
      private function handleBuyAndFeedButtonClicked(e:MouseEvent) : void
      {
         this.m_isFrictionlessBuyFeedPending = true;
         GrowableUIHelper.promptAndFeedConsumable(this.m_growableResource,this.handleBuyAndFeedButtonCallback,true,!this.m_isFrictionlessBuyFeed);
         this.refreshUI();
         this.statCount("buy_feed_chow");
         if(!this.m_isFrictionlessBuyFeed)
         {
            this.statCount("buy_feed_chow_prompt");
         }
      }
      
      private function handleBuyAndFeedButtonCallback(result:Object) : void
      {
         this.m_isFrictionlessBuyFeedPending = false;
         if(result.hasOwnProperty("frictionlessGranted") && result.frictionlessGranted == true)
         {
            if(!this.m_isFrictionlessBuyFeed)
            {
               this.statCount("buy_feed_chow_accepted");
            }
            this.m_isFrictionlessBuyFeed = true;
         }
         this.showGrowableProgress();
         this.refreshUI();
      }
      
      private function handleWeighButtonClicked(e:MouseEvent) : void
      {
         this.m_contest.weighObject(this.instanceData);
         parent.hideAllFrames();
         this.statCount("weigh_entry");
      }
      
      private function showGrowableProgress(autoHide:Boolean = true) : void
      {
         this.m_consumableProgressTextField.enabled = true;
         TweenLite.to(this.m_consumableProgressTextField,0.5,{"alpha":1});
         this.m_progressHideTimer.reset();
         if(autoHide)
         {
            this.m_progressHideTimer.start();
         }
      }
      
      private function progressBarMouseOverHandler(e:Event) : void
      {
         this.showGrowableProgress(false);
      }
      
      private function progressBarMouseOutHandler(e:Event) : void
      {
         this.showGrowableProgress();
      }
      
      private function hideGrowableProgressTimerComplete(e:Event) : void
      {
         TweenLite.to(this.m_consumableProgressTextField,1,{"alpha":0});
         this.m_consumableProgressTextField.enabled = false;
      }
      
      override public function release() : void
      {
         this.m_progressHideTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.hideGrowableProgressTimerComplete);
         (m_element["meter_mc"] as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.progressBarMouseOverHandler);
         (m_element["meter_mc"] as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.progressBarMouseOutHandler);
         GrowableInstanceDataProxy.getInstanceForResource(this.m_growableResource).removeEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
         this.m_progressBar = null;
         this.m_noFriendIcon = null;
         this.m_hitArea = null;
         this.m_background = null;
         this.m_feedButton = null;
         this.m_buyButton = null;
         this.m_nudgeButton = null;
         this.m_completeButton = null;
         this.m_weighButton = null;
         this.m_addFriendButton = null;
         this.m_askButton = null;
         this.m_statusTextField = null;
         this.m_friendlyNameTextField = null;
         this.m_consumableProgressTextField = null;
         this.m_partnerNameText = null;
         this.m_friendIcon = null;
         this.m_progressHideTimer = null;
         super.release();
      }
      
      public function show() : void
      {
         if(!visible)
         {
            this.statCount("impressions");
            visible = true;
         }
      }
      
      public function hide() : void
      {
         visible = false;
      }
      
      public function statCount(phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         this.m_contest.statCount("contest_menu",phylum,zclass,family,genus,value);
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
   }
}

