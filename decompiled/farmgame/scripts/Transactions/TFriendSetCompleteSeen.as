package Transactions
{
   public class TFriendSetCompleteSeen extends TFarmTransaction
   {
      
      public static const METHOD_FRIEND_SET_COMPLETE_SEEN:String = "friendSetCompleteSeen";
      
      private var m_friendSetCode:String = "";
      
      private var m_remove:Boolean;
      
      public function TFriendSetCompleteSeen(friendSetCode:String, remove:Boolean = false)
      {
         super();
         this.m_friendSetCode = friendSetCode;
         this.m_remove = remove;
      }
      
      override public function perform() : void
      {
         signedCall("FriendSetService." + METHOD_FRIEND_SET_COMPLETE_SEEN,this.m_friendSetCode,this.m_remove);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_FRIEND_SET_COMPLETE_SEEN;
         result.friendSetCode = this.m_friendSetCode;
         result.remove = this.m_remove;
         return result;
      }
   }
}

