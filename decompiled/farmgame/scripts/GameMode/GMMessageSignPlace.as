package GameMode
{
   import Classes.FarmGameObject;
   import Classes.Message;
   import Classes.MessageSign;
   import Classes.util.ZLocUtils;
   import Display.Dialog;
   import Display.MessageCenterDialog;
   import Display.SendMessageDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import Managers.FarmStatsManager;
   import Managers.MessageManager;
   import Transactions.TMessageSignPlace;
   import flash.events.MouseEvent;
   
   public class GMMessageSignPlace extends GMObjectMove
   {
      
      private var m_signName:String;
      
      private var m_messageSign:MessageSign = new MessageSign(Global.player.snUser.uid);
      
      private var m_message:Message;
      
      public function GMMessageSignPlace(signName:String, message:Message = null)
      {
         this.m_signName = signName;
         this.m_message = message;
         super(null);
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         if(!m_selectedObject)
         {
            m_highlightedPoint = getMouseTilePos();
            this.m_messageSign.setOuter(Global.world);
            this.m_messageSign.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
            m_selectedObject = this.m_messageSign as FarmGameObject;
         }
         return super.onMouseMove(event);
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            if(this.m_message)
            {
               this.sendMessageSignTransaction();
            }
            else
            {
               this.displayMessageCenter();
            }
            Global.world.setDefaultGameMode();
         }
         return true;
      }
      
      private function sendMessageSignTransaction() : void
      {
         this.m_messageSign.setMessage(this.m_message.getMessage());
         if(Global.worldManager.isVisiting())
         {
            this.m_messageSign.hostId = Global.worldManager.getVisiting();
         }
         else
         {
            this.m_messageSign.hostId = Global.player.snUser.uid;
         }
         this.m_messageSign.timestamp = this.m_message.getTimestamp();
         this.m_messageSign.authorId = this.m_message.getAuthorId();
         FarmStatsManager.count(MessageSign.SIGNPOST_MESSAGE,"send","click_accept");
         TransactionManager.addTransaction(new TMessageSignPlace(this.m_messageSign,this.m_message));
         MessageManager.getInstance().onPlaceMessageSignDone();
      }
      
      private function displayMessageCenter() : void
      {
         var dialog:Dialog = null;
         if(Utilities.isFullScreen())
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","FullScreenTypingWarning"));
         }
         if(MessageManager.getInstance().canShowMessageCenter())
         {
            dialog = new MessageCenterDialog(this.m_messageSign);
         }
         else
         {
            dialog = new SendMessageDialog(this.m_messageSign);
         }
         UI.displayPopup(dialog,true);
      }
      
      override public function isFullscreenEnabled() : Boolean
      {
         return false;
      }
   }
}

