package Widgets.Windows.Promotions
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.CapitalOnePromoManager;
   import Transactions.TSignedCallTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class CapitalOnePromoWindow extends FarmWindow
   {
      
      public function CapitalOnePromoWindow(isFromMarketAd:Boolean = false)
      {
         if(isFromMarketAd)
         {
            Global.player.setSeenFlag(CapitalOnePromoManager.MARKET_AD_SEEN,true);
            CapitalOnePromoManager.countMarketAdClick();
         }
         super(CapitalOnePromoManager.START_DIALOG_ASSET_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window)
         {
            CapitalOnePromoManager.countPromoStartDialogImpression();
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","CapitalOnePromoWindow_Accept"),this.onAcceptClick,false,true));
            if(Global.player.getSeenFlag(CapitalOnePromoManager.ITEM_RECEIVED))
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","CapitalOnePromoWindow_ItemAlreadyGranted_Title"),true));
               addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","CapitalOnePromoWindow_ItemAlreadyGranted_Body"),true));
            }
            else
            {
               addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","CapitalOnePromoWindow_ItemNotYetGranted_Title"),true));
               addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","CapitalOnePromoWindow_ItemNotYetGranted_Body"),true));
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
      }
      
      private function acceptPromo() : void
      {
         CapitalOnePromoManager.countStatueGifted();
         TransactionManager.addTransaction(new TSignedCallTransaction("PromoGiftService.addGiftsToGiftbox",["CapitalOne"],this.onAddPromoGiftCompleted),true);
         Global.player.addGift(CapitalOnePromoManager.PROMO_ITEM);
         UI.displayPopup(new CapitalOnePromoPlaceWindow());
      }
      
      private function onAcceptClick(event:Event) : void
      {
         if(!Global.player.getSeenFlag(CapitalOnePromoManager.ITEM_RECEIVED))
         {
            this.acceptPromo();
         }
         CapitalOnePromoManager.launchPromoURL();
         close();
      }
      
      private function onAddPromoGiftCompleted(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(CapitalOnePromoManager.ITEM_RECEIVED);
         }
      }
   }
}

