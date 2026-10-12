package Transactions
{
   public class TTradePigSlop extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      public function TTradePigSlop(callback:Function = null)
      {
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("PigPenService.onTradePigSlop");
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

