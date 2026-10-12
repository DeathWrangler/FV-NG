package Transactions
{
   public class TSendUserEnvReport extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_reportData:Object = null;
      
      public function TSendUserEnvReport(reportData:Object, callback:Function = null)
      {
         this.m_callback = callback;
         this.m_reportData = reportData;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("JsBusterService.sendUserEnvReport",this.m_reportData);
      }
   }
}

