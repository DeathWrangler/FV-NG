package Transactions
{
   public class TActionCount extends TFarmTransaction
   {
      
      private var m_flagName:String;
      
      public function TActionCount(flagName:String)
      {
         super();
         this.m_flagName = flagName;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.incrementActionCount",this.m_flagName);
      }
   }
}

