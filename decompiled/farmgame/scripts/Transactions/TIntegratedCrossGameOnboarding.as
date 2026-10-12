package Transactions
{
   public class TIntegratedCrossGameOnboarding extends TFarmTransaction
   {
      
      private var m_gameId:String;
      
      private var m_itemName:String;
      
      public function TIntegratedCrossGameOnboarding(itemName:String, gameId:String)
      {
         super();
         this.m_gameId = gameId;
         this.m_itemName = itemName;
      }
      
      override public function perform() : void
      {
         signedCall("IntegratedCrossGameGiftingService.grantOnboardingMailbox",this.m_gameId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null)
         {
            Global.player.addGift(this.m_itemName);
            Global.world.enterForcePlaceMode(this.m_itemName);
         }
      }
   }
}

