package Transactions
{
   import Engine.Transactions.Transaction;
   
   public class TIrrigationAction extends Transaction
   {
      
      private static const SERVICE_CALL:String = "IrrigationService.onIrrigationAction";
      
      private var m_action:String;
      
      private var m_actionItems:Array;
      
      private var m_params:Array;
      
      private var m_callback:Function;
      
      public function TIrrigationAction(action:String, actionItems:Array, callback:Function, ... rest)
      {
         super();
         this.m_action = action;
         this.m_actionItems = actionItems;
         this.m_callback = callback;
         this.m_params = rest;
      }
      
      override public function perform() : void
      {
         signedCall(SERVICE_CALL,this.m_action,this.m_actionItems,this.m_params);
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

