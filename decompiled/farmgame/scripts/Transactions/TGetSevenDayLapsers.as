package Transactions
{
   public class TGetSevenDayLapsers extends TGetRecentlyPlayedFriends
   {
      
      public function TGetSevenDayLapsers(limitFriends:Boolean, callback:Function = null)
      {
         super(limitFriends,callback);
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getSevenDayLapsedFriendsForGifts");
      }
   }
}

