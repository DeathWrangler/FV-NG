package Widgets.Windows
{
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmRunQuestManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Leaderboard.LeaderboardSlotPlayerData;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FarmRunQuestRewardWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 25;
      
      protected var m_title:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      public var m_item:FarmItem = null;
      
      private var m_extraReward:MovieClip = new MovieClip();
      
      public var m_callBackFunction:Function;
      
      private var m_shareButton:FarmAnimatedCashButton;
      
      private var m_LeaderBoardTitle_tf:ZwTextField;
      
      private var m_worldStageComplete:Boolean = false;
      
      private var m_finalRewardBG:MovieClip = new MovieClip();
      
      private const friendCard0_mc:String = "friendCard0_mc";
      
      private var m_friendCard0_mc:MovieClip;
      
      private var m_friendRank0_tf:ZwTextField;
      
      protected var friendIcon0_mc:FarmIcon;
      
      private const friendCard1_mc:String = "friendCard1_mc";
      
      private var m_friendCard1_mc:MovieClip;
      
      private var m_friendRank1_tf:ZwTextField;
      
      protected var friendIcon1_mc:FarmIcon;
      
      private const friendCard2_mc:String = "friendCard2_mc";
      
      private var m_friendCard2_mc:MovieClip;
      
      private var m_friendRank2_tf:ZwTextField;
      
      protected var friendIcon2_mc:FarmIcon;
      
      private const friendCard3_mc:String = "friendCard3_mc";
      
      private var m_friendCard3_mc:MovieClip;
      
      private var m_friendRank3_tf:ZwTextField;
      
      protected var friendIcon3_mc:FarmIcon;
      
      private const friendCard4_mc:String = "friendCard4_mc";
      
      private var m_friendCard4_mc:MovieClip;
      
      private var m_friendRank4_tf:ZwTextField;
      
      protected var friendIcon4_mc:FarmIcon;
      
      private var m_friendIcon0Frame:ZwFrame;
      
      private var m_friendIcon1Frame:ZwFrame;
      
      private var m_friendIcon2Frame:ZwFrame;
      
      private var m_friendIcon3Frame:ZwFrame;
      
      private var m_friendIcon4Frame:ZwFrame;
      
      public function FarmRunQuestRewardWindow(callback:Function, assetPath:String, worldStageComplete:Boolean = false)
      {
         super(assetPath);
         this.m_callBackFunction = callback;
         this.m_worldStageComplete = worldStageComplete;
      }
      
      override protected function postLoadComplete() : void
      {
         var itemBox1:FarmIcon = null;
         var currentStage:Number = NaN;
         var m_extraRewarditem:FarmItem = null;
         var itemBox2:FarmIcon = null;
         var FriendData:Array = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,"Congratulations"));
         }
         var stageJustCompleted:Number = FarmRunQuestManager.getInstance().getCurrentStage() - 1;
         if(stageJustCompleted >= 0)
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(FarmRunQuestManager.getInstance().getRewardsItemsArray()[stageJustCompleted]);
         }
         if(m_window.hasOwnProperty("generic_tf"))
         {
            addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Dialogs","ofquests-01-stage" + stageJustCompleted.toString() + "_Reward")));
         }
         if(m_window.hasOwnProperty("generic2_tf"))
         {
            addWidget(new ZwTextField(m_window.generic2_tf,"Share the good news with your friends!"));
         }
         if(m_window.hasOwnProperty("itemName_tf"))
         {
            addWidget(new ZwTextField(m_window.itemName_tf,this.m_item.friendlyTitle));
         }
         if(m_window.hasOwnProperty("icon_1_mc"))
         {
            addWidget(new FarmIcon(m_window.icon_1_mc));
            itemBox1 = getWidget(m_window.icon_1_mc) as FarmIcon;
            if(Boolean(itemBox1) && Boolean(this.m_item))
            {
               itemBox1.loadIcon(this.m_item.getImageByName(FarmItem.ICON_FEED));
               itemBox1.visible = true;
            }
         }
         if(this.m_worldStageComplete)
         {
            if(FarmRunQuestManager.getInstance().isFeatureReplayed() == false)
            {
               if(m_window.hasOwnProperty("icon_2_mc"))
               {
                  addWidget(new FarmIcon(m_window.icon_2_mc));
                  currentStage = FarmRunQuestManager.getInstance().getCurrentStage();
                  if(currentStage >= 0)
                  {
                     m_extraRewarditem = Global.farmGameSettingsManager.getFarmItemByCode(FarmRunQuestManager.getInstance().getWorldCompleteRewardsItemsArray(currentStage));
                     itemBox2 = getWidget(m_window.icon_2_mc) as FarmIcon;
                     if(Boolean(itemBox2) && Boolean(m_extraRewarditem))
                     {
                        itemBox2.loadIcon(m_extraRewarditem.getImageByName(FarmItem.ICON_FEED));
                        itemBox2.visible = true;
                     }
                  }
               }
               if(m_window.hasOwnProperty("rewardbg_mc"))
               {
                  this.m_finalRewardBG = m_window.rewardbg_mc;
                  this.m_finalRewardBG.visible = true;
               }
               if(m_window.hasOwnProperty("reward_tf"))
               {
                  addWidget(new ZwTextField(m_window.reward_tf,"CONGRATS! You\'ve also won: Dreamcatcher Unicorn"));
               }
               if(this.m_finalRewardBG.hasOwnProperty("reward_tf"))
               {
                  addWidget(new ZwTextField(this.m_finalRewardBG.reward_tf,"CONGRATS! You\'ve also won: Dreamcatcher Unicorn"));
               }
            }
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            this.m_shareButton = addWidget(new FarmAnimatedCashButton(m_window.share_bt,"Share","",this.shareReward)) as FarmAnimatedCashButton;
            this.m_shareButton.visible = true;
         }
         if(m_window.hasOwnProperty("generic3_tf"))
         {
            addWidget(this.m_LeaderBoardTitle_tf = new ZwTextField(m_window.generic3_tf,"LEADERBOARD"),true);
            this.m_LeaderBoardTitle_tf.visible = true;
            currentStage = FarmRunQuestManager.getInstance().getCurrentStage();
            FriendData = this.getLeaderboardItems("FarmRunQuests");
            this.populateLeaderBoardOnRewardScreen(FriendData);
         }
      }
      
      private function getLeaderboardItems(leaderboardName:String) : Array
      {
         var i:int = 0;
         var injectedUser:Boolean = false;
         var leaderboardFriendListLength:int = 0;
         var userRank:Number = NaN;
         var resultLength:int = 0;
         var friendData:Object = null;
         var playerData:LeaderboardSlotPlayerData = null;
         var resultData:Array = null;
         var result:Array = new Array();
         var userScore:int = FarmRunQuestManager.getInstance().getUserScore();
         var userData:LeaderboardSlotPlayerData = new LeaderboardSlotPlayerData(Global.player.uid,userScore);
         var leaderboardFriendList:Array = FarmRunQuestManager.getFriendList(leaderboardName);
         if(leaderboardFriendList)
         {
            injectedUser = false;
            leaderboardFriendListLength = int(leaderboardFriendList.length);
            for(i = 0; i < leaderboardFriendListLength; i++)
            {
               friendData = new LeaderboardSlotPlayerData(Number(leaderboardFriendList[i]["uid"]),int(leaderboardFriendList[i]["value"]));
               if(!injectedUser && userScore >= friendData.score)
               {
                  result.push(userData);
                  injectedUser = true;
               }
               result.push(friendData);
            }
            if(!injectedUser)
            {
               result.push(userData);
            }
            userRank = 0;
            resultLength = int(result.length);
            for(i = 0; i < resultLength; i++)
            {
               playerData = result[i] as LeaderboardSlotPlayerData;
               if(playerData)
               {
                  if(playerData.uid == Global.player.uid)
                  {
                     userRank = i + 1;
                  }
                  playerData.rank = i + 1;
               }
            }
         }
         else
         {
            userData.rank = 1;
            userRank = 1;
            result.push(userData);
         }
         if(userRank > 5)
         {
            if(result.length > 5)
            {
               resultData = new Array();
               for(i = 0; i < 3; i++)
               {
                  resultData.push(result[i]);
               }
               resultData.push(result[userRank - 2]);
               resultData.push(result[userRank - 1]);
               result = resultData;
            }
         }
         return result;
      }
      
      public function populateLeaderBoardOnRewardScreen(data:Array) : void
      {
         var iconUrl:String = null;
         var rank:int = 0;
         var uid:* = undefined;
         var userData:LeaderboardSlotPlayerData = null;
         var friend:Friend = null;
         if(data)
         {
            if(data.length == 1)
            {
               uid = String(data[0].uid);
               if(uid == Global.player.uid)
               {
                  iconUrl = Global.player.picture;
                  name = Global.player.firstName;
               }
               rank = int(data[0].rank);
               if(m_window.hasOwnProperty(this.friendCard0_mc))
               {
                  this.m_friendCard0_mc = m_window.friendCard0_mc;
                  this.m_friendCard0_mc.visible = true;
                  this.m_friendIcon0Frame = addWidget(new ZwFrame(this.m_friendCard0_mc.friendIcon0_mc)) as ZwFrame;
                  this.friendIcon0_mc = this.m_friendIcon0Frame.addWidget(new FarmIcon(this.m_friendCard0_mc.friendIcon0_mc)) as FarmIcon;
                  this.m_friendIcon0Frame.visible = true;
                  this.friendIcon0_mc.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
                  this.friendIcon0_mc.setSmoothing(true);
                  this.friendIcon0_mc.loadIcon(iconUrl);
                  this.friendIcon0_mc.visible = true;
                  addWidget(this.m_friendRank0_tf = new ZwTextField(this.m_friendCard0_mc.friendRank0_tf,String(rank)),true);
                  this.m_friendRank0_tf.visible = true;
               }
            }
            else
            {
               if(data.length > 0)
               {
                  userData = data[0];
                  uid = String(userData.uid);
                  if(uid == Global.player.uid)
                  {
                     iconUrl = Global.player.picture;
                  }
                  else
                  {
                     friend = Global.friendManager.getFriendData(uid);
                     if(friend)
                     {
                        iconUrl = friend.picture;
                     }
                  }
                  rank = int(userData.rank);
                  if(m_window.hasOwnProperty(this.friendCard0_mc))
                  {
                     this.m_friendCard0_mc = m_window.friendCard0_mc;
                     this.m_friendCard0_mc.visible = true;
                     this.m_friendIcon0Frame = addWidget(new ZwFrame(this.m_friendCard0_mc.friendIcon0_mc)) as ZwFrame;
                     this.friendIcon0_mc = this.m_friendIcon0Frame.addWidget(new FarmIcon(this.m_friendCard0_mc.friendIcon0_mc)) as FarmIcon;
                     this.m_friendIcon0Frame.visible = true;
                     this.friendIcon0_mc.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
                     this.friendIcon0_mc.setSmoothing(true);
                     this.friendIcon0_mc.loadIcon(iconUrl);
                     this.friendIcon0_mc.visible = true;
                     addWidget(this.m_friendRank0_tf = new ZwTextField(this.m_friendCard0_mc.friendRank0_tf,String(rank)),true);
                     this.m_friendRank0_tf.visible = true;
                  }
               }
               if(data.length > 1)
               {
                  userData = data[1];
                  uid = String(userData.uid);
                  if(uid == Global.player.uid)
                  {
                     iconUrl = Global.player.picture;
                  }
                  else
                  {
                     friend = Global.friendManager.getFriendData(uid);
                     if(friend)
                     {
                        iconUrl = friend.picture;
                     }
                  }
                  rank = int(userData.rank);
                  if(m_window.hasOwnProperty(this.friendCard1_mc))
                  {
                     this.m_friendCard1_mc = m_window.friendCard1_mc;
                     this.m_friendCard1_mc.visible = true;
                     this.m_friendIcon1Frame = addWidget(new ZwFrame(this.m_friendCard1_mc.friendIcon1_mc)) as ZwFrame;
                     this.friendIcon1_mc = this.m_friendIcon1Frame.addWidget(new FarmIcon(this.m_friendCard1_mc.friendIcon1_mc)) as FarmIcon;
                     this.m_friendIcon1Frame.visible = true;
                     this.friendIcon1_mc.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
                     this.friendIcon1_mc.setSmoothing(true);
                     this.friendIcon1_mc.loadIcon(iconUrl);
                     this.friendIcon1_mc.visible = true;
                     addWidget(this.m_friendRank1_tf = new ZwTextField(this.m_friendCard1_mc.friendRank1_tf,String(rank)),true);
                     this.m_friendRank1_tf.visible = true;
                  }
               }
               if(data.length > 2)
               {
                  userData = data[2];
                  uid = String(userData.uid);
                  if(uid == Global.player.uid)
                  {
                     iconUrl = Global.player.picture;
                  }
                  else
                  {
                     friend = Global.friendManager.getFriendData(uid);
                     if(friend)
                     {
                        iconUrl = friend.picture;
                     }
                  }
                  rank = int(userData.rank);
                  if(m_window.hasOwnProperty(this.friendCard2_mc))
                  {
                     this.m_friendCard2_mc = m_window.friendCard2_mc;
                     this.m_friendCard2_mc.visible = true;
                     this.m_friendIcon2Frame = addWidget(new ZwFrame(this.m_friendCard2_mc.friendIcon2_mc)) as ZwFrame;
                     this.friendIcon2_mc = this.m_friendIcon2Frame.addWidget(new FarmIcon(this.m_friendCard2_mc.friendIcon2_mc)) as FarmIcon;
                     this.m_friendIcon2Frame.visible = true;
                     this.friendIcon2_mc.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
                     this.friendIcon2_mc.setSmoothing(true);
                     this.friendIcon2_mc.loadIcon(iconUrl);
                     this.friendIcon2_mc.visible = true;
                     addWidget(this.m_friendRank2_tf = new ZwTextField(this.m_friendCard2_mc.friendRank2_tf,String(rank)),true);
                     this.m_friendRank2_tf.visible = true;
                  }
               }
               if(data.length > 3)
               {
                  userData = data[3];
                  uid = String(userData.uid);
                  if(uid == Global.player.uid)
                  {
                     iconUrl = Global.player.picture;
                  }
                  else
                  {
                     friend = Global.friendManager.getFriendData(uid);
                     if(friend)
                     {
                        iconUrl = friend.picture;
                     }
                  }
                  rank = int(userData.rank);
                  if(m_window.hasOwnProperty(this.friendCard3_mc))
                  {
                     this.m_friendCard3_mc = m_window.friendCard3_mc;
                     this.m_friendCard3_mc.visible = true;
                     this.m_friendIcon3Frame = addWidget(new ZwFrame(this.m_friendCard3_mc.friendIcon3_mc)) as ZwFrame;
                     this.friendIcon3_mc = this.m_friendIcon3Frame.addWidget(new FarmIcon(this.m_friendCard3_mc.friendIcon3_mc)) as FarmIcon;
                     this.m_friendIcon3Frame.visible = true;
                     this.friendIcon3_mc.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
                     this.friendIcon3_mc.setSmoothing(true);
                     this.friendIcon3_mc.loadIcon(iconUrl);
                     this.friendIcon3_mc.visible = true;
                     addWidget(this.m_friendRank3_tf = new ZwTextField(this.m_friendCard3_mc.friendRank3_tf,String(rank)),true);
                     this.m_friendRank3_tf.visible = true;
                  }
               }
               if(data.length > 4)
               {
                  userData = data[4];
                  uid = String(userData.uid);
                  if(uid == Global.player.uid)
                  {
                     iconUrl = Global.player.picture;
                  }
                  else
                  {
                     friend = Global.friendManager.getFriendData(uid);
                     if(friend)
                     {
                        iconUrl = friend.picture;
                     }
                  }
                  rank = int(userData.rank);
                  if(m_window.hasOwnProperty(this.friendCard4_mc))
                  {
                     this.m_friendCard4_mc = m_window.friendCard4_mc;
                     this.m_friendCard4_mc.visible = true;
                     this.m_friendIcon4Frame = addWidget(new ZwFrame(this.m_friendCard4_mc.friendIcon4_mc)) as ZwFrame;
                     this.friendIcon4_mc = this.m_friendIcon4Frame.addWidget(new FarmIcon(this.m_friendCard4_mc.friendIcon4_mc)) as FarmIcon;
                     this.m_friendIcon4Frame.visible = true;
                     this.friendIcon4_mc.setIconSize(FarmRunQuestManager.ICON_SIZE,FarmRunQuestManager.ICON_SIZE);
                     this.friendIcon4_mc.setSmoothing(true);
                     this.friendIcon4_mc.loadIcon(iconUrl);
                     this.friendIcon4_mc.visible = true;
                     addWidget(this.m_friendRank4_tf = new ZwTextField(this.m_friendCard4_mc.friendRank4_tf,String(rank)),true);
                     this.m_friendRank4_tf.visible = true;
                  }
               }
            }
         }
      }
      
      override public function close() : void
      {
         if(this.m_callBackFunction != null)
         {
            this.m_callBackFunction.call();
         }
         super.close();
      }
      
      public function shareReward(ev:Event = null) : void
      {
         FarmRunQuestManager.getInstance().shareReward();
         this.close();
      }
   }
}

