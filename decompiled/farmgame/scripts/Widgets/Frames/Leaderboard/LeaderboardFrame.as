package Widgets.Frames.Leaderboard
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.Leaderboard.LeaderboardState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.LeaderboardManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Leaderboard.LeaderboardSlotPlayerData;
   import flash.display.DisplayObject;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public final class LeaderboardFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_lastClickTime:int;
      
      private var m_leaderboard:Leaderboard;
      
      private var m_icon:FarmIcon;
      
      private var m_timeRemainingTextField:ZwTextField;
      
      private var m_taskTextField:ZwTextField;
      
      private var m_leaderboardSlotFrame:LeaderboardSlotContainerFrame;
      
      private var m_rankRewardSlotFrame:LeaderboardRankRewardSlotContainerFrame;
      
      private var m_timer:Timer;
      
      public function LeaderboardFrame(element:DisplayObject, leaderboard:Leaderboard = null)
      {
         super(element);
         this.m_leaderboard = leaderboard;
         this.m_icon = addWidget(new FarmIcon(m_element.questIcon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_timeRemainingTextField = addWidget(new ZwTextField(m_element.timer_tf,"")) as ZwTextField;
         this.m_taskTextField = addWidget(new ZwTextField(m_element.infotext_tf,"")) as ZwTextField;
         addWidget(new ZwTextField(m_element.rank_tf,ZLocUtils.t("Leaderboard","Rank")));
         addWidget(new ZwTextField(m_element.score_tf,ZLocUtils.t("Leaderboard","Score")));
         this.m_leaderboardSlotFrame = addWidget(new LeaderboardSlotContainerFrame(m_element.content_mc)) as LeaderboardSlotContainerFrame;
         this.m_rankRewardSlotFrame = addWidget(new LeaderboardRankRewardSlotContainerFrame(m_element.rewards_mc)) as LeaderboardRankRewardSlotContainerFrame;
         this.refresh();
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_leaderboard = null;
         this.m_leaderboardSlotFrame = null;
         this.m_rankRewardSlotFrame = null;
         this.m_taskTextField = null;
         this.m_timeRemainingTextField = null;
         this.stopTimer();
         this.m_timer = null;
         super.release();
      }
      
      private function refresh() : void
      {
         var i:int = 0;
         var leaderboardName:String = null;
         var leaderboardSlotItems:Array = null;
         var leaderboardSlotItemsLength:int = 0;
         var slotData:LeaderboardSlotPlayerData = null;
         if(this.m_leaderboard)
         {
            leaderboardName = this.m_leaderboard.name;
            this.m_icon.loadIcon(this.m_leaderboard.iconUrl);
            this.m_taskTextField.text = ZLocUtils.t("Leaderboard","LeaderboardWindow_Info",{"task":this.m_leaderboard.descriptionText});
            leaderboardSlotItems = this.getLeaderboardSlotItems(leaderboardName);
            this.m_leaderboardSlotFrame.items = leaderboardSlotItems;
            leaderboardSlotItemsLength = int(leaderboardSlotItems.length);
            if(leaderboardSlotItemsLength > 0)
            {
               for(i = 0; i < leaderboardSlotItems.length; i++)
               {
                  slotData = leaderboardSlotItems[i] as LeaderboardSlotPlayerData;
                  if(Boolean(slotData) && slotData.uid == Global.player.uid)
                  {
                     break;
                  }
               }
               this.m_leaderboardSlotFrame.pageNumber = Math.ceil((i + 1) / this.m_leaderboardSlotFrame.numSlots) - 1;
            }
            this.m_rankRewardSlotFrame.items = this.m_leaderboard.rankRewards;
            if(this.leaderboard.expirationTime > 0)
            {
               this.startTimer();
            }
            else
            {
               this.stopTimer();
            }
         }
         else
         {
            this.stopTimer();
         }
      }
      
      private function getLeaderboardSlotItems(leaderboardName:String) : Array
      {
         var i:int = 0;
         var userState:LeaderboardState = null;
         var userScore:int = 0;
         var userData:LeaderboardSlotPlayerData = null;
         var leaderboardFriendList:Array = null;
         var progressRewards:Array = null;
         var injectedUser:Boolean = false;
         var leaderboardFriendListLength:int = 0;
         var resultLength:int = 0;
         var friendData:Object = null;
         var playerData:LeaderboardSlotPlayerData = null;
         var progressReward:Object = null;
         var injectedProgressReward:Boolean = false;
         var slotData:Object = null;
         var result:Array = new Array();
         if(this.m_leaderboard)
         {
            userState = Global.player.getLeaderboardState(leaderboardName);
            userScore = userState ? userState.score : 0;
            userData = new LeaderboardSlotPlayerData(Global.player.uid,userScore);
            leaderboardFriendList = LeaderboardManager.getFriendList(leaderboardName);
            if(leaderboardFriendList)
            {
               injectedUser = false;
               leaderboardFriendListLength = int(leaderboardFriendList.length);
               leaderboardFriendList.sortOn("value",Array.NUMERIC | Array.DESCENDING);
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
               resultLength = int(result.length);
               for(i = 0; i < resultLength; i++)
               {
                  playerData = result[i] as LeaderboardSlotPlayerData;
                  if(playerData)
                  {
                     playerData.rank = i + 1;
                  }
               }
            }
            else
            {
               userData.rank = 1;
               result.push(userData);
            }
            progressRewards = this.m_leaderboard.progressRewards;
            if(progressRewards)
            {
               for each(progressReward in progressRewards)
               {
                  injectedProgressReward = false;
                  resultLength = int(result.length);
                  for(i = 0; i < resultLength; i++)
                  {
                     slotData = result[i];
                     if(slotData is LeaderboardSlotPlayerData)
                     {
                        if(int(progressReward["threshold"]) > (slotData as LeaderboardSlotPlayerData).score)
                        {
                           result.splice(i,0,progressReward);
                           injectedProgressReward = true;
                           break;
                        }
                     }
                     else if(int(progressReward["threshold"]) > int(slotData["threshold"]))
                     {
                        result.splice(i,0,progressReward);
                        injectedProgressReward = true;
                        break;
                     }
                  }
                  if(!injectedProgressReward)
                  {
                     result.push(progressReward);
                  }
               }
            }
         }
         return result;
      }
      
      public function get leaderboard() : Leaderboard
      {
         return this.m_leaderboard;
      }
      
      public function set leaderboard(value:Leaderboard) : void
      {
         this.m_leaderboard = value;
         this.refresh();
      }
      
      private function startTimer() : void
      {
         if(!this.m_timer)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         }
         this.m_timer.start();
         this.onTimer();
      }
      
      private function stopTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.stop();
         }
      }
      
      private function onTimer(event:TimerEvent = null) : void
      {
         var expirationTime:Number = NaN;
         var timeText:String = null;
         if(this.m_leaderboard)
         {
            expirationTime = this.m_leaderboard.expirationTime;
            if(expirationTime > 0)
            {
               timeText = FarmGameUtil.getTimeLeftText(expirationTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
               if(timeText)
               {
                  this.m_timeRemainingTextField.text = ZLocUtils.t("Leaderboard","LeaderboardWindow_TimeRemaining",{
                     "leaderboardName":this.m_leaderboard.nameText,
                     "time":timeText
                  });
               }
               else
               {
                  this.m_timeRemainingTextField.text = ZLocUtils.t("Leaderboard","LeaderboardWindow_Expired");
                  this.stopTimer();
               }
            }
         }
      }
   }
}

