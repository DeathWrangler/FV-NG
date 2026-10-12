package Transactions
{
   public class TRefreshBalance extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      public function TRefreshBalance(callback:Function = null)
      {
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getBalance");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != result)
         {
            Global.player.gold = result.gold;
            Global.player.cash = result.cash;
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

