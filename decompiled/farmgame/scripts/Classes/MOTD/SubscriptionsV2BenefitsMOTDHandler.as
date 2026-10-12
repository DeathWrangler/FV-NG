package Classes.MOTD
{
   import Events.SubscriptionsEvent;
   import Managers.SubscriptionsManager;
   
   public class SubscriptionsV2BenefitsMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function SubscriptionsV2BenefitsMOTDHandler(currentMotd:Object)
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
         SubscriptionsManager.instance.dispatchEvent(new SubscriptionsEvent(SubscriptionsManager.SHOW_BENEFITS_POPUP,{"source":"motd"}));
      }
   }
}

