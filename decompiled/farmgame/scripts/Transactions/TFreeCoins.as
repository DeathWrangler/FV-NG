package Transactions
{
   public class TFreeCoins extends TWorldState
   {
      
      protected var freeCoins:int;
      
      public function TFreeCoins()
      {
         super(null);
         this.freeCoins = 0;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.freeCoins");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.hasOwnProperty("freeCoins") && result.freeCoins > 0)
         {
            this.freeCoins = result.freeCoins;
         }
      }
   }
}

