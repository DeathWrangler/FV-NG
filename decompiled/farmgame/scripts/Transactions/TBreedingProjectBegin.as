package Transactions
{
   import Managers.BreedingManager;
   
   public class TBreedingProjectBegin extends TFarmTransaction
   {
      
      protected var m_featureName:String;
      
      protected var m_trayIndex:int;
      
      protected var m_ingredients:Object;
      
      protected var m_callback:Function;
      
      public function TBreedingProjectBegin(featureName:String, trayIndex:int, ingredients:Object, callback:Function = null)
      {
         this.m_featureName = featureName;
         this.m_trayIndex = trayIndex;
         this.m_ingredients = ingredients;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("BreedingService.beginNewBreedingProject",this.m_featureName,this.m_trayIndex,this.m_ingredients);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && Boolean(result.trayInfo))
         {
            result.trayInfo.itemCode = result.trayResult;
            BreedingManager.getInstance().addProject(result.featureName,result.trayIndex,result.trayInfo);
            if(this.m_callback != null)
            {
               this.m_callback();
            }
         }
      }
   }
}

