package Transactions
{
   import Classes.Growable.*;
   
   public class TGrowableUseConsumable extends TFarmTransaction
   {
      
      private var m_callback:Function = null;
      
      private var m_resource:GrowableResourceDelegate = null;
      
      private var m_numConsumablesUsed:int = 0;
      
      private var m_buyConsumables:Boolean = false;
      
      private var m_methodName:String = null;
      
      public function TGrowableUseConsumable(resource:GrowableResourceDelegate, numConsumablesUsed:int = 1, callback:Function = null, buyConsumables:Boolean = false)
      {
         super();
         this.m_callback = callback;
         this.m_resource = resource;
         this.m_numConsumablesUsed = numConsumablesUsed;
         this.m_buyConsumables = buyConsumables;
         this.m_methodName = this.m_buyConsumables ? "buyAndUseConsumbale" : "useConsumable";
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = {"method":this.m_methodName};
         result[GrowableConstants.QUEST_FIELD_CONSUMABLE_CODE] = this.m_resource.consumableItemCode;
         result[GrowableConstants.QUEST_FIELD_CONSUMABLE_COUNT] = this.m_numConsumablesUsed;
         return result;
      }
      
      override public function perform() : void
      {
         signedCall("GrowableService." + this.m_methodName,this.m_resource.storageId,this.m_numConsumablesUsed);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         this.m_resource.refreshVisibleToActual(result.stage);
         if(this.m_callback != null)
         {
            this.m_callback(result);
         }
      }
   }
}

