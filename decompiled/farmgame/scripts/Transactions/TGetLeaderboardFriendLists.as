package Transactions
{
   import Engine.Managers.TransactionManager;
   
   public class TGetLeaderboardFriendLists extends TFarmTransaction
   {
      
      private static var s_instance:TGetLeaderboardFriendLists;
      
      private static const MAX_BATCH_SIZE_UNDEFINED:int = -1;
      
      private static const MAX_BATCH_SIZE:int = 10;
      
      private static const MAX_BATCH_SIZE_RUNTIME_KEY:String = "PERF_MAX_BATCH_LEADERBOARD_GETFRIENDLSITS";
      
      private static const KEY_LEADERBOARD_NAME:String = "name";
      
      private static const KEY_CALLBACK:String = "callback";
      
      private static var s_maxBatchSize:int = MAX_BATCH_SIZE_UNDEFINED;
      
      private var m_leaderboardsWithCallbacks:Array;
      
      public function TGetLeaderboardFriendLists(enforcer:SingletonEnforcer, leaderboardName:String, callback:Function)
      {
         GlobalEngine.assert(enforcer != null,"[TGetLeaderboardFriendLists] :: Use getLeaderBoardFriendList()");
         super();
         this.m_leaderboardsWithCallbacks = [];
         var leaderboardData:Object = {};
         leaderboardData[KEY_LEADERBOARD_NAME] = leaderboardName;
         leaderboardData[KEY_CALLBACK] = callback;
         this.m_leaderboardsWithCallbacks.push(leaderboardData);
      }
      
      public static function getLeaderBoardFriendList(leaderboardName:String, callback:Function) : void
      {
         var runtimeBatchSize:String = null;
         if(s_maxBatchSize == MAX_BATCH_SIZE_UNDEFINED)
         {
            runtimeBatchSize = GlobalEngine.getFlashVar(MAX_BATCH_SIZE_RUNTIME_KEY) as String;
            if(runtimeBatchSize != null)
            {
               s_maxBatchSize = int(runtimeBatchSize);
            }
            else
            {
               s_maxBatchSize = MAX_BATCH_SIZE;
            }
         }
         if(s_instance != null && s_instance.batchSize < s_maxBatchSize)
         {
            s_instance.addDataToBatch(leaderboardName,callback);
         }
         else
         {
            s_instance = new TGetLeaderboardFriendLists(new SingletonEnforcer(),leaderboardName,callback);
            TransactionManager.addTransaction(s_instance);
         }
      }
      
      private function get batchSize() : int
      {
         return this.m_leaderboardsWithCallbacks.length;
      }
      
      private function addDataToBatch(leaderboardName:String, callback:Function) : void
      {
         var leaderboardData:Object = {};
         leaderboardData[KEY_LEADERBOARD_NAME] = leaderboardName;
         leaderboardData[KEY_CALLBACK] = callback;
         this.m_leaderboardsWithCallbacks.push(leaderboardData);
      }
      
      override public function perform() : void
      {
         var leaderboardData:Object = null;
         s_instance = null;
         var leaderboardNames:Array = [];
         for each(leaderboardData in this.m_leaderboardsWithCallbacks)
         {
            leaderboardNames.push(leaderboardData[KEY_LEADERBOARD_NAME]);
         }
         signedCall("LeaderboardService.getBatchFriendLists",leaderboardNames);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var leaderboardData:Object = null;
         var func:Function = null;
         if(result)
         {
            for each(leaderboardData in this.m_leaderboardsWithCallbacks)
            {
               if(result.hasOwnProperty(leaderboardData[KEY_LEADERBOARD_NAME]) && Boolean(leaderboardData[KEY_CALLBACK]))
               {
                  func = leaderboardData[KEY_CALLBACK] as Function;
                  if(func != null)
                  {
                     func(result[leaderboardData[KEY_LEADERBOARD_NAME]]);
                  }
               }
            }
         }
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
