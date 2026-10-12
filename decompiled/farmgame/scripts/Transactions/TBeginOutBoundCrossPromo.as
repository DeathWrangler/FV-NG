package Transactions
{
   import Managers.CrossPromoManager;
   
   public class TBeginOutBoundCrossPromo extends TFarmTransaction
   {
      
      protected var m_action:String = "";
      
      public function TBeginOutBoundCrossPromo(action:String)
      {
         this.m_action = action;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CrossPromoService.beginOutBoundCrossPromo",this.m_action);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(!(result is String) && Boolean(result.promoIds))
         {
            CrossPromoManager.getInstance().notifyCanDoOutBoundPromo(result.promoIds);
         }
      }
   }
}

