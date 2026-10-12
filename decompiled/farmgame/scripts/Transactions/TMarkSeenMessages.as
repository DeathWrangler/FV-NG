package Transactions
{
   public class TMarkSeenMessages extends TFarmTransaction
   {
      
      private var m_messageIds:Array;
      
      public function TMarkSeenMessages(messageIds:Array)
      {
         super();
         this.m_messageIds = messageIds;
      }
      
      override public function perform() : void
      {
         signedCall("MessageService.markSeenMessages",this.m_messageIds);
      }
   }
}

