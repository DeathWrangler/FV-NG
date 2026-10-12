package Transactions.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingSystem;
   import Managers.FeatureCraftingManager;
   import Transactions.TFarmTransaction;
   
   public class THarvestFeatureCraftingStation extends TFarmTransaction
   {
      
      private static const METHOD_COMPLETE_NOW:String = "completeNowStation";
      
      private static const METHOD_HARVEST:String = "harvestStation";
      
      private var m_method:String;
      
      private var m_craftingSystem:String;
      
      private var m_stationName:String;
      
      private var m_recipeName:String;
      
      private var m_hasAutoStart:Boolean;
      
      public function THarvestFeatureCraftingStation(craftingSystem:String, stationName:String, recipeName:String, hasAutoStart:Boolean, completeNow:Boolean = false)
      {
         this.m_craftingSystem = craftingSystem;
         this.m_stationName = stationName;
         this.m_recipeName = recipeName;
         this.m_method = completeNow ? METHOD_COMPLETE_NOW : METHOD_HARVEST;
         this.m_hasAutoStart = hasAutoStart;
         super();
      }
      
      override public function perform() : void
      {
         signedCall(FeatureCraftingManager.SERVICE_NAME + "." + this.m_method,this.m_craftingSystem,this.m_stationName);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = this.m_method;
         result.craftingSystem = this.m_craftingSystem;
         result.stationName = this.m_stationName;
         result.recipeName = this.m_recipeName;
         result.hasAutoStart = this.m_hasAutoStart;
         return result;
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         var system:FeatureCraftingSystem = FeatureCraftingManager.instance.getSystem(this.m_craftingSystem);
         if(Boolean(system) && Boolean(system.currentContentsWindow))
         {
            system.currentContentsWindow.close();
         }
         super.onFault(errorType,errorData);
      }
   }
}

