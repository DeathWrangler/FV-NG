package Classes.SocialRaffle
{
   public class SocialRaffleDataView
   {
      
      protected var m_rewards:Array = new Array();
      
      protected var m_grantedRewards:Array = new Array();
      
      protected var m_friendAccepts:Array = new Array();
      
      protected var m_boughtTickets:Array = new Array();
      
      protected var m_numGivenTickets:Number = 0;
      
      protected var m_friendSetCode:String = "";
      
      protected var m_currentSet:Number = 0;
      
      protected var m_madeProgress:Boolean = false;
      
      protected var m_hasGiftedRewards:Boolean = false;
      
      protected var m_showPastHelperFriends:Boolean = false;
      
      protected var m_startDay:Number = 0;
      
      protected var m_currentDay:Number = 0;
      
      protected var m_userStartTime:Number = 0;
      
      protected var m_startTime:Number = 0;
      
      protected var m_endTime:Number = 0;
      
      protected var m_raffleState:String = "active";
      
      public function SocialRaffleDataView(rawData:Object)
      {
         super();
         this.init(rawData);
      }
      
      private function init(rawData:Object) : void
      {
         var rewards:Array = null;
         var grantedRewards:Array = null;
         var reward:Object = null;
         var rewardObj:SocialRaffleReward = null;
         if(rawData.hasOwnProperty("rewards"))
         {
            rewards = rawData.rewards;
            for each(reward in rewards)
            {
               rewardObj = new SocialRaffleReward(reward.itemName,reward.chance,reward.qty);
               this.m_rewards.push(rewardObj);
            }
         }
         if(rawData.hasOwnProperty("raffle"))
         {
            if(rawData.raffle.hasOwnProperty("startDay"))
            {
               this.m_startDay = rawData.raffle.startDay;
            }
            if(rawData.raffle.hasOwnProperty("currentDay"))
            {
               this.m_currentDay = rawData.raffle.currentDay;
            }
            if(rawData.raffle.hasOwnProperty("userStartTime"))
            {
               this.m_userStartTime = rawData.raffle.userStartTime;
            }
            if(rawData.raffle.hasOwnProperty("startTime"))
            {
               this.m_startTime = rawData.raffle.startTime;
            }
            if(rawData.raffle.hasOwnProperty("endTime"))
            {
               this.m_endTime = rawData.raffle.endTime;
            }
            if(rawData.raffle.hasOwnProperty("friendAccepts"))
            {
               this.m_friendAccepts = rawData.raffle.friendAccepts;
            }
            if(rawData.raffle.hasOwnProperty("boughtTickets"))
            {
               this.m_boughtTickets = rawData.raffle.boughtTickets;
            }
            if(rawData.raffle.hasOwnProperty("numGivenTickets"))
            {
               this.m_numGivenTickets = rawData.raffle.numGivenTickets;
            }
            if(rawData.raffle.hasOwnProperty("friendSetCode"))
            {
               this.m_friendSetCode = rawData.raffle.friendSetCode;
            }
            if(rawData.raffle.hasOwnProperty("currentSet"))
            {
               this.m_currentSet = rawData.raffle.currentSet;
            }
            if(rawData.raffle.hasOwnProperty("madeProgress"))
            {
               this.m_madeProgress = rawData.raffle.madeProgress;
            }
            if(rawData.raffle.hasOwnProperty("raffleState"))
            {
               this.m_raffleState = rawData.raffle.raffleState;
            }
            if(rawData.raffle.hasOwnProperty("hasGiftedRewards"))
            {
               this.m_hasGiftedRewards = rawData.raffle.hasGiftedRewards;
            }
            if(rawData.raffle.hasOwnProperty("showPastHelperFriends"))
            {
               this.m_showPastHelperFriends = rawData.raffle.showPastHelperFriends;
            }
            if(rawData.raffle.hasOwnProperty("grantedRewards"))
            {
               grantedRewards = rawData.raffle.grantedRewards;
               for each(reward in grantedRewards)
               {
                  rewardObj = new SocialRaffleReward(reward.itemName,reward.chance,reward.qty,reward.friendUid,reward.wonPrize,reward.rewardLink,reward.hasProcessed);
                  this.m_grantedRewards.push(rewardObj);
               }
            }
         }
      }
      
      public function get grandPrize() : SocialRaffleReward
      {
         return this.m_rewards[this.m_rewards.length - 1];
      }
      
      public function get rewards() : Array
      {
         return this.m_rewards;
      }
      
      public function get grantedRewards() : Array
      {
         return this.m_grantedRewards;
      }
      
      public function get friendAccepts() : Array
      {
         return this.m_friendAccepts;
      }
      
      public function get friendAcceptsForToday() : Array
      {
         var adjustedDayOfWeek:Number = this.getAdjustedDayOfWeek();
         var newArray:Array = new Array();
         if(this.m_friendAccepts[adjustedDayOfWeek] != null)
         {
            newArray = this.m_friendAccepts[adjustedDayOfWeek];
         }
         return newArray;
      }
      
      public function get boughtTickets() : Array
      {
         return this.m_boughtTickets;
      }
      
      public function get numGivenTickets() : Number
      {
         return this.m_numGivenTickets;
      }
      
      public function set numGivenTickets(value:Number) : void
      {
         this.m_numGivenTickets = value;
      }
      
      public function get friendSetCode() : String
      {
         return this.m_friendSetCode;
      }
      
      public function get userStartTime() : Number
      {
         return this.m_userStartTime;
      }
      
      public function get startDay() : Number
      {
         return this.m_startDay;
      }
      
      public function get currentDay() : Number
      {
         return this.m_currentDay;
      }
      
      public function get startTime() : Number
      {
         return this.m_startTime;
      }
      
      public function get endTime() : Number
      {
         return this.m_endTime;
      }
      
      public function get currentSet() : Number
      {
         return this.m_currentSet;
      }
      
      public function get hasGiftedRewards() : Boolean
      {
         return this.m_hasGiftedRewards;
      }
      
      public function get showPastHelperFriends() : Boolean
      {
         return this.m_showPastHelperFriends;
      }
      
      public function get madeProgress() : Boolean
      {
         return this.m_madeProgress;
      }
      
      public function set madeProgress(value:Boolean) : void
      {
         this.m_madeProgress = value;
      }
      
      public function get raffleState() : String
      {
         return this.m_raffleState;
      }
      
      public function getAdjustedDayOfWeek() : Number
      {
         var adjustedWeekday:Number = this.currentDay - this.startDay;
         if(adjustedWeekday < 0)
         {
            adjustedWeekday = SocialRaffleConstants.DAYS_PER_WEEK + adjustedWeekday;
         }
         return adjustedWeekday;
      }
      
      public function updateBoughtTickets(numTickets:Number) : void
      {
         var adjustedDayOfWeek:Number = this.getAdjustedDayOfWeek();
         this.m_boughtTickets[adjustedDayOfWeek] += numTickets;
      }
      
      public function getLastFriendUidHelp() : String
      {
         var friendUid:String = "0";
         var dayOfWeek:Number = this.getAdjustedDayOfWeek();
         var friendData:Array = this.m_friendAccepts[dayOfWeek];
         if(friendData.length > 0)
         {
            friendUid = friendData[friendData.length - 1];
         }
         return friendUid;
      }
      
      public function getTotalNumTickets() : Number
      {
         var total:Number = 0;
         total += this.m_numGivenTickets;
         var i:Number = 0;
         for(i = 0; i < this.m_friendAccepts.length; i++)
         {
            if(this.m_friendAccepts[i] is Array)
            {
               total += this.m_friendAccepts[i].length;
            }
         }
         for(i = 0; i < this.m_boughtTickets.length; i++)
         {
            total += this.m_boughtTickets[i];
         }
         return total;
      }
   }
}

