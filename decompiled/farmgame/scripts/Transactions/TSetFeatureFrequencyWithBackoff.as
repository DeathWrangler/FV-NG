package Transactions
{
   public class TSetFeatureFrequencyWithBackoff extends TSetFeatureFrequencyTimestamp
   {
      
      public static const FF_BACKOFF_POSTFIX:String = "_backoff";
      
      public static const FF_BACKOFF_INCREMENT_VARIABLE_POSTFIX:String = "_backoff_days";
      
      public static const FF_BACKOFF_BASE_POSTFIX:String = "_backoff_base";
      
      private static const DEFAULT_MAX_BACKOFF_INCREMENTS:int = 3;
      
      private var m_maxBackoffIncrements:int;
      
      public function TSetFeatureFrequencyWithBackoff(featureName:String, maxBackoffIncrements:int = 3)
      {
         super(featureName);
         this.m_maxBackoffIncrements = maxBackoffIncrements;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.updateFeatureFrequencyWithBackoff",m_featureName,this.m_maxBackoffIncrements);
      }
   }
}

