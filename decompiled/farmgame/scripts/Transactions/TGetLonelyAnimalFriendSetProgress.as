package Transactions
{
   public class TGetLonelyAnimalFriendSetProgress extends TFarmTransaction
   {
      
      protected var m_friendSetCode:String = "";
      
      protected var m_friendSetWorldCode:String = "";
      
      protected var m_callback:Function = null;
      
      public function TGetLonelyAnimalFriendSetProgress(friendSetCode:String, callback:Function = null, friendSetWorldCode:String = "")
      {
         this.m_friendSetCode = friendSetCode;
         this.m_callback = callback;
         this.m_friendSetWorldCode = friendSetWorldCode;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("LonelyAnimalFriendSetService.getLonelyAnimalFriendSetProgress",this.m_friendSetCode,this.m_friendSetWorldCode);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result)
         {
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

