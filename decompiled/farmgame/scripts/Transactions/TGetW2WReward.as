package Transactions
{
   public class TGetW2WReward extends TFarmTransaction
   {
      
      private var m_featureName:String = "";
      
      private var m_feedName:String = "";
      
      private var m_hitUid:String;
      
      private var m_targetUid:String = "0";
      
      private var m_callback:Function = null;
      
      public function TGetW2WReward(featureName:String, feedName:String, hitUid:String, targetUid:String, callback:Function)
      {
         this.m_featureName = featureName;
         this.m_feedName = feedName;
         this.m_hitUid = hitUid;
         this.m_targetUid = targetUid;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("W2WFeatureService.onGetReward",this.m_featureName,this.m_feedName,this.m_hitUid.toString(),this.m_targetUid.toString());
      }
      
      override protected function onComplete(result:Object) : void
      {
         var timestamp:Number = NaN;
         if(result)
         {
            timestamp = Math.round(GlobalEngine.serverTime / 1000);
            Global.player.w2wState.setRecentlySent(this.m_featureName,this.m_feedName,this.m_hitUid,timestamp);
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

