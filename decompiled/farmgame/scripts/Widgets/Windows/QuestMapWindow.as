package Widgets.Windows
{
   import Classes.Constants.QuestConstants;
   import Classes.Constants.WorldsConstants;
   import Classes.Friend;
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestManager;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Transactions.Quests.TIncrementGenericFarmTask;
   import Transactions.TCreateAndPublishW2W;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FriendBubble;
   import Widgets.Frames.HelpFriendFrame;
   import Widgets.Icons.FarmIcon;
   import ZQuest.Init.QuestSettingsInit;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   
   public class QuestMapWindow extends FarmWindow
   {
      
      public static const SEEN_FLAG_SUFFIX:String = "_questMapSeen";
      
      protected static const EXTENDED_PERMISSION_THRESHOLD:int = 5;
      
      protected static const FRIEND_BUBBLE_X_DISP:Number = 0;
      
      protected static const FRIEND_BUBBLE_Y_DISP:Number = 0;
      
      protected static const HELP_TOOL_TIP_Y_DISP:Number = 10;
      
      protected static const CHAPTER_REWARD_NODE_NAME_PREFIX:String = "starHitLoc";
      
      protected static const TOOLTIP_Y_OFFSET:int = 150;
      
      protected static const POPUP_NAME:String = "questMapWindow";
      
      protected var m_questChain:String = null;
      
      protected var m_totalLocations:int;
      
      protected var m_currentLocation:int = 0;
      
      protected var m_playerQuest:FarmQuest;
      
      protected var m_friendsAtLocations:Array;
      
      protected var m_helpToolTip:HelpFriendFrame;
      
      protected var m_mouseInIcon:Boolean = false;
      
      protected var m_mouseInToolTip:Boolean = false;
      
      protected var m_showAnimation:Boolean;
      
      protected var m_helpOthersWindow:QuestMapHelpOthersWindow;
      
      protected var m_numW2WSent:int = 0;
      
      protected var m_maxLocation:int = 0;
      
      protected var m_userIcon:FarmIcon = null;
      
      private var m_whatIsThisButton:FarmAnimatedTextButton = null;
      
      public function QuestMapWindow(windowAssetRelUrl:String, questChain:String, userDriven:Boolean = true, modal:Boolean = true, bAddClickBlocker:Boolean = true, showTransitionAnimation:Boolean = false)
      {
         var friend:Friend = null;
         var location:int = 0;
         var canHelp:int = 0;
         var completedQuests:Array = null;
         var quest:FarmQuest = null;
         super(windowAssetRelUrl,modal,bAddClickBlocker);
         var i:* = 0;
         this.name = POPUP_NAME;
         this.m_questChain = questChain;
         this.m_showAnimation = showTransitionAnimation;
         if(userDriven)
         {
            FarmStatsManager.count("fv_expfarm","questmap","open_map","","userclick");
         }
         else
         {
            FarmStatsManager.count("fv_expfarm","questmap","open_map","","popup");
         }
         this.m_maxLocation = Global.farmGameSettingsManager.getInt(questChain + "_questMap_maxLocation",0);
         this.m_playerQuest = FarmQuestManager.getInstance().getActiveQuestByChain(questChain);
         if(null == this.m_playerQuest)
         {
            completedQuests = FarmQuestManager.getInstance().completedQuests;
            for(i = int(completedQuests.length - 1); i >= 0; i--)
            {
               if((completedQuests[i] as String).split("-")[0] == questChain)
               {
                  this.m_playerQuest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(completedQuests[i]) as FarmQuest;
                  break;
               }
            }
         }
         if(this.m_playerQuest)
         {
            this.m_currentLocation = this.m_playerQuest.location;
            this.m_totalLocations = this.m_playerQuest.totalLocations;
         }
         else
         {
            quest = (QuestSettingsInit.getInstance() as FarmQuestSettingsInit).getItemByName(questChain + FarmQuestManager.SECOND_CHAPTER_SUFFIX) as FarmQuest;
            if(quest)
            {
               this.m_totalLocations = quest.totalLocations;
            }
            else
            {
               this.m_totalLocations = 0;
            }
         }
         var friends:Array = Global.friendManager.getQuestFriends(questChain);
         this.m_friendsAtLocations = new Array();
         for(i = 0; i < this.m_totalLocations; i++)
         {
            this.m_friendsAtLocations.push(new Array());
         }
         for(i = 0; i < friends.length; i++)
         {
            friend = friends[i] as Friend;
            location = friend.getQuestLocationByName(questChain);
            while(this.m_totalLocations < location)
            {
               this.m_friendsAtLocations.push(new Array());
               ++this.m_totalLocations;
            }
            if(location > 0)
            {
               canHelp = friend.canHelp(questChain,this.m_playerQuest);
               if(canHelp == FarmQuestManager.CAN_HELP || canHelp == FarmQuestManager.CAN_SEND)
               {
                  (this.m_friendsAtLocations[location - 1] as Array).unshift(friend);
               }
               else
               {
                  (this.m_friendsAtLocations[location - 1] as Array).push(friend);
               }
            }
         }
         if(this.m_currentLocation == 0 || this.m_currentLocation > this.m_maxLocation)
         {
            this.m_currentLocation = this.m_maxLocation;
         }
      }
      
      public static function getAssetPathByWorld(worldName:String) : String
      {
         var assetPath:String = "";
         switch(worldName)
         {
            case WorldsConstants.WORLD_ID_ENGLAND:
               assetPath = "assets/dialogs/FV_questMap_england_2.swf";
         }
         return assetPath;
      }
      
      override protected function postLoadComplete() : void
      {
         var dataClass:Class = null;
         var mc:MovieClip = null;
         var anchor:MovieClip = null;
         var friendBubble:FriendBubble = null;
         var i:int = 0;
         super.postLoadComplete();
         addWidget(new FarmAnimatedButton(m_window.return_bt,onClose));
         addWidget(new ZwTextField(m_window.return_bt.generic_tf,ZLocUtils.t("Dialogs","ReturnToFarm")));
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_questChain + "_QuestMap_Title")));
         var rewardBannerFrame:ZwFrame = new ZwFrame(m_window.ch8Banner_mc);
         rewardBannerFrame.addWidget(new ZwTextField(rewardBannerFrame.element.generic_tf,ZLocUtils.t("Dialogs",this.m_questChain + "_promo_title")));
         rewardBannerFrame.addWidget(new ZwTextField(rewardBannerFrame.element.generic2_tf,ZLocUtils.t("Dialogs",this.m_questChain + "_promo_body")));
         var bannerShouldBeVisible:Boolean = this.m_currentLocation < this.m_maxLocation;
         addWidget(rewardBannerFrame,bannerShouldBeVisible);
         if(m_window.messageIcon_mc is Bitmap)
         {
            (m_window.messageIcon_mc as Bitmap).smoothing = true;
         }
         var friendBubbleClasses:Array = [];
         for(i = 1; i < 5; i++)
         {
            if(m_window.loaderInfo.applicationDomain.hasDefinition("FriendBubble" + i + "MC"))
            {
               dataClass = m_window.loaderInfo.applicationDomain.getDefinition("FriendBubble" + i + "MC") as Class;
               friendBubbleClasses.push(dataClass);
            }
         }
         var locationState:String = "state2";
         var numFriends:int = 0;
         for(i = 0; i < this.m_totalLocations; i++)
         {
            mc = m_window["location" + i + "_mc"] as MovieClip;
            if(mc)
            {
               if(i == this.m_currentLocation - 1)
               {
                  locationState = "state1";
               }
               else if(i == this.m_currentLocation)
               {
                  locationState = "state0";
               }
               mc.gotoAndStop(locationState);
            }
            mc = m_window[CHAPTER_REWARD_NODE_NAME_PREFIX + i + "_mc"] as MovieClip;
            numFriends = int((this.m_friendsAtLocations[i] as Array).length);
            if(0 < numFriends)
            {
               numFriends = Math.min(numFriends,4);
               anchor = m_window["anchor" + i + "_mc"] as MovieClip;
               mc = new (friendBubbleClasses[numFriends - 1] as Class)();
               mc.x = anchor.x + FRIEND_BUBBLE_X_DISP;
               mc.y = anchor.y + FRIEND_BUBBLE_Y_DISP;
               friendBubble = new FriendBubble(mc,this.m_friendsAtLocations[i] as Array,i);
               friendBubble.setIconMouseEventCallback(this.onFriendIconMouseEvent);
               friendBubble.setTextMouseClickCallback(this.onFriendOthersClick);
               addWidget(friendBubble);
               m_window.addChild(mc);
               (m_window["friendMarker" + i + "_mc"] as MovieClip).visible = true;
            }
            else if(null != m_window["friendMarker" + i + "_mc"] as MovieClip)
            {
               m_window.removeChild(m_window["friendMarker" + i + "_mc"] as MovieClip);
            }
            friendBubble = null;
            anchor = null;
            mc = null;
         }
         if(this.m_currentLocation <= this.m_totalLocations)
         {
            if(this.m_currentLocation > 0 && !this.m_showAnimation)
            {
               m_window.gotoAndStop("state" + (this.m_currentLocation - 1));
            }
         }
         else if(this.m_totalLocations > 0)
         {
            m_window.gotoAndStop("state" + (this.m_totalLocations - 1));
         }
         this.m_userIcon = new FarmIcon(m_window.userMarker_mc.userBubble_mc.userPic_mc,Global.player.picture);
         if(m_window.hasOwnProperty("whatIsThis_mc"))
         {
            this.m_whatIsThisButton = new FarmAnimatedTextButton(m_window.whatIsThis_mc,ZLocUtils.t("Dialogs","HowDoesThisWork"),this.onClickHowDoesThisWork);
            addWidget(this.m_whatIsThisButton);
         }
         var seenFlag:String = "xukQuestMapWT";
         if(!Global.player.getSeenFlag(seenFlag))
         {
            Global.player.setSeenFlag(seenFlag);
            this.displayWhatIsThis();
         }
      }
      
      private function onChapterRewardNodeMouseOver(event:MouseEvent) : void
      {
      }
      
      private function onChapterRewardNodeMouseOut(event:MouseEvent) : void
      {
      }
      
      private function onClickHowDoesThisWork(mouseEvent:MouseEvent) : void
      {
         this.displayWhatIsThis();
         this.m_whatIsThisButton.enabled = true;
      }
      
      private function displayWhatIsThis() : void
      {
         var whatIsThis:FarmDynamicDialog = FarmDynamicDialog.createDialog("QuestMapHelp",FarmDynamicDialog);
         whatIsThis.setup();
         whatIsThis.show();
      }
      
      private function onWhatIsThisClosed(event:WidgetControllerEvent) : void
      {
         this.m_whatIsThisButton.enabled = true;
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         if(this.m_showAnimation && this.m_currentLocation > 1)
         {
            this.playAnimation();
         }
      }
      
      public function playAnimation() : void
      {
         m_window.gotoAndPlay("state" + (this.m_currentLocation - 2));
         (m_window["location" + (this.m_currentLocation - 1) + "_mc"] as MovieClip).gotoAndPlay("state0");
         if(this.m_currentLocation > 2)
         {
            (m_window["location" + (this.m_currentLocation - 2) + "_mc"] as MovieClip).gotoAndPlay("state1");
         }
         (m_window.userMarker_mc.userBubble_mc.userPic_mc as MovieClip).addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      override protected function release() : void
      {
         var mc:MovieClip = null;
         (m_window.userMarker_mc.userBubble_mc.userPic_mc as MovieClip).removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         for(var i:int = 0; i < this.m_totalLocations; i++)
         {
            mc = null;
            mc = m_window[CHAPTER_REWARD_NODE_NAME_PREFIX + i + "_mc"] as MovieClip;
            if(mc)
            {
               mc.removeEventListener(MouseEvent.MOUSE_OVER,this.onChapterRewardNodeMouseOver);
               mc.removeEventListener(MouseEvent.ROLL_OUT,this.onChapterRewardNodeMouseOut);
            }
         }
         this.m_userIcon = null;
         super.release();
      }
      
      private function onEnterFrame(event:Event) : void
      {
         var userBubble:MovieClip = null;
         if(m_window != null && m_window.userMarker_mc != null)
         {
            userBubble = m_window.userMarker_mc.userBubble_mc.userPic_mc as MovieClip;
            if(userBubble != null && this.m_userIcon.icon != null)
            {
               userBubble.addChild(this.m_userIcon.icon);
            }
         }
      }
      
      public function onFriendIconMouseEvent(friend:Friend, event:MouseEvent) : void
      {
         var rect:Rectangle = null;
         if(event.type == MouseEvent.MOUSE_OVER)
         {
            this.m_mouseInIcon = true;
            if(this.m_helpToolTip == null)
            {
               this.m_helpToolTip = new HelpFriendFrame(new (m_window.loaderInfo.applicationDomain.getDefinition("HelpTrueMC") as Class)(),new (m_window.loaderInfo.applicationDomain.getDefinition("HelpFalseMC") as Class)(),this.onFriendHelpClick);
               m_window.addChild(this.m_helpToolTip.element as Sprite);
               this.m_helpToolTip.registerEventListener(MouseEvent.MOUSE_OVER,this.onToolTipMouseOver);
               this.m_helpToolTip.registerEventListener(MouseEvent.MOUSE_OUT,this.onToolTipMouseOut);
               this.m_helpToolTip.element.visible = true;
               this.m_helpToolTip.visible = false;
            }
            if(this.m_helpToolTip.getFriend() != friend)
            {
               this.m_helpToolTip.setupForQuestHelp(friend,this.m_questChain,this.m_playerQuest);
            }
            rect = (event.target as Sprite).getBounds(m_window);
            this.m_helpToolTip.x = (rect.right + rect.left - this.m_helpToolTip.width) / 2;
            this.m_helpToolTip.y = rect.top - this.m_helpToolTip.height + HELP_TOOL_TIP_Y_DISP;
            if(false == this.m_helpToolTip.visible)
            {
               this.m_helpToolTip.visible = true;
            }
         }
         else if(event.type == MouseEvent.MOUSE_OUT)
         {
            this.m_mouseInIcon = false;
            this.conditionallyHideToolTip(event);
         }
      }
      
      public function onFriendOthersClick(friends:Array, location:int) : void
      {
         if(null == this.m_helpOthersWindow)
         {
            this.m_helpOthersWindow = new QuestMapHelpOthersWindow("assets/dialogs/FV_questMapOthers_" + this.m_questChain + ".swf",this.onFriendHelpClick,true,false,this.m_questChain);
            this.m_helpOthersWindow.setLocation(location,friends,this.m_playerQuest);
            UI.displayPopup(this.m_helpOthersWindow,false);
         }
         else
         {
            this.m_helpOthersWindow.setLocation(location,friends,this.m_playerQuest);
            this.m_helpOthersWindow.show();
         }
      }
      
      public function onFriendHelpClick(friend:Friend) : void
      {
         var canHelp:int = 0;
         var bundleId:String = null;
         var feedName:String = null;
         var sendingQuest:FarmQuest = null;
         var bundleData:Object = null;
         var farmItem:FarmItem = null;
         this.setHelpToolTipVisible(false);
         var friendQuest:FarmQuest = friend.getActiveQuestByChain(this.m_questChain);
         if(friendQuest != null)
         {
            canHelp = friend.canHelp(this.m_questChain,this.m_playerQuest);
            bundleId = "";
            feedName = "";
            sendingQuest = null;
            switch(canHelp)
            {
               case FarmQuestManager.CAN_HELP:
                  bundleId = this.m_playerQuest.name + FarmQuest.W2W_ASK_FOR_HELP_SUFFIX;
                  sendingQuest = this.m_playerQuest;
                  feedName = this.m_playerQuest.getW2WFeedName(true);
                  break;
               case FarmQuestManager.CAN_SEND:
                  bundleId = friendQuest.name + FarmQuest.W2W_SEND_HELP_SUFFIX;
                  feedName = friendQuest.getW2WFeedName(false);
                  sendingQuest = friendQuest;
            }
            if(bundleId != "")
            {
               bundleData = new Object();
               bundleData.player_first_name = Global.player.firstName;
               bundleData.friend_first_name = friend.firstName;
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(sendingQuest.helpAction.itemCode);
               bundleData.item_name = farmItem.friendlyName;
               bundleData.images = [{
                  "href":"{SN_APP_URL}",
                  "src":farmItem.icon
               }];
               ++this.m_numW2WSent;
               TransactionManager.addTransaction(new TCreateAndPublishW2W(bundleId,bundleData,friend.uid,sendingQuest.getW2WFeatureName(),feedName,null,0,false,this.hasFeaturePermission()),true);
            }
         }
      }
      
      protected function onToolTipMouseOver(event:MouseEvent) : void
      {
         this.m_mouseInToolTip = true;
      }
      
      protected function onToolTipMouseOut(event:MouseEvent) : void
      {
         var tooltip:Sprite = this.m_helpToolTip.element as Sprite;
         var hitTest:Boolean = tooltip.hitTestPoint(event.stageX,event.stageY,true);
         if(!hitTest)
         {
            this.m_mouseInToolTip = false;
            this.conditionallyHideToolTip(event);
         }
      }
      
      protected function conditionallyHideToolTip(event:MouseEvent) : void
      {
         if(!this.m_mouseInToolTip && !this.m_mouseInIcon)
         {
            this.setHelpToolTipVisible(false);
         }
      }
      
      private function setHelpToolTipVisible(visible:Boolean) : void
      {
         if(this.m_helpToolTip != null)
         {
            this.m_helpToolTip.visible = visible;
         }
      }
      
      override public function close() : void
      {
         super.close();
         TransactionManager.addTransaction(new TIncrementGenericFarmTask(QuestConstants.ACTION_VIEW_QUEST_MAP));
         if(this.m_helpOthersWindow != null)
         {
            this.m_helpOthersWindow.close();
         }
      }
      
      protected function hasFeaturePermission() : Boolean
      {
         return GlobalEngine.socialNetwork.userHasStreamPermissions() && Boolean(FeatureOptionsManager.getInstance().getFeatureOption(this.m_questChain + FeatureOptionsManager.QUEST_MAP_SUFFIX,FeatureOptionsManager.AUTO_PUBLISH_STREAM));
      }
   }
}

