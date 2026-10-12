package Transactions
{
   import Classes.MystreeSapling;
   import Classes.Quest.FarmQuestManager;
   import Engine.Events.TransactionEvent;
   
   public class TMystreeTransform extends TWorldState
   {
      
      private static const ACTION_TRANSFORM:String = "transform";
      
      private var m_onCompleteCallBack:Function;
      
      private var m_plotId:String;
      
      public function TMystreeTransform(resource:MystreeSapling, plotId:String, onCompleteCallBack:Function = null)
      {
         super(resource);
         this.m_onCompleteCallBack = onCompleteCallBack;
         this.m_plotId = plotId;
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
         signedWorldAction(ACTION_TRANSFORM,{"plotId":this.m_plotId});
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_TRANSFORM;
         result.featureName = "mystree_v1";
         return result;
      }
   }
}

