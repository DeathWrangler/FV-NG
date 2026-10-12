package Transactions
{
   import Classes.EnglandOnboardingController;
   
   public class TSawPubDialog extends TFarmTransaction
   {
      
      private var m_currentWorldType:String = null;
      
      private var m_itemName:String = null;
      
      public function TSawPubDialog(currentWorldType:String, itemName:String)
      {
         super();
         this.m_currentWorldType = currentWorldType;
         this.m_itemName = itemName;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.seenPubDialog");
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result)
         {
            if(result.hasOwnProperty("success") && Boolean(result.success))
            {
               if(!result.hasItemInGiftBox)
               {
                  Global.player.addGift(this.m_itemName);
               }
               Global.player.incrementActionCount(EnglandOnboardingController.PUB_DIALOG_ACTION_COUNT,true);
               Global.world.enterForcePlaceMode(this.m_itemName);
            }
         }
      }
   }
}

