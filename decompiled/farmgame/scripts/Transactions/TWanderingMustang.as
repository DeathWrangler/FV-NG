package Transactions
{
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.WanderingAnimalsManager;
   
   public class TWanderingMustang extends TFarmTransaction
   {
      
      public var m_rewardId:String;
      
      public function TWanderingMustang()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("WanderingAnimalService.onCreateMustangReward");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var iconURL:String = null;
         var promoMessage:String = null;
         var dialog:GenericIconPopup = null;
         if(Boolean(result) && Boolean(result.rewardId))
         {
            this.m_rewardId = result.rewardId;
            iconURL = Global.getAssetURL("assets/animals/animal_mustang_icon.png");
            promoMessage = ZLocUtils.t("Dialogs","wandering_mustang_appeared");
            dialog = new GenericIconPopup(promoMessage,GenericPopup.TYPE_ASKBUY,this.onWanderingMustangClose,iconURL,false,true,"wanderingMustangPopup",false,"assets/dialogs/FV_Feature_Callout_Mustang.swf");
            dialog.setAcceptTextName("wandering_mustang_ask_for_help");
            dialog.setCancelTextName("wandering_mustang_buy_help_button");
            UI.displayPopup(dialog,true,"wanderingMustangPopup",true);
            FarmStatsManager.count("wild_mustang","view_mustang");
         }
      }
      
      protected function onWanderingMustangClose(event:GenericPopupEvent) : void
      {
         var message:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            WanderingAnimalsManager.getInstance().onAskForHelp(this.m_rewardId);
         }
         else if(event.button == GenericPopup.CANCEL)
         {
            message = ZLocUtils.t("Dialogs","wandering_mustang_buy_help_message");
            WanderingAnimalsManager.getInstance().onBuyHelp(this.m_rewardId,message);
         }
      }
   }
}

