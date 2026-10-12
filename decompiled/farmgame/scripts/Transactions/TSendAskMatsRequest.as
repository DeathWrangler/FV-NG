package Transactions
{
   public class TSendAskMatsRequest extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      private var m_itemName:String;
      
      private var m_featureName:String;
      
      private var m_requestIds:Array;
      
      private var m_source:String;
      
      private var m_expansion:String;
      
      private var m_view:String;
      
      private var m_serverTime:int = 0;
      
      public function TSendAskMatsRequest(itemName:String, featureName:String, requestIds:Array, source:String, expansion:String, view:String, serverTime:int = 0, callback:Function = null)
      {
         super();
         this.m_itemName = itemName;
         this.m_featureName = featureName;
         this.m_requestIds = requestIds;
         this.m_callback = callback;
         this.m_expansion = expansion;
         this.m_view = view;
         this.m_serverTime = serverTime;
         this.m_source = source;
      }
      
      override public function perform() : void
      {
         signedCall("FBRequestService.sendAskMatsRequest",this.m_itemName,this.m_featureName,this.m_requestIds,this.m_source,this.m_expansion,this.m_view,this.m_serverTime);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

