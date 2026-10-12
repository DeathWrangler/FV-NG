package Transactions
{
   import Classes.Idle.PromoIdleTask;
   import Events.CloseEvent;
   
   public class TPromotion extends TFarmTransaction
   {
      
      protected var m_accepted:Boolean = false;
      
      public function TPromotion(accepted:Boolean = false)
      {
         super();
         this.m_accepted = accepted;
      }
      
      override public function perform() : void
      {
         signedCall("PromoService.setShownPromotionPrompt",PromoIdleTask.activePromoSettings.@promoName.toString(),this.m_accepted);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_accepted)
         {
            PromoIdleTask.navigateToMoneyPage();
         }
         PromoIdleTask.shouldShow = false;
      }
      
      protected function onClose(event:CloseEvent) : void
      {
      }
   }
}

