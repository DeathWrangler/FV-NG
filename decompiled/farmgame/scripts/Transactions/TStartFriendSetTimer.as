package Transactions
{
   public class TStartFriendSetTimer extends TFarmTransaction
   {
      
      private var m_friendSetCode:String = "";
      
      public function TStartFriendSetTimer(friendSetCode:String)
      {
         super();
         this.m_friendSetCode = friendSetCode;
      }
      
      override public function perform() : void
      {
         signedCall("FriendSetService.startFriendSetTimer",this.m_friendSetCode);
      }
   }
}

