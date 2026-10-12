package Transactions
{
   public class TGetEligibleW2WRecipients extends TFarmTransaction
   {
      
      protected var m_featureName:String;
      
      protected var m_feedName:String;
      
      protected var m_onComplete:Function;
      
      public function TGetEligibleW2WRecipients(featureName:String, feedName:String, onComplete:Function = null)
      {
         super();
         this.m_featureName = featureName;
         this.m_feedName = feedName;
         this.m_onComplete = onComplete;
      }
      
      override public function perform() : void
      {
         signedCall("W2WFeatureService.onGetEligibleW2WRecipients",this.m_featureName,this.m_feedName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var friendObjects:Array = null;
         if(this.m_onComplete != null)
         {
            if(result.hasOwnProperty("eligibleIds") && result.hasOwnProperty("rewardLinks") && this.m_onComplete != null)
            {
               friendObjects = Global.friendManager.getFriendObjects(result.eligibleIds);
               this.m_onComplete(friendObjects,result.rewardLinks);
            }
         }
      }
   }
}

