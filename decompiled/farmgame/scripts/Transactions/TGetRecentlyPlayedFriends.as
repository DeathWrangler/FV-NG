package Transactions
{
   public class TGetRecentlyPlayedFriends extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      private var m_limitFriends:Boolean;
      
      public function TGetRecentlyPlayedFriends(limitFriends:Boolean, callback:Function = null)
      {
         super();
         this.m_callback = callback;
         this.m_limitFriends = limitFriends;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getRecentlyPlayedFriendsForGifts",this.m_limitFriends);
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

