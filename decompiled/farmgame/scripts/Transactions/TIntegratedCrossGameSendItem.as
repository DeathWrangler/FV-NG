package Transactions
{
   import Classes.util.ZLocUtils;
   import Display.CrossPromoMailboxDialog;
   import Display.FarmDynamicDialog;
   import com.troyer.widget.view.TextFieldView;
   
   public class TIntegratedCrossGameSendItem extends TFarmTransaction
   {
      
      private var m_gameId:String = "";
      
      private var m_crossGameDialog:CrossPromoMailboxDialog = null;
      
      private var m_giftName:String;
      
      public function TIntegratedCrossGameSendItem(gameId:String, giftName:String, crossGameDialog:CrossPromoMailboxDialog)
      {
         super();
         this.m_gameId = gameId;
         this.m_giftName = giftName;
         this.m_crossGameDialog = crossGameDialog;
      }
      
      override public function perform() : void
      {
         signedCall("IntegratedCrossGameGiftingService.sendGiftToTargetGame",this.m_gameId,this.m_giftName);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var dialog:FarmDynamicDialog = null;
         var message:String = null;
         if(result != null)
         {
            dialog = FarmDynamicDialog.createDialog("XPromoOnboardingDialog",FarmDynamicDialog);
            dialog.setShortcutAttribute("titletext",TextFieldView.ATTRIBUTE_TEXT,"Congratulations");
            message = ZLocUtils.t_pk("Dialogs:SentGiftText",null,{"item":ZLocUtils.tk_pk("Dialogs:" + this.m_giftName + "_friendlyName")});
            dialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,message);
            dialog.setShortcutAttribute("okayButton",TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","Okay"));
            dialog.setup();
            dialog.show();
         }
      }
   }
}

