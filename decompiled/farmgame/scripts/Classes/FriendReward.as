package Classes
{
   public class FriendReward
   {
      
      public const NUM_SECS_IN_DAY:uint = 86400;
      
      public var m_rewardName:String;
      
      public var m_id:String;
      
      public var m_userId:String;
      
      public var m_helpers:Array;
      
      public var m_timeRequested:Number;
      
      public function FriendReward(rewardName:String, id:String, userId:String, helpers:Array, timeRequested:Number)
      {
         super();
         this.m_rewardName = rewardName;
         this.m_id = id;
         this.m_userId = userId;
         this.m_helpers = helpers;
         this.m_timeRequested = timeRequested;
      }
      
      public function get rewardName() : String
      {
         return this.m_rewardName;
      }
      
      public function get id() : String
      {
         return this.m_id;
      }
      
      public function get userId() : String
      {
         return this.m_userId;
      }
      
      public function get helpers() : Array
      {
         return this.m_helpers;
      }
      
      public function get timeRequested() : Number
      {
         return this.m_timeRequested;
      }
      
      public function getNumHelps() : Number
      {
         var helper:Object = null;
         var totalHelpers:int = 0;
         for each(helper in this.m_helpers)
         {
            if(Boolean(helper.numHelps) && helper.numHelps > 0)
            {
               totalHelpers += helper.numHelps;
            }
         }
         return totalHelpers;
      }
      
      public function getTotalHelpers() : Number
      {
         return this.m_helpers.length;
      }
      
      public function getHelperLimit() : Number
      {
         return Global.farmGameSettingsManager.getNumber(this.rewardName + "HelperLimit");
      }
      
      public function getDaysRemaining() : int
      {
         var timeLimit:int = Global.farmGameSettingsManager.getNumber(this.rewardName + "TimeLimit");
         var timeServer:int = GlobalEngine.getTimer() / 1000;
         var days:Number = timeLimit - (timeServer - this.timeRequested);
         return Math.round(days / this.NUM_SECS_IN_DAY);
      }
      
      public function hasExpired() : Boolean
      {
         var timeLimit:int = Global.farmGameSettingsManager.getNumber(this.rewardName + "TimeLimit");
         var timeServer:int = GlobalEngine.getTimer() / 1000;
         var diff:Number = timeServer - this.timeRequested;
         return diff >= timeLimit;
      }
      
      public function getIconToolTip() : String
      {
         return this.rewardName + "_iconTooltip";
      }
      
      public function success() : Boolean
      {
         return this.getNumHelps() >= this.getHelperLimit() || this.getTotalHelpers() >= this.getHelperLimit();
      }
      
      public function getHelperNames() : String
      {
         var helper:Object = null;
         var names:String = "";
         var cnt:Number = 0;
         for each(helper in this.m_helpers)
         {
            if(helper.helperId)
            {
               if(cnt < this.getHelperLimit() - 1)
               {
                  names += Global.friendManager.getFriendName(helper.helperId,true) + ", ";
               }
               else
               {
                  names += Global.friendManager.getFriendName(helper.helperId,true);
               }
            }
         }
         return names;
      }
   }
}

