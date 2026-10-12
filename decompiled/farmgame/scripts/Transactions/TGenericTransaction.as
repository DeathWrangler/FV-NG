package Transactions
{
   public class TGenericTransaction extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      private var m_serviceName:String;
      
      private var m_serviceFunctionName:String;
      
      private var m_params:Array;
      
      public function TGenericTransaction(serviceName:String, serviceFunctionName:String, callback:Function = null, parameters:Array = null)
      {
         this.m_callback = callback;
         this.m_serviceName = serviceName;
         this.m_serviceFunctionName = serviceFunctionName;
         this.m_params = parameters == null ? [] : parameters;
         super();
      }
      
      override public function perform() : void
      {
         var passedUpParams:Array = this.m_params;
         passedUpParams.unshift(this.m_serviceName + "." + this.m_serviceFunctionName);
         signedCall.apply(this,passedUpParams);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
         super.onComplete(result);
      }
      
      override public function getTransactionData() : Object
      {
         return {
            "params":this.m_params,
            "method":this.m_serviceFunctionName
         };
      }
   }
}

