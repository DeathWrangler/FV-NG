package Transactions.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Classes.Quest.FarmQuestManager;
   import Engine.Events.TransactionEvent;
   import Managers.FeatureCraftingManager;
   import Transactions.TFarmTransaction;
   
   public class TFillFeatureCraftingOrder extends TFarmTransaction
   {
      
      private static const METHOD_COMPLETE_ORDER_NOW:String = "completeOrderNow";
      
      private static const METHOD_FILL_ORDER:String = "fillOrder";
      
      private var m_method:String;
      
      private var m_craftingSystem:String;
      
      private var m_npcName:String;
      
      private var m_orderId:int;
      
      private var m_rewardItemCodes:Array;
      
      public function TFillFeatureCraftingOrder(craftingSystem:String, npcName:String, orderId:int, completeNow:Boolean = false)
      {
         this.m_craftingSystem = craftingSystem;
         this.m_npcName = npcName;
         this.m_orderId = orderId;
         this.m_method = completeNow ? METHOD_COMPLETE_ORDER_NOW : METHOD_FILL_ORDER;
         super();
      }
      
      override public function perform() : void
      {
         signedCall(FeatureCraftingManager.SERVICE_NAME + "." + this.m_method,this.m_craftingSystem,this.m_npcName,this.m_orderId);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = this.m_method;
         result.craftingSystem = this.m_craftingSystem;
         result.npcName = this.m_npcName;
         result.orderId = this.m_orderId;
         result.ordersFilled = 1;
         result.rewardItemCodes = this.m_rewardItemCodes;
         return result;
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         var craftingSystem:FeatureCraftingSystem = FeatureCraftingManager.instance.getSystem(this.m_craftingSystem);
         if(craftingSystem)
         {
            craftingSystem.evaluateServerResponseForNewOrders(result);
         }
         if(result)
         {
            if(result.hasOwnProperty("rewardItemCodes"))
            {
               this.m_rewardItemCodes = result.rewardItemCodes as Array;
               FarmQuestManager.getInstance().processTransactionOnServerComplete(new TransactionEvent(TransactionEvent.COMPLETED,this));
            }
         }
      }
   }
}

