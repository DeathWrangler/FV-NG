package Engine.Transactions
{
   public class TSendZaspReport extends Transaction
   {
      
      private var m_reports:Array = null;
      
      public function TSendZaspReport(param1:Array)
      {
         super();
         if(param1 != null)
         {
            this.m_reports = param1;
         }
         if(this.m_reports == null || this.m_reports.length <= 0)
         {
            canPerform = false;
         }
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.sendZaspReport",this.m_reports);
      }
      
      override public function isFaultable() : Boolean
      {
         return false;
      }
   }
}

