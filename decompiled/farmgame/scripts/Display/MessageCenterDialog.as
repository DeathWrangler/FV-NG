package Display
{
   import Classes.Constants.Experiments;
   import Classes.EmbeddedArt;
   import Classes.FarmSocialNetwork;
   import Classes.Friend;
   import Classes.Message;
   import Classes.MessageSign;
   import Classes.SocialAction;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.HUD.MessageCenterButton;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Managers.EmailManager;
   import Managers.FarmStatsManager;
   import Managers.MessageManager;
   import Managers.SocialActionsManager;
   import Transactions.TMessageSignPlace;
   import com.adobe.utils.StringUtil;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.*;
   
   public class MessageCenterDialog extends SlotDialog
   {
      
      private var m_messages:Array;
      
      private var m_display_messages:Array;
      
      private var m_index:Number = 0;
      
      private var m_buttons:Array;
      
      private const CHECK_MARK_FRAME_ON:int = 1;
      
      private const CHECK_MARK_FRAME_OFF:int = 2;
      
      private const MESSAGE_ICON_WIDTH:int = 50;
      
      private const MESSAGE_ICON_HEIGHT:int = 50;
      
      private const MAX_CHARS:Number = 140;
      
      private const MAX_MESSAGES:Number = 30;
      
      private const NUM_MESSAGE_SLOTS:Number = 3;
      
      private const NUM_SLOT_BUTTONS:int = 4;
      
      private const DELETE_OFFSET_INDEX:int = 0;
      
      private const REPLY_OFFSET_INDEX:int = 1;
      
      private const GIFT_OFFSET_INDEX:int = 2;
      
      private const VISIT_OFFSET_INDEX:int = 3;
      
      private const ERROR_MESSAGE_NOT_FOUND:Number = -1;
      
      private const GAME_MESSAGE_TEXT_COLOR:Number = 255;
      
      private const POST_INDEX:int = 13;
      
      private const REPORT_INDEX:int = 14;
      
      private const USER_MESSAGE_TEXT_COLOR:Number = 0;
      
      private const FIRST_ELEMENT_OF_TIME_ARRAY:Number = 0;
      
      private const ABUSE_EMAIL:String = "mailto:reportabuse@zynga.com";
      
      private const UNSELECTED_FRAME:int = 1;
      
      private const SELECTED_FRAME:int = 3;
      
      private const SEEN_FLAG_COMMENT_FIRST_OPEN:String = "commentFirstOpen";
      
      private const SEEN_FLAG_COMMENT_ASK_STREAM_PERMISSIONS:String = "commentBoxAskStream";
      
      private var m_messageSign:MessageSign = null;
      
      private var m_willPlaceSign:Boolean = false;
      
      private var m_isViewSignMessage:Boolean = false;
      
      private var m_isSocial:Boolean = false;
      
      private var m_iswallpost:Boolean = false;
      
      private var m_hasActivatedText:Boolean = false;
      
      private var m_replyMessageId:Number = 0;
      
      private var m_isVisiting:Boolean;
      
      public function MessageCenterDialog(messageSign:MessageSign = null, isViewSignMessage:Boolean = false)
      {
         var currentTime:Number = NaN;
         this.m_messages = new Array();
         this.m_display_messages = new Array();
         this.m_buttons = new Array();
         this.m_isVisiting = Global.worldManager.isVisiting();
         m_dialogAsset = "assets/dialogs/FV_Message_Center_lrg.swf";
         this.name = "MessageCenter";
         this.m_messageSign = messageSign;
         this.m_isViewSignMessage = isViewSignMessage;
         super();
         if(!Global.player.getSeenFlag(this.SEEN_FLAG_COMMENT_FIRST_OPEN))
         {
            FarmStatsManager.count("Comment_box","comment_box_first_time");
            Global.player.setSeenFlag(this.SEEN_FLAG_COMMENT_FIRST_OPEN);
            currentTime = GlobalEngine.serverTime / 1000;
            Global.player.setFeatureLastShown(this.SEEN_FLAG_COMMENT_FIRST_OPEN,currentTime,true);
         }
         if(Utilities.isFullScreen())
         {
            Utilities.toggleFullScreen();
         }
      }
      
      override protected function onLoadComplete() : void
      {
         var titleText:String = null;
         var friendUid:String = null;
         var host:Friend = null;
         var userName:String = null;
         super.onLoadComplete();
         this.addEventListeners();
         if(Global.worldManager.isVisiting())
         {
            friendUid = Global.worldManager.getVisiting();
            host = Global.friendManager.getFriendData(friendUid);
            userName = MessageManager.getPlayerName(friendUid,false);
            titleText = ZLocUtils.t("Dialogs","message_center_title_visit",{"user":ZLocUtils.tn(userName)});
         }
         else
         {
            titleText = ZLocUtils.t("Dialogs","message_center_title");
         }
         m_window.messageTitle_tf.text = titleText;
         ZLocUtils.autoFormatSize(m_window.messageTitle_tf);
         ZLocUtils.setText(m_window,"playerName_tf","Dialogs","message_center_player_name");
         ZLocUtils.setText(m_window,"comment_tf","Dialogs","message_center_comment");
         m_window.comment_tf.maxChars = this.MAX_CHARS;
         m_window.comment_tf.multiline = false;
         ZLocUtils.setText(m_window,"signPost_tf","Dialogs","message_center_signpost");
         ZLocUtils.setText(m_window,"loggedIn_tf","Dialogs","message_center_logged_in");
         ZLocUtils.setText(m_window,"postProfile_tf","Dialogs","message_center_postprofile");
         ZLocUtils.setText(m_window,"commentsTabOn_tf","Dialogs","message_center_commentstab");
         ZLocUtils.setText(m_window,"commentsTabOff_tf","Dialogs","message_center_commentstab");
         ZLocUtils.setText(m_window,"socialTabOn_tf","Dialogs","message_center_socialtab");
         ZLocUtils.setText(m_window,"socialTabOff_tf","Dialogs","message_center_socialtab");
         ZLocUtils.setText(m_window,"email_tf","Dialogs","message_center_email");
         this.setupPlayerPanel();
         m_tiles.push(m_window.commentCell1_mc,m_window.commentCell2_mc,m_window.commentCell3_mc);
         removeTiles();
         var isViewMessageSign:Boolean = this.m_isViewSignMessage && this.m_messageSign != null;
         if(!isViewMessageSign)
         {
            if(0 == MessageManager.getInstance().getMessages().length)
            {
               this.m_isSocial = SocialActionsManager.getInstance().getActions().length > 0;
            }
            else if(MessageManager.getInstance().getNumNewMessages() == 0)
            {
               this.m_isSocial = SocialActionsManager.getInstance().getNumNewActions() > 0;
            }
         }
         if(this.m_isSocial)
         {
            this.populateSocial();
         }
         else
         {
            this.populateMessages();
         }
         if(isViewMessageSign)
         {
            m_tileSet = this.findPageIndexById(this.m_messageSign.getMessageId());
         }
         var startIndex:int = m_tileSet * this.getNumSlots();
         addAllComponents(startIndex);
         this.cleanUpVisuals();
         this.switchTabs();
         m_window.commentEntry_mc.visible = false;
         if(this.m_messageSign != null && !this.m_isViewSignMessage)
         {
            this.m_willPlaceSign = true;
            this.setCheckMarkState(m_window.checkMarkSignPost_mc,true);
            this.onClickTextBox(null);
            Global.stage.focus = m_window.comment_tf;
         }
         m_window.checkMarkEmail_mc.visible = false;
         m_window.checkMarkEmail_mc.enabled = false;
         m_window.checkMarkEmail_bt.visible = false;
         m_window.checkMarkEmail_bt.enabled = false;
         m_window.email_tf.visible = false;
         MessageManager.getInstance().removeMessageAvatars();
         MessageManager.getInstance().showCommentBoxEmailPrompt(this.onFinishEmailPermissions);
      }
      
      private function onFinishEmailPermissions() : void
      {
         if(GlobalEngine.socialNetwork.userHasEmailPermission())
         {
            this.setCheckMarkState(m_window.checkMarkEmail_mc,true);
         }
      }
      
      private function cleanUpVisuals() : void
      {
         this.setCheckMarkState(m_window.checkMarkSignPost_mc,false);
         this.setCheckMarkState(m_window.checkMarkFaceBook_mc,false);
         this.setCheckMarkState(m_window.checkMarkEmail_mc,false);
         var showPostProfile:Boolean = this.m_isVisiting;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_REMOVE_STREAM_PUBLISH_W2W) > 1)
         {
            showPostProfile = false;
         }
         if(Global.farmSocialNetwork.getSocialNetworkId() == FarmSocialNetwork.SNID_ZLIVE)
         {
            m_window.checkMarkFaceBook_mc.visible = false;
            m_window.checkMarkFaceBook_bt.visible = false;
            m_window.postProfile_tf.text = "";
         }
         else
         {
            m_window.checkMarkFaceBook_mc.visible = showPostProfile;
            m_window.checkMarkFaceBook_bt.visible = showPostProfile;
         }
         m_window.postProfile_tf.visible = showPostProfile;
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         var message:Message = null;
         super.onCloseClick(event);
         if(!this.m_isViewSignMessage && this.m_messageSign != null && this.m_messageSign.getMessageId() == 0)
         {
            message = MessageManager.getInstance().getMessageByMessageSignId(this.m_messageSign.getId());
            if(null == message || message.getAuthorId() == "-1")
            {
               this.m_messageSign.detach();
            }
         }
         event.stopPropagation();
         this.cleanUpAndClose();
      }
      
      private function addEventListeners() : void
      {
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         this.m_buttons[this.POST_INDEX] = new GenericButton(m_window.post_bt,this.onPostClick);
         this.m_buttons[this.POST_INDEX].text = ZLocUtils.t("Dialogs","Post");
         m_window.arrowUp_bt.addEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.arrowDown_bt.addEventListener(MouseEvent.CLICK,onRtArrowClick);
         m_window.checkMarkSignPost_bt.addEventListener(MouseEvent.CLICK,this.toggleSignPost);
         m_window.commentsTab_bt.addEventListener(MouseEvent.CLICK,this.switchToComments);
         m_window.socialTab_bt.addEventListener(MouseEvent.CLICK,this.switchToSocial);
         m_window.checkMarkFaceBook_bt.addEventListener(MouseEvent.CLICK,this.toggleFaceBook);
         m_window.checkMarkEmail_bt.addEventListener(MouseEvent.CLICK,this.toggleReceiveEmail);
         this.m_buttons[this.REPORT_INDEX] = new GenericButton(m_window.reportAbuse_bt,this.onReportAbuse);
         this.m_buttons[this.REPORT_INDEX].text = ZLocUtils.t("Dialogs","Report");
         m_window.comment_tf.addEventListener(MouseEvent.CLICK,this.onClickTextBox);
      }
      
      private function onClickTextBox(event:MouseEvent) : void
      {
         if(!this.m_hasActivatedText)
         {
            m_window.comment_tf.text = "";
            this.m_hasActivatedText = true;
         }
      }
      
      private function toggleReceiveEmail(event:MouseEvent) : void
      {
         var newIsAllow:Boolean = !MessageManager.getInstance().isAllowSendEmails();
         this.setCheckMarkState(m_window.checkMarkEmail_mc,newIsAllow);
         if(GlobalEngine.socialNetwork.userHasEmailPermission())
         {
            MessageManager.getInstance().setAllowSendEmails(newIsAllow);
         }
         else if(newIsAllow)
         {
            EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_SOCIAL_COMM_USER,this.onFinishEmailPermissionsForCheckBox);
         }
      }
      
      private function onFinishEmailPermissionsForCheckBox() : void
      {
         var hasPermissions:Boolean = GlobalEngine.socialNetwork.userHasEmailPermission();
         this.setCheckMarkState(m_window.checkMarkEmail_mc,hasPermissions);
         if(hasPermissions)
         {
            MessageManager.getInstance().setAllowSendEmails(true);
         }
      }
      
      private function toggleFaceBook(event:MouseEvent) : void
      {
         this.m_iswallpost = !this.m_iswallpost;
         this.setCheckMarkState(m_window.checkMarkFaceBook_mc,this.m_iswallpost);
      }
      
      private function setCheckMarkState(checkMark:MovieClip, isOn:Boolean) : void
      {
         if(isOn)
         {
            checkMark.gotoAndStop(this.CHECK_MARK_FRAME_ON);
         }
         else
         {
            checkMark.gotoAndStop(this.CHECK_MARK_FRAME_OFF);
         }
      }
      
      private function switchToComments(event:MouseEvent) : void
      {
         this.populateMessages();
         removeTiles(true);
         this.m_isSocial = false;
         this.switchTabs();
         addAllComponents(0);
      }
      
      private function switchToSocial(event:MouseEvent) : void
      {
         this.populateSocial();
         removeTiles(true);
         this.m_isSocial = true;
         this.switchTabs();
         addAllComponents(0);
      }
      
      private function onReportAbuse(event:MouseEvent) : void
      {
         navigateToURL(new URLRequest(this.ABUSE_EMAIL),"");
         this.onCloseClick(event);
      }
      
      private function switchTabs() : void
      {
         m_window.socialTabOn_tf.visible = this.m_isSocial;
         m_window.socialTabOff_tf.visible = !this.m_isSocial;
         m_window.commentsTabOn_tf.visible = !this.m_isSocial;
         m_window.commentsTabOff_tf.visible = this.m_isSocial;
         if(this.m_isSocial)
         {
            m_window.socialTab_mc.gotoAndStop(this.SELECTED_FRAME);
            m_window.commentsTab_mc.gotoAndStop(this.UNSELECTED_FRAME);
         }
         else
         {
            m_window.socialTab_mc.gotoAndStop(this.UNSELECTED_FRAME);
            m_window.commentsTab_mc.gotoAndStop(this.SELECTED_FRAME);
         }
      }
      
      private function populateSocial() : void
      {
         m_data = SocialActionsManager.getInstance().getActions();
      }
      
      private function toggleSignPost(event:MouseEvent) : void
      {
         this.m_willPlaceSign = !this.m_willPlaceSign;
         this.setCheckMarkState(m_window.checkMarkSignPost_mc,this.m_willPlaceSign);
      }
      
      private function findPageIndexById(messageId:Number) : Number
      {
         for(var index:Number = 0; index < m_data.length; index++)
         {
            if(m_data[index].getId() == messageId)
            {
               m_data[index].setHighlighted(true);
               return Math.floor(index / this.NUM_MESSAGE_SLOTS);
            }
         }
         return this.ERROR_MESSAGE_NOT_FOUND;
      }
      
      private function onPostClick(event:MouseEvent) : void
      {
         var messageText:String = null;
         var m_message:Message = null;
         if(Boolean(m_window) && Boolean(m_window.comment_tf) && Boolean(m_window.comment_tf.text) && this.m_hasActivatedText)
         {
            messageText = StringUtil.trim(m_window.comment_tf.text);
            if(messageText.length > 0)
            {
               m_message = new Message(messageText,Global.player.uid,0,false);
               this.post(m_message);
            }
         }
      }
      
      private function isPostWithCreatedMessageSign() : Boolean
      {
         return Boolean(this.m_messageSign) && !this.m_isViewSignMessage && this.m_willPlaceSign;
      }
      
      private function onPostMessageServerFinish(message:Message) : void
      {
         if(!this.m_isSocial)
         {
            this.refreshMessages();
         }
      }
      
      private function post(message:Message) : void
      {
         if(this.isPostWithCreatedMessageSign())
         {
            this.m_messageSign.updateWithMessage(message);
            TransactionManager.addTransaction(new TMessageSignPlace(this.m_messageSign,message,this.onPostMessageServerFinish));
         }
         else if(this.m_willPlaceSign)
         {
            MessageManager.getInstance().addMessageWithSign(message);
            this.cleanUpAndClose();
         }
         else
         {
            MessageManager.getInstance().addMessage(message,true,this.onPostMessageServerFinish);
            if(Boolean(this.m_messageSign) && !this.m_isViewSignMessage)
            {
               this.m_messageSign.detach();
            }
         }
         if(this.m_iswallpost)
         {
            this.postFeed(message);
         }
         if(this.m_replyMessageId > 0)
         {
            MessageManager.getInstance().sendReplyMessage(message,this.m_replyMessageId);
         }
         if(Boolean(m_window) && Boolean(m_window.comment_tf) && Boolean(m_window.comment_tf.text))
         {
            m_window.comment_tf.text = "";
         }
         this.switchToComments(null);
         this.refreshMessages();
         m_window.commentEntry_mc.visible = false;
         this.setCheckMarkState(m_window.checkMarkSignPost_mc,false);
         this.m_messageSign = null;
         this.m_isViewSignMessage = false;
         this.m_replyMessageId = 0;
         this.m_willPlaceSign = false;
      }
      
      private function refreshMessages() : void
      {
         this.populateMessages();
         removeTiles();
         addAllComponents(0);
      }
      
      private function postFeed(message:Message) : void
      {
         var targetId:String = MessageManager.getInstance().getCurrentRecipientId();
         var targetUrl:String = "{creative:commentBox}index.php?messageCenterPopup=true&visitId=" + targetId;
         var bundleData:Object = {
            "comment_link":targetUrl,
            "images":[{
               "href":"{SN_APP_URL}" + targetUrl,
               "src":Global.getAssetURL("assets/newsfeed/messaging_wallpost.png")
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory("feed_CommentBoxWallPost",bundleData,[targetId],false);
      }
      
      private function removeEventListeners() : void
      {
         var button:GenericButton = null;
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.arrowUp_bt.removeEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.arrowDown_bt.removeEventListener(MouseEvent.CLICK,onRtArrowClick);
         for each(button in this.m_buttons)
         {
            button.turnOff();
         }
      }
      
      private function populateMessages() : void
      {
         m_data = MessageManager.getInstance().getMessages();
      }
      
      override protected function addComponent(compIndex:int, index:int = 0) : void
      {
         var tile:MovieClip = null;
         var deltaTime:Number = NaN;
         var days:Number = NaN;
         var defaultIcon:DisplayObject = null;
         var iconUrl:String = null;
         var message:Message = null;
         var showSocialButtons:Boolean = false;
         var showReplyButton:Boolean = false;
         var canDelete:Boolean = false;
         m_window.arrowUp_bt.visible = index != 0;
         if(index >= m_data.length - this.NUM_MESSAGE_SLOTS)
         {
            m_window.arrowDown_bt.visible = false;
         }
         else
         {
            m_window.arrowDown_bt.visible = true;
         }
         if(Boolean(m_tiles && m_tiles[compIndex]) && Boolean(m_data) && Boolean(m_data[index + compIndex]))
         {
            tile = m_tiles[compIndex];
            ZLocUtils.setText(tile,"reply_bt.reply_tf","Dialogs","message_center_reply");
            ZLocUtils.setText(tile,"gift_bt.gift_tf","Dialogs","message_center_gift");
            ZLocUtils.setText(tile,"visit_bt.gift_tf","Dialogs","message_center_visit");
            deltaTime = Math.floor(GlobalEngine.serverTime / 1000) - m_data[index + compIndex].getTimestamp();
            days = Number(FarmGameUtil.parseTimeLeft(deltaTime)[this.FIRST_ELEMENT_OF_TIME_ARRAY]);
            if(days == 0)
            {
               ZLocUtils.setText(tile,"time_tf","Dialogs","message_center_today");
            }
            else if(days == 1)
            {
               ZLocUtils.setText(tile,"time_tf","Dialogs","message_center_yesterday");
            }
            else
            {
               ZLocUtils.setText(tile,"time_tf","Dialogs","message_center_daysAgo",{"quantity":days});
            }
            tile.time_tf.visible = true;
            defaultIcon = new EmbeddedArt.hud_no_profile_pic();
            if(this.m_isSocial)
            {
               this.adjustSocialButtons(index,compIndex);
               this.setupSocialData(index,compIndex);
            }
            else
            {
               message = m_data[index + compIndex];
               tile.visible = true;
               tile.new_mc.visible = message.isNew();
               tile.signPostIcon_mc.visible = Boolean(message.getObjectId());
               tile.comment_tf.text = message.getMessage();
               showSocialButtons = message.isFriendAuthor();
               showReplyButton = showSocialButtons && !this.m_isVisiting;
               tile.reply_bt.visible = showReplyButton;
               tile.reply_bt.enabled = showReplyButton;
               tile.gift_bt.visible = showSocialButtons;
               tile.gift_bt.enabled = showSocialButtons;
               tile.visit_bt.visible = showSocialButtons;
               tile.visit_bt.enabled = showSocialButtons;
               canDelete = message.isSelfAuthor() || !this.m_isVisiting;
               tile.delete_bt.visible = canDelete;
               tile.delete_bt.enabled = canDelete;
               this.tileAddEventListeners(tile,message,showSocialButtons,canDelete,compIndex);
               iconUrl = message.getIconUrl();
               if(null == iconUrl)
               {
                  iconUrl = this.getPlayerIconUrl(message.getAuthorId());
               }
               this.addIcon(iconUrl,tile,tile.friendIconSmall_mc,this.MESSAGE_ICON_WIDTH,this.MESSAGE_ICON_HEIGHT,0,0,defaultIcon);
               if(message.isGameAuthor())
               {
                  tile.comment_tf.textColor = this.GAME_MESSAGE_TEXT_COLOR;
                  tile.playerName_tf.text = "";
               }
               else
               {
                  tile.comment_tf.textColor = this.USER_MESSAGE_TEXT_COLOR;
                  tile.playerName_tf.text = MessageManager.getPlayerName(message.getAuthorId());
               }
               tile.commentHighlight_mc.visible = message.getHighlighted();
               message.setHighlighted(false);
            }
            tile.postComment_bt.visible = false;
            tile.postComment_bt.enabled = false;
         }
      }
      
      private function adjustSocialButtons(index:int, compIndex:int) : void
      {
         var giftRecipientId:String = null;
         var tile:MovieClip = m_tiles[compIndex];
         var action:SocialAction = m_data[index + compIndex];
         var deleteIndex:int = this.NUM_SLOT_BUTTONS * compIndex + this.DELETE_OFFSET_INDEX;
         var replyIndex:int = this.NUM_SLOT_BUTTONS * compIndex + this.REPLY_OFFSET_INDEX;
         var giftIndex:int = this.NUM_SLOT_BUTTONS * compIndex + this.GIFT_OFFSET_INDEX;
         var visitIndex:int = this.NUM_SLOT_BUTTONS * compIndex + this.VISIT_OFFSET_INDEX;
         tile.visible = true;
         tile.reply_bt.visible = false;
         tile.delete_bt.visible = false;
         if(this.m_buttons[replyIndex] != null)
         {
            this.m_buttons[replyIndex].turnOff();
         }
         if(this.m_buttons[deleteIndex] != null)
         {
            this.m_buttons[deleteIndex].turnOff();
         }
         giftRecipientId = action.getFriendId();
         if(this.m_buttons[giftIndex] != null)
         {
            this.m_buttons[giftIndex].turnOff();
         }
         if(this.m_buttons[visitIndex] != null)
         {
            this.m_buttons[visitIndex].turnOff();
         }
         this.m_buttons[giftIndex] = new GenericButton(tile.gift_bt,function(event:MouseEvent):void
         {
            FarmStatsManager.sample(100,"fv_fbml_depr_inspect","r1FlowCalled","MessageCenterDialog");
            GlobalEngine.socialNetwork.redirect("gifts.php?ref=commentBox&giftRecipient=" + giftRecipientId);
         });
         this.m_buttons[visitIndex] = new GenericButton(tile.visit_bt,function(event:MouseEvent):void
         {
            Global.worldManager.visitNeighbor(giftRecipientId.toString());
            cleanUpAndClose();
         });
         if(this.m_isVisiting && Global.friendManager.getFriendData(action.getFriendId()) == null)
         {
            this.m_buttons[giftIndex].turnOff();
            this.m_buttons[visitIndex].turnOff();
         }
         else
         {
            this.m_buttons[giftIndex].turnOn();
            this.m_buttons[visitIndex].turnOn();
         }
         tile.new_mc.visible = action.isNew();
         tile.signPostIcon_mc.visible = false;
      }
      
      private function setupSocialData(index:int, compIndex:int) : void
      {
         var iconUrl:String = null;
         var actionLocaleKeyZLoc:String = null;
         var visitingIdZLoc:String = null;
         var visitingNameZLoc:String = null;
         var itemActionLocaleKeyZLoc:String = null;
         var tile:MovieClip = m_tiles[compIndex];
         var action:SocialAction = m_data[index + compIndex];
         var actionType:Number = action.getActionType();
         var defaultIcon:DisplayObject = new EmbeddedArt.hud_no_profile_pic();
         var oParams:Object = new Object();
         oParams.user = "";
         oParams.item = "";
         if(this.m_isVisiting)
         {
            visitingIdZLoc = Global.worldManager.getVisiting();
            visitingNameZLoc = MessageManager.getPlayerName(visitingIdZLoc);
            oParams.user = visitingNameZLoc;
            actionLocaleKeyZLoc = "Neighbor_Action_Visit_" + actionType;
         }
         else
         {
            actionLocaleKeyZLoc = "Neighbor_Action_" + actionType;
         }
         if(action.getActionItem() != null)
         {
            oParams.item = ZLocUtils.tk_pk(action.getActionItem().friendlyName);
            itemActionLocaleKeyZLoc = ZLocUtils.tk_pk_asTitle(action.getActionItem().friendlyName) + "_" + actionLocaleKeyZLoc;
            if(ZLocUtils.hasString("Dialogs",itemActionLocaleKeyZLoc))
            {
               actionLocaleKeyZLoc = itemActionLocaleKeyZLoc;
            }
         }
         ZLocUtils.setText(tile,"comment_tf","Dialogs",actionLocaleKeyZLoc,oParams);
         tile.comment_tf.visible = true;
         tile.comment_tf.textColor = this.USER_MESSAGE_TEXT_COLOR;
         iconUrl = this.getPlayerIconUrl(action.getFriendId());
         this.addIcon(iconUrl,tile,tile.friendIconSmall_mc,this.MESSAGE_ICON_WIDTH,this.MESSAGE_ICON_HEIGHT,0,0,defaultIcon);
         this.addProfileIcon(action.getFriendId().toString(),tile,tile.friendIconSmall_mc);
         tile.playerName_tf.text = MessageManager.getPlayerName(action.getFriendId());
         tile.commentHighlight_mc.visible = false;
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_MESSAGE_SLOTS;
      }
      
      private function tileAddEventListeners(tile:MovieClip, message:Message, enableSocial:Boolean, enableDelete:Boolean, tileIndex:int) : void
      {
         var messageAuthorId:String = null;
         var removeMessageId:Number = NaN;
         var replyMessageId:Number = NaN;
         var deleteIndex:int = this.NUM_SLOT_BUTTONS * tileIndex + this.DELETE_OFFSET_INDEX;
         var replyIndex:int = this.NUM_SLOT_BUTTONS * tileIndex + this.REPLY_OFFSET_INDEX;
         var giftIndex:int = this.NUM_SLOT_BUTTONS * tileIndex + this.GIFT_OFFSET_INDEX;
         var visitIndex:int = this.NUM_SLOT_BUTTONS * tileIndex + this.VISIT_OFFSET_INDEX;
         messageAuthorId = message.getAuthorId();
         if(tile)
         {
            if(this.m_buttons[deleteIndex] != null)
            {
               this.m_buttons[deleteIndex].turnOff();
            }
            if(enableDelete && Boolean(tile.delete_bt))
            {
               removeMessageId = message.getId();
               this.m_buttons[deleteIndex] = new GenericButton(tile.delete_bt,function(event:MouseEvent):void
               {
                  MessageManager.getInstance().removeMessage(removeMessageId,true);
                  refreshMessages();
               });
               this.m_buttons[deleteIndex].turnOn();
            }
            if(this.m_buttons[replyIndex] != null)
            {
               this.m_buttons[replyIndex].turnOff();
            }
            if(enableSocial && !this.m_isVisiting)
            {
               replyMessageId = message.getId();
               this.m_buttons[replyIndex] = new GenericButton(tile.reply_bt,function(event:MouseEvent):void
               {
                  onClickReplyButton(replyMessageId);
               });
               this.m_buttons[replyIndex].turnOn();
            }
            if(this.m_buttons[giftIndex] != null)
            {
               this.m_buttons[giftIndex].turnOff();
            }
            if(enableSocial)
            {
               this.m_buttons[giftIndex] = new GenericButton(tile.gift_bt,function(event:MouseEvent):void
               {
                  GlobalEngine.socialNetwork.redirect("gifts.php?ref=commentBox&giftRecipient=" + messageAuthorId);
               });
               this.m_buttons[giftIndex].turnOn();
            }
            if(this.m_buttons[visitIndex] != null)
            {
               this.m_buttons[visitIndex].turnOff();
            }
            if(enableSocial)
            {
               this.m_buttons[visitIndex] = new GenericButton(tile.visit_bt,function(event:MouseEvent):void
               {
                  Global.worldManager.visitNeighbor(messageAuthorId.toString());
                  cleanUpAndClose();
               });
               this.m_buttons[visitIndex].turnOn();
            }
         }
      }
      
      private function onClickReplyButton(messageId:Number) : void
      {
         m_window.commentEntry_mc.visible = true;
         this.m_messageSign = null;
         this.m_isViewSignMessage = false;
         this.m_replyMessageId = messageId;
      }
      
      private function getPlayerIconUrl(uid:String) : String
      {
         var friend:Friend = null;
         var iconUrl:String = null;
         if(uid == Global.player.snUser.uid)
         {
            iconUrl = Global.player.snUser.picture;
         }
         else
         {
            friend = Global.friendManager.getFriendData(uid);
            if(friend)
            {
               iconUrl = friend.picture;
            }
         }
         return iconUrl;
      }
      
      private function setupPlayerPanel() : void
      {
         if(Boolean(m_window) && Boolean(m_window.playerName_tf) && Boolean(m_window.playerName_tf.text))
         {
            m_window.playerName_tf.text = Global.player.snUser.name;
         }
         if(Boolean(m_window) && Boolean(m_window.friendIcon_mc))
         {
            this.addProfileIcon(Global.player.snUser.uid.toString(),m_window,m_window.friendIcon_mc);
         }
      }
      
      private function addProfileIcon(uid:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50, offsetX:Number = 0, offsetY:Number = 0) : void
      {
         var friend:Friend = null;
         var iconUrl:String = null;
         if(uid == Global.player.snUser.uid.toString())
         {
            iconUrl = Global.player.snUser.picture;
         }
         else
         {
            friend = Global.friendManager.getFriendData(uid);
            if(friend)
            {
               iconUrl = friend.picture;
            }
         }
         var defaultIcon:DisplayObject = new EmbeddedArt.hud_no_profile_pic();
         this.addIcon(iconUrl,tile,movieClip,width,height,offsetX,offsetY,defaultIcon);
      }
      
      private function addIcon(url:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50, offsetX:Number = 0, offsetY:Number = 0, defaultIcon:DisplayObject = null) : void
      {
         var icon:Loader = null;
         if(url)
         {
            icon = LoadingManager.load(url,function(event:Event):void
            {
               var dispObj:* = null;
               if(Boolean(icon) && Boolean(icon.content))
               {
                  dispObj = icon.content;
                  if(tile)
                  {
                     Utilities.removeAllChildren(movieClip);
                  }
                  dispObj.width = width;
                  dispObj.height = height;
                  dispObj.x += offsetX;
                  dispObj.y += offsetY;
                  movieClip.addChild(dispObj);
               }
            });
         }
         else if(defaultIcon)
         {
            defaultIcon.width = width;
            defaultIcon.height = height;
            defaultIcon.x += offsetX;
            defaultIcon.y += offsetY;
            movieClip.addChild(defaultIcon);
         }
      }
      
      public function cleanUpAndClose() : void
      {
         this.removeEventListeners();
         MessageManager.getInstance().markNewMessagesAsSeen();
         SocialActionsManager.getInstance().markNewActionsAsSeen();
         var messageCenterButton:MessageCenterButton = Global.hud.messageCenterButton;
         if(messageCenterButton)
         {
            messageCenterButton.updateNotificationBubble();
         }
         close();
      }
   }
}

