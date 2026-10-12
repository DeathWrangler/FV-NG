package Transactions
{
   import Classes.FeatureDataObjects.FriendSet;
   import Engine.Managers.TransactionManager;
   
   public class TBatchInitializeFriendSets extends TFarmTransaction
   {
      
      private static var s_instance:TBatchInitializeFriendSets;
      
      private static const MAX_BATCH_SIZE_UNDEFINED:int = -1;
      
      private static const MAX_BATCH_SIZE:int = 10;
      
      private static const MAX_BATCH_SIZE_RUNTIME_KEY:String = "PERF_MAX_BATCH_FRIENDSETS";
      
      private static var s_maxBatchSize:int = MAX_BATCH_SIZE_UNDEFINED;
      
      private var m_friendSets:Vector.<FriendSet>;
      
      public function TBatchInitializeFriendSets(enforcer:SingletonEnforcer, dataObj:FriendSet)
      {
         GlobalEngine.assert(enforcer != null,"[TBatchInitializeFriendSets] :: Use initialize()");
         super();
         this.m_friendSets = new Vector.<FriendSet>();
         this.m_friendSets.push(dataObj);
      }
      
      public static function initialize(friendSet:FriendSet) : void
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
            s_instance.addFriendSetToBatch(friendSet);
         }
         else
         {
            s_instance = new TBatchInitializeFriendSets(new SingletonEnforcer(),friendSet);
            TransactionManager.addTransaction(s_instance);
         }
      }
      
      public function get batchSize() : int
      {
         return this.m_friendSets.length;
      }
      
      public function addFriendSetToBatch(friendSet:FriendSet) : void
      {
         this.m_friendSets.push(friendSet);
      }
      
      override public function perform() : void
      {
         var friendSet:FriendSet = null;
         s_instance = null;
         var params:Array = [];
         for each(friendSet in this.m_friendSets)
         {
            params.push({
               "code":friendSet.code,
               "index":friendSet.index
            });
         }
         signedCall("FriendSetService.getBatchFriendSetData",params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var friendSetResult:Object = null;
         var friendSet:FriendSet = null;
         if(result)
         {
            for each(friendSet in this.m_friendSets)
            {
               if(result.hasOwnProperty(friendSet.code))
               {
                  friendSetResult = result[friendSet.code];
                  if(Boolean(friendSetResult.uids) && Boolean(friendSetResult.pending))
                  {
                     friendSet.onInitialize(friendSetResult);
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
