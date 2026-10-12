package Widgets.Windows
{
   import Classes.Friend;
   import Classes.Zoom.ZoomMessage;
   import Classes.util.ExternalUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Engine.Utilities;
   import Events.OnlineStatusEvent;
   import Managers.ChatManager;
   import Managers.FarmStatsManager;
   import Managers.ZoomManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class ChatWindow extends FarmWindow
   {
      
      private static const CHAT_SWF:String = "assets/dialogs/FV_Chat.swf";
      
      private static const PLAYER_ICON_SIZE:int = 50;
      
      private static const TEXT_ENTRY_MAX_CHARS:int = 200;
      
      private static const FULLSCREEN_Y_OFFSET:int = 610;
      
      private var m_friendInfo:Friend = null;
      
      private var m_messages:Array = null;
      
      private var m_arrowIndex:int = 0;
      
      private var m_toUid:String = "-1";
      
      private var m_hasUnreadMsgs:Boolean = false;
      
      private var m_textEntry:ZwTextField = null;
      
      private var m_textField:ZwTextField = null;
      
      private var m_loaded:Boolean = false;
      
      private var m_upArrowButton:FarmAnimatedButton = null;
      
      private var m_downArrowButton:FarmAnimatedButton = null;
      
      private var m_mainFrame:ZwFrame = null;
      
      private var m_sendButton:FarmAnimatedTextButton = null;
      
      private var m_exitFullscreenButton:FarmAnimatedTextButton = null;
      
      private var m_statusIcon:ZwWidget = null;
      
      private var m_autoSortFriendBarOnClose:Boolean = false;
      
      private var m_textChanged:Boolean = false;
      
      private var m_enableChatButton:FarmAnimatedTextButton = null;
      
      private var m_textFieldMc:ZwWidget = null;
      
      private var m_sendGiftButton:FarmAnimatedTextButton = null;
      
      public function ChatWindow(friendInfo:Friend, messages:Array, arrowIndex:int, hasUnreadMsgs:Boolean)
      {
         super(CHAT_SWF);
         this.m_friendInfo = friendInfo;
         this.m_messages = messages;
         this.m_arrowIndex = arrowIndex;
         this.m_toUid = this.m_friendInfo.uid;
         this.m_hasUnreadMsgs = hasUnreadMsgs;
         ChatManager.instance.addEventListener(OnlineStatusEvent.STATUS_CHANGE,this.onStatusChange);
         Global.stage.addEventListener(Event.FULLSCREEN,this.onFullscreen);
         Global.overrideDebugKeys = true;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.m_mainFrame = new ZwFrame(m_window.main_mc);
         if(!m_window.main_mc.hasOwnProperty("arrow" + this.m_arrowIndex + "_mc"))
         {
            this.m_arrowIndex = 0;
         }
         var arrowClip:MovieClip = m_window.main_mc["arrow" + this.m_arrowIndex + "_mc"] as MovieClip;
         this.m_mainFrame.addWidget(new ZwWidget(arrowClip));
         this.m_textEntry = this.m_mainFrame.addWidget(new ZwTextField(m_window.main_mc.enter_tf,"")) as ZwTextField;
         m_window.main_mc.enter_tf.addEventListener(Event.CHANGE,this.onTextChanged);
         (this.m_textEntry.element as TextField).maxChars = TEXT_ENTRY_MAX_CHARS;
         this.m_sendButton = this.m_mainFrame.addWidget(new FarmAnimatedTextButton(m_window.main_mc.send_bt,ZLocUtils.t("Dialogs","MFSWindow_SendButton"),this.onSend)) as FarmAnimatedTextButton;
         this.m_exitFullscreenButton = this.m_mainFrame.addWidget(new FarmAnimatedTextButton(m_window.main_mc.exit_bt,ZLocUtils.t("Dialogs","Exit"),this.onExit)) as FarmAnimatedTextButton;
         var playerImage:FarmIcon = this.m_mainFrame.addWidget(new FarmIcon(m_window.main_mc.icon_mc,this.m_friendInfo.picture)) as FarmIcon;
         playerImage.setIconSize(PLAYER_ICON_SIZE,PLAYER_ICON_SIZE);
         this.m_upArrowButton = this.m_mainFrame.addWidget(new FarmAnimatedButton(m_window.main_mc.arrowUp_bt,this.onArrowUp)) as FarmAnimatedButton;
         this.m_downArrowButton = this.m_mainFrame.addWidget(new FarmAnimatedButton(m_window.main_mc.arrowDown_bt,this.onArrowDown)) as FarmAnimatedButton;
         Global.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyboardEventHandler);
         this.refreshMessageTextArea();
         this.m_loaded = true;
         m_closeButton = this.m_mainFrame.addWidget(new FarmButton(m_window.main_mc.close_bt,onClose)) as FarmButton;
         this.m_sendGiftButton = this.m_mainFrame.addWidget(new FarmAnimatedTextButton(m_window.main_mc.gift_bt,ZLocUtils.t("Dialogs","VisitBackGiftButtonBig"),this.onGiftClick)) as FarmAnimatedTextButton;
         if(!Global.player.isEligibleGiftRecipient(this.m_toUid))
         {
            this.m_sendGiftButton.enabled = false;
            this.m_sendGiftButton.applyGrayOut = true;
         }
         var visitBtn:FarmAnimatedTextButton = this.m_mainFrame.addWidget(new FarmAnimatedTextButton(m_window.main_mc.visit_bt,ZLocUtils.t("Dialogs","message_center_visit"),this.onVisitClick)) as FarmAnimatedTextButton;
         if(Global.worldManager.getVisiting() == this.m_toUid)
         {
            visitBtn.enabled = false;
            visitBtn.applyGrayOut = true;
         }
         this.m_mainFrame.addWidget(new ZwTextField(m_window.main_mc.name_tf,this.m_friendInfo.firstName));
         this.m_statusIcon = this.m_mainFrame.addWidget(new ZwWidget(m_window.main_mc.status_mc)) as ZwWidget;
         this.m_enableChatButton = this.m_mainFrame.addWidget(new FarmAnimatedTextButton(m_window.main_mc.enable_bt,ZLocUtils.t("Dialogs","enableChat",{"userName":this.m_friendInfo.firstName}),this.onEnableChat),!Global.player.farmTalkPermission) as FarmAnimatedTextButton;
         this.m_textFieldMc = this.m_mainFrame.addWidget(new ZwWidget(m_window.main_mc.textField_mc)) as ZwWidget;
         if(!Global.player.farmTalkPermission)
         {
            this.m_sendButton.visible = false;
            this.m_textEntry.visible = false;
            this.m_textFieldMc.visible = false;
            this.m_exitFullscreenButton.visible = false;
         }
         this.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         this.refreshPresenceIcon();
         this.checkAndHandleCurrentZoomStatus();
         if(Utilities.isFullScreen())
         {
            this.m_textEntry.text = ZLocUtils.t("Dialogs","noChat");
            this.m_textEntry.selectable = false;
            this.m_sendButton.visible = false;
         }
         else
         {
            this.m_exitFullscreenButton.visible = false;
            Global.stage.focus = m_window.main_mc.enter_tf;
         }
         addWidget(this.m_mainFrame);
         (m_window as MovieClip).gotoAndPlay("intro");
      }
      
      private function refreshMessageTextArea() : void
      {
         var message:ZoomMessage = null;
         var msgText:String = "";
         if(Global.player.farmTalkPermission == true)
         {
            if(this.m_messages.length > 0)
            {
               for each(message in this.m_messages)
               {
                  msgText += this.getMessageText(message);
               }
            }
            else
            {
               msgText = ZLocUtils.t("Dialogs","sendMessageTo",{
                  "color":"#401e00",
                  "friendName":this.m_friendInfo.firstName
               });
            }
         }
         else
         {
            msgText = ZLocUtils.t("Dialogs","chatDisabled");
         }
         if(this.m_textField == null)
         {
            this.m_textField = addWidget(new ZwTextField(m_window.main_mc.recieved_tf,"",true)) as ZwTextField;
         }
         this.m_textField.text = msgText;
         (this.m_textField.element as TextField).scrollV = (this.m_textField.element as TextField).maxScrollV;
         this.refreshScrollButtonStates();
      }
      
      private function getMessageText(zoomMessage:ZoomMessage) : String
      {
         var result:String = "";
         if(zoomMessage.type == ChatManager.EVENTTYPE_CHAT)
         {
            result = ZLocUtils.t("Dialogs","messageFrom",{
               "color":"#0d171e",
               "friendName":this.m_friendInfo.firstName
            });
         }
         else if(zoomMessage.type == ChatManager.EVENTTYPE_SELF_CHAT)
         {
            result = ZLocUtils.t("Dialogs","messageSelf",{"color":"#6d7988"});
         }
         return result + ZLocUtils.t("Dialogs","messageContent",{"content":zoomMessage.content});
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_textField = null;
         this.m_textEntry = null;
         this.m_downArrowButton = null;
         this.m_upArrowButton = null;
         this.m_sendButton = null;
         this.m_exitFullscreenButton = null;
         this.m_statusIcon = null;
         ChatManager.instance.removeEventListener(OnlineStatusEvent.STATUS_CHANGE,this.onStatusChange);
         Global.stage.removeEventListener(Event.FULLSCREEN,this.onFullscreen);
         Global.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyboardEventHandler);
         Global.overrideDebugKeys = false;
         this.m_enableChatButton = null;
         this.m_textFieldMc = null;
         this.m_sendGiftButton = null;
      }
      
      private function onArrowUp(event:Event) : void
      {
         if(this.m_textField.element)
         {
            --(this.m_textField.element as TextField).scrollV;
            this.refreshScrollButtonStates();
         }
      }
      
      private function onArrowDown(event:Event) : void
      {
         if(this.m_textField.element)
         {
            ++(this.m_textField.element as TextField).scrollV;
            this.refreshScrollButtonStates();
         }
      }
      
      private function onMouseWheel(event:MouseEvent) : void
      {
         this.refreshScrollButtonStates();
      }
      
      private function refreshScrollButtonStates() : void
      {
         if(this.m_downArrowButton != null)
         {
            if((this.m_textField.element as TextField).scrollV == (this.m_textField.element as TextField).maxScrollV)
            {
               this.m_downArrowButton.applyGrayOut = true;
               this.m_downArrowButton.enabled = false;
            }
            else
            {
               this.m_downArrowButton.applyGrayOut = false;
               this.m_downArrowButton.enabled = true;
            }
         }
         if(this.m_upArrowButton != null)
         {
            if((this.m_textField.element as TextField).scrollV == 1)
            {
               this.m_upArrowButton.applyGrayOut = true;
               this.m_upArrowButton.enabled = false;
            }
            else
            {
               this.m_upArrowButton.applyGrayOut = false;
               this.m_upArrowButton.enabled = true;
            }
         }
      }
      
      private function onVisitClick(event:Event) : void
      {
         Global.worldManager.visitNeighbor(this.m_friendInfo.uid.toString());
         FarmStatsManager.count("chat","clickvisit");
      }
      
      private function onGiftClick(event:Event) : void
      {
         this.close();
         FreeGiftSelectionWindow.popWindow();
         FarmStatsManager.count("chat","clickgift");
      }
      
      private function keyboardEventHandler(event:KeyboardEvent) : void
      {
         switch(event.charCode)
         {
            case 27:
               this.close();
               break;
            case 13:
               this.onSend(event);
         }
      }
      
      override public function close() : void
      {
         (m_window as MovieClip).gotoAndPlay("outro");
         (m_window as MovieClip).addEventListener(Event.ENTER_FRAME,this.onCloseEnterFrame);
         ChatManager.markMessagesReadFromUid(this.m_toUid);
         if(this.m_autoSortFriendBarOnClose)
         {
            Global.ui.m_friendBar.autoSortStart();
         }
      }
      
      private function onCloseEnterFrame(event:Event) : void
      {
         if((m_window as MovieClip).currentFrame == (m_window as MovieClip).totalFrames)
         {
            (m_window as MovieClip).removeEventListener(Event.ENTER_FRAME,this.onCloseEnterFrame);
            ChatManager.currentChatWindowOpen = "0";
            super.close();
         }
      }
      
      private function onSend(event:Event) : void
      {
         var wasMessageWaitingStr:String = null;
         var groupId:String = null;
         var onlineStatus:String = null;
         var text:String = escape(this.m_textEntry.text);
         var zoomOkay:Boolean = this.checkAndHandleCurrentZoomStatus();
         if(zoomOkay)
         {
            ExternalUtil.instance.call("sendZoomMessage",this.m_toUid.toString(),text,"chat");
            ExternalUtil.instance.call("sendZoomMessage",Global.player.uid,text,"selfChat:" + this.m_toUid.toString());
            FarmStatsManager.sample(100,"chat","chatFlow","1_sentChatMessage_as");
            wasMessageWaitingStr = this.m_hasUnreadMsgs ? "message_waiting" : "not_waiting";
            groupId = this.m_friendInfo.isCommunityNeighbor ? "community" : "fb";
            onlineStatus = ChatManager.getOnlineStatus(this.m_toUid) == OnlineStatusEvent.STATUS_OFFLINE ? "offline" : "online";
            StatsManager.social("chat",String(this.m_toUid),"click_send",wasMessageWaitingStr,groupId,onlineStatus,0,Global.worldManager.currentWorldType);
            this.m_textChanged = false;
         }
      }
      
      private function onStatusChange(event:OnlineStatusEvent) : void
      {
         if(event.friendUid == this.m_toUid)
         {
            switch(event.status)
            {
               case OnlineStatusEvent.NEW_MESSAGE:
                  this.handleNewMessage(event);
                  break;
               default:
                  this.refreshPresenceIcon();
            }
         }
         if(event.status == OnlineStatusEvent.STATUS_ONLINE)
         {
            this.m_autoSortFriendBarOnClose = true;
         }
         else if(Boolean(event.status == OnlineStatusEvent.NEW_MESSAGE) && Boolean(event.message) && event.message.type == ChatManager.EVENTTYPE_CHAT)
         {
            this.m_autoSortFriendBarOnClose = true;
         }
      }
      
      private function handleNewMessage(event:OnlineStatusEvent) : void
      {
         if(this.m_loaded)
         {
            this.refreshMessageTextArea();
         }
      }
      
      private function refreshPresenceIcon() : void
      {
         if(this.m_statusIcon != null)
         {
            this.m_statusIcon.visible = ChatManager.getOnlineStatus(this.m_toUid) == OnlineStatusEvent.STATUS_ONLINE;
         }
      }
      
      private function onTextChanged(event:Event) : void
      {
         var wasMessageWaitingStr:String = null;
         var groupId:String = null;
         var onlineStatus:String = null;
         if(!this.m_textChanged)
         {
            this.m_textChanged = true;
            wasMessageWaitingStr = this.m_hasUnreadMsgs ? "message_waiting" : "not_waiting";
            groupId = this.m_friendInfo.isCommunityNeighbor ? "community" : "fb";
            onlineStatus = ChatManager.getOnlineStatus(this.m_toUid) == OnlineStatusEvent.STATUS_OFFLINE ? "offline" : "online";
            StatsManager.social("chat",String(this.m_toUid),"text_input",wasMessageWaitingStr,groupId,onlineStatus,0,Global.worldManager.currentWorldType);
         }
      }
      
      private function onFullscreen(event:Event) : void
      {
         if(!Utilities.isFullScreen())
         {
            this.m_textEntry.text = "";
            this.m_textEntry.selectable = true;
            Global.stage.focus = m_window.main_mc.enter_tf;
            this.m_sendButton.visible = Global.player.farmTalkPermission;
            this.m_exitFullscreenButton.visible = false;
            this.centerPopup();
            this.checkAndHandleCurrentZoomStatus();
         }
      }
      
      override public function centerPopup(pAbsolutePos:Point = null) : void
      {
         super.centerPopup(pAbsolutePos);
         if(Utilities.isFullScreen() && pAbsolutePos == null)
         {
            this.y = Global.stage.stageHeight - FULLSCREEN_Y_OFFSET;
         }
      }
      
      private function onExit(event:Event) : void
      {
         if(Utilities.isFullScreen())
         {
            Utilities.toggleFullScreen();
         }
      }
      
      private function checkAndHandleCurrentZoomStatus() : Boolean
      {
         var result:Boolean = ZoomManager.isZoomOkay();
         if(!result)
         {
            this.m_textEntry.text = ZLocUtils.t("Dialogs","chatDown");
            this.m_textEntry.selectable = false;
            this.m_sendButton.applyGrayOut = true;
            this.m_sendButton.enabled = false;
         }
         else
         {
            this.m_textEntry.text = "";
            this.m_textEntry.selectable = true;
            this.m_sendButton.applyGrayOut = false;
            this.m_sendButton.enabled = true;
         }
         return result;
      }
      
      private function setUpForFullscreen() : void
      {
         this.m_textEntry.text = ZLocUtils.t("Dialogs","noChat");
         this.m_textEntry.selectable = false;
         this.m_sendButton.visible = false;
      }
      
      private function onEnableChat(event:Event) : void
      {
         var timer:Timer = null;
         Global.player.farmTalkPermission = true;
         this.m_sendButton.visible = true;
         this.m_textEntry.visible = true;
         this.m_textFieldMc.visible = true;
         this.m_enableChatButton.visible = false;
         this.refreshMessageTextArea();
         if(Utilities.isFullScreen())
         {
            this.setUpForFullscreen();
         }
         ZoomManager.initConnection();
         ZoomManager.readyForData();
         timer = new Timer(1000,1);
         timer.addEventListener(TimerEvent.TIMER_COMPLETE,function(event:TimerEvent):void
         {
            if(!Utilities.isFullScreen())
            {
               checkAndHandleCurrentZoomStatus();
            }
            timer.removeEventListener(TimerEvent.TIMER_COMPLETE,arguments.callee);
         });
         timer.start();
         FarmStatsManager.count("chat","opt_out","enable","chat_ui");
      }
   }
}

