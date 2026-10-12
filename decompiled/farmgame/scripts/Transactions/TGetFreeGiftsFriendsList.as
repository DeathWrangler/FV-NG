package Transactions
{
   public class TGetFreeGiftsFriendsList extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      public function TGetFreeGiftsFriendsList(callback:Function = null)
      {
         super();
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("FriendListService.getFriendsForR2FreeGiftsInterstitial");
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

