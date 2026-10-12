package Transactions
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Events.TransactionEvent;
   import Managers.FarmStatsManager;
   
   public class TGetGiftBoxErrors extends TFarmTransaction
   {
      
      private var m_giftboxError:int = 0;
      
      public function TGetGiftBoxErrors()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.getGiftboxErrorState");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var stringKey:String = null;
         this.m_giftboxError = result["giftboxError"] as int;
         dispatchEvent(new TransactionEvent(TransactionEvent.COMPLETED));
         if(this.m_giftboxError != 0)
         {
            switch(this.m_giftboxError)
            {
               case 1:
                  stringKey = "GiftboxError_Full_withEviction";
                  break;
               case 2:
                  stringKey = "GiftboxError_Full_noEviction";
                  break;
               case 3:
                  stringKey = "GiftboxError_Full_consumables";
            }
            UI.displayMessage(ZLocUtils.t("Dialogs",stringKey),GenericPopup.TYPE_OK,null,"",true);
            FarmStatsManager.count("giftbox_show_error_message",stringKey);
         }
      }
      
      public function get giftboxErrorState() : int
      {
         return this.m_giftboxError;
      }
   }
}

