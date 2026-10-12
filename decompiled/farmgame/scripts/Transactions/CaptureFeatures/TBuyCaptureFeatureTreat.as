package Transactions.CaptureFeatures
{
   import Engine.Transactions.Transaction;
   import Managers.CaptureFeatureManager;
   
   public class TBuyCaptureFeatureTreat extends Transaction
   {
      
      private var m_callback:Function = null;
      
      private var m_featureName:String = null;
      
      public function TBuyCaptureFeatureTreat(featureName:String, callback:Function = null)
      {
         super();
         this.m_callback = callback;
         this.m_featureName = featureName;
      }
      
      override public function perform() : void
      {
         signedCall("CaptureFeatureService.onPurchaseTreat",this.m_featureName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(result.hasOwnProperty("featureData"))
         {
            CaptureFeatureManager.instance.setFeatureData(this.m_featureName,result["featureData"]);
         }
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

