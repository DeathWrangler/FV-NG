package Transactions
{
   import Engine.Events.TransactionEvent;
   
   public class TGetHarvestEmailPref extends TFarmTransaction
   {
      
      private var m_canSendHarvestEmail:Boolean = false;
      
      public function TGetHarvestEmailPref()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.getHarvestEmailPref");
      }
      
      override protected function onComplete(result:Object) : void
      {
         this.m_canSendHarvestEmail = result["canSendHarvestEmail"];
         dispatchEvent(new TransactionEvent(TransactionEvent.COMPLETED));
      }
      
      public function get canSendHarvestEmail() : Boolean
      {
         return this.m_canSendHarvestEmail;
      }
   }
}

