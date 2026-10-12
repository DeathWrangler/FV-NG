package Transactions
{
   public class TSetFeatureFrequencyTimestamp extends TFarmTransaction
   {
      
      protected var m_featureName:String;
      
      public function TSetFeatureFrequencyTimestamp(featureName:String)
      {
         super();
         this.m_featureName = featureName;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.updateFeatureFrequencyTimestamp",this.m_featureName);
      }
   }
}

