package Transactions
{
   import Classes.Animal;
   
   public class TAnimalTransform extends TWorldState
   {
      
      public static const ACTION_TRANSFORM:String = "transform";
      
      private var m_onCompleteCallBack:Function;
      
      private var m_animal:Animal;
      
      public function TAnimalTransform(resource:Animal, onCompleteCallBack:Function = null)
      {
         super(resource);
         this.m_animal = resource;
         this.m_onCompleteCallBack = onCompleteCallBack;
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_onCompleteCallBack !== null)
         {
            this.m_onCompleteCallBack.call(null,result);
         }
      }
      
      override public function perform() : void
      {
         signedWorldAction("transform");
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = {};
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_TRANSFORM;
         result.item = this.m_animal.getItem();
         return result;
      }
   }
}

