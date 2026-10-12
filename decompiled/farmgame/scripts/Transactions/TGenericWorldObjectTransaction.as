package Transactions
{
   import Engine.Classes.WorldObject;
   
   public class TGenericWorldObjectTransaction extends TWorldState
   {
      
      private var m_action:String = "";
      
      private var m_callback:Function = null;
      
      private var m_params:Array;
      
      public function TGenericWorldObjectTransaction(worldObj:WorldObject, action:String, callback:Function = null, params:Array = null)
      {
         this.m_action = action;
         this.m_callback = callback;
         this.m_params = params == null ? [] : params;
         super(worldObj);
      }
      
      override public function perform() : void
      {
         this.m_params.unshift(this.m_action);
         signedWorldAction.apply(this,this.m_params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

