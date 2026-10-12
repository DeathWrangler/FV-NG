package Transactions.BreedingProjects
{
   import Transactions.TFarmTransaction;
   
   public class TPurchaseBreedingLevel extends TFarmTransaction
   {
      
      protected var m_targetLevel:int = 0;
      
      protected var m_featureName:String = "";
      
      public function TPurchaseBreedingLevel(featureName:String, targetLevel:int)
      {
         super();
         this.m_featureName = featureName;
         this.m_targetLevel = targetLevel;
      }
      
      override public function perform() : void
      {
         signedCall("AnimalBreedingService.onPurchaseBreedingLevel",this.m_featureName,this.m_targetLevel);
      }
   }
}

