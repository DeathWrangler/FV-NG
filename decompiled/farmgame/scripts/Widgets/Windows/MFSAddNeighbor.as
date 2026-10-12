package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Constants.MFSConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.CommunityMatchmakingUtility;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.MFSRequestManager;
   import Transactions.TGenericTransaction;
   import Transactions.TSendRequest2NeighborInvite;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.DeleteNeighborConfirmFrame;
   import Widgets.Frames.MFSCommunityNeighborFrame;
   import Widgets.Frames.MFSCurrentNeighborSlotFrame;
   import Widgets.Frames.MFSWindowSlotFrame;
   import Widgets.Frames.MultipleDeleteNeighborConfirmFrame;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MFSAddNeighbor extends MFSAddNeighborBase
   {
      
      public static const ADD_NEIGHBOR_BATCH_LIMIT:int = 21;
      
      public static const ADD_NEIGHBOR_BATCH_LIMIT_TAB0:int = 15;
      
      public static const ADD_NEIGHBOR_SWF:String = "assets/dialogs/FV_AddNeighbors.swf";
      
      public static const COMMUNITY_NEIGHBORS_REQUEST:String = "CommunityNeighborsRequest";
      
      public static const FEATURE_COMMUNITY_NEIGHBOR_INVITE_LIMIT:String = "COMMUNITY_NEIGHBOR_INVITE_LIMIT";
      
      public static const MFS_ADD_NEIGHBOR_STATS:String = "neighbor_tab";
      
      public static const GHOST_NEIGHBORS:String = "ghost_neighbor";
      
      public static const PLAYS_FARMVILLE:String = "plays_farmville";
      
      public static const ALL_FB_FRIENDS:String = "all_fb_friends";
      
      public static const COMMUNITY_FRIENDS:String = "community_friends";
      
      public static const CURRENT_NEIGHBORS:String = "current_neighbors";
      
      private static const CURRENT_NEIGHBOR_TAB_NUMBER:int = 4;
      
      protected var m_deleteButton:FarmAnimatedTextButton = null;
      
      protected var m_assetSwf:String = "";
      
      private var m_subCat:String = "";
      
      public var m_creative:String = "";
      
      protected var m_selectAllGhostCheckBox:MFSWindowCheckBox = null;
      
      protected var m_selectionGhostStatus:int = 0;
      
      protected var m_communityNeighborFrame:MFSCommunityNeighborFrame = null;
      
      protected var m_ghostfriendsSlotFrame:MFSWindowSlotFrame = null;
      
      protected var m_currentNeighborFrame:MFSCurrentNeighborSlotFrame = null;
      
      protected var m_deleteConfirmFrame:DeleteNeighborConfirmFrame = null;
      
      protected var m_deleteConfirmFrame2:MultipleDeleteNeighborConfirmFrame = null;
      
      protected var m_requestLeft:int = 0;
      
      private var m_numSelectedNeighborsToDelete:int;
      
      private var m_selectedNeighborsToDeleteHash:Object = {};
      
      private var m_numNeighborsNeededToDelete:int;
      
      public function MFSAddNeighbor(source:String, completeCallback:Function)
      {
         if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment())
         {
            this.m_assetSwf = CommunityMatchmakingUtility.COMMUNITY_MATCHMAKING_V3_ADD_NEIGHBOR_SWF;
         }
         else
         {
            this.m_assetSwf = ADD_NEIGHBOR_SWF;
         }
         var friendSpec:Object = {
            "tabNameGhost":["GhostNeighbor"],
            "tabNamePlaysFarmVille":["FarmVille"],
            "tabNameFacebook":["Facebook"],
            "tabNameCommunity":["PossibleCommunity"],
            "tabNameNeighbors":["CurrentAllNeighbor"]
         };
         var friendTabOrder:Array = ["tabNameGhost","tabNamePlaysFarmVille","tabNameFacebook","tabNameCommunity","tabNameNeighbors"];
         super(friendSpec,source,completeCallback,this.m_assetSwf,friendTabOrder,MFS_ADD_NEIGHBOR_STATS);
         m_batchLimit = ADD_NEIGHBOR_BATCH_LIMIT;
      }
      
      override protected function postLoadComplete() : void
      {
         var deleteText:String = null;
         super.postLoadComplete();
         this.m_currentNeighborFrame = addWidget(new MFSCurrentNeighborSlotFrame(m_window.mc_slotcontainer2,this.onRemoveNeighborCallback,this)) as MFSCurrentNeighborSlotFrame;
         this.m_currentNeighborFrame.visible = false;
         this.m_communityNeighborFrame = addWidget(new MFSCommunityNeighborFrame(m_window.communityNeighbors_mc,this)) as MFSCommunityNeighborFrame;
         this.m_communityNeighborFrame.visible = false;
         this.m_deleteConfirmFrame = addWidget(new DeleteNeighborConfirmFrame(m_window.deleteConfirm_mc,this.onAcceptRemove,this.onCloseRemove)) as DeleteNeighborConfirmFrame;
         this.m_deleteConfirmFrame.visible = false;
         if(m_tabOneButton != null)
         {
            if(m_window.deleteConfirm2_mc)
            {
               this.m_deleteConfirmFrame2 = addWidget(new MultipleDeleteNeighborConfirmFrame(m_window.deleteConfirm2_mc,this.onAcceptGhostRemove,this.onCloseGhostRemove)) as MultipleDeleteNeighborConfirmFrame;
               this.m_deleteConfirmFrame2.visible = false;
            }
            if(m_window.ghost_mc.mc_slotcontainer1)
            {
               this.m_ghostfriendsSlotFrame = addWidget(new MFSWindowSlotFrame(m_window.ghost_mc.mc_slotcontainer1,this.onGhostSlotClick)) as MFSWindowSlotFrame;
               this.m_ghostfriendsSlotFrame.visible = false;
            }
            if(m_window.ghost_mc.header_tf1)
            {
               m_titleTextField = addWidget(new ZwTextField(m_window.ghost_mc.header_tf1,ZLocUtils.t("Dialogs","GhostNeighborsDefine"))) as ZwTextField;
            }
            if(m_window.ghost_mc.selectAll_bt1)
            {
               this.m_selectAllGhostCheckBox = new MFSWindowCheckBox(m_window.ghost_mc.selectAll_bt1,this.onGhostCheckBoxClick,m_statsFlowName);
               addWidget(this.m_selectAllGhostCheckBox);
               this.m_selectAllGhostCheckBox.visible = false;
            }
            if(m_window.ghost_mc.delete_bt1)
            {
               deleteText = ZLocUtils.t("Dialogs","GhostNeighborDeleteButton");
               this.m_deleteButton = addWidget(new FarmAnimatedTextButton(m_window.ghost_mc.delete_bt1,deleteText,this.onDeleteButtonClick),false) as FarmAnimatedTextButton;
            }
            if(m_window.ghost_mc.next_bt1)
            {
               m_window.ghost_mc.next_bt1.visible = false;
            }
            if(m_window.ghost_mc.back_bt1)
            {
               m_window.ghost_mc.back_bt1.visible = false;
            }
            if(m_window.ghost_mc.resend_bt1)
            {
               m_window.ghost_mc.resend_bt1.visible = false;
            }
         }
      }
      
      override protected function setFirstRunActiveTab() : void
      {
         var currentTime:int = GlobalEngine.serverTime / 1000;
         Global.player.setFeatureLastShown(MFSRequestManager.R2_ADD_NEIGHBOR_IN_FLASH_FREQUENCY_FLAG,currentTime,true);
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_NEIGHBOR_TAB_REDESIGN);
         switch(variant)
         {
            case 3:
               m_currentTab = 0;
               break;
            case 4:
               m_currentTab = 1;
               break;
            case 5:
               m_currentTab = 2;
               break;
            case 6:
               m_currentTab = 3;
               break;
            default:
               m_currentTab = 0;
         }
         m_toggleManager = new ZwToggleManager();
         if(getFriendsInTab(m_tabNames[m_currentTab]).length > 0)
         {
            switch(m_currentTab)
            {
               case 0:
                  this.m_subCat = GHOST_NEIGHBORS;
                  setInitialTabToggle(true,false,false,false,false);
                  break;
               case 1:
                  this.m_subCat = PLAYS_FARMVILLE;
                  setInitialTabToggle(false,true,false,false,false);
                  break;
               case 2:
                  this.m_subCat = ALL_FB_FRIENDS;
                  setInitialTabToggle(false,false,true,false,false);
                  break;
               case 3:
                  this.m_subCat = COMMUNITY_FRIENDS;
                  setInitialTabToggle(false,false,false,true,false);
                  this.onClickTabFour(null);
                  break;
               default:
                  this.m_subCat = PLAYS_FARMVILLE;
                  setInitialTabToggle(false,true,false,false,false);
            }
            FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,m_source,this.m_subCat);
         }
         else
         {
            super.setFirstRunActiveTab();
         }
      }
      
      private function onDeleteButtonClick(event:MouseEvent = null) : void
      {
         FarmStatsManager.count(m_source,m_statsFlowName,"delete_button",this.m_ghostfriendsSlotFrame.pageNumber.toString());
         if(m_mfsExperimentVariant >= MFS3_VARIANT && this.m_ghostfriendsSlotFrame.checkSelectedStatus(m_currentlyDisplayedFriends.length) == MFSWindowSlotFrame.SELECT_STATE_NONE)
         {
            this.setCheckAllGhostState(true);
         }
         this.onDelete();
      }
      
      private function onDelete() : void
      {
         var uids:Array = this.m_ghostfriendsSlotFrame.getSelectedFriends();
         if(uids.length > 0)
         {
            if(this.m_deleteConfirmFrame2)
            {
               this.m_deleteConfirmFrame2.visible = true;
            }
         }
      }
      
      override protected function navigatePage(navigatePageBy:int) : void
      {
         if(!m_currentTab == 0)
         {
            if(m_friendsSlotFrame.checkSelectedStatus(m_currentlyDisplayedFriends.length) == MFSWindowSlotFrame.SELECT_STATE_MIX)
            {
               UI.displayPopup(new MFSWarning(onSend,this.conditionallyLoadNextBatch,false,navigatePageBy,m_statsFlowName),false);
               toggleButtonsOnWarningEnable(false);
            }
            else
            {
               this.conditionallyLoadNextBatch(false,navigatePageBy);
            }
         }
         else
         {
            this.conditionallyLoadNextBatch(false,navigatePageBy);
         }
      }
      
      public function onGhostSlotClick() : void
      {
         this.m_selectionGhostStatus = this.m_ghostfriendsSlotFrame.checkSelectedStatus(m_currentlyDisplayedFriends.length);
         if(this.m_selectAllGhostCheckBox)
         {
            if(this.m_selectionGhostStatus == MFSWindowSlotFrame.SELECT_STATE_ALL)
            {
               this.m_selectAllGhostCheckBox.setCheckSelected(true);
            }
            else
            {
               this.m_selectAllGhostCheckBox.setCheckSelected(false);
            }
         }
         this.updateButtonsOnSlotSelection();
      }
      
      protected function onGhostCheckBoxClick() : void
      {
         this.setCheckAllGhostState(this.m_selectAllGhostCheckBox.checkSelected);
         var clickState:String = this.m_selectAllGhostCheckBox.checkSelected == true ? "all" : "none";
         FarmStatsManager.count(m_source,m_statsFlowName,"select_all_click",clickState);
      }
      
      protected function setCheckAllGhostState(enabled:Boolean) : void
      {
         if(this.m_selectAllGhostCheckBox)
         {
            this.m_selectAllGhostCheckBox.setCheckSelected(enabled);
         }
         if(this.m_ghostfriendsSlotFrame)
         {
            this.m_ghostfriendsSlotFrame.selectAllToggle(enabled);
            this.m_selectionGhostStatus = this.m_ghostfriendsSlotFrame.checkSelectedStatus(m_currentlyDisplayedFriends.length);
         }
         this.updateButtonsOnSlotSelection();
      }
      
      protected function updateButtonsOnSlotSelection() : void
      {
         if(this.m_selectionGhostStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
         {
            setEnabledChild(this.m_deleteButton,false);
         }
         else
         {
            setEnabledChild(this.m_deleteButton,true);
         }
      }
      
      override protected function conditionallyLoadNextBatch(showProgressAnimation:Boolean = true, direction:int = 1, sentItems:Boolean = false) : Boolean
      {
         var currentTabsLastBatchIndex:int = 0;
         var tempBatchIndex:int = 0;
         var result:Boolean = false;
         if(m_currentTab == 4)
         {
            currentTabsLastBatchIndex = m_totalCurrentTabBatches - 1;
            tempBatchIndex = Math.min(Math.max(m_batchIndex[m_currentTab] + direction,0),currentTabsLastBatchIndex);
            if(sentItems && m_batchIndex[m_currentTab] == currentTabsLastBatchIndex)
            {
               tempBatchIndex = 0;
            }
            if(m_batchIndex[m_currentTab] != tempBatchIndex || sentItems && currentTabsLastBatchIndex != 0)
            {
               m_batchIndex[m_currentTab] = tempBatchIndex;
               m_currentlyDisplayedFriends = getCurrentTabItems();
               this.m_currentNeighborFrame.items = m_currentlyDisplayedFriends;
               if(m_batchIndex[m_currentTab] == 0)
               {
                  setVisibleChild(m_backButton,false);
               }
               else
               {
                  setVisibleChild(m_backButton,true);
               }
               if(m_batchIndex[m_currentTab] == m_totalCurrentTabBatches - 1)
               {
                  setVisibleChild(m_nextButton,false);
               }
               else
               {
                  setVisibleChild(m_nextButton,true);
               }
               result = true;
            }
         }
         else
         {
            result = super.conditionallyLoadNextBatch(showProgressAnimation,direction,sentItems);
         }
         return result;
      }
      
      override protected function postRefreshActions() : void
      {
         if(m_currentTab == 3 || m_currentTab == 4)
         {
            this.conditionallyRefresh();
         }
      }
      
      private function onAcceptRemove(data:Object) : void
      {
         var paramsArray:Array = null;
         this.m_deleteConfirmFrame.visible = false;
         if(data.hasOwnProperty("uid"))
         {
            paramsArray = new Array();
            paramsArray.push(data["uid"]);
            Global.ui.m_friendBar.removeSlotByUid(data["uid"]);
            this.invalidate(paramsArray,"CurrentAllNeighbor");
            TransactionManager.addTransaction(new TGenericTransaction("UserService","removeNeighbor",null,paramsArray),true);
            this.m_currentNeighborFrame.updateHeader(getFriendsInTab(m_tabNames[m_currentTab]).length);
            if(data.hasOwnProperty(MFSConstants.NEIGHBOR_TYPE))
            {
               if(data[MFSConstants.NEIGHBOR_TYPE] == "n")
               {
                  FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"remove_neighbor","fb_friend",data["uid"].toString());
               }
               else
               {
                  FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"remove_neighbor","community_friend",data["uid"].toString());
               }
            }
            if(this.m_currentNeighborFrame)
            {
               this.m_currentNeighborFrame.setState(data);
            }
         }
      }
      
      private function onAcceptGhostRemove() : void
      {
         var uidsArray:Array = null;
         var i:int = 0;
         var paramsArray:Array = null;
         var remData:Array = null;
         this.m_deleteConfirmFrame2.visible = false;
         var data:Array = this.m_ghostfriendsSlotFrame.getSelectedFriendsData();
         if(data.length >= 1)
         {
            uidsArray = [];
            for(i = 0; i < data.length; i++)
            {
               uidsArray.push(data[i]["uid"]);
            }
            paramsArray = [];
            paramsArray.push(uidsArray);
            TransactionManager.addTransaction(new TGenericTransaction("UserService","removeGhostNeighborList",null,paramsArray),true);
            for(i = 0; i < data.length; i++)
            {
               if(data[i].hasOwnProperty(MFSConstants.NEIGHBOR_TYPE))
               {
                  if(data[i][MFSConstants.NEIGHBOR_TYPE] == "n")
                  {
                     FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"remove_neighbor","fb_friend",data[i]["uid"].toString());
                  }
                  else
                  {
                     FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"remove_neighbor","community_friend",data[i]["uid"].toString());
                  }
               }
               this.invalidate(uidsArray,"GhostNeighbor");
               Global.ui.m_friendBar.removeSlotByUid(data[i]["uid"]);
            }
            remData = null;
            remData = getCurrentTabItems();
            if(remData.length > 0)
            {
               this.m_ghostfriendsSlotFrame.items = remData;
            }
            else
            {
               m_window.ghost_mc.visible = false;
               m_noFriendsClip.visible = true;
            }
            FarmStatsManager.count("ghost_neighbours_screen","remove",getFriendsInTab(m_tabNames[m_currentTab]).toString(),data.length.toString());
         }
      }
      
      private function onCloseRemove() : void
      {
         this.m_deleteConfirmFrame.visible = false;
      }
      
      private function onCloseGhostRemove() : void
      {
         this.m_deleteConfirmFrame2.visible = false;
      }
      
      override protected function addCornerContents() : void
      {
      }
      
      override protected function addBackgroundScene() : void
      {
      }
      
      override protected function setWindowDescription() : void
      {
      }
      
      override protected function onClickTabOne(evt:MouseEvent = null) : void
      {
         this.openGhostNeighborTab();
      }
      
      override protected function onClickTabTwo(evt:MouseEvent = null) : void
      {
         if(m_loadingComplete)
         {
            this.m_subCat = PLAYS_FARMVILLE;
            FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"select",this.m_subCat);
            this.refreshNeighborFrame();
            super.onClickTabTwo(evt);
         }
      }
      
      override protected function onClickTabThree(evt:MouseEvent = null) : void
      {
         if(m_loadingComplete)
         {
            this.m_subCat = ALL_FB_FRIENDS;
            FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"select",this.m_subCat);
            this.refreshNeighborFrame();
            super.onClickTabThree(evt);
         }
      }
      
      public function openAddNeighborTab() : void
      {
         if(m_loadingComplete)
         {
            m_currentTab = 3;
            this.m_subCat = COMMUNITY_FRIENDS;
            FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"select",this.m_subCat);
            this.conditionallyRefresh();
            m_selectAllCheckBox.visible = false;
            m_nextButton.visible = false;
            m_backButton.visible = false;
            this.m_currentNeighborFrame.visible = false;
            this.m_communityNeighborFrame.items = m_currentlyDisplayedFriends;
            if(!this.canSendCommunityRequests())
            {
               this.m_communityNeighborFrame.disableAddNeighborButton();
            }
            this.m_communityNeighborFrame.visible = true;
            this.m_communityNeighborFrame.stopSpinner();
            setInitialTabToggle(false,false,false,true,false);
            super.onClickTabFour();
         }
         else
         {
            m_openTabFunction = this.openAddNeighborTab;
         }
      }
      
      public function openGhostNeighborTab() : void
      {
         var inviteText:String = null;
         var sendText:String = null;
         if(m_loadingComplete)
         {
            m_currentTab = 0;
            this.m_subCat = GHOST_NEIGHBORS;
            FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"select",this.m_subCat);
            this.refreshNeighborFrame();
            this.conditionallyRefresh();
            if(this.m_selectAllGhostCheckBox)
            {
               this.m_selectAllGhostCheckBox.setCheckSelected(true);
            }
            if(this.m_selectAllGhostCheckBox)
            {
               this.onGhostCheckBoxClick();
            }
            else if(!m_usingMFS3)
            {
               this.setCheckAllGhostState(false);
            }
            if(this.m_selectionGhostStatus)
            {
               this.m_selectionGhostStatus = this.m_ghostfriendsSlotFrame.checkSelectedStatus(m_currentlyDisplayedFriends.length);
               this.updateButtonsOnSlotSelection();
            }
            this.m_ghostfriendsSlotFrame.items = getCurrentTabItems();
            FarmStatsManager.count("ghost_neighbours_screen","view",getFriendsInTab(m_tabNames[m_currentTab]).length.toString());
            m_window.ghost_mc.visible = true;
            this.m_ghostfriendsSlotFrame.visible = true;
            this.m_selectAllGhostCheckBox.visible = true;
            this.m_deleteButton.visible = true;
            setInitialTabToggle(true,false,false,false,false);
            this.updateButtonVisibility();
            if(GlobalEngine.getFlashVar("OPS_JS_GET_FRIENDS_PERMISSION") as String == "true")
            {
               if(m_tabNames[m_currentTab] == MFSConstants.TAB_NAME_FACEBOOK)
               {
                  refreshAskFriendsPermissionMovieClip(!m_hasFriendsPerm);
                  if(!m_hasFriendsPerm)
                  {
                     if(m_windowBgTextField)
                     {
                        m_windowBgTextField.text = ZLocUtils.t("Dialogs","askPermissionTitle");
                     }
                  }
                  else if(m_windowBgTextField)
                  {
                     m_windowBgTextField.text = ZLocUtils.t("Dialogs","MFSWindow_NoFriendsInTab_Body");
                  }
                  inviteText = ZLocUtils.t("Dialogs","MFSWindow_InviteButton");
                  if(m_usingMFS3)
                  {
                     if(m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
                     {
                        inviteText = ZLocUtils.t("Dialogs","MFSWindow_SelectAllInviteButton");
                     }
                  }
                  if(m_sendButton)
                  {
                     m_sendButton.text = inviteText;
                  }
               }
               else
               {
                  sendText = ZLocUtils.t("Dialogs","MFSWindow_SendButton");
                  if(m_usingMFS3)
                  {
                     if(m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
                     {
                        sendText = ZLocUtils.t("Dialogs","MFSWindow_SelectAllSendButton");
                     }
                  }
                  if(m_sendButton)
                  {
                     m_sendButton.text = sendText;
                  }
                  refreshAskFriendsPermissionMovieClip(false);
                  if(m_windowBgTextField)
                  {
                     m_windowBgTextField.text = ZLocUtils.t("Dialogs","MFSWindow_NoFriendsInTab_Body");
                  }
               }
            }
         }
      }
      
      override protected function updateButtonVisibility() : void
      {
         if(!m_currentTab == 0)
         {
            super.updateButtonVisibility();
         }
         else if(m_loadingComplete)
         {
            if(m_currentlyDisplayedFriends.length < 1)
            {
               setVisibleChild(m_selectAllCheckBox,false);
               setVisibleChild(m_backButton,false);
               setVisibleChild(m_nextButton,false);
               setVisibleChild(m_noFriendsClip,true);
               setVisibleChild(m_sendButton,false);
               setVisibleChild(m_progressTextField,false);
               setVisibleChild(m_progressMeter,false);
               setVisibleChild(m_friendsSlotFrame,false);
               m_window.ghost_mc.visible = false;
            }
            else
            {
               setVisibleChild(this.m_ghostfriendsSlotFrame,true);
               setVisibleChild(m_friendsSlotFrame,false);
               setVisibleChild(m_noFriendsClip,false);
               setVisibleChild(m_nextButton,false);
               setVisibleChild(m_backButton,false);
               setVisibleChild(m_selectAllCheckBox,false);
               setVisibleChild(m_sendButton,false);
               setVisibleChild(m_progressTextField,false);
               setVisibleChild(m_progressMeter,false);
               if(m_batchIndex[m_currentTab] == 0)
               {
                  setVisibleChild(m_backButton,false);
               }
               else
               {
                  setVisibleChild(m_backButton,true);
               }
               if(m_batchIndex[m_currentTab] == m_totalCurrentTabBatches - 1)
               {
                  setVisibleChild(m_nextButton,false);
               }
               else
               {
                  setVisibleChild(m_nextButton,true);
               }
            }
         }
      }
      
      override protected function onClickTabFour(evt:MouseEvent = null) : void
      {
         this.openAddNeighborTab();
      }
      
      override protected function onClickTabFive(evt:MouseEvent = null) : void
      {
         if(m_loadingComplete)
         {
            m_currentTab = 4;
            this.m_subCat = CURRENT_NEIGHBORS;
            FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"select",this.m_subCat);
            this.conditionallyRefresh();
            this.m_communityNeighborFrame.visible = false;
            super.onClickTabFive();
            if(m_currentlyDisplayedFriends.length < 1)
            {
               m_noFriendsClip.visible = true;
            }
            else
            {
               this.m_currentNeighborFrame.items = m_currentlyDisplayedFriends;
               this.m_currentNeighborFrame.visible = true;
               this.m_currentNeighborFrame.updateHeader(getFriendsInTab(m_tabNames[m_currentTab]).length);
            }
         }
      }
      
      private function onRemoveNeighborCallback(data:Object) : void
      {
         var dataArray:Array = null;
         if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment() && this.m_currentNeighborFrame.multiDeleteMode)
         {
            if(this.m_selectedNeighborsToDeleteHash[data[MFSConstants.UID]])
            {
               delete this.m_selectedNeighborsToDeleteHash[data[MFSConstants.UID]];
               --this.m_numSelectedNeighborsToDelete;
            }
            else
            {
               this.m_selectedNeighborsToDeleteHash[data[MFSConstants.UID]] = data;
               ++this.m_numSelectedNeighborsToDelete;
            }
            this.m_currentNeighborFrame.multiDeleteButtonEnabled = this.m_numSelectedNeighborsToDelete >= this.m_numNeighborsNeededToDelete;
         }
         else if(Boolean(this.m_deleteConfirmFrame) && data != null)
         {
            dataArray = [];
            dataArray.push(data);
            this.m_deleteConfirmFrame.items = dataArray;
            this.m_deleteConfirmFrame.visible = true;
         }
      }
      
      protected function conditionallyRefresh() : void
      {
         m_currentlyDisplayedFriends = getCurrentTabItems();
         setVisibleChild(m_selectAllCheckBox,false);
         m_noFriendsClip.visible = false;
         m_sendButton.visible = false;
         m_progressTextField.visible = false;
         m_progressMeter.visible = false;
         m_friendsSlotFrame.visible = false;
         if(m_window.ghost_mc)
         {
            m_window.ghost_mc.visible = false;
         }
         if(m_currentTab == 3)
         {
            setVisibleChild(m_backButton,false);
            setVisibleChild(m_nextButton,false);
         }
         else
         {
            if(m_batchIndex[m_currentTab] == 0)
            {
               setVisibleChild(m_backButton,false);
            }
            else
            {
               setVisibleChild(m_backButton,true);
            }
            if(m_batchIndex[m_currentTab] == m_totalCurrentTabBatches - 1)
            {
               setVisibleChild(m_nextButton,false);
            }
            else
            {
               setVisibleChild(m_nextButton,true);
            }
         }
      }
      
      private function refreshNeighborFrame() : void
      {
         if(this.m_communityNeighborFrame)
         {
            this.m_communityNeighborFrame.visible = false;
         }
         if(this.m_currentNeighborFrame)
         {
            this.m_currentNeighborFrame.visible = false;
         }
      }
      
      override protected function refresh(showProgressAnimation:Boolean = true) : void
      {
         if(!m_currentTab == 0)
         {
            super.refresh(false);
         }
         else if(m_tabOneButton != null)
         {
            this.openGhostNeighborTab();
         }
         else
         {
            m_currentTab = 1;
            super.refresh(false);
         }
      }
      
      public function canSendCommunityRequests() : Boolean
      {
         var reqLimit:int = 0;
         var result:Boolean = false;
         var requestCoolDown:int = int(FarmGameUtil.NUM_SECS_IN_DAY);
         var lastRequestSent:int = Global.player.getFeatureLastShown(COMMUNITY_NEIGHBORS_REQUEST);
         var currentTime:int = GlobalEngine.serverTime / 1000;
         var timeSinceLastSent:int = currentTime - lastRequestSent;
         if(timeSinceLastSent < requestCoolDown)
         {
            reqLimit = int(Global.flashHotParams[FEATURE_COMMUNITY_NEIGHBOR_INVITE_LIMIT]);
            this.m_requestLeft = reqLimit - Global.player.getActionCount(COMMUNITY_NEIGHBORS_REQUEST);
            if(this.m_requestLeft > 0)
            {
               result = true;
            }
         }
         else
         {
            result = true;
            this.m_requestLeft = int(Global.flashHotParams[FEATURE_COMMUNITY_NEIGHBOR_INVITE_LIMIT]);
            Global.player.resetActionCount(COMMUNITY_NEIGHBORS_REQUEST,true);
            Global.player.setFeatureLastShown(COMMUNITY_NEIGHBORS_REQUEST,currentTime,true);
         }
         return result;
      }
      
      public function getCurrentNeighbors() : Array
      {
         return this.getItemsForTab(CURRENT_NEIGHBOR_TAB_NUMBER);
      }
      
      override protected function getItemsForTab(tab:int) : Array
      {
         var resultArray:Array = null;
         var tabArray:Array = getFriendsInTab(m_tabNames[tab]);
         if(!m_hasInitialFriendCount[tab] && m_loadingComplete)
         {
            m_numFriends[tab] = tabArray.length;
            m_hasInitialFriendCount[tab] = true;
         }
         if(tab == 0)
         {
            m_batchLimit = ADD_NEIGHBOR_BATCH_LIMIT_TAB0;
         }
         else
         {
            m_batchLimit = ADD_NEIGHBOR_BATCH_LIMIT;
         }
         m_totalCurrentTabBatches = Math.ceil(tabArray.length / m_batchLimit);
         m_batchIndex[tab] = Math.min(Math.max(m_batchIndex[tab],0),m_totalCurrentTabBatches - 1);
         if(tab == 0)
         {
            if(Boolean(this.m_ghostfriendsSlotFrame) && this.m_ghostfriendsSlotFrame.isPaginated())
            {
               resultArray = tabArray.slice(m_batchIndex[tab] * m_batchLimit,m_batchIndex[tab] * m_batchLimit + m_batchLimit);
            }
            else
            {
               resultArray = tabArray;
            }
         }
         else if(Boolean(m_friendsSlotFrame) && m_friendsSlotFrame.isPaginated())
         {
            resultArray = tabArray.slice(m_batchIndex[tab] * m_batchLimit,m_batchIndex[tab] * m_batchLimit + m_batchLimit);
         }
         else
         {
            resultArray = tabArray;
         }
         return resultArray;
      }
      
      public function get numNeighborsNeededToDelete() : int
      {
         return this.m_numNeighborsNeededToDelete;
      }
      
      public function clearSelectedNeighborsToDeleteData() : void
      {
         this.m_numSelectedNeighborsToDelete = 0;
         this.m_selectedNeighborsToDeleteHash = {};
      }
      
      public function removeAndAddNeighbors() : void
      {
         UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"CommunityMatchmakingV3_removeAndAddConfirm"),GenericPopup.TYPE_ACCEPTCANCEL,this.onRemoveAndAddNeighborsClosed,"",true);
      }
      
      public function onRemoveAndAddNeighborsClosed(event:GenericPopupEvent) : void
      {
         var userToDelete:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            StatsManager.count(CommunityMatchmakingUtility.FEATURE_NAME,"purge_neighbors_dialog","num_purged_neighbors",this.m_numNeighborsNeededToDelete.toString());
            for each(userToDelete in this.m_selectedNeighborsToDeleteHash)
            {
               this.onAcceptRemove(userToDelete);
            }
            this.addCommunityNeighborsCallback(null,false);
            this.close();
         }
      }
      
      private function onSelfSelectNeighborsChosen() : void
      {
         this.clearSelectedNeighborsToDeleteData();
         this.m_currentNeighborFrame.multiDeleteMode = true;
         this.m_currentNeighborFrame.addMultiDeleteButton();
         this.onClickTabFive();
         setInitialTabToggle(false,false,false,false,true);
      }
      
      public function addCommunityNeighborsCallback(event:Event, checkNeighborLimit:Boolean = true) : void
      {
         var datum:Object = null;
         var neighborStr:String = null;
         var passedParams:Array = null;
         var isOptedInToCommunityMatchmakingV3:Boolean = false;
         var result:Array = this.m_communityNeighborFrame.getSelectedFriends();
         var numNeighborsToAdd:int = int(result.length);
         var potentialNeighbors:int = numNeighborsToAdd + Global.friendManager.neighborCount;
         var maxNeighbors:int = Global.farmGameSettingsManager.getInt(CommunityMatchmakingUtility.MAX_NEIGHBORS_CONFIG_KEY,CommunityMatchmakingUtility.MAX_NUM_NEIGHBORS);
         maxNeighbors = CommunityMatchmakingUtility.getDebugMaxNeighborLimit(maxNeighbors);
         if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment() && potentialNeighbors > maxNeighbors && checkNeighborLimit)
         {
            this.m_numNeighborsNeededToDelete = potentialNeighbors - maxNeighbors;
            this.clearSelectedNeighborsToDeleteData();
            for each(datum in this.getCurrentNeighbors())
            {
               if(this.m_numSelectedNeighborsToDelete >= this.m_numNeighborsNeededToDelete)
               {
                  break;
               }
               if(CommunityMatchmakingUtility.isInactiveUser(datum))
               {
                  this.m_selectedNeighborsToDeleteHash[datum[MFSConstants.UID]] = datum;
                  ++this.m_numSelectedNeighborsToDelete;
               }
            }
            if(this.m_numNeighborsNeededToDelete == this.m_numSelectedNeighborsToDelete)
            {
               neighborStr = this.m_numSelectedNeighborsToDelete == 1 ? "neighbor" : "neighbors";
               UI.displayPopup(new GenericTwoButtonWindow("assets/dialogs/FV_CommunityNeighbors_delete.swf",CommunityMatchmakingUtility.FEATURE_NAME,this.removeAndAddNeighbors,this.onSelfSelectNeighborsChosen,{
                  "count":this.m_numNeighborsNeededToDelete,
                  "neighborWord":neighborStr
               }),false);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"CommunityMatchmakingV3_neighborListFull"),GenericPopup.TYPE_OK,onClose,"",true);
            }
         }
         else
         {
            if(numNeighborsToAdd > 0)
            {
               if(this.m_requestLeft >= result.length)
               {
                  this.m_requestLeft -= result.length;
               }
               else
               {
                  result.splice(result.length - 1,result.length - this.m_requestLeft);
               }
               Global.player.setActionCount(COMMUNITY_NEIGHBORS_REQUEST,Global.player.getActionCount(COMMUNITY_NEIGHBORS_REQUEST) + result.length);
               this.invalidate(result,"PossibleCommunity");
               this.conditionallyRefresh();
               this.m_communityNeighborFrame.items = m_currentlyDisplayedFriends;
               FarmStatsManager.count(MFS_ADD_NEIGHBOR_STATS,"community_friends_add");
               passedParams = [];
               passedParams.push(result,this.m_source,"");
               if(CommunityMatchmakingUtility.isInCommunityMatchmakingV3Experiment())
               {
                  isOptedInToCommunityMatchmakingV3 = this.m_communityNeighborFrame.isOptedIn();
                  FeatureOptionsManager.getInstance().setFeatureOption(CommunityMatchmakingUtility.FEATURE_NAME,CommunityMatchmakingUtility.FEATURE_OPTION_KEY_OPT_IN,isOptedInToCommunityMatchmakingV3);
                  passedParams.push(isOptedInToCommunityMatchmakingV3);
               }
               TransactionManager.addTransaction(new TGenericTransaction("UserService","sendCommunityInviteRequest",null,passedParams),true);
            }
            if(!this.canSendCommunityRequests())
            {
               this.m_communityNeighborFrame.disableAddNeighborButton();
            }
         }
      }
      
      public function invalidate(uids:Array, friendType:String) : void
      {
         var i:int = 0;
         for(var invalidateUID:int = 0; invalidateUID < uids.length; invalidateUID++)
         {
            for(i = 0; i < m_friends[friendType].length; i++)
            {
               if(uids[invalidateUID] == m_friends[friendType][i].uid)
               {
                  m_friends[friendType][i].valid = false;
               }
            }
         }
      }
      
      override protected function release() : void
      {
         super.release();
         if(this.m_communityNeighborFrame)
         {
            this.m_communityNeighborFrame = null;
         }
         if(this.m_currentNeighborFrame)
         {
            this.m_currentNeighborFrame = null;
         }
         if(this.m_deleteConfirmFrame)
         {
            this.m_deleteConfirmFrame = null;
         }
         if(this.m_deleteConfirmFrame2)
         {
            this.m_deleteConfirmFrame2 = null;
         }
         this.m_selectAllGhostCheckBox = null;
         this.m_ghostfriendsSlotFrame = null;
         this.m_deleteButton = null;
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("FriendListService","getFriendsForR2FlashNeighborFlow",onFriendPopulation),true);
      }
      
      override public function close() : void
      {
         super.close();
         MFSRequestManager.getInstance().releaseAddNeighborWindow();
      }
      
      override protected function fbResponseAction(requestIds:Array) : void
      {
         this.m_creative = "select_all_no";
         if(this.m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_ALL)
         {
            this.m_creative = "select_all_yes";
         }
         TransactionManager.addTransaction(new TSendRequest2NeighborInvite(requestIds,m_serverTime,this.m_subCat,this.m_creative),true);
      }
   }
}

