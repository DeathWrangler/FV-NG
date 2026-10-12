package Transactions
{
   import Engine.Transactions.Transaction;
   
   public class THolidayCountdownSeenWhatIsThis extends Transaction
   {
      
      protected var m_count:int;
      
      public function THolidayCountdownSeenWhatIsThis(count:int)
      {
         this.m_count = count;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("HolidayCountdownService.setSeenWhatIsThis",this.m_count);
      }
   }
}

