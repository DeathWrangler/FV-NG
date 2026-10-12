package Transactions
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class TGetOutBoundPromoUrl extends TFarmTransaction
   {
      
      protected var m_promoId:String = "";
      
      protected var m_promoUrl:String = "";
      
      public function TGetOutBoundPromoUrl(promoId:String)
      {
         this.m_promoId = promoId;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CrossPromoService.getOutBoundPromoUrl",this.m_promoId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var claimPopupMessage:String = null;
         var claimPopup:GenericPopup = null;
         if(result.promoUrl)
         {
            this.m_promoUrl = result.promoUrl;
            claimPopupMessage = ZLocUtils.t("Dialogs","CrossPromo_Start_" + this.m_promoId);
            claimPopup = new GenericPopup(claimPopupMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onCloseClaimPopup);
            UI.displayPopup(claimPopup);
         }
      }
      
      protected function onCloseClaimPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            Global.farmSocialNetwork.redirectTop(this.m_promoUrl,null,"_blank",false);
            FarmStatsManager.count("out_bound_cross_promo",this.m_promoId,"click_start_promo");
         }
         else
         {
            FarmStatsManager.count("out_bound_cross_promo",this.m_promoId,"click_cancel_promo");
         }
      }
   }
}

