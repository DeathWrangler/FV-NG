package Transactions.FarmVillage
{
   import Managers.FarmVillageFactoriesManager;
   import Transactions.TFarmTransaction;
   
   public class THarvestFarmvillageFactory extends TFarmTransaction
   {
      
      private var m_factoryName:String = "";
      
      public function THarvestFarmvillageFactory(factoryName:String)
      {
         super();
         this.m_factoryName = factoryName;
      }
      
      override public function perform() : void
      {
         signedCall(FarmVillageFactoriesManager.FACTORY_SERVICE + "." + FarmVillageFactoriesManager.FACTORY_HARVEST_FUNCTION,this.m_factoryName);
      }
      
      override public function getTransactionData() : Object
      {
         var itemCode:String = Global.farmGameSettingsManager.getFarmItemCodeByName(this.m_factoryName);
         var result:Object = new Object();
         result.method = FarmVillageFactoriesManager.FACTORY_HARVEST_FUNCTION;
         result.action = "harvest";
         result.item = this.m_factoryName;
         result.itemCode = itemCode;
         return result;
      }
   }
}

