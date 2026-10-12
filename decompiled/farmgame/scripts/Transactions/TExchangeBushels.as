package Transactions
{
   public class TExchangeBushels extends TFarmTransaction
   {
      
      private var m_bushelItemCode:String;
      
      private var m_Callback:Function;
      
      public function TExchangeBushels(bushelItemCode:String, callback:Function = null)
      {
         this.m_bushelItemCode = bushelItemCode;
         this.m_Callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onExchangeBushels",this.m_bushelItemCode);
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

