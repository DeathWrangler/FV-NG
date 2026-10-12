package Transactions
{
   public class TCottageHistorySeen extends TFarmTransaction
   {
      
      private var m_craftType:String;
      
      private var m_callback:Function;
      
      public function TCottageHistorySeen(craftType:String, callback:Function = null)
      {
         this.m_craftType = craftType;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onMarkCottageHistorySeen",this.m_craftType);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result.responseCode);
         }
      }
   }
}

