package Transactions
{
   public class TClaimMarketReward extends TFarmTransaction
   {
      
      private var m_Callback:Function;
      
      private var m_Picks:int;
      
      private var m_Selection:int;
      
      public function TClaimMarketReward(picks:int, selection:int, callBack:Function = null)
      {
         super();
         this.m_Callback = callBack;
         this.m_Picks = picks;
         this.m_Selection = selection;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onClaimReward",this.m_Selection,this.m_Picks);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != result)
         {
            if(null != this.m_Callback)
            {
               this.m_Callback();
            }
         }
      }
   }
}

