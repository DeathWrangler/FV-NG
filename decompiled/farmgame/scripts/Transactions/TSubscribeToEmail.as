package Transactions
{
   public class TSubscribeToEmail extends TFarmTransaction
   {
      
      private var m_emailChannel:String;
      
      public function TSubscribeToEmail(emailChannel:String)
      {
         super();
         this.m_emailChannel = emailChannel;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.subscribeToEmail",this.m_emailChannel);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result == "success")
         {
            GlobalEngine.log("TSubscribeToEmail",this.m_emailChannel + " -- Subscribe successful");
         }
         else
         {
            GlobalEngine.log("TSubscribeToEmail",this.m_emailChannel + " -- Subscribe failed. User does not have email perms.");
         }
      }
   }
}

