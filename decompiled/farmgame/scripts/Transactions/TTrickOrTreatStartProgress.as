package Transactions
{
   public class TTrickOrTreatStartProgress extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      private var m_featureName:String;
      
      public function TTrickOrTreatStartProgress(featureName:String, callback:Function)
      {
         super();
         this.m_featureName = featureName;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("TrickOrTreatService.startProgress");
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

