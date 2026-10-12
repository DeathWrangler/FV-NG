package Widgets.Slots
{
   import Classes.Friend;
   import Classes.Growable.GrowableConstants;
   import Classes.Growable.GrowableContest;
   import Classes.Growable.GrowableInstanceDataProxy;
   import Classes.Growable.GrowableResourceDelegate;
   import Classes.Growable.GrowableUIHelper;
   import Classes.Growable.IGrowableResource;
   import Classes.GrowableAnimal;
   import Classes.ZItem.FarmItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.DynamicObjectEvent;
   import Managers.GrowableContestManager;
   import Transactions.TGrowableUnlockSlot;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleMode;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.GrowableContestWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gs.TweenLite;
   
   public class GrowableObjectBaseSlot extends ZwSlotFrame
   {
      
      public static const LOCKED_BUTTON_CLICKED:String = "GrowableObjectBaseSlot.LockedSlotBuy";
      
      public static const NUDGE_BUTTON_CLICKED:String = "GrowableObjectBaseSlot.Nudge";
      
      private const PROGRESS_TIMER_HIDE_DELAY:int = 5000;
      
      private const TRANSITION_EFFECT_FADE_OUT_DELAY:int = 3;
      
      private const FEATURE_DIALOG_PREFIX:String = "BaseSlotFrame_";
      
      private var m_friendlyNameTextField:ZwTextField;
      
      private var m_statusTextField:ZwTextField;
      
      private var m_totalFeedCounter:ZwTextField;
      
      private var m_partnerLabelTextField:ZwTextField;
      
      private var m_acceptFriendLabelTextField:ZwTextField;
      
      private var m_objectPreview:ObjectPreviewFrame;
      
      private var m_lockedWidget:ZwWidget;
      
      private var m_lockedSlotState:ZwWidget;
      
      private var m_unusedSlotState:ZwWidget;
      
      private var m_effect:ZwWidget;
      
      private var m_noFriendWidget:ZwWidget;
      
      private var m_progressBar:FarmProgressBar = null;
      
      private var m_progressBarElement:MovieClip;
      
      private var m_onboardingArrow:ZwWidget;
      
      private var m_slotBg:ZwFrame;
      
      private var m_objectPreviewForeground:ZwWidget;
      
      private var m_objectPreviewBackground:ZwWidget;
      
      private var m_friendIcon:FarmIcon;
      
      private var m_buyFeedButton:FarmAnimatedCashButton;
      
      private var m_weighButton:FarmAnimatedTextButton;
      
      private var m_unlockButton:FarmAnimatedCashButton;
      
      private var m_feedButton:FarmAnimatedTextButton;
      
      private var m_acceptButton:FarmAnimatedTextButton;
      
      private var m_startButton:FarmAnimatedTextButton;
      
      private var m_addFriendsButton:FarmAnimatedTextButton;
      
      private var m_nopeButton:FarmAnimatedTextButton;
      
      private var m_nudgeButton:FarmAnimatedTextButton;
      
      private var m_completeButton:FarmAnimatedCashButton;
      
      private var m_contest:GrowableContest;
      
      private var m_window:GrowableContestWindow;
      
      private var m_fakeMapResource:GrowableAnimal = null;
      
      private var m_instanceResource:GrowableAnimal = null;
      
      private var m_data:Object;
      
      private var m_objectState:String = null;
      
      private const OBJECT_STATE_PLACE:String = "place";
      
      private const OBJECT_STATE_GROW:String = "grow";
      
      private const OBJECT_STATE_WEIGH:String = "weigh";
      
      private const OBJECT_STATE_PARTNER:String = "neighbor";
      
      private const OBJECT_STATE_COMPLETE_NOW:String = "complete";
      
      private const OBJECT_STATE_PARTNER_REQUEST:String = "partnerRequest";
      
      private var m_partnerId:String;
      
      private var m_previousState:String;
      
      private var m_visitedStages:Object;
      
      private var m_isFrictionlessBuyFeed:Boolean;
      
      private var m_isFrictionlessBuyFeedPending:Boolean;
      
      private var m_progressHideTimer:Timer;
      
      private var m_isPartnerRequest:Boolean;
      
      private var m_refreshAction:uint = 0;
      
      private const REFRESH_ACTION_NONE:uint = 0;
      
      private const REFRESH_ACTION_WEIGH:uint = 1;
      
      private var m_isOnboarding:Boolean;
      
      private var m_instanceDataProxy:GrowableInstanceDataProxy;
      
      public function GrowableObjectBaseSlot(window:GrowableContestWindow, element:DisplayObject, contest:GrowableContest, isOnboarding:Boolean = false)
      {
         this.m_window = window;
         this.m_contest = contest;
         this.m_isOnboarding = isOnboarding;
         super(element);
         if(ObjectUtil.pathExists(m_element,"back_mc"))
         {
            this.m_slotBg = new ZwFrame(m_element["back_mc"]);
            addWidget(this.m_slotBg);
         }
         if(ObjectUtil.pathExists(m_element,"pigName_tf"))
         {
            this.m_friendlyNameTextField = new ZwTextField(m_element["pigName_tf"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "DefaultName"));
            addWidget(this.m_friendlyNameTextField);
         }
         if(ObjectUtil.pathExists(m_element,"timeLeft_tf"))
         {
            this.m_statusTextField = new ZwTextField(m_element["timeLeft_tf"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "DefaultStatus"));
            addWidget(this.m_statusTextField);
         }
         if(ObjectUtil.pathExists(m_element,"partners_tf"))
         {
            this.m_partnerLabelTextField = new ZwTextField(m_element["partners_tf"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "DefaultPartnerLabel"));
            addWidget(this.m_partnerLabelTextField,false);
         }
         if(ObjectUtil.pathExists(m_element,"acceptFriend_tf"))
         {
            this.m_acceptFriendLabelTextField = new ZwTextField(m_element["acceptFriend_tf"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "PartnerHelp"));
            addWidget(this.m_acceptFriendLabelTextField,false);
         }
         if(ObjectUtil.pathExists(m_element,"partnerCopy_tf"))
         {
            this.m_totalFeedCounter = new ZwTextField(m_element["partnerCopy_tf"],"");
            addWidget(this.m_totalFeedCounter);
            this.m_totalFeedCounter.alpha = 0;
            this.m_totalFeedCounter.enabled = false;
         }
         if(ObjectUtil.pathExists(m_element,"lock_mc"))
         {
            this.m_lockedWidget = new ZwWidget(m_element["lock_mc"]);
            addWidget(this.m_lockedWidget);
         }
         if(ObjectUtil.pathExists(m_element,"effect_mc"))
         {
            this.m_effect = new ZwWidget(m_element["effect_mc"]);
            addWidget(this.m_effect);
            this.m_effect.element.gotoAndStop(2);
            this.m_effect.visible = false;
            this.m_effect.alpha = 1;
         }
         if(ObjectUtil.pathExists(m_element,"greyPig_mc"))
         {
            this.m_lockedSlotState = new ZwWidget(m_element["greyPig_mc"]);
            m_element["greyPig_mc"].generic_tf.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "UnlockPrompt");
            addWidget(this.m_lockedSlotState);
         }
         if(ObjectUtil.pathExists(m_element,"blackPig_mc"))
         {
            this.m_unusedSlotState = new ZwWidget(m_element["blackPig_mc"]);
            m_element["blackPig_mc"].generic_tf.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "StartPrompt");
            addWidget(this.m_unusedSlotState);
         }
         if(ObjectUtil.pathExists(m_element,"friendArrow_mc"))
         {
            this.m_onboardingArrow = new ZwWidget(m_element["friendArrow_mc"]);
            addWidget(this.m_onboardingArrow);
         }
         if(ObjectUtil.pathExists(m_element,"itemForeground_mc"))
         {
            this.m_objectPreviewForeground = new ZwWidget(m_element["itemForeground_mc"]);
            addWidget(this.m_objectPreviewForeground);
         }
         if(ObjectUtil.pathExists(m_element,"itemBackground_mc"))
         {
            this.m_objectPreviewBackground = new ZwWidget(m_element["itemBackground_mc"]);
            addWidget(this.m_objectPreviewBackground);
         }
         if(ObjectUtil.pathExists(m_element,"buyFeed_mc"))
         {
            this.m_buyFeedButton = new FarmAnimatedCashButton(m_element["buyFeed_mc"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "BuyFeed"),"1",this.handleBuyFeedButtonClicked);
            addWidget(this.m_buyFeedButton);
         }
         if(ObjectUtil.pathExists(m_element,"weigh_bt"))
         {
            this.m_weighButton = new FarmAnimatedTextButton(m_element["weigh_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Weigh"),this.handleWeighButtonClicked);
            addWidget(this.m_weighButton);
         }
         if(ObjectUtil.pathExists(m_element,"unlock_bt"))
         {
            this.m_unlockButton = new FarmAnimatedCashButton(m_element["unlock_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Unlock"),"00",this.handleUnlockButtonClicked);
            addWidget(this.m_unlockButton);
         }
         if(ObjectUtil.pathExists(m_element,"feed_bt"))
         {
            this.m_feedButton = new FarmAnimatedTextButton(m_element["feed_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Feed"),this.handleFeedButtonClicked);
            addWidget(this.m_feedButton);
         }
         if(ObjectUtil.pathExists(m_element,"accept_mc"))
         {
            this.m_acceptButton = new FarmAnimatedTextButton(m_element["accept_mc"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Accept"),this.handleAcceptButtonClicked);
            addWidget(this.m_acceptButton);
         }
         if(ObjectUtil.pathExists(m_element,"start_bt"))
         {
            this.m_startButton = new FarmAnimatedTextButton(m_element["start_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Start"),this.handleStartButtonClicked);
            addWidget(this.m_startButton);
         }
         if(ObjectUtil.pathExists(m_element,"nudge_bt"))
         {
            this.m_nudgeButton = new FarmAnimatedTextButton(m_element["nudge_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Nudge"),this.handleNudgeButtonClicked);
            addWidget(this.m_nudgeButton);
         }
         if(ObjectUtil.pathExists(m_element,"complete_bt"))
         {
            this.m_completeButton = new FarmAnimatedCashButton(m_element["complete_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Complete"),"100",this.handleCompleteButtonClicked);
            addWidget(this.m_completeButton);
         }
         if(ObjectUtil.pathExists(m_element,"meter_mc"))
         {
            this.m_progressBarElement = m_element["meter_mc"];
            this.m_progressBarElement.addEventListener(MouseEvent.MOUSE_OVER,this.progressBarMouseOverHandler);
            this.m_progressBarElement.addEventListener(MouseEvent.MOUSE_OUT,this.progressBarMouseOutHandler);
            this.m_progressBar = new FarmProgressBar(this.m_progressBarElement);
            addWidget(this.m_progressBar);
         }
         if(ObjectUtil.pathExists(m_element,"addFriends_bt"))
         {
            this.m_addFriendsButton = new FarmAnimatedTextButton(m_element["addFriends_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "AddFriends"),this.handleAddFriendsButtonClicked);
            addWidget(this.m_addFriendsButton);
         }
         if(ObjectUtil.pathExists(m_element,"nope_bt"))
         {
            this.m_nopeButton = new FarmAnimatedTextButton(m_element["nope_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Nope"),this.handleNopeButtonClicked);
            addWidget(this.m_nopeButton);
         }
         if(ObjectUtil.pathExists(m_element,"noFriend_mc"))
         {
            this.m_noFriendWidget = new ZwWidget(m_element["noFriend_mc"]);
            addWidget(this.m_noFriendWidget);
         }
         this.m_window.addEventListener(LOCKED_BUTTON_CLICKED,this.handleLockedSlotBought);
         this.m_window.addEventListener(NUDGE_BUTTON_CLICKED,this.handleNudgeEventTriggered);
         this.m_progressHideTimer = new Timer(this.PROGRESS_TIMER_HIDE_DELAY,1);
         this.m_progressHideTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.hidePigProgressTimerComplete);
      }
      
      private function get hasPartnerActionPending() : Boolean
      {
         var data:Object = null;
         var result:Boolean = false;
         if(this.m_fakeMapResource != null)
         {
            data = this.m_contest.getContestEntryForKey(this.m_fakeMapResource.persistentDataKey);
            if(data != null)
            {
               result = Boolean(data["pendingPartnerAction"]);
            }
         }
         return result;
      }
      
      override public function populate(data:Object) : void
      {
         if(this.m_instanceDataProxy)
         {
            this.m_instanceDataProxy.removeEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
            this.m_instanceDataProxy.removeEventListener(GrowableConstants.EVENT_STAGE_CHANGED,this.handleInstanceStageChanged);
            this.m_instanceDataProxy = null;
         }
         this.m_previousState = null;
         this.m_data = data;
         super.populate(data);
         this.hideAllWidgets();
         if(this.m_data["type"] == GrowableContest.OBJECT_TYPE_ACTIVE || this.m_data["type"] == GrowableContest.OBJECT_TYPE_REQUEST)
         {
            this.m_instanceDataProxy = GrowableInstanceDataProxy.getInstanceForKey(this.m_data.storageKey,this.m_data.code);
            this.m_visitedStages = {};
         }
         switch(this.m_data["type"])
         {
            case GrowableContest.OBJECT_TYPE_ACTIVE:
               this.setupObjectSlot();
               break;
            case GrowableContest.OBJECT_TYPE_REQUEST:
               this.setupRequestSlot();
               break;
            case GrowableContest.OBJECT_TYPE_LOCKED:
               this.setupLockedSlot();
               break;
            case GrowableContest.OBJECT_TYPE_UNLOCKED:
               this.setupUnlockedSlot();
         }
         if(this.m_instanceDataProxy)
         {
            this.m_instanceDataProxy.addEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
            this.m_instanceDataProxy.addEventListener(GrowableConstants.EVENT_STAGE_CHANGED,this.handleInstanceStageChanged);
         }
      }
      
      private function isPlaced() : Boolean
      {
         var placed:Boolean = false;
         if(this.m_data.hasOwnProperty("instanceId") && this.m_data.hasOwnProperty("world"))
         {
            if(Boolean(this.m_data.instanceId) && Boolean(this.m_data.world))
            {
               placed = true;
               GrowableContestManager.instance.donePlacing(this.m_data.storageKey);
            }
         }
         return placed;
      }
      
      private function needsPlaced() : Boolean
      {
         return !this.isPlaced() && !GrowableContestManager.instance.isPlacing(this.m_data.storageKey);
      }
      
      private function setupObjectSlot() : void
      {
         this.m_data["type"] = GrowableContest.OBJECT_TYPE_ACTIVE;
         this.m_isPartnerRequest = false;
         this.m_slotBg.visible = true;
         this.m_friendlyNameTextField.visible = true;
         this.m_statusTextField.visible = true;
         this.m_totalFeedCounter.visible = true;
         this.m_onboardingArrow.visible = this.m_isOnboarding;
         if(this.m_objectPreviewForeground)
         {
            this.m_objectPreviewForeground.visible = true;
         }
         if(this.m_objectPreviewBackground)
         {
            this.m_objectPreviewBackground.visible = true;
         }
         this.m_friendlyNameTextField.text = this.getObjectFriendlyName();
         this.setupImagePreview(this.m_data["code"],this.m_data["storageKey"]);
         this.m_instanceResource = null;
         if(this.m_data.hasOwnProperty("instanceId") && this.m_data.hasOwnProperty("world"))
         {
            if(Global.worldManager.currentWorldType == this.m_data["world"])
            {
               this.m_instanceResource = Global.world.getObjectById(this.m_data["instanceId"]) as GrowableAnimal;
            }
         }
         this.refreshFieldsAndButtons();
      }
      
      private function setupLockedSlot() : void
      {
         this.m_data["type"] = GrowableContest.OBJECT_TYPE_LOCKED;
         this.m_isPartnerRequest = false;
         this.m_lockedWidget.visible = true;
         this.m_lockedSlotState.visible = true;
         this.m_unlockButton.visible = true;
         this.m_unlockButton.setAmountText(this.m_data["price"]);
      }
      
      private function setupUnlockedSlot() : void
      {
         this.m_data["type"] = GrowableContest.OBJECT_TYPE_UNLOCKED;
         this.m_isPartnerRequest = false;
         this.m_startButton.visible = true;
         this.m_unusedSlotState.visible = true;
         this.m_lockedSlotState.visible = false;
         this.m_lockedWidget.visible = false;
         this.m_unlockButton.visible = false;
      }
      
      private function setupRequestSlot() : void
      {
         this.m_data["type"] = GrowableContest.OBJECT_TYPE_REQUEST;
         this.m_isPartnerRequest = true;
         this.m_slotBg.visible = true;
         this.m_nopeButton.visible = true;
         this.m_acceptButton.detachTooltip();
         this.setupImagePreview(this.m_data["code"],this.m_data["storageKey"]);
         this.m_totalFeedCounter.alpha = 0;
         this.m_totalFeedCounter.text = "";
         this.m_totalFeedCounter.enabled = false;
         this.m_friendlyNameTextField.visible = true;
         this.m_friendlyNameTextField.text = this.getObjectFriendlyName();
         this.m_statusTextField.visible = false;
         switch(this.m_data["inviteState"])
         {
            case "valid":
               this.toggleButton(this.m_nopeButton,true);
               this.m_statusTextField.text = this.m_fakeMapResource.getTimeTilExpire();
               this.m_nopeButton.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Nope");
               if(this.m_contest.availableCapacity() > 0)
               {
                  this.m_partnerLabelTextField.visible = true;
                  this.m_acceptFriendLabelTextField.visible = true;
                  this.m_acceptButton.visible = true;
                  this.toggleButton(this.m_acceptButton,true);
               }
               else
               {
                  this.m_acceptButton.visible = true;
                  this.simulateToggleButton(this.m_acceptButton,false);
                  this.m_acceptButton.attachTooltip(new FarmTextTooltip(this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "NoRoom")));
               }
               break;
            default:
               this.requestStatCount("inviteState","default");
            case "taken":
               this.m_statusTextField.visible = true;
               this.m_statusTextField.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "RequestExpired");
               this.m_acceptButton.visible = false;
               this.m_nopeButton.text = ZLocUtils.t("Dialogs","Okay");
               this.toggleButton(this.m_nopeButton,true);
               break;
            case "grown":
               this.m_statusTextField.visible = true;
               this.m_statusTextField.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "FullyGrown");
               this.m_acceptButton.visible = false;
               this.m_nopeButton.text = ZLocUtils.t("Dialogs","Okay");
               this.toggleButton(this.m_nopeButton,true);
         }
         if(this.m_data["partner"])
         {
            this.setupFriendPreview(this.m_data["partner"],false);
            if(this.m_friendIcon)
            {
               this.m_friendIcon.visible = true;
            }
         }
      }
      
      private function showPigProgress(autoHide:Boolean = true) : void
      {
         TweenLite.to(this.m_totalFeedCounter,0.5,{"alpha":1});
         this.m_progressHideTimer.reset();
         if(autoHide)
         {
            this.m_progressHideTimer.start();
         }
      }
      
      private function hidePigProgressTimerComplete(e:Event) : void
      {
         TweenLite.to(this.m_totalFeedCounter,1,{"alpha":0});
      }
      
      private function progressBarMouseOverHandler(e:Event) : void
      {
         this.showPigProgress(false);
      }
      
      private function progressBarMouseOutHandler(e:Event) : void
      {
         this.m_progressHideTimer.reset();
         this.m_progressHideTimer.start();
      }
      
      override public function release() : void
      {
         this.m_window.removeEventListener(LOCKED_BUTTON_CLICKED,this.handleLockedSlotBought);
         this.m_window.removeEventListener(NUDGE_BUTTON_CLICKED,this.handleNudgeEventTriggered);
         this.m_progressHideTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.hidePigProgressTimerComplete);
         if(this.m_progressBarElement)
         {
            this.m_progressBarElement.removeEventListener(MouseEvent.MOUSE_OVER,this.progressBarMouseOverHandler);
            this.m_progressBarElement.removeEventListener(MouseEvent.MOUSE_OUT,this.progressBarMouseOutHandler);
         }
         if(this.m_instanceDataProxy)
         {
            this.m_instanceDataProxy.removeEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
            this.m_instanceDataProxy.removeEventListener(GrowableConstants.EVENT_STAGE_CHANGED,this.handleInstanceStageChanged);
         }
         this.m_instanceDataProxy = null;
         TweenLite.killTweensOf(this.m_effect);
         TweenLite.killTweensOf(this.m_totalFeedCounter);
         this.m_friendlyNameTextField = null;
         this.m_statusTextField = null;
         this.m_totalFeedCounter = null;
         this.m_partnerLabelTextField = null;
         this.m_objectPreview = null;
         this.m_objectPreviewForeground = null;
         this.m_objectPreviewBackground = null;
         this.m_lockedWidget = null;
         this.m_lockedSlotState = null;
         this.m_unusedSlotState = null;
         this.m_effect = null;
         this.m_noFriendWidget = null;
         this.m_progressBar = null;
         this.m_friendIcon = null;
         this.m_buyFeedButton = null;
         this.m_weighButton = null;
         this.m_unlockButton = null;
         this.m_feedButton = null;
         this.m_acceptButton = null;
         this.m_startButton = null;
         this.m_addFriendsButton = null;
         this.m_nopeButton = null;
         this.m_nudgeButton = null;
         this.m_completeButton = null;
         this.m_contest = null;
         this.m_window = null;
         this.m_fakeMapResource = null;
         this.m_data = null;
         super.release();
      }
      
      private function setupImagePreview(code:String, key:String) : void
      {
         var obj:FarmItem = null;
         var newStage:String = null;
         if(this.m_fakeMapResource != null)
         {
            newStage = this.m_fakeMapResource.visibleStageName;
         }
         if(this.m_fakeMapResource == null || this.m_previousState != newStage)
         {
            if(this.m_fakeMapResource != null)
            {
               this.m_fakeMapResource.detach();
            }
            obj = Global.farmGameSettingsManager.getFarmItemByCode(code);
            this.m_fakeMapResource = new GrowableAnimal();
            this.m_fakeMapResource.setItem(obj);
            this.m_fakeMapResource.attachToPersistentData(key);
            this.m_fakeMapResource.setState(obj.getPreviewState());
            this.m_fakeMapResource.createDisplayObject();
            if(this.m_objectPreview)
            {
               removeWidget(this.m_objectPreview);
            }
            this.m_objectPreview = new ObjectPreviewFrame(m_element["pigImage_mc"],this.m_fakeMapResource.getItem(),null,[this.m_contest.objectPreviewScale],null,"","",this.m_fakeMapResource) as ObjectPreviewFrame;
            addWidget(this.m_objectPreview);
            newStage = this.m_fakeMapResource.visibleStageName;
            if(newStage == null || newStage == "")
            {
               newStage = "default";
            }
            if(this.m_visitedStages == null)
            {
               this.m_visitedStages = {};
            }
            if(this.m_visitedStages[newStage] != true)
            {
               this.m_fakeMapResource.refreshVisibleToActual(newStage);
               this.m_fakeMapResource.reloadImage();
               this.m_friendlyNameTextField.text = obj.friendlyTitle;
               this.m_visitedStages[newStage] = true;
            }
            this.m_previousState = newStage;
         }
      }
      
      private function getObjectFriendlyName() : String
      {
         var obj:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data["code"]);
         return obj.friendlyTitle;
      }
      
      private function handleInstanceDataChanged(e:Event) : void
      {
         this.refreshObjectSlot(this.m_fakeMapResource.getGrowableInstanceData());
         if(this.m_refreshAction == this.REFRESH_ACTION_WEIGH)
         {
            this.m_contest.weighObject(this.m_data);
            this.m_window.close();
         }
         this.m_refreshAction = this.REFRESH_ACTION_NONE;
      }
      
      private function handleInstanceStageChanged(e:Event) : void
      {
         this.m_effect.element.visible = true;
         this.m_effect.element.alpha = 1;
         this.m_effect.element.gotoAndPlay(2);
         TweenLite.to(this.m_effect.element,0.5,{
            "alpha":0,
            "delay":this.TRANSITION_EFFECT_FADE_OUT_DELAY,
            "onComplete":function():void
            {
               if(m_effect)
               {
                  m_effect.element.stop();
                  m_effect.element.visible = false;
               }
            }
         });
         this.m_friendlyNameTextField.text = this.getObjectFriendlyName();
      }
      
      private function setupFriendPreview(friendId:String, showNudge:Boolean = true, nudgeCanBeEnabled:Boolean = true) : void
      {
         var friend:Friend = null;
         if(friendId != this.m_partnerId)
         {
            this.m_partnerId = friendId;
            friend = Global.friendManager.getFriendData(friendId);
            if(friend)
            {
               if(this.m_friendIcon)
               {
                  removeWidget(this.m_friendIcon);
               }
               this.m_friendIcon = new FarmIcon(m_element["singleFriend_mc"],friend.picture);
               addWidget(this.m_friendIcon);
               this.m_partnerLabelTextField.text = friend.firstName;
            }
            this.m_nudgeButton.visible = showNudge;
            this.toggleButton(this.m_nudgeButton,nudgeCanBeEnabled && this.m_contest.canPostFeed(GrowableContest.FEED_TYPE_REMIND,friendId.toString()));
         }
      }
      
      public function refreshFieldsAndButtons() : void
      {
         var buttonsCanBeEnabled:Boolean = false;
         var toolTipText:String = null;
         var completionCash:int = 0;
         if(this.m_fakeMapResource != null && this.m_data["type"] == (GrowableContest.OBJECT_TYPE_ACTIVE || GrowableContest.OBJECT_TYPE_REQUEST))
         {
            buttonsCanBeEnabled = !this.m_fakeMapResource.lockFlag;
            if(this.m_isPartnerRequest)
            {
               this.m_objectState = this.OBJECT_STATE_PARTNER_REQUEST;
            }
            else if(this.hasPartnerActionPending)
            {
               this.m_objectState = this.OBJECT_STATE_PARTNER;
            }
            else if(this.m_fakeMapResource.checkAgeExpired() || !this.m_fakeMapResource.canStillGrow())
            {
               this.m_objectState = this.OBJECT_STATE_WEIGH;
            }
            else if(this.needsPlaced())
            {
               this.m_objectState = this.OBJECT_STATE_PLACE;
            }
            else
            {
               this.m_objectState = this.OBJECT_STATE_GROW;
            }
            if(this.m_data["partner"] > 0)
            {
               this.setupFriendPreview(this.m_data["partner"],this.m_objectState == this.OBJECT_STATE_PARTNER || this.m_objectState == this.OBJECT_STATE_GROW,buttonsCanBeEnabled);
               this.m_partnerLabelTextField.visible = true;
               if(this.m_friendIcon)
               {
                  this.m_friendIcon.visible = true;
               }
            }
            else if(this.m_objectState == this.OBJECT_STATE_PARTNER || this.m_objectState == this.OBJECT_STATE_GROW)
            {
               this.m_addFriendsButton.visible = true;
               this.toggleButton(this.m_addFriendsButton,buttonsCanBeEnabled);
               this.m_noFriendWidget.visible = true;
               toolTipText = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "AddFriendToolTip");
               if(toolTipText)
               {
                  this.m_addFriendsButton.attachTooltip(new MarketTooltip(toolTipText));
               }
            }
            else
            {
               this.m_addFriendsButton.visible = false;
               this.m_partnerLabelTextField.visible = false;
               this.m_noFriendWidget.visible = false;
            }
            this.m_progressBar.visible = true;
            this.m_progressBar.progress = this.m_fakeMapResource.totalFedCount;
            this.m_totalFeedCounter.text = ZLocUtils.t("Dialogs","Growable_ConsumableProgress",{
               "chow":this.m_fakeMapResource.totalFedCount.toString(),
               "chowCapacity":"100"
            });
            switch(this.m_objectState)
            {
               case this.OBJECT_STATE_PARTNER_REQUEST:
                  this.m_buyFeedButton.visible = false;
                  this.m_feedButton.visible = false;
                  this.m_weighButton.visible = false;
                  this.m_progressBar.visible = false;
                  this.m_statusTextField.visible = false;
                  break;
               case this.OBJECT_STATE_WEIGH:
                  this.m_weighButton.visible = true;
                  this.toggleButton(this.m_weighButton,buttonsCanBeEnabled);
                  this.m_buyFeedButton.visible = false;
                  this.m_feedButton.visible = false;
                  this.m_completeButton.visible = false;
                  this.m_statusTextField.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "ExpiredStatus");
                  break;
               case this.OBJECT_STATE_GROW:
                  if(this.m_window.getConsumableCount() > 0)
                  {
                     this.m_feedButton.visible = true;
                     this.toggleButton(this.m_feedButton,buttonsCanBeEnabled);
                     this.m_buyFeedButton.visible = false;
                  }
                  else
                  {
                     this.m_buyFeedButton.visible = true;
                     this.toggleButton(this.m_buyFeedButton,buttonsCanBeEnabled && !this.m_isFrictionlessBuyFeedPending);
                     this.m_feedButton.visible = false;
                  }
                  this.m_weighButton.visible = false;
                  this.m_feedButton.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Feed");
                  this.m_statusTextField.text = this.m_fakeMapResource.getTimeTilExpire();
                  completionCash = this.m_fakeMapResource.completionCash;
                  this.m_completeButton.setAmountText(String(completionCash));
                  this.m_completeButton.visible = true;
                  this.toggleButton(this.m_completeButton,buttonsCanBeEnabled);
                  break;
               case this.OBJECT_STATE_PLACE:
                  this.toggleButton(this.m_buyFeedButton,buttonsCanBeEnabled && !this.m_isFrictionlessBuyFeedPending);
                  this.m_buyFeedButton.visible = false;
                  this.m_feedButton.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "Place");
                  this.m_feedButton.visible = true;
                  this.toggleButton(this.m_feedButton,buttonsCanBeEnabled);
                  this.m_weighButton.visible = false;
                  this.m_statusTextField.text = this.m_fakeMapResource.getTimeTilExpire();
                  break;
               case this.OBJECT_STATE_PARTNER:
                  this.m_buyFeedButton.visible = false;
                  this.m_feedButton.text = this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "AcceptPartner");
                  this.m_feedButton.visible = true;
                  this.toggleButton(this.m_feedButton,buttonsCanBeEnabled);
                  this.m_weighButton.visible = false;
                  this.m_statusTextField.text = this.m_fakeMapResource.getTimeTilExpire();
            }
         }
      }
      
      private function refreshObjectSlot(data:Object) : void
      {
         if(Boolean(data.code) && data.code != this.m_data.code)
         {
            this.m_data.code = data.code;
         }
         else
         {
            this.m_data.code = GrowableResourceDelegate.getItemCodeFromStageKey(data.stage,this.m_data.code);
         }
         if(this.m_objectState != this.OBJECT_STATE_PARTNER)
         {
            if(this.m_instanceResource)
            {
               this.m_instanceResource.refreshVisibleToActual(data.stage);
               this.m_instanceResource.reloadImage();
            }
            this.m_fakeMapResource.refreshVisibleToActual(data.stage);
         }
         if(this.m_data.hasOwnProperty("code") && this.m_data.hasOwnProperty("storageKey"))
         {
            this.setupImagePreview(this.m_data["code"],this.m_data["storageKey"]);
         }
         this.refreshFieldsAndButtons();
         if(this.m_window)
         {
            this.m_window.refreshWindow();
         }
      }
      
      private function handleBuyFeedButtonClicked(e:MouseEvent) : void
      {
         this.m_isFrictionlessBuyFeedPending = true;
         GrowableUIHelper.promptAndFeedConsumable(this.m_fakeMapResource as IGrowableResource,this.handleBuyAndFeedButtonCallback,true,!this.m_isFrictionlessBuyFeed);
         this.refreshFieldsAndButtons();
         this.showPigProgress();
         this.participantStatCount("buy_feed_chow");
         if(!this.m_isFrictionlessBuyFeed)
         {
            this.participantStatCount("buy_feed_chow_prompt");
         }
      }
      
      private function handleBuyAndFeedButtonCallback(result:Object) : void
      {
         this.m_isFrictionlessBuyFeedPending = false;
         if(result.hasOwnProperty("frictionlessGranted") && result.frictionlessGranted == true)
         {
            if(!this.m_isFrictionlessBuyFeed)
            {
               this.participantStatCount("buy_feed_chow_accepted");
            }
            this.m_isFrictionlessBuyFeed = true;
         }
         this.refreshObjectSlot(result);
      }
      
      private function handleFeedButtonClicked(e:MouseEvent) : void
      {
         this.m_isFrictionlessBuyFeed = false;
         switch(this.m_objectState)
         {
            case this.OBJECT_STATE_PARTNER:
               this.showPigProgress();
               this.m_contest.acceptHelp(this.m_fakeMapResource,this.refreshObjectSlot);
               this.participantStatCount("accept_feed");
               break;
            case this.OBJECT_STATE_GROW:
               this.m_window.decrementConsumableCount();
               this.showPigProgress();
               this.m_fakeMapResource.feedConsumable(1,this.refreshObjectSlot,false);
               this.participantStatCount("feed_chow");
               break;
            case this.OBJECT_STATE_PLACE:
               this.participantStatCount("place");
               this.m_window.enterPlacementMode(this.m_fakeMapResource.getItemName(),this.m_fakeMapResource.persistentDataKey,false);
         }
         this.refreshFieldsAndButtons();
      }
      
      private function handleWeighButtonClicked(e:MouseEvent) : void
      {
         this.m_contest.weighObject(this.m_data);
         this.participantStatCount("weigh_entry");
         this.m_window.close();
      }
      
      private function handleAddFriendsButtonClicked(e:MouseEvent) : void
      {
         this.m_contest.makePartnerRequest(this.m_fakeMapResource.persistentDataKey);
         this.participantStatCount("invite_friend");
      }
      
      private function handleNopeButtonClicked(e:MouseEvent) : void
      {
         this.toggleButton(this.m_acceptButton,false);
         this.toggleButton(this.m_nopeButton,false);
         this.m_contest.rejectRequest(this.m_data["storageKey"],this.onRejectRequestComplete);
         this.refreshFieldsAndButtons();
         this.requestStatCount("reject_entry");
      }
      
      private function onRejectRequestComplete() : void
      {
         var rejectionDelayTimer:Timer = new Timer(125,1);
         rejectionDelayTimer.addEventListener(TimerEvent.TIMER,this.onRejectRequestTimerComplete);
         rejectionDelayTimer.start();
      }
      
      private function onRejectRequestTimerComplete(event:Event) : void
      {
         event.target.removeEventListener(TimerEvent.TIMER,this.onRejectRequestTimerComplete);
         if(this.m_contest.hasPendingRequests())
         {
            this.m_window.showRequestsFrame();
         }
         else
         {
            this.m_window.showMyItemFrame();
         }
      }
      
      private function handleAcceptButtonClicked(e:MouseEvent) : void
      {
         if(this.m_contest.availableCapacity() > 0)
         {
            this.toggleButton(this.m_acceptButton,false);
            this.toggleButton(this.m_nopeButton,false);
            this.m_contest.acceptRequest(this.m_data["storageKey"],this.acceptRequestCallback);
            this.refreshFieldsAndButtons();
            this.m_window.showLoadingIndicator();
            this.requestStatCount("accept_entry");
         }
      }
      
      private function acceptRequestCallback(data:Object) : void
      {
         this.m_window.hideLoadingIndicator();
         if(data["success"])
         {
            this.m_isPartnerRequest = false;
            this.m_window.enterPlacementMode(this.m_fakeMapResource.getItem().name,this.m_fakeMapResource.persistentDataKey);
         }
         else
         {
            this.m_data["inviteState"] = data["state"];
            this.setupRequestSlot();
         }
         this.refreshFieldsAndButtons();
      }
      
      private function handleStartButtonClicked(e:MouseEvent) : void
      {
         this.m_window.showMarketFrame(null);
         this.refreshFieldsAndButtons();
         this.participantStatCount("start_entry");
      }
      
      private function handleUnlockButtonClicked(e:MouseEvent) : void
      {
         var cost:Number = this.m_contest.slotUnlockCost;
         if(Global.player.canBuyCash(cost))
         {
            Global.player.cash -= cost;
            this.m_window.dispatchEvent(new DynamicObjectEvent(LOCKED_BUTTON_CLICKED,false));
            TransactionManager.addTransaction(new TGrowableUnlockSlot(this.m_contest.contestId,this.handleUnlockButtonCallback),true);
            this.refreshFieldsAndButtons();
            this.participantStatCount("unlock");
         }
      }
      
      private function handleLockedSlotBought(e:DynamicObjectEvent) : void
      {
         this.toggleButton(this.m_unlockButton,e.data);
         this.refreshFieldsAndButtons();
      }
      
      private function handleUnlockButtonCallback(e:Object) : void
      {
         this.m_window.dispatchEvent(new DynamicObjectEvent(LOCKED_BUTTON_CLICKED,true));
         this.setupUnlockedSlot();
         this.refreshFieldsAndButtons();
      }
      
      private function handleNudgeButtonClicked(e:Object) : void
      {
         if(this.m_data.hasOwnProperty("partner"))
         {
            this.toggleButton(this.m_nudgeButton,false);
            this.m_contest.postGeneralFeed(GrowableContest.FEED_TYPE_REMIND,this.handleNudgeButtonReturn,this.m_data["partner"]);
            this.m_window.dispatchEvent(new DynamicObjectEvent(NUDGE_BUTTON_CLICKED,{
               "partner":this.m_data["partner"],
               "status":false
            }));
         }
         this.refreshFieldsAndButtons();
         this.participantStatCount("nudge");
      }
      
      private function handleNudgeEventTriggered(e:DynamicObjectEvent) : void
      {
         if(e.data.partner == this.m_data["partner"])
         {
            this.toggleButton(this.m_nudgeButton,e.data.status);
         }
         this.refreshFieldsAndButtons();
      }
      
      private function handleNudgeButtonReturn(data:Object) : void
      {
         this.toggleButton(this.m_nudgeButton,!data);
         this.m_window.dispatchEvent(new DynamicObjectEvent(NUDGE_BUTTON_CLICKED,{
            "partner":this.m_data["partner"],
            "status":!data
         }));
         this.refreshFieldsAndButtons();
      }
      
      private function handleCompleteButtonClicked(e:MouseEvent) : void
      {
         GrowableUIHelper.promptAndCompleteAnimal(this.m_fakeMapResource,this.handleCompleteButtonCallback);
         this.refreshFieldsAndButtons();
         this.participantStatCount("complete_now_click");
      }
      
      private function handleCompleteButtonCallback(result:Object) : void
      {
         this.refreshObjectSlot(result);
         this.m_refreshAction = this.REFRESH_ACTION_WEIGH;
      }
      
      public function participantStatCount(phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         this.m_contest.statCount("participating_tab",phylum,zclass,family,genus,value);
      }
      
      public function requestStatCount(phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         this.m_contest.statCount("requests_tab",phylum,zclass,family,genus,value);
      }
      
      private function simulateToggleButton(button:FarmAnimatedTextButton, to:Boolean) : void
      {
         button.enabled = true;
         button.setToggleMode(ZwToggleMode.SINGLE_SELECT);
         button.setToggleState(to ? ZwToggleState.DESELECTED : ZwToggleState.SELECTED);
         button.applyGrayOut = !to;
         button.element.buttonMode = to;
      }
      
      private function toggleButton(button:FarmAnimatedButton, to:Boolean) : void
      {
         button.enabled = to;
         button.applyGrayOut = !to;
      }
   }
}

