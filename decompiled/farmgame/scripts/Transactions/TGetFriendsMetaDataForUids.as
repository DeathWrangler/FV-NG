package Transactions
{
   public class TGetFriendsMetaDataForUids extends TFarmTransaction
   {
      
      private var m_uids:Array;
      
      private var m_callback:Function;
      
      public function TGetFriendsMetaDataForUids(uids:Array, callback:Function = null)
      {
         super();
         this.m_uids = uids;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("FriendService.getFriendsMetaDataForUids",this.m_uids);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != this.m_callback)
         {
            this.m_callback(result);
         }
      }
   }
}

