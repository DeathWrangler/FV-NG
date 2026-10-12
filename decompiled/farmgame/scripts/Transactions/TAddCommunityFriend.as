package Transactions
{
   public class TAddCommunityFriend extends TFarmTransaction
   {
      
      private var m_communityFriendUid:String;
      
      private var m_callback:Function;
      
      public function TAddCommunityFriend(communityFriendUid:String, callback:Function = null)
      {
         super();
         this.m_communityFriendUid = communityFriendUid;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("CommunityService.addCommunityFriend",this.m_communityFriendUid);
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

