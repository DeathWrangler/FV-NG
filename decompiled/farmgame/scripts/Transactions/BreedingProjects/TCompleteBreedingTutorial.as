package Transactions.BreedingProjects
{
   import Classes.storage.StorageItem;
   import Transactions.TFarmTransaction;
   
   public class TCompleteBreedingTutorial extends TFarmTransaction
   {
      
      protected var m_projectName:String = "";
      
      public function TCompleteBreedingTutorial(breedingProject:String)
      {
         this.m_projectName = breedingProject;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("BreedingService.completeTutorialForProject",this.m_projectName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var storedSeed:StorageItem = null;
         if(result != null)
         {
            storedSeed = StorageItem.getStorageItem(result.reward,[result.amount]);
            if(storedSeed)
            {
               Global.player.addSeedItem(storedSeed);
            }
         }
      }
   }
}

