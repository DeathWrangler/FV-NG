package Transactions
{
   public class TGetSendFreeGiftsFriendsList extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_friendSpec:Array = null;
      
      public function TGetSendFreeGiftsFriendsList(friendSpec:Array, callback:Function = null)
      {
         super();
         this.m_callback = callback;
         this.m_friendSpec = friendSpec;
      }
      
      override public function perform() : void
      {
         signedCall("FriendListService.getFriendsForR2FreeGifts",this.m_friendSpec);
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

