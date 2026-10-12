package Transactions
{
   public class TGetSendFlashGiftFriends extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      private var m_requestItemName:String;
      
      private var m_specs:Array;
      
      public function TGetSendFlashGiftFriends(requestItemName:String, specs:Array, callback:Function = null)
      {
         super();
         this.m_requestItemName = requestItemName;
         this.m_specs = specs;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getSendFlashGiftFriends",this.m_requestItemName,this.m_specs);
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

