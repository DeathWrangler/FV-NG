package Transactions.CaptureFeatures
{
   import Engine.Transactions.Transaction;
   import Managers.CaptureFeatureManager;
   
   public class TCapturedFeature extends Transaction
   {
      
      protected var m_itemName:String = null;
      
      protected var m_options:Object = null;
      
      protected var m_featureName:String = null;
      
      protected var m_serviceFunction:String = null;
      
      public function TCapturedFeature(featureName:String, serviceFunction:String, itemName:String, options:Object = null)
      {
         super();
         this.m_itemName = itemName;
         this.m_options = options;
         this.m_serviceFunction = serviceFunction;
         this.m_featureName = featureName;
      }
      
      override public function perform() : void
      {
         signedCall("CaptureFeatureService." + this.m_serviceFunction,this.m_featureName,this.m_itemName,this.m_options);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.hasOwnProperty("featureData"))
         {
            CaptureFeatureManager.instance.setFeatureData(this.m_featureName,result.featureData);
         }
      }
   }
}

