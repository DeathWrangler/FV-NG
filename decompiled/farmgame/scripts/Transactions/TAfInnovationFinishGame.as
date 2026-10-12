package Transactions
{
   public class TAfInnovationFinishGame extends TGenericTransaction
   {
      
      private var m_serviceFunctionName:String = null;
      
      public function TAfInnovationFinishGame(serviceName:String, serviceFunctionName:String, callback:Function = null, parameters:Array = null)
      {
         this.m_serviceFunctionName = serviceFunctionName;
         super(serviceName,serviceFunctionName,callback,parameters);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = this.m_serviceFunctionName;
         return result;
      }
   }
}

