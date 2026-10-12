package Transactions
{
   import Engine.Transactions.Transaction;
   
   public class TransactionWithCallBack extends Transaction
   {
      
      private var m_action:String = "";
      
      private var m_params:Array;
      
      private var m_callback:Function = null;
      
      public function TransactionWithCallBack(action:String, callback:Function, ... params)
      {
         this.m_action = action;
         this.m_callback = callback;
         params.unshift(action);
         this.m_params = params;
         super();
      }
      
      override public function perform() : void
      {
         signedCall.apply(this,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

