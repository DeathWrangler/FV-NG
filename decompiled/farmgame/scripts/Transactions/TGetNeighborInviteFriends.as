package Transactions
{
   public class TGetNeighborInviteFriends extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      public function TGetNeighborInviteFriends(callback:Function = null)
      {
         super();
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("FriendListService.getFriendsForR2InviteInterstitial");
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

