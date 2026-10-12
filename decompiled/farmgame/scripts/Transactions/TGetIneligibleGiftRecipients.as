package Transactions
{
   public class TGetIneligibleGiftRecipients extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      public function TGetIneligibleGiftRecipients(callback:Function = null)
      {
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("FriendListService.getIneligibleGiftRecipients");
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

