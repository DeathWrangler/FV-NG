package Transactions
{
   public class TGetAddCraftingCrewReward extends TFarmTransaction
   {
      
      private var m_callback:Function;
      
      private var m_craftType:String;
      
      public function TGetAddCraftingCrewReward(craftType:String, callback:Function = null)
      {
         super();
         this.m_craftType = craftType;
         this.m_callback = callback;
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onGetAddCraftingCrewReward",this.m_craftType);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(null != this.m_callback)
         {
            result.craftType = this.m_craftType;
            this.m_callback(result);
         }
      }
   }
}

