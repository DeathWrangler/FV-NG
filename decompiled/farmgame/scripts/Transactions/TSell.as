package Transactions
{
   import Classes.FarmGameObject;
   import Managers.UGCDecoManager;
   
   public class TSell extends TWorldState
   {
      
      public function TSell(object:FarmGameObject)
      {
         super(object);
      }
      
      override public function perform() : void
      {
         signedWorldAction("sell");
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(result.hasOwnProperty("ugcdeco"))
         {
            if(result["ugcdeco"].hasOwnProperty(UGCDecoManager.UGC_MATERIALS_INDEX))
            {
               UGCDecoManager.instance.setFeatureData(result.ugcdeco);
            }
         }
      }
   }
}

