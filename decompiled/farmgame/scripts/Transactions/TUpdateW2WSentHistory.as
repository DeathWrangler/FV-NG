package Transactions
{
   public class TUpdateW2WSentHistory extends TFarmTransaction
   {
      
      private var m_featureName:String = "";
      
      private var m_feedName:String = "";
      
      private var m_targetUid:String = "0";
      
      private var m_callback:Function = null;
      
      public function TUpdateW2WSentHistory(featureName:String, feedName:String, targetUid:String)
      {
         this.m_featureName = featureName;
         this.m_feedName = feedName;
         this.m_targetUid = targetUid;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("W2WFeatureService.updateSentHistory",this.m_featureName,this.m_feedName,this.m_targetUid.toString());
      }
      
      override protected function onComplete(result:Object) : void
      {
      }
   }
}

