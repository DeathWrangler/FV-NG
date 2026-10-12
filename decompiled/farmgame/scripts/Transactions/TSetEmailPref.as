package Transactions
{
   public class TSetEmailPref extends TFarmTransaction
   {
      
      private var m_permission:String;
      
      private var m_email:String;
      
      public function TSetEmailPref(email:String, permission:String)
      {
         super();
         this.m_email = email;
         this.m_permission = permission;
      }
      
      override public function perform() : void
      {
         signedCall("ZAPIClientService.setEmailPref",this.m_email,this.m_permission);
      }
   }
}

