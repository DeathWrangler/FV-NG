package Display.FriendBar
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.EmbeddedArt;
   import Classes.FarmvilleClothingLoader;
   import Classes.Friend;
   import Classes.IUser;
   import Classes.NPC;
   import Classes.ZItem.ExpansionData;
   import Classes.util.ZLocUtils;
   import Display.StrokeTextField;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.SoundManager;
   import Engine.Managers.StatsManager;
   import Engine.Utilities;
   import Events.FriendBarSlotEvent;
   import Events.OnlineStatusEvent;
   import Managers.ChatManager;
   import Managers.ClickTrackingManager;
   import Managers.WorldSeasonsManager;
   import MyLife.Assets.Avatar.AvatarActions.AnimationAction;
   import MyLife.NPC.SimpleNPC;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import gs.TweenLite;
   
   public class FriendBarSlot extends Sprite
   {
      
      public static const SLOT_WIDTH_INTERVAL:int = 66;
      
      private const STATS_SWF_URL:String = Global.getAssetURL("assets/hud/Status_Shelf/FV_statsFriends.swf");
      
      private const Y_POSITION_SLOT_BACKGROUND:int = 16;
      
      private const Y_POSITION_SPECIAL_SLOT_BACKGROUND:int = 7;
      
      private const PROFILE_PIC_BOTTOM_Y:Number = 32;
      
      private const PROFILE_PIC_TOP_Y:Number = -40;
      
      private const FRIEND_BAR_BASE_X:int = 40;
      
      private const VISIBLE_SLOTS:int = 8;
      
      protected var m_backgroundNormal:Bitmap;
      
      protected var m_backgroundOver:Bitmap;
      
      public var m_index:int;
      
      public var m_label:TextField;
      
      public var m_lockLabel:TextField;
      
      public var m_friend:IUser;
      
      public var m_character:SimpleNPC = null;
      
      public var m_profilePic:DisplayObject;
      
      protected var m_profileBackImage:MovieClip;
      
      protected var m_messageOnMC:MovieClip = null;
      
      public var m_statusCellTextFields:Array;
      
      public var m_xp:int = 0;
      
      public var m_level:int = 0;
      
      public var m_rank:int = 0;
      
      protected var m_isLoadingFriend:Boolean = false;
      
      public var m_avatarData:Object;
      
      public var m_fakeFriend:Boolean;
      
      public var m_empty:Boolean;
      
      protected var m_statsValuesArray:Array;
      
      protected var m_statsSubValuesArray:Array;
      
      private var m_initAvatarSpriteLoad:Boolean = false;
      
      private var m_location:String;
      
      private var m_locationIcon:DisplayObject;
      
      private var m_messagingIcons:Object = new Object();
      
      private var m_currentStatus:String = "";
      
      private var m_currentStatusIcon:DisplayObject = null;
      
      private var m_borderBackgroundNormal:Bitmap = null;
      
      private var m_borderBackgroundOver:Bitmap = null;
      
      private var m_noBorderBackgroundNormal:Bitmap = null;
      
      private var m_noBorderBackgroundOver:Bitmap = null;
      
      private var m_isSpecialFriendSlot:Boolean;
      
      private var m_starIcon:DisplayObject = null;
      
      public function FriendBarSlot(slotIndex:int)
      {
         super();
         this.m_index = slotIndex;
         this.m_backgroundNormal = new EmbeddedArt.hud_nghbr_slot_norm();
         this.m_backgroundNormal.y = this.getSlotBackgroundYOffset();
         addChildAt(this.m_backgroundNormal,0);
         this.m_label = new TextField();
         this.m_label.selectable = false;
         addChild(this.m_label);
         this.m_statsValuesArray = [-1,-1,-1,-1,-1,-1];
         this.m_statsSubValuesArray = new Array();
         this.addEventListener(MouseEvent.ROLL_OVER,this.onRollOverFriend);
         this.addEventListener(MouseEvent.ROLL_OUT,this.onRollOutFriend);
         this.addEventListener(MouseEvent.CLICK,this.onClickFriend);
         ChatManager.instance.addEventListener(OnlineStatusEvent.STATUS_CHANGE,this.onUserStatusChange);
      }
      
      public static function onlineStatusSort(friendSlot1:FriendBarSlot, friendSlot2:FriendBarSlot) : int
      {
         var result:int = friendSlot1.onlineStatusSortPriority - friendSlot2.onlineStatusSortPriority;
         if(result == 0)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_WORLDSCORE_NEIGHBOR_SORT) > 0)
            {
               result = worldScoreSort(friendSlot1,friendSlot2);
            }
            else
            {
               result = xpAmountSort(friendSlot1,friendSlot2);
            }
         }
         return result;
      }
      
      public static function worldScoreSort(friendSlot1:FriendBarSlot, friendSlot2:FriendBarSlot) : int
      {
         var result:int = 0;
         var friend1:IUser = friendSlot1.friend;
         var friend2:IUser = friendSlot2.friend;
         if(Boolean(friend1) && Boolean(friend2))
         {
            result = 0;
            if(WorldSeasonsManager.getInstance().getCurrentSeason(Global.worldManager.currentWorldType) == WorldSeasonsManager.SEASON_TWO)
            {
               result = friendSlot1.friend.currentWorldScore2 - friendSlot2.friend.currentWorldScore2;
            }
            else
            {
               result = friendSlot1.friend.currentWorldScore - friendSlot2.friend.currentWorldScore;
            }
            if(result == 0)
            {
               result = xpAmountSort(friendSlot1,friendSlot2);
            }
         }
         else
         {
            result = badDataSort(friendSlot1,friendSlot2);
         }
         return result;
      }
      
      public static function xpAmountSort(friendSlot1:FriendBarSlot, friendSlot2:FriendBarSlot) : int
      {
         var result:int = 0;
         var name1:String = null;
         var name2:String = null;
         var friend1:IUser = friendSlot1.friend;
         var friend2:IUser = friendSlot2.friend;
         if(Boolean(friend1) && Boolean(friend2))
         {
            result = friendSlot1.friend.xp - friendSlot2.friend.xp;
            if(result == 0)
            {
               name1 = friend1 is NPC ? (friend1 as NPC).getNPCDataName() : friend1.name;
               name2 = friend2 is NPC ? (friend2 as NPC).getNPCDataName() : friend2.name;
               if(name1 < name2)
               {
                  result = -1;
               }
               else
               {
                  result = 1;
               }
            }
         }
         else
         {
            result = badDataSort(friendSlot1,friendSlot2);
         }
         return result;
      }
      
      private static function badDataSort(friendSlot1:FriendBarSlot, friendSlot2:FriendBarSlot) : int
      {
         var result:int = 1;
         var friend1:IUser = friendSlot1.friend;
         var friend2:IUser = friendSlot2.friend;
         if(Boolean(friend1) && !friend2)
         {
            result = 1;
         }
         else if(Boolean(friend2) && !friend1)
         {
            result = -1;
         }
         else
         {
            result = (friendSlot1 as int) - (friendSlot2 as int);
            if(result == 0)
            {
               result = 1;
            }
         }
         return result;
      }
      
      private function onUserStatusChange(event:OnlineStatusEvent) : void
      {
         var newStatus:String = null;
         var groupId:String = null;
         var onlineStatus:String = null;
         if(event.friendUid == this.uid)
         {
            newStatus = this.m_currentStatus;
            if(this.uid == ChatManager.currentChatWindowOpen)
            {
               newStatus = ChatManager.getOnlineStatus(this.uid);
            }
            else if(event.status == OnlineStatusEvent.NEW_MESSAGE && !ChatManager.hasUnreadMessageFrom(this.uid))
            {
               newStatus = ChatManager.getOnlineStatus(this.uid);
            }
            else if(this.m_currentStatus != OnlineStatusEvent.NEW_MESSAGE)
            {
               newStatus = event.status;
            }
            if(this.m_currentStatus != OnlineStatusEvent.NEW_MESSAGE && newStatus == OnlineStatusEvent.NEW_MESSAGE && this.friend is Friend)
            {
               groupId = (this.friend as Friend).isCommunityNeighbor ? "community" : "fb";
               onlineStatus = ChatManager.getOnlineStatus(this.uid) == OnlineStatusEvent.STATUS_OFFLINE ? "offline" : "online";
               StatsManager.social("chat",String(this.uid),"chatter_notify","",groupId,onlineStatus,0,Global.worldManager.currentWorldType);
            }
            this.messagingStatus = newStatus;
            this.refreshCardBitmaps();
         }
      }
      
      protected function refreshCardBitmaps() : void
      {
         var onlineStatus:String = ChatManager.getOnlineStatus(this.uid);
         if(!ChatManager.instance.isFarmTalkEnabled(this.uid))
         {
            onlineStatus = OnlineStatusEvent.STATUS_OFFLINE;
         }
         switch(onlineStatus)
         {
            case OnlineStatusEvent.STATUS_ONLINE:
               if(this.m_borderBackgroundNormal != null)
               {
                  this.backgroundNormal = this.m_borderBackgroundNormal;
               }
               if(this.m_borderBackgroundOver != null)
               {
                  this.backgroundOver = this.m_borderBackgroundOver;
               }
               break;
            default:
               if(this.m_noBorderBackgroundNormal != null)
               {
                  this.backgroundNormal = this.m_noBorderBackgroundNormal;
               }
               if(this.m_noBorderBackgroundOver != null)
               {
                  this.backgroundOver = this.m_noBorderBackgroundOver;
               }
         }
      }
      
      public function refresh() : void
      {
      }
      
      private function hasMessagingIcon() : Boolean
      {
         var ret:Boolean = true;
         if(this.m_isSpecialFriendSlot)
         {
            ret = false;
         }
         else if(this.uid == Global.player.uid)
         {
            ret = false;
         }
         else if(this.messagingStatus == OnlineStatusEvent.STATUS_OFFLINE || this.messagingStatus == "")
         {
            ret = false;
         }
         else if(!ChatManager.instance.isFarmTalkEnabled(this.uid))
         {
            ret = false;
         }
         return ret;
      }
      
      public function get messagingStatus() : String
      {
         return this.m_currentStatus;
      }
      
      public function set messagingStatus(status:String) : void
      {
         this.m_currentStatus = status;
         if(this.hasMessagingIcon())
         {
            if(this.m_currentStatusIcon != null)
            {
               removeChild(this.m_currentStatusIcon);
            }
            if(!this.m_messagingIcons.hasOwnProperty(status) || this.m_messagingIcons[status] == null)
            {
               switch(status)
               {
                  case OnlineStatusEvent.STATUS_ONLINE:
                     this.m_messagingIcons[status] = LoadingManager.load(Global.getAssetURL("assets/dialogs/FV_Support/FV_Chat/message_online.png"));
                     break;
                  case OnlineStatusEvent.NEW_MESSAGE:
                     this.m_messagingIcons[status] = LoadingManager.load(Global.getAssetURL("assets/dialogs/FV_Support/FV_Chat/message_on.swf"),this.animatedSwfLoaded);
                     break;
                  case OnlineStatusEvent.STATUS_OFFLINE:
                  default:
                     this.m_messagingIcons[status] = LoadingManager.load(Global.getAssetURL("assets/dialogs/FV_Support/FV_Chat/message_off.png"));
               }
            }
            this.m_currentStatusIcon = this.m_messagingIcons[status];
            this.m_currentStatusIcon.x = 34;
            this.m_currentStatusIcon.y = 82;
            addChild(this.m_currentStatusIcon);
            this.tryToPlayMessageAnim();
         }
         else if(this.m_currentStatusIcon != null)
         {
            removeChild(this.m_currentStatusIcon);
            this.m_currentStatusIcon = null;
         }
         this.setLocationIconPos(this.m_locationIcon);
      }
      
      protected function animatedSwfLoaded(event:Event) : void
      {
         this.m_messageOnMC = event.target.content as MovieClip;
         this.tryToPlayMessageAnim();
      }
      
      private function tryToPlayMessageAnim() : void
      {
         if(this.m_messageOnMC)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_JEWEL_PULSE) > 1)
            {
               this.m_messageOnMC.gotoAndPlay(1);
            }
            else
            {
               this.m_messageOnMC.gotoAndStop(1);
            }
         }
      }
      
      public function onClickMessage(event:Event) : void
      {
         var isMessageWaiting:Boolean = this.m_currentStatus == OnlineStatusEvent.NEW_MESSAGE;
         var isMessageWaitingStr:String = isMessageWaiting ? "message_waiting" : "not_waiting";
         var groupId:String = this.friend is Friend && Boolean((this.friend as Friend).isCommunityNeighbor) ? "community" : "fb";
         var onlineStatus:String = ChatManager.getOnlineStatus(this.uid) == OnlineStatusEvent.STATUS_OFFLINE ? "offline" : "online";
         StatsManager.social("chat",String(this.uid),"click_neighbor",isMessageWaitingStr,groupId,onlineStatus,0,Global.worldManager.currentWorldType);
         event.stopImmediatePropagation();
         this.openChatWindow();
      }
      
      public function openChatWindow() : void
      {
         this.m_currentStatus = "";
         var chatWindowIndex:int = (parent.x - this.FRIEND_BAR_BASE_X) / SLOT_WIDTH_INTERVAL + this.m_index;
         ChatManager.onClickMessage(chatWindowIndex,this.uid);
      }
      
      public function set noBorderBackgroundNormal(bg:Bitmap) : void
      {
         this.m_noBorderBackgroundNormal = bg;
         this.refreshCardBitmaps();
      }
      
      public function set noBorderBackgroundOver(bg:Bitmap) : void
      {
         this.m_noBorderBackgroundOver = bg;
         this.refreshCardBitmaps();
      }
      
      public function set borderBackgroundNormal(bg:Bitmap) : void
      {
         this.m_borderBackgroundNormal = bg;
         this.refreshCardBitmaps();
      }
      
      public function set borderBackgroundOver(bg:Bitmap) : void
      {
         this.m_borderBackgroundOver = bg;
         this.refreshCardBitmaps();
      }
      
      public function set backgroundNormal(newBackground:Bitmap) : void
      {
         if(Boolean(this.m_backgroundNormal) && contains(this.m_backgroundNormal))
         {
            removeChild(this.m_backgroundNormal);
         }
         this.m_backgroundNormal = newBackground;
         this.m_backgroundNormal.y = this.getSlotBackgroundYOffset();
         addChildAt(this.m_backgroundNormal,0);
      }
      
      public function set backgroundOver(newBackground:Bitmap) : void
      {
         if(Boolean(this.m_backgroundOver) && contains(this.m_backgroundOver))
         {
            removeChild(this.m_backgroundOver);
         }
         this.m_backgroundOver = newBackground;
      }
      
      public function set isSpecialFriendSlot(isSpecial:Boolean) : void
      {
         this.m_isSpecialFriendSlot = isSpecial;
         if(this.m_backgroundNormal)
         {
            this.m_backgroundNormal.y = this.getSlotBackgroundYOffset();
         }
         if(this.m_locationIcon)
         {
            this.m_locationIcon.visible = !this.m_isSpecialFriendSlot;
         }
      }
      
      public function onClickFriend(event:MouseEvent) : void
      {
         dispatchEvent(new FriendBarSlotEvent(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this,"friendbar","contextual","friend"));
      }
      
      public function updateSlot(friend:IUser, rank:int, level:int, xp:int, avatarData:Object, statsObj:Object, fakeFriend:Boolean = false, emptySlot:Boolean = false, isLoading:Boolean = false) : void
      {
         this.m_level = level;
         this.m_xp = xp;
         this.m_avatarData = avatarData;
         this.m_rank = rank;
         this.m_fakeFriend = fakeFriend;
         this.m_empty = emptySlot;
         if(this.numChildren > 1)
         {
            this.removeChildAt(1);
         }
         this.m_friend = friend;
         this.m_isLoadingFriend = false;
         this.m_profileBackImage = new MovieClip();
         this.m_profileBackImage.alpha = 0;
         addChild(this.m_profileBackImage);
         if(emptySlot)
         {
            this.setupEmptySlot();
         }
         else if(isLoading)
         {
            this.setupLoadingOccupiedSpot();
            this.m_isLoadingFriend = true;
         }
         else
         {
            this.setupOccupiedSpot();
         }
         if(statsObj != null && statsObj.hasOwnProperty("ribbons") && statsObj.hasOwnProperty("medals") && statsObj.hasOwnProperty("masteries") && statsObj.hasOwnProperty("collections") && statsObj.hasOwnProperty("buildings"))
         {
            this.updateStatsValuesArray([Global.farmGameSettingsManager.getLevelForXP(xp),int(statsObj.ribbons.total),int(statsObj.masteries.total),int(statsObj.medals.total),int(statsObj.collections),int(statsObj.buildings)]);
            this.m_statsSubValuesArray = [[],[statsObj.ribbons.yellow,statsObj.ribbons.white,statsObj.ribbons.red,statsObj.ribbons.blue],[statsObj.masteries.level1,statsObj.masteries.level2,statsObj.masteries.level3],[statsObj.medals.bronze,statsObj.medals.silver,statsObj.medals.gold],[],[]];
         }
      }
      
      public function get subStats() : Array
      {
         return this.m_statsSubValuesArray;
      }
      
      public function updateSlotAvatar(avatarCustomizationData:Object, gender:int) : void
      {
         if(this.m_character)
         {
            this.m_character.setAvatarCustomizationData(avatarCustomizationData,gender);
            this.m_avatarData = avatarCustomizationData;
         }
      }
      
      public function updateSlotFriend(friend:IUser) : void
      {
         this.updateSlot(friend,this.m_rank,this.m_level,this.m_xp,this.m_avatarData,null,this.m_fakeFriend,this.m_empty,this.m_isLoadingFriend);
      }
      
      public function updateStatsValues(Level_Num:Number, Ribbon_Num:Number, Mastery_Num:Number, Medal_Num:Number, Collections_Num:Number, Building_Num:Number) : void
      {
         var statsValuesArray:Array = [Level_Num,Ribbon_Num,Mastery_Num,Medal_Num,Collections_Num,Building_Num];
         this.updateStatsValuesArray(statsValuesArray);
      }
      
      public function updateStatsValuesArray(statsValuesArray:Array) : void
      {
         this.m_statsValuesArray = statsValuesArray;
      }
      
      protected function updateStatsTextFields() : void
      {
         for(var i:Number = 0; i < this.m_statusCellTextFields.length; i++)
         {
            this.m_statusCellTextFields[i].text = this.m_statsValuesArray[i] == -1 ? "?" : this.m_statsValuesArray[i].toString();
         }
      }
      
      public function get profileBackImage() : Sprite
      {
         return this.m_profileBackImage.getChildAt(0) as Sprite;
      }
      
      protected function backImageLoaderCallback(event:Event) : void
      {
         var subcellMCs:Array = null;
         var statCellIcons:Array = null;
         var i:Number = NaN;
         var loadedBackImage:MovieClip = event.target.content as MovieClip;
         if(loadedBackImage)
         {
            this.m_statusCellTextFields = new Array();
            subcellMCs = [loadedBackImage.statCell1_mc,loadedBackImage.statCell2_mc,loadedBackImage.statCell3_mc,loadedBackImage.statCell4_mc,loadedBackImage.statCell5_mc,loadedBackImage.statCell6_mc];
            statCellIcons = [new EmbeddedArt.FV_StatusShelf_Icon_Level(),new EmbeddedArt.FV_StatusShelf_Icon_Ribbon(),new EmbeddedArt.FV_StatusShelf_Icon_Mastery(),new EmbeddedArt.FV_StatusShelf_Icon_Medal(),new EmbeddedArt.FV_StatusShelf_Icon_Collections(),new EmbeddedArt.FV_StatusShelf_Icon_Building()];
            for(i = 0; i < subcellMCs.length; i++)
            {
               this.m_statusCellTextFields.push(subcellMCs[i].counter_tf);
               subcellMCs[i].counter_tf.selectable = false;
               subcellMCs[i].statIcon_mc.addChild(statCellIcons[i]);
            }
            loadedBackImage.y = this.PROFILE_PIC_BOTTOM_Y;
            loadedBackImage.alpha = 0;
            this.updateStatsTextFields();
            this.m_profileBackImage.addChild(loadedBackImage);
         }
      }
      
      protected function setupOccupiedSpot() : void
      {
         var pic:DisplayObject = null;
         var urlPic:String = null;
         if(Boolean(this.m_friend) && Boolean(this.m_friend.snUser))
         {
            urlPic = this.m_friend.snUser.picture;
            if(urlPic)
            {
               pic = LoadingManager.loadFromUrl(urlPic,{
                  "priority":LoadingManager.PRIORITY_LOW,
                  "cache":false
               });
            }
         }
         if(pic == null)
         {
            pic = new EmbeddedArt.hud_no_profile_pic();
            pic.width = 48;
            pic.height = 48;
         }
         pic.x = 6;
         pic.y = this.PROFILE_PIC_BOTTOM_Y;
         if(this.m_profilePic != null)
         {
            this.removeChild(this.m_profilePic);
         }
         this.m_profilePic = addChild(pic);
         this.updateXP();
         if(!this.m_isSpecialFriendSlot)
         {
            this.setupLocationIcon();
            this.messagingStatus = OnlineStatusEvent.STATUS_OFFLINE;
         }
         this.setupName();
         LoadingManager.load(this.STATS_SWF_URL,this.backImageLoaderCallback);
      }
      
      public function updateXP() : void
      {
         if(this.m_starIcon)
         {
            removeChild(this.m_starIcon);
            this.m_starIcon = null;
         }
         this.setupXP();
      }
      
      protected function setupXP() : void
      {
         var score:int = 0;
         var textColor:Object = null;
         var worldScoreId:String = "";
         var season2Enabled:Boolean = Global.worldManager.currentWorldType == "avalon" && WorldSeasonsManager.getInstance().getCurrentSeason(Global.worldManager.currentWorldType) == WorldSeasonsManager.SEASON_TWO;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_WORLDSCORE_NEIGHBOR_SORT) > 0)
         {
            worldScoreId = season2Enabled ? Global.worldManager.currentWorldScore2Id : Global.worldManager.currentWorldScoreId;
         }
         this.m_starIcon = new (Global.worldScoreSettingsManager.getStar(worldScoreId))();
         if(worldScoreId == "")
         {
            score = this.m_level;
         }
         else
         {
            score = season2Enabled ? int(this.m_friend.currentWorldLevel2) : int(this.m_friend.currentWorldLevel);
         }
         textColor = Global.worldScoreSettingsManager.getLevelFontColor(worldScoreId);
         this.m_starIcon.x = 45;
         this.m_starIcon.y = 7;
         addChild(this.m_starIcon);
         var level_fmt:TextFormat = new TextFormat();
         level_fmt.font = "Merkin2";
         level_fmt.size = this.m_level > 99 ? 8 : 10;
         level_fmt.color = textColor;
         level_fmt.align = TextFormatAlign.CENTER;
         var levelText:TextField = new TextField();
         levelText.embedFonts = true;
         levelText.defaultTextFormat = level_fmt;
         levelText.setTextFormat(level_fmt);
         levelText.selectable = false;
         levelText.embedFonts = true;
         levelText.width = 20;
         levelText.text = score.toString();
         levelText.x = this.m_starIcon.x + 1;
         levelText.y = this.m_starIcon.y + 3;
         addChild(levelText);
      }
      
      private function setLocationIconPos(icon:DisplayObject) : void
      {
         if(icon)
         {
            if(this.hasMessagingIcon())
            {
               icon.x = 12;
            }
            else
            {
               icon.x = 24;
            }
            icon.y = 86;
         }
      }
      
      protected function setupLocationIcon() : void
      {
         var flagIcon:DisplayObject = null;
         var expansionData:ExpansionData = null;
         this.m_location = WorldsConstants.WORLD_ID_HOME;
         if(this.m_locationIcon)
         {
            if(this.m_locationIcon.parent)
            {
               this.m_locationIcon.parent.removeChild(this.m_locationIcon);
               this.m_locationIcon = null;
            }
         }
         var friendData:Friend = Global.friendManager.getFriendData(this.m_friend.uid);
         if(friendData)
         {
            this.m_location = friendData.worldName;
            if(this.m_location == null)
            {
               this.m_location = WorldsConstants.WORLD_ID_HOME;
            }
         }
         else if(this.m_friend.uid == Global.player.uid)
         {
            this.m_location = Global.worldManager.currentWorldType;
         }
         var onAnotherFarm:Boolean = this.m_location != WorldsConstants.WORLD_ID_HOME;
         if(onAnotherFarm)
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(this.m_location);
            if(Boolean(expansionData) && Boolean(expansionData.hudIcon) && expansionData.hudIcon != "")
            {
               flagIcon = LoadingManager.load(Global.getAssetURL(expansionData.hudIcon));
               if(this.hasMessagingIcon())
               {
                  flagIcon.x = 10;
               }
               else
               {
                  flagIcon.x = 22;
               }
               flagIcon.y = 86;
            }
         }
         else
         {
            flagIcon = LoadingManager.load(Global.getAssetURL("assets/hud/LocationIcons/homeIcon_15x14.png"));
            this.setLocationIconPos(flagIcon);
         }
         if(flagIcon)
         {
            this.m_locationIcon = flagIcon;
            addChild(flagIcon);
         }
      }
      
      protected function setupName() : void
      {
         var name:String = ZLocUtils.t("FarmGame","HaveNoFriendNameData");
         if(Boolean(this.m_friend) && Boolean(this.m_friend.firstName))
         {
            name = this.m_friend.firstName;
         }
         var name_fmt:TextFormat = new TextFormat();
         name_fmt.font = "Merkin2";
         name_fmt.size = 10;
         name_fmt.color = 16776426;
         this.m_label.embedFonts = true;
         this.m_label.defaultTextFormat = name_fmt;
         this.m_label.setTextFormat(name_fmt);
         this.m_label.selectable = false;
         this.m_label.autoSize = TextFieldAutoSize.LEFT;
         this.m_label.text = name;
         this.m_label.width = this.width;
         this.m_label.wordWrap = false;
         addChild(this.m_label);
      }
      
      private function setupNPCSlot(imageUrl:String) : void
      {
         var spr:Sprite = new Sprite();
         addChild(spr);
      }
      
      private function getSlotBackgroundYOffset() : Number
      {
         return this.m_isSpecialFriendSlot ? this.Y_POSITION_SPECIAL_SLOT_BACKGROUND : this.Y_POSITION_SLOT_BACKGROUND;
      }
      
      private function setupEmptySlot() : void
      {
         var spr:Sprite = new Sprite();
         spr.x = 35;
         spr.y = 80;
         spr.width = 40;
         spr.height = 60;
         var colors:Array = [13101820,15127986,13820812,16438757];
         var colorIdx:int = this.m_rank % colors.length;
         var avatar:DisplayObject = new EmbeddedArt.emptyAvatar();
         avatar.x = (spr.width - avatar.width) / 2 + 30;
         avatar.y = (spr.height - avatar.height) / 2 + 60;
         var colorTransform:ColorTransform = new ColorTransform();
         colorTransform.color = colors[colorIdx];
         avatar.transform.colorTransform = colorTransform;
         addChild(avatar);
         var message:String = ZLocUtils.t("FarmGame","InviteNeighbor");
         var levelText:StrokeTextField = this.createSlotStatusText(message,60,1,33);
         addChild(levelText);
         addChild(spr);
      }
      
      private function setupLoadingOccupiedSpot() : void
      {
         this.removeEventListener(MouseEvent.CLICK,this.onClickFriend);
         var message:String = ZLocUtils.t("FarmGame","LoadingNeighborSlot");
         var statusText:StrokeTextField = this.createSlotStatusText(message,60,1,85);
         addChild(statusText);
         if(this.m_character)
         {
            this.m_character.doAvatarAction(AnimationAction.ARM_SHUFFLE);
         }
      }
      
      private function createAvatarSprite(x:Number, y:Number, width:Number, height:Number, isAvatarVisible:Boolean) : Sprite
      {
         var spr:Sprite = new Sprite();
         this.m_character = new SimpleNPC(new FarmvilleClothingLoader());
         this.m_character.visible = isAvatarVisible;
         Utilities.toggleInputAndChildren(this.m_character,false);
         Utilities.toggleInputOnlySelf(spr,false);
         if(this.m_avatarData != null)
         {
            this.m_character.setAvatarCustomizationData(this.m_avatarData);
         }
         this.m_character.x = -5;
         this.m_character.y = 6;
         spr.addChild(this.m_character);
         spr.x = x;
         spr.y = y;
         spr.width = width;
         spr.height = height;
         return spr;
      }
      
      private function createSlotStatusText(message:String, width:Number, x:Number, y:Number) : StrokeTextField
      {
         var textColors:Array = [1152737,4534804,4687160,14124483];
         var colorIdx:int = this.m_rank % textColors.length;
         var format:TextFormat = new TextFormat("Merkin2",10,16777215,true,null,null,null,null,TextFormatAlign.CENTER);
         var text:StrokeTextField = new StrokeTextField(textColors[colorIdx],1);
         text.toolTipText = message;
         text.setTextFormat(format);
         text.width = 60;
         text.wordWrap = true;
         text.multiline = true;
         text.embedFonts = true;
         text.x = x;
         text.y = y;
         return text;
      }
      
      protected function onRollOverFriend(e:MouseEvent) : void
      {
         var spr:Sprite = null;
         if(!this.m_initAvatarSpriteLoad && !this.m_empty)
         {
            this.m_initAvatarSpriteLoad = true;
            spr = this.createAvatarSprite(35,80,40,60,true);
            this.m_profileBackImage.addChild(spr);
         }
         if(this.m_backgroundOver)
         {
            if(Boolean(this.m_backgroundNormal) && contains(this.m_backgroundNormal))
            {
               removeChild(this.m_backgroundNormal);
            }
            this.m_backgroundOver.y = this.getSlotBackgroundYOffset();
            addChildAt(this.m_backgroundOver,0);
         }
         if(this.m_profilePic)
         {
            TweenLite.to(this.m_profilePic,0.2,{
               "alpha":1,
               "y":this.PROFILE_PIC_TOP_Y
            });
            SoundManager.playSound("neighbor");
         }
         this.m_profileBackImage.visible = true;
         TweenLite.to(this.m_profileBackImage,0.2,{"alpha":1});
         if(this.m_character)
         {
            this.m_character.doRandomDance();
         }
         ClickTrackingManager.getInstance().sampleOrCount("fv_neighbor_bar_populate",ClickTrackingConstants.NEIGHBOR_BAR_STATS_COUNTER,ClickTrackingConstants.NEIGHBOR_BAR_CARD_TOUCH);
      }
      
      protected function onRollOutFriend(e:MouseEvent) : void
      {
         if(this.m_backgroundNormal)
         {
            if(Boolean(this.m_backgroundOver) && contains(this.m_backgroundOver))
            {
               removeChild(this.m_backgroundOver);
            }
            this.m_backgroundNormal.y = this.getSlotBackgroundYOffset();
            addChildAt(this.m_backgroundNormal,0);
         }
         if(this.m_profilePic)
         {
            TweenLite.to(this.m_profilePic,0.2,{"y":this.PROFILE_PIC_BOTTOM_Y});
         }
         if(!this.m_isLoadingFriend)
         {
            TweenLite.to(this.m_profileBackImage,0.2,{
               "alpha":0,
               "onComplete":this.hideBackImage
            });
         }
         if(this.m_character)
         {
            this.m_character.doAvatarAction("0");
         }
      }
      
      protected function hideBackImage() : void
      {
         this.m_profileBackImage.visible = false;
      }
      
      public function get uid() : String
      {
         var result:String = "0";
         if(this.m_friend)
         {
            result = this.m_friend.uid;
         }
         return result;
      }
      
      public function get friend() : IUser
      {
         return this.m_friend;
      }
      
      public function get stats() : Array
      {
         return this.m_statsValuesArray;
      }
      
      protected function get onlineStatusSortPriority() : int
      {
         var result:int = 0;
         if(this is NPCSlot)
         {
            result = 4;
         }
         else if(this.messagingStatus == OnlineStatusEvent.NEW_MESSAGE)
         {
            result = 3;
         }
         else if(this.messagingStatus == OnlineStatusEvent.STATUS_ONLINE)
         {
            result = 2;
         }
         else if(this.messagingStatus == OnlineStatusEvent.STATUS_OFFLINE)
         {
            result = 1;
         }
         else
         {
            result = 0;
         }
         return result;
      }
      
      public function shouldDisplay() : Boolean
      {
         return true;
      }
      
      public function get index() : int
      {
         return this.m_index;
      }
      
      public function set index(index:int) : void
      {
         this.m_index = index;
      }
   }
}

