package Widgets.Windows
{
   import Cache.Classes.ZCacheUtil;
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ExternalUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.Requests2Manager;
   import Transactions.TSendFeedInterstitialFeed;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.TabToggle;
   import Widgets.Frames.MFSDualScrollingSlotFrame;
   import Widgets.Frames.MFSWindowSlotFrame;
   import Widgets.Frames.SearchFrame;
   import Widgets.Icons.FarmIcon;
   import com.adobe.serialization.json.JSON;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MFSWindow extends FarmWindow
   {
      
      private static const SWF_EXPORT_TUTORIAL:String = "searchTutorial_mc";
      
      private static const TUTORIAL_SEEN_FLAG:String = "searchAdd_tutorial";
      
      public static const GHOST_NEIGHBOR_SET_FLAG:String = "ghost_neighbor_set_flag";
      
      protected static const MFS3_VARIANT:int = 2;
      
      protected var m_icon:FarmIcon = null;
      
      protected var m_messageTextField:ZwTextField = null;
      
      protected var m_titleTextField:ZwTextField = null;
      
      protected var m_descriptionTextField:ZwTextField = null;
      
      protected var m_noFriendsClip:ZwWidget = null;
      
      protected var m_windowBgTextField:ZwTextField = null;
      
      private var m_tutorial:MovieClip = null;
      
      private var m_accept:FarmAnimatedButton = null;
      
      protected var m_progressTextField:ZwTextField = null;
      
      protected var m_progressMeter:ZwFrame = null;
      
      protected var m_progressBar:ZwWidget = null;
      
      protected var m_progressAnimation:ZwWidget = null;
      
      protected var m_MFSTypeString:String = "";
      
      protected var m_item:FarmItem = null;
      
      protected var m_cachedItem:FarmItem = null;
      
      protected var m_friends:Object = null;
      
      protected var m_delayCloseButton:FarmButton = null;
      
      protected var m_sendButton:FarmAnimatedTextButton = null;
      
      protected var m_shareButton:FarmAnimatedTextButton = null;
      
      protected var m_loadingSpinner:ZwWidget = null;
      
      protected var m_friendsSlotFrame:MFSWindowSlotFrame = null;
      
      protected var m_statsFlowName:String = "";
      
      protected var m_feedStatsFlowName:String = null;
      
      protected var m_totalCurrentTabBatches:int = 0;
      
      protected var m_nextButton:FarmAnimatedTextButton = null;
      
      protected var m_backButton:FarmAnimatedTextButton = null;
      
      protected var m_tabOneButton:FarmAnimatedTextButton = null;
      
      protected var m_tabTwoButton:FarmAnimatedTextButton = null;
      
      protected var m_tabThreeButton:FarmAnimatedTextButton = null;
      
      protected var m_tabFourButton:FarmAnimatedTextButton = null;
      
      protected var m_tabFiveButton:FarmAnimatedTextButton = null;
      
      protected var m_searchFrame:SearchFrame;
      
      protected var m_searchString:String = "";
      
      protected var m_batchIndex:Array = null;
      
      protected var m_currentTab:int = 0;
      
      protected var m_currentlyDisplayedFriends:Array = null;
      
      protected var m_selectAllCheckBox:MFSWindowCheckBox = null;
      
      protected var m_numFriends:Array = null;
      
      protected var m_numItemsSent:Array = null;
      
      protected var m_hasInitialFriendCount:Array = null;
      
      protected var closeButtonAddTimer:Timer = null;
      
      protected var m_friendSpec:Object = null;
      
      protected var m_loadingComplete:Boolean = false;
      
      protected var m_openTabFunction:Function = null;
      
      protected var m_selectionStatus:int = 0;
      
      protected var m_tabNames:Array = null;
      
      protected var m_requestItem:FarmItem = null;
      
      protected var m_completeCallback:Function = null;
      
      protected var m_numItemsSentTotal:int = 0;
      
      protected var m_toggleManager:ZwToggleManager = null;
      
      protected var m_cornerWidget:ZwWidget = null;
      
      protected var m_serverTime:int = 0;
      
      protected var m_source:String = "";
      
      protected var m_view:String = "";
      
      protected var m_feedDialogQueued:Boolean = false;
      
      protected var m_MFSDialogQueued:Boolean = false;
      
      protected var m_friendPopulationResult:Object = null;
      
      protected var m_FeedDialogActive:Boolean = false;
      
      protected var m_showFeedDialog:Boolean = false;
      
      protected var m_batchLimit:int = 24;
      
      protected var m_mfsExperimentVariant:int = 0;
      
      protected var m_usingMFS3:Boolean = false;
      
      protected var m_attemptedSendUIDs:Array = null;
      
      private var m_invitableFriends:Array;
      
      private var m_askFriendsPermissionText:ZwTextField = null;
      
      protected var m_askFriendsPermission_bt:FarmAnimatedTextButton = null;
      
      private var m_askMovieClip:MovieClip = null;
      
      protected var m_hasFriendsPerm:Boolean = true;
      
      protected var m_fbTransactionStarted:Boolean = false;
      
      public function MFSWindow(friendSpec:Object, friendTabOrder:Array, item:FarmItem, completeCallback:Function, typeString:String, source:String, statsFlowName:String, assetSwf:String = null)
      {
         var tabName:String = null;
         var tabOrderLength:int = 0;
         var i:int = 0;
         var tabNameOrdered:String = null;
         this.m_mfsExperimentVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MFS_UI_OPTIMIZATION);
         if(!assetSwf || assetSwf.length == 0)
         {
            if(this.m_mfsExperimentVariant >= MFS3_VARIANT)
            {
               assetSwf = MFSConstants.MFS3_SWF;
               this.m_batchLimit = MFSConstants.SEND_BATCH_LIMIT;
               this.m_usingMFS3 = true;
            }
            else
            {
               assetSwf = MFSConstants.MFS_SWF;
            }
         }
         super(assetSwf);
         this.m_loadingComplete = false;
         this.m_friendSpec = friendSpec;
         this.m_tabNames = [];
         if(friendTabOrder == null || friendTabOrder.length == 0)
         {
            for(tabName in this.m_friendSpec)
            {
               this.m_tabNames.push(tabName);
            }
         }
         else
         {
            tabOrderLength = int(friendTabOrder.length);
            for(i = 0; i < tabOrderLength; i++)
            {
               for(tabNameOrdered in this.m_friendSpec)
               {
                  if(tabNameOrdered == friendTabOrder[i])
                  {
                     this.m_tabNames.push(tabNameOrdered);
                  }
               }
            }
         }
         this.m_item = item;
         this.m_completeCallback = completeCallback;
         this.m_MFSTypeString = typeString;
         this.m_source = source;
         this.m_statsFlowName = statsFlowName;
         this.m_hasInitialFriendCount = new Array(3);
         this.m_numFriends = new Array(3);
         this.m_currentlyDisplayedFriends = new Array(this.m_batchLimit);
         this.m_numItemsSent = new Array(3);
         for(var iterator:int = 0; iterator < 3; iterator++)
         {
            this.m_hasInitialFriendCount[iterator] = false;
            this.m_numFriends[iterator] = 0;
            this.m_numItemsSent[iterator] = 0;
         }
         this.m_batchIndex = new Array(5);
         this.m_batchIndex[0] = 0;
         this.m_batchIndex[1] = 0;
         this.m_batchIndex[2] = 0;
         this.m_batchIndex[3] = 0;
         this.m_batchIndex[4] = 0;
      }
      
      private static function isInvitableFriendsJSCallEnabled() : Boolean
      {
         var result:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_OPS_JS_INVITABLE_FRIENDS) == 1)
         {
            result = true;
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var sendText:String = null;
         if(m_window.mc_background)
         {
            addWidget(new ZwWidget(m_window.mc_background));
         }
         if(m_window.mc_header)
         {
            addWidget(new ZwWidget(m_window.mc_header));
         }
         if(m_window.header_tf)
         {
            this.m_titleTextField = addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs",this.m_MFSTypeString + "_Title"))) as ZwTextField;
         }
         if(m_window.noMoreFriends_mc)
         {
            this.m_noFriendsClip = addWidget(new ZwWidget(m_window.noMoreFriends_mc)) as ZwWidget;
            this.m_windowBgTextField = addWidget(new ZwTextField(m_window.noMoreFriends_mc.copy_tf,ZLocUtils.t("Dialogs","MFSWindow_NoFriendsInTab_Body"))) as ZwTextField;
            this.m_noFriendsClip.visible = false;
         }
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FV_INTERSTITIAL_CLOSE_DELAY) > 1 && (this.m_MFSTypeString == MFSRecentlyPlayed.MFS_TYPE || this.m_MFSTypeString == MFSConstants.FREE_GIFT_WINDOW))
         {
            this.closeButtonAddTimer = new Timer(int(Global.flashHotParams["CLOSE_BUTTON_DELAY_TIME"]),1);
         }
         else
         {
            this.closeButtonAddTimer = new Timer(MFSConstants.CLOSE_BUTTON_TIME,1);
         }
         this.closeButtonAddTimer.addEventListener(TimerEvent.TIMER,this.closeButtonCallback);
         this.closeButtonAddTimer.start();
         this.addCornerContents();
         this.addBackgroundScene();
         this.addWindowSubtitle();
         this.addWindowDescription();
         if(m_window.mc_loader)
         {
            this.m_loadingSpinner = addWidget(new ZwWidget(m_window.mc_loader)) as ZwWidget;
         }
         if(m_window.txt_meter)
         {
            this.m_progressTextField = addWidget(new ZwTextField(m_window.txt_meter," "),false) as ZwTextField;
            this.m_progressMeter = addWidget(new ZwFrame(m_window.stack_mc),false) as ZwFrame;
            this.m_progressBar = this.m_progressMeter.addWidget(new ZwWidget(m_window.stack_mc.mc_orangebar)) as ZwWidget;
         }
         if(m_window.fireworkanimation_mc)
         {
            this.m_progressAnimation = addWidget(new ZwWidget(m_window.fireworkanimation_mc)) as ZwWidget;
            (this.m_progressAnimation.element as MovieClip).gotoAndStop(0);
         }
         if(this.m_usingMFS3)
         {
            this.m_friendsSlotFrame = new MFSDualScrollingSlotFrame(m_window.scrollContainer_mc,this.onSlotClick);
         }
         else
         {
            if(m_window.selectAll_bt)
            {
               this.m_selectAllCheckBox = new MFSWindowCheckBox(m_window.selectAll_bt,this.onCheckBoxClick,this.m_statsFlowName);
               addWidget(this.m_selectAllCheckBox);
               this.m_selectAllCheckBox.visible = false;
            }
            if(m_window.mc_slotcontainer)
            {
               this.m_friendsSlotFrame = new MFSWindowSlotFrame(m_window.mc_slotcontainer,this.onSlotClick);
            }
            if(m_window.next_bt)
            {
               this.m_nextButton = new FarmAnimatedTextButton(m_window.next_bt,ZLocUtils.t("Dialogs","MFSWindow_Next"),this.onClickNext);
               addWidget(this.m_nextButton);
               this.m_nextButton.visible = false;
            }
            if(m_window.back_bt)
            {
               this.m_backButton = new FarmAnimatedTextButton(m_window.back_bt,ZLocUtils.t("Dialogs","MFSWindow_Back"),this.onClickBack);
               addWidget(this.m_backButton);
               this.m_backButton.visible = false;
            }
         }
         if(this.m_friendsSlotFrame)
         {
            addWidget(this.m_friendsSlotFrame);
            this.m_friendsSlotFrame.visible = false;
         }
         if(m_window.delay_close_bt)
         {
            this.m_delayCloseButton = addWidget(new FarmButton(m_window.delay_close_bt,this.onClose),false) as FarmButton;
         }
         if(m_window.bt_sendgifts)
         {
            sendText = ZLocUtils.t("Dialogs","MFSWindow_SendButton");
            if(this.m_usingMFS3)
            {
               sendText = ZLocUtils.t("Dialogs","MFSWindow_SelectAllSendButton");
            }
            this.m_sendButton = addWidget(new FarmAnimatedTextButton(m_window.bt_sendgifts,sendText,this.onSendButtonClick),false) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty("bt_share"))
         {
            this.m_shareButton = addWidget(new FarmAnimatedTextButton(m_window.bt_share,"Share",this.onShareButtonClick),false) as FarmAnimatedTextButton;
         }
         if(this.m_tabNames[0] != MFSConstants.NO_TABS && Boolean(m_window.tab1_bt))
         {
            this.m_tabOneButton = new FarmAnimatedTextButton(m_window.tab1_bt,ZLocUtils.t("Dialogs","MFSWindow_" + this.m_tabNames[0]),this.onClickTabOne);
            addWidget(this.m_tabOneButton);
         }
         if(Boolean(this.m_tabNames[0] != MFSConstants.NO_TABS && m_window.tab6_bt) && Boolean(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FV_GHOST_NEIGHBORS_TAB) > 0) && Global.player.getSeenFlag(GHOST_NEIGHBOR_SET_FLAG))
         {
            this.m_tabOneButton = new FarmAnimatedTextButton(m_window.tab6_bt,ZLocUtils.t("Dialogs","MFSWindow_" + this.m_tabNames[0]),this.onClickTabOne);
            addWidget(this.m_tabOneButton);
         }
         if(Boolean(this.m_tabNames[1]) && Boolean(m_window.tab2_bt))
         {
            this.m_tabTwoButton = new FarmAnimatedTextButton(m_window.tab2_bt,ZLocUtils.t("Dialogs","MFSWindow_" + this.m_tabNames[1]),this.onClickTabTwo);
            addWidget(this.m_tabTwoButton);
         }
         if(Boolean(this.m_tabNames[2]) && Boolean(m_window.tab3_bt))
         {
            this.m_tabThreeButton = new FarmAnimatedTextButton(m_window.tab3_bt,ZLocUtils.t("Dialogs","MFSWindow_" + this.m_tabNames[2]),this.onClickTabThree);
            addWidget(this.m_tabThreeButton);
         }
         if(Boolean(this.m_tabNames[3]) && Boolean(m_window.tab4_bt))
         {
            this.m_tabFourButton = new FarmAnimatedTextButton(m_window.tab4_bt,ZLocUtils.t("Dialogs","MFSWindow_" + this.m_tabNames[3]),this.onClickTabFour);
            addWidget(this.m_tabFourButton);
         }
         if(Boolean(this.m_tabNames[4]) && Boolean(m_window.tab5_bt))
         {
            this.m_tabFiveButton = new FarmAnimatedTextButton(m_window.tab5_bt,ZLocUtils.t("Dialogs","MFSWindow_" + this.m_tabNames[4]),this.onClickTabFive);
            addWidget(this.m_tabFiveButton);
         }
         if(m_window.hasOwnProperty("searchBar_mc"))
         {
            this.m_searchFrame = new SearchFrame(m_window.searchBar_mc,this.onSearchUpdate);
            addWidget(this.m_searchFrame,true);
         }
         if(m_window.hasOwnProperty(SWF_EXPORT_TUTORIAL))
         {
            this.m_tutorial = m_window[SWF_EXPORT_TUTORIAL] as MovieClip;
            this.m_tutorial.visible = false;
            if(!Global.player.getSeenFlag(TUTORIAL_SEEN_FLAG))
            {
               Global.player.setSeenFlag(TUTORIAL_SEEN_FLAG);
               if(this.m_tutorial)
               {
                  this.m_tutorial.visible = true;
                  this.m_tutorial.gotoAndPlay(2);
                  this.m_accept = new FarmAnimatedButton(this.m_tutorial.okay_bt,this.onAcceptTutorial) as FarmAnimatedButton;
               }
            }
         }
         if(this.m_showFeedDialog)
         {
            this.m_FeedDialogActive = true;
            this.m_MFSDialogQueued = true;
            this.switchFromMFSToFeed();
         }
         this.sendPopulatingTransaction();
         FarmStatsManager.count(this.m_source,this.m_statsFlowName,"dialog_impression");
         if(m_window.hasOwnProperty("giftsConfirm_mc"))
         {
            this.m_askMovieClip = m_window.giftsConfirm_mc;
            this.m_askMovieClip.visible = false;
            this.m_askFriendsPermissionText = addWidget(new ZwTextField(m_window.giftsConfirm_mc.generic_tf,"",false)) as ZwTextField;
            this.m_askFriendsPermission_bt = new FarmAnimatedTextButton(m_window.giftsConfirm_mc.accept_bt,ZLocUtils.t("Dialogs","askPermissionButtonText"),this.popJSFriendsPermissionDialog);
            addWidget(this.m_askFriendsPermission_bt,false);
         }
      }
      
      private function onSearchUpdate(searchString:String = "") : void
      {
         this.m_searchString = searchString;
         this.refresh(false);
      }
      
      public function onAcceptTutorial(event:MouseEvent) : void
      {
         this.m_tutorial.visible = false;
      }
      
      protected function addCornerContents() : void
      {
         if(m_window.mc_recentlyplayed)
         {
            this.addCornerAvatar();
         }
      }
      
      private function popJSFriendsPermissionDialog(e:Event = null) : void
      {
         Global.player.extendedPermissionState.requestFriendsPermissions();
         this.m_hasFriendsPerm = true;
         this.refreshAskFriendsPermissionMovieClip(false);
         if(this.m_windowBgTextField)
         {
            this.m_windowBgTextField.text = ZLocUtils.t("Dialogs","MFSWindow_NoFriendsInTab_Body");
         }
      }
      
      protected function addCornerAvatar() : void
      {
         var avatarFrame:ZwFrame = new ZwFrame(m_window.mc_recentlyplayed);
         if(this.m_item != null)
         {
            this.m_icon = avatarFrame.addWidget(new FarmIcon(avatarFrame.element.mc_gift,this.m_item.iconUrl)) as FarmIcon;
            this.m_icon.setIconSize(MFSConstants.ICON_SIZE,MFSConstants.ICON_SIZE);
         }
         avatarFrame.addWidget(new ZwWidget(avatarFrame.element.mc_giftcontainer));
         if(getWidget(avatarFrame) != null)
         {
            removeWidget(avatarFrame);
         }
         this.m_cornerWidget = addWidget(avatarFrame) as ZwWidget;
      }
      
      protected function addBackgroundScene() : void
      {
         if(m_window.mc_scene)
         {
            addWidget(new ZwWidget(m_window.mc_scene));
         }
      }
      
      private function closeButtonCallback(e:TimerEvent) : void
      {
         this.addCloseButton();
      }
      
      private function addCloseButton() : void
      {
         if(Boolean(m_window) && Boolean(m_window.delay_close_bt))
         {
            this.m_delayCloseButton.visible = true;
            if(this.closeButtonAddTimer != null)
            {
               this.closeButtonAddTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.addCloseButton);
               this.closeButtonAddTimer = null;
            }
         }
      }
      
      protected function getMessageText() : String
      {
         return this.m_item.friendlyTitle;
      }
      
      protected function sendPopulatingTransaction() : void
      {
      }
      
      protected function onFriendPopulation(result:Object) : void
      {
         if(MFSWindow.isInvitableFriendsJSCallEnabled())
         {
            if(Boolean(result) && Boolean(result.hasOwnProperty("requestedFriends")) && Boolean(result["requestedFriends"].hasOwnProperty("Facebook")) && result["requestedFriends"]["Facebook"].length == 0)
            {
               result["requestedFriends"]["Facebook"] = [];
               this.onFriendPopulation2(result);
               if(this.isFBDialogEnabled() == false)
               {
                  if(Boolean(this.m_invitableFriends) && Boolean(this.m_invitableFriends.length))
                  {
                     result["requestedFriends"]["Facebook"] = this.m_invitableFriends;
                     this.onFriendPopulation2(result);
                  }
                  else
                  {
                     try
                     {
                        ExternalUtil.instance.addCallback("onNonAppFriendsCallback",ZCacheUtil.applyPartial(this.onNonAppFriendsCallback,this,[result]));
                        ExternalUtil.instance.call("getNonAppFriendsInfo");
                     }
                     catch(e:Error)
                     {
                        onFriendPopulation2(result);
                     }
                  }
               }
            }
            else
            {
               this.onFriendPopulation2(result);
            }
         }
         else
         {
            this.onFriendPopulation2(result);
         }
      }
      
      private function onNonAppFriendsCallback(tResult:Object = null, jsResult:Object = null) : void
      {
         var data:Object = null;
         var userData:Object = null;
         var friendData:Array = [];
         if(Boolean(jsResult) && jsResult.hasOwnProperty("data"))
         {
            for each(userData in jsResult["data"])
            {
               data = {};
               data.uid = userData.id;
               data.name = userData.name;
               data.pic_square = userData.picture.data.url;
               data.valid = true;
               friendData.push(data);
            }
            this.m_invitableFriends = friendData;
         }
         tResult["requestedFriends"]["Facebook"] = friendData;
         this.onFriendPopulation2(tResult);
      }
      
      private function onNonAppFriendsV2Callback(tResult:Object = null, jsResult:Object = null) : void
      {
         this.m_noFriendsClip.visible = false;
         this.m_fbTransactionStarted = false;
         if(this.m_delayCloseButton)
         {
            this.m_delayCloseButton.enabled = true;
         }
         for(var tabIndex:int = 0; tabIndex < this.m_tabNames.length; tabIndex++)
         {
            if(this.m_tabNames[tabIndex] == MFSConstants.TAB_NAME_FARMVILLE || this.m_tabNames[tabIndex] == "tabNamePlaysFarmVille")
            {
               this.m_currentTab = tabIndex;
               break;
            }
         }
         this.setFarmvilleTab(this.m_currentTab);
         this.refresh();
      }
      
      public function setFarmvilleTab(activeTabIndex:int) : void
      {
         this.m_toggleManager = new ZwToggleManager();
         switch(activeTabIndex)
         {
            case 0:
               this.setInitialTabToggle(true,false,false,false,false);
               break;
            case 1:
               this.setInitialTabToggle(false,true,false,false,false);
               break;
            case 2:
               this.setInitialTabToggle(false,false,true,false,false);
               break;
            case 3:
               this.setInitialTabToggle(false,false,false,true,false);
               break;
            case 4:
               this.setInitialTabToggle(false,false,false,false,true);
         }
      }
      
      private function onFriendPopulation2(result:Object) : void
      {
         try
         {
            if(GlobalEngine.getFlashVar("OPS_JS_GET_FRIENDS_PERMISSION") as String == "true")
            {
               ExternalUtil.instance.addCallback("onFriendsDataLoaded",ZCacheUtil.applyPartial(this.onFriendsDataLoaded,this,[result]));
               ExternalUtil.instance.call("FarmNS.FlashExtendedPermissionsManager.checkFriendsPermissionFlash");
            }
            else
            {
               this.onFriendsDataLoaded(result,true);
            }
         }
         catch(e:Error)
         {
            onFriendsDataLoaded(result,true);
         }
      }
      
      private function onFriendsDataLoaded(result:Object, jsFriendsPermissionResult:Boolean = true) : void
      {
         if(m_window)
         {
            this.m_hasFriendsPerm = jsFriendsPermissionResult;
            if(this.m_FeedDialogActive)
            {
               this.m_friendPopulationResult = result;
            }
            else
            {
               this.m_loadingComplete = true;
               if(this.closeButtonAddTimer)
               {
                  if(this.closeButtonAddTimer.running)
                  {
                     this.closeButtonAddTimer.stop();
                  }
               }
               this.addCloseButton();
               this.m_numItemsSentTotal = 0;
               if(Boolean(result) && result.hasOwnProperty("requestedFriends"))
               {
                  this.m_friends = result["requestedFriends"] as Object;
               }
               this.setVisibleChild(this.m_loadingSpinner,false);
               this.setVisibleChild(this.m_sendButton,true);
               this.setVisibleChild(this.m_progressTextField,true);
               this.setVisibleChild(this.m_progressMeter,true);
               this.setFirstRunActiveTab();
               this.setWindowDescription();
               this.refresh(false);
            }
            this.updateButtonVisibility();
            this.postRefreshActions();
            if(this.m_openTabFunction != null)
            {
               this.m_openTabFunction();
               this.m_openTabFunction = null;
            }
         }
      }
      
      protected function refreshAskFriendsPermissionMovieClip(visible:Boolean = false) : void
      {
         if(Boolean(this.m_askMovieClip) && Boolean(this.m_askFriendsPermission_bt) && Boolean(this.m_askFriendsPermissionText))
         {
            this.m_askMovieClip.visible = visible;
            this.m_askFriendsPermission_bt.visible = visible;
            this.m_askFriendsPermissionText.visible = visible;
         }
      }
      
      protected function postRefreshActions() : void
      {
      }
      
      protected function addWindowSubtitle() : void
      {
         this.m_messageTextField = addWidget(new ZwTextField(m_window.item_tf,this.getMessageText())) as ZwTextField;
      }
      
      protected function addWindowDescription() : void
      {
         if(Boolean(m_window) && m_window.hasOwnProperty("txt_body"))
         {
            this.m_descriptionTextField = addWidget(new ZwTextField(m_window.txt_body,ZLocUtils.t("Dialogs",this.m_MFSTypeString + "_Loading"))) as ZwTextField;
         }
      }
      
      protected function setWindowDescription() : void
      {
         var numFriends:int = 0;
         if(Boolean(m_window) && m_window.hasOwnProperty("txt_body"))
         {
            numFriends = int(this.getFriendsInTab(this.m_tabNames[this.m_currentTab]).length);
            this.m_descriptionTextField.text = ZLocUtils.t("Dialogs",this.m_MFSTypeString + "_Message",{
               "giftName":this.m_item.friendlyTitle,
               "friendCount":numFriends
            });
         }
      }
      
      protected function getProgressBarText(sentCount:int, friendCount:int) : String
      {
         return ZLocUtils.t("Dialogs","MFSWindow_Progress",{
            "sentCount":sentCount,
            "friendCount":friendCount
         });
      }
      
      protected function getFriendsInTab(tabName:String) : Array
      {
         var types:Array = null;
         var typesLength:int = 0;
         var j:int = 0;
         var type:String = null;
         var friendTypeLength:int = 0;
         var i:int = 0;
         var friend:Object = null;
         var isSearchIncluded:Boolean = false;
         var result:Array = [];
         if(tabName != null && tabName != "")
         {
            if(this.isFBDialogEnabled() && tabName == MFSConstants.TAB_NAME_FACEBOOK)
            {
               if(this.m_fbTransactionStarted == false)
               {
                  this.m_noFriendsClip.visible = false;
                  ExternalUtil.instance.addCallback("onNonAppFriendsV2Callback",ZCacheUtil.applyPartial(this.onNonAppFriendsV2Callback,this,[result]));
                  ExternalUtil.instance.call("getNonAppFriendsInfoV2");
                  this.m_fbTransactionStarted = true;
                  if(this.m_delayCloseButton)
                  {
                     this.m_delayCloseButton.enabled = false;
                  }
               }
            }
            else
            {
               types = this.m_friendSpec[tabName];
               typesLength = int(types.length);
               for(j = 0; j < typesLength; j++)
               {
                  type = types[j];
                  if(this.m_friends != null && this.m_friends[type] != null)
                  {
                     this.m_friends[type].sortOn("name");
                     friendTypeLength = int(this.m_friends[type].length);
                     for(i = 0; i < friendTypeLength; i++)
                     {
                        friend = this.m_friends[type][i];
                        isSearchIncluded = this.m_searchString == "" || friend["name"].toLowerCase().search(this.m_searchString) != -1;
                        if(Boolean(friend.hasOwnProperty("uid") && !this.isFriendAlreadyInList(result,friend) && friend.hasOwnProperty("valid")) && Boolean(friend.valid) && isSearchIncluded)
                        {
                           result.push(friend);
                        }
                     }
                  }
               }
            }
         }
         return result;
      }
      
      public function get numSelectedFriends() : int
      {
         return this.m_friendsSlotFrame.numSelectedItems;
      }
      
      private function isFriendAlreadyInList(arr:Array, friend:Object) : Boolean
      {
         var result:Boolean = false;
         var arrLen:int = int(arr.length);
         for(var k:int = 0; k < arrLen; k++)
         {
            if(arr[k].uid == friend.uid)
            {
               result = true;
               break;
            }
         }
         return result;
      }
      
      protected function setFirstRunActiveTab() : void
      {
         this.m_toggleManager = new ZwToggleManager();
         var allTabsEmpty:Boolean = true;
         var i:int = 0;
         while(true)
         {
            if(i >= this.m_tabNames.length)
            {
               if(allTabsEmpty)
               {
                  this.m_currentTab = 0;
                  this.setInitialTabToggle(true,false,false,false,false);
               }
               return;
            }
            addr0160:
            if(this.getFriendsInTab(this.m_tabNames[i]).length > 0)
            {
               break;
            }
            i++;
         }
         allTabsEmpty = false;
         this.m_currentTab = i;
         switch(i)
         {
            case 0:
               this.setInitialTabToggle(true,false,false,false,false);
               break;
            case 1:
               this.setInitialTabToggle(false,true,false,false,false);
               break;
            case 2:
               this.setInitialTabToggle(false,false,true,false,false);
               break;
            case 3:
               this.setInitialTabToggle(false,false,false,true,false);
               break;
            case 4:
               this.setInitialTabToggle(false,false,false,false,true);
         }
         §§goto(addr0160);
      }
      
      protected function setInitialTabToggle(tabOneActive:Boolean, tabTwoActive:Boolean, tabThreeActive:Boolean, tabFourActive:Boolean, tabFiveActive:Boolean) : void
      {
         if(this.m_tabOneButton != null)
         {
            this.m_toggleManager.addToggle(new TabToggle(this.m_tabOneButton),tabOneActive);
         }
         if(Boolean(this.m_tabNames[1]) && Boolean(this.m_tabTwoButton))
         {
            this.m_toggleManager.addToggle(new TabToggle(this.m_tabTwoButton),tabTwoActive);
         }
         if(Boolean(this.m_tabNames[2]) && Boolean(this.m_tabThreeButton))
         {
            this.m_toggleManager.addToggle(new TabToggle(this.m_tabThreeButton),tabThreeActive);
         }
         if(Boolean(this.m_tabNames[3]) && Boolean(this.m_tabFourButton))
         {
            this.m_toggleManager.addToggle(new TabToggle(this.m_tabFourButton),tabFourActive);
         }
         if(Boolean(this.m_tabNames[4]) && Boolean(this.m_tabFiveButton))
         {
            this.m_toggleManager.addToggle(new TabToggle(this.m_tabFiveButton),tabFiveActive);
         }
      }
      
      protected function getCurrentTabItems() : Array
      {
         return this.getItemsForTab(this.m_currentTab);
      }
      
      protected function getItemsForTab(tab:int) : Array
      {
         var resultArray:Array = null;
         var tabArray:Array = this.getFriendsInTab(this.m_tabNames[tab]);
         if(!this.m_hasInitialFriendCount[tab] && this.m_loadingComplete)
         {
            this.m_numFriends[tab] = tabArray.length;
            this.m_hasInitialFriendCount[tab] = true;
         }
         this.m_totalCurrentTabBatches = Math.ceil(tabArray.length / this.m_batchLimit);
         this.m_batchIndex[tab] = Math.min(Math.max(this.m_batchIndex[tab],0),this.m_totalCurrentTabBatches - 1);
         if(Boolean(this.m_friendsSlotFrame) && this.m_friendsSlotFrame.isPaginated())
         {
            resultArray = tabArray.slice(this.m_batchIndex[tab] * this.m_batchLimit,this.m_batchIndex[tab] * this.m_batchLimit + this.m_batchLimit);
         }
         else
         {
            resultArray = tabArray;
         }
         return resultArray;
      }
      
      protected function refresh(showProgressAnimation:Boolean = true) : void
      {
         var inviteText:String = null;
         var sendText:String = null;
         if(this.m_selectAllCheckBox)
         {
            this.m_selectAllCheckBox.setCheckSelected(true);
         }
         this.m_currentlyDisplayedFriends = this.getCurrentTabItems();
         this.m_friendsSlotFrame.items = this.m_currentlyDisplayedFriends;
         if(this.m_progressTextField)
         {
            this.m_progressTextField.text = this.getProgressBarText(this.m_numItemsSent[this.m_currentTab],this.m_numFriends[this.m_currentTab]);
            (this.m_progressBar.element as MovieClip).scaleX = this.m_numItemsSent[this.m_currentTab] / this.m_numFriends[this.m_currentTab];
            if(showProgressAnimation && Boolean(this.m_progressAnimation))
            {
               (this.m_progressAnimation.element as MovieClip).gotoAndPlay(0);
            }
         }
         if(this.m_selectAllCheckBox)
         {
            this.onCheckBoxClick();
         }
         else if(!this.m_usingMFS3)
         {
            this.setCheckAllState(false);
         }
         if(this.m_selectionStatus)
         {
            this.m_selectionStatus = this.m_friendsSlotFrame.checkSelectedStatus(this.m_currentlyDisplayedFriends.length);
            this.updateSendButtonOnSlotSelection();
         }
         this.updateButtonVisibility();
         if(GlobalEngine.getFlashVar("OPS_JS_GET_FRIENDS_PERMISSION") as String == "true")
         {
            if(this.m_tabNames[this.m_currentTab] == MFSConstants.TAB_NAME_FACEBOOK)
            {
               this.refreshAskFriendsPermissionMovieClip(!this.m_hasFriendsPerm);
               if(!this.m_hasFriendsPerm)
               {
                  if(this.m_windowBgTextField)
                  {
                     this.m_windowBgTextField.text = ZLocUtils.t("Dialogs","askPermissionTitle");
                  }
               }
               else if(this.m_windowBgTextField)
               {
                  this.m_windowBgTextField.text = ZLocUtils.t("Dialogs","MFSWindow_NoFriendsInTab_Body");
               }
               inviteText = ZLocUtils.t("Dialogs","MFSWindow_InviteButton");
               if(this.m_usingMFS3)
               {
                  if(this.m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
                  {
                     inviteText = ZLocUtils.t("Dialogs","MFSWindow_SelectAllInviteButton");
                  }
               }
               if(this.m_sendButton)
               {
                  this.m_sendButton.text = inviteText;
               }
            }
            else
            {
               sendText = ZLocUtils.t("Dialogs","MFSWindow_SendButton");
               if(this.m_usingMFS3)
               {
                  if(this.m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
                  {
                     sendText = ZLocUtils.t("Dialogs","MFSWindow_SelectAllSendButton");
                  }
               }
               if(this.m_sendButton)
               {
                  this.m_sendButton.text = sendText;
               }
               this.refreshAskFriendsPermissionMovieClip(false);
               if(this.m_windowBgTextField)
               {
                  this.m_windowBgTextField.text = ZLocUtils.t("Dialogs","MFSWindow_NoFriendsInTab_Body");
               }
            }
         }
         if(m_window.ghost_mc)
         {
            m_window.ghost_mc.visible = false;
         }
      }
      
      protected function setVisibleChild(button:ZwWidget, visible:Boolean) : void
      {
         if(button)
         {
            button.visible = visible;
         }
      }
      
      protected function setEnabledChild(button:ZwWidget, enabled:Boolean) : void
      {
         if(button)
         {
            button.enabled = visible;
         }
      }
      
      protected function updateButtonVisibility() : void
      {
         if(this.m_loadingComplete)
         {
            if(this.m_currentlyDisplayedFriends.length < 1)
            {
               this.setVisibleChild(this.m_selectAllCheckBox,false);
               this.setVisibleChild(this.m_backButton,false);
               this.setVisibleChild(this.m_nextButton,false);
               this.setVisibleChild(this.m_noFriendsClip,true);
               this.setVisibleChild(this.m_sendButton,false);
               this.setVisibleChild(this.m_progressTextField,false);
               this.setVisibleChild(this.m_progressMeter,false);
               this.setVisibleChild(this.m_friendsSlotFrame,false);
            }
            else
            {
               this.setVisibleChild(this.m_friendsSlotFrame,true);
               this.setVisibleChild(this.m_noFriendsClip,false);
               this.setVisibleChild(this.m_selectAllCheckBox,true);
               this.setVisibleChild(this.m_sendButton,true);
               this.setVisibleChild(this.m_progressTextField,true);
               this.setVisibleChild(this.m_progressMeter,true);
               if(this.m_batchIndex[this.m_currentTab] == 0)
               {
                  this.setVisibleChild(this.m_backButton,false);
               }
               else
               {
                  this.setVisibleChild(this.m_backButton,true);
               }
               if(this.m_batchIndex[this.m_currentTab] == this.m_totalCurrentTabBatches - 1)
               {
                  this.setVisibleChild(this.m_nextButton,false);
               }
               else
               {
                  this.setVisibleChild(this.m_nextButton,true);
               }
            }
         }
      }
      
      protected function conditionallyLoadNextBatch(showProgressAnimation:Boolean = true, direction:int = 1, sentItems:Boolean = false) : Boolean
      {
         this.toggleButtonsOnWarningEnable(true);
         var result:Boolean = false;
         var currentTabsLastBatchIndex:int = this.m_totalCurrentTabBatches - 1;
         var tempBatchIndex:int = Math.min(Math.max(this.m_batchIndex[this.m_currentTab] + direction,0),currentTabsLastBatchIndex);
         if(sentItems && this.m_batchIndex[this.m_currentTab] == currentTabsLastBatchIndex)
         {
            tempBatchIndex = 0;
         }
         if(this.m_batchIndex[this.m_currentTab] != tempBatchIndex || sentItems && currentTabsLastBatchIndex != 0 || !this.m_friendsSlotFrame.isPaginated() && this.m_currentlyDisplayedFriends.length - this.m_attemptedSendUIDs.length > 0)
         {
            this.m_batchIndex[this.m_currentTab] = tempBatchIndex;
            this.refresh(showProgressAnimation);
            result = true;
         }
         return result;
      }
      
      protected function onClickTabOne(evt:MouseEvent = null) : void
      {
         this.m_currentTab = 0;
         if(this.m_searchFrame)
         {
            this.m_searchFrame.reset();
         }
         this.refresh(false);
      }
      
      protected function onClickTabTwo(evt:MouseEvent = null) : void
      {
         this.m_currentTab = 1;
         if(this.m_searchFrame)
         {
            this.m_searchFrame.reset();
         }
         this.refresh(false);
      }
      
      protected function onClickTabThree(evt:MouseEvent = null) : void
      {
         this.m_currentTab = 2;
         if(this.m_searchFrame)
         {
            this.m_searchFrame.reset();
         }
         this.refresh(false);
      }
      
      protected function onClickTabFour(evt:MouseEvent = null) : void
      {
         if(this.m_searchFrame)
         {
            this.m_searchFrame.visible = false;
         }
      }
      
      protected function onClickTabFive(evt:MouseEvent = null) : void
      {
         if(this.m_searchFrame)
         {
            this.m_searchFrame.reset();
         }
      }
      
      protected function onClickNext(evt:MouseEvent = null) : void
      {
         this.navigatePage(MFSConstants.PAGE_INCREMENT_VALUE);
      }
      
      protected function onClickBack(evt:MouseEvent = null) : void
      {
         this.navigatePage(MFSConstants.PAGE_DECREMENT_VALUE);
      }
      
      protected function toggleButtonsOnWarningEnable(enable:Boolean) : void
      {
         this.setEnabledChild(this.m_nextButton,enable);
         this.setEnabledChild(this.m_backButton,enable);
         this.setEnabledChild(this.m_sendButton,enable);
         this.setEnabledChild(this.m_delayCloseButton,enable);
         this.m_friendsSlotFrame.enableAll = enable;
      }
      
      protected function navigatePage(navigatePageBy:int) : void
      {
         if(this.m_friendsSlotFrame.checkSelectedStatus(this.m_currentlyDisplayedFriends.length) == MFSWindowSlotFrame.SELECT_STATE_MIX)
         {
            UI.displayPopup(new MFSWarning(this.onSend,this.conditionallyLoadNextBatch,false,navigatePageBy,this.m_statsFlowName),false);
            this.toggleButtonsOnWarningEnable(false);
         }
         else
         {
            this.conditionallyLoadNextBatch(false,navigatePageBy);
         }
      }
      
      protected function onCheckBoxClick() : void
      {
         this.setCheckAllState(this.m_selectAllCheckBox.checkSelected);
         var clickState:String = this.m_selectAllCheckBox.checkSelected == true ? "all" : "none";
         FarmStatsManager.count(this.m_source,this.m_statsFlowName,"select_all_click",clickState);
      }
      
      protected function setCheckAllState(enabled:Boolean) : void
      {
         if(this.m_selectAllCheckBox)
         {
            this.m_selectAllCheckBox.setCheckSelected(enabled);
         }
         if(this.m_friendsSlotFrame)
         {
            this.m_friendsSlotFrame.selectAllToggle(enabled);
            this.m_selectionStatus = this.m_friendsSlotFrame.checkSelectedStatus(this.m_currentlyDisplayedFriends.length);
         }
         this.updateSendButtonOnSlotSelection();
      }
      
      protected function updateSendButtonOnSlotSelection() : void
      {
         var inviteText:String = null;
         var sendText:String = null;
         if(this.m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
         {
            this.setEnabledChild(this.m_sendButton,false);
         }
         else
         {
            this.setEnabledChild(this.m_sendButton,true);
         }
         if(this.m_sendButton)
         {
            if(GlobalEngine.getFlashVar("OPS_JS_GET_FRIENDS_PERMISSION") as String == "true" && this.m_tabNames[this.m_currentTab] == MFSConstants.TAB_NAME_FACEBOOK)
            {
               inviteText = ZLocUtils.t("Dialogs","MFSWindow_InviteButton");
               if(this.m_usingMFS3)
               {
                  if(this.m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
                  {
                     inviteText = ZLocUtils.t("Dialogs","MFSWindow_SelectAllInviteButton");
                  }
               }
               if(this.m_sendButton)
               {
                  this.m_sendButton.text = inviteText;
               }
            }
            else
            {
               sendText = ZLocUtils.t("Dialogs","MFSWindow_SendButton");
               if(this.m_usingMFS3)
               {
                  if(this.m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
                  {
                     sendText = ZLocUtils.t("Dialogs","MFSWindow_SelectAllSendButton");
                  }
               }
               if(this.m_sendButton)
               {
                  this.m_sendButton.text = sendText;
               }
            }
         }
      }
      
      public function onSlotClick() : void
      {
         this.m_selectionStatus = this.m_friendsSlotFrame.checkSelectedStatus(this.m_currentlyDisplayedFriends.length);
         if(this.m_selectAllCheckBox)
         {
            if(this.m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_ALL)
            {
               this.m_selectAllCheckBox.setCheckSelected(true);
            }
            else
            {
               this.m_selectAllCheckBox.setCheckSelected(false);
            }
         }
         this.updateSendButtonOnSlotSelection();
      }
      
      private function onSendButtonClick(event:MouseEvent = null) : void
      {
         FarmStatsManager.count(this.m_source,this.m_statsFlowName,"send_gift_button",this.m_friendsSlotFrame.pageNumber.toString());
         if(this.m_mfsExperimentVariant >= MFS3_VARIANT && this.m_friendsSlotFrame.checkSelectedStatus(this.m_currentlyDisplayedFriends.length) == MFSWindowSlotFrame.SELECT_STATE_NONE)
         {
            this.setCheckAllState(true);
         }
         this.onSend();
      }
      
      protected function onShareButtonClick(event:MouseEvent = null) : void
      {
         FarmStatsManager.count(this.m_source,this.m_feedStatsFlowName,"send_gift_button");
         this.setEnabledChild(this.m_shareButton,false);
         this.m_FeedDialogActive = false;
         TransactionManager.addTransaction(new TSendFeedInterstitialFeed(this.m_item.code,this.m_MFSTypeString),true);
         var timeLimit:int = int(Global.flashHotParams[MFSConstants.FEED_INTERSTITIAL_V2_TIME_LIMIT]);
         var actionKey:String = MFSConstants.INTERSTITIAL_FEED + "_" + this.m_MFSTypeString + "_TimeInterval";
         Global.player.incrementIntervalActionCount(actionKey,timeLimit);
         if(this.m_MFSDialogQueued)
         {
            this.switchFromFeedToMFS();
            if(this.m_friendPopulationResult)
            {
               this.onFriendPopulation(this.m_friendPopulationResult);
            }
            this.m_MFSDialogQueued = false;
         }
         else
         {
            if(this.m_completeCallback != null)
            {
               this.m_completeCallback(this.m_numItemsSentTotal);
            }
            close();
         }
         FarmStatsManager.count(this.m_source,this.m_feedStatsFlowName,"request_send_success");
      }
      
      protected function onSend() : void
      {
         var requestData:String = null;
         var requestMessage:String = null;
         var requestTitle:String = null;
         this.toggleButtonsOnWarningEnable(true);
         var uids:Array = this.m_friendsSlotFrame.getSelectedFriends();
         if(uids.length > MFSConstants.SEND_BATCH_LIMIT)
         {
            uids = uids.slice(0,MFSConstants.SEND_BATCH_LIMIT);
         }
         if(uids.length > 0)
         {
            if(!this.m_usingMFS3)
            {
               this.setVisibleChild(this.m_friendsSlotFrame,false);
               this.setVisibleChild(this.m_loadingSpinner,true);
               this.setVisibleChild(this.m_sendButton,false);
            }
            if(this.m_sendButton)
            {
               this.m_sendButton.text = ZLocUtils.t("Dialogs","MFSWindow_SendingButton");
            }
            requestData = this.getRequestData();
            requestMessage = this.getRequestMessage(this.m_tabNames[this.m_currentTab]);
            requestTitle = this.getRequestTitle();
            this.m_attemptedSendUIDs = uids;
            this.sendRequest(requestData,requestMessage,requestTitle,uids,this.m_source,this.fbResponseHandler);
         }
      }
      
      protected function sendRequest(requestData:String, requestMessage:String, requestTitle:String, uids:Array, source:String, fbResponseHandler:Function) : void
      {
         Requests2Manager.sendGift(requestData,requestMessage,requestTitle,uids,this.m_source,fbResponseHandler);
      }
      
      protected function fbResponseAction(requestIds:Array) : void
      {
      }
      
      protected function getRequestData() : String
      {
         var requestData:Array = [];
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      protected function getRequestMessage(currentTabName:String) : String
      {
         return "";
      }
      
      protected function getRequestTitle() : String
      {
         return ZLocUtils.t_pk("Dialogs",this.m_MFSTypeString + "_Title");
      }
      
      private function invalidate(uids:Array) : void
      {
         var friendType:String = null;
         var friendTypeLength:int = 0;
         var i:int = 0;
         var uidLength:int = int(uids.length);
         for(var invalidateUID:int = 0; invalidateUID < uidLength; invalidateUID++)
         {
            for(friendType in this.m_friends)
            {
               friendTypeLength = int(this.m_friends[friendType].length);
               for(i = 0; i < friendTypeLength; i++)
               {
                  if(uids[invalidateUID] == this.m_friends[friendType][i].uid)
                  {
                     this.m_friends[friendType][i].valid = false;
                  }
               }
            }
         }
      }
      
      public function fbResponseHandler(response:Object) : void
      {
         var requestIds:Array = null;
         var sentUIDs:Array = null;
         var showAnimation:Boolean = false;
         if(Boolean(response) && response.hasOwnProperty("request_ids"))
         {
            requestIds = response["request_ids"] as Array;
            if(Boolean(requestIds) && requestIds.length > 0)
            {
               sentUIDs = this.m_friendsSlotFrame.getInvalidatedFriendsOnSend();
               if(this.m_attemptedSendUIDs)
               {
                  sentUIDs = this.m_attemptedSendUIDs;
               }
               this.m_numItemsSentTotal += sentUIDs.length;
               this.m_numItemsSent[this.m_currentTab] += sentUIDs.length;
               if(this.m_tabNames[this.m_currentTab] == MFSConstants.TAB_NAME_TRIPLE_PARTS)
               {
                  this.m_view = MFSConstants.THREE_X_STRING;
               }
               else if(this.m_tabNames[this.m_currentTab] == MFSConstants.TAB_NAME_SINGLE_PARTS)
               {
                  this.m_view = MFSConstants.ONE_X_STRING;
               }
               this.fbResponseAction(requestIds);
               this.invalidate(sentUIDs);
               showAnimation = true;
            }
            FarmStatsManager.count(this.m_source,this.m_statsFlowName,"request_send_success");
         }
         else
         {
            this.m_attemptedSendUIDs = new Array();
            FarmStatsManager.count(this.m_source,this.m_statsFlowName,"request_send_fail");
         }
         this.showNextBatchOfFriends(showAnimation);
      }
      
      protected function showNextBatchOfFriends(showAnimation:Boolean) : void
      {
         var hasClosed:Boolean = false;
         if(!this.conditionallyLoadNextBatch(showAnimation,0,true))
         {
            hasClosed = true;
            if(this.m_feedDialogQueued && this.canPostFeed())
            {
               this.switchFromMFSToFeed();
            }
            else
            {
               if(this.m_completeCallback != null)
               {
                  this.m_completeCallback(this.m_numItemsSentTotal);
               }
               close();
            }
         }
         if(!hasClosed)
         {
            if(!this.m_usingMFS3)
            {
               this.setVisibleChild(this.m_friendsSlotFrame,true);
               this.setVisibleChild(this.m_loadingSpinner,false);
            }
            this.updateSendButtonOnSlotSelection();
         }
      }
      
      protected function canPostFeed() : Boolean
      {
         var result:Boolean = true;
         var timeLimit:int = int(Global.flashHotParams[MFSConstants.FEED_INTERSTITIAL_V2_TIME_LIMIT]);
         var actionKey:String = MFSConstants.INTERSTITIAL_FEED + "_" + this.m_MFSTypeString + "_TimeInterval";
         var feedCount:int = Global.player.getIntervalActionCount(actionKey,timeLimit);
         if(feedCount >= 1)
         {
            result = false;
         }
         return result;
      }
      
      protected function switchFromMFSToFeed() : void
      {
      }
      
      protected function switchFromFeedToMFS() : void
      {
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(this.m_source,this.m_statsFlowName,"close_button");
         if(this.m_feedStatsFlowName != null)
         {
            FarmStatsManager.count(this.m_source,this.m_feedStatsFlowName,"close_button");
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_item = null;
         this.m_completeCallback = null;
         this.m_friends = null;
         this.m_friendsSlotFrame = null;
         this.m_icon = null;
         this.m_loadingSpinner = null;
         this.m_titleTextField = null;
         this.m_windowBgTextField = null;
         this.m_noFriendsClip = null;
         this.m_cachedItem = null;
         this.m_messageTextField = null;
         this.m_descriptionTextField = null;
         this.m_progressAnimation = null;
         this.m_progressBar = null;
         this.m_progressMeter = null;
         this.m_progressTextField = null;
         this.m_sendButton = null;
         this.m_shareButton = null;
         this.m_nextButton = null;
         this.m_backButton = null;
         this.m_tabOneButton = null;
         this.m_tabTwoButton = null;
         this.m_tabThreeButton = null;
         this.m_tabFourButton = null;
         this.m_tabFiveButton = null;
         this.m_MFSTypeString = null;
         this.m_source = null;
         this.m_statsFlowName = null;
         this.m_batchIndex = null;
         this.m_currentlyDisplayedFriends = null;
         this.m_selectAllCheckBox = null;
         this.m_toggleManager = null;
         this.m_friendPopulationResult = null;
         super.release();
      }
      
      public function get friendSpec() : Object
      {
         return this.m_friendSpec;
      }
      
      protected function convertToUniqueValuesArray(obj:Object) : Array
      {
         var key:String = null;
         var i:int = 0;
         var friendType:String = null;
         var result:Array = [];
         for(key in obj)
         {
            for(i = 0; i < obj[key].length; i++)
            {
               friendType = obj[key][i];
               if(result.indexOf(friendType) < 0)
               {
                  result.push(friendType);
               }
            }
         }
         return result;
      }
      
      private function isFBDialogEnabled() : Boolean
      {
         var enabled:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MFS_API_CHANGES) >= 2 || Boolean(Global.flashHotParams["MFS_API_CHANGES"]))
         {
            enabled = true;
         }
         return enabled;
      }
   }
}

