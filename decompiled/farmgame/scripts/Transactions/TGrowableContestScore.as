package Transactions
{
   import Classes.Growable.GrowableConstants;
   
   public class TGrowableContestScore extends TFarmTransaction
   {
      
      private var m_storageKey:String = null;
      
      private var m_callback:Function = null;
      
      public function TGrowableContestScore(storageKey:String, callback:Function = null)
      {
         super();
         this.m_storageKey = storageKey;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall(GrowableConstants.SERVICE_GROWABLE_CONTEST + ".calculateScore",this.m_storageKey);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

