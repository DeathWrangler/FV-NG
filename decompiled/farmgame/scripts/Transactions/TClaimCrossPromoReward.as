package Transactions
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Windows.ThemedWindow;
   import flash.events.Event;
   
   public class TClaimCrossPromoReward extends TFarmTransaction
   {
      
      protected var m_promoId:String = "";
      
      protected var m_rewardUrl:String = "";
      
      protected var m_themedWindow:ThemedWindow = null;
      
      public function TClaimCrossPromoReward(promoId:String)
      {
         this.m_promoId = promoId;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CrossPromoService.claimReward",this.m_promoId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var themeXml:XML = null;
         var claimPopupMessage:String = null;
         var claimPopup:GenericPopup = null;
         if(result.rewardUrl)
         {
            this.m_rewardUrl = result.rewardUrl;
            themeXml = Global.farmGameSettingsManager.getWindowThemeXMLByCode(this.m_promoId);
            if(themeXml != null)
            {
               this.m_themedWindow = new ThemedWindow(ThemedWindow.BUTTON_SCHEME_ACCEPT_CANCEL);
               this.m_themedWindow.setTitleText(ZLocUtils.t("Dialogs","CrossPromo_Title"));
               this.m_themedWindow.setBodyText(ZLocUtils.t("Dialogs","CrossPromo_ItemText_" + this.m_promoId),ZLocUtils.t("Dialogs","CrossPromo_RewardText_" + this.m_promoId));
               this.m_themedWindow.setButtonText(ZLocUtils.t("Dialogs","Claim"),ZLocUtils.t("Dialogs","Cancel"));
               this.m_themedWindow.setTheme(themeXml.background.@url.toString());
               this.m_themedWindow.setIcon(themeXml.icon.@url.toString());
               this.m_themedWindow.setAcceptCallback(this.onWindowAccept);
               this.m_themedWindow.setCancelCallback(this.onWindowCancel);
               UI.displayPopup(this.m_themedWindow);
            }
            else
            {
               claimPopupMessage = ZLocUtils.t("Dialogs","CrossPromo_Congrats_" + this.m_promoId);
               claimPopup = new GenericPopup(claimPopupMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onCloseClaimPopup);
               claimPopup.setAcceptTextName("Claim");
               UI.displayPopup(claimPopup);
            }
         }
      }
      
      protected function onCloseClaimPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            GlobalEngine.socialNetwork.redirect(this.m_rewardUrl,null,"_blank",false);
         }
      }
      
      protected function onWindowAccept(event:Event) : void
      {
         GlobalEngine.socialNetwork.redirect(this.m_rewardUrl,null,"_blank",false);
      }
      
      protected function onWindowCancel(event:Event) : void
      {
         Global.hud.iconQueue.addIconToTop(this.m_promoId);
      }
   }
}

