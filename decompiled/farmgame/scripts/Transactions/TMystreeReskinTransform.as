package Transactions
{
   import Classes.MystreeReskinSapling;
   import Classes.Quest.FarmQuestManager;
   import Engine.Events.TransactionEvent;
   
   public class TMystreeReskinTransform extends TWorldState
   {
      
      private static const ACTION_TRANSFORM:String = "transform";
      
      private var m_onCompleteCallBack:Function;
      
      private var m_plotId:String;
      
      public var m_featureName:String;
      
      public function TMystreeReskinTransform(resource:MystreeReskinSapling, plotId:String, featureName:String = null, onCompleteCallBack:Function = null)
      {
         super(resource);
         this.m_onCompleteCallBack = onCompleteCallBack;
         this.m_plotId = plotId;
         this.m_featureName = featureName;
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_onCompleteCallBack !== null)
         {
            this.m_onCompleteCallBack.call(null,result);
         }
         FarmQuestManager.getInstance().processTransactionOnServerComplete(new TransactionEvent(TransactionEvent.COMPLETED,this));
      }
      
      override public function perform() : void
      {
         signedWorldAction(ACTION_TRANSFORM,{
            "plotId":this.m_plotId,
            "featureName":this.m_featureName
         });
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_TRANSFORM;
         result.featureName = this.m_featureName;
         return result;
      }
   }
}

