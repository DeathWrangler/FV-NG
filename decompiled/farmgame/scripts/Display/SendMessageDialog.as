package Display
{
   import Classes.Message;
   import Classes.MessageSign;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Managers.FarmStatsManager;
   import Managers.MessageManager;
   import Transactions.TMessageSignPlace;
   import flash.events.MouseEvent;
   
   public class SendMessageDialog extends Dialog
   {
      
      private var m_messageSign:MessageSign;
      
      protected const MAX_CHARS:Number = 140;
      
      private var m_accept:GenericButton;
      
      public function SendMessageDialog(messageSign:MessageSign)
      {
         m_dialogAsset = "assets/dialogs/FV_sendMessage.swf";
         this.m_messageSign = messageSign;
         FarmStatsManager.count(MessageSign.SIGNPOST_MESSAGE,"send","click_initial");
         super();
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         FarmStatsManager.count(MessageSign.SIGNPOST_MESSAGE,"send","view_enter_msg");
         Global.stage.focus = m_window.sendMessage_mc.messaging_tf;
         m_window.sendMessage_mc.messaging_tf.maxChars = this.MAX_CHARS;
         m_window.sendMessage_mc.messaging_tf.multiline = false;
         m_window.sendMessage_mc.messaging_tf.text = "";
         this.m_accept = new GenericButton(m_window.sendMessage_mc.send_bt,this.onSendMessage);
         this.m_accept.text = ZLocUtils.t("Dialogs","Send");
         m_window.sendMessage_mc.close_bt.addEventListener(MouseEvent.CLICK,this.onCancel);
      }
      
      private function onCancel(event:MouseEvent) : void
      {
         this.m_messageSign.detach();
         this.onCloseClick(event);
      }
      
      private function onSendMessage(event:MouseEvent) : void
      {
         var message:Message = null;
         var msg:String = m_window.sendMessage_mc.messaging_tf.text;
         if(msg.length == 0)
         {
            Global.stage.focus = m_window.sendMessage_mc.messaging_tf;
         }
         else
         {
            msg = msg.substr(0,this.MAX_CHARS);
            this.m_messageSign.setMessage(msg);
            if(Global.worldManager.isVisiting())
            {
               this.m_messageSign.hostId = Global.worldManager.getVisiting();
            }
            else
            {
               this.m_messageSign.hostId = Global.player.snUser.uid;
            }
            this.m_messageSign.timestamp = GlobalEngine.serverTime;
            this.m_messageSign.authorId = Global.player.snUser.uid;
            FarmStatsManager.count(MessageSign.SIGNPOST_MESSAGE,"send","click_accept");
            message = new Message(msg,this.m_messageSign.authorId,this.m_messageSign.getTempId(),false);
            TransactionManager.addTransaction(new TMessageSignPlace(this.m_messageSign,message));
            this.onCloseClick(event);
         }
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         super.onCloseClick(event);
         Global.world.setDefaultGameMode();
         MessageManager.getInstance().onPlaceMessageSignDone();
         m_window.sendMessage_mc.send_bt.removeEventListener(MouseEvent.CLICK,this.onSendMessage);
         m_window.sendMessage_mc.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         event.stopPropagation();
         close();
         dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
   }
}

