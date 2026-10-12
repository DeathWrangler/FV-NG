package Transactions
{
   public class TTrickOrTreatRedeemReward extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_featureName:String;
      
      public function TTrickOrTreatRedeemReward(featureName:String, callback:Function = null)
      {
         super();
         this.m_featureName = featureName;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("TrickOrTreatService.redeemReward");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

