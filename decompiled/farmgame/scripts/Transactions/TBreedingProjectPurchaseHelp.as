package Transactions
{
   import Managers.BreedingManager;
   
   public class TBreedingProjectPurchaseHelp extends TFarmTransaction
   {
      
      protected var m_featureName:String;
      
      protected var m_trayIndex:int;
      
      protected var m_callback:Function;
      
      public function TBreedingProjectPurchaseHelp(featureName:String, trayIndex:int, callback:Function)
      {
         this.m_featureName = featureName;
         this.m_trayIndex = trayIndex;
         this.m_callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("BreedingService.addPurchasedHelp",this.m_featureName,this.m_trayIndex);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            BreedingManager.getInstance().addPurchasedHelp(this.m_featureName,this.m_trayIndex,result.price,result.amount);
            if(this.m_callback != null)
            {
               this.m_callback();
            }
         }
      }
   }
}

