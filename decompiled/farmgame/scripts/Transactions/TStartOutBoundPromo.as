package Transactions
{
   import Classes.Constants.CrossPromoConstants;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class TStartOutBoundPromo extends TFarmTransaction
   {
      
      protected var m_promoId:String = "";
      
      protected var m_promoUrl:String = "";
      
      public function TStartOutBoundPromo(promoId:String)
      {
         this.m_promoId = promoId;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("CrossPromoService.startOutBoundPromo",this.m_promoId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var claimPopupMessage:String = null;
         var iconPath:String = null;
         var claimPopup:GenericIconPopup = null;
         if(result.promoUrl)
         {
            this.m_promoUrl = result.promoUrl;
            claimPopupMessage = ZLocUtils.t("Dialogs","CrossPromo_Start_" + this.m_promoId);
            iconPath = CrossPromoConstants.BASE_BG_PATH + this.m_promoId + "_dialogIcon.png";
            iconPath = Global.getAssetURL(iconPath);
            claimPopup = new GenericIconPopup(claimPopupMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onCloseClaimPopup,iconPath);
            UI.displayPopup(claimPopup);
            FarmStatsManager.count(this.m_promoId,"dialog","impressions");
         }
      }
      
      protected function onCloseClaimPopup(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count(this.m_promoId,"dialog","visit");
            Global.farmSocialNetwork.redirectTop(this.m_promoUrl,null,"_blank",false);
         }
         else
         {
            FarmStatsManager.count(this.m_promoId,"dialog","cancel");
         }
      }
   }
}

