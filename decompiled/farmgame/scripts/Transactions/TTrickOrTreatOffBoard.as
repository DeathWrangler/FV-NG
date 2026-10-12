package Transactions
{
   public class TTrickOrTreatOffBoard extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      private var m_featureName:String;
      
      public function TTrickOrTreatOffBoard(featureName:String, callback:Function = null)
      {
         super();
         this.m_callback = callback;
         this.m_featureName = featureName;
      }
      
      override public function perform() : void
      {
         signedCall("TrickOrTreatService.performOffBoarding");
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

