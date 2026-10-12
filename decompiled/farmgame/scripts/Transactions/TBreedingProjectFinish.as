package Transactions
{
   import Managers.BreedingManager;
   
   public class TBreedingProjectFinish extends TFarmTransaction
   {
      
      protected var m_featureName:String;
      
      protected var m_trayIndex:int;
      
      protected var m_callback:Function;
      
      public function TBreedingProjectFinish(featureName:String, trayIndex:int, callback:Function = null)
      {
         this.m_featureName = featureName;
         this.m_trayIndex = trayIndex;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("BreedingService.finishBreedingProject",this.m_featureName,this.m_trayIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.quantityCreated))
         {
            BreedingManager.getInstance().finishBreedingProject(this.m_featureName,this.m_trayIndex,result.bredItemCode,result.quantityCreated);
            if(this.m_callback != null)
            {
               this.m_callback(result);
            }
         }
      }
   }
}

