package Widgets.Slots.Leaderboard
{
   public class LeaderboardSlotPlayerData
   {
      
      public var uid:*;
      
      public var score:int;
      
      public var rank:int;
      
      public function LeaderboardSlotPlayerData(uid:*, score:int, rank:int = 0)
      {
         super();
         this.uid = uid;
         this.score = score;
         this.rank = rank;
      }
   }
}

