package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Managers.CapitalOnePromoManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class CapitalOnePromoPlaceWindow extends FarmWindow
   {
      
      public function CapitalOnePromoPlaceWindow()
      {
         super(CapitalOnePromoManager.PROMO_PLACEMENT_WINDOW_ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window)
         {
            CapitalOnePromoManager.countConfirmationDialogImpression();
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","CapitalOnePromoPlaceWindow_Title"),true));
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","CapitalOnePromoPlaceWindow_Body"),true));
            addWidget(new FarmAnimatedTextButton(m_window.place_bt,ZLocUtils.t("Dialogs","PlaceNow"),this.onAcceptClick,false,true));
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         Global.player.setSeenFlag(CapitalOnePromoManager.PLACEMENT_REMINDER_SEEN);
         CapitalOnePromoManager.countConfirmationDialogClose();
         super.onClose(event);
      }
      
      private function onAcceptClick(event:Event) : void
      {
         CapitalOnePromoManager.countConfirmationDialogClick();
         Global.world.enterForcePlaceMode(CapitalOnePromoManager.PROMO_ITEM,false,Global.world.GIFTBOX_ID);
         Global.player.setSeenFlag(CapitalOnePromoManager.PLACEMENT_REMINDER_SEEN);
         close();
      }
   }
}

