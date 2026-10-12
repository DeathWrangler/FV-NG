package Transactions
{
   import Classes.StorageBuilding;
   
   public class THarvestReadyNow extends TWorldState
   {
      
      public static const ACTION_HARVEST_READY_NOW:String = "HarvestReadyNow";
      
      private var m_callBack:Function = null;
      
      public function THarvestReadyNow(building:StorageBuilding, callback:Function = null)
      {
         this.m_callBack = callback;
         super(building);
      }
      
      override public function perform() : void
      {
         signedWorldAction("HarvestReadyNow");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var building:StorageBuilding = null;
         if(result)
         {
            super.onComplete(result);
            building = m_object as StorageBuilding;
            building.setFullGrown();
            if(this.m_callBack !== null)
            {
               this.m_callBack.call(null,result);
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         var storageBuilding:StorageBuilding = m_object as StorageBuilding;
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_HARVEST_READY_NOW;
         result.item = storageBuilding.getItem();
         return result;
      }
   }
}

