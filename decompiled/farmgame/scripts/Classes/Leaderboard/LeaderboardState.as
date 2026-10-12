package Classes.Leaderboard
{
   public class LeaderboardState
   {
      
      private var m_name:String;
      
      private var m_score:int;
      
      private var m_progressRewards:Object;
      
      private var m_progressFeeds:Object;
      
      private var m_rank:int;
      
      private var m_rankReward:Boolean;
      
      private var m_rankRewardSeen:Boolean;
      
      private var m_rankFeed:Boolean;
      
      private var m_seen:Boolean;
      
      public function LeaderboardState(resultInfo:Object = null)
      {
         super();
         if(resultInfo)
         {
            this.init(resultInfo);
         }
      }
      
      public function init(resultInfo:Object) : void
      {
         this.m_name = resultInfo.hasOwnProperty("name") ? String(resultInfo["name"]) : "";
         this.m_score = resultInfo.hasOwnProperty("score") ? int(resultInfo["score"]) : 0;
         this.m_progressRewards = resultInfo.hasOwnProperty("progressRewards") ? Object(resultInfo["progressRewards"]) : new Object();
         this.m_progressFeeds = resultInfo.hasOwnProperty("progressFeeds") ? Object(resultInfo["progressFeeds"]) : new Object();
         this.m_rank = resultInfo.hasOwnProperty("rank") ? int(resultInfo["rank"]) : 0;
         this.m_rankReward = resultInfo.hasOwnProperty("rankReward") ? Boolean(resultInfo["rankReward"]) : false;
         this.m_rankFeed = resultInfo.hasOwnProperty("rankReward") ? Boolean(resultInfo["rankFeed"]) : false;
         this.m_seen = resultInfo.hasOwnProperty("seen") ? Boolean(resultInfo["seen"]) : false;
         this.m_rankRewardSeen = resultInfo.hasOwnProperty("rankRewardSeen") ? Boolean(resultInfo["rankRewardSeen"]) : false;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function set name(value:String) : void
      {
         this.m_name = value;
      }
      
      public function get score() : int
      {
         return this.m_score;
      }
      
      public function set score(value:int) : void
      {
         this.m_score = value;
      }
      
      public function incrementScore(value:int = 1) : void
      {
         this.m_score += value;
      }
      
      public function get progressRewards() : Object
      {
         return this.m_progressRewards ? this.m_progressRewards : [];
      }
      
      public function hasProgressReward(index:int) : Boolean
      {
         return index >= 0 && Boolean(this.m_progressRewards) ? Boolean(this.m_progressRewards[index]) : false;
      }
      
      public function setProgressReward(index:int) : void
      {
         if(!this.m_progressRewards)
         {
            this.m_progressRewards = new Object();
         }
         this.m_progressRewards[index] = true;
      }
      
      public function get progressFeeds() : Object
      {
         return this.m_progressFeeds ? this.m_progressFeeds : [];
      }
      
      public function hasProgressFeed(index:int) : Boolean
      {
         return index >= 0 && Boolean(this.m_progressFeeds) ? Boolean(this.m_progressFeeds[index]) : false;
      }
      
      public function setProgressFeed(index:int) : void
      {
         if(!this.m_progressFeeds)
         {
            this.m_progressFeeds = new Object();
         }
         this.m_progressFeeds[index] = true;
      }
      
      public function get rank() : int
      {
         return this.m_rank;
      }
      
      public function set rank(value:int) : void
      {
         this.m_rank = value;
      }
      
      public function get rankReward() : Boolean
      {
         return this.m_rankReward;
      }
      
      public function set rankReward(value:Boolean) : void
      {
         this.m_rankReward = value;
      }
      
      public function get rankRewardSeen() : Boolean
      {
         return this.m_rankRewardSeen;
      }
      
      public function set rankRewardSeen(value:Boolean) : void
      {
         this.m_rankRewardSeen = value;
      }
      
      public function get rankFeed() : Boolean
      {
         return this.m_rankFeed;
      }
      
      public function set rankFeed(value:Boolean) : void
      {
         this.m_rankFeed = value;
      }
      
      public function get seen() : Boolean
      {
         return this.m_seen;
      }
      
      public function set seen(value:Boolean) : void
      {
         this.m_seen = value;
      }
   }
}

