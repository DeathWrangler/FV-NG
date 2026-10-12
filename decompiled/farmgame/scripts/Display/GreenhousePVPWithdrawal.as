package Display
{
   import Classes.EmbeddedArt;
   import Classes.Friend;
   import Classes.IUser;
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Events.CloseEvent;
   import Managers.BreedingManager;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GreenhousePVPWithdrawal extends SlotDialog
   {
      
      private static const LOC_BUNDLE:String = "Dialogs";
      
      private static const ASK_FOR_CREDITS_SHEEN_INTERVAL_MS:uint = 5000;
      
      private static const ANIMATE_METER_INTERVAL_MS:uint = 60;
      
      private static const LOCKED_ITEM_REDEEM_BUTTON_FRAME:uint = 4;
      
      private static const LEADERBOARD_SLOT_ICON_HEIGHT:Number = 39;
      
      private static const LEADERBOARD_SLOT_ICON_WIDTH:Number = 39;
      
      private static const LEADERBOARD_SLOT_ICON_OFFSET_X:Number = 1;
      
      private static const LEADERBOARD_SLOT_ICON_OFFSET_Y:Number = 1;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_HEIGHT:Number = 56;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_WIDTH:Number = 56;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_X:Number = 1.5;
      
      private static const LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_Y:Number = 2;
      
      protected static const MODE_PROGRESS:uint = 0;
      
      protected static const MODE_COMPARISON:uint = 1;
      
      private static const NUM_METER_ANIM_FRAMES:uint = 17;
      
      private static const CENTER_ICON_VERTICAL_DISPLACE:Number = -50;
      
      private const NUM_PROGRESS_SLOTS:int = 6;
      
      private const NUM_COMPARISON_SLOTS:int = 3;
      
      protected var m_buildingClassName:String;
      
      private var m_featureName:String;
      
      protected var m_buttons:Object = new Object();
      
      protected var m_totalCreditsReceived:uint = 0;
      
      private var m_creditsMeterBarFullHeight:Number = 0;
      
      private var m_friends:Array = new Array();
      
      private var m_friendsRanking:uint = 0;
      
      private var m_mainDialog:MovieClip;
      
      private var m_storageBuilding:StorageBuilding;
      
      public function GreenhousePVPWithdrawal(building:StorageBuilding, buildingClassName:String, mainDialog:MovieClip)
      {
         this.m_storageBuilding = building;
         this.m_buildingClassName = buildingClassName;
         this.m_featureName = building.getItem().name;
         this.m_mainDialog = mainDialog;
         super();
         this.onOpen();
      }
      
      protected function onOpen() : void
      {
         m_window = this.m_mainDialog.m_leaderboardContainer;
         this.addEventListeners();
         this.setupLeaderboard();
         this.switchMode(MODE_COMPARISON);
         this.fixArrows();
      }
      
      override protected function getNumSlots() : int
      {
         return this.NUM_COMPARISON_SLOTS;
      }
      
      override protected function addComponent(compId:int, index:int = 0) : void
      {
         if(Boolean(m_tiles && m_tiles[compId]) && Boolean(m_data) && Boolean(m_data[index + compId]))
         {
            this.addComparisonComponent(compId,index);
         }
      }
      
      protected function getLockedItemIconUrl() : String
      {
         return "";
      }
      
      private function addComparisonComponent(compId:int, index:int) : void
      {
         var mc:MovieClip = m_tiles[compId] as MovieClip;
         var friendData:Object = m_data[index + compId];
         if(friendData.name)
         {
            mc.name_tf.text = friendData.name;
         }
         if(friendData.statCount != null)
         {
            mc.points_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_featureName + "_Score",{"quantity":friendData.statCount});
         }
         if(friendData.uid)
         {
            this.addProfileIcon(friendData.uid,mc,mc.icon,LEADERBOARD_SLOT_ICON_WIDTH,LEADERBOARD_SLOT_ICON_HEIGHT,LEADERBOARD_SLOT_ICON_OFFSET_X,LEADERBOARD_SLOT_ICON_OFFSET_Y);
         }
         var rankNumber:uint = index + compId + 1;
         mc.rank_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_featureName + "_Ranking",{"rankNum":rankNumber});
         mc.visible = true;
      }
      
      protected function pushNewData() : void
      {
         m_data = [];
         m_tileSet = 0;
         this.pushNewComparisonData();
         this.fixArrows();
      }
      
      private function pushNewComparisonData() : void
      {
         var friend:Object = null;
         var fullName:String = null;
         var friendData:Object = null;
         var friendPlayer:Friend = null;
         for(var index:int = 0; index < this.m_friends.length; index++)
         {
            friend = this.m_friends[index];
            if(friend)
            {
               fullName = "";
               if(friend.uid == Global.player.snUser.uid)
               {
                  fullName = Global.player.snUser.name;
               }
               else
               {
                  friendPlayer = Global.friendManager.getFriendData(friend.uid);
                  if(friendPlayer)
                  {
                     fullName = friendPlayer.name;
                  }
               }
               friendData = new Object();
               friendData.name = fullName;
               friendData.statCount = friend.getBreedingStatsByFeatureName(this.m_featureName);
               friendData.uid = friend.uid;
               m_data.push(friendData);
            }
         }
      }
      
      protected function onClose(event:MouseEvent = null) : void
      {
         for(var index:uint = 0; index < this.m_buttons.length; index++)
         {
            if(this.m_buttons[index])
            {
               this.m_buttons[index].turnOff();
            }
         }
         removeTiles(false);
         this.removeEventListeners();
         if(event != null)
         {
            event.stopPropagation();
         }
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      private function addEventListeners() : void
      {
         m_window.arrowUp_bt.addEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.arrowDown_bt.addEventListener(MouseEvent.CLICK,onRtArrowClick);
      }
      
      private function removeEventListeners() : void
      {
         if(Boolean(m_window) && Boolean(m_window.close_bt))
         {
            m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onClose);
         }
         m_window.arrowUp_bt.removeEventListener(MouseEvent.CLICK,onLtArrowClick);
         m_window.arrowDown_bt.removeEventListener(MouseEvent.CLICK,onRtArrowClick);
      }
      
      protected function setupTiles() : void
      {
         var tile:String = null;
         m_tiles = new Array();
         for(var index:uint = 0; index < this.getNumSlots(); index++)
         {
            tile = "slot_" + index;
            if(m_window.hasOwnProperty(tile))
            {
               m_tiles[index] = m_window.getChildByName(tile);
               this.initializeComparisonTile(m_tiles[index]);
            }
         }
      }
      
      private function initializeComparisonTile(tile:MovieClip) : void
      {
         tile.name_tf.text = "";
         tile.points_tf.text = "";
         tile.rank_tf.text = "";
      }
      
      private function addProfileIcon(uid:String, tile:MovieClip, movieClip:MovieClip, width:Number = 50, height:Number = 50, offsetX:Number = 0, offsetY:Number = 0) : void
      {
         var friend:Friend = null;
         var iconUrl:String = "";
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
      
      protected function getDialogSideIconUrl() : String
      {
         return "";
      }
      
      private function onProgressClick(event:Event) : void
      {
         this.switchMode(MODE_PROGRESS);
      }
      
      private function onComparisonClick(event:Event) : void
      {
         this.switchMode(MODE_COMPARISON);
      }
      
      protected function getDefaultMode() : uint
      {
         return MODE_PROGRESS;
      }
      
      protected function switchMode(mode:uint) : void
      {
         this.setupTiles();
         this.pushNewData();
         addAllComponents(0);
      }
      
      private function setupLeaderboard() : void
      {
         this.populateFriends();
         this.setupPlayerPanel();
      }
      
      private function setupPlayerPanel() : void
      {
         var playerPanel:MovieClip = null;
         if(Boolean(m_window) && Boolean(m_window.playerPanel_mc))
         {
            playerPanel = m_window.playerPanel_mc as MovieClip;
            playerPanel.name_tf.text = Global.player.snUser.name;
            playerPanel.points_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_featureName + "_Score",{"quantity":BreedingManager.getInstance().getPvPStatByFeatureName(this.m_featureName)});
            playerPanel.rank_tf.text = ZLocUtils.t(LOC_BUNDLE,this.m_featureName + "_LeaderboardRanking",{
               "rankNum":this.m_friendsRanking,
               "maximum":this.m_friends.length
            });
            this.addProfileIcon(Global.player.snUser.uid.toString(),playerPanel,playerPanel.icon,LEADERBOARD_PLAYER_PANEL_ICON_WIDTH,LEADERBOARD_PLAYER_PANEL_ICON_HEIGHT,LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_X,LEADERBOARD_PLAYER_PANEL_ICON_OFFSET_Y);
         }
      }
      
      private function populateFriends() : void
      {
         var curFriend:Object = null;
         var friends:Array = Global.friendManager.neighbors.concat();
         friends.push(Global.player);
         friends.sort(this.sortFriendsByStatCount);
         for(var sortedIndex:uint = 0; sortedIndex < friends.length; sortedIndex++)
         {
            curFriend = friends[sortedIndex];
            if(curFriend.uid == Global.player.snUser.uid)
            {
               this.m_friendsRanking = sortedIndex + 1;
               break;
            }
         }
         this.m_friends = friends;
      }
      
      private function sortFriendsByStatCount(friend1:IUser, friend2:IUser) : int
      {
         var result:int = 0;
         var credits1:int = friend1.getBreedingStatsByFeatureName(this.m_featureName);
         var credits2:int = friend2.getBreedingStatsByFeatureName(this.m_featureName);
         if(credits1 > credits2)
         {
            result = -1;
         }
         else if(credits2 > credits1)
         {
            result = 1;
         }
         return result;
      }
      
      override protected function fixArrows() : void
      {
         m_window.arrowUp_bt.visible = m_tileSet > 0 ? true : false;
         m_window.arrowDown_bt.visible = (m_tileSet + 1) * this.getNumSlots() < m_data.length ? true : false;
      }
   }
}

