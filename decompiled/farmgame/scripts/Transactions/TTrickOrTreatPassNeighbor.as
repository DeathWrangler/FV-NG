package Transactions
{
   public class TTrickOrTreatPassNeighbor extends TFarmTransaction
   {
      
      private var m_neighborUid:String;
      
      private var m_callback:Function;
      
      private var m_featureName:String;
      
      public function TTrickOrTreatPassNeighbor(featureName:String, neighborUid:String, callback:Function = null)
      {
         super();
         this.m_callback = callback;
         this.m_neighborUid = neighborUid;
         this.m_featureName = featureName;
      }
      
      override public function perform() : void
      {
         signedCall("TrickOrTreatService.passNeighbor");
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

