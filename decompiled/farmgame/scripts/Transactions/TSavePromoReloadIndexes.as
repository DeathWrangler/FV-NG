package Transactions
{
   public class TSavePromoReloadIndexes extends TFarmTransaction
   {
      
      private var m_promoIndexes:Array;
      
      public function TSavePromoReloadIndexes(promoIndexes:Array)
      {
         super();
         this.m_promoIndexes = promoIndexes;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.savePromoReloadIndexes",this.m_promoIndexes);
      }
   }
}

