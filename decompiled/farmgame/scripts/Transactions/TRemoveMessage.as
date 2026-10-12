package Transactions
{
   public class TRemoveMessage extends TFarmTransaction
   {
      
      private var m_messageId:Number;
      
      private var m_recipientId:String;
      
      public function TRemoveMessage(messageId:Number, recipientId:String)
      {
         super();
         this.m_messageId = messageId;
         this.m_recipientId = recipientId;
      }
      
      override public function perform() : void
      {
         var recipientIdString:String = this.m_recipientId.toString();
         signedCall("MessageService.removeMessage",this.m_messageId,recipientIdString);
      }
   }
}

