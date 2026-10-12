package Init
{
   import Engine.Events.TransactionEvent;
   import Engine.Init.InitializationAction;
   import Engine.Managers.TransactionManager;
   import Managers.UserInboxManager;
   import Managers.WorldScoreManager;
   import Transactions.TInitUser;
   import flash.events.Event;
   
   public class TransactionsInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "TransactionsInit";
      
      public function TransactionsInit(useBatchLimit:Boolean = false)
      {
         super(INIT_ID);
         addDependency(ZGameSettingsInit.INIT_ID);
         addDependency(SocialNetworkInit.INIT_ID);
         addDependency(WorldInit.INIT_ID);
         addDependency(WatchToEarnInit.INIT_ID);
         if(useBatchLimit)
         {
            addDependency(BatchLimitInit.INIT_ID);
         }
      }
      
      override public function execute() : void
      {
         var completeMonitor:CompleteMonitor = null;
         var initUser:TInitUser = null;
         if(GlobalEngine.socialNetwork)
         {
            TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,WorldScoreManager.onTransactionAdded);
            TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,UserInboxManager.onTransactionComplete);
            completeMonitor = new CompleteMonitor();
            initUser = new TInitUser(GlobalEngine.socialNetwork.getLoggedInUser().firstName);
            completeMonitor.addDispatcher(initUser);
            completeMonitor.addEventListener(Event.COMPLETE,this.onTransactionsComplete);
            if(Global.farmGame.prefetchTInitUserOn)
            {
               initUser.onAmfCompleteSteps(PreFetchTransactionInit.responseObject);
               initUser.markComplete();
               TransactionManager.getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.COMPLETED,initUser));
            }
            else
            {
               TransactionManager.addTransaction(initUser,true);
            }
            Global.farmGame.notifyWaitOnTransaction();
         }
      }
      
      protected function onTransactionsComplete(ev:Event) : void
      {
         ev.currentTarget.removeEventListener(Event.COMPLETE,this.onTransactionsComplete);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

