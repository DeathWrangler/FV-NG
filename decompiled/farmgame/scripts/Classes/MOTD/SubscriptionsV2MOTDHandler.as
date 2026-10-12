package Classes.MOTD
{
   import Events.SubscriptionsEvent;
   import Managers.SubscriptionsManager;
   
   public class SubscriptionsV2MOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function SubscriptionsV2MOTDHandler(currentMotd:Object)
      {
         super(currentMotd);
      }
      
      override public function execute() : void
      {
         this.acceptMOTD();
         m_isFinished = true;
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_SIGNUP_POPUP,{"source":"motd"}));
      }
   }
}

