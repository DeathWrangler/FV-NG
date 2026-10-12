package Transactions
{
   import Classes.Message;
   import Classes.MessageSign;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.MessageManager;
   
   public class TMessageSignPlace extends TPlace
   {
      
      private static const ACTION_PLACE_MESSAGE:String = "placeMessage";
      
      protected var m_messageSign:MessageSign;
      
      protected var m_message:Message;
      
      private var m_onPostMessageComplete:Function = null;
      
      public function TMessageSignPlace(messageSign:MessageSign, message:Message, onPostMessageComplete:Function = null)
      {
         this.m_messageSign = messageSign;
         this.m_message = message;
         this.m_onPostMessageComplete = onPostMessageComplete;
         super(messageSign);
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_PLACE_MESSAGE);
      }
      
      override protected function onComplete(result:Object) : void
      {
         FarmStatsManager.count(MessageSign.SIGNPOST_MESSAGE,"send","sign_placement_complete");
         super.onComplete(result);
         this.m_messageSign.setMessage(result.messageText);
         this.m_messageSign.setMessageId(result.messageId);
         this.m_message.setObjectId(this.m_messageSign.getId());
         this.m_message.setId(result.messageId);
         MessageManager.getInstance().addMessage(this.m_message);
         if(this.m_onPostMessageComplete != null)
         {
            this.m_onPostMessageComplete(this.m_message);
         }
         UI.displayMessage(ZLocUtils.t("Dialogs","MessageSignSuccess"),GenericPopup.TYPE_OK,this.messageSignSuccess);
      }
      
      private function messageSignSuccess(event:GenericPopupEvent) : void
      {
         if(this.m_messageSign.hostId != Global.player.snUser.uid)
         {
            GlobalEngine.socialNetwork.sendNotification("MessageSign",[],[this.m_messageSign.hostId.toString()]);
         }
         FarmStatsManager.count(MessageSign.SIGNPOST_MESSAGE,"send","click_okay");
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_PLACE_MESSAGE;
         result.hostId = this.m_messageSign.hostId;
         result.authorId = this.m_messageSign.authorId;
         return result;
      }
   }
}

