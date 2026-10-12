package Transactions.BreedingProjects
{
   public class TPurchaseDragonBreedingLevel extends TPurchaseBreedingLevel
   {
      
      public function TPurchaseDragonBreedingLevel(featureName:String, targetLevel:int)
      {
         super(featureName,targetLevel);
      }
      
      override public function perform() : void
      {
         signedCall("DragonBreedingService.onPurchaseBreedingLevel",m_featureName,m_targetLevel);
      }
   }
}

