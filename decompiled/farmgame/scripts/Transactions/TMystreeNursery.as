package Transactions
{
   import Classes.MystreeNursery;
   
   public class TMystreeNursery extends TWorldState
   {
      
      private var m_actionName:String;
      
      private var m_callback:Function;
      
      private var m_params:Object;
      
      public function TMystreeNursery(nursery:MystreeNursery, actionName:String, callback:Function = null, params:Object = null)
      {
         super(nursery);
         this.m_actionName = actionName;
         this.m_callback = callback;
         this.m_params = params == null ? {} : params;
      }
      
      override public function perform() : void
      {
         signedWorldAction(this.m_actionName,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.tendSapling = 0;
         result.action = this.m_actionName;
         if(this.m_actionName == "tendSapling")
         {
            result.tendSapling = 1;
            result.method = TWorldState.METHOD_PERFORM_ACTION;
         }
         return result;
      }
   }
}

