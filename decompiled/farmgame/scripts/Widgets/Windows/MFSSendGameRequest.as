package Widgets.Windows
{
   import Classes.Constants.MFSConstants;
   import Classes.MatchMaking.MatchMakingManager;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUD;
   import Engine.Managers.TransactionManager;
   import Managers.AFInnovationManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.MFSWindowSlotFrame;
   import com.adobe.serialization.json.JSON;
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class MFSSendGameRequest extends MFSWindow
   {
      
      protected var m_featureName:String;
      
      protected var m_assetUrl:String;
      
      private var m_player2UID:String;
      
      private var m_player2Name:String;
      
      private var m_gameId:String;
      
      private var m_matchTimer:Timer;
      
      private var m_currentTimeCount:int = 0;
      
      private const DEFAULT_CONNECTION_WAITING_PERIOD:Number = 25;
      
      public function MFSSendGameRequest(featureName:String, source:String, completeCallback:Function, assetUrl:String)
      {
         var friendSpec:Object = {"tabNameRequest":["OnlineFriends"]};
         this.m_featureName = featureName;
         this.m_assetUrl = assetUrl;
         super(friendSpec,null,null,completeCallback,"OnlineFriends",source,featureName,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.header_tf)
         {
            m_titleTextField = addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs",m_MFSTypeString + "_Title"))) as ZwTextField;
         }
         if(m_window.txt_body)
         {
            m_descriptionTextField = addWidget(new ZwTextField(m_window.txt_body,ZLocUtils.t("Dialogs",m_MFSTypeString + "_Subtitle"))) as ZwTextField;
         }
         if(m_window.noMoreFriends_mc)
         {
            m_noFriendsClip = addWidget(new ZwWidget(m_window.noMoreFriends_mc)) as ZwWidget;
            m_windowBgTextField = addWidget(new ZwTextField(m_window.noMoreFriends_mc.copy_tf,ZLocUtils.t("Dialogs","MFSWindow_NoFriendsInTab_Body"))) as ZwTextField;
            m_noFriendsClip.visible = false;
         }
         addCornerContents();
         addBackgroundScene();
         this.addWindowSubtitle();
         if(m_window.mc_loader)
         {
            m_loadingSpinner = addWidget(new ZwWidget(m_window.mc_loader)) as ZwWidget;
         }
         if(m_window.mc_slotcontainer)
         {
            m_friendsSlotFrame = new MFSWindowSlotFrame(m_window.mc_slotcontainer,this.onSlotClick);
         }
         if(m_window.next_bt)
         {
            m_nextButton = new FarmAnimatedTextButton(m_window.next_bt,ZLocUtils.t("Dialogs","MFSWindow_Next"),onClickNext);
            addWidget(m_nextButton);
            m_nextButton.visible = false;
         }
         if(m_window.back_bt)
         {
            m_backButton = new FarmAnimatedTextButton(m_window.back_bt,ZLocUtils.t("Dialogs","MFSWindow_Back"),onClickBack);
            addWidget(m_backButton);
            m_backButton.visible = false;
         }
         if(m_friendsSlotFrame)
         {
            addWidget(m_friendsSlotFrame);
            m_friendsSlotFrame.visible = false;
         }
         if(m_window.delay_close_bt)
         {
            m_delayCloseButton = addWidget(new FarmButton(m_window.delay_close_bt,this.onClose),false) as FarmButton;
         }
         if(m_showFeedDialog)
         {
            m_FeedDialogActive = true;
            m_MFSDialogQueued = true;
            switchFromMFSToFeed();
         }
         this.sendPopulatingTransaction();
      }
      
      override protected function getRequestData() : String
      {
         var requestData:Array = [];
         m_serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
         requestData.push(MFSConstants.FB_REQ2_REQUESTTYPE_ASKITEMS);
         requestData.push(this.m_featureName);
         requestData.push(m_item.name);
         requestData.push(m_serverTime);
         return com.adobe.serialization.json.JSON.encode(requestData);
      }
      
      override protected function getRequestMessage(currentTabName:String) : String
      {
         var result:String = null;
         var requestTextKey:String = "_request_gift_text";
         if(ZLocUtils.hasString("Gifts",this.m_featureName + requestTextKey))
         {
            result = ZLocUtils.t_pk("Gifts",this.m_featureName + requestTextKey,{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
         }
         return result;
      }
      
      override protected function sendPopulatingTransaction() : void
      {
         TransactionManager.addTransaction(new TGenericTransaction("MatchService","getOnlineFriends",onFriendPopulation),true);
      }
      
      override protected function postRefreshActions() : void
      {
         FarmStatsManager.count("Hand_of_Destiny","MFS_UI","online_friends","","","",m_numFriends[0] + m_numFriends[1] + m_numFriends[2]);
      }
      
      private function onchatMessageReceived(e:DataEvent) : void
      {
         if(e.data.indexOf("Accepted:" + this.m_gameId) != -1)
         {
            FarmStatsManager.count("Hand_of_Destiny","MFS_UI",this.m_player2UID,"Accept",this.m_gameId,"",this.m_currentTimeCount);
            if(this.m_matchTimer)
            {
               this.m_matchTimer.stop();
            }
            MatchMakingManager.getInstance().sendMessage("StartGame:" + this.m_gameId,this.m_player2UID);
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
            AFInnovationManager.getInstance().setPlayerStatus(this.m_player2UID);
            AFInnovationManager.getInstance().p2pWindow.initializeGameBoard(this.m_player2UID,this.m_gameId,AFInnovationManager.getInstance().playerStatus);
            this.close();
         }
      }
      
      override protected function addCornerAvatar() : void
      {
      }
      
      override protected function getMessageText() : String
      {
         return "ItemName";
      }
      
      override protected function addWindowSubtitle() : void
      {
      }
      
      override protected function setWindowDescription() : void
      {
      }
      
      private function sendGameRequest(uid:String, name:String) : void
      {
         var onTimerExpired:Function;
         FarmStatsManager.count("Hand_of_Destiny","MFS_UI",uid,"Send");
         onTimerExpired = function(event:TimerEvent):void
         {
            refreshConnectionTimerText();
         };
         AFInnovationManager.getInstance().openP2PGameWindow();
         this.m_player2UID = uid;
         this.m_player2Name = name;
         this.m_gameId = MatchMakingManager.getInstance().createGameId(Global.player.uid,this.m_player2UID);
         MatchMakingManager.getInstance().addZoomFriend(this.m_player2UID);
         MatchMakingManager.getInstance().sendGameRequest(this.m_player2UID);
         MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
         if(this.m_matchTimer != null)
         {
            this.m_matchTimer.stop();
            this.m_matchTimer = null;
         }
         this.m_matchTimer = new Timer(1000);
         this.m_matchTimer.addEventListener(TimerEvent.TIMER,onTimerExpired);
         this.m_matchTimer.start();
      }
      
      private function refreshConnectionTimerText() : void
      {
         var text1:String = null;
         var timerText:String = null;
         var text2:String = null;
         if(this.m_currentTimeCount > this.DEFAULT_CONNECTION_WAITING_PERIOD)
         {
            this.m_matchTimer.stop();
            AFInnovationManager.getInstance().p2pWindow.setOverlayText(this.m_player2Name + " has declined your invite.","","Okay",AFInnovationManager.getInstance().p2pWindow.closeWindowAndShowMainUI);
            FarmStatsManager.count("Hand_of_Destiny","MFS_UI",this.m_player2UID,"Reject",this.m_gameId,"",this.m_currentTimeCount);
         }
         else
         {
            text1 = "Inviting your friend. Please wait for " + this.m_player2Name + " to respond.";
            timerText = HUD.getformattedTimeLeft(this.DEFAULT_CONNECTION_WAITING_PERIOD - this.m_currentTimeCount);
            text2 = "This invite will expire in " + timerText + "seconds";
            AFInnovationManager.getInstance().p2pWindow.setOverlayText(text1,text2);
            this.m_currentTimeCount += 1;
         }
      }
      
      override public function onSlotClick() : void
      {
         m_selectionStatus = m_friendsSlotFrame.checkSelectedStatus(m_currentlyDisplayedFriends.length);
         var friendData:Array = m_friendsSlotFrame.getSelectedFriendsData();
         close();
         this.sendGameRequest(friendData[0]["uid"],friendData[0]["name"]);
      }
      
      override protected function updateSendButtonOnSlotSelection() : void
      {
         if(m_selectionStatus == MFSWindowSlotFrame.SELECT_STATE_NONE)
         {
            setEnabledChild(m_sendButton,false);
         }
         else
         {
            setEnabledChild(m_sendButton,true);
         }
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      override protected function onClose(e:Event) : void
      {
         super.onClose(e);
         AFInnovationManager.getInstance().showMainUI();
      }
   }
}

