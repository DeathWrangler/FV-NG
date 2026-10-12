package Transactions
{
   public class TUserName extends TFarmTransaction
   {
      
      private var m_userName:String;
      
      public function TUserName(name:String)
      {
         super();
         this.m_userName = name;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setUserName",this.m_userName);
      }
   }
}

