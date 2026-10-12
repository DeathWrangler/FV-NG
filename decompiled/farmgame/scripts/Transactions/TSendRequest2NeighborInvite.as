package Transactions
{
   public class TSendRequest2NeighborInvite extends TFarmTransaction
   {
      
      private var m_requestIds:Array = null;
      
      private var m_timeStamp:int = 0;
      
      private var m_source:String = null;
      
      private var m_ref:String = null;
      
      private var m_callback:Function = null;
      
      public function TSendRequest2NeighborInvite(requestIds:Array, timeStamp:int, source:String, ref:String = "", callback:Function = null)
      {
         super();
         this.m_requestIds = requestIds;
         this.m_timeStamp = timeStamp;
         this.m_source = source;
         this.m_ref = ref;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("FBRequestService.sendInviteRequest",this.m_requestIds,this.m_timeStamp,this.m_source,this.m_ref);
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

