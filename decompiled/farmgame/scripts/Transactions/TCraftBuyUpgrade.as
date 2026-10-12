package Transactions
{
   import Classes.crafting.CraftTypeState;
   
   public class TCraftBuyUpgrade extends TFarmTransaction
   {
      
      private var m_craftType:String;
      
      private var m_isRushUpgrade:Boolean;
      
      private var m_Callback:Function;
      
      public function TCraftBuyUpgrade(craftType:String, isRushUpgrade:Boolean, callback:Function = null)
      {
         this.m_craftType = craftType;
         this.m_isRushUpgrade = isRushUpgrade;
         this.m_Callback = callback;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CraftingService.onBuyCraftUpgrade",this.m_craftType,this.m_isRushUpgrade);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_Callback != null)
         {
            this.m_Callback(result);
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = super.getTransactionData();
         if(result == null)
         {
            result = {};
         }
         var craftTypeState:CraftTypeState = Global.player.craftingState.craftingSkillState.getCraftTypeState(this.m_craftType);
         if(craftTypeState)
         {
            result.method = "onBuyCraftUpgrade";
            result.nextLevel = craftTypeState.level;
            result.craftType = this.m_craftType;
         }
         return result;
      }
   }
}

