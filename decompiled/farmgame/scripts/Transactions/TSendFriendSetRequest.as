package Transactions
{
   public class TSendFriendSetRequest extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      private var m_itemName:String;
      
      private var m_featureName:String;
      
      private var m_friendSetCode:String;
      
      private var m_currentFriendSet:String;
      
      private var m_requestIds:Array;
      
      private var m_key:String;
      
      private var m_source:String;
      
      private var m_serverTime:int = 0;
      
      public function TSendFriendSetRequest(itemName:String, featureName:String, friendSetCode:String, currentFriendSet:String, requestIds:Array, source:String, serverTime:int = 0, callback:Function = null)
      {
         super();
         this.m_itemName = itemName;
         this.m_featureName = featureName;
         this.m_friendSetCode = friendSetCode;
         this.m_currentFriendSet = currentFriendSet;
         this.m_requestIds = requestIds;
         this.m_callback = callback;
         this.m_serverTime = serverTime;
         this.m_source = source;
      }
      
      override public function perform() : void
      {
         signedCall("FBRequestService.sendFriendSetRequest",this.m_itemName,this.m_featureName,this.m_friendSetCode,this.m_currentFriendSet,this.m_requestIds,this.m_source,this.m_serverTime);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

