package Transactions
{
   public class TEnterSweepstakes extends TFarmTransaction
   {
      
      private var m_Callback:Function;
      
      public function TEnterSweepstakes(callback:Function = null)
      {
         this.m_Callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("EnglishSweepstakesService.onClaimFirstEntry");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_Callback != null)
         {
            this.m_Callback(result);
         }
      }
   }
}

