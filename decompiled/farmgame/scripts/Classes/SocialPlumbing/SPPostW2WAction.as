package Classes.SocialPlumbing
{
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Events.SocialPlumbingEvent;
   import Transactions.TFarmTransaction;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   
   public class SPPostW2WAction extends SocialPlumbingAction
   {
      
      protected var m_transaction:TFarmTransaction = null;
      
      public function SPPostW2WAction(data:Object)
      {
         super(data);
         m_acceptButtonText = ZLocUtils.t("Dialogs","Post");
      }
      
      override public function takeAction() : void
      {
         if(this.m_transaction != null)
         {
            this.m_transaction.addEventListener(Event.COMPLETE,this.onTransactionComplete);
            this.m_transaction.addEventListener(Event.CLOSE,this.onTransactionClose);
            TransactionManager.addTransaction(this.m_transaction);
         }
      }
      
      protected function postFeed() : void
      {
         if(ExternalInterface.available == true)
         {
            ExternalInterface.addCallback("alertSocialPlumbingAction",this.onCloseFeedDialog);
         }
      }
      
      protected function onTransactionClose(event:Event) : void
      {
         event.target.removeEventListener(Event.CLOSE,this.onTransactionClose);
         event.target.removeEventListener(Event.COMPLETE,this.onTransactionComplete);
         this.onCloseFeedDialog("skipped");
      }
      
      protected function onTransactionComplete(event:Event) : void
      {
         event.target.removeEventListener(Event.CLOSE,this.onTransactionClose);
         event.target.removeEventListener(Event.COMPLETE,this.onTransactionComplete);
      }
      
      public function onCloseFeedDialog(feedback:Object = null, isException:Boolean = false) : void
      {
         var feedbackStr:String = null;
         var event:SocialPlumbingEvent = null;
         if(feedback != null && feedback is String)
         {
            feedbackStr = feedback as String;
            if(isException == false)
            {
               event = null;
               switch(feedbackStr)
               {
                  case "posted":
                     event = new SocialPlumbingEvent(SocialPlumbingEvent.FEED_ACCEPT);
                     break;
                  case "closed":
                     event = new SocialPlumbingEvent(SocialPlumbingEvent.FEED_CLOSED);
                     break;
                  case "skipped":
                     event = new SocialPlumbingEvent(SocialPlumbingEvent.FEED_SKIPPED);
               }
               if(event)
               {
                  dispatchEvent(event);
               }
            }
         }
      }
   }
}

