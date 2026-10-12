package Managers
{
   import Classes.FriendReward;
   
   public class FriendRewardsManager
   {
      
      private static var m_objInstance:FriendRewardsManager;
      
      private var m_friendRewards:Array = new Array();
      
      public function FriendRewardsManager(objEnforcer:SingletonEnforcer)
      {
         super();
      }
      
      public static function getInstance() : FriendRewardsManager
      {
         if(m_objInstance == null)
         {
            m_objInstance = new FriendRewardsManager(new SingletonEnforcer());
         }
         return m_objInstance;
      }
      
      public function loadFriendRewards(friendRewards:Object) : void
      {
         var friendRewardName:String = null;
         var friendRewardField:String = null;
         var id:String = null;
         var userId:String = null;
         var timeRequested:Number = NaN;
         var helpers:Array = null;
         var friendRewardHelperName:String = null;
         var helperObj:Object = null;
         var friendRewardHelper:String = null;
         if(friendRewards)
         {
            for(friendRewardName in friendRewards)
            {
               for(friendRewardField in friendRewards[friendRewardName])
               {
                  id = friendRewards[friendRewardName][friendRewardField].id;
                  userId = friendRewards[friendRewardName][friendRewardField].userId;
                  timeRequested = Number(friendRewards[friendRewardName][friendRewardField].timeRequested);
                  helpers = new Array();
                  for(friendRewardHelperName in friendRewards[friendRewardName][friendRewardField].helpers)
                  {
                     helperObj = new Object();
                     for(friendRewardHelper in friendRewards[friendRewardName][friendRewardField].helpers[friendRewardHelperName])
                     {
                        helperObj[friendRewardHelper] = friendRewards[friendRewardName][friendRewardField].helpers[friendRewardHelperName][friendRewardHelper];
                     }
                     helpers.push(helperObj);
                  }
                  this.m_friendRewards.push(new FriendReward(friendRewardName,id,userId,helpers,timeRequested));
               }
            }
         }
      }
      
      public function get friendRewards() : Array
      {
         return this.m_friendRewards;
      }
      
      public function getFriendRewardByName(rewardName:String) : FriendReward
      {
         var friendRewardObj:FriendReward = null;
         var friendReward:FriendReward = null;
         for each(friendRewardObj in this.m_friendRewards)
         {
            if(friendRewardObj.m_rewardName == rewardName)
            {
               friendReward = friendRewardObj;
               break;
            }
         }
         return friendReward;
      }
      
      public function getAllFriendRewardByName(rewardName:String) : Array
      {
         var friendRewardObj:FriendReward = null;
         var friendRewardArray:Array = new Array();
         for each(friendRewardObj in this.m_friendRewards)
         {
            if(friendRewardObj.m_rewardName == rewardName)
            {
               friendRewardArray.push(friendRewardObj);
            }
         }
         return friendRewardArray;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
