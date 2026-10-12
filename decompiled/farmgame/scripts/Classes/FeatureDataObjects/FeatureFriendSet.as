package Classes.FeatureDataObjects
{
   import Engine.Managers.TransactionManager;
   import Transactions.TFriendSetCompleteSeen;
   import Transactions.TStartFriendSetTimer;
   
   public class FeatureFriendSet extends FriendSet
   {
      
      protected var m_startTime:Number = 0;
      
      protected var m_goalLevel:int = 0;
      
      protected var m_numBoughtFriends:Number = 0;
      
      public function FeatureFriendSet(code:String, index:Number = -2, callback:Function = null)
      {
         super(code,index,callback);
      }
      
      override public function onInitialize(result:Object) : void
      {
         if(result.startTime != null)
         {
            this.m_startTime = result.startTime;
         }
         if(result.boughtFriendCount != null)
         {
            this.m_numBoughtFriends = result.boughtFriendCount;
         }
         super.onInitialize(result);
      }
      
      override public function getDifficultyForLevel(level:int, min:int, max:int) : int
      {
         return min;
      }
      
      override public function get numFriendsCompleted() : int
      {
         return super.numFriendsCompleted + this.m_numBoughtFriends;
      }
      
      override public function get className() : String
      {
         return FriendSet.FEATURE_FRIEND_SET;
      }
      
      public function getStartTime() : Number
      {
         return this.m_startTime;
      }
      
      public function getNumBoughtFriends() : Number
      {
         return this.m_numBoughtFriends;
      }
      
      override public function markSeen() : void
      {
         super.markSeen();
         if(this.m_goalLevel >= 1 && this.m_startTime == 0)
         {
            this.m_startTime = GlobalEngine.serverTime / 1000;
         }
      }
      
      public function startFriendSetTimer() : void
      {
         this.m_startTime = GlobalEngine.serverTime / 1000;
         TransactionManager.addTransaction(new TStartFriendSetTimer(this.m_code));
      }
      
      public function completionSeen() : void
      {
         this.markSeen();
         TransactionManager.addTransaction(new TFriendSetCompleteSeen(m_code));
      }
   }
}

