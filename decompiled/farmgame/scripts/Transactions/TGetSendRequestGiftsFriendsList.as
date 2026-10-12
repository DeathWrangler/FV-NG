package Transactions
{
   import Classes.Constants.MFSConstants;
   
   public class TGetSendRequestGiftsFriendsList extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_friendSpec:Array = null;
      
      private var m_requestItemName:String;
      
      public function TGetSendRequestGiftsFriendsList(friendSpec:Array, requestItemName:String, callback:Function = null)
      {
         super();
         this.m_callback = callback;
         this.m_friendSpec = friendSpec;
         this.m_requestItemName = requestItemName;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getAskItemFriends",MFSConstants.FB_REQ2_REQUESTTYPE_ASKITEMS,"",this.m_requestItemName,this.m_friendSpec);
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

