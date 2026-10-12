package Widgets.Frames.FarmRunQuests
{
   import Classes.Leaderboard.Leaderboard;
   import Classes.util.ZLocUtils;
   import Managers.FarmRunQuestManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Leaderboard.LeaderboardSlotPlayerData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.utils.Timer;
   
   public final class FarmRunQuestLeaderboardFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_leaderboard:Leaderboard;
      
      private var m_icon:FarmIcon;
      
      private var m_leaderboardSlotFrame:FarmRunQuestLeaderboardSlotContainerFrame;
      
      private var m_timer:Timer;
      
      private var m_callBack:Function;
      
      public function FarmRunQuestLeaderboardFrame(element:DisplayObject, leaderboard:Leaderboard = null)
      {
         super(element);
         addWidget(new ZwTextField(m_element.rank_tf,ZLocUtils.t("Leaderboard","Rank")));
         addWidget(new ZwTextField(m_element.score_tf,"Progress"));
         addWidget(new ZwTextField(m_element.reward_tf,"Complete the Dreamcatcher\'s Trail to win this grand prize!"));
         this.m_leaderboardSlotFrame = addWidget(new FarmRunQuestLeaderboardSlotContainerFrame(m_element.content_mc)) as FarmRunQuestLeaderboardSlotContainerFrame;
         this.refresh();
      }
      
      public function closeLeaderboard(event:Event) : void
      {
         this.m_callBack.call();
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_leaderboard = null;
         this.m_leaderboardSlotFrame = null;
         super.release();
      }
      
      public function refresh() : void
      {
         var leaderboardSlotItems:Array = this.getLeaderboardSlotItems("FarmRunQuests");
         this.m_leaderboardSlotFrame.items = leaderboardSlotItems;
         this.m_leaderboardSlotFrame.pageNumber = 0;
      }
      
      private function getLeaderboardSlotItems(leaderboardName:String) : Array
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
   }
}

