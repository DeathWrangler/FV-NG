package Transactions
{
   public class TPerformNPCAction extends TFarmTransaction
   {
      
      private var m_npc:int;
      
      private var m_aid:int;
      
      private var m_callback:Function;
      
      public function TPerformNPCAction(npcid:int, aid:int, callback:Function = null)
      {
         this.m_npc = npcid;
         this.m_aid = aid;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("NPCService.performNPCAction",this.m_npc,this.m_aid);
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

