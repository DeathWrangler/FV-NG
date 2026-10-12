package Init
{
   import Engine.Init.InitializationAction;
   import Engine.Managers.TransactionManager;
   import Transactions.PreFetchTInitUser;
   import flash.events.Event;
   
   public class PreFetchTransactionInit extends InitializationAction
   {
      
      private static var m_responseObject:Object;
      
      public static const INIT_ID:String = "PreFetchTransactionInit";
      
      public static const ON_RESPONSE_EVENT:String = "onResponseEvent";
      
      public function PreFetchTransactionInit(useBatchLimit:Boolean = false)
      {
         super(INIT_ID);
         if(useBatchLimit)
         {
            addDependency(BatchLimitInit.INIT_ID);
         }
         addDependency(UserDataInit.INIT_ID);
      }
      
      public static function get responseObject() : Object
      {
         return m_responseObject;
      }
      
      override public function execute() : void
      {
         var prefetchInitUser:PreFetchTInitUser = new PreFetchTInitUser(UserDataInit.getFirstName(),this.onResponseReceived);
         TransactionManager.addTransaction(prefetchInitUser,true);
      }
      
      private function onResponseReceived(result:Object) : void
      {
         m_responseObject = result;
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

