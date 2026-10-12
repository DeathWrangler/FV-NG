package Transactions
{
   public class TSetFriendSetProgress extends TFarmTransaction
   {
      
      protected var m_friendSetCode:String = "";
      
      protected var m_gameId:Number = 0;
      
      protected var m_callback:Function = null;
      
      public function TSetFriendSetProgress(friendSetCode:String, gameId:Number, callback:Function = null)
      {
         this.m_friendSetCode = friendSetCode;
         this.m_gameId = gameId;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ItemFriendSetService.setFriendSetProgress",this.m_friendSetCode,this.m_gameId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result.data)
         {
            if(this.m_callback != null)
            {
               this.m_callback(result.data);
            }
         }
      }
   }
}

