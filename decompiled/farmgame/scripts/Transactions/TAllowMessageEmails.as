package Transactions
{
   public class TAllowMessageEmails extends TFarmTransaction
   {
      
      private var m_isAllow:Boolean;
      
      public function TAllowMessageEmails(isAllow:Boolean)
      {
         super();
         this.m_isAllow = isAllow;
      }
      
      override public function perform() : void
      {
         signedCall("MessageService.setAllowEmail",this.m_isAllow);
      }
   }
}

