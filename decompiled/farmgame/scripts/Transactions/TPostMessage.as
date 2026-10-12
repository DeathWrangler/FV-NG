package Transactions
{
   import Classes.Message;
   import Managers.MessageManager;
   
   public class TPostMessage extends TFarmTransaction
   {
      
      private var m_message:Message;
      
      private var m_recipientId:String;
      
      private var m_replyMessageId:Number;
      
      private var m_onPostMessageComplete:Function = null;
      
      public function TPostMessage(message:Message, recipientId:String, replyMessageId:Number = 0, onPostMessageComplete:Function = null)
      {
         super();
         this.m_message = message;
         this.m_recipientId = recipientId;
         this.m_replyMessageId = replyMessageId;
         this.m_onPostMessageComplete = onPostMessageComplete;
      }
      
      override public function perform() : void
      {
         signedCall("MessageService.addMessage",this.m_message.getMessage(),this.m_recipientId.toString(),this.m_replyMessageId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var messageId:Number = Number(result.messageId);
         this.m_message.setId(messageId);
         MessageManager.getInstance().addMessage(this.m_message);
         if(this.m_onPostMessageComplete != null)
         {
            this.m_onPostMessageComplete(this.m_message);
         }
      }
   }
}

