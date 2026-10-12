package Transactions
{
   import Classes.Growable.GrowableConstants;
   import Classes.Growable.GrowableContest;
   import Managers.GrowableContestManager;
   
   public class TGrowableUnlockSlot extends TFarmTransaction
   {
      
      private var m_contestId:String = null;
      
      private var m_callback:Function;
      
      public function TGrowableUnlockSlot(contestId:String, callback:Function = null)
      {
         super();
         this.m_contestId = contestId;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall(GrowableConstants.SERVICE_GROWABLE_CONTEST + ".buySlot",this.m_contestId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         var contest:GrowableContest = GrowableContestManager.instance.getContest(this.m_contestId);
         var state:Object = contest.currentState;
         state.slotsAvailable = result.slotsAvailable;
         contest.currentState = state;
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

