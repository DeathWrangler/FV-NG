package Transactions
{
   import Engine.Transactions.TPublishUserAction;
   
   public class TCreateAndPublishW2W extends TPublishUserAction
   {
      
      private var m_featureName:String = "";
      
      private var m_feedName:String = "";
      
      public function TCreateAndPublishW2W(action:String, bundleData:Object, targetId:String, featureName:String, feedName:String, closeCallback:Function = null, feedTimeout:int = 0, askPermissions:Boolean = false, autoPublish:Boolean = false, userMessage:String = "")
      {
         this.m_featureName = featureName;
         this.m_feedName = feedName;
         var timestamp:Number = Math.round(GlobalEngine.serverTime / 1000);
         Global.player.w2wState.setRecentlySent(this.m_featureName,this.m_feedName,targetId,timestamp);
         super(action,bundleData,[targetId.toString()],false,closeCallback,feedTimeout,askPermissions,autoPublish,userMessage);
      }
      
      override public function perform() : void
      {
         signedCall("W2WFeatureService.onGetAndPublishReward",m_action,m_bundleData,m_strTargetIds[0],this.m_featureName,this.m_feedName);
      }
   }
}

